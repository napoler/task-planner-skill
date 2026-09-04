#!/usr/bin/env node
/**
 * ================================================================================
 * 【工具元数据 - 修改这里即可自动更新帮助信息】
 * ================================================================================
 *
 * META_NAME: todo-manager           # 工具名称（英文，动词-名词结构）
 * META_VERSION: 1.0.0               # 版本号
 * META_AUTHOR: ZCode                # 作者
 *
 * META_TITLE: 持久化任务管理器
 * META_DESCRIPTION: 基于 JSON 文件存储的任务管理 CLI，与 todo-skill 工作流及原生 Task 工具兼容
 *
 * META_KEYWORDS:
 *   - todo
 *   - task
 *   - manager
 *   - plan
 *
 * META_USAGE: |
 *   $ cli_todo-manager.ts create --title "任务名" --desc "描述" --priority High
 *   $ cli_todo-manager.ts list --status pending
 *   $ cli_todo-manager.ts plan --goal "大目标" --max_steps 10
 *   $ cli_todo-manager.ts --help
 *
 * META_EXAMPLES: |
 *   # 示例1: 创建任务计划骨架（SKILL.md Step 1）
 *   $ cli_todo-manager.ts plan --goal "完成站点改版" --max_steps 10
 *
 *   # 示例2: 创建并推进一个任务（SKILL.md Step 5）
 *   $ cli_todo-manager.ts create --title "调研" --desc "输出调研报告"
 *   $ cli_todo-manager.ts update --index 1 --status completed
 *
 *   # 示例3: 导出完整 store 供 session-kv 存储
 *   $ cli_todo-manager.ts export
 *
 * META_INPUT: |
 *   输入格式: 命令行子命令 + flag 参数
 *   存储: store.json（JSON，格式与 python 版 todo_manager.py 完全兼容）
 *
 * META_OUTPUT: |
 *   输出格式: JSON（stdout，单行紧凑，ensure_ascii 语义与 python 版一致）
 *   错误: stderr（JSON 或日志）
 *   返回码: 0=成功, 1=运行失败（如无效索引）, 2=参数错误
 *
 * META_DEPS: |
 *   Node.js >= 22.18（原生 TypeScript type stripping，无需编译）
 *   无外部依赖
 *
 * ================================================================================
 *
 * 【运行方式】
 *   cli_todo-manager.ts --help        （chmod +x 后直接调用）
 *   node cli_todo-manager.ts --help
 *
 * 【命名规范】
 *   文件名: cli_todo-manager.ts
 *   META_NAME: todo-manager
 *
 * 【迁移说明 2026-08-29】
 *   由 python 版 tools/todo_manager.py 迁移（AGENTS.md §九 Bun+TS 优先级 +
 *   cli-tool-builder DoD）。运行时降级决策：bun 本机不可用（command -v bun exit 1，
 *   用户确认），按 cli-tool-builder DoD-1 显式降级 node 原生 TS。
 *   迁移对等对照表见 plans/task-todo-skill-ts/progress.md。
 *
 * ================================================================================
 */

/**
 * @configurable 可迁移参数（迁移时只改这里 + 环境变量，禁止全文 sed）
 * - TODO_STORE_FILE  默认 <脚本目录>/store.json  任务存储文件路径（测试时指向临时副本，禁止污染生产数据）
 */

import * as fs from "fs";
import * as path from "path";

// ================================================================================
// 【元数据 - 从上方注释中提取】
// ================================================================================

const TOOL_NAME = "todo-manager";
const __version__ = "1.0.0";
const __author__ = "ZCode";

const TOOL_TITLE = "持久化任务管理器";
const TOOL_DESCRIPTION =
  "基于 JSON 文件存储的任务管理 CLI，与 todo-skill 工作流及原生 Task 工具兼容";

const TOOL_KEYWORDS = ["todo", "task", "manager", "plan"];

const TOOL_USAGE = `$ cli_todo-manager.ts create --title "任务名" --desc "描述" --priority High
  $ cli_todo-manager.ts list --status pending
  $ cli_todo-manager.ts plan --goal "大目标" --max_steps 10
  $ cli_todo-manager.ts --help`;

const TOOL_EXAMPLES = `# 示例1: 创建任务计划骨架（SKILL.md Step 1）
$ cli_todo-manager.ts plan --goal "完成站点改版" --max_steps 10

# 示例2: 创建并推进一个任务（SKILL.md Step 5）
$ cli_todo-manager.ts create --title "调研" --desc "输出调研报告"
$ cli_todo-manager.ts update --index 1 --status completed

# 示例3: 导出完整 store 供 session-kv 存储
$ cli_todo-manager.ts export`;

