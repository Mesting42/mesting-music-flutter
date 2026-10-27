# Mesting Music 1.0.1 接续

更新日期：2026-10-27（Asia/Shanghai）。公开版本 **1.0.1 / 22**，内部 `beta` flavor、包名 `com.mesting.music.beta`、正式显示名 Mesting Music 保持。先读 [本轮修改](fixes-2026-10-27-v1.0.1.md)、本文件、[接续入口](CONTINUE-BETA.md)、根目录 AGENTS.md / PRODUCT.md / DESIGN.md；另一会话接手先只读核对，再按用户指令继续。

## 工作区与冻结记录

- 当前分支 `beta`，HEAD `edc6d1bf881cbe2173709cc84b86b91637fbaaed`，已归档标签仍为 `v1.0.37-beta.19`。Beta.20、Beta.21 和本轮修改均保留在未提交工作区；没有 commit/tag/push 或 GitHub Release。
- 不 reset/clean/stash/switch 或用 GitHub 的 Beta.19 覆盖当前目录。本轮源码以 `Mesting-Music-v1.0.1-source.zip` 快照交接；GitHub 当前代码不包含这些未推送修改。
- Beta.20/21 的 APK 与原始源码 ZIP 均保持，尤其 Beta.21 APK SHA256 `46723B9F392121107DC5AF7423B7DEC8E08DCFDD77C4A86FC8B2DED0094EDBD9`，源码 ZIP SHA256 `31C2396315F5832045F7E6943E7947DFE49DFF08AA3978ABEBA836269B45C4DD`。
- 两张原始启动 PNG、组合角色 `companions-atlas.png` 与 `beta_companion_stage.dart` 保持原字节。旧 `.impeccable/design.json` 的漂移仅记录，没有顺手重建；1.0.1 的权威规则是 PRODUCT.md / DESIGN.md 新节。

## 当前功能及所有者

本版实现静态绿色成功标记、浅色可见的评论等待标记、中性欢迎背景/细线手机图标、完整玻璃更新抽屉及 4dp 真实进度条。角色与之前的队列、指南、法律入口及设备选择修改继续保留。本轮没有修改账号后台或开启自动听歌时长上报。

更新链分为公开元数据 source、可恢复文件 repository、单一 controller、纯展示 sheet/progress 和既有 Android 安装 bridge。只读 `https://download.csnas.asia/api/app/music/health`，使用真实 Android versionCode 顺序。常规 HTTPS 主源 `https://download.csnas.asia/music/download`，备用 `https://download1.csnas.asia/music/download?direct=backup`；没有 P2P/P8P 或文件分享。自动检查需完成入口，包含游客，15 分钟前台节流；稍后提醒同一非强制版本 12 小时。

管理员凭据只供浏览器登录，不进入代码、文档、日志、APK 或源码快照。平台上传/发布与手机客户端的匿名更新读取是两条独立路径。缺少发布说明时省略，不编造更新内容。稳定 stable 和 Java 测试源继续保留原规则。

## 验证

- Beta 广泛回归 268 项通过；最后受影响的更新、评论、成功提示、抽屉与浅深色截图回归 29 项通过。这些组有重叠，不能相加。
- 正式渠道完整回归 740 通过、117 条件跳过、2 项既有失败：`editing menu leaves its gap outside the complete multiline field` 与 `follower removal sheet stays above the persistent player`。没有新增失败；最终评论等待标记的小范围修改另由受影响回归覆盖，不声称全量全绿。
- 最终 `flutter analyze --no-pub` 无问题。便携摘要见 `docs/version-archive/v1.0.1-evidence/test-summary.json`。
- 28 张生产 Flutter 控件主机截图，包含浅深色、390dp、320dp/1.5 倍字、十种更新状态。版本 1.0.1 → 1.0.2 与 30/80 MiB 是合成夹具；安装阶段夹具保留完成路径与 100% 字节，不将截图当作真实发布或安装证据。
- 独立完整复核只提出评论等待标记可见度一项，修复后的 R1 verdict 为 `ship`，该项实测前导白笔画对比度浅色 5.08:1、深色 5.95:1。此 verdict 只评分 R1，前序完整复核的设备边界仍保留。设计文档独立整理已完成。

