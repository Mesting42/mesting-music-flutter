# Mesting Music 1.0.24 / code45 本地交付与后续接续

日期：2026-10-31，Asia/Shanghai。本文件取代旧交接中的“1.0.24 尚未编码/构建”，旧交接保留各自历史状态。

唯一工程仍为 `D:/AnLi/Mesting-Music-Flutter/app-md3music-beta`，分支 beta，HEAD `15023fec8e903e40ff3841f10a396580ee1860ef`。本轮使用原本脏工作区，未 reset/clean、拉取覆盖、另建 worktree、Git 提交或推送。当前源码包含 1.0.23-r2 原有未提交内容和本轮 1.0.24 内容。

本版五组需求均已编码并完成主机验证：统一双平台签到、独立保存酷狗账号补源、下载状态/进度/字节/波形与分页、音效封面/公共底栏/同类分页/键盘恢复、App 内连续双平台流畅度诊断。详细实现见 [修改说明](docs/fixes-2026-10-31-v1.0.24.md)，诊断适用页面/排除项/断点边界见 [场景说明](docs/DIAGNOSTIC-SCENARIOS-v1.0.24.md)。

本地交付入口：

- `release/Mesting-Music-v1.0.24.apk`，107222734 字节，SHA256 `7f10e55588106d0f7cdd65f726e9e398c441e10f1c92cf396265be3bed020163`。
- `Mesting-Music-v1.0.24-source.zip`，完整源码与固定引擎；摘要及每文件校验结果见外置 `release/Mesting-Music-v1.0.24-source-verification.json` 和 `release/Mesting-Music-v1.0.24-SHA256.txt`。避免把源码 ZIP 自己的摘要写回它包含的文件。
- `docs/INSTALL-v1.0.24.md` 与 `docs/validation-2026-10-31-v1.0.24.json`。

APK 使用原升级证书 `8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333`、`com.mesting.music.beta`、1.0.24/code45、双 ARM、Release/不可调试。V2/V3、ZIP CRC、16KiB APK 对齐、ELF 对齐、包内更新说明、69 项正式包素材排除已检查。两份定制引擎逐字节匹配 R2，7 个玻璃着色器、8 个 SDK 原生库与 8 个原许可载荷保持；没有重建或替换引擎。新包实际运行后端尚未手机复核，不能从包内字节直接声称本次手机已验收。

最终主机验证：70 个 Beta 测试文件共 1197 项通过，Stable 2 文件 19 项通过，保留引擎 Android 返回行为 1 项通过；所有修改/新增 Dart 源码与测试静态分析 0 问题。原生栈解析 11 项、Vulkan 签名 10 项通过；新增 Android 导出类通过正式 Kotlin 编译。真实音效/下载页的浅色、深色、常宽、窄屏大字号交互/几何回归通过；主机截图中部分标签存在宿主字体回退，不能作为 Android 字形或 GPU 玻璃验收。签名 APK 的生产 Range 更新说明读取通过。明细与各文件次数以验证 JSON 为准，不累加重复运行。

手机测试继续被用户暂停。本轮没有 ADB、触控、安装、真实已保存平台账号操作或 music/GitHub 发布。尚待用户验证真实账号签到/到账与音源权益、1.0.24 手机启动及完整自动诊断一轮、GPU 性能/原生长期稳定性。Together 官版与 Mesting 双端互通/距离仍由用户自行测试，未记通过。不能宣称持续 120 FPS 或永久修复 Adreno 驱动。

当前源码的维护入口与注意点：

