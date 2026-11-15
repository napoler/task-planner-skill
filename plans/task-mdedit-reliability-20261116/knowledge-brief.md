# Knowledge Brief — task-mdedit-reliability-20261116（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-mdedit-reliability-20261116/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/task-mdedit-reliability-20261116/knowledge-brief.md 后即按 §1-§5 填写；
     计划期填 §1/§4/§5 骨架，§2/§3 执行期每个 S-unit 完成后持续回填（新事实/新锚点当日入账）。
  ② 为何设计成五段: 子代理 prompt 只能带「路径 + 摘要」（Rule 22.4 §9 上下文预算），
     五段=小模型可消费的知识最小集——§1 对齐术语、§2 只放已验证事实（带证据锚点，
     未验证推测禁入=防把假设当事实注入）、§3 定位文件（禁凭记忆改文件）、§4 提前
     排雷（历史教训+FMEA 兜底指针）、§5 把「S-unit → 该读哪节」互链到 S-unit 表。
  ③ 为何独立于三文件: 知识维与决策维(findings)/进度维(progress)/目标维(task_plan)
     分账存放——执行期重读任务时只读本文件即可恢复知识底座，不翻全会话/全 findings。 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

<!-- 填写说明：一句话说明本任务做什么 + 为什么做（≤2 行）；下方术语表每条 ≤1 行，只收录「不解释会读不懂后续 S-unit 材料包」的术语 -->
## §1 任务速览与核心概念
- 任务一句话：为 markdown 多次编辑高频出错建立跨项目工具级防护（edit-ops JSON 指令单 + 校验/原子应用/回读验证/回滚脚本 + 技能接线），使错误可被机制性拦截/检测/回滚。
- 背景/动机：用户反馈 Edit 锚点编辑在 markdown 场景频繁失配、吞块、状态混乱、批量替换静默失配（R1/R6，user-session-log.md #1），仅靠纪律不足以稳定纠正。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| edit-ops JSON | 结构化编辑指令单中间表示（操作类型、目标定位、前置条件、期望结果），用于写前校验与可审计执行 |
| 预校验 | 应用前检查锚点存在性/唯一性/命中计数/冲突，任一失败则整单拒绝不落盘 |
| 原子应用 | 全部操作校验通过才写入目标文件，否则不产生部分写入状态 |
| 回读验证 | 写后按结构/断言回读（如段清单守恒、hash/命中结果）确认变更符合预期 |
| 备份回滚 | 应用前备份，校验或写后验证失败时可恢复到安全状态 |
| Rule 106/106.1a | task-discipline 文档修改复检与结构文件插段纪律（过程期门），与工具级执行器互补 |
| 部署位族 | 跨环境技能/脚本同步目标集合（本任务预估覆盖 zcode/claude/cursor/agents，P6 以仓库机制实证） |

