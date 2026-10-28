# 发布下一版应用更新

<!-- current-git-archive-state -->
**后续Git归档补记：** 1.0.6～1.0.10五版Git提交、标签与正式GitHub Release均已补齐，1.0.10为最新正式版。 最新接续见 [跨电脑总交接](../HANDOFF-CURRENT-SESSION-2026-10-28-GITHUB-CONTINUE.md)；下方冻结时的未提交／HEAD字段保留原事实，不能当成当前远端状态。
<!-- /current-git-archive-state -->
**1.0.10/code31已发布music：** 本版构建验签、公开health、完整下载SHA-256及安装前线上更新说明读取均通过；先读 [本版接续](SESSION-HANDOFF-2026-10-28-v1.0.10.md)。后续code须大于31，保持原安装身份和签名，不重建或覆盖旧冻结交付。

## 2026-10-28 最新发布指针

**1.0.9 / code30 已发布 music，公开health、完整下载摘要及生产Range更新说明读取通过，见 [本版接续](SESSION-HANDOFF-2026-10-28-v1.0.9.md)。后续code须大于30，并同步随包release-notes.json与内置说明。以下旧构建及旧发布状态仅作历史，不重发。保留原包名、正式显示名、原签名及全部冻结交付；Git未提交／推送，未经新授权不操作手机。**

**1.0.8 / code29 已发布 music，见 [本版接续](SESSION-HANDOFF-2026-10-28-v1.0.8.md)。后续code须大于29，并同步随包release-notes.json与内置说明。以下旧构建示例属于历史，不重发。保留原包名、正式显示名及签名。**

**2026-10-28 最新：1.0.7 / code 28 已发布；见 [本版接续](SESSION-HANDOFF-2026-10-28-v1.0.7.md)。后续code必须大于28，并同步随包release-notes.json和内置版本说明；不要重发下方旧版。**

**2026-10-28 最新：1.0.6 / code 27 已发布，见 [本版接续](SESSION-HANDOFF-2026-10-28-v1.0.6.md)。下一版 code 必须大于 27；发布前同步 `assets/data/release-notes.json` 的 version、versionCode 和 releaseNotes，使 1.0.6 起的旧客户端能在升级前从目标 APK 读取说明。下文关于 1.0.5 待补发的状态属于历史，不再执行。**

适用当前 Mesting Music 更新链。最新 GitHub/本地交付为 **1.0.5 / code 26**，但 music 后台仍是 **1.0.4 / 25**；见 [当前交接](SESSION-HANDOFF-2026-10-28-v1.0.5.md)。本次上传发布被浏览器 URL 安全检查中止，待续时直接使用 `release/Mesting-Music-v1.0.5.apk`，大小 97,702,493 字节、SHA-256 `48F99ABCFB2381EE1E499EC1E0E935449D498D8233BEC8F95BE7D0EB4798FDF1`，按下文第 3—6 步完成，不重建旧 code。1.0.1 起客户端从 music health 检查，1.0.4 起后续下载接入 Ring SDK。管理凭据不写入源码、构建参数或交付快照。

1. 保持包名 `com.mesting.music.beta`、显示名 Mesting Music 和原签名证书。1.0.5 的实际 code 为 `26`；后续修复使用更高 code，例如 `1.0.6 / 27`。内部 flavor 仅用于已有安装的兼容，不另发公开 Beta 版本。
2. 在保留当前工作区的前提下完成代码和相应回归，再构建：

   ```powershell
   ./tool/build_android_release_apk.ps1 -FlutterSdkRoot 'D:/你的Flutter目录/flutter' -VersionName '1.0.6' -VersionCode 27
   ```

   不加 `--no-pub`。检查构建后的版本、包名、签名、SHA-256、大小及资源排除，保存独立版本安装包与源码快照。不要覆盖已冻结的旧交付文件。

3. 在 [应用发布](https://download.csnas.asia/admin?page=apps) 的“发布到应用”选择 **Mesting Music · music**，选择本次 APK，点“上传并暂存”。只上传可公开分发的 APK，不上传私钥、源码或账号记录。
4. 候选校验完成后核对应用标识、Android 包名、实际版本 code、文件大小和 SHA-256 与本地一致，再发布。保持旧版本历史，避免误改其他应用。如果平台需要单独填写公开版本名，将它与 APK 的 versionName 保持一致。
5. 查看 [公开 health](https://download.csnas.asia/api/app/music/health)，确认同一响应中的 `version`、`android_version_code`、`file_size`、`sha256` 与本次 APK 一致。使用 [公开下载入口](https://download.csnas.asia/music/download) 验证完整下载摘要；本地保存下载结果与原文件比较。
6. 由用户在旧版真实设备上验证提醒、暂停/续传、系统安装权限和覆盖升级。新会话不得把此前的单次设备授权当作持续授权，也不能以静态截图替代安装验收。

当前客户端使用 15 分钟自动前台检查节流；手动点击设置“版本更新”立即检查，同一非强制版本选择“稍后提醒我”后暂缓 12 小时。服务器只修改显示版本名不会提高已安装应用的实际 versionCode，也不能为旧 Beta.20/21 自动补装更新功能。安装器由 Android 决定，用户仍需确认安装。

1.0.4 当前下载由 Ring Download SDK 1.1.0 管理 HTTPS 及可用节点的 P2P/P8P、续传和有界恢复；用户端分享保持关闭，业务层不再为 SDK 失败启动重复整包 HTTP 下载。旧 HTTP partial 仍可沿原协议完成一次。限流、摘要、范围或身份错误不能靠放宽 HTTPS、包名、版本或签名校验绕过。更新发现仍依赖 music/health，接入 SDK 不提供独立 COS 新版本发现源。SDK 源码随私有接续包提供，保留原权利和第三方声明，不直接公开上传公共仓库；管理后台只接收可公开分发的签名 APK。
