# P1 Checkpoint — task-mdedit-trigger-20261116

## Scope (worktree only)
- Worktree: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116` (branch `wt/task-mdedit-trigger-20261116`)
- Modified files:
  1. `skills/task-planner/scripts/zcode-pretooluse.sh`
  2. `skills/task-discipline/references/execution-recall-card.md`
  3. `skills/task-discipline/SKILL.md`

## 1. Hook advisory implementation (S1)

**Change (incremental, in `Write|Edit|ApplyPatch)` case, before delegation logic):**
- Added md-edit-ops advisory block with What/Why comment:
  - `# [2026-11-16 task-mdedit-trigger-20261116] md-edit-ops advisory (What: Write/Edit 修改 .md 时按结构化/批量信号输出 md-edit-ops 提醒; Why: 封堵普通会话随手编辑 .md 不触发 md-edit-ops 的缺口，Rule 106.6 协同；fail-open 仅提醒不阻断)`
- Conditions: `tool` in {Write,Edit} ∧ `file_path` ends `.md` ∧ path not matching `*/plans/*|plans/*` ∧ (Edit: `old_string` or `new_string` contains newline OR `${#_os}+${#_ns}>=200`) ∨ (Write: `${#content}>=600`)
- Output (stdout, advisory, no exit): `[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit`
- jq parse/field access uses `2>/dev/null || printf ''` fallbacks → fail-open behavior preserved.

**Diff (main repo vs worktree hook):**
Command: `cd /mnt/data/dev/task-planner-skill && diff -u skills/task-planner/scripts/zcode-pretooluse.sh tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh; echo "---diff-exit:$?---"`
Output:
```
--- skills/task-planner/scripts/zcode-pretooluse.sh	2026-11-03 00:59:31.047996173 +0800
+++ tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh	2026-11-16 04:08:20.412280744 +0800
@@ -27,6 +27,36 @@
 # Edit 的 new_string 行数:从 stdin JSON 截前 4KB(M-4)后 wc -l;字段缺失传 "-"
 case "$tool" in
   Write|Edit|ApplyPatch)
+    # [2026-11-16 task-mdedit-trigger-20261116] md-edit-ops advisory (What: Write/Edit 修改 .md 时按结构化/批量信号输出 md-edit-ops 提醒; Why: 封堵普通会话随手编辑 .md 不触发 md-edit-ops 的缺口，Rule 106.6 协同；fail-open 仅提醒不阻断)
+    if [ "$tool" = "Write" ] || [ "$tool" = "Edit" ]; then
+      case "$file" in
+        *.md)
+          case "$file" in
+            */plans/*|plans/*) : ;;
+            *)
+              _md_hit=0
+              if [ "$tool" = "Edit" ]; then
+                _os="$(printf '%s' "$input" | jq -r '.tool_input.old_string // ""' 2>/dev/null || printf '')"
+                _ns="$(printf '%s' "$input" | jq -r '.tool_input.new_string // ""' 2>/dev/null || printf '')"
+                if [[ "$_os" == *$'\n'* || "$_ns" == *$'\n'* ]]; then
+                  _md_hit=1
+                elif [ $(( ${#_os} + ${#_ns} )) -ge 200 ] 2>/dev/null; then
+                  _md_hit=1
+                fi
+              elif [ "$tool" = "Write" ]; then
+                _ct="$(printf '%s' "$input" | jq -r '.tool_input.content // ""' 2>/dev/null || printf '')"
+                if [ "${#_ct}" -ge 600 ] 2>/dev/null; then
+                  _md_hit=1
+                fi
+              fi
+              if [ "$_md_hit" -eq 1 ] 2>/dev/null; then
+                printf '%s\n' "[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit"
+              fi
+              ;;
+          esac
+          ;;
+      esac
+    fi
     sid="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
     sid="${sid:-default}"
     lines_arg="-"
---diff-exit:1---
```
(Exit 1 due to differences present; diff shows only the inserted advisory block — no existing logic removed/modified.)

**Existing rc=2 paths preserved (line numbers shifted by insertion only):**
Command:
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116 && \
diff -u <(cd /mnt/data/dev/task-planner-skill && grep -n 'exit 2' skills/task-planner/scripts/zcode-pretooluse.sh) \
        <(grep -n 'exit 2' skills/task-planner/scripts/zcode-pretooluse.sh) || true
```
Output:
```
--- /dev/fd/63 ...
+++ /dev/fd/62 ...
@@ -1,6 +1,6 @@
 22:  exit 2
