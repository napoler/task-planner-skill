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
m=re.search(r'^\s*outcome:\s*(COMPLETE|PARTIAL|BLOCKED)',txt,re.M)
if not m: print('[verdict] rc1: no outcome',file=sys.stderr); sys.exit(1)
if m.group(1)=='BLOCKED':
    c=re.search(r'^\s*confirmed:\s*(true|false)',txt,re.M)
    if not c or c.group(1)!='true':
        print('[verdict] rc1: BLOCKED without user confirmation',file=sys.stderr); sys.exit(1)
print('[verdict] OK: %s'%m.group(1)); sys.exit(0)
PY
