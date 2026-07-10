import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

/// 竖屏 PageView 第二步：设置忘记密码提示语。
///
/// 使用系统 [TextField] 输入提示语（非数字键盘），提交后由 ViewModel
/// 落盘 PIN 并开启应用保护。
final class AppLockEnableSetupPortraitHintPage extends StatelessWidget {
  const AppLockEnableSetupPortraitHintPage({
    super.key,
    required this.state,
    required this.hintController,
    required this.hintFocusNode,
    required this.onSubmit,
    required this.onBack,
  });

  /// ViewModel 输出的流程状态。
  final AppLockEnableSetupState state;

  /// 提示语文本控制器，由 Host 创建与销毁。
  final TextEditingController hintController;

  /// 提示语输入框焦点，进入此步骤时由 Host 自动请求。
  final FocusNode hintFocusNode;

  /// 校验提示语并提交开启验证。
  final VoidCallback onSubmit;

  /// 返回 PIN 步骤（不清除已输入的 PIN）。
  final VoidCallback onBack;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 步骤说明
                  Text(
                    '设置一句提示语，忘记密码时可帮助你回忆备用密码。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // 提示语输入框
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
                  // 提示语校验或落盘失败时的错误信息
                  if (state.errorMessage case final message?) ...[
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  // 提交并开启应用保护；提交中显示加载指示器
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
                  const SizedBox(height: 16),
                  // 返回 PIN 步骤
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
        );
      },
    );
  }
}
