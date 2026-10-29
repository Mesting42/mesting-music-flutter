# Mesting Music 1.0.15 / Android code36 本机接续

用户已确认本地 SVIP、原生多音源补源及完整本地发布准备。工程根 D:/AnLi，beta / `deb68e4b4bad84d422085e4567d556b4441b5e48`；全部既有未提交改动保留。music 上传发布由用户操作，不访问手机/ADB，不提交或推送。

实现见 [模块、来源状态与边界](NETEASE-SOURCES-2026-10-29-v1.0.15.md)。官方 → 新音源 → BugPk，本地 SVIP 按账号及可选 UID 名单生效，个人页和会员页统一展示。保留原有玻璃、底部搜索和动画。

## 当前状态

实现、主机回归、原签名 APK 构建及实际包核验已完成；源码快照以本版相邻 source-verification JSON 为准。构建临时包不得替代最终交付，不覆盖 1.0.13/1.0.14 原包或源码 ZIP。

## 构建与接手

构建入口 `tool/build_android_release_apk.ps1 -VersionName 1.0.15 -VersionCode 36 -FlutterSdkRoot D:/CodexCache/flutter-3.41.9`。保持 Flutter3.41.9、Dart3.11.5、JDK17、target36/min24、双ARM及原证书。pubspec历史stable版本不代替实际APK版本。完整源码带授权SDK、上游许可、对应改动及测试，排除签名材料、本机配置、账号、缓存和构建物。

未经新明确授权不访问手机、读取账号或发送消息，不操作 music 后台。GD Studio、波点、YouTube 当前保留说明入口但停用；匿名单曲探测不证明全部会员曲目可用。安装覆盖、系统音频、后台、真机性能及此前消息/官版一起听双端效果仍由用户验收。原音乐网页继续保留，不继续桌面内存优化。

## 最终本机交付

准备时间 2026-10-29T15:24:40+08:00。最终 APK 为 `release/Mesting-Music-v1.0.15.apk`，104,294,015 字节，SHA-256 `60246270fa1f142515c0d6fa961cea308a70ed82d31a13c2e257c13543eb9f08`。包内 1.0.15/code36、正式名、原证书、v2/v3、双 ARM、ZIP/ELF 对齐、包内8条说明和第三方许可均核验通过。

36个文件937项主机回归、最终4文件46项及普通更新10项通过，组间重叠不相加。静态分析0问题。UI渲染21张，检查浅深色、320宽/1.5倍字及玻璃起手滚动取消。生产Range读取器从最终APK本地读取8条说明，3次、66,354字节，无网络。

匿名样本中BugPk回退到HTTPS网易CDN，仅读首1024字节；B站检索可响应但样本未通过同曲检查，酷我样本无结果；GD Studio拒绝/访问受限。没有读取真实账号、代测会员专属歌曲、访问手机或进行官版双端验收。旧冻结产物及锁文件21条记录逐字节保持。

由用户自行上传此APK，说明复制 `release/Mesting-Music-v1.0.15-release-notes.txt`，字段见 publish JSON。本轮未上传或发布，未提交或推送。源码ZIP逐文件清单和摘要见本版 source-verification JSON。
