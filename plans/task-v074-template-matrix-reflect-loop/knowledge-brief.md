# Knowledge Brief — task-v074-template-matrix-reflect-loop（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：在 task-planner 仓落地 Rule 33（解决→反思→验证迭代循环）+ Rule 34（模板矩阵选取门控+沉淀入库）及配套脚本/config/init 改进，全量 selftest 0 FAIL 后合并部署 3 实体位。
- 背景/动机：模板矩阵缺机器门控、问题解决后无反思验证闭环、沉淀无入库通道；SKILL.md:524 "自动路由"声明与实际 init-session.sh 位置参数实现存在语义漂移。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 三档键 | config.json 键 enum enforce/warn/off + 默认 warn + selftest 静态守护 + 检查脚本消费（Rule 31.6/32.5 既有范式） |
| 四点同步 | Rule 34.2：init VALID_TYPES + template-mapping 决策树/清单 + plan-writer 映射表 + SKILL 模板节，四处一致（init 动态化后降为三点） |
| REFLECT-GATE | check-complete.sh 终验新段落：frontmatter 声明 reflect_verify: required 的任务校验 progress.md 反思记录行 |
| check-template-type.sh | 新脚本：attest LOCK 前校验 frontmatter template_type ∈ 白名单（动态派生 variant/ 目录），非法/缺失拒绝锁定，--skip 逃生 |
| selftest 双件 | selftest-reflect-verify.sh + selftest-template-lifecycle.sh，写法对齐 selftest-veto.sh（68 行，ok/bad helper + 编号断言 + 末行 Total） |

## §2 已验证关键事实
| 事实 | 证据 file:line / URL | 影响 |
|------|---------------------|------|
| templates/variant/ 现有 12 变体（research/diagnostic/writing/publish/code-edit/refactor/bugfix/migration/test-writing/deployment/performance-tuning/schema-migration） | skills/task-planner/templates/variant/ 目录 ls（2026-09-15） | 34.3 沉淀须先对照 12 类防重复（34.5） |
| template-mapping.md 决策树在 :9-24，§六清单+互斥表在 :123-151 | references/template-mapping.md:9-24 | 四点同步之二落点 |
| init-session.sh：TEMPLATE_TYPE="${2:-}" :56，VALID_TYPES 硬编码 :63，variant 路由 :65-79 | scripts/init-session.sh:56,63,65-79 | P4 S1 改造点；SKILL.md:524 称"自动"=语义漂移源 |
| critical-rules.md 当前最大 Rule 32（:260-268），范式=NN.M 动词短语+末条机制（config 三档键+selftest）；Rule 31 在 :249-258 | references/critical-rules.md:249-268 | Rule 33/34 直接追加 :268 之后，结构照抄 31.6/32.5 |
| 检查清单最大 C20（SKILL.md:194） | SKILL.md:193-194 | 新增 C21/C22 落点 |
| SKILL.md 联动点：索引行 :9 含"Rules 1-32"字样、:211-212 特判段、:294-295 摘要行；当前 529 行 | SKILL.md:9, 529(wc -l) | P5 改动锚点；≤500 行净增纪律=只能行位替换级改动 |
| check-complete.sh LEARNING-GATE 段 :579-680（含 :575 起注释头、档位解析 env>config>warn） | scripts/check-complete.sh:575-585 | REFLECT-GATE 插在 LEARNING-GATE 之后 |
| config.json 是 JSON-Schema：properties 数组式定义 + :429 additionalProperties:false；veto_enforce 键在 :289（最新键范式）；:394-419 存在既有重复键脏点 | config.json:289,429 | 新键挂 properties 且勿修脏点（最小 diff） |
| selftest-veto.sh VT-10（:13,51）与 selftest-error-loop.sh EL-11（:14,59）锚定 "Rules 1-32"/`Rules 1-3[12]` | 两脚本 grep 实测 | 加 Rule 33/34 后必须同步这两处断言，否则回归 FAIL |
| attest-plan.sh 90 行，LOCK 主流程 :56-73，含 check-plan-dispatch 集成先例（:63 拒绝锁定+--skip 逃生） | scripts/attest-plan.sh:56-73 | check-template-type.sh 集成范式直接照抄 :63 |
| selftest 库 14+ 个脚本、无聚合 runner，全量=逐个 bash；当前基线 235 PASS/0 FAIL | scripts/selftest-*.sh ls + v073 commit 7ef6214 前 c132c92 | P1 基线记录；P5 回归标准 |
| 遗留 wt/task-v072 worktree（901b68b）与分支在位，已交付 | git worktree list 实测 | P1 建 v074 时禁止触碰/清理 v072 |

