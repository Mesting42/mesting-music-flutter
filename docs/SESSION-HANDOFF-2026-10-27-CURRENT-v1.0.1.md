# 当前会话交接：Mesting Music 1.0.1

整理日期：2026-10-27（Asia/Shanghai）。项目目录 **`D:/AnLi`**。本文供用户要求的新会话接手，覆盖本会话的 Beta.21 功能修改、后续纠正与 1.0.1 更新接入；继承的 Beta.20 工作另列为历史背景。

**接手后先只读核对，再等待用户下一条指令。不要自行开始真机操作、修复历史失败、重新打包、上传、发布或 Git 提交。** 本文不是新的待办授权；已有确认的产品决定继续有效，不需要重复询问。

## 一、当前结论

- 已完成用户确认的界面、交互、欢迎角色、指南/法律文本与应用内更新代码。当前交付并在平台观察到的公开版本为 **1.0.1 / Android versionCode 22**。
- 应用显示名 **Mesting Music**；内部 flavor `beta` 与包名 **`com.mesting.music.beta`** 保持，使用原 Beta.14–21 证书。公开名称不再用 beta，不代表可以修改兼容性包名或换签名。
- Release APK、源码 ZIP、安装说明和核验文件已交付。公开 health、真实 HTTPS 完整下载、暂停续传和 SHA-256 均已验证；这不是用户手机上的安装验收。
- 当前没有已授权但遗漏的本轮编码、打包或上传任务。尚未完成/刻意暂缓的事项列在第五节，不得全部当作自动续做任务。
- 工作区包含未提交的 Beta.20、Beta.21 与 1.0.1 修改。Git 仍停在 Beta.19，**本地工作区才是继续开发的真实来源**；GitHub clone 不含本轮成果。

## 二、会话完成内容与最终决定

