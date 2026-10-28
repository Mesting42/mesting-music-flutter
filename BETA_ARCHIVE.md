# Mesting Music 版本归档

**2026-10-29 最新 GitHub 归档：1.0.12 / code33。** 1.0.11、1.0.12 均已有固定源码提交、标签与正式 Release，beta 维护入口为1.0.12；main 与历史版本保持。原 APK / ZIP 摘要和所有附件已核验，详见[最新跨电脑交接](HANDOFF-CURRENT-SESSION-2026-10-29-GITHUB-CONTINUE.md)与[本轮来源](docs/version-archive/RELEASE-ARCHIVE-2026-10-29-v111-v112.md)。

| 版本 | 固定标签 | Release |
| --- | --- | --- |
| 1.0.12 / 33 | [v1.0.12](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.12) | [原APK / 源码 / 校验](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.12) |
| 1.0.11 / 32 | [v1.0.11](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.11) | [原APK / 源码 / 校验](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.11) |

music 的最新只读核对已显示1.0.12/code33；归档不重复发布。下文较旧“最新／未推送／仅私有”保留各次历史状态，当前以本段和最新总交接为准。

**2026-10-28 最新归档：1.0.5 / code 26。** 1.0.3、1.0.4 从原冻结快照补齐提交、标签和 Release；1.0.5 包含本轮修复与已授权分发的 SDK 源码。见 [归档记录](docs/version-archive/RELEASE-BACKFILL-2026-10-28.md) 与 [最新交接](docs/SESSION-HANDOFF-2026-10-28-v1.0.5.md)。music 后台仍为 1.0.4 / 25，1.0.5 管理 UI 发布待完成。下文旧“未推送/仅私有”是历史时点描述。

| 版本 | 源码标签 | 交付 |
| --- | --- | --- |
| 1.0.5 / 26 | [v1.0.5](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.5) | [最新 Release](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.5) |
| 1.0.4 / 25 | [v1.0.4](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.4) | [原冻结 APK/源码](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.4) |
| 1.0.3 / 24 | [v1.0.3](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.3) | [原冻结 APK/源码](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.3) |

**当前本地交付 1.0.4 / 25**：已在 1.0.3 发布后接入 SDK 并发布现有 music 后台，完整源码以私有快照保存。尚未 commit/tag/push 或创建 GitHub Release；远端最新标签仍为下方 1.0.2。见 [1.0.4 最新交接](docs/SESSION-HANDOFF-2026-10-28-v1.0.4.md)。SDK 原许可不自动授权公开上传源码。

**新增本地交付 1.0.3 / 24**：已发布现有 music 后台，APK 与源码快照在本地冻结；尚未 commit/tag/push 或创建 GitHub Release。远端最新标签仍为下方 1.0.2。本版见 [1.0.3 交接](docs/SESSION-HANDOFF-2026-10-27-v1.0.3.md)。后续 P8P SDK 接入将使用 1.0.4 / 25，不覆盖 1.0.3 快照。

归档更新：2026-10-27（Asia/Shanghai）。已补齐 Beta.20、Beta.21、正式版 1.0.1 和 1.0.2 的源码提交、固定标签与 GitHub Release；最新正式版本为 **1.0.2 / 23**，同时已发布到 Ring Download 的 music。来源和逐文件摘要见 [本次补档记录](docs/version-archive/RELEASE-BACKFILL-2026-10-27.md)，产品变化见 [修改记录](docs/fixes-2026-10-27-v1.0.2.md)。内部 beta 名称仅用于身份兼容；各版原始 APK、源码 ZIP 与历史记录保持冻结。
日常开发分支：`beta`。另一台电脑从 [接续入口](docs/CONTINUE-BETA.md) 开始，
源码和 APK 使用同名固定版本标签。旧 `main` 分支和此前已有标签/Release 保留原样；正式 1.0.1/1.0.2 标签来自当前维护的 `beta` 代码线，不切换到旧 stable 产品界面。

