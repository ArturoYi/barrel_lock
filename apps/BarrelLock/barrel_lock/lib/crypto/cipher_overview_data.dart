/// 密码列表 overview 明文字段（加密前 JSON 结构）。
final class CipherOverviewData {
  const CipherOverviewData({
    required this.title,
    required this.subtitle,
    this.host,
    this.hasTotp = false,
  });

  final String title;
  final String subtitle;
  final String? host;
  final bool hasTotp;

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    if (host != null) 'host': host,
    if (hasTotp) 'hasTotp': hasTotp,
  };

  factory CipherOverviewData.fromJson(Map<String, dynamic> json) {
    return CipherOverviewData(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      host: json['host'] as String?,
      hasTotp: json['hasTotp'] as bool? ?? false,
    );
  }

  /// 解密失败时的占位数据。
  static const fallback = CipherOverviewData(title: '无法解密', subtitle: '');
}
