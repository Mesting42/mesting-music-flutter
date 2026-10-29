# Mesting Music 1.0.14 / Android code35 本机接续

用户已确认整体整理网易云功能并准备原签名APK、完整源码ZIP和校验资料，music上传发布由用户操作。工程根D:/AnLi，beta / `deb68e4b4bad84d422085e4567d556b4441b5e48`，既有工作区与所有未提交改动保留。

## 已完成与当前状态

实现、主机回归、原签名APK构建及包结构核验已完成；源码快照状态以相邻验证JSON为准。实际产物以 `release/Mesting-Music-v1.0.14-verification.json`、`release/Mesting-Music-v1.0.14-source-verification.json` 及本版validation JSON为准，不用build临时包代替。

见[整理说明](NETEASE-UX-2026-10-29-v1.0.14.md)、[修改](fixes-2026-10-29-v1.0.14.md)和[安装验收](INSTALL-v1.0.14.md)。保留305项目录和固定上游请求合约。消息、聊天、图片/资源分享、持续一起听控制器、评论平台标题、播放开始记录及BugPk官方外链处理已纳入本版，分类、分页、选择器和日期操作一并整理。

34个文件904项整体回归、后续5个文件58项定向回归通过，组间重叠不相加；分析0问题。匿名BugPk样本通过生产解析器返回HTTPS网易CDN，仅读取前1024字节，无账号凭据，不代表所有会员曲目可用。渲染覆盖浅深色、320宽及1.5倍字，修复邀请按钮挤压好友名。

## 产物与复现

最终APK目标 `release/Mesting-Music-v1.0.14.apk`，源码目标根目录 `Mesting-Music-v1.0.14-source.zip`，说明、发布JSON和校验资料在release。1.0.13冻结交付及历史版本保留。

正式显示名Mesting Music，包名com.mesting.music.beta，预期原证书SHA-256 `8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333`。最终包必须实际验证，不能只凭文件名推断覆盖升级。共享pubspec中的历史stable版本保留，发布入口传入1.0.14/code35。

构建：`tool/build_android_release_apk.ps1 -VersionName 1.0.14 -VersionCode 35 -FlutterSdkRoot D:/CodexCache/flutter-3.41.9`。Flutter3.41.9/Dart3.11.5、JDK17、target36/min24/NDK28.2.13676358，双ARM。保留pub阶段重新生成Release插件注册；内存/工作线程限制仅当前构建进程。依赖锁原SHA-256 `6316dd4a0989c4a89b32d2a9a82bf603203743175909b52395a2d97cc4f2b5cc` 保持。

源码快照包含授权SDK、原许可、新代码、测试与文档，排除密钥、密码、本机配置、真实账号、构建物和缓存。原 `SOURCE-SNAPSHOT.json` 不改写，在ZIP中保存为 `SOURCE-SNAPSHOT-BASELINE.json`；当前逐文件清单用 `SOURCE-SNAPSHOT.json`，整包摘要放ZIP外以免自引用。

## 待验收与接手边界

- 未访问手机、ADB或安装。实际覆盖升级、Android选择/上传、键盘、后台限制及性能由用户验收。
- 真实账号最近播放/累计时长、私信图片送达、会员音源和官版双端一起听未代测。公开一起听协议主要描述主机流程，防御性字段解析和模拟测试不能证明官版实际下发及双向操作可用；系统杀进程或断网也不能保证连接。
- 未读取真实账号或替用户发送消息/邀请，未操作music后台、上传或发布，不把本地通过说成线上发布。
- 不提交/推送、reset/clean或覆盖旧冻结交付，不关闭保留的music网页，不继续已停止的桌面内存优化。签名材料私下保存。
- 新会话先读本接续并只读核对Git、摘要与验证状态，再等待用户新任务，不自动重复发布同code。

## 最终APK本地交付记录

准备时间2026-10-29T13:31:32+08:00。APK为`release/Mesting-Music-v1.0.14.apk`，104,146,241字节，SHA-256 `0918994ce5199232e5080d93fbb25d643b230ae5ef27a6564d47bad355ed0468`。原证书、v2/v3签名、正式名、包名、1.0.14/code35、双ARM、ZIP 16KiB、ARM64 ELF 16KiB及ARM32 ELF 4KiB对齐、CRC、随包说明/目录/许可与QA资源排除均核验通过。

生产Range说明读取器从最终实际APK读取8条说明，与离线历史一致；3次本地Range，共66,422字节，无网络。普通更新10项通过；原冻结交付和配置共25项逐字节保持。测试组有重叠，不相加。最终完整验证见`docs/validation-2026-10-29-v1.0.14.json`。本轮未上传、发布、Git提交/推送或访问手机。

构建目录中的临时包不是最终交付。只向music上传`release/Mesting-Music-v1.0.14.apk`，更新说明复制`release/Mesting-Music-v1.0.14-release-notes.txt`，核对字段见发布JSON。源码ZIP内清单与整包摘要以相邻source-verification JSON为准。
