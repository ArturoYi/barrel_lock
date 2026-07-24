import 'package:fast_loading/fast_loading.dart';
import 'package:fast_toast/fast_toast.dart';

import 'package:app_l10n/app_l10n.dart';

typedef L10nPick = String Function(AppLocalizations l);

/// Toast / Loading 的无 Context 本地化便捷 API。
abstract final class OverlayL10n {
  OverlayL10n._();

  static void showToast(
    L10nPick pick, {
    ToastType type = ToastType.custom,
    ToastConfig? config,
    ToastStyle? style,
  }) {
    FastToast.show(
      pick(AppL10n.current),
      type: type,
      config: config,
      style: style,
    );
  }

  static void successToast(
    L10nPick pick, {
    ToastConfig? config,
    ToastStyle? style,
  }) {
    FastToast.success(pick(AppL10n.current), config: config, style: style);
  }

  static void errorToast(
    L10nPick pick, {
    ToastConfig? config,
    ToastStyle? style,
  }) {
    FastToast.error(pick(AppL10n.current), config: config, style: style);
  }

  static void showLoading([L10nPick? pick]) {
    FastLoading.show(
      message: (pick ?? (l) => l.overlay_loading)(AppL10n.current),
    );
  }

  static void showLoadingPleaseWait() {
    showLoading((l) => l.overlay_please_wait);
  }
}
