<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-planctl-exec-surface-20261122

- task_id: `task-planctl-exec-surface-20261122`
- 时间: created_at=2026-11-21T20:32:16Z / updated_at=2026-11-21T21:43:17Z
plan_tier: standard
execution_lane: L1
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（目标）** sess_1d7e33d6 会话中「planctl CLI+JSON 为默认」完全没被使用（plan-state.json 空壳+4 MD 手写）——根因修复：把 CLI 口径落到执行者实际读到的 4 个面
- **R2（目标）** 修复不破坏既有面：全量回归零新增 FAIL + 四位部署逐位 diff=0
- **R3（目标）** 行为面真正用起来：tmp 冒烟全链 CLI 流（init→add→render→attest）exit 0 且 MD 为派生视图

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 目标 | sess_1d7e33d6 会话中「planctl CLI+JSON 为默认」完全没被使用（plan-state.json 空壳+4 MD 手写）——根因修复：把 CLI 口径落到执行者实际读到的 4 个面 | VC-1, VC-2, VC-3, VC-4 |  |
| R2 | 目标 | 修复不破坏既有面：全量回归零新增 FAIL + 四位部署逐位 diff=0 | VC-5 |  |
| R3 | 目标 | 行为面真正用起来：tmp 冒烟全链 CLI 流（init→add→render→attest）exit 0 且 MD 为派生视图 | VC-6 |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | 4 个执行面（init-session 输出/模板契约行含 29 variant/hook 教学文案/attest 空壳 WARN）全部切换 planctl 口径，旧教学字面清零 | VC-1/2/3 实弹 PASS+hook 生产注入新文案实证（T3） |  |
| G2 | 全量 selftest 与基线对比零新增 FAIL；zcode/agents/claude/cursor 四位部署 diff=0 且部署位 selftest 复跑绿 | 全量 selftest 逐脚本一致（1440 断言零新增 FAIL）+VC-5 DEPLOY-DIFF-0-REAL |  |
| G3 | tmp 行为面冒烟：按 init 新输出指引走 planctl add→render→attest 全链 exit 0，4 MD 带 GENERATED_HEADER | tmp 冒烟全链 exit 0+GENERATED_HEADER+主计划纯 CLI 流多次锁定（T2） |  |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 | 执行面口径切换 | 4 个执行面（init-session 输出/模板契约行含 29 variant/hook 教学文案/attest 空壳 WARN）全部切换 planctl 口径，旧教学字面清零 | VC-1/VC-2/VC-3 命令全 pass（grep 旧字面=0+init 输出块 tmp 实测） | S2, S3, S4, S5, S6, S7 | pending |
| G2 | 回归与部署零破坏 | 全量 selftest 与基线对比零新增 FAIL；zcode/agents/claude/cursor 四位部署 diff=0 且部署位 selftest 复跑绿 | VC-5 命令（四位 diff=0）+ 全量 selftest 基线对比 | S9, S10 | pending |
| G3 | 行为面闭环冒烟 | tmp 行为面冒烟：按 init 新输出指引走 planctl add→render→attest 全链 exit 0，4 MD 带 GENERATED_HEADER | VC-6 命令（/tmp/planctl-smoke-out/task_plan.md 首行=GENERATED_HEADER+attest exit 0） | S11 | pending |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P0 | complete | S1 | VC-5 | 计划与隔离+传播面 grep | 2026-11-21T20:34:54Z |  |
| P1 | complete | S2 | VC-1 | init-session.sh 输出下一步 CLI 命令块 | 2026-11-21T20:40:43Z |  |
| P2 | complete | S3, S4 | VC-2 | 模板契约行改 planctl 派生口径（base4+variant） |  |  |
| P3 | complete | S5, S6 | VC-3 | 旧教学文案清零（posttooluse+sessionstart 链+SKILL 工作流行+todo-sync+examples+plan-writer+userpromptsubmit） |  |  |
| P4 | complete | S7, S8 | VC-4, VC-6 | attest 域互洽：空壳 WARN+render 补 gate 必需区块 | 2026-11-21T20:46:41Z |  |
| P5 | complete | S9 | VC-5 | selftest 断言同步+全量回归基线对比 | 2026-11-21T20:48:44Z |  |
| P6 | complete | S10 | VC-5 | merge 回 master+四位部署+清理 worktree | 2026-11-21T21:09:26Z |  |
| P7 | complete | S11 | VC-6 | 行为面冒烟+交付报告+memory |  |  |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC-1, VC-2, VC-3, VC-4 |
| R2 | VC-5 |
| R3 | VC-6 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| SKILL.md SOP 文本载体 | 散文条款执行者读不赢每次工具调用注入的 hook 旧教学（F3①） | S5/S6 执行面文案切换+速查口径 | VC-3 |
| 模板契约行+init 输出 | 「模型填写面」契约+init 仅一行输出直接引导手写 4 MD（F3②③） | S2/S3/S4 模板派生口径+init 命令块 | VC-1,VC-2 |
| attest/check 门链 | 全读 MD：JSON 空壳绿灯不可见；render 缺 66.5/51.1 区块=纯 CLI 流闭环断裂（F3④/F4） | S7 空壳 WARN+S8 render 补锚 | VC-4,VC-6 |
| 四位部署传播 | 部署位漂移风险（历史多次判例） | S9/S10 全量回归+四位 diff=0 | VC-5 |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | init-session.sh JSON init 成功路径输出「下一步」CLI 指引块且脚本内 planctl.py 提及≥4 处 | test $(grep -c planctl.py /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh) -ge 4 |  |
| VC-2 | 4 个派生视图模板（task_plan/findings/progress/verification）头部契约行改为 planctl 派生口径，「模型填写面」旧字面清零（notepad-learnings/user-session-log 为合法人工面保留除外）；variant 非 mini 档加派生警示行 | test $(grep -l 模型填写面 /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md /mnt/data/dev/task-planner-skill/skills/task-planner/templates/findings.md /mnt/data/dev/task-planner-skill/skills/task-planner/templates/progress.md /mnt/data/dev/task-planner-skill/skills/task-planner/templates/verification.md 2>/dev/null \| wc -l) -eq 0 |  |
| VC-3 | hook 旧教学清零：posttooluse 6 处「Edit task_plan.md/Edit 进 findings.md/Edit 进 progress.md」改 planctl+render 口径；task-plan-init.cjs/plan-created.cjs 追加 planctl 行 | test $(grep -c "Edit task_plan.md\\|Edit 进 findings.md\\|Edit 进 progress.md" /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-posttooluse.sh) -eq 0 |  |
| VC-4 | attest-plan.sh 空壳 WARN：fixture（plan-state.json 业务全空+task_plan.md>2KB 手写）触发 SOFT_ONLY WARN 且 exit 0 不阻断 | cd /tmp/planctl-vc4-fixture && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh 2>&1 \| grep -c SOFT_ONLY |  |
| VC-5 | 四位部署逐位 diff=0：源仓 254 个 git 跟踪文件（skills/task-planner）与 zcode/agents/claude/cursor 四位逐文件 cmp 全同（部署位含 .history/trash 运行期文件，整目录 diff-r 口径不可用） | cd /mnt/data/dev/task-planner-skill && git ls-files skills/task-planner \| while read f; do for base in /home/terry/.zcode/skills /home/terry/.agents/skills /home/terry/.claude/skills /home/terry/.cursor/skills; do cmp -s "$f" "$base/$f" \|\| { echo DIFF-$base/$f; exit 1; }; done; done && echo DEPLOY-DIFF-0 |  |
| VC-6 | tmp 行为面冒烟：init→add(requirements/goals/vcs/phases)→render→attest 全链 exit 0，render 后 4 MD 首行为 GENERATED_HEADER | test $(head -1 /tmp/planctl-smoke-out/plans/task-smoke-001/task_plan.md \| grep -c 勿直接编辑) -eq 1 |  |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 0: 计划与隔离+传播面 grep
- **Status:** complete
- **Started:** 2026-11-21T20:34:54Z
- **Executor:** 主进程（小）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1 | [P0] 建 worktree+传播面 grep 定位 pin 站点（git worktree add+grep 旧文案全集） | 主进程（小） | tmp/worktrees/task-planctl-exec-surface-20261122 | grep 清单落 findings | 10min | 只读 | 否 | - | pending |