## 本次补齐的 GitHub 版本

| 公开版本 | 固定源码标签 | 发布入口与属性 |
| --- | --- | --- |
| Beta.20 / code 20 | [`v1.0.37-beta.20`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.20) | [历史预发布](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.20) |
| Beta.21 / code 21 | [`v1.0.37-beta.21`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.21) | [历史预发布](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.21) |
| 1.0.1 / code 22 | [`v1.0.1`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.1) | [正式发布](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.1) |
| 1.0.2 / code 23 | [`v1.0.2`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.2) | [最新正式发布](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.2) |

以上各版均附原始 APK、原始源码 ZIP、包核验 JSON、原始源码逐条清单、安装说明、修改记录和 SHA-256 汇总。归档提交创建于本次补档，不回填旧开发时间；历史冻结文档中的“未推送”描述保留为当时状态，由本记录更新。

## 本地交付与应用内更新

1.0.2 交付 `release/Mesting-Music-v1.0.2.apk` 与 `Mesting-Music-v1.0.2-source.zip`；身份、原签名、资源、平台及主机验证边界见同目录验证 JSON 和 [原交付记录](docs/SESSION-HANDOFF-2026-10-27-v1.0.2.md)。GitHub 标签另外包含本次归档文档，原始 ZIP 不重打包。本次补档没有运行手机安装或重跑产品测试，已有验证边界不变。

