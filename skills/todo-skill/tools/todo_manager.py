#!/usr/bin/env python3
"""持久化任务管理器 — 基于 JSON 文件存储，与 Claude Code 原生 Task 工具兼容。

用法:
    python3 todo_manager.py create --title "任务名" --desc "描述" [--priority High|Medium|Low]
    python3 todo_manager.py list [--status pending|in_progress|completed]
    python3 todo_manager.py update --index 1 --status completed
    python3 todo_manager.py update --index 1 --desc "新描述"
    python3 todo_manager.py clear
    python3 todo_manager.py plan --goal "大目标描述" [--max_steps 10]
    python3 todo_manager.py status
    python3 todo_manager.py export  # 输出 JSON 供 session-kv 存储
"""

import argparse
import json
import os
import sys
from datetime import datetime, timezone

STORE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "store.json")
DEFAULT_STORE = {"tasks": [], "created_at": None, "updated_at": None}


def _now_iso():
    return datetime.now(timezone.utc).isoformat()


def _load():
    if os.path.exists(STORE_FILE):
        with open(STORE_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            if "tasks" not in data:
                data["tasks"] = []
            return data
    return dict(DEFAULT_STORE)


def _save(data):
    data["updated_at"] = _now_iso()
    if data.get("created_at") is None:
        data["created_at"] = data["updated_at"]
    with open(STORE_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


# ── 命令实现 ──────────────────────────────────────────────

def cmd_create(args):
    data = _load()
    task = {
        "id": len(data["tasks"]) + 1,
        "title": args.title,
        "description": args.desc or "",
        "priority": args.priority,
        "status": "pending",
        "created_at": _now_iso(),
        "updated_at": _now_iso(),
    }
    data["tasks"].append(task)
    _save(data)
    print(json.dumps({"action": "created", "task": task}, ensure_ascii=False))


def cmd_list(args):
    data = _load()
    tasks = data["tasks"]
    if args.status:
        tasks = [t for t in tasks if t["status"] == args.status]
    if not tasks:
        print(json.dumps({"tasks": [], "count": 0}, ensure_ascii=False))
        return
    print(json.dumps({"tasks": tasks, "count": len(tasks)}, ensure_ascii=False))


def cmd_update(args):
    data = _load()
    idx = args.index - 1
    if idx < 0 or idx >= len(data["tasks"]):
        print(json.dumps({"error": f"无效索引 {args.index}，共 {len(data['tasks'])} 个任务"}, ensure_ascii=False), file=sys.stderr)
        sys.exit(1)
    task = data["tasks"][idx]
    if args.status:
        task["status"] = args.status
    if args.desc is not None:
        task["description"] = args.desc
    task["updated_at"] = _now_iso()
    _save(data)
    print(json.dumps({"action": "updated", "task": task}, ensure_ascii=False))


def cmd_clear(args):
    data = _load()
    count = len(data["tasks"])
    data["tasks"] = []
    _save(data)
    print(json.dumps({"action": "cleared", "removed": count}, ensure_ascii=False))


def cmd_plan(args):
    """生成任务计划骨架（实际拆解由 SKILL.md 中的 Agent 完成）。

    返回空计划结构，SKILL.md 指导主进程通过 Agent 填充 steps 数组。
    """
    data = _load()
    plan = {
        "goal": args.goal,
        "max_steps": args.max_steps,
        "steps": [],
        "strategy": "agent_decompose",
        "created_at": _now_iso(),
    }
    # 清除旧任务，准备新计划
    data["tasks"] = []
    _save(data)
    print(json.dumps(plan, ensure_ascii=False))


def cmd_status(args):
    data = _load()
    total = len(data["tasks"])
    by_status = {}
    for t in data["tasks"]:
        s = t["status"]
        by_status[s] = by_status.get(s, 0) + 1
    summary = {
        "total": total,
        "by_status": by_status,
        "created_at": data.get("created_at"),
        "updated_at": data.get("updated_at"),
    }
    print(json.dumps(summary, ensure_ascii=False))


def cmd_export(args):
    """导出完整 store 供 session-kv 存储。"""
    data = _load()
    print(json.dumps(data, ensure_ascii=False))


# ── CLI 入口 ──────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="持久化任务管理器")
    sub = parser.add_subparsers(dest="command", required=True)

    # create
    p_create = sub.add_parser("create", help="创建任务")
    p_create.add_argument("--title", required=True)
    p_create.add_argument("--desc", default="")
    p_create.add_argument("--priority", default="Medium", choices=["High", "Medium", "Low"])

    # list
    p_list = sub.add_parser("list", help="列出任务")
    p_list.add_argument("--status", choices=["pending", "in_progress", "completed"])

    # update
    p_update = sub.add_parser("update", help="更新任务")
    p_update.add_argument("--index", type=int, required=True)
    p_update.add_argument("--status", choices=["pending", "in_progress", "completed"])
    p_update.add_argument("--desc")

    # clear
    sub.add_parser("clear", help="清空所有任务")

    # plan
    p_plan = sub.add_parser("plan", help="创建任务计划骨架")
    p_plan.add_argument("--goal", required=True)
    p_plan.add_argument("--max_steps", type=int, default=10)

    # status
    sub.add_parser("status", help="查看任务统计")

    # export
    sub.add_parser("export", help="导出完整 store")

    args = parser.parse_args()
    cmds = {
        "create": cmd_create,
        "list": cmd_list,
        "update": cmd_update,
        "clear": cmd_clear,
        "plan": cmd_plan,
        "status": cmd_status,
        "export": cmd_export,
    }
    cmds[args.command](args)


if __name__ == "__main__":
    main()
