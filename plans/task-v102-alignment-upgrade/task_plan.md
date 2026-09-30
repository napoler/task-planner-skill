---
template_type: rule-enhancement
plan_tier: standard
---

# Task Plan: task-v102-alignment-upgrade — alignment-review 验证优先升级（写入前校验闸门+变更记录+标准流程化）

<!--
  WHAT: 升级 alignment-review 技能为验证优先策略（写入前版本一致性校验闸门+冲突整理优先+变更记录输出）+ Rule 42.6 对齐消费制度化（写入前校验纪律+完成前对齐标准流程）+ SKILL C32+模板「对齐审查」行+RL-11 守护。
  WHY: 用户 2026-09-30 指令四点: ①验证优先,流程初期即完成关键确认 ②对齐现有模板有效利用新 skill ③文档更新前必须先版本一致性校验,冲突优先整理再写入,自动识别不一致/重复/过期,按最新有效版本合并删冗余,输出变更记录,未经校验不直接追加 ④对齐 skill 引用列入标准流程,完成任务前及时对齐所有文档。
  交互模式: silent（/goal 延续）。主进程直接撰写计划（白名单②,plan-writer 档位死亡三度实测）。
-->

## Goal
升级 review-library/alignment-review 为验证优先策略（新增「写入前校验闸门」与「变更记录输出」两段+触发条件扩展到写入动作前）+ Rule 42.6 四子条（写入前校验纪律/完成前对齐标准流程/变更记录要求/机制）+ SKILL.md C32 合规行+摘要行同步+模板配置表「对齐审查」行+mini-lite 豁免行+RL-11 守护断言；全量 selftest 0 FAIL 后合并回 master、三部署位 IDENTICAL、push GitHub、worktree 清理。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | task-v102-alignment-upgrade |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v102-alignment-upgrade |
| `branch` | wt/task-v102-alignment-upgrade（基线 master@5ddc317） |
| `scope_files` | review-library/alignment-review/SKILL.md; references/critical-rules.md(仅 42.6 追加); SKILL.md(C32+摘要行); templates/task_plan.md(+1 行); templates/variant/mini-lite-type.md(+1 行); scripts/selftest-review-library.sh(RL-11+计数级联) |
| `interaction_mode` | silent |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 |
|---|----------|----------|
| VC-1 | alignment-review 升级在位:含「写入前校验」段（五步流程:读最新态→对照→识别不一致/重复/过期→按最新有效版本合并删冗余→输出变更记录）+「未经一致性校验，不直接追加」用户原话锚+「变更记录」段+触发条件含写入动作前 | grep 逐锚+Read |
| VC-2 | Rule 42.6 四子条在位（42.6.1 写入前校验纪律/42.6.2 完成前对齐标准流程/42.6.3 变更记录要求/42.6.4 零新键机制）;既有 42.1-42.5/43.x 零改动 | grep '^42.6' + diff 面 |
| VC-3 | SKILL C32 行+Rule 42 摘要行 42.6 措辞+模板配置表「对齐审查」行+mini-lite 豁免行;字面锚保全（Rules 1-39=2,1-4x=0） | grep 逐锚 |
| VC-4 | RL-11 在位（alignment 写入前/变更记录/未经校验锚断言）且 selftest-review-library 全 PASS（RL-01..11）;全量回归（40 脚本）0 FAIL 且 PASS ≥639（主进程定数） | bash 全量 |
| VC-5 | 合并部署 push 清理闭环+部署位升级内容分发（grep 写入前锚部署位命中） | smart-merge-back+ls-remote+部署位 grep |
| VC-6 | 边界零回归+CR APPROVED（隔离审查;CHANGES_REQUESTED→fix-phase） | CR 结论+diff 面 |

**终验规则**: 全 VC → COMPLETE;遗留 → PARTIAL;3 次无效 → BLOCKED（41.4 前置）。

