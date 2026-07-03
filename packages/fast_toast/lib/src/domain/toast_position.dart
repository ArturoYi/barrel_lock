import 'package:flutter/material.dart';

/// Toast 垂直锚点。
enum ToastPositionAnchor { top, center, bottom }

/// Toast 在屏幕上的位置与偏移。
final class ToastPosition {
  const ToastPosition({
    this.anchor = ToastPositionAnchor.center,
    this.offset = Offset.zero,
  });

  static const ToastPosition center = ToastPosition();

  static ToastPosition top({double offset = 48}) {
    return ToastPosition(
      anchor: ToastPositionAnchor.top,
      offset: Offset(0, offset),
    );
  }

  static ToastPosition bottom({double offset = 48}) {
    return ToastPosition(
      anchor: ToastPositionAnchor.bottom,
      offset: Offset(0, offset),
    );
  }

  final ToastPositionAnchor anchor;
  final Offset offset;

  Alignment get alignment => switch (anchor) {
    ToastPositionAnchor.top => Alignment.topCenter,
    ToastPositionAnchor.center => Alignment.center,
    ToastPositionAnchor.bottom => Alignment.bottomCenter,
  };
}
