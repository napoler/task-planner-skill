#!/usr/bin/env python3
"""
Session Catchup — 跨会话规划文件更新检测
找到最新规划文件更新，收集所有未同步消息并输出摘要。
用法: session-catchup.py [project-path]
"""

import json
import os
import sys

PLANNING_FILES = {"task_plan.md", "progress.md", "findings.md"}
SKIP_PREFIXES = ("<local-command", "<command-", "<task-notification")


def detect_ide() -> str:
    if os.environ.get("OPENCODE_DATA_DIR"):
        return "opencode"
    claude_dir = os.path.join(os.path.expanduser("~"), ".claude")
    if os.path.exists(claude_dir):
        return "claude-code"
    opencode_dir = os.path.join(os.path.expanduser("~"), ".local", "share", "opencode")
    if os.path.exists(opencode_dir):
        return "opencode"
    return "unknown"


def project_dir_claude(project_path: str) -> str | None:
    sanitized = project_path.replace("/", "-").replace("_", "-")
    if not sanitized.startswith("-"):
        sanitized = "-" + sanitized
    return os.path.join(os.path.expanduser("~"), ".claude", "projects", sanitized)


def get_session_files(project_dir: str):
    if not os.path.exists(project_dir):
        return []
    entries = os.listdir(project_dir)
    result = []
    for f in entries:
        if f.endswith(".jsonl") and not f.startswith("agent-"):
            fp = os.path.join(project_dir, f)
            mtime = os.stat(fp).st_mtime
            result.append({"file": fp, "mtime": mtime})
    result.sort(key=lambda x: x["mtime"], reverse=True)
    return result


def scan_for_planning_update(session_file: str) -> tuple[int, str | None]:
    last_line = -1
    last_file = None
    try:
        with open(session_file, "r", encoding="utf-8") as fh:
            lines = fh.readlines()
        for i, line in enumerate(lines):
            if '"Write"' not in line and '"Edit"' not in line:
                continue
            try:
                data = json.loads(line)
            except Exception:
                continue
            if data.get("type") != "assistant":
                continue
            content = data.get("message", {}).get("content") or []
            if not isinstance(content, list):
                continue
            for item in content:
                if item.get("type") != "tool_use":
                    continue
                tool_name = item.get("name") or ""
                if tool_name not in ("Write", "Edit"):
                    continue
                file_path = (item.get("input") or {}).get("file_path") or ""
                for pf in PLANNING_FILES:
                    if file_path.endswith(pf):
                        last_line = i
                        last_file = pf
    except Exception:
        pass
    return last_line, last_file


def extract_messages(session_file: str, after_line: int = -1) -> list[dict]:
    result = []
    try:
        with open(session_file, "r", encoding="utf-8") as fh:
            lines = fh.readlines()
        for i, line in enumerate(lines):
            if after_line >= 0 and i <= after_line:
                continue
            try:
                msg = json.loads(line)
            except Exception:
                continue
            msg_type = msg.get("type")
            is_meta = msg.get("isMeta") or False

            if msg_type == "user" and not is_meta:
                content = msg.get("message", {}).get("content") or ""
                if isinstance(content, list):
                    for item in content:
                        if item.get("type") == "text":
                            content = item.get("text") or ""
                            break
                if (
                    not isinstance(content, str)
                    or not content
                    or len(content) <= 20
                ):
                    continue
                if content.startswith(SKIP_PREFIXES):
                    continue
                session_id = os.path.splitext(os.path.basename(session_file))[0][:8]
                result.append({
                    "role": "user",
                    "content": content[:300],
                    "session": session_id,
                })

            elif msg_type == "assistant":
                text_content = ""
                tool_uses = []
                msg_content = msg.get("message", {}).get("content") or ""
                if isinstance(msg_content, str):
                    text_content = msg_content
                elif isinstance(msg_content, list):
                    for item in msg_content:
                        if item.get("type") == "text":
                            text_content = item.get("text") or ""
                        elif item.get("type") == "tool_use":
                            name = item.get("name") or ""
                            inp = item.get("input") or {}
                            if name == "Edit":
                                tool_uses.append(f"Edit: {inp.get('file_path', 'unknown')}")
                            elif name == "Write":
                                tool_uses.append(f"Write: {inp.get('file_path', 'unknown')}")
                            elif name == "Bash":
                                cmd = (inp.get("command") or "")[:80]
                                tool_uses.append(f"Bash: {cmd}")
                            elif name == "AskUserQuestion":
                                tool_uses.append("AskUserQuestion")
                            else:
                                tool_uses.append(name)
                if text_content or tool_uses:
                    session_id = os.path.splitext(os.path.basename(session_file))[0][:8]
                    result.append({
                        "role": "assistant",
                        "content": text_content[:600] if text_content else "",
                        "tools": tool_uses,
                        "session": session_id,
                    })
    except Exception:
        pass
    return result


