import 'package:core/core.dart';

import 'cipher_full_data_payload.dart';

/// 网站登录类（`CipherType.websiteLogin = 1`）的 [CipherEntry.fullDataBlob] 明文结构。
///
/// 描述第三方网站/服务的登录凭据（如 GitHub 用户名与密码），
/// 与 App 解锁（[AppIdentityAuth]）及账号系统无关。
final class WebsiteLoginCipherPayload extends CipherFullDataPayload {
  const WebsiteLoginCipherPayload({
    required this.username,
    required this.password,
    this.notes,
    this.totpSecret,
  });

  final String username;
  final String password;
  final String? notes;

  /// TOTP 种子（离线 2FA，可选）。
  final String? totpSecret;

  @override
  int get type => CipherType.websiteLogin;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'username': username,
    'password': password,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (totpSecret != null && totpSecret!.isNotEmpty) 'totpSecret': totpSecret,
  };

  factory WebsiteLoginCipherPayload.fromJson(Map<String, dynamic> json) {
    return WebsiteLoginCipherPayload(
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      notes: json['notes'] as String?,
      totpSecret: json['totpSecret'] as String?,
    );
  }
}
