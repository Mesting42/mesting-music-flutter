# Mesting Music 正式版 1.0.4：P8P 接入交接

2026-10-28（Asia/Shanghai）。用户已确认 1.0.3 发布后接入交接包，并以 **1.0.4 / code 25** 在同一个 music 后台正式发布。本版实现、构建、原签名、后台发布、公开元数据与旧客户端完整下载/续传核验均已完成。

修改范围见 [1.0.4 修改记录](fixes-2026-10-28-v1.0.4.md)，SDK 原始交接见 [SDK 交接文档](RING-P8P-SDK-HANDOFF-2026-10-27.md)。后者基于旧 1.0.2，其示例版本号、环境及“未发布”描述属于原交接当时状态，不能覆盖本文当前事实。

## 安装包身份

| 项目 | 核验值 |
| --- | --- |
| 公开版本 / 实际 code | 1.0.4 / 25 |
| 名称 / 内部 flavor | Mesting Music / beta |
| Android 包名 | `com.mesting.music.beta` |
| APK | `release/Mesting-Music-v1.0.4.apk` |
| 大小 | 97,682,013 字节，93.16 MiB |
| SHA-256 | `FC14345A637A79D03A34E3CC8AE8C1F0B70697B8060751523160212AE79F6FB7` |
| 原证书 SHA-256 | `8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333` |
| 签名 / 模式 | APK v2/v3，Release 非 debuggable |
| 原生 ABI | ARM32 + ARM64，含各自的 WebRTC 原生库 |
| 对齐 | ZIP 16KiB；ARM64 ELF 16KiB；ARM32 ELF 4KiB |
| 本地私有源码快照 | `Mesting-Music-v1.0.4-private-source.zip` |

签名后 525 个非签名 ZIP 条目与构建输出逐字节相同。Release 注册器包含 RingDownloadPlugin 与 FlutterWebRTCPlugin，不含 IntegrationTestPlugin。相对 1.0.3，仅新增 API30 及以下的传统 `BLUETOOTH` 普通权限声明；`ACCESS_NETWORK_STATE` 已存在，没有新增相机/麦克风权限声明。用户端上传分享关闭，音乐播放器及原生音频 owner 没有改动。69 项旧 stable 专用素材继续排除，1.0.3 原始素材逐字节保留。

体积相对 1.0.3 增加约 19.83 MiB，主要来自新增 WebRTC 原生依赖；不以删除已确认保留的素材抵消此新增依赖。

## 运行与回退边界

