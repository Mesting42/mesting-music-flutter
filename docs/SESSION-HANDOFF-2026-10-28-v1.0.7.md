# Mesting Music 1.0.7 接续

日期：2026-10-28（Asia/Shanghai）。工程根 `D:/AnLi`。用户已确认本轮完整实施及发布到 music，版本 1.0.7 / Android code 28，原包名 `com.mesting.music.beta`、显示名 Mesting Music、原签名保持。

**状态：1.0.7 / code 28 已发布 music，公开完整下载摘要与安装前在线说明读取均通过。**

## 源码与授权

Git 分支 beta，HEAD 仍为 v1.0.5 / `dbc5e78d05570c26f56fe5c5773245737a464a5f`。1.0.6 与本轮源码全部保留在工作区，未 Git commit/push/tag/建 GitHub Release。没有要求 Git 发布，不擅自提交。1.0.6 APK、SHA 文件和源码 ZIP 冻结，不覆盖。

用户自行真机测试；本轮不访问手机、不使用 ADB、不安装、不读取凭据或真实账号记录。以后需要设备时重新取得明确授权，原生 benchmark 仅隔离 `.beta.benchmark` 包并强制 `--keep-app-running`。签名材料、本机配置与 SDK 分享关闭状态保留，源码快照排除凭据和缓存。

## 已完成

见 [详细修改](fixes-2026-10-28-v1.0.7.md)。包括播放器模式／玻璃按钮／内缘菜单；发现／固定功能网格；本地音乐、识曲、听书、酷狗一起听；官方历史与新实际时长同步、旧歌曲补传和旧累计时长留本地；真实墙钟计时、纹理共享、底栏内容复用与可导出逐帧诊断。

新功能分层目录与接线：

- `lib/features/local_music/` → `LocalMusicPage`、Android `LocalMusicBridge`，URI 由唯一音频引擎读取。
- `lib/features/recognition/` → `SongRecognitionPage`，PCM conversion isolate、每次独立临时目录与请求取消。
- `lib/features/audiobooks/` → `AudiobooksPage`、`audiobookRepositoryProvider.resolve`、`audiobookProgressBindingProvider`。
- `lib/features/kugou_together/` → `TogetherPage`、`togetherControllerProvider.resolveRoomTrack`。
- `lib/features/music_platform/listening_sync/` → `platformListeningSyncProvider`，设置页 `ListeningSyncPage`。schema 7 journal，`verifyPending()`仅官方只读核对。
- `lib/core/audio/actual_listening_counter.dart` 为本地／平台共用实际墙钟计时基础。

App根按听书／房间／普通歌曲顺序解析播放源，最终仍由同一个 handler 持有音频。页面路由 `/music/local`、`/music/recognize`、`/music/audiobooks`、`/music/together`；功能根继续 `/music`，发现根 `/music/recommend`。

## 验证

48项新增测试、164项受影响Beta回归、73项额外音频／更新回归、42项选定正式渠道回归通过，各批次有交叉不可直接相加。第一次综合Beta命令误含stable固定包名夹具的3项失败已分开正式渠道42项重跑通过，没有放松产品身份校验。静态分析无问题，43张有效Beta主机截图已独立复核SHIP，2项P2修复后7项针对性回归通过。LocalMusicBridge独立Kotlin编译通过。

产物与原始日志在 `.codex-artifacts/2026-10-28-release107/`，额外book/together截图及同步日志在 `.codex-artifacts/2026-10-28-followup-review/`。首轮测试夹具、字体和并行shader文件冲突的失败证据保留，最终日志以 `*-final`／`*-beta` 与接续说明为准。

主机不认证物理Android持续120fps、真实MediaStore/SAF/麦克风、双端房间同步、付费听书权限、酷狗累计时长实际入账或覆盖升级。之前两轮上报成功却未入账的记录仍见 [同步旧证据](listening-sync-verification-2026-10-27.md)；新版本区分接收与核对状态，不能宣称旧625分钟已经进入官版。

## 构建

Flutter 3.41.9 / Dart 3.11.5、JDK17、原共享 Android SDK。正式入口 `tool/build_android_release_apk.ps1` 默认1.0.7/28，校验随包说明JSON匹配且锁文件不漂移，不加 `--no-pub`。本轮使用进程局部Gradle 3GB heap／2 workers避免先前8GB heap换页，没有修改共享Gradle配置或删除缓存。

## 最终安装包

| 项目 | 值 |
| --- | --- |
| 版本 / Android code | 1.0.7 / 28 |
| APK | release/Mesting-Music-v1.0.7.apk |
| 大小 | 100,132,223 字节 |
| SHA-256 | D39E5926A79EA371F0C4491506C4BC6690558955D8D8192E9FBEF6615129CAB8 |
| 原签名证书 SHA-256 | 8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333 |
| pubspec.lock SHA-256 | FDE25643DA671EF68397B59A3BB38E4AD5F664075E2D0414EBADABB9DC2DF2EF |

最终build-final.log为263.6秒构建，之前首次构建302.4秒；协议与隐私页2项通过后重新生成最终交付。ARM32+ARM64、release非debuggable、min24/target36、ZIP和6个ARM64 ELF 16KiB对齐通过，69项正式渠道资产排除。IntegrationTestPlugin与主机QA字体未入包，Ring/WebRTC保留，随包release-notes.json与源码一致。构建结束只停止本轮已确认的Gradle daemon，不动共享SDK或缓存。

## music 发布

已通过用户登录的Codex内置浏览器选择music、上传并暂存、核对完整SHA-256和包名/code28后发布。上传104.1秒；发布后应用卡片已显示Mesting-Music-v1.0.7.apk和公开版本1.0.7。截图 `.codex-artifacts/2026-10-28-release107/music-published.png`。保留历史版本，其他应用未更改；没有上传源码、凭据或签名材料。公开下载和说明读取结果在后文补充。

公开health已读回1.0.7/code28、100,132,223字节和相同SHA-256。公开主入口完整下载后的摘要与本地原签名APK逐字节身份一致，证据 `public-health.json`、`full-download-verification.json` 和 `public-verification.json`。未更改下载限流，不额外反复请求主备片段；安装前说明另使用生产Range/ZIP读取器核对。

生产PublicApkReleaseNotes实际读取线上1.0.7 APK的Range、ETag、ZIP条目和6条中文说明通过，未用当前内置历史冒充远程结果。该读取器、release source和Beta更新面板与冻结1.0.6源码逐字节相同，证明1.0.6已有同一路径；设备上实际点击提醒/安装仍由用户验证。证据live-notes.log/json和old-client-notes-compatibility.json。本轮未额外请求断点片段或整包副站，不把主机续传回归宣称成此次完整实网主备续传验收。

## 可迁移源码

本轮另存根目录 `Mesting-Music-v1.0.7-source.zip`，由git已跟踪文件和未忽略的新源码共同组成（含SDK已获用户授权分发的源码、原许可证和第三方声明），排除签名/凭据/机器配置/构建缓存。ZIP内SOURCE-SNAPSHOT.json逐文件哈希验证，外部source-verification.json记录整个ZIP摘要；ZIP为本机工作区快照，不是Git已推送状态。需要新电脑接续应先读同版AGENTS和本交接，不只clone旧beta远程。

本轮已完成授权范围的源码、回归、构建、music发布和公开交付验证。需要用户真机确认的项目不冒充已完成，具体边界保持上文。
