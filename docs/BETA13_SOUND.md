# Beta.13 登录成功提示音

`android/app/src/main/res/raw/mesting_login_success.wav` 是本轮为 Mesting
原创合成的短提示音，不是 Apple 系统音效或从参考视频提取的声音。

音频为单声道 44,100Hz、16-bit PCM、0.48 秒。基频 1318.51Hz 与四分之一
幅度的二次谐波叠加，2ms 渐入和 120ms 指数衰减，峰值控制在满幅以内。
其素材权属和来源与第三方启动视频、音乐平台音源分开。

Android 的 `LoginSuccessSoundBridge` 独立持有一个 SoundPool，使用媒体音量、
遵循静音/振动模式、不请求音乐音频焦点。引擎解绑时释放资源。Dart 仅在新的
交互登录成功事件中调用一次；凭证恢复、刷新和重复扫码回调不播放。

主机测试只检查事件触发次数及流程，不等于已经验证真机响度、混音或音频焦点。
