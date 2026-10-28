# 当前会话总交接：Mesting Music 1.0.8

日期：2026-10-28（Asia/Shanghai）。工程根 **D:/AnLi**。用户本次要求整理全部完成项、注意事项、未完成任务，并新开会话移交。本文件是移交总入口；版本细节按下列同版记录查阅。

**后续已发布1.0.9 / code30：** 用户确认统一听书／功能搜索的底部控件、修复菜单残点与上沿凸起、调整私人 FM 首屏加载并移除加载底色，随后授权打包并发布。最新状态见 [1.0.9 当前接续](HANDOFF-CURRENT-SESSION-2026-10-28-v1.0.9.md) 与 [本地修复记录](docs/fixes-2026-10-28-search-menu-fm.md)。当前工作区已超出下述冻结1.0.8源码；原APK、源码ZIP及依赖锁保持原摘要。下述 `session-transfer-verification.json` 是修复前的交接核对，不代表当前源码仍与1.0.8 ZIP逐字节相同；下方1.0.8线上状态仅作历史。

## 当前结论

**1.0.6 / code27、1.0.7 / code28、1.0.8 / code29 已在本会话完成实施、验证、打包和 music 后台发布。当前线上为1.0.8，最新源码与原签名交付已保留。已授权的本轮本地实施和发布工作已完成；持续120fps及真实设备／官方账号验收尚未完成。**

交接时重新只读核验本地1.0.8 APK及源码ZIP的大小／SHA-256，并读取公开health，版本、code、文件大小和摘要匹配。未重新下载整包。保存于 `.codex-artifacts/2026-10-28-release108/handoff-health.json`。

**新会话先只读接手，简短报告核对结果后等待用户。不要自行开启新版本、再次发布、提交Git、运行重建或访问手机。**

## 本会话完成了什么

### 1.0.6：菜单、文案、本地化和安装前更新说明

- 修复歌曲页面菜单展开时左上角闪现的异常玻璃。更多按钮增加常驻圆形玻璃底座，保留原400ms展开／240ms收回、液态短颈和中途反向连续轨迹。
- 完整播放器和胶囊同类菜单统一为内缩圆角透光按压反馈及轻微回弹，去除灰色Material水波。
- 顺序播放提示去掉重复的“不循环”；签到页仅保留右上角刷新加载动画，下拉手势仍可用；生日滚轮中文年月日；音效使用酷狗目录中每个效果对应的官方原始图。
- 优化页面／底栏的稳定子树、搜索输入和指示器重建路径，保留原玻璃和弹簧。
- 从1.0.6起支持在安装前查看后续版本的在线更新说明：优先health元数据，否则有界HTTPS Range读取目标APK内说明，验证ETag、ZIP、CRC和版本身份。用户已接受已安装1.0.5本身无法凭空获得这项能力。
- 详见 [1.0.6 接续](docs/SESSION-HANDOFF-2026-10-28-v1.0.6.md) 与 [修改](docs/fixes-2026-10-28-v1.0.6.md)。

### 1.0.7：导航、新功能、官方统计同步和初版诊断

