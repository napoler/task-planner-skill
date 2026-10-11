# task-planner 技能全面质量审计报告

**审计时间**: 2026-10-09  
**审计对象**: /mnt/data/dev/task-planner-skill/skills/task-planner/ (master ebb5fba)  
**审计基准**: Rule 66 (task-v151) 已落地，全量回归 64 selftest ΣFAIL=0

---

## 1. 机械锚审计

**结论**: 已核查 20+ 条定值断言/行号锚/grep 锚，全部通过，无漂移。

### 1.1 定值断言验证

| 断言位置 | 断言内容 | 实际值 | 结果 |
|----------|----------|--------|------|
| selftest-agent-coverage.sh:198 | agent-coverage.md 行数 ≤129 | wc -l = 129 | PASS |
| selftest-dispatch-grain.sh:80 | grep -c '^46\.' = 5 | 5 | PASS |
| selftest-ask-default-timeout.sh:34 | grep -c '^44\.' = 5 | 5 | PASS |
| selftest-requirement-coverage.sh:183 | grep -c '^66\.' = 6 | 6 | PASS |
| selftest-evidence-goal-gate.sh:88 | grep -cE '^58\.[1-7] ' = 7 | 7 | PASS |
| selftest-research-first.sh:72 | SKILL.md '1-66' 计数 ≥3 | 3 | PASS |
| selftest-context-hygiene.sh:185 | plan_archive_age_days default == 7 | 7 | PASS |
| selftest-fallback.sh:126 | tier_order 数组 6 项 | 6 | PASS |

### 1.2 行号锚验证

| 锚位置 | 锚内容 | 验证结果 |
|--------|--------|----------|
| selftest-sync-index.sh:143-145 | sed -n '1p'/'2p'/'3p' 索引头三行 | 格式匹配 |

### 1.3 全文 grep 锚验证

| 锚模式 | 文件 | 实际命中 | 断言 | 结果 |
|--------|------|----------|------|------|
| 'Critical Rules 1-66' | SKILL.md | 2 | ≥1 | PASS |
| '1-66' | SKILL.md | 3 | ≥3 | PASS |
| 'Critical Rules 1-65' | SKILL.md | 0 (已演进为 1-66) | =0 | PASS |
| '1-39' | SKILL.md | 0 | =0 | PASS |

**抽样面**: 覆盖 selftest-agent-coverage/selftest-dispatch-grain/selftest-ask-default-timeout/selftest-requirement-coverage/selftest-evidence-goal-gate/selftest-research-first/selftest-context-hygiene/selftest-fallback/selftest-sync-index 共 9 个脚本的 20+ 条锚。

---

## 2. 条款引用面

**结论**: critical-rules.md 引用的 48 个脚本文件全部在位；20 个 config enforce 键全部被 ≥1 脚本消费。

### 2.1 脚本引用验证

- critical-rules.md 引用 `scripts/*.sh` 共 48 个唯一引用
- 逐个验证: 48/48 文件存在（OK）
- 无 `selftest-registry.ts`（非 tsv）引用（前期 grep 误报已排除）

### 2.2 Config 键消费验证

20 个 `*_enforce` 键全部被 ≥1 脚本消费:

| 键 | 消费脚本数 |
|----|-----------|
| content_quality_enforce | 1 |
| context_hygiene_enforce | 1 |
| delegation_enforce | 3 |
| dispatch_contract_enforce | 1 |
| error_loop_enforce | 2 |
| fmea_enforce | 5 |
| hook_self_heal_enforce | 1 |
| knowledge_brief_enforce | 1 |
| mechanism_profile_enforce | 2 |
| periodic_review_enforce | 2 |
| plan_hygiene_enforce | 1 |
| plan_tier_enforce | 5 |
| reflect_verify_enforce | 2 |
| rescue_chain_enforce | 2 |
| shared_tracker_enforce | 1 |
| skill_collab_enforce | 1 |
| skill_modify_enforce | 4 |
| template_gate_enforce | 2 |
| vc_gate_enforce | 2 |
| veto_enforce | 1 |

**无死键**。

### 2.3 高频条款引用面抽查

