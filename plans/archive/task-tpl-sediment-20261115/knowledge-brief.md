# Knowledge Brief — task-tpl-sediment-20261115（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-tpl-sediment-20261115/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：为 task-planner 建成「执行路径→模板」主动沉淀机制（Rule 34.8/34.9 增量）+ 新增 plan-template-advisor 项目模板适配子技能，以本仓 dogfood 产出首个过审查门的项目级模板。
- 背景/动机：用户诉求——执行期主动沉淀已验证路径为模板、模板过严格审查门、项目级模板可持续适配沉淀复用（专档 #1）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| variant 模板 | templates/variant/*-type.md，template_type 白名单源，动态派生（check-template-type.sh:17） |
| 项目级模板 | `<项目>/.zcode/plan-templates/`（或 .claude 位）下按文件名覆盖内置+并入白名单（init-session.sh:65-97,667-679） |
| 候选暂存 | 过审查门前模板候选留在计划目录 template-candidate/，禁入官方库 |
| 审查门 G1-G4 | G1 结构 lint/G2 render 冒烟/G3 独立审查派发/G4 官方级联四点+计数+selftest |
| 106.1a 三规约 | 插段前 grep 段清单/new_string 必含锚行子串/Edit 后结构回读（判例 task-anchor-eread） |

## §2 已验证关键事实
| 事实 | 证据 file:line / URL | 影响 |
|------|---------------------|------|
| variant 共 30 个，白名单动态派生无硬编码 | check-template-type.sh:17；ls variant/ 实测 | 不加官方 variant 则计数串「30 个」不动 |
| 项目级模板覆盖+白名单并入为原生机制 | init-session.sh:65-97,667-679,707-715 | 特性 B 沉淀位零脚本复用；advisor 只写 *-type.md 禁覆盖核心计划文件模板 |
| Rule 34.3 触发仅终验、34.4 无审查门无暂存 | critical-rules-template.md:11-22 | 特性 A=增量补 34.8（执行期触点+暂存+审查门）/34.9（项目沉淀位） |
| TL-17 断言 template-guide 含「30 个」 | selftest-template-lifecycle.sh:198-204 | 官方 variant 增删必同步计数；本任务不动官方库 |
| Rule 编号账本已至 107 | plans/.rule-reservations.jsonl（107 landed task-serial-sync-20261115） | new_rule 留空，增量挂 34 族 |
| --deploy 仅覆盖 task-planner 目录→3 槽位 | smart-merge-back.sh:389,470 | 新卫星目录须 install-stub SATELLITE_SKILLS+手工 cp |
| --deploy 槽位=3（zcode/claude/opencode），install-stub 注释四宿主含 cursor | install-stub.sh:41,289 | 部署对账按实际清单逐位，cursor 位落盘核对 |
| 卫星 SKILL 最小形态=name+description | plan-template-kit/SKILL.md:1-40（40 行先例） | advisor 单文件最小合法 |
| 在途任务 clause-generalize scope 含 SKILL.md:229/core.md:107 行 | plans/task-clause-generalize-20261115/task_plan.md scope_files | 同文件不同区域，合并回并集解预案（FMEA） |

## §3 关键文件锚点表
| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/plan-template-kit/references/critical-rules-template.md | :11-22 | Rule 34 全文（34.1 门控/34.2 四点同步/34.3 触发/34.4 流程/34.5 防滥用/34.6 开关键/34.7 template-sense）；34.8/34.9 插入点=34.7 末行后 |
| skills/task-planner/scripts/init-session.sh | :65-97 | find_project_templates+copy_template 项目级优先逻辑 |
| skills/task-planner/scripts/init-session.sh | :570-730 | TEMPLATE_TYPE 解析+VALID_TYPES 并入项目 *-type.md |
| skills/task-planner/scripts/check-template-type.sh | :17 | 白名单动态派生行 |
| skills/task-planner/scripts/selftest-template-lifecycle.sh | :186-204 | TL-09 动态派生断言+TL-17「30 个」计数断言 |
| skills/task-planner/lib/install-stub.sh | :41 | SATELLITE_SKILLS 清单（加 advisor 名） |
| skills/task-planner/SKILL.md | :213 | 卫星路由表行（加 12 行）+「11 卫星」计数串 |
| skills/task-planner/references/critical-rules.md | :178,200 | 分层归属枚举/路由索引行（加 advisor） |

## §4 易错点与禁止假设清单
1. 禁止改既有 34.1-34.7 文本一字（只追加 34.8/34.9；104.1a 吞锚三规约：插段前 grep 段清单、new_string 含锚行子串、插后结构回读）
2. 禁止新增官方 variant 文件（不动「30 个」计数）；禁止新增 selftest 脚本/机器门/hook（文本优先铁律）
3. advisor 产出禁覆盖核心 7 计划文件模板（只写 `*-type.md`）；项目级模板名必须 `*-type.md` 后缀才进白名单
4. render 冒烟在 tmp/ 跑 init 会写会话 side 指针→须隔离 sid（env 伪造/事毕 set-active-plan 复原）
5. 部署位=3 槽位+cursor 位，逐位 diff=0 对账；禁整仓 add（pathspec 锁定）
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 2/4 同文件竞写」「Phase 3 冒烟指针污染」行

## §5 S-unit 材料包索引
| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P1-S1/S2 | §1+§2+§3 | plans/task-tpl-sediment-20261115/findings.md（F1-F10） |
| P2-S1-S5 | §3 锚点表+§4 | plans/task-tpl-sediment-20261115/clause-drafts.md（含级联 spec） |
| P2-S6 | §2 项目级机制行+§4 | plans/task-tpl-sediment-20261115/advisor-draft（P1-S2 产物） |
| P3-S1 | §4 全部 | plans/task-tpl-sediment-20261115/verification.md（门清单） |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）
| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| plan-template-kit | ~/.zcode/skills/plan-template-kit/SKILL.md | 模板生命周期域卫星（Rule 34 全文权威源） | 伴飞（P2 条款插改 S-unit 挂载） |
| alignment-review | ~/.zcode/skills/alignment-review/SKILL.md | 收尾对齐审查（Rule 42.6 标准收尾） | 主进程 Skill 调用（收尾） |
| writing-skills | ~/.agents/skills/writing-skills/SKILL.md | advisor SKILL.md 起草参考（描述触发精度） | P1-S2 起草参考 |
| critic（agent） | —（agents 位） | 独立审查派发（G3 门/103.3 复检） | Agent 派发 |

## §7 项目知识库回链（终验后入库触发）
- **触发点**：check-complete exit 0 后
- **入库命令**：`bash scripts/kb-sync-from-plan.sh plans/archive/task-tpl-sediment-20261115` → draft → 精炼改名 → `bash scripts/kb-rebuild-index.sh`
- **条目规范**：knowledge/README.md（主题级合成、Rule 71 无源不写）
