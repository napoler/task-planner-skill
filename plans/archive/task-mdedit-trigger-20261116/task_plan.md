# Task Plan: md-edit-ops 触发面封堵（hook advisory + discipline 语义接线）

---
template_type: rule-enhancement
plan_tier: standard
execution_lane: L1
cost_estimate:
  main_process_opus: 1
  subagent_calls:
    code-assistant: 1
    code-runner-agent: 1
  estimated_opus_equivalent: 1.07
  estimated_savings_vs_naive: 0.55
---

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「md-edit-ops 已交付部署（见 /mnt/data/dev/task-planner-skill/knowledge/entries/md-edit-ops-structured-editing.md）但触发面有缺口——普通会话随手 Edit .md 文件不保证触发（用户问询实证+上一任务会话行为反例）。需封堵该触发缺口。」<sub>（[目标]）</sub>
- **R2**: 「A+B 组合 (Recommended)」<sub>（[手段]，2026-11-16 AskUserQuestion 显式授权锚）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3, VC-4, VC-5, VC-6 | A(hook advisory)与B(语义接线)落地；三正三负与4项RC=0；5位部署对账与运行位实弹命中/不命中符合预期 |
| R2 | VC-1, VC-2, VC-5 | A+B 双侧同时实施并部署到目标位，非单边缩水 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`/mnt/data/dev/task-planner-skill/plans/task-mdedit-trigger-20261116/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 工具调用前触发感知 | 普通会话 Edit/Write .md 无 md-edit-ops 提醒，结构化/批量修改易走裸编辑 | P1/S1：zcode-pretooluse.sh `Write|Edit|ApplyPatch` 头部 advisory（A），fail-open stdout 提醒 | VC-1, VC-3 |
| 执行纪律召回 | 执行期未必回忆 md-edit-ops/Rule 106.6 触发条件 | P1/S2,S3：recall-card §B 与 task-discipline SKILL 语义指针（B） | VC-2, VC-4 |
| 验收覆盖 | 误报/漏报（plans 路径、单行小改、短写入）或纪律接线缺失未被发现 | P2：hook 三正三负 + discipline 4 项 RC=0 | VC-3, VC-4 |
| 部署与运行面 | 源改动未同步到实际技能位或运行位行为不一致 | P3：5 位部署+对账+运行位实弹一正一负 | VC-5, VC-6 |

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal（封堵 md-edit-ops 触发面缺口，A+B 同时落地）；R1/R2 原文锚；Scope A/B 逐字语义；VC-1~VC-6 判据；禁改既有 hook 阻断/委派逻辑；advisory fail-open exit 0；计划期不碰 scope 实施文件/不 git | 本文件 Goal/R/Scope/VC/约束 |
| 🔀 可变量 | worktree 内具体实现细节（在 A/B 约束内）、P2 执行体在 code-runner 与主进程机械跑间微调（须登记）、5 位路径的实际探测顺序、收口中 kb/归档执行与否（视体量） | progress/Decisions |
| 📈 学得量 | 实施/验收/部署中发现的新事实、失败模式与锚点→findings.md/knowledge-brief.md/progress.md；禁反向改写不变量 | findings.md, knowledge-brief.md |

## Goal
封堵 md-edit-ops 在普通 .md 编辑场景的触发面缺口：在 zcode-pretooluse.sh 落地 fail-open advisory 提醒（A）并完成 task-discipline 两处语义接线（B），经三正三负与 4 项 discipline 校验、5 位部署对账及运行位实弹验证后交付。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `8973c6067dd044a48d8b58f39169cbf7` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116`（待建） |
| `scope_files` | `skills/task-planner/scripts/zcode-pretooluse.sh`, `skills/task-discipline/references/execution-recall-card.md`, `skills/task-discipline/SKILL.md` |
| `interaction_mode` | `silent`（完成性指令/D1 自动通过口径适用，登记静默决策） |
| `对齐审查` | `[登记]` P3 收口前对 A/B 变更与 Rule 106.6/md-edit-ops 文案做一致性核对；变更随交付落盘 |
| `自动超时默认项` | `D1: 按已展示计划执行/5min`（默认推荐项执行并登记自动裁决记录） |
| `new_rule` | 留空 |
| `质量审查工具` | 检测结论：本任务改 hook 脚本+纪律文档，质量审查面=脚本行为正确性与文案一致性；采用现有 code-review/verifier 语义自检+P2 可执行 VC 命令为主，无需新增审查技能；缺口无（登记 S-unit 复检见 P2） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | A：worktree 内 `zcode-pretooluse.sh` 在 `Write\|Edit\|ApplyPatch` 分支头部含纯增量 advisory（tool∈{Edit,Write}、.md 且路径不含 `/plans/`、Edit 换行或 old+new≥200、Write content≥600 命中则 stdout 指定提醒行；fail-open exit 0；含 What+Why 注释；不改既有阻断/委派逻辑） | grep + 代码片段 Read | `WT=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116; F="$WT/skills/task-planner/scripts/zcode-pretooluse.sh"; grep -qF '[md-edit-ops] 提醒:' "$F" && grep -qF 'Rule 106.6' "$F" && grep -q '/plans/' "$F"` |
| VC-2 | B：recall-card §B 末尾含指定行；task-discipline SKILL 速查/原则区含同义 md-edit-ops 指针（Rule 106.6）且锚定 | grep/Read | `WT=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116; R="$WT/skills/task-discipline/references/execution-recall-card.md"; S="$WT/skills/task-discipline/SKILL.md"; grep -qF '批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL' "$R" && grep -q 'md-edit-ops' "$S" && grep -q 'Rule 106.6' "$S"` |
| VC-3 | hook 三正三负：正例(Edit 含换行/Edit old+new≥200/Write content≥600) stdout 含 `[md-edit-ops] 提醒:` 且 exit 0；负例(/plans/ 路径/单行小改/短 Write) stdout 不含该提醒且 exit 0 | 模拟 stdin 管道执行脚本 | 见 `verification.md` V-2.1（同口径可执行命令） |
| VC-4 | discipline 关联 4 项检查 RC=0：召回卡指定行在位、§B 锚存在、SKILL 含 md-edit-ops、SKILL 含 Rule 106.6 | bash 检查命令 | `WT=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116; R="$WT/skills/task-discipline/references/execution-recall-card.md"; S="$WT/skills/task-discipline/SKILL.md"; test -f "$R" && test -f "$S" && grep -qF '批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL' "$R" && grep -q '## B. 变更与范围' "$R" && grep -q 'md-edit-ops' "$S" && grep -q 'Rule 106.6' "$S"` |
| VC-5 | 5 位部署+对账：变更部署至 zcode/claude/cursor/agents/opencode 对应技能位，目标文件与源一致且对账无差异 | 路径存在性 + diff/cmp 对账记录 | `ok=0; for base in "$HOME/.zcode" "$HOME/.claude" "$HOME/.cursor" "$HOME/.agents" "$HOME/.config/opencode"; do [ -d "$base/skills/task-planner" ] && [ -d "$base/skills/task-discipline" ] && ok=$((ok+1)); done; echo "present=$ok"; test "$ok" -ge 5`（辅以 diff 证据） |
| VC-6 | 运行位实弹：至少 1 个已部署运行位 hook 一正一负，正例输出提醒且 exit 0，负例不输出提醒且 exit 0 | 对真实部署脚本 stdin 实弹 | `H="$HOME/.zcode/skills/task-planner/scripts/zcode-pretooluse.sh"; p=$(printf '%s' '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.md","old_string":"a\nb","new_string":"c"}}' | bash "$H"); echo "$p"|grep -q '\[md-edit-ops\] 提醒:'; n=$(printf '%s' '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/plans/x.md","old_string":"a\nb","new_string":"c"}}' | bash "$H"); echo "$n"|grep -q '\[md-edit-ops\] 提醒:' && exit 1 || exit 0` |