- 用户确认底部导航采用 **发现／功能／音乐库／我的**。原首页保留内容并改名“发现”，原发现页替换为延续当前Apple风格的固定三列功能网格；用户选择先不做入口编辑／排序／固定功能。
- 随机开关和循环关闭／列表循环／单曲循环分别使用不同图标。播放器左右收起／更多按钮统一玻璃样式；菜单从按钮朝向菜单的一侧内缘展开，保留既有液态效果。
- 本地音乐：Android MediaStore扫描、SAF手动多文件及文件夹导入、持久授权、按文件夹浏览、搜索、失效状态与离线播放；索引原子保存、元数据后台提取、封面惰性缓存。
- 听歌识曲：麦克风权限、8秒分段／最多7轮、isolate中转换PCM16单声道8kHz、识别结果接入现有播放和收藏。每次运行使用独立临时目录，支持取消和生命周期清理。
- 听书：分类、搜索、专辑、章节、付费／试听权限处理、自动续章、按账号续播；临时地址由repository解析。
- 一起听：按用户确认接入酷狗房间服务，使用当前酷狗账号，支持创建／加入／恢复／离开、邀请、成员、队列以及主客端播放／seek同步。所有来源复用唯一音频handler。
- 播放历史与时长：schema7按账号隔离同步journal；可还原旧歌曲历史排队补传；新真实收听时长用单调墙钟计算，排除暂停、缓冲、seek。已接收、待核对与官方读回verified分开，超时unknown不盲重发。
- 用户已明确接受：旧625分钟完整保留本地，不制造新片段，不补记为今天，也不承诺回填酷狗原月份。这个接口限制已经达成取舍，不是遗漏任务。
- 新增同步状态页面；更新对应协议／隐私文案。加入Android高刷请求、全DPR同帧背景捕获复用、底栏布局和文字／图标内容保留、90秒用户自行导出的流畅度诊断。
- 修复主机审查发现的嵌套重绘边界背景缓存过期与识曲临时文件碰撞。
- 详见 [1.0.7 接续](docs/SESSION-HANDOFF-2026-10-28-v1.0.7.md) 与 [修改](docs/fixes-2026-10-28-v1.0.7.md)。

### 1.0.8：依据小米14Pro报告进行渲染专项优化

- 用户确认报告来自1.0.7、默认浅／深色界面，主要快速切四个根页并展开／收起播放胶囊，设备 **小米14Pro**。
- 原报告44.458秒／2133条帧采样，120Hz显示；UI P90 3.460ms，光栅P90 31.633ms；超8.33ms分别4.03%和76.75%。瓶颈主要位于光栅／合成，不能直接断言GPU占满或某个shader是唯一原因。
- 排除根页面动画无限堆积的判断；默认底栏指示器blur=0，不应无依据归咎于全屏捕获循环。旧报告事件与帧缺共同时间锚点，窗口关联仅粗略。
- 玻璃RGB采样落在同一2×2范围时只读取四个RGBA纹理点一次，保留每通道插值、透明度和背景合成；跨范围走旧路径，没有降低色散、清晰度或材质。
- 稳定展开的底栏与胶囊按严格条件共享背景读取。当前变换、阴影范围、模糊读取外沿不安全、按压缩放、淡出、收展、键盘／搜索或重叠时隔离；旧共享key在首个不安全帧清除。浅色阴影使共享关闭时保留原画面，不强行共享；指示器仍独立。
- schema2诊断增加原始vsync锚点、事件前后帧区间、版本／主题／物理尺寸／DPR／shader能力，以及有界匿名CPU绘制、遮罩／阴影／捕获计数。停止后等待1.2秒收集末批耗时，过滤采集区间外帧。
- 六处材质／播放器／菜单／页面与底栏调用端源码和冻结1.0.7逐字节一致；原动画时长、曲线和弹簧保持。
- 详见 [1.0.8 接续](docs/SESSION-HANDOFF-2026-10-28-v1.0.8.md)、[修改](docs/fixes-2026-10-28-v1.0.8.md) 和 [本地renderer补丁说明](third_party/liquid_glass_widgets/MESTING_PATCHES.md)。

## 已验证的范围与证据

- 1.0.6：138项受影响Beta回归、14项新增、28项选定stable检查通过；主机截图和336帧结构性对比保留，不冒充真机帧率。
- 1.0.7：48项新增、164项受影响Beta、73项额外音频／更新及42项选定stable检查，分组有交叉。43张Beta主机截图、原生LocalMusicBridge Kotlin编译及最终静态分析通过。首轮夹具／渠道混跑／字体／shader并行冲突失败日志保留，最终通过记录见同版文档。
- 1.0.8：首批26项、最终41项检查通过（有重叠），静态分析无问题。实际GLSL helper编译SkSL/GLES/GLES3/Vulkan，21,504个参考像素每通道差异不超过1/255。8张诊断截图覆盖浅深色、390dp、320dp/1.6倍文字及768dp，等待状态／状态保留／共享隔离／排空过滤均验证。
- 最新APK原包名、签名、版本、非debuggable、min24/target36、ARM32/ARM64、ZIP及6个ARM64 ELF 16KiB对齐通过；69项正式渠道资源、IntegrationTestPlugin、QA字体和测试shader未入包，Ring/WebRTC保留。
- 最新公开health及一次完整下载摘要匹配本地；生产Range/ZIP读取线上4条中文说明通过，旧1.0.7读取器／release source／Beta面板与本版逐字节一致。此证据不等于手机上已点击更新或覆盖安装。
- 主要证据目录：`.codex-artifacts/2026-10-28-release106/`、`2026-10-28-release107/`、`2026-10-28-release108/`；原报告分析在 `.codex-artifacts/2026-10-28-diagnostics107/`。这些忽略文件仅在本机，不能假设git clone包含。
- 最新目录重点：`apk-verification.json`、`source-verification.json`、`public-verification.json`、`live-notes.json`、`validation-summary.json`、`preserved-frozen.json`、`preserved-behaviour.json`、`finish-review.md`、测试／构建日志、`screens/` 与 `music-published.png`。

