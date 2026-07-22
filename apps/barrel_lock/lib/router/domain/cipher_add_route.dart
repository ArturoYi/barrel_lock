import 'package:core/core.dart';

/// 添加密码页路由描述符（可选 query `vaultId`、`type`）。
final class CipherAddRoute {
  const CipherAddRoute();

  String get name => 'cipherAdd';
  String get path => '/cipher/add';

  /// [type] 对应 [CipherType] 整型值，默认网站登录。
  String call({String? vaultId, int type = CipherType.websiteLogin}) {
    final params = <String, String>{};
    if (vaultId != null && vaultId.isNotEmpty) {
      params['vaultId'] = vaultId;
    }
    if (type != CipherType.websiteLogin) {
      params['type'] = type.toString();
    }
    if (params.isEmpty) {
      return path;
    }
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$path?$query';
  }
}
