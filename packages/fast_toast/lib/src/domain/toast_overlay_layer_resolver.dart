import 'toast_overlay_layer.dart';
import 'toast_request.dart';

/// App 层注入：按运行时上下文覆盖 [ToastConfig.overlayLayer]。
///
/// 返回 `null` 时保留请求中的显式配置；仅当请求为 [ToastOverlayLayer.normal] 时生效。
typedef ToastOverlayLayerResolver =
    ToastOverlayLayer? Function(ToastRequest request);
