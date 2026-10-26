# Mesting Music 修复记录 · 2026-10-26

本次修改落在当前本地源码中，主要针对截图中的 Beta 界面。修改前的文件副本及 SHA-256 清单保存在 `.codex-backups/2026-10-26-navigation-progress-menus/`。

- 系统返回：搜索结果 → 搜索落地页 → 进入搜索前的页面。真实推入的详情页先返回实际来源；直接恢复且没有历史栈的二级页获得逻辑父页面。每日推荐、设置、装扮、播放器等页面纳入回归。
- 小新：保留原有完整身体、步行动画与天气效果，根据每一帧图片的透明底部留白修正落脚点，以进度线顶部为地面。暂停时保留静止姿态，播放时沿原有动画行走。
- Hello Kitty、库洛米：尺寸从 28dp 调整为 24dp，约缩小 14.3%；角色中心对齐进度线中心，并继续随歌曲进度移动。
- 输入菜单：从完整输入框边界计算间距，底部与输入框保持 8dp 空隙；仍保留选区、数字限制、长度限制与原有输入格式化流程。
- 两种菜单：共用模糊和动画实现，模糊参数从 2 调整到 3；展开 360ms、收回 220ms，从触发位置展开并柔和回弹，关闭时收拢。支持减少动画设置，快速反向关闭不会跳变，业务动作在菜单关闭结束后执行。
- 恢复闪红：Beta 的日间、夜间原生预览及强制明暗启动颜色此前全部覆盖为珊瑚红；现改为白色 / `#11141B` 中性底色，并为 Flutter 恢复期间的原生窗口补充对应背景。真正冷启动的品牌影片仍由现有 Flutter 启动流程管理。

关键实现按职责分开：

| 位置 | 职责 |
| --- | --- |
| `lib/app/system_back_coordinator.dart` | 记录 Navigator 返回能力，并在共享音频引擎恢复前台时重新同步 Android 返回回调 |
| `lib/features/player/presentation/music_navigation.dart` | 没有真实历史栈时的逻辑父页面规则 |
| `lib/features/experience/presentation/beta_search_back_history.dart` | 搜索层级与恢复详情页的真实本地返回历史 |
| `lib/features/auth/presentation/beta_entry_coordinator.dart` | 等路由挂载后再领取登录导航返回优先级，修复首次挂载的断言错误 |
| `lib/features/player/presentation/ip_progress_decoration.dart` | 两类角色统一的尺寸、水平位置和垂直锚点计算 |
| `lib/shared/widgets/beta_glass_popover.dart` | 两类菜单共用的玻璃表面、展开/收回动效与安全区布局 |
| `lib/shared/widgets/beta_text_editing.dart` | 从输入框边界定位编辑菜单，并通过原生编辑接口提交修改 |
| `android/app/src/beta/res/values*/` | 原生预览与运行窗口的明暗底色 |

验证使用独立 Flutter 3.41.9 / Dart 3.11.5，SDK 位于 `D:/CodexCache/flutter-3.41.9/`。依赖锁文件与修改前一致。

- Beta 回归：90 项通过，覆盖导航、登录入口、冷启动媒体、进度条、菜单和 Android 资源配置。
- 稳定版共用代码回归。该组测试使用 `--flavor stable`；它们检查的稳定版布局不适合使用 Beta 配置运行。：6 项通过，覆盖每日推荐与底部导航
- 带实际字体的渲染检查：7 项通过，导出 15 张截图；已检查小新落脚位置、头部对齐、明暗菜单及输入框外侧间距。
- `flutter analyze --no-pub`：无问题。
- 与项目 AGP 8.11.1 对应的 AAPT2（2.19-12782657）：Beta Android 资源编译通过；XML 解析及明暗底色检查通过。

自动验证中的修改前失败证据包括：恢复窗口后 Android 未收到接管返回通知；无历史栈的二级页返回能力为 false；输入菜单与输入框实际间距为 0；头部仍为 28dp；动画中途切换方向时发生位置跳变。相应回归现已通过。

日志和截图位于 `.codex-artifacts/2026-10-26-ui-fixes/`：

- `beta-regression.log`、`stable-regression.log`、`rendered-ui.log`、`analyze.log`。
- `screenshots/beta13-companion-*-129.png` 为三种角色的进度中点效果。
- `screenshots/beta13-capsule-menu-*.png` 和 `screenshots/beta13-edit-menu-*.png` 为菜单效果。
- `beta-resources.zip` 为 AAPT2 编译的验证产物。

动效参考 [Apple 的 Liquid Glass 官方说明](https://developer.apple.com/videos/play/wwdc2025/219/) 中从触发控件展开、柔和形变以及让动作与材质同步的原则。

修复验证阶段未连接 Android 真机或模拟器。桌面图标与最近任务两种入口都纳入了恢复问题分析，但 Flutter 生命周期模拟和原生资源编译无法代替真实 Android 窗口切换。偶发闪红是否在该机型完全消失，仍需安装后验证。

真机验收时，建议保持音乐播放，分别通过桌面图标和最近任务切回各重复 10 次，检查页面、队列及进度保持且不露红底；再用屏幕左右两侧的系统返回手势验证搜索三级层级和其他详情页，最后检查两个菜单在键盘展开、大字体及快速开合时的效果。

## Beta.14 安装包交付

已根据用户要求生成 Release 安装包 `release/Mesting-Music-v1.0.37-beta.14.apk`。应用名称保持 **Mesting Music**，包名保持 `com.mesting.music.beta`，版本号为 `1.0.37-beta.14`，versionCode 为 14；支持 ARM64 和 ARMv7，最低 Android 7.0（API 24）。

- APK 大小：90,213,540 字节（86.03 MiB）。
- SHA-256：`361255B0F52D13EA8CE86987F9B37B6F05EF56F72123FA1091551932A8E137DF`。
- Release 构建、Android Lint Vital、APK v2 签名验证和 ZIP 16 KiB 对齐验证通过；全部 ARM64 ELF 加载段满足 16 KiB 对齐要求，APK 中的 10 个原生库与本次编译产物逐项哈希一致。
- 从实际 APK 读取到浅色原生窗口底色 `#FFFFFF`、夜间底色 `#11141B`，所需角色素材和播放器原生库均已打包。
- 原电脑 Beta.13 的签名密钥未转移，当前使用本机现有 Android debug 证书签署 Release 包。用户已接受签名不同时卸载 Beta.13 再安装 Beta.14；卸载会清除旧版本机数据。本次未安装到手机，未验证原签名兼容性。

打包和校验日志位于 `.codex-artifacts/2026-10-26-beta14-apk/`；交付目录附有校验值及 `Mesting-Music-v1.0.37-beta.14-verification.json`。未上传、发布或修改线上更新源。
