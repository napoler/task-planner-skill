# drift-check-2 — 收口前复合偏移检查（task-kb-persist-20261022）

- 检查时间：2026-10-22
- 角色：复合偏移检查（只读检查 + 唯一检查点写入）
- 写面限制：仅本文件可写；仓库其余文件零修改（未运行任何写性脚本，未执行 check-complete / attest / archive-plan / sync-todos）
- 判定：**⚠️DRIFT**（7 项偏离，全部为簿记/指针级；交付物与能力面本身成立，无功能阻塞项）

---

## 一、检查项逐条结果

### 检查项 1：需求全命中对齐 —— ✅ PASS（三能力全覆盖）

用户原话 #1（user-session-log.md:25）三能力 → 最终交付对照：

| 用户能力面 | 交付物 | 实测证据 |
|---|---|---|
| ① 每次积累持续沉淀 | `scripts/kb-sync-from-plan.sh` + `.zcode/plan-templates/knowledge-brief.md` §7（:79「§7 项目知识库回链（终验后入库触发）」，含触发点/入库命令/精炼/索引/条目规范 5 条） | 文件在位；§7 段实读存在 |
| ② 持久化累计（可复用） | `knowledge/` 12 主题条目（13 文件含 1 draft）+ `INDEX.md` 13 行 + `entry-template.md` + `README.md`；每条带 sources 回链（12 正式条目 114 sources） | `ls knowledge/entries/*.md` = 13；`grep -c '^| ' knowledge/INDEX.md` = 13 = 12+1 表头 |
| ③ 解决类似问题快速查询复用 | `scripts/kb-search.sh`（关键词 + `--tag`）；`kb-rebuild-index.sh` 索引派生 | 实跑 `bash scripts/kb-search.sh 派发` exit 0，命中 dispatch-lifecycle-return-contract / dispatch-split-decision / misc-task-typing-and-execution-gates，输出含 `plans/archive/...` 来源路径 |
| 合并回 master | 03ffb944 | `git log` = 037c683 → bca7104 → ced08af → 03ffb94（merge），HEAD 之上为 7eddc7c 计划目录入库 |

未覆盖能力面：**无**。已知未做而属用户明示禁区/登记遗留者（不构成能力面缺失）：模板闭环仅项目级覆盖未触 `~/.zcode/**`（task_plan.md:111 范围限制）；58 份模板占位 kb 无内容可蒸馏（delivery-summary.md:42）；draft 需人工精炼（非全自动）。

### 检查项 2：声称—证据一致 —— ⚠️ 部分不一致（D-C / D-D）

| 声称 | 证据文件存在性 | 结论 |
|---|---|---|
| task_plan.md:91 58.5 裁决「solved」，证据锚 = `subagent-state/P4-S2-verifier.md` + `verification.md` Goal Gate | **存在**：`subagent-state/P4-S2-verifier.md`（91 行，含 VC-1~7 各命令与输出、114/114 sources 审计、4 项对齐审查、58.5 供料表）；`subagent-state/P4-S1-code-runner.md`（42 行，92/92 PASS、A=0、「套件有牙」负验证）；`verification.md:141-155` Goal Gate 段（outcome: **COMPLETE**） | ✅ 声称与内容相符 |
| delivery-summary.md:3「COMPLETE（VC-1~7 全 PASS，92/92 零回归）」 | 同上三份证据一致；`verification.md:145-154` 逐 VC PASS 可对照 | ✅ 相符 |
| delivery-summary.md:35「机器门 check-complete / check-delegation / attest → exit 0 / verdict=ok(rate 1.000) / SHA 锁定」 | check-delegation 有据（verification.md:129 JSON verdict=ok rate=1.000）；**check-complete 无任何运行记录**（全目录 grep 仅 3 处提及，无输出锚）；且 attest SHA 已失效（见 D-D） | ❌ 不符（见 D-C/D-D） |

### 检查项 3：范围终检 —— ✅ PASS

```
git show --stat 037c683 bca7104 ced08af 03ffb944
```
| Commit | 文件 | 是否在允许清单 |
|---|---|---|
| 037c683 | knowledge/INDEX.md、README.md、entry-template.md、entries/_draft-task-v122.md、scripts/kb-{search,rebuild-index,sync-from-plan}.sh（7 files, 391 ins） | ✅ 全在 `knowledge/**` + `scripts/kb-*.sh` |
| bca7104 | knowledge/INDEX.md（重建）+ 12 正式条目（13 files, 834 ins, 1 del；1 del = 新文件内生成时间戳行被替换，非既有内容删除） | ✅ 全在 `knowledge/**` |
| ced08af | .zcode/plan-templates/knowledge-brief.md（1 file, 86 ins） | ✅ 在清单内 |
| 03ffb944（merge） | 合计 20 files, 1310 insertions, 0 deletions（16 knowledge + 3 scripts + 1 .zcode） | ✅ 无越界 |
| 7eddc7c（计划目录入库，其后） | `plans/task-kb-persist-20261022/**` 34 files | ✅ 在清单内 |

