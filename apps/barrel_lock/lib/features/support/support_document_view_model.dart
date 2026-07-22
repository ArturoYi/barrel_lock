import 'package:core/core.dart';

import 'support_document_coordinator.dart';
import 'support_document_model.dart';

/// 服务支持文档页展示状态。
final class SupportDocumentViewState {
  const SupportDocumentViewState({
    required this.title,
    required this.paragraphs,
    this.notFound = false,
  });

  final String title;
  final List<String> paragraphs;
  final bool notFound;
}

/// 服务支持文档页 ViewModel（family：文档 id）。
final class SupportDocumentViewModel extends Notifier<SupportDocumentViewState> {
  SupportDocumentViewModel(this._docId);

  final String _docId;

  late final SupportDocumentModel _model;
  late final SupportDocumentCoordinator _coordinator;

  @override
  SupportDocumentViewState build() {
    _model = ref.read(supportDocumentModelProvider);
    _coordinator = ref.read(supportDocumentCoordinatorProvider);

    final document = _model.documentFor(_docId);
    if (document == null) {
      return const SupportDocumentViewState(
        title: '内容不存在',
        paragraphs: ['该文档暂未提供，请返回后重试。'],
        notFound: true,
      );
    }

    return SupportDocumentViewState(
      title: document.title,
      paragraphs: document.paragraphs,
    );
  }

  void onPop() => _coordinator.pop();
}

final supportDocumentViewModelProvider = NotifierProvider.autoDispose
    .family<SupportDocumentViewModel, SupportDocumentViewState, String>(
      SupportDocumentViewModel.new,
    );
