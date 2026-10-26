---
name: Mesting Music Android Beta.10
description: 封面主导、红色强调与共享播放控件的中文私人听歌空间
colors:
  beta-accent: "#DE3A3D"
  beta-accent-dark: "#FF777A"
  beta-panel-light: "#F2F2F7"
  beta-panel-dark: "#291D20"
  entry-coral: "#DE5757"
  primary-seed: "#465CC7"
  primary-seed-dark: "#91A5FF"
  favorite: "#CC3F56"
  canvas-light: "#FFFFFF"
  canvas-dark: "#000000"
  surface-light: "#FCFCFD"
  surface-dark: "#11141B"
  text-primary-light: "#20232B"
  text-primary-dark: "#F5F7FC"
  text-secondary-light: "#5D6572"
  text-secondary-dark: "rgba(200,208,222,0.741176)"
  text-muted-light: "#7E8795"
  text-muted-dark: "rgba(152,162,179,0.568627)"
  player-base: "#17191F"
  player-ink: "#FFFFFF"
  lyric-inactive: "rgba(255,255,255,0.65098)"
typography:
  display: {fontFamily: "sans-serif, Noto Sans SC, Microsoft YaHei", fontSize: "34px", fontWeight: 800, lineHeight: 1.2, letterSpacing: "-0.9px"}
  headline: {fontSize: "23px", fontWeight: 800, letterSpacing: "-0.4px"}
  detail-title: {fontSize: "21px", fontWeight: 700, lineHeight: 1.2, letterSpacing: "-0.5px"}
  title: {fontSize: "16px", fontWeight: 600}
  body: {fontSize: "13px", fontWeight: 400}
  action: {fontSize: "14px", fontWeight: 800}
  glass-action: {fontSize: "15px", fontWeight: 700}
  label: {fontSize: "10px", fontWeight: 600}
  lyrics: {fontSize: "24px", fontWeight: 700, lineHeight: 1.4, letterSpacing: "-0.5px"}
rounded:
  artwork-small: "9px"
  cover: "12px"
  content: "18px"
  panel: "22px"
  dialog: "28px"
  player-quality: "30px"
  composer: "24px"
  floating: "32px"
  sheet: "36px"
  capsule: "999px"
spacing:
  tight: "4px"
  small: "8px"
  compact: "12px"
  shelf-gap: "14px"
  control: "18px"
  page: "22px"
  section: "24px"
  section-top: "28px"
components:
  button-primary: {typography: "{typography.action}", rounded: "{rounded.capsule}", height: "48px"}
  button-secondary: {rounded: "{rounded.capsule}", height: "48px"}
  button-text: {rounded: "{rounded.capsule}", height: "44px"}
  input: {rounded: "{rounded.content}", padding: "17px 18px"}
  chip: {rounded: "{rounded.capsule}"}
  panel: {rounded: "{rounded.panel}", padding: "20px"}
  cover: {rounded: "{rounded.cover}"}
  navigation: {rounded: "{rounded.capsule}", height: "64px"}
  playback-pill: {rounded: "{rounded.floating}", height: "64px"}
  player-transport: {backgroundColor: "transparent", textColor: "{colors.player-ink}", height: "48px"}
  favorite-button: {backgroundColor: "transparent", height: "48px", width: "48px"}
  media-volume: {height: "48px"}
  comment-input: {rounded: "{rounded.composer}"}
  comment-send: {backgroundColor: "rgba(0,99,216,0.94902)", textColor: "{colors.player-ink}", rounded: "{rounded.composer}", height: "48px", width: "48px"}
  glass-button: {typography: "{typography.glass-action}", rounded: "{rounded.capsule}", height: "52px", padding: "0 18px"}
  glass-field: {rounded: "{rounded.composer}", padding: "17px 20px"}
  glass-back: {rounded: "{rounded.capsule}", height: "48px", width: "48px"}
---

# Design System: Mesting Music Android Beta.10

## Overview

**Creative North Star: "封面主导的私人听歌空间"**

封面承担视觉重心，中文大标题与留白组织阅读顺序。横向内容组露出下一项，歌曲列表保持紧凑；播放与导航悬浮于内容之上。Beta 使用用户参考图采样的红色强调，经典浅色、深色和跟随系统共用布局，进度条样式与角色独立选择。

