# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

中文音乐用户，在通勤、工作学习、放松和入睡等片段时间里寻找合适的音乐。

## Product Purpose

Mesting 是一款 Flutter 音乐应用，帮助用户快速发现、播放和管理适合当下状态的音乐。成功标准是用户首次打开后能迅速理解当前推荐，并在较少操作内开始播放。

## Positioning

以封面主导、中文内容和连续播放组织发现与音乐库。Android Beta.8 延续 Beta.7 的固定版本 md3Music 平台来源、顺序和反馈契约，沿用用户确认的 Apple Music 视觉依据；正式渠道保留既有“当下状态驱动”的定制推荐。

## Operating Context

主要使用场景是移动端单手操作、碎片化使用和持续播放；首页、发现、音乐库、我的组成四个主要目的地，搜索独立。手机与宽屏共享 Beta 底栏，正文自适应约束宽度。

## Capabilities and Constraints

- 现有项目使用 Flutter。Android Beta 由 DistributionChannel.isBeta（appFlavor == beta）接入，包名 com.mesting.music.beta；正式 flavor 的页面、主题、定制推荐、导航和默认黑胶保持其原有契约。共享工具的改进按调用点生效，不构成全局渠道切换。
- Beta.5 新增音乐库路由、年/月 Replay 和歌单封面编辑。回顾只统计当前 owner 的真实每日记录，不反推未记录月份；云写入失败保留草稿，不显示虚假成功。
- Beta.6 封面规范化/只读回退与音质偏好契约继续。Beta.8 音质菜单依据当前歌曲真实资源只展示已有档位，不预填标准/高品质/无损/Hi-Res 四档。资源存在与会员权限分开判断，会员提示只在尝试选择后按平台结果出现，未知元数据手动重试。切换复用已有音频服务，保留进度、播放状态、队列与模式；失败保留旧流和旧偏好，偏好/实际返回/试听/降档分别如实表达。
- Beta.7 的发现呈现私人 FM、每日推荐、刷歌推荐与新歌速递，来源固定为 md3Music a69503b84e8829f888684f67c163be03c589c014 的 API/解析/刷新/续播契约；不再应用本地艺人评分和个人热榜。FM 提供红心/探索/小众/电台，保留 cur_mark、播放完成、喜欢/取消喜欢和不喜欢反馈及账号隔离。
- 只有明确从 FM/刷歌推荐开始的队列拥有推荐来源。剩余待播项 ≤3 时，服务按服务器顺序预取并追加到真实可见队列，不混入本地音乐库或随机备选池。明确搜索/歌单/音乐库播放会结束旧来源，即使碰巧选择同一录音；代次和账号校验拒绝过时响应。
- Beta 搜索首页与独立搜索入口使用真实 /search/hot 分榜关键词、历史和主题歌单/场景/热门歌单/排行/新碟等探索分类；关键词只触发搜索，不能伪装成可播放歌曲。旧定制推荐路由在 Beta 转入发现，正式渠道仍使用原实现。场景与主题的当前展示/可点击能力以平台已接入数据为准，不能仅凭端点存在承诺完整功能。
- cover、classic、aurora、cassette、lyricStage 五种样式保留各自上半区形象和动态，共用同一播放进度、裸白色 transport、Android 系统媒体音量及评论/音质/当前队列。封面与歌词模式都保留这些控件；播放器不建立另一套队列或音频服务。
- 系统音量通过 Android STREAM_MUSIC 原生桥读写/事件同步，无宿主禁用。Beta.8 提供 48dp 高响应区和即时拖动反馈，原生写入串行保留最新值，抑制重复状态、事件和相同步进。进度与音量各自提供中文名称、时长/百分比和可调节语义；硬件键和 TalkBack 仍待真机。
- Beta 装扮移除品牌选择器、重复皮肤说明/经典卡片、DRESS UP 和 followTheme 选项，固定 coral 图标/启动页；保留浅/深/系统、自定义图片/视频、显式 IP 进度配色/角色。Beta.8 再移除 IP 装饰开关，替代 Beta.6/Beta.7 的开关保留说明。Beta.7 残留 followTheme 转 classic，已转换显式 IP 保留；背景强度 .58、性能 automatic、完整 IP 主题退役继续适用。
- 轻量反馈使用一个可替换的顶部安全区半透明 HUD。普通提示仅保留短标题和图标，错误/警告保留可行动信息；通知不可覆盖真实业务结果。
- 不把 Material 3 默认色阶、默认按钮外观或默认卡片外观作为最终品牌表达。
- Beta.8 使用单一惰性 Apple 搜索结果列表，保留分页、收藏与更多；紧凑热搜保留分榜/排名/换页。左右窄边返回二级页面，内嵌/独立搜索按步骤返回。MusicShell 持有来源 tab，播放器/设置隐藏玻璃栏后仍恢复原目的地。
- 全局上一首/下一首区分明确列表上下文与 FM 服务器顺序/历史，Previous → Next 可回原曲。五样式完整播放器仅顶部灰色 handle 下拉收起，封面/歌词状态共用提交与回弹。
- 收藏统一裸心形、48×48dp 透明目标、局部主题对比与按压缩放；Replay 年份反馈/菜单为圆角，首页实心图标。经典唱机使用无黑描边的几何白色唱臂、唱头落在外圈沟槽，保留播放/暂停旋转区别；更多菜单带图标、分组、分隔线与当前样式对勾。
- 评论优先录音专属 ID，有界旧 ID 修复/设备注册恢复只针对读取，写入仍需明确操作且不自动重试。特色歌单解析 special_list/plist，排行解析 songlist；平台账号页使用实际 coral Mesting 应用图标。

