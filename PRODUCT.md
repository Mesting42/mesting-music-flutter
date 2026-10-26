# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

中文音乐用户，在通勤、工作学习、放松和入睡等片段时间里寻找合适的音乐。

## Product Purpose

Mesting 是一款 Flutter 音乐应用，帮助用户快速发现、播放和管理适合当下状态的音乐。成功标准是用户首次打开后能迅速理解当前推荐，并在较少操作内开始播放。

## Positioning

以封面主导、中文内容和连续播放组织发现与音乐库。Android Beta.11 延续固定版本 md3Music 平台来源、顺序和反馈契约，沿用用户确认的 Apple Music 视觉依据，并以原创音乐伙伴、统一账号入口、真实分类搜索及八页使用指南建立进入体验；正式渠道保留既有“当下状态驱动”的定制推荐。

## Operating Context

主要使用场景是移动端单手操作、碎片化使用和持续播放；首页、发现、音乐库、我的组成四个主要目的地，搜索独立。手机与宽屏共享 Beta 底栏，正文自适应约束宽度。

## Capabilities and Constraints

- 现有项目使用 Flutter。Android Beta 由 DistributionChannel.isBeta（appFlavor == beta）接入，包名 com.mesting.music.beta；正式 flavor 的页面、主题、定制推荐、导航和默认黑胶保持其原有契约。共享工具的改进按调用点生效，不构成全局渠道切换。
- Beta.11 延续首次未完成进入且无恢复会话时显示欢迎页；每次新的交互式登录成功都依次显示成功卡、八页引导，再进入应用。恢复凭证与刷新 token 不算新登录，二维码轮询不能重复触发成功流程。游客直接进入应用，指南可跳过并在设置重新查看；退出仅真实成功后由上层协调器先覆盖欢迎页，再归位旧路由栈，返回不能重新进入退出前页面；等待时禁用重复操作，失败保留会话并允许重试。两类账号控制器继续独立持有凭证，酷狗、Mesting 与游客的数据归属延续。
- 欢迎页优先手机号和微信扫码，其他方式提供酷狗/QQ 扫码；Mesting 账号登录/注册明确标为“暂不可用”并禁用 Beta 新入口，已有会话与数据保留。手机号页只承载手机号验证码，所选扫码通过 initialMethod 进入独立方式页；我的与设置使用同一个 BetaAccountCard，游客及受保护操作通过 openBetaLogin 进入欢迎页。协议小圆形状态与文字/链接整组居中、同基线，链接可独立访问，小屏和大字允许换行。
- Beta.11 手机号表单按用户确认的 Raycast 简洁布局适配 Mesting 浅深色：圆形返回、简洁标题、宽输入、一个登录主操作。验证码操作仍位于输入框内右侧，字段与操作为 Stack 内独立兄弟 premium 玻璃层。用户确认 R1 partial 后继续修复：私有 _InlineCodeField 仅负责布局，保留系统 TextScaler，按六位数字及普通/倒计时标签测量可用宽度；窄屏大字将“验证码”标签移到框外，右侧操作分为两行并增加字段/按钮高度，保持完整数字输入空间，状态仍由原页面持有。responsive-code-tests.log 2/2 通过：320dp/1.6 浅深色输入六位 863432，maxScrollExtent<1，外标签与键盘主登录均 hitTestable；reviewer 已看 approved 原图并确认 R1 resolved。发送先注册设备，单次用户操作仅发送一次；原生 captcha_options 保留 KUGOU_API_MID/dfid 签名上下文、删除账号凭证，平台 status=1 才倒计时。20015 仍如实显示业务拒绝；这项客户端/原生修复不证明真实短信已送达。
- 用户确认所有登录类页面移除“开源许可与致谢”；共享 showLicensePage 入口位于 Beta 设置的应用分组（settings-open-source），协议/隐私同意入口继续按其真实用途呈现。原先源码没有独立设置许可入口，本轮将其移入设置；settings-capture-final.log 1 通过，fixture 改为真实 /music/settings，正确截图为 settings-final.png。
- 八页指南根据实际发现/搜索、歌词、灰条收起与底部操作、账号适用的推荐/收藏、手动队列优先与续播/历史、外观、五种播放器、开始使用组织；不承诺桌面歌词、Zen 或 AI 等未实现能力。五张动态预览共用真实 playerVisualStyleProvider，选择会保存到装扮/播放器相同偏好；外观模式也读取真实主题偏好。演示不发起播放、云写入或第二个音频 owner。
- Beta.11 游客可浏览公开内容、五类搜索、进入真实公开详情并播放平台提供的可播放资源；当前播放队列与临时待播继续开放。收藏/取消收藏、创建/修改个人歌单等账号写入在组件和仓库边界拦截并引导统一登录；不删除或迁移已有本机游客数据，也不把播放历史和当前队列误当成个人写入。
- Beta.10 在现有严格编码 hash 切换上，增加同 ID 的媒体修订通知，使当前曲音质/元数据跟随真实媒体发布而更新，且不订阅位置 tick。有损返回的正值实测码率优先于可能由适配器补入的请求档位标签；严格切换不符或无法确认时保留旧音源和偏好。当前软件证据不等于真实 CDN/会员权限验收。
- Beta.11 的 BetaPageMotion 将页面正文与主题不透明 surface 共同横向移动，进入和返回连续显露真实上级页面；不存在留到卸载终帧的静止整屏遮罩，源页保留挂载与滚动。播放器封面/歌词、曲目身份和样式继续成对入退；上一首/下一首读取真实播放命令方向。共享 transport 与音频 owner 持续存在，快速反复操作由局部过渡接续。
- Beta.5 新增音乐库路由、年/月 Replay 和歌单封面编辑。回顾只统计当前 owner 的真实每日记录，不反推未记录月份；云写入失败保留草稿，不显示虚假成功。
- Beta.6 封面规范化/只读回退与音质偏好契约继续。Beta.9 音质菜单依据当前歌曲真实资源只展示已有档位，不预填标准/高品质/无损/Hi-Res 四档。资源存在与会员权限分开判断，会员提示只在尝试选择后按平台结果出现，未知元数据手动重试。切换保留档位到编码 hash 的对应关系，严格请求所选实际音源，无损降到高品质/标准也使用目标档位的 hash；勾选、提示和播放器实际来源一致后才保存偏好。复用已有音频服务并保留进度、播放状态、队列与模式；失败保留旧流和旧偏好，偏好/实际返回/试听/降档分别如实表达。
- Beta.7 的发现呈现私人 FM、每日推荐、刷歌推荐与新歌速递，来源固定为 md3Music a69503b84e8829f888684f67c163be03c589c014 的 API/解析/刷新/续播契约；不再应用本地艺人评分和个人热榜。FM 提供红心/探索/小众/电台，保留 cur_mark、播放完成、喜欢/取消喜欢和不喜欢反馈及账号隔离。
- Beta.9 单点只播放所选一首，不隐式导入整页歌曲；只有明确“播放全部”才导入集合。已有手动待播时按实际情况提供保留/替换选择，手动队列优先于自动推荐。普通播放在手动队列耗尽后可由完成或“下一首”进入平台自动续播；当前队列区分自动项。上一首使用实际播放历史，没有历史则重播当前，不从未播放的页面曲目伪造历史。
- 只有明确从 FM/刷歌推荐开始才拥有该来源的反馈归属；普通自动续播不冒充 FM。剩余待播项 ≤3 时按服务器顺序预取并追加到真实可见队列，不混入本地音乐库或随机备选池。明确搜索/歌单/音乐库播放结束旧 FM 来源，即使碰巧同一录音；代次和账号校验拒绝过时响应，慢速“下一首”不能在后续暂停/停止/跳转进度后重新启动播放。
- Beta 搜索首页与独立搜索入口使用真实 /search/hot 分榜关键词、历史和主题歌单/场景/热门歌单/排行/新碟等探索分类；关键词只触发搜索，不能伪装成可播放歌曲。旧定制推荐路由在 Beta 转入发现，正式渠道仍使用原实现。场景与主题的当前展示/可点击能力以平台已接入数据为准，不能仅凭端点存在承诺完整功能。
- Beta.11 结果顶部以“歌曲/专辑/歌手/歌单/歌词”固定顺序取代“搜索结果”大标题。歌曲延续紧凑惰性列表，专辑/歌单为手机双列方封面，歌手为圆头像列表，歌词展示真实歌曲与接口实际返回的片段。歌词内容使用 /search?type=lyric，/search/lyric 属于下载候选而非内容搜索。裸数组歌手返回被实际解析，缺失头像按可见身份惰性补取，最多 3 并发、160 个成功缓存；歌单 gid 保留为 global_collection_id，详情沿真实专辑/歌手/公开歌单接口加载。
- 五类按需加载并分别保留页码、数据、错误/重试与滚动位置，不同时预取所有分类；查询或账号变化使旧代次失效。底部目的地导航结束搜索，清空输入、结果、类别及本次 PageStorageBucket，下次相同词也从顶部和歌曲类别开始，真实搜索历史保留；播放器/详情等临时页面仅暂存，返回恢复原词、类别与位置。结果组件本地 bucket 随搜索首页替换结果而销毁；类别切换和临时路由仍在同次会话中。
- cover、classic、aurora、cassette、lyricStage 五种样式保留各自上半区形象和动态，共用同一播放进度、裸白色 transport、Android 系统媒体音量及评论/音质/当前队列。封面与歌词模式都保留这些控件；播放器不建立另一套队列或音频服务。
- 系统音量通过 Android STREAM_MUSIC 原生桥读写/事件同步，无宿主禁用。Beta.8 提供 48dp 高响应区和即时拖动反馈，原生写入串行保留最新值，抑制重复状态、事件和相同步进。进度与音量各自提供中文名称、时长/百分比和可调节语义；硬件键和 TalkBack 仍待真机。
- Beta 装扮移除品牌选择器、重复皮肤说明/经典卡片、DRESS UP 和 followTheme 选项，固定 coral 图标/启动页；保留浅/深/系统、自定义图片/视频、显式 IP 进度配色/角色。Beta.8 再移除 IP 装饰开关，替代 Beta.6/Beta.7 的开关保留说明。Beta.7 残留 followTheme 转 classic，已转换显式 IP 保留；背景强度 .58、性能 automatic、完整 IP 主题退役继续适用。
- 轻量反馈使用一个可替换的顶部安全区半透明 HUD。普通提示仅保留短标题和图标，错误/警告保留可行动信息；通知不可覆盖真实业务结果。
- 不把 Material 3 默认色阶、默认按钮外观或默认卡片外观作为最终品牌表达。
- Beta.9 建立的单一惰性 Apple 歌曲结果列表继续用于 Beta.11 歌曲类别，歌曲计数只显示“共 N 首”；歌曲列表按滚动指标自动分页，失败才显示重试，保留服务端顺序、收藏与更多。紧凑热搜保留分榜/排名/换页。左右 32dp 边缘和真实系统返回均逐步执行“搜索结果→搜索首页→来源页”。MusicShell 持有来源 tab 与滚动位置，BetaMusicShell 在播放器/设置后方保持挂载，仅改变 chrome 可见性。
- 五样式完整播放器仅顶部灰色 handle 下拉收起，封面/歌词状态共用提交与回弹；持续挂载的胶囊随下拉显露。胶囊仅订阅播放布尔值并使用共享实时播放/暂停操作，滚动超过 88dp 才收拢、回到 24dp 才展开，保留真实玻璃。
- Beta.11 将收拢状态放入局部 ValueNotifier，同一帧滚动通知合并至帧后更新，只重建底栏局部；持续挂载、88/24dp 滞回、完整展开/收回动画与 premium/full 光学参数保留。相同 120 帧播放中滚动刺激的 shell 重建 120→0，底栏仍 120；该证据仅测 Flutter 工作量，不表示 FPS。
- 收藏统一裸心形、48×48dp 透明目标、局部主题对比与按压缩放；成功状态以局部 420ms 动画表达喜欢/取消喜欢，可中断并尊重减少动画。Replay 年份使用 Cupertino 透明度反馈与圆角菜单，不产生矩形按压底；首页实心图标。经典唱机使用无黑描边的几何白色唱臂、唱头落在外圈沟槽，保留播放/暂停旋转区别；更多菜单带图标、分组、分隔线与当前样式对勾。
- 详情标题使用 21dp 单行文字，仅实际溢出时裁切跑马灯；测量与渲染共用继承字体和 TextScaler。
- 评论排序/范围各为一个下拉菜单并排一行；浮动输入和蓝色 48dp 3D 发送按钮是独立的真实 Liquid Glass 兄弟表面，使用 liquid_glass_widgets premium 渲染，不能嵌套或以位图替代。KeyboardVisibilityBuilder 观察当前原生 View 的键盘指标：键盘显示最多 2 行，否则最多 4 行。评论优先录音专属 ID，有界旧 ID 修复/设备注册恢复只针对读取；发送/回复/删除均需明确操作且不自动重试。特色歌单解析 special_list/plist，排行解析 songlist；平台账号页使用实际 coral Mesting 应用图标。

