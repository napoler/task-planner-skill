# A · 跨文件引用完整性 + 计数声明算术 审计检查点

- 审计对象：/mnt/data/dev/task-planner-skill 技能族（15 技能，当前纪元 Rule 1-96，2026-10-24）
- 审计范围：各技能 SKILL.md + references/*.md + README（active，剔除 skills/task-planner/.backup/**）
- 执行体：只读审查；本文件为唯一写权限产出（checkpoint）
- 数法说明：规则号按各 critical-rules-*.md 顶层 `### NN ` 标题锚计数；引用存在性以「引用文件所在目录」为基准 resolve（并辅以 skill-root / repo-root 基准交叉），`test -f/-d`；纯示例、URL 占位、`*` 通配 glob、平台家目录（~/.zcode、<platform-home>）均按铁律忽略。

## 计数声明核实（实证结论）

- [OK] task-planner/SKILL.md:9/:210「核心在位 14 条（1,2,3,5,19,20,26,51,62,66,80,81,82,83）」——14 项；critical-rules.md 顶层 `### NN` 锚实测恰为 1,2,3,5,19,20,26,51,62,66,80,81,82,83 共 14 条全文在位。数字正确。
- [OK] 「其余 79 条已按域迁至 11 卫星」——逐卫星顶层锚计数：dispatch=12, discipline=46, media=3, research=3, template=4, collab=3, cost=1, resume=1, progress=1, drift=4, verification=1；合计 = 79。且 96 − 14(核心) − 3(77/78/79 预留未落地，见 critical-rules.md:140 注) = 79。数字正确。
- [OK] task-discipline/SKILL.md:15/:79/:90「共 46 条」——critical-rules-discipline.md 顶层锚实测 46 条（含 95，不含 75）。数字正确。
- [OK] 「11 卫星」——skills/*/references/critical-rules-*.md 实为 11 个文件。数字正确。
- [N/A] 「|95|」式行内注记——全仓 grep 无 `|9x|` 形态注记，未构成缺陷。
- 路由表 Rule 锚抽查（≥10）：collab R91、discipline R95、dispatch R96、verification R84、progress R30、resume R24、cost R17、drift R61/R64、media R47——各卫星文件 `Rule NN`/`### NN` 标题锚全部在位（grep 命中 ≥2）。全文归属正确，无缺失。

## 发现明细

### P1（必须修）

- A-01 | P1 | skills/task-planner/references/critical-rules.md:194 | task-discipline 卫星路由索引列「…92,93,94）」缺 Rule 95 | 实测 critical-rules-discipline.md 顶层含 `### 95`（line 617），task-planner/SKILL.md:197 与 :210 口径均已列 95 | 修法：line 194 索引末尾补 `,95`（45→46 条）。
- A-02 | P1 | skills/task-planner/references/critical-rules.md:198 | plan-collab-router 卫星路由索引列「Rule 39,40）」缺 Rule 91 | 实测 critical-rules-collab.md 顶层含 `### 91`，SKILL.md:201 口径已列 39,40,91 | 修法：line 198 末尾补 `,91`（2→3 条）。

### P2（应当修）

- A-03 | P2 | skills/task-planner/SKILL.md:197 | task-discipline 调用条件用范围「69-76」含 Rule 75，但 75 归属 plan-research-router（critical-rules-research.md 顶层 `### 75`；critical-rules.md:194 亦正确排除 75）| 修法：把 `69-76` 改 `69-74,76`（与 critical-rules.md:194 一致），避免 75 双归属。
- A-04 | P2 | skills/task-planner/SKILL.md:206 vs 225/230 | 同文件双形态不一致：verification-gate 的 critical-rules-verification.md 在路由表用 `../verification-gate/references/critical-rules-verification.md`（L206），散文指针却用裸 `references/critical-rules-verification.md`（L225、L230），裸形自 SKILL.md 目录不可解析（task-planner/references/ 无此文件）| 修法：L225/L230 改 `../verification-gate/references/...` 与 L206 对齐。
- A-05 | P2 | skills/task-planner/SKILL.md:266 vs 242 | 同文件双形态不一致：agent-coverage.md 在指针表用 `../task-dispatch/references/agent-coverage.md`（L266），散文用裸 `references/agent-coverage.md`（L242，且同行还裸 `references/split-pattern-library.md`）| 修法：L242 两处裸引用改 `../task-dispatch/references/...`。
- A-06 | P2 | skills/task-planner/SKILL.md:238 | 裸 `references/research-routing.md` 自 task-planner 目录不可解析（该文件在 plan-research-router）；本文件无 `../plan-research-router/...` 对应形态 | 修法：改 `../plan-research-router/references/research-routing.md`。
- A-07 | P2 | skills/plan-cost-guard/SKILL.md:29 | 裸 `task-planner/references/critical-rules.md` 跨技能指针自 plan-cost-guard 目录不可解析（同技能 references/cost-control.md:168、cost_log.md:7/69 均用 `../../task-planner/references/critical-rules.md`）| 修法：改 `../../task-planner/references/critical-rules.md`（L29 已自注「跨技能指针」，仅需修正基准形态）。
- A-08 | P2 | skills/task-discipline/references/execution-recall-card.md:2 | 裸 `task-planner/references/critical-rules.md` 自本目录不可解析（同卫星 critical-rules-discipline.md 均用 `../../task-planner/...`）| 修法：改 `../../task-planner/references/critical-rules.md`。
- A-09 | P2 | skills/verification-gate/references/critical-rules-verification.md:7 | 裸 `task-planner/references/critical-rules.md` 自本目录不可解析 | 修法：改 `../../task-planner/references/critical-rules.md`。

### INFO（仅供参考）

- A-10 | INFO | skills/plan-template-kit/references/template-guide.md:86 | 文中「统一库 lib/plan-parse.sh」路径不精确：实际文件在 skills/task-planner/scripts/lib/plan-parse.sh（task-planner/lib/ 根下无 plan-parse.sh）| 建议：注明 `scripts/lib/plan-parse.sh` 全路径。
- A-11 | INFO | skills/verification-gate/SKILL.md:39 | `scripts/check-x.sh` 为示例占位（行尾 `<!-- 示例占位 -->`），非真实引用 | 无需修，仅登记。
- A-12 | INFO | skills/plan-collab-router/references/critical-rules-collab.md:35、critical-rules-drift.md:65、critical-rules-discipline.md:387/390、task-dispatch/references/agent-coverage.md:40 | 散文裸 `companion/agents/*.md`（plan-writer/decision-arbiter/drift-checker）自卫星目录不可解析，实际在 task-planner/companion/agents/（均已 test -f 在位）| 建议：可加 `../task-planner/` 前缀，或明示「companion 属 task-planner 主技能」。

## 已核实无问题项（防误报）
- task-planner/README.md:254 `../task-dispatch/scripts/selftest-*.sh`、critical-rules-media/template/dispatch 的 `scripts/check-*.sh`、`selftest-*.sh` 等 = 通配 glob，非具体目标，忽略。
- research-routing.md:33 `.../pull/<n>` 为 GitHub URL 占位，非文件引用，忽略。
- 通配 glob 中所有命名具体脚本（如 critical-rules-template.md 引用的 8 个 scripts/*.sh、templates/variant/*.md、config.json）经 skill-root / `../../task-planner/` 基准 `test -f` 全部在位。
- 15 技能 SKILL.md + 全部 critical-rules-*.md 顶层规则锚无 77/78/79 落地（与 critical-rules.md:140 预留说明一致）。
