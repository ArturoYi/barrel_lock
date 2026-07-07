import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PIN 输入遮罩状态。
final class AppLockPinPromptState {
  const AppLockPinPromptState({
    required this.reason,
    required this.errorMessage,
    this.obscurePin = true,
  });

  final IdentityAuthReason reason;
  final String? errorMessage;
  final bool obscurePin;

  AppLockPinPromptState copyWith({
    String? errorMessage,
    bool? obscurePin,
    bool clearError = false,
  }) {
    return AppLockPinPromptState(
      reason: reason,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      obscurePin: obscurePin ?? this.obscurePin,
    );
  }
}

/// 全局 PIN 输入请求控制器，供 [BarrelLockIdentityAuthUiDelegate] 使用。
final class AppLockPinPromptNotifier extends Notifier<AppLockPinPromptState?> {
  Completer<String?>? _completer;
  final _pinController = TextEditingController();

  TextEditingController get pinController => _pinController;

  @override
  AppLockPinPromptState? build() => null;

  Future<String?> requestPin(
    IdentityAuthReason reason, {
    String? errorMessage,
  }) {
    _completer?.complete(null);
    _completer = Completer<String?>();
    _pinController.clear();
    state = AppLockPinPromptState(reason: reason, errorMessage: errorMessage);
    return _completer!.future;
  }

  void submitPin() {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      state = state?.copyWith(errorMessage: '请输入密码');
      return;
    }
    _completer?.complete(pin);
    _finish();
  }

  void cancel() {
    _completer?.complete(null);
    _finish();
  }

  void toggleObscure() {
    final current = state;
    if (current == null) return;
    state = current.copyWith(obscurePin: !current.obscurePin);
  }

  void _finish() {
    _completer = null;
    _pinController.clear();
    state = null;
  }
}

final appLockPinPromptProvider =
    NotifierProvider<AppLockPinPromptNotifier, AppLockPinPromptState?>(
      AppLockPinPromptNotifier.new,
    );

/// 全屏 PIN 输入遮罩（各平台共用）。
final class AppLockPinPromptOverlay extends ConsumerWidget {
  const AppLockPinPromptOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = ref.watch(appLockPinPromptProvider);
    if (prompt == null) {
      return const SizedBox.shrink();
    }

    final notifier = ref.read(appLockPinPromptProvider.notifier);
    final controller = notifier.pinController;

    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.98),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '输入应用内密码',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                prompt.reason.defaultMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: controller,
                autofocus: true,
                obscureText: prompt.obscurePin,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: '应用内密码',
                  errorText: prompt.errorMessage,
                  suffixIcon: IconButton(
                    onPressed: notifier.toggleObscure,
                    icon: Icon(
                      prompt.obscurePin
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                onSubmitted: (_) => notifier.submitPin(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: notifier.submitPin,
                child: const Text('确认'),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: notifier.cancel, child: const Text('取消')),
            ],
          ),
        ),
      ),
    );
  }
}
