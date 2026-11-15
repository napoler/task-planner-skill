# P4 checkpoint — md-edit-ops 技能与文档接线 (task-mdedit-reliability-20261116)

- task_id: task-mdedit-reliability-20261116 / Phase 4
- worktree: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-reliability-20261116
- 约束: 只写 worktree 内文件；禁碰主仓/其他worktree/全局~/.zcode；禁 git
- 开始: 2026-11-16 (subagent run)

## Step 1: Rule 106.6 插入 (critical-rules-discipline.md)

### 1a. 插段前段清单 (106.1a: `grep -nE '^#{2,3} '`)
- 文件: skills/task-discipline/references/critical-rules-discipline.md
- 目标位置: Rule 106 区，106.5 之后、Rule 107 之前
- 106.5 结束锚行(739): `基线组与门禁硬挂钩：B1 未勾=修改步不得声称完成；B2 未勾=Phase 不得翻 complete；B3/B4 未勾=不得出 outcome；S3 `[plan-sync]` 回写两组都要处理，基线组条目丢失=当次立即重建（防丢弃）。Why：todo=执行视图唯一事实，门禁挂 todo 使「流程缺失/丢弃」在下次同步时可见；B1 设计为持续项避免逐次修改的 todo 刷屏。`
- Rule 107 起始(741): `107. **序列创作知识同步纪律（跨单元叙事连续性三环闭环，P0；2026-11-15 task-serial-sync-20261115 新增）**`
- 前 ^#{2,3} 计数: 66（grep -nE '^#{2,3} ' | wc -l）
- 前尾部相关: 722:### 106 ... (heading) 无 106.6；741 为 `107.` 段落标题（非##/### heading，计入段落但 heading计数看##/###）


### 1b. 插入内容与 106.1a 三规约
- `grep -nE '^#{2,4} '` 定位确认：Rule 106 heading at 722；106.5 文本区 736-739；Rule 107 文本起始 741（插前）。插入目标=106.5 之后、Rule 107 之前。
- 插段前 `grep -nE '^#{2,3} '` 计数: 66（见 /tmp/p4-headings-before.txt，tail 至 722:### 106 ...）。
- `new_string` 含 `old_string` 锚行子串：包含 106.5 末句锚行 `基线组与门禁硬挂钩：...B1 设计为持续项避免逐次修改的 todo 刷屏。` 与 `107. **序列创作知识同步纪律...` 原文，满足 106.1a。
- 插入块（≤12 行，实际 6 行）：
  - `106.6 **结构化编辑工具指针（md-edit-ops）**：markdown 批量/结构化修改优先走 skills/md-edit-ops/ 的 edit-ops 指令单执行器（写前预校验/原子应用/回读断言/apply-report），替代裸 sed/python 长文批量替换。`
  - apply-report 路径须记入 progress `[recheck]` 行（与 106.1 留痕协同）
  - 裸 sed/python 长文批量替换必须校验命中数与变更数，**0 命中即 FAIL** 且禁静默成功；同法失配按 106.1a 复检止损
  - 单处小改可仍用 Edit，但必须守 106.1/106.1a（写后回读、结构插段锚行子串与段清单复检）
  - 互引：`skills/md-edit-ops/SKILL.md`（CLI/七步流水线/exit code 契约）

### 1c. 插段后段清单复检 (106.1a)
- `grep -nE '^#{2,3} '` 计数: 66（/tmp/p4-headings-after.txt）；`diff -u before after` = 无差异（##/### 段数守恒，106.6 为 106.x 正文子条非标题行）。
- 106.6 命中: `741:106.6 **结构化编辑工具指针（md-edit-ops）**...`（唯一）。
- Rule 107 起始唯一性: `747:107. **序列创作知识同步纪律...`（^107\. 主条唯一；107.0-107.5 子条后续存在，符合原结构）。
- 文件行数: 754 -> 760 (+6)。

### 1d. 关联 selftest (critical-rules-discipline)
- registry 查询: `grep -n "critical-rules-discipline" skills/task-planner/scripts/selftest-registry.tsv`
  - 81:selftest-input-consistency.sh
  - 95:selftest-anti-deferral.sh
  - 97:selftest-file-disposal.sh
  - 98:selftest-enumerate-first.sh
- 实跑结果（cwd=worktree `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-reliability-20261116`，禁改断言）：
  1. `bash skills/task-planner/scripts/selftest-input-consistency.sh` -> RC=0
     - IC-01..IC-05 PASS, Total PASS=5 FAIL=0 WARN=0
  2. `bash skills/task-planner/scripts/selftest-anti-deferral.sh` -> RC=0
     - AD-01..AD-12 PASS, Total PASS=12 FAIL=0
  3. `bash skills/task-planner/scripts/selftest-enumerate-first.sh` -> RC=0
     - EN-01..EN-07 PASS, Total PASS=7 FAIL=0
  4. `bash skills/task-planner/scripts/selftest-file-disposal.sh` -> RC=0
     - FD-01/02/03/04a/04b/05a/05b/06 PASS, Total PASS=8 FAIL=0
