import 'package:flutter/material.dart';

import '../domain/toast_request.dart';
import '../presentation/toast_widget.dart';

/// 管理单槽 [OverlayEntry] 的插入与移除。
final class ToastOverlayHost {
  OverlayState? _overlayState;
  OverlayEntry? _entry;
  VoidCallback? _dismissCurrent;

  bool get hasEntry => _entry != null;

  OverlayState? get overlayState => _overlayState;

  void attach(OverlayState overlayState) {
    _overlayState = overlayState;
  }

  void detach() {
    _removeEntry();
    _overlayState = null;
    _dismissCurrent = null;
  }

  void show({
    required ToastRequest request,
    required VoidCallback onDismissed,
  }) {
    final overlayState = _overlayState;
    if (overlayState == null) {
      return;
    }

    _removeEntry();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return ToastOverlayContent(
          request: request,
          onRegisterDismiss: (trigger) {
            _dismissCurrent = trigger;
          },
          onDismissed: () {
            if (_entry == entry) {
              _removeEntry();
            }
            onDismissed();
          },
        );
      },
    );

    _entry = entry;
    overlayState.insert(entry);
  }

  void dismissCurrent() {
    _dismissCurrent?.call();
  }

  void removeImmediately() {
    _removeEntry();
  }

  void _removeEntry() {
    final entry = _entry;
    if (entry == null) {
      return;
    }
    entry.remove();
    entry.dispose();
    _entry = null;
    _dismissCurrent = null;
  }
}
