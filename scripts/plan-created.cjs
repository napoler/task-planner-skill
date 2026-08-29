#!/usr/bin/env node
/**
 * plan-created.cjs — Agent 创建有效计划后手动调用的清理脚本
 *
 * 用法：node ~/.claude/skills/task-planner/scripts/plan-created.cjs
 *       可从任意子目录调用（自动向上查找项目根）
 *
 * 行为：
 *   1. 从 CWD 向上查找包含 plans/ 的项目根
 *   2. 确认 plans/task-{id}/task_plan.md 存在且比哨兵更新（有效新计划）
 *   3. 删除项目根目录的 .plan-required 哨兵
 */

const fs = require('fs');
const path = require('path');

// 从 CWD 向上查找有 plans/ 目录的根
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

const projectRoot = findProjectRoot(process.cwd());
const SENTINEL_PATH = path.join(projectRoot, '.plan-required');
const PLANS_DIR = path.join(projectRoot, 'plans');

// 验证：确认 plans/ 下有比哨兵更新的有效 task_plan.md
let planFound = false;
let planPath = '';
let sentinelMtime = null;

if (fs.existsSync(SENTINEL_PATH)) {
  try {
    sentinelMtime = fs.statSync(SENTINEL_PATH).mtimeMs;
  } catch {}
}

if (fs.existsSync(PLANS_DIR)) {
  try {
    const entries = fs.readdirSync(PLANS_DIR);
    for (const entry of entries) {
      const candidate = path.join(PLANS_DIR, entry, 'task_plan.md');
      if (!fs.existsSync(candidate)) continue;
      // 跳过 archive 目录（归档旧计划不算"新创建"）
      if (entry.startsWith('archive')) continue;
      const mtime = fs.statSync(candidate).mtimeMs;
      // 计划必须比哨兵更新（或哨兵不存在）
      if (!sentinelMtime || mtime > sentinelMtime) {
        planFound = true;
        planPath = candidate;
        break;
      }
    }
  } catch {}
}

if (!planFound) {
  console.log('[task-plan] ⚠ 未找到有效的新计划，无法清除哨兵。');
  if (sentinelMtime) {
    console.log('[task-plan] 现有 plans/ 中的计划都比哨兵旧，请创建新计划。');
  }
  console.log('[task-plan] 初始化命令: mkdir -p plans/task-{id}/ && cd $_ && bash ~/.claude/skills/task-planner/scripts/init-session.sh');
  process.exit(1);
}

// 清除哨兵
if (fs.existsSync(SENTINEL_PATH)) {
  fs.unlinkSync(SENTINEL_PATH);
  console.log('[task-plan] ✓ 哨兵已清除: ' + SENTINEL_PATH);
  console.log('[task-plan] 有效计划确认: ' + planPath);
  console.log('[task-plan] 可正常执行写入操作。');
} else {
  console.log('[task-plan] 哨兵不存在（可能已被其他进程清除）。');
}

process.exit(0);
