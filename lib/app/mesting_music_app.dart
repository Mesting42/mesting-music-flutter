import 'package:flutter/material.dart';

import '../features/themes/app_theme.dart';
import 'router/app_router.dart';

class MestingMusicApp extends StatelessWidget {
  const MestingMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mesting 音乐',
      debugShowCheckedModeBanner: false,
      theme: buildMestingTheme(),
      routerConfig: appRouter,
    );
  }
}
