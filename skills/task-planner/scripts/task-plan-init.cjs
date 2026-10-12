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
// [task-perf-opt Change #2] 轻量档关键词检测：SessionStart hook 的 stdin 是否含 prompt 字段
//   无法从技能仓代码确认（取决于 ZCode 平台 hook 输入格式）。本处对多种可能字段名尽力提取
//   （.prompt / .user_prompt / .message / .content），命中轻量档关键词（简单/简单修复/就改一行/
//   改一下/fix/typo）→ 输出「用户已声明轻量档」提示行；读不到 prompt（SessionStart 早于首条用户
//   消息，或平台不携带）→ fail-open 留空，不误判、不阻断。跨 hook 通信替代机制（UserPromptSubmit
//   写标记 → PreToolUse 读）见 Change #5 注释；本处仅做「读得到才用」的无副作用前置检测。
const LIGHTWEIGHT_KW = ['简单修复', '就改一行', '改一下', '简单', 'fix', 'typo'];
let promptText = '';
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
    // 多字段名尽力提取 prompt（平台 hook 输入格式未定，读得到才用；全缺 → promptText 留空 fail-open）
    const cand = [j && j.prompt, j && j.user_prompt, j && j.message, j && j.content];
    promptText = cand.find((x) => typeof x === 'string' && x.length > 0) || '';
  } catch (e) {
    // 非 JSON（手工运行、空输入）→ 降级 env
  }
} catch (e) {
  // fail-open
}
// 轻量档命中判定：promptText 非空且含任一关键词（「简单修复」等变体亦命中，修复「简单修复≠简单」触发倒置）
const lightweightHit = promptText !== '' && LIGHTWEIGHT_KW.some((kw) => promptText.includes(kw));
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
  // [task-perf-opt Change #2] 触发条件④从「用户未说『简单』」扩展为「用户未声明轻量档」——
  // 命中变体「简单修复 / 就改一行 / 改一下 / fix / typo」亦不触发 task-planner（修复「简单修复≠简单」触发倒置根因 #2）
  console.log('[task-plan]   - 边界模糊 / 高风险 / 用户未声明轻量档（"简单"/"简单修复"/"就改一行"/"改一下"/"fix"/"typo"）');
  if (lightweightHit) {
    // [task-perf-opt Change #2③] 用户已声明轻量档 → 跳过 task-planner 触发提示（fail-open：promptText 非空才可能命中）
    console.log('[task-plan] ✅ 用户已声明轻量档（检测到「' + LIGHTWEIGHT_KW.find((kw) => promptText.includes(kw)) + '」），跳过 task-planner 触发提示');
  }
  console.log('[task-plan] 初始化命令:');
  // [2026-08-28] 修复:提示语路径改指本 skill 的 zcode 副本(原为 ~/.claude,与 ZCode 实际加载路径不一致)
  console.log('[task-plan]   mkdir -p plans/task-{id}/ && cd $_ && bash ~/.zcode/skills/task-planner/scripts/init-session.sh');
  // [2026-09-10 task-planrequired-race] 哨兵位置说明：不再写 <CWD>/.plan-required，改会话私有 side 哨兵（B1-B4 竞态根除）
  console.log('[task-plan] 哨兵位置: ' + SENTINEL_PATH + '（会话私有；legacy <CWD>/.plan-required 不再写入）');
} catch (e) {
  console.log('[task-plan] ⚠ 写入哨兵失败: ' + e.message);
}

// [2026-10-07 fix-pointer-race RC-2] sidmap 确定性映射落盘:env CLAUDE_CODE_SESSION_ID 与 hook sid
// 是两套命名空间时,下游 init-session.sh / plan-created.cjs 靠 <env_sidkey>.sidmap 找到本会话
// hook sidkey,替代"抢最新哨兵"猜测(多会话并发下=抢他会话命名空间,指针抢占事故根因)。
// 仅 env 存在且与 hook sidkey 不同才写;原子写(fail-open,失败仅告警不阻断会话)。
try {
  const envSid = process.env.CLAUDE_CODE_SESSION_ID || '';
  const envKey = normSidkey(envSid);
  if (envKey && envKey !== sidkey) {
    const mapPath = path.join(SIDE_DIR, envKey + '.sidmap');
    const mapTmp = path.join(SIDE_DIR, `.${envKey}.sidmap.tmp`);
    fs.writeFileSync(mapTmp, sidkey + '\n', { encoding: 'utf-8' });
    fs.renameSync(mapTmp, mapPath);
    console.log('[task-plan] sidmap 已写: ' + mapPath + ' (env=' + envKey + ' → hook=' + sidkey + ')');
  }
} catch (e) {
  console.log('[task-plan] ⚠ sidmap 写入失败(fail-open): ' + e.message);
}

// [2026-09-10 task-planrequired-race · CR P0 修正后] resume 判定：仅当本会话 side 指针
// （由 set-active-plan --sid / init-session 等显式为本会话写入）指向存在 task_plan.md 的
// 有效计划时，视为"带计划恢复"，撤掉刚写的哨兵。【不读全局 fallback、不做盲 adoption】——
// 否则活跃仓里全局 fallback 恒有效 → 任何新会话启动即撤哨兵（VC-2 保护回归，Code Review 2026-09-10）。
// 指针缺失 → 哨兵保留；解除路径 = 创建计划后 init-session 置全局 fallback（D10' 解析命中）或 plan-created。
// [2026-10-10 task-v164] 退役原"全局单例指针"叙事：plans/.active_plan 现为工作树内瞬态 fallback
//   （路径随 $PWD 本地化；git rm --cached + .gitignore 同族瞬态，非入库单例）；
//   正常路径 = side 会话私有指针（权威层）。
try {
  // [2026-10-07 fix-pointer-race RC-1] resume 判定双命名空间读(剥前缀 miss 回查 sess<sidkey> 形态,
  // 对齐 resolve-plan-dir.sh 兼容读;历史写入方曾以裸 sid 落盘,单读会误判"无计划"→哨兵误启用)
  const sideDir2 = path.join(root, 'plans', '.active_plan_side');
  let sidePlan2 = path.join(sideDir2, sidkey + '.active_plan');
  if (!fs.existsSync(sidePlan2)) {
    sidePlan2 = path.join(sideDir2, 'sess' + sidkey + '.active_plan');
  }
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
