import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'layout/app_lock_enable_setup_landscape_layout.dart';
import 'layout/app_lock_enable_setup_portrait_layout.dart';

/// 监听 [appLockEnableSetupProvider]，在设置页上叠加开启验证 Panel。
final class AppLockEnableSetupHost extends ConsumerStatefulWidget {
  const AppLockEnableSetupHost({super.key});

  @override
  ConsumerState<AppLockEnableSetupHost> createState() =>
      _AppLockEnableSetupHostState();
}

class _AppLockEnableSetupHostState
    extends ConsumerState<AppLockEnableSetupHost> {
  late final TextEditingController _pinController;
  late final TextEditingController _confirmPinController;
  late final FocusNode _pinFocusNode;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _confirmPinController = TextEditingController();
    _pinFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pinFocusNode.unfocus();
    _pinFocusNode.dispose();
    _confirmPinController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _clearInputs() {
    _pinFocusNode.unfocus();
    _pinController.clear();
    _confirmPinController.clear();
  }

  void _submit() {
    _pinFocusNode.unfocus();
    ref
        .read(appLockEnableSetupProvider.notifier)
        .submitPin(
          pin: _pinController.text,
          confirmPin: _confirmPinController.text,
        );
  }

  void _cancel() {
    _pinFocusNode.unfocus();
    ref.read(appLockEnableSetupProvider.notifier).cancel();
    _clearInputs();
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pinFocusNode.canRequestFocus) {
            _pinFocusNode.requestFocus();
          }
        });
      }
    });

    final layoutProps = (
      state: state,
      pinController: _pinController,
      confirmPinController: _confirmPinController,
      pinFocusNode: _pinFocusNode,
      onSubmit: _submit,
      onCancel: _cancel,
      onToggleObscurePin: () =>
          ref.read(appLockEnableSetupProvider.notifier).toggleObscurePin(),
      onToggleObscureConfirmPin: () => ref
          .read(appLockEnableSetupProvider.notifier)
          .toggleObscureConfirmPin(),
    );

    return OrientationBuilder(
      builder: (context, orientation) {
        final panel = switch (orientation) {
          Orientation.portrait => AppLockEnableSetupPortraitLayout(
            state: layoutProps.state,
            pinController: layoutProps.pinController,
            confirmPinController: layoutProps.confirmPinController,
            pinFocusNode: layoutProps.pinFocusNode,
            onSubmit: layoutProps.onSubmit,
            onCancel: layoutProps.onCancel,
            onToggleObscurePin: layoutProps.onToggleObscurePin,
            onToggleObscureConfirmPin: layoutProps.onToggleObscureConfirmPin,
          ),
          Orientation.landscape => AppLockEnableSetupLandscapeLayout(
            state: layoutProps.state,
            pinController: layoutProps.pinController,
            confirmPinController: layoutProps.confirmPinController,
            pinFocusNode: layoutProps.pinFocusNode,
            onSubmit: layoutProps.onSubmit,
            onCancel: layoutProps.onCancel,
            onToggleObscurePin: layoutProps.onToggleObscurePin,
            onToggleObscureConfirmPin: layoutProps.onToggleObscureConfirmPin,
          ),
        };
        return FocusScope(child: panel);
      },
    );
  }
}
