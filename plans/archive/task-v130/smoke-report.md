# 冒烟测试报告 — task-v130（媒体专业执行体 + 门控接受度）

> **定位栏**: 机器档案=`/mnt/data/dev/task-planner-skill/plans/task-v130/` ｜ 仓库=`/mnt/data/dev/task-planner-skill` ｜ 被测基线=v124 merge 0a82262（agents 部署双位）+ v125 merge c38a5fc ｜ 测试时间=2026-10-04 18:20-18:45
> **复现入口**: `cd /mnt/data/dev/task-planner-skill && cat plans/task-v130/subagent-state/s1-image.md plans/task-v130/subagent-state/s2-video.md plans/task-v130/subagent-state/s3-image.md`

## 逐层结果（4 层）

| 层 | 测试项 | 判定 | 证据（原文摘） |
|----|--------|------|---------------|
| L1 可见性 | `image-generation-executor` 能否被派发 | ✅ **PASS** | S1 派发成功并返回合法 8 字段（s1-image.md）——**agent 列表已含 v124 新体**（SessionStart 重枚举） |
| L1 可见性 | `video-generation-executor` 能否被派发 | ✅ **PASS** | S2 派发成功返回 8 字段（s2-video.md） |
| L2 守卫 | image 缺输入 → HARD_BLOCK | ✅ **PASS** | S1 返回 `HARD_BLOCK: 缺任务单元清单、缺提示词（或写词材料）、缺生成参数`；零 API 调用零产物 |
| L2 守卫 | video 缺放行登记 → HARD_BLOCK | ✅ **PASS** | S2 返回 `HARD_BLOCK: 缺 G1 草稿放行登记（grep 行）+ 缺镜头清单 + 缺生成参数`；且 agent 自行 grep 全目录复核登记确实不存在（证据纪律生效）；未代用户放行 |
| L3 全链 | 单张 t2i 真实生成（核词→试水→三检→回执） | ⚠️ **BLOCKED（外部凭证）** | S3：核词/四段式英文 prompt 已完成冻结 → 调用 `agnes_api.py image` 返回 `HTTP 401 {"error":{"message":"无效的令牌"}}`；curl 复核 chat/completions 同 401；BASE_URL=api.agnes-ai.cn 已排除域名陷阱；**零浪费重抽**、未扩批、未虚构；按负结果规程上报（s3-image.md 全文） |
| L3 行为面（故障模式下） | agent 面对真实 API 故障的行为 | ✅ **PASS（正面观察）** | 先 smoke-test 后调、≥2 路诊断（脚本+curl）、零预算浪费、如实 status: failed + 精确 blocker + 解除条件——正是设计意图的故障行为 |
| L4 门控接受度 | attest/check-plan-dispatch 对新执行体类型名 | ✅ **PASS** | `attest-plan.sh plans/task-v130/task_plan.md` 零告警锁定（SHA 2a8ddab5…）；S-unit 表 Executor 列写 `image-generation-executor`/`video-generation-executor` 未被守卫拒绝（对比 v127 记录的「守卫注册表缺名误报」——本次无此现象） |

## 结论

- **行为冒烟：2/3 机制层全过**（可见性 ✅ / SOP 守卫 ✅ / 门控接受度 ✅），**1 层被外部凭证阻塞**（全链生成：Agnes API 401「无效的令牌」，属环境凭证问题，非 agent 或机制缺陷；env 中仅存 `AGNES_API_KEY` 且已被拒，无备用 token 变量）。
- **解除条件**：刷新 `AGNES_API_KEY`（或提供 `AGNES_API_TOKEN`/`APIHUB_AGNES_API_KEY` 中任一有效值）→ 全链层可复测。
- **计划任务已排**：`automation-13c74ca0-6816-41dd-9c30-759b130eb7e8`（标题「2小时后重试媒体agent全链冒烟测试（计划任务）」）——两小时后自动重跑 S3 全链；成功则本报告追加「§全链复测」段，仍 401 则记录并停止。可在 Automations 页随时编辑/删除。

## §冒烟连带发现（行为层抓到、静态 selftest 未覆盖）

| # | 发现 | 判定 | 处置 |
|---|------|------|------|
| F1 | **check-delegation 的 Phase Executor 复合字段只认 `+` 分隔**：本测试初稿用「 `image-generation-executor / video-generation-executor`」→ 合并 token 在 Handoff 表匹配失败 → `verdict=violation（unverified_delegation）` | 计划字段格式问题（非注册表缺名——两类型在 Handoff 表各自成行均在位；守卫对 `/` 分隔视为单 token） | 已修：字段改 `+` 分隔 → check-complete 全门通过（cc_rc=0）。**改进建议（deferred）**：守卫可加 `/`→`+` 归一（换道一行 sed），或计划模板明示「多执行体仅用 `+`」——交后续任务裁决（本任务为测试不扩范围） |
| F2 | Agnes 凭证 401（见 L3） | 外部环境 | 计划任务 automation-13c74ca0 复测；需用户刷新 `AGNES_API_KEY` |

## §全链复测（由计划任务写入）

**复测时间**: 2026-10-05 05:11-05:13 CST（automation-13c74ca0，前次 S3 后约 10.5h）｜ **复测执行体**: `image-generation-executor`（`subagent-state/s3b-image.md` 全文）

**结果：仍 BLOCKED——Agnes 凭证未恢复（HTTP 401「无效的令牌」）**

| 项 | 实测 |
|----|------|
| smoke-test | `HTTP 401 from /v1/chat/completions: {"error":{"code":"","message":"无效的令牌 (request id: 20261004211135816474694Y6xxt5gN)","type":"AgnesAI_error"}}`（05:11 CST） |
| curl 直证 | `HTTP_STATUS=401` 同错误体（request id: 20261004211315367795693ze4uG4gW，05:13 CST） |
| 环境事实 | `AGNES_API_KEY` 在位（len=52）；BASE_URL=api.agnes-ai.cn（正确域，非 apihub 陷阱） |
| 重试纪律 | 零多余重试（401 确定性故障；未换端点猜测、未扩批、零产物） |

**判定**：key 未刷新或刷新未生效（两 request id 相隔 2 分钟、跨 10.5h 与 S3 同错误）——**解除条件=换发有效 `AGNES_API_KEY`**；换发后由用户手动触发一次复测即可（本次计划任务为一次性，已按指令不再新建自动化）。

## §发现汇总（更新）
- F2（凭证）：**仍未解除**（2026-10-05 05:13 直证 401；需用户换发 key）
- F1（门控字段格式）：已修（Executor `+` 分隔；改进建议 deferred 待裁）
