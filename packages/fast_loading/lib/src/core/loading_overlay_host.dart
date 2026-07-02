import 'package:flutter/material.dart';

import '../presentation/loading_overlay_content.dart';
import 'loading_controller.dart';

/// 管理单一 [OverlayEntry] 的插入与移除。
final class LoadingOverlayHost {
  OverlayState? _overlayState;
  OverlayEntry? _entry;

  bool get hasEntry => _entry != null;

  void attach(OverlayState overlayState) {
    _overlayState = overlayState;
  }

  void detach() {
    _removeEntry();
    _overlayState = null;
  }

  void show() {
    final overlayState = _overlayState;
    if (overlayState == null) {
      return;
    }

    if (_entry != null) {
      return;
    }

    final entry = OverlayEntry(
      builder: (context) {
        return ListenableBuilder(
          listenable: LoadingController.instance,
          builder: (context, _) {
            final controller = LoadingController.instance;
            return LoadingOverlayContent(
              config: controller.config,
              displayPhase: controller.displayPhase,
              resultWidget: controller.resultWidget,
              resultMessage: controller.resultMessage,
            );
          },
        );
      },
    );
    _entry = entry;
    overlayState.insert(entry);
  }

  void hide() {
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
  }
}
