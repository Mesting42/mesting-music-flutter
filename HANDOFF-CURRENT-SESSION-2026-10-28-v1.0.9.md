# 当前会话接续：Mesting Music 1.0.9

日期：2026-10-28（Asia/Shanghai）。工程根 `D:/AnLi`。

**后续修复已随1.0.10/code31发布music：** 导入同排、场景专区资源、胶囊切歌、统一模式颜色、按钮状态、指南关闭和同步参数修复见 [实现阶段接续](HANDOFF-CURRENT-SESSION-2026-10-28-UI-SCENE-SYNC.md)，最终发布证据见 [1.0.10接续](HANDOFF-CURRENT-SESSION-2026-10-28-v1.0.10.md)。下方1.0.9发布与冻结摘要是历史交付证据，不代表新修复已进入该APK或旧源码ZIP；旧交付保持不变。

用户确认统一听书／功能搜索的底部控件、修复菜单残点和上沿凸起、调整私人 FM 首屏加载并移除加载底色；随后明确要求发布到 music，并确认版本 **1.0.9 / Android code30**。

**当前状态：1.0.9 / code30 已发布 music，后台显示当前公开版本1.0.9；公开health、完整下载SHA-256及安装前线上更新说明读取均通过。本轮实施、打包和发布已完成，真实设备验收由用户自行进行。**

## 源码与验证入口

- [1.0.9 接续](docs/SESSION-HANDOFF-2026-10-28-v1.0.9.md)、[本版修改](docs/fixes-2026-10-28-v1.0.9.md)、[修复阶段记录](docs/fixes-2026-10-28-search-menu-fm.md)。
- [1.0.6～1.0.8 完整背景交接](HANDOFF-CURRENT-SESSION-2026-10-28-v1.0.8.md) 保留既有选择、功能范围、历史性能诊断和真实设备／官方账号待验证事项；其中旧发布状态按本版最终接续覆盖。
- 共享搜索契约：`lib/shared/widgets/beta_bottom_search.dart`；输入所有者切换：本地玻璃包 `tab_bar_searchable_internal.dart`；页面集成：`beta_music_shell.dart`、`music_functions_page.dart`、`audiobooks_page.dart`；菜单连接面：`beta_glass_popover.dart`；FM：`platform_recommendations_page.dart`、`automatic_song_paging.dart`。
- 14 项新增专项、53 项完整壳层回归及 32 项更新／下载检查通过；前两批证据在 `.codex-artifacts/2026-10-28-search-menu-fm/`，发布检查在 `.codex-artifacts/2026-10-28-release109/`。主机截图不能代替 Android Impeller、真实键盘或设备性能验收。
- 发布前最终静态分析无问题；生产 `PublicApkReleaseNotes` 实际对线上APK使用Range读取，4条中文说明与随包目标版本完全一致，绕过当前内置历史，覆盖旧客户端安装前读取路径。

## 新安装包身份

| 项目 | 已核验值 |
| --- | --- |
| 安装包 | `D:/AnLi/release/Mesting-Music-v1.0.9.apk` |
| 版本／code | 1.0.9 / 30 |
| 包名／显示名 | com.mesting.music.beta / Mesting Music |
| 大小 | 100,265,367 字节 |
| APK SHA-256 | 87B7D4825B102F1C3A96EB977CE7FB18D8ED7041079D713CEE6AE3A752244FA2 |
| 原证书 SHA-256 | 8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333 |
| 依赖锁 SHA-256 | FDE25643DA671EF68397B59A3BB38E4AD5F664075E2D0414EBADABB9DC2DF2EF |

构建用原 Flutter3.41.9／Dart3.11.5／JDK17，进程局部 Gradle3GB heap／2 workers，耗时约400秒。min24／target36、ARM32／ARM64、release 非 debuggable、ZIP CRC、ZIP 与六个 ARM64 ELF 的16KiB 对齐通过。69 项正式渠道资源、IntegrationTestPlugin、QA 字体和测试 shader 均未入包，Ring／WebRTC 保留。随包与内置四条更新说明已同步为1.0.9。

独立源码交付为 `D:/AnLi/Mesting-Music-v1.0.9-source.zip`，包含本版最终文档、源码、测试及原授权SDK源与许可证。整包摘要与校验记录放在 `.codex-artifacts/2026-10-28-release109/source-verification.json`，逐文件摘要在ZIP内 `SOURCE-SNAPSHOT.json`；不回写旧冻结交付。最终统一核对记录为同目录 `validation-summary.json`。

## music 发布与公开读回

用户已明确授权发布到music并确认1.0.9/code30。使用原登录后台上传本版APK，候选暂存返回完整SHA-256、包名、code30一致后发布；后台已显示 `Mesting-Music-v1.0.9.apk` 和当前公开版本1.0.9。上传耗时581.8秒，未修改其他应用或删除版本历史，证明截图 `.codex-artifacts/2026-10-28-release109/music-published.png`。

[公开下载入口](https://download.csnas.asia/music/download) 与 [公开health](https://download.csnas.asia/api/app/music/health) 已核验。health返回1.0.9/code30、100,265,367字节及表中同一摘要；主入口完整下载100,265,367字节，SHA-256与本机原签名APK一致。证据 `public-health.json`、`full-download-verification.json`、`public-verification.json`；实际Range读取说明证据 `live-notes.log/json`。没有反复下载主备整包或修改限流、权限及COS配置。

## 必须保留的边界

- 分支 `beta`，HEAD `dbc5e78d05570c26f56fe5c5773245737a464a5f`（v1.0.5）；1.0.6～1.0.9 源码仍在未提交工作区。不得 reset／clean／stash 或自动 add／commit／push／tag，保留所有修改、未跟踪文件和旧交付。
- 1.0.6～1.0.8 六份 APK／源码 ZIP 及依赖锁均与冻结记录一致，证据 `preserved-frozen.json`。不因发布新版本清理共享 SDK、签名或缓存。
- 未操作手机，也未代测酷狗真实账号。用户自行验收更新按钮、覆盖安装、键盘、最终玻璃效果、MediaStore／SAF、识曲、听书权限、双端一起听与官方实际入账；120Hz 或主机样本不等于持续120fps。旧625分钟继续本地保留，不造假回填或盲重发 unknown／已dispatch 记录。
- SDK 分享保持关闭，原许可证与第三方声明保留。后台只上传本版 APK；源码 ZIP 不含私钥、凭据、本机配置和构建缓存。
- 新需求继续一次一个问题、理解后方案确认再实施。没有新授权不访问手机；后续原生 benchmark 仅隔离 `.beta.benchmark` 并强制 `--keep-app-running`。
