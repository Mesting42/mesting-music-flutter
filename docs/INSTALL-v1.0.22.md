# 1.0.22 / code43 候选安装与日志反馈

本版是用户已确认的修复候选，主机回归和原签名双ARM构建已完成；手机安装、我的页流畅度及原生闪退是否消除仍待验收。

- [原签名APK](../release/Mesting-Music-v1.0.22.apk)
- [完整源码ZIP](../Mesting-Music-v1.0.22-source.zip)
- [APK核验](../release/Mesting-Music-v1.0.22-verification.json)、[源码核验](../release/Mesting-Music-v1.0.22-source-verification.json)、[SHA256清单](../release/Mesting-Music-v1.0.22-SHA256.txt)

应用名称Mesting Music，包名com.mesting.music.beta，1.0.22/code43，最低Android 7.0（API24），双ARM。原证书SHA256为8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333，与1.0.21冻结记录一致，code42→43。身份具备覆盖条件，本轮未做物理设备覆盖验收；请直接打开APK覆盖现有安装，保留现有数据，不先卸载。

安装后先进入“设置 → 网易云播放与同步”，保留/开启“音源诊断日志”，等待几秒后点“复制 JSON 日志”。新报告在系统保留详情时带nativeTrace中的信号、受限线程名与库/函数栈，可以尝试读取已经发生的崩溃，无需先刻意再触发。旧历史仍标versionUnknown，不能把它自动算成本候选崩溃。

nativeTrace.status为available时表示读取到受限摘要；unavailable/unsupported/thread_unavailable/limit_exceeded/invalid_or_unavailable等均为明确的缺失或限制状态，不代表没有发生崩溃。系统记录可能已被覆盖，旧记录无法保证恢复。只有最新2条原生记录读取详情，其余可为not_requested。复制内容原样反馈即可。

方便时再按原视频的短路线检查：重新打开→音乐库短滑→我的正常/快速上下滑；另外检查从按钮起手滚动并停住、到歌单/专区后返回顶部、切到其他页再回我的。不要把本机测试通过或一次未闪退当作长期稳定性结论；本轮没有提供手机FPS改善数字。

完整玻璃、页面/按压动画和正式名称保持；没有新增原生权限或强制关闭渲染器。本包使用正常release配置，私有编译诊断关闭，用户可见的主动日志导出保留。未打入测试插件、测试字体或生成歌词。

未发布music/GitHub、未提交推送；由用户自行安装。源码不含签名私钥、本机SDK配置、用户视频和原始私有日志。详见[总交接](../HANDOFF-CURRENT-SESSION-2026-10-30-v1.0.22.md)、[修改](fixes-2026-10-30-v1.0.22.md)与[验证](validation-2026-10-30-v1.0.22.json)。
