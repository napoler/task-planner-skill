# S26 A-3 drift-check 合并 — checkpoint
status: complete
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091 (branch wt/task-v091-efficiency-optimization)
base HEAD: 3cdab78 (进场核对: rev-parse HEAD=3cdab78c2cca65acadb9edf6352658e750cd05d3, status clean)

## 改动清单（36.4 四项删除全部在位）
1. SKILL.md:102 一带：步骤 6 [DRIFT CHECK] 保留 `Skill("task-drift-guard")` 为同点唯一检测载体，C4 改写为 skill 调用+三态契约（ALIGNED/DRIFT/BLOCKED→STOP，critical-rules Rule 11/15 条款原文零改动）；删除 C4a 行（`check-drift.sh --json` 强制双跑项，降为可选佐证）——drift 双跑删一 完成
2. SKILL.md:107：删除 PLAN-RESUME 被动扫描段（每 Phase complete 调用），C13 改写为「交付终态/会话恢复触发点按 Rule 24.5 自主续推 Top 1」；Chain 交接第 5 步同步收敛；SKILL 摘要行 Rule 24 同步改写——plan-resume 移位 完成
3. C 表改写：C4（去 C4a）/C5-C18/C19-C27 每项标注机器门承载（check-complete 3-File Gate/VC 逐条/终态判定/Learning Gate/REFLECT-GATE/porcelain 预检/check-3file-gate/check-skill-modify/check-template-type 等）或「人工保留不收敛」（C15 质量违规核查、C20 veto 禁令核查、C10-C12/C18 判定与复述、C23 三关、C25 画像）；C19/C20/C24/C27 的 N/A/PASS 强制记行尾条款全部删除（改为条件触发式「未命中则无需记行」）——N/A 记行删除 完成
4. critical-rules.md Rule 15：行内增注「该 skill 调用为漂移检测同点唯一载体，check-drift.sh 降为可选佐证不双跑，三态契约零改动」
5. critical-rules.md Rule 24：增 A-3 触发点收敛注释段（「每 Phase complete」→「交付终态/会话恢复」两类）+24.1 行内尾注；24.2-24.7 守卫条款与 v0.5 行为契约零改动

## 行数登记
SKILL.md: 558 → 556（净 -2，≤558 断言 PASS）
critical-rules.md: 367 → 368（净 +1，注释性增行，非行数断言对象）

## selftest 锚核对（10 个受影响清单全跑）
- selftest-veto.sh Total 13 PASS=13（'| C20 |' 命中，锚保留）
- selftest-error-loop.sh Total 16 PASS=16（'| C19 |'+Rule 31 命中）
- selftest-skill-modify.sh Total 9 PASS=9（'| C24 |' 命中）
- selftest-plan-tier.sh Total 32 PASS=32（'^| C26 ' 行首锚命中）
- selftest-workflow-orchestration.sh Total 16 PASS=16（'| C27 |' 命中）
- selftest-conclusion-discipline.sh Total 24 PASS=24（'| C23 |' 命中）
- selftest-mechanism-profile.sh Total 19 PASS=19（'^| C25 '+Rule 37 命中）
- selftest-reflect-verify.sh Total 12 PASS=12（'^| C21 ' 命中）
- selftest-task-boundary.sh Total 11 PASS=11（'| C12 |'+D/A/B/C 命中）
- selftest-template-lifecycle.sh Total 18 PASS=18（'^| C22 ' 命中）
- 冲突项：无（全部锚 token 兼容，S27 统一核对无需修订项；唯一被删 token = C4a 行，grep 实证无任何 selftest 锚定 C4a）
- 抽跑：selftest-batch-pilot.sh Total 10 PASS=10（BP-08 行数 556≤558）；selftest-skill-collab.sh Total 25 PASS=25

## compass 误报评估结论
A-3 删除 N/A/PASS 形式化记行 + B-2 单写者条款（后续步骤）使 findings/progress 写入密度下降，而 [plan-compass] 提醒阈值（zcode-posttooluse.sh:findings_stale_minutes=20/progress_stale_minutes=25 硬编码默认，config.json 键存在）为 mtime 型判定——长间隔自然工作（派发/验收 Read 不写三文件）期间更易触发误报与 compass_escalate_after=2 升级链。处置=最小方案：保留阈值与升级链不变、不扩大改动面（不切 ledger 信号源），误报面以 C 表删 N/A 记行 + 19.7 既有「回填后自然进入冷却」条款对冲；登记待观察项 → S27/终审 #9 复核（若误报频次上升再议信号源切 ledger）。

## 三态契约核验
ALIGNED→继续 / DRIFT→记录 progress 警觉继续 / BLOCKED→STOP 等决策：SKILL.md 步骤 6 原文保留 + C4 改写行内复核 + Rule 15 行内增注「零改动」标注；Rule 11（critical-rules）未触碰。

## 零触碰核验
Rule 21.4/Rule 26/Rule 24.2-24.7 守卫/v0.5 行为契约/10 个 selftest 文件均未改动（diff --stat 仅 SKILL.md+critical-rules.md 两文件）。

## commit
53ff783 refactor(task-planner): task-v091/S26 A-3 — 每 Phase 重复检测合并（SKILL 三处+Rule 15/24 同步）
（分支 wt/task-v091-efficiency-optimization，worktree 内提交）
