# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

#### [sub:1-executor] 记忆盘点
- 盘点范围:MEMORY.md 90 行/57 条索引全量+A 类 16 条(强时效断言)全读+B 类 15 条抽查(≥8 达标)+C 类 26 条免检登记
- 过时风险清单 33 条(逐条四维+处置+证据):全量清单落 `plans/task-v109/subagent-state/1-executor.md` 里程碑 2/3/4 节
- 高危 2 条:A1 `task-planner-repo-deploy-flow`(正文 09-16 基线后未追加,实测 zcode 位 28 variant vs claude/opencode 16=videop1 双向分叉实锤 diff -rq zcode 20+ 文件 differ/claude 23 行,与 v108 遗留「部署待裁决」一致,处置=updated);A16 `task-v091`(「33 脚本 525/0 基线」被实测 43 脚本 655/0 替代,处置=stale-marked 标注 superseded)
- B 类 15 条:14 verified+1 stale-marked(`task-v056`「master 领先 origin 7 未 push」时点声明失效,遗留已由 v057 清账);规则号锚抽查全在位(grep 21.4=7/19.5=1/session-catchup.ts 仓内存在/仓根 scripts//session-catchup.py 不存在=幽灵锚实锤)
- C 类 26 条:纯历史教训/交付记录,低消费风险,标注保留
- 实测锚:selftest 全量(43 脚本仓内)PASS=655 FAIL=0(含 final-gate-hash 22/0,其输出 Total 行格式特殊需单独汇总);plans/INDEX in_progress=2(v093/v094 中断挂账)
- 模板设计稿完整:memory-hygiene-type.md 区块清单(头部 template_type/plan_tier 注释+17 区块含 Drift Log/Handoff/委派统计/配置 3 行)+特有区块 5(M1 盘点表 7 列/M2 四维机械命令范式/M3 处置枚举 verified·updated·stale-marked·删除建议仅建议+守门/M4 验证锚规范+MEMORY.md.proposed 抽验契约/M5 写入三要素=绝对日期+验证锚+失效条件),全文落 `plans/task-v109/subagent-state/1-executor.md`「设计稿」节
- 结论:57 条中真正需 updated=1、stale-marked=2(含 A16+B1 task-v056),删除建议=0(无需删除即可恢复可用性,Phase 4 dogfood 保守策略可达)

#### [sub:2-executor] 模板编写级联
- N-01 新建 `WT/skills/task-planner/templates/variant/memory-hygiene-type.md`（设计稿 M1-M5 全量嵌入「📋 记忆整理协议」节+标准区块齐备+验证独立性行+三区块修改面声明）；gate 实测 `check-template-type.sh <新模板>` → `[template-gate] OK: template_type=memory-hygiene` exit=0；variant 目录实测 17 个
- N-02 级联 7 文件 16→17：template-mapping.md（§一 决策树+清单补行+门控提示 v093 起 16→17 类、§六 速查表补「记忆卫生(v4) 通用组-记忆卫生」行、§九 矩阵补 memory-hygiene 行=18 行）；plan-writer.md 映射表补 `memory-hygiene` 行（17 行）；SKILL.md:274「standard 17 variant」；critical-rules.md:348「18 行：17 variant + general」+:361「现有 17 个 variant」；template-guide.md §2.2 表补 17 行（标题 17 个）；selftest-template-lifecycle.sh TL-17 注释+断言「16 个」→「17 个」
- 验证：`bash selftest-template-lifecycle.sh` → Total: 18 PASS=18 FAIL=0 exit=0；`git status --porcelain` 恰 7 M+1 未跟踪=8 文件；SKILL/critical-rules「16 variant」grep 零残留
- 全量 checkpoint 落 `plans/task-v109/subagent-state/2-executor.md`

#### [sub:6-executor] dogfood 整理
- 57 条逐条 M1-M5 处置完成：**verified=49 / updated=2 / stale-marked=4 / 删除建议=0**；产出 `plans/task-v109/memory-hygiene-report.md`（总表 57 行+原文留存+删除建议节）+ `MEMORY.md.proposed`（57 索引行，max line=200 字符，验证戳 `[v109 2026-10-02 盘点 verified|stale-marked|updated]`）
- 实测纠偏 sub:1 底稿：selftest 仓内脚本=**42**（非 43，registry.tsv=43 行含表头=SR-12 动态口径一致）；主仓 variant=16、worktree=17；部署位 zcode=28（videop1 分叉实锤,独有 audio-voice-type 等）/claude=16/opencode=16；INDEX 表行 complete=52/in_progress=2（L48-49 的 v093/v094 行陈旧,尾注 L124 与表行一致）；38 个 commit 锚逐 sha grep 全部在史
- updated 2 条（不直接改 topic,更新文案+原文留存入报告 §二）：①task-v091（基线 525/0 superseded-by-v108 42/660）②task-planner-repo-deploy-flow（frontmatter 9 位口径 vs 3 实体位双源+正文止于 09-16 未随 v076-v108 追加+videop1 分叉现状+索引双行合并 1 行）
- stale-marked 4 条（M3 固定标注文案入报告 §三）：task-v093（33 脚本 525/0 时点基线）/task-v074（294/0 vs 301/0 双源+未 push 态）/task-v056（领先 origin 7 时点,现 ahead 21）/task-planner-plan-parsing-pitfalls（仓根 scripts/ 锚灭,session-catchup.py 实为 .ts）
- 全量 checkpoint 落 `plans/task-v109/subagent-state/6-executor.md`（4 里程碑+8 字段终块）

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:3-executor] 回归验证
- 全量 42 个 selftest-*.sh 在 worktree task-v109 逐一运行（90s timeout 包裹，无超时）：41 脚本 rc=0、1 脚本 rc=1；断言合计 PASS=684 FAIL=1（各脚本 Total 行原文全量落 `plans/task-v109/subagent-state/3-executor-results.txt`）
- 唯一失败：`selftest-skill-split.sh` L50 断言 `t "T-迁 template-guide.md 含 16 个" grep -q '16 个' "$S2/references/template-guide.md"`（rc=1，Total: 41 PASS=40 FAIL=1）
- 根因：Phase 2（84b1dd5）16→17 级联改了 7 个文件（findings sub:2 所列 N-02 清单），但 `selftest-skill-split.sh` 不在此 7 文件级联清单内——其 T-迁 断言硬编码 `'16 个'`，而 `skills/plan-template-kit/references/template-guide.md:32` 已改为「17 个」（worktree 实测；主仓基线为「16 个」）= Phase 2 级联遗漏项
- 无新缺陷：除上述 1 条已知级联遗漏外 FAIL=0；`selftest-final-gate-hash.sh` rc=0 但其 Total 行格式特殊（无 Total 行，实测 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`）；`selftest-registry.sh` 实测 registry rows=42 与 actual selftest=42 一致
- 修复建议（供主进程裁决）：`selftest-skill-split.sh:50` 断言 `'16 个'` → `'17 个'`（1 行，与 selftest-template-lifecycle TL-17 同型修正）

#### [sub:4-executor] 形态与抽样
- **形态核查（worktree task-v109）**：17/17 variant `grep -c "template_type:"`=1 且值与文件名（去 -type 后缀）逐一匹配（bugfix/code-edit/deployment/diagnostic/memory-hygiene/migration/mini-lite/performance-tuning/publish/refactor/research/rule-enhancement/schema-migration/test-writing/video-fix/video/writing）；新模板 memory-hygiene-type.md（230 行）区块对照 bugfix 齐备：头部三注释（L1-L3）+plan_tier（L8）/配置 3 行（L16-L18）/验证独立性行（L33）/M1-M5（L121-L161）/委派统计（L220）/Handoff（L226）。**缺口：无 `## 🚨 Drift Log` 区块**（grep=0；17 variant 中仅 memory-hygiene 与既有 mini-lite 缺失，mini-lite 为 v108 前状态非本任务引入）
- **干净上下文抽样（≥3 条，只读，处置记录全落 checkpoint）**：
  - ① `task-v091-efficiency-optimization`（A 类）→ **stale-marked**：frontmatter description「v092 后 master 全量基线=33 脚本 525/0」被实测替代——`ls skills/task-planner/scripts/selftest-*.sh | wc -l`→**42**、`grep -c selftest- selftest-registry.tsv`→**42**；sub:3 全量回归断言 PASS=684 亦非 525。正文「32 脚本 518 PASS」同为被替代基线数字。锚证据：`git log` 命中 b5b9bc0/36e9aaa/cc64c1b/eb7d728 四 commit 行原文（交付断言本体 verified，仅基线数字 stale）。④风险=高（数字被直接引用执行）
  - ② `task-v056-fine-grained-dispatch-plan`（A 类）→ **stale-marked**：「master 领先 origin 7 提交未 push」时点断言——`git status -sb`→`## master...origin/master [ahead 20]`，领先数已漂移 7→20 且未 push 持续；遗留①「check-complete 委派率门控反转 P1」被 [[task-v057]] description「D5 修复 check-complete 反转」清账（grep 实锤），锚 21.1b grep=4/22.4 grep=10 在位（主体 verified，局部两断言 stale）。④风险=中
  - ③ `subagent-clean-context-testing`（B 类）→ **verified**：锚 [[task-v091]] S32 交叉引用实存（v091 文件 L19 grep 'S32' 命中原文）、裁决日期 2026-09-26 绝对、无时点数字断言、无冲突。④风险=低（纯用户裁决记录）
