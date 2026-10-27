# 当前会话交接：Mesting Music Beta.20

**接续更新：以下保留 Beta.20 会话历史。最新本地代码与交付为 [Beta.21](SESSION-HANDOFF-2026-10-27-BETA21.md)，新会话先读该记录与 [修改说明](fixes-2026-10-27-beta21.md)。Beta.21 未访问或安装手机；下文安装、旧测试与版本表仅适用于 Beta.20。**

交接日期：2026-10-27（Asia/Shanghai）。工作目录：`D:/AnLi`。

**给新会话的第一步：先阅读本文和 `AGENTS.md`，只读核对分支、标签、未提交修改及交付文件；简短报告接续状态后，等待用户下一步指示。不要自行编码、构建、访问手机、提交、推送或发布。**

## 一、目前的准确状态

| 项目 | 当前状态 |
| --- | --- |
| 本机产品版本 | 已构建并安装 `1.0.37-beta.20` / versionCode 20 |
| 手机日常包名 | `com.mesting.music.beta` |
| Git 分支 | `beta`，保留本机未提交修改 |
| Git HEAD | `edc6d1bf881cbe2173709cc84b86b91637fbaaed` |
| HEAD 固定标签 | `v1.0.37-beta.19` |
| 本地远端跟踪状态 | `HEAD...origin/beta` 为 `0 0`，两者仍指向 Beta.19；此次交接没有重新访问远端 |
| GitHub 仓库 | `https://github.com/Mesting42/mesting-music-flutter`，公开仓库 |
| Beta.20 提交/标签/Release | **均未创建、未推送、未发布** |
| 正式渠道 | 没有安装到手机，没有更新其版本号或线上更新清单 |

手机显示 Beta.20，而 `git describe --tags --exact-match HEAD` 显示 Beta.19，是因为 Beta.20 在工作区中尚未提交，属于预期状态。不要把本机修改覆盖回 Beta.19，也不要声称从 GitHub clone 就能拿到 Beta.20。

交接时已重新读取 Git 状态并核对 APK、源码 ZIP 和依赖锁哈希，没有重新运行测试、构建或操作手机。

## 二、本会话已经完成的工作

### 1. 核对并接续 Beta.19

已经阅读 `AGENTS.md`、`docs/CONTINUE-BETA.md`、Beta.19 修复及接续记录、`BETA_ARCHIVE.md`、`DESIGN.md`、`PRODUCT.md`，核对本机到 Beta.19 的源码和历史标签。旧版记录属于各自冻结构建，不作为新需求重新实现。

同步 Beta.19 时，曾遇到本机 Gradle wrapper 文件与新增跟踪文件重合；原本机文件和哈希保存在被忽略的 `.codex-backups/2026-10-27-sync-beta19-1ikgtei0/`。没有使用强制 reset、clean 或覆盖用户数据的方式解决。

### 2. 调查并实测听歌时长同步

用户要求“先验证是否可用，可以用的话接上”，并允许对照原开源版及其他 GitHub 项目。已对照 md3Music、KuGouMusicApi、MoeKoeMusic 等实现。源码存在接口不作为实际入账证明。

用户先授权仅使用隔离测试包连接手机。隔离包为 `com.mesting.music.listeningcheck.beta.benchmark`，独立源码副本位于 `.codex-temp/listencheck-e7_504_y/`，账号由用户在手机内登录。主机只读取经过白名单筛选的数值报告，没有提取日常应用或官版凭证。

首个测试包因继承的启动别名指向未包含的 `CoralBrandActivity` 而闪退；已修正为独立原生入口，重新安装后成功打开、登录并完成试验。这是隔离包准备问题，不是日常 Beta.19 的崩溃结论。

两轮分别真实播放 75,651ms、75,649ms。第一轮播放开始、结束及等级上报均返回成功，但累计读回始终为 850 秒；第二轮补齐与原生播放事件相同的持久化 UUID，计数仍不变，结束事件另有一次连接异常。没有把第一轮的时长重发，也没有伪造时长。用户手动刷新官版后确认：账号中心仍为 14 分钟，当天仍无听歌记录。

