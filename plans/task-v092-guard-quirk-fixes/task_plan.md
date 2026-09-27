<!-- template_type: bugfix -->
<!-- 适用场景: bug 修复/根因定位 -->
<!-- 触发关键词: 修复/报错/失败/异常/恒空/恒跳过/恒误报 -->
<!-- plan_tier: standard -->

# Task Plan: task-v092-guard-quirk-fixes — v091 遗留守卫缺陷修复

## Goal

修复 v091 遗留四组守卫缺陷(check-conflicts.sh INDEX 解析恒空+自计划跳过恒不等、check-drift.sh 两 quirk+:205 区间 awk 第 5 处复制、template-guide.md:69 文档锚漂移+计数过时)，全量 selftest ≥518 PASS/0 FAIL，CC-06 夹具同步改造后语义有效，合并部署后三实体位 diff -r IDENTICAL。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `template_type` | `bugfix` |
| `code_review` | `required` |
| `interaction_mode` | `silent`（自主会话：用户已显式点名缺陷清单，无中途决策点） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 四组缺陷先稳定复现（Phase 1），修复后逐一反证不复现：① check-conflicts runtime `active_plans` 非空且 A/B/C 维度可触发；② 自计划跳过判定成立；③ check_phase_order 全 complete 序列输出 PHASE-ORDER 正常（rc 无 CRITICAL）；④ check_scope_breach 对两列范围表可提取「允许的文件」列 | Phase 1 复现输出 + Phase 2/3 修复后同夹具复跑对比 | `plans/task-v092-guard-quirk-fixes/findings.md`（复现/反证对照节）+ `subagent-state/` checkpoint |
| VC-2 | 仓侧全量 selftest 全绿且不低于基线：32 脚本逐脚本 Total 求和 ≥518 PASS / 0 FAIL | 主进程逐脚本实跑求和（LC_ALL=C 无关，bash 直跑） | `plans/task-v092-guard-quirk-fixes/progress.md`（逐脚本结果行） |
| VC-3 | CC-06 夹具随 check-conflicts 修复同步改造，改造后 selftest-check-conflicts 全 PASS 且 CC-06 断言仍锁定「冲突 A 报警+交集文件+rc=1」语义（非恒真恒假断言） | `bash skills/task-planner/scripts/selftest-check-conflicts.sh` 全 PASS + CC-06 夹具 INDEX 构造与真实 INDEX.md 形态一致 | `subagent-state/` Phase 2 checkpoint + selftest 输出 |
| VC-4 | 合并 master 后 `smart-merge-back.sh --deploy` 三实体位（~/.zcode、~/.claude、~/.config/opencode）与仓侧 diff -r 逐位 IDENTICAL（diff_lines=0，对账若新增逻辑 LC_ALL=C pin） | 主进程独立 `diff -r` ×3 亲验 + sha256 抽查 | `plans/task-v092-guard-quirk-fixes/progress.md`（Phase 6 部署记录） |
| VC-5 | 范围外零触碰：material「范围外清单」5 项（plan glob/UPS 慢源/Tier B/WF-10/check-delegation 等其他守卫脚本）git diff 无痕；删除基线对照 git 历史确认无功能性删除 | `git diff master --stat` 全清单逐项比对 scope 表 + Rule 36.4 声明核对 | `plans/task-v092-guard-quirk-fixes/verification.md`（终验）+ git diff 输出 |

