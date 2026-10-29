# 另一台电脑接续：Mesting Music 1.0.12

日期：2026-10-29（Asia/Shanghai）。1.0.11 / code32 与1.0.12 / code33 均已保存独立版本提交、固定标签和正式 GitHub Release，全部附件的大小和 SHA-256 已按 GitHub 返回的 digest 验证。当前维护入口是 beta，产品源码是1.0.12；main 与旧标签、Release 保持。

## 固定版本与交付

| 版本 / code | 标签与 Release | 固定源码提交 |
| --- | --- | --- |
| 1.0.11 / 32 | [v1.0.11](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.11) | `4d2c18e300d6b4cdf69e839379cedc657e9ffc7d` |
| 1.0.12 / 33 | [v1.0.12](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.12) | `27c77a315a58b6c343dba527d4165a09170db2c7` |

每版 Release 含原始 APK、原始完整源码 ZIP、包与源码验证 JSON、源码逐文件清单、SHA256SUMS.txt、安装验收、修改和冻结交接。1.0.11 另附原公开下载核验；1.0.12 另附本轮 music 公开 health 与首尾 Range 核验。原 APK / ZIP 未重建、重签或重新压缩。

1.0.11 ZIP 的1553份源文件、1.0.12 ZIP 的1582份源文件以及各自 SOURCE-SNAPSHOT.json 均逐字节匹配对应版本提交。标签只追加来源清单和归档说明；beta 在1.0.12标签之后补充文档、校验与接续证据，运行源码、素材、测试、依赖锁和构建入口不变。GitHub 自动生成源码包包含额外归档资料，原交付请选各版附件中带版本号的 source.zip。

冻结文档和验证 JSON 的未提交／未推送／未发布字段保留当时事实。当前状态以本文、[本轮 GitHub 核验](docs/version-archive/GITHUB-ARCHIVE-2026-10-29-verification.json)及远端为准；不修改旧 APK、ZIP 或历史交付记录来掩盖时间差。

## 新电脑开始

在新目录执行：

```powershell
git clone --branch beta https://github.com/Mesting42/mesting-music-flutter.git Mesting-Music
cd Mesting-Music
git fetch origin --tags
git status --short --branch
git log -5 --oneline --decorate
git merge-base --is-ancestor v1.0.12 HEAD
```

已存在的工作区先检查 git status，保留自己的改动后按普通快进同步。固定查看1.0.11或1.0.12时，在独立干净目录查看对应标签；不要拿旧 ZIP 覆盖新工程或清理未提交修改。

先读根目录 AGENTS.md、本文、[接续入口](docs/CONTINUE-BETA.md)、[1.0.12 修改](docs/fixes-2026-10-29-v1.0.12.md)与[安装验收](docs/INSTALL-v1.0.12.md)，再等待用户的新需求。新需求按协作约定逐题澄清并在确认方案后实施。

## 构建环境与签名

- Flutter3.41.9 / Dart3.11.5；Java / Kotlin 编译目标17。本次 Gradle 使用 Android Studio JBR21.0.10，Android compile / target36、min24、NDK28.2.13676358；既有 WebRTC 构建还需 SDK34。
- pubspec.lock SHA-256：`6316dd4a0989c4a89b32d2a9a82bf603203743175909b52395a2d97cc4f2b5cc`。使用仓库内 SDK 和补丁库，保留锁文件，不全量升级依赖。
- 新电脑自行配置 Flutter、Android SDK、JDK 和 android/local.properties，不复制旧电脑绝对路径与缓存。正常构建保留 pub 阶段，避免测试插件遗留进入 Release。

```powershell
$musicFlutter = 'D:/你的Flutter目录/flutter'
& "$musicFlutter/bin/flutter.bat" pub get --enforce-lockfile
& "$musicFlutter/bin/flutter.bat" analyze --no-pub
$musicRegression = (Get-Content docs/validation-2026-10-29-v1.0.12.json -Raw -Encoding UTF8 | ConvertFrom-Json).regression.files
& "$musicFlutter/bin/flutter.bat" test --no-pub --flavor beta @musicRegression
./tool/build_android_release_apk.ps1 -FlutterSdkRoot $musicFlutter -VersionName '1.0.12' -VersionCode 33
```

上例用于重现，不覆盖原冻结附件或重复发布同 code。后续版本号先与用户确认，Android code 必须大于33，并同步随包更新说明和内置版本历史。共享 pubspec.yaml 中旧 stable 版本不决定本次产品身份，公开版本由 beta flavor 和发布入口参数确定。

保留包名 com.mesting.music.beta、显示名 Mesting Music、双 ARM 与原证书 SHA-256：`8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333`。现有 Gradle 使用 debug signing 配置；需单独私下转移并配置同一原签名材料，再核对产物证书。新电脑自动生成的 debug 密钥不能覆盖原安装。密钥、密码、管理凭据和真实账号不在 Git / ZIP / Release 中。

完整源码保留用户已确认可公开分发的 SDK、原 LICENSE 与第三方声明。SDK appId=music、P2P/P8P 接收开启、用户文件分享关闭。

## 当前 music 与验收边界

本轮只读公开 health 已显示1.0.12 / code33，102048657字节，公布 SHA-256 为 `4085984c595fca2c8bf6dc5c52e2576bd30d71b31122e92dab1b253504fa6def`，与冻结 APK 一致。公开下载首尾各64KiB均HTTP206并逐字节匹配；本轮没有重新下载公开整包计算其完整摘要，也没有操作后台发布。较旧冻结交接中的“1.0.12尚未发布”已被此时点公开状态更新，接手后不重复发布同 code。详见[只读公开核验](release/Mesting-Music-v1.0.12-music-public-verification.json)。

1.0.11 的17文件150项回归、1.0.12 的26文件273项回归均有原记录，静态分析无问题。1.0.12 的64条上游合约、11项界面检查已包含在273项中，不叠加计数；8类匿名在线目录另有记录。本次归档只复核源文件与产物一致性，未重跑历史产品回归或访问手机。

1.0.12 已按当前平台分流四个主页面，接入网易云功能、评论与 MV、BugPk 同 ID 备用源和严格公开补源、歌曲文件下载、最近播放与实际秒数上报。原网易云音源优先；备用链默认开启，只在原流不可播或仅试听时使用。保留通用本地功能、双平台登录和各账号暂停恢复的队列与进度。

真实账号写入、系统文件保存与后台下载、覆盖升级、受限歌曲的补源长期可用性、官版最近播放及累计时长实际入账仍由用户验收；接口接收不等于官方统计入账，不回填或盲重发 unknown / dispatched 事件。没有新明确授权不使用 ADB 或访问手机，主机截图不认证持续120fps。

## 本机保留方式

原本机工作区 D:/AnLi/Mesting-Music-Flutter/app-md3music-beta 仍在 codex/release-1.0.4、HEAD d609805，原暂存区和全部产品文件保留；归档对象、标签与本地 beta 已更新。当前未提交显示包含已归档实现及本轮接续文档，不能据此判断 GitHub 缺失。不要在该脏工作区直接切分支或重置；另一台电脑从远端 beta 干净克隆接续。

此前1.0.6～1.0.10的归档记录见[前次说明](docs/version-archive/RELEASE-BACKFILL-2026-10-28-v106-v110.md)，本轮来源见[归档说明](docs/version-archive/RELEASE-ARCHIVE-2026-10-29-v111-v112.md)。
