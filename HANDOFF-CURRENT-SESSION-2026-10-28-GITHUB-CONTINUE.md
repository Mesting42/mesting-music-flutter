# 另一台电脑接续：Mesting Music 1.0.10

日期：2026-10-28（Asia/Shanghai）。1.0.6～1.0.10五版Git提交、标签与正式GitHub Release均已补齐，1.0.10为最新正式版。

维护分支是`beta`，产品版本为1.0.10/code31。`main`及已有标签／Release保留；当前源码与已验证1.0.10冻结源码的区别仅为本次追加的归档、接续和索引文档，运行源码、素材、测试、依赖锁与构建入口字节不变。最新beta可能含标签之后的文档提交，先核对远端，不用旧文档中的v1.0.5 HEAD覆盖新分支。

## 版本和来源

| 版本／code | 固定标签及Release | 冻结源码归档提交 |
| --- | --- | --- |
| 1.0.6 / 27 | [`v1.0.6`](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.6) | `e8dd1dceb7398fee81a8cb26ad4614c46c8d5e44` |
| 1.0.7 / 28 | [`v1.0.7`](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.7) | `54d135526cfcc91465829f801b37550875df6885` |
| 1.0.8 / 29 | [`v1.0.8`](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.8) | `aafdb710d5bd79bb2c10bb87c5557b94c22909a9` |
| 1.0.9 / 30 | [`v1.0.9`](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.9) | `649bbec5a1e2f81cbb7b448b73c016ce4f47c37f` |
| 1.0.10 / 31 | [`v1.0.10`](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.10) | `c7588cad0708657b9f901110d470f6209f252326` |

每版Release附原APK、原源码ZIP、包／源码核验JSON、逐文件来源清单、修改记录、冻结交接、安装说明、归档说明和SHA256SUMS.txt。原APK／ZIP未重建、重签或重新压缩。GitHub自动生成的源码包还包含追加归档资料；原交付附件与自动生成包的含义不同。

归档提交创建于本次，不伪造历史开发日期。冻结文档中的“未提交／未推送”是打包时事实，最新状态按本文、[归档记录](docs/version-archive/RELEASE-BACKFILL-2026-10-28-v106-v110.md)及远端核对。源码含原有已获公开分发授权的SDK源，原LICENSE和第三方声明保留。

## 新电脑取得代码

在一个新目录执行，不覆盖另一台电脑已有的未提交文件：

```powershell
git clone --branch beta https://github.com/Mesting42/mesting-music-flutter.git Mesting-Music
cd Mesting-Music
git fetch origin --tags
git status --short --branch
git log -7 --oneline --decorate
git merge-base --is-ancestor v1.0.10 HEAD
```

已存在的工作区先检查`git status`，保留自己的改动，再按普通快进同步；不要reset／clean或拿旧源码包覆盖新工程。固定查看本次产品源码或回退参考时使用`v1.0.10`，建议在独立干净目录查看标签。

新会话先读根目录AGENTS.md、本文、[1.0.10修复](docs/fixes-2026-10-28-v1.0.10.md)及[实现阶段记录](docs/fixes-2026-10-28-ui-scene-sync.md)，只读核对后等待用户新需求。

## 环境与构建

- Flutter **3.41.9**／Dart **3.11.5**，Java **17**；Android compile／target36、min24、NDK28.2.13676358，WebRTC构建另需SDK34。本次使用build-tools35.0.0核验包。
- `pubspec.lock` SHA-256：`FDE25643DA671EF68397B59A3BB38E4AD5F664075E2D0414EBADABB9DC2DF2EF`。使用仓库内SDK和补丁库，不全量升级依赖。
- 使用新电脑自己的Flutter、Android SDK与JDK路径，配置本机`android/local.properties`；这些路径和缓存不在Git中。
- 普通构建保留pub阶段，以重新生成正确的原生插件注册；本次本机Gradle使用3GB heap及2 workers，这只是进程局部资源设置。

```powershell
$musicFlutter = 'D:/你的Flutter目录/flutter'
& "$musicFlutter/bin/flutter.bat" pub get --enforce-lockfile
& "$musicFlutter/bin/flutter.bat" analyze --no-pub
& "$musicFlutter/bin/flutter.bat" test --no-pub --flavor beta test/scene_catalog_contract_test.dart test/release_107_listening_sync_test.dart test/beta_update_isolation_test.dart
./tool/build_android_release_apk.ps1 -FlutterSdkRoot $musicFlutter -VersionName '1.0.10' -VersionCode 31
```

上例仅用于重现本版，不能覆盖冻结交付或重新发布同code。后续新版本必须先确认版本号，Android code大于31，并同步`assets/data/release-notes.json`及内置版本说明。

`pubspec.yaml`的1.0.37+58是共享旧stable配置，当前公开安装身份由发布入口的beta flavor与版本参数确定。保留包名`com.mesting.music.beta`、正式名称Mesting Music和原签名；原证书SHA-256为`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。

签名密钥与密码需单独私下转移；新电脑自动生成的debug签名不能证明可覆盖当前安装。项目目前使用debug签名配置，须在新电脑妥善配置同一原密钥并核对最终证书。私钥、管理凭据、真实账号记录和本机配置不进入Git或Release；SDK用户端分享继续关闭。

## 已完成与待验证

music当前公开1.0.10/code31，APK100,281,903字节，SHA-256 `995D13469846636DB41AF5B138893C3C8D56C891D4CFED3BC93F01F0E94DD032`；公开整包和安装前Range更新说明已读回一致。本轮归档没有改变music后台或产品行为。

1.0.10包含导入同排、11个场景专区、胶囊跟手切歌、模式颜色、按钮滚动／禁用状态、指南关闭和酷狗同步参数修复。修复阶段28项专项／真实响应重放与126项综合回归通过，发布阶段42项检查和线上说明读取通过，静态分析无问题；分组有交叉，不相加声称唯一测试总数。此轮只归档，未重跑历史产品测试。

真机覆盖升级、键盘／玻璃体验、权限、本地扫描、识曲、一起听、听书和官版历史／累计／每日实际入账仍由用户验收；显示120Hz或主机截图不证明持续120fps。旧625分钟继续本地保留，不伪造回填或盲重发unknown／dispatched事件。

未获新的明确授权时不访问手机、不使用ADB。原生benchmark仅隔离`.beta.benchmark`，强制`--keep-app-running`。

汽水／网易云仅做API调查，登录入口和底部角色图尚未实施。网易云可优先评估[增强版API](https://github.com/NeteaseCloudMusicApiEnhanced/api-enhanced)；[汽水项目](https://github.com/guowenye/qishui-api)的扫码目前主要依赖已登录抖音，搜索、完整播放和账号写入仍需验证。原角色图仍在本会话附件，未加入工程。下一次实施继续一次一个问题并先确认方案。