## §3 关键文件锚点表
| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-planner/references/critical-rules.md | :249-258 | Rule 31 全文（31.1-31.6），机制小节 31.6 含 error_loop_enforce 三档+selftest-error-loop 守护 |
| 同上 | :260-268 | Rule 32 全文（32.1-32.5），32.5 机制=veto_enforce+selftest-veto+notepad 消费侧 |
| skills/task-planner/config.json | :289 | veto_enforce 键定义（type/enum 三档/default warn/description 长文案范式），新键模板 |
| 同上 | :429 | "additionalProperties": false — 新键必须挂 properties 内 |
| skills/task-planner/scripts/check-complete.sh | :575-585 | Learning Gate 段头注释（列识别/占位兼容/env>config>warn 档位解析范式） |
| 同上 | :579-680 | LEARNING-GATE 完整段（awk 状态机范式：gawk 区间陷阱规避） |
| skills/task-planner/scripts/attest-plan.sh | :56-73 | attest 主流程：resolve→hash→check-plan-dispatch(:63 拒绝+--skip)→写 .plan-attestation（v068 附 sid） |
| skills/task-planner/scripts/init-session.sh | :56-79 | TEMPLATE_TYPE 位置参数 + VALID_TYPES 硬编码 + variant 路由（合法→复制、非法→warn 回落 generic） |
| skills/task-planner/scripts/selftest-veto.sh | 全文 68 行 | ok/bad helper + VT-NN 编号断言 + 末行 "Total: X passed, Y failed" 范式（双件 new selftest 模板） |
| skills/task-planner/SKILL.md | :9, :193-194, :211-212, :294-295, :524 | 索引行"Rules 1-32"/C19-C20/特判段/摘要行/init"自动"路由声明（漂移源） |
| skills/task-planner/references/template-mapping.md | :9-24, :123-151 | 决策树 + §六 12 类清单与互斥表（Rule 34.2 同步之二） |
| skills/task-planner/companion/agents/plan-writer.md | :46-77 | 13 类映射表（Rule 34.2 同步之三） |
| plans/INDEX.md / .zcode/ledger/task-planner-maintenance/task-planner-maintenance.jsonl | 全 | P6 簿记落点（INDEX 登记 v074 + ledger done 条目） |

## §4 易错点与禁止假设清单
1. 加 Rule 33/34 后忘记同步 selftest-veto.sh VT-10（:13,51）与 selftest-error-loop.sh EL-11（:14,59）的 "Rules 1-32"/`Rules 1-3[12]` 锚点 → 全量回归 FAIL；修法 P4 S3 先 grep -rn "Rules 1-3" scripts/ 扫全库再改齐。
2. check-template-type.sh 白名单若硬编码而 init-session.sh 动态派生 → 双权威源漂移（门控与 init 判定不一致）；裁定=两者同源自 variant/ 目录动态派生。
3. config.json 在 :394-419 有既有重复键脏点 — 本任务不顺手修（最小 diff），新键只追加 properties 条目，jq 语法校验过即可。
4. SKILL.md 当前 529 行、纪律"≤500 行净增" — 只能行位替换级改动（索引行/摘要行压缩既有措辞抵扣追加），禁止大段新增。
5. 禁止假设 REFLECT-GATE 判定格式可随意定 — 必须在 33.3 写死 progress.md 反思记录行格式（建议 `[reflect]` 标记行），selftest 锚断言与之对齐。
6. 禁止触碰/清理遗留 wt/task-v072 worktree 与分支（信号②③）；v074 worktree 用新路径 /mnt/data/dev/task-planner-skill-worktrees/v074。
7. 禁止假设全量 selftest 有聚合 runner — 实际逐个 bash scripts/selftest-*.sh，回归结果手工汇总 N PASS/0 FAIL。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「P4/P5 selftest 锚定级联 RPN120」与「P3/P4 双权威源漂移 RPN140」行。

## §5 S-unit 材料包索引
| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P1-baseline | §2（基线 235 事实）+ §4.7 | 无（跑全量 selftest） |
| P2-S1 | §1（三档键）+ §3（critical-rules :249-268 锚） | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md |
| P2-S2 | §2（config:289/:429 事实）+ §3（check-complete :575-585） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh |
| P3-S1 | §1（四点同步）+ §3（mapping:9-24,123-151） | /mnt/data/dev/task-planner-skill/skills/task-planner/references/template-mapping.md |
| P3-S2 | §2（VALID_TYPES :63 事实）+ §4.2（单一事实源裁定） | /mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/ |
| P3-S3 | §2（attest :56-73 事实）+ §3 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh |
| P4-S1 | §2（init :56-79 + SKILL:524 漂移事实） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh |
| P4-S2 | §2（基线事实）+ §3（selftest-veto 全文范式） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-veto.sh |
| P4-S3 | §4.1（VT-10/EL-11 行号） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-veto.sh + selftest-error-loop.sh |
| P5-S1 | §2（SKILL.md 529 行 + 联动锚点事实） | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md |
| P5-S2 | §3（mapping/plan-writer 锚） | /mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/plan-writer.md |
| P5-S3 | §4.7（无聚合 runner） | progress.md Selftest Log 段落 |
