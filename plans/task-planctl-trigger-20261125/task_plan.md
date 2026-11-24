<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-planctl-trigger-20261125

- task_id: `task-planctl-trigger-20261125`
- 时间: created_at=2026-11-24T18:16:47Z / updated_at=2026-11-24T19:17:41Z
plan_tier: standard
execution_lane: L2
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（手段）** 用户原话镜像(2026-11-25)：skill 中 planctl.py 权重被恶意降低，定位段「核心=四文件罗盘管理(task-v171 分层后)」完全没有提及 planctl.py，导致后期执行技能时核心触发完全没有被激活、直接手写四文件造成错误；一直解决技能问题一直本末倒置，核心触发不解决则所有产物都不会得到有效激活。要求恢复 planctl.py 的核心触发权重。
- **R2（手段）** 范围外(不改)：critical-rules.md 规则正文与 references 细节文档、不新增脚本/机器门/hook(文本优先铁律)、~/.claude/settings.json 等个人配置；tier-deadzone 在途计划保持原状不回滚。

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 手段 | 用户原话镜像(2026-11-25)：skill 中 planctl.py 权重被恶意降低，定位段「核心=四文件罗盘管理(task-v171 分层后)」完全没有提及 planctl.py，导致后期执行技能时核心触发完全没有被激活、直接手写四文件造成错误；一直解决技能问题一直本末倒置，核心触发不解决则所有产物都不会得到有效激活。要求恢复 planctl.py 的核心触发权重。 | VC-1, VC-2, VC-3 |  |
| R2 | 手段 | 范围外(不改)：critical-rules.md 规则正文与 references 细节文档、不新增脚本/机器门/hook(文本优先铁律)、~/.claude/settings.json 等个人配置；tier-deadzone 在途计划保持原状不回滚。 | VC-3 |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | 母版定位段+四端点薄壳 planctl.py 引擎权重恢复 |  |  |
| G2 | 合并 master+install 部署+verify+selftest+四端点对账+计划收口 |  |  |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 | 核心触发权重修复 | 母版定位段+四端点薄壳 planctl.py 引擎权重恢复 | 定位段含 planctl 唯一引擎锚+四薄壳含核心执行引擎段+selftest 零增量 | - | pending |
| G2 | 部署闭环收口 | 合并 master+install 部署+verify+selftest+四端点对账+计划收口 | verify.sh 0 fail+部署位 grep 对账+attest 重锁+commit | - | pending |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete |  |  | 取证与计划初始化 | 2026-11-24T18:18:10Z |  |
| P2 | complete |  |  | 源仓修复(SKILL.md 定位段+薄壳生成器) | 2026-11-24T18:18:12Z |  |
| P3 | complete |  |  | 部署验证与收口 | 2026-11-24T19:08:44Z |  |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC-1, VC-2, VC-3 |
| R2 | VC-3 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| （root_causes 未登记） | 结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由 | - | - |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | 母版定位段权重恢复：SKILL.md 定位标题与核心定位段以 planctl.py 为唯一执行引擎/唯一写入口表述，且保留 selftest 锚「四文件罗盘的唯一管理域」 | grep -q "核心 = planctl.py 驱动的四文件罗盘管理" skills/task-planner/SKILL.md && grep -q "四文件罗盘的唯一管理域" skills/task-planner/SKILL.md | 定位段标题含「核心 = planctl.py 驱动的四文件罗盘管理」+核心定位段含唯一执行引擎/唯一写入口+「四文件罗盘的唯一管理域」锚(grep 1/1) |
| VC-2 | 四端点薄壳(SKILL.md)均含「核心执行引擎（P0」段且生成器源含同段(防再漂移) | test $(grep -l "核心执行引擎（P0" /home/terry/.zcode/skills/task-planner/SKILL.md /home/terry/.claude/skills/task-planner/SKILL.md /home/terry/.config/opencode/skills/task-planner/SKILL.md /home/terry/.cursor/skills/task-planner/SKILL.md 2>/dev/null \| wc -l) -eq 4 | 四薄壳引擎段/链外专档/表格字面/误称=0 终检 4/4(直调 generate_stub_skill_md r3 源重生成);生成器源含同段防再漂移 |
| VC-3 | verify FAIL 集=基线 4 项既有(smart-merge-back/init-session hardcoded-paths,非本任务引入)+全量 selftest FAIL=0 | bash skills/task-planner/scripts/run-selftests.sh | verify 27 pass/4 fail(4项=smart-merge-back/init-session 既有 hardcoded-paths 基线,非本任务引入)+全量 selftest 106/106 FAIL=0(fresh, r3 终态) |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 取证与计划初始化
- **Status:** complete
- **Started:** 2026-11-24T18:18:10Z
- **Executor:** 主进程
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1.1 | [P1] 取证与计划初始化（母版/薄壳/计划三面取证+init+原话落盘+tier-deadzone 重锁） | 主进程 | 0 | 计划锁定+user-session-log 原话在位 | 10min | ≤100l | 无 | - [parallel-group:否] | pending |

