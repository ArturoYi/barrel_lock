import 'package:core/core.dart';

import '../../crypto/app_account_cipher_payload.dart';
import '../../crypto/bank_card_cipher_payload.dart';
import '../../crypto/cipher_full_data_codec.dart';
import '../../crypto/cipher_full_data_payload.dart';
import '../../crypto/cipher_overview_codec.dart';
import '../../crypto/cipher_overview_data.dart';
import '../../crypto/identity_document_cipher_payload.dart';
import '../../crypto/secure_note_cipher_payload.dart';
import '../../crypto/ssh_key_cipher_payload.dart';
import '../../crypto/website_login_cipher_payload.dart';
import '../../storage/storage_providers.dart';
import '../vault_manage/vault_manage_model.dart';

/// 添加密码页业务数据（MVVM-C 的 M 层）。
///
/// **字段映射约定**
/// - [CipherEntry.type]：与 [CipherFullDataPayload.type] 一致（见 [CipherType]）
/// - [CipherEntry.overviewBlob]：列表层 [CipherOverviewData]（各类型共用结构）
/// - [CipherEntry.fullDataBlob]：详情层 [CipherFullDataPayload] 子类 JSON
///
/// 各类型 overview / full_data schema 见 `packages/core/lib/storage/密码App数据表设计.md`。
final class CipherAddModel {
  CipherAddModel(this._repos, this._vaultManage);

  final StorageRepositories _repos;
  final VaultManageModel _vaultManage;

  /// 解析目标保险库：优先选用传入 ID，否则首个 active vault，否则新建默认库。
  Future<String> resolveVaultUuid({String? preferredVaultId}) async {
    if (preferredVaultId != null && preferredVaultId.isNotEmpty) {
      final vault = await _repos.vaults.findById(preferredVaultId);
      if (vault != null && !vault.isTrashed) {
        return preferredVaultId;
      }
    }

    final activeVaults = await _repos.vaults.watchActive().first;
    if (activeVaults.isNotEmpty) {
      return activeVaults.first.vaultUuid;
    }

    return createDefaultVault();
  }

  /// 创建默认保险库「我的保险库」。
  Future<String> createDefaultVault() {
    return _vaultManage.createVault(name: '我的保险库');
  }