- **协议可用性评估（M1-M5）**：抽样三维全部用 M2 机械命令范式完成（①grep -c 规则号/ls 脚本计数/②基线数字重跑 diff/③跨条目 grep+仓内 diff），处置按 M3 枚举一一对应（stale-marked×2/verified×1/删除建议=0），证据按 M4 规范（命令→关键输出 ≥10 字符）入 checkpoint。结论：**协议足以支撑只读校验+处置定态+证据落盘闭环**。缺口 2 条如实登记（不掩盖）：G-1 M2②范式未覆盖「git push 领先数」类时点断言（本次自行 `git status -sb` 补位）；G-2 M3 对「断言数字漂移但条目主体有效」（7→20）的定态边界未明示按 stale-marked 而非 updated（本次按 M3 stale-marked 语义「局部断言过时,加标注,不删原文」处置）

#### [sub:5-executor] 对齐审查
- 结论:APPROVED（P0/P1=0；P2=3，均非本任务引入且不在级联 scope 内）
- ①文档↔产出同步:diff（3 commits 84b1dd5/e3e93cb/beebf95，16 文件 +262/-249，实际 skills 面=8 文件）与任务意图（新模板+17 计数级联+漏网锚补修+Drift Log 补齐）逐项对应；抽 5 处 diff 原文对照通过（README:23、SKILL:274、critical-rules:361、TL:84、guide:52）
- ②计数枚举联动:17 variant=实测 `ls variant/*.md` 17；§九=实测 17 variant 行+general 行=18 行（CR:348 口径自洽）；mapping §六=17；plan-writer=17；guide:32/64/71；README:23/35/74；TL-17/skill-split:50 均断言「17 个」且 rerun 全 PASS（TL 18/18、split 41/41 rc=0）。全库 grep「16 variant/16 个 variant/现有 16 个/16 个」零残留（仅剩 3 处叙事/示例/非 variant 面，逐一排查在案）
- ③引用完整性:新模板+级联补行引用 10 条抽验实存（check-template-type.sh/mini-lite/selftest-plan-tier/critical-rules/mapping §九/review-library×11 类/Rule 42.6/44.2 等）；`check-template-type.sh <新模板>` → `[template-gate] OK: template_type=memory-hygiene` rc=0
- ④守卫锚级联:TL-17 注释+断言「17 个」健康（L20/L84）；skill-split:50 「17 个」健康；节标题 `## 🚨 Drift Log（漂移检测记录）`/`## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）` 与主模板 task_plan.md:336/375 逐字一致（beebf95 已补 Drift Log）；gate 白名单实测含 memory-hygiene
- P2（pre-existing，非 16→17 级联 scope，建议后续任务处置）:
  1. `[P2] skills/task-planner/docs/ARCHITECTURE.md:15 — "scripts/（16 个工具脚本）" 计数漂移 — 实测 scripts/*.sh=72（含 selftest）；无 selftest 断言守护该文件，建议下任务刷新 docs 计数`
  2. `[P2] skills/task-planner/README.md:23 — "全部 26 个模板统一含「📚 必要知识储备」" 与 guide:64「25 个模板」及实测 grep 锚=23 互斥 — master 既有（diff 仅改 16→17，未动 26/25），建议下任务统一口径`
  3. `[P2] skills/task-planner/templates/variant/memory-hygiene-type.md:30 — VC-5 指令示例「grep 16 variant 零残留/17 命中」为旧口径示例（本模板=旧基线视角的通用范例）— 与当前 17 基线易混淆，建议改「按当前基线 N 口径 grep 零残留/(N+1) 命中」`