已发布现有 **Mesting Music · music**，服务端创建时间原文 `2026-10-28T00:20:05.815829`（不额外推定其时区）。[公开 health](https://download.csnas.asia/api/app/music/health) 的 1.0.4 / 25、97,682,013 字节及 SHA-256 与本地包一致；后台当前公开版本也已回读为 1.0.4，没有修改其他应用或 COS 配置。

从冻结 1.0.3 源码 ZIP 逐字节提取原更新模块，以模拟安装 1.0.3 / 24 的身份访问 [公开下载入口](https://download.csnas.asia/music/download)：发现 1.0.4 / 25，下载到 1MiB 暂停，用 `Range: bytes=1048576-` 续传至完整 APK，大小和 SHA-256 均通过。模拟 1.0.2 / 23 同样可发现更新，模拟已安装 1.0.4 / 25 时无更新。主/备入口各自前 64KiB 的 206/总长/字节一致；完整下载仅覆盖主入口。

应用内提醒沿用前台自动检查与“设置 → 版本更新”，保留原 15 分钟检查节流及稍后提醒偏好；没有新建系统后台推送或自动安装服务。

SDK 仅用于更新 APK 下载，appId 为 music，P2P/P8P 开启，allowSharing 为 false；节点不可用时 HTTPS 路径仍可完成。业务更新发现仍使用 music/health，比较实际 APK code，SDK 校验后宿主二次摘要及安装前核验继续保留。

1.0.2/1.0.3 客户端升级到本版仍使用它们已有的 HTTPS 更新代码；安装本版后，后续更新才使用新 SDK。主机可验证下载与元数据，不能替代用户手机覆盖升级、厂商安装权限、实际节点字节贡献、前后台或真实音频/视频验收。本轮没有访问手机、使用 ADB 或启动系统安装器。

1.0.3 已先发布并完整验证，现有冻结交付保持原字节：APK SHA-256 `A3003191040051B30A14AF4938BB9D4CFCAF857A1B8E3A6B9F4558944885A4BA`，源码 ZIP SHA-256 `70F5BDAF9D9618C2FCB60F3B7349DFC2B8212EB35B027120767EA882792A73D5`。旧 APK 不等于 Android 可直接降级并保留数据，回退运行行为须用更高 code 的修复版重新发布。

## 构建与验证

本机保留独立 Flutter 3.41.9 / Dart 3.11.5、JBR21（Java/Kotlin target17）、compile/target SDK36、minSdk24、NDK28.2.13676358。WebRTC 依赖的 SDK34 由构建器在既有 Android SDK 许可下补齐。没有升级全局 Flutter、修改 Pub 缓存或放宽 HTTPS 证书校验。

宿主锁文件 SHA-256：`6E29E2A4B236776D9E7C1BCD458783D0214F0EF151E7DC793B0B4E5AD7591DD0`。先前交接主机 Flutter3.47.7 的六项固定测试依赖按当前 Flutter 约束恢复；本机锁已用 `pub get --enforce-lockfile` 验证。需要复现本版时显式传 1.0.4/25；后续修复必须使用更高实际 code，不能覆盖同一在线 code。

原生库初次直连 Maven 长时间无数据，已仅终止本次创建的 Gradle 客户端/daemon 后重试。成功构建进程使用已有本地代理，配置未写入源码或全局环境；首次主动终止不计为产品编译缺陷。

- 宿主更新接入和 1.0.3 相关回归：80 通过。
- 旧 stable 选定兼容：18 通过；没有重跑旧 stable 全量历史套件。
- SDK 六文件首轮：213 通过、1 项因工作目录误读宿主版本失败；路径修正后该项隔离复测通过。原日志保留，不将首轮写为全绿。没有为 contention 历史用例修改传输策略，本机对应场景首轮通过。
- 全项目静态分析无问题，最后修改处定向分析无问题；完整 Android Release 构建、原签名及对齐核验通过。
- Windows 主机通过真实 SDK 默认引擎下载已发布 1.0.3，2MiB 后暂停恢复、SDK 与宿主校验、安装目录移动均通过。主机明确返回 platform_unsupported 而走 HTTPS，不冒充已验证 Android P8P 连接或真实节点提速。

主机原始证据位于 `.codex-artifacts/2026-10-27-release104/`。便携摘要、线上核验和原包身份在 `docs/version-archive/v1.0.4-evidence/`，源码快照逐条清单另存本机忽略目录；管理密码、私钥、随机下载标识和真实账号记录不归档。

## 源码接续与保密

当前分支 `codex/release-1.0.4`，HEAD 基线 `95d5719829a754978ba615a873aa6ddff08f67f6` / v1.0.2。1.0.3 与本版源码均包含在当前未提交修改中，另有独立冻结 ZIP；本轮未 commit/tag/push，也未创建 GitHub Release。远端 beta/v1.0.2 不能取得本版代码。不要 reset/clean 当前工作区，不重打包旧版快照。

SDK 原始 ZIP SHA-256：`0EDC03178BF446D19947643D59021D46362E24A4B3C8E5A1807C9E85DD4BC7EF`。196 项中 194 项原字节一致，两处本机差异有单独来源说明和摘要。许可不自动授权公开 SDK 源码；本版完整源码快照包含私有 SDK，仅用于私下接续，不直接上传公共 GitHub 或更新后台。更新后台只上传已签名的 APK。

用户已经决定自行真机测试并断开 USB。未经新的明确授权，不运行 ADB、不访问、安装或重启手机。后续新需求继续遵守根目录 AGENTS 的单问题澄清和确认流程。