**终验规则**：
- 全部 VC 通过 → COMPLETE
- VC-1 失败（Phase 1 复现不出）→ BLOCKED：材料包机理假设被证伪，回计划层重析（禁止猜根因后修）
- VC-2 失败 → 回 Phase 5 修回归；VC-4 失败 → 重部署复验，≥2 次失败升级用户
- 模型降档（haiku 承担多文件 shell 修复）风险 → 按 22.3 ③ 升档 sonnet-1 重派，禁止降档省成本

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | skills/task-planner/scripts/check-conflicts.sh；skills/task-planner/scripts/check-drift.sh；skills/task-planner/scripts/lib/plan-parse.sh（仅当 Phase 1 裁决接库且需小改头注/语义注记；否则零触碰） | 其他任何 scripts/*.sh（含 check-delegation/check-plan-dispatch/zcode-pretooluse 等）；lib/ 其他文件 |
| 测试 | skills/task-planner/scripts/selftest-check-conflicts.sh（CC-06 夹具同步改造）；skills/task-planner/scripts/selftest-check-drift 相关行为级用例（新增或既有 check-drift 断言脚本，Phase 1 确认承载文件；新建文件落 scripts/selftest-*.sh 惯例命名） | 改既有其他 selftest 断言基线 |
| 文档 | skills/task-planner/references/template-guide.md（仅 §2.5 :69 区文档锚+计数修正）；plans/task-v092-guard-quirk-fixes/ 全部文件 | critical-rules.md/SKILL.md/template-mapping.md/config.json；template-mapping.md 若发现同型计数漂移只登记不修 |
| 计划簿记 | plans/task-v092-guard-quirk-fixes/{task_plan.md, findings.md, progress.md, notepad-learnings.md, verification.md, knowledge-brief.md, subagent-state/**, materials/**} | 其他 plans/ 目录（含 INDEX.md——执行期仅主进程按 sync-todos 刷新） |

**强制约束**：
- Rule 36 声明：本任务无功能性删除，全部为缺陷行为恢复（恒空/恒跳过/恒误报 → 设计意图行为）；36.4 删除清单=空；36.3 删除基线=git 历史（master 0b2208b）
- 修复基于 Phase 1 实证根因，禁止症状性修复（try/catch 吞错、放宽断言、静默降级）
- check-drift.sh「可选佐证」地位不变（DRIFT CHECK 唯一载体=Skill("task-drift-guard")），禁止借机恢复双跑或删脚本；禁止削弱既有 Check 1-3 检测
- check-conflicts :139/:166 已接入 plan_parse_scope（v091 S16），修复不得回退该接入语义
- worktree 内实施，主仓只读；每次派发前主进程登记 Handoff 表

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 缺陷取证材料包 | /mnt/data/dev/task-planner-skill/plans/task-v092-guard-quirk-fixes/materials/defect-evidence.md | 必读 | ☑ |
| 项目内部文档/知识库 | v091 遗留登记原文 | /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/verification.md:24/:83 | 参考 | ☑ |
| 项目内部文档/知识库 | worktree 隔离 SOP | /home/terry/.zcode/skills/task-planner/references/worktree-isolation.md | 参考 | ☐ |
| 项目内部文档/知识库 | knowledge-brief 模板（§五段结构） | /home/terry/.zcode/skills/task-planner/templates/knowledge-brief.md | 参考 | ☑ |
| 官方 Issue/changelog | 无上游依赖（纯仓内 bash/awk 行为恢复） | n/a | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## Current Phase

Phase 5

## Phases

### Phase 1: 取证——四组缺陷机理实证（复现锁定）

- [ ] check-conflicts.sh:123-145 INDEX 解析管道逐段实跑：以真实 plans/INDEX.md（表头后第 2 行即分隔行 `|---|`，已 Read 实证）+ /tmp 变形夹具逐段跑 `sed -n '/^| Task ID/,/^|-------/p'` → `tail -n +2` → `grep '^|'` → `awk -F'|'`，锁定 1a 恒空根因；同法锁定 1b 自计划跳过恒不等（:147-157 current_plan_dir 相对路径 vs active_plans 条目路径形态/空白）
- [ ] check-drift.sh 复现：3a check_phase_order（:122 `prev_status="pending"` 初值→全 complete 序列 CRITICAL PHASE-SKIP）用 /tmp 计划夹具复现 rc 与输出；3b check_scope_breach（:205-211 `sed 's/.*|//;s/|.*//'` 对两列范围表取不到「允许的文件」列）构造两列表夹具复现 SCOPE-NONE；3c :205 区间式 awk `/^## ⚠️ 执行范围限制/,/^## /` 首行即配终止（gawk 5.2.1，本机实测）恒空复现
- [ ] plan_parse_scope 语义核对：Read lib/plan-parse.sh:30-46（点分整格语义）+ check-drift「允许的文件」列语义对拍（两列范围表/逗号清单样张），裁决「接库 or 状态机化」，结论落 findings.md
- [ ] template-guide.md 计数实测：`ls templates/*.md | wc -l`=10、`ls templates/variant/*.md | wc -l`=15（=5+10? 以 Phase 1 实测为准）、`grep -rl "## 📚 必要知识储备" templates/ | wc -l`=22（2026-09-27 主进程计划期实测），与 §2.3 声明 21/§2.5 声明 20 三方差值归因；固定 sid 教训核查 selftest 新增用例命名
- [x] 四组复现证据+根因结论+修复方向裁决全部落 findings.md；knowledge-brief.md §2/§3 回填
- **V-N:** VC-1, VC-5
- **Status:** complete（verified 2026-09-27：S1-S4 四取证全 done 且主进程逐一 Read 复核；3-File Gate PASS）
- **Executor:** executor（sonnet-1）