- 变更记录三要素:变更范围=worktree skills 面 8 文件（新模板+级联 7）；冲突处理结果=16→17 级联全链闭合（漏网锚 e3e93cb 补修 skill-split:50/guide:64,71/README×3，Drift Log beebf95 补齐），无未决残留冲突（P2 三项=pre-existing 非本变更引入）；文档当前状态=17/18/25 计数全链自洽，selftest TL+split rerun 全 PASS

#### [sub:8-executor] 合并后终验
- **HEAD=d8eb770 (merge wt/task-v109) master 全量回归终验**: `skills/task-planner/scripts/selftest-*.sh` 42/42 逐一 `bash` 运行（timeout 90s 包裹, 无超时）——**42/42 rc=0, FAIL=0, 断言合计 660 PASS（程序化求和 SUM-ASSERTIONS=660 复跑验证）**; 其中 `selftest-registry.sh` Total: 5 PASS=5 (registry rows=42, actual selftest=42)
- **负结果**: 逐脚本 grep FAIL/Assertion/✗ 全部 0 命中; sub:3 阶段的唯一失败 `selftest-skill-split.sh` L50「'16 个'→'17 个'」级联遗漏已在本 HEAD 修复（selftest-skill-split.sh 41/41 PASS rc=0, 与 TL-17 同型修正生效）
- **环境备注**: 42 个脚本权限位均为 `-rw-rw-r--`（无 +x）, 直接 `./` 执行 rc=127 属环境问题非脚本缺陷; `selftest-final-gate-hash.sh` 输出格式特殊（`==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====` 无 Total 行, 同 sub:3 记载）
- **结论**: 合并后 master 全量回归通过, 无新增失败断言; 明细 42 行原文落 `plans/task-v109/subagent-state/8-executor.md`

