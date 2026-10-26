# 在另一台电脑继续 Beta 开发

更新日期：2026-10-27（Asia/Shanghai）。当前版本：**1.0.37-beta.19 / 19**。
仓库：[Mesting42/mesting-music-flutter](https://github.com/Mesting42/mesting-music-flutter)。
开发分支：`beta`；固定标签：`v1.0.37-beta.19`。

## 先取得正确源码

建议使用新目录，保留另一台电脑已有的旧版本和未提交修改：

```powershell
git clone --branch beta https://github.com/Mesting42/mesting-music-flutter.git Mesting-Music-beta
cd Mesting-Music-beta
git status --short --branch
git log -1 --oneline
git describe --tags --exact-match HEAD
```

本次归档后应为 Beta.19。已有干净的 `beta` 克隆可执行：

```powershell
git fetch origin --tags
git switch beta
git pull --ff-only origin beta
```

存在未提交修改时先保存自己的工作，再合并处理；不要强制 reset、清理或覆盖旧目录。
固定查看本次版本可从 `v1.0.37-beta.19` 创建新分支。
Beta.1–19 的来源、标签和 APK 入口在 [版本归档](../BETA_ARCHIVE.md)。
Beta.1–13 是原交付源码的补档链，Beta.14–17 旧历史未改写；日常最新线为
Beta.17 → Beta.18 → Beta.19。

## 阅读顺序与当前状态

1. [Beta.19 修改与验证边界](fixes-2026-10-27-beta19.md)。
2. [Beta.19 详细接续记录](SESSION-HANDOFF-2026-10-27-BETA19.md)。
3. 根目录 `AGENTS.md`、`DESIGN.md`、`PRODUCT.md`；新需求继续一次只问一个问题，
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
- 实际交付使用 Android Studio JBR **21.0.10**；Java/Kotlin 编译目标为 17。
- Android SDK compile/target **36**，NDK **28.2.13676358**，项目 minSdk **24**。
- `pubspec.lock` 保持：
  `3F2DC18A71A59324ADF202E8EFE43E2F712B23A16E743B772AF0EC10748B4957`。
- Gradle wrapper 脚本和 JAR 已包含。SDK、JDK、`local.properties`、本机缓存和私钥需
  在新电脑自行配置；不要照搬旧电脑的绝对路径。

将新电脑实际 Flutter 目录代入：

```powershell
$betaFlutter = 'D:/你的Flutter目录/flutter/bin/flutter.bat'
& $betaFlutter --version
& $betaFlutter pub get --enforce-lockfile
& $betaFlutter analyze --no-pub
& $betaFlutter test --no-pub --flavor beta test/beta18_refinements_test.dart test/beta19_refinements_test.dart
```

正式渠道素材检查必须带 `--flavor stable`。最终 Beta 回归 287 项通过；正式渠道
734 项通过、91 项跳过、3 项既有失败（文本编辑菜单间距、旧队列颜色、关注者移除
sheet 层级），不是本次新增回归。便携证据摘要位于 `docs/version-archive/beta19-evidence/`。

## 构建、签名与下载

```powershell
./tool/build_android_md3_beta_apk.ps1 -FlutterSdkRoot 'D:/你的Flutter目录/flutter'
```

默认构建 `1.0.37-beta.19` / 19，单 APK 包含 ARM32 与 ARM64，关闭线上更新检查。
脚本执行资源暂存清理、69 项正式专用素材排除检查和依赖锁校验。
`pubspec.yaml` 中的 `1.0.37+58` 是共享正式版本配置；Beta 由构建脚本覆盖版本号，
不要为继续 Beta 擅自改动正式版本配置。

源码默认使用机器自己的 debug 签名；它不等于交付包使用的原 Beta 签名。
后续需要覆盖现有 Beta.19 时，应通过私有方式转移原 Beta.14–19 密钥，并检查最终
证书 SHA-256：
`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。
私钥、密码、`key.properties` 均未上传 Git 或 Release。

[已签名 Beta.19 APK 与原始源码包](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.19)。
APK 为 74,768,283 字节（71.30 MiB），SHA-256：
`115B14AF1C0CD6F7E464E5F8A759511F5BE0308D078A0E94E38A4E6E04CAB745`。
归档不修改稳定版/Java 测试通道的更新清单。
