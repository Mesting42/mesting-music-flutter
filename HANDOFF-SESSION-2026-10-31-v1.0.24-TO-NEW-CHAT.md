# Mesting Music 会话交接：1.0.23-r2 已验证，1.0.24 接续实施

生成时间：2026-10-31，Asia/Shanghai。此文档优先于旧交接中的“当前”“待确认R3”“尚在编译”等历史状态。

## 1. 用户最新指令与接手边界

用户最新原话：“编写当前会话的交接文档，当前会话完成了什么？有哪些未完成的？有哪些已经修复过的问题需要注意不要再犯的？并且新开一个会话，模型改为6.1sol 推理开最高 然后将接下来的任务移交给新对话完成 修改完之后 版本定义为1.0.24”。

后续目标是完成第6节的五组明确需求，版本定义为1.0.24 / Android code45。之前讨论的1.0.23-r3文件名已被这条新指令取代。不要覆盖1.0.23-r2、任何旧APK或源码ZIP。

用户指定接收会话模型gpt-6.1-sol、推理开最高。当前桌面建会话工具对该模型提供的最高档位为ultra；用工具明确设置，不只把模型名字写进提示词。新会话沿用本机工程与未提交改动，不建立新worktree。

此前在每次方案确认时用户继续追加需求，所以五组新功能尚未编码。最新“移交给新对话完成”是继续推进这些任务的新指令；不要把旧“待确认R3”无限沿用为阻塞。已明确的选择不重复询问，新需求或重大歧义才继续按用户约定逐题澄清。

用户的协作约定：遇到新需求/修复先提问，一次只问一个，理解真实目标后给方案，确认后实施；编码注释充分、职责解耦。新会话应先读本文件及AGENTS.md，核对工作区后按明确范围推进。

**手机测试已被用户明确暂停。** 本轮最后有效测试结束后没有继续ADB采样、触控或安装。不要因旧的“可连接/覆盖安装”授权自动恢复手机测试；完成新包后先交付可审阅产物，再由用户安排手机验证。一起听双端互通和距离由用户后续自行测试。

没有Git提交、推送、PR、GitHub Release或music后台发布授权。用户自行发布过1.0.22是用户告知；本轮没有后台操作。保留music浏览器页面，不恢复已停止的桌面内存优化。

## 2. 唯一工作区及当前代码状态

- 工程：D:/AnLi/Mesting-Music-Flutter/app-md3music-beta。
- 分支beta，HEAD/base：15023fec8e903e40ff3841f10a396580ee1860ef。
- 存在完整未提交改动，暂存区无本轮暂存；不要reset、clean、拉取覆盖、切换到另一份工程或建立未经要求的新worktree。
- 新会话的默认cwd可能仍是C:/Users/Mest；所有项目命令显式指定上面的D:工作目录，不在C:创建新工程。
- 保留初始未跟踪HANDOFF-SESSION-2026-10-30-v1.0.22-SYNC-TO-NEW-CHAT.md和全部旧冻结交付。
- 交接前git status完整快照：.codex-artifacts/2026-10-31-handoff124/git-status-before-handoff.txt。此时52条状态项，后续本交接和入口指针会再增加。
- 第6节五组功能没有业务代码实施。工作区当前业务改动仍是本轮1.0.23崩溃恢复与一起听；新功能仅做了只读源码调查及需求记录。
- 1.0.24业务版本号、release notes、构建默认值尚未修改，交给接手会话统一改。pubspec原有1.0.37+58是历史内部值，公开Beta版本通过构建参数覆盖；不要误把它当当前交付版本。

## 3. 已完成并可用的交付

当前可交付/手机已安装：

