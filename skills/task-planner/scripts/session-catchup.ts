#!/usr/bin/env bun
/**
 * session-catchup.ts — 跨会话规划文件更新检测
 *
 * 用法: bun session-catchup.ts [project-path]
 *
 * 找到最新规划文件更新，收集所有未同步消息并输出摘要。
 */

import * as fs from "fs";
import * as os from "os";
import * as path from "path";

const PLANNING_FILES = new Set(["task_plan.md", "progress.md", "findings.md"]);
const SKIP_PREFIXES = ["<local-command", "<command-", "<task-notification"];

// ─── Helpers ──────────────────────────────────────────────────────────────────

function detectIDE(): string {
  if (process.env.OPENCODE_DATA_DIR) return "opencode";
  const claudeDir = path.join(os.homedir(), ".claude");
  if (fs.existsSync(claudeDir)) return "claude-code";
  const opencodeDir = path.join(os.homedir(), ".local", "share", "opencode");
  if (fs.existsSync(opencodeDir)) return "opencode";
  return "unknown";
}

function projectDirClaude(projectPath: string): string | null {
  const sanitized = projectPath.replace(/\//g, "-").replace(/_/g, "-").replace(/^-/, "");
  const prefixed = sanitized.startsWith("-") ? sanitized : `-${sanitized}`;
  return path.join(os.homedir(), ".claude", "projects", prefixed);
}

function getSessionFiles(projectDir: string): Array<{ file: string; mtime: number }> {
  if (!fs.existsSync(projectDir)) return [];
  const entries = fs.readdirSync(projectDir);
  const result: Array<{ file: string; mtime: number }> = [];
  for (const f of entries) {
    if (f.endsWith(".jsonl") && !f.startsWith("agent-")) {
      const fp = path.join(projectDir, f);
      result.push({ file: fp, mtime: fs.statSync(fp).mtimeMs });
    }
  }
  result.sort((a, b) => b.mtime - a.mtime);
  return result;
}

function scanForPlanningUpdate(sessionFile: string): { line: number; file: string | null } {
  let lastLine = -1;
  let lastFile: string | null = null;
  try {
    const content = fs.readFileSync(sessionFile, "utf-8");
    const lines = content.split("\n");
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (!line.includes('"Write"') && !line.includes('"Edit"')) continue;
      try {
        const data = JSON.parse(line) as Record<string, unknown>;
        if (data.type !== "assistant") continue;
        const msgContent = (data.message as Record<string, unknown>)?.content;
        if (!Array.isArray(msgContent)) continue;
        for (const item of msgContent as Array<Record<string, unknown>>) {
          if (item.type !== "tool_use") continue;
          const toolName = (item.name as string) || "";
          if (toolName !== "Write" && toolName !== "Edit") continue;
          const filePath = ((item.input as Record<string, unknown>)?.file_path as string) || "";
          for (const pf of PLANNING_FILES) {
            if (filePath.endsWith(pf)) {
              lastLine = i;
              lastFile = pf;
            }
          }
        }
      } catch {
        // skip malformed JSON
      }
    }
  } catch {
    // skip unreadable files
  }
  return { line: lastLine, file: lastFile };
}

function extractMessages(sessionFile: string, afterLine = -1): Array<Record<string, unknown>> {
  const result: Array<Record<string, unknown>> = [];
  try {
    const content = fs.readFileSync(sessionFile, "utf-8");
    const lines = content.split("\n");
    for (let i = 0; i < lines.length; i++) {
      if (afterLine >= 0 && i <= afterLine) continue;
      let msg: Record<string, unknown>;
      try {
        msg = JSON.parse(lines[i]) as Record<string, unknown>;
      } catch {
        continue;
      }
      const msgType = msg.type as string;
      const isMeta = Boolean(msg.isMeta);

      if (msgType === "user" && !isMeta) {
        const rawContent = (msg.message as Record<string, unknown>)?.content;
        let content = "";
        if (typeof rawContent === "string") {
          content = rawContent;
        } else if (Array.isArray(rawContent)) {
          for (const item of rawContent as Array<Record<string, unknown>>) {
            if (item.type === "text") {
              content = (item.text as string) || "";
              break;
            }
          }
        }
        if (
          typeof content !== "string" ||
          !content ||
          content.length <= 20 ||
          SKIP_PREFIXES.some((p) => content.startsWith(p))
        ) {
          continue;
        }
        const sessionId = path.basename(sessionFile, ".jsonl").slice(0, 8);
        result.push({ role: "user", content: content.slice(0, 300), session: sessionId });
      } else if (msgType === "assistant") {
        let textContent = "";
        const toolUses: string[] = [];
        const rawContent = (msg.message as Record<string, unknown>)?.content;
        if (typeof rawContent === "string") {
          textContent = rawContent;
        } else if (Array.isArray(rawContent)) {
          for (const item of rawContent as Array<Record<string, unknown>>) {
            if (item.type === "text") {
              textContent = (item.text as string) || "";
            } else if (item.type === "tool_use") {
              const name = (item.name as string) || "";
              const inp = (item.input as Record<string, unknown>) || {};
              if (name === "Edit") {
                toolUses.push(`Edit: ${inp.file_path || "unknown"}`);
              } else if (name === "Write") {
                toolUses.push(`Write: ${inp.file_path || "unknown"}`);
              } else if (name === "Bash") {
                toolUses.push(`Bash: ${(inp.command as string || "").slice(0, 80)}`);
              } else {
                toolUses.push(name);
              }
            }
          }
        }
        if (textContent || toolUses.length > 0) {
          const sessionId = path.basename(sessionFile, ".jsonl").slice(0, 8);
          result.push({
            role: "assistant",
            content: textContent.slice(0, 600),
            tools: toolUses,
            session: sessionId,
          });
        }
      }
    }
  } catch {
    // skip unreadable files
  }
  return result;
}

