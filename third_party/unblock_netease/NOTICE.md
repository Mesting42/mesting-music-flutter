# UnblockNeteaseMusic native source adapters

Upstream: https://github.com/UnblockNeteaseMusic/server

Pinned revision: `1d64281c0fae81a4e3cf21f176706b0baa3a606d` (enhanced branch), package 0.28.0.

The original server project states LGPL-3.0-only. Its `COPYING.LESSER`, GPL text `COPYING`, README, package metadata and the referenced original provider files are retained here. Original authorship and credits remain in those files. WBI references additionally credit SocialSisterYi/bilibili-API-collect as upstream does.

Mesting 1.0.15 adapts the anonymous Bilibili audio/video and GD Studio request sequencing to native Dart in `lib/features/music_platform/netease/fallback/netease_public_sources.dart`. This adapted module is distributed under LGPL-3.0-only with its corresponding Dart source in the complete source ZIP. The recording interfaces and integration are kept separate for maintenance. No upstream Node runtime, proxy, certificate, private key, shared account cookie, advertising completion event or server-side membership patch is bundled or executed.

Changes from upstream: HTTPS retained; anonymous public CDN headers follow probe, player and download; no personal account cookies; explicit performer/title and duration checks replace first-result selection; stale video metadata is checked again; bounded work/cancellation checks; no relay fallback; delivered format is checked rather than assigning a quality solely from a request. GD Studio is disabled because its current endpoint rejects the NetEase source. The original existing anonymous Kugou/Kuwo and BugPk adapters remain Mesting integrations.

The local SVIP feature is an independent on-device presentation/preference policy. It does not alter secure credentials or authenticated upstream API responses.
