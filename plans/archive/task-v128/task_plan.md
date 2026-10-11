# Task Plan: 规则编号预留登记制（Rule 20 扩展 20.6 + rule-reserve.sh，F1 机制化止损）
<!-- template_type: rule-enhancement -->
<!-- 沉淀出处: task-v128（2026-10-04 用户指令「处理」——落地 `plans/round-retrospective-2026-10-04.md` 推荐 #1：F1 规则编号并发竞态机制化） -->

<!-- plan_tier: standard -->
<!-- execution_lane: L1（新机制+新脚本+挂点，38.7 不适用 L0） -->
<!-- 编号自避（D1）: 本机制**不新增 Rule 号**——扩展 Rule 20（计划注入与防篡改）加 20.6 子条；编号占用全景（2026-10-04 04:0x 更新）: 48 已落地(v123) / 49 已落地(v126，已合并 48c6952) / 50 **contested**（v125 由 49 改号 + v127 自取——双双同瞄，本任务即其机制化解对象） / 51 reserved(v129，`new_rule` 字段已先行使用并请本任务补录) / 下一可用=52 -->

## Goal
落地「规则编号预留登记制」：新脚本 `scripts/rule-reserve.sh`（reserve/check/next/list/land/release 六命令，账本 `plans/.rule-reservations.jsonl`）+ `attest-plan.sh` 查重挂点（计划声明 `new_rule:` 时自动登记/冲突告警，零新 config 键）+ SKILL/条款（Rule 20.6）/计划模板联动 + `selftest-rule-reserve.sh` 守护 + 现有编号追溯登记（46-50 五条，含 49 contested），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位。

