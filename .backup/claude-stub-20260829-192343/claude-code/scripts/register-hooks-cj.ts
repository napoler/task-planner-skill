#!/usr/bin/env node
/**
 * register-hooks-cj.ts — Patch ~/.claude/settings.local.json to add task-planner hooks.
 *
 * Reads current settings.local.json (or creates empty object), ensures `hooks` block
 * has the 5 task-planner hooks, then writes back atomically.
 *
 * Usage:
 *   bun run register-hooks-cj.ts [--dry-run] [--settings <path>] [--canonical <path>]
 *
 * If --settings is omitted, defaults to ~/.claude/settings.local.json.
 * If --canonical is omitted, defaults to $HOME/dev/task-planner.
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { homedir } from 'node:os';

const TASK_PLANNER_ROOT = process.env.TASK_PLANNER_ROOT ||
  join(homedir(), 'dev', 'task-planner');

function loadSettings(path: string): Record<string, unknown> {
  try {
    const raw = readFileSync(path, 'utf8').trim();
    if (!raw) return {};
    return JSON.parse(raw) as Record<string, unknown>;
  } catch {
    return {};
  }
}

function dumpSettings(path: string, obj: Record<string, unknown>, dryRun: boolean): void {
  if (dryRun) {
    console.log('[dry-run] Would write settings.local.json with hooks:');
    console.log(JSON.stringify(obj, null, 2));
    return;
  }
  const parent = resolve(path, '..');
  try {
    mkdirSync(parent, { recursive: true });
  } catch { /* directory may already exist */ }
  const tmp = path + '.tmp.' + process.pid;
  writeFileSync(tmp, JSON.stringify(obj, null, 2) + '\n', 'utf8');
  try {
    writeFileSync(path, readFileSync(tmp));
    process.unlinkSync(tmp);
  } catch {
    // atomic-fallback: direct write
    writeFileSync(path, JSON.stringify(obj, null, 2) + '\n', 'utf8');
  }
  console.log('[task-planner] settings.local.json patched.');
}

function taskPlannerHookEnv(commandBase: string): string {
  return commandBase.replace(
    '$HOME/dev/task-planner',
    '${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}'
  );
}

function buildHooks(canonicalRoot: string): Record<string, unknown[]> {
  const SD = '${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts';
  const HOOK_TOOL = '${CLAUDE_TOOL_NAME:-Write}';
  const HOOK_FILE = '${FILE_PATH:-}';
  const HOOK_SD = '"$SD"';

  const hooks: Record<string, unknown[]> = {
    SessionStart: [
      { tags: ['*'], command: 'bash ' + SD + '/task-plan-init.cjs', statusMessage: 'Checking task plan status...' },
    ],
    PreToolUse: [
      {
        matcher: 'Write|Edit',
        command: 'bash ' + SD + '/check-scope.sh "' + HOOK_TOOL + '" "' + HOOK_FILE + '"',
      },
    ],
    PostToolUse: [
      {
        matcher: 'Write|Edit',
        command: 'bash ' + SD + '/check-doc-sync.sh',
        statusMessage: '[task-planner] 计划/Todo 同步检查...',
      },
    ],
    UserPromptSubmit: [
      {
        command: 'bash ' + SD + '/zcode-userpromptsubmit.sh',
        statusMessage: '[task-planner] 新指令计划影响提示...',
      },
    ],
    Stop: [
      {
        command: 'SD="' + SD + '"; powershell.exe -NoProfile -ExecutionPolicy Bypass -File ' + HOOK_SD + '/check-complete.ps1 2>/dev/null || sh ' + HOOK_SD + '/check-complete.sh',
        statusMessage: '[task-planner] 完成检测...',
      },
    ],
  };

  // Log resolved paths
  for (const [name, commands] of Object.entries(hooks)) {
    for (const cmd of commands as Array<{ command?: string; statusMessage?: string }>) {
      if (cmd.command) {
        const resolved = cmd.command.replace(
          /\$\{TASK_PLANNER_ROOT:-\$HOME\/dev\/task-planner\}/g,
          canonicalRoot
        );
        console.log('[task-planner] hook ' + name + ': ' + resolved.slice(0, 80) + '...');
      }
    }
  }

  return hooks;
}

function patchSettings(settings: Record<string, unknown>, hooks: Record<string, unknown[]>, dryRun: boolean): void {
  const existing = settings.hooks as Record<string, unknown[]> | undefined;
  const merged = { ...existing } as Record<string, unknown[]> | {};
  for (const [name, cmds] of Object.entries(hooks)) {
    if (merged[name]) {
      console.log(`[task-planner] hook ${name}: existing entry found, overwriting with canonical.`);
    } else {
      console.log(`[task-planner] hook ${name}: registered (new).`);
    }
    merged[name] = cmds;
  }
  settings.hooks = merged;
  dumpSettings(process.argv[2] ?? join(homedir(), '.claude', 'settings.local.json'), settings, dryRun);
}

function main(): void {
  const args = process.argv.slice(2);
  let dryRun = false;
  let settingsPath = join(homedir(), '.claude', 'settings.local.json');
  let canonicalPath = TASK_PLANNER_ROOT;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--dry-run') { dryRun = true; settingsPath = '/dev/null'; continue; }
    if (arg === '--settings' && args[i + 1]) { settingsPath = args[++i]; continue; }
    if (arg === '--canonical' && args[i + 1]) { canonicalPath = args[++i]; continue; }
    console.error(`[task-planner] unknown arg: ${arg}`);
    process.exit(2);
  }

  if (!dryRun && !require('node:fs').existsSync(canonicalPath)) {
    console.error(`[task-planner] canonical not found at ${canonicalPath}. Install via git clone first.`);
    process.exit(1);
  }

  const settings = loadSettings(settingsPath);
  const hooks = buildHooks(canonicalPath);
  patchSettings(settings, hooks, dryRun);
}

main();
