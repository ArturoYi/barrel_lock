import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../settings/widgets/settings_section_card.dart';
import '../widgets/cipher_add_form_fields.dart';

/// 安全笔记（type=4）表单字段区。
final class SecureNoteFormSection extends StatefulWidget {
  const SecureNoteFormSection({
    super.key,
    required this.state,
    required this.onTitleChanged,
    required this.onContentChanged,
    required this.onNotesChanged,
    required this.onSave,
  });

  final SecureNoteFormState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onContentChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSave;

  @override
  State<SecureNoteFormSection> createState() => _SecureNoteFormSectionState();
}

final class _SecureNoteFormSectionState extends State<SecureNoteFormSection> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _titleController = TextEditingController(text: s.title);
    _contentController = TextEditingController(text: s.content);
    _notesController = TextEditingController(text: s.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.state.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '保存加密笔记内容；列表展示标题摘要。',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SettingsSectionCard(
          children: [
            CipherAddField(
              label: '标题',
              controller: _titleController,
              enabled: !isSaving,
              onChanged: widget.onTitleChanged,
            ),
            CipherAddField(
              label: '内容',
              controller: _contentController,
              enabled: !isSaving,
              maxLines: 8,
              onChanged: widget.onContentChanged,
            ),
            CipherAddField(
              label: '备注',
              controller: _notesController,
              enabled: !isSaving,
              maxLines: 3,
              onChanged: widget.onNotesChanged,
              onSubmitted: isSaving ? null : (_) => widget.onSave(),
            ),
          ],
        ),
      ],
    );
  }
}
