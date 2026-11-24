# 修正方案：让简单任务走通轻量快车道，并给审计环装上脚本刹车

## Context（为什么是这个方案）

你投诉"给综艺补 4 个常驻嘉宾人设"跑了几小时且不准。判例任务实据：2h41m、5 Phase / 12 S-unit，其中**整整 1 小时花在 5 轮计划审计上**（`3C/9I → 0C/4I → 0C/2I → 0C/1I → APPROVED`）。

本轮只读取证推翻了父会话"头号根因是 ≤2 文件门槛"的判断，真实断点是四个，且前两个此前从未被修到：

1. **修复不可持久**：11-23 针对同一问题的四项修复只落在源仓工作区、从未进 master；zcode 部署位（你实际在用的运行位）现在是版本碎片——`init-session.sh` / `task-plan-init.cjs` / `attest-plan.sh` 是"无修复"版，`planctl.py` 是"含修复"版。auto-tier 在线上仍是"需显式开关、从没人打开"的死机制。
2. **体量链路三处会断**：写入挂在 SessionStart（该脚本注释自述"早于首条用户消息，读不到 prompt"）；读取只认 `CLAUDE_CODE_SESSION_ID`（同目录 `zcode-userpromptsubmit.sh:38-41` 早为这个断裂补过 `ZCODE_SESSION_ID`，新代码没对齐）；推断是二值的（"4 个嘉宾"→`files: 1`）。
3. **审计环无脚本驱动点**：循环体内没有任何脚本被调用；止损只挂在默认 `warn` 的 attest 上；主口径依赖 `issues` 字段而真实任务从不带。
4. **mini 档不是全链豁免**：`sync-todos.sh` 的 16 条基线 todo 无档位裁剪；G4–G8 未标豁免；三处"≤2 文件"硬口径与新口径冲突。

**需要我如实更正的**：父会话我交付的"纯文档 3–5 文件降档"（已在 master `e95e313e`）触发条件是 `TASK_SCOPE_FILE_LIST`，全仓无任何写入方——它在真实路径上一次都不会触发，沙箱通过是因为我手工喂了 env。当时说"根因已解决"过头了。本方案把它改成真实入口驱动。

**目标（可验证）**
- A. 你的原话经真实入口（UserPromptSubmit → init，零手工 env）落 `plan_tier: mini`；mini 必做 todo 从 17 条降到 ≤11 条，不派审计体 / drift-checker。
- B. 任何档位计划审计连续 2 轮 REJECTED 后，第 3 轮被脚本拦住，直到登记收口。
- C. 全部改动在 **zcode 部署位形态**下端到端验证通过，已提交、已部署、已对账。

---

## 包 1 — 先把地基修平（持久化）

- 把 11-23 已批准、已验证但未提交的四项修复正式入库：从主仓工作区导出 `attest-plan.sh`、`task-plan-init.cjs` 及 `init-session.sh` / `planctl.py` 的 lean hunk，在 worktree 应用、逐 hunk 复核后提交。
- 收口 `plans/task-planner-lean-20261123/`（补 outcome、归档）。

## 包 2 — 体量事实链路修通

**执行第一步先实测两个平台前提**（plan 模式下测不了；任一不成立就调整实现，不硬上）：① ZCode Bash 环境有无 `CLAUDE_CODE_SESSION_ID`；② UserPromptSubmit 的 stdin 是否携带用户原文及字段名。

- `scripts/task-plan-init.cjs`
  - 内联二值推断抽成具名函数，输出增加 `kind`（code / doc）；`files` 改为数量感知（"N 个/位/名/份"，支持中文数字），否则为 1。
  - 新增 `--scope-only` 子模式：只落盘 scope 后退出，不碰哨兵。SessionStart 原路径不变。复用既有 `normSidkey`（:68）与 `SIDE_DIR`（:100）。
- `scripts/zcode-userpromptsubmit.sh`
  - 在"探测活跃计划"（:45）之前加一步：取 prompt 调 `node task-plan-init.cjs --scope-only`。仅当"无活跃计划或计划已完结，且 scope 缺失或超过 30 分钟"时写，避免后续追问覆盖首条指令的体量。fail-open。
- `scripts/init-session.sh`
  - 兜底读取的 sid 源补 `ZCODE_SESSION_ID`（对齐 `zcode-userpromptsubmit.sh:38-41` 的既有兜底链）；路径不再依赖 `cd ..`。
  - 读取 `kind`；纯文档降档增加"`kind=doc` ∧ 文件数 3–5"分支，不再依赖无人提供的 `TASK_SCOPE_FILE_LIST`（后者保留为显式信号）。

**里程碑 1**：真实入口回放通过（见验证）后才继续。

## 包 3 — 审计环脚本刹车

