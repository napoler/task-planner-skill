---
id: worktree-parallel-pointer-race
title: "并行会话隔离与活跃计划指针竞态"
tags: [并行会话, 指针竞态, 瞬态状态, sid隔离, 合并纪律]
sources: [plans/archive/fix-pointer-race-20261007/findings.md, plans/archive/fix-pointer-race-20261007/subagent-state/5-code-assistant.md, plans/archive/task-v059-active-plan-race/findings.md, plans/archive/task-v159-pointer-lifecycle/findings.md, plans/archive/task-v159-pointer-lifecycle/delivery-summary.md, plans/archive/task-v164-pointer-worktree-local/knowledge-brief.md, plans/archive/task-v164-pointer-worktree-local/findings.md, plans/archive/task-v164-pointer-worktree-local/delivery-summary.md, plans/archive/task-v182-git-snapshot-commits/findings.md, plans/archive/task-videop1-ep03-rollback-guard/progress.md, plans/archive/task-v170-archive-completed-plans/progress.md]
updated: 2026-10-22
---

# 并行会话隔离与活跃计划指针竞态

## 结论（可直接复用）

1. **指针解析链四层，顺序即语义**：① side 层（`plans/.active_plan_side/<sid>.active_plan`，会话私有、已 gitignore、TTL 24h）= 权威层 → ② 全局 fallback（`plans/.active_plan`，现已改为工作树内瞬态）→ ③ mtime 兜底（`plans/*/task_plan.md` 最新目录）→ ④ legacy 根单文件。链位：`resolve-plan-dir.sh:30` ROOT=`${1:-$PWD}`、`:58-95` side、`:97-105` 全局、`:107-129` mtime+legacy。**改解析链顺序/语义属 scope 蔓延**（真缺陷在跟踪态与叙事层，不在路径层）。〔task-v164〕
2. **竞态三根因（2026-10-07 定案）**：RC-1 写读命名空间分裂（写侧带 `sess` 前缀、读侧只读剥前缀形态）→ RC-2 init「抢最新哨兵」兜底多会话互抢（复现 `4272173a` 污染）→ RC-3 mtime 兜底把 miss 放大为持续劫持。修复=7 文件 +309/-14（`8f6c0f3`）：读写统一 + sidmap 确定性映射 + 兜底两级化（映射权威优先 → ≤120s 新鲜窗探测 → **拒抢 WARN**）+ gc 扫 sidmap。〔fix-pointer-race〕
3. **sidmap = env sid→hook sid 确定性映射**（`.plan_required_side/<env_sidkey>.sidmap`，SessionStart 落盘）。三级语义：① sidmap 在 → 用映射键（**不要求目标哨兵存在**，哨兵被正常清除属常态）② 无 sidmap → 新鲜窗探测 ③ 其余 → env key 原样。resolve 侧 env-only 调用方（allow-direct/check-delegation/plan-doctor/posttooluse 清锁/attest 回退）双形态 `${SID}`/`sess${SID}` 都 miss 时，读 sidmap 首行剥非字母数字取前 40 得 `_mapped_sid`，顺序探测 `${SIDE_DIR}/${_mapped}.active_plan` → `${SIDE_DIR}/sess${_mapped}.active_plan`。**有身份记录时绝不探测**（防误取他会话指针）；sidmap 损坏 → 跳过探测、按 env sid 落盘（fail-conservative）。〔fix-pointer-race〕
4. **根治做法：全局指针降级为工作树内瞬态文件**：`git rm --cached plans/.active_plan`（工作区文件保留）+ 仓根 `.gitignore` 追加 `plans/.active_plan`（:15，与 `.active_plan_side/`/`.plan_required_side/`/`.drift-rhythm/` 同族）→ 跨树零共享、**合并零冲突**（取删除态、各会话 set 再生）、**git churn 止息**（跟踪态曾 8 连 chore：`f6d6158`/`de3c19f`/`21f7e6b`/`ee978a1` 等，注释自证「交付后残留」）。路径本就随 `$PWD` 本地化（`set-active-plan.sh:69`/`:84-85`）→ 禁借机做路径大改。〔task-v164〕
5. **双树互不感知=修复有效的行为级判据**：B 树 legacy set → `:3 [active-plan] 全局指针已设置: task-v160-decision-grading(...)`，同时 `:5 A全局=task-v164-pointer-worktree-local`（A 树未受 B 写影响）；同 sid 双树 resolve 各自正解（`:7`/`:8`）；`:6 B-status=NO-ENTRY(PASS)`（瞬态文件不入 git status）。另：`--sid sid-y` 会被规范化为 `sidy` 落盘，读写两侧一致（`:17` 以 `sid-y` 解析命中同键）。〔task-v164〕
6. **新建 worktree 无全局指针是正常态，但 mtime 兜底可能落到别的计划**：C 树 `:13 C全局=不存在(预期)`、`:14 resolveC-noside=…/plans/fix-pointer-race-20261007/task_plan.md`——路径合法但未必是本任务计划。sid-less 消费者在新树内必须显式 `set` 指针；**「解析成功」≠「解析正确」**。〔task-v164〕
7. **瞬态化后必须补「存在性假设」维守卫**：分级判据若只分「是否命中代码逻辑」，会漏掉第三维=**读取处是否假设文件必存在**。实证 `check-complete.sh:1375` 裸重定向读 `plans/../.active_plan`（`tr … < file 2>/dev/null` 捕不住 shell 层重定向失败）→ 瞬态化后每次终验多一行 `No such file or directory`。修法=`[ -f "$PLAN_DIR_GUESS/../.active_plan" ] && …` 前置守卫，保持「缺失→静默跳过」fail-open 语义（/tmp 夹具 OLD/NEW 对照实测 OLD 漏 stderr、NEW stderr 空）。〔task-v164〕
8. **引用面改述逐文件人工判定，禁 grep+sed 批量替换**：`grep -rn 'active_plan' skills/task-planner/` 实测 **28 文件 / 170 hits**（材料记 166，以实测为准）→ 只读消费方 14 / 措辞更新方 12 / 已改述 2；措辞更新判据=hit 或其注释块 ±5 行把全局指针框为旧语义（全局 legacy/移交/跨树共享/入库/git 跟踪）。**改文档字面会连带机器契约**：改 `SKILL.md`「指针移交」→「指针清理」→ `selftest-pointer-lifecycle.sh` PL-07 断言 FAIL（`Total: 10 PASS=9 FAIL=1`）→ 断言须同步锁步（PL-06 双锚 `移交提醒`+`移交提醒.*>&2` 保持不动）。〔task-v164〕
9. **状态判定必须锚定真实状态行，模板行不是状态**：初版 `Status.*complete` 误清在途计划（CR 判 **BLOCKER**）→ 反向判据撞模板固定行（pending→in_progress→complete）→ 终版=锚定真实状态行两子句（`has_complete` 且 `no_active`）。边界：中文「- **状态:** complete」不命中 → **不清理**（保守方向，宁可留不可误删）。〔task-v159〕
10. **side 写入要有所有权守卫**：`.session-owner` 双形态匹配（`sess` 前缀 / 裸 uuid）；claimant 处 `in_progress` → **不写该键 + WARN**；`--force` 覆盖。set-active-plan.sh 与 init-session.sh 必须同语义，否则「沿袭 sidkey 互踩」复发。〔task-v159〕
11. **并行在途提交一律限定 pathspec**：`git add`+裸 `commit` 提交整个 index → 他会话已暂存的 3 个 rename 搭车（`4e88cf3`）；修法 `git reset --soft HEAD~1` + `git commit -m … -- <pathspec>` 重提（`b169843`），rename 原样留暂存区；提交后必核 `git log -1 --stat` 文件清单=本任务 scope。〔task-videop1-ep03〕
12. **并集解（并行接管对端批次）后必须重跑全集**：接管对端批次（21min 冻结+完好态双 PASS）后并集解，首轮 4 块冲突全解，**二轮才发现对端枚举化连带伤**（其批次从未跑全集，依赖区间写法 incidental 字面随枚举化消失）。教训：① 并集解后必须重跑全集 ② 主仓 `scripts/` 直改会被委派门硬拦 → 改派 Code Assistant ③ 接管批次若含索引语义变更，全集回归责任随接管转移。〔task-v182〕
13. **他会话改动本任务计划的第一信号 = attest 哈希不符**：`.plan-attestation` 锁定值 `a35c941f…` vs 现文件 sha256 `dc600b0b…`（不符确认），且 `task_plan.md` mtime 22:02:47 晚于 `attested_at` 21:55:55 约 7 分钟 → 前会话锁定后修改未重 attest。处置=**只读核验 + 登记报告用户，不动该文件**（§11.4 并行尊重）。〔task-v170〕
14. **并发会话/cron 会翻转全局层指针——文案层必须同步退役「互顶/移交」叙事**：`check-dispatch.sh:20` 注释原文即「全局指针 .active_plan 被并发会话/cron 频繁翻转」；`zcode-pretooluse.sh:72-73` 原「不再被互顶的全局指针误拦」→ 改「不再被并发覆写的全局层误拦」。旧措辞留存会继续误导后续读者并触发 grep 验收误判。〔task-v164〕