听歌会员奖励返回 `130012`（今日已领取），到期时间不变，无法证明新增权益。没有反复领取或测试广告领取。

**结论：本次没有验证到累计或当天时长真实入账，Beta.20 未接入自动时长上报。会员任务新增发放尚未验证。不能把接口成功状态当成同步成功。**

匿名、可入库结论见 [听歌验证](listening-sync-verification-2026-10-27.md)。隔离源码、脚本、构建和账号报告留在忽略目录，不提交、不上传公开仓库。

### 3. 经用户确认实施 Beta.20 五项修改

| 修改 | 最终行为与关键位置 |
| --- | --- |
| 搜索输入误触 | 键盘抬起搜索框时，外层 accessory 布局范围与内层可见输入框一致，点击不再落到背后歌曲。补丁在 `third_party/liquid_glass_widgets/package/lib/src/widgets/surfaces/tab_bar_searchable_layout.dart`，说明在同级项目的 `MESTING_PATCHES.md`。没有叠加第二次键盘位移或降低玻璃效果。 |
| 评论底栏重叠 | 歌曲评论、歌单评论及回复详情通过根 Navigator 打开，覆盖 shell 底栏与迷你播放器，返回时恢复来源页。关键文件 `lib/features/music_platform/presentation/platform_comments_page.dart`。音频所有权不变。 |
| 全局功能强调色 | 功能及选中蓝色、收藏粉色、签到完成绿色；浅深色分开调校，面板中性化。集中在 `beta_appearance.dart`、`app_theme.dart`，并覆盖导航、个人页、歌单操作、装扮选择和指南进度。封面、原创入口插画、IP 角色与正式渠道保留各自配色。 |
| 签到格重设计 | 新增 `PlatformRewardDay`，淡绿色圆角格、日期下方格内对勾，今天独立蓝边；月份进度绿色，大字单行适配。业务仍由原奖励控制器负责。 |
| 静态启动展示 | 新增 `StartupVisibilityGate`，从图片首个完整解码并绘制的帧后等待约 500ms，同时等待真实依赖完成；音频和玻璃仍并行初始化。`StartupImageSurface` 只报告呈现或加载失败，失败回退不阻塞。视频和正式渠道原契约保留。 |

用户此前确认的配色分工继续有效：功能蓝、收藏粉、完成绿、中性黑白灰。当前小字浅色蓝为 `#0066D9`、深色蓝为 `#0091FF`；收藏浅/深为 `#FF2D55` / `#FF375F`；完成浅/深为 `#007A2B` / `#30D158`。这些是结合对比度调校的应用值，**不声称是 iOS 27 的精确官方 RGB**。依据见修复记录中的 Apple 当前 HIG 链接。

### 4. 回归、构建、签名与手机覆盖安装

相关测试和静态分析已完成，Release 构建成功。69 项正式专用素材排除检查通过；两张用户原始静态 PNG 入包字节未变；双 ARM、ZIP 与 ARM64 ELF 16 KiB 对齐、10 项原生库和构建输出对应关系均已核验。

用户随后明确追加：“目前我手机是还有链接电脑的，新版本构建完之后请直接帮我安装到我的手机”。因此本轮在核验原证书一致后，通过 `adb install -r` 将日常 Beta.19 覆盖升级到 Beta.20，并正常打开。安装返回 Success，读取版本为 20，首次安装时间未变，启动后约 10 秒进程仍处前台。

**没有卸载、清数据或使用 Flutter drive。安装与启动确认不等于每项历史收藏、账号状态或全部真机交互已经验收。**

本次安装授权已经执行完毕。新会话先等待用户，不能据此无限扩大手机操作范围；原生性能测试仍只限隔离 `.beta.benchmark` 身份并强制 `--keep-app-running`。

## 三、交付文件与准确身份

以下路径均相对 `D:/AnLi`：

