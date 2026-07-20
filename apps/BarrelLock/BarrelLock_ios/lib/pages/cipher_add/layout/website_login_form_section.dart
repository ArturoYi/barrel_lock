import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../settings/widgets/settings_section_card.dart';

/// 网站登录（type=1）表单字段区。
final class WebsiteLoginFormSection extends StatefulWidget {
  const WebsiteLoginFormSection({
    super.key,
    required this.state,
    required this.onTitleChanged,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
    required this.onWebsiteChanged,
    required this.onNotesChanged,
    required this.onSave,
  });

  final WebsiteLoginFormState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onWebsiteChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSave;

  @override
  State<WebsiteLoginFormSection> createState() =>
      _WebsiteLoginFormSectionState();
}

final class _WebsiteLoginFormSectionState
    extends State<WebsiteLoginFormSection> {
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _websiteController;
  late final TextEditingController _notesController;
  var _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _titleController = TextEditingController(text: s.title);
    _usernameController = TextEditingController(text: s.username);
    _passwordController = TextEditingController(text: s.password);
    _websiteController = TextEditingController(text: s.website);
    _notesController = TextEditingController(text: s.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colors;
    final isSaving = widget.state.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '保存第三方网站或服务的登录凭据，与 App 解锁密码无关。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SettingsSectionCard(
          children: [
            _CipherAddField(
              label: '名称',
              controller: _titleController,
              enabled: !isSaving,
              textInputAction: TextInputAction.next,
              onChanged: widget.onTitleChanged,
            ),
            _CipherAddField(
              label: '用户名',
              controller: _usernameController,
              enabled: !isSaving,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              keyboardType: TextInputType.emailAddress,
              onChanged: widget.onUsernameChanged,
            ),
            _CipherAddPasswordField(
              controller: _passwordController,
              enabled: !isSaving,
              obscure: _obscurePassword,
              onChanged: widget.onPasswordChanged,
              onToggleObscure: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            _CipherAddField(
              label: '网站',
              controller: _websiteController,
              enabled: !isSaving,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.url],
              keyboardType: TextInputType.url,
              onChanged: widget.onWebsiteChanged,
            ),
            _CipherAddField(
              label: '备注',
              controller: _notesController,
              enabled: !isSaving,
              textInputAction: TextInputAction.done,
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

final class _CipherAddField extends StatelessWidget {
  const _CipherAddField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
    this.textInputAction,
    this.keyboardType,
    this.autofillHints,
    this.maxLines = 1,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

final class _CipherAddPasswordField extends StatelessWidget {
  const _CipherAddPasswordField({
    required this.controller,
    required this.onChanged,
    required this.onToggleObscure,
    required this.obscure,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleObscure;
  final bool obscure;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscure,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.password],
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: '密码',
          border: InputBorder.none,
          isDense: true,
          suffixIcon: IconButton(
            tooltip: obscure ? '显示密码' : '隐藏密码',
            onPressed: enabled ? onToggleObscure : null,
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
    );
  }
}
