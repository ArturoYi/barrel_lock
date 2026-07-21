import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import 'vault_search_bar.dart';
import 'vault_switcher_button.dart';

/// 搜索栏 + 保险库切换：保持单一 [VaultSearchBar] 实例，聚焦时仅动画位移切换按钮。
class VaultHomeSearchRow extends StatefulWidget {
  const VaultHomeSearchRow({
    super.key,
    required this.query,
    required this.onChanged,
    required this.vaults,
    required this.selectedVault,
    required this.onVaultSelected,
    this.onCreateVault,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final List<VaultSummary> vaults;
  final VaultSummary selectedVault;
  final ValueChanged<String> onVaultSelected;
  final VoidCallback? onCreateVault;

  @override
  State<VaultHomeSearchRow> createState() => _VaultHomeSearchRowState();
}

class _VaultHomeSearchRowState extends State<VaultHomeSearchRow> {
  var _searchFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: VaultSearchBar(
                query: widget.query,
                onChanged: widget.onChanged,
                onFocusChanged: _onSearchFocusChanged,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.hardEdge,
              child: _searchFocused
                  ? const SizedBox(width: 0, height: 44)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 10),
                        VaultSwitcherButton(
                          vaults: widget.vaults,
                          selectedVault: widget.selectedVault,
                          onVaultSelected: widget.onVaultSelected,
                          onCreateVault: widget.onCreateVault,
                        ),
                      ],
                    ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: _searchFocused
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: VaultSwitcherButton(
                      vaults: widget.vaults,
                      selectedVault: widget.selectedVault,
                      onVaultSelected: widget.onVaultSelected,
                      onCreateVault: widget.onCreateVault,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _onSearchFocusChanged(bool focused) {
    if (_searchFocused == focused) {
      return;
    }
    setState(() => _searchFocused = focused);
  }
}