| 文件 | 用途 |
| --- | --- |
| `release/Mesting-Music-v1.0.37-beta.20.apk` | 已安装的最终 Release APK |
| `release/Mesting-Music-v1.0.37-beta.20-verification.json` | 包名、版本、签名、ABI、对齐、原始 PNG 和安装边界 |
| `release/Mesting-Music-v1.0.37-beta.20.apk.sha256` | APK 校验值 |
| `release/Beta.20-安装说明.txt` | 安装及更新说明 |
| `Mesting-Music-beta.20-source.zip` | 包含当时 1,053 个源码/文档文件及未提交修改的快照；不含 Git 历史、私钥、APK 或账号报告 |
| `docs/fixes-2026-10-27-beta20.md` | 本版修改、测试与交付记录 |
| `docs/version-archive/beta20-evidence/test-summary.json` | 可跨电脑保存的匿名测试摘要 |
| `.codex-artifacts/2026-10-27-ui-review/` | 本机详细日志、软件预览和包装核验脚本，Git 忽略 |
| `.codex-artifacts/2026-10-27-listening-investigation/` | 隔离听歌试验及脱敏报告，Git 忽略且不公开上传 |

- APK：74,743,132 字节（71.28 MiB），SHA-256 `F0B86C8C3FF6BE3AC0C7F88FA4572E7AB4EF118C04C7085AAA2BF6689916954D`。
- APK：`com.mesting.music.beta`，`1.0.37-beta.20` / 20，Release 非调试，minSdk 24 / targetSdk 36，ARM32 + ARM64，实际签名方案 v2。
- 原 Beta.14–19 相同证书 SHA-256：`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。不要把旧重签包的 v3 写成这次实际结果。
- 源码 ZIP：45,889,097 字节，SHA-256 `8B61C5E33903E3C7B7D9087BC2598B734D941E0405153534AE512F149B30DB99`。

**源码 ZIP 是已冻结的交付快照，本次新增的“当前会话交接”及入口链接更新晚于它，不在该 ZIP 内。APK 和 ZIP 不因交接而重建或覆盖；如需将最新说明带到另一台电脑，请另带本文及更新后的接续入口。**

## 四、测试结论及其限制

| 检查组 | 实际结果 | 边界 |
| --- | --- | --- |
| Beta 专项广泛回归 | 234 通过，0 失败 | 早于最后的启动失败回退和指南进度小改；后两组补验对应路径 |
| 启动、评论、奖励等最终相关回归 | 57 通过，0 失败 | 含新启动回退和 Beta.20 专项 |
| 最终指南与 Beta.20 专项 | 24 通过，0 失败 | 最后运行代码修改后的补验 |
| 正式渠道全量 | 741 通过、94 跳过、3 个既有失败 | 未声称全绿；正式运行行为未被最终 Beta 小改改变 |
| 最终静态分析 | `No issues found` | 不替代真机交互 |
| 实际手机 | 覆盖安装、版本读取和正常启动确认通过 | 未完成全部 IME、手势、GPU、后台音频或用户数据验收 |

测试组有重叠，不能把通过数相加。正式渠道三个失败与 Beta.19 记录一致：

1. `editing menu leaves its gap outside the complete multiline field`。
2. `rose colors are limited to declared brand and heart roles`（旧队列删除背景色规则）。
3. `follower removal sheet stays above the persistent player`（既有夹具/层级问题）。

本次没有重新测 Beta.20 的 FPS、进程 CPU 或启动基准，不使用 Beta.19 的性能数字冒充新测量。`am start -W` 只是一次正常启动确认，不作为完整性能结论。

## 五、构建环境与继续修改时的注意事项

- 独立 Flutter `D:/CodexCache/flutter-3.41.9`，Flutter 3.41.9 / Dart 3.11.5。
- 本机 JDK 17.0.20.1，实际目录从 `D:/CodexCache/android-build/jdk-home.txt` 读取。Java/Kotlin 编译目标为 17；另一台电脑此前的 JBR 21 也有历史验证。
- Android SDK `D:/CodexCache/android-build/sdk`，NDK 28.2.13676358；Gradle 缓存 `D:/CodexCache/android-build/gradle`。
- 构建时仅在当前进程设置环境：`APPDATA=D:/CodexCache/android-build/flutter-config`、上述 `JAVA_HOME`、`ANDROID_HOME`、`ANDROID_SDK_ROOT`、`GRADLE_USER_HOME`，不修改全局配置。
- `pubspec.lock` 仍为 `3F2DC18A71A59324ADF202E8EFE43E2F712B23A16E743B772AF0EC10748B4957`，不要顺手升级依赖。
- `pubspec.yaml` 的 `1.0.37+58` 是正式渠道共享版本，不改它；`tool/build_android_md3_beta_apk.ps1` 当前默认覆盖为 Beta.20 / 20。
- Release 构建不要传 `--no-pub`，Flutter 3.41 的测试插件注册残留可能使构建失败；用现有构建脚本执行资源暂存和依赖锁检查。
- 本机的默认签名证书恰好与交付原 Beta 证书一致；换电脑的默认 debug 密钥不能自动等同。只通过私有方式转移原密钥并核对证书，绝不提交私钥、密码或 `key.properties`。
- 必须保留完整 premium 模糊、折射、形变、回弹和胶囊开合，不通过降质或平面替代来修复性能。
- 新需求/新 bug 按 `AGENTS.md` 一次只问一个问题，明确目标、方案确认后实施；不要重新确认已经明确接受的产品配色和行为。
- 早先验证码问题已由用户确认是当天手机号获取次数过多，换手机号可正常登录，不要把旧图当成待修接口故障。

需要重新构建时，在用户有新工作指示后参考：

```powershell
./tool/build_android_md3_beta_apk.ps1 -FlutterSdkRoot 'D:/CodexCache/flutter-3.41.9'
```

## 六、未完成或后续可处理的事项

| 事项 | 当前结论 | 下一步条件 |
| --- | --- | --- |
| Beta.20 五项代码修改、构建与安装 | 已完成 | 等待用户真实使用反馈，不能自称所有真机交互已验收 |
| Beta.20 Git 提交、标签与 GitHub 归档 | **未做** | 等用户明确要求；随后只暂存已审查文件，补齐更新说明与校验，保留历史标签/Release |
| 酷狗累计及当天时长同步 | **未验证可用，未接入** | 仅在用户要求继续调查时开展新的有界试验；旧 75 秒测量不能重发，不能伪造或刷时长 |
| 听歌会员新增任务认可 | **未完成真实新增验证** | 当前账号当天已领取；需要用户授权合适的新条件，不能据 130012 承诺新增权益 |
| 正式渠道三个旧测试失败 | 未修复，已记录 | 当前范围以外；若用户要求再独立排查，不混称 Beta.20 新回归 |
| 全量手机体验、TalkBack、不同 IME、GPU/CPU 性能 | 未认证 | 用户反馈或明确授权后的隔离验证 |
| 隔离测试包/临时副本清理 | 未做 | 有意保留；不能擅自卸载设备包或删除可恢复的本地证据 |

**当前没有需要新会话立即自动实施的任务。先完成只读接续，等用户下一步指示。**

## 七、新会话阅读与只读核对顺序

1. 本文、`AGENTS.md`。
2. `docs/CONTINUE-BETA.md`、`docs/SESSION-HANDOFF-2026-10-27-BETA20.md`。
3. `docs/fixes-2026-10-27-beta20.md`、`docs/listening-sync-verification-2026-10-27.md`。
4. `docs/fixes-2026-10-27-beta19.md`、`BETA_ARCHIVE.md`，按冻结历史理解。
5. 如需继续实现，再读 `DESIGN.md`、`PRODUCT.md` 和相关代码，先遵守确认流程。

允许的初始检查示例：

```powershell
git status --short --branch
git log -1 --oneline
git describe --tags --exact-match HEAD
git diff --stat
Get-FileHash -Algorithm SHA256 -LiteralPath 'release/Mesting-Music-v1.0.37-beta.20.apk'
Get-FileHash -Algorithm SHA256 -LiteralPath 'Mesting-Music-beta.20-source.zip'
```

不要自动 `git add -A`、stash、reset、clean、切分支、拉取覆盖、构建、安装、重签、修改版本号、创建标签或 Release。不要读取密钥内容或账户私有存储，不把忽略目录当成可以随意删除的缓存。后续提交时，APK/源码 ZIP 不进入 Git，脱敏研究总结可以入库，隔离账号报告不可以。