## Brand Commitments

- 产品品牌：Mesting；Beta 可见应用名称统一为 Mesting Music；界面语言：简体中文。
- 需要降低常见 AI 生成界面的模板感，避免紫粉渐变、泛滥玻璃拟态、重复大圆角卡片和无意义装饰。
- Beta 以用户提供的 Apple Music 参考图为视觉依据：封面、大标题、横向内容组和悬浮控件；界面保留中文 Mesting 品牌与自身账号、播放能力。
- Beta 使用参考图采样红色统一导航选中态、个人页图标和相关选择；Beta.9 经典浅色面板改为中性白灰（#F2F2F7），保留红色强调、既有深色与封面播放器氛围。显式 IP 图案与角色继续拥有自身配色，选中标签保持主要文字对比。
- Beta 底部直接使用 liquid_glass_widgets 1.15.0 官方 Apple Music 示例的组件、布局与交互动态。Beta.10 经用户确认将同一 premium 材质扩展至欢迎/登录/验证码/退出等指定账号操作、账号输入、圆形返回及当时的开源许可入口；许可登录页按钮属于历史实现，Beta.11 已按最新确认移至设置应用分组。当前指定玻璃表面独立拥有层，评论输入/蓝色发送继续为兄弟表面。内容列表、阅读正文及表单所在页面背景保持稳定；该范围按 Beta 调用点接入，不构成正式渠道的全局改版。局部音质弹层/HUD 按自身规范处理。
- Beta.10 的欢迎与指南采用用户选定的珊瑚红原创音符/唱片矢量双角色，具有四肢、表情、轻摆、眨眼和轻点问候；沿用既有 Mesting 世界、所给参考构图及随后确认的完整文字方案。没有另外生成或批准的 ImageGen comp、approval sidecar 或随机 FORM seed，不能事后补造来源记录。
- 默认封面播放器可切换左对齐同步歌词；歌词当前基准为 24dp 并支持 TextScaler。迷你 accessory 仅保留播放/暂停和下一首两个裸图标，点击/左右滑动与官方玻璃交互继续适用。
- 酷狗、Mesting、游客各自拥有收藏和历史；Mesting 社交入口不会显示给酷狗账号。云端写入失败不伪装成本地成功，不能把平台来源当成会员授权。

