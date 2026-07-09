import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'layout/app_lock_enable_setup_landscape_layout.dart';
import 'layout/app_lock_enable_setup_portrait_layout.dart';
import 'widgets/app_lock_enable_setup_form.dart';
import 'widgets/app_lock_enable_setup_hint_form.dart';

/// 监听 [appLockEnableSetupProvider]，在设置页上叠加开启验证 Panel。
final class AppLockEnableSetupHost extends ConsumerStatefulWidget {
  const AppLockEnableSetupHost({super.key});

  @override
  ConsumerState<AppLockEnableSetupHost> createState() =>
      _AppLockEnableSetupHostState();
}

class _AppLockEnableSetupHostState
    extends ConsumerState<AppLockEnableSetupHost> {
  late final PageController _pageController;
  late final TextEditingController _pinController;
  late final TextEditingController _confirmPinController;
  late final TextEditingController _hintController;
  late final FocusNode _pinFocusNode;
  late final FocusNode _hintFocusNode;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pinController = TextEditingController();
    _confirmPinController = TextEditingController();
    _hintController = TextEditingController();
    _pinFocusNode = FocusNode();
    _hintFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pinFocusNode.dispose();
    _hintFocusNode.dispose();
    _hintController.dispose();
    _confirmPinController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _clearInputs() {
    _pinFocusNode.unfocus();
    _hintFocusNode.unfocus();
    _pinController.clear();
    _confirmPinController.clear();
    _hintController.clear();
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _continueToHint() {
    _pinFocusNode.unfocus();
    ref
        .read(appLockEnableSetupProvider.notifier)
        .continueToHintStep(
          pin: _pinController.text,
          confirmPin: _confirmPinController.text,
        );
  }

  void _submitSetup() {
    _hintFocusNode.unfocus();
    ref
        .read(appLockEnableSetupProvider.notifier)
        .submitSetup(
          pin: _pinController.text,
          confirmPin: _confirmPinController.text,
          hint: _hintController.text,
        );
  }

  void _backToPinStep() {
    _hintFocusNode.unfocus();
    ref.read(appLockEnableSetupProvider.notifier).backToPinStep();
  }

  void _cancel() {
    _pinFocusNode.unfocus();
    _hintFocusNode.unfocus();
    ref.read(appLockEnableSetupProvider.notifier).cancel();
    _clearInputs();
  }

  void _onBack() {
    final step = ref.read(appLockEnableSetupProvider).step;
    if (step == AppLockEnableSetupStep.hint) {
      _backToPinStep();
      return;
    }
    _cancel();
  }

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

  void _requestFocusForStep(AppLockEnableSetupStep step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final focusNode = switch (step) {
        AppLockEnableSetupStep.pin => _pinFocusNode,
        AppLockEnableSetupStep.hint => _hintFocusNode,
      };
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appLockEnableSetupProvider);
    if (!state.isVisible) {
      return const SizedBox.shrink();
    }

    ref.listen(appLockEnableSetupProvider, (previous, next) {
      if (previous?.isVisible == true && !next.isVisible) {
        _clearInputs();
      }
      if (previous?.phase != AppLockEnableSetupPhase.active &&
          next.phase == AppLockEnableSetupPhase.active) {
        _requestFocusForStep(next.step);
      }
      if (previous?.step != next.step) {
        _syncPageToStep(next.step);
        if (next.phase == AppLockEnableSetupPhase.active) {
          _requestFocusForStep(next.step);
        }
      }
    });

    final theme = Theme.of(context);
    final pinPage = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '开启应用保护前，请先设置 ${AppLockPinPolicy.length} 位数字密码作为兜底解锁方式。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          AppLockEnableSetupForm(
            state: state,
            pinController: _pinController,
            confirmPinController: _confirmPinController,
            pinFocusNode: _pinFocusNode,
            onSubmit: _continueToHint,
            onCancel: _cancel,
            onToggleObscurePin: () =>
                ref.read(appLockEnableSetupProvider.notifier).toggleObscurePin(),
            onToggleObscureConfirmPin: () => ref
                .read(appLockEnableSetupProvider.notifier)
                .toggleObscureConfirmPin(),
          ),
        ],
      ),
    );
    final hintPage = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '设置一句提示语，忘记密码时可帮助你回忆备用密码。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          AppLockEnableSetupHintForm(
            state: state,
            hintController: _hintController,
            hintFocusNode: _hintFocusNode,
            onSubmit: _submitSetup,
            onBack: _backToPinStep,
          ),
        ],
      ),
    );

    return OrientationBuilder(
      builder: (context, orientation) {
        final panel = switch (orientation) {
          Orientation.portrait => AppLockEnableSetupPortraitLayout(
            state: state,
            pageController: _pageController,
            pinPage: pinPage,
            hintPage: hintPage,
            onBack: _onBack,
          ),
          Orientation.landscape => AppLockEnableSetupLandscapeLayout(
            state: state,
            pageController: _pageController,
            pinPage: pinPage,
            hintPage: hintPage,
            onBack: _onBack,
          ),
        };
        return FocusScope(child: panel);
      },
    );
  }
}
