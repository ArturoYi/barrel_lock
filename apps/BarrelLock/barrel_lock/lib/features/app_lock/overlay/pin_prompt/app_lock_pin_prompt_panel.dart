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

  @override
  void didUpdateWidget(covariant AppLockPinPromptPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.attempt != widget.state.attempt) {
      _pinBuffer = '';
    }
  }

  void _submitPin() {
    ref.read(appLockPinPromptProvider.notifier).submitPin(_pinBuffer);
  }

  void _cancel() {
    ref.read(appLockPinPromptProvider.notifier).cancel();
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
  }

  void _onDeletePressed() {
    if (widget.state.isSubmitting || _pinBuffer.isEmpty) {
      return;
    }
    setState(() {
      _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1);
    });
  }

  void _onClearPressed() {
    if (widget.state.isSubmitting || _pinBuffer.isEmpty) {
      return;
    }
    setState(() {
      _pinBuffer = '';
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
      onSubmit: _submitPin,
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
                  onSubmit: _submitPin,
                  onCancel: _cancel,
                  onToggleObscure: _toggleObscure,
                  onDigitPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                  onClearPressed: _onClearPressed,
                ),
                Orientation.landscape => AppLockPinPromptLandscapeLayout(
                  state: state,
                  pinBuffer: _pinBuffer,
                  isSubmitting: isSubmitting,
                  onSubmit: _submitPin,
                  onCancel: _cancel,
                  onToggleObscure: _toggleObscure,
                  onDigitPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                  onClearPressed: _onClearPressed,
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
    required this.onSubmit,
    required this.onToggleObscure,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
  });

  final AppLockPinPromptState state;
  final String pinBuffer;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onToggleObscure;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;

  String get _displayPin {
    if (state.obscurePin) {
      return List.filled(pinBuffer.length, '●').join();
    }
    return pinBuffer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: '应用内密码',
                value: _displayPin,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _displayPin.isEmpty ? ' ' : _displayPin,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      letterSpacing: 8,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: isSubmitting ? null : onToggleObscure,
              icon: Icon(
                state.obscurePin ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppLockPinKeypad(
          onDigitPressed: onDigitPressed,
          onDeletePressed: onDeletePressed,
          onClearPressed: onClearPressed,
          enabled: !isSubmitting,
          isFull: pinBuffer.length >= AppLockPinPolicy.length,
        ),
        if (state.errorMessage case final message?) ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: isSubmitting ? null : onSubmit,
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('确认'),
        ),
      ],
    );
  }
}

/// 竖屏 / 横屏布局共用的标题区骨架。
final class AppLockPinPromptHeaderSection extends StatelessWidget {
  const AppLockPinPromptHeaderSection({super.key, required this.state});

  final AppLockPinPromptState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('输入应用内密码', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          state.reason.defaultMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
