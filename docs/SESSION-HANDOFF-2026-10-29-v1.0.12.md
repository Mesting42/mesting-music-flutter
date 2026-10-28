# Mesting Music 1.0.12 接续与发布状态

工程根 `D:/AnLi/Mesting-Music-Flutter/app-md3music-beta`，当前分支 `codex/release-1.0.4`，基线 HEAD `d609805aef6cb1136e14a535233d3aa760ae62d0`。保护全部工作区修改，不 reset／clean／切分支／新建丢失工作区改动的worktree。本版未 Git 提交或推送。

实现与边界见 [修改记录](fixes-2026-10-29-v1.0.12.md)、[安装验收](INSTALL-v1.0.12.md)，验证见 `validation-2026-10-29-v1.0.12.json`。本版1.0.12/code33；1.0.11/code32的冻结APK／ZIP保持。

## 当前发布状态

**准备发布，尚未上传或公开发布。** 用户已授权完成验证后发布到 music，并在2026-10-29明确要求重试。用户已在Codex内置浏览器打开 `https://download.csnas.asia/admin?page=apps`，但当前Computer Use浏览器清单只有Codex MCP Apps；按URL绑定内置浏览器及刷新运行时后仍报 `Browser is not available: iab`。不得把用户已经打开网页改写为工具已经拿到可控句柄；不得提取Cookie或改用隐藏管理员接口绕过。之前Windows浏览器操作也曾因无法确定URL被工具终止。

先完成本机原签名构建和摘要核验；浏览器连接恢复后通过真实后台上传最终APK、核对1.0.12/code33候选并发布。只读公开health必须与最终包的版本、大小、SHA256一致，另验完整下载、HTTP206续传与安装前Range更新说明。所有结果未完成前均不能声称“已发布”。

## 主要入口

- `platform_capabilities.dart`：酷狗专属入口和旧路由访问限制。
- `netease/netease_extended_routes.dart`、`netease_supplement_routes.dart`：固定上游合约。
- `netease/netease_features_repository.dart`、`netease_features_page.dart`：网易云功能目录和分派。
- `netease/netease_fallback.dart`：优先原流、BugPk同ID及严格公开补源。
- `netease/netease_listening_reporter.dart`：实际秒数、持久发送日志和账号隔离。
- `lib/features/downloads/`：下载队列、格式识别、取消、重试和导出。
- Android `MusicDownloadBridge.kt`、`NeteaseCloudFileBridge.kt`：设备文件导出与明确云盘文件选择，不操作手机测试。

主机验证26文件273项通过；64条协议合约由固定npm模块独立生成。新增92项包含协议／补源／下载77项、实际时长4项、界面11项，与273项重合。额外真实匿名在线目录1项涉及8类，不能与离线项混算或称真实账号验收。

继续保持双平台登录、各账号暂停保存／暂停恢复、原玻璃与动效；SDK appId=music、P2P/P8P接收开启、分享关闭。签名、密码和管理凭据不进入Git／源码ZIP／后台；不使用ADB或访问手机。新需求依AGENTS逐题澄清，用户确认方案后实施。

## 最终安装包

原签名构建与APK结构核验已完成。文件 `release/Mesting-Music-v1.0.12.apk`，102048657 字节，SHA256 `4085984c595fca2c8bf6dc5c52e2576bd30d71b31122e92dab1b253504fa6def`。v2/v3签名、双ARM、ZIP/ELF对齐、CRC、八条随包更新说明、离线LICENSE/NOTICE、QA字体和integration_test插件排除均通过。仍未上传或公开发布；发布清单在 `release/Mesting-Music-v1.0.12-publish.json`。
