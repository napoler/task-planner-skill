<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-align-mandatory-step-20261123

- task_id: `task-align-mandatory-step-20261123`
- 时间: created_at=2026-11-22T19:01:56Z / updated_at=2026-11-22T21:21:16Z
template_type: rule-enhancement
plan_tier: standard
execution_lane: L2
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（目标）** 把对齐设为修改完成后的强制必选步骤——所有任务在任何修改完成后必须执行对齐核查（用户原话#1逐字锚）
- **R2（目标）** 对齐内涵须覆盖所有设计相关文件的同步完整性：关联面四族+部署位+引用面，杜绝部分改部分丢弃
- **R3（目标）** 落地到技能必选步骤载体（Phase翻转前/终验交付/合规清单），并确保部署位同步无漂移
- **R4（目标）** 机器门实施（用户 #2 裁决①逐字授权）：check-complete.sh 加 ALIGN-ANCHOR GATE（默认 enforce，四锚全在位才放行）+ config.json 档位键 align_anchor_enforce + selftest-batch-pilot.sh BP-11 静态锚；机器门/断言脚本随 --deploy 全部署位同步（含授权 .agents）

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 目标 | 把对齐设为修改完成后的强制必选步骤——所有任务在任何修改完成后必须执行对齐核查（用户原话#1逐字锚） | VC-1 |  |
| R2 | 目标 | 对齐内涵须覆盖所有设计相关文件的同步完整性：关联面四族+部署位+引用面，杜绝部分改部分丢弃 | VC-2 |  |
| R3 | 目标 | 落地到技能必选步骤载体（Phase翻转前/终验交付/合规清单），并确保部署位同步无漂移 | VC-3, VC-4 |  |
| R4 | 目标 | 机器门实施（用户 #2 裁决①逐字授权）：check-complete.sh 加 ALIGN-ANCHOR GATE（默认 enforce，四锚全在位才放行）+ config.json 档位键 align_anchor_enforce + selftest-batch-pilot.sh BP-11 静态锚；机器门/断言脚本随 --deploy 全部署位同步（含授权 .agents） | VC-5 |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | 把对齐升格为所有任务修改完成后的强制必选步骤（步骤4硬门含精确锚『修改完成后强制对齐』） | bash 实跑 VC-1: grep -Fq "修改完成后强制对齐" skills/task-planner/SKILL.md → PASS（锚在 SKILL.md:186） | R1 |
| G2 | 对齐内涵覆盖关联面四族+部署位+引用面同步完整性，杜绝部分改部分丢弃 | bash 实跑 VC-2: grep -Fq "关联面四族+部署位+引用面" skills/task-planner/SKILL.md → PASS（锚在 SKILL.md:186；覆盖四族+部署位+引用面） | R2 |
| G3 | 三处必选步骤载体（翻转前/终验/合规清单）齐备且部署位同步零丢弃 | bash 实跑 VC-3+VC-4: 三处载体 grep 全命中 + 5 部署位 md5 一致 → PASS（SKILL.md:186/208/254 + 5位四锚/GATE/BP-11） | R3 |
| G4 | 机器门 ALIGN-ANCHOR GATE（默认 enforce）+ 档位键 + BP-11 静态锚全部落地，5 部署位一致，enforce 缺锚 FAIL/齐锚 PASS | bash 实跑 VC-5: sed 抽 align_anchor_gate source + mktemp 缺锚文件 4 态 → PASS（齐锚enforce rc=0/缺锚rc=1/off/warn rc=0；check-complete.sh:1673） | R4, D4 |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 | R1 强制对齐必选步骤 | 把对齐升格为所有任务修改完成后的强制必选步骤（步骤4硬门含精确锚『修改完成后强制对齐』） | VC-1 命令 exit 0 | S2 | complete |
| G2 | R2 对齐内涵覆盖 | 对齐内涵覆盖关联面四族+部署位+引用面同步完整性，杜绝部分改部分丢弃 | VC-2 命令 exit 0 | S2 | complete |
| G3 | R3 载体落地+部署同步 | 三处必选步骤载体（翻转前/终验/合规清单）齐备且部署位同步零丢弃 | VC-3 + VC-4 命令 exit 0 | S3, S4 | complete |
| G4 | R4 机器门实施+静态锚 | 机器门 ALIGN-ANCHOR GATE（默认 enforce）+ 档位键 + BP-11 静态锚全部落地，5 部署位一致，enforce 缺锚 FAIL/齐锚 PASS | VC-5 exit 0（含判别性探针） | S7, S8, S5 | complete |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete | S1 | VC-1, VC-2 | 需求与设计锚定 |  | R1, R2, R3, R4 |
| P2 | complete | S2, S3, S7, S8 | VC-1, VC-2, VC-3, VC-5 | 条款落地（SKILL.md 三处锚点 + 机器门 + 静态锚） |  | R1, R2, R3, R4 |
| P3 | complete | S4 | VC-4, VC-5 | 合并回+部署位同步 |  | R3, R4 |
| P4 | complete | S5 | VC-1, VC-2, VC-3, VC-4, VC-5 | 验证（VC 全量复验+selftest） |  | R1, R2, R3, R4 |
| P5 | complete | S6 | VC-4, VC-5 | 交付（防倒退终检+归档） |  | R3, R4 |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC-1 |
| R2 | VC-2 |
| R3 | VC-3, VC-4 |
| R4 | VC-5 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| （root_causes 未登记） | 结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由 | - | - |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | 步骤4翻转前硬门已把对齐升格为修改完成后强制必选步骤：SKILL.md 含精确锚『修改完成后强制对齐』（R1，需求锚（规范化）；逐字原话见 user-session-log.md #1） | grep -Fq '修改完成后强制对齐' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && echo PASS |  |
| VC-2 | 对齐内涵覆盖所有设计相关文件同步完整性：SKILL.md 含精确锚『关联面四族+部署位+引用面』，杜绝部分改部分丢弃（R2） | grep -Fq '关联面四族+部署位+引用面' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && echo PASS |  |
| VC-3 | 必选步骤载体三处齐备：终验智能子动作含『终验强制对齐』且合规清单新增 G11 对齐核查独立项（锚用无管道符串 G11 + 对齐核查，规避 MD 表格渲染转义；R3） | grep -Fq '终验强制对齐' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -Fq 'G11' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -Fq '对齐核查' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && echo PASS |  |
| VC-4 | 部署同步无丢弃（用户 #2 裁决②授权覆盖）：主仓 + 4 部署位（.zcode/.claude/.config/opencode/.agents）共 5 处一致——SKILL.md 四锚全命中 + check-complete.sh 含 ALIGN-ANCHOR GATE + selftest-batch-pilot.sh 含 BP-11；机器门/断言脚本随 --deploy F5 整目录同步，.agents 由授权 cp/rsync 同步（R3） | B=/mnt/data/dev/task-planner-skill/skills/task-planner; for d in "/mnt/data/dev/task-planner-skill/skills/task-planner" "/home/terry/.zcode/skills/task-planner" "/home/terry/.claude/skills/task-planner" "/home/terry/.config/opencode/skills/task-planner" "/home/terry/.agents/skills/task-planner"; do grep -qF '修改完成后强制对齐' "$d/SKILL.md" \|\| exit 1; grep -qF '关联面四族+部署位+引用面' "$d/SKILL.md" \|\| exit 1; grep -qF '终验强制对齐' "$d/SKILL.md" \|\| exit 1; grep -qF 'G11' "$d/SKILL.md" \|\| exit 1; grep -qF 'ALIGN-ANCHOR GATE' "$d/scripts/check-complete.sh" \|\| exit 1; grep -qF 'BP-11' "$d/scripts/selftest-batch-pilot.sh" \|\| exit 1; done; echo PASS |  |
| VC-5 | 机器门实施（用户 #2 裁决①③）+ 真跑门三档（禁止 grep 临时文件冒充）：(a) check-complete.sh 含 ALIGN-ANCHOR GATE + 可独立 source 的门函数 align_anchor_gate()（ markers FN BEGIN/END 包住、自包含只依赖入参 tier 与 skill_md）+ 四锚 grep + 档位键；(b) config.json properties.align_anchor_enforce.default=enforce（jq 缺失/解析失败 fail-closed 落 enforce）；(c) selftest-batch-pilot.sh 含 BP-11 且实跑 0 FAIL；(d) 整目录 mktemp 复制（scripts+SKILL.md+config.json）→ sed 抽门函数 source → 齐锚 enforce 实跑 rc=0；删一锚 enforce 实跑 rc=1（! 断言）；同删锚 off rc=0、warn rc=0；trap EXIT 清理，绝不污染主仓/worktree/SKILL.md | BASE=/mnt/data/dev/task-planner-skill/skills/task-planner; CC="$BASE/scripts/check-complete.sh"; CFG="$BASE/config.json"; BP="$BASE/scripts/selftest-batch-pilot.sh"; SK="$BASE/SKILL.md"; grep -qF 'ALIGN-ANCHOR GATE' "$CC" && grep -qF 'align_anchor_gate()' "$CC" && grep -qF 'ALIGN-ANCHOR GATE FN BEGIN' "$CC" && grep -qF 'ALIGN-ANCHOR GATE FN END' "$CC" && grep -qF '修改完成后强制对齐' "$CC" && grep -qF '关联面四族+部署位+引用面' "$CC" && grep -qF '终验强制对齐' "$CC" && grep -qF '对齐核查' "$CC" && jq -e '.properties.align_anchor_enforce.default=="enforce"' "$CFG" >/dev/null && grep -qF 'BP-11' "$BP" && bash "$BP" >/dev/null 2>&1 && T="$(mktemp -d)" && trap 'rm -rf "$T"' EXIT && cp -r "$BASE/scripts" "$T/scripts" && cp "$SK" "$T/SKILL.md" && cp "$CFG" "$T/config.json" && sed -n '/ALIGN-ANCHOR GATE FN BEGIN/,/ALIGN-ANCHOR GATE FN END/p' "$T/scripts/check-complete.sh" > "$T/gate_fn.sh" && test -s "$T/gate_fn.sh" && source "$T/gate_fn.sh" && align_anchor_gate enforce "$T/SKILL.md" && sed -i '/修改完成后强制对齐/d' "$T/SKILL.md" && ! align_anchor_gate enforce "$T/SKILL.md" && align_anchor_gate off "$T/SKILL.md" && align_anchor_gate warn "$T/SKILL.md" && echo PASS |  |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 需求与设计锚定
- **Status:** complete
- **Started:** 
- **Executor:** general-doc-processor
- [x] V-1.1: VC-1（Phase 1 验证契约映射）
- [x] V-1.2: VC-2（Phase 1 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1 | [P1] R 锚定复核+三处锚点精确文案草稿（rebase 后行号）（R1-R4 ↔ RES-1/2/3 复核；锁定 4 个精确锚字符串（修改完成后强制对齐 / 关联面四族+部署位+引用面 / 终验强制对齐 / G11 对齐核查项）与三处插入行位（rebase ea2d6df 后：SKILL.md:185 步骤4 / :206 终验子动作 / :251 G10 后插入点 :252，以实测行号为准）；文案草稿落 findings） | general-doc-processor | /mnt/data/dev/task-planner-skill/plans/task-align-mandatory-step-20261123/knowledge-brief.md；/mnt/data/dev/task-planner-skill/plans/task-align-mandatory-step-20261123/notepad-learnings.md；/mnt/data/dev/task-planner-skill/plans/task-align-mandatory-step-20261123/findings.md | findings 含三处行位+四锚字符串+部署位清单（主仓+4槽，含 .agents 已授权覆盖） | 10min | 1f/40l/10min | no | - | pending |

