import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'layout/cipher_add_portrait_view.dart';

/// 添加密码页（MVVM-C 的 V 层）。
class CipherAddPage extends ConsumerWidget {
  const CipherAddPage({this.vaultId, this.cipherType, super.key});

  final String? vaultId;
  final int? cipherType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        cipherAddVaultIdProvider.overrideWithValue(vaultId),
        cipherAddInitialTypeProvider.overrideWithValue(
          cipherType ?? CipherType.websiteLogin,
        ),
      ],
      child: const _CipherAddPageBody(),
    );
  }
}

final class _CipherAddPageBody extends ConsumerStatefulWidget {
  const _CipherAddPageBody();

  @override
  ConsumerState<_CipherAddPageBody> createState() => _CipherAddPageBodyState();
}

final class _CipherAddPageBodyState extends ConsumerState<_CipherAddPageBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.invalidate(cipherAddViewModelProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cipherAddViewModelProvider);
    final viewModel = ref.read(cipherAddViewModelProvider.notifier);

    ref.listen(cipherAddViewModelProvider, (previous, next) {
      final message = next.errorMessage;
      if (message == null || message == previous?.errorMessage) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });

    return OrientationBuilder(
      builder: (context, orientation) {
        return CipherAddPortraitView(
          state: state,
          onCipherTypeSelected: viewModel.onCipherTypeSelected,
          onTitleChanged: viewModel.onTitleChanged,
          onUsernameChanged: viewModel.onUsernameChanged,
          onPasswordChanged: viewModel.onPasswordChanged,
          onWebsiteChanged: viewModel.onWebsiteChanged,
          onPackageNameChanged: viewModel.onPackageNameChanged,
          onNotesChanged: viewModel.onNotesChanged,
          onCardholderNameChanged: viewModel.onCardholderNameChanged,
          onCardNumberChanged: viewModel.onCardNumberChanged,
          onExpiryMonthChanged: viewModel.onExpiryMonthChanged,
          onExpiryYearChanged: viewModel.onExpiryYearChanged,
          onCvvChanged: viewModel.onCvvChanged,
          onPinChanged: viewModel.onPinChanged,
          onDocumentTypeChanged: viewModel.onDocumentTypeChanged,
          onFullNameChanged: viewModel.onFullNameChanged,
          onDocumentNumberChanged: viewModel.onDocumentNumberChanged,
          onIssueDateChanged: viewModel.onIssueDateChanged,
          onExpiryDateChanged: viewModel.onExpiryDateChanged,
          onContentChanged: viewModel.onContentChanged,
          onPrivateKeyChanged: viewModel.onPrivateKeyChanged,
          onPublicKeyChanged: viewModel.onPublicKeyChanged,
          onPassphraseChanged: viewModel.onPassphraseChanged,
          onHostChanged: viewModel.onHostChanged,
          onCancel: viewModel.onCancel,
          onSave: viewModel.onSave,
        );
      },
    );
  }
}
