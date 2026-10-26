---
name: Mesting Android Beta.5
description: 封面主导、主题自适应的中文私人听歌空间
colors:
  primary-seed: "#465CC7"
  primary-seed-dark: "#91A5FF"
  primary-classic-light: "#505B92"
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
  player-base: "#1A1B20"
  player-control: "#34383F"
  lyric-inactive: "rgba(255,255,255,0.65098)"
typography:
  display: {fontFamily: "sans-serif, Noto Sans SC, Microsoft YaHei", fontSize: "34px", fontWeight: 800, lineHeight: 1.2, letterSpacing: "-0.9px"}
  headline: {fontSize: "23px", fontWeight: 800, letterSpacing: "-0.4px"}
  title: {fontSize: "16px", fontWeight: 600}
  body: {fontSize: "13px", fontWeight: 400}
  action: {fontSize: "14px", fontWeight: 800}
  label: {fontSize: "10px", fontWeight: 600}
  lyrics: {fontSize: "30px", fontWeight: 800, lineHeight: 1.45, letterSpacing: "-0.5px"}
rounded:
  artwork-small: "9px"
  cover: "12px"
  content: "18px"
  panel: "22px"
  dialog: "28px"
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
  navigation: {rounded: "{rounded.capsule}", height: "62px"}
  playback-pill: {rounded: "{rounded.floating}", height: "64px"}
---

# Design System: Mesting Android Beta.5

## Overview

**Creative North Star: "封面主导的私人听歌空间"**

封面承担视觉重心，中文大标题与留白组织阅读顺序。横向内容组露出下一项，歌曲列表保持紧凑；播放与导航悬浮于内容之上。既有装扮、浅深色和跟随系统继续共用新布局。

本文记录已经实现的 Android Beta.5。Beta 门限为 DistributionChannel.isBeta（Android appFlavor == beta）：推荐/发现入口、音乐库入口、导航、迷你播放条、平台账号个人页与播放器默认值分别按条件接入。正式分支保留既有页面、导航、迷你播放器与默认黑胶；共享主题和 PlatformStyle 不是全局发布开关。

依据为项目主题、编辑式组件、导航、播放器、编辑器与 Replay 源码，以及 2026-10-25 beta5-review-round2 截图。beta5-finish-verdict2.md 的 disposition 为 ship：六项修复及 Replay 首屏页脚重叠均解决。截图中的账号、记录与重复人像是合成测试 fixture，不代表生产曲库素材，也不证明实体 Android 或云端链路已验证。

**Key Characteristics:**

- 封面主导，正文使用清楚稳定的主题表面。
- 大标题、粗体分区、紧凑曲目元数据形成层级。
- 当前主题强调色表达选择与确认，收藏使用独立功能色。
- 玻璃服务悬浮 chrome，加载、失败与归属具有中文表达。

## Colors

### Primary
经典浅/深色主题分别使用 primary-seed / primary-seed-dark 生成 ColorScheme；装扮可替换种子。导航、滑块、焦点与确认读取当前 colorScheme.primary。primary-classic-light 是已复核的经典浅色生成结果，仅用于静态预览，不能固定全部主题。

### Secondary
favorite 专用于收藏心形与状态反馈，不承担 Beta 导航或保存按钮。

### Neutral
canvas-* 是经典纯色背景，surface-* 对应表单/弹层 surface。正文、说明、弱提示成组随亮度切换；深色半透明文字须结合实际背景判断。平台面板与表单使用不透明 surfaceContainerLow。播放器采用固定 player-base / player-control 与白色文字，非当前歌词降亮度，避免继承浅色表单填充。

**The Theme Ownership Rule.** 交互强调色来自当前主题，氛围来自当前歌曲封面，收藏使用独立功能色。

## Typography

平台默认无衬线，中文回退 Noto Sans SC、Microsoft YaHei、sans-serif；没有新增品牌字体包。截图测试字体 BetaQACJK 不是产品字体。用户确认的参考方向允许中文系统大标题。

display 用于页面标题，headline 用于分区；曲目使用 title 并单行省略，普通封面标题为相近的小一档（15dp/600）且最多两行。body 承载歌手与说明，空状态行高（1.6）；action 承载按钮，label 配合导航图标。lyrics 按真实文本与 TextScaler 测量高度，当前行白色，其余行降亮度。

**The Readable Hierarchy Rule.** 长内容换行、省略或滚动，不缩小整页文字来塞满首屏。

## Layout

Flutter 数值为逻辑像素；frontmatter 的 px 是可移植记法，文字遵循系统 TextScaler。页面左右（22dp）、书架间隔（14dp）、分区上/下（28/14dp）。页头计入安全区，正文回弹、可刷新。常规封面宽（158dp）、歌单（174dp）；歌曲行方封面（52dp），垂直内距（9dp）。