### Phase 2: 条款落地（SKILL.md 三处锚点 + 机器门 + 静态锚）
- **Status:** complete
- **Started:** 
- **Executor:** general-coder（P2 4 文件编辑 + 19 脚本级联修复，实际派发）
- [x] V-2.1: VC-1（Phase 2 验证契约映射）
- [x] V-2.2: VC-2（Phase 2 验证契约映射）
- [x] V-2.3: VC-3（Phase 2 验证契约映射）
- [x] V-2.4: VC-5（Phase 2 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S2 | [P2] 步骤4硬门升格+对齐内涵落地（净增≤4）（前置=worktree rebase/merge 到 ea2d6df（基线 461 行）；rebase 后 SKILL.md:185 步骤4翻转前硬门把 103.6 文案升格为强制对齐总入口，逐字追加『修改完成后强制对齐』；同处追加内涵锚『关联面四族+部署位+引用面』；净增≤4行（合计≤9：S2≤4+S3≤5，461+9=470 不触 BP-08）；四族按 103.6=字面/引用/部署镜像/断言面，含单文件修改；禁改既有规则语义） | general-doc-processor | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | VC-1 + VC-2 exit 0（两锚 grep 命中）；落地后 wc -l SKILL.md ≤470（BP-08） | 12min | 1f/4l/12min | no | - | pending |
| S3 | [P2] 终验子动作+合规清单 G11（净增≤5）（rebase 后 SKILL.md:206 终验智能子动作追加『终验强制对齐』；G10(:251) 后插入点 :252 新增 G11 对齐核查行，行内明写判定时点=Phase 翻转前/终验前；G1-G10 为落地前历史快照，落地后引用同步 G1-G11；净增≤5行（合计≤9 硬预算）；行号以 rebase 后实测为准） | general-doc-processor | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | VC-3 exit 0（三锚 grep 命中）；落地后 wc -l SKILL.md ≤470（BP-08） | 12min | 1f/5l/12min | no | - | pending |
| S7 | [P2] 机器门 ALIGN-ANCHOR GATE + 档位键（check-complete.sh :1671 fi 后/:1673 Rule 37 注释前插 ALIGN-ANCHOR GATE（避开 C-2 FG 哈希锚）：定义自包含门函数 align_anchor_gate() <tier> <skill_md>（用 FN BEGIN/END markers 包住，只依赖入参+grep+printf，供 VC-5 sed 抽取 source 实跑三档），四锚齐 return 0、enforce 缺锚 return 1、warn/off return 0；调用块 resolve 档位→非 off 调函数→enforce 档 exit 1；config.json properties 加 align_anchor_enforce（enum enforce/warn/off，default=enforce，仿 :131-139），env TASK_PLANNER_ALIGN_ANCHOR_ENFORCE 优先，resolve=env>顶层>properties>enforce 兜底；档位解析 fail-closed：jq 缺失/JSON 损坏/非法值落 enforce 禁静默 warn；门随 P2 同批上线） | general-coder（Code Assistant） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh；/mnt/data/dev/task-planner-skill/skills/task-planner/config.json | VC-5(a)(b)(d) 命中：门函数可 source 实跑三档（齐锚 enforce rc=0/删锚 enforce rc=1/off rc=0/warn rc=0）；jq 缺失模拟落 enforce | 15min | 2f/60l/15min | no | - | pending |
| S8 | [P2] 静态锚 BP-11（既有 selftest 内加断言）（BP-10 前（约:105）插 BP-11：对 $SKILLMD 四锚做 grep -qF，复用 ok()/bad()（:44-45），末尾 Total/exit 不改；不新增脚本；BP-08 只钉 SKILL.md 行数，脚本行数另计不受约束） | general-coder（Code Assistant） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-batch-pilot.sh | VC-5(c)(d) 命中：BP-11 四锚断言在位 + selftest-batch-pilot.sh 0 FAIL（Total 增量 1） | 10min | 1f/25l/10min | no | - | pending |

