import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../settings/widgets/settings_section_card.dart';
import '../widgets/cipher_add_form_fields.dart';

/// 身份证件（type=3）表单字段区。
final class IdentityDocumentFormSection extends StatefulWidget {
  const IdentityDocumentFormSection({
    super.key,
    required this.state,
    required this.onTitleChanged,
    required this.onDocumentTypeChanged,
    required this.onFullNameChanged,
    required this.onDocumentNumberChanged,
    required this.onIssueDateChanged,
    required this.onExpiryDateChanged,
    required this.onNotesChanged,
    required this.onSave,
  });

  final IdentityDocumentFormState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDocumentTypeChanged;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onDocumentNumberChanged;
  final ValueChanged<String> onIssueDateChanged;
  final ValueChanged<String> onExpiryDateChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSave;

  @override
  State<IdentityDocumentFormSection> createState() =>
      _IdentityDocumentFormSectionState();
}

final class _IdentityDocumentFormSectionState
    extends State<IdentityDocumentFormSection> {
  late final TextEditingController _titleController;
  late final TextEditingController _documentTypeController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _documentNumberController;
  late final TextEditingController _issueDateController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _notesController;
  var _obscureDocumentNumber = true;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _titleController = TextEditingController(text: s.title);
    _documentTypeController = TextEditingController(text: s.documentType);
    _fullNameController = TextEditingController(text: s.fullName);
    _documentNumberController = TextEditingController(text: s.documentNumber);
    _issueDateController = TextEditingController(text: s.issueDate);
    _expiryDateController = TextEditingController(text: s.expiryDate);
    _notesController = TextEditingController(text: s.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _documentTypeController.dispose();
    _fullNameController.dispose();
    _documentNumberController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
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
          '保存身份证、护照等证件信息；列表仅展示证件类型与姓名摘要。',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SettingsSectionCard(
          children: [
            CipherAddField(
              label: '名称',
              controller: _titleController,
              enabled: !isSaving,
              onChanged: widget.onTitleChanged,
            ),
            CipherAddField(
              label: '证件类型',
              controller: _documentTypeController,
              enabled: !isSaving,
              onChanged: widget.onDocumentTypeChanged,
            ),
            CipherAddField(
              label: '姓名',
              controller: _fullNameController,
              enabled: !isSaving,
              onChanged: widget.onFullNameChanged,
            ),
            CipherAddObscureField(
              label: '证件号码',
              controller: _documentNumberController,
              enabled: !isSaving,
              obscure: _obscureDocumentNumber,
              onChanged: widget.onDocumentNumberChanged,
              onToggleObscure: () => setState(
                () => _obscureDocumentNumber = !_obscureDocumentNumber,
              ),
            ),
            CipherAddField(
              label: '签发日期',
              controller: _issueDateController,
              enabled: !isSaving,
              onChanged: widget.onIssueDateChanged,
            ),
            CipherAddField(
              label: '有效期',
              controller: _expiryDateController,
              enabled: !isSaving,
              onChanged: widget.onExpiryDateChanged,
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
