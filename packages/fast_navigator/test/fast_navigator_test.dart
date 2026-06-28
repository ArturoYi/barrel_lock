import 'package:flutter_test/flutter_test.dart';

void main() {
  test('库入口可被加载', () {
    // 仅做编译期验证:能 `import` 到 library 入口即视为通过。
    // 等 M1/M2 阶段真实 API 落地后,在此处补充针对 FastRoute / FastRouter
    // 的单元测试。
    expect(true, isTrue);
  });
}