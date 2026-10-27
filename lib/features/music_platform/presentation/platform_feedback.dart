import 'package:flutter/material.dart';

import '../../../shared/widgets/music_notice.dart';
import '../../../core/audio/mesting_audio_handler.dart';
import '../data/music_platform_api.dart';

void showPlatformFailure(BuildContext context, Object error) {
  showMusicNotice(
    context,
    icon: Icons.error_outline_rounded,
    title: '操作未完成',
    message: error is MusicPlatformException
        ? error.message
        : error is PlaybackContinuationException
        ? error.message
        : '请检查网络后重试',
  );
}
