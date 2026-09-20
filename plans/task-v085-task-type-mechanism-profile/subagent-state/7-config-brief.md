# task-v085 S6/S7/S8 派发材料包 — Phase 3 脚本与守卫层

## 执行环境（必读）
工作目录（worktree）：/home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile
所有文件路径相对该 worktree 根。禁止触碰其他 worktree 或主仓。Phase 1/2 已完成：Rule 37 在 critical-rules.md、§九 矩阵在 template-mapping.md、SKILL/模板/guide 增量在位——禁止改写。

## S6 — config.json 新增 mechanism_profile_enforce 键
目标文件：skills/task-planner/config.json（JSON Schema 形态）
要求：
1. 在 `properties` 下新增键 `"mechanism_profile_enforce"`，位置放在 `template_gate_enforce` 键定义之后（紧邻）
2. 键结构完全仿照 `template_gate_enforce`（同文件内既有范式）：type=string、enum ["enforce","warn","off"]、default "warn"、description 注明 `Rule 37 任务类型机制画像三档：warn=终验画像抽查仅提示；enforce=内容组计划声明 code_review: required 时 exit 1；off=跳过。详见 template-mapping.md §九`
3. 禁止改动其他任何键；`additionalProperties` 等既有结构保持
验收：`python3 -m json.tool skills/task-planner/config.json` 通过；`jq -r '.properties.mechanism_profile_enforce.default'` 输出 warn；`grep -c "mechanism_profile_enforce"` = 1

## S7 — check-complete.sh 末段新增画像抽查段（≤15 行）
目标文件：skills/task-planner/scripts/check-complete.sh
要求：
1. 先 Read 全文理解既有结构与档位解析范式（grep config 三档：env TASK_PLANNER_MECHANISM_PROFILE_ENFORCE > config .properties.mechanism_profile_enforce.default > 默认 warn）
2. 在主流程合适位置（既有各 GATE 校验段之后、最终 exit 判定之前）插入画像抽查段，逻辑：
   - 从计划文件提取 template_type（frontmatter 行或表格行，参照 check-template-type.sh L20-24 的两路提取法）
   - 若 template_type ∈ writing/research/publish（内容组）且计划含 `code_review: required` 声明：
     - warn 档：stderr 打一行 `[mechanism-profile] ⚠ 内容组计划声明 code_review: required（Rule 37 画像默认不适用；如属显式例外请登记理由）`，不改变 exit 码
     - enforce 档：打 `[mechanism-profile] ✗ ...` 并计入失败（使脚本最终 exit 1；注意不破坏既有 exit 语义——若脚本以汇总变量决定退出码则追加进既有机制，禁止新增提前 exit 路径）
   - off 档：整段跳过
3. 风格与既有 gate 段一致（bash、无外部依赖、jq 缺失时降级 fail-open）
验收（自查+行为实测）：构造 /tmp fake plan（template_type=writing 表格行 + code_review required 行）跑 `bash check-complete.sh <fake-plan-dir>`（或按脚本实际调用方式）验证 warn 档不改变原 exit 码、enforce 档（TASK_PLANNER_MECHANISM_PROFILE_ENFORCE=enforce）exit 1；再跑 worktree 内真实 plans 目录确认既有 exit 语义不变
注意：若脚本需要参数（plan dir），按脚本头部 Usage 为准；实测证据写入 checkpoint

## S8 — 新建 selftest-mechanism-profile.sh + TL-18 追加
目标 A：新建 skills/task-planner/scripts/selftest-mechanism-profile.sh（仿 selftest-template-lifecycle.sh / selftest-veto.sh 范式，静态断言 12-15 条 + 行为级 ≥2 条）：
- 静态断言（全部必须）：critical-rules.md 含 `### 37 ` 头 + 37.1-37.5 五子条锚 + FMEA R1 兜底措辞「通用守卫对全部任务类型不变」；template-mapping.md 含 `^## 九、` + writing/research/publish 三行「不适用」；SKILL.md 含「类型适配（Rule 37）」+ `| C25 ` 行 + Critical Rules 列表 Rule 37 行；config.json 含 mechanism_profile_enforce 键且 default=warn；templates/task_plan.md（通用模板）含「机制画像」≥2 处；template-guide.md 含「机制画像」1 处；check-complete.sh 含 mechanism-profile 抽查段锚
- 行为级断言（≥2）：①对 fake plan（template_type=writing + code_review: required）跑 check-complete.sh，默认档不产生 exit 1（或按 S7 实际语义：不改变基线 exit 码）②同 fake plan 在 TASK_PLANNER_MECHANISM_PROFILE_ENFORCE=enforce 下 exit 1。fake plan 放 mktemp 目录，用完清理（selftest-template-lifecycle TL-12/13 行为级范式）
- 输出范式与既有 selftest 一致：逐条 ok N/bad N + `Total:` 行 + 全 PASS exit 0 / 任一 FAIL exit 1
目标 B：selftest-template-lifecycle.sh 末尾追加 TL-18（1-2 行 ok/bad）：`grep -q '^## 九、' "$TMAP"` → ok 18 "template-mapping.md 含 §九 机制适用性矩阵"；总断言数 17→18（同步文件头注释与 Total 逻辑如为硬编码则一并更新）
验收：worktree 内 `bash scripts/selftest-mechanism-profile.sh` 全 PASS exit 0；`bash scripts/selftest-template-lifecycle.sh` 18 PASS=18 FAIL=0；`bash scripts/selftest-dispatch.sh` 等相邻 selftest 不受影响（抽查 1-2 个）

## 检查点与返回（硬性）
- 每完成一个 S-unit 立即写 checkpoint（S6→7-json-edit-agent.md / S7→8-code-assistant.md / S8→9-code-assistant.md），路径前缀 /mnt/data/dev/task-planner-skill/plans/task-v085-task-type-mechanism-profile/subagent-state/
- 8 字段返回：1. status 2. files_written 3. key_outputs 4. evidence（验收实测输出）5. issues 6. next_step 7. checkpoint 8. verify_hint

## 读写契约
读：材料包+目标文件+范式参考文件；写：仅本 S-unit 目标文件+对应 checkpoint