| ID | 目标（≤1 句） | 执行体 | 输入（路径 + ≤10 行摘要） | 验收（可观察） | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | check-conflicts 1a+1b 管道逐段实跑复现 | 继承 | skills/task-planner/scripts/check-conflicts.sh:123-157——五字段 while read + sed 区间管道（表头→分隔行）+tail/grep/awk 清洗 + current_plan_dir mtime<86400 glob 判定；plans/INDEX.md:8-9——表头第 2 行即分隔行 | 管道逐段输出贴 findings.md，恒空/恒不等根因各含 ≥1 条逐段实测证据 | 12min | pending |
| S2 | check-drift 3a/3b/3c 三 quirk 复现 | 继承 | skills/task-planner/scripts/check-drift.sh:111-154（prev_status 初值 pending/越级判定）+:205-211（尾列提取 sed）+/lib/plan-parse.sh:30-46（点分整格 awk 单实现）；gawk 5.2.1 | /tmp 夹具三类复现输出（CRITICAL 误报/SCOPE-NONE/恒空）各 ≥1 份，根因结论落 findings.md | 15min | pending |
| S3 | plan_parse_scope 语义对拍+接库裁决 | 继承 | materials/defect-evidence.md:18 修复方向（接库 or 状态机化裁定输入）；lib/plan-parse.sh:8-14 调用方清单+未纳入注记 | 对拍样张 ≥2 组（两列表/逗号清单），裁决+理由写入 findings.md（供 Phase 3 执行） | 8min | pending |
| S4 | template-guide 计数实测+锚漂移归因 | 继承 | skills/task-planner/references/template-guide.md:60-74——§2.3 声明 21 个/:66 grep 锚验收 21/:74 "维持 20 不变"三处声明并存 | 实测三数（10/15/22 主进程已测）+三声明差值归因写入 findings.md（供 Phase 4 执行） | 5min | pending |

### Phase 2: worktree 创建 + check-conflicts.sh 修复（1a+1b）+ CC-06 夹具同步改造

- [x] 主进程建 worktree：`git worktree add /home/terry/task-planner-skill-worktrees/task-v092-guard-quirk-fixes -b wt/task-v092-guard-quirk-fixes master`（基线 0b2208b）
- [x] S5 修 1a：按 Phase 1 根因修 :123-145 管道（候选：sed 区间模式对真实表头形态/sed 尾域清洗），使真实 INDEX.md 形态下 active_plans 非空、A/B/C 维度可触发
- [x] S6 修 1b：按 Phase 1 根因修 :147-157 current_plan_dir 与 active_plans 条目的跳过判定（路径形态/空白归一）
- [x] S7 CC-06 夹具同步改造：selftest-check-conflicts.sh CC-06 INDEX 构造改为修复后可解析形态（保「分隔行置尾 S16 先例」或换真实形态，以 Phase 1 结论为准），断言仍为「冲突 A 报警+交集文件 src/shared.py+rc=1」；不回退 :139/:166 plan_parse_scope 接入
- **V-N:** VC-1, VC-3
- **Status:** complete（verified 2026-09-27：S5=59b1471/S6=cba40ec/S7=7bdd6ff 三提交，selftest 7/7 含新 CC-07；主进程 git show 逐一复核 diff）
- **Executor:** executor（sonnet-1）