### Phase 1: init-session.sh 输出下一步 CLI 命令块
- **Status:** complete
- **Started:** 2026-11-21T20:40:43Z
- **Executor:** 主进程（小）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S2 | [P1] init 输出追加下一步命令块（Edit 追加 4-6 行） | 主进程（小） | skills/task-planner/scripts/init-session.sh | VC-1 命令 | 10min | 1文件+10行 | 否 | - | pending |

### Phase 2: 模板契约行改 planctl 派生口径（base4+variant）
- **Status:** complete
- **Started:** 
- **Executor:** general-coder（子代理）、主进程（小）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S4 | [P2] 29 variant 头部契约行同步（逐文件头部契约行替换+登记理由） | general-coder（子代理） | skills/task-planner/templates/variant/*-type.md | VC-2 命令+抽查 Read | 25min | 29文件×1行 | 否 | - | pending |
| S3 | [P2] base4 模板头部契约行改口径（Edit 头部注释） | 主进程（小） | skills/task-planner/templates/{task_plan,findings,progress,verification}.md | VC-2 命令 | 15min | 4文件×1-2行 | 否 | - | pending |

### Phase 3: 旧教学文案清零（posttooluse+sessionstart 链+SKILL 工作流行+todo-sync+examples+plan-writer+userpromptsubmit）
- **Status:** complete
- **Started:** 
- **Executor:** 主进程（小）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S5 | [P3] posttooluse 6 处教学文案改 planctl 口径（Edit 6 处） | 主进程（小） | skills/task-planner/scripts/zcode-posttooluse.sh | VC-3 命令 | 20min | 1文件×6处 | 否 | - | pending |
| S6 | [P3] sessionstart 链+userpromptsubmit 头行（Edit 追加 planctl 提示行） | 主进程（小） | skills/task-planner/scripts/{task-plan-init.cjs,plan-created.cjs,zcode-userpromptsubmit.sh} | grep 命中 | 15min | 3文件×1-2行 | 否 | - | pending |

### Phase 4: attest 域互洽：空壳 WARN+render 补 gate 必需区块
- **Status:** complete
- **Started:** 2026-11-21T20:46:41Z
- **Executor:** 主进程（小）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S7 | [P4] attest-plan.sh 空壳 WARN 检测（Edit 写入前检测块） | 主进程（小） | skills/task-planner/scripts/attest-plan.sh | VC-4 fixture 实测 | 20min | 1文件+25行 | 否 | - | pending |
| S8 | [P4] render 补 🎯 Goal 单元表+🔍 调研区块使纯 CLI 流可过 attest（goal def 加可选字段+render 两区块+goal 数据回填） | 主进程（小） | skills/task-planner/scripts/planctl.py + schemas/plan-state.schema.json | worktree planctl render 后 attest 66.5 过 | 30min | 2文件+60行 | 否 | - | pending |

### Phase 5: selftest 断言同步+全量回归基线对比
- **Status:** complete
- **Started:** 2026-11-21T20:48:44Z
- **Executor:** 主进程（中）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S9 | [P5] selftest 断言同步+全量回归（grep pin 站点逐处同步+跑全量） | 主进程（中） | skills/task-planner/scripts/selftest* | 基线对比零新增 FAIL | 40min | 按 pin 数 | 否 | - | pending |

### Phase 6: merge 回 master+四位部署+清理 worktree
- **Status:** complete
- **Started:** 2026-11-21T21:09:26Z
- **Executor:** 主进程（中）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S10 | [P6] merge+四位部署+清理（merge --no-ff+rsync 四位+worktree remove） | 主进程（中） | 四位部署位 | VC-5 命令 | 30min | 部署位×4 | 否 | - | pending |

### Phase 7: 行为面冒烟+交付报告+memory
- **Status:** complete
- **Started:** 
- **Executor:** 主进程（小）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S11 | [P7] tmp 冒烟+报告+memory（全链 CLI 流实跑+报告） | 主进程（小） | /tmp/planctl-smoke-out | VC-6 命令 | 20min | tmp 一次性 | 否 | - | pending |

## 🧮 根源覆盖表
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| SKILL.md SOP 文本载体 | 散文条款执行者读不赢每次工具调用注入的 hook 旧教学（F3①） | S5/S6 执行面文案切换+速查口径 | VC-3 |
| 模板契约行+init 输出 | 「模型填写面」契约+init 仅一行输出直接引导手写 4 MD（F3②③） | S2/S3/S4 模板派生口径+init 命令块 | VC-1,VC-2 |
| attest/check 门链 | 全读 MD：JSON 空壳绿灯不可见；render 缺 66.5/51.1 区块=纯 CLI 流闭环断裂（F3④/F4） | S7 空壳 WARN+S8 render 补锚 | VC-4,VC-6 |
| 四位部署传播 | 部署位漂移风险（历史多次判例） | S9/S10 全量回归+四位 diff=0 | VC-5 |

## Decisions Made
| Decision | Rationale |
|---|---|
| 修复面=执行者实际读到的 4 个面（init 输出/模板契约行/hook 教学文案/attest 空壳 WARN），不新增任何拦截门 | 用户既定裁决「真正有效的是在模板写入哪一步应该使用 cli 落盘」+两次否决 PreToolUse 硬拦截；取证证明 SKILL.md 散文载体执行者读不赢 hook 注入与模板契约行 |
| hook 仅改教学文案（6 处罗盘提醒+2 处 init 提示+1 处回放头行），节奏提醒/计数器/门机制全部不动 | 此前「hook 不动」为 jsonderive 任务范围控制；本次用户投诉直指方案未被使用，PostToolUse 旧教学是每次工具调用注入的最强反向指令，不对齐则修复大概率再度失效；无任何新增拦截 |
| P4 空壳检测=warn-only 单行输出，不阻断不新增脚本，嵌入既有 attest-plan.sh | 文本优先铁律下机器断言最小化；使「JSON 空壳+MD 手写」复发立即可见而非静默绿灯，且不触碰已否决的拦截方向 |
| render 扩展：新增「## 🎯 Goal 单元表」区块（goals 新增可选字段 name/verify/s_units/status 渲染六列锚）+「🔍 调研需求与检索计划」区块（research_status），schema 同步加可选字段不进 required | JSON 全派生架构下 gate 必需区块必须可由 JSON 派生，否则纯 CLI 流无法过 attest（F4 闭环断裂）；goal 新字段全部可选保存量 validate 兼容 |
| 旧教学清零传播面按 grep 实测扩展：SKILL.md L109/L128/L222 工作流行、references/todo-sync.md S2/S5、examples.md、companion/agents/plan-writer.md 调用方约束、zcode-userpromptsubmit.sh:285 邻近引用提示、check-doc-sync.sh 注释、INSTALL.md 预期输出、CLAUDE.md:48——同类载体一并切 planctl 口径 | 传播面先 grep（判例教训）；SKILL.md L109 每 Phase 工作流与 todo-sync S2/S5 是执行者高频读取面，漏改则旧教学残留在最强载体；plan-cost-guard/billing.md 属他技能范围不动，plans/ 存量档不清理（用户裁决） |
| VC-6 判据路径修正：冒烟产物实际在 /tmp/planctl-smoke-out/plans/task-smoke-001/（init 要求 plans/<task-id>/ 目录结构），原命令少了子目录层级 | 判据冻结后修正=重锁协议（Decisions 登记+render+重跑 attest）；冒烟已实跑全链 exit 0 |
| VC-5 判据口径修正：部署位含 8570 个运行期文件（.history/trash 等），整目录 diff -r 必然误报；改为 git 跟踪 254 文件逐位 cmp | 判据必须匹配真实生产字节（判例：判据 token 匹配真实生产字节）；重锁协议登记 |