- 结论: 全部 PASS，无 FAIL，无断言修改。

## Step 2: 接线登记

### 2a. task-planner 内低风险文件登记 md-edit-ops 使用点指针（优先 references/）
- 候选扫描: `skills/task-planner/references/*.md` 与 registry 依赖交叉检查 -> spec-mode.md 未在 registry deps 中，且 `grep -rl "spec-mode" skills/task-planner/scripts` 无命中（非 selftest 断言敏感区）。todo-sync/worktree-isolation/critical-rules/goal-gate/completion-gate/methodology 均在 registry 引用，敏感度更高。
- 修改文件: `skills/task-planner/references/spec-mode.md`（§4 关系段末尾前新增一条）
  - 新增: `- Markdown 批量/结构化编辑执行面：优先 \`skills/md-edit-ops/\` 指令单（task-discipline Rule 106.6 指针），与规格路由无冲突、纯增量协同`
  - 行数: 36 -> 37 (+1)
- 关联 selftest: registry 无 spec-mode.md 依赖条目，scripts 未引用 spec-mode.md -> 无需实跑 selftest（无关联项）。grep: `grep -n "md-edit-ops" skills/task-planner/references/spec-mode.md` -> 37 命中。

### 2b. 技能索引（README*/INDEX 类文件）
- 查找: `find skills -maxdepth 1 -name "README*" -o -name "INDEX*" -o -name "index*"` = 空；全仓 skills 目录下无技能索引/目录型 README/INDEX 文件。存在 per-skill README（如 skills/task-planner/README.md, skills/plan-resume/README.md, skills/task-drift-guard/README.md）但非“技能索引（catalog/index）”文件。
- **SKIP**: 无 worktree 技能索引（README*/INDEX 类 catalog 文件）可登记；未对 per-skill README 做无关硬改。

### 2c. md-edit-ops SKILL.md 补 task-discipline Rule 106.6 互引
- 修改文件: `skills/md-edit-ops/SKILL.md`（“与 Rule 106/106.1a 协同”段新增一条）
  - 新增: `- 规则指针：task-discipline \`Rule 106.6\`（\`skills/task-discipline/references/critical-rules-discipline.md\`，批量/结构化 markdown 修改优先本执行器）。`
  - 行数: 84 -> 85 (+1)
- 关联 selftest: registry 100 `selftest-md-edit-ops.sh` 依赖含 `skills/md-edit-ops/SKILL.md`，实跑 -> RC=0, Total PASS=52 FAIL=0, RESULT: ALL GREEN（bun 26 + node-strip-types 26）。未改断言。
  - 命令: `bash skills/md-edit-ops/scripts/selftest-md-edit-ops.sh`
  - 摘要: 正例/失配/多命中/expect/base_hash/dry-run/标题删除语义/insert锚保活/多文件回滚/坏JSON/sub计数/--report 等双运行时全绿。

## Step 3: Acceptance 实测汇总
1. 106.6 条款 grep 命中: `skills/task-discipline/references/critical-rules-discipline.md:741:106.6 ...`
   - 段清单(##/###): 前 66 -> 后 66（守恒，106.6 非##/###标题），diff 无变化；Rule 107 起始 `747:107.` 唯一主条。
2. 涉及文件关联 selftest 实跑（原样结果）:
   - critical-rules-discipline.md: input-consistency PASS 5/0 RC0; anti-deferral PASS 12/0 RC0; enumerate-first PASS 7/0 RC0; file-disposal PASS 8/0 RC0.
   - md-edit-ops/SKILL.md: selftest-md-edit-ops PASS 52/0 RC0 ALL GREEN.
   - spec-mode.md: 无 registry/scripts 关联自测项（N/A），未改断言敏感区。
3. SKILL.md 互引 grep: `skills/md-edit-ops/SKILL.md:79:- 规则指针：task-discipline \`Rule 106.6\` ...` 命中。
4. SKIP: 2b 技能索引 README*/INDEX catalog 文件不存在于 worktree skills/（仅 per-skill README 存在）-> SKIP，理由已登记。

## 文件变更汇总（worktree 内）
- modified: `skills/task-discipline/references/critical-rules-discipline.md` 754->760 (+6)
- modified: `skills/task-planner/references/spec-mode.md` 36->37 (+1)
- modified: `skills/md-edit-ops/SKILL.md` 84->85 (+1)
- created: `/mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/subagent-state/p4-checkpoint.md` (this file)
