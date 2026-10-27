# Mesting Music 当前会话总交接

**本文件为 1.0.4 时点的完整历史交接。当前入口已更新为 [1.0.5 总交接](HANDOFF-CURRENT-SESSION-2026-10-28-v1.0.5.md)，涉及 Git/GitHub、SDK 分发授权与待发布状态以新入口为准。**

交接日期：2026-10-28（Asia/Shanghai）。按用户要求汇总本会话的完成结果、未完成事项和接续注意点。成文前已重新核对本地工作区、冻结文件摘要、GitHub 远端引用及 music 公开版本接口。

## 1. 当前状态与第一步

| 项目 | 已核对事实 |
| --- | --- |
| 实际工程 | `D:/AnLi/Mesting-Music-Flutter/app-md3music-beta` |
| 当前正式产品 | **Mesting Music 1.0.4 / Android code 25** |
| 发布目标 | `https://download.csnas.asia/admin` 的 **Mesting Music · music** |
| 包名 / flavor | `com.mesting.music.beta` / `beta`，仅作覆盖升级兼容 |
| 本地分支 | `codex/release-1.0.4` |
| 本地 HEAD | `95d5719829a754978ba615a873aa6ddff08f67f6`，已归档 v1.0.2 |
| 工作区 | **大量修改和未跟踪文件，包含完整 1.0.3/1.0.4 实现** |
| GitHub beta | 远端核验仍为上述 1.0.2 提交；没有 v1.0.3/v1.0.4 标签 |
| GitHub main | `eb49d72d3c73aafc50db33ba1b224559e2ca279f`，旧产品线，未替换 |
| 最新任务 | 1.0.3 与 SDK 1.0.4 均已实现、构建、原签名、发布和线上下载核验；没有待执行的 SDK 接入或发布动作 |

新会话先阅读本文与 [AGENTS](AGENTS.md)，只读核验并报告接手情况，等待用户下一项具体需求。聊天所在的 Codex 项目可能只是 `C:/Users/Mest` 的“Mest”，不是工程根目录；工程命令必须显式使用上面的 D 盘目录。

不能拿远端旧 beta 覆盖当前脏树；不要 reset/clean，不创建只含 HEAD 而丢失未提交改动的替代工作区。本轮交接不授权自动继续开发、手机测试、Git 推送或再次发布。

## 2. 已完成什么

### 2.1 历史性能、素材及版本接续

这些是本会话历史和当前产品继承状态，不是新会话要重做的任务，来源以各版冻结记录为准。

- Beta.19 保留完整玻璃模糊、折射、形变、回弹和胶囊开合，通过几何/合成缓存、离屏 pass 与 ticker 生命周期减少开销。
- 修复震动/手机登录蓝色按钮、签到相关白底黑字按钮在往返滚动和回弹时采到错误背景的问题。签到、听音乐领取、自动领取保留白底黑字。
- 按用户选择，仅当前 beta 产品移除 Mesting 登录/注册入口及 69 项旧 stable 专用入包素材；旧 stable 功能与原素材源码保留。有效 IP 进度条、角色和现用素材保留。
- 加入两张用户原始 PNG 静态启动页，首次升级迁移为图一一次，之后保存用户选择；取消静态启动固定等待并并行准备依赖。
- 小新太阳、微风、夕阳、夜晚、细雨、雷雨、游行七种效果均作为独立手动选项并持久化。
- Beta.1–13 原始源码/APK 已找回补档，既有 Beta.14–17 历史保留，Beta.18/19 已归档。后续补档记录还覆盖 Beta.20/21、正式 1.0.1/1.0.2；旧标签、Release 和冻结文件不覆盖。
- 正式 1.0.2 是本次新功能基线，其首页栏目、输出设备等属于继承实现，不归为本轮 1.0.3/1.0.4 新增代码。历史见 [Git 补档](docs/version-archive/RELEASE-BACKFILL-2026-10-27.md) 与 [版本索引](BETA_ARCHIVE.md)。