禁区核查：`skills/**` 与既有 `scripts/*.sh` 在本任务 4 commit 中**零修改**（当前 `git status` 中 `skills/task-planner/SKILL.md`、`references/critical-rules.md`、`scripts/selftest-requirement-coverage.sh` 的脏状态系**其他任务在途产物**，不在本任务 commit 内）；`~/.zcode/**` 部署位零写入；worktree 与 `wt/task-kb-persist-20261022` 分支已清理（`git worktree list` 仅主仓，`git branch` 无该 wt 分支）。

### 检查项 4：三源一致 —— ❌ FAIL（见 D-A / D-B）

| Phase | task_plan.md `**Status:**` | progress.md `**Status:**` | verification.md Phase Gate `Status:` |
|---|---|---|---|
| 1 | complete (:175) | complete (:14) | complete (:55) |
| 2 | complete (:190) | complete (:39) | **pending (:74)** ❌ |
| 3 | complete (:208) | complete (:61) | complete (:93) |
| 4 | complete (:221) | complete (:78) | complete (:112) |

三源合取不成立 → 检查项 4 FAIL。

---

## 二、偏离点清单

| # | 检查项 | 类型 | 描述 | 严重度 | 证据 | 建议动作（本次未执行） |
|---|--------|------|------|--------|------|----------------|
| **D-A** | 4 | 状态冲突（三源不一致） | `verification.md:74` Phase 2 = `Status: pending / Last verified: —`，与 task_plan.md:190、progress.md:39 的 `complete` 冲突；连带 verification.md:66-72 的 Phase 2「Done when」3 条 + V-2.1/V-2.2 复选框全未勾；同段 verification.md:14-34 的 VC-1~VC-7 主契约 7 项复选框亦全未勾、Evidence 仍为占位「（终验时填…）」，实测结果只落在 Goal Gate 段（:141-155） | **中**（终验文档三源口径破裂，且 Phase 2 门从未被标记 verified） | `grep -n '^Status:' verification.md` → :55 complete / :74 pending / :93 complete / :112 complete | 将 verification.md Phase 2 翻 `Status: complete` + 勾 V-2.1/V-2.2 与 Done-when（证据=progress.md Phase 2 Test Results 表：12 条目/索引 13 行=12+1/双采样 2/2）；同步勾 VC-1~VC-7 主契约并把 Goal Gate 结果回填 Evidence 字段 |
| **D-B** | 4 | 状态自相矛盾 + 机器门阻断 | task_plan.md Phase 1 的 4 条 checklist 仍为 `- [ ]`（:170-173）而同段 `**Status:** complete`（:175）。仓库自带门 `bash skills/task-planner/scripts/check-state-consistency.sh plans/task-kb-persist-20261022` 实测输出 `[state-mismatch] S-1a Phase 1: 存在 4 个未勾「- [ ]」但 **Status:** complete` → **exit 1 FAIL**；`check-complete.sh:126-150` 前置调用该门，sc_rc=1 即 `exit 1` 阻断收口 | **高**（唯一机器可判的收口阻断项；仅需勾 4 个框） | 实跑输出如上 | 勾选 task_plan.md:170-173 四条（Phase 1 工作确已完成：worktree 建立+3 脚本+2 文档+冒烟全过，见 progress.md Phase 1 Test Results），重跑该门至 PASS |
| **D-C** | 2 | 声称—证据不符 | delivery-summary.md:35「机器门 check-complete / check-delegation / attest → exit 0」——计划目录内**无任何 check-complete 运行记录**（全目录 grep「check-complete」仅 3 处文本提及，无输出锚、无退出码证据）；且按 D-B 现状该门会 FAIL | 中 | `grep -rn "check-complete" plans/task-kb-persist-20261022/` | D-B 修复后实跑 check-complete.sh 并把输出与退出码落 verification.md，再据实回填 delivery-summary.md:35 |
| **D-D** | 2 | 锁定失效 | `.plan-attestation` 的 `plan_sha256=cf03dbfd4292acbf4b5cd41ec6d5291098f64c074f7bd21e7610345a0a071270`（attested_at=2026-10-22T06:14:43）与当前 task_plan.md 实测 `sha256sum` = `e674640405b809d3f80572c381fcb30f025022088b079c8d5e72f6199b6b2d09` **不符**——task_plan.md mtime 06:16 晚于 attest 06:14:43（Phase 2/3 checklist 由 `[ ]` 改 `[x]` 的未提交编辑所致） | 中 | `cat .plan-attestation` + `sha256sum task_plan.md` | 修完 D-A/D-B 后重新 attest（attest-plan.sh），使 plan_sha256 与终态文件一致 |
| **D-E** | 1 | 交付指针失效 | delivery-summary.md:24「审计档案 → `/mnt/data/dev/task-planner-skill/plans/archive/task-kb-persist-20261022/`」——该目录**不存在**；计划仍在 `plans/task-kb-persist-20261022/`，task_plan.md:154 Next Step 中 `archive-plan 归档` 仍为待办 | 低 | `ls -d plans/archive/task-kb-persist-20261022` → No such file | 归档执行后刷新该行指针；归档前可改为现行路径 |
| **D-F** | 2 | 登记残留 | progress.md:31 Phase 1 Test Results「全在位（wc 86/60/**84**/63/40 行）」仍记 kb-sync-from-plan.sh = 84 行，实测 **90 行**（drift-check-1 D-2 的更正仅以注记形式落在 :26，表格值未改） | 低 | `wc -l scripts/kb-sync-from-plan.sh` → 90 | 将 :31 表内 84 改 90（:25 Files 段已是 90，口径自相矛盾） |
| **D-G** | 2 | 登记表未闭合 | findings.md:63-67「Issues Encountered」表仍为空行（drift-check-1 D-7 仅闭合了 task_plan.md Drift Log 一侧；findings 侧 Issues 表未回填 Phase 1 的 gawk ERE 陷阱 / sources 绝对路径缺陷 / `*ask*` 关键词误匹配等已实际发生事项） | 低 | findings.md:63-67 | 按 Rule 71 回填 Issues 表（结论须带源锚） |