- release/Mesting-Music-v1.0.23-r2.apk。
- 包名com.mesting.music.beta，版本1.0.23 / code44，双ARM，Release、不可调试。
- 大小106813134字节。
- SHA256：306f66d8ec2426de98bf52f251220d56a57cd907fd028eb27d100b223c9b56b5。
- 原升级证书SHA256：8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333。
- release/Mesting-Music-v1.0.23-r2-verification.json和.apk.sha256已有。
- 用户明确确认后于2026-10-31 02:53:24覆盖安装，保留账号/数据；手机APK回读摘要与冻结R2一致。
- 真机引擎实际日志：Using the Impeller rendering backend (OpenGLES). 不是只看应用请求参数。
- 完整底部玻璃导航和播放胶囊已确认显示。包内7个玻璃着色器、8个其他SDK原生库及8个原许可载荷与旧包逐字节一致；另附定制引擎完整许可。
- V2/V3签名、ZIP CRC、16KiB APK对齐、ELF段对齐、正式包测试素材排除、包内4条更新说明均已校验。
- 实际签名R2 APK的生产Range读取器测试通过：3次Range请求，66082字节读到全部4条更新说明。

旧首包release/Mesting-Music-v1.0.23.apk必须保留，但不得当作有效修复包：

- SHA256=b8852cf8bf49a22517f33e5fa5c47860450d5f5e2ac6a674688654a40298952f。
- 它原签名正确且曾安装，但实际仍是Vulkan，未通过后端验收。
- release/Mesting-Music-v1.0.23-STATUS.txt明确标注两者区别。

完整源码ZIP尚未冻结，也没有1.0.23-r3或1.0.24 APK。不要在新会话宣称这些文件已经存在。按1.0.24完成全部新需求后再冻结新源码包、校验报告与摘要。

## 4. 本轮已实现的修复

### 4.1 原生闪退兼容恢复

用户原日志确认升级1.0.22之后仍崩溃：2026-10-30 22:24:04.168，1.raster，SIGSEGV11 / SEGV_MAPERR1，faultAddress0x1c，vulkan.adreno.so，vkBeginCommandBuffer。驱动BuildId=33f69a5b3c5ea87c251952c3e0b7a7a2，首PC=0xd524c。更新在22:23:29，不可把这条记录归到旧版本。

补齐真实底部玻璃和暂停胶囊的隔离profile壳还复现过同驱动/同首PC崩溃，前置8KB分配失败、mmap errno12。隔离套件中断，且进程有更早运行历史；只能作为额外证据，不能证明“我的”是唯一资源来源。

已加入：

- VulkanCrashSignature.kt：只匹配本应用可用的Adreno Vulkan栅格原生崩溃；无函数名的栈须精确匹配驱动ID/PC/故障地址，排除Java错误、ANR和无栈记录。
- RendererCompatibility.kt：Beta/API31+读取受限本进程历史；最多等待250ms，晚结果供下次冷启动；决定按OS指纹保存，OTA失效旧决定。
- MestingApplication.kt：在AudioService创建/缓存引擎之前设置后端。不能只在MainActivity加参数。
- 定制Flutter 3.41.9 Release引擎：仅放开原有OpenGLES显式选择分支，保留Impeller、premium shader、模糊/折射/动画与默认自动路径。
- Beta manifest使用专用Application；Stable的原启动manifest和正式依赖不被替换。

最重要的发现：官方3.41.9的SelectedRenderingAPI把显式OpenGLES选择放在非Release条件中。Profile成功不代表Release有效。本轮首包因此被拒收，用户明确选定制Release引擎来保留完整玻璃。不要退回普通官方引擎、Skia或降级玻璃来“快速修复”。

这属于避开已确认Vulkan路径的兼容恢复，不能宣称修复了闭源Adreno驱动或永久根治。

### 4.2 一起听融入正式播放器

- 原独立入口转入生产BetaNowPlayingPage，顶部双头像、房间状态、平台真实时长与距离；管理操作移到玻璃面板。
- 原有邀请、复制链接、共享队列、成员和结束保留；退出面板不结束同步；五种播放器和单音频owner保留。
- 心跳只重建房间区域，独立时长标签计时；仅房间出现/消失影响整体高度预算。窄屏/大字有滚动预算，不挤压封面。
- TogetherLocationBridge只执行用户主动的一次前台系统定位；支持近似授权，不读Wi-Fi标识，不保存坐标历史、不加后台权限；转后台取消。
- 先显示用途再申请权限。迟到结果按账号/房间代次丢弃，定位操作不占播放命令队列。
- 官方9.5.12协议字段：GPS report、distance get、relation statistics get/v2；distance单位公里，时长秒。statistics roomUserIds仅peerId，privacy/opened按真实协议。
- unopenedUserIds优先于旧distance值，关闭位置后不显示缓存距离；平台明确拒绝时不假报开启/关闭成功。
- 定位、距离与时长模型分离，保留平台不可用/等待/错误状态，不伪造数据。