| 范围 | 最终实现及不可混淆的决定 |
| --- | --- |
| 播放队列 | 弹出播放列表与播放器内待播列表共用 `BetaPlaybackQueue`，采用现有 Apple Music 风格玻璃；支持拖拽手柄排序、左滑移除、无障碍上下移动/移除。列表更新时按歌曲身份重定位；移除待播项不替换当前音频。随机与循环操作独立。 |
| 成功提示纠正 | Beta.21 曾误解为去掉整个成功对勾；**1.0.1 已纠正为保留绿色圆环/对勾，只移除标记绘制过渡**。使用 `BetaSuccessMark(animated: false)`，保留文字、容器进退、触感和语义播报。旧 Beta.21 文档的“纯文字/不挂载 check”是历史，不能重新套用。专用登录成功 HUD 独立。 |
| 首次协议卡 | 移除 Beta 首次进入自动叠加的协议/隐私卡片，不自动写入同意；欢迎页显式勾选、链接和登录同意校验保留。stable 原逻辑保留。 |
| 手机登录输入材质 | `BetaGlassScrollBody` 在 overscroll 合成内补齐真实页面底层，修复手机号/验证码输入框滚动变灰，保留 premium 模糊、折射、形变等材质。 |
| 用户协议/隐私 | 按现有酷狗登录、验证码/扫码、安全验证、搜索/播放、评论、账号/本地存储、路由与权限、历史云账号等功能重写。1.0.1 补充下载平台、网络请求信息、随机下载 UUID 和系统安装权限说明。不虚构服务端能力、删除第三方账号或实际时长入账；联系方式按用户决定暂缺。 |
| 新手指南 | 八页指南按实际搜索、播放/歌词/评论、账号与收藏、队列手势、设备输出、启动/天气及播放器样式组织；预览可交互，示意不发账号请求、不播放真实音频、不写用户数据。 |
| 欢迎角色 | 使用启动图中的黑胶唱片和奶油色耳机身份：唱片左下坐姿、耳机右侧搭肩；默认显示 `hi` 气泡与三条手指提示线，随挥手/点按弹动，配合眨眼、点头和轻跳。它是组合姿态图集的 2D 动画，不是新的骨骼 3D 模型。不可见、后台或减少动画时停止。用户明确要求后续欢迎背景/按钮调整不改变这两个人物。 |
| 欢迎背景/按钮/图标 | 用户选定中性近白/近黑背景；手机号蓝色主胶囊、微信及游客/其他方式中性玻璃。手机图标采用细线 `CupertinoIcons.device_phone_portrait`；窄屏大字时次入口上下排列。角色图集、站位和舞台字节保持。 |
| 切换音频设备 | 在原音频输出玻璃卡片内展开可用设备，而非直接跳到不同视觉的系统卡片；只列系统公开可转移路由，原生确认并读回后才显示成功。配对、新设备等系统不公开操作保留“系统设备管理”；不能保证 Android 系统界面也能使用应用自绘风格。 |
| 评论发送等待 | 修复浅色下不清楚的发送等待标记，保持 48dp 蓝色 premium 材质；输入、指针和焦点单独阻断，避免 disabled 透明度削弱。Cupertino 默认 spinner 最大 alpha 147/255 仍偏淡，改用独立八刻度白色 `BetaActivityIndicator`，半径 12、亮部完整不透明；1 秒绘制周期，减少动画/不可见时暂停。 |
| 应用内更新 | 用户选择常规 HTTPS 提醒、下载、安装，**不接入 P2P/P8P/分享**。读 music 公开 health，使用真实 Android code 判断版本，支持主源/有界备用源、Range/If-Range、暂停续传、SHA-256 和原有原生包名/版本/签名校验。无后台凭据进入客户端。 |
| 版本更新抽屉 | 点击设置入口立即打开同一 premium 玻璃抽屉，再异步显示检查中、已最新、发现新版、下载、暂停、校验、权限、准备安装、系统安装已打开或错误重试。复用单一 owner，防重复下载/安装器；存储不可用可恢复。不能把“打开安装器”写成“安装成功”。 |
| 下载进度 | 用户选择 **4dp 细胶囊 + 百分比 + 已下载/总大小**。首帧恢复已保存进度，后续填充 180ms 插值，减少动画时直接更新；字节标签始终是真实数据。100% 下载与校验/安装分开。 |
| 自动提醒规则 | 完成首次入口后含游客都可检查；回前台按 15 分钟节流，同一非强制版本“稍后提醒”暂缓 12 小时；手动检查可立即执行。关闭再打开抽屉不创建第二个下载任务。stable/Java 测试源保留原规则。 |

已有 Beta.20 修改继续保留：搜索/accessory 点击范围修复、评论通过根 Navigator 避开底栏、蓝色功能/粉色收藏/绿色签到的语义色、签到日历和启动图完整帧约 500ms 展示。它们不是本轮新待办；详见 [Beta.20 修改](fixes-2026-10-27-beta20.md)。

## 三、当前 Git 与交付文件

只读核对时的分支 `beta`，HEAD **`edc6d1bf881cbe2173709cc84b86b91637fbaaed`**，标签 **`v1.0.37-beta.19`**。未 commit、tag、push 或创建 GitHub Release；未在本交接阶段 fetch 或切换分支。

| 文件 | 已冻结身份 |
| --- | --- |
| `release/Mesting-Music-v1.0.1.apk` | 1.0.1 / 22；76,197,276 字节（72.67 MiB）；SHA256 `27FBC6BA1DDF98A405A322AB8B71F834ED4A9456042E5D2821B8AA15546D80D2` |
| `Mesting-Music-v1.0.1-source.zip` | 47,224,043 字节；1088 个文件；SHA256 `E6C10555D5039925A6816BDEE2E2460EF0B5FF1BA33DE0DA5DFC0074738040AB`；不含 Git 历史、APK、密钥、缓存或账号报告 |
| `release/Mesting-Music-v1.0.1-verification.json` / `.apk.sha256` | 实际包名、版本、证书、双 ARM、对齐、原生库和资源核对 |
| `release/1.0.1-安装说明.txt` | 安装方式、更新引导与真机边界 |
| `docs/version-archive/v1.0.1-evidence/` | `test-summary.json`、`platform-verification.json`、`live-client-verification.json`、`https-probes.json` |
| `.codex-artifacts/2026-10-27-v1.0.1/` | 本机完整日志、28 张控件截图、平台截图、构建/源码核验、下载文件与匿名会话缓存；Git 忽略 |

