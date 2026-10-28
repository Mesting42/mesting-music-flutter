# 酷狗播放历史、累计时长与每日统计排查

日期：2026-10-28（Asia/Shanghai），工程根 `D:/AnLi`。本轮由用户确认排查三处统计。未访问手机、未读取当前登录凭据、未对真实账号写入播放事件或时长。

## 已核对的协议与结论

| 目标 | 现有通道 | 本轮证据与限制 |
| --- | --- | --- |
| 最近播放历史 | `/playhistory/upload` → `/playhistory/v1/upload_songs`；`/user/history` 独立读回 | 已有录音 ID、实际时间与次数上报链路，持久化 journal 区分待发送、已接收、待核对和读回确认。本轮核对公开上游与本机实现，未确认当前真实账号在官版显示新记录。 |
| 账号累计听歌时长 | `/user/grade/info` → lite v2 `get_grade_info`，读回 `d_sec` | 找到并修复基线／目标混用：发送已读回基线和本次实际新增秒数；`baseline + delta` 只用于之后核对。接口可用或返回成功不等于官版实际入账。 |
| 每日听歌统计 | CSCC 真实开始／结束事件是现有候选通道 | 已检查开始／结束、实际毫秒数、真实设备字段和状态文案。未找到能够独立保证官版日报／月报记账的已验证写入与读回通道，不能将 CSCC 收据或累计秒数变化当成日报入账证明。 |

以上是对当前开源客户端／适配器实现的核对，不是酷狗对第三方客户端同步成功的保证。此前真实对照仍见 [10 月 27 日验证记录](listening-sync-verification-2026-10-27.md)：两轮各约75秒真实播放的接口响应没有带来服务器850秒或官版14分钟的增长。

## 本轮修复

`ListeningSyncStore.claimGrade` 原已分别保存 `baseline`、`diffSec`、`target`，但 worker 调用 gateway 时传的是 `target`。例如服务器850秒、本次新增1秒，实际发出了 `d_sec=851, diff_sec=1`，与上游客户端的基线协议不符。回归先复现这一差异，再改为 `d_sec=850, diff_sec=1`；目标851秒仍保留用于独立读回核对。后续批次同样使用重新读取的基线，毫秒余数按原逻辑保留。

新增批次在 payload 标注 `kugou-lite-baseline-delta-v1`，不修改旧记录，不改变数据库结构。现有 `accepted/dispatched/unknown` 记录仍只做读回，不因为本次修复重新发送；未确认批次可能继续阻塞后续时长批次，以避免重复累计。

内部结束原因可以保留“暂停或停止”“切歌”等细节；线上 CSCC 状态统一使用上游客户端发出的“完整播放”或“中断播放”，实际播放毫秒数不变。此修正不代表服务端必然接受或给当前账号记账。

未改原生 SDK 的 appid、客户端版本、签名参数或上报来源，不通过伪造官版身份、设备信息、旧播放片段或奖励请求来尝试强制入账。旧625分钟继续完整保留在本地，不转为今天的新播放。

## 来源与复核入口

本次读取的上游 HEAD：KuGouMusicApi `5d6c9f7b180279c9dd08bc6f7159de52a856d587`；MoeKoeMusic `4cbba2619b8ca99cce0a91b864a2656590ccabf2`。开源实现之间的配置差异仍需真实对照才能确定影响，不能仅凭静态差异改变已签名原生库。

- [KuGouMusicApi：累计时长基线与增量](https://github.com/MakcRe/KuGouMusicApi/blob/5d6c9f7b180279c9dd08bc6f7159de52a856d587/module/user_grade_info.js)
- [KuGouMusicApi：播放历史上传](https://github.com/MakcRe/KuGouMusicApi/blob/5d6c9f7b180279c9dd08bc6f7159de52a856d587/module/playhistory_upload.js) 与 [历史读取](https://github.com/MakcRe/KuGouMusicApi/blob/5d6c9f7b180279c9dd08bc6f7159de52a856d587/module/user_history.js)
- [KuGouMusicApi：CSCC 开始／结束与等级响应](https://github.com/MakcRe/KuGouMusicApi/blob/5d6c9f7b180279c9dd08bc6f7159de52a856d587/module/user_listen_report.js)
- [MoeKoeMusic：先刷新基线、报告真实新增时长及结束状态](https://github.com/MoeKoeMusic/MoeKoeMusic/blob/4cbba2619b8ca99cce0a91b864a2656590ccabf2/src/stores/listenTime.js)

公开资料快照、红灯与最终回归证据位于 `.codex-artifacts/2026-10-28-followup-ui-sync/`。`red-sync-baseline.log` 捕获851／850的实际参数差异；后续以最终通过日志为准。报告不含真实账号、token、UUID或原始私有响应。

## 后续真实验收

由用户使用同一酷狗账号，在本轮修复进入新安装包后进行：

1. 先记录官版最近播放、累计时长和当天统计三处基线。
2. 在 Mesting Music 开启已有播放同步，正常播放一首具有酷狗录音身份的歌曲至少75秒，再正常暂停；本地文件、听书、暂停、缓冲、拖动进度不作为这次新增时长。
3. “刷新同步状态”仅做独立读回。分别查看官版新歌曲记录、累计秒数／分钟变化和当天统计，允许平台处理延迟；三处各自留存结果。
4. 若只见“平台已接收”而官版未变化，继续保留待核对状态，不清空 journal 或重放不确定写入。需要进一步真实请求诊断时，再由用户明确授权具体测试范围。

本机协议和持久化测试不能代替这一步；在它通过前不能对外承诺“官版播放时长与每日统计已同步”。
