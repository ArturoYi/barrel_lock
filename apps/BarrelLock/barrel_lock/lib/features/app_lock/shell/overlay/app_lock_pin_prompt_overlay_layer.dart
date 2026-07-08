import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../runtime_auth/app_lock_pin_prompt_view_model.dart';
import 'app_lock_pin_prompt_panel.dart';

/// 为全局 PIN 输入面板提供 [Overlay] 祖先（挂在 [MaterialApp.builder] 外层）。
///
/// [EditableText] 创建选区浮层时需要 Overlay；直接放在 Stack 里会触发
/// `debugCheckHasOverlay`。
final class AppLockPinPromptOverlayLayer extends ConsumerStatefulWidget {
  const AppLockPinPromptOverlayLayer({super.key});

  @override
  ConsumerState<AppLockPinPromptOverlayLayer> createState() =>
      _AppLockPinPromptOverlayLayerState();
}

class _AppLockPinPromptOverlayLayerState
    extends ConsumerState<AppLockPinPromptOverlayLayer> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? _entry;
  AppLockPinPromptState? _currentPrompt;
  ProviderSubscription<AppLockPinPromptState?>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual(appLockPinPromptProvider, (
      previous,
      next,
    ) {
      _scheduleSync(next);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncEntry(ref.read(appLockPinPromptProvider));
    });
  }

  @override
  void dispose() {
    _subscription?.close();
    _removeEntry();
    super.dispose();
  }

  void _scheduleSync(AppLockPinPromptState? pinPrompt) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncEntry(pinPrompt);
      }
    });
  }

  void _syncEntry(AppLockPinPromptState? pinPrompt) {
    final overlayState = _overlayKey.currentState;
    if (overlayState == null) {
      return;
    }

    if (pinPrompt == null) {
      _removeEntry();
      return;
    }

    _currentPrompt = pinPrompt;

    if (_entry == null) {
      _entry = OverlayEntry(
        builder: (context) {
          final prompt = _currentPrompt;
          if (prompt == null) {
            return const SizedBox.shrink();
          }
          return Positioned.fill(
            child: FocusScope(child: AppLockPinPromptPanel(state: prompt)),
          );
        },
      );
      overlayState.insert(_entry!);
      return;
    }

    _entry!.markNeedsBuild();
  }

  void _removeEntry() {
    _currentPrompt = null;
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(key: _overlayKey);
  }
}
