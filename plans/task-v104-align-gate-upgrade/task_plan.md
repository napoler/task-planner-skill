---
template_type: rule-enhancement
plan_tier: standard
---

# Task Plan: task-v104-align-gate-upgrade — 写入前校验闸门升级（五维扫描+标记确认后整理+简短变更记录三要素）

<!--
  WHAT: alignment-review 写入前校验闸门升级（全文扫描五维→标记冲突+建议处置→确认后再整理→按最新有效版本整理（删除或归档+统一术语/编号/章节结构/引用）→简短变更记录三要素）+ 42.6.1/42.6.3 行内升级 + C32 行「五要素→三要素」级联 + RL-12/13 守护断言；合并部署 push 清理。
  WHY: 用户 2026-10-01 指令（task-v102 闸门深化）：多次更新文档时优先版本一致性检查而非直接追加；先全文扫描识别版本冲突/重复段/过期结论/编号不一致/失效引用；标记冲突位置+建议处置方法，确认后再同步整理；按最新有效版本整理（删除或归档过期内容，统一术语/编号/章节结构/引用）；每次更新后生成简短变更记录（变更范围/冲突处理结果/文档当前状态），确保文档清晰、一致、可追溯。
  交互模式: silent（/goal 延续）。主进程直接撰写计划（白名单②,plan-writer 档位死亡多度实测）。
-->

## Goal
升级 alignment-review 写入前校验闸门为「五维全文扫描→标记+建议→确认后整理→最新有效版本整理（删除或归档+四项统一）→简短变更记录三要素」流程,同步升级 42.6.1/42.6.3 与 C32 行,新增 RL-12/13 守护；全量 selftest 0 FAIL 后合并回 master、三部署位 IDENTICAL、push GitHub、worktree 清理。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | task-v104-align-gate-upgrade |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v104-align-gate-upgrade |
| `branch` | wt/task-v104-align-gate-upgrade（基线 master@e1180a5） |
| `scope_files` | review-library/alignment-review/SKILL.md(闸门段+变更记录段升级); references/critical-rules.md(仅 42.6.1/42.6.3 行内); SKILL.md(C32 行内「五要素→三要素」); scripts/selftest-review-library.sh(RL-12/13+头注释级联) |
| `interaction_mode` | silent |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 |
|---|----------|----------|
| VC-1 | 闸门段升级:五维扫描（版本冲突/重复段/过期结论/编号不一致/失效引用）+「标记冲突位置+建议处置方法」+「确认后再同步整理」（ask=确认/silent=Rule 44 自动超时裁决 44.3）+「删除或归档」+四项统一（术语/编号/章节结构/引用）全在位;「未经一致性校验，不直接追加新内容」v102 原话锚保留 | grep 逐锚+Read |
| VC-2 | 变更记录段升级:简短三要素表（变更范围/冲突处理结果/文档当前状态）替换原五字段表;「确保文档清晰、一致、可追溯」语义在位 | grep 逐锚 |
| VC-3 | CRIT 42.6.1 行内升级（五维扫描+确认后整理+Rule 44 衔接）+42.6.3 三要素化（变更范围/冲突处理结果/文档当前状态）;42.6.2/42.6.4 与 44.x/43.x 零改动;C32 行「五要素」→「三要素」级联 | grep+dif 面 |
| VC-4 | RL-12/13 在位（alignment 新锚+CRIT 三要素锚+selftest-review-library Total 11→13）;全量回归 41 脚本 0 FAIL 且 PASS ≥650（主进程定数） | bash 全量 |
| VC-5 | 合并部署 push 清理闭环+部署位新锚分发 | smart-merge-back+ls-remote+部署位 grep |
| VC-6 | 边界零回归+CR APPROVED（隔离审查;CHANGES_REQUESTED→fix-phase） | CR 结论+diff 面 |

**终验规则**: 全 VC → COMPLETE;遗留 → PARTIAL;3 次无效 → BLOCKED（41.4 前置）。

