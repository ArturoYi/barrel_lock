import 'package:flutter/material.dart';

import '../domain/dialog_entry.dart';
import '../presentation/dialog_overlay_layer.dart';

/// 管理根 [OverlayState] 上各弹窗 [OverlayEntry] 的插入、更新与移除。
///
/// 与 [DialogManager] 分工：
/// - Manager 负责栈语义与 Future
/// - Host 负责 Overlay 物理层与 zIndex 排序
final class DialogOverlayHost {
  OverlayState? _overlayState;
  final Map<String, _MountedDialog> _mounted = {};

  bool get isAttached => _overlayState != null;

  void attach(OverlayState overlayState) {
    _overlayState = overlayState;
  }

  void detach() {
    for (final mounted in _mounted.values) {
      mounted.overlayEntry.remove();
      mounted.overlayEntry.dispose();
    }
    _mounted.clear();
    _overlayState = null;
  }

  /// 插入新弹窗 [OverlayEntry]，按 [DialogShowConfig.zIndex] 决定层级。
  void present(DialogEntry<dynamic> entry, {required VoidCallback onDismiss}) {
    final overlay = _overlayState;
    if (overlay == null) {
      return;
    }

    final handle = DialogLayerHandle();
    final overlayEntry = OverlayEntry(
      builder: (context) => DialogLayer(
        key: ValueKey(entry.id),
        entry: entry,
        handle: handle,
        onShowComplete: () => entry.showConfig.onShow?.call(),
        onDismiss: onDismiss,
      ),
    );

    _mounted[entry.id] = _MountedDialog(
      overlayEntry: overlayEntry,
      handle: handle,
      entry: entry,
    );

    final below = _insertBelowTarget(entry.showConfig.zIndex);
    if (below != null) {
      overlay.insert(overlayEntry, below: below);
    } else {
      overlay.insert(overlayEntry);
    }
  }

  /// 同 tag 复用时，原地刷新 [DialogLayer] 的 builder/config。
  void refresh(DialogEntry<dynamic> entry) {
    _mounted[entry.id]?.handle.updateEntry(entry);
    _mounted[entry.id]?.entry = entry;
  }

  /// 触发 [DialogLayer] 退场动画，结束后执行 [onComplete]。
  void dismiss(String id, {required VoidCallback onComplete}) {
    final mounted = _mounted[id];
    if (mounted == null) {
      onComplete();
      return;
    }

    mounted.handle.dismiss().then((_) {
      _removeMounted(id);
      onComplete();
    });
  }

  void dismissAll({required VoidCallback onComplete}) {
    if (_mounted.isEmpty) {
      onComplete();
      return;
    }

    var remaining = _mounted.length;
    final ids = _mounted.keys.toList(growable: false);
    for (final id in ids) {
      dismiss(
        id,
        onComplete: () {
          remaining--;
          if (remaining == 0) {
            onComplete();
          }
        },
      );
    }
  }

  /// 找到第一个 zIndex 大于目标的 Entry，在其下方插入（保证低 zIndex 在底下）。
  OverlayEntry? _insertBelowTarget(int zIndex) {
    final sorted = _mounted.values.toList()
      ..sort(
        (a, b) =>
            a.entry.showConfig.zIndex.compareTo(b.entry.showConfig.zIndex),
      );

    for (final mounted in sorted) {
      if (mounted.entry.showConfig.zIndex > zIndex) {
        return mounted.overlayEntry;
      }
    }
    return null;
  }

  void _removeMounted(String id) {
    final mounted = _mounted.remove(id);
    if (mounted == null) {
      return;
    }
    mounted.overlayEntry.remove();
    mounted.overlayEntry.dispose();
  }
}

final class _MountedDialog {
  _MountedDialog({
    required this.overlayEntry,
    required this.handle,
    required this.entry,
  });

  final OverlayEntry overlayEntry;
  final DialogLayerHandle handle;
  DialogEntry<dynamic> entry;
}

/// Presentation 层触发关闭的桥接，避免 Host/Layer 与 Manager 循环依赖。
abstract final class DialogManagerBridge {
  static void Function(String id)? dismissById;

  static void dismiss(String id) => dismissById?.call(id);
}
