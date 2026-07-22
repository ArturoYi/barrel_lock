import 'package:flutter/services.dart';

/// 主键盘 digit0-9 与小键盘 numpad0-9 → 0-9；其余返回 null（过滤）。
int? digitFromLogicalKey(LogicalKeyboardKey key) {
  return switch (key) {
    LogicalKeyboardKey.digit0 || LogicalKeyboardKey.numpad0 => 0,
    LogicalKeyboardKey.digit1 || LogicalKeyboardKey.numpad1 => 1,
    LogicalKeyboardKey.digit2 || LogicalKeyboardKey.numpad2 => 2,
    LogicalKeyboardKey.digit3 || LogicalKeyboardKey.numpad3 => 3,
    LogicalKeyboardKey.digit4 || LogicalKeyboardKey.numpad4 => 4,
    LogicalKeyboardKey.digit5 || LogicalKeyboardKey.numpad5 => 5,
    LogicalKeyboardKey.digit6 || LogicalKeyboardKey.numpad6 => 6,
    LogicalKeyboardKey.digit7 || LogicalKeyboardKey.numpad7 => 7,
    LogicalKeyboardKey.digit8 || LogicalKeyboardKey.numpad8 => 8,
    LogicalKeyboardKey.digit9 || LogicalKeyboardKey.numpad9 => 9,
    _ => null,
  };
}

bool isBackspaceOrDelete(LogicalKeyboardKey key) =>
    key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete;

bool isSubmitKey(LogicalKeyboardKey key) =>
    key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter;

bool isCancelKey(LogicalKeyboardKey key) => key == LogicalKeyboardKey.escape;
