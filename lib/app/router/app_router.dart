import 'package:go_router/go_router.dart';

import '../../features/library/presentation/music_home_page.dart';
import '../../features/player/presentation/music_shell.dart';
import '../../features/player/presentation/now_playing_page.dart';
import '../../features/playlists/presentation/playlist_detail_page.dart';
import '../../features/playlists/presentation/playlists_page.dart';
import '../../features/queue/presentation/queue_page.dart';

final appRouter = GoRouter(
  initialLocation: '/music',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MusicShell(child: child),
      routes: [
        GoRoute(
          path: '/music',
          builder: (context, state) => const MusicHomePage(),
        ),
        GoRoute(
          path: '/music/queue',
          builder: (context, state) => const QueuePage(),
        ),
        GoRoute(
          path: '/music/playlists',
          builder: (context, state) => const PlaylistsPage(),
        ),
        GoRoute(
          path: '/music/playlists/:playlistId',
          builder: (context, state) => PlaylistDetailPage(
            playlistId: state.pathParameters['playlistId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const NowPlayingPage(),
    ),
  ],
);