### Phase 3: 合并回+部署位同步
- **Status:** complete
- **Started:** 
- **Executor:** 主进程（白名单①：git 编排 + smart-merge-back.sh --deploy 部署位同步，属宪法§十一合并回合约）
- [x] V-3.1: VC-4（Phase 3 验证契约映射）
- [x] V-3.2: VC-5（Phase 3 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S4 | [P3] worktree rebase 前置 + 合并回主仓+4槽位部署同步（.agents 已授权覆盖）（前置=worktree rebase/merge 到 ea2d6df（fetch origin && rebase origin/main，无远端则 merge ea2d6df），冲突按四锚逐项解决；wc -l SKILL.md ≤470 复验，超则收紧净增预算禁上调 BP-08；全 VC 复验通过→git merge --no-ff→bash smart-merge-back.sh <wt> --deploy（默认 3 位 F5 对账 diff=0，整目录含 scripts/config 自动同步）→.agents 用户 #2 已授权覆盖：授权 cp/rsync 整目录 + md5 校验→清理 worktree/分支→主仓 Read 复验） | 主进程（白名单①：git 编排 + smart-merge-back.sh --deploy 部署位同步，属宪法§十一合并回合约） | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md；/home/terry/.zcode/skills/task-planner/；/home/terry/.claude/skills/task-planner/；/home/terry/.config/opencode/skills/task-planner/；/home/terry/.agents/skills/task-planner/ | VC-4 exit 0（5 位 SKILL.md 四锚 + GATE + BP-11 一致）；--deploy 退出 0 无 DEPLOY_DRIFT；.agents 授权覆盖+md5 留痕；rebase 后 wc -l ≤470 | 15min | 2f/0l/15min | no | - | pending |