历史小米 14 Pro 隔离 Profile 对比：Beta.18 → Beta.19 的 Raster P95 为 31.684 → 25.311ms，下降 20.11%；超过 8.33ms 帧占比为 36.87% → 31.39%。不能据此认证持续 120fps，也没有足够等条件 CPU 占用对照，不能说 CPU 100% 已彻底解决。有效场景和边界见 [Beta.19 记录](docs/fixes-2026-10-27-beta19.md)。

### 2.2 正式 1.0.3 / code 24

已按用户逐项确认范围完成并先行发布：

- 共享玻璃按钮/图标禁用态分别适配浅深色。触感关闭后“体验触感”仍可辨认且不可点击，开启后才高亮；保留完整玻璃光学。
- 更新抽屉新增“查看此次更新”，最新版也可查看本版说明，按精确版本匹配，不给未知版本借用旧说明。
- 真实酷狗资料编辑六项：头像、昵称、性别、生日、个性签名、地区。头像先预览再明确上传；只保存变更字段，失败保留草稿，账号/凭证变化拒绝旧结果；头像遵循平台审核。
- 离线省市两级选择，覆盖 31 个内地省级地区，保留原账号目录外地区。
- 原生均衡器绑定现有音乐会话，九个预设/自定义频段持久化，使用设备实际频段/范围，初始化移出 UI 线程。
- 音效目录接真实接口，免费条目按原版映射为均衡预设；未实现或声称 IRS/VPF 卷积，筛选只针对已加载条目。
- MV 使用真实录音/视频元数据、地址与清晰度，支持进度和全屏。进入暂停音乐，退出只在进入前播放且未被后续命令取代时恢复；用户/定时器的后续暂停优先。
- 定时关闭支持预置、自定义倒计时或曲终停止，仅暂停并保留账号/应用；曲终计时临时处理单曲循环。计时不跨进程保存。
- 用户确认的均衡滑块为 **6dp 圆点 / 约 2dp 轨道 / 48dp 响应区**，无滑块阴影和按压放大。

沿用既有 Apple/iOS27 Cupertino 与 premium 玻璃体系。上游参考 md3Music v6.1.0，固定提交 `4f783a998d7a108685dfa2e3dc9449df9c474c4e`；许可/移植说明已保留。

### 2.3 正式 1.0.4 / code 25：P8P SDK

用户明确要求先发布 1.0.3，再接入交接包，并确认以 1.0.4/25 正式发布。**本阶段已经完成，不再处于“等 1.0.3 后开始”状态。**

- 本地依赖 Ring Download SDK 1.1.0，固定 `appId: music`、`enableP2P: true`、`enableP8P: true`、`allowSharing: false`；用户端上传分享关闭，音乐继续使用原 owner。
- 更新发现仍为 music/health、比较实际 APK code；SDK 管理 HTTPS 先行、可用节点、取消、续传及有界恢复。宿主不为 SDK 失败再启动重复整包 HTTP。
- 旧 HTTP partial 兼容完成一次，后续用 SDK 缓存；完成后 Music 再校验大小/SHA，原子移入原安装目录，安装前继续校验。
- 隐私说明披露实际网络协商/诊断，内置 1.0.4 更新说明，保留 1.0.3 全部功能和素材。
- SDK 196 个原文件中 194 项字节一致：生产文件仅去掉一个多余非空断言，测试文件修正从宿主根目录误读版本的假设。原 ZIP 冻结，详见 [SDK 来源](third_party/ring_download_sdk.SOURCE.md)。
- 原签名、双 ARM ABI、Release 非 debuggable、ZIP/ARM64 ELF 16KiB 对齐通过；签名后 525 个非签名条目与构建输出一致。相对 1.0.3 增约 19.83MiB，主要为 WebRTC 原生库。
- 已发布现有 music，后台当前公开版本及 health 均回读为 1.0.4/25，大小/SHA 与本地一致。服务端创建时间原文 `2026-10-28T00:20:05.815829`，不额外推定时区。

