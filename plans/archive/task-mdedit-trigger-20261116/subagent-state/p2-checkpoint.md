# P2 复检 checkpoint（task-mdedit-trigger-20261116）
- task_id: task-mdedit-trigger-20261116
- phase: P2 独立复检（Rule 103.3 全新复检体）
- worktree: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116
- main_repo: /mnt/data/dev/task-planner-skill
- date: 2026-11-16
- 隔离约束: 只读 worktree 与计划目录；未执行 git 写操作/部署；仅写入本 checkpoint 与 /tmp 临时 fixture 脚本

## 1. Hook 模拟 6+1 例（独立构造 fixture，不照抄 P1）

### 1.1 测试目标与判定口径
- 目标 hook: `skills/task-planner/scripts/zcode-pretooluse.sh`（worktree）
- 提醒标记: `[md-edit-ops] 提醒:`
- 正例判定: stdout 含提醒 且 exit 0
- 负例判定: stdout 不含提醒 且 exit 与主仓同输入/同 cwd 行为一致（题述允许负例可能触发其他既有逻辑，只需断言无 md-edit-ops 提醒）
- 额外观察: 负例同时在主仓 hook 上对照执行，记录 main_rc/main_stdout/main_stderr 以验证“exit 与主仓同输入行为一致”

### 1.2 Fixture 构造（Python 生成 6+1 例）
命令:
```bash
cat > /tmp/run_mdedit_hook_cases.py <<'PYTHON'
...（见下方脚本实录）...
PYTHON
python3 /tmp/run_mdedit_hook_cases.py 2>&1
```

脚本实录关键片段（独立构造）:
```python
WT = "/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116"
MAIN = "/mnt/data/dev/task-planner-skill"
WT_HOOK = os.path.join(WT, "skills/task-planner/scripts/zcode-pretooluse.sh")
MAIN_HOOK = os.path.join(MAIN, "skills/task-planner/scripts/zcode-pretooluse.sh")
REMINDER = "[md-edit-ops] 提醒:"
# P1: Edit multi-line old_string
{"tool_name":"Edit","tool_input":{"file_path":"/tmp/testdoc.md","old_string":"line1\nline2\nline3","new_string":"single"}}
# P2: Edit single-line but total old+new >= 200 (120+80)
{"tool_name":"Edit","tool_input":{"file_path":"/tmp/readme.md","old_string":"a"*120,"new_string":"b"*80}}
# P3: Write content >= 600
{"tool_name":"Write","tool_input":{"file_path":"/tmp/notes.md","content":"x"*600}}
# N1: path 含 plans/ 且多行
{"tool_name":"Edit","tool_input":{"file_path":"/mnt/data/dev/task-planner-skill/plans/task-x/doc.md","old_string":"a\nb\nc","new_string":"d\ne"}}
# N2: Edit 单行短改
{"tool_name":"Edit","tool_input":{"file_path":"/tmp/short.md","old_string":"hello","new_string":"world"}}
# N3: Write content == 599
{"tool_name":"Write","tool_input":{"file_path":"/tmp/boundary.md","content":"y"*599}}
# N4 (第7例): Edit .txt 多行
{"tool_name":"Edit","tool_input":{"file_path":"/tmp/data.txt","old_string":"a\nb\nc","new_string":"d\ne\nf"}}
# 对每例: worktree hook 执行；负例额外在 main hook 同输入执行对照
```

### 1.3 执行结果（原始 JSON 输出）

