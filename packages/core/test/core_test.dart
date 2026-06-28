import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('core public API', () {
    test('appName 暴露正确常量', () {
      expect(appName, 'Flutter Bazaar');
    });

    test('greeting 拼接 appName 生成欢迎语', () {
      expect(greeting(), 'Welcome to Flutter Bazaar');
      expect(greeting(), contains(appName));
    });
  });
}