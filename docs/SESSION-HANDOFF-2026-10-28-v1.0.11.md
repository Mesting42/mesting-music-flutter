# Mesting Music 1.0.11 接续

日期：2026-10-28（Asia/Shanghai）。工程根：`D:/AnLi/Mesting-Music-Flutter/app-md3music-beta`。

<!-- publication-state -->
**1.0.11 / Android code32 已在 music 公开发布并完成线上核验。** 后台当前公开版本、公开 health、完整 APK 下载的大小与 SHA-256、暂停后 HTTP 206 断点续传，以及生产 `PublicApkReleaseNotes` 的安装前 Range 更新说明读取均通过。公开记录创建时间为 2026-10-28 23:39:53；后台截图保存在本机证据目录。本轮只发布这份最新 APK，没有向后台上传源码或密钥。
<!-- /publication-state -->

## 用户确认的范围

欢迎页先酷狗、再网易云，点击后进入对应平台的完整登录方式列表，游客入口保留。酷狗提供手机号、酷狗扫码、微信扫码、QQ 扫码；网易云提供网易云扫码、手机验证码、手机密码、邮箱密码。页面、控件、胶囊播放器、交互和过渡效果沿用现有酷狗实现。

两边分别保存登录状态。“我的”可以直接切换平台：离开时暂停并保存当前歌曲、队列与位置；进入目标平台后恢复自己的快照并保持暂停，用户手动播放。明确退出登录仅删除当前平台凭据，保留其播放快照和另一平台登录状态。用户曾误选“清空队列”和“不保留登录”，随后明确纠正，不能按误选实施。

用户确认版本 **1.0.11 / Android code32**。用户自行真机验收；没有新的明确授权，不使用 ADB、不连接或操作手机。

## 成果与代码入口

实现说明见 [1.0.11 修改记录](fixes-2026-10-28-v1.0.11.md)，可移交核验摘要见 [验证 JSON](validation-2026-10-28-v1.0.11.json)。新增代码主要在 `lib/features/music_platform/netease/`。协议、安全存储、登录与业务仓库分开；平台分派集中在 `platform_backend_providers.dart`，登录方式与切换页在 `presentation/platform_login_options_page.dart`。共用模型和页面处理歌单、资料、评论、MV、歌词与音质。

账号变更由 `PlatformAccountController` 串行处理，通过注入回调暂停和保存原播放器，不创建第二个音频处理器。数据使用平台与账号共同标识；酷狗旧数据范围兼容，网易云 Cookie 不进入酷狗传输或听歌同步任务。搜索和异步响应具有账号隔离与过期结果检查。详细注释、MIT 声明和离线许可证随源码及 APK 保留。

## 最终 APK

