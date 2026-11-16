# Progress Log — task-auditgate-machine-20261116

## Session: 2026-11-16

### Phase 1: 基线核实与负断言冻结
- **R 锚定**：R1, R2, R3
- **Status:** complete
- **Started:** 2026-11-16 23:39
- **Completed:** 2026-11-17（worktree tmp/worktrees/task-auditgate-machine-20261116@7e67c5d）
- Actions taken:
  - 主进程初始化 `plans/task-auditgate-machine-20261116/` 七文件并逐字落盘 `user-session-log.md` #1（append-only）。
  - plan-writer 完成本地 Read/Grep 基线核实：`attest-plan.sh` 门链锚点（:26-45,84-99,540-562）、`check-tier-consistency.sh` 精确档位解析（:60-63）、selftest/registry 契约、Rule 109/SKILL 现文、先例 APPROVED 末段聚合形态。
  - 冻结基线负断言（2026-11-16）：`audit-gate` in attest/SKILL/rules=0；`check-plan-audit-gate.sh` absent；`selftest-plan-audit-gate.sh` absent；registry 行=0；`plan-audit-skip` 为既有 token（SKILL=1, rules=2，非判别性增量）。
  - 产出并落盘计划六文件：`task_plan.md`、`findings.md`、`knowledge-brief.md`、`progress.md`、`verification.md`、`notepad-learnings.md`（本轮补齐）；`user-session-log.md` 未改。
- Files created/modified:
  - `plans/task-auditgate-machine-20261116/task_plan.md` (created/full)
  - `plans/task-auditgate-machine-20261116/findings.md` (created/full)
  - `plans/task-auditgate-machine-20261116/knowledge-brief.md` (created/full)
  - `plans/task-auditgate-machine-20261116/progress.md` (updated/full)
  - `plans/task-auditgate-machine-20261116/verification.md` (updated/full)
  - `plans/task-auditgate-machine-20261116/notepad-learnings.md` (updated/full)
  - `plans/task-auditgate-machine-20261116/user-session-log.md` (init, append-only, unchanged)
- Test Results:
  | Test | Input | Expected | Actual | Status |
  |------|-------|----------|--------|--------|
  | 基线负断言 | `grep -c audit-gate attest-plan.sh/SKILL.md/critical-rules.md` | 0/0/0 | 0/0/0 | PASS |
  | 新文件缺失 | `ls check-plan-audit-gate.sh selftest-plan-audit-gate.sh` | absent | absent | PASS |
  | 既有 token 基线 | `grep -c plan-audit-skip SKILL/rules` | 1/2 | 1/2 | PASS |
  | 机械门控 | 计划门控脚本（Phase 0 已执行） | rc 0 | 八门全 rc=0（2026-11-17 复跑） | PASS |
  | S1 插入锚点 | attest-plan.sh window-lint fi(:560) 与 hash=(:561) 之间 | 锚点唯一 | findings S1 段 file:line | PASS |
  | S1 负断言（worktree） | grep -c audit-gate 三文件 | 0/0/0 | 0/0/0+两文件缺席+registry 0 行 | PASS |
  | S2 范式 | selftest-vc-nonvacuous ok/bad+registry 4 列+glob 发现 | 锚在位 | findings S2 段 | PASS |

### Phase 2: 设计冻结与计划走查
- **R 锚定**：R1, R2, R3
- **Status:** complete
- **Started:** 2026-11-17
- Actions taken:
  - 设计定稿落 findings.md「Design Decisions」D1-D6（checker 全规格/attest 接线（插入点 :560/:561+enforce 阶梯 warn 默认+argv 逃生+cksum 三预留位）/selftest 15 用例/109.8 与 SKILL 逐字草案）；CA-7~CA-12 已随审计迭代终态化（task_plan 变更标注表）。
- Files created/modified:
  - `plans/task-auditgate-machine-20261116/findings.md`（Design Decisions 段）
  - `plans/task-auditgate-machine-20261116/task_plan.md`（Phase 2 checkbox 翻转）
- Test Results:
  - 设计规格与 verification.md VC-1/VC-3 七态/15 用例逐项对照一致（R8 已独立复现矩阵）

### Phase 3: 机器强门实现（checker + attest 接线 + selftest）
- **R 锚定**：R1, R2
- **Status:** complete
- **Started:** 2026-11-17（worktree tmp/worktrees/task-auditgate-machine-20261116@7e67c5d）
- Actions taken:
  - S1 checker 新增（VC-1 七态 rc=0+补充态全对）；S2 attest 4 处增量接线（enforce 拒锁不写锁/APPROVED 写锁/warn 默认/逃生 WARN）；S3 selftest 16 断言 16/16 PASS；实现期自纠 2 缺陷（skip 行首锚定/判定序重排）——详见下文「Phase 3+4 执行」段。
- Files created/modified:
  - worktree 内 `skills/task-planner/scripts/check-plan-audit-gate.sh`（新建）、`skills/task-planner/scripts/attest-plan.sh`（4 处增量）、`skills/task-planner/scripts/selftest-plan-audit-gate.sh`（新建）
- Test Results:
  - VC-1 七态 rc=0（r1..r7=1,1,0,1,1,1,0）；selftest Total 16 PASS=16 FAIL=0；enforce 真实链路拒锁不写锁/放行写锁；证据 evidence/VC-1.out、VC-3.out

### Phase 4: 文本条款与登记同步（109.8 + SKILL + registry）
- **R 锚定**：R1, R3
- **Status:** complete
- **Started:** 2026-11-17（worktree 内）
- Actions taken:
  - critical-rules.md 追加 109.8 六子项（109.7 原样）；SKILL.md 审计门区块末追加机器门行；selftest-registry.tsv 四列行 append（NF=4 全表校验过）。
- Files created/modified:
  - worktree 内 `skills/task-planner/references/critical-rules.md`、`skills/task-planner/SKILL.md`、`skills/task-planner/scripts/selftest-registry.tsv`
- Test Results:
  - `grep -c '^### 109 '`=1；SKILL 机器门行 grep=1；VC-4 exit=0（run-verification 证据 evidence/VC-4.out）

### Phase 5: 回归、自举实测与合并部署
- **R 锚定**：R1, R2, R3
- **Status:** complete
- **Started:**
- Actions taken:
  - worktree 提交 b0e7caf（6 文件 317 insertions，pathspec 锁定）→ S2 范围断言 SCOPE-OK diff=6 untracked=0（[scope-check] 行已落 progress）→ smart-merge-back --deploy rc=0（merge commit cf697f7，部署位 IDENTICAL）→ worktree/分支清理完成。
  - **VC-5 自举实测（merge-back 后主仓）**：`TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce attest` 对本 plan-dir → rc=0 且输出 `[audit-gate] PASS: 末段审计留痕 [plan-audit-R8] APPROVED`；checker 直跑 rc=0——机器门对自己 plan-dir 闭环。
  - **终验 run-verification**：PASS=6 FAIL=0（VC-1 七态/VC-2 attest 行为/VC-3 selftest+registry/VC-4 109.8+SKILL 锚/VC-5 自举/VC-6 范围断言+全量同集零增量+逐字锚+config 无新键），机器证据 evidence/VC-1..6.out。
  - 全量回归（VC-6 内）：主仓 `Total: 100 PASS=93 FAIL=7`，Failed=冻结基线 7 名单逐名一致（含新增 selftest-plan-audit-gate 全过）；registry T03 孤儿=基线预存债；self-resolution 跨执行根 flaky 已辨析（progress 上文）。
  - （执行期 S2 在此段追加 [scope-check] 行——VC-6 唯一权威证据；文件级追加亦可被全文件 token 匹配，段内追加为推荐形态）
- Files created/modified:
  - （待填充：本文件审计留痕段、`verification.md` 证据、merge/deploy 产物）
- Test Results:
  - （待填充）

## 审计留痕占位（执行期由主进程/critic 写入，禁止预写 APPROVED）
- 本计划 `[plan-audit-R<N>]` 末段 `结论: **APPROVED**` 是 Phase 5 自举实测的**输入**（非证据）：须由 critic 文本审计写入，且段内必须含 `审计体:`/`轮次:`/`问题清单` 三 token（最小形态；**`问题清单` 容忍全角/半角括注后接冒号**——真实 APPROVED 段形态为 `- 问题清单（留档，不阻断）:`，按字面连写冒号判据会误拒真实 plan-dir，R7 I-1），否则 checker 拒锁；证据=Phase 5 merge-back 后主仓新 attest 实跑 rc=0 且输出含 `[audit-gate]`。
- 轻量豁免仅在 109.3 适用时写 `[plan-audit-skip]`（本计划 `plan_tier: standard` / `execution_lane: L1`，不适用豁免路径）。
- **写作规范（R7 Q-1，checker 契约依赖）**：审计段之后的任何后随块（修复轮/登记同步/簿记）**必须用 H2 标题 `## `**——checker 聚合边界仅认 `^## `；若用 `### ` 或粗体标题，边界不生效、两约束静默退化（伪 PASS 风险）。本文件既有审计段后的修复轮/登记块均按 `## ` H2 追加（含本修复轮块）。

## 📚 必要知识储备使用记录
| Phase | 引用知识源 | 用途(决策/实现/验证) |
|-------|-----------|---------------------|
| Phase 1 | `attest-plan.sh:26-99,106-198,540-562` | 门链锚点、skip/cksum/插入位置设计 |
| Phase 1 | `check-tier-consistency.sh:1-70` | checker rc 0/1/2 与 L1+ 判定范式 |
| Phase 1 | `critical-rules.md:194-212`、`SKILL.md:68-77` | Rule 109/109.7 现文与机器面边界、SKILL 审计门载体 |
| Phase 1 | `plans/archive/task-planaudit-20261116/*`、`knowledge/entries/task-planaudit-20261116.md` | APPROVED 末段聚合形态与三教训（disk-verified/非真空/主仓权威） |

