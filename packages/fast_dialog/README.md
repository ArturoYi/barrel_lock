# fast_dialog

基于 Flutter **Overlay + 弹窗栈** 的全局 Dialog 框架，**零第三方依赖、零业务侵入**。

> **当前状态**：M1 已完成，已接入 `packages/core` 的 [ThemedApp]。

**不包含** Loading、Toast 等非 Dialog 弹出层。

---

## 接入（BarrelLock 已默认接入）

各 App 使用 `ThemedApp.router` 即可，builder 链已包含 `FastDialogOverlay`：

```
页面 → FastDialogOverlay → FastToastOverlay → FastLoadingOverlay
```

路由联动由 [AppRouter] 注入 `DialogRouteObserver.forManager()`，无需页面手动 `bindRoute`。

---

## 业务用法

```dart
final ok = await FastDialog.show<bool>(
  tag: 'confirm_delete',
  showConfig: const DialogShowConfig(
    animation: DialogAnimationSpec(type: DialogAnimationType.scale),
    mask: DialogMaskBlur(),
  ),
  builder: (ctx) => MyConfirmDialog(
    onConfirm: () => FastDialog.dismiss(result: true),
    onCancel: () => FastDialog.dismiss(result: false),
  ),
);
```

```dart
final class LogoutConfirmDialog extends BaseDialog<bool> {
  @override
  String get tag => 'logout_confirm';

  @override
  Widget build(BuildContext context) => /* 业务 UI */;
}
```

---

## 架构

| 层 | 类型 | 职责 |
|----|------|------|
| api | `FastDialog` | 静态门面 |
| api | `FastDialogOverlay` | 根 Overlay 挂载 |
| api | `DialogRouteObserver` | 路由 push/pop 联动 |
| core | `DialogManager` | 栈 SSOT、Future、去重 |
| core | `DialogOverlayHost` | OverlayEntry 管理 |
| domain | `BaseDialog` / `DialogShowConfig` | 约束与配置 |
| presentation | `DialogLayer` / `DialogAnimator` | 动画与 UI 外壳 |

---

## License

Private — BarrelLock monorepo.