- 文件：`release/Mesting-Music-v1.0.11.apk`，**101,655,441 字节**。
- SHA-256：`3F63EE0B26584C3DB2CD6AB0A953B859E132773F288BABB26B2BEFB80617F8E5`。
- 包名：`com.mesting.music.beta`；名称：Mesting Music；版本：1.0.11 / 32。
- 原证书 SHA-256：`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。
- v2/v3 签名、不可调试、min24/target36、ARM32/ARM64、ZIP CRC、ZIP/ARM64 ELF 16KiB 和 ARM32 ELF 4KiB 对齐已核验。
- 随包六条版本说明与源 JSON 完全一致；网易云 MIT LICENSE/NOTICE 已打包并登记到既有许可证列表；69 项旧正式渠道专用素材未进入 Beta 包，主机 QA 字体及 integration_test 插件未混入。

完整 APK 核验见 `release/Mesting-Music-v1.0.11-verification.json`。第一次仅缺离线许可证的本机构建保存在忽略的 `pre-license/` 证据中，不是交付文件。不能拿它或原始 build 目录中临时 debug 签名包覆盖最终交付。

## 验证与实际边界

17 个相关测试文件一次运行 150 项通过；静态分析无问题。修改测试提示后又跑过 6 项适配器检查，该 6 项与 150 有重合，不相加声称唯一总数。10 项界面测试已覆盖浅色、深色、小屏与大字体，截图已查看。AES/RSA 对照向量由独立 Node 标准加密库生成。

真实公开接口仅执行匿名二维码生成和搜索，均成功。没有发送短信，没有使用真实网易云账号登录、上传头像或写入云端歌单/评论。真实账号登录、接口风控或验证、会员版权歌曲播放、两平台覆盖升级及手机交互仍由用户验收；主机截图不证明持续 120fps。网易云不会伪造酷狗官版听歌累计或奖励数据。

## 源码与 Git 状态

当前分支保持 `codex/release-1.0.4`，基线 HEAD `d609805aef6cb1136e14a535233d3aa760ae62d0`。本版改动均在工作区，**没有提交或推送 1.0.11 到 Git/GitHub**。此前 1.0.3～1.0.10 的归档保持，远端接续旧版说明见 [1.0.10 GitHub 接续](../HANDOFF-CURRENT-SESSION-2026-10-28-GITHUB-CONTINUE.md)。不要 reset、clean 或切换分支覆盖现有改动。

本次开始时已经存在的 14 个修改文件在工程外恢复备份中保留，本版在这些改动上继续完成。原会话数据库缺口未能完整恢复，用户已放弃继续搜索；不能声称丢失记录已找回。当前实现以用户重新确认的需求、仓库和这份交接为准。

最终源码归档为 `Mesting-Music-v1.0.11-source.zip`，在发布核验完成后冻结。逐文件路径、大小和 SHA-256 放在归档内 `SOURCE-SNAPSHOT.json`；整包摘要单独保存于 `release/Mesting-Music-v1.0.11-source.sha256`，避免自引用。源码包括授权 SDK 与声明，排除私钥、密码、本机配置、缓存及真实账号数据。不向 music 后台上传源码或密钥。后续电脑若直接 clone 现有远端，只能取得已归档的 1.0.10；接续本版需同时使用这个完整源码 ZIP，不能误以为远端已含 1.0.11。

## 线上交付证据

公开入口：[Mesting Music 下载](https://download.csnas.asia/music/download)，[只读 health](https://download.csnas.asia/api/app/music/health)。公开健康数据识别 1.0.11 / 32、101,655,441 字节和上述完整摘要。使用现有更新仓库模拟已安装 1.0.10 / 31 时，能发现本版更新；下载在 2,118,783 字节处暂停，随后请求 `Range: bytes=2118783-` 得到 206，完整文件摘要与签名交付包相同。

另外强制调用现有 `PublicApkReleaseNotes`，没有依赖本机新增的内置历史，线上三个 Range 读取返回 206，并解析出与本版 JSON 完全相同的六条中文更新说明。相关主机在线专项 1 项通过，与离线 150 项分开记录。可移交结果放在 `release/Mesting-Music-v1.0.11-public-verification.json`；它不包含登录或管理凭据。

过程曾因 FRP 上传等待与应用中断导致候选卡片未显示；后端实际保留了候选，刷新后台后读取到它。不要将浏览器进度 100% 单独当作发布完成依据。本版最终状态以上面后台与公开入口读回结果为准，不再重传同一版本。

## 重现环境

使用 Flutter **3.41.9** / Dart **3.11.5**。此机实际使用 Android Studio JBR **21.0.10**，Java/Kotlin 编译目标保持 17；Android SDK 36、NDK28.2.13676358，核验工具为 build-tools36.0.0。脚本需要 PowerShell 7；Windows PowerShell 5 的模块或 .NET 接口差异不应通过修改业务代码绕过。

`pubspec.lock` SHA-256：`6316DD4A0989C4A89B32D2A9A82BF603203743175909B52395A2D97CC4F2B5CC`。新增依赖仅固定 `pointycastle` 4.0.0、`qr_flutter` 4.1.0 及其锁定依赖。不要全量升级依赖。

```powershell
$musicFlutter = 'D:/你的Flutter目录/flutter'
& "$musicFlutter/bin/flutter.bat" pub get --enforce-lockfile
& "$musicFlutter/bin/flutter.bat" analyze --no-pub
$musicValidation = Get-Content -LiteralPath 'docs/validation-2026-10-28-v1.0.11.json' -Raw -Encoding UTF8 | ConvertFrom-Json
$musicTests = @($musicValidation.regression.files)
& "$musicFlutter/bin/flutter.bat" test --no-pub --flavor beta @musicTests
./tool/build_android_release_apk.ps1 -FlutterSdkRoot $musicFlutter -VersionName '1.0.11' -VersionCode 32
```

本机构建临时使用 3GB heap、2 workers；`android/gradle.properties` 在构建后已逐字节恢复。构建保留 pub 阶段，防止运行测试后开发插件注册进入 Release。共享 `pubspec.yaml` 的旧 stable 版本没有改动，本次公开身份由 Beta 发布脚本的参数决定。

原密钥和密码需私下转移。工程现有 Gradle 签名配置默认使用 debug 密钥，另一台机器自己生成的 debug 证书不能覆盖现有安装；必须使用同一原密钥并核对上面证书。SDK 保持 appId music、P2P/P8P 接收开启、用户分享关闭，未改动 SDK 实现。

后续新版本的 Android code 必须大于 32，更新随包说明与内置历史，不能覆盖冻结包或重发同 code。后续新需求仍遵守 AGENTS.md 的逐题澄清与先确认方案规则。