## Brand Commitments

- 产品名称：Mesting；界面语言：简体中文。
- 需要降低常见 AI 生成界面的模板感，避免紫粉渐变、泛滥玻璃拟态、重复大圆角卡片和无意义装饰。
- Beta 以用户提供的 Apple Music 参考图为视觉依据：封面、大标题、横向内容组和悬浮控件；界面保留中文 Mesting 品牌与自身账号、播放能力。
- Beta.7 使用参考图采样红色统一导航选中态、个人页图标和相关选择，个人页面板浅红/深红适配；显式 IP 图案与角色继续拥有自身配色，选中标签保持主要文字对比。
- Beta 底部直接使用 liquid_glass_widgets 1.15.0 官方 Apple Music 示例的组件、布局与交互动态；内容区域与账号表单保持清楚稳定。玻璃限定悬浮 chrome，局部音质弹层/HUD按各自规范处理。
- 默认封面播放器可切换左对齐同步歌词；歌词当前基准为 24dp 并支持 TextScaler。迷你 accessory 仅保留播放/暂停和下一首两个裸图标，点击/左右滑动与官方玻璃交互继续适用。
- 酷狗、Mesting、游客各自拥有收藏和历史；Mesting 社交入口不会显示给酷狗账号。云端写入失败不伪装成本地成功，不能把平台来源当成会员授权。

## Evidence on Hand

- Beta.8 新边界：MusicShell / BetaMusicShell.navigationOwner、BetaEdgeBack、PlayerPullToDismiss、AppleSearchResults、AppleHotSearchBoards、PlayerMoreMenu；音质为 PlatformQualityCatalog/provider/resolver，播放仍由 MestingAudioHandler 唯一持有。具体源码入口见 docs/MD3MUSIC_BETA.md。

- Beta 布局：`lib/features/experience/presentation/music_landing_page.dart`、`beta_music_shell.dart`、`beta_bottom_bar.dart`、`floating_playback_pill.dart`。
- 播放与歌词：`lib/features/experience/presentation/beta_now_playing_page.dart`、`apple_player_controls.dart`、`immersive_lyrics.dart`；复用 `lib/core/audio/mesting_audio_handler.dart`。
- 音量：`lib/core/audio/media_volume_controller.dart` 与 `android/app/src/main/kotlin/com/mesting/mesting_music/MediaVolumeBridge.kt`。
- 推荐：`lib/features/music_platform/data/platform_recommendations.dart`、`data/platform_explore.dart`、`platform_recommendation_providers.dart` 和对应 `platform_recommendations_page.dart` / `platform_search_landing.dart`。
- 视觉和迁移：`lib/features/themes/beta_appearance.dart`、`app_theme.dart`、`theme_controller.dart`、`app_brand_style.dart`、`theme_gallery_page.dart`；反馈入口为 `lib/shared/widgets/music_notice.dart`。
- 较早正式推荐入口：`lib/features/recommendation/presentation/recommendation_page.dart`；不应作为 Beta.7 平台推荐排序来源。
- 2026-10-25 Beta.8 复核为 SHIP WITH STATED VALIDATION LIMITS，R1–R3 已闭合。组合验收组 33 项通过（14 UI + 19 transport/手势/API/音量），普通回归 602 通过/47 条件跳过，Beta 定向组 110 通过；均无失败，各组重叠不能相加。analyze 无问题。 相同 100 个快速音量样本的原生写入由 100 次降为 2 次、末值 1.0；480 首搜索在手机视口只实例化 10 个封面，是边界工作量证据，不是帧率指标。证据使用合成数据、Flutter 软件渲染和 Windows QA 中文字体，无实体 Android 验证。硬件音量、TalkBack、预测返回/硬件手势、真实 IME、GPU 动态/帧率、冷启动/升级迁移、线上 CDN/音质/权限及真实账号/评论写入仍待验收。发布构建、com.mesting.music.beta / 1.0.37-beta.8 / 8、同一测试证书、16KiB 对齐和 ARM 服务库一致性已验证；具体哈希与源归档由最终交付清单记录。 历史 Beta.7 证据与详情见 docs/MD3MUSIC_BETA.md。

## Product Principles

- 先让用户播放，再让用户探索。
- 平台推荐来源、顺序和反馈应比装饰更明确。
- 音乐封面是主要视觉资产，界面 chrome 保持克制。
- 颜色、图标、间距和交互状态必须来自可复用语义规则。
- 首次使用者无需学习 Material 组件习惯即可理解页面。
- 软件截图、模拟协议和构建成功只能证明各自范围，不能替代真机或线上服务验收。

## Accessibility & Inclusion

- 触控目标遵循移动端至少 44dp 的可用范围；Beta.8 收藏统一 48×48dp，音量响应区高 48dp。顶部收起 handle 等紧凑操作按实际尺寸记录，软件测试不等于真机可达性验收。
- 浅色和深色模式都保持正文、次级文字、分隔线和焦点状态的可读对比度。
- 图标不能成为唯一信息来源，重要操作需要清晰文字或语义标签。
- 播放进度与系统媒体音量必须有各自的名称、可理解值和可调节动作；widget 测试通过不等于 TalkBack 设备验收。