本文按当前 Beta.10 源码更新已经确认的设计系统，沿用 Apple Music 视觉依据与同一 North Star。可见名称为 Mesting Music。经典浅色使用中性白灰面板与既有红色强调，深色和封面播放器配色保留；入口与指南在此世界内使用珊瑚红原创音乐双角色和局部暖色背景。Beta 门限为 DistributionChannel.isBeta（Android appFlavor == beta）；正式 flavor 的页面、导航、迷你播放器、完整主题、定制推荐与默认黑胶契约保留，共享工具按调用点生效。

当前发布构建已验证为 Mesting Music / com.mesting.music.beta / 1.0.37-beta.10 / 10；最终重捕获及有界独立复核为 ship，R1–R8 resolved，回归/analyze 与发布包身份、签名、对齐、ARM 一致性已验证。精确计数和 APK 哈希见 docs/MD3MUSIC_BETA.md；源码归档身份由冻结后生成的外部交付清单记录，不嵌入待归档内容。Beta.9 的已验结论继续属于其历史构建。软件捕获和逐帧 GIF 使用合成数据、Flutter 软件渲染及 Windows QA 中文字体，不能证明原生 GPU 折射、帧率、硬件音量、TalkBack、真实 IME 或线上服务。入口方向来自既有 Mesting 世界、用户参考构图、珊瑚红矢量双角色选择及确认后的文字方案；没有独立 ImageGen 批准图、approval sidecar 或随机 FORM seed。

**Key Characteristics:**

- 封面主导，正文使用清楚稳定的主题表面。
- 大标题、粗体分区、紧凑曲目元数据形成层级。
- 中性白灰支撑经典浅色，Beta 红色统一导航和选中 chrome，显式 IP 图案与角色保留自身配色。
- 五种播放器共用白色播放操作、进度、系统媒体音量与底部功能。
- 真实玻璃服务持续挂载的悬浮 chrome、独立评论输入/发送与明确指定的 Beta 账号操作/字段；正文背景清楚稳定。
- 原创音符/唱片双角色以可控矢量、关节动作和浅深色可辨轮廓承载入口识别；等待与成功采用共享分段 spinner 和绘制标记。

## Colors

### Primary
Beta 的 beta-accent 来自用户固定参考图；深色使用 beta-accent-dark。BetaAppearance 与 app_theme.dart 将它们接入 primary，中性浅灰/既有深红面板接入 primaryContainer 和 surfaceContainerLow。四个目的地的选中图标与文字、个人页图标和相关选择使用这组颜色。正式 flavor 仍由既有主题种子与预设决定，primary-seed / primary-seed-dark 属于该保留系统。

entry-coral 是欢迎伙伴、指南选中描边/进度/插画的重复局部强调，不能替代导航的 beta-accent。入口暖色浅背景与暗色暖黑背景是该组表面的构图材料，不作为全应用页面底色。

### Secondary
favorite 保留为正式渠道收藏色；Beta 已选心形读取亮度适配的 beta-accent / beta-accent-dark，未选读取实际局部 onSurfaceVariant。显式 IP 进度图案/角色保留自身配色，选择外框用红色，标签保持 text-primary-*。

### Neutral
canvas-* 是经典纯色背景，surface-* 对应基础表面。正文、说明、弱提示成组随亮度切换；深色半透明文字须结合实际背景判断。Beta 个人页与低阶内容面板使用 beta-panel-*；经典浅色的表面与分层容器为中性白灰，不能从红色 seed 自动生成粉色背景。播放器使用 player-base、白色文字、封面模糊和深色罩层；非当前歌词降亮度。

**The Theme Ownership Rule.** Beta 红色拥有导航与选择 chrome，歌曲封面拥有氛围，显式 IP 图案与角色拥有自身配色；正式 flavor 继续读取原主题。

**The Local Contrast Rule.** 经典灰色唱机的顶部收起/更多操作使用局部深色半透明底，底部加强深色罩层，歌手为不透明白字；共享上一首/播放/下一首仍是裸白色图标。

## Typography

平台默认无衬线，中文回退 Noto Sans SC、Microsoft YaHei、sans-serif；没有新增品牌字体包。截图测试的 BetaQACJK 与显式 chip/subtitle 字体是 QA 设施，不是产品字体。QA 字体的覆盖范围不能代替 Android 字体与字形验收。

