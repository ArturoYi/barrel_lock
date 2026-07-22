import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'support_feedback_coordinator.dart';
import 'support_feedback_model.dart';

/// 客服反馈页展示状态。
final class SupportFeedbackViewState {
  const SupportFeedbackViewState({
    this.contact = '',
    this.message = '',
    this.isSubmitting = false,
  });

  final String contact;
  final String message;
  final bool isSubmitting;

  bool get canSubmit =>
      !isSubmitting &&
      message.trim().isNotEmpty &&
      message.length <= SupportFeedbackModel.maxMessageLength;

  SupportFeedbackViewState copyWith({
    String? contact,
    String? message,
    bool? isSubmitting,
  }) {
    return SupportFeedbackViewState(
      contact: contact ?? this.contact,
      message: message ?? this.message,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// 客服反馈页 ViewModel。
final class SupportFeedbackViewModel extends Notifier<SupportFeedbackViewState> {
  late final SupportFeedbackCoordinator _coordinator;

  @override
  SupportFeedbackViewState build() {
    _coordinator = ref.read(supportFeedbackCoordinatorProvider);
    return const SupportFeedbackViewState();
  }

  void onPop() => _coordinator.pop();

  void onContactChanged(String value) {
    state = state.copyWith(contact: value);
  }

  void onMessageChanged(String value) {
    state = state.copyWith(message: value);
  }

  Future<void> onSubmit() async {
    if (!state.canSubmit) {
      return;
    }

    state = state.copyWith(isSubmitting: true);
    final body = _buildFeedbackBody();
    final launched = await _launchMailComposer(body);
    state = state.copyWith(isSubmitting: false);

    if (launched) {
      FastToast.show('已打开邮件应用，请确认收件人后发送');
      return;
    }

    await Clipboard.setData(
      ClipboardData(
        text: '收件人：${SupportFeedbackModel.feedbackEmail}\n\n$body',
      ),
    );
    FastToast.show('无法打开邮件应用，已复制反馈内容');
  }

  String _buildFeedbackBody() {
    final contact = state.contact.trim();
    final message = state.message.trim();
    final version = AppDeviceInfo.versionLabel;
    final platform = AppDeviceInfo.platform.name;

    return [
      message,
      '',
      '---',
      '联系邮箱：${contact.isEmpty ? '未填写' : contact}',
      '应用版本：$version',
      '平台：$platform',
    ].join('\n');
  }

  Future<bool> _launchMailComposer(String body) async {
    final uri = Uri(
      scheme: 'mailto',
      path: SupportFeedbackModel.feedbackEmail,
      queryParameters: {
        'subject': SupportFeedbackModel.feedbackSubject,
        'body': body,
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri);
      }
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

final supportFeedbackViewModelProvider =
    NotifierProvider<SupportFeedbackViewModel, SupportFeedbackViewState>(
      SupportFeedbackViewModel.new,
    );
