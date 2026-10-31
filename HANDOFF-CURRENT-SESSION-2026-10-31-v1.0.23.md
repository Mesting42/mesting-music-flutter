# 1.0.23 / code44 当前交接

**最新接续：用户现已要求将剩余任务移交新会话完成，并将下一版定义为1.0.24/code45，取代此前1.0.23-r3。以[1.0.24会话总交接](HANDOFF-SESSION-2026-10-31-v1.0.24-TO-NEW-CHAT.md)为接手入口。下文“待最终确认”“尚在构建”等按原历史时点保留，不能覆盖最新指令与R2实际验收状态。五组新增功能尚未编码；手机测试仍暂停，不自动恢复；保留原R2、原SDK和全部工作区，不Git提交推送或发布。**

最新状态：原签名双ARM 1.0.23-r2 已构建、校验并按用户授权覆盖安装。APK位于 release/Mesting-Music-v1.0.23-r2.apk，SHA256=306f66d8ec2426de98bf52f251220d56a57cd907fd028eb27d100b223c9b56b5；手机回读摘要一致，真实引擎日志明确为 Impeller OpenGLES，完整底部玻璃与暂停胶囊保留。原路线5轮进程不变，2333帧完整窗口栅格P99=15.86ms。另完成12个有效扩展窗口共37350帧，正常/快速滑动与60次约65-112ms间隔的超快速Tab点击；准确页面覆盖、空数据与排除项见扩展采样JSON，不能宣称所有页面已测完。

用户已要求暂停手机测试。暂停后未继续ADB采样或触控；一起听双端由用户后续自行测试。最新三项新增需求仍在逐题澄清/方案确认中：手机内一键双平台及公共页面正常/超快速操作、失败后继续/分段保存/断点续跑/导出报告；统一网易云/酷狗双标签签到页且酷狗自动签到跨平台生效；网易云官方优先、失败或仅试听时使用已保存酷狗概念版账号补源并支持手动选择。用户在此前方案确认时提出后两项追加需求，因此不能把尚待回应的完整方案当作已批准，也未开始这三项功能编码。预定独立R3，R2保持冻结；源码ZIP未冻结，Git提交推送与发布未授权。

随后追加下载页需求：复用Beta版本更新的AppleDownloadProgress胶囊进度组件，显示真实已下载/总大小并自动KB/MB；解析阶段使用自定义蓝色波形而非默认转圈。“下载任务”保留等待/解析/下载/保存/失败/取消，完成项仅在“已下载”；无剩余任务显示暂无。两个分栏支持左右滑动、点击同步及独立滚动位置。已经将四组需求合并给用户再次确认，当前尚未收到最终确认。未登录平台自动诊断跳过，已有账号平台可切换，结束恢复原平台；签到页测试不点击签到/领取业务动作。不要把上文历史中的三项计数当作最新完整范围。

最新完整方案已增至五组，仍待用户最终确认，不要提前实施：第5组是音效封面真实加载、社区/耳机/明星三页左右滑动，以及全App同类页面的分栏滑动与底部控件统一检查。用户明确键盘收起后保留与发现页相同的播放胶囊，即使筛选仍有效；只在键盘弹出时收起。音乐内容页不额外绘制包住底部控件的背景盒子，复用发现的公共玻璃导航/胶囊/搜索；完整玻璃效果保留。对下载任务失败/取消保留的选择已确认；当前酷狗接口主要为概念版，网易云现有酷狗补源是匿名，新增应使用独立已保存账号并保持网易云官方优先。五组最终确认问题已发出，尚无答复；本轮尚未改动任何这五组功能代码。手机测试暂停约束持续有效。

工程唯一目录 D:/AnLi/Mesting-Music-Flutter/app-md3music-beta；分支beta，基线HEAD=15023fec8e903e40ff3841f10a396580ee1860ef。用户已确认本轮方案和版本，允许连接手机采样，随后明确要求使用日常已安装的正式版测试。本轮不包含Git提交、推送、GitHub或music发布授权。

实现包括Adreno Vulkan崩溃后的Impeller OpenGLES兼容恢复、播放页顶部一起听状态、独立管理面板、平台时长/距离数据与主动定位。根因证据、具体实现和权限边界见[修改](docs/fixes-2026-10-31-v1.0.23.md)，验证事实见[validation](docs/validation-2026-10-31-v1.0.23.json)。构建、安装和交付状态必须以validation为准，不能从文档标题或旧记录推定已验收。

