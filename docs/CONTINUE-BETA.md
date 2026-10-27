# Mesting Music 正式版接续

**2026-10-28 当前指针：1.0.4 / code 25 已发布到 music 后台；先读 [1.0.4 交接](SESSION-HANDOFF-2026-10-28-v1.0.4.md) 与 [修改记录](fixes-2026-10-28-v1.0.4.md)。SDK 已接入更新下载，1.0.3 原包/快照保持冻结。GitHub 尚未同步本轮，远端 beta / v1.0.2 仍为旧 1.0.2。本地工作分支 codex/release-1.0.4；完整源码另存 Mesting-Music-v1.0.4-private-source.zip，包含 SDK，只通过私有方式接续，不直接公开上传。**

## 以下为 1.0.2 冻结归档的接续记录

下方 GitHub 命令和 1.0.2 摘要只用于取得旧的已归档基线，不能取得尚未推送的 1.0.3/1.0.4 工作区。当前功能、SDK、构建及验证边界以上方最新交接为准。

**2026-10-27 最新指针：正式版 1.0.2 / code 23 已发布到 music。先读 [1.0.2 完整交接](SESSION-HANDOFF-2026-10-27-v1.0.2.md) 和 [本轮修改](fixes-2026-10-27-v1.0.2.md)；内部 beta 名称只作包名/签名兼容，不代表公开测试版。1.0.1 及更早记录属于各自冻结交付。**

**新会话先读 [Git/GitHub 最新补档记录](version-archive/RELEASE-BACKFILL-2026-10-27.md) 和 [当前完整产品交接](SESSION-HANDOFF-2026-10-27-v1.0.2.md)，只读核对后等待用户指示。** [1.0.1 会话交接](SESSION-HANDOFF-2026-10-27-CURRENT-v1.0.1.md)、[1.0.1 交付记录](SESSION-HANDOFF-2026-10-27-v1.0.1.md) 与 [Beta.20 会话记录](SESSION-HANDOFF-2026-10-27-CURRENT-SESSION.md) 分别保留。

更新日期：2026-10-27（Asia/Shanghai）。当前交付为 **1.0.2 / 23**，保留内部 beta 包名和原签名；线上生产更新代码已完成旧版发现、真实 HTTPS 下载、暂停续传和 SHA-256 核验。后续经用户确认，已将 Beta.20/21/1.0.1/1.0.2 分别归档到 Git/GitHub，`beta` 当前指向 **v1.0.2**；原 `main` 和旧标签未变。本次补档没有访问手机或安装。

