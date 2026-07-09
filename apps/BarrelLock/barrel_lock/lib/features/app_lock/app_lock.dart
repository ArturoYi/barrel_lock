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
/// ├── pin_manage/                # 应用内 PIN 日常管理
/// ├── session/                   # 运行时锁定会话
/// ├── runtime_auth/              # 运行时解锁 PIN（UI 委托 + 全局 PIN 遮罩 VM）
/// └── overlay/                   # 全局锁屏 Overlay
///     ├── app_lock_overlay.dart  # 锁屏容器
///     └── pin_prompt/            # 运行时 PIN 输入面板
/// ```
///
/// ## 术语（应用内 PIN）
///
/// | 层级 | 名称 | 说明 |
/// |------|------|------|
/// | UI 文案 | 备用密码 | 设置页、PIN 管理页等面向用户的称呼 |
/// | 业务 / VM 状态 | `hasFallbackPin` | [AppLockPreferences.hasFallbackPin]、各 ViewModel 展示字段 |
/// | Auth 持久化 SSOT | `hasAppPin` / `setAppPin` | [AppLockAuthService] → [AppIdentityAuth]（哈希落盘） |
///
/// 「备用」指生物识别不可用或失败时的回退解锁方式，不是系统锁屏密码。
/// ViewModel 写入 PIN 后须同步更新 [AppLockPreferences.hasFallbackPin]。
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
export 'overlay/app_lock_overlay.dart';