## 证据锚

| 锚 | 事实 | 来源任务 |
|----|------|---------|
| plans/archive/fix-pointer-race-20261007/findings.md:46-49 | RC-1/RC-2/RC-3 根因链；7 文件 +309/-14（`8f6c0f3`）；selftest-active-plan 29/29；部署位 7 文件 IDENTICAL | fix-pointer-race |
| plans/archive/fix-pointer-race-20261007/subagent-state/5-code-assistant.md:7-21 | sidmap 三级语义 + 双形态探测 + 「有身份记录绝不探测」防抢 + T12g/j/k/l 用例 | fix-pointer-race |
| plans/archive/task-v059-active-plan-race/findings.md:52-57 | 旧 hook 按主仓指针校验 → worktree 计划被误拦；symlink+`--sid`+legacy 三步修法 | task-v059 |
| plans/archive/task-v159-pointer-lifecycle/findings.md:21-24 | F1 状态判定 BLOCKER 迭代（两子句锚定）；F3 `.session-owner` 双形态+in_progress 不写+WARN；F5 实弹 OK + D4 删后写事故 | task-v159 |
| plans/archive/task-v159-pointer-lifecycle/delivery-summary.md:7,24 | gc 生命周期（dead-ref/completed-TTL→置空）+ side 写入所有权守卫；F1 全局置空语义=回退 mtime 最新（side 层才是并行载体） | task-v159 |
| plans/archive/task-v164-pointer-worktree-local/knowledge-brief.md:11-15,52-59 | 指针四层术语表；§4 易错点 7 条（禁改解析链/禁批量 sed/禁删工作区文件/新 worktree 无指针=竞态/飞行 worktree 冲突按瞬态处置） | task-v164 |
| plans/archive/task-v164-pointer-worktree-local/findings.md:26-49 | A 路径层已本地化；B 跟踪态 churn 8 连；C 并行实况（side 8 个指针 / 全局层漂移面）；D 兄弟瞬态四类 ignore；E 引用面 28 文件 166 hits | task-v164 |
| plans/archive/task-v164-pointer-worktree-local/findings.md:58-59,83-124,185-187,205-209 | 存在性假设维盲区 + `.dispatch-inflight` 卫生债；28/170 分级表 + PL-07 FAIL 副作用；双树互不感知日志行；check-complete.sh:1375 裸重定向缺陷与 `[ -f ]` 修法 | task-v164 |
| plans/archive/task-v164-pointer-worktree-local/delivery-summary.md:8,16,57 | 行为面变化=并行会话不再互顶全局指针；R2 证据=双树互不感知；收尾=部署位与主仓 diff -r 对账 | task-v164 |
| plans/archive/task-v182-git-snapshot-commits/findings.md:33 / task-videop1-ep03-rollback-guard/progress.md:106 / task-v170-archive-completed-plans/progress.md:34 | 并集解二轮连带伤 + 三条教训；裸 commit 卷入并行 rename；attest 锁定值 vs 现文件 sha256 不符 | task-v182 / videop1-ep03 / v170 |