当前证书 SHA256：**`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`**。APK 已核验 Release 非调试、v2 签名、ARM32/ARM64、ZIP 与 ARM64 ELF 16 KiB 对齐、10 项原生库与构建输出一致、69 项正式专用素材排除、原始启动 PNG/组合图集入包字节一致。依赖锁未变。

旧 Beta.20/21 APK 与源码 ZIP 原样保留。尤其 Beta.21 APK SHA256 `46723B9F392121107DC5AF7423B7DEC8E08DCFDD77C4A86FC8B2DED0094EDBD9`、源码 ZIP SHA256 `31C2396315F5832045F7E6943E7947DFE49DFF08AA3978ABEBA836269B45C4DD`。不要覆盖这些归档。

**本交接文档是在 1.0.1 源码 ZIP 冻结后，按用户新要求新增。该 ZIP 不含本文和本次接续指针更新；应用代码、已交付 APK 和 ZIP 没有因此重建或改写。** 同机继续使用 `D:/AnLi`；移到另一电脑需连同本文单独带走，而非以为重新 clone 已含全部修改。

## 四、验证结论与证据边界

| 验证 | 实际结果 |
| --- | --- |
| Beta 广泛回归 | 268 项通过；在最后存储恢复和 spinner 修复前执行，后续由受影响测试覆盖。 |
| 最终受影响回归 | 29 项通过，包含更新协议、重复 owner、存储恢复、入口/游客、立即打开抽屉、评论与成功提示及主机状态捕获。与广泛组重叠，不相加。 |
| stable 完整回归 | 740 通过、117 条件跳过、2 项既有失败，没有新增失败；在最终评论 spinner 小范围修复前执行，后者另有受影响回归。不得声称全量全绿。 |
| 静态分析 | 最终 `flutter analyze --no-pub` 无问题。 |
| 视觉复核 | 28 张浅深色/窄屏大字生产 Flutter 控件主机截图，合成账号/版本/下载数据与 Windows QA 字体；安装阶段夹具已补全完成路径/字节。独立完整复核仅留 spinner 对比一项，修复后 R1 verdict 为 `ship`：浅色 5.08:1、深色 5.95:1。最终 verdict 只评分 R1，不扩大为真机验收。 |
| 真实线上下载 | 使用生产 repository/source，明确模拟旧版 code21 身份；在 1,051,711 字节暂停，再续传至 76,197,276 字节并通过 SHA-256。1 项测试通过；未调用 Android 安装器，未使用用户手机。 |
| 主/备站探测 | 新版发布后各读取 1,024 字节，均为 206、总长度 76,197,276，具备 APK ZIP 开头。备用站未做整个 APK 的完整下载，不冒称完整镜像验收。 |