| ID | 目标（≤1 句） | 执行体 | 输入（路径 + ≤10 行摘要） | 验收（可观察） | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S5 | 修 check-conflicts :123-145 INDEX 解析恒空 | executor（sonnet-1） | findings.md Phase 1 复现节（1a 根因+逐段证据）；check-conflicts.sh:118-145 原码 | 真实形态 INDEX 夹具下 active_plans 非空+冲突 A 维度触发；diff 仅限该函数区段 | 15min | pending |
| S6 | 修 :147-157 自计划跳过恒不等 | executor（sonnet-1） | findings.md 1b 根因；check-conflicts.sh:147-166（current_plan_dir glob+scope 提取） | /tmp 夹具：当前计划自身被正确跳过、他计划被检测；diff 仅限该区段 | 10min | pending |
| S7 | CC-06 夹具同步改造 | executor（sonnet-1） | selftest-check-conflicts.sh:133-170（CC-06 块：畸形 INDEX 构造+断言）；findings.md 修复形态结论 | selftest-check-conflicts.sh 全 PASS；CC-06 断言语义不变；夹具 INDEX 与真实 INDEX.md 形态一致 | 15min | pending |

### Phase 3: check-drift.sh 修复（3a 初值 + 3b/3c scope 提取）

- [x] S8 修 3a：check_phase_order prev_status 初值改中性（如空/"none"），全 complete 序列不再误报 CRITICAL；ALIGNED 夹具 rc=0
- [x] S9 修 3b/3c：按 Phase 1 S3 裁决——语义一致则 check_scope_breach 接 plan_parse_scope 统一库（消除 :205 第 5 处复制+lib 头注「未纳入」同步更新）并取对「允许的文件」列；不一致则状态机化+取对列
- [x] 修复不削弱 Check 1-3 既有检测（diff 审查确认）；行为级用例先于或同步于修复（VC-5 回归）
- **V-N:** VC-1, VC-2
- **Status:** complete（verified 2026-09-27：S8=f3966eb/S9=11c294c；S9 四夹具+38 计划 byte-identical+sync-todos 对拍全过；主进程 git show 复核）
- **Executor:** executor（sonnet-1）

| ID | 目标（≤1 句） | 执行体 | 输入（路径 + ≤10 行摘要） | 验收（可观察） | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S8 | 修 check_phase_order 初值误报 | executor（sonnet-1） | check-drift.sh:111-154（prev_status="pending" :122；越级判定 :138）；findings.md 3a 复现 | 全 complete 夹具 rc 无 CRITICAL+PHASE-ORDER INFO；越级夹具仍正确报（正反两向） | 10min | pending |
| S9 | 修 check_scope_breach 提取（按裁决接库/状态机化） | executor（sonnet-1） | check-drift.sh:198-216（提取管道+SCOPE-NONE 分支）；findings.md 之 S3 节（对拍样张+接库或状态机化裁决，含库头注更新义务） | 两列范围表夹具可提取「允许的文件」列；progress 越界文件触发 WARNING（正向）；既有 Check 1-3 输出不变 | 15min | pending |

### Phase 4: template-guide.md 文档锚+计数修正

- [x] S10 行号锚改章节锚：§2.5 内「:65 的 grep 锚计数」改「§2.4 的 grep 锚验收」（§2.4 形态，抗插行漂移；材料包锚点 :69 实漂至 §2.4 契约安全 bullet 与 :74，Phase 1 S4 归因为准）
- [x] S11 计数按实测修正：以 Phase 1 实测（ls=10 核心+15 variant、grep=22）修正「维持 20」声明，与 §2.3「21 个」三方对齐（20/21/22 以实测+归因结果为准）；template-mapping.md 若同型漂移只登记不修
- **V-N:** VC-1, VC-5
- **Status:** complete（verified 2026-09-27：S10=35cd075/S11=e5a402d；三实测数与文档自洽+旧值零残留；:32 §2.2 同型漂移与 template-mapping 漂移超 scope 已登记 findings）
- **Executor:** code-assistant（haiku-1）

