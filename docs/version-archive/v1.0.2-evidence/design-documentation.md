# Music refinements — design documentation

日期：2026-10-27。范围：同一 Mesting / Apple Music / iOS 27 视觉依据内的普通扩展。

## 角色与结论

本 pass 使用已发布的 `impeccable_documenter` 角色，已完整阅读其角色文件与 `reference/document.md`。角色以实际实现为设计事实来源；普通扩展保留既有系统，报告旧漂移，不借本轮任务重写系统。

**结论：无需增加、替换或重新生成设计 token。** 保留 [DESIGN.md](D:/AnLi/DESIGN.md) 的现有 frontmatter、当前 1.0.1 权威组件条款和用户指定的 Apple Music / iOS 27 视觉方向。此次变化应由一段当前功能/组件契约说明记录。本文不是新视觉世界、comp、concept roll、QUALITY BAR 或新的系统规范。

本 pass 只写本文；未改动 PRODUCT.md、DESIGN.md、`.impeccable/design.json` 或产品源码，未执行测试、构建、网络请求、Git 修改或设备操作。测试和独立审查由主任务分别提供证据。

## 保留的设计系统

| 系统部分 | 实现与 incumbent 一致的规则 | 本轮处理 |
| --- | --- | --- |
| 配色 | Beta 功能蓝沿用 `#0066D9` / `#0091FF`，分组面板沿用 `#F2F2F7` / `#1C1C1E`；收藏粉、完成绿和封面氛围仍各有用途。新首页读取现有主题文字与表面。 | 不新增颜色或把局部输出图标蓝提升为全局 token。 |
| 字体 | 平台无衬线与 Noto Sans SC / Microsoft YaHei 回退继续有效，没有新字体包。生产页头 34dp/800、分区 23dp/800、封面标题 15dp/600、歌曲标题 16dp/600、歌手说明 13dp 延续。 | 不改变字阶；Windows QA 字体只是捕获设施。 |
| 布局 | 编辑正文继续使用 22dp 横向留白、14dp 书架间隔，已有 TextScaler 参与书架高度。方形封面、邻项露出和真实可操作分区入口继续组织音乐内容。 | 新增书架复用现有组件；局部书架宽度与场景按钮间距不升级为全局间距规范。 |
| 形状 | 普通封面 12dp、特色封面 22dp；页面沿用现有面板与胶囊。输出卡片沿用原 32dp 圆角，更新抽屉沿用 1.0.1 的 34dp。 | 不新增圆角体系。 |
| 玻璃 | `BetaGlassMenuSurface` 继续使用共享 `betaMusicPillGlass`、premium、独立层。正文/封面保持稳定表面，玻璃用于已有悬浮 chrome 和指定操作。 | 设备列表在同一玻璃卡片中展开；不增加第二个面板，也不把内容书架做成玻璃。 |

依据：[DESIGN.md 的 token 与 1.0.1 条款](D:/AnLi/DESIGN.md:4)、[BetaAppearance](D:/AnLi/lib/features/themes/beta_appearance.dart:6)、[主题接入](D:/AnLi/lib/features/themes/app_theme.dart:20)、[编辑组件](D:/AnLi/lib/features/experience/presentation/editorial_widgets.dart:54)、[共享玻璃表面](D:/AnLi/lib/shared/widgets/beta_glass_popover.dart:12)。

继续适用的命名规则是 **Theme Ownership**、**Readable Hierarchy**、**Reachable Content** 和 **Floating Glass**。这些变化没有理由改写其边界，也不支持以默认 Material 外观替代用户已固定的视觉依据。

## 本轮组件契约

### 版本标签和值相邻

[更新抽屉的 `_detail`](D:/AnLi/lib/features/app_update/presentation/beta_app_update_sheet.dart:319) 从把值推到末端的 Row 改为同一个 Wrap：标签后跟值，横向间距 12dp，换行间距 4dp；两者仍为 15dp，值保留 600 字重。只有实际宽度或系统大字需要时才换行。它是本组件的标签/值邻接规则，不应扩展为所有设置行的通用排版。

浅深色窄屏大字图均可见“当前版本 1.0.1”紧邻。1.0.1 原有的更新状态 owner、细进度、主操作和玻璃材质未在本次布局修改中替换。

