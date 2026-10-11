# u4-executor — task-v155 RRV-04 绝对编号锚→内容锚修正

## 任务
修 `skills/task-planner/scripts/selftest-report-reviewability.sh` 的 RRV-04 断言（约 :103-113）：
原绝对编号锚 `grep -e '^| C46 '` 在合并并集后被并行任务占用（Rule 70 合规行让位至 C48），
改为内容锚：取 `^| C<digits> |` 合规行中含「用户呈报可审批性」的那行，再断言「待审项清单」「可定位地址」各 ≥1。
保留 `Rule 70 ≥4` 首锚不变。同步改写 What 头部注释与 RRV-04 段注释。

## 根因
合并并集后 Rule 70 合规行的绝对编号位被并行任务（Rule 68/69）占用，合规行整体让位（现为 SKILL.md:229 的 C48 行）；
绝对编号锚随编号后移必级联误报，故改内容锚，未来编号让位不再级联。

## 解法
- RRV-04 块：`C46_LINE=$(grep -e '^| C46 ' ...)` → `RRV04_LINE=$(grep -e '^| C[0-9]* |' "$SKILL" | grep "用户呈报可审批性")`
- 变量重命名去 C46：`RRV04_C46/_C46_LIST/_C46_ADDR` → `RRV04_LINE/RRV04_LIST/RRV04_ADDR`
- 断言：`Rule70>=4 && LIST>=1 && ADDR>=1`（原 `C46>=1` 计数条件删除，由内容锚行存在隐含）
- 注释：What 头部 RRV-04 说明 + RRV-04 段 What/Why 补根因（含指定措辞「合规行内容锚（用户呈报可审批性），未来编号让位不再级联——2026-10-10 task-v155 合并并集 cardinality 教训」）

## 冲突处置（供主进程知悉）
prompt §2 要求根因注释点名「C46/C47」，但验收项 1 要求 `grep -c "C46"` = 0（硬门）。
两者字面互斥。裁决：优先满足可观察硬门（grep=0），根因注释以「并行任务（Rule 68/69）占用绝对编号位、合规行整体让位（现为 C48 行）」表述，未落字面 C46/C47 令牌，语义等价。

## 验证证据
- `grep -c "C46" scripts/selftest-report-reviewability.sh` = 0
- `bash scripts/selftest-report-reviewability.sh` → exit 0，`Total: PASS=13 FAIL=0 WARN=0`（RRV-04 PASS）
- `bash -n` 语法 OK
- 内容锚交叉：`grep -nE '^\| C[0-9]+ \|' SKILL.md | grep '用户呈报可审批性'` → 唯一命中 `229:| C48 | 用户呈报可审批性（R…`；该行 待审项清单=1、可定位地址=1
- 负向稳健性：对副本将「待审项清单」变异后，list_hits=0 → 断言将 FAIL（守卫未被弱化）

## 约束遵守
未 git add/commit/merge/reset/checkout；仅改该脚本；未碰其他 worktree。

## 最终结论
```
status: done
acceptance: 3/3 pass — [1:PASS grep -c "C46"→0; 2:PASS bash selftest exit0 Total PASS=13 FAIL=0; 3:PASS 内容锚唯一命中 SKILL.md:229 C48 行且含待审项清单/可定位地址]
files: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-report-reviewability.sh(+15/-9)
evidence: selftest-report-reviewability.sh:108-119 新 RRV-04 块; 运行输出 `RRV-04 PASS: SKILL 接线锚(Rule 70≥4 合规行内容锚含四要素)` 与 `Total: PASS=13 FAIL=0 WARN=0`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/u4-executor.md (status: done)
findings_written: #### [sub:u4-executor]
blockers: none
confidence: HIGH
```