当前 [music 公开下载](https://download.csnas.asia/music/download) 已返回 1.0.2 / 23，SHA256 与本地包相符；生产下载代码以模拟已安装 1.0.1 / 22 的身份完成真实 HTTPS 暂停/续传及完整摘要核验，同版本不提示新版本。主/备下载入口 HEAD 200、Range 206 及前 64 KiB 与本包匹配；未对备用入口另做全包下载。后续发布见 [操作步骤](docs/RELEASE-UPDATE-GUIDE.md)。

## Beta.1–19 版本索引

| 版本 | 固定源码标签 | 下载与核验 |
| --- | --- | --- |
| Beta.1 | [`v1.0.37-beta.1`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.1) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.1) |
| Beta.2 | [`v1.0.37-beta.2`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.2) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.2) |
| Beta.3 | [`v1.0.37-beta.3`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.3) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.3) |
| Beta.4 | [`v1.0.37-beta.4`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.4) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.4) |
| Beta.5 | [`v1.0.37-beta.5`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.5) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.5) |
| Beta.6 | [`v1.0.37-beta.6`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.6) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.6) |
| Beta.7 | [`v1.0.37-beta.7`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.7) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.7) |
| Beta.8 | [`v1.0.37-beta.8`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.8) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.8) |
| Beta.9 | [`v1.0.37-beta.9`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.9) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.9) |
| Beta.10 | [`v1.0.37-beta.10`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.10) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.10) |
| Beta.11 | [`v1.0.37-beta.11`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.11) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.11) |
| Beta.12 | [`v1.0.37-beta.12`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.12) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.12) |
| Beta.13 | [`v1.0.37-beta.13`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.13) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.13) |
| Beta.14 | [`v1.0.37-beta.14`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.14) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.14) |
| Beta.15 | [`v1.0.37-beta.15`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.15) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.15) |
| Beta.16 | [`v1.0.37-beta.16`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.16) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.16) |
| Beta.17 | [`v1.0.37-beta.17`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.17) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.17) |
| Beta.18 | [`v1.0.37-beta.18`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.18) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.18) |
| Beta.19 | [`v1.0.37-beta.19`](https://github.com/Mesting42/mesting-music-flutter/tree/v1.0.37-beta.19) | [APK、源码包与核验记录](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.19) |

Beta.14–17 延续原有 Release 附件；本轮为 Beta.1–13、18、19 补齐原始源码 ZIP、
原始 APK、SHA-256、安装说明和归档验证元数据。GitHub 标签的源码下载另外包含
版本来源说明等归档文档。

## 快照来源与历史关系

- **Beta.1–13**：从这台电脑原有交付目录找回每一版完整源码 ZIP 和 APK；原始交付
  清单的文件大小、SHA-256 全部匹配。逐条读取并核验全部源码条目，归档时没有删减
  原 ZIP 的源文件。Beta.1/2 ZIP 的 `mesting-md3-beta/` 外层目录在 Git 树中展开到根。
  这十三个版本按顺序组成补档提交链，起点为原 Beta.1 清单记载的正式基线。
  提交创建于本次归档，不伪造原开发日期。
- **Beta.14–17**：保留现有提交、标签和 Release，未把新补的 Beta.13 插入旧历史、
  未移动旧标签。原归档来源与证据范围完整保存在
  [2026-10-26 记录](docs/version-archive/BETA14-17-ARCHIVE-2026-10-26.md)。
- **Beta.18**：原冻结源码 ZIP 恢复为 Beta.17 的后继提交，新增归档来源与验证记录。
  原 APK 和原源码 ZIP 保持原字节，不重编译、不重签。
- **Beta.19**：当前完整工作区提交在 Beta.18 之后。保留交付时运行代码，补充跨电脑
  文档、版本索引、Gradle wrapper、原始源码清单及验证摘要。APK 是已交付的冻结
  Release；本次归档没有重新构建。`beta` 指向这一最新提交。

`docs/version-archive/beta.N-source-manifest.json` 记录新补版本的原始源文件路径、
字节数、SHA-256、原 ZIP 与 APK 哈希及证书。它描述冻结交付时的原始字节，
Git 的文本换行规范化和新增归档文档不冒充原 ZIP 内容。Beta.14–17 的原有清单保持。
APK 和 ZIP 通过 Release 附件分发，APK、源码 ZIP、构建缓存及私钥不进入 Git 对象。

## 另一台电脑接续

```powershell
git clone --branch beta https://github.com/Mesting42/mesting-music-flutter.git Mesting-Music-beta
cd Mesting-Music-beta
git status --short --branch
git describe --tags --exact-match HEAD
```

本次补档完成时应显示 `v1.0.2`。若以后分支已前进，固定查看本版：

```powershell
git switch -c codex/continue-v1.0.2 v1.0.2
```

已有克隆应先检查未提交修改，再 `git fetch origin --tags`；工作区干净且位于 `beta`
时使用 `git pull --ff-only origin beta`。保留另一台电脑旧工作目录，不强制覆盖。
构建环境、原签名密钥和已知限制见 [接续入口](docs/CONTINUE-BETA.md)。

## 签名与安装

本次重新验证了全部新补 APK 的 v2 签名、版本、包名、Release 非调试属性和双 ARM
架构；保留原安装包字节，不为统一证书重签历史版本。

- Beta.1–13 证书：`08C3774545B89E3A30F5D20F162A30D1B48C13C19205A5073AA945CB8360AD4F`。
- Beta.14–21 及正式 1.0.1/1.0.2 证书：`8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。

因此旧版 APK 是历史留档，不能仅凭相同包名保证跨这两个签名组覆盖安装；Android
也限制 versionCode 降级。为查看旧源码使用标签即可，无需在日常手机卸载应用。
后续覆盖升级 1.0.1/1.0.2 时，需通过私有方式转移同一原签名密钥，并提高实际版本 code。
源码仓库和 Release 均不含私钥或密码。

## 本次验证边界

Beta.19 的 287 项 Beta 主机回归通过，正式渠道 734 项通过、91 项跳过、3 项既有
失败；静态分析无问题。本次 Git 归档未修改运行代码、未重跑历史测试或操作手机。
已有真机性能/颜色证据、默认测试卸载事件和剩余限制见
[Beta.19 修复记录](docs/fixes-2026-10-27-beta19.md)。用户后续自行测试，禁止据归档
宣称稳定 120fps、CPU 问题完全解决、原数据完整保留或所有真实账号写入已验收。