```json
[
  {
    "id": "P1_Edit_multiline_old_string",
    "type": "positive",
    "wt_rc": 0,
    "wt_reminder_hit": true,
    "wt_stdout": "[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit\n",
    "wt_stderr": ""
  },
  {
    "id": "P2_Edit_singleline_total_ge200",
    "type": "positive",
    "wt_rc": 0,
    "wt_reminder_hit": true,
    "wt_stdout": "[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit\n",
    "wt_stderr": ""
  },
  {
    "id": "P3_Write_content_ge600",
    "type": "positive",
    "wt_rc": 0,
    "wt_reminder_hit": true,
    "wt_stdout": "[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（<技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit\n",
    "wt_stderr": ""
  },
  {
    "id": "N1_path_plans_multiline",
    "type": "negative",
    "wt_rc": 0,
    "wt_reminder_hit": false,
    "wt_stdout": "",
    "wt_stderr": "",
    "main_rc": 0,
    "main_reminder_hit": false,
    "main_stdout": "",
    "main_stderr": "",
    "exit_matches_main": true
  },
  {
    "id": "N2_Edit_singleline_short",
    "type": "negative",
    "wt_rc": 0,
    "wt_reminder_hit": false,
    "wt_stdout": "",
    "wt_stderr": "",
    "main_rc": 0,
    "main_reminder_hit": false,
    "main_stdout": "",
    "main_stderr": "",
    "exit_matches_main": true
  },
  {
    "id": "N3_Write_content_599",
    "type": "negative",
    "wt_rc": 0,
    "wt_reminder_hit": false,
    "wt_stdout": "",
    "wt_stderr": "",
    "main_rc": 2,
    "main_reminder_hit": false,
    "main_stdout": "",
    "main_stderr": "[delegation-block] 🚫 主进程直做拦截 — file=/tmp/boundary.md\n按 SKILL.md 路由表派子代理执行(Write/Edit/ApplyPatch 业务代码默认派 code-assistant/executor);\n若属误拦,确认文件路径是否应纳入 plans/ 白名单(.md/.json,见 check-delegation.sh);\n若用户明文要求主进程亲为,请**用户**在主对话确认后运行技能目录下 allow-direct.sh(路径见 scripts/):\n  提示语:on 子命令需要 --confirm-user-requested 参数;同时会校验当前 sid 是否已 bypass 过(同 sid 仅一次;若需同 plan-dir 二次 bypass,加 --force)\n(30 分钟窗口;会被 ledger 记录并在终验展示)\n",
    "exit_matches_main": false
  },
  {
    "id": "N4_Edit_txt_multiline",
    "type": "negative",
    "wt_rc": 0,
    "wt_reminder_hit": false,
    "wt_stdout": "",
    "wt_stderr": "",
    "main_rc": 0,
    "main_reminder_hit": false,
    "main_stdout": "",
    "main_stderr": "",
    "exit_matches_main": true
  }
]
```

### 1.4 N3 差异澄清（cwd 影响既有 delegation 门控，不影响“无 md-edit-ops 提醒”判定）
命令:
```bash
python3 /tmp/n3_check.py 2>&1
```
```python
# payload 同 N3；分别在 cwd=MAIN 与 cwd=WT 下跑 WT hook 与 MAIN hook
```
输出:
```
--- cwd=MAIN ---
WT rc=2 hit=False
STDERR_HEAD: [delegation-block] 🚫 主进程直做拦截 — file=/tmp/boundary.md
按 SKILL.md 路由表派子代理执行(Write/Edit/ApplyPatch 业务代码默认派 code-assistant/executor);
MAIN rc=2 hit=False
STDERR_HEAD: [delegation-block] 🚫 主进程直做拦截 — file=/tmp/boundary.md
按 SKILL.md 路由表派子代理执行(Write/Edit/ApplyPatch 业务代码默认派 code-assistant/executor);
--- cwd=WT ---
WT rc=0 hit=False
MAIN rc=0 hit=False
```
结论: N3 下 WT/MAIN hook 在相同 cwd 条件下行为一致（均无 md-edit-ops 提醒，exit 均为 0 或均为 2 随 cwd 而变）；初次批跑时 cwd=WT 导致 WT rc=0、MAIN rc=2 的表观差异来自既有 delegation 门控对 cwd/plan 上下文的敏感性，非 md-edit-ops advisory 引入。按题述负例判定“无提醒且 exit 与主仓同输入行为一致”，在同 cwd 对照下 **一致**。

### 1.5 Hook 用例判定汇总
| Case | 类型 | exit | 提醒命中 | 判定 |
|------|------|------|----------|------|
| P1_Edit_multiline_old_string | 正 | 0 | 是 | PASS |
| P2_Edit_singleline_total_ge200 | 正 | 0 | 是 | PASS |
| P3_Write_content_ge600 | 正 | 0 | 是 | PASS |
| N1_path_plans_multiline | 负 | 0 | 否 | PASS（与主仓同输入同 cwd 行为一致；无提醒） |
| N2_Edit_singleline_short | 负 | 0 | 否 | PASS（与主仓一致；无提醒） |
| N3_Write_content_599 | 负 | 0(wt)/0(main, cwd=WT); 2/2(cwd=MAIN) | 否 | PASS（同 cwd 对照 exit 一致；无提醒） |
| N4_Edit_txt_multiline | 负 | 0 | 否 | PASS（与主仓一致；无提醒） |

**小结: 6+1 例均满足判定口径（正例命中提醒且 exit 0；负例无提醒且同输入/同 cwd 行为与主仓一致）。**

## 2. Selftest 复跑与预存/引入判定

