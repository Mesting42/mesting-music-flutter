/// Bundled release notes belong to their exact public version. They work
/// offline and must never be shown as the notes of an unknown future build.
/// The distribution service may also supply notes for a newer release.
const musicReleaseNotes = <String, List<String>>{
  '1.0.5': [
    '统一移除歌曲标题末尾的音频文件后缀，保留原歌曲与文件身份。',
    '修复定时关闭浅色主题，以及资料、MV 等页面滚动时玻璃控件背景变灰。',
    '播放器更多菜单折叠封面样式，移除重复歌词入口，统一输出设备图标尺寸。',
    'MV 全屏切换横屏，退出恢复竖屏与原页面，保留播放进度并加入进出过渡。',
    '音效目录采用统一主题图标，胶囊与输入框长按菜单加入液态分离、融合过渡。',
    '优化页面与底栏收展过渡，保留完整玻璃光学、胶囊效果及 6dp 均衡圆点。',
  ],
  '1.0.4': [
    '接入 Ring Download SDK 1.1.0，更新下载支持 HTTPS 与可用节点的 P2P/P8P 辅助传输。',
    '保留下载暂停、续传和安装前完整性校验，旧版未完成的下载仍可继续。',
    '用户端文件上传分享保持关闭，音乐播放沿用原有播放链路。',
    '保留 1.0.3 的个人资料、均衡器、音效、MV、定时关闭及按钮适配修复。',
  ],
  '1.0.3': [
    '修复禁用按钮在浅色、深色模式下的文字与背景对比，关闭触感后仍能看清“体验触感”。',
    '版本更新新增“查看此次更新”，可随时查看当前版本的更新说明。',
    '新增酷狗个人资料编辑：头像、昵称、性别、生日、个性签名和省市地区选择。',
    '新增均衡器与音效目录，实际作用于音乐播放，并保存预设及自定义频段。',
    '新增歌曲 MV 播放，进入时暂停音乐，返回时按进入前的播放状态恢复。',
    '新增定时关闭，支持倒计时或播完当前歌曲后停止播放。',
  ],
  '1.0.2': [
    '首页新增猜你喜欢、新歌首发、热门榜单、新碟、主题及场景音乐。',
    '输出设备卡片支持选择本机和已连接的媒体输出设备，统一耳机图标。',
    '调整当前版本信息布局，装扮入口统一放在设置中。',
  ],
  '1.0.1': [
    '以 Mesting Music 正式版发布，保留既有安装身份与升级兼容性。',
    '接入版本检查、HTTPS 更新下载和系统安装授权流程。',
  ],
};

List<String> notesForMusicVersion(String version) =>
    musicReleaseNotes[version.trim().replaceFirst(RegExp(r'^v'), '')] ??
    const [];
