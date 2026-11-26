#!/usr/bin/env python3
"""todoctl.py — 跨任务共用未解决待办清单（项目根 todo.json）的唯一写入口。

What（判定逻辑 + 输入输出契约）:
  用法: python3 todoctl.py <subcommand> [--root <project-root>] [options]
  权威源: <project-root>/todo.json（JSON，非 MD）；所有写入必须经本脚本，禁手改。
  子命令: init / add / list / get / resolve / reopen / set / stats / check / next / review / retire
  输出: 管理命令=JSON 到 stdout；check=单行 `TODOCTL CHECK <name>: PASS|FAIL <reason>`；错误到 stderr。
  退出码: 0=成功 / 1=业务失败（未找到、校验失败、幂等冲突等） / 2=输入异常（缺参、路径错误）。

Why:
  用户反馈任务半途搁置后无法统计「哪些问题已解决/未解决」；现有 plans/INDEX.md 是
  MD 派生视图、todo-sync 只管任务内 Todo，均非跨任务 JSON 权威源。本脚本复刻 planctl.py
  的安全写入惯例（校验→备份→原子替换→回读校验），让不同任务/会话可靠地追加未结问题。
  机制通用：source.type 与 tags 为开放标签，不写死任何任务类型或内容域（Rule 117.4）。

  [2026-11-26 task-shared-todo-20261126] 新增；配套 Rule 117 + examples/shared-todo。
  [2026-11-26 task-todo-consumption-20261126] 新增 next/review/retire 消费闭环子命令。
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

STATE_NAME = "todo.json"
BACKUP_SUFFIX = ".bak"
SCHEMA_VERSION = 1
STATUSES = ("open", "in_progress", "done", "cancelled")
PRIORITIES = ("low", "normal", "high", "urgent")
PRIORITY_RANK = {"urgent": 3, "high": 2, "normal": 1, "low": 0}
TERMINAL = ("done", "cancelled")
SOURCE_KEYS = ("type", "plan_id", "ref", "session_id")
ITEM_KEYS = (
    "id", "status", "priority", "title", "detail", "source", "tags",
    "created_at", "updated_at", "resolved_at", "resolution",
)
ID_RE = re.compile(r"^TODO-(\d{4,})$")
TS_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
ARCHIVE_CANDIDATE_RE = re.compile(r"SKIP\s+(\S+)\s+\(candidate/none\)")
ARCHIVE_SKIP_RE = re.compile(r"SKIP\s+(\S+)\s+\(([^)]+)\)")


class TodoCtlError(Exception):
    """携带退出码的领域错误；调用方据此映射 rc。"""

    def __init__(self, message, rc=1):
        super().__init__(message)
        self.rc = rc


def now_ts():
    """ISO8601 UTC 秒级时间戳（与示例实物格式一致）。"""
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def resolve_root(explicit):
    """解析项目根：显式 --root 优先，否则 git toplevel，最后退回 cwd。"""
    if explicit:
        path = Path(explicit).expanduser()
        if not path.is_dir():
            raise TodoCtlError("--root 不是目录: %s" % explicit, 2)
        return path.resolve()
    try:
        proc = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, universal_newlines=True,
        )
        if proc.returncode == 0 and proc.stdout.strip():
            return Path(proc.stdout.strip()).resolve()
    except OSError:
        pass
    return Path.cwd().resolve()


def state_path(root):
    return root / STATE_NAME


def empty_state():
    """建空骨架；不预填任何问题条目（禁止脑补历史遗留）。"""
    return {"schema_version": SCHEMA_VERSION, "updated_at": now_ts(), "items": []}


def parse_ts(value, label, allow_none=False):
    if value is None and allow_none:
        return
    if not isinstance(value, str) or not TS_RE.match(value):
        raise TodoCtlError("%s 必须是 ISO8601Z 时间戳: %r" % (label, value))


def validate_state(doc):
    """校验权威源结构与语义；任何不合法抛出 rc=1 的领域错误。"""
    if not isinstance(doc, dict):
        raise TodoCtlError("顶层必须是对象")
    if doc.get("schema_version") != SCHEMA_VERSION:
        raise TodoCtlError("schema_version 必须为 %d" % SCHEMA_VERSION)
    parse_ts(doc.get("updated_at"), "updated_at")
    items = doc.get("items")
    if not isinstance(items, list):
        raise TodoCtlError("items 必须是数组")
    seen = set()
    for i, item in enumerate(items):
        label = "items[%d]" % i
        if not isinstance(item, dict):
            raise TodoCtlError("%s 必须是对象" % label)
        missing = [k for k in ITEM_KEYS if k not in item]
        if missing:
            raise TodoCtlError("%s 缺字段: %s" % (label, ",".join(missing)))
        if not ID_RE.match(str(item["id"])):
            raise TodoCtlError("%s.id 格式非法: %r" % (label, item["id"]))
        if item["id"] in seen:
            raise TodoCtlError("id 重复: %s" % item["id"])
        seen.add(item["id"])
        if item["status"] not in STATUSES:
            raise TodoCtlError("%s.status 非法: %r" % (label, item["status"]))
        if item["priority"] not in PRIORITIES:
            raise TodoCtlError("%s.priority 非法: %r" % (label, item["priority"]))
        if not isinstance(item["title"], str) or not item["title"].strip():
            raise TodoCtlError("%s.title 不能为空" % label)
        if not isinstance(item["detail"], str):
            raise TodoCtlError("%s.detail 必须是字符串" % label)
        src = item["source"]
        if not isinstance(src, dict) or any(k not in SOURCE_KEYS for k in src):
            raise TodoCtlError("%s.source 只允许 %s 中的键" % (label, ",".join(SOURCE_KEYS)))
        if not isinstance(item["tags"], list) or any(not isinstance(t, str) for t in item["tags"]):
            raise TodoCtlError("%s.tags 必须是字符串数组" % label)
        parse_ts(item["created_at"], "%s.created_at" % label)
        parse_ts(item["updated_at"], "%s.updated_at" % label)
        if item["status"] in TERMINAL:
            parse_ts(item["resolved_at"], "%s.resolved_at" % label)
        elif item["resolved_at"] is not None:
            raise TodoCtlError("%s 未结项的 resolved_at 必须为 null" % label)
    return doc


def read_state(root, allow_missing=False):
    path = state_path(root)
    if not path.exists():
        if allow_missing:
            return None, path
        raise TodoCtlError("todo.json 不存在: %s（先跑 init）" % path, 2)
    try:
        with path.open("r", encoding="utf-8") as f:
            doc = json.load(f)
    except (OSError, ValueError) as exc:
        raise TodoCtlError("todo.json 读取/解析失败: %s" % exc)
    validate_state(doc)
    return doc, path


def commit_state(path, doc):
    """校验→备份→原子替换→回读校验；失败保留旧档（对齐 planctl.py 写入惯例）。"""
    validate_state(doc)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(prefix=".todoctl-", suffix=".tmp", dir=str(path.parent))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(doc, f, ensure_ascii=False, indent=2)
            f.write("\n")
            f.flush()
            os.fsync(f.fileno())
        if path.exists():
            shutil.copy2(str(path), str(path) + BACKUP_SUFFIX)
        os.replace(tmp_name, str(path))
    except OSError as exc:
        try:
            os.unlink(tmp_name)
        except OSError:
            pass
        raise TodoCtlError("原子写入失败: %s" % exc, 2)
    read_state(path.parent)  # 回读再校验


def next_id(doc):
    nums = [int(ID_RE.match(str(i["id"])).group(1)) for i in doc["items"]]
    return "TODO-%04d" % ((max(nums) if nums else 0) + 1)


def find_item(doc, item_id):
    for item in doc["items"]:
        if item["id"] == item_id:
            return item
    raise TodoCtlError("未找到待办: %s" % item_id)


def parse_tags(raw):
    if not raw:
        return []
    return [t.strip() for t in raw.split(",") if t.strip()]


def _parse_ts_dt(value, label):
    """解析 ISO8601Z 时间戳为 UTC datetime；校验失败抛 TodoCtlError。"""
    parse_ts(value, label)
    return datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)


def _age_days(created_at, now_dt):
    """created_at 到 now_dt 的天数差，向下取整。"""
    created = _parse_ts_dt(created_at, "created_at")
    delta = now_dt - created
    days = int(delta.total_seconds() // 86400)
    return max(days, 0)


def _is_actionable(item):
    return item.get("status") in ("open", "in_progress")


def _next_sort_key(item):
    # priority 降序 -> rank 取负；created_at 升序；id 升序
    rank = PRIORITY_RANK.get(item.get("priority"), -1)
    return (-rank, item.get("created_at", ""), item.get("id", ""))


def _skill_root():
    """skill 根 = todoctl.py 所在位置向上两级（scripts/<file> -> skill root）。"""
    return Path(__file__).resolve().parents[1]


def _run_cmd(cmd, cwd=None):
    """运行命令并返回 (rc, stdout, stderr)。不抛异常，交给调用方判定。"""
    proc = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
        cwd=str(cwd) if cwd else None,
    )
    return proc.returncode, proc.stdout or "", proc.stderr or ""


def _retire_candidates(doc, root):
    """终态条目的 source.plan_id 去重，且 plans/<plan_id>/task_plan.md 存在。"""
    plans_dir = root / "plans"
    seen = set()
    result = []
    for item in doc.get("items", []):
        if item.get("status") not in TERMINAL:
            continue
        source = item.get("source") or {}
        plan_id = source.get("plan_id")
        if not isinstance(plan_id, str) or not plan_id.strip():
            continue
        plan_id = plan_id.strip()
        if plan_id in seen:
            continue
        seen.add(plan_id)
        if (plans_dir / plan_id / "task_plan.md").exists():
            result.append(plan_id)
    return sorted(result)


def cmd_init(args):
    doc, path = read_state(args.root, allow_missing=True)
    if doc is not None:
        print(json.dumps({"status": "exists", "path": str(path), "count": len(doc["items"])}, ensure_ascii=False))
        return 0
    doc = empty_state()
    commit_state(path, doc)
    print(json.dumps({"status": "created", "path": str(path), "count": 0}, ensure_ascii=False))
    return 0


def cmd_add(args):
    doc, path = read_state(args.root)
    for item in doc["items"]:
        if item["title"] == args.title and item["status"] not in TERMINAL:
            print(json.dumps({"status": "dedup", "item": item}, ensure_ascii=False))
            return 0
    ts = now_ts()
    item = {
        "id": next_id(doc),
        "status": "open",
        "priority": args.priority,
        "title": args.title,
        "detail": args.detail or "",
        "source": {
            "type": args.source_type or "task",
            "plan_id": args.source_plan or "",
            "ref": args.ref or "",
            "session_id": args.session_id or "",
        },
        "tags": parse_tags(args.tags),
        "created_at": ts,
        "updated_at": ts,
        "resolved_at": None,
        "resolution": None,
    }
    doc["items"].append(item)
    doc["updated_at"] = ts
    commit_state(path, doc)
    print(json.dumps({"status": "created", "item": item}, ensure_ascii=False))
    return 0


def cmd_list(args):
    doc, _ = read_state(args.root)
    wanted = None if args.status == "all" else args.status
    items = [i for i in doc["items"] if wanted is None or i["status"] == wanted]
    if args.tag:
        items = [i for i in items if args.tag in i["tags"]]
    if args.json:
        print(json.dumps(items, ensure_ascii=False, indent=2))
    else:
        for i in items:
            print("%s  %-11s  %s" % (i["id"], i["status"], i["title"]))
    return 0


def cmd_get(args):
    doc, _ = read_state(args.root)
    item = find_item(doc, args.id)
    print(json.dumps(item, ensure_ascii=False, indent=2))
    return 0


def cmd_resolve(args):
    doc, path = read_state(args.root)
    item = find_item(doc, args.id)
    item["status"] = "done"
    item["resolved_at"] = now_ts()
    item["updated_at"] = item["resolved_at"]
    item["resolution"] = args.note or ""
    doc["updated_at"] = item["updated_at"]
    commit_state(path, doc)
    print(json.dumps({"status": "resolved", "item": item}, ensure_ascii=False))
    return 0


def cmd_reopen(args):
    doc, path = read_state(args.root)
    item = find_item(doc, args.id)
    item["status"] = "open"
    item["resolved_at"] = None
    item["resolution"] = None
    item["updated_at"] = now_ts()
    doc["updated_at"] = item["updated_at"]
    commit_state(path, doc)
    print(json.dumps({"status": "reopened", "item": item}, ensure_ascii=False))
    return 0


def cmd_set(args):
    doc, path = read_state(args.root)
    item = find_item(doc, args.id)
    if args.field not in ("title", "detail", "priority", "status", "tags"):
        raise TodoCtlError("set 支持的字段: title/detail/priority/status/tags", 2)
    value = args.value
    if args.field == "tags":
        value = parse_tags(value)
    item[args.field] = value
    if args.field == "status":
        item["resolved_at"] = now_ts() if value in TERMINAL else None
        item["updated_at"] = item["resolved_at"] or now_ts()
    else:
        item["updated_at"] = now_ts()
    doc["updated_at"] = item["updated_at"]
    commit_state(path, doc)  # 校验失败即回滚（不写盘）
    print(json.dumps({"status": "updated", "item": item}, ensure_ascii=False))
    return 0


def cmd_stats(args):
    doc, _ = read_state(args.root)
    counts = {s: 0 for s in STATUSES}
    for item in doc["items"]:
        counts[item["status"]] += 1
    if args.json:
        print(json.dumps(counts, ensure_ascii=False))
    else:
        print(" ".join("%s=%d" % (s, counts[s]) for s in STATUSES))
    return 0


def cmd_check(args):
    try:
        read_state(args.root)
    except TodoCtlError as exc:
        print("TODOCTL CHECK schema: FAIL %s" % exc)
        return 1
    print("TODOCTL CHECK schema: PASS")
    return 0


def cmd_next(args):
    """只读：选择下一条可执行待办（open/in_progress）。"""
    doc, _ = read_state(args.root)
    candidates = [i for i in doc.get("items", []) if _is_actionable(i)]
    candidates.sort(key=_next_sort_key)
    if not candidates:
        print(json.dumps({"status": "empty", "count": 0}, ensure_ascii=False))
        return 0
    item = candidates[0]
    reason = "priority=%s, oldest %s" % (item.get("priority"), item.get("status"))
    out = {"status": "selected", "count": len(candidates), "item": item, "reason": reason}
    print(json.dumps(out, ensure_ascii=False))
    return 0


def cmd_review(args):
    """只读：统计状态分布、过期未结项、可退场 plan_id 候选。"""
    doc, _ = read_state(args.root)
    days = args.older_than_days
    if days < 0:
        raise TodoCtlError("--older-than-days 必须 >= 0", 2)
    now_dt = datetime.now(timezone.utc)
    counts = {s: 0 for s in STATUSES}
    stale = []
    for item in doc.get("items", []):
        st = item.get("status")
        if st in counts:
            counts[st] += 1
        if st in TERMINAL:
            continue
        age = _age_days(item.get("created_at"), now_dt)
        if age >= days:
            stale.append({
                "id": item.get("id"),
                "title": item.get("title"),
                "status": st,
                "age_days": age,
            })
    stale.sort(key=lambda x: (-x["age_days"], x.get("id", "")))
    retire_candidates = _retire_candidates(doc, args.root)
    out = {
        "counts": counts,
        "stale": stale,
        "retire_candidates": retire_candidates,
        "index_hint": "bash scripts/sync-todos.sh --index %s/plans" % str(args.root),
    }
    print(json.dumps(out, ensure_ascii=False))
    return 0


def _archive_dry_run(archive_script, plans_dir):
    rc, stdout, stderr = _run_cmd(["bash", str(archive_script), "--batch", "--dry-run", "--root", str(plans_dir)])
    eligible = []
    for line in (stdout or "").splitlines():
        m = ARCHIVE_CANDIDATE_RE.search(line)
        if m:
            eligible.append(m.group(1))
    skipped = []
    for line in (stdout or "").splitlines():
        m = ARCHIVE_SKIP_RE.search(line)
        if not m:
            continue
        sid, reason = m.group(1), m.group(2)
        if reason == "candidate/none":
            continue
        skipped.append({"id": sid, "reason": reason})
    return rc, stdout, stderr, sorted(set(eligible)), skipped


def cmd_retire(args):
    """默认 dry-run 零写入；--execute 时通过 archive-plan.sh + sync-todos.sh 执行归档。"""
    doc, _ = read_state(args.root)
    candidates = _retire_candidates(doc, args.root)
    if args.id and args.id not in candidates:
        raise TodoCtlError("不是可退场候选: %s" % args.id, 1)

    skill = _skill_root()
    archive_script = skill / "scripts" / "archive-plan.sh"
    sync_script = skill / "scripts" / "sync-todos.sh"
    plans_dir = args.root / "plans"

    if not archive_script.exists():
        raise TodoCtlError("未找到 archive-plan.sh: %s" % archive_script, 2)
    if not plans_dir.exists():
        raise TodoCtlError("plans 目录不存在: %s" % plans_dir, 2)

    rc, stdout, stderr, eligible_all, skipped_all = _archive_dry_run(archive_script, plans_dir)
    eligible = [p for p in candidates if p in set(eligible_all)]
    if args.id:
        eligible = [p for p in eligible if p == args.id]
    eligible_set = set(eligible)

    # 将候选集中被守卫拦下的项加入 skipped（含 reason）
    skipped = []
    seen_skip = set()
    for s in skipped_all:
        if s["id"] in set(candidates) and s["id"] not in eligible_set:
            key = (s["id"], s["reason"])
            if key not in seen_skip:
                seen_skip.add(key)
                skipped.append(s)
    # 候选但 dry-run 未列出的项（例如 archive-plan.sh rc!=0 或未枚举到）给出保守 reason
    listed = set(s["id"] for s in skipped_all) | set(eligible_all)
    for cid in candidates:
        if args.id and cid != args.id:
            continue
        if cid in eligible_set:
            continue
        if cid not in listed:
            key = (cid, "not-enumerated-by-archive-dry-run")
            if key not in seen_skip:
                seen_skip.add(key)
                skipped.append({"id": cid, "reason": "not-enumerated-by-archive-dry-run"})

    if rc != 0 and not eligible_all and not skipped_all:
        raise TodoCtlError(
            "archive-plan.sh --dry-run 失败(rc=%d): %s" % (rc, (stderr or stdout).strip()[:500]),
            1,
        )

    if not args.execute:
        out = {"mode": "dry-run", "eligible": eligible, "skipped": skipped}
        print(json.dumps(out, ensure_ascii=False))
        return 0

    archived = []
    already = []
    failed = []
    for pid in eligible:
        arc_rc, arc_out, arc_err, _, _ = (None, "", "", None, None)
        arc_rc, arc_out, arc_err = _run_cmd(["bash", str(archive_script), pid, "--root", str(plans_dir)])
        combined = (arc_out or "") + "\n" + (arc_err or "")
        if "ALREADY_ARCHIVED" in combined:
            already.append(pid)
        elif "ARCHIVED" in combined and "REJECT" not in combined and "FAIL" not in combined and arc_rc == 0:
            archived.append(pid)
        elif arc_rc == 0 and "ARCHIVED" in combined:
            archived.append(pid)
        else:
            reason = "rc=%d" % arc_rc
            if "REJECT" in combined:
                reason = "REJECT"
            elif "FAIL" in combined:
                reason = "FAIL"
            detail = (arc_err or arc_out).strip().splitlines()
            tail = detail[-1] if detail else reason
            failed.append({"id": pid, "reason": reason, "detail": tail[:300]})

    index_refresh = "skipped"
    total_rc = 0
    if archived:
        if not sync_script.exists():
            index_refresh = "failed"
            failed.append({"id": "__index__", "reason": "sync-todos.sh-missing", "detail": str(sync_script)})
            total_rc = 1
        else:
            idx_rc, idx_out, idx_err = _run_cmd(["bash", str(sync_script), "--index", str(plans_dir)])
            if idx_rc == 0:
                index_refresh = "ok"
            else:
                index_refresh = "failed"
                failed.append({"id": "__index__", "reason": "rc=%d" % idx_rc, "detail": ((idx_err or idx_out).strip()[-300:])})
                total_rc = 1
    if failed:
        # 有归档失败或 index 失败
        has_real_failure = any(f.get("id") != "__index__" or index_refresh == "failed" for f in failed)
        if has_real_failure:
            total_rc = 1

    out = {
        "mode": "execute",
        "archived": archived,
        "already": already,
        "skipped": skipped,
        "failed": failed,
        "index_refresh": index_refresh,
    }
    print(json.dumps(out, ensure_ascii=False))
    return total_rc


def add_root_arg(parser, suppress=False):
    kwargs = {"help": "项目根目录（默认 git toplevel 或 cwd）"}
    if suppress:
        kwargs["default"] = argparse.SUPPRESS
    parser.add_argument("--root", **kwargs)


def build_parser():
    p = argparse.ArgumentParser(description="跨任务共用未解决待办清单的唯一写入口")
    add_root_arg(p)
    sub = p.add_subparsers(dest="cmd")

    sp = sub.add_parser("init", help="建空骨架（已存在不覆盖）")
    add_root_arg(sp, suppress=True); sp.set_defaults(func=cmd_init)

    sp = sub.add_parser("add", help="新增待办（title 相同且未结则幂等返回既有项）")
    add_root_arg(sp, suppress=True)
    sp.add_argument("--title", required=True)
    sp.add_argument("--detail")
    sp.add_argument("--source-type")
    sp.add_argument("--source-plan")
    sp.add_argument("--ref")
    sp.add_argument("--session-id")
    sp.add_argument("--priority", choices=PRIORITIES, default="normal")
    sp.add_argument("--tags", help="逗号分隔的开放标签")
    sp.set_defaults(func=cmd_add)

    sp = sub.add_parser("list", help="列出待办（默认未结项）")
    add_root_arg(sp, suppress=True)
    sp.add_argument("--status", default="open", help="open|in_progress|done|cancelled|all")
    sp.add_argument("--tag")
    sp.add_argument("--json", action="store_true")
    sp.set_defaults(func=cmd_list)

    sp = sub.add_parser("get", help="按 id 查看单条")
    add_root_arg(sp, suppress=True); sp.add_argument("id"); sp.set_defaults(func=cmd_get)

    sp = sub.add_parser("resolve", help="标记已解决（保留条目）")
    add_root_arg(sp, suppress=True); sp.add_argument("id"); sp.add_argument("--note")
    sp.set_defaults(func=cmd_resolve)

    sp = sub.add_parser("reopen", help="重新打开已结项")
    add_root_arg(sp, suppress=True); sp.add_argument("id"); sp.set_defaults(func=cmd_reopen)

    sp = sub.add_parser("set", help="修改标量字段")
    add_root_arg(sp, suppress=True)
    sp.add_argument("id"); sp.add_argument("--field", required=True); sp.add_argument("--value", required=True)
    sp.set_defaults(func=cmd_set)

    sp = sub.add_parser("stats", help="按 status 统计")
    add_root_arg(sp, suppress=True); sp.add_argument("--json", action="store_true")
    sp.set_defaults(func=cmd_stats)

    sp = sub.add_parser("check", help="机器门：校验权威源结构")
    add_root_arg(sp, suppress=True); sp.set_defaults(func=cmd_check)

    sp = sub.add_parser("next", help="只读：按优先级/创建时间选择下一条待办")
    add_root_arg(sp, suppress=True); sp.set_defaults(func=cmd_next)

    sp = sub.add_parser("review", help="只读：状态统计 + stale 未结项 + 退场候选")
    add_root_arg(sp, suppress=True)
    sp.add_argument("--older-than-days", type=int, default=7, help="stale 判定阈值（天，默认 7）")
    sp.set_defaults(func=cmd_review)

    sp = sub.add_parser("retire", help="退场归档：默认 dry-run；--execute 调用 archive-plan.sh")
    add_root_arg(sp, suppress=True)
    sp.add_argument("--id", help="仅退场指定 plan-id（须在候选集内）")
    sp.add_argument("--execute", action="store_true", help="执行归档（默认 dry-run 零写入）")
    sp.set_defaults(func=cmd_retire)
    return p


def main(argv=None):
    parser = build_parser()
    args = parser.parse_args(argv)
    if not getattr(args, "cmd", None):
        parser.print_help(sys.stderr)
        return 2
    try:
        args.root = resolve_root(getattr(args, "root", None))
        return args.func(args)
    except TodoCtlError as exc:
        print("todoctl: %s" % exc, file=sys.stderr)
        return exc.rc
    except OSError as exc:
        print("todoctl: IO 错误: %s" % exc, file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
