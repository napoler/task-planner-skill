<!-- template_type: mini-lite -->
execution_lane: L0-T（Rule 38.7 纯文本档：规则条款增改+索引/计数级联，仅 1 个用户显式诉求授权的 selftest 守护脚本；零新 config 键/hooks/守护进程）
<!-- plan_tier: mini -->
<!-- 适用场景: 轻量任务（≤2 文件 ∧ 预估 ≤15min ∧ 单模块）——跳过中/重仪式区块，中/重任务禁用本模板（Rule 38.2） -->
<!-- 触发关键词: 轻量/小改/单文件/快修/微调/15 分钟/小任务 -->
<!-- 推荐 subagent: 主进程直做（白名单②）或 executor(haiku) 单文件小改；无强制派发 -->
<!-- 38.3 区块白名单: 仅 Goal/VC/执行范围限制表/单 Phase/Handoff 表, 增其他仪式区块=模板违约(selftest-plan-tier 断言); [task-v094 T-B2] 2 Phase→单 Phase(实施+验收合一) -->
<!-- Rule 40.2 豁免声明（task-v097）: mini 档不加「🧰 工具选择与编排」区块——Rule 38.3 轻量模板区块白名单的自然延伸,mini 免计划期工具分析仪式;显式声明以防误判缺区块为违约 -->
<!-- Rule 42.5 豁免声明（task-v099）: mini 档不含「质量审查工具」配置行——Rule 38.3 轻量模板契约的自然延伸（同 40.2 豁免行范式） -->
<!-- Rule 42.6 豁免声明（task-v102）: mini 档不含「对齐审查」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5 豁免行范式） -->
<!-- Rule 44 豁免声明（task-v103）: mini 档不含「自动超时默认项」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5/42.6 豁免行范式） -->

# Task Plan: 惰性上抛禁令（Rule 97）L0-T 规则文本级联

## Goal
新增 Rule 97 惰性上抛禁令与不可用判词证据门（纪律域 satellite），+ 1 个 selftest 守护 + 全量索引/计数/纪元级联；纯 L0-T 文本档（零新 config 键/hooks/守护进程）

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | selftest-anti-deferral.sh 全 PASS（AD-01..12, 0 FAIL） | `bash skills/task-planner/scripts/selftest-anti-deferral.sh` | 末行 Total |
| VC-2 | selftest-registry.sh 全 PASS（T02 新行配对无缺失） | `bash skills/task-planner/scripts/selftest-registry.sh` | 末行 Total |
| VC-3 | run-selftests.sh 全量回归 FAIL=0 且无回归（LA-14 properties=53 / TL-23 仍 PASS） | `bash skills/task-planner/scripts/run-selftests.sh` | 末行 FAIL=0 |
| VC-4 | 级联 grep 核对：SKILL.md '1-97'≥3 ∧ '其余 80 条'≥2 ∧ '94,95,97'≥1；task-discipline '92,93,94,95,97'≥1 ∧ '47 条'≥3 ∧ '46 条'=0；worktree/smart-merge '97.6'各≥1 | 逐条 grep | 命令输出 |

**终验规则**: 全部 VC 通过 → COMPLETE

> **VC-3 终验说明（执行期登记）**：全量回归实态=`Total: 94 PASS=93 FAIL=1`，唯一 FAIL=`selftest-rule-reserve-pairing` PR-02（rule 97 处于 reserved 未 land，非豁免悬空编号清单命中）。根因=铁约束禁 git commit/push（留给用户裁决），`rule-reserve.sh land 97` 设计语义为「合并后 land」（账本追加+commit 收口成对），故推迟至用户 commit 时执行；届时 PR-02 归位 FAIL=0。非本次改动引入的回归（PR-01/PR-03 PASS，LA-14 properties=53 / TL-23 无回归，其余 92 脚本全 PASS，registry rows=94/actual=94 含新增 selftest-anti-deferral.sh 双向配对成立）。

## ⚠️ 执行范围限制

| 改什么（scope_files） | 禁碰什么 |
|-------|------|
| skills/task-discipline/references/critical-rules-discipline.md（末追加 Rule 97） | 既有 26/41/43/54/60/83/86/89/95 原文零改动 |
| skills/task-planner/scripts/selftest-anti-deferral.sh（新建） + selftest-registry.tsv（+1 行） | 既有 selftest 断言面不动；config.json properties=53 不动 |
| skills/task-planner/SKILL.md（1-97 纪元/80 条/task-discipline 路由 +97） | 核心 14 条枚举不动 |
| skills/task-planner/references/critical-rules.md:194 / references/worktree-isolation.md:86 / scripts/smart-merge-back.sh（+1 注释行） | smart-merge-back.sh exit 7 机器行为/恢复指引零改动 |
| skills/task-planner/docs/ARCHITECTURE.md / README.md / CLAUDE.md / README_zh.md（纪元+79→80 级联） | ARCHITECTURE:125 历史 epoch-log + 各仓根历史尾注链（1-95→1-96 记录）原样保留 |
| skills/task-discipline/SKILL.md（46→47/枚举止于94 补 95 加 97） | 无 |
| skills/task-planner/scripts/selftest-subagent-activation.sh（SA-11/SA-12 锚常量 1-97/80 条随动） | SA-10 dispatch 域 ,96 断言不动 |

约束: L0-T 纯文本档；任一机器条件不满足 → 改回 standard 全量模板

## Phases（固定 1：实施+验收合一，[task-v094 T-B2]；3-File 双条件在本 Phase 照常一次，Rule 19.2 降档）

### Phase 1: 实施+验收（合一）
- 追加 Rule 97 + 新建 selftest + registry 登记 + 全量级联 + selftest-subagent-activation 锚随动
- Read 回填复核 + 级联 grep 核对 + 全量 selftest 回归（与实施同 Phase 闭环）
- **V-N:** VC-1..VC-4（允许集中映射）
- **Status:** complete（2026-11-02 实施+验收闭环，证据见 progress.md Phase 1 Test Results 表 + VC-3 终验说明）
- **Executor:** 主进程（白名单⑥ L0-T 规范文本级联，worktree 不变）

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | checkpoint 路径 |
|---|--------------|----------------|------|---------|----------------|
| 无 | 全程主进程直做（L0-T） | | | | |

## Decisions Made
- **单 commit 交付（38.7 簿记精简）**：本任务=单 commit `feat(task-planner-skill): Rule 97 惰性上抛禁令与不可用判词证据门 + L0-T 级联`；LANE-L0 GATE ③ feat|fix 提交数=260≠1 惯性缺口，特此声明机理由（历史多 commit 惯性，本任务遵循 38.7 L0 单 commit 簿记精简口径，交付时合并为 1 commit）。
- **rule-reserve land 步骤推迟**：`rule-reserve.sh land 97 task-lazy-escalation-20261102` 与 commit 收口成对执行（设计语义=合并后 land），铁约束禁 git commit/push → 留用户 commit 时同批执行；届时 selftest-rule-reserve-pairing PR-02 归位，全量 FAIL=0。
- **既有欠账不改**：skills/task-planner/README.md:69 路由枚举止于 76（v171 快照陈旧，'69-74,76' grep 证 2 处）非本任务范围，仅登记，不修。