## ⚠️ 执行范围限制
| 类别 | 允许 | 禁止 |
|------|------|------|
| 技能 | review-library/alignment-review/SKILL.md（新增两段+触发条件加 1 条;既有四要素/清单零改动） | 池内其他 10 技能 |
| 条款 | references/critical-rules.md EOF 后 42.6 节追加（42.1-42.5/43.x 零改动） | 其他任何行 |
| SKILL | SKILL.md C32 行新增+Rule 42 摘要行行内追加 42.6 措辞 | 其他行 |
| 模板 | templates/task_plan.md 配置表+1「对齐审查」行;mini-lite-type.md+1 豁免行 | 契约标记 |
| 测试 | scripts/selftest-review-library.sh（RL-11+头注释计数 10→11 条级联）;scripts/selftest-reliability-institution.sh（R-01 锚 42 计数 5→10 级联,B 类扩围 2026-10-01:42.6 追加的级联遗漏,S3 实测暴露）;scripts/selftest-skill-split.sh（T-主 439→440 级联,B 类扩围:C32 行 +1）;scripts/selftest-self-resolution.sh（SR-11 宽容正则根治,B 类扩围 2026-10-01:label token 三连断 v098→v099→v102,改 task-v099|task-v10x 宽容正则,断言语义不变） | 其他 selftest |
| 配置 | （无） | config.json 零改动 |

## 📚 必要知识储备
| 名称 | 定位 | ☑ |
|------|------|---|
| alignment-review 现文（触发段/四要素结构） | review-library/alignment-review/SKILL.md | ☑ |
| Rule 42 现文（42.5 末条=42.6 追加点） | CRIT :414-432 | ☑ |
| C30/C31 行形态 | SKILL :195-196 | ☑ |
| SR/RL selftest 范式 | scripts/selftest-self-resolution.sh | ☑ |
| 模板配置表/豁免行形态 | templates/task_plan.md:25-31;mini-lite :7-8 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: alignment-review 当前是「事后审查」定位——文档已经被错误追加/漂移后才审查,修正成本高。用户要求验证优先（shift-left）:写入前即校验版本一致性,冲突先整理再写入,输出变更记录;且对齐审查要成为标准收尾流程（完成前对所有文档跑一遍）。升级后 alignment 从「审查技能」变为「写入闸门+审查技能」,问题解决。
- [x] 能交付 / [x] 唯一目标 / [x] 方法清晰

## Current Phase
（终态）Phase 5 complete — outcome: COMPLETE

## Next Step
交付报告呈示。
主进程建 worktree（@5ddc317）+基线复测落 progress。

## 🧰 工具选择与编排（Rule 40）
| Phase | 工具面 | 理由 |
|-------|--------|------|
| P1 | ①③ | worktree/基线 |
| P2 | ③ executor S1（sonnet-1 技能升级判断型）→S2（sonnet-1 条款）→S3（haiku-1 锚行编辑）→S4（sonnet-1 selftest）串行 | 21.4 |
| P3 | ⑥ 主进程求和 | 白名单③ |
| P4 | ① git 全链 | — |
| P5 | ③ code-reviewer+②⑤ | CR+簿记 |

**workflow 判定**: 未命中（S1→S4 串行依赖+未点名 /workflow）→21.4 串行。**/goal 对齐**: Goal+VC 即证据源;40.3 披露照旧。

## Phases

### Phase 1: 基线 + worktree
- [ ] worktree @5ddc317,porcelain=0;基线复测（40 脚本 638/0+alignment 行数+RL 计数 10）
- **V-N:** VC-4, VC-6
- **Status:** complete
- **Executor:** 主进程（①③——白名单）

