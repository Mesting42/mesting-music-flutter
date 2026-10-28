# Mesting Music 1.0.8 接续

日期：2026-10-28（Asia/Shanghai）。工程根 `D:/AnLi`，版本 1.0.8 / Android code 29。用户已确认性能专项方案、实施及通过本地验证后发布 music。

状态：1.0.8 / code29 已发布 music；公开health、完整下载SHA-256及安装前线上更新说明读取均通过。

## 范围与源码

见 [本轮修改](fixes-2026-10-28-v1.0.8.md)。仅改玻璃渲染重复采样、安全背景共享与诊断，不修改歌曲／本地音乐／听书／一起听／官方同步业务。底栏、播放器、菜单和页面动画的调用端源码与冻结1.0.7逐字节相同；包内几何动画时长与原弹簧保持。

分支 `beta`，HEAD仍为v1.0.5 / `dbc5e78d05570c26f56fe5c5773245737a464a5f`。1.0.6、1.0.7及本轮全部未提交变化保留，没有Git commit/push/tag/Release。不得用旧Git远程覆盖本机源码。1.0.6/1.0.7 APK、摘要和源码ZIP冻结，签名／本机配置／共享SDK与缓存保留，不含继续清理授权。

用户自行真机测试；未访问手机、未使用ADB、未安装或读取设备。本轮不读写酷狗真实账号。若后续需要设备须新明确授权；原生benchmark仍仅隔离 `.beta.benchmark` 且强制 `--keep-app-running`。

## 接手入口

- `third_party/liquid_glass_widgets/package/shaders/liquid_glass_render.frag`：实际RGB同纹理范围采样复用与跨范围回退。
- `package/lib/src/renderer/glass_backdrop_peer.dart`：共享门和胶囊专用淡出；`glass_backdrop_group_boundary.dart`：严格peer范围／变换检查；`src/engine/liquid_glass_layer.dart`：保留层key失效及绘制计数。
- `package/lib/glass_render_diagnostics.dart`：默认关闭的匿名CPU绘制计数，最多14000个帧键。
- `lib/core/performance/frame_timing_probe.dart`：schema2、原始帧时钟锚点、事件前后帧区间、90秒上限、1.2秒排空和边界过滤。
- `lib/features/settings/presentation/frame_diagnostics_page.dart`：版本／显示能力元数据和排空等待状态。
- `test/release_108_shader_test.dart`：编译实际GLSL helper并对比冻结公式；只暂存到unit_test_assets，产物不进入发布包。
- `test/release_108_render_test.dart` 与 `test/release_108_diagnostics_ui_test.dart`：共享隔离、旧key失效、排空过滤、中文UI和四种配置。

## 验证与限制

本机第一批26项渲染／界面回归通过，最终41项更新／播放器／新诊断检查通过，两批有重叠不累加。静态分析无问题。8张诊断主机截图覆盖390dp浅深色、320dp/1.6倍文字和768dp；测试字体补齐后复核。21,504个新旧采样像素每通道差异不超过1/255。原菜单轨迹、底栏336帧收展和更新下载校验通过。

初轮shader编译缺spirv输出参数、shader测试需要native资产暂存、UI截图需runAsync、旧未来版本fixture与1.0.8内置说明冲突均已修正并保留失败日志，未放松产品验证。最终结果以 `.codex-artifacts/2026-10-28-release108/final-checks.log`、`regression.log` 和 `analyze-final3.log` 为准。

主机绘制计数和像素测试不能证明小米14Pro实际GPU性能。下一步由用户安装后在相同显示分辨率、主题和电源／温度条件下重复四根页切换、胶囊展开／收起，再发送schema2报告。比较光栅P50/P90/P99、超8.33ms占比及同原始vsync下的CPU绘制计数；不将样本密度或显示120Hz冒充120fps。浅色阴影使共享关闭时属于保真策略，后续看matte/shadow计数后再选无损改法。

## 构建与交付

Flutter3.41.9 / Dart3.11.5 / JDK17，原共享SDK；`tool/build_android_release_apk.ps1` 默认1.0.8/29，进程局部Gradle3GB heap／2 workers，不使用`--no-pub`，拒绝锁文件漂移。安装身份 `com.mesting.music.beta`、显示名Mesting Music和原签名证书保持。

交付目标 `release/Mesting-Music-v1.0.8.apk`；迁移源码 `Mesting-Music-v1.0.8-source.zip`。源码ZIP由Git已跟踪及未忽略新源码共同生成，含原授权SDK源与许可证，排除私钥、凭据、本机配置和构建缓存。Git远程仍不代表最新工作区。产物摘要和发布证明写入本版验证文件，不覆盖历史交付。

最终安装包／公开下载／安装前更新说明读取均已完成；源码ZIP由当前最终文档与源码生成，逐文件摘要见ZIP内SOURCE-SNAPSHOT.json，整包结果另存本机忽略目录source-verification.json。

最终构建516.1秒，69项正式渠道资源排除、ARM32/ARM64、min24/target36、release非debuggable、ZIP及6个ARM64 ELF 16KiB对齐通过；IntegrationTestPlugin、QA字体和测试shader未入包，Ring/WebRTC保留。只停止了本轮创建且已确认父进程的Gradle daemon，未删除共享缓存。

| 安装包项目 | 已核验值 |
| --- | --- |
| 大小 | 100,249,043 字节 |
| SHA-256 | E7C58250887A7CD8C43FA673FBA9DAE2DD66B644BE8AA993F28E9E4362237E78 |
| 原签名证书SHA-256 | 8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333 |
| pubspec.lock SHA-256 | FDE25643DA671EF68397B59A3BB38E4AD5F664075E2D0414EBADABB9DC2DF2EF |

冻结1.0.6与1.0.7 APK／源码ZIP及依赖锁摘要均未改变。1.0.7冻结源码中的远程更新说明读取器、release source与Beta说明面板和本轮逐字节一致；安装前实际设备点击仍未代测。

## music发布与公开读回

已通过用户登录的Codex内置浏览器上传至music；暂存返回包名、code29及完整SHA-256一致后，核对公开版本名1.0.8，确认发布。后台当前公开版本与文件均显示1.0.8，未修改其他应用或删除历史版本。上传经FRP共516.9秒，证明截图 `.codex-artifacts/2026-10-28-release108/music-published.png`。

公开health读回版本1.0.8/code29、100,249,043字节与相同摘要；主入口完整下载100,249,043字节的SHA-256与本地原签名APK完全一致。证据public-health.json、full-download-verification.json及public-verification.json。没有反复下载主备整包或修改限流。

生产PublicApkReleaseNotes直接对线上APK实际执行Range、ETag、ZIP条目和CRC读取，4条中文说明与本轮目标版本一致；该调用绕过当前内置历史，验证旧客户端安装前的远程读取路径。证据live-notes.log/json；未代替设备上的实际按钮点击／安装验证。
