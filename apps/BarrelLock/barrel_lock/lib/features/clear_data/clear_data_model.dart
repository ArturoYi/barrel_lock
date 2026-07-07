import 'package:core/core.dart';

/// 清除数据流程步骤。
enum ClearDataStep { idle, confirm1, confirm2, clearing, done }

/// 清除数据页业务数据（MVVM-C 的 M 层）。
final class ClearDataModel {
  const ClearDataModel();

  Future<void> wipeAllPasswords() async {
    // 后续接入密码仓库；当前模拟耗时。
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }
}

final clearDataModelProvider = Provider<ClearDataModel>(
  (_) => const ClearDataModel(),
);
