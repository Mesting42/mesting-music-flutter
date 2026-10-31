# Music 接入 P8P SDK：开发者交接

日期：2026-10-27。交付为源码改动与补丁，不是已发布 APK。

## 1. 从哪里接续

- 仓库：`https://github.com/Mesting42/mesting-music-flutter`。
- 基线：`beta` 分支、`v1.0.2`，提交 `95d5719829a754978ba615a873aa6ddff08f67f6`。
- 本地工作分支：`codex/music-p8p-sdk-integration`；未向 Music GitHub 或其他仓库推送。
- 当前正式产品仍是 **1.0.2 / code 23**。本次没有改包名、原签名、版本号或线上 APK。
- 公开产品虽然叫正式版，仍须构建 **beta flavor**，包名保持 `com.mesting.music.beta`。不要切换到旧 `main`/stable 产品界面。

本包包含 `music-p8p-sdk.patch`、与补丁一致的 `source-overlay/`、SDK 原始 ZIP、测试日志和校验清单。选择补丁或覆盖文件其中一种方式，不要重复应用。

## 2. 实际下载逻辑

```text
启动/手动检查更新
  → 沿用 CsnasUpdateReleaseSource 获取 music/health
  → 检查 app_slug、APK 实际 versionCode、大小、SHA-256、主副站地址
  → 原有界面决定是否提示、是否开始下载
  → RingAppUpdateTransport → Ring Download SDK 1.1.0
      ├─ 本站 URL：HTTPS 立即启动；可用时接入 P8P；主副站由 SDK 切换
      └─ 外部 HTTPS/COS：直接下载；不为了下载再请求平台 health/节点
  → SDK 完成校验 + Music 再核验大小/SHA-256
  → 原子移动到原 app_updates/ 安装白名单
  → 用户授权安装后再次核验 → 原 Android 安装桥接
```

- SDK 参数固定 `appId: music`、`enableP2P: true`、`enableP8P: true`。
- Music 原先没有启用用户上传；本次保持 `allowSharing: false`。B/C/服务端仍可帮助 Music 下载。不是让音乐播放走 P8P。
- 生命周期监听由 SDK 处理；设备随机标识、信令、下载会话和传输统计由 SDK 管理，不需要 Music 另外实现。
- 版本升级仍比较 APK 实际 code，不改成“每次 SHA 不同就升级”。SHA 用来识别和核验下载文件。
- 主副站属于同一份发布快照；不添加“临时从平台查第三个 COS 地址”的依赖。
- SDK 的 P8P 失败由其 HTTPS 下载路径恢复，宿主不会再启动一个重复的整包 HTTP 下载。
- 旧 `.partial` 文件仍按旧 HTTP Range/会话协议续传一次，完成后后续新任务走 SDK；不会猜测或修改 SDK 的内部续传格式。
- SDK 暂停会等待写入清理完成。进程内保留已显示进度；进程重启后首次显示可能暂为 0，开始续传时由 SDK 回报实际进度，缓存数据仍保留。
- 完成文件通过 rename 移入原安装目录，避免增加一份完整 APK 的磁盘占用。

## 3. 平台停机与 COS 的准确边界

**本次没有改变 Music 的“发现更新”来源：它仍只通过我们的 music/health 获取最新版本。平台停机时，Music 无法凭空发现一个新版本/COS 地址，正常的音乐业务不因此改走平台。**

已经获得合法外部 COS 更新清单时，SDK 实际下载不请求平台 health、不发现节点、不依赖我们的服务在线；本轮以禁止全部额外服务套接字的方式验证了外部 HTTPS 主源失败后镜像仍完成。外部 URL 会丢弃遗留的本站备用地址，避免重新依赖本站。

SDK 本身支持外部 URL-only 下载；**Music 当前更新协议仍要求版本/code、大小和 SHA-256**。本次保留 Music 已有协议。以后如果要在平台停机时仍发现新版本，需要开发者配置独立可用的更新清单来源；仅替换下载 SDK 不会自动提供这个来源。

## 4. 改动文件