双方真实定位与网易云官版↔Mesting、Mesting↔Mesting互通均未验收。用户明确说“一起听后续我自己测试”。只可报告接口/单位/生命周期/主机布局测试通过。

主要文件：lib/features/music_platform/netease/together/中的controller、panel、player_header、presence，兼容入口netease_together_page.dart；BetaNowPlayingPage；TogetherLocationBridge.kt；netease_manual_routes.dart；legal_documents.dart。

## 5. 已有验证与中断前手机采样

当前业务源码最后完整回归：

| 范围 | 结果 |
| --- | --- |
| Beta 62文件 | 1141通过，0失败/跳过 |
| Stable 2文件 | 19通过 |
| Android保留引擎返回行为 | 1通过 |
| 原生栈解析Kotlin | 11通过 |
| Vulkan签名Kotlin | 10通过 |
| 实际固定C++选择分支 | Release10/Profile10/Slim3，共23 |
| 五种播放器×常规/窄屏大字 | 10通过，主机合成数据 |
| 静态分析 | 0问题 |

日志在.codex-artifacts/2026-10-30-release123/：
beta-regression-final.jsonl、stable-regression-final.jsonl、android-back.jsonl、analyze-final-2.log、.kotlin-tests.log。其他旧次数不要累加成新测试数。

手机：小米14Pro/23116PN5BC(shennong)，Android16/API36，1080×2400、DPR2.625、系统120Hz。序列号属于私有证据，不写入交付报告。设备仍可能连接，但暂停后不要为“核对”再访问。

R2原路线5轮：音乐库短滑→我的正常/快速/反向滑动，包含从玻璃按钮起手拖动，进程不变。约24.84秒完整窗口2333帧，build P50/P90/P99=1.53/2.58/5.15ms；raster=5.92/9.96/15.86ms；raster>8.33ms为514，>16.67ms为20。

1.0.22同类混合路线基线2000帧，raster P99=22.43ms，>16.67ms为134。两者都包含诊断导航，不能当纯列表屏幕FPS或严格控制A/B结论。

后来按用户要求扩展正常/快速/超快速场景，12个有效窗口共37350帧。涵盖四主Tab、私人FM、每日推荐、榜单/歌单/新碟/歌手/MV列表、歌曲/歌词/243首队列、消息/聊天、下载、本地、674首喜欢、云端历史等已有页面。60次超快速Tab点击，组内实测约65–112ms，最终正确停在“我的”；请求会被既有导航调度合并，不等于60个完整动画都展示。

部分示例：播放中歌词/队列组2075帧、栅格P99=19.55ms，仍有44帧>16.67ms；消息/聊天组1826帧、P99=16.19ms。不能美化为无慢帧或持续120fps。

后半程用户改为深色主题、持续播放并启用系统性能悬浮窗；不要与较早浅色暂停状态混作受控比较。悬浮窗的瞬时FPS也不能代替Flutter采样。

暂停时仍未完成所有页面。精确记录见docs/PERFORMANCE-2026-10-31-v1.0.23-extended.json，invalidCapturesExcluded与coverageCorrections必须保留。特别是“订阅的播客”一次坐标点到遮挡的胶囊，不能算播客页验证；消息第一次/播放器前两次采样因返回路径或未停止采集被排除。最终成功的player-complete-dark与messages-chat-verified是有效窗口。

## 6. 新会话需完成的五组需求（目标1.0.24/code45）

### A. 统一双平台签到及跨平台自动签到

用户明确选择：点击“我的→签到”进入一个统一签到页，网易云/酷狗两个标签，两边签到均保留。在网易云听歌时，用本机已保存的酷狗账号打开酷狗签到日历、查看会员并领取，当前音乐平台不切换。

酷狗原有自动签到开关也要跨平台生效；其他奖励由用户手动领取。保留酷狗现有日历、确认记录、会员状态、签到与领取/验证能力；成功依据真实返回，不因为本地动画就写成功。