**遗留观察项（非偏离，不计入判定）**
- `plans/INDEX.md` 与 `plans/.rule-reservations.jsonl` 当前为未提交修改：前者是本任务 `sync-todos --index`（04:58，早于 Phase 2-4 完成，故仍显示 in_progress Phase 1/4，属刷新时序滞后）；后者新增的两行 `rule:93 / task-v195-spec-recall` 系**其他任务**产物，与本任务零关联。
- `knowledge/entries/_draft-task-v122.md` 正文标题行内嵌 worktree 绝对路径（frontmatter sources 已仓相对合规），重跑 kb-sync 会改写 tracked 文件——已在 task_plan.md:92 与 delivery-summary.md:40 登记为遗留，本检查未复跑该脚本，未触发。
- VC-5 口径已在 drift-check-1 统一为「INDEX 数据行 = 非 draft 条目数 + 1 表头」：task_plan.md:77 与 verification.md:27 现均为 `grep -v _draft` +1 口径，一致，遗留风险已消。

---

## 三、判定

**⚠️DRIFT**

- 需求面（检查项 1）与范围面（检查项 3）**均成立**：三能力全部有交付物与可复现实跑证据；4 个 commit 共 20 文件纯新增、零删除，全部落在允许清单内，禁区零触碰，worktree/分支已清理。
- 证据面（检查项 2）**主体成立**（P4-S1 / P4-S2 / verification.md Goal Gate 三份证据齐备且与声称相符），但机器门声称（check-complete exit 0）无证据锚且与现状相冲、attest SHA 已失效。
- 状态面（检查项 4）**不成立**：verification.md Phase 2 = pending、task_plan.md Phase 1 checklist 未勾，且仓库自带 `check-state-consistency.sh` 实测 FAIL → `check-complete.sh` 会在收口前置门 exit 1。

**收口前必做（按序，2 项即可解锁机器门）**：D-B（勾 task_plan.md:170-173 四框）→ D-A（verification.md Phase 2 翻 complete + 勾 VC 主契约/Phase 2 复选框）→ D-D（重 attest）→ D-C（实跑 check-complete 并落证 + 回填 delivery-summary.md:35）→ D-E/D-F/D-G（指针与登记表订正）。

---

## 四、证据锚

- 计划文档：`/mnt/data/dev/task-planner-skill/plans/task-kb-persist-20261022/{user-session-log.md,task_plan.md,progress.md,findings.md,verification.md,delivery-summary.md,.plan-attestation}`
- 子代理检查点：`/mnt/data/dev/task-planner-skill/plans/task-kb-persist-20261022/subagent-state/{P4-S1-code-runner.md,P4-S2-verifier.md,drift-check-1.md}`
- 实测命令：`git show --stat 037c683 bca7104 ced08af 03ffb944`、`git show --stat 7eddc7c`、`git log --oneline -8`、`git status --short`、`git worktree list`、`ls knowledge/entries/*.md | wc -l`、`grep -c '^| ' knowledge/INDEX.md`、`wc -l scripts/kb-*.sh knowledge/*.md .zcode/plan-templates/knowledge-brief.md`、`bash scripts/kb-search.sh 派发`、`bash skills/task-planner/scripts/check-state-consistency.sh plans/task-kb-persist-20261022`、`sha256sum task_plan.md`、`cat .plan-attestation`、`ls -d plans/archive/task-kb-persist-20261022`
- 未执行（只读约束）：check-complete.sh / attest-plan.sh / archive-plan.sh / sync-todos.sh / kb-sync-from-plan.sh（VC-3 会改写 tracked draft）