## 最新交付与冻结身份

| 项目 | 当前已核验值 |
| --- | --- |
| 线上应用／版本 | music / Mesting Music 1.0.8 / Android code29 |
| 安装身份 | com.mesting.music.beta，内部beta仅保留安装兼容；显示名不加“测试” |
| APK | D:/AnLi/release/Mesting-Music-v1.0.8.apk |
| APK大小／SHA-256 | 100,249,043字节；E7C58250887A7CD8C43FA673FBA9DAE2DD66B644BE8AA993F28E9E4362237E78 |
| 原签名证书SHA-256 | 8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333 |
| 源码ZIP | D:/AnLi/Mesting-Music-v1.0.8-source.zip |
| ZIP大小／SHA-256 | 48,336,789字节／1499文件；58F171A355935C73F805C6B95B001DA4B0C0301B0ED736BD4155118DA03096DC |
| 依赖锁SHA-256 | FDE25643DA671EF68397B59A3BB38E4AD5F664075E2D0414EBADABB9DC2DF2EF |

**本次扩写交接发生在源码ZIP冻结之后。ZIP内含发布时的原简版交接，本文件与接手指针的后续补充位于当前工作区，不回写或重打该ZIP。** ZIP内SOURCE-SNAPSHOT.json可逐文件核对发布时源码。保留1.0.6/1.0.7及更早冻结交付，不重建、不重新签名或覆盖。

## 未完成／待验证事项

1. **小米14Pro实际流畅度仍待复测。** 用户尚未提供1.0.8 schema2报告，不能宣称持续120fps或量化GPU提速。应由用户重复同分辨率、主题、电源／温度条件的根页切换和胶囊收展，再比较光栅P50/P90/P99、超8.33ms占比及同原始vsync的CPU计数。采样密度不是呈现FPS，CPU绘制计数也不是GPU pass数。
2. **真实账号和设备验收仍有缺口。** MediaStore/SAF、麦克风识曲、双端酷狗房间同步、听书付费／试听权限、蓝牙／音效听感、保留数据覆盖升级及实际更新按钮点击没有由本会话代测；实现与主机协议／界面检查已完成，应按用户反馈再处理，不自行批量调用真实账号。
3. **官方历史／听歌时长实际入账未确认。** 上游接收成功不等于酷狗已累计。旧证据 `docs/listening-sync-verification-2026-10-27.md` 保留；优先独立只读核对，未知或已dispatch记录不要盲重发。旧625分钟不准造假回填，继续本地保留。
4. **Git归档尚未做，也没有授权自动做。** beta HEAD仍是v1.0.5，1.0.6～1.0.8全在脏工作区。APK已发布不代表代码已推送GitHub。若未来用户要求归档，先确认范围、校验冻结交付与当前remote refs，再按约定处理。
5. 没有待补发的1.0.6/1.0.7/1.0.8安装包，没有已知阻断主机检查的P1/P2留待续做。进一步遮罩／阴影优化取决于下一份真实计数，不自行当成已批准的1.0.9计划。

## 必须注意的边界

