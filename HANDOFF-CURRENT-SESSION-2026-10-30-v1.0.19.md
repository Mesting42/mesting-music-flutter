# Mesting Music 1.0.19 / code40 本地交付接续

日期：2026-10-30（Asia/Shanghai）。本轮按用户逐项确认方案完成七项修复，准备原签名 APK、完整源码及校验资料。只准备本地文件；没有 Git 提交推送、GitHub Release 或 music 后台发布，没有真实账号、手机或 ADB 操作。

- 代码基线：beta / `8763551c0cc39c1c25f60e42fd49624f58d91a89`；本轮改动尚未提交。远端归档基线仍以 1.0.18 跨电脑交接为准。
- APK：`release/Mesting-Music-v1.0.19.apk`，104609407 字节，SHA-256 `247a7347d12ad00161473e7cfad1e1c2170c2cf1adb3697bf08c4a8992089d59`。
- 完整源码：根目录 `Mesting-Music-v1.0.19-source.zip`；大小和摘要以 `release/Mesting-Music-v1.0.19-source-verification.json` 为准，不能覆盖旧冻结交付。
- 原签名证书：`8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333`，包名 `com.mesting.music.beta`，双 ARM，code40；未做手机覆盖安装验收。
- 51 文件 1081 项 Beta 回归通过；普通 stable 19 项、Android 返回专项 1 项通过；新 UI 9 项已在主组内，不重复相加。静态分析 0 问题。APK v2/v3、CRC、16KiB ZIP/arm64 ELF 对齐、许可和无 QA/测试插件打包检查通过，生产 Range 读取器从最终本地 APK 读出 8 条说明。

先读 `docs/fixes-2026-10-30-v1.0.19.md`、`docs/INSTALL-v1.0.19.md`、`docs/PERFORMANCE-2026-10-30-v1.0.19.md` 和 validation JSON。网易云歌单/歌手图片使用 CDN 缩略图；双平台下载音质逐任务保存并严格核对；聊天普通表情转换、名称居中、一起听及菜单布局已修复；未读总数超过99为99+，新账号等待时隐藏旧值；重复音乐搜索入口移除。RouteSettledContent 延后可选栏加载，不降低玻璃质量。

Flutter 3.41.9 / Dart 3.11.5，Java 编译目标17，保持依赖锁，原签名通过私下保留的密钥生成。不要从源码包寻找私钥或改用新 debug 签名。SDK 原许可及第三方声明保留，用户分享继续关闭。

真实账号的下载权益、歌单/歌手封面、私信和计数、手机离线存储及更新后帧率仍由用户复测。已有诊断只证明 1.0.18 的绘制耗时较高；匿名缩略图样本减少约97%传输量，不等于应用帧率提升97%或持续120fps。

后续先只读核对 Git/工作区、交付核验和未提交改动，按 AGENTS.md 继续逐题澄清并确认方案后实施。没有新授权不提交推送或发布后台，不访问手机/ADB、真实账号，不关闭保留的 music 网页。