**终验规则**：全部 VC 通过 → COMPLETE；VC 通过但有已知遗留缺陷 → PARTIAL；≥1 VC 失败且重试 3 次无效 → BLOCKED。`code_review: required`，终验前须 Code Review Gate 结论 APPROVED。

## 🛡 双轮质检与同步完整性声明（Rule 103 — standard）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | P1 实施 S1-S3（脚本/文档改动）、P3 部署对账与实弹结果（实质产出） |
| 豁免登记 | P2 为确定性命令验收（可由命令证据复现）可按 103.7 精简，但须保留命令输出证据；无其他豁免 |
| 多文件变更集预判 | P1 涉及 3 个受管文件（hook 脚本+2 文档）→ 触发 103.6 同步核对清单；P3 多位部署为同步分发面，终验核对对账证据 |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1 |
| **裁决** | `pending`（终验填写：solved / partial / not-solved） |
| **解决证据锚** | （终验填写：VC-1~VC-6 证据路径/命令输出锚） |
| **未解决面+原因** | （终验填写） |
| **已排除路径** | （如 not-solved 填写） |
| **下一步建议** | （如 not-solved 填写） |

## 🎯 Goal 单元表（Rule 66.1 — standard）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | Hook 提醒 | worktree 内 zcode-pretooluse.sh 实现 A 且不破坏既有逻辑 | VC-1 命令 PASS + 代码 Read 确认 advisory 位置/注释 | P1/S1 | complete |
| G2 | 语义接线 | recall-card 与 task-discipline SKILL 增加 B 指定/同义行 | VC-2 命令 PASS + 锚定行 Read | P1/S2,S3 | complete |
| G3 | 模拟验收 | 三正三负与 discipline 4 项全部通过 | VC-3, VC-4 命令 PASS + 输出记录 | P2/S1,S2 | complete |
| G4 | 部署实弹 | 5 位部署对账一致且运行位实弹通过 | VC-5, VC-6 命令 PASS + diff/实弹日志 | P3/S1,S2 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码/脚本 | worktree 内 `skills/task-planner/scripts/zcode-pretooluse.sh`；部署阶段同步到 `$HOME/.zcode/.claude/.cursor/.agents/.config/opencode` 对应 `skills/task-planner/scripts/zcode-pretooluse.sh`（若位存在） | 其他脚本、既有阻断/委派逻辑语义改动 |
| 文档/技能接线 | worktree 内 `skills/task-discipline/references/execution-recall-card.md`、`skills/task-discipline/SKILL.md`；部署阶段同步到上述 5 位对应 `skills/task-discipline/...` 文件 | `critical-rules-discipline.md` 规则正文、其他 discipline 文档、无关技能文件 |
| 配置 | 无 | hooks 配置/registry 等除非部署必需且经证据确认（默认不改） |
| 计划文档 | `/mnt/data/dev/task-planner-skill/plans/task-mdedit-trigger-20261116/{task_plan,findings,knowledge-brief,progress,verification,user-session-log,notepad-learnings}.md` | 其他计划目录、scope 外业务文件 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📋 变更标注表（Rule 74.3 — 修订方案必填）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|------------------------|---------|
| CA-1 | `skills/task-planner/scripts/zcode-pretooluse.sh` `Write\|Edit\|ApplyPatch` 分支头部 | 修改（增量插入 advisory 块） | 增量 | 「扩展 skills/task-planner/scripts/zcode-pretooluse.sh 的 Write\|Edit\|ApplyPatch 分支头部，纯增量 advisory 块（fail-open exit 0，禁改既有阻断/委派逻辑）…」 | Scope A；R2 授权 | 在分支头部加入条件判断与 stdout 提醒+What/Why 注释，不改既有 rc=2 路径 |
| CA-2 | `skills/task-discipline/references/execution-recall-card.md` §B 末尾 | 修改（增量加 1 行） | 增量 | 「①…§B『变更与范围』区末尾加 1 行：『- 批量/结构化 markdown 修改优先 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL』」 | Scope B① | 追加指定 bullet，保留既有行 |
| CA-3 | `skills/task-discipline/SKILL.md` 速查/原则区 | 修改（增量加 1 行同义指针） | 增量 | 「②…速查/原则区加 1 行同义指针（位置自定须锚定）」 | Scope B② | 在可锚定速查段新增 md-edit-ops/Rule 106.6 指针行 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | md-edit-ops 可靠性任务知识底座 | `/mnt/data/dev/task-planner-skill/plans/archive/task-mdedit-reliability-20261116/knowledge-brief.md` §2/§3 | 必读 | ☑ |
| 项目内部文档/知识库 | md-edit-ops 结构化编辑条目 | `/mnt/data/dev/task-planner-skill/knowledge/entries/md-edit-ops-structured-editing.md` | 必读 | ☑ |
| 源码/脚本 | PreToolUse hook 适配器现状 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-pretooluse.sh` | 必读 | ☑ |
| 规范/技能文档 | 执行召回卡与 discipline SKILL | `/home/terry/.zcode/skills/task-discipline/references/execution-recall-card.md`、`/home/terry/.zcode/skills/task-discipline/SKILL.md` | 必读 | ☑ |
| 规范/标准 | Rule 106.6 条款锚点 | `skills/task-discipline/references/critical-rules-discipline.md:741`（据 KB） | 参考 | ☑ |

**填写规则**：定位可唯一定位；必读缺失 STOP；引用对齐调研引用格式。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: md-edit-ops 工具链已可用但触发不稳定，如何在不破坏既有 hook 安全语义的前提下，让普通 .md 结构化/批量编辑场景被可靠提醒并在纪律层可召回，从而封堵触发面缺口？

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（A+B 落地且验收/部署实弹通过即交付）
- [x] 核心问题不解决，其他工作都白费吗？（仅文档或仅脚本单边不足以覆盖“随手 Edit 不触发”两面）
- [x] 核心问题的解决方法是清晰的、可执行的？（Scope A/B、3 Phase、VC 命令已明确）

### T2 问题解构四问（方法论落盘）
1. **问题是什么**：md-edit-ops 已部署但触发面有缺口，普通会话随手 Edit .md 文件不保证触发；需要补齐触发提醒与语义接线（A+B）。
2. **本质是什么（≥5 why）**：①为何不触发？无机械信号在 Edit/Write 前提示 md-edit-ops。②为何无信号？PreToolUse 现有逻辑关注哨兵/委派/技能修改/并发，不识别 .md 结构化编辑模式。③为何纪律不足？执行召回卡/SKILL 未显式指向 md-edit-ops/Rule 106.6 触发动作，依赖记忆。④为何会反复？提醒与召回未形成“hook 机械+语义”双保险。⑤本质：触发链路缺失（工具能力存在 ≠ 使用路径被激活），需在入口处低噪声 advisory 与执行纪律速查处同时接线。
3. **解决方案是什么**：候选 A-only/B-only/A+B；用户已授权 **A+B (Recommended)**。取舍：A 提供即时机械提醒但可能被忽略语义，B 提供召回但无即时信号；组合互补且改动小、风险可控（fail-open advisory + 两行增量文案）。不选单边因无法充分封堵“随手 Edit”缺口。
4. **执行方案是什么**：P1 worktree 实施 A+B（S1-S3）→ P2 模拟验收三正三负+4 项（S1-S2）→ P3 部署 5 位+对账+运行位实弹+收口（S1-S2），每步有 VC 命令与证据锚；兜底见 FMEA。

## 🔍 调研需求与检索计划（Rule 75.1 — standard）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| P1/S1 hook advisory | LOCAL-ONLY | `zcode-pretooluse advisory`, `md-edit-ops trigger` | 本地 Read（脚本/KB） | 实施锚点与条件逻辑 | 否 |
| P1/S2 recall-card 接线 | LOCAL-ONLY | `execution-recall-card §B`, `Rule 106.6` | 本地 Read | 末尾插入点 | 否 |
| P1/S3 SKILL 接线 | LOCAL-ONLY | `task-discipline SKILL`, `速查 md-edit-ops` | 本地 Read | 锚定位置与同义文案 | 否 |
| P2/S1-S2 验收 | LOCAL-ONLY | `stdin json hook`, `grep RC=0` | 本地命令 | 三正三负/4 项证据 | 否 |
| P3/S1-S2 部署实弹 | NET-DATA-DEPENDENT（环境位探测） | `~/.zcode skills`, `~/.config/opencode skills` | 本地文件系统探测 + 对账命令 | 5 位路径清单、diff、实弹输出 | 否（非网络检索） |

> 说明：无外部网络调研需求；P3 依赖本机多技能位实际存在性（环境数据），以探测与对账命令取证。

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | `zcode-pretooluse.sh`、recall-card、task-discipline SKILL、md-edit-ops KB | Read/grep/命令输出 | findings.md, knowledge-brief.md §2/§3 | ☑ |
| ② 对标样本（58.2 强制） | archive 任务 `task-mdedit-reliability-20261116` 既有工具链与 Rule 106.6 落地 | Read knowledge-brief/entry | `plans/archive/task-mdedit-reliability-20261116/knowledge-brief.md`、`knowledge/entries/md-edit-ops-structured-editing.md` | ☑ |
| ③ 外部约束 | Rule 106.6、hook fail-open/advisory 语义、§十一 worktree 与部署惯例 | 规则/脚本证据 | `zcode-pretooluse.sh:83-91` 观察分支模式、KB How | ☑ |

## Current Phase
Phase 1

## Next Step
在 worktree `tmp/worktrees/task-mdedit-trigger-20261116` 中实施 A+B（S1: hook advisory；S2: recall-card 指定行；S3: SKILL 同义指针），完成后运行 VC-1/VC-2 自检并回填 progress/verification。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 code-assistant(haiku-1)；机械守卫脚本（worktree/git/自检命令按需） | 小范围确定性改动（1 脚本+2 单行文档增量），适合轻档执行体；主进程负责派发与盘上复核 |
| Phase 2 | Agent 子代理 code-runner-agent(mini)；Bash 验证命令 | 三正三负与 4 项检查为可复现命令序列，需留输出证据 |
| Phase 3 | 主进程（白名单：部署编排/簿记/归档）；Bash/cmp/diff | 多位部署、对账与运行位实弹需跨路径决策与证据汇总；收口登记 kb/归档视体量 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（非独立并行≥3 S-unit fan-out、非长链编排、无用户点名 /workflow）→ 按 Rule 21.4 独立性守门调度（P1 内 S-unit 有轻依赖可并行评估，默认小步串行/显式声明即可）。

**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；未见用户侧 /goal 锚定，技能层不代调；计划文件路径为 `/mnt/data/dev/task-planner-skill/plans/task-mdedit-trigger-20261116/task_plan.md`。

## Phases

### Phase 1: Worktree 内实施 A+B
- [x] 创建/确认 worktree `tmp/worktrees/task-mdedit-trigger-20261116` 并定位目标文件副本
- [x] 实施 Scope A：hook advisory 纯增量块（条件/文案/注释/fail-open，不改既有逻辑）
- [x] 实施 Scope B：recall-card §B 指定行 + task-discipline SKILL 同义指针（锚定）
- [x] 自检 VC-1/VC-2 命令并回填证据
- **V-N:** VC-1, VC-2（本 Phase 验收映射）
- **Status:** complete
- **Executor:** code-assistant

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 在 hook Write/Edit/ApplyPatch 分支头部新增 .md 结构化编辑 advisory | 继承 | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh`：case 分支解析 tool_input，命中 Edit/Write .md 且非 /plans/ 且满足换行/≥200/≥600 条件则 stdout 提醒并继续；jq 阻断/委派逻辑保留 | VC-1 通过；`[md-edit-ops] 提醒:` 与 What/Why 注释在位；既有 rc=2 路径未改 | 10min | 1f/40l/10min | 无 | - | pending |
| S2 | (A6,建议档位:haiku) 在 execution-recall-card §B 末尾追加指定 md-edit-ops 行 | 继承 | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-discipline/references/execution-recall-card.md`：§B 末项为 Rule 92，追加 brief 指定 bullet | VC-2 中 recall-card 断言通过，原 §B 结构保留 | 5min | 1f/5l/5min | 无 | - | pending |
| S3 | (A6,建议档位:haiku) 在 task-discipline SKILL 速查/原则区追加同义 md-edit-ops 指针并锚定 | 继承 | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-discipline/SKILL.md`：定位/域边界或规则索引邻近速查段，新增含 md-edit-ops 与 Rule 106.6 的指针行 | VC-2 中 SKILL 断言通过，指针位置可在 plan/证据中锚定 | 5min | 1f/5l/5min | 无 | - | pending |

