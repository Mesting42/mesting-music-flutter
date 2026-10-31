# Mesting Music 1.0.20 / code41 本地交付接续

日期：2026-10-30（Asia/Shanghai）。在1.0.19实机报告基础上，逐题澄清并获用户确认1.0.20方案后实施。用户明确授权本轮手机/ADB诊断与复测；结束时选择自行安装正式APK，后续不自动访问手机。

- Git为beta / 8763551c0cc39c1c25f60e42fd49624f58d91a89；保留1.0.19及本轮全部未提交工作，不reset/clean/拉取覆盖，不提交推送。公开归档基线仍以1.0.18跨电脑交接为准，未发布本轮GitHub/music。
- 正式APK：release/Mesting-Music-v1.0.20.apk，104642175字节；SHA-256为73e60f7b9681567fbfc81269496dad3e0bfa651b8cca60e9e4e0ddd30944f635。
- 完整源码：根目录Mesting-Music-v1.0.20-source.zip；大小、摘要、文件清单与CRC以release/Mesting-Music-v1.0.20-source-verification.json及ZIP内SOURCE-SNAPSHOT.json为准。旧冻结文件全部保留。
- 包名com.mesting.music.beta，原证书8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333，双ARM、code41。正式包与手机诊断候选同code但字节不同，用户需用正式包手动覆盖，正式APK安装结果尚未验收。
- 55文件1093项Beta、stable19项、Android返回1项通过，静态分析0问题。阴影像素三项包含在Beta主组，不重复累加；原生滚动/控件套件、原签名/CRC/对齐/许可和生产Range说明读取通过。
- 封面403请求标识与未读短字段已由实际App链路确认；诊断候选实机显示两个创建歌单、两个收藏歌单、歌手榜封面和消息徽标。未发送消息、代读聊天或提取凭据，未执行账号写操作。
- 同脚本原生profile：raster p95为18.343→15.638ms，超过16.67ms比例7.4%→3.0%。仅特定滚动/胶囊场景单次结果，存在匿名动态背景、系统通知、低电量/温度变量，不是全App持续FPS验收。玻璃着色器/参数/动画保留。
- 原闪退确认在Adreno Vulkan驱动，具体触发根因与永久修复未证明；本轮有限测试未复现，不能称已根治。手机断开后未回读后续系统退出记录。

先读[修改](docs/fixes-2026-10-30-v1.0.20.md)、[安装](docs/INSTALL-v1.0.20.md)、[性能及闪退边界](docs/PERFORMANCE-2026-10-30-v1.0.20.md)和[验证](docs/validation-2026-10-30-v1.0.20.json)。原始手机日志/截图/候选APK在被Git忽略的.codex-artifacts/2026-10-30-release120，不放源码ZIP或公开账号内容。

Flutter3.41.9/Dart3.11.5、engine42d3d75、Java17。依赖锁SHA-256为6316dd4a0989c4a89b32d2a9a82bf603203743175909b52395a2d97cc4f2b5cc；正式构建入口tool/build_android_release_apk.ps1默认1.0.20/code41，未启用诊断开关。私下原签名密钥不入源码ZIP，SDK许可/第三方声明保留，SDK分享继续关闭。

接手先只读核对Git、工作区和最新交付验证。新需求按AGENTS.md一次一问、确认方案后实施。没有新授权不发布后台、不提交推送、不访问手机/ADB/真实账号，不关闭保留的music网页。
