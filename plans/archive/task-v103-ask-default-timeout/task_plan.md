---
template_type: rule-enhancement
plan_tier: standard
---

# Task Plan: task-v103-ask-default-timeout — Rule 44 用户选择点默认项+自动超时（选择/不打断中间态）

<!--
  WHAT: 新增 Rule 44（用户选择点默认选项与自动超时裁决）：2+ 选项呈现必带推荐默认项+自动超时时长（默认 5 分钟），超时未答复自动按推荐项执行并登记自动裁决记录；产出一致仅步骤/时间不同的选项优先直接裁决登记（41.3 衔接）不打扰用户；SKILL C33 消费行+模板「自动超时默认项」配置行+RT-01..RT-09 守护+级联；合并部署 push 清理。
  WHY: 用户 2026-10-01 指令：「提供方案差别不大时没必要交给用户选择；给用户选择的东西都设默认选项；设置自动超时（如 5 分钟），超时不选择则按推荐方案执行——在让用户选择和不打断任务之间做中间态,以后都可以这样做」。
  交互模式: silent（/goal 延续）。主进程直接撰写计划（白名单②,plan-writer 档位死亡多度实测）。
-->

## Goal
新增 Rule 44「用户选择点默认项与自动超时裁决」（4 子条:44.1 呈现契约默认项+超时时长/44.2 低区分度优先直接裁决/44.3 超时自动选择+裁决记录/44.4 零新键机制）+ SKILL C33 行+Rule 44 摘要行+模板「自动超时默认项」配置行+mini-lite 豁免行+selftest-ask-default-timeout（RT-01..09）+registry 登记+全量 selftest 0 FAIL 后合并回 master、三部署位 IDENTICAL、push GitHub、worktree 清理。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | task-v103-ask-default-timeout |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v103-ask-default-timeout |
| `branch` | wt/task-v103-ask-default-timeout（基线 master@7106233） |
| `scope_files` | references/critical-rules.md(44 追加); SKILL.md(C33+摘要行); templates/task_plan.md(+1 行); templates/variant/mini-lite-type.md(+1 行); scripts/selftest-ask-default-timeout.sh(新建); scripts/selftest-registry.tsv(+1 行) |
| `interaction_mode` | silent |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 |
|---|----------|----------|
| VC-1 | CRIT 44 四子条在位:44.1（推荐默认项必带+超时时长默认 5 分钟可任务级覆盖）/44.2（产出一致仅步骤/时间不同=低区分度,优先直接裁决登记不打扰,询问时也必带默认）/44.3（超时未答复→自动按推荐默认项执行+「自动裁决记录」必登记:超时值/推荐项/触发时间/理由）/44.4（零新键,RT 守护）;43.x/42.x 零改动 | grep '^44\.' + diff 面 |
| VC-2 | SKILL C33 行+Rule 44 摘要行;模板「自动超时默认项」行（每个询问点登记默认项与超时时长）+mini-lite 豁免行;字面锚保全 | grep 逐锚 |
| VC-3 | RT selftest 在位:RT-01..09+registry 登记;全量回归 41 脚本 0 FAIL 且 PASS ≥700+RT-01..09（主进程定数,基线 639+RT 9≈648,实数以定数为准） | bash 全量 |
| VC-4 | 合并部署 push 清理闭环+部署位 44 锚分发 | smart-merge-back+ls-remote+部署位 grep |
| VC-5 | 边界零回归+CR APPROVED（隔离审查;ECONNREFUSED 时 22.3① 改派 executor 审查规程） | CR 结论+diff 面 |

**终验规则**: 全 VC → COMPLETE;遗留 → PARTIAL;3 次无效 → BLOCKED（41.4 前置）。

## ⚠️ 执行范围限制
| 类别 | 允许 | 禁止 |
|------|------|------|
| 条款 | CRIT EOF 前 44 节追加（44.1-44.4,插在文件末尾部既有 43.x 区后——实测定位） | 42.x/43.x/其他行 |
| SKILL | C33 行新增（C32 行后）+Rule 44 摘要行新增 | C29-C32/Rule 40-43 摘要行 |
| 模板 | 配置表+1「自动超时默认项」行;mini-lite+1 豁免行 | 契约标记 |
| 测试 | 新建 scripts/selftest-ask-default-timeout.sh（RT-01..09）+registry +1 行 | 其他 selftest 逻辑改动（计数级联除外） |
| 配置 | （无） | config.json 零改动（44.4 零新键） |

## 📚 必要知识储备
| 名称 | 定位 | ☑ |
|------|------|---|
| CRIT 末区（43.4 行=EOF 前 44 插入位） | CRIT :436-437 | ☑ |
| C32 行形态（C33 插入位） | SKILL :197 | ☑ |
| 模板配置表形态 | templates/task_plan.md 配置表区 | ☑ |
| RT 自测范式（对照 R/SR/RL 脚本） | scripts/selftest-reliability-institution.sh | ☑ |
| registry 行形态 | scripts/selftest-registry.tsv | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 现行选项呈现规范要求 2+ 选项给推荐,但无「默认项+自动超时」机制——任务因等待用户答复而中断,且低区分度选项（产出相同仅步骤/时间不同）也消耗用户注意力。用户要求中间态:默认选项+超时自动裁决（5 分钟,可覆盖）,既不无脑打断,也不替用户做重大决策。规则 44 落地后,选择点从「呈现即阻塞」变为「带默认与超时的非阻塞呈现」,问题解决。
- [x] 能交付 / [x] 唯一目标 / [x] 方法清晰

