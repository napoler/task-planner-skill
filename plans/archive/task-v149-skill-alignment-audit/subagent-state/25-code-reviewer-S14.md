# S14 Code Review 检查点（code-reviewer，只读）

- 审查对象：/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit
- diff 范围：`git diff 21f7e6b..HEAD`（三 commit a234369 / fca4f40 / aa06dde，31 文件）
- 需求锚：R3「修复其中的问题、错误以及不合理的地方」= 修复质量 + 无副作用确认
- 结论：**CHANGES_REQUESTED**（2 Medium 阻断声明性修复质量；无 Blocker/安全项）
- 复核工具：git / grep / sed / find / bash selftest 直跑

## 审查重点逐项结论

1. critical-rules.md Rule 65 块（:802-834）——**PASS**
   `git show 1a92ef3:...critical-rules.md` 提取原 Rule 57 块，与现行 Rule 65 块做「57↔65 编号归一化」后 `diff` 结果为 **逐字节 IDENTICAL**（含 65.1-65.8 全部子条）。65.7 自引用已正确改 65（:832）。65.5「57.1-57.5」已改「65.1-65.5」。仲裁注（:802）依 :676 先例自洽。
2. 11 个守卫 selftest ——**PASS**
   periodic-review / lane-advancement / requirement-coverage / self-resolution / tool-selection / workflow-orchestration / drift-check-subagent / research-first / four-file-dataflow / evidence-goal-gate / iteration-persistence / skill-split 直跑 **全 FAIL=0**（10/14/23/13/12/16/20/12/18/21/18/41 PASS）。上界 1-64→1-65 断言语义保留；负断言 ^65→^66 方向正确（critical-rules.md `^65.`=8、`^66.`=0；FF 脚本 `^66\.[0-9] ` fixed-string=2、`^65\.[0-9] `=0）。RF-10 正(≥2 ^66)/负(=0 ^65)方向正确。
3. lib/install-companion.sh ——**PASS（含 2 处 Nit）**
   COMPANION_DIR 定义+6 处引用一致（:21/40/41/152/155/157）；仓内 install-companion.sh 已无 COMPAANION 残留。备份根改 `$HOME/.task-planner-backups/companion/<ts>`（:64）落在扫描树（~/.zcode/skills）之外，解 v146 复发。cp 目标 `$BACKUP_DIR/${dst#$TARGET_ROOT/}` 与 mkdir `${dst#$TARGET_ROOT/}` 路径对齐（:118/120），修正了原 basename 拍平覆盖。
4. selftest-drift-check-subagent.sh DCS-20（:86-91）——**PASS**
   扫描根 SKILLS_ROOT→SKILL_ROOT。实盘复现：全 .zcode/skills 树命中 4（skill-fix×2、references/cost-control.md、cost_log.md，均无关技能合法文案）；收窄后 task-planner 目录命中 0。收紧保留「防本技能位残留」意图，消环境敏感伪失败，判断正确。
5. check-doc-sync.sh 注释键考证 ——**PASS（代码）/ M-3（考证叙述不准）**
   代码确用 plan_update_interval_minutes（:12/33/45；config.json:202），注释修正方向正确。但 :14「sync_interval_calls 在 commit 2337ce0 重命名为 todo_sync_interval_calls」不成立（见 M-3）。
6. 文档批抽查 ≥5 ——**PASS（4 项对齐）+ M-2 / M-4（2 项失准）**
   companion=7（实测 7）、references=10（find 实测 10）、templates 10+29、selftest=62、smoke 17 pass（实跑 17/0）、variant 29 均与实态一致；examples/full-workflow.md 路径（install.sh/lib/verify.sh/session-catchup.ts）实态存在。失准项见 M-2/M-4。

## 发现清单

### M-1 🟡 [正确性/一致性] `skills/task-planner/scripts/periodic-review.sh:2` — 规则归属残留旧号
- 原文: `# periodic-review.sh — Rule 57 周期性回顾与前后对照检测`
- 原因: Rule 65 恢复把所有自引用改 65（selftest-periodic-review.sh 全量改号、registry:61 已改），但本脚本头部注释仍称「Rule 57 周期性回顾」。Rule 57 现为「迭代测试轮次落盘纪律」（CR:642 注），指向完全不同的条款=规则归属错误。改号工程遗漏 1 处。
- 修复: 该行 `Rule 57` → `Rule 65`。
- 置信度: HIGH

### M-2 🟡 [文档失准] `skills/task-planner/docs/ARCHITECTURE.md:17`（及 :64）— 计数与其自述命令不符
- 原文: ``- `scripts/`（106 个文件，2026-10-08 task-v149 实测 `find scripts -maxdepth 1 -type f | wc -l` → 106``
- 原因: 实跑 `find skills/task-planner/scripts -maxdepth 1 -type f | wc -l` = **104**（106 系 `ls -1 scripts | wc -l`，含 capabilities/、lib/ 两个子目录）。文档把「ls 项数」挂到「find -type f」命令上，读者按命令复跑得 104 ≠ 106，证据链自相矛盾；:64「实测 106 文件」同错。
- 修复: 二选一——数字改 104（若口径=文件），或命令改 `ls -1 scripts | wc -l`（若口径=目录项），并保留 .sh 96/含 62 selftest 的分项。
- 置信度: HIGH

