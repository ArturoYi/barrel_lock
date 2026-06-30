/// fast_navigator 包入口。
/// 暴露所有必要的类给使用者。
library;

// 对外 API
export 'src/api/fast_navigator.dart';
export 'src/api/fast_router_config.dart';

// 领域模型 — 状态
export 'src/domain/state/duplicate_route_exception.dart';
export 'src/domain/state/launch_mode.dart';

// 领域模型 — 路由定义
export 'src/domain/route/routes.dart';

// 领域模型 — 匹配
export 'src/domain/match/route_match.dart';
export 'src/domain/match/route_parameters.dart';

// 领域模型 — 中间件
export 'src/domain/middleware/route_middleware.dart';

// (router / internal 层对业务隐藏，按需再暴露)
