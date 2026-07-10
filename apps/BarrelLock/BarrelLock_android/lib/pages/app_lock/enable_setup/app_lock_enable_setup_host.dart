import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'landscape/app_lock_enable_setup_landscape_layout.dart';
import 'portrait/app_lock_enable_setup_portrait_layout.dart';
import 'shared/app_lock_enable_setup_pin_input_field.dart';

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

  /// 确认密码缓冲。
  String _confirmPinBuffer = '';

  /// 当前聚焦的密码框；决定键盘输入目标。
  AppLockEnableSetupPinInputField _activePinField =
      AppLockEnableSetupPinInputField.pin;

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
    _clearPinBuffers();
  }

  /// 仅清空 PIN 相关缓冲，保留提示语 Controller（步骤回退时 PIN 仍有效）。
  void _clearPinBuffers() {
    setState(() {
      _pinBuffer = '';
      _confirmPinBuffer = '';
      _activePinField = AppLockEnableSetupPinInputField.pin;
    });
  }

  /// 当前聚焦框对应的 PIN 缓冲，供键盘满位判断使用。
  String get _activePinBuffer => switch (_activePinField) {
    AppLockEnableSetupPinInputField.pin => _pinBuffer,
    AppLockEnableSetupPinInputField.confirmPin => _confirmPinBuffer,
  };

  /// 数字键按下：向当前聚焦框追加一位数字。
  ///
  /// 主密码填满 [AppLockPinPolicy.length] 位后自动切换到确认密码框。
  /// 提交中或当前框已满时忽略输入。
  void _onDigitPressed(int digit) {
    final state = ref.read(appLockEnableSetupProvider);
    if (state.isBusy || _activePinBuffer.length >= AppLockPinPolicy.length) {
      return;
    }
    setState(() {
      if (_activePinField == AppLockEnableSetupPinInputField.pin) {
        _pinBuffer += '$digit';
        if (_pinBuffer.length >= AppLockPinPolicy.length) {
          _activePinField = AppLockEnableSetupPinInputField.confirmPin;
        }
      } else {
        _confirmPinBuffer += '$digit';
      }
    });
  }

  /// 退格键按下：删除当前聚焦框末位。
  ///
  /// 确认密码框为空时，回退到主密码框并删除主密码末位（连贯退格体验）。
  void _onDeletePressed() {
    final state = ref.read(appLockEnableSetupProvider);
    if (state.isBusy) {
      return;
    }
    setState(() {
      switch (_activePinField) {
        case AppLockEnableSetupPinInputField.pin:
          if (_pinBuffer.isEmpty) {
            return;
          }
          _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1);
        case AppLockEnableSetupPinInputField.confirmPin:
          if (_confirmPinBuffer.isEmpty) {
            // 确认框已空 → 回退到主密码框并删主密码末位
            _activePinField = AppLockEnableSetupPinInputField.pin;
            if (_pinBuffer.isNotEmpty) {
              _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1);
            }
            return;
          }
          _confirmPinBuffer = _confirmPinBuffer.substring(
            0,
            _confirmPinBuffer.length - 1,
          );
      }
    });
  }

  /// 清空键按下：清空当前聚焦框的全部内容（不影响另一框）。
  void _onClearPressed() {
    final state = ref.read(appLockEnableSetupProvider);
    if (state.isBusy) {
      return;
    }
    setState(() {
      switch (_activePinField) {
        case AppLockEnableSetupPinInputField.pin:
          _pinBuffer = '';
        case AppLockEnableSetupPinInputField.confirmPin:
          _confirmPinBuffer = '';
      }
    });
  }

  /// 用户点击密码展示框时切换聚焦目标。
  void _onActivePinFieldChanged(AppLockEnableSetupPinInputField field) {
    setState(() => _activePinField = field);
  }

  /// 校验 PIN 并通知 ViewModel 进入提示语步骤。
  void _continueToHint() {
    ref
        .read(appLockEnableSetupProvider.notifier)
        .continueToHintStep(pin: _pinBuffer, confirmPin: _confirmPinBuffer);
  }

  /// 提交 PIN + 提示语，由 ViewModel 落盘并开启应用保护。
  void _submitSetup() {
    _hintFocusNode.unfocus();
    ref
        .read(appLockEnableSetupProvider.notifier)
        .submitSetup(
          pin: _pinBuffer,
          confirmPin: _confirmPinBuffer,
          hint: _hintController.text,
        );
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
      confirmPinBuffer: _confirmPinBuffer,
      activePinField: _activePinField,
      activePinBuffer: _activePinBuffer,
      hintController: _hintController,
      hintFocusNode: _hintFocusNode,
      onDigitPressed: _onDigitPressed,
      onDeletePressed: _onDeletePressed,
      onClearPressed: _onClearPressed,
      onContinueToHint: _continueToHint,
      onSubmitSetup: _submitSetup,
      onBackToPinStep: _backToPinStep,
      onCancel: _cancel,
      onBack: _onBack,
      onActivePinFieldChanged: _onActivePinFieldChanged,
      onToggleObscurePin: ref
          .read(appLockEnableSetupProvider.notifier)
          .toggleObscurePin,
      onToggleObscureConfirmPin: ref
          .read(appLockEnableSetupProvider.notifier)
          .toggleObscureConfirmPin,
    );

    return OrientationBuilder(
      key: const ValueKey('visible'),
      builder: (context, orientation) {
        return switch (orientation) {
          Orientation.portrait => AppLockEnableSetupPortraitLayout(
            state: layoutProps.state,
            pageController: layoutProps.pageController,
            pinBuffer: layoutProps.pinBuffer,
            confirmPinBuffer: layoutProps.confirmPinBuffer,
            activePinField: layoutProps.activePinField,
            activePinBuffer: layoutProps.activePinBuffer,
            hintController: layoutProps.hintController,
            hintFocusNode: layoutProps.hintFocusNode,
            onDigitPressed: layoutProps.onDigitPressed,
            onDeletePressed: layoutProps.onDeletePressed,
            onClearPressed: layoutProps.onClearPressed,
            onContinueToHint: layoutProps.onContinueToHint,
            onSubmitSetup: layoutProps.onSubmitSetup,
            onBackToPinStep: layoutProps.onBackToPinStep,
            onCancel: layoutProps.onCancel,
            onBack: layoutProps.onBack,
            onActivePinFieldChanged: layoutProps.onActivePinFieldChanged,
            onToggleObscurePin: layoutProps.onToggleObscurePin,
            onToggleObscureConfirmPin: layoutProps.onToggleObscureConfirmPin,
          ),
          Orientation.landscape => AppLockEnableSetupLandscapeLayout(
            state: layoutProps.state,
            pageController: layoutProps.pageController,
            pinBuffer: layoutProps.pinBuffer,
            confirmPinBuffer: layoutProps.confirmPinBuffer,
            activePinField: layoutProps.activePinField,
            activePinBuffer: layoutProps.activePinBuffer,
            hintController: layoutProps.hintController,
            hintFocusNode: layoutProps.hintFocusNode,
            onDigitPressed: layoutProps.onDigitPressed,
            onDeletePressed: layoutProps.onDeletePressed,
            onClearPressed: layoutProps.onClearPressed,
            onContinueToHint: layoutProps.onContinueToHint,
            onSubmitSetup: layoutProps.onSubmitSetup,
            onBackToPinStep: layoutProps.onBackToPinStep,
            onCancel: layoutProps.onCancel,
            onBack: layoutProps.onBack,
            onActivePinFieldChanged: layoutProps.onActivePinFieldChanged,
            onToggleObscurePin: layoutProps.onToggleObscurePin,
            onToggleObscureConfirmPin: layoutProps.onToggleObscureConfirmPin,
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
