# NetEase protocol adapter

The Dart adapter in lib/features/music_platform/netease ports the documented request formats and encryption contracts of @neteaseapireborn/api 4.29.7, derived from Binaryify/NeteaseCloudMusicApi. The pinned npm source is distributed under the MIT license reproduced alongside this notice. The interface family is also used by https://github.com/qier222/YesPlayMusic .

No YesPlayMusic UI, Node runtime, or audio-unblocking module is embedded. Upstream account permissions and returned media URLs remain authoritative. This adapter uses direct HTTPS to the upstream music hosts and independent secure storage; it does not require an API deployment.