**解决的用户诉求（原话）**：「处理」——即执行复盘推荐 #1；直接动机=编号竞态已在两轮内复现（v122/v123 争 47；v125/v126 争 49；v127 只能人工自取 50 止损），需要从「事后仲裁/人工避让」升级为「计划期登记 + attest 查重」。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（代码面 4 文件 >3 → 非轻 diff，走标准 CR 单轮全量） |
| `session_id` | `fe0e5590357e4f39ad6f2dcb4909c7ae` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v128` |
| `scope_files` | `skills/task-planner/scripts/rule-reserve.sh(新建), skills/task-planner/scripts/selftest-rule-reserve.sh(新建), skills/task-planner/scripts/attest-plan.sh, skills/task-planner/scripts/selftest-registry.tsv, skills/task-planner/scripts/selftest-skill-split.sh, skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, skills/task-planner/templates/task_plan.md, plans/.rule-reservations.jsonl(新建)`（init-session.sh 豁免不实施，见 Phase 4 范围决策） |
| `interaction_mode` | `ask` |
| `对齐审查` | `[登记]` 终验前跑 alignment-review（42.6.2）；脚本/条款/文档/SKILL 四面同步核对（42.6.1） |
| `自动超时默认项` | 唯一 2+ 选项询问点=计划批准（默认=批准，超时 5 分钟按 44.3 自动执行并登记五要素）；D2/D3 逐项确认随批准生效 |
| `质量审查工具` | review-library 池成员 `code-quality-review`（42.2 四级检测命中，CR Gate 承载） |

## ✅ Verification Contract（全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|----------|
| VC-1 | `rule-reserve.sh` 六命令行为实测：reserve 空闲成功 / reserve 冲突 exit 3 且输出持有人 / check 双态 / next 跳过占用给最小可用 / list 全景含 contested / land 状态翻转 / release 仅持有人可用（非持有人 exit 4） | 临时账本 fixture 逐个实跑 | progress.md Test Results |
| VC-2 | `attest-plan.sh` 挂点三态行为：① 计划声明 `new_rule: NN` 且空闲 → 自动登记 + INFO；② 他人持有/contested → WARN + next 建议（不阻断）；③ `TASK_PLANNER_RULE_RESERVE_STRICT=1` → 冲突时 exit 2；④ 未声明 `new_rule` 的计划零影响（原行为逐字不变） | 三个 fixture 计划（临时目录）实跑 attest | progress.md Test Results |
| VC-3 | 文档与数据联动：SKILL 计划期指引锚 + `critical-rules.md` 20.6 子条（编号预留登记+零新键声明）+ `templates/task_plan.md` 可选字段行 + 账本追溯登记 5 条（46/47/48 landed、49 contested{v125,v126}、50 reserved{v127}） | grep 逐锚 + `cat plans/.rule-reservations.jsonl` | SKILL.md / critical-rules.md / task_plan.md 模板 / 账本 |
| VC-4 | `selftest-rule-reserve.sh` 全 PASS（静态锚 + 行为 fixture，含负向有牙齿）+ registry 46=46 一致 + 全量回归 0 FAIL（**总数=主进程逐脚本 Total 行求和**；基线 45 脚本 702/0〔v126 合并后〕→ 预期 46 脚本） | 单跑 + 全量 `for f in scripts/selftest-*.sh` | progress.md Selftest Log |
| VC-5 | 独立验证：CR（code-quality-review）verdict + 全新子代理独立行为审计（六命令三态复跑 + attest 挂点 fixture 复跑）+ alignment-review verdict=APPROVED | 三份独立报告 | subagent-state/ |
| VC-6 | 合并回 master（`--no-ff`，含 master 前进合流预案）+ 3 实体位 ALL IDENTICAL + worktree/分支清理 + 簿记（含账本入库） | `smart-merge-back.sh <wt> --deploy` 输出 | progress.md 合并段 |

**终验规则**：全 VC 通过 → COMPLETE；VC 通过有遗留 → PARTIAL；≥1 VC 失败重试 3 次无效 → BLOCKED。

## ⚠️ 执行范围限制（只操作列表内文件）

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| 新脚本 | `scripts/rule-reserve.sh`、`scripts/selftest-rule-reserve.sh` | —— |
| 挂点 | `scripts/attest-plan.sh`（仅追加查重段：新增 ~15 行，原逻辑零改动）、`scripts/init-session.sh`（仅追加 1 行提示） | 改既有两脚本既有行为 |
| 登记面 | `scripts/selftest-registry.tsv`（+1 行）、`scripts/selftest-skill-split.sh`（T-主 447→新值，label 注明 task-v128） | 改其他断言 |
| 文档 | `SKILL.md`（净增 ≤4 行：计划期指引 + 终验簿记提醒）、`references/critical-rules.md`（Rule 20 块内追加 20.6，**不改 Rule 号**）、`templates/task_plan.md`（配置表 +1 行可选字段） | 动 Rule 49/50 相关面（v125/v126/v127 所有）；改既有规则语义 |
| 数据 | `plans/.rule-reservations.jsonl`（新建+追溯登记） | 改其他 plans 任务产物 |
| 配置 | `config.json` 零改动（零新键；严格档=env `TASK_PLANNER_RULE_RESERVE_STRICT`） | 动既有键 |

**锚定级联预警**：SKILL 行数（现 449，T-主 ≤449，演进链 440→442→444→447→449）——本任务净增 ≤4 行须同步上调 T-主 定数（预计 451，label 注明 task-v128）；`selftest-skill-split.sh` 与 v125 计划范围重叠（其将再演进至实际值）→ 合并乱序时后者按实际行数重锚（FMEA 登记）；registry +1 行须与 selftest-registry.sh 计数断言同步。

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 复盘报告 F1 全文 | `plans/round-retrospective-2026-10-04.md` §F1 | ☑（规划期已读） |
| 项目内部 | attest 门控链范式（既有 gate 追加段写法） | `scripts/attest-plan.sh`（template-gate/fmea-gate 段） | ☑ |
| 项目内部 | 脚本头注释四要素 + 断言范式 | `scripts/selftest-template-lifecycle.sh` / `scripts/check-delegation.sh:1-40` | ☑ |
| 项目内部 | 队列式工具脚本先例（bash+jq 风格） | `scripts/ledger-append.sh`、`scripts/subagent-fallback.sh` | 必读 |
| 项目内部 | 编号占用现状（46-50） | 本计划头注 + findings §种子数据 | ☑ |
| 项目内部 | 在途冲突面（v126 执行中/v127 规划中/v125 挂起） | `plans/task-v126/task_plan.md`、`plans/task-v127/findings.md` | ☑（侦察已读） |

## ⚠️ 核心问题定义
**核心问题**：Rule 编号无所有权凭证——多会话并行时靠「先发现者避让 / 后到者仲裁 / 人工取号」维持，已两轮复现（47、49），仲裁失败成本=全量重编号（子条锚/守卫断言/索引/文档）。
**判断**：[x] 机制化后编号冲突在**计划期**（attest）即被检出并给出 next 建议，把事后仲裁变事前登记；[x] 不解决则每次并行都重复人肉协调；[x] 解法清晰=登记账本+attest 查重+next 建议，零新键、fail-open 不伤既有链路。

## Current Phase
**COMPLETE（2026-10-04 06:3x 终验通过：check-complete exit 0，VC-1..6 全过，outcome=COMPLETE）**

## Next Step
无——任务已交付。用户面总结=`plans/task-v128/delivery-summary.md`（含 Rule 51.3 需求覆盖核对）；后续候选见其 §5（v125 改号提醒 / 复盘 F2-F6）

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| P1 | 主进程 worktree + Agent executor（基线） | git 编排=白名单①；基线=机械执行 |
| P2 | Agent executor(sonnet-1) | bash 脚本判断型实现（六命令+账本） |
| P3 | Agent executor + code-assistant | 挂点=判断型；文档行内=机械 |
| P4 | Agent code-assistant + executor | selftest 范式复制；全量回归机械 |
| P5 | Agent 三路全新独立视角 | 验证独立性（43.1） |
| P6 | 主进程（白名单①②③）+ smart-merge-back | 合并/部署/簿记 |

**workflow 编排判定**：未命中（用户未点名 /workflow）→ Rule 21.4 守门调度
**/goal 对齐**：未使用

## Phases

### Phase 1: 隔离与基线
- [x] worktree 建立（`/mnt/data/dev/task-planner-skill-worktrees/task-v128`，分支 `wt/task-v128`，接 master **48c6952**〔B 类修订后〕；2026-10-04 04:0x 建立）
- [x] S1 全量 selftest 基线（45 脚本，改前）——45/45 rc=0，ΣPASS=702 FAIL=0
- **V-N:** VC-4（基线面 ✓ 702/0@48c6952）
- **Status:** complete（2026-10-04 04:2x；wt 零产物 → Rule 27 skip；3-File gate exit 0）
- **Executor:** executor（S1）；worktree 建立=主进程（白名单①）
| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | 全量 selftest 基线（45 脚本逐 Total 记录） | executor(sonnet-1)（mini provider 拒先例，直接改派） | wt:`scripts/selftest-*.sh` | 45/45 rc 记录 + ΣPASS 原文（预期 702） | 10min | complete |

### Phase 2: 核心脚本实现
- [x] S2 `rule-reserve.sh` 六命令 + 账本 JSONL schema + 头注释四要素——自测 8/8；commit **46bb036**（+408 行；原手记 622ca3e 系笔误，S10 对齐审查 P2 发现后修正）
- **V-N:** VC-1 ✓（六命令+contested+append-only+降级全绿；主进程独立抽查）
- **Status:** complete（2026-10-04 04:5x；3-File gate 预检；产物已提交）
- **Executor:** executor(sonnet-1)
| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|----|------------|--------|------|------|------|------|
| S2 | 按 findings §设计冻结 实现 `scripts/rule-reserve.sh`（reserve/check/next/list/land/release；账本 `plans/.rule-reservations.jsonl`；冲突 exit 3、越权 release exit 4；jq 缺失降级 grep 解析） | executor(sonnet-1) | wt:（新建）+ `plans/task-v128/findings.md`（§设计冻结） | 六命令用临时账本 fixture 实跑全过（贴输出） | 20min | complete |

### Phase 3: 挂点与文档联动
- [x] S3 attest-plan.sh 查重挂点（declare `new_rule:` → check/reserve/WARN/STRICT）——四态+SKIPPED 全过，+64/-0
- [x] S4 SKILL 两行 + T-主 定数（449→451）——两锚命中，41/41
- [x] S4b Rule 20.6 子条 + 模板 `new_rule` 行——两锚命中，纯增量
- **V-N:** VC-2 ✓（四态 fixture + F4 diff 零 + SKIPPED fail-open）、VC-3 ✓（SKILL/CR/模板 五锚到位）
- **Status:** complete（2026-10-04 05:1x；产物 commit 见 Phase 3 提交；3-File gate 预检）
- **Executor:** executor(sonnet-1)（S3）+ code-assistant(haiku-1)（S4）
| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|----|------------|--------|------|------|------|------|
| S3 | `attest-plan.sh` 追加查重段（解析计划 `<!-- new_rule: NN -->` 或配置表行；空闲自动登记、冲突 WARN+next、STRICT env→exit 2、缺脚本 fail-open 跳过；既有门控输出零变化） | executor(sonnet-1) | wt:`scripts/attest-plan.sh` + findings（§挂点契约） | 四态 fixture 实跑（空闲/冲突/WARN/STRICT）+ 未声明计划原行为 diff 零 | 20min | complete |
| S4 | SKILL 两行指引 + T-主 定数级联（449→451，label 注 task-v128） | code-assistant(haiku-1) | wt:`SKILL.md` `scripts/selftest-skill-split.sh` + findings（§D4 文案） | 两锚 grep 命中；`wc -l`=451；skill-split 复跑 PASS | 12min | complete |
| S4b | Rule 20.6 子条 + `templates/task_plan.md` 配置表 `new_rule` 行 | code-assistant(haiku-1) | wt:`references/critical-rules.md` `templates/task_plan.md` + findings（§D4 文案） | 两锚 grep 命中；既有 Rule 1-49 原文零改动 | 10min | complete |

### Phase 4: 守卫 + 回归 + 数据
- [x] S5 `selftest-rule-reserve.sh` + registry 登记——10/10（负向有牙齿）；registry 46=46
- [x] S6 账本追溯登记（六条 46-51）——jq 全解析；list/next 正确（next=52）
- [x] S7 全量回归（46 脚本）——46/46 rc=0，ΣPASS=712 FAIL=0
- **V-N:** VC-3 ✓（种子六条全景）、VC-4 ✓（712/0 + 负向实证）
- **Status:** complete（2026-10-04 05:5x；产物 commit **8bf2151**（3 文件 +550）；3-File gate exit 0）
- **范围决策**：init-session.sh 提示行（scope 允许集内）**豁免不实施**——SKILL:75 指引 + 模板 `new_rule` 字段 + attest 自动登记已构成三触点，第四触点冗余（YAGNI，登记）
- **Executor:** code-assistant(haiku-1)（S5/S6）+ executor（S7）
| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|----|------------|--------|------|------|------|------|
| S5 | 新建 `selftest-rule-reserve.sh`（静态锚：脚本/账本路径/六命令用法串/STRICT env 名 + 行为 fixture：reserve 冲突 exit3、next 跳过占用、release 越权 exit4，含负向必 FAIL 自检）+ registry +1 行 | code-assistant(haiku-1) | wt:`scripts/` + findings（§TL 定义） | 单跑全 PASS + 负向实测 + registry 46=46 | 15min | complete |
| S6 | 账本追溯登记 6 条（46/47/48/49 landed、50 contested{v125,v127}、51 reserved{v129}）写入 `plans/.rule-reservations.jsonl` | code-assistant(haiku-1) | findings（§种子数据 D4b） | `list` 输出全景正确、`next`=52 | 8min | complete |
| S7 | 全量回归（46 脚本逐 Total） | executor(sonnet-1) | wt:`scripts/selftest-*.sh` | 46/46 rc=0，总数主进程求和（预期 712） | 10min | complete |

### Phase 5: 独立验证
- [x] S8 CR（code-quality-review，标准单轮）——**APPROVED**（P0/P1=0；P2×2 记录：reserve 竞态建议 flock、task-id 正则转义）
- [x] S9 独立行为审计（六命令+attest 四态+坏输入×6）——4/4 PASS，与 CR P2 定档一致
- [x] S10 alignment-review——**APPROVED**（P0=0；P2×1=hash 笔误已修正）
- **V-N:** VC-5 ✓（三路独立验证齐）
- **Status:** complete（2026-10-04 06:0x；本 Phase 零 wt 产物；3-File gate 预检）
- **Executor:** executor(sonnet-1)（S8/S9/S10 三路独立视角；S9 为独立行为审计）
| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|----|------------|--------|------|------|------|------|
| S8 | CR Gate：`git diff master` 全量（代码面 4 文件）单轮审查 | executor(sonnet-1)+Skill(code-quality-review) | wt diff | APPROVED 或清单 | 15min | pending |
| S9 | 独立审计：六命令三态 + attest 四态 fixture 独立复跑 + 账本 schema 校验 | executor(sonnet-1) | wt 脚本 + findings | 逐项 PASS/FAIL + 反例区分度 | 15min | pending |
| S10 | alignment-review 四要素（脚本/条款/SKILL/模板/账本五面） | executor(sonnet-1)+Skill(alignment-review) | wt diff + 本计划 | APPROVED（P0=0） | 12min | pending |

### Phase 6: 合并回 + 部署 + 簿记
- [x] 部署前方向审计（3 位 vs 本支：差异=本任务 6 文件+2 新脚本；位内专有=历史备份目录/stray .zcode，非前向更新）——安全
- [x] `smart-merge-back.sh <wt> --deploy`——**merge 67e6c3f**（V1-V6 全过）；3 实体位 ALL IDENTICAL rc=0；含 v126/v127/v129 合流（单点冲突按 454 解决）
- [x] 账本首次真实运维：`land 50 task-v127` / `land 51 task-v129`（contested 解除，next=52；commit 31e4230）
- [x] worktree/分支清理 + 主仓 Read 复验（454/555；三文件在位；3 位抽查）
- [x] verification.md 回填 + check-complete exit 0 + 交付总结（新模板 Rule 51.3 需求覆盖核对版，落盘+chat）+ memory/INDEX/档案入库
- **V-N:** VC-6 ✓, VC-5 ✓
- **Status:** complete（2026-10-04 06:3x）
- **Executor:** 主进程（白名单①②③）+ executor（S11 冲突解决 / S12 合流后回归）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①15 项 plans 簿记/信号②③ v126 活跃 worktree（已提交 5f66bd8）/信号④4 未完成任务；均不在本任务 scope，同文件区（SKILL/skill-split/CR 尾）与 v125/v126/v127 有潜在合并冲突——按序号并存+按实际重锚处置） |
| `isolation` | `worktree`（§11.1 条款 1） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v128` |
| `branch` | `wt/task-v128` |
| `merge_back` | `pending` |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P3 | attest 挂点缺陷致**全仓后续 attest 受损**（高影响） | 9 | 3 | 2 | 54 | 新增段 fail-open（脚本缺失/解析失败→跳过不阻断）+ fixture 四态实测 + 未声明计划原行为 diff 零复核 |
| P4 | T-主 定数与 v125 双改同文件冲突 | 6 | 5 | 2 | 60 | 合并乱序按实际行数重锚（label 各自注明）；冲突解决后全量复跑 |
| P4 | registry 计数与新增脚本不一致 | 5 | 4 | 2 | 40 | selftest-registry 断言 45=45 复核 |
| P5 | 审计发现命令边界缺陷（如并发写账本） | 5 | 4 | 3 | 60 | 计划内 fix 回路；账本写入用 >>（append）原子行 |
| P6 | master 前进（v126/v127 合并）冲突 | 6 | 6 | 2 | 72 | 预登记「按序号并存 + 按实际重锚」口径；解决后全量复跑 |
| 全任务 | ENOSPC 复发 | 9 | 2 | 2 | 36 | 写前 df 检查（memory 教训已录） |

