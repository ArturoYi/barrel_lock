import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 添加页附件区（首版：身份证件）。
class CipherAttachmentSection extends StatelessWidget {
  const CipherAttachmentSection({
    super.key,
    required this.attachmentState,
    required this.enabled,
    required this.onAddTapped,
    required this.onRemovePending,
    required this.onPreviewPending,
  });

  final CipherAddAttachmentState attachmentState;
  final bool enabled;
  final VoidCallback onAddTapped;
  final ValueChanged<String> onRemovePending;
  final ValueChanged<PendingAttachment> onPreviewPending;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final pending = attachmentState.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '附件（可选）',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '可添加身份证正反面等照片',
          style: context.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pending.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == pending.length) {
                return _AddAttachmentTile(
                  enabled: enabled && attachmentState.canAddMore,
                  onTap: onAddTapped,
                );
              }

              final item = pending[index];
              return _PendingAttachmentTile(
                item: item,
                enabled: enabled,
                onTap: () => onPreviewPending(item),
                onRemove: () => onRemovePending(item.localId),
              );
            },
          ),
        ),
      ],
    );
  }
}

final class _AddAttachmentTile extends StatelessWidget {
  const _AddAttachmentTile({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 96,
          height: 96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: enabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 4),
              Text(
                '添加',
                style: context.textTheme.labelMedium?.copyWith(
                  color: enabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PendingAttachmentTile extends StatelessWidget {
  const _PendingAttachmentTile({
    required this.item,
    required this.enabled,
    required this.onTap,
    required this.onRemove,
  });

  final PendingAttachment item;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            child: Image.memory(
              item.bytes,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: context.colors.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            onPressed: enabled ? onRemove : null,
            icon: const Icon(Icons.close, size: 16),
          ),
        ),
      ],
    );
  }
}

/// 选择附件来源。
Future<ImageAttachmentSource?> showAttachmentSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageAttachmentSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('拍照'),
            onTap: () =>
                Navigator.of(context).pop(ImageAttachmentSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('从相册选择'),
            onTap: () =>
                Navigator.of(context).pop(ImageAttachmentSource.gallery),
          ),
        ],
      ),
    ),
  );
}

enum ImageAttachmentSource { camera, gallery }

void showPendingAttachmentPreview(
  BuildContext context,
  PendingAttachment attachment,
) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: InteractiveViewer(
        child: Image.memory(attachment.bytes, fit: BoxFit.contain),
      ),
    ),
  );
}
