# Knowledge Brief — task-v100-review-library

## §1 任务速览与核心概念
- 任务一句话: 在 skills/task-planner/review-library/ 建 10 个通用质量审核技能（每个 SKILL.md 40-70 行,四要素: frontmatter/触发条件/审查清单≥8条/APPROVED 输出合约）+ Rule 42.2 检测链三级→四级（插入内置兜底池层）+ C30 同步 + selftest 守护,合并部署 push。
- 10 技能清单: general-review / code-quality-review / test-quality-review / security-review / performance-review / content-quality-review / documentation-review / data-quality-review / ui-quality-review / release-review
- 概念: 兜底池=Rule 42.2 检测链第④层（环境 agents 均未命中时先查内置池,池未命中才走 42.3 补建）;兜底池由 task-planner 自身消费（Read/Skill 加载）,无需 ZCode 原生发现。

## §2 已验证关键事实
| 事实 | 证据 |
|------|------|
| master HEAD=539adcc | git rev-parse 实测 2026-09-30 |
| SKILL.md=439 行 / critical-rules.md=432 行 | wc 实测 |
| Rule 42.2 在 CRIT :420,标题「三级检测顺序（项目级→用户级→环境既有 agents，均未命中=缺口）」 | sed 实测 |
| C30 行在 SKILL :195,含「三级顺序」措辞 | grep 实测 |
| review-library/ 不存在（待建） | ls 实测 |
| 全量基线 38 脚本 616/0（P1 worktree 复测为准） | v099 交付记录 |
| registry.tsv=40 行 | wc 实测 |
| Rule 42.3 补充合约=「补充动作作为 S-unit 登记」 | CRIT 实测 |

## §3 关键文件锚点表
| 路径 | 行号 | 摘要 |
|------|------|------|
| references/critical-rules.md | :420 | Rule 42.2 三级检测原文（改写目标行） |
| references/critical-rules.md | :414-432 | Rule 42 全节（禁动区对照） |
| SKILL.md | :195 | C30 行（「三级顺序」措辞同步点） |
| scripts/selftest-self-resolution.sh | 全文 | SR 范式（新 selftest 照同构） |
| scripts/selftest-registry.tsv | :1-40 | 四列格式（+1 行对齐） |
| plans/task-v099-reliability-institution/notepad-learnings.md | 🚫段 | Rule 32 否决出处（v099 已登记） |

## §4 易错点与禁止假设
1. 42.2 改写禁伤①②③层与「均未命中=缺口」语义——diff 单行核验
2. 「Rules 1-39」字面 2 处不动;新增文本禁「1-4x」越界字面
3. 新 selftest 断言锚先 grep 实测再写入（v099 教训）;Total 双形态求和（v098 教训）
4. 10 技能非空壳:每领域清单 ≥8 条具体检查项,禁通用废话清单
5. registry 行数断言用 rows=actual 动态口径;恰 10 目录计数是硬断言（11 或 9 都 FAIL）
6. C30 行内改写仅动「三级」措辞,其余保全（免伤 C29/C31）
7. push 成功判据=ls-remote 远端 HEAD 比对（v099 教训）
8. 兜底技能的输出合约必须与既有 CR 家族一致（APPROVED/CHANGES_REQUESTED+P0-P2 分级）——自洽性

## §5 S-unit 材料包索引
| S-unit | 读 brief 哪节 | 额外材料 |
|--------|--------------|----------|
| P2-S1 | §1 §4 | CRIT 43.1 条文（证据要求引用源） |
| P2-S2/S3/S4 | §1（清单）+S1 产出范式 | 前序 S-unit 产出 |
| P2-S5 | §3（:420/:195 锚） | — |
| P3-S6 | §4 | selftest-self-resolution.sh 全文范式 |
