# Beta.21 本地交付与接续

更新日期：2026-10-27（Asia/Shanghai）。目录 `D:/AnLi`。

## 接续第一步

先阅读本文、[修改记录](fixes-2026-10-27-beta21.md)、`AGENTS.md`、`DESIGN.md`、`PRODUCT.md`，只读核对 Git 和交付文件，再按用户的新指令继续。旧 Beta.20 会话交接和冻结交付属于历史证据；不要把旧方案重新当成待办。

`beta` 工作区包含原 Beta.20 与本轮 Beta.21 修改，均未提交。HEAD 保持 `edc6d1bf881cbe2173709cc84b86b91637fbaaed`，固定标签 `v1.0.37-beta.19`；本地 `origin/beta` 仍与 HEAD 相同，本轮没有 fetch。GitHub clone 不能得到这些尚未推送的工作区修改。源码快照包含当前文件，不包含 Git 历史、私钥、本机缓存、APK、账号报告或手机数据。

## 当前实现

已按用户确认完成队列统一视觉/拖拽/左滑、操作成功提示去勾留字、首次自动协议卡移除、滚动输入材质修复、现有功能的法律/八页指南、组合角色动效及音频输出卡内选择。用户最后补充的 `hi` 气泡与三条手指提示线默认显示，互动弹动；唱片在左、耳机在右搭肩。具体代码、边界及素材来源见修改记录。

继续保留 premium 模糊/折射/形变/回弹/胶囊开合、两张原始静态启动 PNG、七种进度天气、原奖励/账号/音频业务所有权。自动听歌时长上报保持关闭。法律联系方式由用户明确暂缓，不填写虚构地址。

## 构建环境

Flutter **3.41.9**、Dart **3.11.5**、JDK **17.0.20.1+1**、Android SDK compile/target **36**、min **24**、NDK **28.2.13676358**。共享正式版本仍为 `1.0.37+58`，Beta 脚本覆盖为 `1.0.37-beta.21` / `21`。

```powershell
# 使用新电脑的真实路径；不复制本机私钥或缓存到公开仓库。
$betaFlutter = 'D:/你的Flutter目录/flutter/bin/flutter.bat'
& $betaFlutter pub get --enforce-lockfile
& $betaFlutter analyze --no-pub
& $betaFlutter test --no-pub --flavor beta test/beta21_refinements_test.dart test/beta10_entry_test.dart
./tool/build_android_md3_beta_apk.ps1 -FlutterSdkRoot 'D:/你的Flutter目录/flutter'
```

Release 路径不能添加 `--no-pub`：测试可能留下 dev-only 原生插件注册，构建脚本依赖 Flutter 正确重建 Release 注册。依赖锁 SHA256 仍为 `3F2DC18A71A59324ADF202E8EFE43E2F712B23A16E743B772AF0EC10748B4957`。

## 本地交付位置

| 路径 | 内容 |
| --- | --- |
| `release/Mesting-Music-v1.0.37-beta.21.apk` | 新 Release APK，最终身份/签名/对齐以同名验证 JSON 为准 |
| `release/Mesting-Music-v1.0.37-beta.21-verification.json` | APK 字节、哈希、签名、双 ARM、对齐、原始 PNG 与组合角色入包核对 |
| `release/Mesting-Music-v1.0.37-beta.21.apk.sha256` | APK 外部校验值 |
| `release/Beta.21-安装说明.txt` | 本版安装与设备验证边界 |
| `Mesting-Music-beta.21-source.zip` | 当前源码/文档快照，归档完成后不再改写 |
| `docs/version-archive/beta21-evidence/test-summary.json` | 匿名、可跨电脑保存的验证摘要 |
| `.codex-artifacts/2026-10-27-beta21/` | 本机日志、打包/归档验证和独立复核，Git 忽略 |
| `.impeccable/review/beta21/` | 31 张生产组件的主机截图，Git 忽略 |

源码 ZIP 逐条核验 CRC、文件字节和 SHA256；最终哈希写在忽略目录的 `beta21-source-verification.json`，避免在 ZIP 内自引用。Beta.20 APK 与源码 ZIP 完整保留，不覆盖旧交付。

最终 APK **76,033,360 字节（72.51 MiB）**；SHA256 `46723B9F392121107DC5AF7423B7DEC8E08DCFDD77C4A86FC8B2DED0094EDBD9`。已核对真实包名/标题、版本21、Release 非调试、v2签名、双ARM、ZIP/ARM64 ELF 16KiB对齐和全部10项原生库。证书 SHA256 `8CE2203AD821AD8D38576F9AE86350D98254AC05F2CB974E773C1973B22E0333`，与 Beta.14–20 一致；原始启动图及最终组合角色图集与源字节一致，旧独立角色图集未入包。

## 验证边界

各组精确结果见便携摘要；定向组之间重叠，不把数量累加为独立覆盖。正式渠道 732 通过、113 条件跳过、2 既有失败，未宣称全量全绿。界面使用真实 Flutter 控件，账号/歌曲/路由为夹具，Windows QA 字体仅用于主机截图。独立复核只覆盖本次主机证据。

本轮未访问或安装用户手机。此前 Beta.20 已安装是历史事实，不能写成本轮 Beta.21 已安装。Android GPU、键盘/自动填充、无障碍、实际蓝牙转移、系统返回和性能均留给用户自行验收。没有真机授权时不运行 ADB、不安装、不启动或访问手机。原生性能测试只允许隔离 `.beta.benchmark` 身份，强制 `--keep-app-running`，不得对日常安装使用默认 Flutter drive。

本轮无 Git commit/tag/push/Release，无线上更新清单修改。签名私钥保持忽略、不得公开；覆盖升级需使用与 Beta.14–20 相同的证书。更换电脑时通过用户的私有途径取得原密钥，不能假设新机 debug 密钥可覆盖已有应用。
