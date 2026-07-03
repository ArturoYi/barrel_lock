import 'package:fast_toast/fast_toast.dart';
import 'package:fast_toast/src/core/toast_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final controller = ToastController.instance;

  setUp(controller.resetForTest);

  tearDown(controller.resetForTest);

  Widget buildApp({required Widget home}) {
    return MaterialApp(
      builder: (context, child) {
        return FastToastOverlay(child: child ?? const SizedBox.shrink());
      },
      home: home,
    );
  }

  group('FastToastOverlay', () {
    testWidgets('shows toast through overlay', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      FastToast.success('保存成功');
      await tester.pump();

      expect(find.text('保存成功'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('queues toasts sequentially', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      FastToast.show(
        'first',
        config: const ToastConfig(duration: Duration(milliseconds: 100)),
      );
      FastToast.show('second');
      await tester.pump();

      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsNothing);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('show before overlay mount appears after attach', (
      tester,
    ) async {
      FastToast.show('early');
      expect(FastToast.pendingCount, 1);
      expect(find.text('early'), findsNothing);

      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      expect(find.text('early'), findsOneWidget);
    });

    testWidgets('dismissAll removes visible toast immediately', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      FastToast.error('网络异常');
      await tester.pump();

      expect(find.text('网络异常'), findsOneWidget);

      FastToast.dismissAll();
      await tester.pump();

      expect(find.text('网络异常'), findsNothing);
      expect(FastToast.isShowing, isFalse);
    });

    testWidgets('dismissible toast closes on tap', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      FastToast.show('tap me', config: const ToastConfig(dismissible: true));
      await tester.pump();

      await tester.tap(find.text('tap me'));
      await tester.pump();

      expect(find.text('tap me'), findsNothing);
    });

    testWidgets('loading pause blocks dequeue until resume', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      ToastController.loadingPauseCheck = () => true;
      FastToast.show('blocked');
      await tester.pump();

      expect(FastToast.pendingCount, 1);
      expect(FastToast.isShowing, isFalse);

      ToastController.loadingPauseCheck = () => false;
      FastToast.resume();
      await tester.pump();

      expect(FastToast.pendingCount, 0);
      expect(FastToast.isShowing, isTrue);
      expect(find.text('blocked'), findsOneWidget);
    });

    testWidgets('bypassLoadingPause shows during loading pause', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      ToastController.loadingPauseCheck = () => true;
      FastToast.show(
        'urgent',
        config: const ToastConfig(bypassLoadingPause: true),
      );
      await tester.pump();

      expect(FastToast.isShowing, isTrue);
      expect(find.text('urgent'), findsOneWidget);
    });
  });
}
