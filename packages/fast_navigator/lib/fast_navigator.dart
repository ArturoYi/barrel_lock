/// fast_navigator 包入口。
///
/// 基于 Navigator 2.0 自研的声明式路由框架。
/// 统一 export 各层公开 API，业务侧仅需 `import 'package:fast_navigator/fast_navigator.dart'`。
library;

// ── Core：Navigator 2.0 四件套 ──
export 'src/core/fast_router.dart';
export 'src/core/fast_router_delegate.dart';
export 'src/core/fast_route_information_parser.dart';

// ── Domain：路由领域模型 ──
export 'src/domain/navigation_state.dart';
export 'src/domain/route_match.dart';
export 'src/domain/route_registry.dart';
export 'src/domain/route_config.dart';
export 'src/domain/route_middleware.dart';

// ── Facade：对外门面 API ──
export 'src/facade/fast_navigator.dart';
export 'src/facade/fast_router_config.dart';

// ── Foundation：Page 与参数 ──
export 'src/page/fast_page.dart';
export 'src/params/route_parameters.dart';
