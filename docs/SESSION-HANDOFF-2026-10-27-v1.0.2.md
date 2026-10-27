# Mesting Music 正式版 1.0.2 完整交接

**后续 Git 状态更新**：用户在本版交付后明确确认将所有未推版本补齐到 Git/GitHub。Beta.20/21、1.0.1、1.0.2 的新标签与发布入口见 [补档记录](version-archive/RELEASE-BACKFILL-2026-10-27.md)。下文“未提交/未推送”是冻结交付当时状态；APK、原始源码 ZIP 和产品验证边界保持原样。

2026-10-27（Asia/Shanghai）。本轮已完成实现、Release APK 核验、music 平台发布和线上更新下载验证。新会话先只读核对分支、工作区、下列交付摘要和 [修改记录](fixes-2026-10-27-v1.0.2.md)，等待用户下一步指示；不把历史 Beta 方案当作待办。

## 已完成

用户已确认：音乐栏目、排列及个性化推荐由公开酷狗页面与现有接口整理；保留当前页面设计；设备卡片内直选“本机”和耳机；不再公开 Beta 版本；正式发布 1.0.2，并沿用当前身份和签名。所有澄清及实施方案已经确认，不要重复提问这些决定。

- 版本值靠近“当前版本”，窄屏大字允许换行。
- 当前“我的”移除重复装扮入口，保留设置入口并修正指南。
- 耳机改为统一细线轮廓；实际素材为 MIT Tabler 图标改编，来源、原 SVG 和许可随源码及 APK 提供，不声称它是 Apple 官方 iOS 27 图标。
- 玻璃输出卡片内展开“本机”及已连接输出；选择作用于同一音乐播放器的 AudioTrack/ExoPlayer，不自动打开系统输出面板。暂停时显示待播放生效，已生效状态由原生回读确认。
- 首页增加账号推荐、新歌、榜单、歌单、新碟、主题及场景音乐，入口对应实际目录和详情；不加入听书、直播、视频或讨论。场景只使用服务端音乐模块及其真实标签，账号/token 变更拒绝过期数据。
- 公开文案使用正式名称。自动听歌时长上报仍关闭，联系方式缺项保持原状。

实现范围及关键文件见 [本轮修改](fixes-2026-10-27-v1.0.2.md)。必要注释集中在播放器 owner、原生生命周期和接口解析边界；仓库内 just_audio 0.10.6 分支的补丁说明在 `third_party/just_audio/NOTICE.md`。

## 正式交付和更新

| 项目 | 当前值 |
| --- | --- |
| 公开版本 / Android code | 1.0.2 / 23 |
| 名称 / 模式 | Mesting Music / Release，非 debuggable |
| 包名 / 内部 flavor | `com.mesting.music.beta` / `beta`，仅作兼容身份 |
| APK | `release/Mesting-Music-v1.0.2.apk` |
| 大小 | 76,231,470 字节 / 72.70 MiB |
| APK SHA-256 | `DF7E73F597890F3C868BF53E34E22C712A1E1D2CBD114651A2B7CBEED73F7263` |
| 原签名证书 SHA-256 | `8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333` |
| 源码快照 | 根目录 `Mesting-Music-v1.0.2-source.zip` |
| APK 核验 | `release/Mesting-Music-v1.0.2-verification.json`、`.apk.sha256` |
| 源码核验 | `release/Mesting-Music-v1.0.2-source-verification.json`、根目录 `.zip.sha256` |

源码 ZIP 在本文和便携证据写入后冻结，逐条核验条目摘要，不包含 Git 历史、私钥、账号报告或本机缓存。它包括当前未提交修改。为避免自身摘要循环，源码核验 JSON 和 ZIP 的摘要侧文件在快照生成后单独写出，不在快照中；不要再改旧 ZIP 来补入自己的哈希。

已上传并发布到现有 Ring Download **Mesting Music · music**；服务端返回创建时间原文 `2026-10-27T18:39:44.185841`。本次没有调整其他应用、COS/P2P 或后台设置。

