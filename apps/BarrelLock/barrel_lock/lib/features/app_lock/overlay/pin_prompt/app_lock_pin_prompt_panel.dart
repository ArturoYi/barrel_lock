import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock/shared/widgets/numeric_keyboard_listener.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'app_lock_pin_keypad.dart';
import 'layout/app_lock_pin_prompt_landscape_layout.dart';
import 'layout/app_lock_pin_prompt_portrait_layout.dart';

/// PIN 输入 Overlay 面板（MVVM-C 的 V 层，复用 [appLockPinPromptProvider]）。
final class AppLockPinPromptPanel extends ConsumerStatefulWidget {
  const AppLockPinPromptPanel({super.key, required this.state});

  final AppLockPinPromptState state;

  @override
  ConsumerState<AppLockPinPromptPanel> createState() =>
      _AppLockPinPromptPanelState();
}

class _AppLockPinPromptPanelState extends ConsumerState<AppLockPinPromptPanel> {
  String _pinBuffer = '';
  var _biometricRetryAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricAvailability();
  }

  Future<void> _loadBiometricAvailability() async {
    final availability = await ref
        .read(appLockAuthServiceProvider)
        .checkBiometricAvailability();
    if (!mounted) {
      return;
    }
    setState(() {
      _biometricRetryAvailable =
          availability == BiometricAvailability.available;
    });
  }

  @override
  void didUpdateWidget(covariant AppLockPinPromptPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.attempt != widget.state.attempt) {
      _pinBuffer = '';
    }
  }

  void _submitPinIfReady() {
    if (widget.state.isSubmitting ||
        _pinBuffer.length < AppLockPinPolicy.length) {
      return;
    }
    ref.read(appLockPinPromptProvider.notifier).submitPin(_pinBuffer);
  }

  void _cancel() {
    ref.read(appLockPinPromptProvider.notifier).cancel();
  }

  void _retryBiometric() {
    ref.read(appLockSessionProvider.notifier).retryBiometricFromPinPrompt();
  }

  void _toggleObscure() {
    ref.read(appLockPinPromptProvider.notifier).toggleObscure();
  }

  void _onDigitPressed(int digit) {
    if (widget.state.isSubmitting ||
        _pinBuffer.length >= AppLockPinPolicy.length) {
      return;
    }
    setState(() {
      _pinBuffer += '$digit';
    });
    if (_pinBuffer.length >= AppLockPinPolicy.length) {
      _submitPinIfReady();
    }
  }

  void _onDeletePressed() {
    if (widget.state.isSubmitting || _pinBuffer.isEmpty) {
      return;
    }
    setState(() {
      _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isSubmitting = state.isSubmitting;

    return NumericKeyboardListener(
      enabled: !isSubmitting,
      onDigitPressed: _onDigitPressed,
      onDeletePressed: _onDeletePressed,
      onSubmit: _submitPinIfReady,
      onCancel: _cancel,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              final layout = switch (orientation) {
                Orientation.portrait => AppLockPinPromptPortraitLayout(
                  state: state,
                  pinBuffer: _pinBuffer,
                  isSubmitting: isSubmitting,
                  onCancel: _cancel,
                  onToggleObscure: _toggleObscure,
                  onDigitPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                  onRetryBiometric: _retryBiometric,
                  showBiometricRetry: _biometricRetryAvailable,
                ),
                Orientation.landscape => AppLockPinPromptLandscapeLayout(
                  state: state,
                  pinBuffer: _pinBuffer,
                  isSubmitting: isSubmitting,
                  onCancel: _cancel,
                  onToggleObscure: _toggleObscure,
                  onDigitPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                  onRetryBiometric: _retryBiometric,
                  showBiometricRetry: _biometricRetryAvailable,
                ),
              };

              return KeyedSubtree(
                key: ValueKey<int>(state.attempt),
                child: layout,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 竖屏 / 横屏布局共用的 PIN 输入区骨架（自定义键盘，无系统输入框）。
final class AppLockPinPromptInputSection extends StatelessWidget {
  const AppLockPinPromptInputSection({
    super.key,
    required this.state,
    required this.pinBuffer,
    required this.isSubmitting,
    required this.onToggleObscure,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onRetryBiometric,
    required this.showBiometricRetry,
  });

  final AppLockPinPromptState state;
  final String pinBuffer;
  final bool isSubmitting;
  final VoidCallback onToggleObscure;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onRetryBiometric;
  final bool showBiometricRetry;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final keypad = AppLockPinKeypad(
      onDigitPressed: onDigitPressed,
      leadingKey: showBiometricRetry
          ? AppLockPinKeyAction(
              child: const Icon(Icons.fingerprint),
              onPressed: onRetryBiometric,
              semanticLabel: '生物识别',
            )
          : null,
      trailingKey: AppLockPinKeyAction(
        child: const Icon(Icons.backspace_outlined),
        onPressed: onDeletePressed,
        semanticLabel: '删除',
      ),
      enabled: !isSubmitting,
      isFull: pinBuffer.length >= AppLockPinPolicy.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: isLandscape ? MainAxisSize.max : MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        if (isLandscape) Expanded(child: keypad) else keypad,
      ],
    );
  }
}

/// 竖屏 / 横屏布局共用的标题区骨架。
final class AppLockPinPromptHeaderSection extends StatelessWidget {
  const AppLockPinPromptHeaderSection({
    super.key,
    this.state,
    this.message,
    this.isError = false,
  }) : assert(state != null || message != null);

  final AppLockPinPromptState? state;
  final String? message;
  final bool isError;

  String get _message => message ?? state!.headerMessage;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Text(
      _message,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }
}
