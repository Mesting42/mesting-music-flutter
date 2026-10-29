# 跨电脑接续：Mesting Music 1.0.17 / code38

日期：2026-10-29。五版Git标签和正式GitHub Release已完成，所有附件SHA-256与服务端digest已核对。 远端维护入口beta，main与旧历史保留。

| 版本 / code | 标签与Release | 固定源码提交 |
| --- | --- | --- |
| 1.0.13 / 34 | [v1.0.13](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.13) | `e11c4b8fb5921a47f2a11b432f3ec83855e17c49` |
| 1.0.14 / 35 | [v1.0.14](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.14) | `f4808d68792079b03877405526c7e467bc4ee1a9` |
| 1.0.15 / 36 | [v1.0.15](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.15) | `14a48fab0a876d13ab67c2499ece0b852a19daf2` |
| 1.0.16 / 37 | [v1.0.16](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.16) | `b5e8e578ea568b9c957746098c5736840cc7eb29` |
| 1.0.17 / 38 | [v1.0.17](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.17) | `3c4e29e7e210973ab7edf5dd655ec2fd08798b2a` |

各Release保留原APK、完整原源码ZIP、APK／源码验证、逐文件来源清单、原回归记录、安装复测／修改／冻结交接、更新说明、归档说明与SHA256SUMS.txt。原产物摘要保持，不重复构建。

## 新电脑接续

```powershell
git clone --branch beta https://github.com/Mesting42/mesting-music-flutter.git Mesting-Music
cd Mesting-Music
git fetch origin --tags
git status --short --branch
git log -7 --oneline --decorate
git merge-base --is-ancestor v1.0.17 HEAD
```

先读AGENTS.md、本文、docs/SESSION-HANDOFF-2026-10-29-v1.0.17.md、docs/UX-PLAYBACK-2026-10-29-v1.0.17.md与INSTALL-v1.0.17.md，再等待用户需求。冻结文档中的未推送状态为历史时点，当前Git状态看本文和docs/version-archive/GITHUB-ARCHIVE-2026-10-29-v113-v117-verification.json。原1.0.11/1.0.12的跨电脑交接保留作历史，不用其旧“最新”覆盖本版。

## 环境、产物与边界

Flutter3.41.9 / Dart3.11.5，Java/Kotlin17，min24/target36，NDK28.2.13676358。使用仓库内SDK和pubspec.lock，不全量更新依赖；新电脑自行配置SDK路径和android/local.properties。原证书SHA-256：`8ce2203ad821ad8d38576f9ae86350d98254ac05f2cb974e773c1973b22e0333`，包名com.mesting.music.beta，显示名Mesting Music。密钥需私下转移，不能使用新电脑自动生成的密钥冒充可覆盖升级。公开版本由发布入口参数指定，共享pubspec的旧stable版本不决定Beta交付身份。

1.0.17原验证：45套1017项主机回归、普通stable搜索与更新19项、Android返回专项1项；末次音频与界面65项与主组重叠，不相加。本轮归档只复核冻结源码和产物，不把它说成新做过真机或真实账号验收。

本轮产品含个人页、返回、玻璃控件、消息／搜索、立即切歌、封面、独立下载／播放全部／离线／导出／目录入口及既有音源逐曲选择；没有新增酷狗账号音源或双平台签到。真机文件管理器、离线重启、实际账号未读、官版数据和流畅度仍由用户复测。GitHub发布与music后台独立，本轮未操作后者。

## 本机保留

D:/AnLi原beta工作区仍保留归档前HEAD deb68e4、原index与全部文件字节，不切分支、不reset／clean／stash。归档提交与标签已写入本地Git对象库，另有codex/archive-1.0.13-1.0.17引用；远端beta已指向新归档链。该本地脏工作区不能直接拉取覆盖；新电脑或新的干净目录从远端beta克隆即可接续。未经新授权不访问手机／ADB，不关闭保留的music网页，不继续桌面内存优化。

本轮验收记录见[公开附件及新克隆核验](docs/version-archive/GITHUB-ARCHIVE-2026-10-29-v113-v117-verification.json)。5版共65个附件通过GitHub公开接口回读，37个已有Release及原main／旧标签保持；从网络独立克隆并逐文件核对全部原ZIP条目，运行源码与1.0.17冻结版一致。
