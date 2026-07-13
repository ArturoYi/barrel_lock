import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../settings/widgets/settings_list_tile.dart';
import '../../settings/widgets/settings_section_card.dart';

/// 横屏：内容区居中限宽展示。
final class AppLockSettingsLandscapeBody extends StatelessWidget {
  const AppLockSettingsLandscapeBody({
    super.key,
    required this.data,
    required this.enableSetupVisible,
    required this.onEnabledChanged,
    required this.onOpenPinManage,
  });

  final AppLockSettingsViewState data;
  final bool enableSetupVisible;
  final ValueChanged<bool>? onEnabledChanged;
  final VoidCallback onOpenPinManage;

  static const _contentMaxWidth = 640.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _contentMaxWidth,
                minHeight: constraints.maxHeight - 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (data.statusMessage case final message?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        message,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.error,
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSectionCard(
                    children: [
                      SettingsNavTile(
                        title: '管理备用密码',
                        subtitle: data.preferences.hasFallbackPin
                            ? '已设置'
                            : '未设置',
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
              ),
            ),
          ),
        );
      },
    );
  }
}