- `scripts/planctl.py`
  - 新增 `audit_cap()`：累计 REJECTED ≥ 2 且无 APPROVED 即命中——只看轮数，不看 issue key、不看审计体名。紧邻既有 `audit_no_progress()`（:244）。
  - `add --section audits` 写入后命中即打印 `[audit-cap]` 强制指令：停派审计体 → 可选一次 decision-arbiter 裁决 → 按裁决收口并登记 `[audit-converge]` + 遗留风险清单。
- `scripts/zcode-pretooluse.sh` 的 `Agent` 分支（:110，已存在）
  - 读活跃计划：cap 命中且未登记 `[audit-converge]` → `exit 2`；`decision-arbiter` 始终放行。
  - 同一分支实现 Rule 96.7 的派发计数：会话级计数（复用 `zcode-pretooluse.sh:40-48` 的 mdedit 计数文件模式），累计 >40 次 → `exit 2`，直到登记 checkpoint。
- 口径统一（三处不同数字 → 一个）：`SKILL.md:73`、`references/critical-rules.md` 109.2 / 109.8、`references/plan-workflow-details.md:80`。

## 包 4 — mini 残余仪式裁剪 + 口径对齐

- `scripts/sync-todos.sh`：基线组按档位裁剪，mini 不输出 B2 / B6 / B7 / B8 / B15 / B16（每条对应一个已明文的 mini 豁免：单 Phase、G11 对齐、不走 worktree、DRIFT GATE 跳过）。standard 输出不变。
- `SKILL.md`：G4 标 mini 豁免（与 `check-complete.sh:392` 一致，保留原有字面锚）；新增一张"mini 最小流程"指针表，把散落的豁免收成一处。
- 三处"≤2"对齐：`check-plan-dispatch.sh:96`（auto-tier mini 的范围表阈值放宽到 5）、`templates/variant/mini-lite-type.md:2,4,29`、`templates/variant/l0-lite-type.md:21`。
- `scripts/zcode-posttooluse.sh`：mini 档不再发 drift-rhythm 提醒（当前只是 ×2 降频）。

## 包 5 — 部署与对账

- 先 `git archive HEAD skills/task-planner` 导出纯已提交内容 → 四位整目录 tar 备份 → `rsync -a` **不带 `--delete`**（部署位有自己的 `.git` 等近万项）→ 关键文件 sha256 对账 → 在部署位实跑 hook。
- 范围：`~/.zcode`（必须，ZCode 实际运行位）+ `~/.agents`、`~/.claude`、`~/.cursor`（现各自落后不同版本）。
- SKILL.md 逐位判向：薄壳位不动；全量旧副本位同步到源仓正文。**批准本计划即授权以上四位部署**（保护区）。

---

## 验证

- **真实入口回放（核心）**：把 zcode 部署位形态复制到沙箱（复用 `selftest-compact-recovery.sh` T17 的搭建方式：scripts 全量 + 43 行薄壳），用你的原话构造 UserPromptSubmit stdin → 断言 `.plan_scope` 为 4 个文件 / doc → 调 `init-session.sh` **零 env** → 断言 `plan_tier: mini` + mini-lite 模板 + 不被 variant 吞。
- **变异复演**（证明是这条链在起作用）：去掉 hook 的 scope 写入 → 同一 prompt 应回落 standard；恢复 → mini。审计 cap：构造 2 轮 REJECTED → Agent 调用被 `exit 2`；登记 `[audit-converge]` → 放行；`decision-arbiter` 始终放行。
- **全量回归**：`run-selftests.sh --fresh` 对照基线 106/106，不增 FAIL。只为随行为变更而必须同步的既有断言做调整，不新增断言。
- **一次独立复核**：全新子代理只读复核 diff 与证据。

## 明确不做

- 不动 SessionStart 的 SKILL.md 全文注入（你的明确要求）。
- 不砍子代理委派门、CLI/planctl、Superpowers/OpenSpec（11-23 裁决）。
- 不动 Git 三件套（B9–B11）与 SP/OS / Spec / 两段式（B12–B14）基线项。
- 不改标准档收尾回读"不设上限"（你的裁决）；不动 S-unit 粒度。
- 规则面瘦身（526KB / 127 条）不在本方案，需单独立项。
- 不返工 StoryLab 那个任务本身（部署后重跑应落到分钟级，那是另一个项目的指令）。

## 需要你定的一点

Rule 96.7 时间维度（累计 >60 分钟）：
- **只提醒不硬停 (Recommended)**——硬停会让无人值守的长任务停摆，与你此前"没完成就恶意停止"的投诉相冲。派发数维度（>40 次）做硬门。
- 时间维度也硬停——执行时一行切换。

## 执行约定

- worktree `tmp/worktrees/perf-chain-20261124`（基线 master），按包分 5 次提交；合并时若与他会话未提交改动 hunk 重叠，沿用三方合并逐字保留双方；合并后立即清理 worktree 与分支并 push。
- 首步做意图切换登记：当前活跃计划是"对比文档"任务，与本任务无关，挂起不改。
- 零新增文件 / hook / selftest；改动全部落在现有脚本与现有文本内。