### “我的”的外观入口去重

[PlatformProfile](D:/AnLi/lib/features/music_platform/presentation/platform_profile.dart:107) 在 Beta 显示“应用”分组并保留“设置”，不再重复放置“装扮”。非 Beta 原有“应用与外观”和“装扮”分支保留。[设置中的装扮入口](D:/AnLi/lib/features/settings/presentation/settings_page.dart:62) 仍存在并打开现有装扮中心。

捕获支持 Beta 我的页的入口去重与原有面板层级；文件名含 `profile-*-settings` 的两张图是我的页底部“设置”入口，并非实际设置页截图。设置入口留存由源码核对支持。

### 共享耳塞轮廓与本机手机图形

[AppleAudioGlyph](D:/AnLi/lib/features/experience/presentation/apple_audio_glyphs.dart:13) 的耳塞轮廓改编自本地保留的 Tabler MIT `device-airpods.svg`，来源和许可见 [NOTICE](D:/AnLi/third_party/audio_glyphs/NOTICE.md)。几何为 24 单位坐标、1.65 单位描边、圆端点与圆连接；同一个绘制函数由工具栏和设备卡片复用。

24 是绘图坐标基准，并非每个位置固定 24dp：工具栏及折叠当前设备使用 40dp，设备列表使用 29dp。`phone` 轮廓及原生 `local` 元数据表达“本机”；通用耳机图标不改变设备真实名称，图中 `vivo TWS 5` 仍按该名称显示。未新增 Apple SF 字体包，也没有把 Apple 产品品牌当成通用设备事实。

依据：[工具栏复用](D:/AnLi/lib/features/experience/presentation/player_toolbar_glyphs.dart:90)、[当前设备图形](D:/AnLi/lib/features/experience/presentation/player_output_dialog.dart:143)、[列表图形](D:/AnLi/lib/features/experience/presentation/player_output_routes.dart:88)。

### 同一输出卡片与真实/待生效状态

[PlayerOutputDialog](D:/AnLi/lib/features/experience/presentation/player_output_dialog.dart:60) 保持同一个 `BetaGlassMenuSurface`、当前曲目信息、媒体音量与底部主操作。“切换设备”在 Beta 内部展开“播放设备”，底部变为“完成”；正文可滚动，底部动作独立保留。当前 Beta 不再显示旧的次级“系统设备管理”按钮；稳定渠道保留自己的既有系统选择调用。

[PlayerOutputRoutes](D:/AnLi/lib/features/experience/presentation/player_output_routes.dart:40) 直接请求原有输出控制器。视觉必须继续区分：

- 本次请求尚未结束：显示 spinner 和“正在切换…”，阻止重复请求。
- 原生返回 `selected`：显示对勾、selected 语义和“当前播放设备”。
- 控制器返回 `pendingId`：显示“已选择，播放时生效”，不把待生效偏好画成当前选中。
- 请求未确认或抛错：保留可行动错误；加载失败/空列表不得被描述为可用设备或切换成功。

[AudioOutputController](D:/AnLi/lib/core/audio/audio_output_controller.dart:107) 对请求后的 current 回读区分真实 `id` 与 `pendingId`；原生接受暂停期间的偏好不等于已经产生硬件音频输出。本 pass 没有以软件截图证明蓝牙转移、音频硬件、配对或系统权限。

### 音乐首页扩展与真实目录入口

[MusicLandingPage](D:/AnLi/lib/features/experience/presentation/music_landing_page.dart:28) 保留现有精选、喜欢、最近播放、私人 FM 与 Replay，并增加账号适用的“猜你喜欢”和“新歌首发”，再用既有 EditorialSection / EditorialShelf / EditorialCover 组织榜单、新碟、主题和场景内容。封面仍承担主要视觉信息；场景是读取同一低阶主题表面的可操作按钮。

[MusicHomeCatalogueShelf / Page](D:/AnLi/lib/features/experience/presentation/music_home_catalogues.dart:53) 复用酷狗音乐目录提供者，按类型持有读取/空/失败状态；筛除指定的非音乐栏目名称。书架标题打开完整目录，卡片/场景打开现有真实集合详情；新歌入口打开现有推荐详情。完整目录保留账号代次校验、去重、支持类型的分页及失败重试。这里确认的是实际导航与状态代码，不能由 fixture 推导线上目录覆盖率或服务可用性。

