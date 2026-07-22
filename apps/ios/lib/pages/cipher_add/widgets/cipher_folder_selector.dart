import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 添加页文件夹选择器。
class CipherFolderSelector extends StatelessWidget {
  const CipherFolderSelector({
    super.key,
    required this.folderState,
    required this.onFolderSelected,
    required this.onCreateFolder,
  });

  final CipherAddFolderState folderState;
  final ValueChanged<String?> onFolderSelected;
  final Future<void> Function() onCreateFolder;

  @override
  Widget build(BuildContext context) {
    if (!folderState.canSelectFolder) {
      return const SizedBox.shrink();
    }

    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('未分组')),
      for (final folder in folderState.folders)
        DropdownMenuItem<String?>(value: folder.id, child: Text(folder.name)),
      const DropdownMenuItem<String?>(
        value: CipherAddFolderState.createNewSentinel,
        child: Text('新建文件夹…'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '文件夹',
          border: OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            isExpanded: true,
            value: folderState.selectedFolderId,
            hint: Text(
              folderState.isLoading ? '加载文件夹…' : '未分组',
              style: context.textTheme.bodyLarge,
            ),
            items: items,
            onChanged: folderState.isLoading
                ? null
                : (value) async {
                    if (value == CipherAddFolderState.createNewSentinel) {
                      await onCreateFolder();
                      return;
                    }
                    onFolderSelected(value);
                  },
          ),
        ),
      ),
    );
  }
}