### Phase 4: 验证（VC 全量复验+selftest）
- **Status:** complete
- **Started:** 
- **Executor:** code-runner-agent
- [x] V-4.1: VC-1（Phase 4 验证契约映射）
- [x] V-4.2: VC-2（Phase 4 验证契约映射）
- [x] V-4.3: VC-3（Phase 4 验证契约映射）
- [x] V-4.4: VC-4（Phase 4 验证契约映射）
- [x] V-4.5: VC-5（Phase 4 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S5 | [P4] VC 全量复验+selftest 回归（含机器门判别性）（逐条执行 VC-1..VC-5 命令并记录 PASS/FAIL；VC-5 含机器门（a-e）与判别性探针（临时副本删锚→四锚谓词 FAIL，原件 PASS，不污染主仓）；跑 selftest-doc-script-paths.sh + selftest-batch-pilot.sh（BP-08 行数门 + BP-11 静态锚）；Total 按逐脚本 Total 行求和；唯一入口=主进程按 verification.md 手工逐条执行 + 证据回填，不以 run-verification.sh 汇总为准） | code-runner-agent | /mnt/data/dev/task-planner-skill/plans/task-align-mandatory-step-20261123/verification.md；/mnt/data/dev/task-planner-skill/plans/task-align-mandatory-step-20261123/progress.md | 5 VC 全 PASS + selftest FAIL=0（含 BP-11）；verification.md/progress.md 落证据 | 12min | 2f/20l/12min | no | - | pending |

### Phase 5: 交付（防倒退终检+归档）
- **Status:** complete
- **Started:** 
- **Executor:** 主进程（白名单①：交付归档 + 合并回簿记 + worktree 清理，属 git/交付编排）
- [x] V-5.1: VC-4（Phase 5 验证契约映射）
- [x] V-5.2: VC-5（Phase 5 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S6 | [P5] 防倒退终检+归档簿记（对照进度产出基线三项判定净效果≥0（条款数≥基线/FAIL≤基线/部署位 diff 收敛）；更新 merge_back；archive-plan.sh 归档；Verification Contract 全绿） | 主进程（白名单①：交付归档 + 合并回簿记 + worktree 清理，属 git/交付编排） | /mnt/data/dev/task-planner-skill/plans/task-align-mandatory-step-20261123/progress.md；/mnt/data/dev/task-planner-skill/plans/task-align-mandatory-step-20261123/plan-state.json | VC-4+VC-5 exit 0；防倒退三项净效果≥0；归档幂等 | 8min | 2f/10l/8min | no | - | pending |

## 🔒 不变量声明区
| 三态 | 条目 | 来源锚 |
|---|---|---|
| HARD | P2 落地前先把 worktree rebase/merge 到 ea2d6df（git -C <wt> fetch origin && rebase origin/main，无远端则 git -C <wt> merge ea2d6df），使基线 SKILL.md=461 行；三处锚净增合计≤9 行（S2≤4 + S3≤5），落地后 wc -l ≤470；BP-08 上限 470 禁止默认上调（Rule 74.7 须用户逐字授权）；净增预算 9=470-461；脚本文件行数另计不受 BP-08；机器门随 P2 同批上线默认 enforce，合并回后立即生效 | skills/task-planner/scripts/selftest-batch-pilot.sh:69-70；VC-5 含该哨兵 + BP-11 + 真跑门三档 |

## 📦 进度产出基线
| 基线项 | 动工前快照 | 关键产出/指标 | 禁倒退清单 | 状态 |
|---|---|---|---|---|
| 现有对齐机制条款数 | 5 处机制：Rule103.6 同步完整性(task-dispatch/references/critical-rules-dispatch.md:249)、alignment-review/Rule42.6(正文缺1处=缺口)、Rule106 文档复检(discipline:735-760)、Rule84.14 收尾回读(skills/verification-gate/references/critical-rules-verification.md:58)、部署 diff 对账(smart-merge-back.sh:15-23,470,739-756) | 对齐机制条款数 ≥ 基线 5（净增≥1 强制对齐总入口，且既有条款零删减） | 禁删减既有 103.6/106/84.14/部署 diff 条款；禁以新条款顶替旧条款 | baseline |
| selftest 基线 FAIL 集 | selftest-doc-script-paths.sh Total:3 PASS=3 FAIL=0；selftest-batch-pilot.sh Total:10 PASS=10 FAIL=0（2026-11-23 主进程实测）；BP-11 落地后批试点 Total 预期 11；全量 selftest 基线待 P4 逐脚本 Total 行求和登记 | FAIL 数 ≤ 基线 0（净变化 ≥ 0）；新增 BP-11 断言须 PASS 不引入 FAIL | 禁改 selftest 断言或跳过用例以掩盖 FAIL；FAIL>0 即回炉 | baseline |
| 部署位 diff 状态 | 4 部署位：.zcode 7 项（__pycache__/4 selftest 差异/SKILL.md.bak）/ .claude 6 项 / .config/opencode 6 项（含 SKILL.md 差异）均 DRIFT；.agents(/home/terry/.agents/skills/task-planner/) 存在、非软链、md5 与主仓相同，但不在 smart-merge-back.sh:389 默认 3 位内=契约外活体副本；用户 #2 已授权覆盖，S4/SR 按授权 cp+md5 校验纳入 5 位 | 交付后 5 处（主仓+4槽）SKILL.md 四锚 + check-complete.sh GATE + selftest BP-11 一致（VC-4）；全量 diff 收敛至 0（--deploy 对账 + .agents 授权 cp md5 校验） | 禁仅改主仓不部署；禁未授权 cp——.agents 按 CH-5 用户授权 cp+md5 校验，禁静默省略；禁手工绕过 --deploy 对账；禁脚本不同步部署位 | baseline |
| 机器门/静态锚（用户 #2 裁决①③） | 基线 2026-11-23 实测：check-complete.sh 无 ALIGN-ANCHOR GATE；config.json properties 无 align_anchor_enforce；selftest-batch-pilot.sh 无 BP-11（当前 Total:10 PASS=10 FAIL=0） | 门+档位键（default=enforce）+BP-11 四锚断言全部落地，5 部署位一致（VC-4/VC-5）；BP-11 落地后 selftest Total:11 FAIL=0；enforce 缺锚 rc=1 / 齐锚 rc=0 判别性实测 | 禁删门/禁降档为 off 或 warn 默认（须 enforce）/禁删 BP-11/禁脚本不同步部署位/禁新增独立门控脚本 | baseline |

