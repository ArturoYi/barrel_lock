import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

/// 开启验证提示语输入表单（PageView 第二步）。
final class AppLockEnableSetupHintForm extends StatelessWidget {
  const AppLockEnableSetupHintForm({
    super.key,
    required this.state,
    required this.hintController,
    required this.hintFocusNode,
    required this.onSubmit,
    required this.onBack,
  });

  final AppLockEnableSetupState state;
  final TextEditingController hintController;
  final FocusNode hintFocusNode;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = state.isBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: hintController,
          focusNode: hintFocusNode,
          enabled: !isBusy,
          textInputAction: TextInputAction.done,
          maxLength: AppLockPinPolicy.hintMaxLength,
          decoration: const InputDecoration(
            labelText: '忘记密码提示语',
            counterText: '',
          ),
          onSubmitted: isBusy ? null : (_) => onSubmit(),
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
          onPressed: isBusy ? null : onSubmit,
          child: isBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('确认开启'),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isBusy ? null : onBack,
            child: Text(
              '上一步',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}
