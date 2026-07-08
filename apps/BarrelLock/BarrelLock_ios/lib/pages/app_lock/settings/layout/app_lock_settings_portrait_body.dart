import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../settings/widgets/settings_list_tile.dart';
import '../../../settings/widgets/settings_section_card.dart';

/// 竖屏：滚动列表展示应用保护设置项。
final class AppLockSettingsPortraitBody extends StatelessWidget {
  const AppLockSettingsPortraitBody({
    super.key,
    required this.data,
    required this.enableSetupVisible,
    required this.onEnabledChanged,
    required this.onBiometricOnResumeChanged,
    required this.onOpenPinManage,
  });

  final AppLockSettingsViewState data;
  final bool enableSetupVisible;
  final ValueChanged<bool>? onEnabledChanged;
  final ValueChanged<bool>? onBiometricOnResumeChanged;
  final VoidCallback onOpenPinManage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (data.statusMessage case final message?)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        SettingsSectionCard(
          children: [
            SettingsSwitchTile(
              title: '启用应用保护',
              subtitle: '冷启动与回到前台时需要验证身份',
              icon: Icons.lock_outline,
              value: data.preferences.enabled,
              onChanged: onEnabledChanged,
            ),
            if (data.biometricAvailability == BiometricAvailability.available)
              SettingsSwitchTile(
                title: '回到前台时使用生物识别',
                subtitle: '优先使用面容 ID / 指纹，失败时回退数字密码',
                icon: Icons.fingerprint,
                value: data.preferences.useBiometricOnResume,
                onChanged: onBiometricOnResumeChanged,
              ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsSectionCard(
          children: [
            SettingsNavTile(
              title: '管理备用密码',
              subtitle: data.preferences.hasFallbackPin ? '已设置' : '未设置',
              icon: Icons.password_outlined,
              enabled: !enableSetupVisible,
              onTap: onOpenPinManage,
            ),
          ],
        ),
        if (data.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