## Error Log
| Timestamp | Error | Attempt | Resolution | Root Cause | Prevention | 触发命令/工具 |
|-----------|-------|---------|------------|------------|------------|--------------|
|           |       | 1       |            |            | <待沉淀>   |              |

## 5-Question Reboot Check
| Question | Answer |
|----------|--------|
| Where am I? | 计划阶段最终收口：R8 复审 **APPROVED**（0C/0I，连续第二轮收敛确认；2W+1Q+2N 留档且登记时点已廉价处置——VC-3 权威指针/规格补口径/粒度钉死/findings 指针/5Q 刷新）；[plan-audit-R8] 为最后审计段 |
| Where am I going? | D1 展示+44.3 完成性指令自动裁决登记+attest 旧链锁定（bootstrap: gate-absent）+哨兵清理 → worktree 隔离执行 Phase 1-5（checker/attest 接线/selftest/109.8/SKILL/registry→回归+自举实测）→ 终验+merge-back+部署+归档+交付 |
| What's the goal? | 落地计划审计门机器强门（attest [audit-gate]+checker+selftest）并以 Phase 5 merge-back 后主仓自举实测验证机器门行为有效（D1 走既有文本审计链路，bootstrap: gate-absent） |
| What have I learned? | 见 `findings.md` / `knowledge-brief.md`（attest 锚点、同集零增量冻结基线、断言捕获时点纪律、EOF 追加↔段锚互洽、聚合边界/结论行锚定双约束、容忍 token 匹配真实生产字节形态、独立承重 fixture、漂移双闸、env-only enforce、skip 入缓存键、registry 4 列） |
| What have I done? | 八轮审计全录（14→6→1→2→2→APPROVED→2I→APPROVED）+修复轮 1-5/4b/R6a/R7 全落盘；R8 登记时点已处置 W-1/W-1b/Q-1/N-1/N-2 五项廉价同步；user-session-log 未改 |
| What am I about to do? | D1 展示计划+44.3 自动裁决登记 → attest 旧链 bootstrap 锁定+清哨兵 → worktree 执行 Phase 1（基线核实） |

---
| plan-resume 报告路径 | 上次更新 |
|---------------------|---------|
| `~/.zcode/plans/plan-resume-report.md` | （本轮未执行 plan-resume） |

## [plan-audit-R1] 2026-11-17 计划独立审计第 1 轮（critic，独立上下文——新审计门首次真实走门）
- 轮次: R1 | 审计体: critic | 结论: **REJECTED**（14 发现：CRITICAL×1 / IMPORTANT×5 / WARNING×6 / NIT×2，不满足 0C/0I）
- 问题清单:
  - F8[CRITICAL] 自举时序不可能：计划声称 D1 经新 [audit-gate] 锁定，但该门 Phase 3 才创建——D1 走的仍是旧 attest；最坏情形「门不存在=默认通过」会被当作走门实证，摧毁 R2 行为级证据 → 冻结自举条款选 (a)（D1 走旧链路登记 bootstrap: gate-absent；VC-5 改 Phase 5 用 worktree 内 attest+本 plan-dir 实跑留痕）
  - F3[IMPORTANT] 新门控 env 未纳入 _attest_cksum（attest:86-88）→ off 档缓存回放绕过 enforce 硬门 → 缓存键并入 AUDIT_GATE_ENFORCE+缓存隔离 fixture
  - F4[IMPORTANT] 缓存键不含 progress.md（attest:90-99 只看 task_plan mtime）→ APPROVED 追加/移除不失效缓存 → 键并入 sha256sum progress.md；selftest fixture 独立内容
  - F11[IMPORTANT] L1+ 允许 [plan-audit-skip] 仅 WARN 放行=自声明旁路（超出 109.3 轻量档限定+用户授权范围，循环论证）→ skip 仅轻量档生效；L1+ 仅 --skip-audit-check 参数逃生（WARN+披露）；断言⑤改「轻量档放行+L1+ 拒锁」
  - F13[IMPORTANT] VC-3 Verify command 只 bash -n+registry 行存在，不执行 selftest（全 FAIL 仍 PASS）→ 改直接执行 exit 0 判
  - F1[IMPORTANT] VC-6 判据自缩水（全量回归降子集+丢部署位 diff=0）→ 以 task_plan:83 冻结+Verify command 落 run-selftests --fresh Total 断言+部署位 diff
  - F2[W] R3 范围边界无机器断言 → VC-6 增 git diff --name-only ⊆ scope_files
  - F5[W] APPROVED 判据=生产者可写自述无形态校验 → checker 增段内最小形态断言（审计体+轮次+问题清单行）
  - F6[W] mini×L1 冲突声明优先级未定（存量已有真实冲突计划）→ 定 lane 优先（L1 必审/多值按最严）+fixture
  - F9[W] checker rc=2 语义未定 → fail-open+显式 WARN 行（与先例一致）+selftest 覆盖
  - F12[W] legacy fail-open 与部署即 enforce 的存量迁移面未登记（9 无声明+7 个 standard/L1 无留痕在途计划）→ Phase 5 登记迁移说明+无声明显式 SKIP 输出行
  - F14[W] VC-1/2 纯静态 grep 与拒锁判据不匹配 → 落 fixture 负例实测（attest exit≠0+锁文件不存在）
  - F7[NIT] kb:27 awk 正则未转义 → 改转义形态注明以先例 verification.md:30 为准
  - F10[NIT] kb:16「env/参数同型」与既有仅参数形态不符 → 改「参数同型（仅 argv）不提供 env 逃生」
- 修复对照: → 打回 Plan Writer 修复轮（逐项处置后 R2 复审）
- 备注: 审计门第二次真实走门即抓到设计级矛盾（F8 自举时序）+缓存绕过硬门组合——独立上下文审计有效性再次实证

## 2026-11-17 R1 修复轮（REJECTED → 增量修订，F1-F14）
- 处置: F8 自举条款冻结方案 a（bootstrap: gate-absent，D1 既有文本链路；VC-5 改 Phase 5 自举实测）；F3/F4 cksum 三项（skip+enforce+progress 哈希）；F11 skip 仅轻量档/L1+ 拒锁；F13/F1/F2/F14 VC 与 Verify command 强化；F5/F6/F9 checker 语义；F12 存量迁移登记；F7/F10 kb 修正。
- 文件: `task_plan.md`、`verification.md`、`findings.md`、`knowledge-brief.md`、`notepad-learnings.md`（本段在 progress.md 追加）。
- 未改: `user-session-log.md`（append-only 权威源）；上方「审计留痕占位」保持原样——仍无 `结论: **APPROVED**` 预写（VC-5 语义已按 F8 改为 Phase 5 自举实测，见 task_plan）。
- 机械门重跑: 待本轮末执行 check-plan-dispatch/check-delegation stats 等。

## 2026-11-17 R2 修复轮（REJECTED → 增量修订，N1-N6）
- 处置: N1 VC-6 范围断言改 worktree 路径+untracked+merge-back 前时点；N2 自举实测归主进程 Phase 5 S2（merge-back 后主仓路径+`grep [audit-gate]` 实质断言）；N3 Phase 4 V-N 删 VC-6；N4 VC-1/VC-2 增正向 rc0 用例；N5 审计留痕占位改写（APPROVED 段=自举实测输入，补三 token 最小形态）；N6 Decisions 补缓存正确性取舍。
- 文件: `task_plan.md`、`verification.md`、`findings.md`、`knowledge-brief.md`、`notepad-learnings.md`（本段在 progress.md 追加）。
- 未改: `user-session-log.md`（append-only 权威源）；R1-R3 逐字锚未动。
- 机械门重跑: 待本轮末执行 check-plan-dispatch/check-delegation stats 等。

## 2026-11-17 R3 修复轮（REJECTED → 增量修订，I1+W1/N7/N8）
- 处置: I1 VC-6 scope 断言改 fail-closed（worktree 缺失/git diff/ls-files 失败均 exit1；`out=$(... || true)` 后 `test -z` 非空即 FAIL），并增 Phase 5 S2 merge-back **前** `[scope-check]` 留痕为唯一权威证据；W1 Phase 5 V-N 统一为「VC-5 + VC-6 分两段（范围断言=S2 内 merge-back 前；部署位 diff/回归=终验 Goal Gate 复核）」；N7 VC-2 负例 r1 前补清缓存；N8 VC-1 措辞收敛为 rc0/1 本命令实测、rc2 指向 VC-3。
- 文件: `task_plan.md`、`verification.md`、`findings.md`、`knowledge-brief.md`、`notepad-learnings.md`（本段在 progress.md 追加）。
- 未改: `user-session-log.md`（append-only 权威源）；R1-R3 逐字锚未动；无 APPROVED 预写。
- 机械门重跑（2026-11-17 真实输出）:
  - `check-plan-dispatch.sh` rc=0（2 条非阻断 WARN：plan-tier 提示 / p1-baseline 组内执行体同质；✓ 4 个派发型 Phase 均有带执行体 S-unit 表）
  - `check-delegation.sh stats` rc=0 `{"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"violations":[],"verdict":"ok"}`
  - `check-rvc-coverage.sh` rc=0 ✓ R=3 VC=6 映射行=3；`check-vc-nonvacuous.sh` rc=0 ✓ 6 条 VC 无真空命令
  - `check-template-type.sh` rc=0 rule-enhancement；`check-tier-consistency.sh` rc=0 standard/L1；`check-step-placeholders.sh` rc=0 扫描 21 行；`check-goal-cjk.sh` rc=0 16 个 CJK 词

