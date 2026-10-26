# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

中文音乐用户，在通勤、工作学习、放松和入睡等片段时间里寻找合适的音乐。

## Product Purpose

Mesting 是一款 Flutter 音乐应用，帮助用户快速发现、播放和管理适合当下状态的音乐。成功标准是用户首次打开后能迅速理解当前推荐，并在较少操作内开始播放。

## Positioning

以“当下状态驱动的音乐推荐”和可切换的主题体验组织听歌入口，而不是只展示一个庞大的曲库。

## Operating Context

主要使用场景是移动端单手操作、碎片化使用和持续播放；推荐页是首次进入时最重要的体验入口。

## Capabilities and Constraints

- 现有项目使用 Flutter，推荐页包含每日推荐、情绪入口、曲目列表、播放控制和底部导航。
- Beta.5 已确认整体改版：保留播放能力及账号边界，新增音乐库路由、年/月回顾和歌单封面编辑。
- Beta.6 修复推荐、搜索、歌单与播放器的部分封面缺失；五种播放器样式共用标准/高品质/无损/Hi-Res 偏好，切换保留播放状态与队列，实际资源以平台返回为准。
- 现有主题系统包含品牌色、浅色/深色模式和多个主题预设，后续设计需要通过语义 token 承载。
- 不把 Material 3 默认色阶、默认按钮外观或默认卡片外观作为最终品牌表达。

## Brand Commitments

- 产品名称：Mesting。
- 界面语言：简体中文。
- 需要降低常见 AI 生成界面的模板感，避免紫粉渐变、泛滥玻璃拟态、重复大圆角卡片和无意义装饰。
- Beta.5 以用户提供的六张 Apple Music 参考图为视觉依据：封面主导、大标题、横向内容分组和悬浮控件；界面仍使用中文 Mesting 品牌。
- 首页、发现、音乐库、我的组成四个主要目的地，搜索独立。玻璃仅用于悬浮导航和播放控件，内容区域保持清楚稳定。
- Beta.6 底部直接使用 liquid_glass_widgets 官方 Apple Music 示例的组件、布局与交互动态，保留中文 Mesting 功能；手机与宽屏共用底栏，正文保持自适应约束宽度。
- 默认封面播放器可切换大字歌词；黑胶和既有播放器样式保留为可选项。Beta.6 保留经典浅/深/跟随系统与独立进度条样式/角色，移除三种角色完整主题；旧 followTheme 进度条迁移保留原外观。背景强度与动态性能分别固定 .58 / automatic，保留 IP 角色装饰开关；正式 flavor 保留既有主题行为。
- 酷狗、Mesting、游客各自拥有收藏和历史；Mesting 社交入口不会显示给酷狗账号。云端写入失败不伪装成本地成功。

## Evidence on Hand

- 推荐页实现：`lib/features/recommendation/presentation/recommendation_page.dart`
- 主题实现：`lib/features/themes/app_theme.dart`
- 现有主题 token 与调色板：`lib/features/themes/`

## Product Principles

- 先让用户播放，再让用户探索。
- 推荐理由应比装饰更突出。
- 音乐封面是主要视觉资产，界面 chrome 保持克制。
- 颜色、图标、间距和交互状态必须来自可复用语义规则。
- 首次使用者无需学习 Material 组件习惯即可理解页面。

## Accessibility & Inclusion

- 触控目标遵循移动端至少 44dp 的可用范围。
- 浅色和深色模式都保持正文、次级文字、分隔线和焦点状态的可读对比度。
- 图标不能成为唯一信息来源，重要操作需要清晰文字或语义标签。
