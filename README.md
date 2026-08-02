# Mesting Music

面向 Android 的 Flutter 音乐应用，覆盖在线音乐搜索与播放、全局队列、同步歌词、收藏歌单、播放历史、后台媒体控制、主题换肤、账号与好友互动。

## 版本状态

当前 `main` 分支对应 **`1.0.38+39` 源码快照**。它是在公开稳定版 `1.0.37+38` 之后继续开发的测试版本，包含 Java/MySQL 账号服务的客户端接入能力。

| 引用 | 对应内容 | 状态 |
| --- | --- | --- |
| `flutter-music-v1.0.37` | `1.0.37+38` APK 与早期公开开发基线 | APK 已发布；标签中的源码不是该 APK 的逐文件快照 |
| `flutter-music-v1.0.38-source` | `1.0.38+39` Flutter 客户端源码 | 当前可审查源码；测试版本，未替代 `1.0.37` 稳定版 |
| `main` | 最新公开源码 | 当前与 `flutter-music-v1.0.38-source` 对齐 |

旧开发目录此前没有完整 Git 历史，因此无法可靠还原生成 `1.0.37` APK 时的逐文件源码。仓库没有通过改版本号或移动旧标签伪造对应关系，而是从 `1.0.38+39` 起重新建立源码、版本和标签的可追溯关系。详细说明见 [CHANGELOG.md](CHANGELOG.md)。

稳定版 APK：[Mesting Music Flutter v1.0.37](https://github.com/Mesting42/mesting-music-flutter/releases/tag/flutter-music-v1.0.37)

## 主要功能

- 本地与在线音乐搜索、播放、队列和失败回退
- 列表循环、单曲循环、随机播放及真实播放历史
- LRC 歌词解析、同步滚动和 Android 悬浮歌词
- Android 后台播放、通知栏、锁屏和耳机媒体控制
- 收藏、个人歌单、最近播放、每日足迹和重启恢复
- Riverpod 状态管理、go_router 路由和 Drift / SQLite 本地持久化
- 账号注册登录、资料、好友、私信及一起听功能
- CloudBase 稳定链路与 Java/MySQL 测试链路的构建时切换
- 多套播放器样式、应用主题和角色化视觉方案

## 技术结构

| 领域 | 技术 |
| --- | --- |
| 客户端 | Dart、Flutter、Material / Cupertino |
| 状态与路由 | Riverpod、go_router |
| 音频 | just_audio、audio_service、audio_session |
| 本地数据 | Drift / SQLite、SharedPreferences、Flutter Secure Storage |
| 网络 | HTTP、Audius、可配置音乐服务接口 |
| Android | Kotlin / Java、MediaSession、前台服务、通知与悬浮窗 |

## 本地运行

环境要求：Flutter SDK、Android SDK、JDK 17 或 Android Studio 自带 JBR。

```powershell
flutter pub get
flutter run
```

默认 Debug 构建使用本地预览账号模式。需要联调云端时，通过构建参数注入地址或环境标识，不要把密钥写入仓库：

```powershell
flutter run `
  --dart-define=AUTH_API_BASE_URL=https://api.example.com `
  --dart-define=CLOUDBASE_ENV_ID=your-environment-id
```

## 验证

```powershell
dart analyze lib test
flutter test
flutter build bundle --debug
```

`flutter build bundle` 用于验证 Dart 与资源编译，不生成 APK/AAB。正式发布前还需要配置自己的 Android 签名，不能使用示例或 Debug 签名发布。

## 目录

```text
lib/
  app/               # 应用入口与路由
  core/              # 音频、数据库、安全、网络与持久化
  features/          # 播放器、曲库、搜索、账号、社交等业务模块
  shared/            # 公共模型、组件与工具
android/             # Android 原生工程与媒体服务配置
assets/              # 运行所需品牌、主题与歌单视觉资源
integration_test/    # Android 集成与性能回归
test/                # Dart / Flutter 单元与组件测试
tool/                # 构建和发布辅助脚本
```

## 资源与后端边界

- 仓库不包含本地歌曲、歌词、签名文件、密码、JWT 密钥或云端管理凭据。
- 部分角色主题、封面和品牌名称可能涉及第三方权利，仅用于个人学习与作品展示，不随源码授予复用或商业分发许可。
- Java 21 / Spring Boot / MySQL 服务端目前在独立迁移工程中维护，本仓库公开的是 Flutter 客户端及其接口适配代码。
- 生产稳定版仍为 `1.0.37+38`；`1.0.38+39` 是用于验证 Java/MySQL 迁移的测试源码。

## 开发方式

项目由个人主导并使用 Codex、Claude、Cursor 等 AI 编程工具辅助需求拆解、代码实现、排错和测试。功能规则、集成验证、真机回归、版本发布与最终取舍由项目作者负责。