**下方 GitHub 命令可取得 1.0.2 当前维护源码。原始交付快照为 Release 附件 `Mesting-Music-v1.0.2-source.zip`；标签在它的基础上增加本次归档文档，运行源码保持一致。**
仓库：[Mesting42/mesting-music-flutter](https://github.com/Mesting42/mesting-music-flutter)。
开发分支：`beta`；当前固定标签：`v1.0.2`。

## 先取得正确源码

建议使用新目录，保留另一台电脑已有的旧版本和未提交修改：

```powershell
git clone --branch beta https://github.com/Mesting42/mesting-music-flutter.git Mesting-Music-beta
cd Mesting-Music-beta
git status --short --branch
git log -1 --oneline
git describe --tags --exact-match HEAD
```

本次归档后应为 `v1.0.2`。已有干净的 `beta` 克隆可执行：

```powershell
git fetch origin --tags
git switch beta
git pull --ff-only origin beta
```

存在未提交修改时先保存自己的工作，再合并处理；不要强制 reset、清理或覆盖旧目录。
固定查看本次版本可从 `v1.0.2` 创建新分支。
Beta.1–21 和正式 1.0.1/1.0.2 的来源、标签和 APK 入口在 [版本归档](../BETA_ARCHIVE.md)。
Beta.1–13 是原交付源码的补档链，Beta.14–17 旧历史未改写；日常最新线为
Beta.17 → Beta.18 → Beta.19 → Beta.20 → Beta.21 → 1.0.1 → 1.0.2。

## 阅读顺序与当前状态

1. [最新 Git/GitHub 补档记录](version-archive/RELEASE-BACKFILL-2026-10-27.md)。
2. [1.0.2 详细产品交接](SESSION-HANDOFF-2026-10-27-v1.0.2.md)。
3. 本机 1.0.2 先读 [本轮修改](fixes-2026-10-27-v1.0.2.md) 和 [交接](SESSION-HANDOFF-2026-10-27-v1.0.2.md)，必要时对照 [1.0.1 修改](fixes-2026-10-27-v1.0.1.md)、[Beta.21 修改](fixes-2026-10-27-beta21.md) 与 [Beta.20 修改](fixes-2026-10-27-beta20.md)，再读根目录 `AGENTS.md`、`DESIGN.md`、`PRODUCT.md`；新需求继续一次只问一个问题，
   理解后给出方案、经用户确认再实施。
4. 必要时查看 [Beta.18 记录](fixes-2026-10-26-beta18.md) 和对应旧标签。

最新运行代码完整保留玻璃的模糊、折射、形变、回弹及胶囊开合，不以降低效果替代
性能修复。已加入两张原始静态启动图、首次升级图一的一次性迁移，以及小新七种
独立持久化天气；Beta 的 Mesting 登录入口和正式专用入包素材已移除。

用户已要求后续自行真机测试并断开手机。没有新的明确授权时，不运行 ADB、不安装、
重启或访问手机。历史测试发生过 Flutter drive 默认清理卸载日常应用的事件，
原数据保留未认证，详见修复记录。后续原生测试工具仅允许独立 `.beta.benchmark`
身份并强制 `--keep-app-running`。

## 新电脑环境

- 独立 Flutter **3.41.9** / Dart **3.11.5**；避免改动正式项目的全局 SDK。
- Beta.19 使用 Android Studio JBR **21.0.10**；本机 Beta.20/21/1.0.1/1.0.2 使用 JDK **17.0.20.1**。Java/Kotlin 编译目标为 17。
- Android SDK compile/target **36**，NDK **28.2.13676358**，项目 minSdk **24**。
- 1.0.2 的 `pubspec.lock`：
  `F6C3536F458E6641F2FD0AE68042B0697F0E845D105D6BD4ECA3A328E2BA40D4`。
  仅将 just_audio 0.10.6 切换到仓库内同版本补丁；不沿用 1.0.1 的旧锁摘要。
- Gradle wrapper 脚本和 JAR 已包含。SDK、JDK、`local.properties`、本机缓存和私钥需
  在新电脑自行配置；不要照搬旧电脑的绝对路径。

将新电脑实际 Flutter 目录代入：

```powershell
$betaFlutter = 'D:/你的Flutter目录/flutter/bin/flutter.bat'
& $betaFlutter --version
& $betaFlutter pub get --enforce-lockfile
& $betaFlutter analyze --no-pub
& $betaFlutter test --no-pub --flavor beta test/release_101_ui_test.dart test/csnas_app_update_test.dart test/beta10_entry_test.dart
```

正式渠道素材检查必须带 `--flavor stable`。**以下为 Beta.19 历史结果**：Beta 回归 287 项通过；正式渠道
734 项通过、91 项跳过、3 项既有失败（文本编辑菜单间距、旧队列颜色、关注者移除
sheet 层级），不是本次新增回归。便携证据摘要位于 `docs/version-archive/beta19-evidence/`。

**历史 Beta.21**：早期 Beta 定向回归 266 通过，最终入口/本轮功能 22 通过，静态分析无问题；组间有重叠。正式渠道全量 732 通过、113 条件跳过、2 既有失败（文本编辑菜单间距、关注者移除 sheet），没有新增失败。最新便携摘要在 `docs/version-archive/beta21-evidence/`；主机截图不等于真机验收。

**历史 1.0.1**：广泛 Beta 回归 268 通过，最终受影响回归 29 通过，各组重叠；正式完整回归 740 通过、117 条件跳过、2 项既有失败，无新增失败。最终静态分析无问题。便携摘要在 `docs/version-archive/v1.0.1-evidence/`。

**当前 1.0.2**：受影响回归 148 通过；生产原生注册器主机断言 23 通过；Android 编译及静态分析通过。旧 stable 配置全量为 741 通过、121 跳过、6 失败，额外四项随后隔离重测全部通过，保留两项历史问题；不宣称全量全绿。20 张控件捕获与独立复核完成；公开主/备下载入口的 HEAD、Range 均匹配本版，主入口生产仓库完整下载、续传及摘要通过。便携摘要在 `docs/version-archive/v1.0.2-evidence/`；主机与线上结果不等于手机安装或真实蓝牙验收。

## 构建、签名与下载

```powershell
./tool/build_android_release_apk.ps1 -FlutterSdkRoot 'D:/你的Flutter目录/flutter'
```

当前正式入口默认构建 `1.0.2` / 23，内部沿用兼容 flavor；单 APK 包含 ARM32 与 ARM64，开启 music HTTPS 更新检查。1.0.1 可应用内升级；更早没有更新功能的版本需手动覆盖安装。
脚本执行资源暂存清理、69 项正式专用素材排除检查和依赖锁校验。
`pubspec.yaml` 中的 `1.0.37+58` 是共享旧 stable 配置；当前兼容 flavor 由正式构建入口覆盖版本号，
不要通过切换旧 stable 界面或改包名来移除公开文案中的 Beta。

源码默认使用机器自己的 debug 签名；新电脑生成的密钥不等于交付包使用的原 Beta 签名。
后续需要覆盖现有 1.0.1/1.0.2 时，应通过私有方式转移同一原签名，并检查最终
证书 SHA-256：
`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。
私钥、密码、`key.properties` 均未上传 Git 或 Release。

当前 [music 公开下载](https://download.csnas.asia/music/download) 为 1.0.2 / 23；文件 76,231,470 字节，SHA-256：
`DF7E73F597890F3C868BF53E34E22C712A1E1D2CBD114651A2B7CBEED73F7263`。
后续正式发布按 [更新发布步骤](RELEASE-UPDATE-GUIDE.md)，下一版 code 至少 24。

[历史 Beta.19 APK 与原始源码包](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.19)。
APK 为 74,768,283 字节（71.30 MiB），SHA-256：
`115B14AF1C0CD6F7E464E5F8A759511F5BE0308D078A0E94E38A4E6E04CAB745`。
归档不修改稳定版/Java 测试通道的更新清单。