### Phase 2: 升级面（技能+条款+SKILL/模板+守护）
- [ ] S1: alignment-review 升级——触发条件段+1 条（写入动作前命中）;新增「## 写入前校验闸门（验证优先）」段（五步:读最新态→对照待写内容→识别前后版本不一致/重复/过期→按最新有效版本合并+删除冗余→输出变更记录;含用户原话锚「未经一致性校验，不直接追加新内容」）;新增「## 变更记录输出」段（更新/合并/删除/依据版本/残留冲突五要素）
- [ ] S2: CRIT Rule 42 末尾追加 42.6（对齐审查前置与收尾消费）:42.6.1 写入前校验纪律（验证优先,未经校验不追加）/42.6.2 任务完成前对齐标准流程（alignment-review 过所有任务文档）/42.6.3 变更记录输出要求/42.6.4 机制（C32+RL-11,零新键）
- [ ] S3: SKILL.md C32 行（Rule 42.6 消费）+Rule 42 摘要行行内追加 42.6 措辞;templates/task_plan.md 配置表+1「对齐审查」行+mini-lite 豁免行
- [ ] S4: selftest-review-library.sh RL-11（alignment 含「写入前」「变更记录」「未经一致性校验」锚）+头注释与计数级联（RL 断言 10→11 条）
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** executor（S1 sonnet-1/S2 sonnet-1/S3 haiku-1/S4 sonnet-1;21.4 串行）
| ID | 目标 | 执行体 | 建议档位 | 输入 | 验收 | 预估 | 状态 |
|----|------|--------|---------|------|------|------|------|
| S1 | alignment 升级验证优先 | executor | sonnet-1 | 任务书本计划触发/闸门/变更记录规格+现文 | 用户原话锚+两新段+触发+1 条;四要素/清单零改动 | 15min | pending |
| S2 | Rule 42.6 追加 | executor | sonnet-1 | 42.6 四子条定义 | grep '^42.6'=4 或行内四锚;42.1-42.5/43 零改动 | 15min | pending |
| S3 | C32+摘要+模板行+豁免行 | executor | haiku-1 | C30/C31 形态+配置表 :25-31+mini-lite :7-8 | 四落点 grep;字面锚保全 | 10min | pending |
| S4 | RL-11+计数级联 | executor | sonnet-1 | RL 范式现文 | RL-11 PASS;全脚本 11/0;bash -n | 10min | pending |

### Phase 3: 全量回归
- [ ] 主进程定数（40 脚本双形态求和: selftest-review-library 11/0+全量 0 FAIL,PASS ≥639）
- **V-N:** VC-4
- **Status:** complete
- **Executor:** 主进程（③）

### Phase 4: 合并+部署+push+清理
- [ ] 预检→smart-merge-back --deploy（部署位「写入前」锚 grep）→push（ls-remote 终验）→清理 0/0
- **V-N:** VC-5
- **Status:** complete
- **Executor:** 主进程（①②③）

### Phase 5: CR Gate + 终验簿记
- [ ] CR（code-reviewer 隔离审全量 diff）;APPROVED 才终验
- [ ] 簿记: verification/INDEX/notepad/memory/check-complete（簿记提交后）
- **V-N:** VC-6
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）+ 主进程（②⑤）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（P1 复扫） |
| `isolation` | worktree |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v102-alignment-upgrade |
| `branch` | wt/task-v102-alignment-upgrade（@5ddc317） |
| `merge_back` | pending |

## 📊 FMEA
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P2 | 42.6 追加位置错（插进 42.5 与 43 之间外的位置）或伤 43.x | 8 | 3 | 3 | 72 | EOF 前 42.5 行后定位+diff 单行核验;伤及 restore 重写（⑥） |
| P2 | S1 升级破坏既有四要素（RL-07 循环断言） | 7 | 3 | 3 | 63 | 新增段=纯增量,既有段零改动;RL-07 复跑验证 |
| P3 | RL-11 断言锚与 S1 实文漂移 | 6 | 4 | 3 | 72 | S4 动手前先 Read S1 产出实测锚;FAIL 单断言修 |
| P4 | 部署 DRIFT/push 冲突 | 6 | 3 | 3 | 54 | fail-closed+ls-remote 终验（v099 教训） |

## 🔁 原生 Todo 同步
| Phase | 已建 | 备注 |
|-------|------|------|
| P1-P5 | S1 映射批准后建 | 5 条 |

