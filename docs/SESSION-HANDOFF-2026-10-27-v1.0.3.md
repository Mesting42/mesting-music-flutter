# Mesting Music 正式版 1.0.3 交付与接续

2026-10-27（Asia/Shanghai）。**1.0.3 / code 24 已发布到现有 music 后台**，公开 health 与本地原签名 APK 一致。修改范围见 [本版修改](fixes-2026-10-27-v1.0.3.md)。新会话不得把历史方案当作待办；本版之后用户另行确认 P8P SDK 接入为 **1.0.4 / code 25**，验证后同后台正式发布。

## 本版交付

| 项目 | 核验值 |
| --- | --- |
| 公开版本 / 实际 code | 1.0.3 / 24 |
| 名称 / 包名 | Mesting Music / `com.mesting.music.beta` |
| APK | `release/Mesting-Music-v1.0.3.apk` |
| 字节数 | 76,890,535（73.33 MiB） |
| SHA-256 | `A3003191040051B30A14AF4938BB9D4CFCAF857A1B8E3A6B9F4558944885A4BA` |
| 原签名证书 SHA-256 | `8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333` |
| 签名与 ABI | APK v2/v3；ARM32 + ARM64；Release 非 debuggable |
| 源码快照 | 根目录 `Mesting-Music-v1.0.3-source.zip` |
| 核验记录 | `release/Mesting-Music-v1.0.3-verification.json` 及 `.apk.sha256` |

最终签名包的 523 个非签名 ZIP 条目与构建输出逐字节一致。ZIP 支持 16KiB 对齐，ARM64 ELF 16KiB、ARM32 ELF 4KiB 对齐；69 项旧 stable 专用素材继续排除。私钥和密码只在本机内存用于签名，不进入源码、归档或发布后台。

本版仍使用独立 Flutter 3.41.9 / Dart 3.11.5、Android Studio JBR 21（Java/Kotlin target 17）、SDK 36、NDK 28.2.13676358、minSdk 24。`pubspec.lock` SHA-256 与 1.0.2 相同：`F6C3536F458E6641F2FD0AE68042B0697F0E845D105D6BD4ECA3A328E2BA40D4`。正式构建脚本默认 1.0.3/24，必须沿用 beta flavor 及原签名，不切换到旧 stable UI。

## 线上结果

- [公开 health](https://download.csnas.asia/api/app/music/health) 返回 1.0.3 / 24、76,890,535 字节及相同 SHA-256。服务端创建时间原文为 `2026-10-27T23:32:01.890171`，不额外推定其时区。
- [公开下载](https://download.csnas.asia/music/download) 由生产 `CsnasUpdateReleaseSource` 和 `AppUpdateRepository` 真实访问。模拟已安装 1.0.2 / 23，发现 1.0.3 / 24，下载到 1,048,576 字节暂停，使用 `Range: bytes=1048576-` 续传至完整包，大小及 SHA-256 通过。
- 模拟已安装 1.0.3 / 24 时不再提示同版本更新。没有唤起安装器，也没有访问手机。
- 应用内更新仍为前台自动检查与“设置 → 版本更新”；保留原 15 分钟检查节流及稍后提醒行为。后台发布不等于新增系统推送通知服务。

便携证据在 `docs/version-archive/v1.0.3-evidence/`；主机原始日志、界面捕获和实际下载文件在被忽略的 `.codex-artifacts/2026-10-27-release103/`。后台账号、私钥和真实账号报告不归档。

## 测试边界

广泛 Beta 回归 122 通过，最终 UI/6dp 拖动 22 通过，旧 stable 选定兼容 18 通过，静态分析无问题，原生输出注册器 23 断言通过，完整 Android Release 构建通过。各组有界，重跑不重复计数；本轮没有重跑旧 stable 全量历史套件。

29 张生产控件主机捕获覆盖浅深色、窄屏大字和宽屏，独立 finish review 为 SHIP。夹具采用合成资料、目录、MV 画面与不入包的 Windows QA 字体，不能替代真实账号写入、实际音频/视频、GPU、IME/TalkBack、系统安装权限或保留数据覆盖安装。用户已要求自行真机测试并断开 USB；没有新的明确授权，不运行 ADB、不访问手机。

## Git 与后续 SDK

本版工作分支 `codex/release-1.0.3` 基于 `v1.0.2` / `95d5719829a754978ba615a873aa6ddff08f67f6`。本轮没有 Git commit/tag/push 或 GitHub Release；旧 GitHub 最新指针仍为 1.0.2，music 后台发布与 Git 归档是不同状态。不要覆盖旧版本冻结 APK/源码 ZIP，不在脏工作区 reset/clean。

用户已经确认在本版发布后继续接入 `Music-P8P-SDK-交接包-20261027.zip`，下一版使用 1.0.4 / code 25。补丁基于同一 1.0.2，须保留本版所有新功能做三方合并。SDK 仅用于更新下载，`appId: music`、P2P/P8P 开启、`allowSharing: false`；发现更新仍是现有 health，大小/SHA/真实 code/安装身份校验继续保留。音乐播放不经过 SDK。

交接包及 SDK 原始文件均保存在仓库外，SDK 许可不因本机集成而自动成为可公开上传的源码许可。本版快照不包含 SDK；后续源码快照如包含 SDK 必须保持私有，不盲目推送 GitHub。
