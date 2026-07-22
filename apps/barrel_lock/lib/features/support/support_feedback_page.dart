import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 客服反馈页（MVVM-C 的 V 层）。
class SupportFeedbackPage extends ConsumerStatefulWidget {
  const SupportFeedbackPage({super.key});

  @override
  ConsumerState<SupportFeedbackPage> createState() =>
      _SupportFeedbackPageState();
}

class _SupportFeedbackPageState extends ConsumerState<SupportFeedbackPage> {
  late final TextEditingController _contactController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _contactController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _contactController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportFeedbackViewModelProvider);
    final viewModel = ref.read(supportFeedbackViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: const Text('客服反馈'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '请描述你遇到的问题或建议。点击「发送邮件反馈」将打开系统邮件应用，'
              '收件人已预设为 ${SupportFeedbackModel.feedbackEmail}，请确认内容后点击发送。',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contactController,
              enabled: !state.isSubmitting,
              decoration: const InputDecoration(
                labelText: '联系邮箱（选填）',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: viewModel.onContactChanged,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              enabled: !state.isSubmitting,
              decoration: InputDecoration(
                labelText: '反馈内容',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                counterText:
                    '${state.message.length}/${SupportFeedbackModel.maxMessageLength}',
              ),
              minLines: 6,
              maxLines: 10,
              maxLength: SupportFeedbackModel.maxMessageLength,
              textInputAction: TextInputAction.newline,
              onChanged: viewModel.onMessageChanged,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: state.canSubmit ? viewModel.onSubmit : null,
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('发送邮件反馈'),
            ),
          ],
        ),
      ),
    );
  }
}