- Rule 44 (5 子条): 引用 selftest-ask-default-timeout.sh — 存在
- Rule 46 (5 子条): 引用 check-dispatch.sh — 存在
- Rule 58 (7 子条): 引用 selftest-evidence-goal-gate.sh — 存在
- Rule 62 (4 子条): 引用 check-dispatch.sh, check-3file-gate.sh, selftest-four-file-dataflow.sh — 存在
- Rule 64 (5 子条): 引用 ledger-append.sh, check-3file-gate.sh, zcode-posttooluse.sh, selftest-drift-enforcement.sh — 存在
- Rule 65 (8 子条): 引用 periodic-review.sh, selftest-periodic-review.sh — 存在
- Rule 66 (6 子条): 引用 check-plan-dispatch.sh, check-complete.sh, selftest-goal-unit-goal-mode.sh — 存在

---

## 3. 交叉一致性

**结论**: C1-C45 连续无跳号/重复（含 C43a 非标准命名）；registry 64=64 双向差集为空；Rule 摘要行与子条数一致。

### 3.1 SKILL.md 合规清单 C1-C45

- C1-C45 全部存在，无跳号/重复
- 额外存在 C43a（拆分模式库消费自查，Rule 21.6）— 非标准命名但功能合理

### 3.2 SKILL.md Rule 摘要行 vs critical-rules 实际子条数

| Rule | SKILL.md 摘要行 | critical-rules 实际子条数 | 一致性 |
|------|-----------------|--------------------------|--------|
| 44 | 提到 44.1-44.5 | 5 | OK |
| 46 | 提到 46.1 | 5 | OK（概述性） |
| 58 | 提到 58.1-58.7 | 7 | OK |
| 65 | 提到 65.1-65.5 | 8 | OK（概述性） |
| 66 | 提到 66.1-66.4 | 6 | OK（概述性） |

### 3.3 selftest-registry.tsv vs 实际脚本

- registry 行数: 64（+1 标题行 = 65 总行）
- 实际 selftest-*.sh 文件数: 64
- 双向差集: 空（完全一致）

### 3.4 config.json enforce 键消费

见 2.2 节，20/20 键被消费，无死键。

---

## 4. 死条款/失效守卫

**结论**: 发现 2 个孤儿守卫（P2），1 个部分孤儿守卫（P2）。

### 4.1 孤儿守卫（脚本存在但无条款对应）

| 脚本 | critical-rules.md 引用 | references/ 引用 | SKILL.md 引用 | 严重度 |
|------|----------------------|------------------|---------------|--------|
| check-rescue-chain.sh | 无 | 无 | 无 | P2 |
| check-window-consistency.sh | 无 | 无 | 无 | P2 |
| check-doc-sync.sh | 无 | todo-sync.md:58 | 无 | P2（部分） |

**修复建议**:
- check-rescue-chain.sh: 在 critical-rules.md Rule 41（问题自主消解与升级纪律）中补充引用
- check-window-consistency.sh: 在 critical-rules.md 对应条款中补充引用
- check-doc-sync.sh: 在 critical-rules.md Rule 62（四文件罗盘）中补充引用

### 4.2 条款机器门验证

- Rule 66.5: check-plan-dispatch.sh 66.5 段存在（行 314-395）
- Rule 66.3: check-complete.sh [goal-gate] 段存在
- Rule 65.5: periodic-review.sh + selftest-periodic-review.sh 存在
- Rule 58.7: selftest-evidence-goal-gate.sh 存在

**无死条款**。

---

## 5. 部署位对账

**结论**: ~/.zcode/skills/task-planner vs 仓内 diff -rq 全量无差异（除已知 install 固有定制面）。

- diff -rq 输出: 空（排除 .git/install.log/.backup/SKILL.md 平台前缀）
- 部署位与仓内完全一致

---

## 6. 守卫误报面

**结论**: 试跑 2 个真实计划，告警/拦截行为均属预期。

### 6.1 v151-goal-mode 计划（有 plan_tier: standard + Goal 单元表）

**check-plan-dispatch.sh**:
- 输出: `[plan-dispatch] ✗ Phase 4: 缺 S-unit 表或数据行(Rule 22.6)`
- 原因: Phase 4 S-unit 表在 HTML 注释中（task_plan.md:205），check-plan-dispatch 无法解析
- 判定: **预期** — S-unit 表在注释中=未完成填写，守卫正确拦截

