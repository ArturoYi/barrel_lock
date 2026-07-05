/// BarrelLock 共享路由模块。
///
/// 路由地址（[AppRoutes]）与导航 API（[AppRouter]）在此统一管理；
/// 各平台 app 通过 [AppRouteBuilders] 注入本地 Page Widget。
library;

export 'application/app_route_builders.dart';
export 'application/app_router.dart';
export 'domain/app_routes.dart';
export 'domain/app_simple_route.dart';
export 'domain/detail_route.dart';
export 'presentation/unknown_route_page.dart';