// ─── Main ─────────────────────────────────────────────────────────────────────

function main(): void {
  const args = Bun.argv.slice(2);
  const projectPath = args[0] || process.cwd();
  const ide = detectIDE();

  if (ide === "opencode") {
    console.error("");
    console.error("[task-planner] OpenCode session catchup is not yet fully supported");
    console.error("OpenCode uses a different session storage format (.json) than Claude Code (.jsonl)");
    console.error("Session catchup requires parsing OpenCode's message storage structure.");
    console.error("");
    console.error("Workaround: Manually read task_plan.md, progress.md, and findings.md to catch up.");
    return;
  }

  const pdir = projectDirClaude(projectPath);
  if (!pdir || !fs.existsSync(pdir)) return;

  const sessions = getSessionFiles(pdir);
  if (sessions.length < 2) return;

  // Skip current session (index 0 = most recent)
  const previousSessions = sessions.slice(1);
  let updateSession: (typeof sessions)[0] | undefined;
  let updateLine = -1;
  let updateFile: string | null = null;
  let updateIdx = -1;

  for (let idx = 0; idx < previousSessions.length; idx++) {
    const sess = previousSessions[idx];
    const { line, file } = scanForPlanningUpdate(sess.file);
    if (line >= 0) {
      updateSession = sess;
      updateLine = line;
      updateFile = file;
      updateIdx = idx;
      break;
    }
  }

  if (!updateSession) return;

  const allMessages: Array<Record<string, unknown>> = [];

  const msgsFromUpdate = extractMessages(updateSession.file, updateLine);
  allMessages.push(...msgsFromUpdate);

  const intermediate = previousSessions.slice(0, updateIdx);
  for (let i = intermediate.length - 1; i >= 0; i--) {
    allMessages.push(...extractMessages(intermediate[i].file, -1));
  }

  if (allMessages.length === 0) return;

  console.error("");
  console.error(`[task-planner] SESSION CATCHUP DETECTED (IDE: ${ide})`);
  const sessionName = path.basename(updateSession.file, ".jsonl").slice(0, 8);
  console.error(`Last planning update: ${updateFile} in session ${sessionName}...`);

  const sessionsCovered = updateIdx + 1;
  if (sessionsCovered > 1) {
    console.error(`Scanning ${sessionsCovered} sessions for unsynced context`);
  }
  console.error(`Unsynced messages: ${allMessages.length}`);
  console.error("");
  console.error("--- UNSYNCED CONTEXT ---");

  const MAX_MESSAGES = 100;
  const toShow = allMessages.slice(-MAX_MESSAGES);
  let currentSession: string | null = null;

  for (const msg of toShow) {
    const sess = msg.session as string;
    if (sess !== currentSession) {
      currentSession = sess;
      console.error("");
      console.error(`[Session: ${currentSession}...]`);
    }
    if (msg.role === "user") {
      console.error(`USER: ${(msg.content as string).slice(0, 300)}`);
    } else {
      if (msg.content) {
        console.error(`CLAUDE: ${(msg.content as string).slice(0, 600)}`);
      }
      const tools = (msg.tools as string[]) || [];
      if (tools.length > 0) {
        console.error(` Tools: ${tools.slice(0, 4).join(", ")}`);
      }
    }
  }

  console.error("");
  console.error("--- RECOMMENDED ---");
  console.error("1. Run: git diff --stat");
  console.error("2. Read: task_plan.md, progress.md, findings.md");
  console.error("3. Update planning files based on above context");
  console.error("4. Continue with task");
}

main();
