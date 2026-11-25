# 手机 H5、后端和设备 API

## 首版范围

手机 H5 单页包含设备状态、切屏、静音、已检查水仓、刘看山分析、兴趣与早报。用户用短时一次性配对码绑定设备。手机热点只提供网络。先按项目账号主动选择的兴趣推荐；原生知乎账号授权与可读数据范围待验证。建议 Next.js 加 PostgreSQL，前两天可用预绑模拟设备。

## 待团队锁定的 v1 合同

| 方法与路径 | 输入或输出 | 说明 |
| --- | --- | --- |
| POST /api/device/telemetry | sampledAt, temperatureC, humidityPct, lux, soilState | 每分钟一次；湿度探头缺失用 null，时间用 ISO 8601 UTC |
| GET /api/device/sync | settings, settingsVersion, pendingAction, briefVersion | 3–5 秒轮询设置，内容版本变化再拉取 |
| POST /api/device/ack | settingsVersion 或 actionId | 设备执行后确认，手机显示已执行 |
| GET /api/device/brief | version, generatedAt, cards | 设备读取最新一批 |
| GET /api/devices/:id/status | latestTelemetry, lastSeenAt, appliedSettingsVersion | 手机查看读数及同步状态 |
| PUT /api/devices/:id/settings | mode, muted, checkIntervalDays | mode 为 plant 或 brief |
| POST /api/devices/:id/actions | type: checked_water | 服务端返回 actionId，重复下发不重置计时 |
| POST /api/devices/:id/analysis | 状态、依据、手机解释、屏幕短句 | 读数过期则返回暂无最新数据 |
| GET /api/devices/:id/brief | version, generatedAt, cards | 手机可打开原文 |
| PUT /api/devices/:id/interests | topics | 用户主动选择 3–5 个主题 |

设备凭据与用户身份分开，服务端校验设备归属。设备同步只接受更高设置版本，按 actionId 去重并在应用后确认。离线设置显示待同步。一次性检查指令需结合时间和设备状态防止旧指令迟到后重复重置。真账号和知乎 Access Secret 仅放后端环境变量。

样例上报：
```json
{
  "sampledAt": "2026-11-26T02:00:00Z",
  "temperatureC": 24.1,
  "humidityPct": 56,
  "lux": 320,
  "soilState": "dry",
  "soilDryMinutes": 35
}
```

早报卡片建议字段为 title、shortTitle、summary、url。url 来源于知乎检索结果，由后端验证匹配。

## 植物分析和早报

规则先判定正常、持续偏干、暂无最新数据。偏干 30 分钟是可调原型值。把确定的读数和趋势交给知乎直答生成刘看山口吻的短句，校验长度并用固定文案兜底。无水位测量，提示检查水仓和棉绳。正常状态下保持同一句，跨天或状态变化再刷新。独立刘看山模型接口尚未确认。

兴趣主题 → 知乎搜索或热榜 → 去重 → 3–5 条标题和一句话摘要。先手动刷新，后续每日批量生成。设备本地约 20 秒轮播，手机可查看原文。断网保留最近一期和更新时间；首次无缓存显示联网后获取。花盆本地继续采样、播放动画和提示音。NVS 存设置与检查时间，文件分区存少量动画、字库和缓存早报。掉电后无网重启需重新校时，或采用带备用电池的 RTC。

知乎：https://developer.zhihu.com/
