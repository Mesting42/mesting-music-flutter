# Java + MySQL 测试通道

## 通道边界

| 通道 | 包名 | 更新清单 | 面向对象 |
| --- | --- | --- | --- |
| 正式稳定版 | `com.mesting.music` | `releases/android/latest.json` | 已发布的稳定用户 |
| Java + MySQL 测试版 | `com.mesting.music.javatest` | `releases/android/java-mysql-test/latest.json` | 主动安装测试包的测试者 |
| UI 实验 Beta | `com.mesting.music.beta` | `releases/android/beta/latest.json` | UI/头像实验测试 |

Java + MySQL 测试版使用独立 Android 包名，因此可与稳定版和 Beta 同时安装。它绝不写入或读取稳定版的 `releases/android/latest.json`。

## 构建与发布

当前服务仍是 HTTP 集成测试。必须使用独立的测试包，不能构建或发布为正式 Release。

```powershell
.\tool\build_android_java_mysql_test_apk.ps1 `
  -AuthApiBaseUrl 'http://106.54.124.197'

.\tool\publish_android_java_mysql_test_update.ps1 `
  -ChannelAcknowledgement JAVA_MYSQL_TEST_ONLY `
  -InputApkPath .\build\java_mysql_test_apk\Mesting-Music-Java-MySQL-Test-v1.0.38-build39.apk `
  -ReleaseNotes '验证注册、登录和找回密码'
```

先验证 APK 包名、版本、签名、下载链接、SHA-256 和 API 实机联通性，再执行发布脚本。脚本会先上传 APK 和归档清单，最后才更新本测试通道的 `latest.json`。

## 已知限制与可能影响

1. **HTTP 不安全。** 当前 API 还没有可用的正式 HTTPS 域名；不要在公共 Wi-Fi、代理网络或任何不可信网络中使用真实密码或敏感资料。
2. **它不是正式发布包。** 测试 APK 使用 Debug 构建，仅用于受控测试；稳定版用户不会收到它的更新提示。
3. **旧账户密码不能直接迁移。** CloudBase 的密码哈希不能复制到 Java/MySQL；历史用户可能需要通过邮箱/手机号找回或重新设置密码。
4. **头像跨设备尚未完成验证。** 历史 CloudBase 头像迁移尚未执行，且 `/media/` 的 HTTPS 公网访问尚未完成实机验证；头像可能只在当前设备缓存中显示，换设备、重装或好友查看时可能失败。
5. **历史社交数据不可假定完全一致。** MySQL 已导入历史数据，但双真实账号的搜索、互关、消息、状态和一起听仍需完整回归；遇到缺失或不同步应当反馈，不要把它当作数据已丢失。
6. **自定义主页背景尚未跨设备同步。** Java 后端模式下该设置主要保存于本机。
7. **播放与一起听仍缺真实场景验证。** 长时间播放、前后台/锁屏、网络切换、性能与权限隔离的完整实机回归尚未完成；弱网时可能出现房间状态或播放进度不同步。
8. **尚无自动异机灾备。** MySQL 与媒体目录目前没有完成每日异机备份和恢复演练；单台 CVM 故障可能导致服务中断或需要从最近备份恢复。

只有完成域名、ICP 备案、HTTPS、媒体公网验证、历史头像迁移、自动异机备份和双账号/真机回归后，才可以把功能合入正式稳定通道。