| ID | 目标（≤1 句） | 执行体 | 输入（路径 + ≤10 行摘要） | 验收（可观察） | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S10 | :69 区行号锚改章节锚 | code-assistant（haiku-1） | template-guide.md:71-74（§2.5 两 bullet）；findings.md S4 锚漂移归因 | grep -n ':65' §2.5 区零命中；新锚为「§2.4」章节引用形态；diff ≤4 行 | 5min | pending |
| S11 | 计数声明实测修正 | code-assistant（haiku-1） | findings.md S4 三方实测（10/15/22）；template-guide.md:60/:66/:74 三处声明 | 三处计数与实测一致且互相不矛盾；template-mapping.md 漂移仅登记 findings.md | 5min | pending |

### Phase 5: selftest 行为级用例补写 + 全量回归 ≥518/0

- [x] S12 check-drift 行为级用例：三 quirk 修复正反向断言（全 complete 不误报/越级仍报；两列表提取成功/无表 SCOPE-NONE 保留）——承载文件按 Phase 1 S2 确认（新建 selftest-check-drift.sh 或既有断言脚本追加），固定 sid 每次唯一（v078 教训）
- [x] S13 CC-06 与 1a/1b 行为断言已在 Phase 2 S7 落地，此处复核 + 查漏补用例
- [x] 全量回归：worktree 内 32 脚本逐脚本实跑求和 ≥518 PASS/0 FAIL，逐脚本结果落 progress.md
- **V-N:** VC-2, VC-3
- **Status:** complete（verified 2026-09-27：S12=8b3bab0 六用例 6/6+负向验证非恒真+registry 33/33；S13 主进程白名单③逐脚本实跑求和 525 PASS/0 FAIL（33 脚本=32 既有+新增，518+1+6 算术闭环））
- **Executor:** executor（S12 实派执行体；原派 code-runner-agent mini 遭 Provider 拒绝按 22.3③ 升档，兜底登记 Handoff/progress；S13 全量回归主进程白名单③接管见 Handoff 表）

| ID | 目标（≤1 句） | 执行体 | 输入（路径 + ≤10 行摘要） | 验收（可观察） | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S12 | check-drift 三 quirk 行为级用例补写 | code-runner-agent（mini） | findings.md 三 quirk 复现节（作断言蓝本）；selftest-check-conflicts.sh 头注风格（脚本骨架范例 :1-30） | 新用例覆盖三正+两反断言；单用例调试 ≤2 轮，超则记 blockers 交主进程；worktree 内该脚本 Total FAIL=0 | 15min | pending |
| S13 | 全量回归 32 脚本求和 | code-runner-agent（mini） | skills/task-planner/scripts/selftest-*.sh 全量；progress.md 基线行（518/0） | 逐脚本 Total 行落 progress.md；求和 PASS≥518 且 FAIL=0；<基线即 blockers 停 | 15min | pending |

### Phase 6: 合并 + 部署 + 终验