## 📋 变更标注表
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字） | 依据（证据） | 执行动作 |
|---|---|---|---|---|---|---|
| CH-1 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | 增量（步骤4，rebase 后约:185） | 吸收既有 103.6 同步完整性文案，升格为强制对齐总入口（非替换/非删除） | 多文件变更集（≥2 受管文件）翻转前先过 103.6 同步核对清单 | RES-2 落点①；用户原话#1『修改完成之后必须执行对齐』；复审 I-2 行号重定位 | 追加锚『修改完成后强制对齐』+内涵锚『关联面四族+部署位+引用面』；净增≤4行（合计≤9）；四族按 103.6=字面/引用/部署镜像/断言面，含单文件修改；G1-G10 为落地前快照，落地后引用同步 G1-G11；禁改既有规则语义 |
| CH-2 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | 增量（终验智能子动作，约:206-207） | 复用 Rule 84.14 收尾回读与 Rule 103 双轮质检的同步完整性衔接 | 双轮质检与同步完整性终验衔接（Rule 103） | RES-2 落点②；用户原话#1『确保所有设计相关的文件都进行同步修改』 | 追加『终验强制对齐』子动作行，指向关联面四族+部署位+引用面；禁改既有子动作 |
| CH-3 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | 增量（合规清单，rebase 后 G10(:251) 插入点 :252） | 接续最大 G 编号 G10 → G11（Rule 34 合规清单编号纪律） | \| G10 \| 计划完成后归档自查 | RES-2 落点③：G1-G10（落地前历史快照）无对齐独立项；复审 I-2 行号重定位 | G10(:251) 后插入点 :252 新增 G11 对齐核查行，行内明写判定时点=Phase 翻转前/终验前；G1-G10 为落地前快照，落地后引用同步 G1-G11；禁改既有 G1-G10 语义；净增≤5行（合计≤9） |
| CH-4 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh；/mnt/data/dev/task-planner-skill/skills/task-planner/config.json；/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-batch-pilot.sh | 增量修改（用户 #2 裁决①③显式授权；原『scripts 零 diff』作废） | 机器门从『参数项不实施』升格为『实施』：文本优先铁律障碍由用户逐字授权解除；不新增脚本文件，仅在既有脚本/配置内增量 | SKILL-MODIFY GATE 范式 check-complete.sh:1640-1671（fi 收口 :1671）；evidence_anchor_enforce config.json:131-139；BP-10 selftest-batch-pilot.sh:75-79 | user-session-log.md #2 逐字裁决①③；Explore 勘察带 file:line；D4；复审 I-1/W-1/W-5 | ① check-complete.sh :1671 fi 后、:1673 Rule 37 注释前插 ALIGN-ANCHOR GATE：先定义自包含可独立 source 的门函数 align_anchor_gate()<tier> <skill_md>（用 markers『ALIGN-ANCHOR GATE FN BEGIN/END』包住，只依赖入参+grep+printf，四锚=修改完成后强制对齐/关联面四族+部署位+引用面/终验强制对齐/G11 行含对齐核查，G11 拆双 grep 规避管道转义；enforce 缺锚 return 1 / warn return 0 警示 / off return 0），再接调用块 resolve 档位 → 非 off 调函数 → enforce 档 exit 1；② config.json properties 加 align_anchor_enforce（enum enforce/warn/off，default=enforce），env TASK_PLANNER_ALIGN_ANCHOR_ENFORCE 优先，resolve=env>顶层>properties.default>enforce 兜底；档位解析 fail-closed：jq 缺失/JSON 损坏/非法值一律落 enforce，禁静默回落 warn；③ selftest-batch-pilot.sh BP-10 前(约:105)插 BP-11 四锚 grep -qF + 复用 ok()/bad()(:44-45)，Total/exit 不改；BP-08 只钉 SKILL.md，脚本行数另计；门随本任务 P2 同批上线 |
| CH-5 | /home/terry/.agents/skills/task-planner/SKILL.md + scripts/ + config.json + smart-merge-back.sh:389 | 部署位第4位（用户 #2 裁决②授权覆盖） | .agents 位存在、非软链、md5 与主仓相同，但不在 smart-merge-back.sh:389 默认 3 位内=契约外；用户已显式授权覆盖，纳入完整同步（含机器门/静态锚脚本） | SLOTS=$HOME/.zcode/…:$HOME/.claude/…:$HOME/.config/opencode/…（无 .agents） | user-session-log.md #2 ②授权覆盖；宪法§六保护区授权已取得；独立审计 I-1 | 已授权覆盖：S4 用 --deploy 同步 3 默认位 + 授权 cp/rsync 整目录（含 scripts/config）到 .agents；VC-4 五位校验 SKILL.md 四锚 + ALIGN-ANCHOR GATE + BP-11；禁再走『不覆盖』备选（裁决②已作废） |

## ⚠️ 核心问题定义
| 字段 | 值 |
|---|---|
| 核心问题 | 对齐机制分散在Phase翻转/终验各环节，无统一的修改完成后必做对齐强制入口且无机器门，导致执行层部分改部分丢弃；解决后=每次修改完成都有强制对齐必选步骤，杜绝遗漏 |
| 核心问题判断 | 核心问题解决后能交付吗=是；不解决其他工作白费吗=是；解决方法清晰可执行=是 |

## Next Step
派 Plan Writer 产出计划文档（Phase/VC/S-unit），主进程盘上复核后进计划审计门

