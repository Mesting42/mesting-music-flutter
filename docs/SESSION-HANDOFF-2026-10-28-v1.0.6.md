# Mesting Music 1.0.6 接续

日期：2026-10-28（Asia/Shanghai）。工程根 `D:/AnLi`，基于 `beta` / 固定标签 `v1.0.5` / `dbc5e78d05570c26f56fe5c5773245737a464a5f` 的本轮修改。行为和验证见 [修改记录](fixes-2026-10-28-v1.0.6.md)。

## 交付身份

| 项目 | 值 |
| --- | --- |
| 版本 / Android code | 1.0.6 / 27 |
| 应用 / 包名 / flavor | Mesting Music / com.mesting.music.beta / beta |
| 原签名 APK | release/Mesting-Music-v1.0.6.apk |
| 文件大小 | 99,228,739 字节 |
| SHA-256 | 5A3FB2521F99AFF619D55C25C61E540E426B1E36F747A7955C87F6C3B95DEAAD |
| 原签名证书 SHA-256 | 8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333 |
| pubspec.lock SHA-256 | FDE25643DA671EF68397B59A3BB38E4AD5F664075E2D0414EBADABB9DC2DF2EF |

ARM32 + ARM64、Release 非 debuggable；ZIP 与六个 ARM64 ELF 16KiB 对齐通过。RingDownloadPlugin、FlutterWebRTCPlugin 存在，IntegrationTestPlugin 和主机 QA 字体未入包。69 项正式渠道专用素材继续排除；更新说明 JSON 与源码逐字节对应。

## 本机构建

Flutter 3.41.9 / Dart 3.11.5，JDK 17.0.20.1+1；共享 SDK、JDK 和签名保留。此次 Gradle 按实际插件需求自动补装 Android Platform 34，既有 33/35/36 未移除。不是因为旧交接说 WebRTC 必须 SDK34 而手动全量安装或升级依赖。

首次本机新基线构建约 1139.7 秒。R8 阶段默认 Gradle 8GB heap 在本机 16GB 内存上造成换页；构建已完整成功，本轮结束时停止该次 Gradle daemon 以释放内存，没有重建或重签此包。后续如再次遇到内存压力，优先使用进程内的较小 heap / workers 配置，不擅改共享 SDK 或清理缓存。

## 权限与下一轮

用户确认了本轮实施与 music 后台上传发布；没有要求本轮 Git/GitHub 提交、推送、建标签或新建 Release。保留原有三份跟踪交接文档的未提交改动、新本机清理交接与全部本轮源码；不 reset/clean、不覆盖冻结旧交付、不自动推送。

SDK 分享与自动听歌时长写入继续关闭，原许可/第三方声明保留，签名及凭据不进入源码包、Git 或后台附件。用户自行真机测试，未经新授权不访问手机或 ADB；原生性能工具仍仅允许隔离 `.beta.benchmark` 与 `--keep-app-running`。

本轮新旧 Beta 分组共 152 项通过，选定 stable 28 项通过（有共享用例）；17 张主机捕获与最终静态分析通过。原始证据在 `.codex-artifacts/2026-10-28-release106/`。这些是主机/协议/产物证据，不认证物理 Android GPU 持续 120fps、真实蓝牙/音效、真实账号写入或保留数据升级。

后续实际 Android code 必须大于 27。未来说明需同时更新 `assets/data/release-notes.json` 与内置历史；正式构建入口会校验 JSON 的版本/code，未知未来版本的在线说明由目标 APK 读取。已发布 1.0.5 不具备该能力，用户已接受从 1.0.6 起生效。

## 分发验证

- 已通过用户已登录的 Codex 内置浏览器上传、暂存、核对并发布到 Mesting Music / music；保留旧版历史，其他应用未改。
- 发布后的公开 health 为 1.0.6 / 27，文件名、99,228,739 字节及 SHA-256 与上述本地原签名 APK 一致。
- 从公开主入口完整下载 99,228,739 字节，SHA-256 匹配。真实生产 `PublicApkReleaseNotes` 读取线上 APK 的 Range、ETag、ZIP 条目与中文说明通过，未使用内置历史冒充远程结果。
- 随后追加的 1024–2047 续传片段复核收到 HTTP 429，`Retry-After: 2804`（约 47 分钟），本次不继续请求或更改后台限流配置。该额外片段检查没有通过，不宣称完整实网断点续传验收；此前线上说明的多次 Range 读取和主机下载/续传回归已通过。
- 忽略目录保留 `public-health.json`、`full-download-verification.json`、`live-notes.json`、下载文件与 `music-published.jpg`，没有后台凭据。

当前交付源码、1.0.6 修改和接续资料仍在本地工作区，Git HEAD / 标签保持原基线；本次未提交、推送或创建 GitHub Release。1.0.6 独立完整源码包另存于根目录 `Mesting-Music-v1.0.6-source.zip`，不含私钥、本机配置和缓存。新电脑不能仅靠 clone 未推送的 beta 获得本轮修改。
