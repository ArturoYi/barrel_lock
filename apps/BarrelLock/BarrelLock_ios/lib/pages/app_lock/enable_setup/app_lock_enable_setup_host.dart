import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'landscape/app_lock_enable_setup_landscape_layout.dart';
import 'portrait/app_lock_enable_setup_portrait_layout.dart';

/// 开启验证流程的 Host 组件（MVVM-C 的 V 层入口）。
///
/// 挂载于 [AppLockSettingsPage] 的 Stack 顶层，监听
/// [appLockEnableSetupProvider]，在 `phase != idle` 时叠加全屏 Panel。
///
/// ## 职责划分
///
/// | 本组件 (Host) | Layout / Page 子组件 |
/// |---|---|
/// | PIN 缓冲、提示语 Controller | UI 布局与渲染 |
/// | PageController 与 step 同步 | 接收回调、展示状态 |
/// | 键盘/按钮事件 → ViewModel | 无业务逻辑 |
/// | 横竖屏 Layout 选择 | 各方向独立 Page 实现 |
///
/// 业务校验与落盘由 [AppLockEnableSetupViewModel] 处理，导航由 Coordinator 处理。
final class AppLockEnableSetupHost extends ConsumerStatefulWidget {
  const AppLockEnableSetupHost({super.key});

  @override
  ConsumerState<AppLockEnableSetupHost> createState() =>
      _AppLockEnableSetupHostState();
}