<!-- 填写说明：只录【已验证】事实，每条必须带证据锚点（file:line 或 URL）；未验证推测禁止入表，写进 progress.md「假设」区 -->
<!-- 台账供料源（Rule 21.2.1 台账供料优先）：基线定数类事实（行数/Rule 编号/计数/selftest 基线）证据列优先填台账路径锚（如 plans/.rule-reservations.jsonl:10、plans/task-vXXX/subagent-state/…），并保留原文重验锚并列 -->
<!-- 台账缺口维度（Rule 条款正文/模板区块结构/config 键语义）禁用台账行顶替，须如实填原文锚（file:line） -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 用户核心需求为跨项目 markdown 编辑可靠性“必须纠正”，并列举四候选方向（高级工具/JSON中间件/编辑脚本/有效或已有工具） | `plans/task-mdedit-reliability-20261116/user-session-log.md`（#1 逐字条目） | R 锚、P2 裁决入口与 VC 映射必须覆盖四方向与“拦截/检测/回滚”目标 |
| Rule 106 定义文档修改写后回读门（过程期 P0），含修改点与意图一致、跨字段不变量链复检及 `[recheck]` 留痕要求 | `skills/task-discipline/references/critical-rules-discipline.md:722-724`（106 标题与 106.1） | 工具方案需与纪律协同：工具负责可执行校验/原子性，纪律负责过程留痕与审计 |
| Rule 106.1a 要求结构文件插段前 grep 段清单、new_string 含锚行子串、插段后强制段清单复检（段数守恒/无重复标题） | `skills/task-discipline/references/critical-rules-discipline.md:726` | P3 回读验证/P4 接线应吸收结构守恒断言，降低“吞块/吞锚”风险 |
| 全局 markdown-editor 技能提供 Markdown 编辑原则与流程（读后改、最小修改、结构完整性）但未提供结构化 edit-ops/预校验/原子应用/回读断言/回滚执行器 | `/home/terry/.zcode/skills/markdown-editor/SKILL.md`（name/description、Editing Principles、Execution Workflow 等段） | 可复用其触发与原则，不足以单独解决四类失败模式；P2 需裁决新建 md-edit-ops 或扩展接线 |
| 本仓 task-planner 技能包含计划模板、脚本与校验工具，scripts 目录含 init-session/check-complete/attest-plan/check-plan-dispatch 等 | `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`；`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/`（目录清单） | md-edit-ops 脚本与 selftest 可优先落在技能脚本生态内，便于调用与部署 |
| 计划目录已初始化 7 个文件并位于 task-mdedit-reliability-20261116 | `/mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/`（本次 `ls -la`） | 计划期仅更新 5 个实质文件，保持 scope 与 user-session-log/attestation 等文件边界清晰 |
| Aider SEARCH/REPLACE 成功块立即落盘、无事务回滚（失败块仅报错+建议）；匹配级联 exact→空白归一→`...` 段唯一计数 | `plans/task-mdedit-reliability-20261116/research-external-tools.md` §1（来源 aider.chat/docs/more/edit-formats.html + github.com/Aider-AI/aider `editblock_coder.py`） | edit-ops 必须自带「全过才写+备份回滚」；借鉴其块结构但不移植其部分提交行为 |
| Codex apply_patch（V4A）顺序应用、无全量回滚、失败带 delta；seek_sequence 多级归一匹配（exact→rstrip→trim→Unicode） | 同上 §2（openai/codex `codex-rs/apply-patch/{parser,seek_sequence,file_update,lib}.rs` 源码直读） | 唯一性硬校验须比业界更严（expect_count 强制）；其多级归一仅作匹配降级参考 |
| RFC6902 JSON Patch：顺序执行、任一步失败则整体不得视为成功 | 同上 §3（rfc-editor.org/rfc/rfc6902.txt） | edit-ops「预校验→原子应用」事务语义的直接依据 |
| git apply 默认原子、--check/--reject/--3way 可控 | 同上（git-scm.com/docs/git-apply） | 「预检→应用」两阶段先例；--reject 部分应用反例佐证整单拒绝价值 |
| edit-ops 设计定稿（评估矩阵+schema v1+七步流水线+exit code 2/3/4/5/6 契约） | `plans/task-mdedit-reliability-20261116/findings.md`「edit-ops 设计定稿（P2/S1-S3）」段 | P3 实现语义硬约束：七步顺序与 exit 契约不得收窄；字段命名微调裁量权归执行体 |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；「≤10 行摘要」列指该路径关键区段不超过 10 行的内容摘要，非行数限制语 -->
<!-- 设计插入点+范式锚（台账供料，Rule 21.2.1）：设计类 S-unit 行必含 ①目标文件插入点锚 ②最新范式块锚（来源=编号账本推最大 landed Rule → 文尾块行号）③时效戳（供料日期+快照来源）；锚区间会漂移且部署位在途写入，过期锚须重测不得盲用 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| `plans/task-mdedit-reliability-20261116/user-session-log.md` | #1 条目 | R1 逐字原话与四候选方向/“必须纠正”目标，需求原文权威锚（Rule 51.1/80） |
| `plans/task-mdedit-reliability-20261116/task_plan.md` | Goal/R/VC/Phases/根源覆盖/证据面 | 本任务计划主文档：目标、R→VC、六阶段与 S-unit、裁决与风险门控 |
| `skills/task-discipline/references/critical-rules-discipline.md` | :722-760 | Rule 106/106.1a/106.2-106.5 纪律：写后回读、结构插段守恒、派生值与全量回归、交付物本体、todo 基线组 |
| `/home/terry/.zcode/skills/markdown-editor/SKILL.md` | :1-120 | markdown 编辑技能触发与原则、工作流；无结构化事务执行器，可作为复用基座 |
| `skills/task-planner/SKILL.md` | :1-120 | task-planner 定位、四文件罗盘、计划制作循环与校验脚本约定 |
| `skills/task-planner/scripts/` | 目录 | init-session/attest/check-complete/check-plan-dispatch 等脚本；P3/P5 可新增 md-edit-ops 与 selftest |
| `knowledge/entries/worktree-lifecycle-mergeback.md` | 全文（P6 深读） | 部署位同步与合并回先例参考；P6 对账策略需按仓库现行机制实证 |

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. 禁止把“Rule 106 已存在”误判为“编辑错误已被工具级解决”——106 是纪律门，四类高频失败仍需执行器机制（见 §2 事实 2-4）。
2. 禁止静默失配：批量/脚本替换必须校验 matched_count/changed，0 命中或异常计数不得视为成功（对应失败模式④）。
3. 禁止吞锚插段：结构文件插入/替换必须保留锚行语义并做段清单/守恒回读（106.1a + P3 断言）。
4. 禁止凭记忆编造外部工具能力或调研结论；P1 未取证的候选只能记为“待调研”，不得入 §2 已验证事实。
5. 禁止在 P2 前锁死“仅某一种方向”实现；四候选方向必须逐项评估并在裁决入口给出推荐项(Recommended)与取舍。
6. 部署位族与同步命令不得凭经验猜测（zcode/claude/cursor/agents 路径与机制以 P1/P6 实证/仓库脚本为准）。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 1 外部调研证据不足」「Phase 2 方案取舍分歧」「Phase 3 原子应用/回滚缺陷」「Phase 4 接线不一致」「Phase 5 selftest 覆盖不足」「Phase 6 多环境部署不一致」行。

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；「应读本 brief 哪节」精确到 §x；额外材料路径必须是绝对路径或 plan 目录相对路径 -->
<!-- 台账供料（Rule 21.2.1）：设计类 S-unit 行「额外材料路径」列直接填台账产物绝对路径（替代 prompt 内联），「应读本 brief 哪节」精确到 §2/§3 供料行 -->
## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P1/S1 | §1, §2, §3, §4 | `skills/task-discipline/references/critical-rules-discipline.md:722-760`；`/home/terry/.zcode/skills/markdown-editor/SKILL.md` |
| P1/S2 | §1, §2, §4 | `plans/task-mdedit-reliability-20261116/task_plan.md`（R2/R5/证据面）；`plans/task-mdedit-reliability-20261116/findings.md`（外部对标预留段） |
| P1/S3 | §1, §2, §4 | `plans/task-mdedit-reliability-20261116/task_plan.md`（R3/VC-2）；`plans/task-mdedit-reliability-20261116/findings.md` |
| P1/S4 | §1, §2, §4 | `plans/task-mdedit-reliability-20261116/task_plan.md`（R4/R6）；`skills/task-discipline/references/critical-rules-discipline.md:722-760` |
| P2/S1 | §1, §2, §4, §5 | `plans/task-mdedit-reliability-20261116/findings.md`（P1 汇总）；`plans/task-mdedit-reliability-20261116/task_plan.md`（四方向入口） |
| P2/S2 | §1, §2, §4 | `plans/task-mdedit-reliability-20261116/task_plan.md`；`plans/task-mdedit-reliability-20261116/findings.md` |
| P3/S1-S4 | §1, §2, §3, §4 | `plans/task-mdedit-reliability-20261116/task_plan.md`（P3 S-unit 表/VC-2）；`plans/task-mdedit-reliability-20261116/findings.md` |
| P4/S1-S3 | §1, §2, §3, §4 | `/home/terry/.zcode/skills/markdown-editor/SKILL.md`；`skills/task-discipline/references/critical-rules-discipline.md:722-760`；P2 裁决记录 |
| P5/S1-S3 | §1, §2, §4 | `plans/task-mdedit-reliability-20261116/verification.md`；P3 脚本与 report 约定 |
| P6/S1-S2 | §2, §3, §4 | `knowledge/entries/worktree-lifecycle-mergeback.md`；仓库 deploy/selftest 机制（P1/P6 实证） |

