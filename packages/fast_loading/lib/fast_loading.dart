/// fast_loading 包入口。
library;

// 对外 API
export 'src/api/fast_loading.dart';
export 'src/api/fast_loading_overlay.dart';
export 'src/api/loading_route_guard.dart';

// 领域模型
export 'src/domain/loading_config.dart';
export 'src/domain/loading_dismiss_result.dart';
export 'src/domain/loading_display_phase.dart';
export 'src/domain/loading_style.dart';

// Presentation（可独立嵌入的 Widget）
export 'src/presentation/loading_widget.dart';
