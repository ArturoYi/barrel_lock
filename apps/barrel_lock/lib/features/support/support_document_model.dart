import 'package:core/core.dart';

import 'support_document_content.dart';

/// 服务支持文档数据（MVVM-C 的 M 层）。
final class SupportDocumentModel {
  const SupportDocumentModel();

  SupportDocumentContent? documentFor(String docId) {
    return SupportDocumentContent.forItemId(docId);
  }
}

final supportDocumentModelProvider = Provider<SupportDocumentModel>(
  (_) => const SupportDocumentModel(),
);
