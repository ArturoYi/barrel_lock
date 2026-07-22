import 'package:core/core.dart';

/// 由添加页 [ProviderScope] override，传入当前 Tab 选中的 vaultId。
final cipherAddVaultIdProvider = Provider<String?>(
  (ref) => null,
  name: 'cipherAddVaultId',
);

/// 由添加页 [ProviderScope] override，传入路由 query `type`。
final cipherAddInitialTypeProvider = Provider<int>(
  (ref) => CipherType.websiteLogin,
  name: 'cipherAddInitialType',
);
