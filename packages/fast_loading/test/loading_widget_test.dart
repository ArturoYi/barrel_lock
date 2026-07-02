import 'package:fast_loading/fast_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(LoadingConfig config) {
    return MaterialApp(
      home: Scaffold(
        body: LoadingWidget(
          config: config,
        ),
      ),
    );
  }

  group('LoadingWidget', () {
    testWidgets('default shows indicator without message', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingConfig()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('default uses material elevated surface', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingConfig(message: '加载中')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('加载中'), findsOneWidget);

      final materials = tester.widgetList<Material>(find.byType(Material));
      expect(
        materials.any((material) => material.elevation == 8),
        isTrue,
      );
    });

    testWidgets('loadingWidget overrides default content', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LoadingConfig(
            style: LoadingStyle(
              loadingWidget: Text('custom'),
            ),
          ),
        ),
      );

      expect(find.text('custom'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      final materials = tester.widgetList<Material>(find.byType(Material));
      expect(
        materials.any((material) => material.elevation == 8),
        isTrue,
      );
    });

    testWidgets('surfaceSpec controls elevation and border radius', (tester) async {
      await tester.pumpWidget(
        wrap(
          LoadingConfig(
            message: '加载中',
            style: LoadingStyle(
              surfaceSpec: const LoadingSurfaceSpec().copyWith(
                elevation: 12,
                borderRadius: 24,
              ),
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(LoadingWidget),
          matching: find.byType(Material),
        ),
      );
      expect(material.elevation, 12);
      expect(material.borderRadius, BorderRadius.circular(24));
    });

    testWidgets('indicatorSpec controls size stroke and message spacing', (tester) async {
      const customTextStyle = TextStyle(fontSize: 20, color: Colors.red);

      await tester.pumpWidget(
        wrap(
          LoadingConfig(
            message: '请稍候',
            style: LoadingStyle(
              indicatorSpec: const LoadingIndicatorSpec().copyWith(
                size: 48,
                strokeWidth: 5,
                messageSpacing: 24,
                textStyle: customTextStyle,
              ),
            ),
          ),
        ),
      );

      final progress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progress.strokeWidth, 5);

      final indicatorBox = tester.getSize(find.byType(CircularProgressIndicator));
      expect(indicatorBox.width, 48);
      expect(indicatorBox.height, 48);

      final messageText = tester.widget<Text>(find.text('请稍候'));
      expect(messageText.style?.fontSize, 20);
      expect(messageText.style?.color, Colors.red);

      final messagePadding = tester.widget<Padding>(
        find.ancestor(
          of: find.text('请稍候'),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Padding &&
                widget.padding == const EdgeInsets.only(top: 24),
          ),
        ),
      );
      expect(messagePadding.padding, const EdgeInsets.only(top: 24));
    });

    testWidgets('result message is shown when passed externally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              config: const LoadingConfig(),
              displayPhase: LoadingDisplayPhase.success,
              resultMessage: '提交成功',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('提交成功'), findsOneWidget);
    });

    testWidgets('without message does not reserve message spacing', (tester) async {
      await tester.pumpWidget(wrap(const LoadingConfig()));

      expect(find.byType(Text), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.only(top: 16),
        ),
        findsNothing,
      );
    });

    testWidgets('with message adds spacing below indicator', (tester) async {
      await tester.pumpWidget(wrap(const LoadingConfig(message: '加载中')));

      expect(find.text('加载中'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.only(top: 16),
        ),
        findsOneWidget,
      );
    });

    testWidgets('phase switch keeps single material surface', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              config: const LoadingConfig(),
              displayPhase: LoadingDisplayPhase.loading,
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(LoadingWidget),
          matching: find.byType(Material),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              config: const LoadingConfig(),
              displayPhase: LoadingDisplayPhase.success,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.descendant(
          of: find.byType(LoadingWidget),
          matching: find.byType(Material),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('result content uses material surface', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LoadingConfig(
            style: LoadingStyle(
              successWidget: Text('ok'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              config: const LoadingConfig(),
              displayPhase: LoadingDisplayPhase.success,
              resultWidget: const Text('ok'),
            ),
          ),
        ),
      );

      expect(find.text('ok'), findsOneWidget);

      final materials = tester.widgetList<Material>(find.byType(Material));
      expect(
        materials.any((material) => material.elevation == 8),
        isTrue,
      );
    });
  });
}
