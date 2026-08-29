#!/usr/bin/env node
/**
 * task-plan-init.cjs — SessionStart hook
 *
 * 逻辑（哨兵机制）：
 *   - 每次 SessionStart 都写 .plan-required 哨兵
 *   - 哨兵 = "当前会话尚未创建有效计划，禁止写业务代码"
 *   - 当 agent 通过 init-session.sh 在 plans/task-{id}/ 创建完整计划后，
 *     调用 plan-created.cjs 清除哨兵
 *
 * 哨兵位置：CWD/.plan-required（项目根目录）
 */

const fs = require('fs');
const path = require('path');

const CWD = process.cwd();
const SENTINEL_PATH = path.join(CWD, '.plan-required');

// 幂等写入：内容带时间戳，始终刷新
try {
  const content = `plan-required\ncreated: ${new Date().toISOString()}\ncwd: ${CWD}\n`;
  fs.writeFileSync(SENTINEL_PATH, content, { encoding: 'utf-8' });
  console.log('[task-plan] 🚨 哨兵已写入: ' + SENTINEL_PATH);
  console.log('[task-plan] 触发条件（命中任一需调用 Skill("task-planner")）：');
  console.log('[task-plan]   - 修改 ≥3 个文件');
  console.log('[task-plan]   - 跨多阶段流程');
  console.log('[task-plan]   - 预计耗时 > 10 分钟');
  console.log('[task-plan]   - 边界模糊 / 高风险 / 用户未说"简单"');
  console.log('[task-plan] 初始化命令:');
  // [2026-08-28] 修复:提示语路径改指本 skill 的 zcode 副本(原为 ~/.claude,与 ZCode 实际加载路径不一致)
  console.log('[task-plan]   mkdir -p plans/task-{id}/ && cd $_ && bash ~/.zcode/skills/task-planner/scripts/init-session.sh');
} catch (e) {
  console.log('[task-plan] ⚠ 写入哨兵失败: ' + e.message);
}

process.exit(0);