-44:      #  - 阻断反馈走 stderr + exit 2(Claude hook 规范;与 check-scope 路径一致)
-53:      exit 2
-59:    [ "$rc" -eq 2 ] && exit 2
-64:    # fail-open:mktemp/jq 失败一律 exit 0;阻断反馈由 check-dispatch.sh 走 stderr,此处只透传 exit 2
-80:    [ "$rc" -eq 2 ] && exit 2
+74:      #  - 阻断反馈走 stderr + exit 2(Claude hook 规范;与 check-scope 路径一致)
+83:      exit 2
+89:    [ "$rc" -eq 2 ] && exit 2
+94:    # fail-open:mktemp/jq 失败一律 exit 0;阻断反馈由 check-dispatch.sh 走 stderr,此处只透传 exit 2
+110:    [ "$rc" -eq 2 ] && exit 2
```
(Same 6 occurrences/text, shifted down by advisory block insertion.)

**Marker/guard grep:**
Command: `cd $WT && grep -n '\[md-edit-ops\] 提醒:' skills/task-planner/scripts/zcode-pretooluse.sh && echo "---" && grep -n 'Rule 106.6' skills/task-planner/scripts/zcode-pretooluse.sh`
Output:
```
53:                printf '%s\n' "[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit"
---
30:    # [2026-11-16 task-mdedit-trigger-20261116] md-edit-ops advisory (What: Write/Edit 修改 .md 时按结构化/批量信号输出 md-edit-ops 提醒; Why: 封堵普通会话随手编辑 .md 不触发 md-edit-ops 的缺口，Rule 106.6 协同；fail-open 仅提醒不阻断)
53:                printf '%s\n' "[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit"
```

**Syntax check:** `bash -n .../zcode-pretooluse.sh && echo syntax-ok` → `syntax-ok`

## 2. Discipline wiring (S2, S3)

**Recall card §B tail:**
Command: `cd $WT && tail -n 5 skills/task-discipline/references/execution-recall-card.md`
Output:
```
- 决策分级：A 级变更必呈报；琐碎禁上抛；可测问题禁问用户（Rule 72/86）
- 已确立事实禁反言：短窗口内无新证据禁结论反复横跳（Rule 89）
- 用户否决的方案禁无验证重提（Rule 32）
- 文本优先：规则类诉求=文本条款落最贴近载体；新增脚本/守护=范围扩张须显式授权（Rule 38.7）
- 通道快速失败：不可用禁 ≥2 次同法重试，给三选项（Rule 83）
- 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL
```
(Anchored in `## B. 变更与范围` section.)

**SKILL.md pointer:**
Command: `cd $WT && grep -n 'md-edit-ops' skills/task-discipline/SKILL.md | head -n 5`
Output:
```
27:- md-edit-ops 指针（速查）：批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL。
```
(Placed in "卫星路由：task-discipline"速查/域边界邻近区，紧随调用条件行。)

## 3. Hook simulations (6 required + 1 extra NEG4)

**Final rerun command pattern:** `printf '%s' '<json>' | bash $H` (worktree hook). Captured EXIT/STDOUT/STDERR/HAS_REMINDER. SIM_TMPDIR=`/tmp/tmp.b4Lo65Q8bR`

| Case | Condition | JSON (key fields) | EXIT | HAS_REMINDER | Expected | Result |
|------|-----------|-------------------|------|--------------|----------|--------|
| POS1_edit_multiline | Edit, .md, non-plans, old_string has `\n` | `{"tool_name":"Edit","tool_input":{"file_path":"/tmp/hit1.md","old_string":"line1\nline2","new_string":"x"}}` | 0 | yes | hit | PASS |
| POS2_edit_total_ge200 | Edit, .md, non-plans, single-line but old(150)+new(60)=210>=200 | old="a"*150,new="b"*60 | 0 | yes | hit | PASS |
| POS3_write_ge600 | Write, .md, non-plans, content len 600 | content="x"*600 | 0 | yes | hit | PASS |
| NEG1_plans_path_multiline | Edit, .md but path `/tmp/my/plans/x.md`, multiline | path has `/plans/` | 0 | no | no hit | PASS |
| NEG2_edit_single_short | Edit, .md, non-plans, single-line old+new 6 chars | old="abc",new="def" | 0 | no | no hit | PASS |
| NEG3_write_lt600 | Write, .md, non-plans, content len 599 | content="y"*599 | 0 | no | no hit | PASS |
| NEG4_txt_multiline | Edit, .txt, multiline | path `/tmp/notes.txt` | 0 | no | no hit | PASS |