- [主下载入口](https://download.csnas.asia/music/download)
- [备用下载入口](https://download1.csnas.asia/music/download?direct=backup)
- [公开版本健康信息](https://download.csnas.asia/api/app/music/health)

现有生产 `CsnasUpdateReleaseSource` 和 `AppUpdateRepository` 在 Windows Flutter VM 中，以模拟已安装 1.0.1 / 22 的身份检测到 1.0.2 / 23，真实 HTTPS 下载到 1 MiB 后暂停、续传至全包并通过 SHA-256；同版本判断不再提示更新。主/备入口 HEAD 均 200、长度正确，Range 均 206，前 64 KiB 与本地 APK 一致；完整下载和续传测试仅覆盖主入口。

应用内“推送”沿用前台自动检查及手动“设置 → 版本更新”。回到应用按原有 15 分钟检查节流执行，用户暂不更新时同一版本延后 12 小时再提示；未新增后台系统通知服务。本轮没有唤起 Android 安装器。

本机平台截图为 `.codex-artifacts/2026-10-27-v1.0.2/platform-published.png`。便携线上证据见 `docs/version-archive/v1.0.2-evidence/` 下 `platform-verification.json`、`live-client-verification.json` 和 `public-endpoints-verification.json`。管理凭据未提取、未归档。

## 验证结果及未完成边界

- 最终受影响回归：13 个文件、148 通过、0 失败。
- 生产原生注册器的主机假对象断言：23 通过；Android Java/Kotlin 编译通过；最终静态分析无问题。
- 旧 stable 配置全量：741 通过、121 跳过、6 失败，保留原始结果。额外四项随后在 3 个文件的 41 项隔离测试中全部通过，未修改相关产品代码或放宽断言；交叉 flavor 捕获并行时出现的解码/时序现象原因未单独证实。另两项此前记录的问题仍保留：多行编辑菜单间距、关注者移除 sheet 层级。不能写成全量全绿。
- 20 张生产 Flutter 控件主机捕获；合成账号、目录、版本、样例封面及 Windows QA 字体。两张冷启动图标未解码的初始图已重拍。独立复核结论 `ship` 限于所给源码和有效主机捕获，不包含真机、扩展协议文案、最终 APK 或平台状态。
- Release 核验：包名/名称/1.0.2/23/签名正确；原 1.0.1 证书匹配；ARM32/ARM64；ZIP 和 ARM64 ELF 16 KiB 对齐；10 个原生库与构建产物一致；原始启动图和伙伴 atlas 一致；69 项旧 stable 专用素材继续排除；Tabler 许可已入包。
- 生产更新仓库线上完整下载/暂停续传/摘要、同版本判断通过；主/备公开入口的有界检查通过。

原始计数和具名失败见 `test-summary.json`；各组重叠，不可相加。主机测试、签名兼容及线上下载均不等于覆盖安装成功。

**由用户自行真机测试的部分**：真实蓝牙/耳机切换及换曲后路由、厂商 Android 行为、GPU 玻璃效果、系统安装权限和保留数据升级、真实账号个性化推荐、IME/TalkBack。本轮未访问、安装、重启或操作手机，也未开启听歌时长写入。

## 后续注意事项

当前分支仍为 `beta`，HEAD `edc6d1bf881cbe2173709cc84b86b91637fbaaed`，原标签 `v1.0.37-beta.19`。Beta.20/21/1.0.1/1.0.2 源码修改均在脏工作区中。没有 Git commit/tag/push、GitHub Release、工作区切换或清理。music 平台发布不等同于 Git 推送。

旧 1.0.1 APK/源码 ZIP 保持原字节：

- APK SHA-256：`27FBC6BA1DDF98A405A322AB8B71F834ED4A9456042E5D2821B8AA15546D80D2`。
- 源码 ZIP SHA-256：`E6C10555D5039925A6816BDEE2E2460EF0B5FF1BA33DE0DA5DFC0074738040AB`。

历史回看可在新目录使用 `v1.0.37-beta.19`，它不含本轮；不要在当前脏树 reset、clean 或覆盖用户改动。回退安装还受 Android 版本代码限制，旧 APK 不代表可直接降级并保留数据。

当前构建环境：独立 Flutter 3.41.9 / Dart 3.11.5，JDK 17.0.20.1，compile/target SDK 36、minSdk 24、NDK 28.2.13676358。构建入口：

```powershell
./tool/build_android_release_apk.ps1 -FlutterSdkRoot 'D:/你的Flutter目录/flutter'
```

当前 `pubspec.lock` SHA-256：`F6C3536F458E6641F2FD0AE68042B0697F0E845D105D6BD4ECA3A328E2BA40D4`。不要用 `--no-pub` 复用测试污染的 Release 注册器；不要改用旧 stable UI 或新包名。新电脑须单独配置 SDK/签名，不复制本机私密配置。后续版本 code 至少 24，按 [正式更新发布步骤](RELEASE-UPDATE-GUIDE.md) 核验 APK 真实身份后发布。

用户已要求自行真机测试并断开手机；没有新的明确授权，不运行 ADB、访问或安装手机。原生性能测试只能使用隔离 `.beta.benchmark` 包并强制 `--keep-app-running`。下一轮新需求继续遵循根目录 `AGENTS.md` 的单问题澄清和确认流程。