## ⚠️ 执行范围限制
| 类别 | 允许 | 禁止 |
|------|------|------|
| 技能 | alignment-review 闸门段/变更记录段升级（段内替换;触发条件/四要素其余/审查清单 14 条/证据要求/输出合约零改动） | 池内其他 11 技能 |
| 条款 | 42.6.1/42.6.3 行内升级（42.6.2/42.6.4/44.x 零改动） | 其他任何行 |
| SKILL | C32 行内「五要素」→「三要素」措辞 | C29-C31/C33/摘要行/其他行 |
| 测试 | selftest-review-library（RL-12/13+头注释 RL 计数级联） | 其他 selftest |
| 配置 | （无） | config.json 零改动 |

## 📚 必要知识储备
| 名称 | 定位 | ☑ |
|------|------|---|
| alignment-review 现文（闸门段 :20-29/变更记录段 :55-66） | review-library/alignment-review/SKILL.md | ☑ |
| 42.6.1/.3 现文（:425/:427） | CRIT | ☑ |
| C32 行「五要素」字样（:197） | SKILL | ☑ |
| RL-11 现文范式 | selftest-review-library.sh | ☑ |
| Rule 44 自动超时裁决（44.3） | CRIT :443 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: v102 闸门是「五步对照+五字段变更记录」,用户要求更完整的冲突处置流程：①扫描面扩到五维（新增编号不一致/失效引用独立维度）②两阶段处置——先标记冲突位置+建议处置,确认后才整理（防误删,「确认」在 silent 模式由 Rule 44 自动超时裁决承载,不打断任务）③整理动作扩到「删除或归档」+四项统一（术语/编号/章节结构/引用）④变更记录改为简短三要素（变更范围/冲突处理结果/文档当前状态）——可追溯面收窄聚焦。升级后闸门从「对照检查」变为「扫描-标记-确认-整理-记录」闭环,问题解决。
- [x] 能交付 / [x] 唯一目标 / [x] 方法清晰

## Current Phase
Phase 2

## Next Step
主进程建 worktree（@e1180a5）+基线复测落 progress。

## 🧰 工具选择与编排（Rule 40）
| Phase | 工具面 | 理由 |
|-------|--------|------|
| P1 | ①③ | worktree/基线 |
| P2 | ③ executor S1（sonnet-1 技能升级）→S2（sonnet-1 条款+SKILL 级联）→S3（haiku-1 RL-12/13）串行 | 21.4 |
| P3 | ⑥ 主进程求和 | 白名单③ |
| P4 | ① git 全链 | 白名单① |
| P5 | ③ CR（code-reviewer,故障改派 executor 规程）+②⑤ 簿记 | 白名单②⑤ |

**workflow 判定**: 未命中（S1→S3 串行依赖+未点名 /workflow）→21.4 串行。**/goal 对齐**: Goal+VC 即证据源;40.3 披露照旧。

## Phases

### Phase 1: 基线 + worktree
- [ ] worktree @e1180a5,porcelain=0;基线复测（41 脚本 648/0+alignment 75 行/闸门段/变更记录段/42.6.1/.3 行/C32 行「五要素」实测）
- **V-N:** VC-4, VC-6
- **Status:** complete
- **Executor:** 主进程（① 纯 git/worktree 编排 + ③ 机械验证（基线求和纪律禁子代理自报）——Rule 25.3 白名单①③）