| 文件 | 作用 |
| --- | --- |
| `pubspec.yaml` / `pubspec.lock` | 加入本地 SDK 1.1.0；固定解析结果；package_info_plus 8.3.1 沿用 SDK 已验证的原生元数据依赖，Dio 作为集成测试依赖 |
| `lib/features/app_update/data/ring_app_update_transport.dart` | SDK 适配、元数据映射、暂停/清理、错误翻译和安装统计桥接 |
| `lib/features/app_update/data/app_update_repository.dart` | 可注入下载层、旧续传兼容、安装路径与二次摘要核验 |
| `lib/features/app_update/app_update_providers.dart` | 当前 beta 产品使用一个有生命周期的 SDK 适配器；旧 stable/Java 测试渠道保持原下载层 |
| `test/music_ring_update_test.dart` | 本次新增的宿主接入、取消竞争、文件变动、旧续传及真实 SDK HTTPS 分支回归 |
| `third_party/ring_download_sdk/` | 由正式 1.1.0 ZIP 提供的本地依赖，保留原源码/许可/第三方声明 |
| `third_party/ring_download_sdk.SOURCE.md` | SDK 来源与摘要说明 |

SDK ZIP SHA-256：`0edc03178bf446d19947643d59021d46362e24a4b3c8e5a1807c9e85dd4bc7ef`，499,322 字节。源码本地解析、随 App 编译，不会在 App 启动时下载 SDK。SDK 的 LICENSE 沿用原权利约定，不能因放进此项目便视为重新授予开源许可；本次为本地交接，没有公开上传 SDK 源码。

## 5. 应用补丁

先在新目录取得基线，保留开发者原有修改：

```powershell
git clone --branch beta https://github.com/Mesting42/mesting-music-flutter.git Music-P8P
cd Music-P8P
git switch -c integrate/music-p8p 95d5719829a754978ba615a873aa6ddff08f67f6
# 将交接包内补丁复制至仓库外，再用实际绝对路径替换下面的路径。
git -c core.autocrlf=false -c core.whitespace=cr-at-eol apply --check C:/handoff/music-p8p-sdk.patch
git -c core.autocrlf=false -c core.whitespace=cr-at-eol apply C:/handoff/music-p8p-sdk.patch
```

也可以使用交接包内 `应用补丁.ps1 -RepositoryPath C:/你的/Music-P8P -CheckOnly` 先检查，移除 `-CheckOnly` 后应用。脚本会检查基线、干净工作区及补丁摘要；不会推送、构建或发布。

如果开发分支已前进，不要强制覆盖：以这几个下载模块的变更做三方合并。`source-overlay/` 只包含改动文件和本地 SDK，不是完整 Music 源码仓库。

## 6. 开发者构建与签名

本轮主机实际验证环境为 **Flutter 3.47.7 / Dart 3.13.5**。交付锁文件按此环境生成；相对原 Flutter 3.41.9 环境，Flutter 测试固定依赖及 vector_math/meta 等解析值也有变化，详情以锁文件差异为准，不宣称此锁已在 3.41.9 通过。JDK 17、原 AGP 8.11.1 / Gradle 8.14 / Kotlin 2.2.20 与 minSdk 24 的工程设置未做迁移。

```powershell
$musicFlutter = 'D:/你的Flutter-3.47.7/flutter/bin/flutter.bat'
& $musicFlutter pub get --enforce-lockfile
& $musicFlutter test --no-pub --flavor beta test/music_ring_update_test.dart test/csnas_app_update_test.dart
& $musicFlutter test --no-pub --flavor stable test/app_update_test.dart
# 构建下一版，沿用项目现有的素材过滤和渠道检查入口。
./tool/build_android_release_apk.ps1 -FlutterSdkRoot 'D:/你的Flutter-3.47.7/flutter' -VersionName '1.0.3' -VersionCode 24
```

`1.0.3/24` 为下一版示例；若开发者已发过更高版本，请再提高真实 APK code。不要使用仍默认 1.0.2/23 的无参数构建命令发布本次改动。