display 用于主要页面标题，headline 用于分区；详情页使用 detail-title 单行标题，OverflowMarquee 合并 DefaultTextStyle 后使用同一字体、间距和 TextScaler 测量，只在实际溢出时裁切平移，减少动画时静止。曲目使用 title 并单行省略，普通封面标题为相近的小一档（15dp/600）且最多两行。body 承载歌手与说明，空状态行高（1.6）；action 承载按钮，label 配合导航图标。同步歌词从 Beta.6 的 30dp 收敛到当前 24dp，按真实文本与 TextScaler 测量，左对齐、当前行白色、其余降亮度，上下边缘渐隐。

**The Readable Hierarchy Rule.** 长内容换行、省略或滚动，不缩小整页文字来塞满首屏。

## Layout

Flutter 数值为逻辑像素；frontmatter 的 px 是可移植记法，文字遵循系统 TextScaler。页面左右（22dp）、书架间隔（14dp）、分区上/下（28/14dp）。页头计入安全区，正文回弹、可刷新。常规封面宽（158dp）、歌单（174dp）；歌曲行方封面（52dp），垂直内距（9dp）。

窗口分级：compact <600dp、medium 600–839dp、expanded ≥840dp；正文内容上限依次为可用宽、760dp、1080dp。Beta 手机和宽屏统一使用同一个官方底栏，不显示左轨或预留 88dp 左轨占位。音乐库可用宽 ≥650dp 时两列变四列；特色封面按可用宽计算并夹紧，保留邻项露出。正式 flavor 的既有自适应导航保持原有行为。

**The Reachable Content Rule.** 编辑式正文保留底部滚动余量；短屏播放器增加可滚动高度，文字缩放时增加空间，保留全部播放操作。搜索内容延伸到悬浮玻璃后方，清空原先整条不透明白底；搜索正文内部保留底部余量。官方底栏处理手势安全区和搜索键盘抬升，shell 仅为搜索正文避让键盘，不能重复移动底栏。设置/聊天/完整播放器/媒体预览分别控制悬浮层显示。

**The Transition Surface Rule.** 搜索与普通路由移动中的整页背景读取当前主题不透明 colorScheme.surface；源页保留挂载、焦点/语义/触摸按可见状态切换，不能用透明 scaffoldBackgroundColor 作为遮挡。播放器退场仍连续显露真实下层与已挂载胶囊。

搜索结果用单一 CustomScrollView / SliverList 惰性构建，保留 52dp 封面、紧凑元数据、裸心、更多和真实分页。热搜每页最多 10 词，常规两列、≥650dp 三列，分榜/排名/换页仍在。更多菜单窄屏/大字可换行滚动。AutomaticSongPaging 按新布局的滚动指标提前加载，距离末端不超过 480dp 时可请求下一页；短列表按新指标填充视口，隐藏页面暂停请求。正常状态不显示手动加载按钮，失败保留列表并提供重试；搜索只显示“共 N 首”。

## Elevation & Depth


正文依靠留白、稳定表面与封面层次。特色封面以底部深色渐层承载白字，播放器使用封面模糊与深色罩层。封面局部柔影不是全局阴影；收藏为透明裸心形，不再以圆底/光晕作默认容器。

固定运行依赖 liquid_glass_widgets 1.15.0，官方示例来源快照保留在 third_party/liquid_glass_widgets/。Beta 底部 chrome 直接组合官方 Apple Music 示例的 GlassScaffold、GlassTabBar.searchable 与 GlassButton.custom，由库负责按压、拖动、弹簧和 accessory 形变。底栏使用 premium/full、blur 2、thickness 30、lightIntensity .2、chromaticAberration .01、saturation 1.2、fresnelStrength 0；播放胶囊单独使用 lightIntensity .18。浅/深底栏颜色分别为 #AAF2F2F7 / #AA1C1C1E，胶囊为 #CCF2F2F7 / #CC1C1C1E。

原 MestingGlass 仍用于其他表面，其 standard、blur 12、thickness 22、lightIntensity .22、chromaticAberration .005 及高对比时不透明 surface + outline 是独立实现，不能套用到官方底栏。官方 chrome 使用库自身行为，不能宣称继承原 MestingGlass 的降级或全部透明度均关闭。

**The Floating Glass Rule.** 内容封面、列表与正文背景保持稳定表面；折射用于悬浮 chrome、评论输入/发送及用户指定的 Beta 返回、欢迎/账号/验证码/退出操作与账号字段。每个玻璃控件独立拥有层，不能嵌套玻璃而失去子层折射。封面模糊、播放器音质弹层和短时状态 HUD 各按自身局部背景处理；该扩展不构成正式渠道全局改版。

