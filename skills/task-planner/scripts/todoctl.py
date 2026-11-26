#!/usr/bin/env python3
"""todoctl.py — 跨任务共用未解决待办清单（项目根 todo.json）的唯一写入口。

What（判定逻辑 + 输入输出契约）:
  用法: python3 todoctl.py <subcommand> [--root <project-root>] [options]
  权威源: <project-root>/todo.json（JSON，非 MD）；所有写入必须经本脚本，禁手改。
  子命令: init / add / list / get / resolve / reopen / set / stats / check
  输出: 管理命令=JSON 到 stdout；check=单行 `TODOCTL CHECK <name>: PASS|FAIL <reason>`；错误到 stderr。
  退出码: 0=成功 / 1=业务失败（未找到、校验失败、幂等冲突等） / 2=输入异常（缺参、路径错误）。

Why:
  用户反馈任务半途搁置后无法统计「哪些问题已解决/未解决」；现有 plans/INDEX.md 是
  MD 派生视图、todo-sync 只管任务内 Todo，均非跨任务 JSON 权威源。本脚本复刻 planctl.py
  的安全写入惯例（校验→备份→原子替换→回读校验），让不同任务/会话可靠地追加未结问题。
  机制通用：source.type 与 tags 为开放标签，不写死任何任务类型或内容域（Rule 117.4）。

  [2026-11-26 task-shared-todo-20261126] 新增；配套 Rule 117 + examples/shared-todo。
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
TERMINAL = ("done", "cancelled")
SOURCE_KEYS = ("type", "plan_id", "ref", "session_id")
ITEM_KEYS = (
    "id", "status", "priority", "title", "detail", "source", "tags",
    "created_at", "updated_at", "resolved_at", "resolution",
)
ID_RE = re.compile(r"^TODO-(\d{4,})$")
TS_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")


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