## Key Questions
1. 写入前闸门与既有「完成前对齐门」关系？（答: 42.6.1 是写入时点的闸门（每次文档更新都过）,42.6.2 是任务收尾的标准流程（完成任务前全文档过一遍）——两点一线,闸门防新增漂移,收尾清存量）
2. 模板「对齐审查」行与「质量审查工具」行关系？（答: 并列两行——质量审查工具行登记 42 检测结论（审查技能选型）,对齐审查行登记 42.6 消费义务（收尾流程））
3. RL-11 为何加断言不加 registry 行？（答: selftest-review-library.sh 已登记（v100）,本任务只改其内容+1 断言;registry 登记脚本名非断言数）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: 写入前闸门落在 alignment 技能内而非新 hook | 42.6 判定面=LLM 行为（与 v087-v100 零新键范式一致）;hook 化属过度工程,RL-11 静态守护+C32 消费足够 |
| silent: 42.6 追加进 Rule 42（非新 Rule 44） | 对齐消费是 Rule 42 检测-补充-登记链的自然延伸;避免规则家族膨胀 |
| silent: push 沿用 09-30 持久指令 | 三度确认 |
| silent: 主进程直接撰写计划 | 白名单②;plan-writer 三度死亡 |
| silent: 摘要/模板改动新会话生效 | 快照语义 |
| silent: B 类扩围——R-01/T-主 两处断言级联（S3 实测暴露） | 42.6 追加与 C32 行的计数级联在计划期漏估;断言语义零改动仅锚值/上限更新;v097-v101 锚定级联教训连续第 N 次实证 |
| silent: SR-11 宽容正则根治（label token 三连断） | 与 SR-12 同款根治模式;断言语义不变（级联 label 存在性） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
|       | 1       |            | → progress.md Error Log |

## Notes
- 用户原话三句是 VC-1 的锚:「必须先进行版本一致性校验」「未经一致性校验，不直接追加新内容」「输出变更记录」——S1/S2 撰写必须含字面
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
| `rollback_point` | master@5ddc317 |

## 📊 委派统计
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 | 1 / 5（P2;P5-CR 部分） |
| 主进程直做 | P1/P3/P4/P5（①②③⑤——白名单） |
| 委派率 | 预期 0.2 → 25.4a 判定 |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|-----------|------|
| 1 | 2026-10-01 | executor | P2-S1 alignment 验证优先升级 | done | 75 行（+26/-1 注释行）;写入前闸门五步+变更记录五要素+触发 +1;既有零改动;selftest 10/0 | 01-exec-p2s1.md+主进程抽验 | findings Requirements | plans/task-v102-alignment-upgrade/subagent-state/01-exec-p2s1.md | - / 0 / ☑ |
| 2 | 2026-10-01 | executor | P2-S2 Rule 42.6 追加 | done | 五段纯增（432→437）;五措辞各 1;42.5/43 零变化 | 02-exec-p2s2.md+主进程复核 | findings Research | plans/task-v102-alignment-upgrade/subagent-state/02-exec-p2s2.md | - / 0 / ☑ |
| 3 | 2026-10-01 | executor | P2-S3 C32+摘要+模板行+豁免行 | done | 4 落点全中;字面锚保全;partial 正确上报 2 处级联缺口（归 S4） | 03-exec-p2s3.md | findings Research | plans/task-v102-alignment-upgrade/subagent-state/03-exec-p2s3.md | - / 0 / ☑ |
| 4 | 2026-10-01 | executor | P3-S4 RL-11+三处计数级联 | done | RL 11/0+R-01 10 级联+T-主 440 级联;SR-11 宽容正则根治由主进程白名单③处置（B 类扩围） | 04-exec-p3s4.md+主进程全量 639/0 | findings Research | plans/task-v102-alignment-upgrade/subagent-state/04-exec-p3s4.md | - / 0 / ☑ |
| 5 | 2026-10-01 | executor（22.3① 改派,原 code-reviewer ECONNREFUSED×2） | P5 CR Gate | done | **APPROVED**（0 P0/P1,2 P2 观察项）;4 脚本机器面复跑全 PASS | 05-cr-p5.md | verification CR 段 | plans/task-v102-alignment-upgrade/subagent-state/05-cr-p5.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置
| 字段 | 值 |
|------|-----|
| **chain_mode** | single |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 已知类型;终验处置: 不沉淀理由（34.3 不命中,终验登记）
