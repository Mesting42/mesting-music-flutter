# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

中文音乐用户，在通勤、工作学习、放松和入睡等片段时间里寻找合适的音乐。

## Product Purpose

Mesting 是一款 Flutter 音乐应用，帮助用户快速发现、播放和管理适合当下状态的音乐。成功标准是用户首次打开后能迅速理解当前推荐，并在较少操作内开始播放。

## Positioning

以封面主导、中文内容和连续播放组织发现与音乐库。Android Beta.10 延续固定版本 md3Music 平台来源、顺序和反馈契约，沿用用户确认的 Apple Music 视觉依据，并以原创音乐伙伴、真实登录及八页使用指南建立进入体验；正式渠道保留既有“当下状态驱动”的定制推荐。

## Operating Context

主要使用场景是移动端单手操作、碎片化使用和持续播放；首页、发现、音乐库、我的组成四个主要目的地，搜索独立。手机与宽屏共享 Beta 底栏，正文自适应约束宽度。

## Capabilities and Constraints

- 现有项目使用 Flutter。Android Beta 由 DistributionChannel.isBeta（appFlavor == beta）接入，包名 com.mesting.music.beta；正式 flavor 的页面、主题、定制推荐、导航和默认黑胶保持其原有契约。共享工具的改进按调用点生效，不构成全局渠道切换。
- Beta.10 首次未完成进入且无恢复会话时显示欢迎页；每次新的交互式登录成功都依次显示成功卡、八页引导，再进入应用。恢复凭证与刷新 token 不算新登录，二维码轮询不能重复触发成功流程。游客直接进入应用，指南可跳过并在设置重新查看；退出仅真实成功后回欢迎页，等待时禁用重复操作，失败保留会话并允许重试。两类账号控制器继续独立持有凭证，酷狗、Mesting 与游客的数据归属延续。
- 欢迎页优先手机号和微信扫码，其他方式保留酷狗/QQ 扫码及 Mesting 账号登录/注册，协议与隐私入口可达。八页指南根据实际发现/搜索、歌词、灰条收起与底部操作、账号适用的推荐/收藏、手动队列优先与续播/历史、外观、五种播放器、开始使用组织；不承诺桌面歌词、Zen 或 AI 等未实现能力。五张动态预览共用真实 playerVisualStyleProvider，选择会保存到装扮/播放器相同偏好；外观模式也读取真实主题偏好。演示不发起播放、云写入或第二个音频 owner。
- Beta.10 在现有严格编码 hash 切换上，增加同 ID 的媒体修订通知，使当前曲音质/元数据跟随真实媒体发布而更新，且不订阅位置 tick。有损返回的正值实测码率优先于可能由适配器补入的请求档位标签；严格切换不符或无法确认时保留旧音源和偏好。当前软件证据不等于真实 CDN/会员权限验收。
- Beta.10 搜索和普通路由过渡使用当前主题不透明 surface 遮挡旧内容，源页保留挂载与滚动。播放器封面/歌词、曲目身份和样式保留成对入退；上一首/下一首读取真实播放命令方向。共享 transport 与音频 owner 持续存在，快速反复操作由局部过渡接续。
- Beta.5 新增音乐库路由、年/月 Replay 和歌单封面编辑。回顾只统计当前 owner 的真实每日记录，不反推未记录月份；云写入失败保留草稿，不显示虚假成功。
- Beta.6 封面规范化/只读回退与音质偏好契约继续。Beta.9 音质菜单依据当前歌曲真实资源只展示已有档位，不预填标准/高品质/无损/Hi-Res 四档。资源存在与会员权限分开判断，会员提示只在尝试选择后按平台结果出现，未知元数据手动重试。切换保留档位到编码 hash 的对应关系，严格请求所选实际音源，无损降到高品质/标准也使用目标档位的 hash；勾选、提示和播放器实际来源一致后才保存偏好。复用已有音频服务并保留进度、播放状态、队列与模式；失败保留旧流和旧偏好，偏好/实际返回/试听/降档分别如实表达。
- Beta.7 的发现呈现私人 FM、每日推荐、刷歌推荐与新歌速递，来源固定为 md3Music a69503b84e8829f888684f67c163be03c589c014 的 API/解析/刷新/续播契约；不再应用本地艺人评分和个人热榜。FM 提供红心/探索/小众/电台，保留 cur_mark、播放完成、喜欢/取消喜欢和不喜欢反馈及账号隔离。
- Beta.9 单点只播放所选一首，不隐式导入整页歌曲；只有明确“播放全部”才导入集合。已有手动待播时按实际情况提供保留/替换选择，手动队列优先于自动推荐。普通播放在手动队列耗尽后可由完成或“下一首”进入平台自动续播；当前队列区分自动项。上一首使用实际播放历史，没有历史则重播当前，不从未播放的页面曲目伪造历史。
- 只有明确从 FM/刷歌推荐开始才拥有该来源的反馈归属；普通自动续播不冒充 FM。剩余待播项 ≤3 时按服务器顺序预取并追加到真实可见队列，不混入本地音乐库或随机备选池。明确搜索/歌单/音乐库播放结束旧 FM 来源，即使碰巧同一录音；代次和账号校验拒绝过时响应，慢速“下一首”不能在后续暂停/停止/跳转进度后重新启动播放。
- Beta 搜索首页与独立搜索入口使用真实 /search/hot 分榜关键词、历史和主题歌单/场景/热门歌单/排行/新碟等探索分类；关键词只触发搜索，不能伪装成可播放歌曲。旧定制推荐路由在 Beta 转入发现，正式渠道仍使用原实现。场景与主题的当前展示/可点击能力以平台已接入数据为准，不能仅凭端点存在承诺完整功能。
- cover、classic、aurora、cassette、lyricStage 五种样式保留各自上半区形象和动态，共用同一播放进度、裸白色 transport、Android 系统媒体音量及评论/音质/当前队列。封面与歌词模式都保留这些控件；播放器不建立另一套队列或音频服务。
- 系统音量通过 Android STREAM_MUSIC 原生桥读写/事件同步，无宿主禁用。Beta.8 提供 48dp 高响应区和即时拖动反馈，原生写入串行保留最新值，抑制重复状态、事件和相同步进。进度与音量各自提供中文名称、时长/百分比和可调节语义；硬件键和 TalkBack 仍待真机。
- Beta 装扮移除品牌选择器、重复皮肤说明/经典卡片、DRESS UP 和 followTheme 选项，固定 coral 图标/启动页；保留浅/深/系统、自定义图片/视频、显式 IP 进度配色/角色。Beta.8 再移除 IP 装饰开关，替代 Beta.6/Beta.7 的开关保留说明。Beta.7 残留 followTheme 转 classic，已转换显式 IP 保留；背景强度 .58、性能 automatic、完整 IP 主题退役继续适用。
- 轻量反馈使用一个可替换的顶部安全区半透明 HUD。普通提示仅保留短标题和图标，错误/警告保留可行动信息；通知不可覆盖真实业务结果。
- 不把 Material 3 默认色阶、默认按钮外观或默认卡片外观作为最终品牌表达。
- Beta.9 使用单一惰性 Apple 搜索结果列表，计数只显示“共 N 首”；歌曲列表按滚动指标自动分页，失败才显示重试，保留服务端顺序、收藏与更多。紧凑热搜保留分榜/排名/换页。左右 32dp 边缘和真实系统返回均逐步执行“搜索结果→搜索首页→来源页”。MusicShell 持有来源 tab 与滚动位置，BetaMusicShell 在播放器/设置后方保持挂载，仅改变 chrome 可见性。
- 五样式完整播放器仅顶部灰色 handle 下拉收起，封面/歌词状态共用提交与回弹；持续挂载的胶囊随下拉显露。胶囊仅订阅播放布尔值并使用共享实时播放/暂停操作，滚动超过 88dp 才收拢、回到 24dp 才展开，保留真实玻璃。
- 收藏统一裸心形、48×48dp 透明目标、局部主题对比与按压缩放；成功状态以局部 420ms 动画表达喜欢/取消喜欢，可中断并尊重减少动画。Replay 年份使用 Cupertino 透明度反馈与圆角菜单，不产生矩形按压底；首页实心图标。经典唱机使用无黑描边的几何白色唱臂、唱头落在外圈沟槽，保留播放/暂停旋转区别；更多菜单带图标、分组、分隔线与当前样式对勾。
- 详情标题使用 21dp 单行文字，仅实际溢出时裁切跑马灯；测量与渲染共用继承字体和 TextScaler。
- 评论排序/范围各为一个下拉菜单并排一行；浮动输入和蓝色 48dp 3D 发送按钮是独立的真实 Liquid Glass 兄弟表面，使用 liquid_glass_widgets premium 渲染，不能嵌套或以位图替代。KeyboardVisibilityBuilder 观察当前原生 View 的键盘指标：键盘显示最多 2 行，否则最多 4 行。评论优先录音专属 ID，有界旧 ID 修复/设备注册恢复只针对读取；发送/回复/删除均需明确操作且不自动重试。特色歌单解析 special_list/plist，排行解析 songlist；平台账号页使用实际 coral Mesting 应用图标。

