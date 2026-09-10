#!/usr/bin/env node
/**
 * plan-created.cjs — Agent 创建有效计划后手动调用的清理脚本
 *
 * 用法：node ~/.zcode/skills/task-planner/scripts/plan-created.cjs
 *       可从任意子目录调用（自动向上查找项目根）
 *
 * 行为：
 *   1. 从 CWD 向上查找包含 plans/ 的项目根
 *   2. 验证 plans/ 下存在有效 task_plan.md（跳过 archive 前缀目录）
 *   3. 删除 legacy 全局哨兵 <root>/.plan-required（迁移清理）与本会话 side 哨兵
 *      plans/.plan_required_side/<sidkey>.plan_required（sidkey 缺失则跳过本步）
 *
 * [2026-09-10 task-planrequired-race] 原行为=「plans/ 下存在比全局哨兵新的 task_plan.md 才删
 * 全局 .plan-required」，mtime 仲裁会被他会话 SessionStart 刷新哨兵破坏（findings B3 根因）。
 * 现改为存在性验证：任一有效 task_plan.md 存在即清除；清除动作只针对 legacy + 本会话
 * side 哨兵（normSidkey 与 task-plan-init.cjs 同 canon，findings D4/D8/D10）。
 */

const fs = require('fs');
const path = require('path');

// 从 CWD 向上查找有 plans/ 目录的根（原样复用）
function findProjectRoot(startDir) {
  let d = startDir;
  for (let i = 0; i < 10; i++) {
    if (fs.existsSync(path.join(d, 'plans'))) return d;
    const next = path.resolve(d, '..');
    if (next === d) break;
    d = next;
  }
  return startDir;
}

// [2026-09-10 task-planrequired-race] sid 获取（按优先级）：stdin JSON .session_id（fail-open，
// 手工管道场景）→ env TASK_PLANNER_SID → env CLAUDE_CODE_SESSION_ID。
let sid = '';
try {
  const raw = fs.readFileSync(0, 'utf8');
  const j = JSON.parse(raw);
  if (j && typeof j.session_id === 'string') sid = j.session_id;
} catch (e) {
  // 无 stdin / 非 JSON → 降级 env
}
if (!sid) sid = process.env.TASK_PLANNER_SID || process.env.CLAUDE_CODE_SESSION_ID || '';

// [2026-09-10 task-planrequired-race] canon 与 task-plan-init.cjs 完全一致（findings D8）：
// 剥非字母数字取前 40，再剥 sess 前缀 = uuid core。
function normSidkey(s) {
  let k = String(s).replace(/[^a-zA-Z0-9]/g, '').slice(0, 40);
  if (k.startsWith('sess')) k = k.slice(4);
  return k;
}
const sidkey = normSidkey(sid);

const projectRoot = findProjectRoot(process.cwd());
const PLANS_DIR = path.join(projectRoot, 'plans');

// 验证：plans/ 下任一 task_plan.md 存在即视为有效计划（跳过 archive 前缀目录；B3 根除，
// 不再与哨兵 mtime 比较）
let planFound = false;
let planPath = '';
if (fs.existsSync(PLANS_DIR)) {
  try {
    for (const entry of fs.readdirSync(PLANS_DIR)) {
      if (entry.startsWith('archive')) continue;
      const candidate = path.join(PLANS_DIR, entry, 'task_plan.md');
      if (fs.existsSync(candidate)) {
        planFound = true;
        planPath = candidate;
        break;
      }
    }
  } catch (e) {
    // plans/ 不可读视为无效
  }
}

// 一个都没有 → 保留原警告文案风格 + exit 1（拒绝无计划清除的保护语义）
if (!planFound) {
  console.log('[task-plan] ⚠ 未找到有效的新计划，无法清除哨兵。');
  console.log('[task-plan] 请创建计划: mkdir -p plans/task-{id}/ && cd $_ && bash ~/.zcode/skills/task-planner/scripts/init-session.sh');
  process.exit(1);
}

// 清除动作（存在才删，各打印一行）
// [2026-09-10 CR P1 修正] legacy 哨兵是跨会话共享面：仅当存在比它新的有效计划时才清
// （新计划 mtime > legacy mtime；原先"任一计划存在即删"会让 legacy 在清除侧复活 B4 共享面），
// 否则保留并提示，避免顺手清掉他会话依赖的活跃 gate。
const LEGACY_SENTINEL = path.join(projectRoot, '.plan-required');
if (fs.existsSync(LEGACY_SENTINEL)) {
  let newerPlan = false;
  for (const entry of fs.readdirSync(PLANS_DIR)) {
    if (entry.startsWith('archive')) continue;
    const cand = path.join(PLANS_DIR, entry, 'task_plan.md');
    if (fs.existsSync(cand) && fs.statSync(cand).mtimeMs > fs.statSync(LEGACY_SENTINEL).mtimeMs) {
      newerPlan = true;
      break;
    }
  }
  if (newerPlan) {
    fs.unlinkSync(LEGACY_SENTINEL);
    console.log('[task-plan] ✓ legacy 哨兵已清除（存在比它新的计划）: ' + LEGACY_SENTINEL);
  } else {
    console.log('[task-plan] ⚠ legacy 哨兵保留（无比它新的计划，避免清掉他会话的活跃 gate）');
  }
}

if (sidkey) {
  const sideSentinel = path.join(PLANS_DIR, '.plan_required_side', sidkey + '.plan_required');
  if (fs.existsSync(sideSentinel)) {
    fs.unlinkSync(sideSentinel);
    console.log('[task-plan] ✓ 会话哨兵已清除: ' + sideSentinel + '（sidkey=' + sidkey + '）');
  }
} else {
  console.log('[task-plan] ⚠ 未提取到 session_id，跳过会话 side 哨兵清除（fail-open）');
}

// D10 说明：拦截侧（check-scope）为 check-time 仲裁——若存在晚于哨兵 created 的项目内
// task_plan.md 会自动放行；本脚本是显式即时清除 + 存在性校验（模型侧主动调用）。
console.log('[task-plan] ✓ 有效计划确认: ' + planPath);
console.log('[task-plan] 可正常执行写入操作。');
process.exit(0);
