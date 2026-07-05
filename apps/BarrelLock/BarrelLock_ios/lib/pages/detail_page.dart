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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('详情页 · $id')),
      body: Center(
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
    );
  }
}