## [plan-audit-R2] 2026-11-17 计划独立审计第 2 轮（critic，留痕补登——裁决当日并入 R2 修复轮块）
- 轮次: R2 | 审计体: critic | 结论: **REJECTED**（6 发现：N1-N6，不满足 0C/0I）
- 问题清单: N1 VC-6 git 断言指向主仓必败+untracked 盲区[阻塞]；N2 自举实测违反 SKILL:56+路径反向+rc-only；N3 Phase 4 V-N 残留 VC-6；N4 VC-1/2 负例-only 判据不匹配；N5 审计留痕占位违反禁预写；N6 缓存正确性取舍未登记。
- 修复对照: → R2 修复轮（上块）

## [plan-audit-R3] 2026-11-17 计划独立审计第 3 轮（critic，留痕补登——裁决当日并入 R3 修复轮块）
- 轮次: R3 | 审计体: critic | 结论: **REJECTED**（唯一阻塞 I1[IMPORTANT]+W1/N7/N8 不阻断）
- 问题清单: I1 VC-6 scope 断言 fail-open（worktree 缺失路径 `test -z ""` 真空放行）；W1 VC-6 双时点互斥；N7 VC-2 负例缺清缓存；N8 VC-1 rc2 措辞失配。
- 修复对照: → R3 修复轮（上块）

## [plan-audit-R4] 2026-11-17 计划独立审计第 4 轮（critic，新派发独立上下文）
- 轮次: R4 | 审计体: critic | 结论: **REJECTED**（6 发现：CRITICAL×1 / IMPORTANT×1 / WARNING×2 / NIT×2，不满足 0C/0I）
- 问题清单:
  - C-1[CRITICAL] verification.md:37 尾部 `test "$(grep -c "\"audit" config.json || echo 0)" -eq 0` 恒败——`grep -c` 零命中已打印 0 且 exit 1，`|| echo 0` 追加第二个 0 → 变量="0\n0" → integer expression error rc=2。主进程盘上复现：`bash: line 1: test: 0\n0: integer expression expected`，`TAIL_RC=2`，`cat -A` 实证双行。VC-6 在当前文本下不存在可达成 PASS 的路径。
  - I-1[IMPORTANT] verification.md:37 `test -d "$WT"` fail-closed 与 Phase 5 S2 强制 worktree 清理互斥——终验 run-verification 复跑时 worktree 已清理 → rc=1 → FAIL → outcome 禁 COMPLETE（Rule 84.5）；残留矛盾 task_plan.md:269「VC-6 时点=全部 Phase 完成后的终验复验」vs :284/:372 两段式。主进程盘上复核 :269 残留在位。
  - W-1[W] verification.md:37 白名单正则文件级分支缺 `$` 锚（`skills/task-planner/SKILL\\.md` 无尾锚）→ `SKILL.md.bak` 类副产物静默越界放行（critic 合成仓实测 SCOPE-OK rc=0；控制组越界正确拦截）。
  - W-2[W] `[scope-check]` 留痕无确定性 token 格式定义、progress.md Phase 5 段无槽位说明，机器断言面悬空（grep 仅命中 :139 处置回执）。
  - N-1[NIT] 管道 `|| true` 使 grep rc=2（模式错/读错）也落空输出放行；白名单为 task_plan.md:64 scope_files 手抄副本（漂移面，当前等价）。
  - N-2[NIT] VC-1 措辞收敛后仍漏 r2（mini×L1 冲突负向 `test "$r2" -eq 1`）实测枚举。
- 修复对照: → 打回 Plan Writer 修复轮 4（C-1 断言重写+I-1 两段式时点+269 残留清理+W1 `$` 锚+W2 确定性 token+N1/N2）
- 备注: R4 首次抓到「修复引入回归」形态——R3 的 fail-closed 改造未同步核对命令复跑时点的资源存续，真空放行翻转为确定性阻断；`grep -c || echo 0` 双零陷阱入 kb。反向排除面：逐字锚/user-session-log/无预写 APPROVED 全部复核未动。

## 2026-11-17 R4 修复轮（REJECTED → 增量修订，C-1/I-1/W-1/W-2/N-1/N-2）

