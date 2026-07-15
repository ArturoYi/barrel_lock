import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 毛玻璃搜索栏；聚焦态由内部 [FocusNode] 驱动，避免外部重建导致焦点丢失。
class VaultSearchBar extends StatefulWidget {
  const VaultSearchBar({
    super.key,
    required this.query,
    required this.onChanged,
    this.onFocusChanged,
  });

  final String query;
  final ValueChanged<String> onChanged;

  /// 仅用于同级布局动画（如保险库切换按钮位移），不应写入 ViewModel。
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<VaultSearchBar> createState() => _VaultSearchBarState();
}

class _VaultSearchBarState extends State<VaultSearchBar> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  var _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant VaultSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller
        ..text = widget.query
        ..selection = TextSelection.collapsed(offset: widget.query.length);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    final hasFocus = _focusNode.hasFocus;
    if (hasFocus == _hasFocus) {
      return;
    }
    setState(() => _hasFocus = hasFocus);
    final callback = widget.onFocusChanged;
    if (callback == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      callback(hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: 44,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(
                alpha: _hasFocus ? 0.72 : 0.5,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasFocus
                    ? colorScheme.primary.withValues(alpha: 0.55)
                    : colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              onChanged: widget.onChanged,
              style: context.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '搜索密码、网站、用户名',
                hintStyle: context.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                suffixIcon: widget.query.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => widget.onChanged(''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
