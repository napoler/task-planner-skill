# Knowledge Brief — task-v146-drift-check-subagent（任务知识简略要点）

## §1 速览
把 task-planner 的偏移检查从主上下文 `Skill("task-drift-guard")` 切换为 `drift-checker` 伴随 agent 子代理派发（新 Rule 61），主进程只收单行判定+检查点指针。7 个目标文件（worktree 内）：critical-rules.md / SKILL.md / companion/agents/drift-checker.md(新) / references/agent-coverage.md / skills/task-drift-guard/SKILL.md / scripts/zcode-userpromptsubmit.sh / scripts/selftest-drift-check-subagent.sh(新)+registry.tsv。

## §2 已验证事实（计划期一手验证，禁凭记忆推翻）
- 触发点 6 处坐标与锚清单=findings.md §3（含逐处现串特征）
- 锚级联三判例只锚 `Rules 1-39` 头部前缀——头部不动=零级联
- SKILL.md 行数断言 ≤558（selftest-knowledge-brief.sh:38），当前 484
- install-companion.sh 对 companion/agents/*.md 通配部署（:154-156），claude 位 model 行自适应（:101）——新增 agent 零接线
- 卫星 task-drift-guard/SKILL.md 82 行、model: haiku、纯 LLM 行为层无脚本依赖
- 子代理无 Skill() 工具 → SOP 必须嵌入 agent 定义
- Rule 编号：61 free（rule-reserve check 实测）；59/60=v144/v145 并行任务预留，禁区
- 交互模式先例：v142/v144 均 silent

## §3 文件锚点（绝对路径）
- worktree：`/mnt/data/dev/task-planner-skill-worktrees/task-v146/`（Phase 1 建立，分支 wt/task-v146，基点 master=a7c01a8）
- 目标文件均在 worktree 内 `skills/task-planner/` 与 `skills/task-drift-guard/` 下（相对路径同主仓）
- 计划三文件：`/mnt/data/dev/task-planner-skill/plans/task-v146-drift-check-subagent/{task_plan,findings,progress}.md`
- 范式参照（只读）：主仓 `skills/task-planner/companion/agents/plan-writer.md`（agent 范式）、`scripts/selftest-veto.sh`（selftest 范式）、`references/agent-coverage.md`（矩阵行格式）

## §4 易错点（历史判例，执行期必读）
1. **锚级联**：`Rules 1-39` 头部串禁动，只扩括注；改 SKILL.md 索引前后各跑一次三判例 grep 自证
2. **行数纪律**：SKILL.md 净增 ≤20 行；改后 `wc -l` 自证 ≤558
3. **check-dispatch 守卫**：executor 派发 prompt 必含三文件绝对路径+8 字段标签（acceptance:/checkpoint: 等）+≤3000 字符
4. **worktree 路径**：所有技能文件编辑用 worktree 绝对路径；主仓只写 plans/ 状态文件（主进程专属）
5. **hook 脚本转义**：zcode-userpromptsubmit.sh :220 旧串含 `Skill(\"task-drift-guard\")` bash 转义引号——Edit 时按文件原样匹配，新串避免引入需转义字符
6. **卫星小文件**：task-drift-guard/SKILL.md 82 行，纯追加节，禁整写覆盖
7. **并行禁区**：worktrees/task-v143|v144|v145 与 Rule 59/60 相关行禁碰；critical-rules.md 追加位置=现行尾部（Rule 58 后），合并期若他任务已落 59/60 则 61 排其后（并存不重号，先例 v129）
8. **矩阵行格式**：agent-coverage.md 先 Read 既有行格式再加行；model 行惯例以 companion/agents/ 在位文件为准（S2 前先 Read image-generation-executor.md 核对）
9. **断言计数**：回归总数=主进程逐脚本 Total 行求和，禁采信子代理自报
10. **coverage 矩阵上界级联**：selftest-agent-coverage.sh AC-09 断言矩阵行数 ≤128（task-v131 实测值）——S2 加 drift-checker 行后必触级联，须同步上调 ≤129 并在 label 注记 task-v146（判例：SKILL 行数定数断言随增行必级联）
11. **Rule 15 块内 4 处旧载体词**（导语/15.1/15.2/15.3）必须随 15.4 一并切换，禁只加 15.4 留双源漂移；已验证零脚本锚（2026-10-08 实测 grep 空）

## §5 S-unit 材料包（executor 逐字消费，禁自行改写语义）

### §5.1 Rule 61 条款全文（→ critical-rules.md 尾部 Rule 58 之后追加）
```markdown
### 61 偏移检查子代理化（上下文防爆炸 — task-v146）

> 结果级需求：偏移检查不得污染主上下文（用户 2026-10-08：「检查偏移…放入到子代理中检查…保持上下文干净…规避上下文爆炸」）。

- **61.1 载体强制**：Rule 15.1 全部触发点的偏移检查一律派发 `drift-checker` 伴随 agent（haiku-1 档）在子代理隔离上下文执行（SKILL 路由表「漂移检测」行同步）；主进程禁止为偏移比对 Read task_plan.md 全文或收集 git diff 大输出；主进程只消费单行判定 + 检查点指针
- **61.2 派发契约**：按 Rule 22.4 九字段模板派发，增补 drift 专用四字段=用户目标原话（≤200 字）+当前 Phase/S-unit 一行+近期动作摘要（≤5 行）+触发点类型；prompt ≤3000 字符（21.1b 沿用）；检查点=`<plan-dir>/subagent-state/{seq}-drift-checker.md`（22.8 命名沿用）
- **61.3 产出契约**：drift-checker 只读仓库（唯一写权限=自身检查点）；检查点含判定+证据+建议；返回单行 status: `ALIGNED|DRIFT|BLOCKED` + evidence=检查点绝对路径；三态语义与处置链（15.2 追加 [drift-fix] / BLOCKED→STOP）不变；`task-drift-guard` skill 保留为交互/独立场景载体（双载体三态一致，selftest 守护）
- **61.4 防自触发**：偏移检查的派发与回收不计入「连续 ≥3 次工具调用」累计；每次检查完成后计数清零（检查即新基线），防高频检查自我触发死循环
- **61.5 失败兜底**：drift-checker 失败/超时 → 先 Read 检查点（22.8.4）→ 重试 1 次 → 仍失败降级主进程跑 `check-drift.sh`（只消费脚本输出，禁读计划全文）并登记债务；同 Phase 连续 3 次降级 → 按 Rule 41 评估上报
- **61.6 机制**：零新 config 键；`selftest-drift-check-subagent.sh` 静态守护（六处载体锚+负断言+三态一致+覆盖矩阵行+hook 文案）；SKILL.md 路由表/合规清单 C4/References 同步措辞；锚定级联护栏=索引括注扩展头部 `Rules 1-39` 不动
```

### §5.2 Rule 15 块内载体措辞切换（S1 消费；已验证零脚本锚，级联自由）
规则块位于 critical-rules.md `### 15 高频漂移纠正强制（P0）`（导语段+15.1/15.2/15.3），4 处旧载体词切换 + 块末追加 15.4：
| # | 位置 | 旧（特征串） | 新（目标措辞） |
|---|------|------------|--------------|
| a | 导语段首句 | `每完成 2-3 个原生 todo 后必须调用 \`Skill("task-drift-guard")\`（model: haiku,token 便宜；2026-09-27 task-v091/A-3: 该 skill 调用为漂移检测同点唯一载体,\`check-drift.sh\` 降为可选佐证不双跑——ALIGNED/DRIFT/BLOCKED 三态契约零改动）。` | `每完成 2-3 个原生 todo 后必须派发 \`drift-checker\` 子代理偏移检查（haiku-1 档,主上下文零占用；2026-09-27 task-v091/A-3: 原为 skill 调用唯一载体,\`check-drift.sh\` 降为可选佐证不双跑；2026-10-08 task-v146/Rule 61: 载体切换为子代理派发——ALIGNED/DRIFT/BLOCKED 三态契约零改动）。` |
| b | 15.1 引导句 | `以下任一条件命中立即调用 \`Skill("task-drift-guard")\`（model: haiku,token 便宜）：` | `以下任一条件命中立即派发 \`drift-checker\` 子代理（haiku-1 档,Rule 61 载体）：` |
| c | 15.2 首句 | `task-drift-guard 输出 → 动作对照：` | `drift-checker 判定 → 动作对照：` |
| d | 15.3 中句 | `\`task-drift-guard\` 是 haiku 档,token 便宜,可高频跑；` | `\`drift-checker\` 是 haiku-1 档子代理,token 便宜,可高频跑且主上下文零占用（Rule 61）；` |
| e | 15.3 之后追加 | （无） | §5.2-e 15.4 行（下） |

```markdown
- **15.4 子代理载体（Rule 61 — task-v146）**：15.1 触发点的检查动作由 `drift-checker` 子代理承载（61.1-61.3 契约），主进程不亲自读计划文件做偏移比对；本条触发时机、三态判定与处置链均不变（载体切换≠语义变更）
```
S1 验收增补：critical-rules.md 全文 `Skill("task-drift-guard")` 精确串 0 命中（Rule 15 块切换后）。

### §5.3 companion/agents/drift-checker.md 全文（新建；model 行以 §4.8 核对结果为准）
```markdown
---
name: drift-checker
description: 偏移检查专业执行体|读计划三文件+git 证据做目标对齐三态判定|只读仓库唯一写检查点|task-planner Rule 15/61 唯一执行载体。MUST BE USED for 偏移检查|drift check|漂移检测派发。触发:drift-checker|偏移检查|drift check|漂移检测派发。与 meta-corrector 区别:它做纠偏校正,本 agent 只做只读判定不修正。与 task-drift-guard skill 区别:同源 SOP,skill 为交互/独立场景载体,本 agent 为 task-planner 管理流程的子代理隔离载体（Rule 61）。
model: "custom:9e221f47-3040-4ea7-b742-20b813fb79aa:haiku-1"
thoughtLevel: enabled
tools: [Read, Write, Bash, Grep, Glob]
color: '#E9C46A'
---

> **⏱ 超时约束**: 你有 **10分钟** 执行预算。偏移检查是高频轻量判定，超时立即按已收集证据出判定并落检查点。

# Drift Checker（偏移检查执行体）

你是 task-planner 的偏移检查执行体（Rule 61 载体）。主进程派发你，就是为了**不让自己读大文件**——你在隔离上下文完成全部读取与比对，只回一行结论。

## 硬约束
1. **只读仓库**：禁止 Edit/Write 任何仓库文件；唯一写权限 = 自己的检查点文件（派发 prompt 指定的 `subagent-state/{seq}-drift-checker.md`）
2. 不派发子代理、不修正任何偏移（修正=主进程按 Rule 15.2 处置）
3. 判定基于文件与命令证据，禁止凭派发摘要单独下结论（摘要只是线索，证据必须自查）

## SOP（与 task-drift-guard skill 同源）
1. **读计划**：Read 派发 prompt 中的 task_plan.md 绝对路径（需要时辅读 findings.md/progress.md）——提取 Goal、VC 条目、执行范围限制、当前 Phase
2. **取证据**：在计划所属仓执行 `git status --short && git diff --stat`；对照派发 prompt 的近期动作摘要与触发点类型
3. **三态判定**：
   - ALIGNED：当前动作可映射到 Goal/VC/当前 Phase 范围内
   - DRIFT：动作超出执行范围限制 / 偏离 Goal / 修改范围外文件 / 用户已反馈问题仍沿原方向
   - BLOCKED：前置缺失 / 死循环 / 需用户决策才能继续
4. **落检查点**：写派发 prompt 指定的检查点路径（≤15 行：时间/触发点/判定/证据 file:line/建议）
5. **返回**：按派发 prompt 8 字段模板返回，status 取 `ALIGNED|DRIFT|BLOCKED`，evidence=检查点绝对路径，理由 ≤40 字

## 判定纪律
- 证据不足时倾向 ALIGNED 并在检查点标注「证据不足」，禁止臆测 DRIFT（高频检查宁保守）
- 触发点类型=「用户发出新指令」时，重点比对新指令与 Goal 的 A/B/C 关系结论是否已落计划
- git 脏文件全部落在 scope 内 ≠ 自动 ALIGNED，还需核对 Phase 序与 todo 映射
```

### §5.4 SKILL.md 逐处措辞表（S3 消费；坐标=worktree da1f308 实测行号，执行时以内容特征串定位为准）
| # | 位置 | 旧（特征串） | 新（目标措辞） |
|---|---|---|---|
| 1 | :98 步骤6 | `6. **[DRIFT CHECK]** 调用 \`Skill("task-drift-guard")\`（本触发点唯一检测载体——\`check-drift.sh\` 仅作可选佐证，不双跑；C4）` | `6. **[DRIFT CHECK]** 派发 \`drift-checker\` 子代理偏移检查（本触发点唯一检测载体=Rule 61 子代理化载体——\`check-drift.sh\` 仅作 61.5 降级佐证，不双跑；C4）` |
| 2 | :103 检测层说明行 | `\`task-drift-guard\` 为只读检测层，发现 BLOCKED 时必须等用户明确决策后再继续` | `\`drift-checker\` 为只读检测执行体，发现 BLOCKED 时必须等用户明确决策后再继续` |
| 3 | :127 Chain 步骤4 | `4. 调用 \`Skill("task-drift-guard")\`` | `4. 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）` |
| 4 | :173 C4 行 | `每个 Phase 完成后已调用 \`Skill("task-drift-guard")\`（同点唯一检测载体，ALIGNED/DRIFT/BLOCKED 三态，BLOCKED→STOP；\`check-drift.sh\` 仅作可选佐证，不再与 skill 双跑）` | `每个 Phase 完成后已派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体，同点唯一检测载体，ALIGNED/DRIFT/BLOCKED 三态，BLOCKED→STOP；\`check-drift.sh\` 仅作 61.5 降级佐证，不与子代理双跑）` |
| 5 | :237 B/C 行 | `B/C 类处理完必须再跑 \`Skill("task-drift-guard")\`` | `B/C 类处理完必须再派发 \`drift-checker\` 偏移检查（Rule 61 载体）` |
| 6 | :275 Rule 15 bullet | `每 2-3 个原生 todo 后必须跑 \`Skill("task-drift-guard")\`（详见下方 §高频漂移纠正）` | `每 2-3 个原生 todo 后必须派发 \`drift-checker\` 偏移检查（Rule 61 载体，详见下方 §高频漂移纠正）` |
| 7 | :481 高频漂移纠正节摘要行 | `任一触发条件命中立即调 \`Skill("task-drift-guard")\`（含「用户发出新指令时：A/B/C 判定后做漂移检查」）` | `任一触发条件命中立即派发 \`drift-checker\` 子代理（载体=Rule 61；含「用户发出新指令时：A/B/C 判定后做漂移检查」）` |
| 8 | :385 路由表行 | `\| **漂移检测（高频）** \| \`Skill("task-drift-guard")\` \| haiku（内置） \|` | `\| **漂移检测（高频）** \| \`drift-checker\`（伴随 agent，Rule 61 载体） \| haiku-1 \|` |
| 9 | :352 References 外部 skill 行 | `\`Skill("task-drift-guard")\` 漂移检测 / \`Skill("plan-resume")\` 中断扫描` | `\`drift-checker\` agent 偏移检查执行载体（Rule 61；\`task-drift-guard\` skill=交互/独立场景载体） / \`Skill("plan-resume")\` 中断扫描` |
| 10 | 反模式段末尾追加 | （无偏移行） | `❌ 主进程为偏移比对 Read task_plan.md 全文或收集 git diff 大输出（偏移检查=drift-checker 子代理载体，Rule 61）` |
| 11 | :271 索引行扩括注 | `（Rules 1-39（含 Rule 40-55 全集，Rule 55 可复用能力落盘纪律））` | `（Rules 1-39（含 Rule 40-61 全集，Rule 55 可复用能力落盘纪律 / Rule 61 偏移检查子代理化））` ← **头部 1-39 禁动；v143 未扩括注（仍写 40-55），本次顺带修复** |
| 12 | Rule 摘要 bullet 区（:315 Rule 58 bullet 后）追加一行 | （无 61 行） | `- **Rule 61（偏移检查子代理化 — task-v146）**：15.1 触发点检查由 \`drift-checker\` 伴随 agent 承载，主进程只消费单行判定+检查点（详见 references/critical-rules.md Rule 61）` |

### §5.5 卫星增补节（→ task-drift-guard/SKILL.md 文末纯追加 ≤10 行）
```markdown

## 子代理消费模式（task-v146 — 双载体说明）
- task-planner 管理的执行流程中，本技能的检测动作由 `drift-checker` 伴随 agent 承载（SOP 同源：计划源→Goal/VC 提取→状态证据→三态判定），派发契约与处置链见 task-planner `references/critical-rules.md` Rule 61
- 本 skill 保留为交互/独立场景直用载体（无 task-planner 计划管理上下文时）；三态判定（ALIGNED/DRIFT/BLOCKED）与处置链两载体语义一致，一致性由 `selftest-drift-check-subagent.sh` 守护
```

### §5.6 hook 文案（→ zcode-userpromptsubmit.sh:220）
- 旧：`按 Next Step 推进;偏离即跑 Skill(\"task-drift-guard\")。`
- 新：`按 Next Step 推进;偏离即派发 drift-checker 子代理偏移检查(Rule 61 载体)。`
- 注意：bash 双引号字符串内，新串无引号无反斜杠，直接替换即可

### §5.7 selftest-drift-check-subagent.sh 断言清单（S5 消费；范式=selftest-veto.sh；头部注释含 What/Why 双层）
| ID | 断言（对象+预期） |
|----|------------------|
| DCS-01 | SKILL.md `[DRIFT CHECK]` 步骤行含 `drift-checker` |
| DCS-02 | SKILL.md `只读检测执行体` 行含 `drift-checker` 且不含 `task-drift-guard` |
| DCS-03 | SKILL.md Chain 交接步骤 4 行含 `drift-checker` |
| DCS-04 | 合规清单 C4 行含 `drift-checker` |
| DCS-05 | SKILL.md `B/C 类处理完` 行含 `drift-checker` |
| DCS-06 | SKILL.md Rule 15 bullet（`每 2-3 个原生 todo`）行与 `高频漂移纠正` 节摘要行各含 `drift-checker`（两行分别断言） |
| DCS-07 | 路由表漂移检测行含 `drift-checker` 且含 `haiku-1` |
| DCS-08 | SKILL.md `Skill("task-drift-guard")` 计数=0（负断言） |
| DCS-09 | SKILL.md References 区含 `drift-checker` 且含 `task-drift-guard`（双载体说明行） |
| DCS-10 | SKILL.md 反模式段含 `偏移比对` 禁止行且含 `Rule 61` |
| DCS-11 | SKILL.md 含 `Rule 40-61` 且含 `Rules 1-39`（括注扩展+头部保全双断言）；含 `**Rule 61（偏移检查子代理化` 摘要 bullet |
| DCS-12 | critical-rules.md 含 `### 61 ` 标题 + `**61.1`..`**61.6` 六锚各 ≥1 |
| DCS-13 | critical-rules.md 含 `**15.4` 锚 + 全文 `Skill("task-drift-guard")` 计数=0（负断言） |
| DCS-14 | companion/agents/drift-checker.md 存在 + frontmatter `tools:` 含 Read 与 Write + `model:` 行非空 |
| DCS-15 | drift-checker.md 与 task-drift-guard/SKILL.md 双文件各自含 ALIGNED、DRIFT、BLOCKED 三词（双载体三态一致） |
| DCS-16 | Rule 61 块或 drift-checker.md 含 `subagent-state/` 检查点契约串 |
| DCS-17 | agent-coverage.md 含 `drift-checker` 行 |
| DCS-18 | zcode-userpromptsubmit.sh 含 `drift-checker` 且 `task-drift-guard` 计数=0（负断言） |
| DCS-19 | SKILL.md `wc -l` ≤558 + critical-rules.md 61.4 防自触发锚（`清零`）+ 61.5 降级锚（`check-drift.sh`） |
| DCS-20 | 全 skills/ 树 `Skill("task-drift-guard")` 精确串计数=0（模板/文档联动后全仓负断言；`grep -rn 'Skill("task-drift-guard")' skills/ =空`；裸名 task-drift-guard 在卫星自身/部署注释/历史行/61.3 说明中允许保留） |

### §5.8 agent-coverage.md 追加行（S2 消费；格式随既有行微调）
- 实体名 `drift-checker`｜职责=偏移检查三态判定（Rule 15/61 载体）｜档位=haiku-1｜登记面=SKILL 路由表漂移检测行+companion/agents/drift-checker.md｜缺口类=无（A 类缺口本次收编）
- ⚠️ S2 前先 `wc -l` 实测矩阵行数，再把 selftest-agent-coverage.sh AC-09 上界调为「实测+1」并 label 注记 task-v146（基线 AC-07 另有预存 FAIL 与本单元无关，勿动）

### §5.9 模板与文档联动切换锚清单（S4b/S4c 消费；2026-10-08 全仓扫描实测坐标，以内容特征定位为准）
**S4b 模板（worktree 内 skills/task-planner/templates/）**
- `task_plan.md:391`：「WHEN: 每次调用 Skill("task-drift-guard") 后追加一行记录」→「WHEN: 每次派发 drift-checker 偏移检查（Rule 61 载体）后追加一行记录」
- 9 个 variant（memory-hygiene/refactor/migration/code-edit/test-writing/bugfix/performance-tuning/deployment/schema-migration 各 2 处）三种句式：
  - 终验行 `- [ ] \`Skill("task-drift-guard")\` 终验` → `- [ ] 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）终验`
  - 主进程终验行 `- [ ] **主进程** \`Skill("task-drift-guard")\`（子代理无 Skill() 工具）` 终验 → `- [ ] 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）终验`（过时括注删除）
  - 周期跑行 `每 2-3 个/2 个/每次 Phase 完成 → 跑/调用 \`Skill("task-drift-guard")\`` → `每 N 个 Phase 完成 → 派发 \`drift-checker\` 偏移检查（Rule 61 载体）`（频次词保持原样）
- 验收：`grep -rc 'Skill("task-drift-guard")' templates/ | grep -v ':0'` = 空

**S4c 文档联动**
- `../plan-cost-guard/references/billing.md:15`：`| 高频 task-drift-guard | haiku 档，极便宜（Rule 15 节流：每 phase ≤3 次） |` → `| 高频 drift-checker（偏移检查子代理，Rule 61 载体） | haiku-1 档，极便宜（Rule 15/61 节流：每 phase ≤3 次） |`
- `billing.md:27`：`| task-drift-guard | haiku | ≈ 0.05× | 1-3 | 0.05-0.15 |` → `| drift-checker（Rule 61 载体） | haiku-1 | ≈ 0.05× | 1-3 | 0.05-0.15 |`
- `../plan-cost-guard/references/cost_log.md:18`：示例行 `Skill("task-drift-guard")` → `drift-checker 派发`
- `../plan-cost-guard/references/cost-control.md:13`：`| \`Skill("task-drift-guard")\` | haiku | 高频（每 2-3 todo） | ✅ 已优化 |` → `| \`drift-checker\` 派发（Rule 61 载体） | haiku-1 | 高频（每 2-3 todo） | ✅ 已优化 |`
- `cost-control.md:32`：`每 phase 内 task-drift-guard ≤3 次` → `每 phase 内 drift-checker 派发 ≤3 次（Rule 61 载体）`（其余不动）
- `cost-control.md:49`：`| 漂移检测 | task-drift-guard skill | haiku | ≈ 0.05× opus |` → `| 漂移检测 | drift-checker 子代理（Rule 61 载体；task-drift-guard skill=交互载体） | haiku-1 | ≈ 0.05× opus |`
- `README.md:21`：`- **漂移检测**：每 phase 完成后自动调用 \`task-drift-guard\`` → `- **漂移检测**：每 phase 完成后自动派发 \`drift-checker\` 子代理（Rule 61 载体；task-drift-guard skill 保留交互场景）`（:249 changelog 历史行禁动）
- `INSTALL.md` :221-232 故障排查 5.5 节内命令示例 `# 主进程:Skill("task-drift-guard")` → `# 主进程:派发 drift-checker 子代理（Rule 61 载体）`（:146 部署表行禁动）
- `docs/ARCHITECTURE.md:115`：`| \`task-drift-guard\` | 执行中漂移检测(每 phase 完成后调) | ... |` → 行内职责列改 `交互/独立场景漂移检测载体` 并紧随新增一行 `| \`drift-checker\`（companion agent） | 执行中漂移检测执行载体（Rule 61，逐触发点派发） | 对应 companion/agents/drift-checker.md 路径列 |`（表列结构随既有行）；:132 向后兼容段如述及「skill 为唯一载体」做等义修正并登记 deviations，纯历史描述则保留
- 保留不动（有意）：`install.sh:180`/`lib/install-companion.sh:6`（部署路径注释）、`README.md:249`（历史）、`INSTALL.md:146`（部署表）、`plan-resume/{SKILL,README}.md` 比较表、`task-drift-guard/README.md`、critical-rules.md:722（61.3 双载体说明）
