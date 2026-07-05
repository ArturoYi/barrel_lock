import 'package:fast_navigator/fast_navigator.dart';
import 'package:fast_navigator/src/page/custom_transition_page.dart';
import 'package:fast_navigator/src/page/fade_transition_page.dart';
import 'package:fast_navigator/src/page/no_transition_page.dart';
import 'package:fast_navigator/src/page/page_factory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(AppTypeDetector.resetCache);

  const homeRoute = FastRoute(
    name: 'home',
    path: '/',
    builder: _placeholderBuilder,
  );

  const splashRoute = FastRoute(
    name: 'splash',
    path: '/splash',
    transition: NoTransition(),
    builder: _placeholderBuilder,
  );

  RouteMatch matchFor(FastRoute route, {String path = '/'}) {
    return RouteMatch(
      route: route,
      path: path,
      parameters: const RouteParameters(),
      key: RouteMatch.generateKey(route.name, path),
    );
  }

  group('PageFactory', () {
    testWidgets('PlatformAdaptive + MaterialApp → MaterialPage', (
      tester,
    ) async {
      late Page<Object?> page;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              page = const PageFactory(
                appTypeOverride: AppType.material,
              ).build(context: context, match: matchFor(homeRoute));
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(page, isA<MaterialPage<void>>());
      expect(page.key, ValueKey('home:/'));
    });

    testWidgets('PlatformAdaptive + CupertinoApp → CupertinoPage', (
      tester,
    ) async {
      late Page<Object?> page;

      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              page = const PageFactory(
                appTypeOverride: AppType.cupertino,
              ).build(context: context, match: matchFor(homeRoute));
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(page.runtimeType.toString(), contains('CupertinoPage'));
    });

    testWidgets('PlatformAdaptive + AppType.widgets → NoTransitionPage', (
      tester,
    ) async {
      late Page<Object?> page;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              page = const PageFactory(
                appTypeOverride: AppType.widgets,
              ).build(context: context, match: matchFor(homeRoute));
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(page, isA<NoTransitionPage>());
    });

    testWidgets('route transition overrides global default', (tester) async {
      late Page<Object?> page;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              page = const PageFactory(defaultTransition: MaterialTransition())
                  .build(
                    context: context,
                    match: matchFor(splashRoute, path: '/splash'),
                  );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(page, isA<NoTransitionPage>());
    });

    testWidgets('FadePageTransition → FadeTransitionPage', (tester) async {
      const fadeRoute = FastRoute(
        name: 'fade',
        path: '/fade',
        transition: FadePageTransition(),
        builder: _placeholderBuilder,
      );

      late Page<Object?> page;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              page = const PageFactory().build(
                context: context,
                match: matchFor(fadeRoute, path: '/fade'),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(page, isA<FadeTransitionPage>());
    });

    testWidgets('CustomTransition → CustomTransitionPage', (tester) async {
      const customRoute = FastRoute(
        name: 'fade',
        path: '/fade',
        transition: CustomTransition(transitionsBuilder: _fadeTransition),
        builder: _placeholderBuilder,
      );

      late Page<Object?> page;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              page = const PageFactory().build(
                context: context,
                match: matchFor(customRoute, path: '/fade'),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(page, isA<CustomTransitionPage>());
    });
  });
}

Widget _placeholderBuilder(BuildContext context, RouteMatch match) {
  return const Placeholder();
}

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}