BetaGlassButton、BetaGlassField 和 BetaGlassBackButton 复用 betaMusicPillGlass，均为 premium/useOwnLayer 和独立 RepaintBoundary。按钮以胶囊轮廓、文字强调及库内按压形变表达层级，字段使用 composer 圆角和无实心填充的 TextField。静态 sidecar 只示意结构、色彩与状态，不能复现库的原生光学。

评论发送直接使用库内 GlassButton.custom 的 premium 渲染，不使用位图仿制。输入使用 GlassContainer，输入和按钮各自 useOwnLayer 并置于独立 RepaintBoundary；不能嵌套玻璃按钮而使折射失效。蓝色发送是该操作的局部材质，不能替代全局红色强调。静态 HTML 预览与 Flutter 软件捕获均不能承诺 Android GPU 的立体折射效果。

## Shapes

小图片轻圆角，封面保留方形比例；普通封面、面板、弹窗用 cover / panel / dialog。按钮、chip、导航为胶囊；播放胶囊 32dp，编辑 sheet 只圆顶部。transport/收藏为透明目标；音质弹层 30dp、HUD 25dp。Replay 年份使用 Cupertino 透明度按压反馈，菜单圆角裁切且不绘制矩形反馈底；更多为锚定 22dp 圆角局部模糊弹层。经典唱臂白色几何轮廓、无黑描边，唱头接触标签外的黑色沟槽。

## Components

- **收起与更多**：PlayerPullToDismiss 仅顶部灰色 handle 接收下拉，五样式封面/歌词共用提交/回弹，减少动画即时完成；handle 可点击，封面/歌词/滑块不竞争收起。PlayerMoreMenu 锚定顶部更多，图标行按组分隔、当前样式带对勾，最大宽 280dp、窄屏两侧至少 16dp。
- **收藏**：裸心统一 48×48dp 透明目标，compact 仅改 glyph；按压缩放 .88/120ms。真实成功状态驱动 420ms 局部填充/轮廓与缩放动画，喜欢峰值 1.24、取消喜欢 .8 后归位，方向可中断，减少动画直接终态；失败不播放虚假成功庆祝。保留键盘激活和账号归属。经典唱片/唱臂保留播放和暂停的旋转区别。
- **播放选择与历史**：单点只播放一首，明确“播放全部”才导入集合；已有手动待播提供保留/替换选择，手动项优先自动项。普通队列耗尽在完成或下一首时由平台继续，自动项在当前队列中有独立标识。上一首根据实际播放历史返回，无历史则重播当前；普通自动续播不取得 FM 反馈归属。MestingAudioHandler 是唯一播放 owner；后来暂停/停止/seek 会使慢速下一首结果失效。