平台标识为 **music**，公开入口 [下载 APK](https://download.csnas.asia/music/download)，公开元数据 [health](https://download.csnas.asia/api/app/music/health)，备用 `https://download1.csnas.asia/music/download?direct=backup`。交付时公开版本 1.0.1、实际 code22、大小/摘要与本地一致。代理完成浏览器候选上传后，页面已显示相符线上版本，因此未重复点击发布。记录以公开 health 与真实文件下载为依据；不猜测线上状态转变由谁触发。

历史手机操作须区分时间：Beta.20 曾经授权安装；此后用户重新连接手机并单次授权升级 Beta.21，已 `install -r` 成功、首次安装时间未变、正常启动约 10 秒。证据在 [Beta.21 后续安装记录](version-archive/beta21-evidence/phone-upgrade-2026-10-27.json)，它补充/覆盖旧冻结交接中的“构建时未安装”状态。**1.0.1 没有安装到用户手机，之前授权已完成，不能沿用。** 没有验收全部账号/历史数据或 Android GPU、IME、TalkBack、蓝牙转移、返回手势、帧率。

## 五、未完成、暂缓与非待办

| 项目 | 状态及下一步边界 |
| --- | --- |
| 1.0.1 真机安装和完整业务验收 | 尚未完成，交由用户自测。旧 Beta.20/21 没有本轮更新功能，先手动覆盖安装一次 1.0.1，之后新版才可应用内提醒/下载/打开安装器。新会话无新的明确授权时不得访问手机。 |
| 两项历史测试失败 | 仍存在：`editing menu leaves its gap outside the complete multiline field`（`test/beta_glass_popover_test.dart`）与 `follower removal sheet stays above the persistent player`（`test/social_ui_test.dart`）。不是本轮新增回归；等待用户决定是否另行处理，不为了交接擅自修复。 |
| 协议/隐私联系方式 | 用户明确“这个没有，先不填写”。刻意暂缓，不能填虚构邮箱/主体，也不要反复追问已决定的空缺。 |
| 自动听歌时长同步 | 未验证真实入账，所以自动上报保持关闭。历史两轮试验服务器累计仍为 850 秒、官版仍 14 分钟，HTTP/业务成功不等于入账；见 [独立记录](listening-sync-verification-2026-10-27.md)。没有新授权不重试账号写入、领奖或设备试验。 |
| Git 正式归档 | 未 commit/tag/push/GitHub Release；这是授权边界，不是漏执行。本轮平台 APK 上线不等于 GitHub 已同步。 |
| 后续版本 | 当前仅发布 1.0.1。下一版本若获用户批准，应保持包名/原签名并提高 APK 内 code（下一次至少 23）；不要仅改平台展示名。不得自动创建或发布 1.0.2。 |
| P2P/P8P、COS 回退 | P2P/P8P/分享明确不在本轮范围；本应用 COS 回退未配置，不是漏接入。常规主/备 HTTPS 路线已实现。 |
| 设计旧 sidecar 漂移 | `.impeccable/design.json` 历史叙述漂移已记录，未修复。当前权威是 PRODUCT.md / DESIGN.md 的 1.0.1 节与真实实现，不应顺手重建 sidecar。 |

## 六、接手必须保留的约束

1. 保留整个 dirty 工作区；不 reset、clean、stash、切换分支、批量 stage、恢复用户删除或以旧 clone 覆盖。不要因显示 beta 分支就重新开发 Beta.19 的旧方案。
2. 原 APK/源码 ZIP 冻结不覆盖，不为纯交接重新打包。修改业务代码后才按新版本另行构建和验证。
3. 没有新的明确设备授权，不运行 ADB、不安装、不启动或读取用户手机。原生性能测试仅隔离 `.beta.benchmark`，强制 `--keep-app-running`；不得对日常安装默认 `flutter drive`。
4. 管理后台账号/密码只用于原会话授权的正常登录；**不写文档/代码/日志/构建参数、不复制到新会话提示，也不从旧日志反查凭据**。签名私钥同样不进 Git、平台或源码包；需要迁移时由用户私下提供。
5. 视觉沿用用户选定 Apple/iOS27 方向，不把自定义 RGB 宣称为官方精确规范。保留现有 premium 模糊、折射、形变、回弹和胶囊开合，不能通过降低材质解决缺陷；人物站位、hi/手指线和互动不得擅改。
6. 新需求/bug 遵守 AGENTS.md：一次只问一个问题，理解后给方案，用户确认再实施；必要注释、业务/展示解耦。已确认事项不要重问。
7. 不把“未真机验收”写成“未实现”，也不把主机/模拟数据测试写成真实账号或手机验收。实际证据、历史说明与当前实现有冲突时按时间与新版本纠正说明判断。

## 七、构建环境和关键入口

- Flutter **3.41.9** / Dart **3.11.5**；本机 SDK `D:/CodexCache/flutter-3.41.9`。
- JDK **17.0.20.1+1**；本机环境参考 `.codex-artifacts/2026-10-27-v1.0.1/env.ps1`，不要在新电脑照搬绝对路径。
- Android compile/target **36**、minSdk **24**、NDK **28.2.13676358**；双 ARM APK。
- `pubspec.lock` SHA256 **`3F2DC18A71A59324ADF202E8EFE43E2F712B23A16E743B772AF0EC10748B4957`**。本轮没有添加依赖或升级锁。
- 共享正式 `pubspec.yaml` 版本 **1.0.37+58** 保留，`tool/build_android_md3_beta_apk.ps1` 覆盖为公开 **1.0.1 / 22**，并启用 `ENABLE_APP_UPDATE_CHECKS`。
- Release 命令为 `./tool/build_android_md3_beta_apk.ps1 -FlutterSdkRoot 'D:/你的Flutter目录/flutter'`。**不能追加 `--no-pub`**：测试可能残留 dev-only 原生插件注册，脚本依赖 pub 阶段重建正确 Release 注册并校验锁。
- 不在只读交接时运行核验/归档脚本：部分脚本会复制 APK、写报告、清资源暂存或拒绝覆盖既有文件。读 JSON、文件属性和 SHA 即可。

| 功能 | 主要文件 |
| --- | --- |
| 队列与入口接入 | `lib/features/queue/presentation/beta_playback_queue.dart`、`queue_page.dart`、`player_queue_panel.dart`、`beta_now_playing_page.dart` |
| 欢迎/角色/指南 | `beta_welcome_page.dart`、`beta_companion_stage.dart`、`beta_guide_preview.dart`、`beta_onboarding_page.dart`；图集和来源 `assets/branding/welcome/` |
| 成功/等待与滚动底层 | `lib/shared/widgets/beta_success_feedback.dart`、`music_notice.dart`、`beta_activity_indicator.dart`、`beta_glass_scroll_body.dart` |
| 评论/登录/法律 | `platform_comment_composer.dart`、`platform_account_page.dart`、`legal_documents.dart`、`legal_documents_page.dart`、`disclaimer_dialog.dart` |
| 设备输出 | `audio_output_controller.dart`、`player_output_dialog.dart`、`player_output_routes.dart`、Android `AudioOutputBridge.kt` |
| 更新元数据/文件/状态 | `lib/features/app_update/data/app_update_release_source.dart`、`app_update_repository.dart`、`app_update_providers.dart` |
| 更新展示/自动检查 | `beta_app_update_sheet.dart`、`apple_download_progress.dart`、`app_update_sheet.dart`、`app_update_coordinator.dart`、`settings_page.dart` |
| 本轮测试 | `test/beta21_refinements_test.dart`、`test/release_101_ui_test.dart`、`test/csnas_app_update_test.dart`，以及原有入口/评论/法律/通知测试 |

## 八、新会话接收顺序

1. 阅读根目录 `AGENTS.md`、本文、[1.0.1 详细交接](SESSION-HANDOFF-2026-10-27-v1.0.1.md)、[1.0.1 修改](fixes-2026-10-27-v1.0.1.md)、[发布步骤](RELEASE-UPDATE-GUIDE.md)。
2. 对照 [Beta.21 修改](fixes-2026-10-27-beta21.md)、[Beta.20 修改](fixes-2026-10-27-beta20.md)、[Git 归档](../BETA_ARCHIVE.md)、PRODUCT.md / DESIGN.md。旧方案仅用于追溯，不覆盖第二节的最终决定。
3. 只读 `git status --short`、当前 branch/HEAD/tag 和本地 APK/ZIP 哈希，读取便携核验 JSON。不要默认联网、运行测试/构建、访问手机或平台。
4. 用简短中文确认已接收、当前 1.0.1/22、dirty 工作区和待验收/暂缓项，然后等待用户指示。用户已授权创建并移交新会话，这不自动授权本节以外的新工作。

本文与接续指针是本交接请求新增文档。原 `SESSION-HANDOFF-2026-10-27-CURRENT-SESSION.md` 属于较早的 Beta.20 记录，保留原文件，不能因名称含 CURRENT 就当作最新入口。
