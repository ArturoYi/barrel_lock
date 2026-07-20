import 'package:core/core.dart';

import 'cipher_full_data_payload.dart';

/// App 账户类（`CipherType.appAccount = 6`）的 [CipherEntry.fullDataBlob] 明文结构。
///
/// 描述本地已安装 App 的登录账号与密码（如微信、游戏账号），
/// 与 App 解锁（[AppIdentityAuth]）及网站登录（[WebsiteLoginCipherPayload]）无关。
final class AppAccountCipherPayload extends CipherFullDataPayload {
  const AppAccountCipherPayload({
    required this.username,
    required this.password,
    this.packageName,
    this.notes,
  });

  final String username;
  final String password;

  /// iOS Bundle ID / Android 包名（可选）。
  final String? packageName;
  final String? notes;

  @override
  int get type => CipherType.appAccount;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'username': username,
    'password': password,
    if (packageName != null && packageName!.isNotEmpty)
      'packageName': packageName,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  factory AppAccountCipherPayload.fromJson(Map<String, dynamic> json) {
    return AppAccountCipherPayload(
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      packageName: json['packageName'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
