<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-cli-help-examples-20261122

- task_id: `task-cli-help-examples-20261122`
- 时间: created_at=2026-11-22T12:16:14Z / updated_at=2026-11-22T14:07:26Z

## Goal (1 sentence)
- 两个 CLI 的 help 输出含可照抄示例 + 副作用/退出码/参数说明，实测 help 可见
- SKILL.md+examples.md 含决策表/端到端示例/正反例/常见误用，覆盖 planctl 与 template-catalog
- 零执行逻辑变更；四部署位 diff=0；回归 selftest 零新增 FAIL

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pending | template-catalog.sh --help 输出含示例/退出码/工作流；list/add/clone/derive --help 各含示例 | for s in list add clone derive; do bash '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner'/scripts/template-catalog.sh $s --help \| grep -qE '示例\|Example' \|\| exit 1; done; bash '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner'/scripts/template-catalog.sh --help \| grep -q '退出码' \|\| exit 1; bash '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner'/scripts/template-catalog.sh --help \| grep -q '工作流' \|\| exit 1 |  |  |
| VC-2 | pending | planctl.py --help 与关键子命令 help 含可照抄示例 + 输出/退出码约定 | python3 '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner'/scripts/planctl.py --help \| grep -qE '示例\|Examples' \|\| exit 1; for s in init add set check render audit-add; do python3 '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner'/scripts/planctl.py $s --help \| grep -qE '示例\|Example' \|\| exit 1; done; grep -qE 'rc 0\|退出码\|exit code' '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner'/examples.md \|\| exit 1 |  |  |
| VC-3 | pending | SKILL.md 与 examples.md 含 template-catalog 与 planctl 的决策表/端到端示例/正反例/常见误用 | wt="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner"; grep -q "命令选择决策表" "$wt/SKILL.md" && grep -q "常见误用" "$wt/SKILL.md" && grep -q "端到端" "$wt/SKILL.md" && grep -qE "反例\|错误示范" "$wt/SKILL.md" && grep -q "template-catalog" "$wt/examples.md" && grep -q "planctl" "$wt/examples.md" && grep -qE "反例\|错误示范" "$wt/examples.md" && test $(grep -c '```bash' "$wt/examples.md") -ge 3 |  |  |
| VC-4 | pending | 两份文档新增内容准确：示例命令与脚本真实参数一致（无虚构 flag） | python3 - <<'PY' import re, subprocess, sys wt = '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner' legal = set() def sample(cmd):     legal.update(re.findall(r'--[a-z][a-z-]+', subprocess.run(cmd, capture_output=True, text=True).stdout)) sample(['bash', wt + '/scripts/template-catalog.sh', '--help']) for s in ('list', 'add', 'clone', 'derive'):     sample(['bash', wt + '/scripts/template-catalog.sh', s, '--help']) root = subprocess.run(['python3', wt + '/scripts/planctl.py', '--help'], capture_output=True, text=True).stdout m = re.search(r'\{([^}]+)\}', root) subs = re.split(r',\s*', m.group(1).strip()) if m else () sample(['python3', wt + '/scripts/planctl.py', '--help']) for s in subs:     if s:         sample(['python3', wt + '/scripts/planctl.py', s, '--help']) fake = [] for fn in ('SKILL.md', 'examples.md'):     text = open(wt + '/' + fn).read()     text = re.sub(r'\\\s*\n', ' ', text)  # 续行反斜杠+换行归一化为空格，消续行盲区     for line in text.splitlines():         if 'planctl.py' in line or 'template-catalog.sh' in line:             for f in re.findall(r'--[a-z][a-z-]+', line):                 if f not in legal:                     fake.append(fn + ':' + f) print('LEGAL=', len(legal), 'FAKE=', fake) sys.exit(1 if fake else 0) PY |  |  |
| VC-5 | pending | 四个部署位与源仓四个改动文件 md5 一致（diff=0） | diff=0; for f in scripts/template-catalog.sh scripts/planctl.py SKILL.md examples.md; do for d in /home/terry/.zcode/skills/task-planner /home/terry/.agents/skills/task-planner /home/terry/.claude/skills/task-planner /home/terry/.cursor/skills/task-planner; do cmp -s '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner'/$f $d/$f \|\| { echo "DIFF $d/$f"; diff=$((diff+1)); }; done; done; echo DIFF_COUNT=$diff; test $diff -eq 0 |  |  |
| VC-6 | pending | 回归 selftest 零新增 FAIL（对比基线 8 FAIL） | python3 - <<'PY' import re, subprocess, sys wt = '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner' out = subprocess.run(['bash', wt + '/scripts/run-selftests.sh', '--fresh'], capture_output=True, text=True) text = (out.stdout or '') + (out.stderr or '') base = {'selftest-active-plan','selftest-batch-pilot','selftest-enumerate-first','selftest-execution-stability','selftest-registry','selftest-rule-reserve-pairing','selftest-self-resolution','selftest-summary-readability'} cur = set(re.findall(r'^\[FAIL\]\s+(selftest-\S+)', text, re.M)) new = sorted(cur - base) print('BASE_FAIL=', len(base)); print('CUR_FAIL=', sorted(cur)); print('NEW_FAIL=', new) sys.exit(1 if new else 0) PY |  |  |
| VC-7 | pending | 执行逻辑零变更：两脚本新增 diff 无 def/class/return/if/for/while 控制流改动 | cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122 && n=$(git diff -U0 master -- skills/task-planner/scripts/template-catalog.sh skills/task-planner/scripts/planctl.py \| grep -cE '^[+-][[:space:]]*(def \|class \|async def \|return\|if \|elif \|else:\|for \|while \|try:\|except\|raise )'); echo CTRL_FLOW_DIFF=$n; test $n -eq 0 |  |  |

## Phase Gates
| Goal | Depends on | Done when | Checks | Status |
|---|---|---|---|---|
| （本任务暂无Phase Gates 记录） |  |  |  |  |

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|---|---|---|
| （本任务暂无知识符合性记录） |  |  |

## 委派统计复验（Rule 25.4）
- （本任务暂无委派复验记录）

## 质量门控统计（Rule 26）
- （本任务暂无质量门控记录）

## Goal Gate (终验，所有 phase complete 后执行)
- （本任务暂无Goal Gate 记录）

---
## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|---|---|---|---|
| （本任务暂无交叉验证记录） |  |  |  |

## 5-Question Reboot Check
| # | Question | Answer (fill on resume) |
|---|---|---|
| （本任务暂无5Q 记录） |  |  |