## 已查看的捕获

以下 20 张 PNG 均已逐张直接查看。它们由实际 Flutter 生产控件生成，使用 Windows 主机软件渲染、QA 中文字体、合成账号/音乐/设备数据和示例封面；不是批准 comp，也不代表原生设备验收。

| 捕获 | 支持的观察 |
| --- | --- |
| `refinement-home-light-top.png`、`refinement-home-dark-top.png` | 首页首屏、特色封面、最近播放与原有底部玻璃层级。 |
| `refinement-home-light-ranks.png`、`refinement-home-dark-ranks.png` | 榜单、歌单与 FM 的现有字阶和书架构成。 |
| `refinement-home-light-scenes.png`、`refinement-home-dark-scenes.png` | 主题、场景按钮和 Replay；浅深色主题表面继续一致。 |
| `refinement-output-light.png`、`refinement-output-dark.png` | 折叠输出卡片、设备真实名称、共享耳塞轮廓与媒体音量。 |
| `refinement-output-light-routes.png`、`refinement-output-dark-routes.png` | 同一输出卡片内展开列表、本机手机图形及完成操作。 |
| `refinement-output-narrow-large.png` | 窄屏大字下设备信息、音量及完成操作仍可见。 |
| `refinement-player-headphones.png` | 完整播放器使用同一耳塞轮廓及真实设备名称。 |
| `refinement-current-version-light-narrow-large.png`、`refinement-current-version-dark-narrow-large.png` | 大字下当前版本值紧随标签，沿用更新抽屉层级。 |
| `refinement-catalogue-narrow-large.png`、`refinement-albums-narrow-large.png` | 完整目录与新碟书架在窄屏大字下继续使用既有内容语言。 |
| `refinement-profile-light.png`、`refinement-profile-dark.png` | 原有账号/音乐分组与底栏。 |
| `refinement-profile-light-settings.png`、`refinement-profile-dark-settings.png` | Beta 我的页底部只留设置入口，未重复展示装扮。 |

捕获目录：[captures](D:/AnLi/.codex-artifacts/2026-10-27-music-refinements/captures)。源码对照还抽样比较了本轮 sibling `baseline/` 中的更新明细行、我的页、输出卡片与 glyph；可见变化是局部布局、入口与几何调整，不是配色/字体/光学系统更换。

## 主任务需要限定的旧说明

1. [DESIGN.md:325](D:/AnLi/DESIGN.md:325) 的“本机使用广播轮廓”“全部为应用原创矢量”需要由当前说明覆盖：本机改为手机，耳塞轮廓为 Tabler MIT 改编；仍然不捆绑 SF 字体、不推断 AirPods 品牌。该条原有音量尺寸规则继续适用。
2. [PRODUCT.md:159](D:/AnLi/PRODUCT.md:159) 与 [DESIGN.md:352](D:/AnLi/DESIGN.md:352) 的公开可转移项/系统设备管理叙述需要由当前 Beta 契约限定：现在走应用播放器的直接路由请求，旧次级入口不再呈现；必须分别记录当前已确认路由和暂停时待生效偏好。不能把方法返回 true 一概写成硬件已切换。
3. 当前说明应记录版本 Wrap、我的入口去重与音乐首页真实目录导航，并附主任务最终测试/构建/独立审查的精确证据；本文不预先宣称这些检查已通过。
4. 首次查看的 `refinement-output-light.png` 与 `refinement-current-version-light-narrow-large.png` 中，预期 artwork 区域尚未显示图像，配对深色图和展开图可见图像；源码没有删除相应 artwork。该捕获完整性差异已交主任务复核，不能将图像缺席固化为浅色规范，也不能在未核实前定性为产品缺陷。

`.impeccable/design.json` 仍有本轮之前的身份、伙伴与成功反馈叙述漂移，root 文档也保留已被权威条款覆盖的历史段落。本轮未修复或重新生成这些内容；只应补充当前范围的覆盖关系。软件渲染中的平面玻璃外观、示例人物封面、QA 字形与上面的 artwork 捕获差异均未固化为产品设计规则。