已查明当前耦合：

- beta_personal_profile.dart的_sign：酷狗打开PlatformRewardCalendar，网易云直接neteaseFeaturesProvider.signIn。
- platform_reward_calendar.dart遇usesNetease就显示NeteaseAccountPanel，不是真正可独立使用的酷狗日历。
- platform_rewards_provider.dart所有动作和有效性都绑定当前platformAccountProvider；切到网易云就清空状态。
- MusicPlatformApi.session随当前音乐平台变化；_publish(NetEase)会把酷狗session置空。不能临时修改这个共享session来签到，否则会影响播放与并发请求。
- platform_reward_verification.dart验证码也监听当前账号，需要一并改成真实酷狗操作owner，保留取消/失效检查。

应建立独立已保存酷狗身份/请求作用域、按账号/日期去重与代次保护，复用业务逻辑而非复制整套不联动的状态。退出/替换酷狗账号应让迟到结果和后续间隔请求失效。凭据不进日志/报告/公开补源。

### B. 网易云使用已登录酷狗概念版账号补源

用户已问并确认：当前酷狗主要沿用概念版接口/登录体系；要复用的是现有酷狗平台带账号的播放解析，不是只加匿名公开源。

默认：网易云官方优先；失败或仅试听时尝试酷狗账号同曲补源；也支持手动选择。原有其他补源继续保留。相同录音版本严格匹配，音质依据实际返回；保留网易云歌曲/歌单身份与现有播放界面，不切当前平台。

当前网易云NeteaseTrackSource.kugou是“酷狗公开音源”，netease_fallback.dart约674行构造独立匿名MusicPlatformApi，未携带已存酷狗账号。不要误认它已满足新增需求。

酷狗PlatformPlaybackResolver支持/song/url、新会员路径/song/url/new以及实际音质识别；标准/高品质/无损/Hi-Res等按真实账号/资源权限返回，不能把请求档位直接当结果。自动补源与手动选择/现有下载消费者应一致处理身份、取消、超时和URL验证。

复用独立账号请求作用域，不将NetEase Cookie带给酷狗或公开服务，不修改共享播放器owner/队列来“实现跨平台”。仍需测试错版录音、试听片段、无登录、失效、账号替换、迟到响应、取消、质量降级。

### C. 下载进度、大小、解析动画与左右分页

用户截图明确要求：

- 音频下载进度条与Beta“版本更新”相同，复用AppleDownloadProgress的胶囊样式和真实进度表现。
- 每首显示已下载量及音频总大小，自动KB/MB换算；未知总大小须明确，不伪造0/0或100%。
- 解析音源阶段不用默认转圈；已给用户的具体方案是自定义蓝色动态波形，配“正在解析音源”。
- “下载任务”只包含等待/解析/下载/保存/失败/取消；完成项仅在“已下载”。用户明确失败/取消保留供重试。无剩余任务显示“暂无下载任务”。
- 已下载/下载任务支持屏幕左右滑动，顶部分栏双向同步、分别保留纵向位置。

现代码AudioDownloadPhase只有queued/downloading/saving/completed/failed/cancelled，需明确排队和解析的状态边界并兼容已存任务。received/total已存在。保存成功后才移动到完成页；取消/失败迟到请求不能复活任务。

当前audio_downloads_page.dart下载任务直接使用所有tasks，所以完成项也出现；使用LinearProgressIndicator、BetaActivityIndicator。注意MestingLoadingIndicator在Beta分支本身仍是CupertinoActivityIndicator，直接换名字并不满足“非默认动画”。

真实Beta版本更新使用app_update/presentation/apple_download_progress.dart，而不是stable app_update_sheet.dart内的另一条LinearProgressIndicator。可抽出共享可复用组件，不能让语义仍写“更新下载进度”却用于音频。

### D. 音效封面、全局分页滑动、音乐胶囊与底栏背景统一

用户截图：酷狗音效页社区/耳机/明星三分栏；封面全为占位图；明明在播歌却无胶囊；底部额外出现一块不透明背景，与发现页不同。

要求：