## 🔁 原生 Todo 同步
| Phase | Todo 已建 | 最近同步 | 备注 |
|-------|-----------|---------|------|
| P1-P6 | ☐ | | |

## Key Questions
1. 为什么不新增 Rule 号？→ 机制=规划/防篡改域，扩展 Rule 20 最贴切；且**示范自身主张**（编号是稀缺资源，能扩就不新占）；若后续需要独立成条，下一可用=51。
2. 为什么挂 attest 不挂 init-session？→ attest=计划锁定时刻（门控链已有位置、单点收口）；init 只加提示行（计划期尽早可见）。
3. 与 v125/v126/v127 的关系？→ 零接触其产物；本任务落地后，v125 改号与 v127 的 50 预留均可在机制下复核；追溯登记含 49 contested 快照。
4. 零新 config 键如何严格化？→ env `TASK_PLANNER_RULE_RESERVE_STRICT=1`（对齐 TASK_PLANNER_SKILL_MODIFY_ENFORCE 先例）。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| D1 机制自避编号（扩展 Rule 20，不新增 Rule） | 「能扩不新占」示范机制主张；避免给机制自身制造一次编号协调 |
| D2【逐项确认 1/2】`rule-reserve.sh` 接口六命令与账本 schema（见 findings §设计冻结） | 纯新增脚本，无既有面改动；计划批准即确认 |
| D3【逐项确认 2/2】`attest-plan.sh` 追加查重段（~15 行，fail-open，默认 WARN 不阻断） | 纯增量；影响全仓 attest 链路→fixture 四态 + 原行为零变化实测硬门 |
| D4 账本追溯登记 46-50（含 49 contested 快照） | 机制上线即带真实全景；contested 如实记录不代裁 |
| D5 严格档用 env 不加 config 键 | 对齐既有 enforce env 先例；保持零新键 |
| D6 执行通道 L1 | 新脚本+挂点+文档，38.7 排除 L0 |
| 思路复述已呈示,2026-10-04 | Rule 28.2.1（见会话） |
| **B 类修订（2026-10-04 04:0x）**: master 前进 0f077ae→48c6952（v126 完成并入：Rule 49 落地 + 45 脚本 702/0 + SKILL 449/T-主≤449）；v124 转 Phase 3、v129 新在途 | 基线随之上移（S1=45 脚本；T-主 目标 451）；v129 已先行使用 `new_rule: 51` 并请求补录 → 种子增第 6 条；**50 现行竞态（v125 改号 + v127 自取）如实登记为 contested**——本机制的首个真实对照样本 |
| **B 类修订 #2（2026-10-04 05:5x）**: master 再前进 48c6952→1156786（**v129 完成并入：Rule 51 落地 + SKILL 449→451 + T-主 451 + registry 47 + 46 脚本 717/0 + delivery-summary 67→75**）；v127/v124 各建 worktree 转向执行 | ① 本任务真实 diff 一律以**基点 48c6952** 计（9 文件 +594/-1），CR/审计禁用 `git diff master`；② Phase 6 合并后级联重算：SKILL=**453**（449+本任务 2+ v129 2）、T-主=**453**（双方均已改同一行→冲突解决按 453+双 label）、registry=**48**、脚本=**47**、预期 ΣPASS=**727**（717+本任务 10）；③ 账本 51 条目本性应转 **landed**（v129 已合并 1156786）——Phase 6 用 `rule-reserve.sh land 51 task-v129` 执行（机制首次真实运维） |
| **D1 自动裁决【Rule 44.3】**: 计划批准询问未获答复 → 按推荐默认项「批准，按计划执行」自动放行 | 五要素——超时值: 约定 5 分钟；推荐项: D1 批准；触发时间: 2026-10-04 03:56；裁决理由: 用户「处理」指令明确（=执行复盘推荐 #1）+ worktree 隔离 + 独立验证兜底 + 全程可撤回（合并前零主仓写入）；被覆盖选项: 「只做账本+脚本（不挂 attest）」「暂停审计划」 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
|       | 1       |            | → progress.md Error Log |