首个原签名code44候选已按用户确认覆盖到日常包，保留数据；其SHA256=b8852cf8bf49a22517f33e5fa5c47860450d5f5e2ac6a674688654a40298952f。应用请求OpenGLES，但引擎实际日志仍是Vulkan，因此该候选未通过后端验收，不能称已避开驱动路径。用户明确选择继续构建定制Release引擎以保留完整玻璃；相关源码、窄范围补丁和构建脚本见third_party/flutter_engine与tool。原SDK不改，在F:/CodexData/build-cache/mesting-engine-3.41.9独立准备固定3.41.9源码与依赖。当前源码C++选择分支检查23项通过，实际编译/安装状态需查validation，未生成之前不得把该首包当最终包。手机离开音乐前台时停止触控。

引擎环境接续：Windows挂载小文件写入过慢，F:缓存保留；最终Linux构建目录是WSL Ubuntu的/root/.cache/mesting-engine-3.41.9/native-source，84个Git仓库按已缓存的固定HEAD在ext4重新恢复，工具包复用F:下cipd-cache。2026-10-31 01:58已完成全部工具依赖和系统根目录准备，23项实际C++选择分支再次通过。当前构建日志位于被忽略的.codex-artifacts/2026-10-30-release123/custom-engine-native-git.log与.err，后台入口为同目录native-git-build.sh；进程号记录engine-build-win-pid.txt。旧tar复制留下的/root/.cache/mesting-engine-3.41.9/flutter仅为未完成缓存，不能当实际编译目录。Linux构建采用优化Release/AOT、剥离符号且关闭完整LTO以适配8GiB构建主机，该取舍已记入README；不是profile测试引擎。Gradle已验证仅betaRelease换用原生库，stable仍用原官方双ARM依赖。最终有效候选预定另用Mesting-Music-v1.0.23-r2.apk，首包不覆盖；实际文件与验收结果仍以validation为准。

后续构建日志已切到custom-engine-bounded.log与.err，入口resume-bounded-engine.sh。工具虚拟环境由公开构建脚本放到Linux源码旁的engine-tool-cache；WSL内仅本次构建的systemd临时scope限制为MemoryHigh3G/MemoryMax4G/SwapMax2G、Ninja3并发，已复用此前完成的对象文件继续ARM64。只释放过构建VM的文件缓存，没有更改Windows内存设置或重启/关闭桌面应用。距离DTO另补unopenedUserIds覆盖旧距离数值的保护，Beta/Stable及分析在beta-regression-final.jsonl、stable-regression-final.jsonl与analyze-final-2.log重新验证，最终以这些最新日志为准。旧日志中的通过次数不累加为新测试数。

已确认手机原包为1.0.22/code43且备份摘要与GitHub冻结相同；日常真实账号5轮采样未闪退。约25秒完整窗口2000帧栅格P99=22.43ms，不能称持续120fps。完整玻璃隔离场景另复现过驱动分配失败和0x1c原生崩溃；其套件中断，不记成功。手机用户中途在使用其他应用时曾暂停触控，恢复前台后才继续。

新包原生启动策略位于 MestingApplication / RendererCompatibility / VulkanCrashSignature，Beta manifest覆盖应用类，提前于AudioService缓存引擎。250ms启动探测预算，晚结果供下次冷启动使用；OS更换后不复用旧系统的故障决定。保留premium shader和材质参数，不把它写成闭源驱动永久修复。

一起听拆分为page兼容入口、player header、panel、presence DTO/定位gateway和房间controller。独立TogetherLocationBridge只执行主动的一次定位；不增加后台定位，不读取Wi-Fi标识。房间/账号代次拦截迟到结果。新请求字段根据官方9.5.12协议独立实现；只保存字段事实与单位，不打包官版APK或代码。实际双方距离与双客户端互通仍需两端用户操作核验。

保留本地未提交的 HANDOFF-SESSION-2026-10-30-v1.0.22-SYNC-TO-NEW-CHAT.md、全部旧冻结产物、原签名、SDK和许可。用户已自行发布1.0.22到music，此项是用户告知；本轮没有后台操作。不得把历史冻结文档的旧Git状态覆盖本机当前事实。保留music浏览器页面，不继续已停止的桌面内存优化。后续新需求仍一次一个问题，确认具体方案后实施。
