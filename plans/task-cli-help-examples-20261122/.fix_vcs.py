#!/usr/bin/env python3
"""一次性修复脚本：重写 VC-1/2/3/4/6/7 判别力 + 修 C-2（VC-7 挂载）。用完即删。"""
import json, subprocess

P = '/home/terry/.zcode/skills/task-planner/scripts/planctl.py'
WT = '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner'
WT_ROOT = WT.rsplit('/skills/task-planner', 1)[0]


def run(*a):
    r = subprocess.run(a, capture_output=True, text=True)
    if r.returncode:
        print('ERR', a[:4], r.stderr.strip()[:150])
    return r.returncode


def set_cmd(vc_id, value):
    run('python3', P, 'set', '--plan-dir', '.', '--section', 'vcs',
        '--id', vc_id, '--field', 'command', '--value', value)


# VC-1: 去裸 exit；用中文"退出码"/"工作流"锚（argparse 默认 help 无这些词）
set_cmd('VC-1',
    "for s in list add clone derive; do bash '%s'/scripts/template-catalog.sh $s --help | grep -qE '示例|Example' || exit 1; done; "
    "bash '%s'/scripts/template-catalog.sh --help | grep -qE '退出码|工作流|Examples' || exit 1" % (WT, WT))

# VC-2: 加"输出约定"锚
set_cmd('VC-2',
    "python3 '%s'/scripts/planctl.py --help | grep -qE '示例|Examples' || exit 1; "
    "python3 '%s'/scripts/planctl.py --help | grep -q '输出约定' || exit 1; "
    "for s in init add set check render audit-add; do python3 '%s'/scripts/planctl.py $s --help | grep -qE '示例|Example' || exit 1; done" % (WT, WT, WT))

# VC-3: 加正反例锚 + 示例代码块数 + 两 CLI 名
vc3 = (
    'wt="%s"; '
    'grep -q "命令选择决策表" "$wt/SKILL.md" && '
    'grep -q "常见误用" "$wt/SKILL.md" && '
    'grep -q "端到端" "$wt/SKILL.md" && '
    'grep -qE "反例|错误示范" "$wt/SKILL.md" && '
    'grep -q "template-catalog" "$wt/examples.md" && '
    'grep -q "planctl" "$wt/examples.md" && '
    'grep -qE "反例|错误示范" "$wt/examples.md" && '
    'test $(grep -c \'```bash\' "$wt/examples.md") -ge 3' % WT
)
set_cmd('VC-3', vc3)

# VC-4: 全量子命令采样合法 flag；文档只取含脚本名的行；无 ignore 名单
vc4 = """python3 - <<'PY'
import re, subprocess, sys
wt = '%s'
legal = set()
def sample(cmd):
    legal.update(re.findall(r'--[a-z][a-z-]+', subprocess.run(cmd, capture_output=True, text=True).stdout))
sample(['bash', wt + '/scripts/template-catalog.sh', '--help'])
for s in ('list', 'add', 'clone', 'derive'):
    sample(['bash', wt + '/scripts/template-catalog.sh', s, '--help'])
root = subprocess.run(['python3', wt + '/scripts/planctl.py', '--help'], capture_output=True, text=True).stdout
m = re.search(r'\\{([^}]+)\\}', root)
subs = re.split(r',\\s*', m.group(1).strip()) if m else ()
sample(['python3', wt + '/scripts/planctl.py', '--help'])
for s in subs:
    if s:
        sample(['python3', wt + '/scripts/planctl.py', s, '--help'])
fake = []
for fn in ('SKILL.md', 'examples.md'):
    for line in open(wt + '/' + fn):
        if 'planctl.py' in line or 'template-catalog.sh' in line:
            for f in re.findall(r'--[a-z][a-z-]+', line):
                if f not in legal:
                    fake.append(fn + ':' + f)
print('LEGAL=', len(legal), 'FAKE=', fake)
sys.exit(1 if fake else 0)
PY""" % WT
set_cmd('VC-4', vc4)

# VC-6: 单次 --fresh + 正则 ^[FAIL] + 差集
vc6 = """python3 - <<'PY'
import re, subprocess, sys
wt = '%s'
out = subprocess.run(['bash', wt + '/scripts/run-selftests.sh', '--fresh'], capture_output=True, text=True)
text = (out.stdout or '') + (out.stderr or '')
base = {'selftest-active-plan','selftest-batch-pilot','selftest-enumerate-first','selftest-execution-stability','selftest-registry','selftest-rule-reserve-pairing','selftest-self-resolution','selftest-summary-readability'}
cur = set(re.findall(r'^\\[FAIL\\]\\s+(selftest-\\S+)', text, re.M))
new = sorted(cur - base)
print('BASE_FAIL=', len(base)); print('CUR_FAIL=', sorted(cur)); print('NEW_FAIL=', new)
sys.exit(1 if new else 0)
PY""" % WT
set_cmd('VC-6', vc6)

# VC-7: worktree 内 git diff + 放宽控制流正则
set_cmd('VC-7',
    "cd %s && n=$(git diff -U0 master -- skills/task-planner/scripts/template-catalog.sh skills/task-planner/scripts/planctl.py | grep -cE '^[+-][[:space:]]*(def |class |async def |return|if |elif |else:|for |while |try:|except|raise )'); "
    "echo CTRL_FLOW_DIFF=$n; test $n -eq 0" % WT_ROOT)

# C-2: VC-7 挂 R3.vc + P4.v_checks
r3 = json.loads(subprocess.run(['python3', P, 'get', '--plan-dir', '.', '--section', 'requirements', '--id', 'R3'], capture_output=True, text=True).stdout)
r3['vc'] = ['VC-5', 'VC-6', 'VC-7']
run('python3', P, 'update', '--plan-dir', '.', '--section', 'requirements', '--id', 'R3', '--json', json.dumps(r3, ensure_ascii=False))
p4 = json.loads(subprocess.run(['python3', P, 'get', '--plan-dir', '.', '--section', 'phases', '--id', 'P4'], capture_output=True, text=True).stdout)
p4['v_checks'] = ['VC-4', 'VC-6', 'VC-7']
run('python3', P, 'update', '--plan-dir', '.', '--section', 'phases', '--id', 'P4', '--json', json.dumps(p4, ensure_ascii=False))

print('ALL VC REWRITTEN + C-2 FIXED')
