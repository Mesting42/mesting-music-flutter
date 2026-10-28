import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/track.dart';
import '../music_platform/music_platform_providers.dart';
import '../music_platform/presentation/platform_design.dart';
import '../music_platform/presentation/platform_feedback.dart';
import '../experience/presentation/editorial_widgets.dart';
import 'audio_downloads.dart';

Future<void> enqueueAudioDownload(
  BuildContext context,
  WidgetRef ref,
  Track track,
) async {
  try {
    ref.read(audioDownloadManagerProvider).enqueue(track);
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('已加入下载队列，可在下载管理中查看')));
  } catch (e) {
    if (context.mounted) showPlatformFailure(context, e);
  }
}

void openAudioDownloads(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => const AudioDownloadsPage()));

/// The page observes the long-lived manager. Leaving it never abandons a job;
/// changing accounts cancels pending jobs through the manager provider.
class AudioDownloadsPage extends ConsumerWidget {
  const AudioDownloadsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(audioDownloadManagerProvider);
    final owner = ref.watch(platformAccountProvider).value?.ownerId;
    return PlatformPageFrame(
      title: '下载管理',
      child: ListenableBuilder(
        listenable: manager,
        builder: (context, _) {
          final tasks = manager.tasks
              .where((t) => t.owner == owner)
              .toList()
              .reversed
              .toList();
          if (tasks.isEmpty) {
            return const EditorialEmpty('还没有下载任务。长按歌曲或从播放器更多菜单下载音乐。');
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 190),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final active = task.phase == AudioDownloadPhase.downloading;
              final label = switch (task.phase) {
                AudioDownloadPhase.queued => '等待下载',
                AudioDownloadPhase.downloading => '正在下载',
                AudioDownloadPhase.saving => '正在保存到手机',
                AudioDownloadPhase.completed => '已保存到本地音乐',
                AudioDownloadPhase.failed => task.error,
                AudioDownloadPhase.cancelled => '已取消',
              };
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(task.track.title),
                      subtitle: Text('${task.track.artist}\n$label'),
                      isThreeLine: true,
                      trailing:
                          task.phase == AudioDownloadPhase.queued || active
                          ? IconButton(
                              tooltip: '取消下载',
                              icon: const Icon(CupertinoIcons.xmark_circle),
                              onPressed: () => manager.cancel(task.id),
                            )
                          : task.phase == AudioDownloadPhase.failed ||
                                task.phase == AudioDownloadPhase.cancelled
                          ? IconButton(
                              tooltip: '重新下载',
                              icon: const Icon(CupertinoIcons.arrow_clockwise),
                              onPressed: () => manager.retry(task.id),
                            )
                          : const Icon(CupertinoIcons.check_mark_circled),
                    ),
                    if (active) ...[
                      LinearProgressIndicator(
                        value: task.total > 0
                            ? task.received / task.total
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(task.received / 1048576).toStringAsFixed(1)} MB${task.total > 0 ? ' / ${(task.total / 1048576).toStringAsFixed(1)} MB' : ''}',
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