- 修复真实封面字段/地址/加载链，不用伪造图填补真实请求失败。
- 社区/耳机/明星支持左右滑动及点击联动；检查其他同类内嵌页面分栏并一并支持滑动。排序、音质、偏好等选择值不是页面导航，按控件实际用途判断。
- 下载、消息评论/@等、本地音乐歌曲/文件夹等是调查候选；history/social已有TabBarView，先验证不要重复套PageView。
- 同类音乐内容页统一使用发现页同一套底部玻璃导航/播放胶囊/搜索，不多套背景盒子，保留玻璃折射。
- 用户明确：键盘弹出时收起胶囊；键盘收起后恢复，即使页面仍在筛选状态。不能只用FocusNode是否有焦点判断键盘可见。

已读源码的具体线索：

- music_effects_page.dart：BetaPageSearchLayout→MusicFeaturePage→BetaGlassScrollBody；分栏只更改_catalog并清空重载，没有PageView。
- platform_effects_repository.dart的MusicSoundEffect.parse只看icon_url/model_icon/logo，需核对真实载荷及图片规范化；ArtworkImage已有缓存/尺寸控制。
- BetaPageSearchLayout若不在BetaBottomSearchScope内，会走ColoredBox+本地GlassTabBar.searchable后备，仅有搜索而无全局播放胶囊；scope内还包了bottom136的Padding。此为当前排查线索，尚未证明所有背景问题都来自同一个点。
- MusicFeaturePage、PlatformPageFrame、root/嵌套Navigator与搜索绑定需要一起审视，避免重叠底栏和多个音频owner。
- BetaMusicShell._scroll会忽略非垂直及depth!=0的通知。加入PageView后内部纵向滚动的depth会变化，要显式解决公共底栏收放与活跃页滚动归属，不可只增加PageView便称完成。
- 不要随意删除BetaGlassScrollBody的真实绘制面：它在overscroll合成里供玻璃采样。目标是去掉额外底栏盒子，不能让背板消失导致玻璃发黑/采样无效。

### E. 手机App内一键全页面自动流畅度测试与报告

用户已明确：

- 完全在App“流畅度诊断”内运行，无需电脑/ADB。
- 一次执行覆盖网易云、酷狗两套页面及公共页面；未登录部分记录跳过。
- 所有适用页面正常上下滑、超快速滑动/反向滑动、进出/返回、超快速Tab切换；明确包含歌曲、歌词、队列、消息等，并纳入A-D的新界面。
- 连续跑完整轮，不需要中途反复开始/停止；单页错误/超时记失败后继续，进度可见，逐段保存；保留手动停止。
- 原生进程若真的崩溃，不可能保证原进程继续；保留断点，重新打开诊断页可续跑，勿写“不会中断/不会闪退”的虚假保证。
- 完成自动返回诊断页，生成可阅读汇总和可导出JSON；按页面/正常/快速阶段分别记录帧耗时、慢帧、失败、跳过及原因，可含本次时间范围的脱敏退出摘要。
- 使用真实生产页面/玻璃/队列，不用缺控件的假壳来代表正式页。
- 自动化动作只做页面操作，不点击签到、奖励领取、发送消息、付费、删除等业务动作。跨平台自动签到是A的正常产品能力，但诊断运行应抑制业务副作用，不能因遍历页面或切平台而顺便领取。

现有FrameTimingProbe只支持单次90秒、最多14000帧/250切换标记；Release帧回调约每秒批处理，Stop须1.2秒drain、按原始vsync界限过滤。不要粗暴移除所有上限后把整轮帧都堆内存。应分步骤/分段采样、增量保存。

现有LocalMusicDiagnostics.exportTiming默认Release编译关闭。新功能要有独立用户主动报告存储/导出能力，不能要求用户开调试编译开关或只调用这个空分支。

拆分建议：明确场景清单/数据前置条件、导航与滚动执行适配、会话状态/持久化、帧采样、报告聚合/导出。测试应验证真正可达页与最终目标状态，缺数据详情记跳过而不是造业务数据，也不能把一次误点胶囊算页面通过。避免硬编码1080×2400坐标。

## 7. 后续必须避免重复的问题

