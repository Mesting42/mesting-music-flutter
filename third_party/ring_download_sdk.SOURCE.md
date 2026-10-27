# Ring Download SDK 来源

- 固定版本：1.1.0（P8P 正式 SDK）。
- 原始包：https://download.csnas.asia/static/ring-download-sdk-1.1.0.zip
- ZIP 字节：499322。
- ZIP SHA-256：0edc03178bf446d19947643d59021d46362e24a4b3c8e5a1807c9e85dd4bc7ef。
- 本次 Music 基线：95d5719829a754978ba615a873aa6ddff08f67f6。
- SDK 归档内文件逐一与解压源码核对，详细结果见交接包 evidence/sdk-source-integrity.json。
- 保留原 LICENSE 和 third_party 声明；未将其重新声明为 Music 仓库的开源许可。
- SDK 示例、内部测试和兼容代码随原包保留；Music 生产只引用其公开 ring_download_sdk.dart。
- 本目录无需在 App 启动时从任何网站下载，开发者使用本地 path 依赖编译。

## Music 1.0.4 本机兼容说明

宿主保留独立 Flutter 3.41.9 / Dart 3.11.5，按 SDK 声明的最低约束重新解析并冻结宿主依赖锁，不套用交接主机 Flutter 3.47.7 的固定测试依赖。SDK 196 个原始文件中，仅 `lib/src/core/services/app_upgrade_v40_download_client.dart` 删除了一处已由前序空值断言和流程提升证明不为 null 的重复 `!`，消除宿主分析器的 `unnecessary_non_null_assertion`；没有改变分片、恢复或传输策略。原始 ZIP 及其摘要保持冻结，验证清单分别记录原始与本地摘要，不能称修改后目录 196 项均与原包字节一致。

SDK LICENSE 保留原权利说明，本地集成不代表授权将其源码公开推送至 GitHub。

另修正 SDK 的 `test/sdk_contract_test.dart` 元数据夹具：先核对包名，再定位 SDK 自身的 `pubspec.yaml`，兼容 SDK 目录和 Music 根目录两个测试入口，不误读宿主版本。断言及生产传输代码不受此测试路径修正影响；196 项中其余 194 项与原包一致。