覆盖现有用户安装必须由开发者沿用原密钥。已发布 1.0.2 的证书 SHA-256：`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。本包不含私钥/密码；现有构建脚本默认 debug 签名，开发者必须按原交付流程配置同一签名后再发布。

## 7. 验证记录

| 检查 | 结果 | 日志 |
| --- | --- | --- |
| Music 正式产品/beta 更新回归 | 25 通过，0 失败 | evidence/music-beta-delivery-tests.log |
| Music 旧 stable 更新回归 | 10 通过，0 失败 | evidence/music-stable-update-tests.log |
| 更新模块与新增用例定向分析 | 无问题 | evidence/dart-analyze-delivery.log |
| SDK 6 个合同/传输测试文件 | 首轮 213 通过、1 失败 | evidence/sdk-transport-tests.log |
| SDK 失败用例单独复测 | 1 通过 | evidence/sdk-contention-isolated-retest.log |
| Android 工程检查 | 未完成：本机首次 Gradle 配置耗时过长，已主动停止；不算编译通过 | evidence/android-compile.log |
| SDK 原生插件独立编译 | JDK17/API36 编译通过；Flutter 依赖登记及网络权限声明检查通过 | evidence/sdk-native-validation.json |
| SDK 归档一致性 | 原包 196 个文件逐一 SHA-256 一致 | evidence/sdk-source-integrity.json |
| 补丁检查 | 原基线索引可应用，反向应用恢复原树 | evidence/patch-verification.json |

SDK 扩展回归失败项为 P8P whole download HTTP contract contention-repeated：反复模拟节点繁忙时走到 HTTPS 的开放尾区间，未满足该用例“此场景每次请求均为封闭分片”的断言；该次下载的完整字节校验已通过。单独复测通过，首次失败仍保留，尚不能仅凭一次复测证明完全由机器负载造成或已消除偶发性。SDK 发布源码未为此改变，不能称本轮扩展套件首次全绿。

完整 Music Gradle 检查在这台 8GB 主机的首次工程配置阶段运行较久，已仅停止本次自建验证进程；日志中的 daemon disappeared 来自这次主动停止，不作为代码编译缺陷结论。独立 SDK Java 编译通过不代表完整 APK、Manifest 合并、签名或真机安装已经验收，后续由 Music 开发者在其打包环境完成。

初轮合并测试把旧 stable 用例放在 beta flavor 下，出现包名和旧界面查找失败；已按正确渠道分开复跑，原失败日志保留。新增用例也发现并修复了取消瞬间最终进度事件丢失；另一个新增控制器用例最初缺少必填 releaseNotes，已修正夹具，不改产品协议。

全项目在本机较新 Flutter 下的初轮分析有 9 项诊断，包括原 beta21 测试引用已变为 nullable 的回调、旧重排/缓存 API，以及原搜索模块的提示。本次只修复了更新模块内对应的 await 提示，不改播放器/歌单/搜索或旧界面测试；最终更新模块定向分析结果单列。不能将定向通过表述为全产品静态分析/真机验收通过。

没有访问手机/平板，没有安装或上传正式 APK，没有发布用户更新，没有修改平台数据库、节点、音乐接口或 LifeRing App。

## 8. 开发者发布前的短验证

1. 用原签名构建下一版，在原 1.0.2 上覆盖安装并保留数据。
2. 发布一个更高 code 的受控测试版本，确认“检查 → 下载 → 安装授权 → 安装器”完整链路。
3. 有节点时从后台记录确认 P8P 实际贡献字节；没有节点/信令失败时确认 HTTPS 仍完成。仅看到配置 enableP8P=true 不能证明某次真实用户连接成功。
4. 验证暂停、继续、重开进程与主副站切换；如业务清单提供外部 COS，确认其下载不请求本站。
5. 构建后的包名/真实 code/原签名、Music 平台发布元数据须一致。源码接入不会让已安装的旧 1.0.2 自动具有 P8P；用户先通过旧 HTTPS 升级到本次新版，之后的更新才使用本 SDK。

## 9. 回退

未修改这些文件时，可先 `git apply -R --check music-p8p-sdk.patch`，通过后 `git apply -R music-p8p-sdk.patch` 返回原下载实现；有后续修改时按 Git 提交逐项回退。已上架/已安装的 APK 不会因源码回退自动改变，需要以更高 code、同签名的修复版本发布。