## 🧰 工具选择与编排
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|---|---|---|
| P1 | knowledge-brief.md 五段读 + grep 锚点复核（本地文件，无需网络） | 任务=仓库内文档条款改动，全部事实来自已落盘 RES-1/2/3 与实际文件锚，NET 三态均 LOCAL-ONLY |
| P2 | general-doc-processor（子代理）逐锚 Edit；主进程 Read 复核 | 文档条款增量为低风险文本编辑，按用户提示派 general-doc-processor；主进程只验收不代写 |
| P3 | git merge --no-ff + smart-merge-back.sh --deploy（主进程白名单） | git 编排/部署位同步属宪法§十一合并回合约，仅主进程执行；--deploy 自带 F5 diff=0 对账 |
| P4 | code-runner-agent 跑 VC 命令 + 两 selftest（BP-08/BP-11）+ VC-5 真跑门函数三档 | 命令执行/回归属纯执行派 code-runner-agent；VC-5 用 mktemp 整目录副本 source 门函数实跑三档（齐锚/删锚 enforce/off/warn），trap 清理不污染主仓；主进程按 Total 行求和复核 |
| P5 | planctl status/validate + archive-plan.sh（主进程白名单） | 交付归档/簿记为 git 编排类，主进程执行；validate 保证结构化状态一致 |

## 🔀 隔离决策
| 字段 | 值 |
|---|---|
| conflict_scan | risk(28未提交在plans/docs不重叠skills+并行worktree wt-tplsys+遗留wt分支2+24未完成任务) |
| isolation/worktree_path | /mnt/data/dev/task-planner-skill/tmp/worktrees/task-align-mandatory-step-20261123 |
| branch | wt/task-align-mandatory-step-20261123 |
| merge_back | pending |

## 📊 FMEA 预演
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作 |
|---|---|---|---|---|---|---|
| P2 | 三处锚点只落一处，遗漏终验子动作或 G11（部分改部分丢弃的微观复现） | 9 | 2 | 3 | 54 | VC-1/VC-2/VC-3 三锚逐条 grep 齐验，缺任一即回炉；S2/S3 分别验收 |
| P2 | 术语漂移：执行体改用同义措辞导致精确锚字符串不命中，未来执行体检索不到强制对齐条款 | 6 | 3 | 4 | 72 | changes 表锁定 4 个精确锚字符串；VC grep -F 逐字校验；S1 文案草稿先行锁定 |
| P3 | 部署位只同步部分（4 槽位漏 1），主仓已改但槽位仍旧=用户核心痛点『部分改部分丢』重演 | 10 | 3 | 2 | 60 | VC-4 五位置（主仓+4槽）逐位 grep 四锚+GATE+BP-11；smart-merge-back --deploy 对账 exit 6=DEPLOY_DRIFT 立即回炉 |
| P2 | 门判定字符串与 SKILL.md 实际落文字串脱节（G11 管道转义/同义改写）→恒 FAIL 或恒 PASS | 8 | 2 | 3 | 48 | CH-4 锁定 4 锚（G11 拆双 grep 规避管道转义）；VC-3 + VC-5 双 grep 齐验；临时副本判别性探针 |
| P3 | .agents 部署位漏同步或越权写入：默认 3 位不含 .agents，且该位属宪法§六保护区 | 9 | 2 | 3 | 54 | 默认路径=D1 授权后授权 cp/rsync + VC-4 五位 grep 齐验；备选=D1 不授权则禁写，登记不覆盖理由+外部 cp/md5 验证+残留风险，VC-4 降 4 位口径 |
| P4 | enforce 默认误伤存量计划（SKILL.md 四锚未落地的存量计划在四锚上线前跑 check-complete 即 FAIL） | 9 | 3 | 4 | 108 | 门随本任务 P2 同批上线（INV-1 时序说明）：P2 落四锚与门同批，P4 复验时四锚已齐；存量计划过渡期用 TASK_PLANNER_ALIGN_ANCHOR_ENFORCE=off/warn 须用户授权并登记，禁静默降级；VC-5 判别性探针证明缺锚 FAIL/齐锚 PASS |
| P3 | 机器门/静态锚脚本未同步 4 部署位（--deploy 默认 3 位，.agents 须授权 cp，脚本漏同步致部署位门宽严不一） | 9 | 2 | 3 | 54 | VC-4 五位校验 GATE + BP-11 一致；S4 授权 cp 整目录到 .agents + --deploy 对账 exit 6=DRIFT 回炉 |

## Key Questions
- [CLOSED] D1 三项裁决（user-session-log.md #2 逐字）：①机器门 ②.agents 授权 ③静态锚 — ①实施机器门 ALIGN-ANCHOR GATE（默认 enforce）+ 档位键 + BP-11；②.agents 授权覆盖纳入 5 位；③启用静态锚（既有 selftest 加 BP-11，非新脚本）；裁决留痕=user-session-log.md #2 逐字 + decisions D4；原方案 A 默认值作废；一次定案禁再上抛

