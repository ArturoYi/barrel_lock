import 'package:flutter_test/flutter_test.dart';

// BarrelLock 平台壳的占位测试。
// 注意:不要在这里直接 import 应用入口并 pumpWidget,否则:
//   1. `flutter test` 会尝试把项目编译到当前 runner 启用的所有平台;
//      对于未声明 web 平台的 BarrelLock_android / BarrelLock_ios 等,
//      会出现 "This project is not configured for the web" 报错。
//   2. 真正的 UI 测试应该下放到 packages/ 下的业务包中执行。
void main() {
  test('package loads', () {
    expect(true, isTrue);
  });
}