const TOOL_INPUT = `输入格式: 命令行子命令 + flag 参数
存储: store.json（JSON，格式与 python 版 todo_manager.py 完全兼容）`;

const TOOL_OUTPUT = `输出格式: JSON（stdout，单行紧凑）
错误: stderr（JSON 或日志）
返回码: 0=成功, 1=运行失败（如无效索引）, 2=参数错误`;

const TOOL_DEPS = `Node.js >= 22.18（原生 TypeScript type stripping，无需编译）
无外部依赖`;

// ================================================================================
// 【可配置参数区（@configurable 登记，迁移时只改这里）】
// ================================================================================

const STORE_FILE =
  process.env.TODO_STORE_FILE ??
  path.join(import.meta.dirname ?? path.dirname(process.argv[1] ?? "."), "store.json");

const DEFAULT_STORE = { tasks: [] as Task[], created_at: null as string | null, updated_at: null as string | null };

const PRIORITIES = ["High", "Medium", "Low"] as const;
const STATUSES = ["pending", "in_progress", "completed"] as const;

// ================================================================================
// 【类型定义】
// ================================================================================

interface Task {
  id: number;
  title: string;
  description: string;
  priority: string;
  status: string;
  created_at: string;
  updated_at: string;
}

interface Store {
  tasks: Task[];
  created_at: string | null;
  updated_at: string | null;
}

interface CliArgs {
  command: string;
  title?: string;
  desc?: string | null;
  priority?: string;
  status?: string;
  index?: number;
  goal?: string;
  maxSteps: number;
  verbose: boolean;
}

// ================================================================================
// 【日志系统】（-v/--verbose 日志走 stderr，正常输出走 stdout）
// ================================================================================

class Logger {
  private verbose: boolean;

  constructor(verbose: boolean) {
    this.verbose = verbose;
  }

  private format(level: string, msg: string): string {
    const now = new Date().toISOString().replace("T", " ").slice(0, 19);
    return `${now} [${level}] ${msg}`;
  }

  debug(msg: string): void {
    if (this.verbose) {
      console.error(this.format("DEBUG", msg));
    }
  }

  error(msg: string): void {
    console.error(this.format("ERROR", msg));
  }
}

// ================================================================================
// 【存储层 — 对应 python 版 _now_iso/_load/_save】
// ================================================================================

/** 对应 python 版 _now_iso：ISO8601 时间戳（python 为 +00:00 后缀，此处为 Z 后缀，均为 UTC） */
function nowIso(): string {
  return new Date().toISOString();
}

/** 对应 python 版 _load：读取 store.json，缺 tasks 键时补空数组，文件不存在返回默认结构 */
function loadStore(logger: Logger): Store {
  if (fs.existsSync(STORE_FILE)) {
    const raw = fs.readFileSync(STORE_FILE, "utf-8");
    let data: Store;
    try {
      data = JSON.parse(raw) as Store;
    } catch (e) {
      throw new Error(`store.json 解析失败: ${e instanceof Error ? e.message : String(e)}`);
    }
    if (!Array.isArray(data.tasks)) {
      data.tasks = [];
    }
    logger.debug(`已加载 ${STORE_FILE}（${data.tasks.length} 个任务）`);
    return data;
  }
  logger.debug(`store 不存在，使用默认结构: ${STORE_FILE}`);
  return JSON.parse(JSON.stringify(DEFAULT_STORE)) as Store;
}

/** 对应 python 版 _save：回写 updated_at（首写补 created_at），indent=2 与 python 版一致 */
function saveStore(data: Store, logger: Logger): void {
  data.updated_at = nowIso();
  if (data.created_at === null) {
    data.created_at = data.updated_at;
  }
  fs.writeFileSync(STORE_FILE, JSON.stringify(data, null, 2), "utf-8");
  logger.debug(`已写回 ${STORE_FILE}`);
}

// ================================================================================
// 【命令实现 — 对应 python 版 cmd_create/cmd_list/cmd_update/cmd_clear/cmd_plan/cmd_status/cmd_export】
// ================================================================================

function cmdCreate(args: CliArgs, logger: Logger): void {
  const data = loadStore(logger);
  const task: Task = {
    id: data.tasks.length + 1,
    title: args.title as string,
    description: args.desc ?? "",
    priority: args.priority as string,
    status: "pending",
    created_at: nowIso(),
    updated_at: nowIso(),
  };
  data.tasks.push(task);
  saveStore(data, logger);
  console.log(JSON.stringify({ action: "created", task }));
}

