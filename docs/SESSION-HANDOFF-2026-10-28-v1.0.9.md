# Mesting Music 1.0.9 接续

日期：2026-10-28（Asia/Shanghai）。工程根 `D:/AnLi`。

用户已要求发布到 music，并确认 **1.0.9 / Android code30**。当前状态：**已发布，后台、公开health、完整下载SHA-256及安装前线上更新说明读取均通过。** 完整接续入口为 [当前会话接续](../HANDOFF-CURRENT-SESSION-2026-10-28-v1.0.9.md)，历史业务范围和待验证事项按其中1.0.6～1.0.8背景链接继续保留。

修改见 [本版修改](fixes-2026-10-28-v1.0.9.md) 与 [源码修复记录](fixes-2026-10-28-search-menu-fm.md)。

## 已有验证

- 14 项新增专项与 53 项完整壳层回归通过，含搜索实际输入、两主题／窄屏大字号／宽屏、返回、页面覆盖、FM 首屏与分页、菜单分离及反向。
- 32 项本轮更新与下载链路检查通过，日志 `.codex-artifacts/2026-10-28-release109/update-regression.log`。
- 发布前最终静态分析无问题，日志 `analyze-final.log`；原Flutter3.41.9／Dart3.11.5／JDK17，进程局部Gradle3GB heap／2 workers，正常pub构建约399.7秒，依赖锁未漂移。
- 原 1.0.8 APK、源码 ZIP 和依赖锁在发布准备前再次核验均未变；本次不覆盖旧交付。

## 安装包与公开结果

交付APK `D:/AnLi/release/Mesting-Music-v1.0.9.apk`，100,265,367字节，SHA-256 `87B7D4825B102F1C3A96EB977CE7FB18D8ED7041079D713CEE6AE3A752244FA2`。包名 `com.mesting.music.beta`，原证书SHA-256 `8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`，依赖锁SHA-256 `FDE25643DA671EF68397B59A3BB38E4AD5F664075E2D0414EBADABB9DC2DF2EF`。

min24／target36、ARM32／ARM64、release非debuggable、ZIP CRC、ZIP与六个ARM64 ELF的16KiB对齐通过；69项正式渠道资源、IntegrationTestPlugin、QA字体和测试shader未入包，Ring／WebRTC保留。随包说明与内置四条说明均为1.0.9。

原登录后台候选校验完整摘要、包名和code30一致后发布，后台当前公开版本1.0.9。上传581.8秒，发布结果截图 `.codex-artifacts/2026-10-28-release109/music-published.png`。公开health及 [主下载入口](https://download.csnas.asia/music/download) 的完整下载均为100,265,367字节、同一SHA-256，证据 `public-health.json`、`full-download-verification.json`、`public-verification.json`。

生产 `PublicApkReleaseNotes` 绕过内置历史，对线上目标APK实际执行Range、ETag、ZIP与CRC读取，四条中文说明与本机目标说明完全一致。证据 `live-notes.log/json`，不能代替真实设备更新按钮或安装验收。

源码交付 `D:/AnLi/Mesting-Music-v1.0.9-source.zip`，由当前最终文档、源码、测试及原授权SDK源／许可证生成，排除私钥、凭据、本机配置和构建缓存。整包校验见本轮证据目录 `source-verification.json`；逐文件摘要在ZIP内 `SOURCE-SNAPSHOT.json`，最终统一核对为 `validation-summary.json`。不覆盖1.0.6～1.0.8任何冻结交付。

## 安装与工作区边界

安装包保持 `com.mesting.music.beta`、Mesting Music 显示名及原签名证书。只向 music 上传可公开分发的 APK，不上传源码、私钥、凭据或本机配置。

分支 `beta`，HEAD 仍为 `dbc5e78d05570c26f56fe5c5773245737a464a5f`（v1.0.5）。1.0.6～1.0.9 工作区源码未 Git 提交／推送；保留全部改动、未跟踪文件与冻结交付，不 reset／clean／stash，不自动 add／commit／push／tag。

本轮发布授权不包含手机操作。用户自行测试，未经新的明确授权不得访问／枚举／安装／启动／读取手机。真实设备的更新按钮、覆盖升级、键盘与最终玻璃效果仍待用户验收；先前账号、一起听、听书、本地导入及实际时长入账待验证边界继续有效。