- [x] 合并回合约核验（11.3 五条全过）→ 主仓 `git merge --no-ff wt/task-v092-guard-quirk-fixes`
- [x] `smart-merge-back.sh --deploy` 三实体位 + 主进程 `diff -r` ×3 亲验（IDENTICAL，diff_lines=0；sha256 抽查）
- [x] 主仓全量 selftest 复跑 ≥518/0；Read 关键文件复验（check-conflicts/check-drift/template-guide 三处修复点）
- [x] 簿记：verification.md 回填 VC 证据、INDEX 刷新（sync-todos）、worktree remove+分支删除、merge_back=merged(<commit>)
- **V-N:** VC-4, VC-5
- **Status:** complete（verified 2026-09-27：CR APPROVED（3 非阻塞=1 minor 登记 deferred+2 nit 已修 eaa0d8d）；merge d82720e；部署三位 diff -r ×3=0；主仓 525/0；worktree/分支清理完成）
- **Executor:** 主进程（例外理由:白名单① git/worktree 编排+部署对账 + ② 计划系统文件簿记维护，均非业务代码 Edit）

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|------------------------------------------|
| 1 | 机理假设被证伪：管道逐段实跑未复现恒空/恒不等（材料包候选根因不成立） | 7 | 4 | 3 | 84 | 根因结论如实落 findings.md，STOP 回计划层重析（VC-1 门控），禁止猜根因后修（22.3 ④ 主进程接管分析） |
| 2 | check-conflicts 修复破坏 :139/:166 plan_parse_scope 接入语义（v091 S16 成果回退） | 8 | 3 | 2 | 48 | diff 审查强制含 :139/:166 行；S16 checkpoint 对拍样张复跑；破坏即 revert 重改（22.3 ② 拆细） |
| 3 | check-drift 修复削弱 Check 1-3 既有检测 | 8 | 3 | 3 | 72 | Phase 3 checkbox 强制 diff 审查+正反双向夹具（ALIGNED rc=0 与越级 rc>0 同验）；削弱即回改 |
| 4 | 计数修正引入新矛盾（20/21/22 三方声明改后仍互相冲突） | 5 | 4 | 2 | 40 | 以 Phase 1 S4 实测为唯一事实源统一三处；改后 grep 三处互核；仍冲突则登记 findings 升级主进程 |
| 5 | 全量回归 <518 或新用例自身 FAIL（sid 未固定致用例间污染） | 7 | 4 | 2 | 56 | 逐脚本结果落 progress.md 定位首个 FAIL 脚本回 Phase 2/3/4 对应修复；sid 唯一性写进 S12 验收（v078 教训） |
| 6 | 部署三实体位 diff 非 IDENTICAL（locale/时序） | 8 | 3 | 2 | 48 | LC_ALL=C pin 对账（v091 C-5 教训）；重跑 --deploy+diff -r 复验；≥2 次失败升级用户（AskUserQuestion 档） |

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（scope 全部在 skills/task-planner 仓内两脚本+一文档+本计划目录；主仓无并行任务触碰同文件——INDEX.md/.active_plan 为簿记刷新归主进程白名单） |
| `isolation` | `worktree`（§十一 P0：skills 保护区文件修改必隔离） |
| `worktree_path` | /home/terry/task-planner-skill-worktrees/task-v092-guard-quirk-fixes |
| `branch` | wt/task-v092-guard-quirk-fixes（从 master 0b2208b 拉） |
| `merge_back` | merged(d82720e)（CR nit 收尾 eaa0d8d 后合并；worktree/分支已清理） |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 取证复现 |
| Phase 2 | ☐ |  | worktree+check-conflicts 修复 |
| Phase 3 | ☐ |  | check-drift 修复 |
| Phase 4 | ☐ |  | template-guide 文档修正 |
| Phase 5 | ☐ |  | selftest 补写+全量回归 |
| Phase 6 | ☐ |  | 合并部署终验 |

## 🤝 Subagent Handoff 登记表（Rule 22.5 — 骨架，行由主进程执行期逐次派发登记）

> 列结构对齐既有计划惯例（task-v091 十列形态）；verify_done 勾选以产出 Read 复核为前提。plan-writer 只留骨架不填行。

