#!/usr/bin/env bash
# check-verdict — 读取 verification 文本，校验三态；BLOCKED 须 confirmed:true
set -uo pipefail
F="${1:-/dev/stdin}"
[ -r "$F" ] || { echo "[verdict] rc2: unreadable" >&2; exit 2; }
# Why（2026-11-27 Task5）：brief 内联写法 `python3 - "$F" <<'PY'` 让 Python 源码占用 fd0，
# 此时 open('/dev/stdin') 读到的是源码末尾（空内容）→ 恒 rc1，TC-02 无法放行。
# What：把目标文本额外挂到 fd3（在 heredoc 替换 fd0 之前打开），Python 从 /dev/fd/3 读原文；
# 普通文件路径同样适用，调用接口与三态判定语义不变。
python3 - "$F" 3<"$F" <<'PY'
import sys,re
txt=open('/dev/fd/3',encoding='utf-8').read()
lines=txt.splitlines()
# Why（2026-11-27 Task5 终审 P0 假绿）：原实现 re.search 取首个 outcome 行，存量 rendered
# verification.md 的模板字面行 `outcome: COMPLETE / PARTIAL / BLOCKED` 常排在真实值之前
# （全仓约 78/240 份），导致真实 `outcome: BLOCKED + confirmed:false` 被读成 COMPLETE 而 rc0。
# What：扫描全部 outcome 行，跳过含 ` / ` 的模板示例行，只认最后一个真实 outcome。
outcome_re=re.compile(r'^\s*outcome:\s*(COMPLETE|PARTIAL|BLOCKED)\b')
real=[(i,m.group(1)) for i,line in enumerate(lines)
      for m in [outcome_re.search(line)] if m and ' / ' not in line]
if not real: print('[verdict] rc1: no outcome',file=sys.stderr); sys.exit(1)
idx,verdict=real[-1]
if verdict=='BLOCKED':
    # Why：confirmed 若按全文首个匹配取值，模板示例的 `confirmed: true/false` 或前一轮记录
    # 会绑定到本轮 BLOCKED 上，同样造成假绿；故只取与该真实 outcome 同行或紧随其后（容一空行）的值。
    c=re.search(r'\bconfirmed:\s*(true|false)\b',lines[idx])
    if c is None:
        for j in (idx+1,idx+2):
            if j<len(lines):
                c=re.search(r'^\s*confirmed:\s*(true|false)\b',lines[j])
                if c: break
    if not c or c.group(1)!='true':
        print('[verdict] rc1: BLOCKED without user confirmation',file=sys.stderr); sys.exit(1)
print('[verdict] OK: %s'%verdict); sys.exit(0)
PY
