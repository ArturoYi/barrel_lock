/// 路由树节点库（FastBaseRoute 及其子类型）。
///
/// 使用单一 library + part 组织，以便 [FastBaseRoute] sealed 基类
/// 与子类型（FastRoute、StatefulShellRoute 等）分文件存放且同属一个库。
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../route_match.dart';
import '../route_middleware.dart';

part 'fast_base_route.dart';
part 'fast_route.dart';

/// @deprecated 使用 [FastRoute] 代替
typedef RouteConfig = FastRoute;