### M-3 🟡 [证据/考证] `skills/task-planner/scripts/check-doc-sync.sh:14` — git 考古结论不可复现
- 原文: `# git log -S 考证：sync_interval_calls 在 commit 2337ce0 重命名为 todo_sync_interval_calls（语义相同），`
- 原因: 复核反证——① `git show 2337ce0 --stat` 为「move v2 multi-tool work into skills/task-planner/ subdir」目录搬迁 refactor，非键重命名；② `git log --all -S '"sync_interval_calls"'`（带引号独立键）**空输出**，即该键从未作为独立 config 键存在，`sync_interval_calls` 仅是 `todo_sync_interval_calls` 的子串。`-S 'sync_interval_calls'` 命中 2337ce0 系子串计数随文件搬迁变化的伪信号。注释把「子串伪命中」叙述成「重命名考证」，属未经证实的考古断言（§三 证据铁律）。代码修正（改引 plan_update_interval_minutes）本身正确。
- 修复: 删除/改写 :14 的 2337ce0 重命名叙述，改为事实陈述：「config.json 实际键为 plan_update_interval_minutes（时间阈值）与 todo_sync_interval_calls（次数阈值）；原注释引用的 sync_interval_calls 独立键从未存在」。
- 置信度: HIGH

### M-4 🟡 [文档失准/遗漏] `INSTALL_zh.md:290` + `skills/task-planner/README.md:69` — config 键数 40 陈旧（实 42）
- 原文: `├── config.json                    (JSON-Schema 阈值配置, 40 键)`（INSTALL_zh:290）；`├── config.json ← 阈值配置（40 键）`（README.md:69）
- 原因: json 实测 .properties=42，且守卫（selftest-media-agents MA-10、WF-12、FF-15 等）断言恒为 42。两处在本次改动文件的同一结构块内（INSTALL_zh:293 scripts 计数、README.md:72 Rules 集合均在本批更新），相邻行已改而此计数行漏改=D19「计数项全集」未覆盖项。
- 修复: 两处 `40 键` → `42 键`（或在审计处置表登记该计数项为 deferred 并说明）。
- 置信度: HIGH

### M-5 🟡 [一致性] `skills/task-planner/scripts/selftest-requirement-coverage.sh:165` — RC-15 块头注释与断言方向不一致
- 原文: `# RC-15 负断言 \`grep -c '^65\.'\` =0（[2026-10-08 task-v144 合并级联] 防线前移 ...`
- 原因: 本批已将代码断言改为 `^66\.`（:174）并追加 v149 行，但 :165 块头仍写 `^65\.`、:166-168 What/Why 仍写 `'63.'`/`63 号`。同一断言块内出现 ^65（头）/^66（码）/63（What/Why）三值不一致（前两者由本批引入/未同步）。对読者与后续级联演进有误导。
- 修复: :165 头改 `grep -c '^66\.'`；:166-168 What/Why 并入本次演进（改 66）或至少标注历史值。
- 置信度: HIGH

### L-1 💬 [Nit] `skills/task-planner/lib/install-companion.sh:20` — 注释箭头两侧同名
- 原文: `# ... 修正变量名拼写 COMPANION_DIR→COMPANION_DIR（原多一个 A ...）`
- 原因: 箭头左值应为误拼 `COMPAANION_DIR`（多一个 A），实际写成与右值相同的正确名，箭头无信息量。文字括号已澄清，属注释瑕疵。
- 修复: 左值改回 `COMPAANION_DIR→COMPANION_DIR`。
- 置信度: HIGH

### L-2 💬 [Nit/遗漏] `skills/task-planner/scripts/sync-companion.sh:16` — 同款拼写缺陷未随修
- 原文: `COMPAANION_DIR="${TASK_PLANNER_ROOT:-$SKILL_ROOT}/companion"`
- 原因: D25 在 install-companion.sh 修了同款 `COMPAANION_DIR` 拼写（并称「命名缺陷」），sync-companion.sh 为姊妹脚本、同缺陷（:16/:42/:47/:59/:103/:108/:117 自洽未暴露），未一并修。两脚本现对同一概念变量拼写不一致。
- 修复: 若属本任务「全量对齐」范围则同批改名 COMPANION_DIR；若刻意限定 install-companion.sh，请在处置表登记理由。
- 置信度: HIGH（事实）

### L-3 💬 [Nit] `skills/task-planner/scripts/selftest-registry.tsv` — 10 行仍标 `properties=40`
- 原文: `...;config properties=40`（行 41/43/46/47/48/49/51/52/53/54 等）
- 原因: 守卫断言均=42（v144 起），registry 描述字段 10 处未同步。系存量陈旧（非本批引入），但属 D19 计数面遗漏。
- 修复: 批量改 42 或登记 deferred。
- 置信度: HIGH

## 负结果（无问题面）
- **无 Blocker / 无安全项**：本次未经手 SQL/命令注入、路径遍历、认证面；install-companion.sh 备份/拷贝路径均受 `$TARGET_ROOT`/`$HOME` 约束，无用户可控拼接注入。
- Rule 65 块与 1a92ef3 原文零差异（除 57→65 改号）已证；无条款语义改写。
- 12 个改动守卫 selftest 直跑全 FAIL=0；无基线外新增 FAIL（本任务相关面）。
- 仓内（非 plans）已无 `1-64` 残留、SKILL.md 无 `Rules 1-39`/`1-45` 残留。
- INSTALL.md variant 计数 12→29 正确（实测 29）；MIGRATION smoke 16→17 正确（实跑 17/0）。
- INDEX.md 八行幽灵修正与 git 终态一致，汇总 0 in_progress/0 pending。
- DCS-20 收窄、D22 头注、D23 GLM-5.3（frontmatter model=`zai-individual-coding-plan/GLM-5.3` 一致）、D20 video-fix 未落地登记，均与实态相符。

## 未验证项
- 全量 62 selftest 回归与 P1 基线逐条 diff（S13 code-runner-agent 并行承担，本检查点仅验 12 个改动脚本）。
- 部署位 IDENTICAL 对账（Phase 5 VC-4，未执行）。
- cursor 位重同步 / companion .backup-* 移出（Phase 5 D26/D27，未执行）。
