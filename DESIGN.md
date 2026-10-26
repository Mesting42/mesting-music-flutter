---
name: Mesting Android Beta.8
description: 封面主导、红色强调与共享播放控件的中文私人听歌空间
colors:
  beta-accent: "#DE3A3D"
  beta-accent-dark: "#FF777A"
  beta-panel-light: "#FCF0F0"
  beta-panel-dark: "#291D20"
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
  title: {fontSize: "16px", fontWeight: 600}
  body: {fontSize: "13px", fontWeight: 400}
  action: {fontSize: "14px", fontWeight: 800}
  label: {fontSize: "10px", fontWeight: 600}
  lyrics: {fontSize: "24px", fontWeight: 700, lineHeight: 1.4, letterSpacing: "-0.5px"}
rounded:
  artwork-small: "9px"
  cover: "12px"
  content: "18px"
  panel: "22px"
  dialog: "28px"
  player-quality: "30px"
  replay-year: "20px"
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
---

# Design System: Mesting Android Beta.8

## Overview

**Creative North Star: "封面主导的私人听歌空间"**

封面承担视觉重心，中文大标题与留白组织阅读顺序。横向内容组露出下一项，歌曲列表保持紧凑；播放与导航悬浮于内容之上。Beta 使用用户参考图采样的红色强调，经典浅色、深色和跟随系统共用布局，进度条样式与角色独立选择。

本文合并记录已经实现的 Android Beta.8，延续用户确认的 Apple Music 视觉依据与同一 North Star。Beta.7 已替代 Beta.6 的强调色、圆面 transport、迷你队列按钮与 followTheme 描述；Beta.8 再替代固定四档音质菜单、IP 装饰开关与 38dp 收藏目标。Beta 门限仍为 DistributionChannel.isBeta（Android appFlavor == beta）；正式 flavor 的页面、导航、迷你播放器、完整主题、定制推荐与默认黑胶契约保留，共享工具按调用点生效。

依据为当前主题、导航、播放器、搜索、装扮及平台源码与 Beta.8 finish verdict / screenshots-verdict。2026-10-25 Beta.8 复核为 SHIP WITH STATED VALIDATION LIMITS，R1–R3 已闭合。组合验收组 33 项通过（14 UI + 19 transport/手势/API/音量），普通回归 602 通过/47 条件跳过，Beta 定向组 110 通过；均无失败，各组重叠不能相加。analyze 无问题。证据使用合成数据、Flutter 软件渲染和 Windows QA 中文字体，无实体 Android 验证。硬件音量、TalkBack、预测返回/硬件手势、真实 IME、GPU 动态/帧率、冷启动/升级迁移、线上 CDN/音质/权限及真实账号/评论写入仍待验收。发布构建、com.mesting.music.beta / 1.0.37-beta.8 / 8、同一测试证书、16KiB 对齐和 ARM 服务库一致性已验证；具体哈希与源归档由最终交付清单记录。 不承诺与原生 Apple GPU 效果逐像素一致。

**Key Characteristics:**

- 封面主导，正文使用清楚稳定的主题表面。
- 大标题、粗体分区、紧凑曲目元数据形成层级。
- Beta 红色统一导航和选中 chrome，显式 IP 图案与角色保留自身配色。
- 五种播放器共用白色播放操作、进度、系统媒体音量与底部功能。
- 玻璃服务悬浮 chrome，加载、失败与归属具有中文表达。

## Colors

### Primary
Beta 的 beta-accent 来自用户固定参考图；深色使用 beta-accent-dark。BetaAppearance 与 app_theme.dart 将它们接入 primary，浅红/深红面板接入 primaryContainer 和 surfaceContainerLow。四个目的地的选中图标与文字、个人页图标和相关选择使用这组颜色。正式 flavor 仍由既有主题种子与预设决定，primary-seed / primary-seed-dark 属于该保留系统。

### Secondary
favorite 保留为正式渠道收藏色；Beta.8 已选心形读取亮度适配的 beta-accent / beta-accent-dark，未选读取实际局部 onSurfaceVariant。显式 IP 进度图案/角色保留自身配色，选择外框用红色，标签保持 text-primary-*。

