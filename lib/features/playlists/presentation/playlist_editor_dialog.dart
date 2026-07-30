import 'package:flutter/material.dart';

import '../../library/data/demo_library.dart';

class PlaylistDraft {
  const PlaylistDraft({
    required this.name,
    required this.description,
    required this.coverAsset,
  });

  final String name;
  final String description;
  final String? coverAsset;
}

Future<PlaylistDraft?> showPlaylistEditorDialog(
  BuildContext context, {
  String? initialName,
  String initialDescription = '',
  String? initialCoverAsset,
}) async {
  final nameController = TextEditingController(text: initialName);
  final descriptionController = TextEditingController(text: initialDescription);
  var selectedCover = initialCoverAsset;

  final result = await showDialog<PlaylistDraft>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(initialName == null ? '新建歌单' : '编辑歌单'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                maxLength: 30,
                decoration: const InputDecoration(
                  labelText: '歌单名称',
                  hintText: '例如：夜晚散步',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLength: 100,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '歌单描述',
                  hintText: '可选',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: selectedCover,
                decoration: const InputDecoration(labelText: '歌单封面'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('自动使用第一首歌封面'),
                  ),
                  for (final track in demoTracks)
                    DropdownMenuItem<String?>(
                      value: track.coverAsset,
                      child: Text(track.title),
                    ),
                ],
                onChanged: (value) => setState(() => selectedCover = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(
                dialogContext,
                PlaylistDraft(
                  name: name,
                  description: descriptionController.text.trim(),
                  coverAsset: selectedCover,
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    ),
  );

  nameController.dispose();
  descriptionController.dispose();
  return result;
}
