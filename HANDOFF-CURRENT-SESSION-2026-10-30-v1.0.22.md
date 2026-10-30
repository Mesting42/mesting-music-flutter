# Mesting Music 1.0.22 / code43 候选交付接续

日期2026-10-30（Asia/Shanghai）。用户确认聚焦“我的”页：拆分滚动绘制、优化安全背景采样与封面解码、缩小数据重建、补网易云登录态回归和原生详情导出；保留完整玻璃和动画，先本机验证及原签名候选，真机待方便后补。

**本机实现、验证、候选APK和完整源码准备完成；本轮未连接手机/ADB、未访问真实账号或后台。我的页实际流畅度、trace可用性和原生闪退根治均未验收，不把候选称为正式实机通过。**

- [原签名候选APK](release/Mesting-Music-v1.0.22.apk)：104756863字节；SHA256 `cb6b4bbde02d4c52f985b6d5a344a5f9ecf45f6b0d63be8f5aa40b436dc2c8bb`。应用Mesting Music，包名com.mesting.music.beta，双ARM、code43，原证书与1.0.21一致。APK CRC/16KiB ZIP和ARM64 ELF/ARM32 ELF、许可/资源/原生桥接及正常release配置核验通过，未打入测试插件、测试字体或歌词夹具。
- [完整源码](Mesting-Music-v1.0.22-source.zip)，大小、摘要和文件清单以[源码核验](release/Mesting-Music-v1.0.22-source-verification.json)及ZIP内SOURCE-SNAPSHOT.json为准。[APK核验](release/Mesting-Music-v1.0.22-verification.json)、[SHA256清单](release/Mesting-Music-v1.0.22-SHA256.txt)、[validation](docs/validation-2026-10-30-v1.0.22.json)记录真实候选状态。
- 60文件1123项Beta、stable19、Android返回1、分析0通过。9项个人页专项、5项Dart诊断包含在主组；另有纯Kotlin解析11项。生产Range读取器只从本地精确候选APK读3段66087字节核对4条更新说明，未访问/发布线上服务。
- 新版个人页按标题、身份资料、快捷控件、下载/喜欢和歌单拆sliver与Consumer。完全离屏段可停止当前绘制；收藏元数据变化不重建头像和6个玻璃按钮，数量变化仍显示；喜欢封面64逻辑尺寸，NetEase请求目标192而不是默认768。创建/收藏本来就是lazy列表，继续保留。
- 顶栏及快捷行按严格形变/阴影边界检查共享，重叠或缩放时保持独立。保留材质、光学shader、模糊和动画；不能声称所有布局都共享成功或已有手机FPS提升。明暗/顶部/滚动4对主机截图文字位置相同，排除改解码的喜欢封面后像素一致；Skia/Windows字形仅供布局回归，不作手机Impeller验收。
- 原生历史新增后台worker查询与窄流tombstone读取、生命周期回复清理和Dart第二次白名单。最新2条原生记录最多导出受限线程、24帧、库basename/函数/BuildId/相对PC及信号；4MiB/1秒/128线程限制，不保存原始trace，不导出完整路径/日志/寄存器/命令行/内存/账号。不新增权限或protobuf依赖；系统可能不保留trace，缺失会明确标状态。用户原有“音源诊断日志”开关保留。

用户报告已安装正式1.0.21后，重开→音乐库短滑→我的正常/快滑卡住后退出。用户24秒录屏及导出历史支持北京时间19:58:05.735、20:02:57.147、20:04:57.696为native_crash/status11。20:02记录PSS约571.44MiB/RSS约887.31MiB，另两次0为未知；原记录versionUnknown，未获新原生栈，不能直接归入之前Adreno或OOM。本轮用户明确不方便连接手机，只有本机实施授权。

下一步由用户自行覆盖候选，不先卸载；先到设置→网易云播放与同步→音源诊断日志复制新JSON，系统保留记录时可尝试取旧栈，无需先再次复现。手机方便且取得新授权后，再按视频短路线做正常/快滑/停手及跨页返回采样，并独立核验该候选APK摘要、实际退出和渲染帧；本机9项不是Android GPU或真实音乐库性能测试。具体见[安装](docs/INSTALL-v1.0.22.md)、[修改](docs/fixes-2026-10-30-v1.0.22.md)和[性能边界](docs/PERFORMANCE-2026-10-30-v1.0.22.md)。

工程D:/AnLi，beta / 8763551c0cc39c1c25f60e42fd49624f58d91a89；所有旧未提交变化和暂存区保留。26个旧冻结文件与依赖锁摘要核对未变，未提交、推送、GitHub发布或music后台操作。保留旧APK/源码、原签名和SDK；源码不含签名私钥、用户视频/原始日志、本机SDK配置，许可声明保留、SDK分享继续关闭。

Flutter3.41.9 / Dart3.11.5 / engine42d3d75、Java17，正式配置构建入口tool/build_android_release_apk.ps1默认1.0.22/code43。依赖锁SHA256为6316dd4a0989c4a89b32d2a9a82bf603203743175909b52395a2d97cc4f2b5cc。Kotlin解析可用tool/test_native_crash_trace.py在已配置Java/Gradle缓存的本机重跑，不需要设备。私有签名、截图、构建与验证脚本在被忽略的.codex-artifacts目录。

接手先只读核对最新验证与实际文件，保留冻结点。新需求依AGENTS逐题确认；无新明确授权不访问手机/ADB、真实账号或后台，不提交推送、不覆盖冻结物、不关闭保留的music网页。
