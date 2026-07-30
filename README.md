# Mesting Music

Flutter / Dart 原生音乐应用。这个目录现在作为独立项目维护，与
Mesting 个人数字空间（Vue 3 网站）分开管理。

当前源码是 Flutter 重构过程中的可运行基线，包含本地音乐、全局播放队列、
同步歌词、收藏、歌单、播放历史、主题和 Android 后台播放等能力。已发布的
Flutter APK（v1.0.37）属于发布产物；本仓库的 `pubspec.yaml` 版本号仍以当前
源码基线为准，不将旧源码误标为 v1.0.37 的对应源码。

## 技术结构

- 状态与依赖：Riverpod
- 路由：go_router
- 音频：just_audio、audio_service、audio_session
- 本地数据：Drift / SQLite、SharedPreferences
- 代码目录：`lib/core`（音频与数据）、`lib/features`（业务页面）、`lib/shared`（公共模型与组件）

## 本地运行

```powershell
flutter pub get
flutter run
```

## 开发验证

```powershell
dart analyze lib test
flutter test
flutter build bundle --debug
```

`flutter build bundle` 只验证 Dart 与资源编译，不会生成 APK/AAB。安装包建议在
本地构建后通过 GitHub Release 分发，不要把 APK 二进制提交到源码仓库。

## 演示素材

公开源码仓库不包含完整歌曲、歌词、商业封面或角色主题图。它们仍保留在本地开发
环境中，但已通过 `.gitignore` 排除。克隆项目后，请在 `assets/` 对应目录放入
自己拥有使用权的测试素材，并同步调整 `lib/features/library/data/demo_library.dart`
中的资源映射。

APK 等安装包仅通过 GitHub Release 分发，不进入源码提交历史。
