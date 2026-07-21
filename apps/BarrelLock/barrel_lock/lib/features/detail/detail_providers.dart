import 'package:core/core.dart';

import '../attachment_manage/attachment_manage_model.dart';

/// 详情页附件元数据流。
final detailAttachmentsStreamProvider = StreamProvider.autoDispose
    .family<List<AttachmentMetadata>, String>((ref, cipherUuid) {
      return ref
          .watch(attachmentManageModelProvider)
          .watchMetadataByCipher(cipherUuid);
    });
