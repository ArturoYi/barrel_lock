import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late final TextEditingController _pinController;
  late final FocusNode _pinFocusNode;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _pinFocusNode = FocusNode();
    schedulePinFieldFocus(
      _pinFocusNode,
      isMounted: () => mounted,
      afterSystemAuth: true,
    );
  }

  @override
  void didUpdateWidget(covariant AppLockPinPromptPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.attempt != widget.state.attempt) {
      releasePinFieldFocus(_pinFocusNode);
      _pinController.clear();
      schedulePinFieldFocus(
        _pinFocusNode,
        isMounted: () => mounted,
        afterSystemAuth: true,
      );
    }
  }

  @override
  void dispose() {
    cancelPendingPinFieldFocus();
    _pinFocusNode.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submitPin() {
    releasePinFieldFocus(_pinFocusNode);
    ref.read(appLockPinPromptProvider.notifier).submitPin(_pinController.text);
  }

  void _cancel() {
    cancelPendingPinFieldFocus();
    ref.read(appLockPinPromptProvider.notifier).cancel();
  }

  void _toggleObscure() {
    ref.read(appLockPinPromptProvider.notifier).toggleObscure();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isSubmitting = state.isSubmitting;

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: OrientationBuilder(
            builder: (context, orientation) {
              final layout = switch (orientation) {
                Orientation.portrait => AppLockPinPromptPortraitLayout(
                  state: state,
                  pinController: _pinController,
                  pinFocusNode: _pinFocusNode,
                  isSubmitting: isSubmitting,
                  onSubmit: _submitPin,
                  onCancel: _cancel,
                  onToggleObscure: _toggleObscure,
                ),
                Orientation.landscape => AppLockPinPromptLandscapeLayout(
                  state: state,
                  pinController: _pinController,
                  pinFocusNode: _pinFocusNode,
                  isSubmitting: isSubmitting,
                  onSubmit: _submitPin,
                  onCancel: _cancel,
                  onToggleObscure: _toggleObscure,
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

/// 竖屏 / 横屏布局共用的 PIN 输入区骨架。
final class AppLockPinPromptInputSection extends StatelessWidget {
  const AppLockPinPromptInputSection({
    super.key,
    required this.state,
    required this.pinController,
    required this.pinFocusNode,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onToggleObscure,
  });

  final AppLockPinPromptState state;
  final TextEditingController pinController;
  final FocusNode pinFocusNode;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: pinController,
          focusNode: pinFocusNode,
          enabled: !isSubmitting,
          obscureText: state.obscurePin,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: '应用内密码',
            suffixIcon: IconButton(
              onPressed: isSubmitting ? null : onToggleObscure,
              icon: Icon(
                state.obscurePin ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
          onSubmitted: isSubmitting ? null : (_) => onSubmit(),
        ),
        if (state.errorMessage case final message?) ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
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
