/// 服务支持外链（占位 URL，上线前替换为正式地址）。
abstract final class SupportUrls {
  static const helpDoc = 'https://barrellock.app/help/security';
  static const feedback = 'mailto:support@barrellock.app';
  static const userAgreement = 'https://barrellock.app/legal/terms';
  static const privacyPolicy = 'https://barrellock.app/legal/privacy';
  static const encryptionDoc = 'https://barrellock.app/help/encryption';

  static String? urlForItem(String itemId) {
    return switch (itemId) {
      'help_doc' => helpDoc,
      'feedback' => feedback,
      'user_agreement' => userAgreement,
      'privacy_policy' => privacyPolicy,
      'encryption_doc' => encryptionDoc,
      _ => null,
    };
  }
}
