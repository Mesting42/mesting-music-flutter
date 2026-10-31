import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mesting_music/features/music_platform/netease/netease_api.dart';
import 'package:mesting_music/features/music_platform/netease/netease_session.dart';
import 'package:mesting_music/features/music_platform/netease/netease_music_repository.dart';
import 'package:mesting_music/features/music_platform/netease/messages/netease_messages_repository.dart';
import 'package:mesting_music/features/music_platform/netease/together/netease_together_controller.dart';
import 'package:mesting_music/features/music_platform/netease/together/netease_together_player_header.dart';
import 'package:mesting_music/features/music_platform/netease/together/together_presence.dart';
import 'netease_v114_workflows_test.dart' show FakeTogetherPlayer, eapiBody;

class _Location extends TogetherLocationGateway {
  _Location(this.result);
  Future<TogetherLocationFix> Function() result;
  int requests = 0;
  @override
  Future<TogetherLocationFix> requestFix() {
    requests++;
    return result();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late NeteaseTogetherController controller;
  late FakeTogetherPlayer player;
  late _Location location;
  late List<Map<String, dynamic>> gps;
  late bool current, inRoom, gpsAccepted;
  setUp(() {
    current = inRoom = true;
    gpsAccepted = true;
    gps = [];
    location = _Location(() async => const TogetherLocationFix(30, 120, 500));
    player = FakeTogetherPlayer();
    final api =
        NeteaseApi(
          MockClient((request) async {
            final path = request.url.path;
            var data = <String, Object?>{};
            if (path.endsWith('/status/get')) {
              data = {
                'inRoom': inRoom,
                'roomInfo': {
                  'roomId': 'room-1',
                  'roomUsers': [
                    {
                      'user': {'userId': 7, 'nickname': '我'},
                    },
                    {
                      'user': {'userId': 8, 'nickname': '音乐朋友'},
                    },
                  ],
                },
              };
            } else if (path.endsWith('/user/gps/report')) {
              gps.add(eapiBody(request));
              data = {'success': gpsAccepted};
            } else if (path.endsWith('/distance/get')) {
              data = {'distance': 12.34, 'unopenedUserIds': []};
            } else if (path.endsWith('/relation/statistics/get/v2')) {
              expect(eapiBody(request)['roomUserIds'], '[8]');
              data = {
                'totalConnectionTime': 7260,
                'currentConnectionTime': 120,
              };
            } else if (path.endsWith('/end/v2')) {
              inRoom = false;
            }
            return http.Response(
              jsonEncode({'code': 200, 'data': data}),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }),
        )..configure(
          const NeteaseSession(
            userId: '7',
            cookies: {'MUSIC_U': 'fixture'},
            deviceId: 'fixture',
          ),
        );
    final music = NeteaseMusicRepository(api);
    controller = NeteaseTogetherController(
      music: music,
      player: player,
      messages: NeteaseMessagesRepository(music),
      isCurrent: () => current,
      automaticTimer: false,
      locationGateway: location,
    );
  });
  tearDown(() async {
    controller.dispose();
    await player.close();
  });

  test(
    'restore obtains official seconds and never asks for GPS implicitly',
    () async {
      await controller.restore();
      expect(controller.peers.single.id, '8');
      expect(
        controller.togetherDuration!.inSeconds,
        inInclusiveRange(7260, 7261),
      );
      expect(location.requests, 0);
      expect(gps, isEmpty);
      await controller.restore();
      expect(controller.togetherDuration!.inHours, 2);
    },
  );
  test(
    'explicit location uses the official report and distance routes without Wi-Fi data',
    () async {
      await controller.restore();
      await controller.enableLocation();
      expect(controller.locationEnabled, isTrue);
      expect(controller.distance.kilometres, 12.34);
      expect(gps.single['opened'], 'true');
      expect(gps.single['privacy'], 'true');
      expect(gps.single['latitude'], 30);
      expect(gps.single.containsKey('ssid'), isFalse);
      await controller.disableLocation();
      expect(gps.last['opened'], 'false');
      expect(controller.locationEnabled, isFalse);
      expect(controller.distance.kilometres, isNull);
    },
  );
  test(
    'explicit platform rejection never reports location sharing as enabled or closed',
    () async {
      await controller.restore();
      gpsAccepted = false;
      await controller.enableLocation();
      expect(controller.locationEnabled, isFalse);
      gpsAccepted = true;
      await controller.enableLocation();
      expect(controller.locationEnabled, isTrue);
      gpsAccepted = false;
      await controller.disableLocation();
      expect(controller.locationEnabled, isTrue);
      expect(controller.presenceNotice, contains('未获确认'));
    },
  );
  test('closing the room rejects a late OS location result', () async {
    final pending = Completer<TogetherLocationFix>();
    location.result = () => pending.future;
    await controller.restore();
    final action = controller.enableLocation();
    await controller.end();
    pending.complete(const TogetherLocationFix(30, 120, 40));
    await action;
    expect(gps, isEmpty);
    expect(controller.active, isFalse);
    expect(controller.togetherDuration, isNull);
  });
  test(
    'a changed account never reports coordinates from a pending fix',
    () async {
      final pending = Completer<TogetherLocationFix>();
      location.result = () => pending.future;
      await controller.restore();
      final action = controller.enableLocation();
      current = false;
      pending.complete(const TogetherLocationFix(30, 120, 40));
      await action;
      expect(gps, isEmpty);
    },
  );
  test(
    'denied permission leaves playback synchronization and the room intact',
    () async {
      location.result = () async => throw PlatformException(
        code: 'permission_denied',
        message: '位置权限未开启',
      );
      await controller.restore();
      await controller.enableLocation();
      expect(controller.active, isTrue);
      expect(controller.error, isNull);
      expect(controller.presenceNotice, '位置权限未开启');
      expect(gps, isEmpty);
    },
  );
  test(
    'distance sentinels and invalid fixes cannot become fabricated proximity',
    () {
      for (final value in [0, -1, 'NaN', 999999]) {
        expect(TogetherDistance.parse({'distance': value}).kilometres, isNull);
      }
      expect(
        TogetherDistance.parse({
          'data': {'distance': 10.5},
        }).label,
        contains('10.50'),
      );
      final sharingClosed = TogetherDistance.parse({
        'distance': 12.34,
        'unopenedUserIds': [8],
      });
      expect(sharingClosed.kilometres, isNull);
      expect(sharingClosed.label, '等待对方开启位置');
      expect(
        () => TogetherLocationFix.parse({
          'latitude': 100,
          'longitude': 10,
          'accuracyMeters': 10,
        }),
        throwsFormatException,
      );
      expect(
        formatTogetherDuration(const Duration(minutes: 61)),
        '一起听了 1 小时 1 分钟',
      );
    },
  );
  testWidgets(
    'player room island uses real membership and explicit location consent',
    (tester) async {
      await controller.restore();
      var manages = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            neteaseTogetherControllerProvider.overrideWithValue(controller),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: NeteaseTogetherPlayerHeader(onManage: () => manages++),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('一起听了 2 小时 1 分钟'), findsOneWidget);
      await tester.tap(find.text('开启位置查看距离'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(location.requests, 0);
      expect(find.text('开启位置'), findsOneWidget);
      await tester.tap(find.text('暂不开启'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(gps, isEmpty);
      await tester.tap(find.bySemanticsLabel('与音乐朋友一起听，管理房间'));
      expect(manages, 1);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