### Neutral
canvas-* 是经典纯色背景，surface-* 对应基础表面。正文、说明、弱提示成组随亮度切换；深色半透明文字须结合实际背景判断。Beta 个人页面板使用 beta-panel-*。播放器使用 player-base、白色文字、封面模糊和深色罩层；非当前歌词降亮度。

**The Theme Ownership Rule.** Beta 红色拥有导航与选择 chrome，歌曲封面拥有氛围，显式 IP 图案与角色拥有自身配色；正式 flavor 继续读取原主题。

**The Local Contrast Rule.** 经典灰色唱机的顶部收起/更多操作使用局部深色半透明底，底部加强深色罩层，歌手为不透明白字；共享上一首/播放/下一首仍是裸白色图标。

## Typography

平台默认无衬线，中文回退 Noto Sans SC、Microsoft YaHei、sans-serif；没有新增品牌字体包。截图测试的 BetaQACJK 与显式 chip/subtitle 字体是 QA 设施，不是产品字体。最终软件截图已消除先前已知的搜索中文缺字，Android 字体仍待真机验证。

display 用于页面标题，headline 用于分区；曲目使用 title 并单行省略，普通封面标题为相近的小一档（15dp/600）且最多两行。body 承载歌手与说明，空状态行高（1.6）；action 承载按钮，label 配合导航图标。同步歌词从 Beta.6 的 30dp 收敛到当前 24dp，按真实文本与 TextScaler 测量，左对齐、当前行白色、其余降亮度，上下边缘渐隐。

**The Readable Hierarchy Rule.** 长内容换行、省略或滚动，不缩小整页文字来塞满首屏。

## Layout

Flutter 数值为逻辑像素；frontmatter 的 px 是可移植记法，文字遵循系统 TextScaler。页面左右（22dp）、书架间隔（14dp）、分区上/下（28/14dp）。页头计入安全区，正文回弹、可刷新。常规封面宽（158dp）、歌单（174dp）；歌曲行方封面（52dp），垂直内距（9dp）。

窗口分级：compact <600dp、medium 600–839dp、expanded ≥840dp；正文内容上限依次为可用宽、760dp、1080dp。Beta 手机和宽屏统一使用同一个官方底栏，不显示左轨或预留 88dp 左轨占位。音乐库可用宽 ≥650dp 时两列变四列；特色封面按可用宽计算并夹紧，保留邻项露出。正式 flavor 的既有自适应导航保持原有行为。

**The Reachable Content Rule.** 编辑式正文保留底部滚动余量；短屏播放器增加可滚动高度，文字缩放时增加空间，保留全部播放操作。搜索内容延伸到悬浮玻璃后方，清空原先整条不透明白底；搜索正文内部保留底部余量。官方底栏处理手势安全区和搜索键盘抬升，shell 仅为搜索正文避让键盘，不能重复移动底栏。设置/聊天/完整播放器/媒体预览分别控制悬浮层显示。

搜索结果用单一 CustomScrollView / SliverList 惰性构建，保留 52dp 封面、紧凑元数据、裸心、更多和真实分页。热搜每页最多 10 词，常规两列、≥650dp 三列，分榜/排名/换页仍在。更多菜单窄屏/大字可换行滚动。480 首 fixture 在手机视口仅实例化 10 个封面，是构建边界观测，不是帧率。

## Elevation & Depth


正文依靠留白、稳定表面与封面层次。特色封面以底部深色渐层承载白字，播放器使用封面模糊与深色罩层。封面局部柔影不是全局阴影；Beta.8 收藏为透明裸心形，不再以圆底/光晕作默认容器。

固定运行依赖 liquid_glass_widgets 1.15.0，官方示例来源快照保留在 third_party/liquid_glass_widgets/。Beta 底部 chrome 直接组合官方 Apple Music 示例的 GlassScaffold、GlassTabBar.searchable 与 GlassButton.custom，由库负责按压、拖动、弹簧和 accessory 形变。底栏使用 premium/full、blur 2、thickness 30、lightIntensity .2、chromaticAberration .01、saturation 1.2、fresnelStrength 0；播放胶囊单独使用 lightIntensity .18。浅/深底栏颜色分别为 #AAF2F2F7 / #AA1C1C1E，胶囊为 #CCF2F2F7 / #CC1C1C1E。

