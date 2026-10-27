# Mesting Music 1.0.5 接续

日期：2026-10-28（Asia/Shanghai）。用户已确认本轮全部修改和 Git/GitHub 三版归档。具体行为见 [1.0.5 修改](fixes-2026-10-28-v1.0.5.md)。

## 交付身份

| 项目 | 值 |
| --- | --- |
| 版本 / 实际 code | 1.0.5 / 26 |
| 包名 / flavor | com.mesting.music.beta / beta |
| APK | release/Mesting-Music-v1.0.5.apk |
| 大小 | 97,702,493 字节 |
| SHA-256 | 48F99ABCFB2381EE1E499EC1E0E935449D498D8233BEC8F95BE7D0EB4798FDF1 |
| 证书 SHA-256 | 8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333 |
| GitHub 标签 | v1.0.5；维护分支 beta |
| 原签名 / ABI | v2/v3；ARM32 + ARM64；Release 非 debuggable |
| 对齐 | ZIP 16KiB、ARM64 ELF 16KiB；ARM32 ELF 4KiB |

签名后 525 个非签名条目与构建输出一致；RingDownloadPlugin、FlutterWebRTCPlugin 已入包，IntegrationTestPlugin 未入包。1.0.4 的 63 项既有 shipping assets 逐字节保留，69 项旧 stable 专用素材继续排除，Windows QA 字体未入包。

## Git/GitHub 与 music 后台是两个状态

- 1.0.3、1.0.4 均按冻结源码建立独立归档提交，所有原始文件与 ZIP 字节一致，旧 APK/ZIP 不重建或重打包。详情见 [补档记录](version-archive/RELEASE-BACKFILL-2026-10-28.md)。
- 用户明确确认取得 SDK 源码公开分发授权，要求完整源码推送 GitHub，供换电脑接续；不修改 SDK 原 LICENSE/所有权。签名材料和凭据仍仅私有保存。
- 三版 Release 入口为仓库的 `v1.0.3`、`v1.0.4`、`v1.0.5`，1.0.5 为最新。GitHub 上的版本、附件摘要由发布后的回读记录核验；原包核验 JSON 中 Git/published 字段是构建时记录，不作为最新分发状态。
- **music 后台尚未发布 1.0.5**。浏览器工具无法可靠识别 Windows 当前 URL，安全检查中止了管理 UI；没有绕过限制、提取 Cookie 或调用隐蔽管理接口。公开 health 本次回读仍为 **1.0.4 / 25**。用户已授权的下一步仅是把上述原签名 1.0.5 APK 上传并暂存到现有 music，校对 version/code/size/SHA 后发布，再验证旧客户端完整下载/续传。不重新上传 1.0.3/1.0.4。

## 验证与限制

最终受影响 Beta 分组为 **179 通过 / 0 失败**，包括新回归、资料、音频工具、更新、输入框编辑、MV 生命周期、底栏与旧播放器交互。初轮旧期望失败和一次测试点中“播放”分组标题的记录保留；目标修正后整组重跑通过。各次重跑不重复累加。

42 张生产控件主机捕获覆盖浅深色、小屏大字、宽屏、滚动输入、样式折叠、新图标与过渡中间态，已完成视觉复核。主机 MV 方法通道测试验证横屏请求、系统 Back 恢复竖屏；真实视频控制器夹具验证进出全屏不新建/释放控制器。液态菜单动画反向连续，菜单子树不随绘制 tick 重建。

原始证据在 `.codex-artifacts/2026-10-28-release105/`，便携摘要在 `docs/version-archive/v1.0.5-evidence/`。选定 stable 回归 **56 通过 / 0 失败**，最终分析无问题；完整记录以该目录为准；没有重跑旧 stable 全量套件。Debug UI 夹具的多数据库警告是测试夹具隔离提示，没有将其写成生产数据库验收。

本轮无手机/ADB/安装。主机证据不能认证 Android GPU 的原生液态融合、持续 120fps、CPU 满载彻底解决、真实 P8P 节点贡献、厂商横屏/前后台策略或覆盖安装。真实账号写入、音频听感、MV 解码与设备行为由用户自行测试；旧 stable 历史两项问题没有宣称修复。

## 换电脑

先读 [接续入口](CONTINUE-BETA.md)。使用 Flutter 3.41.9 / Dart 3.11.5，沿用锁文件 `6E29E2A4B236776D9E7C1BCD458783D0214F0EF151E7DC793B0B4E5AD7591DD0`，不全量升级。项目根 pubspec 的共享旧 stable 版本不改，正式构建入口显式覆盖为 1.0.5/26。

SDK 完整源码与本地 path 依赖随仓库提供；它只管理更新 APK 下载，分享仍为 false。原签名 ZIP/keystore 需私有转移，不能把新电脑自动生成的 debug 密钥当成原证书。后续正式版实际 code 必须大于 26。