## 易错点

- **别把「指针能解析」当「指针解析正确」**：新 worktree 无全局指针时 mtime 兜底会给别的计划目录（task-v164 C 树实证）。
- **别改解析链顺序/语义**（side→global→mtime→legacy 冻结）：那属 scope 蔓延（task-v164 §4.1）。
- **别在 sidmap 存在时还去做新鲜窗探测**：会误取/误删他会话指针——有身份记录就绝不探测（fix-pointer-race sub:5）。
- **别把 sidmap 目标哨兵不存在当错误**：哨兵被正常清除是常态，不该因此放弃映射键（fix-pointer-race sub:5）。
- **别在 `git rm --cached` 后顺手删工作区指针文件**：删文件会让 sid-less 消费者彻底丢锚点（task-v164 §4.3）。
- **别用 `grep + sed` 批量改 166/170 处引用面**：多数是只读消费方，批量替换必误伤（task-v164 sub:4）。
- **别漏改机器契约**：改文档字面会让对应 selftest 断言 FAIL（PL-07 判例），断言与文案必须成对锁步（task-v164 sub:5/sub:14）。
- **别用 `Status.*complete` 之类宽匹配判状态**：会误清在途计划（BLOCKER 判例）；中文状态标签不命中时保守不清理（task-v159 F1）。
- **别让「移交/互顶」旧叙事留在注释里**：旧措辞继续误导后续读者并触发 grep 验收误判（task-v164 S5-S10）。
- **别在裸 `git add` + `git commit` 后不看 `--stat`**：并行会话暂存内容会搭车（task-videop1）。
- **别在并集解后就宣布完成**：未跑全集时连带锚伤不可见（task-v182 二轮判例）。
- **别对 attest 哈希不符的他人计划动手**：只读核验 + 登记报告（task-v170）。
- **别把 .gitignore 当部署内容**：仓根文件不随技能部署，部署 diff 不含它是预期差（task-v164 §4.4）。

## 适用场景

- 多会话并行开发同一仓库，需要让「活跃计划指针」互不抢占（派发前、hook 误拦排查）。
- 指针误报：hook 按错误计划目录校验、resolve 解析到已完成计划、全局指针被莫名切换。
- 把运行态文件（指针/哨兵/检查点）从 git 跟踪态迁为瞬态态，并同步治理引用面与机器契约。
- 并行会话在途提交、接管对端批次，或发现 attest 哈希不符需判定归属。
- 审查他任务时核对「解析链未被改动 / 引用面逐文件判定 / 并集解后全集回归」三条纪律。