1. Release后端参数被忽略：必须保留定制Release引擎与包内核验；请求日志不等于实际后端。升级SDK前重新核对补丁和AOT兼容。
2. 签名错误：普通本机构建默认debug证书与已安装应用不一致。只用原签名助手，核对8ce2…证书，不能卸载/清数据来绕过升级失败。
3. 测试壳缺底部玻璃：旧早期壳的数据不代表日常页面；flutter drive不能用于日常包，本轮隔离套件崩溃也不能算通过。
4. GPU捕获不是屏幕FPS：不以gfxinfo、截图瞬时FPS或主机软件渲染证明持续120fps/永久稳定。
5. 90秒到期/未到诊断Stop/点到遮挡胶囊：都应排除对应结果。可访问性“可见”不代表无遮挡可点；必须核对当前页和操作对象。
6. 跨平台不能临时替换全局API.session或播放owner。旧代码特意阻止NetEase凭据进入酷狗客户端；解耦时保留此边界及所有await后的账号代次校验。
7. 双内容树/重建导致玻璃开销：切页合并采用既有BetaTabNavigation，不能为快速Tab测试绕开它后把多个离场玻璃页一直留在绘制。
8. PageView增加通知深度、隐藏页滚动/搜索绑定抢权：公共底栏与筛选只跟随当前活跃页面。每页独立滚动，快速反向切页也要恢复形变/高亮。
9. 下载总大小未知、解析排队混淆、保存中100%：不可假完成；真实完成后再移入已下载。失败/取消仍可重试。
10. 官方Together协议公里/秒、unopened覆盖旧距离、迟到定位：这些已修过的边界必须保留。不要自动邀请好友或定位来做主机验收。
11. PowerShell BOM-less中文读取须-Encoding UTF8，Python read_text须encoding='utf-8'或utf-8-sig，避免GBK解码失败。
12. Flutter测试后--no-pub可能遗留integration_test原生注册；正式构建走公开脚本的pub阶段重建registrant，检查锁文件不漂移及69项素材排除。
13. Git diff在CRLF工作区用core.whitespace带cr-at-eol；不是所有CRLF提示都是真实代码问题。
14. 未发布、未源码冻结、双端未测等状态须如实报告，不能从文件名或旧交接标题推断完成。

## 8. 构建环境、引擎与签名接续

- Flutter SDK：D:/flutter/mesting-beta5/flutter，3.41.9/Dart3.11.5，原SDK未改。
- JAVA_HOME：C:/Program Files/Android/Android Studio/jbr。
- Android SDK：C:/Users/Mest/AppData/Local/Android/Sdk；Build Tools36.1.0。
- GRADLE_USER_HOME：C:/Users/Mest/.gradle。上一轮进程级限制Gradle堆3GiB/worker2；不改用户全局内存设置。
- Python：C:/Users/Mest/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe，不在PATH。
- 原签名库：D:/AnLi/Mesting-Music-Flutter/debug.keystore，alias androiddebugkey。口令只通过环境变量提供，勿写源码、日志、交接或源码包。
- tool/sign_android_release_apk.ps1拒绝覆盖已有签名APK，使用MESTING_SIGN_STORE_PASS/MESTING_SIGN_KEY_PASS环境变量，默认校验原证书。
- 正式构建：tool/build_android_release_apk.ps1 -FlutterSdkRoot D:/flutter/mesting-beta5/flutter；完成1.0.24时传/设置VersionName1.0.24、VersionCode45并同步notes。

定制引擎已导出在third_party/flutter_engine/android-release/，普通App构建直接使用，无需再编译整个Flutter：

- framework pin 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694 / tag3.41.9。
- upstream engine 42d3d75a56efe1a2e9902f52dc8006099c45d937。
- Dart c70f78e7d682c158c15ca0c26c729b3ccb932284。
- arm64 BuildId 7f9d8a668f14166c413851535d650d072dc0053e。
- armv7 BuildId 0f533f57422a3749c262e36ed443c583a9cbce11。
- shipping来自lib.stripped/libflutter.so，不能用带debug段的原始50MB库；manifest含jar/native/patch/依赖/许可SHA。
- 两种库LOAD段64KiB对齐，优化Release/AOT、剥离符号；为8GiB WSL构建省内存关闭LTO，性能不宣称与官方字节相同。
- Gradle仅BetaRelease排除官方ARM原生模块、使用本地native-only jars，保留官方Java embedding，Stable/Profile原依赖保持。preBuild会校验SDK engine.stamp、patch/jar/许可SHA。