窗口分级：compact <600dp、medium 600–839dp、expanded ≥840dp；内容上限依次为可用宽、760dp、1080dp。expanded 用 88dp 左轨；音乐库可用宽 ≥650dp 时两列变四列；宽播放条最大 720dp。特色封面按可用宽计算并夹紧，保留邻项露出。

**The Reachable Content Rule.** 编辑式正文保留 210dp 底部滚动余量；短屏播放器增加可滚动高度，文字缩放时增加空间，保留全部播放操作。导航包含手势安全区，搜索/设置/聊天/完整播放器/媒体预览分别控制悬浮层显示。

## Elevation & Depth

正文依靠留白、稳定表面与封面层次。特色封面以底部深色渐层承载白字；播放器使用实际封面模糊与深色罩层。封面局部柔影、收藏轻红光晕不是全局卡片阴影。

固定依赖 liquid_glass_widgets 1.15.0。MestingGlass 使用 standard、blur 12、thickness 22、lightIntensity .22、chromaticAberration .005；导航同样克制。高对比时前者改用不透明 surface + outline，底部导航采用包的 minimal；两条降级路径不同，不能宣称全部透明度均关闭。

**The Floating Glass Rule.** 内容封面、列表、表单与账号面板保持稳定表面，折射限定悬浮 chrome。封面模糊属于音乐背景。

## Shapes

小图片轻圆角，封面保留方形比例；普通封面、面板、弹窗使用 cover / panel / dialog。按钮、chip、导航为胶囊；搜索与主要播放为独立圆形。播放条是圆角超椭圆，编辑 sheet 只圆化顶部；封面选择以强调色边框表达。

## Components

- **按钮与表单**：PlatformStyle 填充/描边最小 48×48dp，文字按钮 44×44dp；primary/onPrimary、低阶表面或安静文字区分层级。输入 18dp 圆角，焦点 primary 1.5dp 描边，错误使用主题 error；按压/焦点/禁用交给 Flutter Material。
- **Chip / 面板**：chip 无描边，选中为 primary 轻填充。PlatformPanel 为 22dp 圆角、20dp 内距的不透明 surfaceContainerLow；加载、失败、空数据及适用重试如实显示。
- **导航**：手机四目的地首页/发现/音乐库/我的，home/grid/library/person 图标族，另有 58dp 圆搜索。宽轨保留相同图标、强调色及 52dp 独立搜索，选中项有语义状态。
- **播放条**：有当前媒体才显示；44dp 方封面、歌曲/歌手、播放/暂停、下一首、队列；正文点击打开播放器，左右滑动切歌。基础高度 64dp 随文字缩放增长，复用既有服务。
- **播放器**：Beta 缺省沉浸封面，可选黑胶、流光唱片、星环脉冲、液态频谱，使用独立偏好键。方封面/大字同步歌词共用模糊背景；主要播放为白色 74dp 圆面，其余 transport 深色圆面与白图标，收藏拥有自己的主题圆面。歌词可点击同步位置，加载/失败/无歌词如实显示。
- **歌单编辑**：PageView viewportFraction .72，中心方封面、邻项露出、相机/圆点指示；第一项现有/相册，另六项本地模板，空封面有加图占位。固定页头 48dp 强调对勾与安静取消；键盘上移、表单滚动。保存中禁用并显示进度，失败保留草稿，成功才关闭；结果为 640×640 不透明 PNG。
- **Replay 与 owner**：当前账号本机每日记录按年/月聚合；年份菜单、全年/月 chip，选中月进入视野。封面氛围、大排名、时长及“歌曲封面”披露共存，不补算未记录月份。首页精选/最近、发现新歌/分组、音乐库收藏/歌单/最近/Replay 保持各自组合；云端/本地标签与社交能力反映真实归属，不新建第二套收藏或播放状态。

封面/歌词切换与歌词跟随读取 disableAnimations，主题背景也尊重减少动画；局部文字淡变与 sheet 键盘动画仍固定时长，不宣称全应用完全适配。

## Do's and Don'ts

### Do:
- **Do** 使用主题语义色并检查浅深色与装扮背景的最终对比。
- **Do** 让封面、歌曲、歌手与有意义的推荐理由承担信息层级。
- **Do** 提供中文 tooltip/语义标签、selected 状态、文字缩放及可达操作。
- **Do** 让加载、空状态、失败、草稿与账号归属如实可见。

### Don't:
- **Don't** 把 Beta 条件组合推广为正式分支的全局布局或默认播放器。
- **Don't** 给内容列表、表单与账号面板扩散液态玻璃。
- **Don't** 以无意义眉题、重复圆角外框或装饰渐变替代真实内容。
- **Don't** 把 fixture、歌曲封面、未记录月份或失败写入描述为生产素材、艺人肖像、历史统计或成功。
- **Don't** 让浅色表单填充覆盖沉浸播放器的固定控件对比。

未固化为规则：紧凑收藏控件当前 38dp，低于产品 44dp 目标；局部减少动画仍不完整；重复测试人像不是素材规范。它们是实现边界，不是新页面模板。
