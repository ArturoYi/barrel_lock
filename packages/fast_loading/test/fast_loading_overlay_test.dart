import 'package:fast_loading/fast_loading.dart';
import 'package:fast_loading/src/core/loading_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final controller = LoadingController.instance;

  setUp(controller.resetForTest);

  tearDown(controller.resetForTest);

  Widget buildApp({required Widget home}) {
    return MaterialApp(
      builder: (context, child) {
        return FastLoadingOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: home,
    );
  }

  group('FastLoadingOverlay', () {
    testWidgets('shows and hides loading through overlay', (tester) async {
      await tester.pumpWidget(
        buildApp(
          home: const Scaffold(body: Text('content')),
        ),
      );
      await tester.pump();

      FastLoading.show(message: '加载中…');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('加载中…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('content'), findsOneWidget);

      FastLoading.dismiss();
      await tester.pump();

      expect(find.text('加载中…'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('concurrent show keeps single overlay entry', (tester) async {
      await tester.pumpWidget(
        buildApp(
          home: const Scaffold(body: Text('content')),
        ),
      );
      await tester.pump();

      FastLoading.show();
      FastLoading.show();
      FastLoading.show();
      await tester.pump();

      expect(FastLoading.refCount, 3);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      FastLoading.dismiss();
      FastLoading.dismiss();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      FastLoading.dismiss();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('show before overlay mount appears after attach', (tester) async {
      FastLoading.show(message: 'early');
      expect(FastLoading.refCount, 1);
      expect(find.text('early'), findsNothing);

      await tester.pumpWidget(
        buildApp(
          home: const Scaffold(body: Text('content')),
        ),
      );
      await tester.pump();

      expect(find.text('early'), findsOneWidget);
    });

    testWidgets('run auto dismisses after future completes', (tester) async {
      await tester.pumpWidget(
        buildApp(
          home: const Scaffold(body: Text('content')),
        ),
      );
      await tester.pump();

      final result = await FastLoading.run(
        () async => 'ok',
        message: 'running',
      );

      expect(result, 'ok');
      await tester.pump();

      expect(find.text('running'), findsNothing);
      expect(FastLoading.isShowing, isFalse);
    });

    testWidgets('dismissOnBarrierTap closes loading when tapping barrier', (tester) async {
      await tester.pumpWidget(
        buildApp(
          home: const Scaffold(body: Text('content')),
        ),
      );
      await tester.pump();

      FastLoading.show(
        config: const LoadingConfig(
          message: 'tap to close',
          dismissOnBarrierTap: true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('tap to close'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(find.text('tap to close'), findsNothing);
      expect(FastLoading.isShowing, isFalse);
    });

    testWidgets('dismissOnBarrierTap false ignores barrier tap', (tester) async {
      await tester.pumpWidget(
        buildApp(
          home: const Scaffold(body: Text('content')),
        ),
      );
      await tester.pump();

      FastLoading.show(
        config: const LoadingConfig(
          message: 'no tap close',
          dismissOnBarrierTap: false,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(find.text('no tap close'), findsOneWidget);
      expect(FastLoading.isShowing, isTrue);
    });

    testWidgets('dismiss with success shows result then hides', (tester) async {
      await tester.pumpWidget(
        buildApp(
          home: const Scaffold(body: Text('content')),
        ),
      );
      await tester.pump();

      FastLoading.show(
        config: LoadingConfig(
          style: LoadingStyle(
            successWidget: const Icon(Icons.check, key: Key('success-icon')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      FastLoading.dismiss(result: LoadingDismissResult.success, message: '成功');
      expect(LoadingController.instance.displayPhase, LoadingDisplayPhase.success);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('success-icon')), findsOneWidget);
      expect(find.text('成功'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.byKey(const Key('success-icon')), findsNothing);
      expect(FastLoading.isShowing, isFalse);
    });

    testWidgets('dismissAll removes overlay immediately', (tester) async {
      await tester.pumpWidget(
        buildApp(
          home: const Scaffold(body: Text('content')),
        ),
      );
      await tester.pump();

      FastLoading.show();
      FastLoading.show();
      await tester.pump();

      FastLoading.dismissAll();
      await tester.pump();

      expect(FastLoading.refCount, 0);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