## Evidence on Hand

- 当前已验证发布 APK 为 Mesting Music / com.mesting.music.beta / 1.0.37-beta.11 / 11；assembleBetaRelease 成功。test-summary.json 记录最终常规 644 通过/58 条件跳过/0 失败、Beta 163 通过/0 跳过/0 失败，ui-captures-approved.log 43 通过；后补设置捕获 1 通过，analyze-approved.log 为 No issues found。组间重叠不可相加。APK 为 89,244,110 bytes，SHA256 64B761F855B4E44F26979375C04CAE266D608A18DB954D500494B4334D3DC4F3，同一 Beta 测试证书、16KiB ZIP 对齐、ARM64 ELF 16KiB 和打包 ARM 原生对应链已验证。精确记录在 docs/MD3MUSIC_BETA.md；源码 ZIP 字节/哈希留冻结后的外部 manifest。
- Beta.11 首轮 review-first 为 fix，后续 R1 曾 partial；经用户确认继续修复、responsive-code-tests.log 2/2 和 approved 原图复核，reviewer 已确认 R1、R2 均 resolved。R2 的 search-session-regression.log 1 通过，生产路由验证同词新会话 offset=0、同次类别/详情往返保留 offset=50。新 review-final.md 的独立有界结论为 disposition: ship，R1/R2 resolved、许可迁移 match，无剩余 material fix；结论仅覆盖所记录的软件/发布证据范围。
- Beta.11 review-fix-tests.log 3/3 的早期通过仍保留：内联验证码 pending→真实业务 status=1→60s 倒计时与重复点击防护、生产 appRouter 搜索生命周期、相同 120 次 playing-scroll shell=0/bar=120。初轮 642/56、Beta159、UI39、后续 UI42 和分析 1 info 均属早期源码/捕获阶段，已被最终 644/58、Beta163、approved43 与 clean analyze 取代；不以早期结果替代当前验证，也不将软件证据当作实际短信或真机帧率验收。
- Beta.11 genuine host live-read-probe 八类公开搜索/详情响应均 status=1，匹配裸数组歌手、歌词、专辑、gid 歌单及详情解析；这些是主机嵌入服务只读响应，UI 截图仍使用合成 fixture。Native 单元 46 通过；三个 ABI 服务库已用 Rust 1.99.1、NDK 28.2 和锁定 Cargo 依赖从修复源码重建。release 验证将源码原始库 manifest→merged 原始 hash→stripped→APK 两种 ARM 库完整对应，四个 C FFI 导出有效，且与 Beta.10 不同；x86_64 仅额外重建输出，原始未剥离 hash 不与 APK 剥离后 hash 直接混比。adb-devices 为空；真实 SMS、账号/QR/云写入、CDN/权限及设备验收仍未完成。
- Beta.11 新入口与边界：BetaConsentRow、BetaAccountCard、openBetaLogin、PlatformAccountPage.initialMethod、account_capabilities、LibraryRepository 写入防护；五类由 PlatformCategorySearchRepository、CategorySearchController、BetaCategorySearchResults、PlatformCatalogDetailPage 与 artistPortraitProvider 分工。原生修改在 third_party/md3music/rust/src/modules/misc.rs，复现入口为 tool/build_md3_beta_native.ps1；NOTICE 已说明来源与局部修改。
- Beta.11 motion-export.log 4/4 通过；外部 fixture 复用当前 Beta.11 实际组件，由 export-motion.py 导出欢迎/样式浅深四个 GIF，各 36 帧、每帧 80ms，未修改生产源码，也未使用旧 Beta.10 图冒充当前。它们是软件动态演示，与其他组重叠，不是设备 GPU/FPS 证明。
- 历史 Beta.10 已构建并验证 Mesting Music / com.mesting.music.beta / 1.0.37-beta.10 / 10，pubspec 保留正式基线；review-final.md 的有界独立判定为 ship，R1–R8 全部 resolved。普通回归 635 通过/54 条件跳过/0 失败，Beta 定向 150 通过/0 跳过/0 失败，最终软件 UI 34 通过/0 失败；组间重叠不可相加。analyze 无问题，同一 Beta 测试证书、16KiB ZIP 对齐、两种 ARM 服务库与 Beta.9 字节一致已验证。APK 为 89,227,526 bytes，SHA256 及精确证据见 docs/MD3MUSIC_BETA.md。首轮 27/7 与修复组 16 属于早期有界证据；首轮截图缺陷由最终捕获/复核闭合。源码归档精确字节/哈希由冻结后生成的外部 outputs/beta-1.0.37-beta.10/delivery-manifest.json 记录，避免自引用；这些结论仅属于 Beta.10。
- motion-export.log 另有 4 通过，复用相同软件 fixture 导出浅/深欢迎与样式预览，每个 GIF 36 帧、每帧 80ms；这是软件动态演示，不是 Android FPS 或原生 GPU 流畅度证据。设备清单为空，设备/线上边界继续保留。
- Beta.10 入口证据：beta_entry_flow.dart、BetaEntryCoordinator、BetaWelcomePage、BetaOnboardingPage、MestingMusicCompanions、BetaPlayerStylePreviews、BetaSignOutDialog；共享 BetaGlassButton/Field/BackButton、BetaAnchoredMenu、BetaSuccessMark/ActivityIndicator 和 PlayerCommentGlyph。评论菜单打开时实测各自触发器宽度；成功标记/等待状态由真实操作结果驱动。
- 延续结构边界：保持挂载的 MusicShell / BetaMusicShell、32dp BetaEdgeBack 与系统 BackButtonListener、beta_playback_actions、AutomaticSongPaging、OverflowMarquee、PlatformCommentComposer / KeyboardVisibilityBuilder。音质由 PlatformQualityCatalog/provider/resolver 管理；播放仍由 MestingAudioHandler 唯一持有。具体源码入口见 docs/MD3MUSIC_BETA.md。