## 构建与移交

Flutter **3.41.9** / Dart **3.11.5**，JDK **17.0.20.1+1**，Android compile/target **36**，minSdk **24**，NDK **28.2.13676358**，ARM32 + ARM64。依赖锁 SHA256 固定为 `3F2DC18A71A59324ADF202E8EFE43E2F712B23A16E743B772AF0EC10748B4957`。

```powershell
./tool/build_android_md3_beta_apk.ps1 -FlutterSdkRoot 'D:/你的Flutter目录/flutter'
```

默认覆盖构建版本为 1.0.1/22，并开启更新检查。共享 `pubspec.yaml` 的正式版本 `1.0.37+58` 不改。**不要给这条 Release 命令添加 `--no-pub`**，测试后的开发插件注册器需要重新生成；脚本会核对依赖锁并排除正式专用素材。新电脑私钥需私下转移，不能上传平台或 Git；证书 SHA256 必须是 `8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。

最终 APK 文件为 `release/Mesting-Music-v1.0.1.apk`，包核验见同目录 `Mesting-Music-v1.0.1-verification.json` 与 `.apk.sha256`；源码包不含 Git 历史、APK、密钥、本机缓存或账号报告。最终平台与实际下载结果由同目录便携证据确认。

已核验 APK **76,197,276 字节（72.67 MiB）**，SHA256 **`27FBC6BA1DDF98A405A322AB8B71F834ED4A9456042E5D2821B8AA15546D80D2`**。Release 构建成功，69 项正式专用素材排除检查通过，v2 签名与原 Beta.14–21 证书匹配；ZIP 与 ARM64 ELF 16 KiB 对齐、10 项原生库与构建输出一致、启动 PNG/角色图集入包字节与原文件一致；依赖锁未变。旧 Beta.20/21 安装包、源码 ZIP 和角色舞台也与本轮前快照逐字节一致。

## 线上发布与真实 HTTPS 验证

已通过浏览器向 Mesting Music · music 上传本包。上传后平台页面已显示线上 **1.0.1**，未重复点击发布；公开 health 返回真实 code **22**、76,197,276 字节与上述摘要，和本地完全一致。[当前下载入口](https://download.csnas.asia/music/download) 可用。只操作本应用上传与界面筛选，未改其他应用、COS、P2P 或平台系统设置。

随后在主机上运行生产 `AppUpdateRepository` / `CsnasUpdateReleaseSource` 的真实联网验证：用明确模拟的旧版 code21 身份识别更新，下载至 **1,051,711 字节**暂停，再续传并完成整个 76,197,276 字节文件，仓库 SHA-256 校验通过；同一清单对 code22 判断为无新版。该项 1 测试通过，不涉及 Android 方法通道或用户手机。主/备下载地址还分别通过 1,024 字节 Range 探测，均为 206 与新文件总长度；备用站只做有界协议探测，不冒称完整备用文件下载验收。

便携记录位于 `docs/version-archive/v1.0.1-evidence/platform-verification.json`、`live-client-verification.json` 和 `https-probes.json`。截图 `.codex-artifacts/2026-10-27-v1.0.1/platform-published.png` 留在本机忽略目录；完整下载文件、本机随机下载 UUID 和服务器会话同样不进入源码包。后续逐次发布参照 [更新发布步骤](RELEASE-UPDATE-GUIDE.md)。

## 手机边界与后续更新

本轮未访问手机、运行 ADB、覆盖安装或执行原生性能测试。此前用户单次授权的 Beta.21 升级已完成；不得把它当作本轮或后续的持续设备授权。1.0.1 的系统安装、未知来源权限、Android GPU 玻璃、IME、TalkBack、返回手势和实际数据保留继续由用户真机测试。

旧 Beta.20/21 未含本轮更新功能，需要先手动覆盖安装一次 1.0.1；不要主动卸载或清数据。之后发布新版保持包名和原签名，递增 APK 内的 versionCode，再在 music 应用上传、核对候选包并发布。只改平台显示版本名不足以发布可靠升级。内部仍叫 beta 的包名是兼容性身份，不代表公开版本继续用 beta 文本。
