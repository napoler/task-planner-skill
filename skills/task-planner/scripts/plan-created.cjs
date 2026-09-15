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

// task-v065/V-7 [2026-09-13] side 指针 sid 来源扩展: 手工/子代理场景 CLAUDE_CODE_SESSION_ID
// 可能缺失, 补 ZCODE_SESSION_ID → CLAUDE_SESSION_ID → 会话 UUID(取法对齐 attest-plan.sh V-8);
// sidkey 取法不变(仍 normSidkey canon, 与 resolve-plan-dir.sh / task-plan-init.cjs 一致)
if (!sid) sid = process.env.ZCODE_SESSION_ID || process.env.CLAUDE_SESSION_ID || '';

// [2026-09-10 task-planrequired-race] canon 与 task-plan-init.cjs 完全一致（findings D8）：
// 剥非字母数字取前 40，再剥 sess 前缀 = uuid core。
function normSidkey(s) {
  let k = String(s).replace(/[^a-zA-Z0-9]/g, '').slice(0, 40);
  if (k.startsWith('sess')) k = k.slice(4);
  return k;
}
// [2026-09-16 task-v074 P10 sid 哨兵探测 fallback] 在 PLANS_DIR 算出后调用。
const SIDKEY0 = normSidkey(sid);
// 探测延迟到 projectRoot/PLANS_DIR 确定后执行（见下方 sentinelFallbackSidkey 调用）

const projectRoot = findProjectRoot(process.cwd());
const PLANS_DIR = path.join(projectRoot, 'plans');

// [2026-09-16 task-v074 P10 sid 哨兵探测 fallback] 动机：env CLAUDE_CODE_SESSION_ID 与 hook
// stdin .session_id 是两套命名空间（SessionStart 哨兵用 hook sid 写，plan-created 用 env sid 清 →
// 指针/哨兵错位，findings P1-2 实锤 env 133bb… vs hook sess038d…）。当既有 sidkey 无对应哨兵文件时，
// 探测 <root>/plans/.plan_required_side/ 下 mtime 最新的 *.plan_required，取其文件名 stem 为
// sidkey（SessionStart 在会话启动时刚写入 = 本会话真实 sid 的落地物）。
// 多会话并发局限：最新 mtime 的启动会话优先，属已知取舍。
// 语义红线：env sid 有对应哨兵时行为完全不变（仅探测不到才 fallback）。
function sentinelFallbackSidkey(primaryKey) {
  if (primaryKey && fs.existsSync(path.join(PLANS_DIR, '.plan_required_side', primaryKey + '.plan_required'))) {
    return primaryKey; // env sid 命中哨兵 → 维持现状
  }
  const dir = path.join(PLANS_DIR, '.plan_required_side');
  if (!fs.existsSync(dir)) return primaryKey; // 目录无哨兵 → 维持现状
  let latest = '';
  let latestMt = 0;
  let entries = [];
  try { entries = fs.readdirSync(dir); } catch (e) { entries = []; }
  for (const f of entries) {
    if (!f.endsWith('.plan_required')) continue;
    let mtMs = 0;
    try { mtMs = fs.statSync(path.join(dir, f)).mtimeMs; } catch (e) {}
    if (mtMs > latestMt) { latestMt = mtMs; latest = f; }
  }
  if (!latest) return primaryKey;
  const altKey = normSidkey(latest.slice(0, -'.plan_required'.length));
  if (altKey && altKey !== primaryKey) {
    console.log('[task-plan] INFO: env sidkey(' + (primaryKey || '(空)') + ') 无对应哨兵,fallback 最新哨兵 sidkey(' + altKey + ')');
    return altKey;
  }
  return primaryKey;
}
const sidkey = sentinelFallbackSidkey(SIDKEY0);