#### [sub:9-executor] 部署对账
- **主仓基线 (d8eb770)**: `skills/task-planner/templates/variant/` 实测 17 个 (含 memory-hygiene-type.md); 7 级联文件定位: plan-template-kit/references/template-mapping.md, task-planner/companion/agents/plan-writer.md, task-planner/SKILL.md, task-planner/references/critical-rules.md, plan-template-kit/references/template-guide.md, task-planner/scripts/selftest-skill-split.sh, task-planner/scripts/selftest-template-lifecycle.sh
- **宿主1 ~/.zcode/skills**: ① memory-hygiene-type.md 缺失 (ls → No such file or directory); ② 7/7 级联文件 `diff -q` 全部 differ (全部落后); ③ variant 计数=28 (v107 已知 videop1 分叉, 独有 audio-voice/character-design/final-assembly/image/motion-camera/multiview-ref/physics-compliance/prompt-struct/qc-defect/script-dev/storyboard/video-prompt 12 个, 主仓 17 中无缺失但 memory-hygiene 亦无); ④ v109 标记探针: `memory-hygiene` grep 全 6 级联宿主文件=0 命中, `17 个` 探针=0 命中 (仅存量 "16 个" 旧锚残留于 selftest-skill-split.sh/critical-rules.md)
- **宿主2 ~/.claude/skills**: ① memory-hygiene-type.md 缺失; ② 7/7 级联文件 diff -q 全部 differ; ③ variant 计数=16 (17 旧基线, 落后 v109 +1); ④ `17 个` 探针=0, "16 个" 旧锚残留 4 处 (guide/skill-split/TL/critical-rules)
- **宿主3 ~/.opencode/skills**: 同宿主2逐项一致——memory-hygiene 缺失/7/7 differ/variant=16/"16 个" 旧锚 4 处
- **每宿主部署建议 (供用户裁决)**:
  - ~/.zcode/skills: 合并式部署——主仓 17 面 (memory-hygiene + 7 级联) 合入 28 variant 分叉树 (28→29), 不可整树覆盖 (12 独有 variant 会被抹除+16 个分叉同名文件会回退)
  - ~/.claude/skills: 直接全量同步主仓 17 面 (整树=16 旧基线, 无独有分叉, 可整体覆盖)
  - ~/.opencode/skills: 直接全量同步主仓 17 面 (同 claude)
- **负结果声明**: 未修改任何部署位/主仓文件, 未执行 git 写操作; 全部证据=`diff -q`+`ls|wc -l`+`grep` 只读探针; checkpoint 落 `plans/task-v109/subagent-state/9-executor.md`
