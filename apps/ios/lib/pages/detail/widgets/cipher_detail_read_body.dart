import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'cipher_detail_field_row.dart';

/// 详情页元数据区：类型、文件夹。
class CipherDetailMetadataSection extends StatelessWidget {
  const CipherDetailMetadataSection({
    super.key,
    required this.data,
    required this.onChangeFolderTapped,
  });

  final CipherDetailData data;
  final VoidCallback onChangeFolderTapped;

  @override
  Widget build(BuildContext context) {
    final descriptor = CipherTypeDescriptor.forType(data.type);
    final colorScheme = context.colors;
    final folderLabel = data.folderName ?? '未分组';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              cipherTypeIconFor(descriptor.iconName),
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              descriptor.label,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('文件夹'),
          subtitle: Text(folderLabel),
          trailing: TextButton(
            onPressed: onChangeFolderTapped,
            child: const Text('更改'),
          ),
        ),
      ],
    );
  }
}

/// 按 cipher 类型渲染只读字段。
class CipherDetailReadBody extends StatelessWidget {
  const CipherDetailReadBody({
    super.key,
    required this.data,
    required this.revealedFieldKeys,
    required this.onToggleReveal,
    required this.onCopy,
  });

  final CipherDetailData data;
  final Set<String> revealedFieldKeys;
  final ValueChanged<String> onToggleReveal;
  final Future<void> Function(String value) onCopy;

  bool _isRevealed(String key) => revealedFieldKeys.contains(key);

  @override
  Widget build(BuildContext context) {
    final fullData = data.fullData;
    final overview = data.overview;

    return switch (fullData) {
      WebsiteLoginCipherPayload payload => Column(
        children: [
          CipherDetailFieldRow(
            label: '名称',
            value: overview.title,
            fieldKey: 'title',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '用户名',
            value: payload.username,
            fieldKey: 'username',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '密码',
            value: payload.password,
            fieldKey: 'password',
            isRevealed: _isRevealed('password'),
            isSensitive: true,
            onToggleReveal: () => onToggleReveal('password'),
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '网站',
            value: overview.host ?? '',
            fieldKey: 'website',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '备注',
            value: payload.notes ?? '',
            fieldKey: 'notes',
            isRevealed: true,
            multiline: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
        ],
      ),
      BankCardCipherPayload payload => Column(
        children: [
          CipherDetailFieldRow(
            label: '名称',
            value: overview.title,
            fieldKey: 'title',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '持卡人',
            value: payload.cardholderName,
            fieldKey: 'cardholder',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '卡号',
            value: payload.cardNumber,
            fieldKey: 'cardNumber',
            isRevealed: _isRevealed('cardNumber'),
            isSensitive: true,
            onToggleReveal: () => onToggleReveal('cardNumber'),
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '有效期',
            value: '${payload.expiryMonth}/${payload.expiryYear}',
            fieldKey: 'expiry',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: 'CVV',
            value: payload.cvv,
            fieldKey: 'cvv',
            isRevealed: _isRevealed('cvv'),
            isSensitive: true,
            onToggleReveal: () => onToggleReveal('cvv'),
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: 'PIN',
            value: payload.pin ?? '',
            fieldKey: 'pin',
            isRevealed: _isRevealed('pin'),
            isSensitive: true,
            onToggleReveal: () => onToggleReveal('pin'),
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '备注',
            value: payload.notes ?? '',
            fieldKey: 'notes',
            isRevealed: true,
            multiline: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
        ],
      ),
      IdentityDocumentCipherPayload payload => Column(
        children: [
          CipherDetailFieldRow(
            label: '名称',
            value: overview.title,
            fieldKey: 'title',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '证件类型',
            value: payload.documentType,
            fieldKey: 'documentType',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '姓名',
            value: payload.fullName,
            fieldKey: 'fullName',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '证件号码',
            value: payload.documentNumber,
            fieldKey: 'documentNumber',
            isRevealed: _isRevealed('documentNumber'),
            isSensitive: true,
            onToggleReveal: () => onToggleReveal('documentNumber'),
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '签发日期',
            value: payload.issueDate ?? '',
            fieldKey: 'issueDate',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '有效期',
            value: payload.expiryDate ?? '',
            fieldKey: 'expiryDate',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '备注',
            value: payload.notes ?? '',
            fieldKey: 'notes',
            isRevealed: true,
            multiline: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
        ],
      ),
      SecureNoteCipherPayload payload => Column(
        children: [
          CipherDetailFieldRow(
            label: '标题',
            value: overview.title,
            fieldKey: 'title',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '内容',
            value: payload.content,
            fieldKey: 'content',
            isRevealed: true,
            multiline: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '备注',
            value: payload.notes ?? '',
            fieldKey: 'notes',
            isRevealed: true,
            multiline: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
        ],
      ),
      AppAccountCipherPayload payload => Column(
        children: [
          CipherDetailFieldRow(
            label: '名称',
            value: overview.title,
            fieldKey: 'title',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '账号',
            value: payload.username,
            fieldKey: 'username',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '密码',
            value: payload.password,
            fieldKey: 'password',
            isRevealed: _isRevealed('password'),
            isSensitive: true,
            onToggleReveal: () => onToggleReveal('password'),
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '包名',
            value: payload.packageName ?? overview.host ?? '',
            fieldKey: 'packageName',
            isRevealed: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
          CipherDetailFieldRow(
            label: '备注',
            value: payload.notes ?? '',
            fieldKey: 'notes',
            isRevealed: true,
            multiline: true,
            onToggleReveal: () {},
            onCopy: onCopy,
          ),
        ],
      ),
      _ => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          '该类型详情页即将推出',
          style: context.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    };
  }
}