def main() -> None:
    args = sys.argv[1:]
    project_path = args[0] if args else os.getcwd()
    ide = detect_ide()

    if ide == "opencode":
        print("\n[task-planner] OpenCode session catchup is not yet fully supported")
        print("OpenCode uses a different session storage format (.json) than Claude Code (.jsonl)")
        print("Session catchup requires parsing OpenCode's message storage structure.")
        print("\nWorkaround: Manually read task_plan.md, progress.md, and findings.md to catch up.")
        return

    pdir = project_dir_claude(project_path)
    if not pdir or not os.path.exists(pdir):
        return

    sessions = get_session_files(pdir)
    if len(sessions) < 2:
        return

    # Skip current session (index 0 = most recent)
    previous_sessions = sessions[1:]
    update_session = None
    update_line = -1
    update_file = None
    update_idx = -1

    for idx, sess in enumerate(previous_sessions):
        lnum, fname = scan_for_planning_update(sess["file"])
        if lnum >= 0:
            update_session = sess
            update_line = lnum
            update_file = fname
            update_idx = idx
            break

    if not update_session:
        return

    all_messages: list[dict] = []

    msgs_from_update = extract_messages(update_session["file"], update_line)
    all_messages.extend(msgs_from_update)

    intermediate = previous_sessions[:update_idx]
    for sess in reversed(intermediate):
        msgs = extract_messages(sess["file"], -1)
        all_messages.extend(msgs)

    if not all_messages:
        return

    print(f"\n[task-planner] SESSION CATCHUP DETECTED (IDE: {ide})")
    session_name = os.path.splitext(os.path.basename(update_session["file"]))[0][:8]
    print(f"Last planning update: {update_file} in session {session_name}...")

    sessions_covered = update_idx + 1
    if sessions_covered > 1:
        print(f"Scanning {sessions_covered} sessions for unsynced context")
    print(f"Unsynced messages: {len(all_messages)}")

    print("\n--- UNSYNCED CONTEXT ---")

    MAX_MESSAGES = 100
    to_show = all_messages[-MAX_MESSAGES:] if len(all_messages) > MAX_MESSAGES else all_messages
    current_session = None

    for msg in to_show:
        if msg["session"] != current_session:
            current_session = msg["session"]
            print(f"\n[Session: {current_session}...]")
        if msg["role"] == "user":
            print(f"USER: {msg['content'][:300]}")
        else:
            if msg.get("content"):
                print(f"CLAUDE: {msg['content'][:300]}")
            tools = msg.get("tools") or []
            if tools:
                shown = ", ".join(tools[:4])
                print(f" Tools: {shown}")

    print("\n--- RECOMMENDED ---")
    print("1. Run: git diff --stat")
    print("2. Read: task_plan.md, progress.md, findings.md")
    print("3. Update planning files based on above context")
    print("4. Continue with task")


if __name__ == "__main__":
    main()
