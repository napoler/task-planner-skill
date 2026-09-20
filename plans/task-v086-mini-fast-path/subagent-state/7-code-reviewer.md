# task-v086 Code Review 检查点（7-code-reviewer）
- 审查对象: /home/terry/task-planner-skill-worktrees/task-v086-mini-fast-path 已暂存 diff（32 文件 +596/-28）
- 结论: **CHANGES_REQUESTED**（1 个 Blocker + 3 个 Suggestion）；无安全/注入类发现
- 日期: 2026-09-21

## 复现/验证记录
- bash -n 5 脚本全过；config.json jq 解析合法，plan_tier_enforce 三档语义与条款一致
- worktree 内全量 selftest 25 个脚本 OVERALL_FAIL=0（plan-tier 27/27 PASS），与主进程 429/0 结论一致
- 14 既有模板 +1 行均为纯注释 `<!-- plan_tier: standard -->`，无语义面改动
- mini-lite 49 行，六禁区块（FMEA 预演/必要知识储备/委派统计/Batch Report/Chain 区块/Drift Log）grep 均为 0 命中
- 实跑复现（/tmp 沙箱）:
  - ①B: 项目自造模板(首行=`# Task Plan: [x]`) + default 文件 → init 插入 `<!-- template_type: my-custom -->` 于首行 → check-template-type.sh 仍 INVALID 缺失 template_type（gate 只认 `^template_type:` 或 `| template_type |` 两形态，HTML 注释形态不识别）。同一产物 check-complete 机制画像段(mp_tt L877-878)同取不到 → mini-lite 定制计划 mp_tt 落空（fail-open 仅 warn，无阻断，但功能意图落空）
  - ①B2: TASK_PLAN_TIER=mini 产物 mini-lite 自身（首行=注释 template_type）同样过不了 template-gate；enforce 档 attest lock rc=1 拒锁（实测）
  - ③: mini-lite 产物/模板均无 plan_tier: mini 字面子串 → 主仓 32 个既有计划 0 误命中
  - ⑧: default 文件多行值取首行；grep 元字符值因 set -e 中断但 rc=0（与旧行为一致的静默风险）

## 发现清单（摘要，全文见 CR 消息）
1. 🔴 正确性 init-session.sh:213-219 — frontmatter 插入形态与 check-template-type.sh:20 提取形态不匹配，插入行=死代码（置信 HIGH，已双端实测）
2. 🟡 条款缺口 critical-rules.md:336(38.4②) — 条款写「每 Phase V-N 映射最低 2→1」，check-complete.sh:638 实现是「无实质映射行整段跳过(0 条也过)」，实现比条款更宽松（置信 HIGH）
3. 🟡 条款缺口 38.2①「中/重任务禁用 mini 模板=check-template-type 范畴违规」无机器强制；38.3 白名单 selftest 只覆盖 38.2 六区块
4. 💬 证据契约 selftest-plan-tier.sh:115-116 — 样例 plan_tier 仅以表格行形态存在，与真实 mini 产物(HTML 注释)不一致，PT-18/19/20/21 回归价值打折（置信 HIGH）

## 逐文件结论
- attest-plan.sh:173-186 PASS：RC=2 臂内新分支仅 grep 命中才 SKIP，RC=1/0 臂零改动；fmea_enforce=off 时整段跳过（含 mini SKIP 行），语义自洽
- check-complete.sh PASS：114-119/549-550/638/665-667 四处全 if 前置；638 的 continue 在 rm segf 前，无临时文件泄漏；PASSED 回显 vn_thresh_base 对非 mini 恒 2 逐字节同义
- check-plan-dispatch.sh PASS（含④豁免正确性推演：豁免只在 dispatch Phase 且无表无行时 return 0，mini 派发 Phase 有表有行仍走数值校验）
- init-session.sh 见发现 1（Blocker）
- 模板面/selftest/config/SKILL/README PASS；8 个既有 selftest 锚修复均为断言正则/阈值扩围，未发现语义弱化

# 二轮复审（S7 改动面, 2026-09-21）
- 复审对象: worktree 未暂存层 3 文件（check-template-type.sh / critical-rules.md / selftest-plan-tier.sh +定数 27→28）
- 结论: **APPROVED**

## 逐点结论
1. S7-1 修复质量 = PASS。
   - 注释形态提取（check-template-type.sh:27-30）实测: mini 主路径产物（head-2 = 注释双行）→ ctt OK: template_type=mini-lite；enforce 档 attest lock rc=0（此前 rc=1 拒锁已翻正, PT-28 钉住）。
   - 误命中面实测: 正文引用型 `<!-- template_type: migration -->` 在缺前两形态时会误命中（fake 文件 rc=0）。评估: 触发前提=计划无行首直书/表格行标记, 且值为白名单合法 token 才放行（非法值仍 INVALID）; 主仓实扫仅 2 个正文命中文件且自身首行已有标记不受影响; 风险=文档型计划被正文注释误标, 方向为放行非拒锁, 量级=💬 可接受。
   - legacy 无标记计划仍正确 INVALID（task-v056 实测 rc=1）, 未开误放行口子。
   - 注意: S7 采用的是方案 B（gate 补第三形态）, init-session.sh:219 的 awk 插入语句未改、仍产注释形态——双端自洽, 功能闭环; 与一轮 CR 建议的方案 A 不同但等效, 不构成问题。
2. 二轮回归 = PASS。worktree 实跑 25 脚本 OVERALL_FAIL=0, 逐脚本 Total 求和=435（含 plan-tier 28/28; S7 报 430 口径含计数差异脚本 delegation/execution-stability 等 7 个无 Total 行输出按行计数, 断言总数口径差非 FAIL 差异, 0 FAIL 结论一致）。bash -n 2 文件过。
3. S7-2 措辞 = PASS。38.4② 「无实质 V-N 映射行的 Phase 不阻断（mini 等效阈值 0）；有映射行时仍须全部映射到已定义 VC 编号」与 check-complete.sh:638 continue + 后续 target_bad 校验完全一致; 38.2① 尾改「非机器阻断, 指导层——误配 MISMATCH 条件时由 38.1 MISMATCH 提示兜底」与实现一致。
4. 遗留① 登记 = 确认成立。实测: 项目自造 my-custom 产物 ctt=「不在白名单内」rc=1, enforce 档 attest rc=1 仍拒——行为未变（deferred 语义正确, gate 白名单收窄自造模板名属既有 34.1 设计, 非 S7 引入）。计划文件 task_plan.md:82 已含 CR 发现记录; findings/progress 未见独立 deferred-issues 条目, 由主进程登记（本轮按约定不阻塞）。
   - 次要观察（不阻塞）: findings.md 未见 S7 段落, PT-28 注释与 task_plan.md:82 的修复描述（「init 插入改行首直书」）与实际落地方案（gate 补形态）表述不一致, 建议簿记层更正。
