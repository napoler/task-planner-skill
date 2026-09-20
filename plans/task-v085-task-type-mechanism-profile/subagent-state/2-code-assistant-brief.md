# task-v085 S1/S2 派发材料包 — Phase 1 规则与主文件层

## 执行环境（必读）
工作目录（worktree）：/home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile
以下所有文件路径均相对该 worktree 根。禁止触碰其他 worktree 或主仓 skills/ 文件。计划文档在主仓 /mnt/data/dev/task-planner-skill/plans/task-v085-task-type-mechanism-profile/（只读参考，不要写）。

## S1 — critical-rules.md 末尾纯追加 Rule 37（≤70 行）
目标文件：skills/task-planner/references/critical-rules.md（worktree 内，现约 315+ 行，末条为 Rule 36.7）
要求：
1. 文件末尾纯追加 `### 37 任务类型机制画像（mechanism profile — 按 template_type 裁剪机制适用性）` 章节，不改动既有任何行
2. 五个子条结构（对齐既有 Rule 条款风格，如 Rule 34/35/36 的「子条+机制」模式）：
   - **37.1 画像表权威源**：机制适用性的单一权威源 = `references/template-mapping.md` §九「机制适用性矩阵」（14 行：13 variant+general × 列=类型/默认适用机制/不适用机制/执行体路由组）。本条只放判定规则与指针，禁止在 critical-rules.md 复制矩阵内容（防双源漂移）
   - **37.2 判定时点**：计划创建期按 template-mapping.md §一决策树选定 template_type 后，**立即**按 §九 对应行套用机制画像：计划内容（Code Review 配置节取值、各 Phase Executor 字段建议）须与画像一致；通用兜底模板的 Code Review 配置默认按画像自动判定
   - **37.3 三类机制组**（示例性分组，矩阵为准）：代码组（code-edit/refactor/bugfix/migration/schema-migration/test-writing/deployment/performance-tuning/rule-enhancement/diagnostic）= Code Review Gate + code-assistant/debugger/code-reviewer 路由 + 修改后验证流程；内容组（writing/research/publish）= content_quality 门控 + article-writer 等内容类执行体路由，**不适用 Code Review Gate 与 code-assistant/debugger/code-reviewer 路由**；通用组（general 及全类型兜底）= 画像未覆盖的机制按通用守卫执行
   - **37.4 消费侧**：① Phase 执行循环步骤 2.5 委派检查点先查画像再定执行体（Executor 字段与画像路由组一致，例外须在计划登记理由）；② Code Review Gate 仅当 template_type ∈ 代码组**或**计划显式 `code_review: required` 时触发；③ 内容组任务终验走 content_quality 门控（既有 v063 条款），不走 Code Review Gate
   - **37.5 机制**：开关键 `config.json#mechanism_profile_enforce`（默认 warn，三档语义同 template_gate_enforce）；终验画像抽查由 check-complete.sh 末段消费；守护 selftest-mechanism-profile.sh
3. **必须明示（FMEA R1 兜底措辞，防止被误读为豁免全部）**：「画像仅裁剪类型组机制——3-File 落盘（Rule 19）、委派率门控（Rule 25）、漂移检测（Rule 15）、错误学习闭环（Rule 31）等通用守卫对全部任务类型不变」
4. 风格对齐：中文、紧凑、与相邻 Rule 36 一致的条目密度；总行数 ≤70

验收（自查后写入 checkpoint）：
- `grep -n "^### 37 " skills/task-planner/references/critical-rules.md` 命中
- `wc -l` 行数 ≤ 原行数+70；`git diff --stat` 仅该文件、纯增行（diff 增删行数相等且删除=0）

## S2 — SKILL.md 三处纯增量（≤10 行）
目标文件：skills/task-planner/SKILL.md（worktree 内，现 545 行）
三处，全部纯插入、零改写既有行：
1. **路由表头部注记**（§🎯 子代理路由与模型分级，「### 路由表（按任务类型）」标题行与「**目的**」段之后、表头之前，插入 1 行）：
   `> **类型适配（Rule 37）**：下表为代码组画像的默认路由；内容类任务（writing/research/publish）按 references/template-mapping.md §九 机制画像路由到内容类执行体（article-writer 等），不适用 code-assistant/debugger/code-reviewer 行。仅裁剪代码组机制，通用守卫不变。`
2. **合规检查清单加 C25 行**（在 C24 行之后插入 1 行，格式仿 C24）：
   `| C25 | 本任务已按 Rule 37 套用机制画像：template_type 对应的代码组/内容组机制适用性已核对（Code Review Gate、code-assistant 路由等按画像取捨）；画像不适用或未命中登记一行理由 | ☐ |`
3. **Critical Rules 列表加 Rule 37 行**（在 Rule 36 条目行之后插入 1 行，格式仿 Rule 36 行）：
   `- **Rule 37（P0）任务类型机制画像**：画像表(37.1 权威源=template-mapping.md §九)/判定时点(37.2 计划创建期)/三类机制组(37.3)/消费侧(37.4 委派检查点+Code Review Gate 触发条件)/机制(37.5 mechanism_profile_enforce+selftest)——「按类型裁剪机制适用性」链路：仅裁剪类型组机制，3-File/委派率/漂移检测等通用守卫全类型不变（详见 references/critical-rules.md Rule 37）`
验收：`grep -c "Rule 37" SKILL.md` ≥3；`git diff --stat` 净增 ≤10 行；`grep -q 'C22'` 仍命中（TL-14 锚保留）；`grep -q '模板选取门控与沉淀'` 仍命中（TL-15 锚保留）

## 检查点与返回（硬性）
- 每完成一个 S-unit 立即将「S 编号+文件+行数变化+验收 grep 实际输出」追加写入：
  /mnt/data/dev/task-planner-skill/plans/task-v085-task-type-mechanism-profile/subagent-state/2-code-assistant.md（S1 用）
  /mnt/data/dev/task-planner-skill/plans/task-v085-task-type-mechanism-profile/subagent-state/3-code-assistant.md（S2 用）
- 最终消息按 8 字段返回：
  1. status: 2. files_written: 3. key_outputs: 行数变化 4. evidence: 验收 grep 实际输出 5. issues: 6. next_step: 7. checkpoint: 8. verify_hint:

## 读写契约
读：目标文件 + 材料包（本文件）+ 必要时 critical-rules.md 相邻 Rule 36 措辞风格参考
写：仅 S1/S2 目标文件 + 两个检查点文件；禁止动其他任何文件
