# Knowledge Brief — task-v092-guard-quirk-fixes（任务知识简略要点）

<!--
  计划期产出：plan-writer（2026-09-27），事实仅来自 materials/defect-evidence.md 与 plan-writer 实际 Read 过的源码区段（check-conflicts.sh:100-179 / check-drift.sh:105-224 / lib/plan-parse.sh 全文 / template-guide.md:55-79 / plans/INDEX.md:8-9 / selftest-check-conflicts.sh:125-170 / 机器门控脚本）。
  执行期各 S-unit 完成后持续回填 §2/§3。
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念

- 任务一句话：修复 v091 遗留四组守卫缺陷（check-conflicts INDEX 解析恒空+自计划跳过恒不等、check-drift 两 quirk+:205 区间 awk、template-guide.md:69 文档锚），达成全量 selftest ≥518/0 + 三实体位部署 IDENTICAL。
- 背景/动机：task-v091 verification.md:24/:83 遗留披露 + progress.md:74/79/84/85 deferred 登记——这些缺陷使守卫的冲突检测/scope 检测维度实际失效，属缺陷行为恢复非新功能。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| worktree | git 隔离开发区，实现类任务必须在其中开发（§十一 P0）；本任务路径=/home/terry/task-planner-skill-worktrees/task-v092-guard-quirk-fixes，分支 wt/task-v092-guard-quirk-fixes |
| plan_parse_scope | scripts/lib/plan-parse.sh:30-46 的统一 scope 提取函数：区间「## …执行范围限制」→下一个「## 」，表格行第 3+ 字段中含点分路径（/\.[a-zA-Z]/）的**整格**输出（不逗号拆分），fail-open |
| 状态机化 | 用 `{f=1;next} /^## /{f=0}` 状态机替代区间式 `/A/,/B/` awk——区间式首行同时匹配终止模式时恒空（gawk 5.2 已证） |
| CC-06 夹具 | selftest-check-conflicts.sh:133-170 的 runtime 冲突 A 用例：畸形 INDEX（分隔行置尾，S16 先例）+两计划共享 src/shared.py，断言「🔴 冲突 A(同文件)」+交集文件+rc=1 |
| 三实体位 | 三个部署位：~/.zcode/skills/task-planner、~/.claude/skills/task-planner、~/.config/opencode/skills/task-planner，合并后 smart-merge-back.sh --deploy 同步 |
| 固定 sid | selftest 用例的 session_id 必须每次唯一（v078 教训），防用例间 .active_plan/状态互染 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 基线 = master 0b2208b，全量 selftest 基线 518 PASS / 0 FAIL（32 脚本） | materials/defect-evidence.md:3 + plans/task-v091-efficiency-optimization/verification.md:16 | Phase 5 回归不得低于 518/0；worktree 从 0b2208b 拉 |
| check-conflicts 管道输入侧：`while IFS='\|' read -r task_id status phase_total goal mtime _icon`，管道为 `sed -n '/^| Task ID/,/^|-------/p' \| tail -n +2 \| grep '^|' \| sed 's/^|//;s/\|$//' \| awk -F'\|'`（清空格后五字段输出） | skills/task-planner/scripts/check-conflicts.sh:124/:144 | 1a 修复只动 :118-145 区段；逐段实跑取证由 S1 承担 |
| 真实 plans/INDEX.md 表头后**第 2 行即分隔行** `\|---------\|...\|`（8 列分隔行），非「内容行先行、分隔行置尾」 | plans/INDEX.md:8-9（2026-09-27 plan-writer 实 Read） | sed 区间 `/^| Task ID/,/^|-------/p` 在该形态下首行配终止即截断——候选根因方向（终判归 Phase 1 S1 实证） |
| 真实 INDEX.md 共 10 列（Task ID/Status/Phase 进度/Goal/session_id/worktree/scope_files/最后更新/待办/✓），非 :144 awk 假设的 6 列 | plans/INDEX.md:10（表头行实 Read） | awk $1-$6 截取与真实列序的错位也是 1a 候选根因，S1 逐段实跑须覆盖 |
| check-conflicts :139/:166 已接 plan_parse_scope（v091 S16 C-1c），原内联整行清洗已删 | skills/task-planner/scripts/check-conflicts.sh:134-139/:165-166 注记 | 修复不得回退该接入；diff 审查必含这两行 |
| current_plan_dir 判定 = `$repo/plans/*` glob + task_plan.md mtime<86400 | check-conflicts.sh:147-157 | 1b 候选根因=「plans/$task_id」（:127 相对）vs「$repo/plans/*」（:149 绝对）路径形态不一致 |
| check_phase_order `prev_status` 初值 = "pending"（:122），越级判定 = complete 紧跟 pending 即 CRITICAL（:138） | skills/task-planner/scripts/check-drift.sh:111-154 | 3a 初值误报机理已在源码确认；修复=初值中性化+正反双向夹具 |
| check_scope_breach 提取 = 区间 awk + `sed 's/.*|//;s/|.*//'` 取尾列 | check-drift.sh:205-211 | 两列范围表尾列非「允许的文件」列 → 恒 SCOPE-NONE（3b，S32 checkpoint ② 披露） |
| 区间式 awk `/^## ⚠️ 执行范围限制/,/^## /` 起始行同配终止模式恒为空 | check-drift.sh:205 + memory「区间式 awk scope 提取 bug」+ defect-evidence.md:17；gawk 5.2.1（本机实测版本） | 3c 第 5 处复制（task-v053 已状态机化仓内 4 处）；修复方向见 plan_parse_scope 事实行 |
| plan_parse_scope 调用方清单（语义同步义务）= check-conflicts×2 / sync-todos / pretooluse 内联；check-drift:205 标注「未纳入…待后续组统一」 | scripts/lib/plan-parse.sh:8-14 | 接库=消除第 5 复制且符合库设计意图；接库与否 Phase 1 S3 对拍裁决 |
| template-guide §2.5 原文「故 :65 的 grep 锚计数 …维持 20 不变」；§2.3 声明「5 核心+3 辅助+13 variant=21 个」；§2.4 :66 写 grep 锚验收「应为 21」 | skills/task-planner/references/template-guide.md:60/:66/:74 | 三声明（20/21/21）并存且互相矛盾，锚 :69 精确行号已随插行漂移 |
| 计划期实测（plan-writer 2026-09-27）：ls templates/*.md=10、ls variant=15、grep -rl "## 📚 必要知识储备"=22 | bash 实跑输出（Phase 1 S4 须复测固化） | 计数声明全部过时；修正基准以 Phase 1 复测为准，k-brief 头注释「维持 20」声明同样过时 |
| CC-06 现行为：夹具用「分隔行置尾」畸形 INDEX 锁定 A 检测现行为，断言「🔴 冲突 A(同文件)…session=sess-other」+src/shared.py+rc=1 | scripts/selftest-check-conflicts.sh:13/:17/:133-170 | 夹具同步改造的断言底线=语义不变（冲突 A 仍报+交集文件+rc=1） |
| v091 S26 裁决：DRIFT CHECK 唯一载体=Skill("task-drift-guard")，check-drift.sh 仅佐证 | defect-evidence.md:19 | 修复不改变佐证地位；禁止恢复双跑/删脚本 |
| FMEA 机器口径：RPN 表第 6 数据列纯数字（awk -F'\|' $7）；RPN>100 行第 7 数据列非空 | scripts/attest-plan.sh:119-140 + check-complete.sh:505-545 + templates/task_plan.md:247 | 本计划 FMEA 表已按 7 列+第 7 列=RPN 表头对齐（见 §4 易错点 5） |
| S-unit ID 机器契约=纯数字（`^\|\s*S[0-9]+\s*\|`，字母后缀不认，task-v076 attest 拒锁教训） | scripts/selftest-conclusion-discipline.sh:23 + check-plan-dispatch.sh:26 | 本计划 S-unit 编号 S1-S13 纯数字 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/scripts/check-conflicts.sh | :118-145 | 运行时模式收集 active_plans：五字段 while read + sed/tail/grep/awk INDEX 解析管道 + plan_parse_scope 提 scope |
| skills/task-planner/scripts/check-conflicts.sh | :147-166 | current_plan_dir 判定（glob+mtime<86400）+ current session/worktree/scope 提取 |
| skills/task-planner/scripts/check-drift.sh | :111-154 | check_phase_order：Phase Status 序列提取，prev_status 初值 pending，complete-after-pending → CRITICAL PHASE-SKIP |
| skills/task-planner/scripts/check-drift.sh | :198-216 | check_scope_breach：区间 awk+尾列 sed 提取「允许的文件」，空则 SCOPE-NONE 跳过 |
| skills/task-planner/scripts/lib/plan-parse.sh | :30-46 | plan_parse_scope 单 awk 实现：区间宽松匹配→表格行→第 3+ 字段点分整格输出，fail-open |
| skills/task-planner/scripts/lib/plan-parse.sh | :8-14 | 调用方语义同步义务清单+check-drift「未纳入」注记（接库时须更新此处） |
| skills/task-planner/scripts/selftest-check-conflicts.sh | :133-170 | CC-06：task-cur/t-other 两夹具计划+分隔行置尾 INDEX，断言冲突 A 报警+交集+rc=1 |
| skills/task-planner/references/template-guide.md | :60-74 | §2.3 计数声明 21 / §2.4 grep 锚验收 21 / §2.5「:65 计数维持 20」三处并存声明 |
| plans/INDEX.md | :8-10 | 表头+紧跟分隔行+10 列表头形态（1a 取证的真实数据样本） |
| plans/task-v092-guard-quirk-fixes/materials/defect-evidence.md | 全文 39 行 | S-unit 材料包源：五组缺陷锚点/机理假设/范围外清单/验收基线 |

## §4 易错点与禁止假设清单

1. 禁止未经逐段实跑就按「候选根因」动手修 1a——材料包明示「修复前必须先跑管道逐段实测真实输出」；真实 INDEX.md 表头形态（分隔行第 2 行+10 列）与 CC-06 夹具形态（分隔行置尾+6 列）不同，两种形态都要在 S1 夹具矩阵里测。
2. 禁止回退 check-conflicts :139/:166 的 plan_parse_scope 接入（v091 S16 成果）；diff 审查必含这两行。
3. 禁止借修 check-drift 恢复双跑或删脚本；禁止削弱 Check 1-3（phase order/goal alignment 等既有检测）。
4. 3b/3c 接库 vs 状态机化必须等 Phase 1 S3 对拍裁决，不得计划期预设；若接库，lib/plan-parse.sh:8-14 调用方清单头注须同步更新（语义同步义务）。
5. 机器门控易踩点（本计划已按此对齐，执行期新增结构同样遵守）：S-unit ID 纯数字；FMEA 表 7 列且第 7 列=RPN、RPN>100 行兜底列必填；每个 Phase 必有 `**Executor:**` 行；派发型 Phase 必有 S-unit 表。
6. template-guide 修正时禁止顺手改 template-mapping.md（发现同型漂移只登记不修，材料包明示）；修正基准值以 Phase 1 S4 复测为准，不信计划期快照。
7. selftest 新增用例固定 sid 每次唯一（v078 教训）；单用例调试 ≤2 轮，超则记 blockers 交主进程（11 用例单步 18min/1.24M token 实证教训）。
8. 范围外零偷渡：plan glob（:147-157 相邻问题）/UPS 慢源/Tier B 7 项/WF-10/check-delegation 等其他守卫脚本——VC-5 以 git diff --stat 全清单逐项比对。
9. Phase 6 部署对账若新增逻辑必须 LC_ALL=C pin（v091 C-5 locale 假 IDENTICAL 教训）。
- FMEA RPN>100 兜底指针：本计划 FMEA 表最高 RPN=84（Phase 1 机理假设证伪），无 >100 行——兜底统一对齐 VC-1 门控（STOP 回计划层）与 Rule 22.3 链。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1（Phase 1） | §1 + §2（check-conflicts 三行）+ §3（:118-166 两行） | /mnt/data/dev/task-planner-skill/plans/task-v092-guard-quirk-fixes/materials/defect-evidence.md（缺陷 1+2 节）+ plans/INDEX.md:1-12 |
| S2（Phase 1） | §2（check-drift 三行+plan_parse_scope 行）+ §3 | defect-evidence.md 缺陷 3 节 + scripts/check-drift.sh:111-224 |
| S3（Phase 1） | §2（plan_parse_scope 语义/调用方两行）+ §4（易错 4） | scripts/lib/plan-parse.sh 全文 + defect-evidence.md:18 |
| S4（Phase 1） | §2（template-guide 三行+实测行）+ §3 | defect-evidence.md 缺陷 4 节 + references/template-guide.md:55-79 |
| S5-S7（Phase 2） | §2（check-conflicts 全部+CC-06 行）+ §4（易错 1/2/5/7） | findings.md Phase 1 复现节（S1/S3 产出）+ selftest-check-conflicts.sh:125-170 |
| S8-S9（Phase 3） | §2（check-drift 全部）+ §4（易错 3/4） | findings.md S2 复现+S3 裁决 + scripts/check-drift.sh:105-224 |
| S10-S11（Phase 4） | §2（template-guide 三行+实测行）+ §4（易错 6） | findings.md S4 归因 + references/template-guide.md:55-79 |
| S12-S13（Phase 5） | §1（固定 sid 概念）+ §2（基线行+FMEA 口径行）+ §4（易错 5/7） | findings.md 三 quirk 复现节（断言蓝本）+ skills/task-planner/scripts/selftest-*.sh 全量 |
