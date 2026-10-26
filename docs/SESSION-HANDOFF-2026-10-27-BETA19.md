# Beta.19 交付接续

本次修改见 [修复与证据记录](fixes-2026-10-27-beta19.md)。用户已确认全部原需求及
静态启动页、签到页白底黑字追加项；最后明确要求后续由其自行真机测试，并断开手机。
不得继续自动访问手机、安装、重启或运行原生测试。

交付时工程：`D:/AnLi/Mesting-Music-Flutter/app-md3music-beta`，修改前 Git 基线为
`e8ac5bb23ff51787b3a881ad252b4fa9bed97677`（Beta.17）。本文件首先记录本机交付；
2026-10-27 用户追加确认完整 GitHub 归档，当前接续请读 [最新入口](CONTINUE-BETA.md)。
本版源码使用分支 `beta` / 标签 `v1.0.37-beta.19`，原 stash 与冻结 Beta.18 交付保留。

交付目录：
`C:/Users/Mest/Documents/Codex/2026-10-26/mesting-performance-review/delivery`。

正式 Release APK、签名验证 JSON 与校验文件也有同字节副本在工程 `release/`。
源码 ZIP 包含当前未提交工作、正式渠道素材源码、包装工具、回归测试与文档；不含
签名密钥、构建输出、本机路径配置或 APK。目录日期为任务开始日，文档日期为 10 月 27 日。

## 继续工作时必须知道

- 所有效果完整保留，不能再以降低 premium/自适应降级、取消回弹或平面按钮来替代修复。
- 最新有门控校验的性能证据是 `isolated-before-controlled` 与 `isolated-after-controlled`，
  数据汇总为交付 `validation/performance-comparison.json`。早期 warm/unguarded 数字不用于结论。
- 早期 `flutter drive` 默认结束清理卸载了日常 Beta，原数据保留未通过认证。此事已主动说明。
  交付 Release 随后安装成功，单次冷启动进入带昵称和真实队列的首页；不能据此倒推原数据未受影响。
- 当前真机后续验证归用户。测试专用包 `com.mesting.music.beta.benchmark` 可能仍留在设备，
  与正式交付 `com.mesting.music.beta` 分开；本次未在用户断开后继续清理设备。
- 完整原生套件的滚动/胶囊性能部分以及 30 个颜色采样有效；新增恢复页夹具当时因 scope
  复用失败。已修正夹具并做主机验证，用户停止真机后没有再跑该夹具，不能宣称整套原生全绿。
- `tool/run_beta19_native_profile.ps1` 只接受 `.benchmark` 包并强制 keep-app-running。
  若以后重新获得用户明确真机授权，仍需用工程副本准备隔离包，不能对日常安装执行默认 drive。
- Flutter SDK 为独立 `D:/flutter/mesting-beta5/flutter`，3.41.9；全局正式 SDK、PATH 和依赖锁未变。
- 原 Beta 签名密钥在工程父目录；构建输出使用本机 debug 签名，交付包另用已验证的原密钥重签。
  不要把密钥或本机签名脚本密码放入源码、日志或源码 ZIP。
- 正式渠道测试使用 `--flavor stable`，以正确加载按渠道声明的素材。三个旧失败详见修复记录。

用户自行验收重点：快速往返滑动和胶囊开合、震动/手机登录按钮颜色、签到页三个白色按钮、
静态图一及图二切换与重启记忆、小新七天气切换与重启记忆。没有认证持续 120fps 或进程 CPU
占用率下降幅度，也没有在线短信、真实签到/领取或平台账号写入验收结论。
