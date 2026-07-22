/// 服务支持文档页路由（query `doc=<itemId>`）。
final class SupportDocumentRoute {
  const SupportDocumentRoute();

  String get name => 'supportDocument';

  String get path => '/settings/support/document';

  String call({required String docId}) => '$path?doc=$docId';

  String docIdFromQuery(Map<String, String> query) => query['doc'] ?? '';
}