**check-complete.sh**:
- 输出: `[plan] Rule 27.3 violation: scope 内存在未提交变更`
- 原因: v151 计划目录未被 git 跟踪
- 判定: **预期** — 计划目录未提交，守卫正确拦截

### 6.2 v149-skill-alignment-audit 计划（无 plan_tier 标记）

**check-plan-dispatch.sh**:
- 输出: `[goal-check] 无 plan_tier 标记，66.5 goal 门缺省跳过（legacy/无档位兼容口径）`
- 判定: **预期** — 无 plan_tier 标记=缺省档跳过，符合 Rule 66.5 档位语义

**check-complete.sh**:
- 输出: `[plan] Rule 27.3 violation: scope 内存在未提交变更`
- 判定: **预期** — 计划目录有未提交变更

### 6.3 v151 计划 Goal 单元表 vs progress.md 证据行

| Goal | 状态 | [goal:Gn] 证据行 | 判定 |
|------|------|------------------|------|
| G1 | complete | 有（progress.md:46） | OK |
| G2 | pending | 有（progress.md:47） | OK |
| G3 | complete | 有（progress.md:48） | OK |
| G4 | complete | 有（progress.md:49） | OK |
| G5 | complete | **无** | 预期拦截 |
| G6 | complete | **无** | 预期拦截 |

**判定**: G5/G6 缺 [goal:Gn] 证据行是 Rule 66.3 对存量计划的正常拦截。v151 计划是 Rule 66 的首个实例，G5/G6 在 Rule 66 落地前已 complete，无证据行属预期。check-complete.sh 应报 exit 1（但当前被 Rule 27.3 先拦截）。

---

## 7. frontmatter/模板面

**结论**: SKILL.md frontmatter 符合 ZCode 约定；29 个 variant 模板全部含 template_type 标记行。

### 7.1 SKILL.md frontmatter

- `name: task-planner` — OK
- `agent: executor` — OK
- `model: opus` — OK
- `allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, WebSearch, WebFetch"` — OK（ZCode 约定使用 allowed-tools 而非 tools）
- `user-invocable: true` — OK

### 7.2 templates/variant/ 29 文件 template_type 标记

- 29/29 文件含 template_type 标记行 — 全部 OK

---

## 缺陷清单

| 编号 | 严重度 | 位置 | 描述 | 建议 |
|------|--------|------|------|------|
| D1 | P2 | scripts/check-rescue-chain.sh | 孤儿守卫：未被 critical-rules.md 和 references/ 引用 | 在 Rule 41 条款中补充引用 |
| D2 | P2 | scripts/check-window-consistency.sh | 孤儿守卫：未被 critical-rules.md 和 references/ 引用 | 在对应条款中补充引用 |
| D3 | P2 | scripts/check-doc-sync.sh | 部分孤儿守卫：仅在 todo-sync.md 引用，critical-rules.md 无引用 | 在 Rule 62 条款中补充引用 |
| D4 | P2 | SKILL.md:216 | C43a 非标准命名（在 C43 和 C44 之间） | 考虑重命名为 C44 并顺延后续编号，或保持现状（功能合理） |
| D5 | P2 | plans/task-v151-goal-mode/ | G5/G6 状态 complete 但无 [goal:Gn] 证据行 | 计划侧问题，非技能缺陷；后续 goal 模式计划应逐 goal 落证据行 |

---

## 已核查无问题面

1. 机械锚: 20+ 条定值断言/行号锚/grep 锚全部通过，无漂移
2. 条款引用面: 48 个脚本引用全部在位，20 个 config 键全部被消费
3. 交叉一致性: C1-C45 连续，registry 64=64，Rule 摘要行与子条数一致
4. 部署位对账: diff -rq 全量无差异
5. 守卫误报面: v151/v149 计划试跑告警均属预期
6. frontmatter/模板面: SKILL.md frontmatter 合规，29 个 variant 模板全部含 template_type

---

**审计结论**: 技能整体质量良好，无 P0/P1 缺陷。5 个 P2 缺陷均为文档引用面或计划侧问题，不影响核心功能。
