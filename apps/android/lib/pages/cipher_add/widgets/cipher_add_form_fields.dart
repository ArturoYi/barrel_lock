import 'package:flutter/material.dart';

/// 添加页通用单行输入框。
final class CipherAddField extends StatelessWidget {
  const CipherAddField({
    super.key,
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

/// 添加页通用敏感字段（可切换可见性）。
final class CipherAddObscureField extends StatelessWidget {
  const CipherAddObscureField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.obscure,
    required this.onToggleObscure,
    this.enabled = true,
    this.textInputAction,
    this.keyboardType,
    this.autofillHints,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool enabled;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscure,
        maxLines: maxLines,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          isDense: true,
          suffixIcon: IconButton(
            tooltip: obscure ? '显示' : '隐藏',
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
