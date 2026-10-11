# 15g-ri-wf S-unit 检查点

## status: complete（S-unit 本体）
## 时间: 2026-10-10

## 改动（仅 2 文件）

### 1. skills/task-planner/scripts/selftest-reliability-institution.sh
- :13 头注释 R-09 口径行: `grep -c '含 Rule 40-[56][0-9] 全集'` → `grep -cE '含 Rule 40-[567][0-9] 全集'`（宽容锚+越界负断言）
- :84 新增级联注 `[2026-10-10 task-v158 级联（宽容锚随动）]`：SKILL.md:288 实态=「Rule 40-71 全集」，上界 69<71 失配=0，随动 40-[56][0-9]→40-[567][0-9]（覆盖 40-53..40-79）
- :85 断言行: `a="$(grep -cE '含 Rule 40-[567][0-9] 全集' "$SKILLMD" || true)"`
- :87 ok/bad 文案同步 5x/6x/7x

### 2. skills/task-planner/scripts/selftest-workflow-orchestration.sh
- :69 新增级联注 `[2026-10-10 task-v158 级联（宽容锚随动）]` '1-68'→'1-71' 变体族
- :71 计数族扩为 `grep -cE 'Critical Rules 1-(68|71)'` + `grep -cE '1-(68|71)'`（保持 ≥3 语义；旧纪元哨兵 1-68 保留族内）
- :74/:75 ok/bad 文案同步 1-68/1-71
- :74 oldres 逻辑未动（旧纪元 1-39/1-45 负断言保留）

## 证据

### 实态核验（worktree 内 grep 实证）
- SKILL.md:288 = `Critical Rules 1-71（含 Rule 40-71 全集，…）`（References 行）
- SKILL.md:372 = `Critical Rules 1-71（…Rule 65 周期性回顾与前后对照）`（critical-rules 表行）
- SKILL.md:225 C48 行 = `无源不写与空段占位自查（Rule 71）`（含 Rule 71 引用，但不含 "1-71" 字面量；任务描述中"C48 行引用"计入 1-71 依据=未验证，实际 1-71 字面命中仅 2 处 :288/:372）
- `grep -cE '1-(68|71)'` SKILL.md = 2（:288+:372）
- 四索引文档求和实测 cnt=8 ≥3 → WF-10 PASS

### 验收
1. `bash selftest-reliability-institution.sh` → Total: 16 PASS=16 FAIL=0（R-09 PASS）✓
2. `bash selftest-workflow-orchestration.sh` → Total: 16 PASS=16 FAIL=0（WF-10 PASS，输出 `命中总和 8 ≥3`）✓
3. `bash -n` 双脚本通过（SYNTAX-OK）✓
4. diff 复核：本 S-unit 写入仅上述 2 文件；worktree `git status` 显示其他 10+ 个 selftest 脚本与 plans 文件 M/??，均出自同任务其他 S-unit（15a-cd-el/15b-rv-vt/15d-dcs-eh/15e-rr-sr 检查点在案），非本单元写入 ✓

## findings
- 发现偏差（已按实锚最小化修正）：任务描述称「:225 C48 行引用」构成 1-71 命中第三处——实锚核验 :225 C48 行文本为 `无源不写与空段占位自查（Rule 71）`，不含 `1-71` 字面量；grep -n 实证 1-71 字面命中仅 2 处（:288/:372）。扩族后 :288 行被双模式（Critical Rules 1-71 + 1-71）各计 1、:372 同，SKILL.md 侧=4，含 CLAUDE.md 等旧纪元 1-68 残留合计 cnt=8，≥3 语义满足，WF-10 PASS 不受影响。未回改任务描述，仅在此留痕。
- 负结果核查：本单元仅改 2 文件；未触碰 critical-rules.md/SKILL.md/CLAUDE.md/README*；其他单元 diff 与本单元零交叉（文件集不相交）。

## confidence: HIGH（改动 2 文件内全部带锚实证 + 双 selftest FAIL=0 实测）
