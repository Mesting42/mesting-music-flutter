---
name: Mesting Android Beta.7
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
---

# Design System: Mesting Android Beta.7

## Overview

**Creative North Star: "封面主导的私人听歌空间"**

封面承担视觉重心，中文大标题与留白组织阅读顺序。横向内容组露出下一项，歌曲列表保持紧凑；播放与导航悬浮于内容之上。Beta 使用用户参考图采样的红色强调，经典浅色、深色和跟随系统共用布局，进度条样式与角色独立选择。

本文合并记录已经实现的 Android Beta.7，并替代先前 Beta.6 中关于主题强调色、圆面 transport、迷你队列按钮和 followTheme 选项的描述。Beta 门限为 DistributionChannel.isBeta（Android appFlavor == beta）；正式 flavor 保留既有页面、导航、迷你播放器、完整主题、定制推荐与默认黑胶。共享主题工具、反馈组件和 PlatformStyle 不构成全局发布开关。

依据为当前主题、导航、播放器、装扮源码，以及 2026-10-25 的 Beta.7 finish verdict、screenshots-verdict 和已闭合的 R1–R3 证据。最终处置为 **SHIP WITH STATED VALIDATION LIMITS**。截图使用合成本地数据和 Windows 中文 QA 字体；先前搜索 chip 字形缺失已经在最终捕获中修复。Widget 截图不能证明 Android TalkBack、硬件音量、GPU 折射/动态、真实 IME、升级迁移、CDN 或云端链路已验证，也不承诺与原生 Apple GPU 效果逐像素一致。

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
favorite 专用于收藏心形与状态反馈。显式蜡笔小新、Hello Kitty、库洛米进度图案与角色保留自身颜色，外层 Beta 选择框、边线和轻影使用红色；标签使用 text-primary-*，不能把浅红底上的细小选中标签也染红。

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

## Elevation & Depth

正文依靠留白、稳定表面与封面层次。特色封面以底部深色渐层承载白字；播放器使用实际封面模糊与深色罩层。封面局部柔影、收藏轻红光晕不是全局卡片阴影。

固定运行依赖 liquid_glass_widgets 1.15.0，官方示例来源快照保留在 third_party/liquid_glass_widgets/。Beta 底部 chrome 直接组合官方 Apple Music 示例的 GlassScaffold、GlassTabBar.searchable 与 GlassButton.custom，由库负责按压、拖动、弹簧和 accessory 形变。底栏使用 premium/full、blur 2、thickness 30、lightIntensity .2、chromaticAberration .01、saturation 1.2、fresnelStrength 0；播放胶囊单独使用 lightIntensity .18。浅/深底栏颜色分别为 #AAF2F2F7 / #AA1C1C1E，胶囊为 #CCF2F2F7 / #CC1C1C1E。

原 MestingGlass 仍用于其他表面，其 standard、blur 12、thickness 22、lightIntensity .22、chromaticAberration .005 及高对比时不透明 surface + outline 是独立实现，不能套用到官方底栏。官方 chrome 使用库自身行为，不能宣称继承原 MestingGlass 的降级或全部透明度均关闭。

**The Floating Glass Rule.** 内容封面、列表、表单与账号面板保持稳定表面，折射限定悬浮 chrome。封面模糊、播放器音质弹层和短时状态 HUD 各按自身局部背景处理。

## Shapes

小图片轻圆角，封面保留方形比例；普通封面、面板、弹窗使用 cover / panel / dialog。按钮、chip、导航为胶囊。官方播放胶囊使用 32dp 圆角矩形，编辑 sheet 只圆化顶部；封面选择以强调色边框表达。共享 transport 是可触达的透明按钮，不能恢复大圆形底；播放器音质弹层为 30dp 圆角，顶部状态 HUD 为 25dp 圆角。

## Components

