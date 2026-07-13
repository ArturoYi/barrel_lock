import 'package:barrel_lock/features/app_lock/runtime_auth/app_lock_pin_prompt_view_model.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'app_lock_pin_prompt_panel.dart';

/// 监听 [appLockPinPromptProvider]，在根 [Overlay] 上插入 / 移除 PIN 输入面板。
final class AppLockPinPromptOverlayHost extends ConsumerStatefulWidget {
  const AppLockPinPromptOverlayHost({super.key, required this.overlayKey});

  final GlobalKey<OverlayState> overlayKey;

  @override
  ConsumerState<AppLockPinPromptOverlayHost> createState() =>
      _AppLockPinPromptOverlayHostState();
}

class _AppLockPinPromptOverlayHostState
    extends ConsumerState<AppLockPinPromptOverlayHost> {
  OverlayEntry? _entry;
  ProviderSubscription<AppLockPinPromptState?>? _pinPromptSubscription;

  @override
  void initState() {
    super.initState();
    _pinPromptSubscription = ref.listenManual(
      appLockPinPromptProvider,
      _scheduleSyncOverlayEntry,
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _pinPromptSubscription?.close();
    _removeEntry();
    super.dispose();
  }

  void _scheduleSyncOverlayEntry(
    AppLockPinPromptState? previous,
    AppLockPinPromptState? next,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncOverlayEntry(next);
    });
  }

  void _syncOverlayEntry(AppLockPinPromptState? pinPrompt) {
    if (pinPrompt == null) {
      _removeEntry();
      return;
    }

    final overlayState = widget.overlayKey.currentState;
    if (overlayState == null) {
      return;
    }

    final entry = _entry;
    if (entry == null) {
      _insertEntry(overlayState, pinPrompt);
      return;
    }

    entry.markNeedsBuild();
  }

  void _insertEntry(
    OverlayState overlayState,
    AppLockPinPromptState pinPrompt,
  ) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final state = ref.read(appLockPinPromptProvider);
        if (state == null) {
          return const SizedBox.shrink();
        }

        return AppLockPinPromptPanel(state: state);
      },
    );

    _entry = entry;
    overlayState.insert(entry);
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

  @override
  Widget build(BuildContext context) {
    ref.watch(appLockPinPromptProvider);
    return const SizedBox.shrink();
  }
}
