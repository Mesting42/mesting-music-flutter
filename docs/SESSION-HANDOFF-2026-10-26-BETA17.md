# Beta.17 接续开发指南

日期：2026-10-26（Asia/Shanghai）。版本：**Mesting Music 1.0.37-beta.17 / versionCode 17**。

## 从哪里开始

- 仓库：[Mesting42/mesting-music-flutter](https://github.com/Mesting42/mesting-music-flutter)。
- 日常 Beta 开发分支：`beta`。本版固定标签：`v1.0.37-beta.17`。
- `main` 仍是原来的正式版分支；本轮不合并或覆盖它。
- [本版更新说明](fixes-2026-10-26-beta17.md)、[更新日志](../CHANGELOG.md)、[旧版本归档](../BETA_ARCHIVE.md)。
- [Beta.17 安装包及校验文件](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.17)。APK 保存在 Release，不放进 Git 源码对象。

在另一台电脑**新建目录**接续，保留那台电脑尚未归档的旧版目录：

```powershell
git clone --branch beta https://github.com/Mesting42/mesting-music-flutter.git Mesting-Music-beta17
cd Mesting-Music-beta17
git status --short --branch
git log -1 --oneline
git describe --tags --exact-match HEAD
```

本次发布时，`beta` 与 `v1.0.37-beta.17` 指向同一提交。若以后 `beta` 已前进，仍可从固定标签继续本版：

```powershell
git switch -c codex/continue-beta17 v1.0.37-beta.17
```

如使用已有的 Git 克隆，先检查 `git status`。只有工作区干净时再获取并快进 `beta`；不要对另一台电脑的旧源码执行强制覆盖、清理或重置。

## 本版已经完成什么

1. 菜单：将透明度动画移到前景内容，玻璃直接参与场景合成，保留 premium 材质、尺寸伸展及 400ms / 240ms 开合。音质和设备卡片也使用避免整块玻璃淡入淡出的公共对话框。
2. 播放队列：左侧随机播放、右侧循环；增加操作结果 HUD，区分顺序、随机、列表循环和单曲循环图标，并同步底部角标与辅助功能状态。
3. 签到与会员：接入原版两步签到、自动签到开关、听歌领取、广告领取、安全验证、日历和会员到期时间。入口为“我的 → 签到与会员”，使用当前酷狗账号。
4. 设备卡片：先展示应用内玻璃卡片、歌曲、真实设备名称和系统音量，点击切换后由 Android 系统面板完成实际传输。
5. 构建：修正测试后 Release 插件注册文件残留测试插件的问题，保持依赖锁校验。

## 主要代码职责

| 文件 | 职责 |
| --- | --- |
| `lib/shared/widgets/beta_glass_popover.dart` | 共同玻璃表面、菜单开合和对话框合成路径 |
| `lib/features/experience/presentation/player_queue_panel.dart` | 队列控件、模式图标与结果提示 |
| `lib/features/experience/presentation/player_toolbar_glyphs.dart` | 底部三个矢量工具图标和模式角标 |
| `lib/features/experience/presentation/player_output_dialog.dart` | 设备卡片；复用现有音频路由和媒体音量控制器 |
| `lib/features/music_platform/domain/platform_rewards.dart` | 领取结果、打卡日期与会员数据解析 |
| `lib/features/music_platform/data/platform_rewards_repository.dart` | youth / verify 接口协议与平台结果判断 |
| `lib/features/music_platform/platform_rewards_provider.dart` | 账号隔离、自动签到、并发保护、广告间隔和取消 |
| `lib/features/music_platform/presentation/platform_reward_calendar.dart` | 日历、手动入口、开关及会员展示 |
| `lib/features/music_platform/presentation/platform_reward_verification.dart` | 腾讯验证 WebView、取消和超时 |
| `tool/build_android_md3_beta_apk.ps1` | Beta Release 构建与依赖锁一致性检查 |

沿用 md3Music 提交 `a69503b84e8829f888684f67c163be03c589c014` 的业务协议；来源和许可记录在 `third_party/md3music/NOTICE.md`。现有 Rust 二进制、账号仓库和唯一音频 owner 没有替换。

## 新电脑的环境与构建

- 已交付环境：Flutter **3.41.9** / Dart **3.11.5**、JDK **17**、Android SDK（target / compile 36）、NDK **28.2.13676358**。
- 使用与正式版可独立配置的 Flutter SDK；`local.properties`、SDK 安装目录及本机缓存不在 Git 中，需要在新电脑配置。
- 依赖锁 SHA-256：`3F2DC18A71A59324ADF202E8EFE43E2F712B23A16E743B772AF0EC10748B4957`。
- 仅新增 `webview_flutter 4.10.0` 及其三个平台依赖，未升级原有包。

将正确的 SDK 配到当前终端后执行：

```powershell
flutter --version
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub --flavor beta test/platform_rewards_repository_test.dart test/platform_rewards_controller_test.dart test/beta17_player_ui_test.dart test/beta_glass_popover_test.dart
.\tool\build_android_md3_beta_apk.ps1
```

脚本也支持 `-FlutterSdkRoot` 指定新电脑实际的 Beta SDK 目录。不要照搬原电脑 `D:\CodexCache` 的绝对路径，或改动正式版的全局 SDK 来凑构建。

输出是 `build/app/outputs/flutter-apk/app-beta-release.apk`。默认包名 `com.mesting.music.beta`、版本 `1.0.37-beta.17` / 17，关闭线上更新检查。
不要给脚本重新加 `--no-pub`：Flutter 3.41 在该模式下会跳过平台注册文件重新生成，测试后的开发插件引用可能残留。脚本让 Flutter 按 Release 模式生成，并检查依赖锁未漂移。

## 签名与已经验证的范围

- 已发布 APK：91,089,923 字节（86.87 MiB）。SHA-256：`31624C0BDD4C3B9E1F94DFB15C195FD8E4DE4B14957D5BB7E4D3F91EE87D3566`。
- Beta.14–17 使用同一本机调试签名证书，SHA-256：`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。
- **源码不包含签名私钥。** 若新电脑构建后要继续覆盖现有安装，另行安全转移原电脑用户目录中的 `.android/debug.keystore`；不要提交到 Git 或上传 Release。新生成的调试密钥不具有相同签名。
- Beta 回归 **223 项通过**，正式共用导航 **6 项通过**，分析无问题；中文渲染 **9 项通过**，12 张确认截图。APK 的 v2 签名、16 KiB 对齐、原生库与新增验证组件已核验。
- 本轮没有连接手机。菜单黑块是否在原机完全消失、真实验证码/奖励资格、耳机切换和覆盖安装数据保留仍需真机验收。不要把宿主截图或模拟请求当作已完成的真机结果。

原电脑的完整日志、截图和临时备份位于 `.codex-artifacts/`、`.codex-backups/`，这两个目录没有上传。
Git 内保存测试源码、核验摘要、修改记录和源码哈希清单；新电脑可据此重新运行检查，不应假定原电脑的临时文件路径在新电脑存在。

## 给下一轮开发的约定

先阅读本文件、修改记录和根目录 `AGENTS.md`，只读核对 Git 分支、提交、标签和工作区；保留另一台电脑尚未归档的旧版本。
新需求或 bug 一次只问一个问题，理解后给出方案，用户确认后实施；注释说明职责和重要约束，继续分离业务、状态与视觉。

Beta.13 及更早版本可以稍后从原电脑资料补充归档，不改写现有 Beta.14–17 标签。