- **按钮与表单**：PlatformStyle 填充/描边最小 48×48dp，文字按钮 44×44dp；primary/onPrimary、低阶表面或安静文字区分层级。输入 18dp 圆角，焦点 primary 1.5dp 描边，错误使用主题 error；按压/焦点/禁用交给 Flutter Material。
- **Chip / 面板**：普通 chip 选中为 primary 轻填充。PlatformPanel 为 22dp 圆角、20dp 内距的不透明 surfaceContainerLow。Beta 进度样式/角色选择用红色轻填充、边线与轻影，标签保持主题主要文字；加载、失败、空数据及适用重试如实显示。
- **导航**：手机和宽屏同用首页/发现/音乐库/我的四目的地及独立搜索，选中图标与文字使用 Beta 红色。官方底栏基础 64dp、搜索和 accessory 基础 50dp，随 TextScaler 最多增加 28dp；水平/垂直内距为 20/16dp，间距 8dp。正文滚动超过 50dp 时收拢并将 accessory 置于 inline；再次点击当前 tab 回到顶部。搜索展开/取消、清空与键盘行为交给官方组件，外层透明 Material 提供正常文字默认值。
- **播放条**：有当前媒体才显示，作为官方底栏 accessory；32dp 方封面、歌曲/歌手，仅保留播放/暂停与下一首两个裸图标。点击打开播放器、左右滑动切歌。较窄且文字放大时可省略歌手；不按宽度添加队列按钮。GlassButton.custom 基础高度 64dp，复用既有音频服务。
- **播放器**：Beta 默认沉浸封面；cover、classic、aurora、cassette、lyricStage 五种样式保留上半区各自视觉/动态身份，下半区统一使用 ApplePlayerControls。顺序为进度与时间、裸白色 Cupertino 上一首/播放暂停/下一首、真实系统媒体音量、评论/音质/当前队列；封面和歌词两种状态都保留同一组控件。顶部小封面、歌名/歌手与模糊封面背景组织歌词页，点击同步歌词跳转进度。
- **滑块语义与系统音量**：进度的合并语义名为“播放进度”，值为已播/总时长；音量名为“系统媒体音量”，值为百分比。MergeSemantics 保留原生 Slider 可调节动作。Android MediaVolumeBridge 操作 STREAM_MUSIC，并通过事件与前台刷新同步；无宿主平台显示禁用音量轨，不伪造另一播放器增益。五样式语义、通道读/写/事件与缺失宿主均有本地测试，TalkBack 与硬件键仍待真机验收。
- **音质**：五种样式共用标准/高品质/无损/Hi-Res 持久化偏好，播放器内为深色半透明圆角弹层；切换由既有音频 handler 刷新当前源，保留进度、播放/暂停、队列和模式，过时操作不能覆盖新操作。偏好与平台实际返回音质分开表达，未知返回显示“音质/待平台确认”，试听与降档如实披露。
- **装扮**：Beta 仅保留浅色/深色/跟随系统、自定义图片/视频、播放器样式、独立进度样式/角色和 IP 装饰开关。品牌选择器、重复“皮肤”标题/说明/经典卡片、DRESS UP 眉题与 followTheme 选项已移除；启动图标/启动页固定 coral 并迁移旧选择。Beta.7 将残留 followTheme 别名迁移为 classic；Beta.6 已转换成显式 IP 的选择继续保留。完整 IP 主题迁移 classic、背景强度 .58 和性能 automatic 的既有规则继续适用。正式 flavor 的主题行为保持原样。
- **状态反馈**：showMusicNotice 以顶部安全区下的单个半透明 HUD 替换前一个通知；短标题加图标，支持浅深色、淡入/顶部滑入/缩放与减少动画。普通提示省略旧说明，错误/警告仍保留可行动原因；Semantics liveRegion 读出可见信息。不建立第二套成功/失败状态。
- **封面恢复**：推荐、搜索、歌单与播放器共用平台封面规范化，接受有效 HTTP/HTTPS 与协议相对 URL、替换尺寸占位并跳过裸文件名。列表元数据回退仅只读，合并同歌曲请求、最多 3 并发、缓存最近 256 个成功封面；临时失败不永久缓存，也不影响播放或触发云写入。
- **歌单编辑**：PageView viewportFraction .72，中心方封面、邻项露出、相机/圆点指示；第一项现有/相册，另六项本地模板，空封面有加图占位。固定页头 48dp 强调对勾与安静取消；键盘上移、表单滚动。保存中禁用并显示进度，失败保留草稿，成功才关闭；结果为 640×640 不透明 PNG。
- **Replay 与 owner**：当前账号本机每日记录按年/月聚合；年份菜单、全年/月 chip，选中月进入视野。封面氛围、大排名、时长及“歌曲封面”披露共存，不补算未记录月份。首页、发现、音乐库保持各自组合；云端/本地标签与社交能力反映真实归属，不新建第二套收藏或播放状态。推荐来源与续播规则见 PRODUCT.md 及对应 surface brief。

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

未固化为规则：紧凑收藏控件当前 38dp，低于产品 44dp 目标；局部减少动画仍不完整；重复测试人像不是素材规范。它们是实现边界，不是新页面模板。
