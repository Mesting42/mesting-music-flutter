import 'package:flutter/material.dart';

import '../../../shared/widgets/music_notice.dart';
import '../data/music_platform_api.dart';

void showPlatformFailure(BuildContext context, Object error) {
  showMusicNotice(
    context,
    icon: Icons.error_outline,
    title: '操作未完成',
    message: error is MusicPlatformException ? error.message : '请检查网络后重试',
  );
}
