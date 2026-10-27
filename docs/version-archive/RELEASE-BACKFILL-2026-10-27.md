# Beta.20 至正式 1.0.2：Git 与 GitHub 补档

日期：2026-10-27（Asia/Shanghai）。用户已确认分别补齐四版的源码提交、版本标签及 GitHub Release，上传原始 APK、源码 ZIP 和校验文件；Beta.20/21 为历史预发布，1.0.1/1.0.2 为正式发布，1.0.2 作为最新版。本记录更新此前交付文档中的 Git 状态，不修改其历史构建或测试事实。

## 四版对应关系

| 版本 / code | 固定标签 / Release | 原始源码 ZIP / 条目数 |
| --- | --- | --- |
| Beta.20 / 20 | [`v1.0.37-beta.20`](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.20) | `Mesting-Music-beta.20-source.zip` / 1053 |
| Beta.21 / 21 | [`v1.0.37-beta.21`](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.37-beta.21) | `Mesting-Music-beta.21-source.zip` / 1070 |
| 1.0.1 / 22 | [`v1.0.1`](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.1) | `Mesting-Music-v1.0.1-source.zip` / 1088 |
| 1.0.2 / 23 | [`v1.0.2`](https://github.com/Mesting42/mesting-music-flutter/releases/tag/v1.0.2) | `Mesting-Music-v1.0.2-source.zip` / 1156 |

提交链从原 `v1.0.37-beta.19` / `edc6d1bf881cbe2173709cc84b86b91637fbaaed` 依次前进到 Beta.20 → Beta.21 → 1.0.1 → 1.0.2。开发分支保留 `beta` 名称，正式版标签仍基于当前产品代码线。`main` 保留原提交 `eb49d72d3c73aafc50db33ba1b224559e2ca279f`，没有替换旧 stable 界面或改写旧标签/Release。

每个新 Release 附原始 APK、原始源码 ZIP、原包核验 JSON、原始源码清单、安装说明、修改记录及 `SHA256SUMS.txt`。源码标签及 GitHub 自动生成的源码包还包含本次新增归档文档，与原始冻结 ZIP 的含义不同。

## 来源与字节核验

原始源码 ZIP 的所有文件均按交付时记录逐条核验 SHA-256，再从对应冻结快照生成历史源码树；没有从当前代码猜测旧版本。归档提交在本次创建，不伪造过去的开发提交日期。源码保留原始换行；既有 Git 文件执行模式继承原基线。

逐条原始来源清单：

- `beta.20-source-manifest.json`
- `beta.21-source-manifest.json`
- `v1.0.1-source-manifest.json`
- `v1.0.2-source-manifest.json`

上述清单记录原 ZIP 条目及摘要，不将归档新增文件冒充原交付文件。前三个历史标签在各自快照上增加补档说明与截至该版的来源清单；最新 1.0.2 另外同步当前的接续入口、索引和协作提示。运行源码、素材、依赖锁、测试和构建入口保持与各版原 ZIP 一致。原始 APK 和源码 ZIP 未重编译、重签或重打包。

| 版本 | APK SHA-256 |
| --- | --- |
| Beta.20 | `F0B86C8C3FF6BE3AC0C7F88FA4572E7AB4EF118C04C7085AAA2BF6689916954D` |
| Beta.21 | `46723B9F392121107DC5AF7423B7DEC8E08DCFDD77C4A86FC8B2DED0094EDBD9` |
| 1.0.1 | `27FBC6BA1DDF98A405A322AB8B71F834ED4A9456042E5D2821B8AA15546D80D2` |
| 1.0.2 | `DF7E73F597890F3C868BF53E34E22C712A1E1D2CBD114651A2B7CBEED73F7263` |

| 版本 | 原始源码 ZIP SHA-256 |
| --- | --- |
| Beta.20 | `8B61C5E33903E3C7B7D9087BC2598B734D941E0405153534AE512F149B30DB99` |
| Beta.21 | `31C2396315F5832045F7E6943E7947DFE49DFF08AA3978ABEBA836269B45C4DD` |
| 1.0.1 | `E6C10555D5039925A6816BDEE2E2460EF0B5FF1BA33DE0DA5DFC0074738040AB` |
| 1.0.2 | `13BF5455836A319AF0ADDC8CF1C8F743817CBC3CE7C99BE8733B82099CA4387D` |

四版均重新校验 APK v2 签名、实际版本/code、包名和 Release 属性；同一包名 `com.mesting.music.beta`，证书 SHA-256 `8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`。原包核验 JSON 中 `gitCommitted/gitPushed` 为构建当时记录，随原包资料冻结，最新 Git 状态以本记录及远端标签为准。

## 本次验证边界

本次只归档既有版本，不修改产品运行行为，不访问手机、不安装、不重跑历史测试，也不更改 Ring Download 当前正式 1.0.2 或其他线上设置。沿用各版原有产品测试及未验证设备边界，不能由归档推导出真实蓝牙、实际账号或保留数据升级已验收。

Git 提交不包含 APK/ZIP、本机缓存、私钥、管理凭据、账号报告或设备原始日志。分支与四个新标签使用普通快进推送；旧标签/Release 不覆盖。Release 在附件完整上传且 GitHub 返回的大小/摘要逐一匹配后发布。

本机操作与远端回读记录位于忽略目录 `.codex-artifacts/2026-10-27-release-backfill/`；它不作为源码附件上传。跨电脑接续从 [接续入口](../CONTINUE-BETA.md) 开始，固定查看本版可在新目录使用 `v1.0.2`，不要覆盖已有未提交修改。
