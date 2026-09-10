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
 * 哨兵位置：plans/.plan_required_side/<sidkey>.plan_required（会话私有，项目 plans/ 祖先目录下）
 *
 * [2026-09-10 task-planrequired-race] 原行为=无条件写 <CWD>/.plan-required（全局共享致跨会话互写竞态 B1/B2/B4）；
 * 改为会话私有 side 哨兵 plans/.plan_required_side/<sidkey>.plan_required（findings D1/D2/D5/D8）。
 */

const fs = require('fs');
const path = require('path');

// [2026-09-10 task-planrequired-race] session_id 提取：stdin JSON `.session_id`（zcode 保证 SessionStart 携带，
// S1 取证 zcode.cjs:2702），env TASK_PLANNER_SID 降级（zcode-sessionstart.sh 由 stdin 提取后透传）。
// 手工运行无 stdin / JSON 损坏 → fail-open，sid 缺失不写任何哨兵。
let sid = '';
try {
  let raw = '';
  try {
    raw = fs.readFileSync(0, 'utf8');
  } catch (e) {
    // 无 stdin（如手工 `node task-plan-init.cjs` 重定向自 /dev/null 亦为可读空流；pipe closed 等场景）→ 留空
  }
  try {
    const j = JSON.parse(raw);
    if (j && typeof j.session_id === 'string' && j.session_id) sid = j.session_id;
  } catch (e) {
    // 非 JSON（手工运行、空输入）→ 降级 env
  }
} catch (e) {
  // fail-open
}
if (!sid) sid = process.env.TASK_PLANNER_SID || '';

// [2026-09-10 task-planrequired-race] normSidkey（D8）：剥非字母数字取前 40；`sess` 前缀剥掉，
// canonical = uuid core，与 set-active-plan.sh norm_sid / /tmp 状态文件命名空间对齐。
function normSidkey(s) {
  let k = String(s).replace(/[^a-zA-Z0-9]/g, '').slice(0, 40);
  if (k.startsWith('sess')) k = k.slice(4);
  return k;
}

const sidkey = normSidkey(sid);
if (!sidkey) {
  console.log('[task-plan] ⚠ 未提取到 session_id（stdin 无 .session_id 且 TASK_PLANNER_SID 未设）→ 跳过哨兵写入（fail-open）');
  process.exit(0);
}

// [2026-09-10 task-planrequired-race] 项目根解析（D2，对齐 plan-created.cjs findProjectRoot）：
// 从 CWD 向上 ≤10 级找含 plans/ 子目录的祖先；找不到 → 不写哨兵（无项目则无拦截语义，根除 B2 写串位置）。
function findProjectRoot() {
  let dir = process.cwd();
  for (let i = 0; i <= 10; i++) {
    if (fs.existsSync(path.join(dir, 'plans'))) return dir;
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return null;
}

const root = findProjectRoot();
if (!root) {
  console.log('[task-plan] ⚠ 未找到含 plans/ 祖先的项目根（向上 10 级）→ 不写哨兵（fail-open）');
  process.exit(0);
}

// 会话私有 side 哨兵：plans/.plan_required_side/<sidkey>.plan_required，tmp+renameSync 原子写（对齐 set-active-plan 模式）
const SIDE_DIR = path.join(root, 'plans', '.plan_required_side');
const SENTINEL_PATH = path.join(SIDE_DIR, sidkey + '.plan_required');

// 幂等写入：内容带时间戳，始终刷新（原行为保留于会话私有维度）
try {
  fs.mkdirSync(SIDE_DIR, { recursive: true });
  const now = new Date();
  const content = `plan-required\ncreated: ${now.toISOString()}\ncreated_epoch: ${now.getTime()}\ncwd: ${root}\n`;
  const tmp = path.join(SIDE_DIR, `.${sidkey}.plan_required.tmp`);
  fs.writeFileSync(tmp, content, { encoding: 'utf-8' });
  fs.renameSync(tmp, SENTINEL_PATH);
  console.log('[task-plan] 🚨 哨兵已写入(会话私有): ' + SENTINEL_PATH);
  console.log('[task-plan] 触发条件（命中任一需调用 Skill("task-planner")）：');
  console.log('[task-plan]   - 修改 ≥3 个文件');
  console.log('[task-plan]   - 跨多阶段流程');
  console.log('[task-plan]   - 预计耗时 > 10 分钟');
  console.log('[task-plan]   - 边界模糊 / 高风险 / 用户未说"简单"');
  console.log('[task-plan] 初始化命令:');
  // [2026-08-28] 修复:提示语路径改指本 skill 的 zcode 副本(原为 ~/.claude,与 ZCode 实际加载路径不一致)
  console.log('[task-plan]   mkdir -p plans/task-{id}/ && cd $_ && bash ~/.zcode/skills/task-planner/scripts/init-session.sh');
  // [2026-09-10 task-planrequired-race] 哨兵位置说明：不再写 <CWD>/.plan-required，改会话私有 side 哨兵（B1-B4 竞态根除）
  console.log('[task-plan] 哨兵位置: ' + SENTINEL_PATH + '（会话私有；legacy <CWD>/.plan-required 不再写入）');
} catch (e) {
  console.log('[task-plan] ⚠ 写入哨兵失败: ' + e.message);
}

// [2026-09-10 task-planrequired-race · CR P0 修正后] resume 判定：仅当本会话 side 指针
// （由 set-active-plan --sid / init-session 等显式为本会话写入）指向存在 task_plan.md 的
// 有效计划时，视为"带计划恢复"，撤掉刚写的哨兵。【不读全局 legacy、不做盲 adoption】——
// 否则活跃仓里全局指针恒有效 → 任何新会话启动即撤哨兵（VC-2 保护回归，Code Review 2026-09-10）。
// 指针缺失 → 哨兵保留；解除路径 = 创建计划后 init-session 置全局指针（D10' 解析命中）或 plan-created。
try {
  const sidePlan2 = path.join(root, 'plans', '.active_plan_side', sidkey + '.active_plan');
  let planId = '';
  if (fs.existsSync(sidePlan2)) {
    planId = fs.readFileSync(sidePlan2, 'utf8').trim();
  }
  if (planId && !planId.includes('/') && planId.includes('task-')) {
    const planFile = path.join(root, 'plans', planId, 'task_plan.md');
    if (fs.existsSync(planFile)) {
      fs.rmSync(SENTINEL_PATH, { force: true });
      console.log('[task-plan] ✓ 本会话已有有效计划(' + planId + ')，哨兵不启用（resume 判定）');
    }
  }
} catch (e) {
  // resume 判定失败不阻塞会话（哨兵保守保留）
}

process.exit(0);