1. `retained_kugou_scope.dart` 独立保存身份、持久化变更单元、作用域撤销；`MusicPlatformApi.sessionCurrent` 守卫覆盖内部后续请求。不要临时替换共享 `session`、Cookie 或播放器 owner。保存账号更换必须先撤销旧请求和缓存，再等待音频/路由切换。
2. `UnifiedRewardPage` 复用原酷狗 Calendar/Controller/Verification，网易云有独立凭据代次。诊断活动门控在首次切平台前设置，签到、领取、验证码后续写操作均检查；结束不会重放诊断期间跳过的奖励动作。只读取报告不激活门控。
3. `AccountKugouFallback` 与统一 resolver 仍严格核对同录音、试听和时长。音质按 MP3/FLAC 实际头信息，不能把请求档位直接当结果。网易云歌曲/队列身份保持，公开请求不带账号鉴权。
4. `BetaSwipePages` 必须在 initState 捕获初始 index；惰性字段首次在 didUpdateWidget 读取会吞掉第一次点击。减少动画用 jumpToPage，不能给 animateToPage 传 Duration.zero。隐藏页不得抢公共搜索/纵滚所有权。
5. `BetaSecondaryMusicLayout` 复用原公共栏与胶囊；`BetaContentInsets` 把空间留在滚动内容内，`BetaGlassScrollBody` 保留真实取样背板。不要改回额外不透明底部盒子。评论/聊天通过 `musicChrome: false` 保留原玻璃输入栏，避免导航覆盖发送。
6. 键盘以真实 View inset 判断，收起后筛选仍有效也恢复胶囊；已有 Scaffold 消耗的键盘高度不能再叠加。窄屏大字号不要把完整运输控件硬挤进 inline 胶囊。
7. 下载的 resolving 与 queued 分开；尝试代次覆盖取消/立即重试/保存迟到；EOF 后保存成功才算完成。未知总量不伪造 0/0 或完成状态。完成页与任务页严格分离。
8. 音效真实图片主机 `mobileservice.bssdl.kugou.com` 的官方 HTTP 返回有效，HTTPS 证书域名不匹配。只精确保留该公共图片主机的 HTTP，不关闭 TLS 验证或推广为全站降级。匿名原响应存在私有证据目录，不能随源码交付。
9. 自动诊断的 `DiagnosticRunController` 管取消/游标/分段持久化，`ProductionDiagnosticDriver` 只导航与滚动真实页面。超时后的票据阻止迟到导航；返回可能先关闭本地搜索历史，要核对原路由确实离开。根路由重入必须真的经过另一生产路由，不能在同一路由假报动画。恢复原平台/游客但不自动播放。
10. `FrameTimingProbe` 原始 vsync 边界、每段 14000 帧/90 秒上限和 Stop 1.2 秒 drain 保留；不能把整轮所有帧无限堆内存。JSON 主动导出独立于 Release 编译关闭的旧调试导出分支。缺数据、零帧、排除项不能记通过。
11. Kotlin 文件目录仍有旧 `mesting_music` 段，但包声明为 `com.mesting.music`。新增导出类首次构建曾因此不匹配，已修正。不要按目录名盲写 namespace。
12. 签名助手不覆盖已冻结 APK；口令仅环境变量。嵌套 Windows PowerShell 曾缺少 Get-FileHash 模块，助手已改用 .NET SHA256 并独立自检通过；禁用不需要的 v4 外置 idsig，保留 V2/V3。不能因最终打印摘要失败就覆盖重签同名已成功 APK。

正式构建仍使用 Flutter `D:/flutter/mesting-beta5/flutter` 3.41.9、Android Build Tools 36.1.0 和 Android Studio JBR，`tool/build_android_release_apk.ps1` 默认已设 1.0.24/code45。构建的 pub 阶段必须保留以重建测试后可能残留的原生 registrant，锁文件不得漂移。构建进程使用局部 Gradle 堆 3GiB/worker2，未修改用户全局内存设置。

私有日志、原图、匿名探测响应、签名校验过程和冻结助手在 `.codex-artifacts/2026-10-31-release124/`，继承参考图在 `.codex-artifacts/2026-10-31-handoff124/references/`，不得进入源码 ZIP 或提交。旧 R2 `release/Mesting-Music-v1.0.23-r2.apk` SHA256 仍为 `306f66d8ec2426de98bf52f251220d56a57cd907fd028eb27d100b223c9b56b5`，原字节保留。

后续仍遵守逐题澄清新需求、确认后实施、职责解耦与必要注释的约定。本版已确认范围无需重复问答。没有新的明确授权，不访问手机、真实账号、提交推送或发布后台。