原 MestingGlass 仍用于其他表面，其 standard、blur 12、thickness 22、lightIntensity .22、chromaticAberration .005 及高对比时不透明 surface + outline 是独立实现，不能套用到官方底栏。官方 chrome 使用库自身行为，不能宣称继承原 MestingGlass 的降级或全部透明度均关闭。

**The Floating Glass Rule.** 内容封面、列表、表单与账号面板保持稳定表面，折射限定悬浮 chrome。封面模糊、播放器音质弹层和短时状态 HUD 各按自身局部背景处理。

## Shapes

小图片轻圆角，封面保留方形比例；普通封面、面板、弹窗用 cover / panel / dialog。按钮、chip、导航为胶囊；播放胶囊 32dp，编辑 sheet 只圆顶部。transport/收藏为透明目标；音质弹层 30dp、HUD 25dp。Replay 年份反馈与菜单显式 20dp 圆角并裁切；更多为锚定 22dp 圆角局部模糊弹层。经典唱臂白色几何轮廓、无黑描边，唱头接触标签外的黑色沟槽。

## Components

- **收起与更多**：PlayerPullToDismiss 仅顶部灰色 handle 接收下拉，五样式封面/歌词共用提交/回弹，减少动画即时完成；handle 可点击，封面/歌词/滑块不竞争收起。PlayerMoreMenu 锚定顶部更多，图标行按组分隔、当前样式带对勾，最大宽 280dp、窄屏两侧至少 16dp。
- **收藏与切歌**：裸心统一 48×48dp 透明目标，compact 仅改 glyph；按压缩放 .88/120ms，保留键盘激活与真实业务反馈。MestingAudioHandler 区分明确播放上下文与 FM 历史/服务器顺序，Previous → Next 回原曲，不提前消耗推荐项。经典唱片/唱臂保留播放和暂停的旋转区别。

