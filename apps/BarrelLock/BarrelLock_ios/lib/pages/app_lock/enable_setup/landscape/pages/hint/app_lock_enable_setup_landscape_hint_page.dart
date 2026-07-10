import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

/// 横屏 PageView 第二步：左侧说明、右侧提示语输入。
///
/// 布局与 [AppLockEnableSetupLandscapePinPage] 保持一致的左右分栏比例。
final class AppLockEnableSetupLandscapeHintPage extends StatelessWidget {
  const AppLockEnableSetupLandscapeHintPage({
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

  /// 左右栏间距，与 PIN 页保持一致。
  static const _columnGap = 32.0;

  /// 左侧说明区最小宽度。
  static const _infoMinWidth = 220.0;

  /// 右侧表单区最大宽度。
  static const _inputMaxWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = state.isBusy;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左侧：步骤说明
                  Expanded(
                    flex: 3,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: _infoMinWidth,
                      ),
                      child: Text(
                        '设置一句提示语，忘记密码时可帮助你回忆备用密码。',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: _columnGap),
                  // 右侧：提示语输入与操作按钮
                  Expanded(
                    flex: 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _inputMaxWidth,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          const SizedBox(height: 32),
                          FilledButton(
                            onPressed: isBusy ? null : onSubmit,
                            child: isBusy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('确认开启'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: isBusy ? null : onBack,
                            child: Text(
                              '上一步',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