## Notes
- 主进程写计划文件=白名单②；侦察（v126/v127/v125 状态+编号全景）已完成并落 findings
- dogfood：本任务 attest 时声明 `new_rule: none`（不占号）——机制上线后首个「零影响」自证
- 禁触：`plans/task-v124|125|126|127/**` 与 `wt/task-v126` worktree（并行会话产物，§11.4）

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-04 P1 后 | ALIGNED | VC-4 | B 类修订后 Phase 1 全在计划内（worktree@48c6952/基线 702/0）；wt 零产物；50 竞态与 v129 请求已如实登记（种子 6 条） |
| 2026-10-04 P2-P5 后 | ALIGNED | VC-1..5 | S2-S10 全在计划内；两处笔误（hash/Executor 字段）经独立验证发现并修正；无计划外写入 |
| 2026-10-04 P6 后（终检） | ALIGNED | 全部 | B 类修订 #2 合流为预登记预案执行（单点冲突按 454）；账本运维=机制首用（计划内）；交付范围=scope_files 全集 |

## 📊 委派统计（终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | **4 / 6**（P2/P3/P4/P5 全子代理；P1/P6 主进程白名单直做）——stats JSON：phases_total=6, delegated=4, rate=0.667, violations=[], verdict=ok |
| 主进程直做 Phase 清单 | P1（worktree 建立·白名单①；S1 实为子代理）、P6（白名单①②③ 编排/簿记/机械 diff） |
| 委派率 | 0.667 < 0.7 → **WHITELIST-EXEMPT 放行**（直做理由全命中白名单，self_declared=0，violations 空）；S-unit 级 13 次派发（S1-S12+S4b）全单一目标 |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint | 备注 |
|---|------|--------------|----------------|------|---------|------|--------------|-----------|------|
| 1 | 2026-10-04 04:1x | executor | S1 全量 selftest 基线（45 脚本，预期 702） | done | 45/45 rc=0；ΣPASS=702 FAIL=0（bc 复核一致）；wt porcelain 空；无异常无重试 | 检查点 1-executor.md + 结果原文 | findings R4 | plans/task-v128/subagent-state/1-executor.md | - / 0 / ☑（主进程 bc 求和+Read 检查点） |
| 2 | 2026-10-04 04:2x | executor | S2 rule-reserve.sh 六命令实现（按 findings §D2） | done | 六命令+contested+append-only+jq 降级全过（自测 8/8）；git 实测 +408 行（0→408，executable）；主进程抽查 next→52 / check 50→contested rc=3 | wt:scripts/rule-reserve.sh（新建） | findings R5 | plans/task-v128/subagent-state/2-executor.md | - / 0 / ☑（主进程 bash -n+临时账本抽查+commit **46bb036**） |
| 3 | 2026-10-04 04:5x | executor | S3 attest-plan.sh 查重段（fail-open 四态） | done | +64/-0 纯增量；四态+SKIPPED 全过（STRICT exit 2 / F4 逐字节 diff 零）；仅锁定路径生效 | wt:attest-plan.sh:199-268 区 | findings R6 | plans/task-v128/subagent-state/3-executor.md | - / 0 / ☑（主进程 git diff 逐行复核） |
| 4 | 2026-10-04 05:0x | code-assistant | S4 SKILL 两行 + T-主 定数级联 | done | :75/:158 两行；wc -l=451；skill-split 41/41（新定数 451）；+2/-0 与 +1/-1 | wt:SKILL.md:75,158；wt:selftest-skill-split.sh:41 | findings R6 | plans/task-v128/subagent-state/4-code-assistant.md | - / 0 / ☑（主进程 sed/grep 复核） |
| 5 | 2026-10-04 05:0x | code-assistant | S4b Rule 20.6 + 模板 new_rule 行 | done | CR :135 20.6 子条（逐字同定稿）+ 模板 :33 字段行；两文件纯增（+2/-0、+1/-0） | wt:critical-rules.md:135；wt:templates/task_plan.md:33 | findings R6 | plans/task-v128/subagent-state/4b-code-assistant.md | - / 0 / ☑（主进程复核） |
| 6 | 2026-10-04 05:2x | code-assistant | S5 selftest-rule-reserve + registry +1 | done | RR-01..10 全 PASS（Total 10/10）；负向牙齿实测（抹锚→RR-03 同款 FAIL）；registry 46=46；RR-06 fixture 首跑暴露设计错并修正留痕 | wt:selftest-rule-reserve.sh（+135）；wt:selftest-registry.tsv（+1） | findings R7 | plans/task-v128/subagent-state/5-code-assistant.md | - / 0 / ☑（主进程单跑复证 10/10+46=46） |
| 7 | 2026-10-04 05:3x | code-assistant | S6 账本追溯种子 6 条 | done | 6 行 JSONL 逐字落盘；jq 全解析；list 49/50/51 三行在位；next=52 | wt:plans/.rule-reservations.jsonl（+6） | findings R7 | plans/task-v128/subagent-state/6-code-assistant.md | - / 0 / ☑（主进程 Read 检查点+命令复核） |
| 8 | 2026-10-04 05:4x | executor | S7 全量回归（46 脚本） | done | 46/46 rc=0；ΣPASS=712 FAIL=0（=702+10；bc 复核一致）；无异常无重试 | 检查点 7-executor.md | findings R7 | plans/task-v128/subagent-state/7-executor.md | - / 0 / ☑（主进程 bc 求和+Read 检查点） |
| 9 | 2026-10-04 05:5x | executor | S8 CR Gate 全量单轮（基点 diff 9 文件） | done | **APPROVED**（P0/P1=0；P2×2=reserve 竞态建议 flock/task-id 正则转义）；20 路并发 append 无撕裂实测；exit 契约 0/3/4/5 吻合 | 检查点 8-executor.md | findings R8 | plans/task-v128/subagent-state/8-executor.md | - / 0 / ☑（主进程核对 verdict） |
| 10 | 2026-10-04 06:0x | executor | S9 独立行为审计（六命令+四态+坏输入×6） | done | 4/4 PASS；与 CR P2 定档一致（含补充说明）；六坏输入全契约（fail-open/rc2/rc5） | 检查点 9-executor.md | findings R8 | plans/task-v128/subagent-state/9-executor.md | - / 0 / ☑ |
| 11 | 2026-10-04 06:0x | executor | S10 alignment-review 四要素 | done | **APPROVED**（P0=0；P2×1=hash 笔误已修正）；口径 451/47/46 三方闭合+守卫 7 项复证 | 检查点 10-executor.md | findings R8 | plans/task-v128/subagent-state/10-executor.md | - / 0 / ☑ |
| 12 | 2026-10-04 06:2x | executor | S11 合流单行冲突解决（T-主→454） | done | 逐字命中终态行；零标记；skill-split 41/41 + rule-reserve 10/10；+1/-5 | wt:selftest-skill-split.sh:41 | findings R8 | plans/task-v128/subagent-state/11-executor.md | - / 0 / ☑（主进程 merge 提交 b5318a0） |
| 13 | 2026-10-04 06:2x | executor | S12 合流后全量回归（48 脚本） | done | 48/48 rc=0；ΣPASS=734 FAIL=0（bc 复核）；porcelain 空 | 检查点 12-executor.md | findings R8 | plans/task-v128/subagent-state/12-executor.md | - / 0 / ☑ |
