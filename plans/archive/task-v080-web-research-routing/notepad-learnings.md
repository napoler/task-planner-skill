# Task Learnings: task-v080-web-research-routing

## New Requests
- 2026-09-17 用户指令：优化当前技能——调研网络访问时使用 browser-use 插件 + research-assistant 完成网络调研/网页访问，确保 ZCode 中优先使用平台适配工具。范围=task-planner 技能文本路由显式化，纯增量。

## What Worked
- spawn 失效时按 22.3 优先级兜底（①改派→③降档→穷尽→④接管）且**接管前先修订计划**（Executor 例外理由+Decisions），机器统计 verdict=ok 零违规
- 主仓副本跑 smart-merge-back --deploy（v077 教训直接复用）：首次 .zcode 位 REJECTED（运行位自保护）→ 主仓副本重跑即三位 IDENTICAL
- attest 前置机器门两次拦下计划笔误（S-unit ID 格式/FMEA 列口径/template_type 位置）——门控比人可靠，修计划而非绕过

## What Didn't Work
- [假设未验] 假设「Explore(haiku-1) 成功 → code-assistant(haiku-1) 也可启动」——实际会话级思考档位选择在会话中途整体丢失，四档位四类型 4 连败；教训：spawn 失败后不要以「同档位曾成功」推断可用，每轮执行体选择前先试 spawn 或直接走接管链
- [规则缺位] skill-modify/delegation 守卫在 worktree 内解析不到主仓 plans/ 授权表 → warn 假阳性（本任务靠 warn 档放行）；若遇 enforce 档会在合规场景误拦
- [信息缺失] plan-writer/general-purpose/Simple Agent/Code Assistant 的 frontmatter 均未声明思考档位，依赖会话级选择——环境态丢失即全灭

## 🚫 被否决方案（User Rejected — Rule 32）
-（本任务无用户否决记录；禁令源经查均为空）

## Files Modified
- skills/task-planner/SKILL.md（+2：L458 链注记+平台适配声明；路由表+1 行）
- skills/task-planner/references/skill-collaboration.md（+2：§二矩阵 research-assistant/browser-use 行）
- skills/task-planner/scripts/selftest-skill-collab.sh（+6 断言 T11a-d/T12a-b）
- skills/task-planner/scripts/selftest-knowledge-brief.sh（T2b 545→548）
- CHANGELOG.md（+1 条目）

## Verification Results
- Verified: 全量 21 selftest 355 PASS/0 FAIL（worktree+master 双跑）；3 部署位 diff -r IDENTICAL 亲验；merge 2a2df8f；删除行恰=2 允许项（纯增量）
- Failed: 无（.zcode 位首次部署 REJECTED 已按替代路径闭环）

## 📚 必要知识储备备注
- 本次新发现的知识源: 无新增（现有宪法 §七/§十 足够支撑路由语义）
- 值得入库的书目/文献: —
- 待补齐的知识缺口: agent frontmatter 思考档位（thoughtLevel）缺失导致 spawn 全灭的根因在 harness 侧，本仓不可修，登记为环境依赖风险

## Notes for Next Time
- 触发条件=会话中 Agent spawn 报 reasoning-level-missing → 防线：立即按 22.3④ 接管并修订计划登记白名单理由，禁止反复重试同档位（本任务 4 连败后 0 重试，一次到位）
- 触发条件=worktree 内编辑技能文件被 skill-modify/delegation 守卫 warn「未授权」 → 防线：先查授权表在主仓 plans/（worktree 解析不到=假阳性），warn 放行可继续，enforce 档需回主仓跑或登记 sid
- 触发条件=smart-merge-back --deploy 报 .zcode 位 REJECTED（运行位自保护） → 防线：改用主仓副本 scripts/smart-merge-back.sh 重跑（ALREADY_MERGED 门自动跳过合并只补部署）
- 触发条件=attest 拒锁 S-unit/FMEA/template_type → 防线：数据行 ID 须 `| S<纯数字> |`；template_type 须 YAML frontmatter `^template_type:`；FMEA 表须 7 列（$7=RPN 纯数字、$8=兜底非空）
