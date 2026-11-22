#!/usr/bin/env python3
"""R3 修复：VC-1 双锚 / VC-2 输出约定改为文档侧退出码锚 / VC-4 续行归一化 + 代码块整体扫描。用完即删。"""
import json, subprocess

P = '/home/terry/.zcode/skills/task-planner/scripts/planctl.py'
WT = '/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner'


def run(*a):
    r = subprocess.run(a, capture_output=True, text=True)
    if r.returncode:
        print('ERR', a[:4], r.stderr.strip()[:150])
    return r.returncode


def set_cmd(vc_id, value):
    run('python3', P, 'set', '--plan-dir', '.', '--section', 'vcs',
        '--id', vc_id, '--field', 'command', '--value', value)


# VC-1: 退出码 与 工作流 两个锚分别断言（AND），去 OR 弱点
set_cmd('VC-1',
    "for s in list add clone derive; do bash '%s'/scripts/template-catalog.sh $s --help | grep -qE '示例|Example' || exit 1; done; "
    "bash '%s'/scripts/template-catalog.sh --help | grep -q '退出码' || exit 1; "
    "bash '%s'/scripts/template-catalog.sh --help | grep -q '工作流' || exit 1" % (WT, WT, WT))

# VC-2: 根 help 示例锚 + 六子命令示例锚（开工前 FAIL）；输出约定改查文档示例含退出码措辞
set_cmd('VC-2',
    "python3 '%s'/scripts/planctl.py --help | grep -qE '示例|Examples' || exit 1; "
    "for s in init add set check render audit-add; do python3 '%s'/scripts/planctl.py $s --help | grep -qE '示例|Example' || exit 1; done; "
    "grep -qE 'rc 0|退出码|exit code' '%s'/examples.md || exit 1" % (WT, WT, WT))

# VC-4: 续行归一化 + 按代码块整体扫描（消续行盲区）
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
    text = open(wt + '/' + fn).read()
    text = re.sub(r'\\\\\\s*\\n', ' ', text)  # 续行反斜杠+换行归一化为空格，消续行盲区
    for line in text.splitlines():
        if 'planctl.py' in line or 'template-catalog.sh' in line:
            for f in re.findall(r'--[a-z][a-z-]+', line):
                if f not in legal:
                    fake.append(fn + ':' + f)
print('LEGAL=', len(legal), 'FAKE=', fake)
sys.exit(1 if fake else 0)
PY""" % WT
set_cmd('VC-4', vc4)

print('R3 VC REWRITE DONE')
