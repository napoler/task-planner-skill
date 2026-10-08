# 10-drift-checker — task-v148 Phase 3（实现落地）目标对齐判定

- **判定契约**: Rule 61 三态（ALIGNED / DRIFT / BLOCKED）；拿不准=DRIFT
- **执行体**: general-purpose（原 drift-checker 载体 provider 失败改派，Rule 22.3①）
- **时间**: 2026-10-08（Phase 3 收口）
- **判定范围**: Phase 3 实现落地（S1-S6 产物 + worktree 写入面）
- **只读声明**: 除本检查点外零写入；未执行任何 git 写操作

---

## 一、三锚输入（Rule 64.4）

| 锚 | 来源（绝对路径/命令） | 内容摘要 |
|----|----------------------|---------|
| ① Goal 原文锚 | `plans/task-v148-drift-enforce/task_plan.md`「## Goal」段（:31-32） | 落地 Rule 64 三层机械闭环（64.1 留痕三件套 + 64.2 Phase complete 硬门控 + 64.3 hook 节奏 + 64.4 判定输入契约），载体复用 Rule 61 drift-checker 语义零改动；selftest 零新增回归后合并 master 并部署三实体位 IDENTICAL |
| ① 附 scope 表 | 同文件「⚠️ 执行范围限制」表（:80-91） | 允许 8 文件：critical-rules.md / ledger-append.sh / check-3file-gate.sh / zcode-posttooluse.sh / selftest-drift-enforcement.sh(新建) / SKILL.md / drift-checker.md / CHANGELOG.md；另 plans/task-v148-drift-enforce/** 计划文件豁免 |
| ② 最近动作清单锚 | `plans/task-v148-drift-enforce/progress.md` Phase 3 段（:44-69） | 12:00 worktree 创建 → S1-S6 逐单元派发与主进程独立复验 → 13:50 Phase 3 complete；Test Results 8 行全 PASS；累计 diff 8 文件 +151/−2（内容级零删除） |
| ③ scope 文件集锚 | 同 scope 表 + `task_plan.md` `scope_files`（:41） | 见上；scope_files 字段额外含 `plans/task-v148-drift-enforce/**`(计划系统文件豁免) |

---

## 二、worktree 写入面逐一对照（机械核对）

命令：`git -C /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce diff --numstat` + `git status --short --untracked-files=all`

| # | 实际改动文件 | numstat(+/-) | scope 表归属 | 判定 |
|---|-------------|-------------|-------------|------|
| 1 | skills/task-planner/references/critical-rules.md | 18/0 | ✓ 技能规则（尾部追加） | IN |
| 2 | skills/task-planner/scripts/ledger-append.sh | 3/1 | ✓ 技能脚本 | IN |
| 3 | skills/task-planner/scripts/check-3file-gate.sh | 83/0 | ✓ 技能脚本 | IN |
| 4 | skills/task-planner/scripts/zcode-posttooluse.sh | 41/0 | ✓ 技能脚本 | IN |
| 5 | skills/task-planner/scripts/selftest-drift-enforcement.sh | 新建(untracked) | ✓ 技能脚本（新建） | IN |
| 6 | skills/task-planner/SKILL.md | 2/1 | ✓ 技能入口（2 处纯追加） | IN |
| 7 | skills/task-planner/companion/agents/drift-checker.md | 1/0 | ✓ 伴飞 agent（≤3 行追加） | IN |
| 8 | CHANGELOG.md | 2/0 | ✓ 文档（追加条目） | IN |
| 9 | skills/task-planner/scripts/selftest-registry.tsv | 1/0 | ✗ 未逐字列入「⚠️ 执行范围限制」表 / scope_files 字段 | 授权内（见 §三 观察项 1） |
| — | plans/task-v148-drift-enforce/** | 未出现在 worktree（主仓 untracked） | ✓ 计划文件豁免 | IN |

- 合计 worktree 写入 9 文件（8 tracked diff + 1 untracked 新建）；**零范围外写入、零未授权文件改动**。
- worktree 分支 `wt/task-v148-drift-enforce` HEAD=e54973d（= master，改动全部为工作树未提交态）；`git rev-list --left-right --count master...HEAD` = 0 0。
- plans/ 其他任务目录（task-v146 簿记 / task-v147 计划目录）主仓未提交项=**冲突扫描已登记的既有在途**（conflict_scan 信号① 17 文件），非 task-v148 写入；本任务仅在 `plans/task-v148-drift-enforce/**` 落盘。

---

## 三、锚点独立复验（主进程/检查体亲手复现，非采信声明）

| VC | 复验命令 | 实测结果 | 状态 |
|----|---------|---------|------|
| VC-1 | `grep -c '^64\.[1-6] \*\*' critical-rules.md` + `grep -n '^### 64'` | =6；块头 :769 | PASS |
| VC-2 | `grep VALID_EVENTS ledger-append.sh` | :30 含 `drift_check`（第 8 项，既有 7 项原样） | PASS |
| VC-3 | `grep 64.2/drift_check_activity/checkpoint/exempt check-3file-gate.sh` | 第 6 条件三出口（ledger 痕迹 / 检查点 mtime / drift_exempt）在位 | PASS（静态） |
| VC-4 | `grep drift-rhythm/zcode-posttooluse.sh` | :158-192 计数注入段 + `TASK_PLANNER_DRIFT_RHYTHM_N` env 覆盖 + :281 fail-open | PASS（静态） |
| VC-5 | `grep '64\.1 留痕三件套\|留痕三件套已落实' SKILL.md` | =2（:102 + :175）；agent 判定输入锚 :35 | PASS |
| VC-6 | `ls selftest-drift-enforcement.sh` + `grep DCE-` | 文件在位 4796B（13:22）；DCE 引用 25 处（16 断言）；registry :62 登记 | PASS |
| 删除行审计 | `git diff -U0 SKILL.md ledger-append.sh` | SKILL.md −1= C4 行末追加后缀（内容保留）；ledger −1= VALID_EVENTS 值尾改写（7 项原样）→ 内容级零删除 | PASS |

> VC-3/VC-4/VC-6 的**行为级**证据（四态 fixture / 干跑 / 16 断言全 PASS）已由 S2/S3/S5 主进程独立复跑并落 progress.md Test Results（:62-65）；本检查体复核其落盘记录与静态锚在位，未重跑行为套件（只读约束）。

## 四、S-unit 验收独立性核查

| S | 验收证据（progress.md + Handoff 表） | 主进程独立复验 | 判定 |
|---|------------------------------------|---------------|------|
| S1 | 锚 6/6；numstat 18+2/0 删 | ☑（Handoff #3） | 有 |
| S2 | gate 四态 exit 1/0/0/0 + 文案 | ☑ 12:21 独立复跑（Handoff #4） | 有 |
| S3 | 注入/静默/零残留/语法 5 项 | ☑ 12:46（Handoff #5） | 有 |
| S4 | DCS 前后 20/20 | ☑ 12:57 独立复跑（Handoff #6） | 有 |
| S5 | DCE 16/16 | ☑ 13:22 独立复跑（Handoff #7） | 有 |
| S6 | 60P/1F，FAIL 集=基线 | ☑ 主进程白名单③接管即验证者（Handoff #8） | 有 |

**结论：S1-S6 全部具备主进程独立复验证据**，且证据落于 progress.md Phase 3 Test Results + Handoff 登记表（22.5 双通道）。

---

## 五、观察项（不构成 DRIFT，供 Phase 4/5 收口）

1. **selftest-registry.tsv 授权链**：该文件未逐字列入「⚠️ 执行范围限制」表，但 S5 单元目标显式含「+ registry 登记」（task_plan.md :182），progress.md Handoff #7 亦登记「registry 登记」→ 属 S5 目标授权的写入，非范围外私改。建议 Phase 5 将 `scripts/selftest-registry.tsv` 补入 `scope_files` 字段以消除口径缺口（纯簿记）。
2. **plans 目录位置**：`plans/task-v148-drift-enforce/**` 存在于主仓（untracked），worktree 内不存在（untracked 文件不随 worktree checkout 携带）——符合预期，非漂移。

---

## 六、判定

**verdict: ALIGNED**

依据：worktree 实际写入 9 文件（8 tracked diff + 1 新建）全部落在 scope 8 文件清单 + 计划文件豁免内（selftest-registry.tsv 经 S5 单元目标显式授权），**零范围外写入**；S1-S6 验收全部有主进程独立复验证据；VC-1/2/5 锚点与删除行审计经本检查体亲手复现通过。

证据锚：
- 范围核对：`git -C /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce diff --numstat`（9 文件，+151/−2）
- 三锚来源：task_plan.md :31-32/:80-91/:41；progress.md :44-69
- 锚复验：critical-rules.md :769（6/6）；ledger-append.sh :30；SKILL.md :102/:175；drift-checker.md :35；check-3file-gate.sh :251-262；zcode-posttooluse.sh :158-192
