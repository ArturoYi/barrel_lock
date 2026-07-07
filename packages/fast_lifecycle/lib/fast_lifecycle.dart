/// fast_lifecycle — 全平台原生生命周期监听框架。
///
/// 分层：业务门面 [RawLifeCycleManager] → 抽象适配器 [LifeCycleAdapter]
/// → 平台实现 → 系统原生层。
///
/// 底层只透传原生 [RawLifeCycleEvent.rawState]，不提供统一状态枚举。
library;

export 'src/adapter/lifecycle_adapter.dart';
export 'src/adapter/lifecycle_event_callback.dart';
export 'src/channels/lifecycle_channel_names.dart';
export 'src/domain/life_platform_source.dart';
export 'src/domain/flat/flat_lifecycle.dart';
export 'src/domain/lifecycle_scope.dart';
export 'src/domain/lifecycle_event_extra.dart';
export 'src/domain/lifecycle_trigger_reference.dart';
export 'src/domain/raw_lifecycle_event.dart';
export 'src/domain/states/platform_lifecycle_states.dart';
export 'src/internal/lifecycle_init_options.dart';
export 'src/manager/raw_lifecycle_manager.dart';
export 'src/mixins/platform_lifecycle_mixins.dart';
export 'src/mixins/unified_lifecycle_mixins.dart';
export 'src/state/lifecycle_state_accessor.dart';
export 'src/state/lifecycle_state_store.dart';
