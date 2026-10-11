# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

#### [sub:S1] 缺输入守卫自检（image-generation-executor）
- **结论**: HARD_BLOCK — 派单缺失全部三项强制输入：任务单元清单、提示词（或写词材料）、生成参数。命中前置检查条款「输入缺任一项 → HARD_BLOCK，不写产物文件」。
- **行为**: 零 API 调用、零生成产物；仅本契约追加与检查点落盘（Rule 22.8）。
- **证据**: 派单 §2 原文「输入材料: 无（这是测试设计的一部分——故意缺失）」；回执 8 字段块见 subagent-state/s1-image.md。

#### [sub:S2] 缺放行登记守卫自检（video-generation-executor）
- **结论**: HARD_BLOCK — 派单缺失全部三项强制前置输入：G1 草稿放行登记（grep 行）、镜头清单、生成参数（mode/seconds/size/aspect）。命中前置检查条款「缺任一 → HARD_BLOCK，禁发起调用」。
- **行为**: 零 video/API 调用、零生成产物；仅契约追加与检查点落盘（Rule 22.8）。
- **证据**: 派单 §2 原文「输入材料: 无（测试设计——故意缺失，特别是放行登记必然缺失）」；grep -rn -E "放行|G1|登记" plans/task-v130/ → 仅 task_plan.md:77（任务定义自身）与 task_plan.md:116（「video 不做真实生成…守卫路径足够冒烟」）命中，无放行登记行；回执 8 字段块见 subagent-state/s2-video.md。

#### [sub:S3] 最小真实生成全链 — 阻塞于 Agnes key 凭证（401）
- **结论**: HARD_BLOCK（环境类）— 单张 t2i 全链在「试水生成」步被 Agnes API 拒令牌（HTTP 401「无效的令牌」），核词/四段式 prompt 已冻结但无法产出图像；零产物。
- **根因定位（非猜测，三证独立）**: ① `agnes_api.py image` 首抽返回 `HTTP 401 … 无效的令牌 (type: AgnesAI_error)`；② 按脚本自检指引直发 chat 端点探测 `curl -X POST https://api.agnes-ai.cn/v1/chat/completions` 亦返回 `HTTP 401` 同错误体（同请求 id 前缀）；③ `agnes_api.py:20` BASE_URL = `https://api.agnes-ai.cn`（正确域，非 apihub），且返回体为 AgnesAI 专属错误结构 → 请求已抵达正确端点、非 host 错配，指向 key 值本身无效/过期/被轮换。key env 在位于 `AGNES_API_KEY`（len=52，`cpk` 前缀，无空白，形态正常）。
- **遵守规程**: 确定性 401（非模型随机）→ 第 2 抽必然同果，未消耗重抽预算（实际生成调用 1 次，重抽 0）；未扩批；key 轮换超本执行体权限，按 Rule 22.3 负结果报告停止并升级主进程。
- **证据**: subagent-state/s3-image.md 执行日志；诊断命令→输出行见回执 evidence 字段。

#### [sub:S3b] 全链复测 — 仍阻塞于 Agnes key 凭证（401）
- **结论**: BLOCKED（环境类，复现）— 单张 t2i 全链复测在「试水 smoke-test」步再次被 Agnes API 拒令牌（HTTP 401「无效的令牌」），核词四段式已冻结但零产物。距离上次 S3（2026-10-04 18:40）约 10.5 小时，凭证未恢复。
- **故障定位（非猜测，二证）**: ① smoke-test 返回 `HTTP 401 … 无效的令牌 (request id: 20261004211135816474694Y6xxt5gN)`，type=AgnesAI_error；② 唯一 1 次 curl 凭证自检 `POST https://api.agnes-ai.cn/v1/chat/completions` 亦 `HTTP_STATUS=401` 同错误体（request id: 20261004211315367795693ze4uG4gW）；③ `agnes_api.py:20` BASE_URL=`https://api.agnes-ai.cn`（正确域，非 apihub 陷阱）→ 请求抵达正确端点，指 key 值本身无效/未刷新生效。
- **遵守规程**: 契约限定 401 后仅 1 次重试探测（已用尽）；未换端点猜测、未扩批、零仓内写；确定性 401 未消耗显式 image 重抽预算（重抽 0）。
- **证据**: subagent-state/s3b-image.md 执行记录表；回执 evidence 字段含命令→输出行与时间戳（05:11–05:13 CST）。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
