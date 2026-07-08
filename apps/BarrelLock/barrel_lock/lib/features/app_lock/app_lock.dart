/// 锁屏保护共享业务层（MVVM-C 的 M / VM / C）。
///
/// ## 目录结构
///
/// ```
/// features/app_lock/
/// ├── app_lock.dart          # 本文件：模块导出入口
/// ├── model/                 # M 层
/// ├── coordinator/           # C 层
/// ├── view_model/            # VM 层
/// ├── delegate/              # core 身份验证 UI 桥接
/// └── shell/                 # 生命周期绑定（非页面 View）
/// ```
///
/// ## 分层对照
///
/// | 目录 / 文件 | 层 | 职责 |
/// |---|---|---|
/// | `model/app_lock_model.dart` | M | 偏好持久化 |
/// | `model/app_lock_auth_service.dart` | M | 身份验证门面 |
/// | `coordinator/app_lock_coordinator.dart` | C | 路由跳转 |
/// | `view_model/app_lock_view_model.dart` | VM | 设置页 |
/// | `view_model/app_lock_pin_manage_view_model.dart` | VM | 备用密码管理 |
/// | `view_model/app_lock_session_view_model.dart` | VM | 冷启动 / 后台锁定 |
/// | `view_model/app_lock_pin_prompt_view_model.dart` | VM | 全局 PIN 输入 |
/// | `shell/app_lock_session_lifecycle.dart` | Shell | 生命周期桥接 |
/// | `shell/app_lock_overlay/` | Shell View | 全局锁屏 / PIN Overlay |
///
/// **路由页面 View**由各平台 `lib/pages/app_lock/` 实现；**全局 Overlay View** 在 `shell/app_lock_overlay/`。
library;

export 'coordinator/app_lock_coordinator.dart';
export 'delegate/barrel_lock_identity_auth_ui_delegate.dart';
export 'model/app_lock_auth_service.dart';
export 'model/app_lock_model.dart';
export 'shell/app_lock_overlay/app_lock_overlay.dart';
export 'shell/app_lock_session_lifecycle.dart';
export 'view_model/app_lock_pin_manage_view_model.dart';
export 'view_model/app_lock_pin_prompt_view_model.dart';
export 'view_model/app_lock_session_view_model.dart';
export 'view_model/app_lock_view_model.dart';