旧 1.0.2/1.0.3 升级到本版仍用旧 HTTPS；安装 1.0.4 后，后续更新才用 SDK。更新提醒仍是前台自动检查及“设置 → 版本更新”，保留原 15 分钟节流/稍后提醒偏好；没有新增独立系统推送或自动安装。

## 3. 交付文件与摘要

相对路径均以工程根目录为基准；成文时四份冻结文件 SHA-256 均重新计算并匹配。

| 交付 | 文件 | 大小/条目 | SHA-256 |
| --- | --- | --- | --- |
| 1.0.3 APK | `release/Mesting-Music-v1.0.3.apk` | 76,890,535 字节 | `A3003191040051B30A14AF4938BB9D4CFCAF857A1B8E3A6B9F4558944885A4BA` |
| 1.0.3 源码 | `Mesting-Music-v1.0.3-source.zip` | 47,494,313 字节 / 1203 项 | `70F5BDAF9D9618C2FCB60F3B7349DFC2B8212EB35B027120767EA882792A73D5` |
| 1.0.4 APK | `release/Mesting-Music-v1.0.4.apk` | 97,682,013 字节 / 93.16MiB | `FC14345A637A79D03A34E3CC8AE8C1F0B70697B8060751523160212AE79F6FB7` |
| 1.0.4 私有源码 | `Mesting-Music-v1.0.4-private-source.zip` | 48,040,537 字节 / 1419 项 | `89951D343C3BD8C633CAB7B0696A803B4D041E5B10A9FFC77E465ACFF2DD401C` |

快照逐条摘要全部核验，1.0.4 包含 SDK 原 196 个文件路径及两处已说明改动。私钥、账号报告、本机配置、构建缓存未入包。各版核验 JSON、摘要侧文件和安装说明在 `release/` 与根目录。

