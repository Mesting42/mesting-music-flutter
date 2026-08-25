# Mesting Music 发布与源码记录

最后核对：2026-08-26（北京时间）。本文件记录 Android 发布版本、源码标签和更新通道的对应关系；APK 本体不提交进 Git。

## 更新通道

| 通道 | Android 包名 | 更新清单 | 当前记录 | 用途 |
| --- | --- | --- | --- | --- |
| 正式稳定版 | `com.mesting.music` | `releases/android/latest.json` | `1.0.37+42` | 面向稳定用户的 CloudBase 更新包 |
| Java + MySQL 测试版 | `com.mesting.music.javatest` | `releases/android/java-mysql-test/latest.json` | `1.0.38+40` | 仅供主动安装的集成测试者 |
| UI 实验 Beta | `com.mesting.music.beta` | `releases/android/beta/latest.json` | 独立维护 | 不参与正式版发布 |

三条清单、包名、构建脚本和 APK 路径必须独立维护。稳定包不读取或覆盖 Java + MySQL 测试通道、UI Beta 的任何 `latest.json`。

## 版本里程碑

| 版本或节点 | 状态 | 记录说明 |
| --- | --- | --- |
| `1.0.37+38` | 历史稳定 APK | 已保留 GitHub Release 标签 `flutter-music-v1.0.37`；当时完整开发目录尚未纳入 Git，因此该标签不是逐文件源码快照。 |
| `1.0.38+39` | 历史源码快照 | GitHub `main` 的 `flutter-music-v1.0.38-source` 标签，保留 Java/MySQL 迁移测试源码状态。 |
| `e89b878` | 本地正式基线 | 2026-08-05 在本机建立的 `checkpoint-before-my-likes-redesign`，用于隔离正式修改；它原先没有远程仓库绑定。 |
| `1.0.37+40` | 稳定通道恢复 | 恢复 1.37 稳定包，并在设置中显式提供 Java + MySQL 测试下载入口。 |
| `1.0.37+41` | 稳定体验更新 | 加入封面与好友头像缓存、图片失败重试，以及消息和个人资料页面过渡优化。 |
| `1.0.37+42` | 当前稳定发布 | 加入用户协议、隐私政策，并在稳定 CloudBase 通道发布。源码标签为 `flutter-music-v1.0.37-build42`。 |

## Git 历史补全方式

GitHub 原有 `main` 只包含 `1.0.38+39` 的三次公开提交。本地正式基线和其后的功能提交原本没有远程地址，因此无法显示在 GitHub 历史中。

补全时使用一个仅记录来源关系的桥接提交，把本地正式基线链接到现有 GitHub 源码快照；随后按原有顺序保留每一项功能提交。这个过程不重写旧 GitHub 提交、不强制推送，也不把本机调试截图或 APK 二进制文件提交到仓库。

## Java + MySQL 测试版限制

Java + MySQL 仍是 HTTP 集成测试路径，尚未完成正式 HTTPS、历史头像跨设备迁移、社交与一起听双账号真机回归、自动异机灾备等生产化工作。详细限制和测试发布步骤见 [java-mysql-test-channel.md](java-mysql-test-channel.md)。