- **按钮与表单**：既有 PlatformStyle 填充/描边最小 48×48dp，文字按钮 44×44dp；primary/onPrimary、低阶表面或安静文字区分层级。普通输入 18dp 圆角，焦点 primary 1.5dp 描边，错误使用主题 error。Beta.10 指定账号操作改用 BetaGlassButton：默认高 52dp、横向内距 18dp、15dp/700，强调版本使用当前亮度 Beta 红文字；调用点可设高度，不能把所有调用都记成 52dp。BetaGlassBackButton 为 48dp 圆形和中文返回语义。BetaGlassField 为 24dp 圆角，字段内距 20/17dp、外加横向 3dp，字段自身保留焦点、校验、键盘与错误语义。Mesting 登录/注册的六个字段和两个主操作也使用这些组件，正式渠道继续原控件。
- **Chip / 面板**：普通 chip 选中为 primary 轻填充。PlatformPanel 为 22dp 圆角、20dp 内距的不透明 surfaceContainerLow。Beta 进度样式/角色选择用红色轻填充、边线与轻影，标签保持主题主要文字；加载、失败、空数据及适用重试如实显示。
- **导航**：四目的地和独立搜索延续，首页实心图标，选中图标/文字用 Beta 红色。底栏基础 64dp、搜索/accessory 50dp，随 TextScaler 最多加 28dp；内距 20/16dp、间距 8dp。滚动超过 88dp 收拢 accessory，回到 24dp 才展开，再点当前 tab 回顶部。MusicShell 持久持有来源 tab 与滚动位置，BetaMusicShell 在播放器/设置后方保持挂载，chrome 仅改变透明度与显露。BetaEdgeBack 占左右 32dp 边缘；BackButtonListener 先接系统返回，二级页和内嵌/独立搜索按“结果→搜索首页→来源页”返回，保留内部书架/滑块手势。
- **播放条**：有当前媒体才显示，作为官方底栏 accessory；32dp 方封面、歌曲/歌手，仅保留播放/暂停与下一首两个裸图标。点击打开播放器、左右滑动切歌。较窄且文字放大时可省略歌手；不按宽度添加队列按钮。GlassButton.custom 基础高度 64dp，只订阅 playing 布尔值避免随进度事件重建，播放/暂停使用共享实时 toggle 操作以便快速再次点击取消淡出；复用既有音频服务。
- **播放器**：Beta 默认沉浸封面；cover、classic、aurora、cassette、lyricStage 五种样式保留上半区各自视觉/动态身份，下半区统一使用 ApplePlayerControls。顺序为进度与时间、裸白色 Cupertino 上一首/播放暂停/下一首、真实系统媒体音量、评论/音质/当前队列；封面和歌词两种状态都保留同一组控件。顶部小封面、歌名/歌手与模糊封面背景组织歌词页，点击同步歌词跳转进度。PlayerContentTransition 使用局部淡变、微移和缩放的成对入退，默认进入 360ms/退出 280ms；封面/歌词方向相反，上一首/下一首读取 userCommandStream，样式按枚举方向切换；共享 transport 与音频 owner 不重建，减少动画时该过渡归零。
- **滑块语义与系统音量**：进度合并语义“播放进度”读已播/总时长，音量“系统媒体音量”读百分比，保留原生可调动作。音量轨纤细视觉与 48dp 高响应区并存，拖动本地即时更新。Dart 串行保留最新待写值，Kotlin 抑制重复事件和相同步进，前台刷新 STREAM_MUSIC，无宿主禁用。原生写入工作量与 Android 硬件/TalkBack/帧率属于不同验证边界，后者仍待真机。
- **音质**：五样式共用持久化偏好与 30dp 圆角浅/深半透明弹层。PlatformQualityCatalog 依据当前歌曲正值资源 hash/显式资源档位生成选项，会员标志不制造资源；只显示已有档位，未知/失败手动重载，无自动循环。弹层随歌曲更新，选择绑定录音 ID。会员提示只在尝试选择后按平台结果出现。档位保留各自编码 hash，严格请求选择的来源，避免以 FLAC hash 请求标准档仍返回 FLAC；勾选、提示和 footer 与实际引擎来源一致后才保存偏好。既有 handler 保留进度、播放状态、队列/模式，失败保留旧流/旧偏好；偏好、实际、试听、降档与待平台确认分开表达。
- **同曲媒体修订**：currentMediaRevisionProvider 只随媒体项发布递增，使同 ID 音质/元数据变化能够更新 currentTrackProvider，不扩大为位置 tick 订阅。resolver 有损实测码率优先于请求标签；不符/未知维持失败恢复契约，不能以顶部成功文案作为实际档位的唯一证据。
- **评论**：排序（最热/最新/最早）与范围（全部/歌手/我的）两个下拉并排单行，保留排序范围说明、回复/删除与真实线程归属；日期、赞数与排序说明读取局部 textSecondary 以保持浅深色可读性。浮动 composer 使用 24dp 圆角输入，蓝色 48×48dp 发送作为兄弟玻璃按钮；输入 16dp/1.4，键盘显示最多 2 行，否则最多 4 行，最多 1000 字。KeyboardVisibilityBuilder 观察当前原生 View.viewInsets，不读取已被 Scaffold 消耗的 body inset；发送中禁用并显示真实进度。
- **评论菜单与 glyph**：BetaAnchoredMenu 打开时测量各自触发器的真实 RenderBox 宽度并约束菜单，最小触发器 90×44dp 不能当作固定弹层宽度；勾选/间隔/Expanded 标签在相同宽内布局。22dp 圆角菜单使用主题表面。PlayerCommentGlyph 以同一绘制函数提供圆形引号气泡并在教程复用；音质为 Cupertino 中间音箱，原操作语义和目标保留。
- **音乐伙伴与预览**：欢迎/指南复用原创音符和唱片双角色，身体、四肢、面部与耳机由矢量分层绘制，深色外部轮廓提高对比而非全体发光。五种样式小预览共用一个局部绘制时钟与真实样式偏好，每张卡有独立可辨舞台、文字/勾选与 selected 语义，邻页通过 TickerMode 暂停；演示不新建音频服务。入口/指南的具体顺序与构图见对应 surface brief，不作为其他页面模板。
- **装扮**：保留浅/深/系统、自定义图片/视频、五种播放器与显式进度配色/角色。Beta.8 移除 IP 装饰开关，替代 Beta.6/Beta.7 的保留说明；品牌选择器、重复皮肤说明/经典卡片、DRESS UP、followTheme 继续移除。coral 启动身份和旧品牌迁移、残留 followTheme 转 classic、显式 IP 保留、完整 IP 主题退役、背景强度 .58 与性能 automatic 延续。平台账号入口使用实际 coral Mesting 应用图标；正式主题行为保留。
- **状态反馈**：showMusicNotice 以顶部安全区下的单个半透明 HUD 替换前一个通知；短标题加图标，支持浅深色、淡入/顶部滑入/缩放与减少动画。普通提示省略旧说明，错误/警告仍保留可行动原因；Semantics liveRegion 读出可见信息。不建立第二套成功/失败状态。
- **等待与登录成功**：BetaActivityIndicator 统一分段 Cupertino spinner 的尺寸/语义，按验证码、扫码、登录/退出和加载所在区域呈现，等待中禁用重复提交。BetaSuccessMark 共享绘制圆环与对勾，评论成功反馈读取真实结果。居中登录成功卡先进入、绘制标记，再退出后进入指南；减少动画仅按各组件实际实现记录，不宣称全流程全部定时与时钟已停用。退出失败在原对话框保留可恢复错误与会话。
- **封面恢复**：推荐、搜索、歌单与播放器共用平台封面规范化，接受有效 HTTP/HTTPS 与协议相对 URL、替换尺寸占位并跳过裸文件名。列表元数据回退仅只读，合并同歌曲请求、最多 3 并发、缓存最近 256 个成功封面；临时失败不永久缓存，也不影响播放或触发云写入。
- **歌单编辑**：PageView viewportFraction .72，中心方封面、邻项露出、相机/圆点指示；第一项现有/相册，另六项本地模板，空封面有加图占位。固定页头 48dp 强调对勾与安静取消；键盘上移、表单滚动。保存中禁用并显示进度，失败保留草稿，成功才关闭；结果为 640×640 不透明 PNG。
- **Replay 与 owner**：按当前账号本机每日记录聚合年/月，年份 Cupertino 透明度反馈/圆角菜单，选中月进入视野；封面氛围、大排名、时长和“歌曲封面”披露共存，不补算缺失月份。账号归属、收藏/播放唯一状态与既有推荐来源继续适用。

