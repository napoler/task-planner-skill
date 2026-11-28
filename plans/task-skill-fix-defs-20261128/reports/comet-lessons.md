# comet 借鉴清单（CO-1）

## comet 家族机制盘点（≤15 行）
- **入口精简度**：`/comet` 只做 workflow resolve+单入口加载，禁止按任务大小/活跃 change 改选；返回 schema 固定校验、失败即停不猜测（`/home/terry/.zcode/skills/comet/SKILL.md:13-31`）。
- **模板/协议驱动**：Classic 以 `.comet.yaml` 字段+状态机 transition/guard 为唯一推进面；`build_pause/subagent_dispatch/review_mode` 等 machine-owned 约束由 guard+transition 双拦截（`/home/terry/.zcode/skills/comet-classic/reference/comet-yaml-fields.md:48-79,108-117`；`/home/terry/.zcode/skills/comet-classic/SKILL.md:136-151`）。
- **证据绑定**：eval/readiness 只认当前 draft hash 的 evidence，旧 hash 仅审计不可推进；review/readiness 读同一 `workflow-protocol.json`（`/home/terry/.zcode/skills/comet-any/reference/eval-provider.md:17-25,46`）。Verify 还要求真实运行命令记录证据，绕过标记不算证据（`/home/terry/.zcode/skills/comet-verify/SKILL.md:116-124`）。
- **verdict/失败闭环**：verify_failures 机器计数；前3次可修复失败自动回 build，第4次才升级用户策略；CRITICAL/IMPORTANT 不可豁免，偏差接受需显式记录（`/home/terry/.zcode/skills/comet-verify/SKILL.md:64-81`；`/home/terry/.zcode/skills/comet-classic/SKILL.md:145-148`）。
- **backlog/恢复管理**：磁盘状态为准，`state check --recover` 结构化恢复；Ambient Resume 四态 `auto_resume/ask_user/out_of_scope/none` 只读探针；dirty worktree 归因三分类且不自动推进 phase（`/home/terry/.zcode/skills/comet-classic/reference/context-recovery.md:9-25,63-75`；`/home/terry/.zcode/skills/comet-classic/SKILL.md:63-76`；`/home/terry/.zcode/skills/comet-classic/reference/dirty-worktree.md:19-45`）。

## 可移植借鉴（≥6）
| 模式名 | comet 怎么做 | task-planner 现状 | 移植建议 | 成本 |
|---|---|---|---|---|
| 决策四分类阻塞协议 | 决策点分用户决策/自动/停止/手动衔接；≥2合法选项才建用户门；推荐值不得替代确认；未确认不写状态不推进（`/home/terry/.zcode/skills/comet-classic/reference/decision-point.md:9-44`） | 有 G1-G12/AskUserQuestion 文本约束，但缺统一四分类机判与“自动处理不伪造确认”清单化门（`/mnt/data/dev/task-planner-skill/plans/task-comet-trust-learning-20261127/findings.md:30`） | 在 critical-rules/决策门补“四分类判定+自动处理白名单”模板；check-complete 前扫描 `[blocking]`/未决决策标记 | S |
| 证据 draft-hash 绑定面扩展 | eval evidence 绑定当前 draft hash，旧 hash 审计保留但不推进 ready（`/home/terry/.zcode/skills/comet-any/reference/eval-provider.md:17-25`） | 已有 `evidence_binding` path+sha256+version+recorded_at 当前条目校验（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-evidence-binding.sh:15-36`） | 将 VC/verify 关键产物写入 evidence_binding 作为默认流程（planctl/render/check-complete 消费），覆盖“文档改了但旧证据沿用”场景 | M |
| 验收失败计数止损 | `verify_failures` 机器维护；前3次自动 verify-fail 回 build，第4次强制策略决策，CRITICAL/IMPORTANT 不可豁免（`/home/terry/.zcode/skills/comet-verify/SKILL.md:64-81`；`/home/terry/.zcode/skills/comet-classic/reference/comet-yaml-fields.md:55`） | 有 verdict 三态与 BLOCKED confirmed 门，但缺跨轮失败计数/自动止损状态字段（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-verdict.sh:19-39`） | 在 plan-state 增 `verify_failures`/`last_verify_outcome`，check-complete/check-verdict 消费；超阈值要求用户策略决策 | M |
| 只读恢复探针四态 | Ambient Resume 返回 `auto_resume/ask_user/out_of_scope/none`，只读、不建计划不猜（`/home/terry/.zcode/skills/comet-classic/reference/context-recovery.md:17-25`；`/home/terry/.zcode/skills/comet-classic/SKILL.md:63-76`） | SessionStart/Rule 119 已有 inflight 探针与恢复提醒，但 verdict 语义不如四态显式（`/mnt/data/dev/task-planner-skill/plans/task-comet-trust-learning-20261127/findings.md:35`） | 统一恢复探针输出四态 JSON/文本契约；歧义候选仅 `ask_user`，禁止自动选 plan | M |
| Dirty worktree 归因闸门 | dirty diff 分“属于当前/不属于/不确定”三类；不确定即停；dirty 不自动推进状态（`/home/terry/.zcode/skills/comet-classic/reference/dirty-worktree.md:19-45`） | 有 worktree/scope 门，但缺“归因分类后再推进”的显式恢复协议与证据字段（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-scope.sh:1-40`） | 在恢复/执行前加 dirty-worktree 分类检查清单；不确定归因阻断 complete，记录归因证据 | S |
| Output Schema/Node 责任绑定 | comet-any 要求 Output Schema 挂到具体 Node 才生效；脚本/eval/readiness 只读 protocol，不信 Skill 名称（`/home/terry/.zcode/skills/comet-any/SKILL.md:27-30,101-112`） | task-planner 有 VC/模板门，但跨阶段产物“谁产出/谁消费/何时阻断”分散在规则文本（`/mnt/data/dev/task-planner-skill/plans/task-comet-trust-learning-20261127/task_plan.md:167-188`） | 为关键 phase/gate 定义最小产物 schema 契约（字段+producer+consumer gate），先覆盖 verify/evidence 场景 | L |

## 已在位不需移植（防重复造轮子）
- **证据当前版本绑定门已在位**：`check-evidence-binding.sh` 已按同 path 的 `recorded_at/version` 选当前条目，旧 hash 返回 rc1（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-evidence-binding.sh:22-36`）；trust-learning 计划已记录该 P0 修复与复审（`/mnt/data/dev/task-planner-skill/plans/task-comet-trust-learning-20261127/findings.md:38-40`）。
- **三态 verdict + BLOCKED 确认门已在位**：`check-verdict.sh` 跳过模板字面行取末条真实 outcome，BLOCKED 无 confirmed:true 拒绝（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-verdict.sh:19-39`）。
- **用户门 blocking 账本消费已在位**：`check-complete.sh` 对 `decisions[].blocking && !confirmed` 直接 FAIL，缺字段存量兼容放行（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh:20,58-81`）。

## 消费建议
- **本轮 S2-S4 修复**：优先吃“决策四分类阻塞协议”（S，补规则/检查模板）+“Dirty worktree 归因闸门”（S，补恢复前归因检查）；若 S2-S4 涉及验收链路，再接“证据 draft-hash 绑定面扩展”（M，只扩消费不改底座）。
- **登记 backlog**：`verify_failures` 止损计数（M，需 plan-state 字段+门消费+selftest）；恢复探针四态结构化 verdict（M，需 SessionStart/恢复协议统一）；Output Schema/Node 责任绑定（L，需跨 phase 契约设计，避免平行状态源）。
