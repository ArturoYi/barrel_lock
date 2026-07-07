/// Android [androidx.lifecycle.Lifecycle.Event] 名 SSOT（需求文档 §4.2）。
///
/// 进程层与 Activity 层使用相同的 `ON_*` 字符串，通过 [LifecycleScope] 区分。
abstract final class AndroidAppLifecycleState {
  static const onCreate = 'ON_CREATE';
  static const onStart = 'ON_START';
  static const onResume = 'ON_RESUME';
  static const onPause = 'ON_PAUSE';
  static const onStop = 'ON_STOP';
  static const onDestroy = 'ON_DESTROY';
}