封面/歌词切换与歌词跟随读取 disableAnimations，主题背景也尊重减少动画；局部文字淡变与 sheet 键盘动画仍固定时长，不宣称全应用完全适配。

## Do's and Don'ts

### Do:
- **Do** 使用语义色并检查浅深色、红色选中 chrome 与装扮背景的最终对比。
- **Do** 让封面、歌曲、歌手与真实平台内容承担信息层级。
- **Do** 提供中文 tooltip/语义标签、selected 状态、文字缩放及可达操作。
- **Do** 让加载、空状态、失败、草稿与账号归属如实可见。

### Don't:
- **Don't** 把 Beta 条件组合推广为正式分支的全局布局或默认播放器。
- **Don't** 将 Beta 指定账号控件的玻璃扩展成全部正文/列表或正式渠道的默认材质，或把评论发送嵌套进输入玻璃而丢失独立折射。
- **Don't** 以无意义眉题、重复圆角外框或装饰渐变替代真实内容。
- **Don't** 把 fixture、歌曲封面、未记录月份或失败写入描述为生产素材、艺人肖像、历史统计或成功。
- **Don't** 给共享播放 transport 恢复大圆面，或把两个滑块合成无名且不可调的语义节点。
- **Don't** 以软件截图宣称真机 TalkBack、硬件音量、GPU Apple 效果或线上服务已验收。

未固化为规则：软件渲染中的平面玻璃外观不是原生 GPU 光学保证；局部减少动画仍不完整，部分局部时钟与固定计时继续存在；收起 handle 的 112×36dp 手势区和指南跳过等紧凑目标按实际尺寸披露，不能推广为触控尺寸规范；重复测试人像不是素材规范；教程中的字体 glyph 绘制是现有演示实现，不推广为后续图标系统。首轮捕获曾有缺图/字形/轮廓问题，已在有界最终复核闭合，不把它们编成设计规则。范围为通用 Android 兼容，没有机型专属优化，效果/动画/功能均保留；软件捕获、36 帧/80ms GIF 和边界工作量不替代真机 GPU/FPS 或线上验收。
