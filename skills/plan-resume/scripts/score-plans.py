#!/usr/bin/env python3
"""score-plans.py — plan-resume v0.4 综合加权打分(2026-09-04)

算法(用户 2026-09-04 拍板):
  importance_score(plan) =
      0.5 * normalize(out_degree(plan), 0..max)
    + 0.3 * normalize(git_keyword_hits(plan), 0..max)
    + 0.2 * normalize(max(0, 5 - failure_count) / 5)

Usage: score-plans.py [--repo-root PATH] [--time-threshold SECONDS]
                       [--weights "0.5,0.3,0.2"] [--json] [--top N]
"""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


def extract_meta(plan_path: Path, repo_root: Path) -> dict:
    """从 task_plan.md 提取元数据(纯 Python 解析,避开 shell 复杂性)"""
    text = plan_path.read_text(encoding='utf-8', errors='replace')
    if not text:
        return {'task_id': plan_path.parent.name, 'missing': True}

    result = {
        'task_id': plan_path.parent.name,
        'path': str(plan_path),
        'goal': '',
        'current_phase': '',
        'next_step': '',
        'phase_status': '',
        'all_complete': 0,
        'depends_on': '',
        'block_id': '',
        'vc_count': 0,
        'p0_markers': 0,
        'failure_count': 0,
        'real_age_days': 999,
    }

    # 解析 frontmatter
    fm_match = re.match(r'^---\n(.*?)\n---', text, re.DOTALL)
    fm_block = fm_match.group(1) if fm_match else ''
    if fm_block:
        for line in fm_block.splitlines():
            if line.strip().startswith('block_id:'):
                result['block_id'] = line.split(':', 1)[1].strip().strip('"\'')
            if line.strip().startswith('depends_on:'):
                val = line.split(':', 1)[1].strip()
                # [task-a, task-b] 格式
                val = val.strip('[]"\'')
                parts = [p.strip().strip('"\'') for p in val.split(',') if p.strip()]
                result['depends_on'] = '|'.join(parts)

    # Goal
    goal_m = re.search(r'^## Goal\s*\n+(.*?)(?=^##|\Z)', text, re.MULTILINE | re.DOTALL)
    if goal_m:
        first_line = goal_m.group(1).strip().splitlines()[0] if goal_m.group(1).strip() else ''
        # 去掉开头的 <!-- 或其他注释标记
        first_line = re.sub(r'^\s*<!--+\s*', '', first_line)
        first_line = re.sub(r'\s*--+>\s*$', '', first_line)
        result['goal'] = first_line[:200]

    # Phase Status
    statuses = re.findall(r'^\- \*\*Status:\*\*\s+(\w+)', text, re.MULTILINE)
    result['phase_status'] = '|'.join(statuses)
    if statuses and not any(s in ('pending', 'in_progress') for s in statuses):
        result['all_complete'] = 1

    # VC count
    result['vc_count'] = len(re.findall(r'^\|\s*VC-?\d+', text, re.MULTILINE))
    if result['vc_count'] == 0:
        result['vc_count'] = len(re.findall(r'\|.*VC-', text))

    # P0/P1 markers
    result['p0_markers'] = len(re.findall(r'\bP[01]\b', text))

    # Failure count from progress.md
    progress_path = plan_path.parent / 'progress.md'
    if progress_path.exists():
        prog_text = progress_path.read_text(encoding='utf-8', errors='replace')
        err_log_match = re.search(r'^## Error Log\s*\n+(.*?)(?=^##|\Z)',
                                  prog_text, re.MULTILINE | re.DOTALL)
        if err_log_match:
            err_lines = [l for l in err_log_match.group(1).splitlines() if l.strip().startswith('|')]
            result['failure_count'] = len(err_lines)
        if result['failure_count'] == 0:
            result['failure_count'] = len(re.findall(
                r'circuit-break|CIRCUIT-BREAK|\[FAIL\]', prog_text))

    # Real age (from git log, fallback to mtime)
    import time as _time
    try:
        r = subprocess.run(
            ['git', '-C', str(repo_root), 'log', '-1', '--format=%ct',
             '--', str(plan_path.relative_to(repo_root))],
            capture_output=True, text=True, timeout=5
        )
        if r.stdout.strip():
            result['real_age_days'] = (int(_time.time()) - int(r.stdout.strip())) // 86400
        else:
            # Untracked file (git log returns nothing) → fall back to mtime
            mtime = plan_path.stat().st_mtime
            result['real_age_days'] = (int(_time.time()) - int(mtime)) // 86400
    except Exception:
        try:
            mtime = plan_path.stat().st_mtime
            result['real_age_days'] = (int(_time.time()) - int(mtime)) // 86400
        except Exception:
            pass

    return result


def scan_plans(repo_root: Path) -> list[Path]:
    """扫描所有 plan 路径"""
    plans = []
    # 1. plans/*/task_plan.md
    plans_dir = repo_root / 'plans'
    if plans_dir.exists():
        for d in plans_dir.iterdir():
            if d.is_dir() and d.name != 'archive':
                tp = d / 'task_plan.md'
                if tp.exists():
                    plans.append(tp)
    # 2. .zcode/plans/plan-sess_*.md
    zcode_plans = repo_root / '.zcode' / 'plans'
    if zcode_plans.exists():
        for f in zcode_plans.glob('plan-sess_*.md'):
            plans.append(f)
    return plans


