# Findings: task-specmode-integration-20261115（anchors & baseline）
Worktree: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-specmode-integration-20261115` (wt/task-specmode-integration-20261115 @ a7f3faf)

## 1) 章节地图（`skills/task-planner/SKILL.md`, 283 lines）
| 行号范围 | 章节/段落 |
|---|---|
| 1-19 | YAML frontmatter（name/description/references，含卫星指针 L11,L16-L19） |
| 20-28 | hooks 注释块 |
| 29-35 | `## 定位：核心 = 四文件罗盘管理`（四文件铁律/卫星分层 Rule 82） |
| 36-135 | `## 计划制作循环`：初始化机械/智能(L38-L54)、计划确认(L55-L61)、Poka-Yoke(L62)、方法论解构(L64-L69)、执行循环/回写/终验(L78-L135) |
| 136-149 | `### 📄 产出落盘映射（3-File Pattern）`（记录职责） |
| 150-153 | `### 📖 Read vs Write 决策矩阵` |
| 154-170 | `### 合规检查清单（核心域）`（含委派/门控检查点） |
| 171-174 | `### 🔁 原生 Todo 同步（强制）`（调度/记录同步） |
| 175-189 | `### 🆕 用户新指令处理`（需求变更判定 A/B/C/D/E、目标澄清/切换 L188） |
| 190-193 | `### 🔀 冲突分析与工作树隔离` |
| 194-204 | `## 投诉响应协议与 L0 边界审查` |
| 205-221 | `## 卫星路由表（12 卫星）`（非核心域路由+调用条件） |
| 222-236 | `## Critical Rules 指针（核心域）`（Rule 1-107 索引，含 D1 目标绑定/Goal/记录） |
| 237-240 | `## Completion Gate` → verification-gate Rule 84.4 指针 |
| 241-245 | `## Scope Guard / Goal Gate`（目标/VC 约束） |
| 246-249 | `## I/O 契约` |
| 250-253 | `## Chain 模式与协同路由（指针）`（comet/OpenSpec/superpowers/dynamic-workflows 路由） |
| 254-261 | `## 派发与执行纪律指针（卫星 authoritative）`（子代理激活/并行/调度） |
| 262-283 | `## References`（含外部 skill/agent L283） |

**重点定位**：①任务初始化/需求分析/目标澄清 L36-L69, L175-L189, L241-L245；②卫星/伴飞/子代理路由 L16-L19,L205-L221,L250-L261,L283；③记录/调度职责 L136-L174,L222-L236,L246-L249。

## 2) 插入点候选（增量，不覆盖）
| # | 位置 | 理由 | 与周边关系 |
|---|---|---|---|
| C1 | L252（`## Chain 模式与协同路由（指针）`，同段内句首）后增量补充条款行/子项 | 该句已权威列出 `comet/OpenSpec/superpowers/dynamic-workflows` 协同路由与 `plan-collab-router`，是 Superpowers/OpenSpec 既有挂载点，最小改动扩展“何时/如何 spec-mode”条款 | 增量细化 L252 既有路由语义；与 L215 卫星路由表 `plan-collab-router`、Rule 39/40/91 指针一致，不改既有链路 |
| C2 | L55-L57（`## 计划制作循环`→`[A] 计划确认`，展示+门控段）内追加条款要点 | 计划确认/D1 是需求澄清与目标(VC)定稿关口，适合插入“命中 spec-mode 场景须先完成 OpenSpec/Superpowers 条款检查/产物对齐再 yes/attest” | 与 L56 VC/`verification-gate`、L58 目标绑定确认、L57 D1 门控形成前置约束；不覆盖四要素展示要求 |
| C3 | L49-L54（`[A] 初始化（哨兵机制）— 智能子动作`）末尾新增子动作 | 初始化智能阶段决定体量/隔离与方案形态，适合做 spec-mode 触发判定（是否引入 OpenSpec/superpowers 流程）并落 task_plan 决策 | 衔接 L50 冲突分析/隔离决策与后续 L55 计划确认；与 L205 路由表调用条件互补，属增量检查点 |

## 3) 措辞参照（技能引用/卫星/伴飞形态实例）
- L56: `详见卫星 \`verification-gate\`（\`Skill("verification-gate")\`）`
- L72: `命中则 \`Skill("progress-tracker")\` 建/用项目级账本...`
- L114: `\`Skill("code-review")\` 输出 APPROVED 才可进入终验交付`
- L186: `命中 Rule 98 触发面...→ 调用 \`Skill("context-corrector")\` 整理...`
- L252: `主路由 \`Skill("plan-collab-router")\`；dynamic-workflows ... 主动路由...`
- L283: `外部 skill/agent | \`drift-checker\`.../\`Skill("plan-resume")\`.../\`code-review\` skill |`

## 4) 回归基线（selftest）
- 脚本数：`ls skills/task-planner/scripts/selftest*.sh | wc -l` => **97**（`run-selftests.sh` L20-29, 非 selftest-*.sh 入口）
- 调用方式：`run-selftests.sh`（支持 `--fresh/--only/--status`，指纹缓存；见头部注释）
- 实跑：`cd <worktree-root> && bash skills/task-planner/scripts/run-selftests.sh`（未超时）
- 结果：**Total: 97 PASS=95 FAIL=2 (run=97 reused=0)**
- FAIL 清单：`selftest-active-plan` (rc=1), `selftest-execution-stability` (rc=1)

## 5) openspec/superpowers 存在性检查（worktree）
- `ls -ld openspec` => `cannot access 'openspec': No such file or directory`（无）
- `find . -iname '*superpower*' -o -iname '*openspec*'` => 无输出（应为无，已确认）
