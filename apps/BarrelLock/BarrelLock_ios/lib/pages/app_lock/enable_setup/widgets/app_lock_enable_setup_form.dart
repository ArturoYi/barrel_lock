import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 开启验证 PIN 输入表单（设置页内嵌，非全局 Overlay）。
final class AppLockEnableSetupForm extends StatelessWidget {
  const AppLockEnableSetupForm({
    super.key,
    required this.state,
    required this.pinController,
    required this.confirmPinController,
    required this.pinFocusNode,
    required this.onSubmit,
    required this.onCancel,
    required this.onToggleObscurePin,
    required this.onToggleObscureConfirmPin,
  });

  final AppLockEnableSetupState state;
  final TextEditingController pinController;
  final TextEditingController confirmPinController;
  final FocusNode pinFocusNode;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onToggleObscurePin;
  final VoidCallback onToggleObscureConfirmPin;

  static final _inputFormatters = [FilteringTextInputFormatter.digitsOnly];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = state.isBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: pinController,
          focusNode: pinFocusNode,
          enabled: !isBusy,
          obscureText: state.obscurePin,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          maxLength: AppLockPinPolicy.length,
          inputFormatters: _inputFormatters,
          decoration: InputDecoration(
            labelText: '6 位数字密码',
            counterText: '',
            suffixIcon: IconButton(
              onPressed: isBusy ? null : onToggleObscurePin,
              icon: Icon(
                state.obscurePin ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmPinController,
          enabled: !isBusy,
          obscureText: state.obscureConfirmPin,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: AppLockPinPolicy.length,
          inputFormatters: _inputFormatters,
          decoration: InputDecoration(
            labelText: '确认密码',
            counterText: '',
            suffixIcon: IconButton(
              onPressed: isBusy ? null : onToggleObscureConfirmPin,
              icon: Icon(
                state.obscureConfirmPin
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
            ),
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
            onPressed: isBusy ? null : onCancel,
            child: Text(
              '取消',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}