- Beta 布局：`lib/features/experience/presentation/music_landing_page.dart`、`beta_music_shell.dart`、`beta_bottom_bar.dart`、`floating_playback_pill.dart`。
- 播放与歌词：`lib/features/experience/presentation/beta_now_playing_page.dart`、`apple_player_controls.dart`、`immersive_lyrics.dart`；复用 `lib/core/audio/mesting_audio_handler.dart`。
- 音量：`lib/core/audio/media_volume_controller.dart` 与 `android/app/src/main/kotlin/com/mesting/mesting_music/MediaVolumeBridge.kt`。
- 推荐：`lib/features/music_platform/data/platform_recommendations.dart`、`data/platform_explore.dart`、`platform_recommendation_providers.dart` 和对应 `platform_recommendations_page.dart` / `platform_search_landing.dart`。
- 视觉和迁移：`lib/features/themes/beta_appearance.dart`、`app_theme.dart`、`theme_controller.dart`、`app_brand_style.dart`、`theme_gallery_page.dart`；反馈入口为 `lib/shared/widgets/music_notice.dart`。
- 较早正式推荐入口：`lib/features/recommendation/presentation/recommendation_page.dart`；不应作为 Beta.7 平台推荐排序来源。
- 历史 Beta.9（2026-10-25）有界独立复核为 ship，R1–R5 全部闭合。普通回归 619 通过/52 条件跳过/0 失败，Beta 定向组 132 通过/0 跳过/0 失败，软件 UI 23 通过，命令与交互 21 通过；组间重叠不可相加。analyze 无问题。该版发布 APK 已构建并验证 com.mesting.music.beta / Mesting Music / 1.0.37-beta.9 / 9，同一 Beta 测试证书、16KiB ZIP 对齐和 ARM 服务库与 Beta.7 字节一致。该版源 ZIP 字节与哈希由其归档清单记录；这些结果仅适用于 Beta.9。
- work/beta9/pill-benchmark.json 对同一组 100 次播放位置事件的观测为 Beta.8 胶囊重建 99 次、Beta.9 为 0 次；这是 Flutter debug 构建工作量比较，不是帧率或真机流畅度证据。
- 当前没有连接的 Android 设备；软件捕获使用合成数据、Flutter 软件渲染和 Windows QA 中文字体。硬件音量、TalkBack、预测返回/硬件手势、真实 IME、原生 GPU 玻璃/动画/帧率、冷启动/升级迁移、线上 CDN/音质/权限及真实账号/评论写入仍待验收。历史 Beta.7/Beta.8 计数、结论和包身份仅描述各自构建，保留在 docs/MD3MUSIC_BETA.md。

## Product Principles

- 先让用户播放，再让用户探索。
- 平台推荐来源、顺序和反馈应比装饰更明确。
- 音乐封面是主要视觉资产，界面 chrome 保持克制。
- 颜色、图标、间距和交互状态必须来自可复用语义规则。
- 首次使用者无需学习 Material 组件习惯即可理解页面。
- 软件截图、模拟协议和构建成功只能证明各自范围，不能替代真机或线上服务验收。

## Accessibility & Inclusion

- 触控目标遵循移动端至少 44dp 的可用范围；Beta 收藏统一 48×48dp，音量响应区高 48dp。顶部收起 handle 等紧凑操作按实际尺寸记录，软件测试不等于真机可达性验收。
- 浅色和深色模式都保持正文、次级文字、分隔线和焦点状态的可读对比度。
- 图标不能成为唯一信息来源，重要操作需要清晰文字或语义标签。
- 播放进度与系统媒体音量必须有各自的名称、可理解值和可调节动作；widget 测试通过不等于 TalkBack 设备验收。