**Raw outputs (final, correct):**
```
===== CASE: POS1_edit_multiline =====
CMD: printf '%s' '<json>' | bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh
JSON: {"tool_name":"Edit","tool_input":{"file_path":"/tmp/hit1.md","old_string":"line1\nline2","new_string":"x"}}
EXIT:0
STDOUT:
[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit
STDERR:

HAS_REMINDER:
yes

===== CASE: POS2_edit_total_ge200 =====
CMD: printf '%s' '<json>' | bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh
JSON: {"tool_name": "Edit", "tool_input": {"file_path": "/tmp/hit2.md", "old_string": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "new_string": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"}}
EXIT:0
STDOUT:
[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit
STDERR:

HAS_REMINDER:
yes

===== CASE: POS3_write_ge600 =====
CMD: printf '%s' '<json>' | bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh
JSON: {"tool_name": "Write", "tool_input": {"file_path": "/tmp/hit3.md", "content": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}}
EXIT:0
STDOUT:
[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit
STDERR:

HAS_REMINDER:
yes

===== CASE: NEG1_plans_path_multiline =====
CMD: printf '%s' '<json>' | bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh
JSON: {"tool_name":"Edit","tool_input":{"file_path":"/tmp/my/plans/x.md","old_string":"a\nb","new_string":"c"}}
EXIT:0
STDOUT:

STDERR:

HAS_REMINDER:
no

===== CASE: NEG2_edit_single_short =====
CMD: printf '%s' '<json>' | bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh
JSON: {"tool_name":"Edit","tool_input":{"file_path":"/tmp/short.md","old_string":"abc","new_string":"def"}}
EXIT:0
STDOUT:

STDERR:

HAS_REMINDER:
no

===== CASE: NEG3_write_lt600 =====
CMD: printf '%s' '<json>' | bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh
JSON: {"tool_name": "Write", "tool_input": {"file_path": "/tmp/short.md", "content": "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"}}
EXIT:0
STDOUT:

STDERR:

HAS_REMINDER:
no

===== CASE: NEG4_txt_multiline =====
CMD: printf '%s' '<json>' | bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh
JSON: {"tool_name":"Edit","tool_input":{"file_path":"/tmp/notes.txt","old_string":"a\nb","new_string":"c\nd"}}
EXIT:0
STDOUT:

STDERR:

HAS_REMINDER:
no

SIM_TMPDIR=/tmp/tmp.b4Lo65Q8bR
```

**Note (honest record):** initial POS2 fixture in first run used old 120 chars + new "short" (total 125 < 200) so reminder did not fire (HAS_REMINDER no, EXIT 0). Corrected POS2 to old 150 + new 60 = 210 >=200 and reran → hit as expected. During that debug I also found `grep -q $'\n'` behaved unexpectedly in this environment and replaced newline detection with bash `[[ "$_os" == *$'\n'* || "$_ns" == *$'\n'* ]]`; after fix NEG2 became correct (no hit).

## 4. Selftests (worktree)

| Script | Command | RC | Evidence (tail/summary) |
|--------|---------|----|-------------------------|
| selftest-delegation.sh | `cd $WT && bash skills/task-planner/scripts/selftest-delegation.sh` | 0 | `Total: 38 PASS=38 FAIL=0` |
| selftest-execution-stability.sh | `cd $WT && bash skills/task-planner/scripts/selftest-execution-stability.sh` | 1 | `Total: 19 PASS=18 FAIL=1` failing `[FAIL] T11b B1 负例...` |
| selftest-input-consistency.sh | `cd $WT && bash skills/task-planner/scripts/selftest-input-consistency.sh` | 0 | `Total: PASS=5 FAIL=0 WARN=0` |
| selftest-anti-deferral.sh | `cd $WT && bash skills/task-planner/scripts/selftest-anti-deferral.sh` | 0 | `Total: 12 PASS=12 FAIL=0` |
| selftest-enumerate-first.sh | `cd $WT && bash skills/task-planner/scripts/selftest-enumerate-first.sh` | 0 | `Total: 7 PASS=7 FAIL=0` |
| selftest-file-disposal.sh | `cd $WT && bash skills/task-planner/scripts/selftest-file-disposal.sh` | 0 | `Total: 8 PASS=8 FAIL=0` |

**Baseline check for execution-stability:**
Command: `cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/selftest-execution-stability.sh; echo MAIN_RC:$?`
Result: `MAIN_RC:1`, same failure `T11b B1 负例... Total: 19 PASS=18 FAIL=1` on main repo (not introduced by this task's changes).

## 5. Quick VC-style checks

Commands (worktree):
```bash
F="skills/task-planner/scripts/zcode-pretooluse.sh"; R="skills/task-discipline/references/execution-recall-card.md"; S="skills/task-discipline/SKILL.md"
grep -qF '[md-edit-ops] 提醒:' "$F" && echo hit_reminder
grep -qF 'Rule 106.6' "$F" && echo hit_rule
grep -q '/plans/' "$F" && echo hit_plans_guard
grep -qF '批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL' "$R" && echo recall_line_ok
grep -q '## B. 变更与范围' "$R" && echo recall_section_ok
grep -q 'md-edit-ops' "$S" && echo skill_mdedit_ok
grep -q 'Rule 106.6' "$S" && echo skill_rule_ok
```
Output: `hit_reminder, hit_rule, hit_plans_guard, recall_line_ok, recall_section_ok, skill_mdedit_ok, skill_rule_ok` (all present).
