# findings — task-history-recall-20261116

> 任务：新建「plans 文档体系 + git 历史 → 过往任务经验挖掘」技能（工作名 history-recall，定名待设计裁决）。
> 方法论：using-superpowers → brainstorming（本文件=①探索项目上下文的调研产出）。
> 调研执行：Explore 子代理 agent_18a10b70（2026-11-16），关键声称已经主进程盘上抽查复核（185 归档/INDEX 汇总行/kb 脚本与 KB_DIR 实测一致）。

## Requirements（用户原话转译）
- 基于现有 task-planner 文档体系（plans/ 计划档案）做调研：理解用户过往做了什么、什么成功、什么犯错。
- 结合 git 提交历史，更完整地了解此前工作，便于后期下结论。
- 用途：后期任务规划的经验/参考来源；梳理之前任务的参考。
- 用户标注方法论载体 `[$using-superpowers]`。

## Research Findings（一手事实）

### 1. plans/ 数据面（可挖掘原料）
- 顶层：INDEX.md + archive/ + ~37 活跃/专题目录；**归档任务 185 个**（`find plans/archive -maxdepth 1 -mindepth 1 -type d | wc -l`）。
- INDEX.md schema：主表列 `Task ID|Status|Phase 进度|Goal|session_id|worktree|scope_files|最后更新|待办` + 待处理/已完成/汇总分区（plans/INDEX.md:1-64）；汇总行 in_progress:1|pending:11|complete:12。
- 任务目录标准七文档：task_plan.md / findings.md / progress.md / verification.md / knowledge-brief.md / user-session-log.md / notepad-learnings.md（+ .plan-attestation、drift-checkpoint、subagent-state/、evidence/ 等按档位增减；mini 档仅 task_plan.md）。
- 高价值字段：Goal 原文、Decisions Made、Error Log（Root Cause/Prevention 两列）、VC 判据、progress 的 [goal:Gn] 证据行、user-session-log 用户逐字裁决。

### 2. git 面提交惯例
- 前缀模式：`plan()/feat()/merge()/archive()/deploy()/bookkeeping()/closeout()/fix()`，subject 括号绑定 task-id（如 `feat(task-superpowers-openspec-routing-20261116)`）→ task-id 是文档体系与 git 历史的**通用连接键**。

### 3. 既有技能覆盖面（防重复造轮子）
| 技能 | 已覆盖 | 与本任务关系 |
|------|--------|------------|
| plan-resume | 中断计划发现/可续推性判定/续推 | 只管「恢复执行」，不做经验提炼 |
| progress-tracker | 项目级跨会话账本（ledger/*.jsonl） | 只记在途/完成状态事实，无教训挖掘 |
| research-kb（全局） | 网络调研缓存（knowledge/ TTL 30 天） | 管外部资料，非任务经验 |
| session-kv（全局） | 会话内临时 KV | 重启即失，非长期 |
| task-planner 内建召回（Rule 93/84.14/80/19.3） | 执行期召回/收口回读/归档留存 | 全部是**单任务执行期**能力 |
| kb 三脚本（scripts/kb-search.sh 等） | KB_DIR=$REPO_ROOT/knowledge 的 md 检索基座 | **可复用的检索基建** |

### 4. 缺口结论
- **真实缺口**：无「跨 plans/ + plans/archive/ + git 历史」的系统性经验挖掘技能——提炼过往任务的完成模式/失败教训/可复用判据/用户偏好演变，供后续规划检索参考。
- 现有全部能力都是 per-task 或执行期的；跨任务经验层为空白。

## Technical Decisions（2026-11-16 用户裁决收口）
- D1 触发方式 = **显式调用+轻接线**（用户裁决 Q2；task-planner L1+ 规划期 1 行建议指针，不强制）。
- D2 产出形态 = **按需调研型**（用户裁决 Q1；简报+经验卡随消费方任务落盘，不做全量沉淀库）。
- D3 实施形态 = **SOP+专职子代理全家桶**（用户裁决 Q3，超出推荐档位，P0-1 从之；6 交付物清单见 design.md §3）。
- D6 命名 = 技能 `plan-history-recall` / 子代理 `history-miner`（自主裁决，对齐 plan-* 家族与 drift-checker 先例）。
- D7 范围 = `$PWD/plans/` 相对路径通用设计、本仓实测验证（自主裁决，YAGNI 不做跨仓聚合）。
- D4 成本控制 → design.md §6 护栏（≤8 候选/≤3×3 并发/简报 ≤150 行）。
- D5 与 kb 关系 → 不改 kb-search.sh；kb 体系保持 knowledge/ 域，本技能域=plans/+git（design.md §9）。

## Open Questions
- 无未决项——D1-D3 已裁决（Technical Decisions 表）+自裁 D6/D7+设计定稿（design.md）+实施契约事实（Implementation Facts 段）。

## Dogfood Routing（S7 Step 2 路由实测，2026-11-16 记录）
- 通道 A（INDEX grep worktree）：仅 2 行命中（s77-p2-fix/skill-audit-s77-fix）；INDEX 主表 Goal 列文字命中面窄（worktree 信息在专列）。
- 通道 B（git log --all --grep worktree）：命中丰富；**git subject 括号 task-id 惯例是更强路由信号**（旧结论实测再证）。
- 路由裁决：候选 3 = task-crossprojauth-20261104（Rule 100/101 worktree 规范本体）/task-v186（worktree 回合教训）/task-specmode-integration-20261115（近期 worktree merge 实践）；排除留痕（s77-p2-fix 等=worktree 仅手段非主题）。

## CR Round1 修复蒸馏（2026-11-16，critic S9 F1-F15→处置）
- F1 BLOCKER 锚越界 8/13→全量机器重取（grep -n+行号≤wc-l）重写 2 卡+简报；HPR-09 锚可解析断言新增（机器门）
- F3 基线口径三源不一→统一=5（基线对比式判据）；F4 简报路径三源统一 history-recall/history-brief.md
- F5 registry dep_anchors 改兄弟技能 ../ 形态+补 references 两锚；F7 HPR-05 去模型串钉（HPR-06 独占）；F8 参考段去源仓硬路径；F9 五文档读=分段+定向 grep+行号≤wc-l
- F6 卫星表 12→13 不做（count 钉族风险+design 批准范围外）→登记为独立技能非卫星族；F11 接线行加引号 Skill("...")；F13 sha 位数放宽 ≥7；F14 分轮合并落字；F15=HPR-09
- dogfood 经验：miner 产锚幻觉→锚必须机器重取；子代理大输出回执的行号声称=第一造假信号（与 subagent-verifier-fabricated 判例同构）
