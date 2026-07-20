import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../settings/widgets/settings_section_card.dart';
import '../widgets/cipher_add_form_fields.dart';

/// SSH 密钥（type=5）表单字段区。
final class SshKeyFormSection extends StatefulWidget {
  const SshKeyFormSection({
    super.key,
    required this.state,
    required this.onTitleChanged,
    required this.onPrivateKeyChanged,
    required this.onPublicKeyChanged,
    required this.onPassphraseChanged,
    required this.onHostChanged,
    required this.onUsernameChanged,
    required this.onNotesChanged,
    required this.onSave,
  });

  final SshKeyFormState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onPrivateKeyChanged;
  final ValueChanged<String> onPublicKeyChanged;
  final ValueChanged<String> onPassphraseChanged;
  final ValueChanged<String> onHostChanged;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSave;

  @override
  State<SshKeyFormSection> createState() => _SshKeyFormSectionState();
}

final class _SshKeyFormSectionState extends State<SshKeyFormSection> {
  late final TextEditingController _titleController;
  late final TextEditingController _privateKeyController;
  late final TextEditingController _publicKeyController;
  late final TextEditingController _passphraseController;
  late final TextEditingController _hostController;
  late final TextEditingController _usernameController;
  late final TextEditingController _notesController;
  var _obscurePrivateKey = true;
  var _obscurePassphrase = true;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _titleController = TextEditingController(text: s.title);
    _privateKeyController = TextEditingController(text: s.privateKey);
    _publicKeyController = TextEditingController(text: s.publicKey);
    _passphraseController = TextEditingController(text: s.passphrase);
    _hostController = TextEditingController(text: s.host);
    _usernameController = TextEditingController(text: s.username);
    _notesController = TextEditingController(text: s.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _privateKeyController.dispose();
    _publicKeyController.dispose();
    _passphraseController.dispose();
    _hostController.dispose();
    _usernameController.dispose();
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
          '保存 SSH 私钥与连接信息；列表展示主机与用户摘要。',
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
            CipherAddObscureField(
              label: '私钥',
              controller: _privateKeyController,
              enabled: !isSaving,
              obscure: _obscurePrivateKey,
              maxLines: 6,
              onChanged: widget.onPrivateKeyChanged,
              onToggleObscure: () =>
                  setState(() => _obscurePrivateKey = !_obscurePrivateKey),
            ),
            CipherAddField(
              label: '公钥（可选）',
              controller: _publicKeyController,
              enabled: !isSaving,
              maxLines: 4,
              onChanged: widget.onPublicKeyChanged,
            ),
            CipherAddObscureField(
              label: '口令（可选）',
              controller: _passphraseController,
              enabled: !isSaving,
              obscure: _obscurePassphrase,
              onChanged: widget.onPassphraseChanged,
              onToggleObscure: () =>
                  setState(() => _obscurePassphrase = !_obscurePassphrase),
            ),
            CipherAddField(
              label: '主机',
              controller: _hostController,
              enabled: !isSaving,
              keyboardType: TextInputType.url,
              onChanged: widget.onHostChanged,
            ),
            CipherAddField(
              label: '用户名',
              controller: _usernameController,
              enabled: !isSaving,
              onChanged: widget.onUsernameChanged,
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
