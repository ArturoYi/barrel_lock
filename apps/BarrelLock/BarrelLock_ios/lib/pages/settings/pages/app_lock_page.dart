import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_list_tile.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_subpage_scaffold.dart';

/// 锁屏保护配置页（MVVM-C 的 V 层）。
class AppLockPage extends ConsumerWidget {
  const AppLockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appLockViewModelProvider);
    final viewModel = ref.read(appLockViewModelProvider.notifier);

    return SettingsSubpageScaffold(
      title: '锁屏保护',
      onBack: viewModel.onPop,
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '切到后台再返回时验证身份，无生物识别时使用应用内密码。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SettingsSectionCard(
              children: [
                SettingsSwitchTile(
                  title: '启用锁屏保护',
                  value: data.preferences.enabled,
                  onChanged: data.isLoading ? null : viewModel.onEnabledChanged,
                ),
                SettingsSwitchTile(
                  title: '回到前台时使用生物识别',
                  value: data.preferences.useBiometricOnResume,
                  onChanged: !data.preferences.enabled || data.isLoading
                      ? null
                      : viewModel.onBiometricOnResumeChanged,
                ),
                SettingsNavTile(
                  icon: Icons.pin_outlined,
                  title: '备用密码',
                  subtitle: data.preferences.hasFallbackPin ? '已设置' : '未设置',
                  enabled: data.preferences.enabled && !data.isLoading,
                  // TODO: 接入 PIN 设置流程（ViewModel + Coordinator）
                  onTap: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
