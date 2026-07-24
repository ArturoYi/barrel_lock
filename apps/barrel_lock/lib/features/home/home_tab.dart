/// Home 底部 Tab 标识（不含 UI 类型，由 View 映射图标）。
enum HomeTab { password, settings }

/// Tab 展示元数据（M 层输出，V 层渲染）。
final class HomeTabDescriptor {
  const HomeTabDescriptor({required this.tab});

  final HomeTab tab;
}