### Phase 2: 模拟验收
- [x] 在 worktree 脚本上执行 hook 三正三负并记录输出/退出码
- [x] 执行 discipline 4 项检查并记录结果
- [x] 回填 verification.md V-2.1/V-2.2 与 progress 证据
- **V-N:** VC-3, VC-4（本 Phase 验收映射）
- **Status:** complete
- **Executor:** code-runner-agent

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6,建议档位:mini) 运行 hook 三正三负模拟用例 | 继承 | worktree `skills/task-planner/scripts/zcode-pretooluse.sh`；stdin JSON 覆盖 Edit 换行、Edit old+new≥200、Write content≥600 三正例及 /plans/、单行小改、短 Write 三负例 | VC-3 通过；命令输出显示正例命中提醒、负例不命中，exit 0 | 10min | 1f/0l/10min | 无 | S1 | pending |
| S2 | (A6,建议档位:mini) 运行 discipline 接线 4 项检查 | 继承 | worktree `execution-recall-card.md` 与 `task-discipline/SKILL.md`；检查指定行/§B 锚/md-edit-ops/Rule 106.6 | VC-4 通过；4 项条件均真 | 5min | 2f/0l/5min | 无 | S2,S3 | pending |

### Phase 3: 部署 5 位+对账+运行位实弹+收口
- [x] 将 A/B 变更部署到 5 位技能位（zcode/claude/cursor/agents/opencode）并记录路径
- [x] 对账源与目标文件一致性（diff/cmp 证据）
- [x] 运行位实弹一正一负并记录输出
- [x] 收口：更新 progress/verification/findings，按体量决定归档/kb（登记决策与证据）
- **V-N:** VC-5, VC-6（本 Phase 验收映射）
- **Status:** complete
- **Executor:** 主进程（例外理由：① git 编排/部署对账与运行位验证 ② 计划系统文件/簿记维护与收口——Rule 25.3 白名单①②）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 部署 hook 脚本与 recall-card 到对应位 | 主进程（白名单） | worktree 已验收：zcode-pretooluse.sh+execution-recall-card.md；目标位=HOME 下 5 位 skills 目录（zcode/claude/opencode/agents/cursor）；hook→5 位 task-planner/scripts、card→4 位 task-discipline/references | VC-5 部分：cp 后 diff 无差异 | 8min | 2f/0l/8min | 无 | S1,S2(P2) | pending |
| S2 | 部署 task-discipline SKILL 并完成 5 位全量对账 | 主进程（白名单） | worktree 已验收 task-discipline/SKILL.md→4 位 task-discipline/；随后逐文件 diff/cmp 全对账 | VC-5 通过；5 位 diff/cmp 无差异 | 7min | 1f/0l/7min | 无 | S1(P3) | pending |
| S3 | 运行位实弹一正一负并收口记录 | 主进程（白名单） | 已部署运行位 hook 路径（~/.zcode/skills/task-planner/scripts/zcode-pretooluse.sh）；计划目录 verification/progress | VC-6 通过；实弹输出与归档/kb 体量决策登记 | 10min | 0f/0l/10min | 无 | S2(P3) | pending |

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1    | （终验前填写） | （终验前填写） |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `pending`（实施前跑 `check-conflicts.sh` 并回填；本计划为 hook/技能文档改动，预判低冲突但仍走 worktree） |
| `isolation` | `worktree`（实现类改动，按 brief） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116` |
| `branch` | `wt/task-mdedit-trigger-20261116` |
| `merge_back` | `pending` |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/worktree-isolation.md`。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | hook advisory 插入位置/逻辑误伤既有 delegation/skill-modify 阻断链或非 fail-open | 9 | 3 | 5 | 135 | ⑤/①：先 Read 原脚本锚点最小增量插入；P2 前跑现有自检命令并代码审阅 rc=2 路径；异常立即回退该块并 AskUserQuestion（Rule 70） |
| Phase 2 | 三正三负用例覆盖不足（漏判 /plans/、单行边界、字符计数方式差异）导致漏检 | 7 | 4 | 5 | 140 | ④：主进程补充边界用例（含 CRLF/多字节不在 scope 则记录）并复跑 VC-3；失败按 22.3 拆细重测 |
| Phase 3 | 多位部署不一致或运行位未实弹/路径误判（opencode 等位不存在） | 8 | 4 | 4 | 128 | ④/⑤：先探测 5 位实际路径并登记；diff 对账失败逐位修复；若某位不存在如实记录证据并判定是否满足 VC-5（需 ≥5 位存在目标技能目录）后升级用户决策 |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | Worktree 实施 A+B |
| Phase 2 | ☐ |  | 模拟验收三正三负+4 项 |
| Phase 3 | ☐ |  | 部署5位+对账+实弹+收口 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions
1. 5 位技能位的具体路径在本机是否全部存在（尤其 `~/.config/opencode/skills`）？P3 需探测并以证据记录。
2. task-discipline SKILL 中“速查/原则区”锚定到哪一行/标题最稳定且显眼？（P1/S3 需在证据中明确锚点）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 采用 A+B 组合 | 用户 2026-11-16 AskUserQuestion 显式授权「A+B 组合 (Recommended)」，机械提醒+语义召回互补 |
| template_type=rule-enhancement, standard | hook 守护/纪律触发面增强，含多 Phase、多 VC 与部署对账，非 mini |
| D1 授权登记（2026-11-16，五要素）：①路径=非超时——用户 AskUserQuestion 显式答复 ②推荐项=「A+B 组合 (Recommended)」（用户亲选，hook 机械提醒+语义接线）③触发时间=2026-11-16 计划展示前答复④裁决理由=答复与计划 Scope A/B 逐字一致=显式授权⑤被覆盖未决选项=仅 A/仅 B/暂不改（均被用户否决） | 计划 attest 锁定 SHA f11265c5…；user-session-log #1 授权锚+#2 逐字问询原文（80.4 权威面） |
| P1 Executor=code-assistant(haiku-1) | 1 脚本+2 单行文档增量，小改动低风险，轻档足够 |
| P2 Executor=code-runner-agent(mini) | 确定性命令验收与证据采集，适合 runner 执行 |
| P3 Executor=主进程（白名单） | 部署编排、跨位对账、运行位实弹与收口簿记属主进程白名单职责 |
| advisory fail-open 且不改既有逻辑 | Scope A 明确约束；避免引入阻断回归 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
- 计划期仅产出计划文件；实施须在 worktree 内进行。
- Phase 状态变更时同步更新 Next Step、Todo 同步表与 verification 证据。

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务） |
| `success` | n/a（非批量任务） |
| `failed` | n/a（非批量任务） |
| `failure_rate` | n/a（非批量任务） |
| `sampled_pass` | n/a（非批量任务） |
| `sampled_fail` | n/a（非批量任务） |
| `pre_check` | n/a（非批量任务） |
| `rollback_point` | n/a（非批量任务） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 3（计划期占位） |
| 主进程直做 Phase 清单 | Phase 3（例外理由：部署编排/运行位验证/簿记与收口，Rule 25.3 白名单） |
| 委派率 | （终验填写） |
| 激活子代理数（Rule 96.5） | （终验填写） |
| 最大并行宽度（Rule 96.5） | （终验填写） |
| 串行化例外理由（Rule 96.4） | （终验填写） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | code-assistant(haiku-1) | P1 worktree 实施 A+B (S1-S3) | queued | | | | | - / 0 / ☐ |
| 2 | | code-runner-agent(mini) | P2 模拟验收 (S1-S2) | queued | | | | | - / 0 / ☐ |
| 3 | | 主进程 | P3 部署5位+对账+实弹+收口 | queued | | | | | - / 0 / ☐ |

## 🔗 Chain 区块交接配置（可选）

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 触发信号: hook/守护提醒与纪律接线触发面增强，命中 rule-enhancement 画像
- Rule 34.3②: 沉淀预登记 —— 本任务为已有 rule-enhancement 类紧凑补丁实例，终验评估是否补充“触发面封堵(hook advisory+recall 接线)”可复用片段；当前不新建 variant
- 终验必查: Scope A/B 与 VC 证据链完整
- 处置登记处: 终验后在 Decisions/findings 登记沉淀理由或不沉淀理由

## 📋 Handoff 表（子代理派发登记 — Rule 22/25 委派门判据面）

| Phase | S-unit | 子代理类型 | 检查点 | 状态 |
|-------|--------|-----------|--------|------|
| P1 实施 A+B | S1-S3 | code-assistant | subagent-state/p1-checkpoint.md | done |
| P2 模拟验收 | S1-S2 | code-runner-agent | subagent-state/p2-checkpoint.md | done |
