import 'package:flutter/material.dart';

/// 弹出新建保险库 BottomSheet，确认后返回 trimmed 名称；取消返回 null。
Future<String?> showCreateVaultSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _NameInputSheet(
      title: '新建保险库',
      labelText: '保险库名称',
      hintText: '例如：工作、家庭',
    ),
  ).then(_normalizeSheetResult);
}

/// 弹出新建文件夹 BottomSheet。
Future<String?> showCreateFolderSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _NameInputSheet(
      title: '新建文件夹',
      labelText: '文件夹名称',
      hintText: '例如：社交、银行卡',
    ),
  ).then(_normalizeSheetResult);
}

String? _normalizeSheetResult(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return value.trim();
}

final class _NameInputSheet extends StatefulWidget {
  const _NameInputSheet({
    required this.title,
    required this.labelText,
    required this.hintText,
  });

  final String title;
  final String labelText;
  final String hintText;

  @override
  State<_NameInputSheet> createState() => _NameInputSheetState();
}

final class _NameInputSheetState extends State<_NameInputSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入名称';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _submit, child: const Text('创建')),
          ],
        ),
      ),
    );
  }
}