- **按钮与表单**：PlatformStyle 填充/描边最小 48×48dp，文字按钮 44×44dp；primary/onPrimary、低阶表面或安静文字区分层级。输入 18dp 圆角，焦点 primary 1.5dp 描边，错误使用主题 error；按压/焦点/禁用交给 Flutter Material。
- **Chip / 面板**：普通 chip 选中为 primary 轻填充。PlatformPanel 为 22dp 圆角、20dp 内距的不透明 surfaceContainerLow。Beta 进度样式/角色选择用红色轻填充、边线与轻影，标签保持主题主要文字；加载、失败、空数据及适用重试如实显示。
- **导航**：四目的地和独立搜索延续，首页实心图标，选中图标/文字用 Beta 红色。底栏基础 64dp、搜索/accessory 50dp，随 TextScaler 最多加 28dp；内距 20/16dp、间距 8dp。滚动过 50dp 收拢 accessory，再点当前 tab 回顶部。MusicShell 持久持有来源 tab，传给 BetaMusicShell.navigationOwner，播放器/设置隐藏玻璃 shell 后仍恢复。BetaEdgeBack 只占左右 20dp 边缘，二级页和内嵌/独立搜索按步骤返回，保留内部书架/滑块手势。
- **播放条**：有当前媒体才显示，作为官方底栏 accessory；32dp 方封面、歌曲/歌手，仅保留播放/暂停与下一首两个裸图标。点击打开播放器、左右滑动切歌。较窄且文字放大时可省略歌手；不按宽度添加队列按钮。GlassButton.custom 基础高度 64dp，复用既有音频服务。
- **播放器**：Beta 默认沉浸封面；cover、classic、aurora、cassette、lyricStage 五种样式保留上半区各自视觉/动态身份，下半区统一使用 ApplePlayerControls。顺序为进度与时间、裸白色 Cupertino 上一首/播放暂停/下一首、真实系统媒体音量、评论/音质/当前队列；封面和歌词两种状态都保留同一组控件。顶部小封面、歌名/歌手与模糊封面背景组织歌词页，点击同步歌词跳转进度。
- **滑块语义与系统音量**：进度合并语义“播放进度”读已播/总时长，音量“系统媒体音量”读百分比，保留原生可调动作。音量轨纤细视觉与 48dp 高响应区并存，拖动本地即时更新。Dart 串行保留最新待写值，Kotlin 抑制重复事件和相同步进，前台刷新 STREAM_MUSIC，无宿主禁用。100 个相同快速样本原生写入从 100 次降至 2 次、末值 1.0；这是通道工作量证据，硬件/TalkBack/帧率仍待真机。
- **音质**：五样式共用持久化偏好与 30dp 圆角浅/深半透明弹层。PlatformQualityCatalog 依据当前歌曲正值资源 hash/显式资源档位生成选项，会员标志不制造资源；只显示已有档位，未知/失败手动重载，无自动循环。弹层随歌曲更新，选择绑定录音 ID。会员提示只在尝试选择后按平台结果出现。既有 handler 保留进度、播放状态、队列/模式，失败恢复旧流/旧偏好；偏好、实际、试听、降档与待平台确认分开表达。
- **装扮**：保留浅/深/系统、自定义图片/视频、五种播放器与显式进度配色/角色。Beta.8 移除 IP 装饰开关，替代 Beta.6/Beta.7 的保留说明；品牌选择器、重复皮肤说明/经典卡片、DRESS UP、followTheme 继续移除。coral 启动身份和旧品牌迁移、残留 followTheme 转 classic、显式 IP 保留、完整 IP 主题退役、背景强度 .58 与性能 automatic 延续。平台账号入口使用实际 coral Mesting 应用图标；正式主题行为保留。
- **状态反馈**：showMusicNotice 以顶部安全区下的单个半透明 HUD 替换前一个通知；短标题加图标，支持浅深色、淡入/顶部滑入/缩放与减少动画。普通提示省略旧说明，错误/警告仍保留可行动原因；Semantics liveRegion 读出可见信息。不建立第二套成功/失败状态。
- **封面恢复**：推荐、搜索、歌单与播放器共用平台封面规范化，接受有效 HTTP/HTTPS 与协议相对 URL、替换尺寸占位并跳过裸文件名。列表元数据回退仅只读，合并同歌曲请求、最多 3 并发、缓存最近 256 个成功封面；临时失败不永久缓存，也不影响播放或触发云写入。
- **歌单编辑**：PageView viewportFraction .72，中心方封面、邻项露出、相机/圆点指示；第一项现有/相册，另六项本地模板，空封面有加图占位。固定页头 48dp 强调对勾与安静取消；键盘上移、表单滚动。保存中禁用并显示进度，失败保留草稿，成功才关闭；结果为 640×640 不透明 PNG。
- **Replay 与 owner**：按当前账号本机每日记录聚合年/月，年份反馈/菜单 20dp 圆角裁切，选中月进入视野；封面氛围、大排名、时长和“歌曲封面”披露共存，不补算缺失月份。账号归属、收藏/播放唯一状态与既有推荐来源继续适用。

封面/歌词切换与歌词跟随读取 disableAnimations，主题背景也尊重减少动画；局部文字淡变与 sheet 键盘动画仍固定时长，不宣称全应用完全适配。

## Do's and Don'ts

### Do:
- **Do** 使用语义色并检查浅深色、红色选中 chrome 与装扮背景的最终对比。
- **Do** 让封面、歌曲、歌手与真实平台内容承担信息层级。
- **Do** 提供中文 tooltip/语义标签、selected 状态、文字缩放及可达操作。
- **Do** 让加载、空状态、失败、草稿与账号归属如实可见。

### Don't:
- **Don't** 把 Beta 条件组合推广为正式分支的全局布局或默认播放器。
- **Don't** 给内容列表、表单与账号面板扩散液态玻璃。
- **Don't** 以无意义眉题、重复圆角外框或装饰渐变替代真实内容。
- **Don't** 把 fixture、歌曲封面、未记录月份或失败写入描述为生产素材、艺人肖像、历史统计或成功。
- **Don't** 给共享播放 transport 恢复大圆面，或把两个滑块合成无名且不可调的语义节点。
- **Don't** 以软件截图宣称真机 TalkBack、硬件音量、GPU Apple 效果或线上服务已验收。

未固化为规则：局部减少动画仍不完整；收起 handle 的 112×36dp 手势区按实际尺寸披露；重复测试人像不是素材规范。旧 38dp 收藏边界由 Beta.8 的 48dp 目标替代。范围为通用 Android 兼容，没有机型专属优化，效果/动画/功能均保留；软件捕获及边界测量不替代真机验收。
