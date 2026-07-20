import 'package:core/core.dart';

import 'cipher_full_data_payload.dart';

/// SSH 密钥类（`CipherType.sshKey = 5`）的 [CipherEntry.fullDataBlob] 明文结构。
final class SshKeyCipherPayload extends CipherFullDataPayload {
  const SshKeyCipherPayload({
    required this.privateKey,
    this.publicKey,
    this.passphrase,
    this.host,
    this.username,
    this.notes,
  });

  final String privateKey;
  final String? publicKey;
  final String? passphrase;
  final String? host;
  final String? username;
  final String? notes;

  @override
  int get type => CipherType.sshKey;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'privateKey': privateKey,
    if (publicKey != null && publicKey!.isNotEmpty) 'publicKey': publicKey,
    if (passphrase != null && passphrase!.isNotEmpty) 'passphrase': passphrase,
    if (host != null && host!.isNotEmpty) 'host': host,
    if (username != null && username!.isNotEmpty) 'username': username,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  factory SshKeyCipherPayload.fromJson(Map<String, dynamic> json) {
    return SshKeyCipherPayload(
      privateKey: json['privateKey'] as String? ?? '',
      publicKey: json['publicKey'] as String?,
      passphrase: json['passphrase'] as String?,
      host: json['host'] as String?,
      username: json['username'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
