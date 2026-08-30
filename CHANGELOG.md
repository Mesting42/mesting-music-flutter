# Changelog

## 1.0.37+58 - stable CloudBase release

- 修复从侧边菜单进入“我的消息”、设置、用户协议与隐私政策、免责声明时，目标页内容与推荐页短暂重叠的问题。
- 侧栏目标页改为严格单层交接：交接点之前只绘制推荐页，交接点之后只绘制目标页，整个转场不会同时合成两页内容。
- 修复透明主题下目标底层实际仍透明的问题；根导航免责声明使用完全不透明的语义底层，进入和返回均不会透出推荐页。
- 新增逐帧转场回归守卫，覆盖完整进入进度与侧栏目标路由绑定，防止后续改动重新引入同类重叠问题。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布不会写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build58`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+57 - stable CloudBase release

- 桌面歌词拖动时会限制在状态栏、导航栏与屏幕左右安全边缘内，展开或切换设置面板后也会重新校正位置，避免歌词被拖出屏幕后无法操作。
- 桌面歌词控制面板最大宽度由 368dp 小幅增加到 376dp；未锁定时显示打开的锁图标，锁定后切换为上锁图标，并提示可从灵动岛或通知中心音乐面板点击“词”解锁。
- 侧边菜单进入“我的消息”、设置、用户协议与隐私政策、免责声明时，改为在固定不透明目标底层上完成短距离滑入，避免推荐页内容在转场过程中短暂透出。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布不会写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build57`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+56 - stable CloudBase release

- 桌面歌词控制面板最大宽度由 344dp 增加到 368dp，并根据屏幕宽度保留安全边距、始终水平居中。
- 从侧边菜单进入“我的消息”、设置、用户协议与隐私政策、免责声明时，目标页改为短距离、初始可见的自然减速衔接，避免重复整页横扫造成机械感。
- 继续保留侧栏完整退出和 Android 两个合成帧的隔离保护，防止抽屉与目标页内容短暂重叠；系统关闭动画时会直接切换。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布不会写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build56`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+55 - stable CloudBase release

- 桌面歌词展开控制面板按确认设计升级为紧凑深色布局，使用正式 Mesting Logo，并重新安排锁定、关闭和播放控制。
- 新增当前歌曲收藏按钮，空心与实心爱心会随真实收藏状态同步，未登录时继续使用既有登录引导。
- 左下角设置按钮继续提供歌词字体大小和字体颜色调整，并完善触控区域、中文语义与展开状态稳定性。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布不会写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build55`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+54 - stable CloudBase release

- 冷启动恢复本机账号期间不再短暂显示未登录状态，会明确展示账号恢复进度。
- 收藏消息支持长按删除收藏，并同步清理收藏索引与快照，不影响好友会话中的原消息和媒体。
- 重新设计桌面歌词展开控制面板，使用轻量单层布局、统一工具栏与清晰矢量图标；原字体颜色设置面板保持不变。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布不会写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build54`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+53 - stable CloudBase release

- 收藏语音和视频优先复用好友会话中已经解析、验证或缓存的媒体来源，避免收藏后走一条不同且失效的播放链路。
- 临时媒体地址失效时会自动刷新地址并换源重试，语音与视频继续使用正式播放器播放真实文件。
- 修复从“我的消息”进入“收藏消息”时转场交接阈值不一致导致的页面短暂重叠。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布不会写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build53`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+52 - stable CloudBase release

- 修复收藏消息中的语音和视频无法播放的问题；播放前会刷新 CloudBase 媒体地址并准备本地缓存文件。
- 移除收藏消息页面切换时残留的空白操作位。
- 修复从“我的消息”进入“收藏消息”时两个页面内容短暂重叠的问题。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布不会写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build52`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+50 - stable CloudBase release

- 收藏消息中的语音、视频和歌曲分享现在可直接播放；历史 CloudBase 媒体链接失效时会安全地重新获取可用地址。
- 侧边菜单进入“我的消息”、设置、用户协议与隐私政策、免责声明时，统一使用与菜单一致的左侧滑入淡入效果，并继续避免页面短暂重叠。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布没有写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build50`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+46 - stable CloudBase release

- 优化好友消息引用展示、长按语音转文字操作的输入焦点，以及多选时的左侧勾选交互。
- 新增“收藏消息”入口；收藏内容可在“我的消息”右上角查看并返回原会话。
- 语音转文字保留真实识别服务接入边界，当前不会生成不准确的伪转写结果。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布没有写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build46`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+44 - stable CloudBase release

- 正式稳定包 `com.mesting.music` 发布到独立稳定更新清单 `releases/android/latest.json`。
- 修复部分在线歌曲在缓冲完成后仍显示播放中、却没有声音和播放进度的问题；失败时会直连重试并切换可用歌曲。
- 优化好友消息的语音播放、历史消息进入稳定性、歌曲添加按钮点击范围，以及深色界面的细节表现。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布没有写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build44`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+43 - stable CloudBase release

- 正式稳定包 `com.mesting.music` 已发布到独立稳定更新清单 `releases/android/latest.json`。
- 更新推荐页通勤、放松、专注和入睡场景图标，并统一适配当前主题配色。
- 更新播放器缓冲动效，精简版本状态提示、歌曲添加控件与播放列表空状态布局。
- 优化账户绑定验证底部面板、经典主题预览和免责声明转场等界面细节。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布没有写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build43`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.37+42 - stable CloudBase release

- 正式稳定包 `com.mesting.music` 已发布到独立稳定更新清单 `releases/android/latest.json`。
- 新增账号注销流程：二次确认、身份验证以及本机敏感数据清理。
- 新增《用户协议》和《隐私政策》；首次使用、注册及登录前均可单独查阅并确认。
- 优化“我的喜欢”封面和好友头像的本地持久缓存与失败重试，减少切换页面后才显示图片的情况。
- 优化消息页、头像预览页和编辑资料返回“我的”页面的过渡动画。
- Java + MySQL 测试包与 UI Beta 通道保持独立，本次稳定发布没有写入它们的更新清单。

对应源码标签：`flutter-music-v1.0.37-build42`。发布与源码对应关系见 [docs/release-history.md](docs/release-history.md)。

## 1.0.38+39 - source snapshot

- 公开当前 Flutter 客户端源码，并从该版本起重新建立源码、版本与标签的对应关系。
- 加入 Java/MySQL 账号服务客户端接入路径、完整播放内核、账号社交和数据同步代码。
- 修复手机号表单校验读取旧值、注册协议阅读与同意状态混用、搜索联想漏掉用户结果的问题。
- 更新社交轮询与品牌色回归测试，使测试与当前节流、通知和视觉规则一致。

该版本为迁移测试源码，不替代 `1.0.37+38` 公开稳定 APK。

## 1.0.37+38 - stable APK

- Android 稳定版 APK 已发布到 GitHub Releases。
- 当时完整开发目录未纳入 Git，因此旧标签中的公开基线不是 APK 的逐文件源码快照。
- 保留旧标签以避免改写既有发布历史。