function cmdList(args: CliArgs, logger: Logger): void {
  const data = loadStore(logger);
  let tasks = data.tasks;
  if (args.status) {
    tasks = tasks.filter((t) => t.status === args.status);
  }
  console.log(JSON.stringify({ tasks, count: tasks.length }));
}

function cmdUpdate(args: CliArgs, logger: Logger): void {
  const data = loadStore(logger);
  const idx = (args.index as number) - 1;
  if (idx < 0 || idx >= data.tasks.length) {
    // 与 python 版一致：无效索引走 stderr JSON + exit 1
    console.error(
      JSON.stringify({ error: `无效索引 ${args.index}，共 ${data.tasks.length} 个任务` })
    );
    process.exit(1);
  }
  const task = data.tasks[idx];
  if (args.status) {
    task.status = args.status;
  }
  if (args.desc !== null && args.desc !== undefined) {
    task.description = args.desc;
  }
  task.updated_at = nowIso();
  saveStore(data, logger);
  console.log(JSON.stringify({ action: "updated", task }));
}

function cmdClear(_args: CliArgs, logger: Logger): void {
  const data = loadStore(logger);
  const count = data.tasks.length;
  data.tasks = [];
  saveStore(data, logger);
  console.log(JSON.stringify({ action: "cleared", removed: count }));
}

/** 对应 python 版 cmd_plan：生成计划骨架（实际拆解由 SKILL.md 指导 Agent 完成），并清空旧任务 */
function cmdPlan(args: CliArgs, logger: Logger): void {
  const data = loadStore(logger);
  const plan = {
    goal: args.goal,
    max_steps: args.maxSteps,
    steps: [] as unknown[],
    strategy: "agent_decompose",
    created_at: nowIso(),
  };
  data.tasks = [];
  saveStore(data, logger);
  console.log(JSON.stringify(plan));
}

function cmdStatus(_args: CliArgs, logger: Logger): void {
  const data = loadStore(logger);
  const byStatus: Record<string, number> = {};
  for (const t of data.tasks) {
    byStatus[t.status] = (byStatus[t.status] ?? 0) + 1;
  }
  console.log(
    JSON.stringify({
      total: data.tasks.length,
      by_status: byStatus,
      created_at: data.created_at,
      updated_at: data.updated_at,
    })
  );
}

/** 对应 python 版 cmd_export：导出完整 store 供 session-kv 存储 */
function cmdExport(_args: CliArgs, logger: Logger): void {
  const data = loadStore(logger);
  console.log(JSON.stringify(data));
}

// ================================================================================
// 【帮助系统】
// ================================================================================

function makeHelpEpilog(): string {
  return `
【使用示例】
${TOOL_EXAMPLES}

【输入说明】
${TOOL_INPUT}

【输出说明】
${TOOL_OUTPUT}

【依赖环境】
${TOOL_DEPS}

【返回码】
  0 - 成功
  1 - 运行失败（如无效任务索引）
  2 - 参数错误

【工具信息】
  版本: ${__version__}
  作者: ${__author__}
  存储: ${STORE_FILE}（可用环境变量 TODO_STORE_FILE 覆盖）
  模板: ~/.zcode/skills/cli-tool-builder/templates/bun/cli_template.ts（node 运行时适配）
`;
}

function printHelp(): void {
  console.log(`${TOOL_TITLE}
${TOOL_DESCRIPTION}

用法:
  ${TOOL_USAGE}

子命令:
  create    创建任务    --title 必填, --desc, --priority High|Medium|Low
  list      列出任务    [--status pending|in_progress|completed]
  update    更新任务    --index N 必填, [--status ...] [--desc "新描述"]
  clear     清空所有任务
  plan      创建计划骨架（清空旧任务）  --goal 必填, [--max_steps 10]
  status    查看任务统计
  export    导出完整 store JSON

全局参数:
  -h, --help       显示帮助
  --version        显示版本
  --examples       显示使用示例
  --full-help      显示完整帮助（含输入输出）
  -v, --verbose    详细日志输出（stderr）
${makeHelpEpilog()}`);
}

// ================================================================================
// 【参数解析】
// ================================================================================

const USAGE_EXIT = 2;

function fail(message: string, logger: Logger, showHelp = true): never {
  logger.error(message);
  if (showHelp) printHelp();
  process.exit(USAGE_EXIT);
}