- 处置（逐项，全部实际 Edit 落盘）:
  - **C-1[CRITICAL]** verification.md:37 尾部断言重写为 `test -f <config.json> && ! grep -q "\"audit" <config.json>`（`test -f` 守卫缺文件 fail-closed；`grep -q` rc1 经 `!` 翻转为成功）。盘上双态实测见下「C-1 双态实测」。
  - **I-1[IMPORTANT]** VC-6 改两段式：① Verify command 删除 live `test -d "$WT"`/`git`/`grep -vE` 范围断言，改为段锚 awk（`/^### Phase 5:/{f=1;next} f&&/^## /{f=0} f&&/^### /{f=0} f&&/\[scope-check\]/{print;exit}`）+ `SCOPE-OK` token 复核 progress.md Phase 5 段留痕；② 保留 live 复跑部分（`run-selftests.sh --fresh` Total FAIL=0 + 逐字锚 grep + config 断言）；③ 范围断言本体下沉 task_plan.md Phase 5「S2 内嵌命令」代码块（merge-back 前执行，失败不写 PASS 行、不进入 merge-back）；④ 清理 task_plan.md:269 残留「VC-6 时点=全部 Phase 完成后的终验复验」→ 两段式口径（与 :284/:372 一致）；⑤ verification.md VC-6 Evidence 行 + task_plan.md Notes 同步两段式口径。
  - **W-1[W]** 白名单六个文件级分支补尾锚 `$`（`attest-plan\.sh$`/`check-plan-audit-gate\.sh$`/`selftest-plan-audit-gate\.sh$`/`selftest-registry\.tsv$`/`SKILL\.md$`/`critical-rules\.md$`），目录分支 `plans/task-auditgate-machine-20261116/` 保持尾 `/`。合成仓双态实测见下「W-1 合成仓实测」。
  - **W-2[W]** `[scope-check]` 确定性 token 形态定为 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N`，落 task_plan.md:281（步骤）与 :291（S2 验收），与 VC-6 Verify 的 `SCOPE-OK` 断言互洽。（行号后移：实际落点现为 task_plan.md:296/:306——R4 内嵌命令块插入所致）
  - **N-1[NIT]** S2 内嵌命令 `|| true` 改显式捕获：`rc=0; out=$(cat "$D" "$U" | grep -vE "...") || rc=$?` + `test "$rc" -eq 0 -o "$rc" -eq 1 || { ...exit 1; }`；并在 S2 验收与 VC-6 Evidence 增「白名单集合执行时与 task_plan.md `scope_files` 逐项核对一致」。
  - **N-2[NIT]** verification.md:15 VC-1 措辞补 r2：`rc 0/1 本命令实测（r3=rc0 正向 / r1=rc1 无留痕负向 / r2=rc1 mini×L1 冲突负向）`。
- 文件: `verification.md`（VC-1 措辞、VC-6 判据/Evidence/Verify command）、`task_plan.md`（:269 V-N、:281 步骤、:291 S2 验收、Phase 5「S2 内嵌命令」块、Notes VC-6 两段式）、`findings.md`（R4 处置对照 + Issues 行 + 存量 7 FAIL 风险）、`knowledge-brief.md`（§2 三条新事实 + §4 第 13 条改写）、`notepad-learnings.md`（What Worked/What Didn't Work/通用规则 4 条/Files Modified/Verification Results/Notes for Next Time）、本文件（本段）；`subagent-state/fix-R4.md`（checkpoint）。
- 未改: `user-session-log.md`（append-only 权威源；mtime 仍为 2026-11-16 23:39:23，本轮零触碰）；R1-R3 逐字锚 task_plan.md:16-18 逐字未动（见下）；无 `结论: **APPROVED**` 预写（`[plan-audit-R1..R4]` 四段结论均 REJECTED，APPROVED 仅出现在规则说明/待写提示上下文）。
- 三约束自证:
  - ① 逐字锚未动：`sed -n '16,18p' task_plan.md` 输出三条 R1/R2/R3 行与 R4 审计复核时逐字一致。
  - ② `user-session-log.md` 未动：`ls -l --time-style=full-iso` → `2026-11-16 23:39:23.409788871 user-session-log.md`（其余本轮编辑文件 mtime 均为 2026-11-17 02:0x–02:3x）。
  - ③ 无 APPROVED 预写：`grep -n '结论: \*\*APPROVED\*\*' progress.md` 仅命中 :75（占位段规则说明）与 :129（「仍无…预写」声明），无审计段级 APPROVED。
- 机械门重跑（2026-11-17 真实输出，入参=计划目录/task_plan.md 按各脚本用法）:
  - `check-plan-dispatch.sh <plan>/task_plan.md` **rc=0**（2 条非阻断 WARN：plan-tier 提示「mini 判定条件不满足…建议改回 standard」；Rule 68.3「p1-baseline」组内执行体同质）+ `✓ 4 个派发型 Phase 均有带执行体的 S-unit 表`
  - `check-delegation.sh stats <plan>` **rc=0** `{"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"violations":[],"verdict":"ok"}`
  - `check-rvc-coverage.sh <plan>` **rc=0** `✓ R→VC 双向覆盖完整（R=3 VC=6 映射行=3）`
  - `check-vc-nonvacuous.sh <plan>` **rc=0** `✓ 6 条 VC 无真空命令`
  - `check-template-type.sh <plan>/task_plan.md` **rc=0** `OK: template_type=rule-enhancement`
  - `check-tier-consistency.sh <plan>` **rc=0** `✓ 档位声明与体量一致（plan_tier=standard execution_lane=L1; lines=461 phases=5 vc=6 sunit=0 scope=4）`
  - `check-step-placeholders.sh <plan>` **rc=0** `✓ 无可执行性缺陷（扫描 checkbox 步骤 21 行）`
  - `check-goal-cjk.sh <plan>` **rc=0** `✓ 抽出 16 个 CJK 词`
  - 说明：`check-tier-consistency.sh` 首跑曾报 `phases=6`——新增的 `#### Phase 5 S2 内嵌命令` 标题命中 `^#{2,4}[[:space:]]*Phase[[:space:]]*[0-9]`；已改名 `#### S2 内嵌命令：…（Phase 5，…）` 后复跑 `phases=5` rc=0。
- 风险披露（存量，非本轮引入）: `run-selftests.sh --fresh` 实测 `Total: 99 PASS=92 FAIL=7`（selftest-active-plan / batch-pilot / enumerate-first / execution-stability / registry(T03 孤儿行 `selftest-md-edit-ops.sh`) / self-resolution / summary-readability）。VC-6 要求全量 FAIL=0，故 Phase 5 前须先消解或由主进程授权处置（属 `skills/**` 保护区面，本轮禁改；不得以放宽 VC-6 规避）。（已由 R4b 处置：改同集零增量+基线冻结，见 [plan-audit-R5] 前的 R4b 段）

## 2026-11-17 R4b 微修轮（VC-6「同集零增量」对齐存量基线）

- **触发**：修复轮 4 风险披露 #1 —— VC-6 现行判据「全量 selftest `--fresh` 回归 0 FAIL」与存量基线**确定性冲突**（Phase 5 终验必 FAIL → outcome 禁 COMPLETE）。处置方向=项目既有「同集零增量」惯例：断言面仍是全量回归（不缩子集），冻结已知存量失败集合、判「无新增 FAIL」。
- **实测基线（2026-11-17 本轮一手复跑，真实输出）**：
  ```
  Total: 99 PASS=92 FAIL=7 (run=99 reused=0)
  Failed: selftest-active-plan selftest-batch-pilot selftest-enumerate-first selftest-execution-stability selftest-registry selftest-self-resolution selftest-summary-readability
  ```
  脚本 rc=1（7 项存量 FAIL，均为他任务在途未实现面；消解属 `skills/**` 保护区 + 他任务射程，R3 边界外）。
- **处置（三处修改 + 漂移条款，全部实际 Edit 落盘）**：
  1. `task_plan.md` Phase 1：新增 checkbox `:230` + 「selftest 基线冻结」块 `:241-253`（`Total:`/`Failed:` 行原文逐字、冻结日期 2026-11-17、归属说明=他任务在途遗留且 R3 射程外、判据语义=整行等值+`FAIL=7`、基线漂移条款）。
  2. `task_plan.md` 判据口径同步：R→VC 映射 `:24`、VC-6 `:83`、G5 `:120`、Phase 5 S1 步骤 `:294`、S1 S-unit 验收 `:305`、Notes `:408`。
  3. `verification.md` VC-6：判据 `:35`、Evidence `:36`（含基线漂移凭据条款）、Verify command `:37`（`FAIL=0` → `Total` 行 `FAIL=7` 精确匹配 + `Failed:` 行与冻结 7 名单**整行等值**；实现改为单次 `run-selftests.sh --fresh` 落 `mktemp` 文件后双 `grep`，避免重复跑两次全量）、Goal Gate `:182`。
- **正反态 dry-run（真实执行输出，2026-11-17）**：
  ```
  TC-A  正向：新判据 vs 当前真实基线（Total FAIL=7 + Failed 行等值）      rc=0
  TC-B1 负向：真实基线 + 新增假 FAIL 名 selftest-fake-new 且 FAIL=8       rc=1
  TC-B2 负向：计数仍 FAIL=7 但名单被换（self-resolution→fake-swap）       rc=1（证明整行等值是承重的，不只是计数）
  TC-C  旧判据 FAIL=0 vs 当前真实基线（冲突确证）                          rc=1
  TC-D  端到端：抽取 verification.md:37 原文，P→/tmp 副本 + 注入 Phase 5 [scope-check] 留痕  rc=0
  TC-E  端到端负向：同上但 run-selftests 换 mock（输出含假 FAIL 名）       rc=1
  TC-F  端到端负向：副本 progress.md 缺 [scope-check] 留痕                 rc=1
  TC-G  端到端对照：恢复留痕后同命令                                      rc=0
  ```
  （TC-D~G 用 sed 只替换 `P=` 赋值的绝对路径与脚本路径，命令正文与计划文件逐字一致 → 同时验证 Verify command 语法可执行、非真空、各断言段均承重。）
- **三约束自证**：
  - ① R1-R3 逐字锚 `task_plan.md:16-18` 未动（`sed -n '16,18p'` 输出与 R4 复核时逐字一致）。
  - ② `user-session-log.md` 未动：`ls -l --time-style=full-iso` → `2026-11-16 23:39:23.409788871 +0800`。
  - ③ 无 `结论: **APPROVED**` 预写：`grep -n '结论: \*\*APPROVED\*\*' progress.md` 命中 4 行=`:75`（占位段规则说明）、`:129`/`:180`（「仍无…预写」声明句）、本行 `:225`（本条自述）——无审计段级 APPROVED；`[plan-audit-R1..R4]` 四段结论行均 `REJECTED`。
- **机械门重跑（2026-11-17 真实 rc）**：
  ```
  check-rvc-coverage.sh      rc=0  ✓ R→VC 双向覆盖完整（R=3 VC=6 映射行=3）
  check-vc-nonvacuous.sh     rc=0  ✓ 6 条 VC 无真空命令
  check-tier-consistency.sh  rc=0  ✓ standard/L1; lines=477 phases=5 vc=6 sunit=0 scope=4
  check-plan-dispatch.sh     rc=0  2 条非阻断 WARN（plan-tier 提示 / p1-baseline 组内执行体同质）+ ✓ 4 个派发型 Phase 均有带执行体 S-unit 表
  check-delegation.sh stats  rc=0  {"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"violations":[],"verdict":"ok"}
  check-template-type.sh     rc=0  OK: template_type=rule-enhancement
  check-step-placeholders.sh rc=0  ✓ 扫描 checkbox 步骤 22 行（新增 1 行）
  check-goal-cjk.sh          rc=0  ✓ 抽出 16 个 CJK 词
  ```
  补充（如实披露）：`check-complete.sh <plan>/task_plan.md` **rc=1**，原因为 Rule 27.3 porcelain「scope 内存在未提交变更」——整个 `plans/task-auditgate-machine-20261116/` 目前仍是 untracked（`?? plans/task-auditgate-machine-20261116/`，计划期既有状态，非本轮引入）；该门为 Phase 5 终验工具，本轮不以其 rc 作为计划完备性证据。
- **基线漂移条款落点**：`task_plan.md:253`（Phase 1 冻结块「基线漂移条款（禁静默放宽）」）、`:408`（Notes「VC-6 同集零增量判据」）、`verification.md:36`（Evidence「基线漂移凭据」）。三者一致要求：合法漂移须重跑冻结 + `[baseline-shift]` 留痕 + 同步更新字面量，**禁静默放宽**。
- **附带簿记（事实性同步，无设计变更）**：`task_plan.md:205` Current Phase 与 `:209` Next Step 由 stale 的「R1 REJECTED 后 R2 复审」更新为「R1-R4 均已逐轮修复、微修轮 4b 完成、待 R5 复审」。
- **未改**：`skills/**`（保护区）、`user-session-log.md`、其他计划目录、仓库脚本；无新增仓库脚本（dry-run 脚本与 fixture 全在 `/tmp`）。

## [plan-audit-R5] 2026-11-17 计划独立审计第 5 轮（critic，新派发独立上下文）
- 轮次: R5 | 审计体: critic | 结论: **REJECTED**（8 发现：CRITICAL×1 / IMPORTANT×1 / WARNING×2 / QUESTION×1 / NIT×3，不满足 0C/0I）
- 问题清单:
  - C-1[CRITICAL] verification.md:21 VC-2 断言顺序污染无 PASS 路径——负例断言 `test ! -f "$T"/.plan-attestation` 在正例（同 `$T`，已建锁）之后执行恒假 → n=1 → 整命令 rc=1；critic /tmp mock 实测端到端 rc=1。主进程结构性复核确证（r1 负例断言组位于 r2 正例捕获之后、共享 $T）。
  - I-1[IMPORTANT] task_plan.md:324 S2 留痕 `echo ... >> "$PROG"` EOF 追加 ↔ verification.md:37 VC-6 awk 段锚（`### Phase 5:` 至下一个 `## `，止于 :74）互不兼容——留痕永远落段外，终验必 FAIL；S2 验收仅位置不敏感 grep 查不出，缺陷静默潜伏到 merge-back 后。critic 副本实测：EOF 追加→FAIL，段内插入→PASS。主进程结构性复核确证（Phase 5 段 :63-73，EOF 追加越界）。
  - W-1[W] task_plan.md:253/verification.md:36 基线漂移条款可作判据放宽通道——仅凭一行 [baseline-shift] 自述即可改字面量，本任务自身新增 FAIL 也能以「他任务收口」名义吸收。
  - W-2[W] verification.md:207（:200-212 会话恢复块）stale——仍写「R1 REJECTED、R2 复审待跑」，4b 只同步了 task_plan:205/:209。
  - Q-1[Q] verification.md:54 V-1.1 基线负断言与 Phase 3 产物天然互斥（落地后必假），疑终验复跑 Phase 1 gate 会误判；建议注明「仅 Phase 1 时点执行」。
  - N-1[NIT] verification.md:37 config 断言 grep rc=2（文件不可读）经 `!` 翻转 fail-open（理论面，实测影响 LOW）。
  - N-2[NIT] progress.md:176 W-2 处置引用行号 stale（写 :281/:291，实际 :296/:306）。
  - N-3[NIT] progress.md:195 R4 历史段「VC-6 要求全量 FAIL=0」无 superseded 指针（append-only 历史段不建议改写，建议加指针）。
- 负结果报告（已排除面）：「VC-6 时点=终验复验」残留=0；live worktree 依赖=0；FAIL=0 矛盾口径=0（仅合法上下文）；白名单越界逃逸=0（.bak/.orig/.md~/swp/.old 全 BLOCK）；基线伪造=0（99 脚本+7 名单单跑 rc=1 与 run-selftests.sh:166-167 逐字一致）；三约束全绿。
- 修复对照: → 打回 Plan Writer 修复轮 5（C-1 断言时序重排或双 fixture；I-1 段锚改全文件严格 token 正则或 S2 定向插入+W-2 槽位补齐；W-1 漂移条款加逐名归因+critic 复核；W-2 会话恢复块同步；Q-1/N-1/N-2/N-3 廉价修复）
- 备注: C-1 与 R4 C-1 同型（「无 PASS 路径」类恒败）——三轮审计未抓到是因为无人真跑过 VC-2 整链；I-1 为 4b 的 TC-D 验证盲区（注入段内≠S2 真实产出形态）。审计门连续第五轮抓到实弹缺陷，独立上下文审计有效性持续实证。

## 2026-11-17 R5 修复轮（REJECTED → 增量修订，C-1/I-1/W-1/W-2/Q-1/N-1/N-2/N-3）

- **轮次**: R5 修复轮 | 执行体: plan-writer（独立上下文） | 开始 2026-11-17T03:44:11+08:00 | 检查点: `subagent-state/fix-R5.md`
- **处置（逐项，全部实际 Edit 落盘）**:
  - **C-1[CRITICAL] 断言顺序污染（无 PASS 路径）** → verification.md:21 VC-2 Verify command 重排：负例断言组（`test "$r1" -ne 0 && test ! -f "$T"/.plan-attestation && grep -q "audit-gate" "$T"/o1; n=$?`）**紧跟 `r1` 捕获**（在 awk fixture 写入与正例执行之前），正例断言组紧跟 `r2` 捕获（`p=$?`），末尾只汇总 `test "$n" -eq 0 && test "$p" -eq 0`；原有元素（双处 `rm -f /tmp/attest-cache-*.result`、awk fixture、`TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce`、`rm -rf "$T"`）全保留。Evidence 行（:20）增「断言捕获时点」说明。
  - **I-1[IMPORTANT] S2 EOF 追加 ↔ VC-6 段锚不兼容** → verification.md:37 首段改 **全文件严格 token 正则**：`grep -qE "^\[scope-check\] [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z SCOPE-OK diff=[0-9]+ untracked=[0-9]+$" "$P"/progress.md || { rm -f "$O"; exit 1; }`（删除段锚 awk；S2 的 `echo ... >> "$PROG"` 追加形态保持不变）；verification.md:35 判据、:36 Evidence 同步「全文件严格 token 匹配」口径；task_plan.md:296（Phase 5 步骤）、:306（S2 验收）、:310（判据要点④）、:407（Notes）四处「Phase 5 段」定位措辞改「文件末尾追加 + 全文件 token 匹配，位置不敏感」；本文件 Phase 5 段（:63-74 区间，槽位行 :69）补**槽位说明行**（非 SCOPE-OK 行本身，不构成预写）：「（执行期 S2 在此段追加 [scope-check] 行——VC-6 唯一权威证据；文件级追加亦可被全文件 token 匹配，段内追加为推荐形态）」。
  - **W-1[W] 漂移条款加防滥用双闸** → task_plan.md:253（冻结块）+ task_plan.md:408（Notes）+ verification.md:36（Evidence）三处一致：① **逐名归因**（名单每个新增/消失条目须在 `[baseline-shift]` 行内指认他任务/提交锚如 `task-mdedit-reliability-20261116 收口`；**无法指认的新增 FAIL 不得吸收**）；② **漂移后重走 critic 文本审计**（判据字面量变更做简版复审并留痕，禁主进程自裁）；`[baseline-shift]` 行格式扩为 `<ISO8601> <新 Total> | <新 Failed> | <逐名归因> | <重跑冻结依据> | <critic 简版复审结论>`。
  - **W-2[W] 会话恢复块同步** → verification.md:207-211（5-Question Reboot Check）四行改当前实态（Where am I=R1-R4 逐轮修复+4b 完成+R5 修复轮 5 进行中；Where going=R6 复审→D1→…；learned 补 VC 断言时点/产出位置互洽；done=各轮增量修订+八门 rc=0+D1 待执行）；:198（交叉验证记录行，节首 :197）改「R1-R5 均 REJECTED 并逐轮修复，修复轮 5 收口后交 R6 复审」。
  - **Q-1[Q] V-1.1 时点注记** → verification.md:53 条目标签行尾加注「**时点注记（R5 Q-1）**：仅 Phase 1 时点执行（基线快照）；Phase 3 落地后本断言自然失效…**终验 Goal Gate 不复跑本 gate**」（注记落在标签行而非 Verify command 行，保持命令可直接复跑——如实披露该位置选择）。
  - **N-1[NIT] config 断言 rc=2 fail-open 收口** → verification.md:37 尾段 `test -f X && ! grep -q "\"audit" X` 改 `test -f X && { grc=0; grep -q "\"audit" X 2>/dev/null || grc=$?; test "$grc" -eq 1; }`（found→0→败；not found→1→过；error→2→败=fail-closed；`test -f` 保留）。
  - **N-2[NIT] progress.md W-2 行号 stale** → 历史段不改写，行尾追加括注「（行号后移：实际落点现为 task_plan.md:296/:306——R4 内嵌命令块插入所致）」。
  - **N-3[NIT] progress.md R4 历史段指针** → 同法追加「（已由 R4b 处置：改同集零增量+基线冻结，见 [plan-audit-R5] 前的 R4b 段）」。
- **实测输出（/tmp 模拟，真实执行）**:
  - **C-1**（mock attest + `verification.md:21` 命令正文逐字提取、仅替换 `A=` 路径）:
    ```
    VERDICT tag=old mock=attest-mock          rc=1     # 旧形态：正例已建锁 → n=1 → 无 PASS 路径
    VERDICT tag=new mock=attest-mock          rc=0
    VERDICT tag=new mock=attest-mock-broken   rc=1     # 破坏变体（负例也建锁）被 test ! -f 抓到
    SUBVALS      r1=1 n=0 r2=0 p=0            rc=0
    SUBVALS-OLD  r1=1 n=1 r2=0 p=0            rc=1
    ```
  - **I-1**（严格 token 正则 vs 六态副本）:
    ```
    STATE p0（现状无留痕）        rc=1
    STATE p1（Phase 5 段末插入）  rc=0
    STATE p2（EOF 追加 = S2 形态）rc=0
    STATE p3a（缺 SCOPE-OK）      rc=1
    STATE p3b（缺 diff=N）        rc=1
    STATE p3c（带 "- " 前缀）     rc=1
    ```
    端到端（`verification.md:37` 原文，仅替换 `P=` 与 run-selftests 脚本路径为 mock）: `TC-A 正向 rc=0` / `TC-B 去留痕 rc=1` / `TC-C 假 FAIL 名 rc=1`；`bash -n` vc6 rc=0、vc2 rc=0。
  - **N-1**（三态 + 新旧形态对照）:
    ```
    STATE cfg-key        NEW rc=1 | OLD rc=1 | grep_raw=0
    STATE cfg-nokey      NEW rc=0 | OLD rc=0 | grep_raw=1
    STATE cfg-unreadable NEW rc=1 | OLD rc=0 | grep_raw=2     # 旧形态 rc=0=fail-open 确证
    端到端（VC-6 命令 + chmod 000 config）rc=1；对照真实 config rc=0
    ```
- **三约束自证**:
  - ① R1-R3 逐字锚 `task_plan.md:16-18` 逐字未动（`sed -n '16,18p'` 输出与 R5 审计复核时一致）。
  - ② `user-session-log.md` 未动：`ls -l --time-style=full-iso` → `2026-11-16 23:39:23.409788871 +0800`（4355 B）。
  - ③ 无审计段级 `结论: **APPROVED**` 预写：`grep -n` 命中行均为占位段规则说明/「仍无预写」声明句；`[plan-audit-R1..R5]` 五段结论行均 REJECTED。
- **机械门重跑（2026-11-17 真实 rc，八门全跑）**:
  ```
  check-plan-dispatch.sh     rc=0  2 条非阻断 WARN（plan-tier 提示 / p1-baseline 组内执行体同质）+ ✓ 4 个派发型 Phase 均有带执行体 S-unit 表
  check-delegation.sh stats  rc=0  {"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"violations":[],"verdict":"ok"}
  check-rvc-coverage.sh      rc=0  ✓ R→VC 双向覆盖完整（R=3 VC=6 映射行=3）
  check-vc-nonvacuous.sh     rc=0  ✓ 6 条 VC 无真空命令
  check-template-type.sh     rc=0  OK: template_type=rule-enhancement
  check-tier-consistency.sh  rc=0  ✓ plan_tier=standard execution_lane=L1; lines=477 phases=5 vc=6 sunit=0 scope=4
  check-step-placeholders.sh rc=0  ✓ 无可执行性缺陷（扫描 checkbox 步骤 22 行）
  check-goal-cjk.sh          rc=0  ✓ 抽出 16 个 CJK 词
  ```
- **未改**: `skills/**`（保护区）、`user-session-log.md`、其他计划目录、仓库脚本；dry-run 脚本与 fixture 全在 `/tmp/r5t`（无新增仓库脚本）。


## [plan-audit-R6] 2026-11-17 计划独立审计第 6 轮（critic，新派发独立上下文——收敛轮）
- 轮次: R6 | 审计体: critic | 结论: **APPROVED**（0 CRITICAL / 0 IMPORTANT；残留 1W+3N 留档不阻断——迭代收敛达成）
- 问题清单（留档，不阻断）:
  - W-1[W] progress.md 5-Question 块滞后一档（登记时点已由主进程同步刷新至 R6 态——见上方 5-Question 段）
  - N-1[NIT] verification.md:207 状态行滞后一档（登记时点同步）
  - N-2[NIT] task_plan.md Subagent Handoff 登记表缺 R2-R5 复审与修复轮 1-5 行（登记时点批量回填；R1-R3 轮无独立 checkpoint 文件，证据=progress.md 对应 [plan-audit-RN]/修复轮段；R4 起有 subagent-state/ 检查点）
  - N-3[NIT] VC-3 补 progress-hash 缓存失效显式用例（Phase 3 selftest 实现面承载，留档）
- 负结果报告（critic 实测）：R5 八发现 0 残留；VC-2 真实 PASS 路径存在（mock 三变体 rc=0/1/1 两断言承重）；I-1 生产↔消费字节级联测 rc=0（echo 实跑过严格 token 正则）；16 条 Verify command 反引号计数=0；八机械门 rc=0；VC-2 对真实 attest 脚本 rc=1（判据可判别非恒真）；三约束全绿；基线真实性复核（99 脚本+7 名单 glob 序一致）
- 证据: subagent-state/audit-R6.md（4631B 检查点，动工前登记+完成后回填全实测）
- 收敛判定: 修复轮 5 后连续一轮零新 C/I 发现——审计迭代达标出口命中（R1 14→R2 6→R3 1→R4 2→R5 2→R6 0）

## 2026-11-17 R6a 修订轮（R6 APPROVED 后单点加固——checker 聚合中间态假阳性）

- **轮次**: R6a（**不新增 [plan-audit-RN] 段**；修订登记由主进程在 R7 复审时一并处理） | 执行体: plan-writer（独立上下文） | 来源: **主进程 2026-11-17 /tmp 一手实测**（非 critic 提出） | 检查点: `subagent-state/fix-R6a.md`
- **发现**: checker 既定聚合形态（kb §2「先例 APPROVED 末段聚合命令」= awk 只认 `^## [plan-audit-R[0-9]+] ` 段头聚合 + 未锚定 grep 「结论: 两星 APPROVED 两星」）把末段 buf 从最后一个审计头延伸到 **EOF**；审计后还跟有修复轮块（**中间态**）时，buf 吞进后随块中**反引号内的元引用**（修复轮收据自证行「无审计段级 … 预写」）→ 未审也放行（伪 PASS）。修复轮收据天然引用该三 token（checker 自身强制的最小形态），未来计划必然复现；先例 `task-planaudit-20261116` 同形态未暴露，因其验证时点恰为终态。
- **判别性实测（`/tmp/r6a`，两形态 mock 对同一 fixture，真实输出）**:

  | 状态 | 构造 | OLD 形态 rc | 加固形态 rc |
  |------|------|------------|------------|
  | s1 | 终态：末段审计=R6 结论 APPROVED（fixture） | 0 | 0（无假阴性） |
  | s2 | **中间态**：末段审计=R5 结论 REJECTED + 后随 `## … R5 修复轮` 块含反引号元引用 | **0（假 PASS）** | **1（真 FAIL）** |
  | s3 | 真实 progress.md 的 `head -304` 截断态（末审计段=R5，元引用行 :299） | **0（假 PASS）** | **1（真 FAIL）** |
  | s4d | 真实全文件 + 追加无结论行的簿记块 | 0 | 0（无假阴性） |
  | s5 | 审计段内唯一 APPROVED 为行中反引号元引用（无正规结论行） | 0 | 1（锚定约束独立承重） |
  | s6 | 真实全文件现状 | 0 | 0（无假阴性） |

- **处置（单主题三落点 + 同义面，全部实际 Edit 落盘）**:
  1. `task_plan.md` 根源覆盖表「门控判定器实现」行：缺陷面补「中间态假阳性」；修复点补 ① 聚合边界止下一个 H2 `## ` 行 ② 结论行 ERE 行首结构锚定。
  2. `task_plan.md` CA-7 行：依据补主进程实测证据；执行动作写入 ①②（完整正则指向 verification.md VC-1）。
  3. `task_plan.md` Phase 3 S1 验收：两约束写入判据 + **中间态假阳性负例**（必 rc1）；输入列标注先例聚合命令的假阳性（指 kb §2）。
  4. 同义面一致性：`task_plan.md` VC-1 判据/验证方式、Phase 2 规格 checkbox、Phase 3 S1 checkbox 同步两约束。
  5. `verification.md` VC-1 判据（两约束 + r4 中间态负例说明）与 **Verify command 增 r4 用例**（REJECTED 段 + 后随含反引号 APPROVED 元引用的修复轮块；awk 用 `sprintf("%c",96)` 生成反引号，规避命令替换），末尾 `test "$r4" -eq 1`；VC-3 fixture 清单加同用例并标注「两约束由正向+中间态负例共同承重」；知识储备核验行同步。
  6. `knowledge-brief.md:27`：补 R6a 加固说明（实测证据 + 两约束 + 存量先例档案不改写）。
  7. 状态块簿记：`task_plan.md` Current Phase/Next Step 与 `verification.md` 5-Question/交叉验证记录同步至 R6a 态（防 stale 断点）。
- **收据（VC-1 Verify command 从 `verification.md:17` 逐字提取，仅替换 `C=` 为 mock）**:
  ```
  bash -n（替换后命令）      rc=0
  RUN NEWFORM（加固形态）    rc=0     # SUBS r1=1 r2=1 r3=0 r4=1
  RUN OLDFORM（旧形态）      rc=1     # SUBS r1=1 r2=1 r3=0 r4=0 → r4 假 PASS 被抓
  backticks（该行）          =0
  ```
  说明：旧形态下 r4=0（假 PASS）使整命令 rc=1 —— 证明新增 r4 用例**承重**（不是恒真装饰）。
- **机械门重跑（2026-11-17 真实 rc，八门）**:
  ```
  check-rvc-coverage.sh      rc=0  ✓ R→VC 双向覆盖完整（R=3 VC=6 映射行=3）
  check-vc-nonvacuous.sh     rc=0  ✓ 6 条 VC 无真空命令
  check-tier-consistency.sh  rc=0  ✓ plan_tier=standard execution_lane=L1; lines=478 phases=5 vc=6 sunit=0 scope=4（Notes 新增 1 行加固说明使 477→478）
  check-plan-dispatch.sh     rc=0  2 条非阻断 WARN（plan-tier 提示 / p1-baseline 组内执行体同质）+ ✓ 4 个派发型 Phase 均有带执行体 S-unit 表
  check-template-type.sh     rc=0  OK: template_type=rule-enhancement
  check-step-placeholders.sh rc=0  ✓ 无可执行性缺陷（扫描 checkbox 步骤 22 行）
  check-goal-cjk.sh          rc=0  ✓ 抽出 16 个 CJK 词
  check-delegation.sh stats  rc=0  {"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"violations":[],"verdict":"ok"}
  ```
- **本轮中发现并修正的两处自身缺陷（如实披露）**:
  1. **S-unit 表单元格内 `\|` 导致列错位**：首版把完整 ERE 写进 Phase 3 S1 验收格（含转义管道），`check-plan-dispatch.sh` 用 `awk -F'|'` 分列（:246-305 不剔除 `\|`）→ 报「S1 时长不可解析 / 粒度三值格式不可解析 / 输入 3 个文件路径」。修正=**表格内不再写裸/转义管道**，完整正则单点存放于 `verification.md` VC-1（列表项，非表格），其余落点改为「三段结构 + 指路」；输入列第三路径（kb）改为散文指路 → 复跑上述 SKIPPED 提示全部消失。
  2. **mock 自测脚本自身 bug**：首版加固形态 mock 在首个 `## ` 处 `exit`（只聚合首个审计段）→ 终态 fixture 假 FAIL（s4d NEW rc=1）。修正为 `inbuf=0; next`（继续扫描后续审计头）→ 六态全对。教训：mock 必须同时覆盖正例/负例/多同类头三面。
- **三约束自证（写入后实测）**:
  - ① R1-R3 逐字锚 `task_plan.md:16-18` 逐字未动（`sed -n '16,18p'` 输出与 R6 审计复核时一致）。
  - ② `user-session-log.md` 未动：`ls -l --time-style=full-iso` → `2026-11-16 23:39:23.409788871 +0800`（4355 B）；`sha256sum` 前 12 位 `d12cd51f8604`（与 R6 审计记录一致）。
  - ③ 无审计段级结论预写：`grep -c` 未锚定形态=6（均为规则说明/自述句，与写入前同值）；**锚定形态 `^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*` 计数=1**（仅 `[plan-audit-R6]` 真实终态段）；`[plan-audit-R1..R5]` 五段均 REJECTED、R6 为 APPROVED；本轮未新增 `[plan-audit-RN]` 段。
- **未改**: `skills/**`（保护区）、`user-session-log.md`、其他计划目录、仓库脚本；无新增仓库脚本（mock/fixture 全在 `/tmp/r6a`）。

## [plan-audit-R7] 2026-11-17 计划独立审计第 7 轮（critic，新派发独立上下文——R6a 修订范围化复审）
- 轮次: R7 | 审计体: critic | 结论: **REJECTED**（0 CRITICAL / 2 IMPORTANT / 2 WARNING / 2 QUESTION / 2 NIT，不满足 0C/0I）
- 问题清单:
  - I-1[IMPORTANT] verification.md:15（同源 task_plan:78/kb:69/progress:76）最小形态 token `问题清单:` 与唯一 APPROVED 审计段真实字节形态不符——R6 段实为 `- 问题清单（留档，不阻断）:`（:316），spec-literal checker 对真实 plan-dir 判 rc=1 形态残缺 → VC-5 自举实测与 Phase 5 attest 实跑确定性失败；critic 实测 strict mock 真实 dir rc=1/宽松 rc=0。修复=token 改容忍括注形态 + 增真实 R6 段字节形态 fixture。
  - I-2[IMPORTANT] verification.md:23（同源 task_plan:78/:275）两约束 fixture 只能抓「全缺」抓不到「只做其一」——critic 四变体实测：仅边界 rc=0 假 PASS/仅锚定 rc=0 假 PASS，各有独立假 PASS 路径（fixture a=段内裸文 APPROVED；fixture b=后随 H2 块锚定 APPROVED）。修复=VC-1 增 r5/r6 两独立负例+VC-3 同补+判据改写为逐约束承重归属。
  - W-1[W] progress.md 5-Question 仍停 R6 态（R6a/R7 推进未同步——登记时点同步，见下）
  - W-2[W] task_plan.md:78 无声明 SKIP legacy-no-decl 无可执行判据（既有面非本轮引入）→ 修复轮 7 补 VC-3 用例
  - Q-1[Q] kb:27 聚合边界只认 H2 的前提未在契约强制 → 修复轮 7 在 checker 契约/kb 显式登记依赖
  - Q-2[Q] verification.md:17 progress.md 空文件归 rc1/rc2 未定义 → 修复轮 7 定契约（缺失/不可读=rc2；存在但空=rc1）
  - N-1[NIT] task_plan.md:440 派发算术不自洽（登记时点修正，见下）
  - N-2[NIT] progress.md R6a 段 lines=478 收据经登记编辑后不可复现（登记时点补复跑留痕，见下）
- 负结果报告：R6a 两约束语义四处一致无矛盾；VC-1 命令无反引号/sprintf 构造正确；审计段=6 锚定 APPROVED=1；R1-R3 逐字锚/user-session-log/sha 全绿；八机械门 rc=0（lines=489）；表格管道列解析正常；无 R6a 越界 skills/**。
- 修复对照: → 打回 Plan Writer 修复轮 7（I-1 容忍 token+真实形态 fixture；I-2 r5/r6 独立负例；W-2 legacy SKIP 用例；Q-1/Q-2 契约固化；N-1 算术）；主进程登记时点同步项：progress 5-Question 刷新至 R7 态（W-1）+ task_plan:440 算术修正（N-1）+ R6a 段补复跑留痕（N-2）
- 备注: R7 首次出现「主进程自身登记编辑引入的发现」（I-1 token 形态/N-1 算术/N-2 时点收据）——审计门对登记面同样有效；迭代持续收敛（0C，2I 均为廉价修复）。

## 2026-11-17 R7 登记时点同步（主进程，W-1/N-1/N-2 处置）
- progress.md 5-Question 刷新至 R7 态（W-1 处置）；task_plan.md:440 派发算术修正为「已派发 12 次（critic×6+plan-writer×6）+4 排队」（N-1 处置）。
- R6a 段复跑留痕（N-2 处置）：`check-tier-consistency.sh` R7 登记后复跑 → `lines=489 phases=5 vc=6 sunit=0 scope=4` rc=0（2026-11-17 真实输出，tier-consistency] ✓ 档位声明与体量一致）。
- I-1/I-2/W-2/Q-1/Q-2 计划文件修复归修复轮 7（Plan Writer 承载）。

## 2026-11-17 R7 修复轮（REJECTED → 增量修订，I-1/I-2/W-2/Q-1/Q-2）

- **轮次**: R7 修复轮（**不新增 `[plan-audit-RN]` 段**——R7 为最后审计段，R8 裁决由主进程登记） | **执行体**: plan-writer（独立上下文） | 检查点: `subagent-state/fix-R7.md` | 输入: [plan-audit-R7] 段 + R7 登记时点同步段 + `subagent-state/audit-R7.md`
- **处置（逐项，全部实际 Edit 落盘）**:
  - **I-1[IMPORTANT] 最小形态 token 与真实 APPROVED 段字节形态脱钩** → ① token 定义统一为**容忍形态**：`问题清单` 后允许全角/半角括注再接冒号（判据 ERE `^- 问题清单([（(][^）)]*[）)])?:`），`审计体:`/`轮次:` 维持字面（真实段无括注，由 r7 fixture 覆盖）；② VC-1 增 **r7 真实生产形态正例**（R6 段字节形态：结论行带括注 + `- 问题清单（留档，不阻断）:` + `- 审计体: critic` → 必 rc0），保留 r3 规范示意形态正例（`- 问题清单: 无` → rc0）；③ VC-3 用例清单同步双正例（r7 承重 I-1 判别性）。
  - **I-2[IMPORTANT] 两约束只测「全缺」抓不到「只做其一」** → VC-1 增 **r5**（fixture a：REJECTED 段内裸文意见文本「缺少 `结论: **APPROVED**` 行…」→ 期望 rc1，抓「仅锚定实现」假 PASS）与 **r6**（fixture b：后随 H2 块内含正规锚定 APPROVED 行 → 期望 rc1，抓「仅边界实现」假 PASS）；末断言扩为 `r1..r7` 七项；VC-3 补两行为用例；判据句改**逐约束承重归属**（边界↔fixture b、锚定↔fixture a、全缺↔中间态 r4）。
  - **W-2[W] legacy SKIP 无可执行判据** → VC-3 用例清单补「无 `plan_tier`/`execution_lane` 声明 → rc0 且输出含 `[audit-gate] SKIP legacy-no-decl`」；VC-1 判据与 task_plan VC-1 标注该分支有 fixture 承重（防实现误判 rc1 锁死 9 个存量无声明计划）。
  - **Q-1[Q] H2 边界前提固化** → 三处契约说明「聚合边界仅认 `^## `（H2）——审计段后随块**必须用 H2 标题**；H3/粗体标题则边界不生效、两约束静默退化，checker 注释须登记该前提」（verification VC-1 判据、kb §2 + §4 新增 16、task_plan VC-1/CA-7/S1 验收）；本文件「审计留痕占位」区**追加一行写作规范提示**（append，未改写既有行）；本段即以 `## 2026-11-17 R7 修复轮` **H2** 追加（规范自证）。
  - **Q-2[Q] 空文件 rc 口径固化** → 「`progress.md` **文件缺失/不可读=rc2**（fail-open + `[audit-gate] WARN 判定器输入异常`）、**存在但空=无留痕 rc1**」写入 verification VC-1 判据/VC-3 用例、task_plan VC-1/CA-7/S1 验收、kb §4 新增 16；VC-3 的「rc2 输入缺失」用例明确为**删除文件**（非清空）。
  - **簿记同步**：task_plan Current Phase/Next Step（R7 修复收口→R8 复审）、Handoff 表新增 #17（critic R7 REJECTED）/#18（Plan Writer 修复轮 7）、派发算术改「14 次（critic×7 + plan-writer×7）+4 排队（合计 18）」；verification 交叉验证记录与 5-Question 同步至 R7 修复态。
- **实测输出（`/tmp/r7t`，真实执行）**:
  - **I-1 新旧 token 判据对照（同一真实 R6 字节形态 fixture）**:
    ```
    OLD(strict 字面 问题清单:) rc=1  :: [audit-gate] FAIL 缺问题清单（字面）    # 旧判据误拒真实 plan-dir
    NEW(tolerant 括注)          rc=0  :: [audit-gate] PASS                      # 新判据放行
    ```
  - **I-2 四变体 × 五 fixture（判别性矩阵；0=PASS 1=FAIL）**:
    ```
    fixture    full(完全加固)  onlyb(仅边界)  onlya(仅锚定)  old(全缺)
    real_r6        0              0              0             0      # 无假阴性
    spec           0              0              0             0      # 无假阴性
    mid(中间态)    1              1              1             0      # old 假 PASS（已知）
    fxa(段内裸文)  1              0 假PASS       1             0      # 仅边界抓不到 → 仅锚定实现被抓
    fxb(H2块锚定)  1              1              0 假PASS      0      # 仅锚定抓不到 → 仅边界实现被抓
    ```
    → 期望值反转达成：半加固（onlyb/onlya）在 r5/r6 处各被独立击穿，不再等效于完全加固。
  - **VC-1 命令端到端（从 `verification.md:17` 逐字提取，仅替换 `C=` 为 mock；`bash -n` rc=0；该行反引号计数=0）**:
    ```
    VARIANT=full   VC-1 rc=0   SUBS r1=1 r2=1 r3=0 r4=1 r5=1 r6=1 r7=0   # 完全加固：七态全符合
    VARIANT=onlyb  VC-1 rc=1   SUBS r1=1 r2=1 r3=0 r4=1 r5=0 r6=1 r7=0   # 仅边界 → r5（fixture a）抓
    VARIANT=onlya  VC-1 rc=1   SUBS r1=1 r2=1 r3=0 r4=1 r5=1 r6=0 r7=0   # 仅锚定 → r6（fixture b）抓
    VARIANT=old    VC-1 rc=1   SUBS r1=1 r2=1 r3=0 r4=0 r5=0 r6=0 r7=0   # 全缺 → r4/r5/r6 三点全抓
    TOKEN_MODE=strict（旧 token 字面）   VC-1 rc=1   SUBS r7=1            # r7 承重确证：旧判据在真实形态上必失败
    ```
  - **补充行为态（mock 直测）**: `progress.md` 缺失 → rc2（WARN 判定器输入异常）/ 存在但空 → rc1（无审计留痕）/ chmod 000 不可读 → rc2；无声明 legacy → rc0 且输出 `[audit-gate] SKIP legacy-no-decl`；mini×L1 冲突 → rc1；mini 单独 → rc0 SKIP；L1+ 写 `[plan-audit-skip]` → 仍走 APPROVED 判定（rc 按留痕）。
- **三约束自证（写入后实测）**:
  - ① R1-R3 逐字锚 `task_plan.md:16-18` 逐字未动（`sed -n '16,18p'` 输出与本轮开工前一致）。
  - ② `user-session-log.md` 未动：mtime `2026-11-16 23:39:23.409788871 +0800`（4355 B），sha256 前 12 位 `d12cd51f8604`（与 R6a/R7 记录一致）。
  - ③ **未新增 `[plan-audit-RN]` 段**：`^## \[plan-audit-R[0-9]+\]` 段数仍=7（R1-R7，末段=R7 REJECTED）；行首锚定 APPROVED 行仍只有 `[plan-audit-R6]` 1 处；未锚定 token 计数见文末复跑留痕（均为规则说明/自述句，无新增审计段级结论）。
- **机械门重跑（2026-11-17 真实 rc，八门）**:
  ```
  check-plan-dispatch.sh     rc=0  2 条非阻断 WARN（plan-tier 提示 / p1-baseline 组内执行体同质）+ ✓ 4 个派发型 Phase 均有带执行体 S-unit 表；SKIPPED 计数=0
  check-delegation.sh stats  rc=0  {"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"violations":[],"verdict":"ok"}
  check-rvc-coverage.sh      rc=0  ✓ R→VC 双向覆盖完整（R=3 VC=6 映射行=3）
  check-vc-nonvacuous.sh     rc=0  ✓ 6 条 VC 无真空命令
  check-template-type.sh     rc=0  OK: template_type=rule-enhancement
  check-tier-consistency.sh  rc=0  ✓ plan_tier=standard execution_lane=L1; lines=491 phases=5 vc=6 sunit=0 scope=4
  check-step-placeholders.sh rc=0  ✓ 无可执行性缺陷（扫描 checkbox 步骤 22 行）
  check-goal-cjk.sh          rc=0  ✓ 抽出 16 个 CJK 词
  ```
  说明：`lines=489 → 491` 系 Handoff 表新增 #17/#18 两行（N-1 派发算术登记面同步），非判据变更；本段追加后再复跑 `check-tier-consistency` 见下方复跑留痕。
- **未改**: `skills/**`（保护区）、`user-session-log.md`、其他计划目录、仓库脚本；无新增仓库脚本（mock/fixture 全在 `/tmp/r7t`）。
- **复跑留痕（追加本段后，2026-11-17 真实输出）**: `check-tier-consistency.sh` → `✓ plan_tier=standard execution_lane=L1; lines=491 phases=5 vc=6 sunit=0 scope=4` rc=0；三约束复测：`^## \[plan-audit-R[0-9]+\]` 段数=7、行首锚定 APPROVED 行=1（仅 R6）、未锚定 token 计数=7（较追加前 6 增 1，来源=本段引用的 fixture 意见文本元引用，非审计段级结论）、`## 2026-11-17 R7 修复轮` H2 计数=1；`user-session-log.md` sha256 前 12 位 `d12cd51f8604` / mtime `2026-11-16 23:39:23.409788871 +0800` 未变。

## [plan-audit-R8] 2026-11-17 计划独立审计第 8 轮（critic，新派发独立上下文——R7 修复轮范围化复审，收敛确认轮）
- 轮次: R8 | 审计体: critic | 结论: **APPROVED**（0 CRITICAL / 0 IMPORTANT；残留 2W+1Q+2N 留档不阻断——连续第二轮 0C/0I，迭代收敛确认）
- 问题清单（留档，不阻断；登记时点已由主进程廉价处置）:
  - W-1/W-1b[W] task_plan:80/:256/:257/:277 未同步 R7 新增判别用例 → 登记时点已补 VC-3 权威指针+规格定稿补容忍 token/rc2 口径+S3 输入加 VC-3 指针
  - Q-1[Q] 审计体:/轮次: 判定粒度未钉死 → 登记时点已在 verification.md:15 钉「段内子串即可，不要求独立行」
  - N-2[NIT] findings.md:50「checker 复用同形」被 R6a 推翻 → 登记时点已加指针
  - N-1[NIT] progress 5-Question 滞后 → 本登记同步刷新（见下方 5-Question 段）
- 核心复现（critic 独立 mock，未抄修复轮代码）：VC-1 七态矩阵 r1..r7=1,1,0,1,1,1,0 与 fix-R7 声称逐格一致；半加固变体 onlyb rc=1(r5=0)/onlya rc=1(r6=0)；真实 plan-dir 现状（末段 R7 REJECTED）rc=1 fail-closed 正确；真实 R6 形态 rc=0
- 负结果报告：无新 CRITICAL/IMPORTANT；三约束全绿（锚点/append-only/审计段=7 锚定 APPROVED=1）；八机械门 rc=0；反引号=0；Handoff 14+4=18 自洽
- 收敛判定: R7 修复后连续第二轮 0C/0I——审计迭代收敛出口再次确认（R1 14→R2 6→R3 1→R4 2→R5 2→R6 0→R7 2I→R8 0）
- 证据: subagent-state/audit-R8.md（检查点）

## 2026-11-17 D1（44.3 完成性指令自动裁决 + attest 旧链 bootstrap 锁定）
- **D1 展示**：计划（plan_tier=standard / execution_lane=L1，5 Phase/9 S-unit/6 VC，lines≈491）已向用户展示（本会话文本，见交付流）；八轮独立审计 R1-R8 全轨迹在 progress.md `[plan-audit-R1..R8]`，终态 [plan-audit-R8] APPROVED（0C/0I）。
- **44.3 自动裁决登记**：用户原话（user-session-log.md #1）「三、未完成项与风险 1 授权 2 测试」=对上一任务（task-planaudit-20261116）交付总结「三、未完成项与风险」的完成性指令（①授权 CA-6 机器面接线 ②测试）——命中 SKILL.md 44.3 完成性指令场景（明确授权+明确验收期望，非开放式规划），且计划审计门已过（审计门不适用 44.3 自动通过的排除已在 SKILL.md:81 注明——本计划审计 R1-R8 真实走门完毕后才进 D1，符合排除语义）。**自动裁决=通过，无需用户再行确认**；44.3 不适用于[plan-audit-RN] 前置的排除已遵守（审计在先）。
- **attest 旧链锁定（bootstrap: gate-absent）**：新机器门（check-plan-audit-gate.sh/attest [audit-gate] 接线/selftest）Phase 3 才创建，本计划 D1 时点走既有 attest 链路锁定（bootstrap 登记）；Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 自举实测（VC-5：rc=0+grep [audit-gate]）——届时 progress 末审计段为 [plan-audit-R8] APPROVED（容忍 token+锚定行形态，mock 已验证该形态过新 checker 语义）。
- **锁定凭证（2026-11-17 真实输出）**：`attest-plan.sh` rc=0，`.plan-attestation` 已写，SHA-256=`d1be4e66a9e1b47dd91a7a6d8f85def81cd5c17cda4bb82ff07983b826732c4e`（门链全绿：template-gate/tier-consistency/vc-gate 12 条/vc-nonvacuous/rvc-coverage/step-placeholder/fmea warn 档；2 条非阻断 WARN 同前）。bootstrap: gate-absent 登记——新门 Phase 3 后由 Phase 5 自举实测补证（VC-5）。

## 2026-11-17 Phase 3+4 执行（worktree 内，主进程直做兜底——executor 三连败 provider rate limited）
- **Phase 3 S1（checker）**: worktree 新增 skills/task-planner/scripts/check-plan-audit-gate.sh（~125 行）；VC-1 七态 rc=0（verification.md:17 逐字命令 C=替换）；补充态：缺 progress=2/不可读(chmod000)=2/r7 真实 R6 形态=0+PASS/mini=0 SKIP/无声明=0 SKIP legacy；实现期自纠 2 缺陷（skip 子串 grep 被自指计划散文提及误触发→行首锚定 `^\[plan-audit-skip\]`；progress 检查抢跑轻量/无声明路径→判定序重排为 lane/skip 先行，判例已入注释）。
- **Phase 3 S2（attest 接线）**: 4 处增量（skip_audit 变量+usage 行+`_attest_cksum` 第 8 参数组 skip_audit|AUDIT_GATE_ENFORCE|sha256(progress.md)+window-lint 后 [audit-gate] 门块 enforce/warn(默认)/off 阶梯）；实测：enforce 无留痕→rc1 **不写锁**；APPROVED→rc0 写锁含 hash+PASS 行；warn 默认→透传不阻断；--skip-audit-check→WARN 逃生；缓存回放 WARN 同步。
- **Phase 3 S3（selftest）**: worktree 新增 selftest-plan-audit-gate.sh 16 断言（D3 全清单：规范/真实形态双正例/无留痕/legacy SKIP/轻量 skip/L1+ skip 拒锁/mini/mini×L1/形态残缺/中间态/fixture a b/rc2 删文件/缓存隔离/attest 拒锁不写锁/写锁）→ **16/16 PASS exit 0**；run-selftests 聚合 `[run] selftest-plan-audit-gate (rc=0 PASS=16 FAIL=0)`。
- **Phase 4**: critical-rules.md 109.8 落刀（109.7 原样，`^### 109 ` 计数=1）；SKILL.md 审计门区块末追加机器门行；selftest-registry.tsv 四列行 append（awk NF=4 全表过）。
- **回归观测**: worktree 全量 `Total: 100 PASS=93 FAIL=7`，Failed 集=冻结基线 7 名单**逐名一致**（零新增）；registry FAIL=T03 孤儿 selftest-md-edit-ops.sh（基线内预存债，master 同）；**selftest-self-resolution 跨执行根 flaky 判例**——worktree 首跑转绿、复跑转红（主仓恒红），属环境态依赖非内容变化，不改冻结基线（VC-6 按主仓路径+原基线仍精确成立），已留痕。
- **执行体披露**: explore×2+executor×3 五次派发均 provider rate limited（证据=会话 failed 通知）→Phase 1/3/4 全部主进程直做兜底（§十降级链穷尽+task-v171 先例；有界/确定性任务），Handoff 表 #2/#3/#4 已更新降级备注。
- worktree git status：M attest-plan.sh + ?? check-plan-audit-gate.sh/selftest-plan-audit-gate.sh/SKILL.md M/critical-rules.md M/registry M（恰 6 文件=scope 内）。
[scope-check] 2026-11-16T23:19:08Z SCOPE-OK diff=6 untracked=0
