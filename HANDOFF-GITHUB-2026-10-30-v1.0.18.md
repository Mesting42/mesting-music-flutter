# 跨电脑接续：Mesting Music 1.0.18 / Android code39

日期：2026-10-30（Asia/Shanghai）。用户要求的新版本Git/GitHub归档已完成：固定版本提交、标签v1.0.18与正式GitHub Release均已保存，全部15个附件大小、SHA-256和上传状态经GitHub接口回读核验。维护入口是beta，main与旧版本保持。

- [1.0.18 Release](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.18)，固定源码提交`59a3423dd11b457833fc1effea834519bfb22981`。
- 原APK：104560255字节，SHA-256 `6d820c044eb94fa33516b23cce7919dfcbbbc3f234f7aafcaa0035c7b42f173c`。
- 原完整源码ZIP：50271930字节，SHA-256 `a50a0400d7cc708cae07752e27bc089955c09905907a73b9db33738856959d96`。
- 全部1752份源文件与SOURCE-SNAPSHOT.json逐字节匹配固定标签；标签只追加来源说明和来源清单。beta在标签之后仅追加文档、校验和归档证据，运行源码、资源、测试、依赖锁及构建入口保持冻结字节。

Release保留原APK、原始完整源码ZIP、APK／源码核验、逐文件来源清单、SHA256SUMS.txt、修改、安装、冻结交接、回归记录及生产APK更新说明读取证明。APK和ZIP未重建、重签或重新压缩；GitHub自动生成源码包另含追加归档资料。

旧冻结交接中的未提交／未推送／未发布字段是2026-10-29构建时状态。当前Git/GitHub事实按本文、[回读证据](docs/version-archive/GITHUB-ARCHIVE-2026-10-30-v118-verification.json)及远端核对，不改写原冻结文件。本次没有操作music后台，不能把GitHub Release当成music后台发布核验。

## 另一台电脑继续开发

在新目录执行：

```powershell
git clone --branch beta https://github.com/Mesting42/mesting-music-flutter.git Mesting-Music
cd Mesting-Music
git fetch origin --tags
git status --short --branch
git log -5 --oneline --decorate
git merge-base --is-ancestor v1.0.18 HEAD
```

已有工作区先检查git status并保留自己的改动，再普通快进同步；不要覆盖未提交修改。先读AGENTS.md、本文、[本版修改](docs/fixes-2026-10-29-v1.0.18.md)、[安装复测](docs/INSTALL-v1.0.18.md)与版本验证JSON，再等待用户新需求。历史1.0.17的归档交接继续保留，不用其旧“最新”覆盖当前版本。

## 构建环境与签名

Flutter3.41.9 / Dart3.11.5，Java/Kotlin编译目标17，本次Gradle使用Android Studio JBR21，Android min24 / target36、NDK28.2.13676358。使用仓库内SDK和锁文件，不全量升级依赖。pubspec.lock SHA-256：`6316dd4a0989c4a89b32d2a9a82bf603203743175909b52395a2d97cc4f2b5cc`。

```powershell
$musicFlutter = 'D:/你的Flutter目录/flutter'
& "$musicFlutter/bin/flutter.bat" pub get --enforce-lockfile
& "$musicFlutter/bin/flutter.bat" analyze --no-pub
$musicTests = (Get-Content docs/validation-2026-10-29-v1.0.18.json -Raw -Encoding UTF8 | ConvertFrom-Json).betaRegression.files
& "$musicFlutter/bin/flutter.bat" test --no-pub --flavor beta @musicTests
./tool/build_android_release_apk.ps1 -FlutterSdkRoot $musicFlutter -VersionName '1.0.18' -VersionCode 39
```

上例用于重现，不能覆盖原交付或重复发布同code。后续版本号按用户确认，Android code须大于39，同时更新随包说明和内置版本历史。共享pubspec旧stable版本不决定公开Beta安装包身份，实际版本由发布入口参数指定。

新电脑配置自己的Flutter、Android SDK、JDK与android/local.properties。原签名密钥／密码必须私下转移，不能以新生成的debug密钥替代。保留com.mesting.music.beta、Mesting Music显示名、双ARM与证书SHA-256 `8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333`，重新构建后核对最终证书。签名、账号和管理凭据不在Git或Release中。

完整源码保留已获用户公开分发授权的SDK、原LICENSE及第三方声明；SDK appId=music、P2P/P8P接收开启、用户分享关闭。

## 本版功能与验证边界

本版修复网易云音质档位与本地均衡器重复入口、歌单封面、收藏／已购空列表与DTO、账号等级、下载按钮和离线目录、设置分组及个人页字重、网易云MV明文CDN适配、菜单滚动残留高亮。下载与存储位于“我的”。网易云增强音质走真实level请求，本地均衡器明确标注，不等同于官版鲸云DSP引擎。

原记录：49文件1064项Beta、普通stable19项、Android返回专项1项分别通过，静态分析0问题；专项与主组重叠时不叠加。原签名、v2/v3、双ARM、ZIP/ELF对齐、CRC、许可及九条随包说明已验证，生产Range读取器从本地最终APK读取成功。此次归档只复核原产物和源码，没有重做主机／真机验收。

真实等级／收藏／已购、会员及设备支持的增强档位、手机MV解码、ROM文件管理器与离线文件行为仍按安装清单复测。没有新明确授权不访问手机／ADB、真实音乐账号或后台，不关闭保留的music网页。新需求继续逐题澄清、确认方案后实施。
