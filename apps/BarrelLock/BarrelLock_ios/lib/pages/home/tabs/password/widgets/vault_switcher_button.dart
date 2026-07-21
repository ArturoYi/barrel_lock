import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 保险库切换下拉。
class VaultSwitcherButton extends StatelessWidget {
  const VaultSwitcherButton({
    super.key,
    required this.vaults,
    required this.selectedVault,
    required this.onVaultSelected,
    this.onCreateVault,
  });

  static const createVaultSentinel = '__create_vault__';

  final List<VaultSummary> vaults;
  final VaultSummary selectedVault;
  final ValueChanged<String> onVaultSelected;
  final VoidCallback? onCreateVault;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return PopupMenuButton<String>(
      initialValue: selectedVault.id,
      tooltip: '切换保险库',
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (value) {
        if (value == createVaultSentinel) {
          onCreateVault?.call();
          return;
        }
        onVaultSelected(value);
      },
      itemBuilder: (context) {
        return [
          for (final vault in vaults)
            PopupMenuItem<String>(
              value: vault.id,
              child: Row(
                children: [
                  Icon(
                    _iconForVault(vault),
                    size: 20,
                    color: vault.id == selectedVault.id
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      vault.name,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: vault.id == selectedVault.id
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (vault.id == selectedVault.id)
                    Icon(Icons.check_rounded, color: colorScheme.primary),
                ],
              ),
            ),
          if (onCreateVault != null) ...[
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: createVaultSentinel,
              child: Row(
                children: [
                  Icon(Icons.add_rounded, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  const Text('新建保险库'),
                ],
              ),
            ),
          ],
        ];
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForVault(selectedVault),
                size: 18,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                selectedVault.name,
                style: context.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForVault(VaultSummary vault) {
    return switch (vault.iconName) {
      'work' => Icons.work_outline_rounded,
      _ => Icons.person_outline_rounded,
    };
  }
}