## Current Phase
（终态）Phase 5 complete — outcome: COMPLETE

## Next Step
交付报告呈示。
主进程建 worktree（@7106233）+基线复测落 progress。

## 🧰 工具选择与编排（Rule 40）
| Phase | 工具面 | 理由 |
|-------|--------|------|
| P1 | ①③ | worktree/基线 |
| P2 | ③ executor S1（sonnet-1 条款撰写）→S2（haiku-1 锚行编辑）→S3（sonnet-1 selftest+registry）串行 | 21.4 |
| P3 | ⑥ 主进程求和 | 白名单③ |
| P4 | ① git 全链 | 白名单① |
| P5 | ③ CR（code-reviewer,故障改派 executor 规程）+②⑤ 簿记 | 白名单②⑤ |

**workflow 判定**: 未命中（S1→S3 串行依赖+未点名 /workflow）→21.4 串行。**/goal 对齐**: Goal+VC 即证据源;40.3 披露照旧。

## Phases

### Phase 1: 基线 + worktree
- [ ] worktree @7106233,porcelain=0;基线复测（40 脚本 639/0+CRIT/SKILL 行数实测+registry 行数）
- **V-N:** VC-3, VC-5
- **Status:** complete
- **Executor:** 主进程（① 纯 git/worktree 编排 + ③ 机械验证（基线求和纪律禁子代理自报）——Rule 25.3 白名单①③）

### Phase 2: 条款+消费+守护（S1→S3 串行）
- [ ] S1: CRIT 追加 44 四子条（44.1 呈现契约: 2+ 选项必带推荐默认项+自动超时时长（默认 5 分钟,可任务级覆盖）;44.2 低区分度优先直接裁决: 产出一致仅步骤/时间不同→按 41.3 trivial 直接裁决+登记（不打扰）,确需询问时仍必带默认项;44.3 超时自动选择: 超时未答复→自动按推荐默认项执行+「自动裁决记录」必登记（超时值/推荐项/触发时间/理由,写入 progress/Decisions）;44.4 机制: 判定面=LLM 行为,机器面=RT selftest,零新 config 键）
- [ ] S2: SKILL C33 行（C32 行后）+Rule 44 摘要行（Rule 43 摘要行后新增行）;模板「自动超时默认项」配置行+mini-lite 豁免行
- [ ] S3: 新建 scripts/selftest-ask-default-timeout.sh（RT-01..09: 44 四子条锚/用户原话锚「默认选项」「自动超时」「5 分钟」/C33 行/模板行/豁免行/registry 行/1-4x 越界负断言/零新键键数=40）+registry +1 行
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** executor（S1 sonnet-1/S2 haiku-1/S3 sonnet-1;21.4 串行）
| ID | 目标 | 执行体 | 建议档位 | 输入 | 验收 | 预估 | 状态 |
|----|------|--------|---------|------|------|------|------|
| S1 | CRIT Rule 44 追加 | executor | sonnet-1 | 44.1-44.4 定义+用户原话锚 | grep '^44\.'=4+用户原话三锚;42/43 零改动 | 15min | pending |
| S2 | C33+摘要+模板行+豁免行 | executor | haiku-1 | C32 行形态+配置表形态 | 四落点 grep;字面锚保全 | 10min | pending |
| S3 | RT selftest+registry | executor | sonnet-1 | RT-01..09 断言清单 | `Total: 9 PASS=9 FAIL=0`;registry 行;bash -n | 15min | pending |

### Phase 3: 全量回归
- [ ] 主进程定数（41 脚本双形态求和: RT 9/0+全量 0 FAIL;注意 SR-12 动态口径=脚本数+表头自动咬合）
- **V-N:** VC-3
- **Status:** complete
- **Executor:** 主进程（③ 机械验证（全量求和定数禁子代理自报）——Rule 25.3 白名单③）

### Phase 4: 合并+部署+push+清理
- [ ] 预检→smart-merge-back --deploy（部署位「Rule 44」锚 grep）→push（ls-remote 终验）→清理 0/0
- **V-N:** VC-4
- **Status:** complete
- **Executor:** 主进程（① git 编排（merge/deploy/push/cleanup 全链）+ ② merge_back 簿记 + ③ 机械验证（只读预检/部署位终裁）——Rule 25.3 白名单①②③）

### Phase 5: CR Gate + 终验簿记
- [ ] CR（code-reviewer 隔离审全量 diff;ECONNREFUSED 时 22.3① 改派 executor+任务书审查规程）;APPROVED 才终验
- [ ] 簿记: verification/INDEX/notepad/memory/check-complete（簿记提交后）
- **V-N:** VC-5
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）（CR 隔离审查）+ 主进程（② 计划系统文件簿记 + ⑤ 终验机械复核——Rule 25.3 白名单②⑤）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（P1 复扫） |
| `isolation` | worktree |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v103-ask-default-timeout |
| `branch` | wt/task-v103-ask-default-timeout（@7106233） |
| `merge_back` | pending |

