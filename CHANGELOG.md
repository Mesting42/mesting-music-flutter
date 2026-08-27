# Changelog

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