### Phase 2: 源仓修复(SKILL.md 定位段+薄壳生成器)
- **Status:** complete
- **Started:** 2026-11-24T18:18:12Z
- **Executor:** 主进程
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S2.1 | [P2] SKILL.md 定位段权重修复（worktree 内改写定位段：核心=planctl.py 驱动+四视图禁手写+保留 selftest 锚） | 主进程 | 1 | grep 两锚在位+行数钉余量 | 15min | ≤30l | 无 | - [parallel-group:否] | pending |
| S2.2 | [P2] 薄壳生成器注入引擎段（install-stub.sh 四模板注入核心执行引擎段(ENGINE_BLOCK 收编现网 zcode 段)） | 主进程 | 1 | 变异复演：临时目录生成薄壳 grep 引擎段 4/4 | 15min | ≤40l | 无 | - [parallel-group:否] | pending |

### Phase 3: 部署验证与收口
- **Status:** complete
- **Started:** 2026-11-24T19:08:44Z
- **Executor:** 主进程
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S3.1 | [P3] 部署闭环（合并 master→install.sh 四位→verify.sh→全量 selftest→端点对账） | 主进程 | 0 | verify 0 fail+selftest FAIL 集不增+VC-2 4/4 | 25min | ≤100l | 无 | - [parallel-group:否] | pending |
| S3.2 | [P3] 计划收口与提交（VC 翻转+render+attest+INDEX+commit+交付报告） | 主进程 | 0 | VC 3/3 pass+计划 outcome+commit 在位 | 10min | ≤100l | 无 | - [parallel-group:否] | pending |

## Decisions Made
| Decision | Rationale |
|---|---|
| [intent-switch] 自 task-tier-deadzone-fix-20261125(执行中途中断)切至本修复任务；tier-deadzone 保持 in-flight 原状(P1 complete/夹具已建)，本任务收口后可回切 | 用户 2026-11-25 新指令三要素(计划/交付物/对象)与 tier-deadzone 无交集=D 类新任务边界；Rule 94 计划隔离 |
| [re-lock] 本计划 attest 基线(init 落盘)后的数据填充与例行状态翻转均属计划获批流程内写入；每次 render 后按 hook 分支①重跑 attest 重锁，本条为全程重锁统一前置登记 | Rule 51.7 重锁前置=Decisions 登记；本条覆盖机械性重锁，语义级重规划仍须单独登记 |
| [tier] mini→standard：保护区多文件手术（母版定位段+薄壳生成器+四端点部署闭环）体量超 mini 判据（≤15min/≤5文件），且 attest 派发门按 standard 面校验 | 同族先例=tier-deadzone 同日取 standard（多文件保护区手术复杂度已知）；运行时升级链触发同样以步骤门信号为准 |
| 登记待批遗留清单:I-2 smart-merge-back --deploy 整树覆盖薄壳且 deploy_reconcile/verify 双门难抓(修复可被合法流程静默回退)/W-1 ENGINE_BLOCK 无回归门/W-2 install 脏树静默跳 pull/NIT README+ARCHITECTURE 文档滞后——按 R2 范围约束+文本优先铁律本轮不实施,待用户授权后独立任务 | critic R1 四项遗留的诚实边界:文本修复已闭环,机器门/脚本改造属范围扩张需显式授权 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|---|---|---|---|
| Rule 19.7 回填违规: findings/progress 超阈值未回填(hook 两次升级警告) | 0 | 本条登记+本批补登记 research/actions |  |
| worktree 删除后主会话 cwd 悬空→spawn ENOENT(session 级感染子代理) | 0 | Write 占位文件重建路径+Bash 显式 cd 重锚; executor 子代理通道败后主进程直做兜底 |  |
| generate_stub_skill_md 形参序误记(out_path/style 颠倒)→四薄壳重生成全败 | 0 | 纠正为 tool_name hook_style out_path 后 4/4 OK |  |
| r3 编辑 new_string 混入乱串(TASK_PLANNER转义) | 0 | 自检发现即时修正,复演产物验证无残留 |  |
| planctl add 撞已有 id=AttributeError 崩溃而非干净报错(判例: D-1 首写已成功,重试崩溃) | 0 | 写前查重可规避;登记为 planctl 观察项 |  |
