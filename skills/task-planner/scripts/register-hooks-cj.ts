#!/usr/bin/env node --experimental-strip-types
/**
 * @configurable
 * CONFIG 区（可变参数与默认值，迁移时只改此处或对应 env）:
 * - settingsPath: ~/.claude/settings.local.json（homedir 拼接）— hook 注册目标 settings 文件（env: 无，flag: --settings）
 * - TASK_PLANNER_ROOT / canonicalPath: $HOME/dev/task-planner — 规范源根路径，buildHooks 指向该路径下脚本（env: TASK_PLANNER_ROOT，flag: --canonical）
 * 并行安全: 单 settings 文件一次性整写（tmp+rename 原子回写），非追加式
 */
/**
 * register-hooks-cj.ts — Patch ~/.claude/settings.local.json to add task-planner hooks.
 *
 * Reads current settings.local.json (or creates empty object), ensures `hooks` block
 * has the 5 task-planner hooks, then writes back atomically.
 *
 * Usage:
 *   node --experimental-strip-types register-hooks-cj.ts [--dry-run] [--settings <path>] [--canonical <path>]
 *
 * If --settings is omitted, defaults to ~/.claude/settings.local.json.
 * If --canonical is omitted, defaults to $HOME/dev/task-planner.
 */
import { readFileSync, writeFileSync, mkdirSync, statSync, existsSync, unlinkSync, renameSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { homedir } from 'node:os';

interface MetaInfo { name: string; version: string; title: string; description: string; keywords: string[]; usage: string; examples: string; input?: string; output?: string; }
const META: MetaInfo = {
  name: "register-hooks-cj", version: "1.0.0",
  title: "Register Hooks — 将 task-planner hooks 写入 settings.local.json",
  description: "Patch ~/.claude/settings.local.json 添加 task-planner hooks",
  keywords: ["hooks", "task-planner", "settings"],
  usage: "register_hooks_cj.ts [--dry-run] [--settings <path>] [--canonical <path>]",
  examples: "$ node --experimental-strip-types scripts/register_hooks_cj.ts\n$ node --experimental-strip-types scripts/register_hooks_cj.ts --dry-run\n$ node --experimental-strip-types scripts/register_hooks_cj.ts --canonical ~/dev/task-planner",
  output: "stdout: hook registration status | exit: 0=success, 1=error",
};
function handleHelpFlags(argv: string[]): void {
  if (argv.includes("--help") || argv.includes("-h")) {
    const lines: string[] = [
      `${META.title} (v${META.version})`, "",
      META.description, "",
      "Usage:", `  ${META.usage}`, "",
      "Options:", "  --dry-run              Preview without writing",
      "  --settings <path>      Settings file path",
      "  --canonical <path>     Canonical source path",
      "  --help, -h             Show this help", "  --examples             Show usage examples",
      "  --full-help            Show full help with input/output", "",
      META.output || "",
    ];
    console.log(lines.join("\n")); process.exit(0);
  }
  if (argv.includes("--examples")) {
    console.log(`Examples for ${META.name}:\n\n${META.examples}`); process.exit(0);
  }
  if (argv.includes("--full-help")) {
    const lines: string[] = [
      `${META.title} (v${META.version})`, "",
      META.description, "",
      "Usage:", `  ${META.usage}`, "",
      "Options:", "  --dry-run              Preview without writing",
      "  --settings <path>      Settings file path",
      "  --canonical <path>     Canonical source path",
      "  --help, -h             Show this help", "  --examples             Show usage examples",
      "  --full-help            Show full help with input/output", "",
      META.output || "",
    ];
    console.log(lines.join("\n")); process.exit(0);
  }
}

const TASK_PLANNER_ROOT = process.env.TASK_PLANNER_ROOT ||
  join(homedir(), 'dev', 'task-planner');

function loadSettings(path: string): Record<string, unknown> {
  // [2026-11-25 defect-fix P0-3] 文件不存在=首次安装，合法返回空对象；
  // 但文件存在却解析失败时禁止静默返回 {}——否则 dumpSettings 会用空对象整写覆盖
  // 用户的其它配置（插件 hook、权限等）永久丢失。改为抛错由 main 兜底退出。
  if (!existsSync(path)) return {};
  try {
    // [2026-09-01] memory-safety: size guard before readFileSync
    if (statSync(path).size > 50 * 1024 * 1024) throw new Error('settings file >50MB');
    const raw = readFileSync(path, 'utf8').trim();
    if (!raw) return {};
    return JSON.parse(raw) as Record<string, unknown>;
  } catch (err) {
    throw new Error(`[task-planner] 无法解析 ${path}（疑似损坏/半截 JSON）: ${err}。已中止以避免覆盖用户配置，请人工检查该文件。`);
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
  // [2026-11-25 defect-fix P0-3] 原实现 writeFileSync(path, readFileSync(tmp)) 是截断-重写，
  // 非原子；异常时 catch 二次直写会在半截状态上再写一遍，可损毁用户 settings。
  // 改为同目录 renameSync（POSIX 原子替换）；失败仅清理 tmp 并抛错，禁二次直写。
  writeFileSync(tmp, JSON.stringify(obj, null, 2) + '\n', 'utf8');
  try {
    renameSync(tmp, path);
  } catch (err) {
    try { unlinkSync(tmp); } catch { /* tmp 可能已不存在 */ }
    throw new Error(`[task-planner] 原子写回 ${path} 失败: ${err}`);
  }
  console.log('[task-planner] settings.local.json patched.');
}

// [2026-11-25 defect-fix P0-1] 原实现把 SD 硬编码为 '${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts'，
// 该 fallback 路径在实盘不存在（/home/terry/dev/task-planner 无 scripts/ 子目录），
// 且 canonicalRoot 参数只用于日志打印、未参与命令构造 → Claude Code 会话未设 env 时全部 hook ENOENT。
// 本函数在安装期把不存在的默认 fallback 替换为真实 canonical 根，确保写出的命令指向有效脚本目录。
function taskPlannerHookEnv(commandBase: string, canonicalRoot: string): string {
  return commandBase.replace(
    '${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}',
    '${TASK_PLANNER_ROOT:-' + canonicalRoot + '}'
  );
}

function buildHooks(canonicalRoot: string): Record<string, unknown[]> {
  const SD = taskPlannerHookEnv('${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts', canonicalRoot);
  const HOOK_TOOL = '${CLAUDE_TOOL_NAME:-Write}';
  const HOOK_FILE = '${FILE_PATH:-}';
  const HOOK_SD = '"$SD"';

  const hooks: Record<string, unknown[]> = {
    SessionStart: [
      { tags: ['*'], command: 'bash ' + SD + '/task-plan-init.cjs', statusMessage: 'Checking task plan status...' },
    ],
    PreToolUse: [
      {
        // [2026-09-25 task-v090] Rule 39.7.3 matcher 观察面扩围（ZCode 运行位由
        // ~/.zcode/cli/config.json + zcode-pretooluse.sh 39.7.3 观察分支承接；此处保持
        // check-scope.sh command 不变——workflow 四工具无 file_path → check-scope 空路径
        // exit 0 天然放行，零阻断语义；39.5 守卫面不变）
        matcher: 'Write|Edit|CreateWorkflow|AmendWorkflow|SaveWorkflow|EvalWorkflowSnippet',
        command: 'bash ' + SD + '/check-scope.sh "' + HOOK_TOOL + '" "' + HOOK_FILE + '"',
      },
    ],
    PostToolUse: [
      {
        matcher: 'Write|Edit',
        command: 'bash ' + SD + '/check-doc-sync.sh',
        statusMessage: '[task-planner] 计划/Todo 同步检查...',
      },
      {
        // [task-tier-deadzone-fix-20261125 R2/F6] 死角#1：claude 位 tier 升档检查（claude 无 zcode 的
        // posttooluse tier 逻辑 → mini 计划永不升级）。形态与上一条完全一致（本文件既有 schema），
        // 不引入新字段；与 install-stub.sh 薄壳文档、SKILL.md 无 hook 位自查条款三处同源。
        matcher: '*',
        command: 'bash ' + SD + '/tier-upgrade-check.sh',
        statusMessage: '[task-planner] tier 升档检查...',
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
        // [2026-10-11 task-v167] 停止护栏(stall 检测 + block 次数 cap 20): 置于 check-complete 之前,
        // 先拦"任务未完成就停止"(五重 guard 判定), 再由 check-complete 做完成度终验
        command: 'bash ' + SD + '/check-stop-guard.sh',
        statusMessage: '[task-planner] 停止护栏(stall/上限20)...',
      },
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

function patchSettings(settings: Record<string, unknown>, hooks: Record<string, unknown[]>, dryRun: boolean, settingsPath: string): void {
  const existing = settings.hooks as Record<string, unknown[]> | undefined;
  const merged = { ...existing } as Record<string, unknown[]> | {};
  for (const [name, cmds] of Object.entries(hooks)) {
    // [2026-11-25 defect-fix P0-4] 原实现 merged[name]=cmds 整段替换，会清除同事件下
    // 其它插件/用户自有的 hook。改为按 command 去重合并：先保留所有非本技能的条目，
    // 再追加/替换本技能条目（以 command 字符串是否位于 cmds 集合判定归属）。
    const incoming = cmds as Array<{ command?: string }>;
    const incomingCmds = new Set(incoming.map(c => c.command));
    const prior = (merged[name] ?? []) as Array<{ command?: string }>;
    const isTpHook = (cmd: string) =>
      cmd.includes('/task-planner/') ||
      cmd.includes('${TASK_PLANNER_ROOT') ||
      cmd.includes('dev/task-planner}/scripts') ||
      cmd.includes('$SD'); // 旧 Stop hook 用 SD= 变量间接指向 task-planner 脚本
    // [2026-11-25 task-skill-deploy-fix P0-4b] 原 kept 只按 command 字符串精确相等排除 incoming，
    // 旧 task-planner hook（fallback 指向已不存在的 $HOME/dev/task-planner）字符串与新 command 不同，
    // 被误判为第三方而保留 → settings 里新旧 hook 并存、坏路径无法清除（dry-run 实证残留 7 处）。
    // 修正：kept 同时排除"本技能旧 hook"（无论其 fallback 形态），只真正保留第三方条目。
    const kept = prior.filter(c => !incomingCmds.has(c.command ?? '') && !isTpHook(c.command ?? ''));
    const replaced = prior.some(c => isTpHook(c.command ?? ''));
    if (replaced) {
      console.log(`[task-planner] hook ${name}: refreshed task-planner entries (preserved ${kept.length} third-party).`);
    } else {
      console.log(`[task-planner] hook ${name}: registered (new).`);
    }
    merged[name] = [...kept, ...cmds];
  }
  settings.hooks = merged;
  // [2026-11-25 defect-fix P0-2] 原实现用 process.argv[2] 作为写入目标：
  // --settings <path> 时 argv[2] 是字面量 '--settings'，会在 cwd 创建错误文件；
  // --canonical <dir> 时 argv[2] 是目录 → EISDIR。统一改用已解析的 settingsPath。
  dumpSettings(settingsPath, settings, dryRun);
}

function main(): void {
  handleHelpFlags(process.argv.slice(2));
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

  if (!dryRun && !existsSync(canonicalPath)) {
    console.error(`[task-planner] canonical not found at ${canonicalPath}. Install via git clone first.`);
    process.exit(1);
  }

  try {
    const settings = loadSettings(settingsPath);
    const hooks = buildHooks(canonicalPath);
    patchSettings(settings, hooks, dryRun, settingsPath);
  } catch (err) {
    // [2026-11-25 defect-fix P0-3] 配置损坏/写回失败时非零退出，禁止静默吞错
    console.error(err instanceof Error ? err.message : String(err));
    process.exit(2);
  }
}

main();