// 验证：限定「当前会话活跃计划」，口径对齐 resolve-plan-dir.sh 解析链
// (task-v065/V-7 [2026-09-13]：原逻辑=「readdirSync 首个含 task_plan.md 的目录即有效」，
//  32 个历史计划下永不 exit 1——实证误认 task-3file-enforce；
//  现按 ① env TASK_PLANNER_PLAN_DIR ② plans/.active_plan_side/<sidkey>.active_plan(会话指针,
//  sidkey 取法与上方 normSidkey 一致;TTL 24h) ③ legacy plans/.active_plan 指针
//  ④ mtime 最新(跳过 archive 前缀/隐藏/非 slug 目录) 逐层解析，
//  仅当解析出的活跃计划含 task_plan.md 才 planFound=true)
function isValidSlug(name) {
  return /^[A-Za-z0-9_.-]+$/.test(name);
}
let planFound = false;
let planPath = '';
let planSource = '';
if (fs.existsSync(PLANS_DIR)) {
  // ① env 显式指定优先
  const envDir = process.env.TASK_PLANNER_PLAN_DIR;
  if (envDir && fs.existsSync(path.join(envDir, 'task_plan.md'))) {
    planFound = true;
    planPath = path.join(envDir, 'task_plan.md');
    planSource = 'env TASK_PLANNER_PLAN_DIR';
  } else {
    // ②③ 会话指针 → legacy 指针（TTL 24h 与 resolve-plan-dir.sh 对齐）
    const pointerCandidates = [];
    const sideDir = path.join(PLANS_DIR, '.active_plan_side');
    // sidkey 有值 → 只查本会话 side 文件(与 resolve-plan-dir.sh 口径一致: 查 <sidkey>.active_plan 单文件);
    // sidkey 为空(未取到任何会话 id) → 枚举目录下全部 *.active_plan(手工/子代理场景, 取 TTL 内任一指向有效计划的)
    if (sidkey) {
      pointerCandidates.push({ file: path.join(sideDir, sidkey + '.active_plan'), label: '会话指针 .active_plan_side' });
    } else if (fs.existsSync(sideDir)) {
      try {
        for (const f of fs.readdirSync(sideDir)) {
          if (!f.endsWith('.active_plan')) continue;
          pointerCandidates.push({ file: path.join(sideDir, f), label: '会话指针 .active_plan_side(枚举)' });
        }
      } catch (e) { /* side 目录不可读视为无效 */ }
    }
    pointerCandidates.push({ file: path.join(PLANS_DIR, '.active_plan'), label: 'legacy 指针 .active_plan' });
    const nowMs = Date.now();
    for (const pc of pointerCandidates) {
      if (!fs.existsSync(pc.file)) continue;
      let mtMs = 0;
      try { mtMs = fs.statSync(pc.file).mtimeMs; } catch (e) {}
      if (nowMs - mtMs > 24 * 3600 * 1000) continue; // 会话已结束, 指针不再生效
      let pid = fs.readFileSync(pc.file, 'utf8').replace(/[ \r\n\t]/g, '');
      if (!isValidSlug(pid)) continue; // 拒路径穿越/腐烂指针
      const cand = path.join(PLANS_DIR, pid, 'task_plan.md');
      if (fs.existsSync(cand)) {
        planFound = true;
        planPath = cand;
        planSource = pc.label + ' → ' + pid;
        break;
      }
    }
    // ④ mtime 最新（口径对齐 resolve-plan-dir.sh：跳过 archive 前缀/隐藏/非 slug 目录）
    if (!planFound) {
      let latest = '';
      let latestMt = 0;
      for (const entry of fs.readdirSync(PLANS_DIR)) {
        if (entry.startsWith('archive') || entry.startsWith('.')) continue;
        if (!isValidSlug(entry)) continue;
        const cand = path.join(PLANS_DIR, entry, 'task_plan.md');
        if (!fs.existsSync(cand)) continue;
        const mt = fs.statSync(cand).mtimeMs;
        if (mt > latestMt) { latestMt = mt; latest = cand; }
      }
      if (latest) {
        planFound = true;
        planPath = latest;
        planSource = 'mtime 最新';
      }
    }
  }
}

// 活跃计划未解析到 → 保留原警告文案风格 + exit 1（拒绝无计划清除的保护语义）
if (!planFound) {
  console.log('[task-plan] ⚠ 未找到当前会话的有效活跃计划，无法清除哨兵。');
  console.log('[task-plan] 解析链: env TASK_PLANNER_PLAN_DIR → .active_plan_side/<sid>.active_plan → .active_plan → mtime 最新（均未含 task_plan.md）');
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
  // [task-v068 E1'/KQ1] 无 sid 兜底清除：枚举 .plan_required_side 下全部 <sidkey>.plan_required，
  // 仅当 .active_plan_side/<sidkey>.active_plan 不存在（无认领）或 mtime>24h（过期）才删；
  // 活跃指针存在且 <24h 的哨兵保留并打印原因（原零日志缺陷修复）。
  const SIDE_SIDE = path.join(PLANS_DIR, '.plan_required_side');
  const SIDE_PTR = path.join(PLANS_DIR, '.active_plan_side');
  const nowMs = Date.now();
  let removed = 0;
  if (fs.existsSync(SIDE_SIDE)) {
    let entries = [];
    try { entries = fs.readdirSync(SIDE_SIDE); } catch (e) { entries = []; }
    const kept = [];
    for (const f of entries) {
      if (!f.endsWith('.plan_required')) continue;
      const sk = f.slice(0, -'.plan_required'.length);
      const ptr = path.join(SIDE_PTR, sk + '.active_plan');
      let ptrStale = false;
      // [task-v068 fix-B P2-1] 循环内 existsSync(ptr) 原本三次调用, 缓存一次:
      // unlink 后 existsSync 恒 false 导致误打「无活跃指针认领」, 现按 unlink 前快照输出真实原因
      const ptrExists = fs.existsSync(ptr);
      if (ptrExists) {
        let mtMs = 0;
        try { mtMs = fs.statSync(ptr).mtimeMs; } catch (e) {}
        ptrStale = (nowMs - mtMs) > 24 * 3600 * 1000;
      }
      const sp = path.join(SIDE_SIDE, f);
      if (ptrExists && !ptrStale) {
        kept.push(f + '（活跃指针存在且 <24h，保留）');
        continue;
      }
      fs.unlinkSync(sp);
      removed++;
      console.log('[task-plan] ✓ 兜底清除无 sid 会话哨兵: ' + sp + '（' + (ptrExists ? '指针 mtime>24h 过期' : '无活跃指针认领') + '）');
    }
    if (kept.length) {
      for (const k of kept) console.log('[task-plan] ⚠ 保留侧哨兵 ' + k);
    }
  }
  if (removed === 0) {
    console.log('[task-plan] ✓ 无残留哨兵需兜底清除（未提取到 session_id，fail-open 兜底已执行）');
  }
}

// D10 说明：拦截侧（check-scope）为 check-time 仲裁——若存在晚于哨兵 created 的项目内
// task_plan.md 会自动放行；本脚本是显式即时清除 + 存在性校验（模型侧主动调用）。
// [task-v068 E1'] 文案诚实化：上方「✓ 有效计划确认」仅指计划解析成功，不代表哨兵一定被清
// （无 sid 兜底或 legacy 仲裁可能保留），清除结果以本段各行为准。
console.log('[task-plan] ✓ 有效计划确认（' + planSource + '）: ' + planPath);
console.log('[task-plan] 可正常执行写入操作。');
process.exit(0);
