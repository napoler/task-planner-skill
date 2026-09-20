# task-v085 S3/S4/S5 派发材料包 — Phase 2 模板与映射层

## 执行环境（必读）
工作目录（worktree）：/home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile
所有文件路径相对该 worktree 根。禁止触碰其他 worktree 或主仓 skills/ 文件。Phase 1 已完成（critical-rules.md 已含 Rule 37 @L317、SKILL.md 已含 C25/路由注记/Rule 37 行 @310）——禁止改写 Phase 1 产物。

## S3 — template-mapping.md 新增 §九 + §一尾注记（≤60 行）
目标文件：skills/task-planner/references/template-mapping.md（worktree 内，现 198 行，§八 L178 为末章）

1. **§一决策树尾部注记**（§一决策树末行之后插入 1 行）：
   `> 选定 template_type 后，立即按 §九「机制适用性矩阵」套用该类型的机制画像（Rule 37）：Code Review Gate、执行体路由等按矩阵行取捨。`
2. **§九章节**（追加于 §八 末尾之后，即文件末尾）：
   - 章节标题：`## 九、机制适用性矩阵（Rule 37 权威源 — 按 template_type 裁剪机制）`
   - 引导行 1-2 句：本矩阵是 critical-rules.md Rule 37 引用的画像表单一权威源；「不适用」仅指类型组机制不触发，3-File/委派率/漂移检测等通用守卫全类型不变（FMEA R1 措辞）
   - 表头：`| 类型 | 组别 | 默认适用机制 | 不适用机制 | 执行体路由组 |`
   - 14 数据行（13 variant 按字母序 + general）：
     | 类型 | 组别 | 默认适用机制 | 不适用机制 | 执行体路由组 |
     |------|------|-------------|-----------|-------------|
     | bugfix | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant/debugger/code-reviewer |
     | code-edit | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant(haiku-1)/executor |
     | deployment | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | executor/code-assistant |
     | diagnostic | 代码组 | Code Review Gate（修复类）+修改后验证 | content_quality 门控 | code-assistant/debugger |
     | migration | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | executor/code-assistant |
     | performance-tuning | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | executor/code-reviewer |
     | publish | 内容组 | content_quality 门控（Q3/Q4） | Code Review Gate；code-assistant/debugger/code-reviewer 路由 | code-runner-agent/article-batch-publish |
     | refactor | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-simplifier/executor |
     | research | 内容组 | content_quality 门控（Q3/Q4） | Code Review Gate；code-assistant/debugger/code-reviewer 路由 | research-assistant/web-search-agent |
     | rule-enhancement | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant/executor |
     | schema-migration | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant/database-optimizer |
     | test-writing | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant/test-engineer |
     | writing | 内容组 | content_quality 门控（Q3/Q4） | Code Review Gate；code-assistant/debugger/code-reviewer 路由 | article-writer/article-writing-phase-agent |
     | general | 通用组 | 未命中类型时按通用守卫全量执行（画像不裁剪，计划可显式声明个别机制 n/a 并登记理由） | （无预置不适用项） | 按 Phase Executor 字段逐案路由 |
   - 表后收尾 1-2 行：新增任务类型时只需在本矩阵加行并在 variant/ 落模板（Rule 34.4）；「不适用」的例外=计划显式 `code_review: required`（Rule 37.4②）
3. 全文行数约束：新增总量 ≤60 行；禁止改写既有 §一-§八 任何行（§七定制红线区只读）

验收（自查后写入 checkpoint）：
- `grep -n "^## 九、" …template-mapping.md` 命中
- `grep -c "不适用：\|不适用机制"` ≥3（writing/research/publish 三行）
- `git diff --numstat` 删除=0；净增 ≤60
- §七红线区既有行 `git diff` 零触碰

## S4 — 通用 templates/task_plan.md 两处微调（≤8 行）
目标文件：skills/task-planner/templates/task_plan.md（worktree 内，416 行）
1. **Code Review 配置节**（L16-24 区域）：在值行（`| code_review | n/a / required |` 样式行）之后插入 1 行注释或紧邻段落加 1 行：
   `> 默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值。`
2. **Executor 示例行**（L180 附近 `code-assistant（haiku-1）` 示例行）：在示例行后追加 1 行注记（或在同一单元格尾追加短语，二选一保持纯增量）：
   `（示例为代码组画像；非代码任务按 template-mapping.md §九 机制画像选内容类执行体，如 article-writer）`
验收：`grep -n "机制画像" skills/task-planner/templates/task_plan.md` ≥2；`git diff --numstat` 删除=0；净增 ≤8

## S5 — template-guide.md 计数联动核对（新增 ≤1 行）
目标文件：skills/template-mapping 相邻的 skills/task-planner/references/template-guide.md（worktree 内）
1. 先核对：`grep -n "13 个" references/template-guide.md`（TL-17 锚，必须保持命中）与模板总数锚（L32/L60 附近）
2. 本任务未新增/删除任何模板（13 个不变），计数锚**不应需要改动**；仅在矩阵相关段落（如模板清单介绍段）追加 1 行指针：
   `各类型适用的机制画像见 template-mapping.md §九（Rule 37）。`
   若 guide 无合适落点，可不加行并在 checkpoint 记「无需改动」
3. 跑 `bash skills/task-planner/scripts/selftest-template-lifecycle.sh`（worktree 内）确认全量 PASS（含 TL-17）
验收：selftest-template-lifecycle 全量 0 FAIL；guide 净增 ≤1 行；「13 个」锚仍命中

## 检查点与返回（硬性）
- 每完成一个 S-unit 立即写 checkpoint（S3→4-code-assistant.md / S4→5-code-assistant.md / S5→6-code-assistant.md），路径前缀：
  /mnt/data/dev/task-planner-skill/plans/task-v085-task-type-mechanism-profile/subagent-state/
- 最终消息 8 字段：1. status 2. files_written 3. key_outputs 4. evidence（验收 grep 实际输出）5. issues 6. next_step 7. checkpoint 8. verify_hint

## 读写契约
读：材料包（本文件）+ 三个目标文件 + 必要的相邻章节风格参考
写：仅三个目标文件 + 本 S-unit 对应检查点文件；禁止动其他任何文件