## 📊 FMEA
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P2 | 44 节插入位置错（CRIT 末区 43.x 邻接漂移） | 8 | 3 | 3 | 72 | S1 先 grep '^43\.' 实测插入位;diff 纯增核验 |
| P2 | RT 断言锚与实文漂移（S3 后实文被 S4 类改动） | 6 | 3 | 3 | 54 | S3 动手前 Read S1/S2 产出实测锚 |
| P3 | SR-12 动态口径因 registry 行未同步断 | 6 | 3 | 3 | 54 | RT+registry 同批登记（S3 一步）;SR 12/0 复跑 |
| P4 | 部署 DRIFT/push 冲突 | 6 | 3 | 3 | 54 | fail-closed+ls-remote 终验 |
| P5 | code-reviewer ECONNREFUSED | 4 | 3 | 3 | 36 | 22.3① 改派 executor+审查规程（v102 先例） |

## 🔁 原生 Todo 同步
| Phase | 已建 | 备注 |
|-------|------|------|
| P1-P5 | S1 映射批准后建 | 5 条 |

## Key Questions
1. 5 分钟超时是全局默认还是每询问点声明？（答: 44.1 全局默认 5 分钟,询问点可声明任务级覆盖值——注册在「自动超时默认项」模板行;零新 config 键,声明面=计划文档）
2. 超时自动裁决的审计面？（答: 44.3 自动裁决记录五要素（超时值/推荐项/触发时间/理由/被覆盖的未决选项）随 progress 落盘——不打断≠不留痕）
3. 44.2 与 41.3 关系？（答: 41.3 trivial 直接做禁推诿是「不问」的制度,44.2 是「不问」的判定扩展（产出一致仅步骤/时间差异）;44.2 引用 41.3 不重述）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: 44 定为新 Rule（非 43 子条） | 用户选择点契约与 43 可靠性域不同（呈现面 vs 执行面）,独立 Rule 边界清晰 |
| silent: 超时默认 5 分钟（用户原话「就比如设置成 5 分钟超时」） | 用户明示 5 分钟,入 44.1 默认值+任务级覆盖 |
| silent: 零新 config 键 | 判定面=LLM 行为（询问点声明默认项与超时）,RT 静态断言守护;同 42.5/43.4 范式 |
| silent: 主进程直接撰写计划 | 白名单②;plan-writer 档位死亡多度实测 |
| silent: push 沿用 09-30 持久指令 | 用户「部署到各个平台,然后提交到 GitHub 进行备份」 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
|       | 1       |            | → progress.md Error Log |

## Notes
- 用户原话三句是 VC-1 的锚:「设置默认选项」「自动超时」「按照推荐的方案进行执行」——S1/S3 撰写必须含字面「默认选项」「超时」「推荐」
- 禁「1-4x」越界字面;「Rules 1-39」字面 2 处不动;1-40 越界断言（R-09）不命中 44（1-40 数字面,非 44）

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
| `rollback_point` | master@7106233 |

## 📊 委派统计
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 | 1 / 5（P2;P5-CR 部分） |
| 主进程直做 | P1/P3/P4/P5（①②③⑤——白名单） |
| 委派率 | 预期 0.2 → 25.4a 判定 |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|-----------|------|
| 1 | 2026-10-01 | executor | P2-S1 CRIT Rule 44 追加 | done | 44.1-44.4 纯增 7 行（437→444）;原话锚实测 7/7/4;42/43 零改动 | 01-exec-p2s1.md+主进程抽验 | findings Requirements | plans/task-v103-ask-default-timeout/subagent-state/01-exec-p2s1.md | - / 0 / ☑ |
| 2 | 2026-10-01 | executor | P2-S2 C33+摘要+模板行+豁免行 | done | 四落点全中;SKILL 442 行实测入 checkpoint;既有锚零改动 | 02-exec-p2s2.md | findings Research | plans/task-v103-ask-default-timeout/subagent-state/02-exec-p2s2.md | - / 0 / ☑ |
| 3 | 2026-10-01 | executor | P2-S3 RT selftest+registry+T-主级联 | done | RT 9/0;registry 42 行咬合;T-主 440→442 | 03-exec-p2s3.md | findings Research | plans/task-v103-ask-default-timeout/subagent-state/03-exec-p2s3.md | - / 0 / ☑ |
| 4 | 2026-10-01 | code-reviewer | P5 CR Gate | done | **APPROVED**（0 P0/2 P1/3 P2）→fix-phase 全处置（P1×2 索引行纳入 44+P2×3 口径/D6/旧文回溯） | 04-cr-p5.md | verification CR 段 | plans/task-v103-ask-default-timeout/subagent-state/04-cr-p5.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置
| 字段 | 值 |
|------|-----|
| **chain_mode** | single |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 已知类型;终验处置: 不沉淀理由（34.3 不命中,终验登记）
