# Mesting Music 1.0.21 / code42 安装与交付

正式文件为[原签名双ARM APK](../release/Mesting-Music-v1.0.21.apk)，完整源码为[源码ZIP](../Mesting-Music-v1.0.21-source.zip)。APK与源码大小、摘要分别见[APK核验](../release/Mesting-Music-v1.0.21-verification.json)、[源码核验](../release/Mesting-Music-v1.0.21-source-verification.json)和[校验清单](../release/Mesting-Music-v1.0.21-SHA256.txt)。

正式名称Mesting Music，安装包名`com.mesting.music.beta`，1.0.21/code42，最低Android 7.0（API24），支持ARM64/ARM32设备。原证书SHA-256：`8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333`。包名/证书已与1.0.20冻结包核对，版本code从41递增42；本轮已验证原签名诊断候选覆盖安装，正式双ARM APK仍由用户自行覆盖验收。

将正式APK传到手机后直接点开安装，保留现有安装，不先卸载。若手机目前是本轮1.0.21/code42诊断候选，正式包和候选code相同，需要手动点开APK覆盖；候选不等于正式交付。正式包关闭私有诊断，不含集成测试插件或测试歌词。

重点复查连续快速切tab、从音乐库到我的、上下快滑、进入歌曲/歌单、歌手/专辑与搜索结果、胶囊展开收回、封面/歌词/队列切换。快速tab期间保留第一个与最后选择，中间请求会合并；正常过渡仍保留。原生驱动闪退在有限测试中未复现，不代表长期根治；列表滚动仍存在约20ms尾帧，不能承诺全App持续120fps。

若后续再闪退，记录时间、页面、最后操作、播放/暂停状态，保留系统退出记录。后续手机/ADB或账号排查需新的明确授权。

本轮只在本地准备，未上传music、GitHub或提交推送。源码包含许可和第三方声明，不包含原签名私钥、手机私有画面或本机SDK配置。构建环境与复测边界见[总交接](../HANDOFF-CURRENT-SESSION-2026-10-30-v1.0.21.md)和[性能记录](PERFORMANCE-2026-10-30-v1.0.21.md)。