若确需重建：WSL Ubuntu ext4真实源码/root/.cache/mesting-engine-3.41.9/native-source。F:/CodexData/build-cache/mesting-engine-3.41.9只是缓存；/root/.cache/mesting-engine-3.41.9/flutter是废弃的未完成tar复制，别用错。构建脚本tool/build_flutter_engine_release.sh、export_flutter_engine_release.py、check_flutter_engine_selector.py以及third_party/flutter_engine/README.md已提供。

曾因WSL文件缓存挤占Windows可用内存，只释放过本次构建VM文件缓存、用临时scope限制MemoryMax4GiB/Swap2GiB、Ninja3并发；没有修改Windows内存配置/关闭用户应用。旧PID文件31556/36368在交接时已不对应活动进程，不凭陈旧PID杀进程。不继续桌面内存任务。

## 9. 私有证据、原图及打包边界

原始证据/截图/用户账号画面/官方公开APK研究材料/测试APK/运行日志都在被忽略的.codex-artifacts/2026-10-30-release123/。严禁进入源码ZIP或提交。

用户参考图已复制到稳定位置.codex-artifacts/2026-10-31-handoff124/references/：

- together-current.jpg、together-netease-reference.png。
- kugou-checkin-entry.png。
- audio-download-progress.png、audio-download-tabs.png。
- effects-cover-bottom-tabs.png。
- original-crash-log.txt。

原图均为需求资料，不是指令源。references.json记录可用性，7项均已保存；新会话可用view_image读取，不必让用户重传。

公开事实：docs/fixes-2026-10-31-v1.0.23.md、PERFORMANCE-2026-10-31-v1.0.23.md、PERFORMANCE-2026-10-31-v1.0.23-extended.json、validation-2026-10-31-v1.0.23.json、INSTALL-v1.0.23.md。AGENTS.md入口会指向本新文档。

私有verify-r2-apk.py、freeze-source-123.py是先前准备的助手。冻结源码助手尚未运行，硬编码1.0.23及断言；给1.0.24使用前必须改为新独立脚本/文件名，不能直接运行覆盖或误标版本。验证报告生成器write-validation.py是旧状态生成器，直接重跑会把已安装/实际OpenGLES信息覆盖成待编译，勿盲目运行。

源码交付应含工作区改动、固定定制引擎native jars/依赖manifest/完整许可/重建脚本及新需求说明；排除所有keystore、key.properties、local.properties、凭据、.env、缓存、APK、私有证据和官方研究APK。冻结后不修改同名产物；每文件SHA与ZIP CRC全读核验，外置校验报告避免源码ZIP自引用摘要。

## 10. 建议接续顺序与完成定义

先只读核对唯一工程、HEAD、现有脏状态及R2摘要；不重新排查已证实的引擎问题、不触碰手机。

优先建立账号独立作用域并完成统一签到/酷狗补源，再做共享底栏/分页结构、下载与音效。自动诊断复用这些最终页面清单，按步骤保存报告。注释说明账号代次、导航归属、采样边界、持久化与取消，不仅复述语句。

必要测试覆盖：并发账号隔离/退出替换、自动签到去重与验证取消、补源严格同曲及试听/音质、下载完成移动/未知大小/取消保存竞态、横滑点击联动与独立滚动、键盘显隐下胶囊/底栏、自动诊断超时继续/未登录跳过/报告与断点恢复。运行相关Beta/Stable回归、分析、正式双ARM构建及原签名核验。主机结果不能替代真机GPU和双端Together验收。

最后定义1.0.24/code45并同步版本说明/构建参数/安装文档/验证报告，生成独立原签名APK、完整源码ZIP与校验资料。保留1.0.23-r2原字节；不Git提交推送或发布到music/GitHub；手机测试仍暂停，新包就绪后由用户安排。
