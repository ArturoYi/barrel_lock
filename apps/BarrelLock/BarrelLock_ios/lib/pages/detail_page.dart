import 'package:core/core.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({required this.id, super.key});

  final String id;

  Future<void> _demoShowDismiss() async {
    FastLoading.show();
    await Future<void>.delayed(const Duration(seconds: 2));
    FastLoading.dismiss();
  }

  Future<void> _demoRun() async {
    await FastLoading.run(() async {
      await Future<void>.delayed(const Duration(seconds: 2));
    });
  }

  Future<void> _demoRefCount() async {
    FastLoading.show();
    FastLoading.show();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    FastLoading.dismiss();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    FastLoading.dismiss();
  }

  Future<void> _demoDismissSuccess(BuildContext context) async {
    FastLoading.show();
    await Future<void>.delayed(const Duration(seconds: 2));
    FastLoading.dismiss(result: LoadingDismissResult.success);
  }

  Future<void> _demoDismissError(BuildContext context) async {
    FastLoading.show();
    await Future<void>.delayed(const Duration(seconds: 2));
    FastLoading.dismiss(result: LoadingDismissResult.error);
  }

  Future<void> _demoDismissInlineResult() async {
    FastLoading.show();
    await Future<void>.delayed(const Duration(seconds: 2));
    FastLoading.dismiss(result: LoadingDismissResult.success);
  }

  void _demoToastTypes() {
    FastToast.success('保存成功');
    FastToast.error('网络异常');
    FastToast.info('已复制到剪贴板');
  }

  void _demoToastQueue() {
    FastToast.show('第一条');
    FastToast.show('第二条');
    FastToast.show('第三条');
  }

  Future<void> _demoToastAfterLoading() async {
    FastLoading.show();
    FastToast.show('Loading 期间入队，关闭后继续展示');
    await Future<void>.delayed(const Duration(seconds: 2));
    FastLoading.dismiss();
  }

  Future<void> _demoToastBypassLoading() async {
    FastLoading.show();
    FastToast.show(
      'Loading 期间仍展示',
      config: const ToastConfig(bypassLoadingPause: true),
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    FastLoading.dismiss();
  }

  Future<void> _demoDialogConfirm() async {
    final confirmed = await FastDialog.show<bool>(
      tag: 'detail_confirm',
      showConfig: const DialogShowConfig(
        animation: DialogAnimationSpec(type: DialogAnimationType.scale),
      ),
      builder: (context) =>
          _DemoConfirmDialog(title: '确认操作', message: '详情页 id = $id，是否继续？'),
    );
    if (confirmed == true) {
      FastToast.success('已确认');
    } else if (confirmed == false) {
      FastToast.info('已取消');
    }
  }

  Future<void> _demoDialogBottomSheet() async {
    await FastDialog.show<void>(
      showConfig: const DialogShowConfig(
        animation: DialogAnimationSpec(
          type: DialogAnimationType.slideFromBottom,
        ),
        enableDragDismiss: true,
        dragDismissThreshold: 80,
      ),
      builder: (context) => _DemoBottomPanel(title: '底部弹窗 · $id'),
    );
  }

  Future<void> _demoDialogStack() async {
    await FastDialog.show<void>(
      tag: 'stack_base',
      builder: (context) => _DemoStackDialog(
        title: '第一层',
        onOpenSecond: () {
          FastDialog.show<void>(
            showConfig: const DialogShowConfig(zIndex: 1),
            builder: (context) =>
                _DemoStackDialog(title: '第二层（zIndex 更高）', onOpenSecond: null),
          );
        },
      ),
    );
  }

  void _demoDialogDismissAll() {
    FastDialog.show<void>(
      tag: 'dismiss_all_a',
      builder: (context) => const _DemoSimpleDialog(title: '弹窗 A'),
    );
    FastDialog.show<void>(
      tag: 'dismiss_all_b',
      builder: (context) => const _DemoSimpleDialog(title: '弹窗 B'),
    );
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      FastDialog.dismissAll();
      FastToast.info('dismissAll 已关闭全部弹窗');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('详情页 · $id')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: _demoShowDismiss,
                child: const Text('show / dismiss（2s）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoRun,
                child: const Text('FastLoading.run（2s）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoRefCount,
                child: const Text('引用计数（两次 dismiss 才关）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _demoDismissSuccess(context),
                child: const Text('dismiss success（2s → 成功态 1s）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _demoDismissError(context),
                child: const Text('dismiss error（2s → 失败态 1s）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoDismissInlineResult,
                child: const Text('dismiss 外部 message'),
              ),
              const SizedBox(height: 32),
              const Text('FastToast'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoToastTypes,
                child: const Text('success / error / info（串行）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoToastQueue,
                child: const Text('队列（三条依次展示）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoToastAfterLoading,
                child: const Text('Loading 期间入队，关闭后展示'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoToastBypassLoading,
                child: const Text('Loading 期间 bypass 立即展示'),
              ),
              const SizedBox(height: 32),
              const Text('FastDialog'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoDialogConfirm,
                child: const Text('确认弹窗（await 结果）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoDialogBottomSheet,
                child: const Text('底部弹窗（下拉关闭）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoDialogStack,
                child: const Text('多层叠加（zIndex）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _demoDialogDismissAll,
                child: const Text('dismissAll 关闭全部'),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: AppRouter.pop,
                child: Text(
                  '返回',
                  style: AppFontFamily.notoSansSC.textStyle(
                    weight: AppFontWeight.regular,
                    style: AppFontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 确认弹窗 Demo：业务 UI 完全自定义，通过 dismiss(result:) 回传 Future。
final class _DemoConfirmDialog extends StatelessWidget {
  const _DemoConfirmDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => FastDialog.dismiss(result: false),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => FastDialog.dismiss(result: true),
                  child: const Text('确认'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部滑入面板 Demo。
final class _DemoBottomPanel extends StatelessWidget {
  const _DemoBottomPanel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16, width: double.infinity),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('向下拖拽超过阈值可关闭', style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => FastDialog.dismiss(),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 多层弹窗 Demo。
final class _DemoStackDialog extends StatelessWidget {
  const _DemoStackDialog({required this.title, this.onOpenSecond});

  final String title;
  final VoidCallback? onOpenSecond;

  @override
  Widget build(BuildContext context) {
    return _DemoSimpleDialog(
      title: title,
      actionLabel: onOpenSecond == null ? null : '打开第二层',
      onAction: onOpenSecond,
    );
  }
}

final class _DemoSimpleDialog extends StatelessWidget {
  const _DemoSimpleDialog({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => FastDialog.dismiss(),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }
}
