/// 锁屏保护共享业务层（MVVM-C 的 M / VM / C）。
///
/// ## 目录结构
///
/// ```
/// features/app_lock/
/// ├── app_lock.dart              # 本文件：模块导出入口
/// ├── shared/                    # 跨子域 M / C / 策略
/// ├── settings/                  # 应用保护设置偏好
/// ├── enable_setup/              # 开启保护前的 PIN 设置
/// ├── pin_manage/                # 备用密码日常管理
/// ├── session/                   # 运行时锁定会话
/// ├── runtime_auth/              # 运行时解锁 PIN
/// └── shell/overlay/             # 全局锁屏 / PIN Overlay
/// ```
library;

export 'enable_setup/app_lock_enable_setup_coordinator.dart';
export 'enable_setup/app_lock_enable_setup_state.dart';
export 'enable_setup/app_lock_enable_setup_view_model.dart';
export 'pin_manage/app_lock_pin_manage_view_model.dart';
export 'runtime_auth/app_lock_pin_prompt_view_model.dart';
export 'runtime_auth/barrel_lock_identity_auth_ui_delegate.dart';
export 'session/app_lock_session_lifecycle.dart';
export 'session/app_lock_session_view_model.dart';
export 'settings/app_lock_settings_view_model.dart';
export 'shared/coordinator/app_lock_coordinator.dart';
export 'shared/model/app_lock_auth_service.dart';
export 'shared/model/app_lock_model.dart';
export 'shared/model/app_lock_preferences.dart';
export 'shared/policy/app_lock_pin_policy.dart';
export 'shell/overlay/app_lock_overlay.dart';
export 'shell/overlay/pin_field_focus.dart';
