# Mesting Music 1.0.21 / code42 本地交付与待补测

日期2026-10-30（Asia/Shanghai）。用户确认扩大到四个tab、歌曲/歌单列表、歌手/专辑、搜索、完整播放器、歌词与队列的性能和原生闪退排查，保留完整玻璃及动画，交付原签名APK供用户自行安装。

**已完成本地修复、正式构建与主机回归；初轮扩展页面实测和七场景原生性能采样已完成。图片传输跟进后的最后一轮实机核对因手机断开仍待完成，不把它写成通过。**

- 正式APK：[Mesting-Music-v1.0.21.apk](release/Mesting-Music-v1.0.21.apk)，104724095字节，SHA-256 `f8a339f1abbb7045e4dc3ab5151459ee1bba88d680cfe70cded9545450a96a4f`。正式名称Mesting Music，包名com.mesting.music.beta，双ARM、code42，原证书与1.0.20一致。APK CRC、16KiB ZIP/ARM64 ELF、ARM32 ELF、资源/许可/原生桥接和诊断关闭核验通过，无集成测试插件或生成歌词。
- 完整源码：[Mesting-Music-v1.0.21-source.zip](Mesting-Music-v1.0.21-source.zip)。大小、摘要与文件数以[源码核验](release/Mesting-Music-v1.0.21-source-verification.json)和ZIP内SOURCE-SNAPSHOT.json为准。[APK核验](release/Mesting-Music-v1.0.21-verification.json)、[校验清单](release/Mesting-Music-v1.0.21-SHA256.txt)与[validation](docs/validation-2026-10-30-v1.0.21.json)记录真实状态。
- 58文件1109项Beta、stable19项、Android返回1项与静态分析0问题通过。另有播放器视觉6项和渲染细化10项，不重复累加。最终APK内更新说明与历史一致，生产Range读取器在本地精确APK上核对，不代表已上传服务端。
- 导航按真实路由动画完成调度第一个和最终tab请求；播放器快速切换最多两棵内容树并复用反向状态，保留360ms进入/280ms退出曲线；精确几何纹理LRU、句柄所有权和内存压力清理；300ms滚动胶囊目标合并。没有修改光学shader或降低玻璃与动画质量。
- 独立com.mesting.music.beta.benchmark、--keep-app-running、同脚本七场景，基线和渲染候选均通过。快速tab raster p95 51.998→16.201ms；歌词滚动16.686→9.295ms；歌曲/歌单滚动仍约20ms。不是全App稳定120fps。早期预算告警失败保留，最终告警0，不能把早期失败计为通过。
- 原1.0.20/code41手机APK与冻结包摘要一致；14:06:30.097、pid4447、1.raster、Adreno Vulkan vkCmdBeginRenderPass SIGSEGV/0x1c再次发生，具体触发根因未证明。候选有限测试没有新闪退，不能称已根治。退出回读中17:13:32 OneKeyClean为用户请求，不计闪退。
- 约19:02～19:10，原签名诊断候选pid15959完成48次快速tab、我的页与喜欢歌曲列表、播放器展开收回、歌词/队列、歌手榜/详情、新碟/专辑详情及真实搜索结果的快速进入/返回/滚动，进程存活，系统退出记录没有新增原生闪退。没有清数据、卸载、由代理强停日常应用、发送/代读聊天或提取凭据。
- 初轮歌手图片仍占位。随后同一手机公共HTTP实测：Dart默认标识、组合标识及双User-Agent均403，单独应用标识200/45453字节。Flutter NetworkImage使用headers.add，追加后仍带Dart值；磁盘缓存使用替换，因此两条加载路径不同。新增局部ArtworkNetworkImage统一单标识，其他CDN保持原Provider；真实本机HTTP、解码、403恢复等4项已加入主组。详见[修改](docs/fixes-2026-10-30-v1.0.21.md)。
- 图片跟进诊断候选75036141字节，SHA-256 `71dcf79363daf2ae2e3e78f61351a0165a883eebcf3e2e38cf0b330c8986b38b`，已验证原签名，但手机断开后尚未安装/目视核对。最后已请求重连约3分钟，该请求待回应。手机上最后观察到的是更早的1.0.21/code42诊断候选，不能把相同版本号当成已安装最终修复。正式双ARM包也尚未安装，用户选择自行覆盖。

接手先看[安装说明](docs/INSTALL-v1.0.21.md)、[性能及证据边界](docs/PERFORMANCE-2026-10-30-v1.0.21.md)与validation。原生分位数早于最后图片传输跟进，不冒充其后的第二次全场景采样。若重连，先核对诊断候选摘要，原签名覆盖安装，检查歌手封面、我的创建/收藏封面和消息徽标，再快速切tab/滚动及退出回读；保留真实记录，不能直接把pending改成通过。

工程D:/AnLi，beta / 8763551c0cc39c1c25f60e42fd49624f58d91a89。全部未提交变化、暂存区和旧冻结交付保留；19个旧冻结文件及依赖锁摘要均核对。没有Git提交/推送、GitHub发布或music后台操作。正式包与源码只本地准备。第三方许可保留，SDK分享继续关闭，私有签名不入源码。

Flutter3.41.9 / Dart3.11.5 / engine42d3d75、Java17。正式构建入口tool/build_android_release_apk.ps1默认1.0.21/code42，未启用MESTING_LOCAL_DIAGNOSTICS。依赖锁SHA-256为6316dd4a0989c4a89b32d2a9a82bf603203743175909b52395a2d97cc4f2b5cc。私有签名、候选APK、手机截图和原始日志保存在被忽略的.codex-artifacts目录，不公开。

新需求依AGENTS逐题澄清、确认方案后实施。无新的明确授权不访问手机/ADB、真实账号或后台，不提交推送，不覆盖冻结交付，不关闭保留的music网页。
