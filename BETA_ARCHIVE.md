# Mesting Music Beta 版本归档

归档日期：2026-10-26（Asia/Shanghai）。当前快照：**1.0.37-beta.16**。
本分支用于保存这台电脑交付的 Beta 版本；现有正式版 `main`、旧标签和旧 Release 保留。

| 版本 | 源码标签 | 已交付安装包 |
| --- | --- | --- |
| Beta.14 | [`v1.0.37-beta.14`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.14) | [APK / 校验值 / 安装说明](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.14) |
| Beta.15 | [`v1.0.37-beta.15`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.15) | [APK / 校验值 / 安装说明](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.15) |
| Beta.16 | [`v1.0.37-beta.16`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.16) | [APK / 校验值 / 安装说明](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.16) |

## 快照来源

- Beta.14：根据实施 Beta.15 前的完整模块备份还原；本轮 17 个修改文件与当时打包记录的 SHA-256 一致。
- Beta.15：根据实施 Beta.16 前的 640 文件备份还原；备份清单逐项核验，本轮 35 个修改文件与打包记录一致。
- Beta.16：直接保存当前工作目录的源码；本轮 29 个新增或修改文件与最终打包记录一致。

这些提交创建于此次归档，不是补造过去的开发提交日期。备份未覆盖的未改动文件沿用当前解压项目，
因此对历史快照的证明范围是备份和已有哈希记录，不宣称有原始历史 Git 提交或可逐字节复现 APK。
Beta.13 及更早版本的独立 Git 快照将在另一台电脑的原始版本补齐后再归档；当前源码自然包含继承的旧功能。

`docs/version-archive/` 保存各版本源码的路径、字节数和 SHA-256，以及当次修改文件的原始清单。
完整清单不包含该目录本身，避免自引用。三个版本分别使用自己的构建脚本默认版本号。
`pubspec.lock` 未升级，SHA-256 为 `D836F76F4FD5179AFE2BC49089B496D202934759737FB9ECB37943D2B5FA9D57`。

## 查看或继续某个版本

```powershell
git fetch origin --tags
# 在旁边目录查看旧版，保留当前目录的开发状态。
git worktree add ..\AnLi-beta14 v1.0.37-beta.14
# 如需从旧版继续修改，在该目录创建新分支。
git -C ..\AnLi-beta14 switch -c codex/continue-beta14
```

Git 标签用于恢复源码。安装旧 APK 还受 Android 的 versionCode 降级限制，不等同于直接覆盖升级。

## 构建环境与签名

交付使用 Flutter 3.41.9 / Dart 3.11.5、JDK 17、Android SDK 和 NDK `28.2.13676358`。
配置本机 Flutter 和 Android SDK 后执行：

```powershell
flutter pub get
.\tool\build_android_md3_beta_apk.ps1 -VersionName '1.0.37-beta.16' -VersionCode 16
```

脚本支持 `-FlutterSdkRoot`，具体过程见脚本注释。三个版本保持包名 `com.mesting.music.beta`，
构建时关闭线上更新检查。原来已构建的 APK 作为 Release 附件保存，APK 不进入 Git 源码对象。

这台电脑交付的三个 APK 使用同一本机调试签名证书，证书 SHA-256：
`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。
签名私钥和 `local.properties` 不在仓库；在新电脑生成另一把调试密钥，不能保证覆盖现有安装。
需继续覆盖安装时，另行安全转移原签名密钥。原电脑 Beta.13 的签名未知。

已交付 APK 的 SHA-256：

- Beta.14: `361255B0F52D13EA8CE86987F9B37B6F05EF56F72123FA1091551932A8E137DF`
- Beta.15: `8AA701E21D204B3DBEAC45A2B4A5E3906E315AF09C4B775570AD70ED39ED36DF`
- Beta.16: `5CCB834B65DB51C1EEF68A2A7C2B392209126FBF79C02D1EDEBA1502CE0E611C`

## 验证边界与依赖

安装包旁的 `*-verification.json` 保存打包时的签名、架构、对齐等核验结果。
修复记录中的自动化回归属于各版本交付时的结果；此次归档重新核对了源码与安装包哈希，未重编译旧 APK，
未连接手机执行安装、耳机切换、桌面模糊或触感验收，也没有改动线上更新清单。

第三方源码、二进制及许可证说明保留在 `third_party/`。
`tiny_http` 的 `examples/ssl-key.pem` 与证书是公开 crate 0.12.0 自带的演示材料，
与公开上游内容一致（仅本地换行为 CRLF），不是应用签名密钥或账号凭据。
构建缓存、临时备份、旧源码 ZIP、真实凭据与签名私钥由 `.gitignore` 排除。
