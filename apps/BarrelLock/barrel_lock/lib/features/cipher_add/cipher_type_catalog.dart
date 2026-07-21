import 'package:core/core.dart';

/// 添加页可选 cipher 类型的展示元数据。
final class CipherTypeDescriptor {
  const CipherTypeDescriptor({
    required this.type,
    required this.label,
    required this.iconName,
    required this.isFormEnabled,
    required this.supportsAttachments,
  });

  final int type;
  final String label;

  /// Material [Icons] 名称或自定义 icon 标识（View 层映射为 IconData）。
  final String iconName;

  /// 是否已交付完整添加表单 UI；false 时 selector 可展示但提示「即将推出」。
  final bool isFormEnabled;

  /// 添加页是否展示图片附件区。
  final bool supportsAttachments;

  static CipherTypeDescriptor forType(int type) {
    for (final item in CipherTypeCatalog.all) {
      if (item.type == type) {
        return item;
      }
    }
    return CipherTypeCatalog.all.first;
  }
}

/// 六种 cipher 类型的 SSOT 元数据（与 [CipherType] 对齐）。
abstract final class CipherTypeCatalog {
  static const all = <CipherTypeDescriptor>[
    CipherTypeDescriptor(
      type: CipherType.websiteLogin,
      label: '网站登录',
      iconName: 'language',
      isFormEnabled: true,
      supportsAttachments: false,
    ),
    CipherTypeDescriptor(
      type: CipherType.bankCard,
      label: '银行卡',
      iconName: 'credit_card',
      isFormEnabled: true,
      supportsAttachments: true,
    ),
    CipherTypeDescriptor(
      type: CipherType.identityDocument,
      label: '身份证件',
      iconName: 'badge',
      isFormEnabled: true,
      supportsAttachments: true,
    ),
    CipherTypeDescriptor(
      type: CipherType.secureNote,
      label: '安全笔记',
      iconName: 'sticky_note_2',
      isFormEnabled: true,
      supportsAttachments: false,
    ),
    CipherTypeDescriptor(
      type: CipherType.appAccount,
      label: 'App 账户密码',
      iconName: 'smartphone',
      isFormEnabled: true,
      supportsAttachments: false,
    ),
  ];

  static List<CipherTypeDescriptor> get formEnabled =>
      all.where((d) => d.isFormEnabled).toList();
}