### Phase 2: 升级面（S1→S3 串行）
- [ ] S1: alignment 闸门段替换（五维扫描→标记冲突+建议处置→确认后再同步整理（ask 确认/silent Rule 44 自动超时裁决 44.3）→按最新有效版本整理（删除或归档+术语/编号/章节结构/引用统一）→简短变更记录三要素）+变更记录段替换（三要素表:变更范围/冲突处理结果/文档当前状态,简短+可追溯）;「未经一致性校验，不直接追加新内容」锚保留;触发条件/四要素/清单 14 条/证据要求/输出合约零改动;来源注释行尾注追加 v104
- [ ] S2: CRIT 42.6.1 行内升级（五维扫描+标记确认后整理+Rule 44 衔接措辞）+42.6.3 行内三要素化（变更范围/冲突处理结果/文档当前状态）;SKILL C32 行「五要素」→「三要素」级联
- [ ] S3: selftest-review-library RL-12（alignment 新锚:「全文扫描」≥1/「删除或归档」≥1/「变更范围」≥1）+RL-13（CRIT 42.6.3「三要素」≥1 且 C32 行「三要素」≥1）+头注释 RL-01..11→13 级联
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** executor（S1 sonnet-1/S2 sonnet-1/S3 haiku-1;21.4 串行）
| ID | 目标 | 执行体 | 建议档位 | 输入 | 验收 | 预估 | 状态 |
|----|------|--------|---------|------|------|------|------|
| S1 | alignment 闸门+变更记录段升级 | executor | sonnet-1 | 任务书闸门流程规格+现文 | 五维/标记确认/归档/三要素锚全中;v102 原话锚保留;其余段零改动 | 15min | pending |
| S2 | 42.6.1/.3 行内升级+C32 级联 | executor | sonnet-1 | 42.6.1/.3 现文+C32 行 | 行内升级;42.6.2/.4 零改动;C32 仅措辞级联 | 10min | pending |
| S3 | RL-12/13+头注释级联 | executor | haiku-1 | RL-11 范式+S1/S2 产出实测锚 | `Total: 13 PASS=13 FAIL=0`;RL-01..11 零改动 | 10min | pending |

### Phase 3: 全量回归
- [ ] 主进程定数（41 脚本双形态求和: selftest-review-library 13/0+全量 0 FAIL,PASS ≥650）
- **V-N:** VC-4
- **Status:** complete
- **Executor:** 主进程（③ 机械验证（全量求和定数禁子代理自报）——Rule 25.3 白名单③）

### Phase 4: 合并+部署+push+清理
- [ ] 预检→smart-merge-back --deploy（部署位「全文扫描」锚 grep）→push（ls-remote 终验）→清理 0/0
- **V-N:** VC-5
- **Status:** complete
- **Executor:** 主进程（① git 编排（merge/deploy/push/cleanup 全链）+ ② merge_back 簿记 + ③ 机械验证（只读预检/部署位终裁）——Rule 25.3 白名单①②③）

### Phase 5: CR Gate + 终验簿记
- [ ] CR（code-reviewer 隔离审全量 diff;ECONNREFUSED 时 22.3① 改派 executor+任务书审查规程）;APPROVED 才终验
- [ ] 簿记: verification/INDEX/notepad/memory/check-complete（簿记提交后）
- **V-N:** VC-6
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）（CR 隔离审查）+ 主进程（② 计划系统文件簿记 + ⑤ 终验机械复核——Rule 25.3 白名单②⑤）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（P1 复扫） |
| `isolation` | worktree |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v104-align-gate-upgrade |
| `branch` | wt/task-v104-align-gate-upgrade（@e1180a5） |
| `merge_back` | pending |

## 📊 FMEA
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P2 | 闸门段替换伤及相邻段（触发条件/审查清单） | 8 | 3 | 3 | 72 | 段边界以 `## ` 标题定位替换;diff 面核验仅 2 段变化 |
| P2 | C32 行内升级误伤 C33 行（相邻） | 6 | 3 | 3 | 54 | 内容锚定位（「五要素」字样实测仅 C32 行+42.6.3 两处,grep 先普查） |
| P3 | RL-12/13 断言锚与实文漂移 | 6 | 4 | 3 | 72 | S3 动手前先 Read S1/S2 产出实测锚 |
| P4 | 部署 DRIFT/push 冲突 | 6 | 3 | 3 | 54 | fail-closed+ls-remote 终验 |

## 🔁 原生 Todo 同步
| Phase | 已建 | 备注 |
|-------|------|------|
| P1-P5 | S1 映射批准后建 | 5 条 |