- **保留全部脏工作区。** 分支beta，HEAD `dbc5e78d05570c26f56fe5c5773245737a464a5f`。不reset/clean/stash、不覆盖用户改动，不自动add/commit/push/tag／发GitHub Release。
- **不操作手机。** 用户自行真机测试；没有新的明确授权不得ADB枚举、连接、安装、启动、读取或测试手机。以后经授权的原生benchmark也只能用隔离 `.beta.benchmark` 包，强制 `--keep-app-running`，不能默认flutter drive日常包。
- **保留画面和交互。** 不以删除／替换原菜单和胶囊动画、关闭模糊／折射／色散／阴影、降低DPR来虚称达标。先分析新报告，再给用户具体方案。
- **新需求按AGENTS约定。** 一次只问一个真正需要的问题，理解后提出方案，等确认再实施；既有选择不重复追问。必要代码注释与分层解耦保留。
- **版本与说明一致。** 后续Android code必须大于29，版本名由用户确认；同步 `assets/data/release-notes.json` 与内置release_history，保留严格Range/ETag/CRC/版本／签名检查。不拿当前说明冒充未来说明，不重复发布当前已上线版本。
- 用户已确认SDK源码分发授权，保留LICENSE和第三方声明；SDK分享关闭，不开启。私钥、密码、凭据、本机配置不进入源码包／GitHub／music后台；后台仅上传可公开分发APK。
- 不清理共享SDK、签名、源码或缓存，旧清理授权不延续。只在构建结束停止了本轮已确认的Gradle进程，没有继续清理授权。
- 内置浏览器之前登录 `https://download.csnas.asia/admin?page=apps`，不假定新会话继承标签／登录／浏览器句柄。本次handoff不需要再次操作后台。
- 旧1.0.5、LOCAL-CLEANUP等记录只作历史。涉及最新状态先看本文件、AGENTS顶部与1.0.8文档，避免沿旧“待发布”描述重发。

## 构建与定位速查

- Flutter3.41.9 / Dart3.11.5 / JDK17；SDK `D:/CodexCache/flutter-3.41.9`。本机环境脚本 `.codex-artifacts/2026-10-27-v1.0.1/env.ps1`，只读取/使用，不公开其中机器配置。
- 发布入口 `tool/build_android_release_apk.ps1` 默认1.0.8/29，构建使用进程局部Gradle3GB heap／2 workers，不能加 `--no-pub`，依赖锁禁止漂移。测试会改变开发插件生成状态，最终发布构建应正常pub生成registrant。
- Beta回归必须带 `--flavor beta`；stable固定身份夹具单独运行。Flutter测试不并行启动多个进程，避免共享shader编译资产冲突。涉及SQLite使用本机已有 `SQLITE3_TEST_DLL`，路径与例子见1.0.7/1.0.8日志，不盲升级依赖。
- 渲染：`third_party/liquid_glass_widgets/package/shaders/liquid_glass_render.frag`、`package/lib/src/renderer/glass_backdrop_peer.dart`、`glass_backdrop_group_boundary.dart`、`src/engine/liquid_glass_layer.dart` 与 `glass_render_diagnostics.dart`。其中package前缀均接在third_party/liquid_glass_widgets之后。
- 新功能：`lib/features/local_music/`、`recognition/`、`audiobooks/`、`kugou_together/`、`music_platform/listening_sync/`；原生本地桥为 `android/app/src/main/kotlin/com/mesting/mesting_music/LocalMusicBridge.kt`。
- 诊断：`lib/core/performance/frame_timing_probe.dart`、`lib/features/settings/presentation/frame_diagnostics_page.dart`；关键新测试 `test/release_108_shader_test.dart`、`release_108_render_test.dart`、`release_108_diagnostics_ui_test.dart`。

## 新会话接手顺序

1. 读取本文件和AGENTS，再看1.0.8接续／修改；按需看1.0.7和1.0.6，不沿历史绝对路径或旧发布状态执行操作。
2. 只读核对cwd、分支、HEAD与git status；可核对本地APK／源码ZIP摘要及已保存发布证据，不调用会重建／复制／发布的验证脚本。
3. 简短说明已接手、当前线上版本、工作区未提交及真机待验证边界，然后等待用户新报告／需求。初始接手不重跑整套测试、不重建、不发布、不改代码、不访问手机。