def main():
    p = argparse.ArgumentParser(description='plan-resume 综合加权打分')
    p.add_argument('--repo-root', default='.', help='Git 仓库根')
    p.add_argument('--time-threshold', type=int, default=604800,
                   help='时间衰减阈值(秒),默认 7d')
    p.add_argument('--weights', default='0.5,0.3,0.2', help='权重 out,git,fail')
    p.add_argument('--json', action='store_true', help='JSON Lines 输出')
    p.add_argument('--top', type=int, default=999, help='只输出前 N')
    args = p.parse_args()

    repo_root = Path(args.repo_root).resolve()
    weights = [float(x) for x in args.weights.split(',')]
    if len(weights) != 3:
        print('[score-plans] 权重必须是 3 个数字', file=sys.stderr)
        sys.exit(1)
    w_out, w_git, w_fail = weights

    # 1. 扫描所有 plan
    plan_paths = scan_plans(repo_root)
    if not plan_paths:
        print('[score-plans] 未找到 plan', file=sys.stderr)
        return

    # 2. 提取元数据
    metas = [extract_meta(p, repo_root) for p in plan_paths]
    metas = [m for m in metas if not m.get('missing')]

    # 3. 计算 out_degree: 统计每个 block_id 被其他 plan depends_on 引用的次数
    block_ids = {}
    for m in metas:
        effective_bid = m['block_id'] or m['task_id']
        block_ids[effective_bid] = m
    for m in metas:
        m['out_degree'] = 0
    for m in metas:
        deps = m['depends_on'].split('|') if m['depends_on'] else []
        for dep in deps:
            dep = dep.strip()
            if dep and dep in block_ids:
                block_ids[dep]['out_degree'] += 1

    # 4. git_keyword_hits: 7d 内 git log 命中关键词数
    import time
    since_ts = int(time.time()) - 604800
    try:
        r = subprocess.run(
            ['git', '-C', str(repo_root), 'log', f'--since=@{since_ts}',
             '--oneline', '-i'],
            capture_output=True, text=True, timeout=30
        )
        git_log = r.stdout if r.returncode == 0 else ''
    except Exception:
        git_log = ''

    for m in metas:
        goal = m['goal']
        # 提取前 5 个长度≥3 的词
        words = [w for w in re.findall(r'\S+', goal) if len(w) >= 3][:5]
        if not words or not git_log:
            m['git_hits'] = 0
            continue
        pattern = '|'.join(re.escape(w) for w in words)
        try:
            m['git_hits'] = len(re.findall(pattern, git_log, re.IGNORECASE))
        except re.error:
            m['git_hits'] = 0

    # 5. 过滤 + 评分
    threshold_days = args.time_threshold // 86400
    candidates = []
    for m in metas:
        if m['all_complete'] == 1:
            continue
        if m['failure_count'] >= 3:
            continue
        if m['real_age_days'] > threshold_days:
            continue
        candidates.append(m)

    if not candidates:
        if args.json:
            print(json.dumps({'scored': 0, 'plans': []}, ensure_ascii=False))
        else:
            print(f'[score-plans] 无候选 plan 满足过滤条件(阈值 {threshold_days}d)', file=sys.stderr)
        return

    # 归一化
    max_out = max(m['out_degree'] for m in candidates) or 1
    max_git = max(m['git_hits'] for m in candidates) or 1

    for m in candidates:
        n_out = m['out_degree'] / max_out
        n_git = m['git_hits'] / max_git
        n_fail = max(0, 5 - m['failure_count']) / 5
        m['score'] = w_out * n_out + w_git * n_git + w_fail * n_fail

    candidates.sort(key=lambda m: -m['score'])
    top = candidates[:args.top]

    # 输出
    if args.json:
        for m in top:
            print(json.dumps({
                'task_id': m['task_id'],
                'score': round(m['score'], 4),
                'out_degree': m['out_degree'],
                'git_hits': m['git_hits'],
                'failure_count': m['failure_count'],
                'real_age_days': m['real_age_days'],
                'goal': m['goal'][:100],
                'depends_on': m['depends_on'],
                'block_id': m['block_id'],
            }, ensure_ascii=False))
    else:
        print(f'[score-plans] 评分完成: {len(candidates)} 个候选 '
              f'(权重: out={w_out} git={w_git} fail={w_fail})', file=sys.stderr)
        print(f'[score-plans] max: out_degree={max_out} git_hits={max_git}', file=sys.stderr)
        print(f'[score-plans] 时间阈值: {threshold_days}d', file=sys.stderr)
        print(file=sys.stderr)
        print(f'{"score":>8}  {"task_id":<50}  {"out":>4} {"git":>4} {"fail":>4} {"age":>4}')
        for m in top:
            print(f'{m["score"]:.4f}  {m["task_id"]:<50}  '
                  f'{m["out_degree"]:>4} {m["git_hits"]:>4} {m["failure_count"]:>4} '
                  f'{m["real_age_days"]:>4}')


if __name__ == '__main__':
    main()