function parseArgs(argv: string[]): CliArgs {
  const args: CliArgs = { command: "", maxSteps: 10, verbose: false };

  // 子命令与全局 flag 可任意顺序，与 argparse 语义近似
  const rest: string[] = [];
  let i = 0;
  while (i < argv.length) {
    const arg = argv[i];
    if (arg === "-h" || arg === "--help") {
      printHelp();
      process.exit(0);
    } else if (arg === "--version") {
      console.log(`${TOOL_NAME} ${__version__}`);
      process.exit(0);
    } else if (arg === "--examples") {
      console.log(`【${TOOL_TITLE} 使用示例】\n${TOOL_EXAMPLES}`);
      process.exit(0);
    } else if (arg === "--full-help") {
      printHelp();
      process.exit(0);
    } else if (arg === "-v" || arg === "--verbose") {
      args.verbose = true;
      i++;
    } else {
      rest.push(arg);
      i++;
    }
  }

  const logger = new Logger(args.verbose);

  if (rest.length === 0) {
    fail("错误: 缺少子命令", logger);
  }
  args.command = rest.shift() as string;

  while (rest.length > 0) {
    const flag = rest.shift() as string;
    const value = (): string => {
      const v = rest.shift();
      if (v === undefined) {
        fail(`错误: ${flag} 需要一个值`, logger);
      }
      return v;
    };
    switch (flag) {
      case "--title":
        args.title = value();
        break;
      case "--desc":
        args.desc = value();
        break;
      case "--priority": {
        const p = value();
        if (!(PRIORITIES as readonly string[]).includes(p)) {
          fail(`错误: 无效的 priority '${p}'，可用值: ${PRIORITIES.join(", ")}`, logger);
        }
        args.priority = p;
        break;
      }
      case "--status": {
        const s = value();
        if (!(STATUSES as readonly string[]).includes(s)) {
          fail(`错误: 无效的 status '${s}'，可用值: ${STATUSES.join(", ")}`, logger);
        }
        args.status = s;
        break;
      }
      case "--index": {
        const n = Number(value());
        if (!Number.isInteger(n) || n <= 0) {
          fail(`错误: --index 需要正整数，收到 '${n}'`, logger);
        }
        args.index = n;
        break;
      }
      case "--goal":
        args.goal = value();
        break;
      case "--max_steps": {
        const n = Number(value());
        if (!Number.isInteger(n) || n <= 0) {
          fail(`错误: --max_steps 需要正整数，收到 '${n}'`, logger);
        }
        args.maxSteps = n;
        break;
      }
      default:
        fail(`错误: 未知参数 '${flag}'`, logger);
    }
  }
  return args;
}

// ================================================================================
// 【主入口】
// ================================================================================

const COMMANDS = ["create", "list", "update", "clear", "plan", "status", "export"] as const;

function main(): number {
  const argv = process.argv.slice(2);
  // 先探测 verbose 以便错误信息也带 logger（解析错误统一 exit 2）
  const verbose = argv.includes("-v") || argv.includes("--verbose");
  const logger = new Logger(verbose);

  const args = parseArgs(argv);

  if (!(COMMANDS as readonly string[]).includes(args.command)) {
    fail(`错误: 未知子命令 '${args.command}'，可用: ${COMMANDS.join(", ")}`, logger);
  }

  // 每个子命令的必填参数校验（与 argparse required 语义一致，缺失 = exit 2）
  if (args.command === "create" && !args.title) {
    fail("错误: create 需要 --title", logger);
  }
  if (args.command === "update" && args.index === undefined) {
    fail("错误: update 需要 --index", logger);
  }
  if (args.command === "plan" && !args.goal) {
    fail("错误: plan 需要 --goal", logger);
  }

  try {
    switch (args.command) {
      case "create":
        if (!args.priority) args.priority = "Medium";
        cmdCreate(args, logger);
        break;
      case "list":
        cmdList(args, logger);
        break;
      case "update":
        cmdUpdate(args, logger);
        break;
      case "clear":
        cmdClear(args, logger);
        break;
      case "plan":
        cmdPlan(args, logger);
        break;
      case "status":
        cmdStatus(args, logger);
        break;
      case "export":
        cmdExport(args, logger);
        break;
    }
    return 0;
  } catch (e) {
    logger.error(`运行失败: ${e instanceof Error ? e.message : String(e)}`);
    return 1;
  }
}

process.exit(main());