## Brand Commitments

- 产品品牌：Mesting；Beta 可见应用名称统一为 Mesting Music；界面语言：简体中文。
- 需要降低常见 AI 生成界面的模板感，避免紫粉渐变、泛滥玻璃拟态、重复大圆角卡片和无意义装饰。
- Beta 以用户提供的 Apple Music 参考图为视觉依据：封面、大标题、横向内容组和悬浮控件；界面保留中文 Mesting 品牌与自身账号、播放能力。
- Beta 使用参考图采样红色统一导航选中态、个人页图标和相关选择；Beta.9 经典浅色面板改为中性白灰（#F2F2F7），保留红色强调、既有深色与封面播放器氛围。显式 IP 图案与角色继续拥有自身配色，选中标签保持主要文字对比。
- Beta 底部直接使用 liquid_glass_widgets 1.15.0 官方 Apple Music 示例的组件、布局与交互动态。Beta.10 经用户确认将同一 premium 材质扩展至欢迎/登录/验证码/退出等指定账号操作、账号输入、圆形返回及开源许可入口；每个表面独立拥有玻璃层，评论输入/蓝色发送继续为兄弟表面。内容列表、阅读正文及表单所在页面背景保持稳定；该范围按 Beta 调用点接入，不构成正式渠道的全局改版。局部音质弹层/HUD 按自身规范处理。
- Beta.10 的欢迎与指南采用用户选定的珊瑚红原创音符/唱片矢量双角色，具有四肢、表情、轻摆、眨眼和轻点问候；沿用既有 Mesting 世界、所给参考构图及随后确认的完整文字方案。没有另外生成或批准的 ImageGen comp、approval sidecar 或随机 FORM seed，不能事后补造来源记录。
- 默认封面播放器可切换左对齐同步歌词；歌词当前基准为 24dp 并支持 TextScaler。迷你 accessory 仅保留播放/暂停和下一首两个裸图标，点击/左右滑动与官方玻璃交互继续适用。
- 酷狗、Mesting、游客各自拥有收藏和历史；Mesting 社交入口不会显示给酷狗账号。云端写入失败不伪装成本地成功，不能把平台来源当成会员授权。

## Evidence on Hand

- 当前 Beta.10 已构建并验证 Mesting Music / com.mesting.music.beta / 1.0.37-beta.10 / 10，pubspec 保留正式基线；review-final.md 的有界独立判定为 ship，R1–R8 全部 resolved。普通回归 635 通过/54 条件跳过/0 失败，Beta 定向 150 通过/0 跳过/0 失败，最终软件 UI 34 通过/0 失败；组间重叠不可相加。analyze 无问题，同一 Beta 测试证书、16KiB ZIP 对齐、两种 ARM 服务库与 Beta.9 字节一致已验证。APK 为 89,227,526 bytes，SHA256 及精确证据见 docs/MD3MUSIC_BETA.md。首轮 27/7 与修复组 16 属于早期有界证据；首轮截图缺陷由最终捕获/复核闭合。源码归档精确字节/哈希由冻结后生成的外部 outputs/beta-1.0.37-beta.10/delivery-manifest.json 记录，避免自引用。
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
