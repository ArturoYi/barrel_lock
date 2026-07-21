import 'dart:async';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'cipher_attachment_section.dart';

String resolveImageMimeType(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.png')) {
    return 'image/png';
  }
  if (lower.endsWith('.webp')) {
    return 'image/webp';
  }
  return 'image/jpeg';
}

String attachmentFileNameFromPath(String path) {
  final segments = path.split(RegExp(r'[/\\]'));
  final name = segments.isEmpty ? path : segments.last;
  if (name.isEmpty) {
    return 'image.jpg';
  }
  return name;
}

Future<({String fileName, String mimeType, Uint8List bytes})?>
pickCipherAttachment({required ImageAttachmentSource source}) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: switch (source) {
      ImageAttachmentSource.camera => ImageSource.camera,
      ImageAttachmentSource.gallery => ImageSource.gallery,
    },
    maxWidth: 2048,
    maxHeight: 2048,
    imageQuality: 85,
  );
  if (picked == null) {
    return null;
  }

  final bytes = await picked.readAsBytes();
  final fileName = picked.name.isNotEmpty
      ? picked.name
      : attachmentFileNameFromPath(picked.path);
  final mimeType = resolveImageMimeType(fileName);

  return (fileName: fileName, mimeType: mimeType, bytes: bytes);
}
