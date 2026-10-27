# 发布下一版应用更新

适用当前 Mesting Music 的常规 HTTPS 更新链。用户第一次需手动覆盖安装 1.0.1；以后客户端从 music 公开 health 检查新版本。管理后台凭据只在浏览器使用，不应写入项目或构建参数。

1. 保持包名 `com.mesting.music.beta`、显示名 Mesting Music 和原签名证书。公开版本使用正式数字，例如下一版 `1.0.2`，Android `versionCode` 必须大于当前的 `22`。
2. 在保留当前工作区的前提下完成代码和相应回归，再构建：

   ```powershell
   ./tool/build_android_md3_beta_apk.ps1 -FlutterSdkRoot 'D:/你的Flutter目录/flutter' -VersionName '1.0.2' -VersionCode 23
   ```

   不加 `--no-pub`。检查构建后的版本、包名、签名、SHA-256、大小及资源排除，保存独立版本安装包与源码快照。不要覆盖已冻结的旧交付文件。

3. 在 [应用发布](https://download.csnas.asia/admin?page=apps) 的“发布到应用”选择 **Mesting Music · music**，选择本次 APK，点“上传并暂存”。只上传可公开分发的 APK，不上传私钥、源码或账号记录。
4. 候选校验完成后核对应用标识、Android 包名、实际版本 code、文件大小和 SHA-256 与本地一致，再发布。保持旧版本历史，避免误改其他应用。如果平台需要单独填写公开版本名，将它与 APK 的 versionName 保持一致。
5. 查看 [公开 health](https://download.csnas.asia/api/app/music/health)，确认同一响应中的 `version`、`android_version_code`、`file_size`、`sha256` 与本次 APK 一致。使用 [公开下载入口](https://download.csnas.asia/music/download) 验证完整下载摘要；本地保存下载结果与原文件比较。
6. 由用户在旧版真实设备上验证提醒、暂停/续传、系统安装权限和覆盖升级。新会话不得把此前的单次设备授权当作持续授权，也不能以静态截图替代安装验收。

当前客户端使用 15 分钟自动前台检查节流；手动点击设置“版本更新”立即检查，同一非强制版本选择“稍后提醒我”后暂缓 12 小时。服务器只修改显示版本名不会提高已安装应用的实际 versionCode，也不能为旧 Beta.20/21 自动补装更新功能。安装器由 Android 决定，用户仍需确认安装。

主/备站只在传输或服务器失败时做一次有界切换；限流、摘要、范围或身份错误由用户重试或重新发布正确包解决。不要为绕过错误而放宽 HTTPS、包名、版本或签名校验。当前不需要 SDK 密钥、P2P/P8P 或向其他用户上传文件。
