import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'app_lock_view_model.dart';

/// 锁屏保护设置页（各平台路由共用）。
final class AppLockSettingsPage extends ConsumerWidget {
  const AppLockSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appLockViewModelProvider);
    final viewModel = ref.read(appLockViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: const Text('锁屏保护'),
      ),
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
            if (data.statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                data.statusMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('启用锁屏保护'),
              value: data.preferences.enabled,
              onChanged: data.isLoading ? null : viewModel.onEnabledChanged,
            ),
            SwitchListTile(
              title: const Text('回到前台时使用生物识别'),
              subtitle: Text(_biometricSubtitle(data.biometricAvailability)),
              value: data.preferences.useBiometricOnResume,
              onChanged:
                  !data.preferences.enabled ||
                      data.isLoading ||
                      !_canUseBiometric(data.biometricAvailability)
                  ? null
                  : viewModel.onBiometricOnResumeChanged,
            ),
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: const Text('备用密码'),
              subtitle: Text(
                data.preferences.hasFallbackPin ? '已设置 · 可修改或清除' : '未设置',
              ),
              trailing: const Icon(Icons.chevron_right),
              enabled: data.preferences.enabled && !data.isLoading,
              onTap: data.preferences.enabled && !data.isLoading
                  ? viewModel.onOpenPinManage
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  static bool _canUseBiometric(BiometricAvailability availability) {
    return availability == BiometricAvailability.available;
  }

  static String _biometricSubtitle(BiometricAvailability availability) {
    return switch (availability) {
      BiometricAvailability.available => '当前设备可用',
      BiometricAvailability.notEnrolled => '设备未录入生物识别',
      BiometricAvailability.deviceNotSecure => '设备未设置锁屏密码',
      BiometricAvailability.notSupported => '当前平台不支持',
    };
  }
}
