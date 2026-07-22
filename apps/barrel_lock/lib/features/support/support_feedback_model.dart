import 'package:core/core.dart';

/// 客服反馈配置（MVVM-C 的 M 层）。
final class SupportFeedbackModel {
  const SupportFeedbackModel();

  static const feedbackEmail = 'lzm.cyr@gmail.com';
  static const feedbackSubject = 'BarrelLock 用户反馈';
  static const maxMessageLength = 2000;
}

final supportFeedbackModelProvider = Provider<SupportFeedbackModel>(
  (_) => const SupportFeedbackModel(),
);