原签名证书 SHA-256：`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。

- [公开版本元数据](https://download.csnas.asia/api/app/music/health)
- [主下载](https://download.csnas.asia/music/download)
- [备下载](https://download1.csnas.asia/music/download?direct=backup)

**本文与此次入口修改在源码 ZIP 冻结后新增。不要为补入本文重打包旧 ZIP；跨电脑时同时携带私有源码 ZIP 和本总交接文档。**

## 4. 验证结果与边界

| 分组 | 有界结果 |
| --- | --- |
| 1.0.3 受影响 Beta 回归 | 122 通过 |
| 1.0.3 最终界面/6dp 拖动 | 22 通过，29 张主机捕获，独立复核 SHIP |
| 1.0.3 原生输出注册器 | 23 项主机断言通过 |
| 1.0.4 宿主接入及相关功能 | 80 通过 |
| 1.0.4 旧 stable 选定兼容 / Beta 隐私界面 | 18 / 2 通过 |
| SDK 六文件 | 首轮 213 通过、1 个元数据工作目录夹具失败；修正后该项隔离复测通过，保留原日志 |
| 静态分析、Android Release、签名与对齐 | 通过，详细记录保留 |
| 真实 SDK 主机下载 | 线上 1.0.3 在 2MiB 后暂停恢复、校验/移动通过；Windows 明确走 HTTPS，无 Android 节点贡献证明 |
| 冻结 1.0.3 原代码下载 1.0.4 | 发现更新、1MiB 暂停、Range 续传、全包大小/SHA 通过；模拟 1.0.2 也发现，同版本不提示 |
| 主/备入口 | 各前 64KiB 的 206/总长/字节一致；完整下载只覆盖主入口 |

各组存在重叠或重跑，不相加为总通过数。主机捕获是生产控件、合成账号/目录/MV 画面和不入包的 Windows QA 字体，不等于真实账号写入、实际音频/GPU、TalkBack 或安装验收。SDK 历史 contention-repeated 场景本机首轮通过，也不代表所有网络/设备成功。

便携证据：`docs/version-archive/v1.0.3-evidence/`、`v1.0.4-evidence/`。原始日志/捕获/实际下载：`.codex-artifacts/2026-10-27-release103/`、`release104/`，均被 Git 忽略。

## 5. 未完成、待反馈或另行安排的事项

### 5.1 用户自行真机验收

用户已明确自己测试并断开 USB。1.0.3/1.0.4 阶段没有访问手机/执行安装，以下尚未认证：

- 小米 14 Pro 120Hz 快速滚动、胶囊开合的 CPU/GPU/帧耗时；持续 120fps 和彻底解决 CPU 满载目标尚未证明。
- 旧版到 1.0.4 的保留数据覆盖安装、系统来源权限、厂商前后台限制。
- 浅深色触感关闭态，以及震动/手机登录/签到按钮真实滚动和回弹表现。
- 酷狗真实资料写入、头像审核、省市显示、异常草稿恢复。
- 均衡/音效实际听感、切歌/重启后设置与会话、不同输出设备；MV 实际解码/清晰度和原音乐恢复；定时/单曲循环边界。
- Android P8P 实际节点字节贡献、网络切换、前后台及进程重启续传。配置开启或主机 HTTPS 成功不等于手机提速实测。

用户反馈失败后再按新需求澄清修复；新会话不自行访问手机补验收。

### 5.2 Git/GitHub 未同步 1.0.3/1.0.4

只有本地未提交实现和冻结快照，没有这两版 commit/tag/push 或 GitHub Release。**源码未归档到 GitHub，不等于后台未发布。** 此前旧版补档已完成，不能重复覆盖旧 Release。

本轮用户只要求交接和新会话，没有要求现在推送。后续若安排 Git 同步，先明确 SDK 原权利、公共/私有仓库及源码供给方式；不能直接 `git add .` 公开 SDK 或本机文件。只 clone 远端 beta 得不到本版。

### 5.3 保留历史问题与功能边界

- 旧 stable 全量记录仍保留多行编辑菜单间距、关注者移除 sheet 层级两项历史问题；本轮选定兼容通过不等于全量重跑或已修复它们。
- 自动听歌时长上报仍关闭，联系方式暂缺为此前保留决定。
- 定时器不跨进程保存；音效为原版免费条目的均衡映射，没有 IRS/VPF 卷积。
- 更新发现仍依赖 music/health，没有独立 COS 新版本发现源。
- 更新说明为精确版本的内置数据，未知未来版不编造。后续需维护 `release_history.dart`；若要求旧客户端升级前读取未知未来版正文，需要另行扩展远端说明来源。

## 6. 用户决定与操作边界

- 新需求/修复先一次问一个问题，理解后给方案，经确认再实施，保留必要注释和解耦；已确认完成的决定不重复询问。
- 完整保留玻璃和胶囊动效、Apple/iOS27 风格；6dp 均衡圆点是用户明确确认值。
- 正式产品沿用 beta 身份，旧 stable 是另一产品线，不能为了“去掉 Beta”改包名、签名或切换旧界面。
- 早期 USB/安装许可被后续用户自行测试安排取代，不能视作持续授权；不要运行 ADB、访问设备或手机投屏、安装/重启手机。
- 历史 `flutter drive` 未带 `--keep-app-running` 曾卸载日常 Beta，原数据保留未认证。未来经新授权的原生性能测试只用独立 `.beta.benchmark` 并强制保留运行。
- 后续正式修复使用实际 code **大于 25**、同包名和原密钥，不只改服务器名称或覆盖同 code 在线包；旧 APK 不代表可直接降级保留数据。
- SDK 原 LICENSE 不自动授予公开源码许可；完整 1.0.4 源码私有接续。发布 APK 授权不等于公开 SDK 源码授权。
- 后台密码/私钥不写入文档、源码、构建参数、Release 或新会话提示；后台只上传签名 APK。

签名 ZIP：`C:/Users/Mest/Downloads/Mesting-Music-Beta17-signing.zip`；原 keystore：`D:/AnLi/Mesting-Music-Flutter/debug.keystore`。只提供定位，不复写密码。构建默认机器 debug 签名不等于原交付证书，勿替换全局 debug 密钥。

## 7. 环境与实现入口

- Flutter：`D:/flutter/mesting-beta5/flutter`，3.41.9 / Dart3.11.5，勿误用另一套旧 SDK 或照搬交接主机 3.47.7。
- JBR：`C:/Program Files/Android/Android Studio/jbr`，Java/Kotlin target17；Android SDK：`C:/Users/Mest/AppData/Local/Android/Sdk`；compile/target36、min24、NDK28.2.13676358，WebRTC 所需 SDK34 已补齐。
- 根锁 SHA-256：`6E29E2A4B236776D9E7C1BCD458783D0214F0EF151E7DC793B0B4E5AD7591DD0`，已 enforce-lockfile 验证，不无故全量升级。
- Release 入口 `tool/build_android_release_apk.ps1` 默认本版；下一版显式提高版本/code。**不要加 --no-pub**，避免测试后残留 IntegrationTestPlugin；脚本检查锁和 69 项素材排除。
- Maven 直连长期无数据曾用既有本地代理解决，仅配置成功构建进程，未改全局网络或关闭证书验证。先核对下载/代理，不把主动停止的 daemon 当源码缺陷，不停无关进程。
- 后台上传 1.0.4 用时 530.1 秒。等暂存/摘要后再核对发布；旧“候选未发布”提示可能留存，刷新当前公开版本并以同份 health 的 version/code/size/SHA 判断，避免重复发布。
- 曾遇内置浏览器接口不可见、Windows 网址识别拦截；使用工具支持的受控 UI，遵守拦截，不提取 Cookie 或绕用隐蔽管理请求。

| 模块 | 入口 |
| --- | --- |
| 禁用玻璃控件 | `lib/shared/widgets/beta_glass_controls.dart`、`beta_glass_action.dart` |
| 六项资料/地区 | `lib/features/music_platform/` 下 platform_profile、platform_regions、编辑页与 picker |
| 音频 owner / EQ / 定时 / MV 恢复 | `lib/core/audio/` 下 mesting_audio_handler、music_equalizer、music_sleep_timer、playback_interruption |
| 原生 EQ | `android/app/src/main/kotlin/com/mesting/mesting_music/MusicEqualizerPlugin.kt` |
| 音效 / MV | music_platform 下 effects / mv 的 repository、provider、页面 |
| 更新发现/下载/SDK | `lib/features/app_update/` 的 release_source、repository、ring_app_update_transport、providers |
| 更新说明 | `lib/features/app_update/domain/release_history.dart`、release_notes_sheet |
| SDK 原交接本机副本 | `C:/Users/Mest/Documents/Codex/2026-10-27/music-p8p-integration/handoff/交接说明.md` |

## 8. 接续阅读顺序

1. 本文与 [AGENTS](AGENTS.md)。
2. [1.0.4 交接](docs/SESSION-HANDOFF-2026-10-28-v1.0.4.md) 与 [修改](docs/fixes-2026-10-28-v1.0.4.md)。
3. [1.0.3 交接](docs/SESSION-HANDOFF-2026-10-27-v1.0.3.md) 与 [修改](docs/fixes-2026-10-27-v1.0.3.md)。
4. `DESIGN.md`、`PRODUCT.md` 后部最新规则，[发布步骤](docs/RELEASE-UPDATE-GUIDE.md) 和 [SDK 来源](third_party/ring_download_sdk.SOURCE.md)。
5. 回看历史才读 Beta.19、1.0.2 和 Git 补档；旧文档“当前”“待接入”“未发布”属于当时状态，不覆盖本文。

新会话仅确认能读取 D 盘工程、分支/脏树、交付和上述状态，简述已完成/待处理/注意点，等待用户下一条具体需求。此次总交接只增加文档与阅读入口，不修改产品、重构、重建或重新发布。