  /// 通用保存入口：写入任意已支持类型的 cipher 条目。
  Future<String> saveCipher({
    required int type,
    required String? preferredVaultId,
    required CipherOverviewData overview,
    required CipherFullDataPayload fullData,
    String? folderUuid,
  }) async {
    if (fullData.type != type) {
      throw ArgumentError.value(
        fullData,
        'fullData',
        'fullData.type (${fullData.type}) must match type ($type)',
      );
    }

    final vaultUuid = await resolveVaultUuid(
      preferredVaultId: preferredVaultId,
    );
    final now = DateTime.now().toUtc();
    final cipherUuid = AppIds.newUuid();

    final overviewBlob = await CipherOverviewCodec.encrypt(overview);
    final fullDataBlob = await CipherFullDataCodec.encrypt(fullData);

    await _repos.cipherEntries.insert(
      CipherEntry(
        cipherUuid: cipherUuid,
        vaultUuid: vaultUuid,
        folderUuid: folderUuid,
        ownerAccountId: null,
        type: type,
        overviewBlob: overviewBlob,
        fullDataBlob: fullDataBlob,
        isFavorite: false,
        deletedAt: null,
        syncRevision: now,
        localModified: true,
        remoteId: null,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return cipherUuid;
  }

  /// 保存网站登录类（`CipherType.websiteLogin`）密码条目。
  Future<String> saveWebsiteLoginCipher({
    required String? preferredVaultId,
    required String title,
    required String username,
    required String password,
    required String website,
    required String notes,
    String? folderUuid,
  }) {
    final host = parseWebsiteHost(website);
    return saveCipher(
      type: CipherType.websiteLogin,
      preferredVaultId: preferredVaultId,
      folderUuid: folderUuid,
      overview: CipherOverviewData(
        title: title.trim(),
        subtitle: username.trim(),
        host: host,
      ),
      fullData: WebsiteLoginCipherPayload(
        username: username.trim(),
        password: password,
        notes: notes.trim().isEmpty ? null : notes.trim(),
      ),
    );
  }

  /// 保存银行卡类（`CipherType.bankCard`）密码条目。
  Future<String> saveBankCardCipher({
    required String? preferredVaultId,
    required String title,
    required String cardholderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String pin,
    required String notes,
    String? folderUuid,
  }) {
    final normalizedNumber = cardNumber.replaceAll(RegExp(r'\s'), '');
    return saveCipher(
      type: CipherType.bankCard,
      preferredVaultId: preferredVaultId,
      folderUuid: folderUuid,
      overview: CipherOverviewData(
        title: title.trim(),
        subtitle: lastFourDigits(normalizedNumber),
      ),
      fullData: BankCardCipherPayload(
        cardholderName: cardholderName.trim(),
        cardNumber: normalizedNumber,
        expiryMonth: expiryMonth.trim(),
        expiryYear: expiryYear.trim(),
        cvv: cvv.trim(),
        pin: pin.trim().isEmpty ? null : pin.trim(),
        notes: notes.trim().isEmpty ? null : notes.trim(),
      ),
    );
  }

  /// 保存身份证件类（`CipherType.identityDocument`）密码条目。
  Future<String> saveIdentityDocumentCipher({
    required String? preferredVaultId,
    required String title,
    required String documentType,
    required String fullName,
    required String documentNumber,
    required String issueDate,
    required String expiryDate,
    required String notes,
    String? folderUuid,
  }) {
    return saveCipher(
      type: CipherType.identityDocument,
      preferredVaultId: preferredVaultId,
      folderUuid: folderUuid,
      overview: CipherOverviewData(
        title: title.trim(),
        subtitle: maskDocumentNumber(documentNumber.trim()),
      ),
      fullData: IdentityDocumentCipherPayload(
        documentType: documentType.trim(),
        fullName: fullName.trim(),
        documentNumber: documentNumber.trim(),
        issueDate: issueDate.trim().isEmpty ? null : issueDate.trim(),
        expiryDate: expiryDate.trim().isEmpty ? null : expiryDate.trim(),
        notes: notes.trim().isEmpty ? null : notes.trim(),
      ),
    );
  }

  /// 保存安全笔记类（`CipherType.secureNote`）密码条目。
  Future<String> saveSecureNoteCipher({
    required String? preferredVaultId,
    required String title,
    required String content,
    required String notes,
    String? folderUuid,
  }) {
    return saveCipher(
      type: CipherType.secureNote,
      preferredVaultId: preferredVaultId,
      folderUuid: folderUuid,
      overview: CipherOverviewData(
        title: title.trim(),
        subtitle: contentSummary(content),
      ),
      fullData: SecureNoteCipherPayload(
        content: content.trim(),
        notes: notes.trim().isEmpty ? null : notes.trim(),
      ),
    );
  }

  /// 保存 SSH 密钥类（`CipherType.sshKey`）密码条目。
  Future<String> saveSshKeyCipher({
    required String? preferredVaultId,
    required String title,
    required String privateKey,
    required String publicKey,
    required String passphrase,
    required String host,
    required String username,
    required String notes,
    String? folderUuid,
  }) {
    final trimmedHost = host.trim();
    final trimmedUser = username.trim();
    return saveCipher(
      type: CipherType.sshKey,
      preferredVaultId: preferredVaultId,
      folderUuid: folderUuid,
      overview: CipherOverviewData(
        title: title.trim(),
        subtitle: sshSubtitle(trimmedUser, trimmedHost),
        host: trimmedHost.isEmpty ? null : trimmedHost,
      ),
      fullData: SshKeyCipherPayload(
        privateKey: privateKey,
        publicKey: publicKey.trim().isEmpty ? null : publicKey.trim(),
        passphrase: passphrase.trim().isEmpty ? null : passphrase.trim(),
        host: trimmedHost.isEmpty ? null : trimmedHost,
        username: trimmedUser.isEmpty ? null : trimmedUser,
        notes: notes.trim().isEmpty ? null : notes.trim(),
      ),
    );
  }

  /// 保存 App 账户密码类（`CipherType.appAccount`）密码条目。
  Future<String> saveAppAccountCipher({
    required String? preferredVaultId,
    required String title,
    required String username,
    required String password,
    required String packageName,
    required String notes,
    String? folderUuid,
  }) {
    final trimmedPackage = packageName.trim();
    return saveCipher(
      type: CipherType.appAccount,
      preferredVaultId: preferredVaultId,
      folderUuid: folderUuid,
      overview: CipherOverviewData(
        title: title.trim(),
        subtitle: username.trim(),
        host: trimmedPackage.isEmpty ? null : trimmedPackage,
      ),
      fullData: AppAccountCipherPayload(
        username: username.trim(),
        password: password,
        packageName: trimmedPackage.isEmpty ? null : trimmedPackage,
        notes: notes.trim().isEmpty ? null : notes.trim(),
      ),
    );
  }

  /// 从用户输入的网站/URL 提取 host，供 overview 展示与搜索。
  static String? parseWebsiteHost(String website) {
    final trimmed = website.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final uri = trimmed.contains('://')
          ? Uri.parse(trimmed)
          : Uri.parse('https://$trimmed');
      if (uri.host.isNotEmpty) {
        return uri.host;
      }
    } on Object {
      // 非标准 URL，回退为原字符串
    }

    return trimmed;
  }

  static String lastFourDigits(String cardNumber) {
    if (cardNumber.length <= 4) {
      return cardNumber;
    }
    return cardNumber.substring(cardNumber.length - 4);
  }

  static String maskDocumentNumber(String number) {
    if (number.length <= 4) {
      return number;
    }
    return '${'*' * (number.length - 4)}${number.substring(number.length - 4)}';
  }

  static String contentSummary(String content) {
    final trimmed = content.trim();
    if (trimmed.length <= 32) {
      return trimmed;
    }
    return '${trimmed.substring(0, 32)}…';
  }

  static String sshSubtitle(String username, String host) {
    if (username.isEmpty) {
      return host;
    }
    if (host.isEmpty) {
      return username;
    }
    return '$username@$host';
  }
}

final cipherAddModelProvider = Provider<CipherAddModel>((ref) {
  return CipherAddModel(
    ref.watch(storageRepositoriesProvider),
    ref.watch(vaultManageModelProvider),
  );
});
