# Clause Drafts — task-tpl-sediment-20261115（P1-S1 产出）

## §0 scope 清单
- **受管 9 文件（后续插改落位，本草案为唯一事实源）**：`skills/plan-template-kit/references/critical-rules-template.md`（追加 34.8/34.9）、`skills/task-planner/SKILL.md`（卫星路由表+「11 卫星」→12）、`skills/task-planner/references/critical-rules.md`（路由索引/分层枚举）、`skills/task-planner/lib/install-stub.sh`（SATELLITE_SKILLS）、`skills/plan-template-kit/SKILL.md`（沉淀指针）、`README.md`、`docs/ARCHITECTURE.md`、`skills/plan-template-advisor/SKILL.md`（新建）、`plans/task-tpl-sediment-20261115/template-candidate/` 下候选（dogfood）。
- **禁止面（零改动）**：既有 34.1-34.7 条文/30 个既有 variant/零新脚本/零新 Rule 编号/hooks config 不碰；禁改 `skills/task-planner/scripts/**` 与自测脚本。

## §1 条款 34.8 v1 全文
34.8 **执行期沉淀与审查门（执行路径模板候选）**：①**执行期沉淀触点**：Phase 收尾/规范召回/收尾回读时点识别可复用执行路径（新任务类型/验证过的 Phase 结构/来之不易的 Verify command）→ 在 `findings.md` 或 `notepad-learnings.md` 登记一行 `[template-candidate] <类型>｜<一句依据>`（登记不停等不打断执行，Rule 95 兼容）。②**候选暂存**：候选模板落计划目录 `template-candidate/`；未过门禁写入官方 `templates/variant/`。③**两级严格审查门**：官方入库级 G1-G4——G1 结构 lint（34.4 最小结构：Goal/VC 表/Phase 骨架/执行范围限制/必要知识储备，≤100 行，机读头 `<!-- template_type: x -->`，`check-template-type.sh` 过门）；G2 render 冒烟（`render_template` 渲染无 `{{}}` 残留，且 `init-session.sh` 于 tmp 隔离 sid 实跑选中该类型成功）；G3 独立审查派发（critic/agent-quality-auditor 对照 34.5 泛化性双闸门逐项核对）；G4 官方级联（34.2 四点同步+计数串同改+selftest 全绿）。项目级 G1-G3（免 G4，因不动官方库）。④**未过门处置**：候选留暂存并登记理由，禁静默丢弃。与 34.7 分工：34.7 全自动合约触发生成的候选同样须过本条官方门 G1-G4 方可写入 `templates/variant/`（34.5 双闸门=G3 的查重/泛化性输入，非独立入库通道）。判例=task-tpl-sediment-20261115。

## §2 条款 34.9 v1 全文
34.9 **项目级模板适配沉淀位（按需生产）**：沉淀位=`<项目>/.zcode/plan-templates/`（或 `.claude/plan-templates/`；`init-session.sh` 原生发现并入 `*-type.md` 白名单，零接线）。只写 `*-type.md`，禁覆盖核心 7 计划文件模板；命名必须 `*-type.md` 后缀。该目录须维护 manifest（README/INDEX）：模板名/适用类型/来源任务/审查日期。生产者=`plan-template-advisor` 技能（激活后分析项目→预测问题→缺口映射→产出→审查→登记）。与 34.7 分工：34.7=官方 variant 终验全自动合约；34.9=项目级按需生产（G1-G3 过门后落项目位）。判例=task-tpl-sediment-20261115。

## §3 G2 冒烟 spec（可执行步骤序列）
1. **tmp 隔离 sid**：`SID=sid-tpl-smoke-$$`（或随机）；导出/伪造会话标识使 init 写隔离 side 指针，禁止污染当前会话指针。
2. **render 冒烟（直调）**：在隔离副本上调用 `render_template`（`init-session.sh` 内函数/等价入口）渲染候选模板；判据：退出 0 且输出/产物中 `grep -n '{{'` 无残留。
3. **init 实跑（选型）**：`TASK_TEMPLATE_TYPE=<new-type> bash skills/task-planner/scripts/init-session.sh "<冒烟任务名>"` 于 tmp 隔离工作区实跑（sid 隔离/env 伪造，参照步骤 1）；判据：退出 0 且生成计划含选中类型（`template_type`/来源可追溯）。
4. **指针复原**：冒烟若触碰 side 指针，事毕执行 `set-active-plan`（或等价恢复）复原原活跃计划；隔离目录清理。
5. **失败处置**：任一判据失败→G2 不通过，按 34.8④ 留暂存+登记理由。

## §4 级联 spec（五落点，锚行+edit 形态）
| 落点 | 锚（标题/形态串） | edit 形态 |
|------|-------------------|-----------|
| A) `skills/task-planner/SKILL.md` | 卫星路由表区块含 `plan-template-kit` 行的表尾；正文/索引中「11 卫星」计数串 | 在路由表追加 `plan-template-advisor` 行（名称/职责/触发）；将「11 卫星」替换为「12 卫星」 |
| B) `skills/task-planner/references/critical-rules.md` | 路由索引/分层枚举段含 `plan-template-kit` 的条目 | 同段追加 `plan-template-advisor`（模板域项目级适配沉淀）；保持枚举与索引同改 |
| C) `skills/task-planner/lib/install-stub.sh` | `SATELLITE_SKILLS` 数组定义（含已知卫星名列表） | 数组元素追加 `"plan-template-advisor"`（与既有引号/逗号风格一致） |
| D) `skills/plan-template-kit/SKILL.md` | 「沉淀指针」章节末段 | 补一句：执行期候选登记与项目级适配生产由 `plan-template-advisor` 承接（指向 34.8/34.9） |
| E) `README.md` + `docs/ARCHITECTURE.md` | 卫星表/卫星清单含 `plan-template-kit` 的行或计数 | 两文件卫星表各追加 `plan-template-advisor` 行；若存在卫星计数串同步更新 |

## §5 dogfood 候选 spec（P2-S6 依循）
- **目标**：分析本仓（task-planner-skill）模板/规则演进特征，产出 1 个项目适配模板候选，落 `plans/task-tpl-sediment-20261115/template-candidate/<name>-type.md`。
- **前置**：按 34.9 激活 `plan-template-advisor` 流程（分析项目→预测问题→缺口映射→产出→审查→登记）。
- **产物契约**：文件名 `*-type.md`；含机读头 `<!-- template_type: <name> -->` + Goal/VC 表/Phase 骨架/执行范围限制/必要知识储备（≤100 行，满足 G1）；在 `template-candidate/README.md`（或 INDEX）登记模板名/适用类型/来源任务=task-tpl-sediment-20261115/审查日期。
- **审查**：执行 G1-G3（项目级免 G4）；未过门按 34.8④ 留暂存并登记理由。
- **边界**：仅落计划目录候选位，不写入官方 `templates/variant/`，不改 30 个既有 variant。

---
*自审（103.2）*：34.8 四要素（触点/暂存/G1-G4+G1-G3/未过门处置）=PASS；34.9 沉淀位/*-type.md 限制/命名/manifest/生产者/与34.7分工=PASS；§3 冒烟步骤含隔离 sid+render+init+复原+判据=PASS；§4 五落点锚+edit形态齐=PASS；§5 dogfood 候选路径/契约/G1-G3/边界=PASS；全文≤100行+无硬编码行号锚+判例=task-tpl-sediment-20261115=PASS。