import 'package:core/core.dart';

import '../../router/application/app_router.dart';

/// 语言设置页导航协调器。
final class LanguageSettingsCoordinator {
  const LanguageSettingsCoordinator();

  void pop() => AppRouter.pop();
}

final languageSettingsCoordinatorProvider =
    Provider<LanguageSettingsCoordinator>(
      (_) => const LanguageSettingsCoordinator(),
    );
