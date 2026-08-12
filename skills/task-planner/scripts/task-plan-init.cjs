#!/usr/bin/env node
/**
 * task-plan-init.cjs — SessionStart hook
 * 检测当前会话是否需要计划文档。
 *
 * 检测逻辑：
 *   1. 查找当前目录及父目录的 plans/ 下是否有 task_plan.md
 *   2. 查找 session-kv 中是否有活跃的 plan 标记
 *   3. 检查是否有进行中的 batch-xxx/ 或 plan-xxx/ 目录
 *
 * 输出：纯文本注入到会话上下文
 */

const fs = require('fs');
const path = require('path');

const CWD = process.cwd();

// 1. Search for existing task_plan.md upward from CWD
function findExistingPlan(startDir) {
  const dirs = [startDir, path.resolve(startDir, '..'), path.resolve(startDir, '../..'), path.resolve(startDir, '../../..')];
  for (const dir of dirs) {
    // Check plans/task_plan.md
    const candidate = path.join(dir, 'plans', 'task_plan.md');
    if (fs.existsSync(candidate)) return candidate;
    // Check plans/task-{id}/task_plan.md
    const plansDir = path.join(dir, 'plans');
    if (fs.existsSync(plansDir)) {
      const subdirs = fs.readdirSync(plansDir).filter(f => f.startsWith('task-') && fs.statSync(path.join(plansDir, f)).isDirectory());
      for (const subdir of subdirs) {
        const planFile = path.join(plansDir, subdir, 'task_plan.md');
        if (fs.existsSync(planFile)) return planFile;
      }
    }
  }
  return null;
}

// 2. Check for active batch/plan directories
function findActiveBatch(startDir) {
  const dirs = [startDir, path.resolve(startDir, '..'), path.resolve(startDir, '../..')];
  for (const dir of dirs) {
    // Check for batch-xxx directories
    const plansDir = path.join(dir, 'plans');
    if (fs.existsSync(plansDir)) {
      const entries = fs.readdirSync(plansDir);
      const batchDirs = entries.filter(e => e.startsWith('batch-') && fs.statSync(path.join(plansDir, e)).isDirectory());
      if (batchDirs.length > 0) return batchDirs[0];
      const planDirs = entries.filter(e => e.startsWith('plan-') && fs.statSync(path.join(plansDir, e)).isDirectory());
      if (planDirs.length > 0) return planDirs[0];
    }
  }
  return null;
}

// 3. Check for .claude/session-kv or similar
function findSessionContext() {
  const kvPaths = [
    path.join(CWD, '.claude', 'session-kv'),
    path.join(process.env.HOME || '', '.claude', 'session-kv'),
  ];
  for (const kvPath of kvPaths) {
    if (fs.existsSync(kvPath)) {
      try {
        const files = fs.readdirSync(kvPath);
        const hasPlan = files.some(f => f.includes('plan') || f.includes('task'));
        if (hasPlan) return kvPath;
      } catch {}
    }
  }
  return null;
}

const existingPlan = findExistingPlan(CWD);
const activeBatch = findActiveBatch(CWD);
const sessionContext = findSessionContext();

if (existingPlan) {
  console.log('[task-plan] 检测到已有计划: ' + existingPlan);
  console.log('[task-plan] 可在需要恢复执行时读取。');
} else if (activeBatch) {
  console.log('[task-plan] 检测到活跃批量任务: plans/' + activeBatch);
  console.log('[task-plan] 批量任务有自己的计划管理，无需额外创建 task_plan.md。');
} else if (sessionContext) {
  console.log('[task-plan] 检测到会话上下文，计划可能通过 session-kv 管理。');
} else {
  console.log('[task-plan] 提示：当前会话无 task_plan.md。');
  console.log('[task-plan] 触发条件（命中任一调用 Skill("task-planner")）：');
  console.log('[task-plan]   - 修改 ≥3 个文件');
  console.log('[task-plan]   - 跨多阶段流程');
  console.log('[task-plan]   - 预计耗时 > 10 分钟');
  console.log('[task-plan]   - 边界模糊 / 高风险 / 用户未说"简单"');
  console.log('[task-plan] 宪法 §十八点七：每会话必有计划，无计划禁止执行。');
}