## Key Questions
1. 「确认后再整理」的确认者在 silent 模式是谁？（答: 按 Rule 44——silent=用户不在线,确认环节由 44.3 自动超时裁决承载:标记+建议呈报→默认处置（按最新有效版本整理）→裁决记录留痕;ask 模式=真用户确认。42.6.1 显式写此衔接）
2. 变更记录从五字段改三要素,旧五字段信息丢吗？（答: 三要素是「简短」主表（用户指定）,原五字段的「依据版本」并入冲突处理结果列（裁决依据）、「残留冲突」并入冲突处理结果列（未决项）——信息全保留但收窄为一行三列的简短表）
3. RL-11 还有效吗？（答: 有效——「写入前校验」≥2/「未经一致性校验，不直接追加新内容」=1/「变更记录输出」≥1 三锚在升级后全部保留,RL-11 零改动;RL-12/13 是新增锚守护）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: 闸门升级落 alignment 技能内（非新 hook/新 Rule） | 42.6.1/.3 行内升级承载制度层,与 v102 同落点;确认环节复用 Rule 44 既有制度 |
| silent: 变更记录三要素替换五字段（非追加） | 用户明确「简短变更记录」并指定三要素;原字段信息并入新表不丢信息 |
| silent: 主进程直接撰写计划 | 白名单②;plan-writer 档位死亡多度实测 |
| silent: push 沿用 09-30 持久指令 | 用户「部署到各个平台,然后提交到 GitHub 进行备份」多度确认 |
| silent: 42.6.2（完成前对齐标准流程）不动 | 用户本次指令仅涉写入前闸门与变更记录,完成前流程语义不变（YAGNI） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
|       | 1       |            | → progress.md Error Log |

## Notes
- 用户原话锚（英文指令语义,中文化字面入锚）: 「prioritize version consistency checks」「scan the full text」「mark the conflict locations」「synchronize the organization after confirmation」「deleting or archiving outdated content」「unifying terminology, numbering, chapter structure, and citations」「brief change log」→ 对应中文锚「全文扫描」「标记」「确认」「删除或归档」「术语/编号/章节结构/引用」「简短变更记录」
- 既有「五要素」字样仅 2 处（C32 行+CRIT 42.6.3,grep 普查确认）;RL-11 三锚保留
- 禁「1-4x」越界字面;「Rules 1-39」字面 2 处不动

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|

## 📦 Batch Report
| 字段 | 值 |
|------|-----|
| `total` | 0（零单元声明——非批量） |
| `success` | 0 |
| `failed` | 0 |
| `failure_rate` | 0% |
| `sampled_pass` | 0 |
| `sampled_fail` | 0 |
| `pre_check` | Q1:否/Q2:有/Q3:能 |
| `rollback_point` | master@e1180a5 |

## 📊 委派统计
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 | 1 / 5（P2;P5-CR 部分） |
| 主进程直做 | P1/P3/P4/P5（①②③⑤——白名单） |
| 委派率 | 预期 0.2 → 25.4a 判定 |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|-----------|------|
| 1 | 2026-10-01 | executor | P2-S1 alignment 闸门+变更记录段升级 | done | 闸门五维+两阶段+归档+统一;变更记录三要素;v102 原话锚保留;RL-11 仍 11/0 | 01-exec-p2s1.md+主进程亲验 | findings Requirements | plans/task-v104-align-gate-upgrade/subagent-state/01-exec-p2s1.md | - / 0 / ☑ |
| 2 | 2026-10-01 | executor | P2-S2 42.6.1/.3 行内升级+C32 级联 | done | CRIT 2/2+SKILL 1/1;42.6.2/.4 零改动;44.3 五要素保留 | 02-exec-p2s2.md | findings Research | plans/task-v104-align-gate-upgrade/subagent-state/02-exec-p2s2.md | - / 0 / ☑ |
| 3 | 2026-10-01 | executor | P2-S3 RL-12/13+头注释级联 | done | selftest-review-library 13/13;RL-01..11 零改动 | 03-exec-p2s3.md | findings Research | plans/task-v104-align-gate-upgrade/subagent-state/03-exec-p2s3.md | - / 0 / ☑ |
| 4 | 2026-10-01 | code-reviewer | P5 CR Gate | done | **APPROVED**（0 P0/P1,2 P2 指针滞后合规留置+1 留痕） | 04-cr-p5.md | verification CR 段 | plans/task-v104-align-gate-upgrade/subagent-state/04-cr-p5.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置
| 字段 | 值 |
|------|-----|
| **chain_mode** | single |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 已知类型;终验处置: 不沉淀理由（34.3 不命中,终验登记）