| # | Phase/S-unit | subagent_type(model) | 派发时间 | prompt 要点 | 计划三文件路径已传 | 检查点路径 | 返回摘要 | 产出 Read 复核 | verify_done |
|---|-------------|---------------------|---------|------------|------------------|-----------|---------|---------------|------------|
| 1 | 计划期/plan-writer | Plan Writer(sonnet-1) | 2026-09-27 | bugfix 模板+材料包引用+attest 硬契约 | ✅ | subagent-state/00-plan-writer.md | status=done；6P/13 S-unit/VC5；发现 template-guide 计数三声明与实测不一致留 S4 | ✅ Read 复核（结构全项+锚点抽查） | ✅ |
| 2 | Phase 1/S1 | executor | 2026-09-27 | S1 取证：check-conflicts 1a+1b 管道逐段实跑复现 | ✅ | subagent-state/1-executor.md | status=done；1a=sed 区间被紧邻分隔行提前终止（≥7 连字符命中 end 模式）；1b=:170 相对 vs 绝对路径比较恒不等；两缺陷叠加，1a 修后 1b 必显形 | ✅ Read findings S1 节（证据表+夹具对照齐全） | ✅ |
| 3 | Phase 1/S2 | executor | 2026-09-27 | S2 取证：check-drift 3a/3b/3c 三 quirk 复现 | ✅ | subagent-state/2-executor.md | status=done；3a 初值虚构 pending 前驱致首行 complete 即误报（比登记宽）；3b=3c 区间+sed 贪婪取空双层叠加；3c=区间闭于起始行恒剩标题 1 行（跨 gawk/mawk） | ✅ Read findings S2 节（五段实测+探针组+先例对照） | ✅ |
| 4 | Phase 1/S3 | executor | 2026-09-27 | S3 取证：plan_parse_scope 语义对拍+接库裁决 | ✅ | subagent-state/3-executor.md | status=done；裁决=接库+可选列限参数（仅字段3）+消费侧保留 tr 拆逗号；禁止列反向风险实证（仓内 17/38 计划中招）；3 调用方零波及 | ✅ Read findings S3 节（25 格矩阵+裁决论证） | ✅ |
| 5 | Phase 1/S4 | executor | 2026-09-27 | S4 取证：template-guide 计数实测+锚漂移归因 | ✅ | subagent-state/4-executor.md | status=done；三声明归因闭环（:60=21/:66=21/:74=20 均过时，variant 13→15 归因 d6a0f76+51ca883）；:69 定案=契约安全行正则与两脚本现状失配，修正面 :69+:74；template-mapping 同型漂移 2 处登记不修 | ✅ Read findings S4 节抽查 | ✅ |
| 6 | Phase 2/S5 | executor | 2026-09-27 | S5 修复：check-conflicts :123-145 INDEX 解析（worktree 内） | ✅ | subagent-state/5-executor.md | status=done；commit 59b1471（+5/-1）；end 模式改 `^[^|]`+中段滤分隔行；夹具真冲突 A 触发+pending 门控正常；主仓真实形态 38 数据行零误滤；selftest 6/6 | ✅ 主进程 git show 复核 diff+findings S5 节 | ✅ |
| 7 | Phase 2/S6 | executor | 2026-09-27 | S6 修复：:147-170 自计划跳过路径归一（worktree 内） | ✅ | subagent-state/6-executor.md | status=done；commit cba40ec（+5/-1）；候选 a 构造点归一 plan_dir="$repo/plans/$task_id"；自跳过/他检测/相对 repo 三场景+selftest 6/6 全过 | ✅ 主进程 git show 复核变更行 | ✅ |
| 8 | Phase 2/S7 | executor | 2026-09-27 | S7：CC-06 夹具按真实 INDEX 形态改造+selftest 头注刷新 | ✅ | subagent-state/7-executor.md | status=done；commit 7bdd6ff（+50/-14）；7/7 PASS（新增 CC-07 自跳过用例）；负向验证双断言非恒真；夹具与真实 INDEX 逐字节一致 | ✅ Read findings S7 节（断言清单+形态对照） | ✅ |
| 9 | Phase 3/S8 | executor | 2026-09-27 | S8 修复：check_phase_order 初值误报（worktree 内） | ✅ | subagent-state/8-executor.md | status=done；commit f3966eb（+5/-1）；初值 pending→none；四夹具+probe-e 五组验证（误报消/真越级保持/既有行为不变） | ✅ 主进程 git show 复核变更行 | ✅ |
| 10 | Phase 3/S9 | executor | 2026-09-27 | S9 修复：check_scope_breach 接 plan_parse_scope 列限扩展（worktree 内） | ✅ | subagent-state/9-executor.md | status=done；commit 11c294c（+20/-8 两文件）；四夹具 pre/post 全过（反向风险消除+fail-open 保持）；38 计划单参 byte-identical+sync-todos 对拍零波及 | ✅ 主进程 git show 复核 lib diff | ✅ |
| 11 | Phase 4/S10 | code-assistant | 2026-09-27 | S10：template-guide :69 区行号锚改章节锚（worktree 内） | ✅ | subagent-state/10-code-assistant.md | status=done；commit 35cd075（+2/-2）；:65 引用清零；:69 契约安全行按 S9 接库后现状改写（区分两脚本调用形态） | ✅ Read worktree 文件现状核对两行 | ✅ |
| 12 | Phase 4/S11 | code-assistant | 2026-09-27 | S11：计数声明按 S4 实测修正（worktree 内） | ✅ | subagent-state/11-code-assistant.md | status=done；commit e5a402d（+5/-5）；23 口径/22 锚数/25 实数自洽+零残留；:32 §2.2 同型漂移+template-mapping 漂移登记留后续 | ✅ 主进程复核 diff 全文 | ✅ |
| 13 | Phase 5/S12 | executor | 2026-09-27 | S12：新建 selftest-check-drift.sh 行为级用例（worktree 内；承载文件已裁决=新建，grep 实证无既有承载） | ✅ | subagent-state/12-code-runner.md | 首派 mini Provider 拒绝→22.3③ 升档 executor 重派；status=done；commit 8b3bab0（+155 selftest+registry.tsv 1 行）；6 用例 6/6+负向验证非恒真+registry 33/33 | ✅ Read findings S12 节+主进程复跑全量佐证 | ✅ |
| 14 | Phase 5/S13 | 主进程 | 2026-09-27 | S13：全量回归逐脚本实跑求和（mini 档已实证 Provider 拒绝，机械验证命令白名单③接管） | ✅ | 无（主进程执行） | 33 脚本 525 PASS/0 FAIL 全 rc=0（≥518 基线；518+1+6 闭环） | ✅ 主进程实跑输出逐脚本留 progress | ✅ |