class _AppLockEnableSetupHostState
    extends ConsumerState<AppLockEnableSetupHost> {
  /// 驱动 PIN / 提示语两步 PageView 的控制器。
  late final PageController _pageController;

  /// 提示语步骤的文本输入控制器。
  late final TextEditingController _hintController;

  /// 提示语输入框焦点；进入 hint 步骤时自动请求。
  late final FocusNode _hintFocusNode;

  /// 主密码缓冲（自定义键盘写入，非 TextField）。
  String _pinBuffer = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _hintController = TextEditingController();
    _hintFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _hintFocusNode.dispose();
    _hintController.dispose();
    super.dispose();
  }

  /// 重置全部本地输入状态（取消或流程结束时调用）。
  ///
  /// 包括：收起提示语焦点、清空提示语文本、PageView 跳回第 0 页、清空 PIN 缓冲。
  void _clearInputs() {
    _hintFocusNode.unfocus();
    _hintController.clear();
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _clearPinBuffer();
  }

  /// 仅清空 PIN 缓冲，保留提示语 Controller（步骤回退时 PIN 仍有效）。
  void _clearPinBuffer() {
    setState(() {
      _pinBuffer = '';
    });
  }

  /// 数字键按下：向 PIN 缓冲追加一位数字。
  ///
  /// 提交中或已满位时忽略输入。
  void _onDigitPressed(int digit) {
    final state = ref.read(appLockEnableSetupProvider);
    if (state.isBusy || _pinBuffer.length >= AppLockPinPolicy.length) {
      return;
    }
    setState(() {
      _pinBuffer += '$digit';
    });
  }

  /// 退格键按下：删除 PIN 缓冲末位。
  void _onDeletePressed() {
    final state = ref.read(appLockEnableSetupProvider);
    if (state.isBusy || _pinBuffer.isEmpty) {
      return;
    }
    setState(() {
      _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1);
    });
  }

  /// 校验 PIN 并通知 ViewModel 进入提示语步骤。
  void _continueToHint() {
    ref
        .read(appLockEnableSetupProvider.notifier)
        .continueToHintStep(pin: _pinBuffer);
  }

  /// 提交 PIN + 提示语，由 ViewModel 落盘并开启应用保护。
  void _submitSetup() {
    _hintFocusNode.unfocus();
    ref
        .read(appLockEnableSetupProvider.notifier)
        .submitSetup(pin: _pinBuffer, hint: _hintController.text);
  }

  /// 从提示语步骤返回 PIN 步骤（ViewModel 切换 step，不清 PIN 缓冲）。
  void _backToPinStep() {
    _hintFocusNode.unfocus();
    ref.read(appLockEnableSetupProvider.notifier).backToPinStep();
  }

  /// 取消整个开启验证流程，重置本地输入。
  void _cancel() {
    _hintFocusNode.unfocus();
    ref.read(appLockEnableSetupProvider.notifier).cancel();
    _clearInputs();
  }

  /// AppBar 返回按钮逻辑：hint 步骤回退 PIN，pin 步骤取消流程。
  void _onBack() {
    final step = ref.read(appLockEnableSetupProvider).step;
    if (step == AppLockEnableSetupStep.hint) {
      _backToPinStep();
      return;
    }
    _cancel();
  }

  /// 将 ViewModel 的 [AppLockEnableSetupStep] 同步到 PageView 页码。
  ///
  /// pin → 0，hint → 1；仅在页码不一致时执行动画，避免重复触发。
  void _syncPageToStep(AppLockEnableSetupStep step) {
    if (!_pageController.hasClients) {
      return;
    }
    final targetPage = switch (step) {
      AppLockEnableSetupStep.pin => 0,
      AppLockEnableSetupStep.hint => 1,
    };
    if (_pageController.page?.round() != targetPage) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 进入提示语步骤后，在下一帧自动聚焦提示语输入框。
  void _requestFocusForStep(AppLockEnableSetupStep step) {
    if (step != AppLockEnableSetupStep.hint) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (_hintFocusNode.canRequestFocus) {
        _hintFocusNode.requestFocus();
      }
    });
  }

  /// 根据当前屏幕方向，组装横屏或竖屏 Layout 并传入全部绑定参数。
  Widget _buildLayout(AppLockEnableSetupState state) {
    // 用 record 聚合回调，避免横竖屏 switch 中重复书写
    final layoutProps = (
      state: state,
      pageController: _pageController,
      pinBuffer: _pinBuffer,
      hintController: _hintController,
      hintFocusNode: _hintFocusNode,
      onDigitPressed: _onDigitPressed,
      onDeletePressed: _onDeletePressed,
      onContinueToHint: _continueToHint,
      onSubmitSetup: _submitSetup,
      onBackToPinStep: _backToPinStep,
      onCancel: _cancel,
      onBack: _onBack,
      onToggleObscurePin: ref
          .read(appLockEnableSetupProvider.notifier)
          .toggleObscurePin,
    );

    return OrientationBuilder(
      key: const ValueKey('visible'),
      builder: (context, orientation) {
        return switch (orientation) {
          Orientation.portrait => AppLockEnableSetupPortraitLayout(
            state: layoutProps.state,
            pageController: layoutProps.pageController,
            pinBuffer: layoutProps.pinBuffer,
            hintController: layoutProps.hintController,
            hintFocusNode: layoutProps.hintFocusNode,
            onDigitPressed: layoutProps.onDigitPressed,
            onDeletePressed: layoutProps.onDeletePressed,
            onContinueToHint: layoutProps.onContinueToHint,
            onSubmitSetup: layoutProps.onSubmitSetup,
            onBack: layoutProps.onBack,
            onToggleObscurePin: layoutProps.onToggleObscurePin,
          ),
          Orientation.landscape => AppLockEnableSetupLandscapeLayout(
            state: layoutProps.state,
            pageController: layoutProps.pageController,
            pinBuffer: layoutProps.pinBuffer,
            hintController: layoutProps.hintController,
            hintFocusNode: layoutProps.hintFocusNode,
            onDigitPressed: layoutProps.onDigitPressed,
            onDeletePressed: layoutProps.onDeletePressed,
            onContinueToHint: layoutProps.onContinueToHint,
            onSubmitSetup: layoutProps.onSubmitSetup,
            onBackToPinStep: layoutProps.onBackToPinStep,
            onCancel: layoutProps.onCancel,
            onBack: layoutProps.onBack,
            onToggleObscurePin: layoutProps.onToggleObscurePin,
          ),
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appLockEnableSetupProvider);

    // 副作用监听：步骤切换同步 PageView，流程结束时清空输入
    ref.listen(appLockEnableSetupProvider, (previous, next) {
      if (previous?.step != next.step) {
        _syncPageToStep(next.step);
        if (next.phase == AppLockEnableSetupPhase.active) {
          _requestFocusForStep(next.step);
        }
      }
      if (previous?.isVisible == true && !next.isVisible) {
        _clearInputs();
      }
    });

    // AnimatedSwitcher 实现 Panel 显隐过渡；layoutBuilder 使用 Stack 避免布局跳动
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [...previousChildren, ?currentChild],
        );
      },
      child: state.isVisible
          ? _buildLayout(state)
          : const SizedBox.shrink(key: ValueKey('hidden')),
    );
  }
}
