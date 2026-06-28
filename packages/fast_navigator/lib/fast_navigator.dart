/// fast_navigator 包入口。
/// 暴露所有必要的类给使用者。
library;

// 门面层 API
export 'src/facade/fast_navigator.dart';
export 'src/facade/fast_router_config.dart';

// 领域模型
export 'src/domain/route_config.dart';
export 'src/domain/route_match.dart';
export 'src/domain/route_middleware.dart';

// 参数模型
export 'src/params/route_parameters.dart';

// (核心层通常对业务隐藏，但可按需暴露，这里暂不暴露 delegate 等内部实现)