## Decisions Made
| Decision | Rationale |
|---|---|
| [已被 D4 用户 #2 裁决覆盖，保留历史] 原默认走方案A不实施机器门；现①③改为实施机器门+静态锚，②.agents 授权覆盖 | 宪法§二文本优先铁律P0：规则偏好以文本条款落入指令载体即完成，新增脚本/hook/门属范围扩张须显式授权；.agents 属§六保护区，写须用户显式授权；机器门/子选项均属用户裁决项不默认实施 |
| 实现类任务强制worktree隔离：wt/task-align-mandatory-step-20261123@基线579c59b | 改运行中技能基础设施(skills/)，宪法§十一强制隔离；28未提交变更不在skills范围故不stash |
| D类新任务边界判定：与task-fix-all-20261123交付物无交集，旧计划挂起登记[intent-switch]并释放session-owner | skill D类判定卡：Goal/范围/交付物三要素均无交集 |
| D类切换挂起：新任务 task-retrieval-exclude-20261123（检索排除清单）Goal/范围/交付物零交集 | 本会话 sess3913b867 切走；owner已释放；旧计划保持pending待用户裁决是否续推；2026-11-23 |
| 用户 D1 三项裁决已定案（user-session-log.md #2 逐字）：①机器门实施（ALIGN-ANCHOR GATE 默认 enforce + 档位键 + BP-11 静态锚）②.agents 授权覆盖（纳入 5 位同步）③静态锚启用；覆盖原方案 A 默认值，文本优先铁律障碍由用户显式授权解除 | 用户 #2 三项全选最强方案=系统级完整交付；显式授权使范围扩张合法（宪法§二/§六）；一次 AskUserQuestion 定案后禁再上抛；机器门默认 enforce 满足『强制卡控』诉求 |
| 对齐条款去 Rule 112.1 编号，改无编号语义表述 | 实现期自查发现 Rule 112.1 已被 Rule 112 检索排除清单子条占用（critical-rules.md:253）；计划 4 精确锚均不含编号，去编号不影响验收；按文本优先铁律条款以文本落入即生效，无需新编号 |
| config.properties 53→54 级联更新 19 个 selftest 固定计数断言 | 本任务合法新增 align_anchor_enforce 致 properties=54，触发 19 脚本 ==53 断言 FAIL；历史先例每次合法新增键均级联更新全部钉死断言（47→53/P-01 46→47）；不修复即用户『部分改部分丢弃』诉求的实证回归，必须 dogfood 清零 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|---|---|---|---|
| S1/S4 S-unit 全部字段被 planctl update --json 整体替换语义清空（执行体/时长全空，attest 反复报执行体为空） | 3 | 从 .history/plan-state-20261123T041606-01.json 恢复 S1/S4 完整对象，granularity 用已定案合规值，单次 Python 精确写回+render | 改 JSON 前先查 update 是替换还是 merge；多字段一次写全；attest 失败先查字段实值而非重试 |
| 对齐条款误用 Rule 112.1 编号，与 Rule 112 检索排除清单子条（critical-rules.md:253 定义 112.1=清单载体）冲突 | 1 | 实现期自查发现，4 处去编号改无编号语义表述（对齐必选步骤/终验强制对齐/G11对齐核查），4 精确锚不变 | 新增/引用 Rule 编号前先 grep critical-rules.md 确认未被占用；文本优先铁律下条款无需新编号 |
| 新增 config 键 align_anchor_enforce 致 properties 53→54，触发 19 个 selftest 固定计数断言 FAIL（worktree ΣFAIL=24） | 1 | 按历史先例（47→53/P-01 46→47）级联更新 19 脚本断言至 54 + 演进注释，全量 ΣFAIL=0 | 新增 config 键必 grep 全量 selftest 的 properties 计数断言并级联更新；这正是本任务对齐诉求的实证 |

## 📎 领域模板原文附录（仅供参考；权威判据以 JSON 结构化段+机器门为准）
<!-- template_type: rule-enhancement -->
execution_lane: L2
<!-- template_meta: {"type": "rule-enhancement", "name": "规则增强", "summary": "技能规则/条款增强：新增 Rule、config 三档键、消费侧门控、selftest 守护与 SKILL 联动。", "scenarios": ["新增 Rule", "条款增强", "消费侧门控脚本", "selftest 守护", "技能机制化增强"], "features": ["用户需求原文 R→VC 映射", "Verification Contract", "工具选择与编排", "消费侧门控与 selftest 守护", "SKILL 联动"]} -->
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule NN、config 三档键、消费侧门控脚本、selftest 守护、SKILL 联动 -->
<!-- 触发关键词: 加规则/新增 Rule/条款/门控/合规清单/守护/技能增强/机制化 -->
<!-- 推荐 subagent: executor(sonnet-1) 写条款与脚本; code-runner-agent 跑 selftest; 合并部署主进程; 沉淀出处: task-v074（Rule 34.3① 同类任务第 3 次触发） -->
<!-- 📦/🛡 进度产出基线与防倒退终检：按主模板 Rule 111 区块执行（本 variant 不重复区块本体） -->

> # Task Plan: [规则增强任务名称]
<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 pruned="根源覆盖表,不变量声明区,规范基线,进度产出基线,Goal,双轮质检与同步完整性声明,核心目标达成裁决,变更标注表,核心问题定义,调研需求与检索计划,证据面清单,CurrentPhase,NextStep,防倒退终检,收尾回读梳理记录,隔离决策,FMEA预演,原生Todo同步,KeyQuestions,DecisionsMade,ErrorsEncountered,Notes,Chain区块交接配置" pruned_reason="variant=领域裁剪全文，裁剪面以本清单显式登记（Rule 34.5 派生登记）" -->
<!-- planctl 派生口径(task-planctl-exec-surface-20261122)：本骨架数据经 planctl add/set 写入 plan-state.json 后 render 派生 task_plan.md 视图；直接填写会在首次 render 被覆盖 -->

> ## 🎯 用户需求原文（Rule 51.1 逐条抄录 + 51.2 R→VC 映射; R 行=用户原话逐条编号抄录，每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉）

<!-- plan_tier: standard -->
> ## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!-- 2026-10-07 task-v143：init 注入载体（CR F-1 修复，镜像 51.1 注入兜底范式）。适用判定:产出=结论/判断/建议/原因解释的任务；
     豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免 -->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | （自身内容/产品/数据） | | | ☐ |
| ② 对标样本（58.2 强制） | （竞品/同类成功案例/历史基线，≥1 个可指名） | | | ☐ |
| ③ 外部约束 | （平台规则/市场环境/算法机制） | | | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

> ## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!-- 2026-10-07 task-v143：init 注入载体（CR F-1 修复）。58.4 手段/目标二分在需求区 R 行标注 [手段]/[目标]；
     本区块终验时回收目标型需求的解决状态；not-solved/partial 禁止标 COMPLETE（58.5②） -->
| 字段 | 值 |
|------|-----|
| **目标型需求** | （R 行编号，如 R1/R3） |
| **裁决** | `solved` / `partial` / `not-solved`（三选一必填） |
| **解决证据锚** | （file#锚点/取证记录行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填：试过什么+为何不行） |
| **下一步建议** | （not-solved 必填：可执行的下一步） |

> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。

> ## Goal: [一句话: 落地 Rule NN <规则名>（NN.1-NN.M 条款 + config 三档键 + 消费侧门控 + selftest 守护 + SKILL 联动），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位]

> ## 🔍 Code Review 配置
| `code_review` | `required`（改动含 .sh 脚本）; 对齐审查[登记] Rule 42.6;自动超时[询问点] Rule 44;质量审查[检测结论] Rule 42 — 均 mini 豁免 |

> ## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule NN 条款完整（NN.1-NN.M，范式对齐既有规则：子条=NN.M 动词短语，末条"机制"声明三档键+selftest） | Read 条款节 + grep 各子条锚 | `references/critical-rules.md` |
| VC-2 | config 三档键落地（enforce/warn/off，默认 warn，挂 properties 内） | `jq .properties.<key>` 校验 | `config.json` |
| VC-3 | 消费侧脚本集成（档位解析 env>config>warn；各档位分支功能实跑） | enforce/warn/off 三档行为实测 | 消费侧脚本输出 |
| VC-4 | selftest 守护落地 + 全量回归 0 FAIL（**总数=主进程逐脚本 Total 行求和，禁采信子代理自报总数**） | `for f in selftest-*.sh` 逐个跑求和 | progress.md Selftest Log |
| VC-5 | SKILL 联动（索引行 Rules 1-N/合规清单 C 行/特判段/摘要行）+ 3 实体位部署 diff=0 | grep 联动锚 + smart-merge-back --deploy | SKILL.md / 部署输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

> ## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（追加新块） | 改既有规则语义 |
| 配置 | `config.json`（properties 追加新键） | 动既有键；顺手修既有脏点（最小 diff） |
| 脚本/文档 | 消费侧脚本 + 新建 selftest / template-mapping.md / plan-writer.md（如涉四点同步） | 其他脚本/文档 |
| SKILL | `SKILL.md`（**净增 ≤10 行**：行位替换优先） | 大段新增 |

**强制约束**:
- 新规则编号接续当前最大 Rule；合规清单接续最大 C 编号
- ⚠️ **锚定级联**：改 SKILL.md "Rules 1-N" 前先 `grep -rn "Rules 1-" scripts/` 扫全部锚断言一次修齐（宽容正则 `Rules 1-3[x-y]` 优先）; SKILL.md 行数纪律：wc -l 复核；行数上限断言（selftest-knowledge-brief T2b）同步上调 + label 注明 task 代号（先例：≤523 task-v071 → ≤540 task-v074）
- 派发契约：executor prompt 必含计划三文件路径 + acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）

> ## 🧰 工具选择与编排（Rule 40 — 计划期主动分析;Executor 字段=委派门控机器事实源;mini 豁免）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |



> ## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 最近两轮规则块范式 / selftest 写法范式 / 三档键范式 | references/critical-rules.md 末尾; scripts/selftest-veto.sh; config.json 最新三档键 | ☑ |
| 项目内部 | 台账供料简报（Rule 编号账本+审计台账路径等） | `<plan-dir>/knowledge-brief.md` §2/§3/§5（台账路径锚供料，禁 prompt 内联基线） | ☑ |

- **调研需求三态（Rule 75.1）**：本模板任务默认 **可选**——规则增强主要操作仓库内部文件（条款/config/脚本/SKILL.md），通常无需网络调研；涉及新机制引入或外部标准参照时按 Rule 75.1 逐个判定调研触点

> ## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|

> ## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- WHAT: 子代理 vs 主进程执行分布;WHY: 委派率 < delegation_rate_floor(默认 0.7)或白名单外理由 → 最高 PARTIAL;WHEN: 每 Phase complete 后更新,终验前必填 -->
| 字段 | 值 |
|------|-----|
| 子代理/主进程 Phase 数 |  /  |
| 主进程直做 Phase 清单 + 委派率 | （含例外理由; < delegation_rate_floor 默认 0.7 或白名单外理由 → 最高 PARTIAL） |

> ## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 | 2026-11-23 | general-coder | P2 对齐必选步骤 4 文件编辑 | done | 4 文件纯增行；selftest 11 PASS | SKILL.md:186/208/254 | RES-2 | subagent-state/ |
| 2 | 2026-11-23 | general-coder | 19 脚本 config 键数断言 53→54 级联 | done | 19/19 FAIL=0，级联恢复 | selftest-*.sh | RES-5 | subagent-state/ |
| 3 | 2026-11-23 | code-runner-agent | 全量 selftest 104 脚本双环境对照 | done | 主仓 ΣFAIL=0；修后 worktree ΣFAIL=0 | /tmp/*_selftest_results.tsv | TR-1 | subagent-state/ |
| 4 | 2026-11-23 | drift-checker | 实现后只读偏移检查 | done | ✅ALIGNED | subagent-state/20261123-drift-checker.md | — | subagent-state/ |

> ## 🎯 Goal 单元表（Rule 66.1 — attest 获批后填写）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 |  |  |  |  | pending |

## 📦 Batch Report（Rule 18.6 — 留空会被 check-complete 拦）
| 字段 | 值 |
|------|-----|
| `total` | n/a（<一句理由>） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | 任务 <5 单元不触发抽样 |
| `pre_check` | Q1:否 / Q2:无共享写 / Q3:能 |
| `rollback_point` | <worktree 分支，合并前可弃> |