### 2.1 Worktree 执行（cwd=worktree）
命令与 RC:
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116
bash skills/task-planner/scripts/selftest-delegation.sh > /tmp/wt-selftest-delegation.log 2>&1; echo RC=$?            # RC=0
bash skills/task-planner/scripts/selftest-execution-stability.sh > /tmp/wt-selftest-execution-stability.log 2>&1; echo RC=$?  # RC=1
bash skills/task-planner/scripts/selftest-input-consistency.sh > /tmp/wt-selftest-input-consistency.log 2>&1; echo RC=$?      # RC=0
bash skills/task-planner/scripts/selftest-anti-deferral.sh > /tmp/wt-selftest-anti-deferral.log 2>&1; echo RC=$?              # RC=0
bash skills/task-planner/scripts/selftest-enumerate-first.sh > /tmp/wt-selftest-enumerate-first.log 2>&1; echo RC=$?        # RC=0
bash skills/task-planner/scripts/selftest-file-disposal.sh > /tmp/wt-selftest-file-disposal.log 2>&1; echo RC=$?              # RC=0
```

| selftest | worktree RC | 结果摘要 |
|----------|-------------|----------|
| selftest-delegation.sh | 0 | PASS=38 FAIL=0 |
| selftest-execution-stability.sh | 1 | PASS=18 FAIL=1（T11b FAIL） |
| selftest-input-consistency.sh | 0 | PASS=5 FAIL=0 WARN=0 |
| selftest-anti-deferral.sh | 0 | PASS=12 FAIL=0 |
| selftest-enumerate-first.sh | 0 | PASS=7 FAIL=0 |
| selftest-file-disposal.sh | 0 | PASS=8 FAIL=0 |

### 2.2 主仓对照（execution-stability）
命令与 RC:
```bash
cd /mnt/data/dev/task-planner-skill
bash skills/task-planner/scripts/selftest-execution-stability.sh > /tmp/main-selftest-execution-stability.log 2>&1; echo RC=$?  # RC=1
```

execution-stability worktree 尾部:
```
[PASS] T1 check-scope.sh 'memories' 豁免 ≥1
[PASS] T2a plan-created.cjs '兜底清除' ≥1
[PASS] T2b plan-created.cjs 假成功旧文案行为注释在位 ('无残留哨兵' ≥1)
[PASS] T3 zcode-posttooluse.sh 'attested_by_sid|自动重锁' ≥1
[PASS] T4 attest-plan.sh 'attested_by_sid' ≥1
[PASS] T5 zcode-userpromptsubmit.sh 'CLAUDE_CODE_SESSION_ID' ≥1
[PASS] T6 check-delegation.sh 'task-planner-observe' 节流 flag ≥1
[PASS] T7 config hook_self_heal_enforce=warn (python3)
[PASS] T8a hook 自愈实现锚(posttooluse session-owner 重锁 + ups delegation-observe 节流)
[PASS] T8b SKILL.md 行数 ≤558
[PASS] T9a config.json schema 键在位 + hook 面无拼写变体
[PASS] T9b 无拼写变体 hook-self-heal (全 0)
[PASS] T10a knowledge-brief.md 六段 grep -c '^## §' = 6（[2026-10-08 task-v144 合并级联] 五段→六段（§6 技能扫描区块，Rule 59.3））
[PASS] T10b init-session.sh '6/6' ≥1
[PASS] T11a B1 正例: 相对含 slash 路径 Edit → 自动重锁(attested_by_sid=sessabc123 且 plan_sha256=新文件哈希)
[FAIL] T11b B1 负例: 改内容后 owner=othersid999 → 重锁不命中(plan_sha256 仍为旧值 且 attested_by_sid 重置为空, 不被洗白)
[PASS] T13a S5 正例: 陈旧计划+verification.md(前导空格 outcome: COMPLETE) → POSTTOOL 输出无 plan-compass/plan-sync 提醒(兜底豁免生效)
[PASS] T13b S5 因果对照: 同 fixture 删 verification.md → 输出含 plan-compass/plan-sync 陈旧提醒(豁免由兜底分支因果生效, 非环境巧合)
[PASS] T12 B2 三侧 canon 一致 (pretooluse L17 / UPS L34 / jq 全链路, sid=sess-abc123)
Total: 19  PASS=18  FAIL=1
```

主仓 execution-stability 尾部: 同上（Total 19 PASS=18 FAIL=1，FAIL 项同为 T11b）。

日志 diff:
```bash
diff -u /tmp/main-selftest-execution-stability.log /tmp/wt-selftest-execution-stability.log 2>&1 | head -80; echo "---RCdiff=$?---"
```
输出:
```
---RCdiff=0---
```

### 2.3 其他 5 项 selftest 尾部摘要
- delegation: `Total: 38  PASS=38  FAIL=0`
- input-consistency: `Total: PASS=5 FAIL=0 WARN=0`
- anti-deferral: `Total: 12 PASS=12 FAIL=0`
- enumerate-first: `Total: 7  PASS=7  FAIL=0`
- file-disposal: `Total: 8  PASS=8  FAIL=0`

### 2.4 判定
- execution-stability: **预存失败（pre-existing）**。worktree 与主仓同为 `RC=1, PASS=18 FAIL=1`，失败点同为 `T11b`，日志 `diff -u` 无差异（RCdiff=0）。非本次 md-edit-ops 触发面改动引入。
- 其余 5 项: 全绿（RC=0），未见引入回归。

## 3. 语义接线核对

### 3.1 execution-recall-card.md §B 行
命令/输出:
```bash
grep -n "md-edit-ops" skills/task-discipline/references/execution-recall-card.md
20:- 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL

grep -n "Rule 106.6" skills/task-discipline/references/execution-recall-card.md
20:- 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL

grep -n "## B. 变更与范围" skills/task-discipline/references/execution-recall-card.md
13:## B. 变更与范围
```
结果: **在位**（§B 末尾追加行含 `md-edit-ops` 与 `Rule 106.6`）。

### 3.2 task-discipline/SKILL.md 指针行
命令/输出:
```bash
grep -n "md-edit-ops" skills/task-discipline/SKILL.md
27:- md-edit-ops 指针（速查）：批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL。

grep -n "Rule 106.6" skills/task-discipline/SKILL.md
27:- md-edit-ops 指针（速查）：批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL。
```
结果: **在位**（速查指针行含 `md-edit-ops` 与 `Rule 106.6`）。

### 3.3 worktree 与主仓差异仅 3 文件 3 处增量（目标文件对比）
命令/输出:
```bash
git -C /mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116 diff --name-only HEAD
skills/task-discipline/SKILL.md
skills/task-discipline/references/execution-recall-card.md
skills/task-planner/scripts/zcode-pretooluse.sh
```

逐目标文件 diff 摘要（主仓 vs worktree）:
- `skills/task-planner/scripts/zcode-pretooluse.sh`: `---RC=1---`（有差异）；新增 md-edit-ops advisory 块（Write/Edit `*.md` 且排除 `*/plans/*|plans/*`；Edit 命中 old/new 含换行或 old+new 长度合计>=200；Write 命中 content 长度>=600；命中则 stdout 输出提醒，fail-open 不改既有 rc=2 路径）。
- `skills/task-discipline/references/execution-recall-card.md`: `---RC=1---`；§B 末尾新增 1 行 md-edit-ops/Rule 106.6 指针。
- `skills/task-discipline/SKILL.md`: `---RC=1---`；新增 1 行 md-edit-ops 速查指针（含 Rule 106.6）。

结论: worktree 相对 HEAD 的改动文件集合 **仅上述 3 文件**；针对题述 3 个目标文件，主仓 vs worktree 均存在预期增量（hook advisory + 2 处语义接线），未发现额外目标外改动。

## 4. 最终 Verdict

**PASS-with-preexisting-exemption**

理由（证据锚定）:
1. Hook 6+1 例独立复跑全部符合判定口径：正例 3/3 命中 `[md-edit-ops] 提醒:` 且 `exit 0`；负例 4/4 均无提醒，且在同 cwd 对照下与主仓 hook 行为一致（N3 的表观 exit 差异经同 cwd 澄清为既有 delegation 门控上下文敏感性，非本改动引入，且无提醒判定满足）。
2. 指定 6 项 selftest：`delegation/input-consistency/anti-deferral/enumerate-first/file-disposal` 全绿（RC=0）。`execution-stability` 在 worktree 与主仓均为 `RC=1, PASS=18 FAIL=1 (T11b)`，日志 diff 无差异，判定为 **预存失败**，非本次引入。
3. 语义接线在位：`execution-recall-card.md` §B 行与 `task-discipline/SKILL.md` 指针行均含 `md-edit-ops` 与 `Rule 106.6`；worktree `git diff --name-only HEAD` 仅 3 文件，且 3 个目标文件相对主仓均为预期增量差异。

豁免登记: `selftest-execution-stability.sh` 的 `T11b` 预存失败（主仓同款复现，证据见 2.2）。此豁免不由本次改动引入，且与 md-edit-ops 触发面无因果关系。
