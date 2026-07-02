import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../router/router.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('详情页')),
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
