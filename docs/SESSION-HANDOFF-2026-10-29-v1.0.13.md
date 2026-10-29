# Mesting Music 1.0.13 本机接续与发布准备

用户已确认将本轮网易云功能补齐和全App底部玻璃搜索统一定义为 **1.0.13 / Android code34**，并要求准备完整原签名APK、源码ZIP和校验资料，稍后自行到music后台上传发布。

## 当前状态

工程根`D:/AnLi`，分支`beta`，基线HEAD `deb68e4b4bad84d422085e4567d556b4441b5e48`。完整功能代码、主机验证和原签名APK构建已完成，包身份、结构及本地安装前说明读取通过。源码ZIP以相邻源码验证JSON及实际文件为准，未上传或发布，未Git提交／推送。旧版冻结交付、原工作区改动、SDK和签名材料保留。

版本通过现有Beta发布入口的build-name与build-number指定；共享`pubspec.yaml`的历史stable版本不改写。正式显示名保持Mesting Music，原包名`com.mesting.music.beta`，预期原证书SHA-256 `8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333`。只有实际APK验证通过后才作为交付包。

## 已完成实现

见[本版修改](fixes-2026-10-29-v1.0.13.md)、[完整接入记录](NETEASE-FULL-INTEGRATION-2026-10-29.md)、[305项清单](NETEASE-INTERFACE-COVERAGE-2026-10-29.md)和[安装验收](INSTALL-v1.0.13.md)。实现阶段887项主机回归、11项普通搜索、最后553项目录与请求合约通过，12项匿名只读返回正常，静态分析0问题；分组有重复，不相加。

## 构建与来源

使用独立Flutter3.41.9 / Dart3.11.5，Android compile/target36、min24、NDK28.2.13676358，Java/Kotlin目标17。本机构建环境和实际签名、双ARM、ZIP／ELF对齐、随包说明、第三方许可及测试资源排除结果将记录于`release/Mesting-Music-v1.0.13-verification.json`。

构建入口：`tool/build_android_release_apk.ps1 -VersionName 1.0.13 -VersionCode 34 -FlutterSdkRoot D:/CodexCache/flutter-3.41.9`。保留pub阶段，避免主机测试注册残留进入Release，依赖锁必须保持原SHA-256 `6316dd4a0989c4a89b32d2a9a82bf603203743175909b52395a2d97cc4f2b5cc`。任何本机内存限制只用于当前构建进程，不改用户全局配置。

本机Gradle原始产物使用原证书但默认只有v2签名；最终交付使用同一原密钥补齐v2/v3后重新核验。`build/app/...`中的临时包不等于最终交付，只上传`release/Mesting-Music-v1.0.13.apk`；原始构建摘要保存在本版包验证JSON的`inputApkSha256`中。签名补齐不修改版本、程序资源或业务代码。

原签名材料不在Git或源码ZIP中，换电脑需私下转移并核验证书。源码快照包含授权SDK与原许可、新增文件、文档和测试；排除密钥、密码、本机配置、真实账号、缓存和构建产物。逐文件路径、大小及SHA-256放入ZIP内`SOURCE-SNAPSHOT.json`，整包校验放在ZIP外，避免自引用。

工作区原有旧版`SOURCE-SNAPSHOT.json`不改写。为避免压缩包出现同名条目，原清单在新ZIP内逐字节保留为`SOURCE-SNAPSHOT-BASELINE.json`，当前1.0.13清单使用`SOURCE-SNAPSHOT.json`，并记录这项元数据映射。

## 未完成与接续边界

- music上传、候选检查、发布和线上完整下载／续传／安装前更新说明验证由用户后续操作；不得说成本地已发布。
- 真实登录、账号写入、安全变更、会员／音乐人权限、支付、Android文件选择与上传、识曲、一起听双端及手机性能待真实验收。
- 本机未访问手机或使用ADB，不关闭用户保留的music网页，不继续已停止的桌面内存优化。
- 保留全部工作区与历史交付，不reset／clean，不自动提交、推送或重新发布同code。新会话先只读核对本接续、AGENTS、Git与产物摘要，等待用户新任务。

## 本地APK交付记录

截至本机准备时间2026-10-29T11:45:23+08:00，原签名Release包已核验：

- APK：`release/Mesting-Music-v1.0.13.apk`，103,179,585字节。
- SHA-256：`b298926097b4f900e1dadf5f975eab5738fe88e70a4bf50ad617a2aaa0891a3f`。
- 正式名称Mesting Music、包名com.mesting.music.beta、1.0.13/code34，原证书与历史版一致；v2/v3签名、双ARM、ZIP 16KiB、ARM64 ELF 16KiB及ARM32 ELF 4KiB对齐通过。
- CRC、305项目录、AFP资源和MIT许可与源文件一致，QA字体与integration_test插件排除通过。
- 生产`PublicApkReleaseNotes`从最终APK本地模拟Range读取8条说明，内置当前版本说明完全一致；3次读取，共66,344字节。这没有访问网络，不代表music线上说明已核验。
- 发布阶段普通更新10项、Beta更新37项通过，分析0问题；原有冻结产物、gradle.properties与依赖锁共16项逐字节保持。旧UI回归中的历史按钮定位已改为当前网易云登录入口，应用欢迎页未改变。

源码目标：根目录`Mesting-Music-v1.0.13-source.zip`；逐文件清单在包内`SOURCE-SNAPSHOT.json`，最终整包大小与摘要在`release/Mesting-Music-v1.0.13-source-verification.json`与`.sha256`中。外部整包校验不进入自身快照。

向music上传只选择APK。更新说明可直接复制`release/Mesting-Music-v1.0.13-release-notes.txt`，候选核对字段在`release/Mesting-Music-v1.0.13-publish.json`。本地核验汇总见`docs/validation-2026-10-29-v1.0.13.json`。当前没有上传、后台操作、公开发布或线上下载核验，不向后台上传源码或签名材料。