## Key Questions

1. sed 区间模式 `/^| Task ID/,/^|-------/` 在真实 INDEX.md（表头第 2 行即分隔行）下提前终止的确切行为与 1a 恒空的完整证据链？（Phase 1 S1 实测定案）
2. 1b 自计划跳过恒不等是路径形态（相对 vs $repo 绝对）还是空白未剥？修复取归一路径还是归一比较键？
3. plan_parse_scope 点分整格语义与 check-drift「允许的文件」列语义是否一致——3b/3c 接库还是状态机化？（Phase 1 S3 裁决）
4. template-guide 计数三声明（§2.3=21 / §2.4 锚=21 / §2.5=20）与实测（核心 10+variant 15、grep 锚 22）差值归因——v074 后新增了哪些带该章节的模板？修正基准值取多少？
5. check-drift 行为级用例承载文件：新建 selftest-check-drift.sh 还是既有某 selftest 追加？（Phase 1 S2 确认，避免误增脚本数影响 registry/sync-index 对账）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| template_type=bugfix + plan_tier=standard（调用方显式指定） | 四组均为缺陷行为恢复非新功能；standard 档触发 FMEA/委派率/Handoff 全门控 |
| interaction_mode=silent | 自主会话，用户已显式点名缺陷清单（v091 verification.md:24 登记），无中途用户决策点；遗留裁决项仅 Phase 1 S3 接库裁决（机制事实可判定，非用户偏好） |
| code_review=required | 恒空/恒跳过类缺陷修复属行为语义变更，需独立审查视角防「修 A 破 B」（FMEA 第 2/3 行） |
| 委派率 5/6（Phase 1-5 子代理，Phase 6 主进程白名单①②） | 25.3 白名单 git 编排+簿记；业务修复全部下沉，主上下文只留裁决与验收 |
| Rule 36 声明：无功能性删除，全部为缺陷行为恢复 | 材料包「验收与约束基线」节明示；36.4 清单=空；删除基线=git 历史 |
| check-drift 佐证地位不变，禁止恢复双跑/删脚本 | 材料包缺陷 3「定位如实披露」节（v091 S26 裁决延续） |
| CC-06 夹具随 1a 修复同步改造（同 Phase 内 S7） | 材料包「夹具联动」节+progress.md:84 登记；分离改造会造成中间态 selftest 红灯 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- **铁律**：根因未明禁止进入修复（VC-1 门控，Phase 1 复现是 Phase 2/3/4 的前置）
- 材料包即 S-unit 材料包源：/mnt/data/dev/task-planner-skill/plans/task-v092-guard-quirk-fixes/materials/defect-evidence.md（39 行，五组缺陷锚点全带 file:line）
- knowledge-brief.md 五段已由 plan-writer 计划期产出；执行期各 S-unit 完成后回填 §2/§3
- 每 2-3 个 Phase 完成 → Skill("task-drift-guard")（佐证地位，主进程自查为主）
- 修复基线 master 0b2208b；基线 selftest=518 PASS/0 FAIL（32 脚本，v091 verification.md:16 实测）
- 不动文件：findings.md/progress.md/notepad-learnings.md/verification.md 的 stub 结构由主进程与执行体维护（plan-writer 仅此四文件不初始化正文）
