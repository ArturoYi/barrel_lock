import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../settings/widgets/settings_section_card.dart';
import '../widgets/cipher_add_form_fields.dart';

/// App 账户密码（type=6）表单字段区。
final class AppAccountFormSection extends StatefulWidget {
  const AppAccountFormSection({
    super.key,
    required this.state,
    required this.onTitleChanged,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
    required this.onPackageNameChanged,
    required this.onNotesChanged,
    required this.onSave,
  });

  final AppAccountFormState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onPackageNameChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSave;

  @override
  State<AppAccountFormSection> createState() => _AppAccountFormSectionState();
}

final class _AppAccountFormSectionState extends State<AppAccountFormSection> {
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _packageNameController;
  late final TextEditingController _notesController;
  var _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _titleController = TextEditingController(text: s.title);
    _usernameController = TextEditingController(text: s.username);
    _passwordController = TextEditingController(text: s.password);
    _packageNameController = TextEditingController(text: s.packageName);
    _notesController = TextEditingController(text: s.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _packageNameController.dispose();
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
          '保存本地 App 的登录账号与密码，与 App 解锁密码无关。',
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
              textInputAction: TextInputAction.next,
              onChanged: widget.onTitleChanged,
            ),
            CipherAddField(
              label: '账号',
              controller: _usernameController,
              enabled: !isSaving,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              onChanged: widget.onUsernameChanged,
            ),
            CipherAddObscureField(
              label: '密码',
              controller: _passwordController,
              enabled: !isSaving,
              obscure: _obscurePassword,
              textInputAction: TextInputAction.next,
              onChanged: widget.onPasswordChanged,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            CipherAddField(
              label: '包名 / Bundle ID（可选）',
              controller: _packageNameController,
              enabled: !isSaving,
              textInputAction: TextInputAction.next,
              onChanged: widget.onPackageNameChanged,
            ),
            CipherAddField(
              label: '备注',
              controller: _notesController,
              enabled: !isSaving,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              onChanged: widget.onNotesChanged,
              onSubmitted: isSaving ? null : (_) => widget.onSave(),
            ),
          ],
        ),
      ],
    );
  }
}
