# NetEase protocol adapter

The Dart adapter in lib/features/music_platform/netease ports the documented request formats and encryption contracts of @neteaseapireborn/api 4.29.7, derived from Binaryify/NeteaseCloudMusicApi. The pinned npm source is distributed under the MIT license reproduced alongside this notice. The interface family is also used by https://github.com/qier222/YesPlayMusic .

No YesPlayMusic UI or Node runtime is embedded. This adapter uses direct HTTPS to the upstream music hosts and independent secure storage; it does not require an API deployment.

Version 1.0.12 additionally compares music and podcast contracts used by https://github.com/algerkong/AlgerMusicPlayer at f57204d4205769a4457f5975796a35e41785f1d8. Presentation remains the original Mesting Flutter implementation. The Android fallback resolver is independently implemented in Dart: it tries https://api.bugpk.com/api/163_music by exact NetEase song ID, then strictly matched anonymous public sources. No NetEase account cookies are shared with fallback providers. The original account stream remains preferred; delivered quality and fallback provenance are retained. No UnblockNeteaseMusic Node server or desktop binary is embedded.
