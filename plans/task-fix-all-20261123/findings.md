<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-fix-all-20261123

- task_id: `task-fix-all-20261123`
- 时间: created_at=2026-11-22T17:03:36Z / updated_at=2026-11-22T19:01:30Z

## Requirements
- 修复8个selftest FAIL（基线重锁：registry/编号/行数门槛/重锁行为），区分基线漂移与功能回归，禁止作弊式降断言
- 修复4项文档债务：task-planner脚本索引/task-dispatch规则表/task-discipline引用面/plan-resume证据模板
- todo-skill失败态从completed改blocked+留痕；frontmatter-linter加skill档适配；部署位同步§4.6

## Findings
| id | text | source | tags |
|---|---|---|---|
| F-ALL | 8 FAIL分A基线漂移3/C测试env泄漏2/D真实待补1/连带2，无功能回归；registry孤儿是根因源连带4脚本；4组修复4 commits；叠加后主进程全量复跑104/104全绿；末次BP-08上限450→470同步文档债务+19行。证据 forensics/ |  |  |
| F-FINAL | 终验PASS：合并后主仓全量selftest 104/104 FAIL0；独立Verifier 7项全PASS(HIGH)，证伪分母削减/断言删除/产品逻辑改动/越权；三方sha256一致(5b9ecdc3)；merge 579c59b 13文件；drift最终ALIGNED。Verifier非阻断发现T13 env口径经Read确认为st13_exec测试设计意图(独立sid测陈旧提醒豁免)，非残留，按YAGNI不改。 |  |  |

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- 授权落实 frontmatter-linter skill 档适配已落地：改 ~/.zcode/agents/frontmatter-linter.md 3 处（档位判定段/R1拆R1-agent+R1-skill/扫描范围标注/输出模板[agent|skill]），diff 仅预期变化，备份 .bak-tier-20261123-021818。行为验收：顶层 skill 实测 132 个（递归 431），R1-skill ERROR=0、缺 model/tools 误报=0；agent 档抽样 5 个全缺 tools 仍报 ERROR（放宽未污染 agent 档）；R4 WARN 规则已定义未观察到触发样本。子代理报顶层 143 系口径差，按主进程实测 132/431。 — frontmatter-linter agent 复扫(agent_aaed3351)+主进程 find/grep 抽验+diff -u 备份
- 8 FAIL分A基线漂移3/C测试env泄漏2/D真实待补1/连带2，无功能回归；registry孤儿是根因源连带4脚本；4组修复4 commits；叠加后主进程全量复跑104/104全绿；末次BP-08上限450→470同步文档债务+19行。证据 forensics/
- 终验PASS：合并后主仓全量selftest 104/104 FAIL0；独立Verifier 7项全PASS(HIGH)，证伪分母削减/断言删除/产品逻辑改动/越权；三方sha256一致(5b9ecdc3)；merge 579c59b 13文件；drift最终ALIGNED。Verifier非阻断发现T13 env口径经Read确认为st13_exec测试设计意图(独立sid测陈旧提醒豁免)，非残留，按YAGNI不改。

## Technical Decisions
| Decision | Rationale |
|---|---|
| frontmatter根因修法：给linter加skill档规则（skill合法惯例=name+description+allowed-tools，不强制model/tools），21技能不批量补字段 | 根因是linter用agent契约扫skill；批量补字段污染skill惯例 |
| 授权同步部署位（~/.zcode/skills与~/.agents/skills的task-planner SKILL.md），纯内容同步；git master/main按既有裁决不动 | 用户未答→按推荐项自主决策并登记；git main是无关封存导入勿合 |
| 实现类任务强制worktree隔离：wt/task-fix-all-20261123@/mnt/data/dev/task-planner-skill/tmp/worktrees/task-fix-all-20261123，基线e3206b3 | 改运行中技能基础设施，宪法§十一强制隔离 |
| 授权落实=落实 frontmatter skill 档提案（第1项）；ledger-append.sh 去留与 40 提交 push 不在本次范围，交回用户裁决 | 用户原话仅授权落实；上一轮交付第1项用授权后改措辞、第2/3项用裁决/决定时机措辞，区分明确 |

## Issues Encountered
| Issue | Resolution |
|---|---|
| （本任务暂无问题记录） |  |

## Resources
- （本任务暂无资源引用）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
## 本任务 tag 倒排引用
- （本任务暂无tag 引用）