<!-- 填写说明：任务画像期扫描 ~/.zcode/skills 与 ~/.agents/skills 索引，把匹配本任务画像的强化技能（comet 族、superpowers 族、brainstorming 等）入表——What=执行前技能扫描先于派发；Why=技能库 200+ 若从不扫描匹配，强化执行能力（头脑风暴/流程强化）永远处于「从未激活」的闲置状态（Rule 59.3，对应用户 R5） -->
<!-- 用户触发型判别（Rule 59.3 判别条款）：comet 族等 frontmatter 声明 disable-model-invocation（用户显式触发）设计的技能，「激活方式」列只准写「用户手动触发（仅提示）」，禁止主进程/子代理自动代激活——治理解法=显式可见性（扫描入表供用户与执行体择用），而非越权代触发 -->
## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | `/home/terry/.zcode/skills/task-planner/SKILL.md` | 本任务为计划制定与 Phase/VC 门控执行 | 主进程按流程使用 / 子代理按任务书挂载 |
| task-discipline | `/home/terry/.zcode/skills/task-discipline/SKILL.md` | Rule 106/106.1a 与执行纪律、复检留痕 | 子代理 prompt 挂载 / 规则引用 |
| research-assistant | `/home/terry/.zcode/skills/research-assistant/SKILL.md` | P1 四方向外部真实调研与证据收集 | 子代理 prompt 挂载 |
| markdown-editor | `/home/terry/.zcode/skills/markdown-editor/SKILL.md` | 现有 markdown 编辑原则与触发基座，P2/P4 评估复用 | 子代理 prompt 挂载 / 用户按需触发 |
| verification-gate | `/home/terry/.zcode/skills/verification-gate/SKILL.md` | VC/V-N 可执行化、终验与证据链 | 子代理 prompt 挂载 |
| brainstorming | `/home/terry/.agents/skills/brainstorming/SKILL.md` | P2 多方案发散与取舍澄清（如需求仍模糊） | 子代理 prompt 挂载 / 主进程 Skill 调用 |
| systematic-debugging | `/home/terry/.agents/skills/systematic-debugging/SKILL.md` | P5 冒烟失败定位与根因分析 | 子代理 prompt 挂载 |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
<!-- 项目级覆盖段：仅本仓（.zcode/plan-templates/ 覆盖生效）；源模板无此段 -->
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-mdedit-reliability-20261116>` → 生成 knowledge/entries/_draft-task-mdedit-reliability-20261116.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）
