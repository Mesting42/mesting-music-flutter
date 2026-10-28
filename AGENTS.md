# 协作约定

**新会话优先读取 [另一台电脑接续总交接](HANDOFF-CURRENT-SESSION-2026-10-28-GITHUB-CONTINUE.md)。1.0.6～1.0.10五版冻结源码已核验并准备归档提交；GitHub附件发布进行中，最终状态以Release和验收证据为准。 维护入口beta，原main和旧历史保留；旧冻结交接中的Git状态以最新归档记录为准。先只读核对，再等待用户；保留原APK／源码ZIP、签名和SDK。未经新明确授权不访问手机。**

新增Beta页面按钮遵守 [按钮公共约定](docs/BETA-CONTROL-CONVENTIONS.md)：优先使用 `BetaGlassButton`／`BetaGlassAction`，不可复制灰色禁用填充或独立按压状态；必须检查从按钮起手滚动且手指未抬起时的高亮与形变恢复。普通页面不启用 `persistPressOnDrag`。

**2026-10-28 最新维护版：1.0.9 / Android code30 已发布到 music，公开health、完整下载摘要及安装前线上更新说明读取均通过。先读 [1.0.9 接续](docs/SESSION-HANDOFF-2026-10-28-v1.0.9.md) 和 [修改](docs/fixes-2026-10-28-v1.0.9.md)。1.0.6～1.0.9 源码均未 Git 提交／推送，HEAD仍为beta / v1.0.5；保留全部工作区变化与冻结交付。手机由用户自行测试，没有新明确授权不访问手机。下方旧版本状态保留作历史。**

**2026-10-28 最新维护版：1.0.8 / Android code 29 已发布到 music。先读 [1.0.8 接续](docs/SESSION-HANDOFF-2026-10-28-v1.0.8.md) 和 [修改](docs/fixes-2026-10-28-v1.0.8.md)，以接续的最终验证状态为准。1.0.6～1.0.8 源码均未 Git 提交/推送，HEAD 仍为 beta / v1.0.5；保留全部工作区变化与冻结交付。小米14Pro性能由用户自行复测，不把本机验证视为持续120fps；没有新明确授权不操作手机。**

**2026-10-28 最新维护版：1.0.7 / Android code 28 已发布到 music。先读 [1.0.7 接续](docs/SESSION-HANDOFF-2026-10-28-v1.0.7.md) 和 [修改](docs/fixes-2026-10-28-v1.0.7.md)。1.0.6 与本轮源码尚未 Git 提交/推送，HEAD 仍为 beta / v1.0.5；必须保留全部工作区变化。**

**2026-10-28 最新维护版：1.0.6 / Android code 27 已发布到 music。先读 [1.0.6 接续](docs/SESSION-HANDOFF-2026-10-28-v1.0.6.md) 和 [修改](docs/fixes-2026-10-28-v1.0.6.md)，再参考下方旧版与清理交接。本轮源码及交接尚未 Git 提交/推送，HEAD 仍为 beta / v1.0.5；必须保留全部工作区变化。**

当遇到新需求或修复 bug 时，请在回答前先向用户提问，一次只问一个问题，根据回答继续追问，直到有 95% 的信心理解真实需求和目标，再给出最终方案。在用户确认后进行实施。

编码时写好必要注释，尽可能解耦设计，便于其他人员接手代码时快速上手。

接续前先阅读 [当前本机会话总交接](HANDOFF-CURRENT-SESSION-2026-10-28-LOCAL-CLEANUP.md)、[1.0.5 交接](docs/SESSION-HANDOFF-2026-10-28-v1.0.5.md)、[修改](docs/fixes-2026-10-28-v1.0.5.md)、[接续入口](docs/CONTINUE-BETA.md) 和 [Git/GitHub 归档](docs/version-archive/RELEASE-BACKFILL-2026-10-28.md)，核对分支、标签与工作区。本机工程根为 D:/AnLi，beta / v1.0.5 / code 26；music 后台已由用户更新到 1.0.5 / 26，公开 health 已核验，不重复发布。旧文档中的其他绝对路径和待补发状态已过时。旧 Beta 产物及 CodexCache 优先项清理已完成，签名、当前源码与共享 SDK 保留；未清理缓存不代表继续删除授权。用户已确认取得 SDK 源码公开分发授权，完整源码可用于 GitHub 接续，原 LICENSE 和第三方声明保留，SDK 分享继续关闭；不覆盖冻结交付或公开凭据、私钥、本机配置。内部 beta 名称只作安装身份兼容。此次最新交接及指针文档尚未提交/推送；先只读接手，等待用户新的更新需求。

用户已要求后续自行真机测试并断开手机；没有新的明确授权时，不访问或操作其手机。原生性能测试只使用隔离的 `.beta.benchmark` 包，并强制 `--keep-app-running`，不得对日常安装执行默认 `flutter drive`。
