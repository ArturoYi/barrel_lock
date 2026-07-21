import 'dart:async';
import 'dart:typed_data';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 详情页已持久化附件区。
class CipherDetailAttachmentSection extends StatelessWidget {
  const CipherDetailAttachmentSection({
    super.key,
    required this.attachments,
    required this.enabled,
    required this.onAddTapped,
    required this.onDelete,
    required this.onPreview,
  });

  final List<AttachmentMetadata> attachments;
  final bool enabled;
  final VoidCallback onAddTapped;
  final ValueChanged<String> onDelete;
  final ValueChanged<AttachmentMetadata> onPreview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final canAddMore = attachments.length < AttachmentLimits.maxCountPerCipher;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '附件',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == attachments.length) {
                return _AddTile(
                  enabled: enabled && canAddMore,
                  onTap: onAddTapped,
                );
              }
              final item = attachments[index];
              return _AttachmentTile(
                item: item,
                enabled: enabled,
                onTap: () => onPreview(item),
                onDelete: () => onDelete(item.id),
              );
            },
          ),
        ),
        if (!canAddMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '已达 ${AttachmentLimits.maxCountPerCipher} 个附件上限',
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

final class _AddTile extends StatelessWidget {
  const _AddTile({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 96,
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add_photo_alternate_outlined),
        ),
      ),
    );
  }
}

final class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.item,
    required this.enabled,
    required this.onTap,
    required this.onDelete,
  });

  final AttachmentMetadata item;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 96,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_outlined),
                const SizedBox(height: 4),
                Text(
                  item.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            onPressed: enabled ? onDelete : null,
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

Future<void> showStoredAttachmentPreview({
  required BuildContext context,
  required AttachmentManageModel model,
  required AttachmentMetadata metadata,
}) async {
  Uint8List bytes;
  try {
    bytes = await model.loadDecryptedBytes(metadata.id);
  } on AttachmentManageException catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.message)));
    return;
  }

  if (!context.mounted) {
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.contain)),
    ),
  );
}

Future<bool> confirmDeleteAttachment(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('删除附件'),
      content: const Text('确定删除该附件吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('删除'),
        ),
      ],
    ),
  );
  return result ?? false;
}
