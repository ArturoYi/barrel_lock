import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

var _pinFieldFocusGeneration = 0;

/// 在 Overlay / 系统身份验证弹窗关闭后再请求 PIN 输入框焦点。
///
/// 避免与 iOS `TUIKeyplane` 键盘布局竞争，引发 Auto Layout 约束冲突。
///
/// [afterSystemAuth] 为 `true` 时（生物识别 / 设备密码取消后回退应用内 PIN），
/// 会等待系统键盘完全收起再获焦，且不在 iOS 上主动 unfocus 以免触发键盘闪烁。
void schedulePinFieldFocus(
  FocusNode focusNode, {
  required bool Function() isMounted,
  bool afterSystemAuth = false,
}) {
  final generation = ++_pinFieldFocusGeneration;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!isMounted() || generation != _pinFieldFocusGeneration) {
      return;
    }

    await _prepareKeyboardHandoff(afterSystemAuth: afterSystemAuth);

    if (!isMounted() || generation != _pinFieldFocusGeneration) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted() || generation != _pinFieldFocusGeneration) {
        return;
      }
      if (!_canRequestPinFieldFocus(focusNode)) {
        return;
      }
      focusNode.requestFocus();
    });
  });
}

/// 取消尚未执行的延迟获焦，并释放当前焦点。
void releasePinFieldFocus(FocusNode focusNode) {
  _pinFieldFocusGeneration++;
  if (focusNode.hasFocus) {
    focusNode.unfocus();
  }
}

/// 仅取消尚未执行的延迟获焦（面板关闭时避免与 iOS 键盘收起竞争）。
void cancelPendingPinFieldFocus() {
  _pinFieldFocusGeneration++;
}

Future<void> _prepareKeyboardHandoff({required bool afterSystemAuth}) async {
  if (defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android) {
    return;
  }

  if (afterSystemAuth) {
    await _waitForSystemKeyboardDismissed();
    return;
  }

  FocusManager.instance.primaryFocus?.unfocus();
  await Future<void>.delayed(const Duration(milliseconds: 150));
}

Future<void> _waitForSystemKeyboardDismissed() async {
  const pollInterval = Duration(milliseconds: 50);
  const minWait = Duration(milliseconds: 500);
  const settleWait = Duration(milliseconds: 150);
  const timeout = Duration(seconds: 2);

  final started = DateTime.now();
  final deadline = started.add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    final elapsed = DateTime.now().difference(started);
    if (elapsed >= minWait && _isKeyboardInsetCleared()) {
      await Future<void>.delayed(settleWait);
      if (_isKeyboardInsetCleared()) {
        return;
      }
    }
    await Future<void>.delayed(pollInterval);
  }

  await _hideActiveTextInput();
}

Future<void> _hideActiveTextInput() async {
  try {
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  } on Object {
    // 测试环境或未挂载输入通道时忽略。
  }
}

bool _isKeyboardInsetCleared() {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isEmpty) {
    return true;
  }

  final view = views.first;
  final bottomInset = view.viewInsets.bottom / view.devicePixelRatio;
  return bottomInset <= 0;
}

bool _canRequestPinFieldFocus(FocusNode focusNode) {
  if (!focusNode.canRequestFocus) {
    return false;
  }

  final context = focusNode.context;
  if (context == null || !context.mounted) {
    return false;
  }

  return Overlay.maybeOf(context) != null;
}
