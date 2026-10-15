---
name: media-planner
description: 媒体制作任务派发（媒体制作/视频生成/图片生成/剧集创作/单元线并行/内容要求分级）
tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# media-planner — 媒体制作任务派发

## 定位

管「媒体制作类任务的拆分轴与执行体路由」——视频/图片/剧集创作类任务的媒体轴精细拆分。

## 域边界

**管**：媒体任务派发（Rule 47——媒体轴拆分+具名执行体路由+试点先行）、单元线并行（Rule 49——单元线模型+推进三条件+不干扰边界）、内容要求权重分级（Rule 50——原子验收条目表+分级评级）。

**不管**：
- 通用派发机制（task-dispatch：Rule 21.4 并行组/22 契约/25 门控等）
- 通用执行纪律（task-discipline）
- 四文件罗盘数据流转（核心 task-planner，Rule 62）

## 卫星路由：media-planner

域=媒体制作任务派发。规则全文见 `references/critical-rules-media.md`（Rule 47,49,50）。

调用条件：涉及媒体制作/视频生成/图片生成/剧集创作类任务的媒体轴拆分（阶段×生产单元）、具名执行体路由（general-purpose 兜底禁止）、批量生成试点先行、单元线多路并行推进（推进三条件/advancement 登记）、内容要求权重分级与评级（P/E 类型×H/S 层级）时 Read 该文件。

## 规则索引

| 编号 | 标题 | 锚点 |
|------|------|------|
| 47 | 媒体制作任务派发纪律（P0） | `references/critical-rules-media.md` |
| 49 | 单元线多路并行推进（P0） | 同上 |
| 50 | 内容要求权重分级与评级（P0） | 同上 |

## 联动规则（驻核心/他卫星，非本域）

| 规则 | 所属 | 联动点 |
|------|------|--------|
| Rule 21.1b/21.4 | 核心 / task-dispatch | 拆分轴预估主判据、并行组独立性四问 |
| Rule 18.9-18.11 | task-discipline | 批量生成试点先行与失败率熔断（47.3 联动） |
| Rule 33/38 | 核心 | 验证与 QC 链（50 评级衔接） |
| Rule 86 | task-discipline | 可测问题禁问/无推荐禁上抛（47.5 自主迭代环本体） |

## 参考文档

- `references/critical-rules-media.md` — 3 条规则全文（Rule 47,49,50）
