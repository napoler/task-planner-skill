# Verification Contract & Phase Gates

## Goal (1 sentence)
对 canonical 仓 task-planner 技能完成文档对齐批修（18 漂移 + 4 类遗漏）与仓库簿记对齐，合并 master 后重部署 task-planner×3 并 9 位 diff 复验，push origin/master。

---

## Verification Contract (final checks)

- [x] VC-1: 规则数陈旧声明清零（"Rules 1-26/1-18/1-12" 式旧总数不再出现）
  Evidence: worktree+master grep — 仅余 SKILL.md:302 "Rules 1-12：先规划再执行/…"（对规则 1-12 内容的合法分组描述，非总数断言）；README L67 已改 "Rules 1-27（1-12 核心执行约束 + 13-27 P0/P1 扩展门控）"；batch-quality-gate.md L129 已改 "隶属 Rules 1-27" → PASS
- [x] VC-2: SKILL.md frontmatter references 与 references/ 10 个 .md 一一对应
  Evidence: SKILL.md L18-19 新增 template-guide.md / template-mapping.md 两条；grep 复核 10/10 收录 → PASS
- [x] VC-3: 悬空指针清零
  Evidence: grep "templates/template-guide|scripts/plan-writer" = 0（SKILL.md L569 已指 references/；INSTALL.md L231 已指 companion/agents/）；ARCHITECTURE L126 scan-plans.sh 已标 "（示例，非实存脚本）"；lib/install-companion.sh:172 与 scripts/sync-companion.sh:131 内的 scan-plans.sh 为脚本内 echo 示例字符串（非文档、不在本轮 scope，findings §Findings-4 已记录）→ PASS
- [x] VC-4: config 键对齐（autonomous_resume 补入 + README 键数断言修正）
  Evidence: config.json L77 `"autonomous_resume"`（properties schema 风格，default true，JSON 解析验证过）；README 键数断言 13 → 18（17 实有 + 新增 1）+ 新增 18 键说明表 → PASS
- [x] VC-5: INSTALL.md variant 模板计数 = 实际
  Evidence: `ls templates/variant/ | wc -l` = 12；INSTALL.md L241 "应 = 12" → PASS
- [x] VC-6: install.log 出清
  Evidence: 真相修正——从未被 git 跟踪（.gitignore 一直有效）；canonical 磁盘文件已 rm（"install.log removed from canonical disk"）；worktree 与重部署后的部署位均无此文件 → PASS
- [x] VC-7: 遗漏脚本/config 键文档化
  Evidence: README L93-96 收录 plan-doctor.sh / resolve-plan-dir.sh / set-active-plan.sh / zcode-sessionstart.sh（*.ps1 已在既有合并条目）；README L131-134 config 键表收录 stale_remind_cooldown_calls / prompt_note_interval / plan_dir_pattern / autonomous_resume → PASS
- [x] VC-8: 簿记对齐
  Evidence: commit c6be41a（INDEX 脚本刷新 + v053 Current Phase 收尾重 attest SHA 6d4531e5 + v051/v052 目录入库 + aligned_files.json 归位 v051 证据目录）；提交后 git status 仅余 .active_plan(M)（共享指针，并行会话持有）+ v054/v055 计划目录 → PASS
- [x] VC-9: 重部署后 9 位 diff -rq 全等
  Evidence: task-planner×3 重部署（rm+cp -rL）后 diff -rq = 空 ×3；其余 6 位（todo-skill×2/task-drift-guard×2/plan-resume×2）diff -rq = 空 ×6 → PASS
- [x] VC-10: smoke + verify 体检
  Evidence: tests/smoke.sh = 17 pass / 0 fail；lib/verify.sh（TASK_PLANNER_ROOT 已设）= 20 pass / 0 fail → PASS
- [ ] VC-11: master 已推送 origin/master
  Evidence: Phase 6 执行，实时证据回填 progress.md Phase 6 段（git rev-parse origin/master == master）→ 待回填

---

## Phase Gates

### Phase 1: 审计与范围锁定
**Done when**: 双子代理审计落盘 + 计划制定 — Status: `complete`（checkpoint 01/02 + findings §Research Findings）
### Phase 2: 仓库簿记对齐
**Done when**: INDEX/iv053/aligned_files/v051+v052 入库 — Status: `complete`（commit c6be41a）
### Phase 3: 文档漂移批修
**Done when**: executor×2 批修 + 独立复核 + smoke — Status: `complete`（commit c036c3e，8 文件 +69/-26）
### Phase 4: 合并回 master
**Done when**: merge --no-ff + 抽查 + worktree 清理 — Status: `complete`（merge 3d83be2；worktree remove + branch -d 完成）
### Phase 5: 重部署 + 9 位复验
**Done when**: ×3 重部署 + 9 位 diff + verify.sh — Status: `complete`（9/9 IDENTICAL；verify 20/0）
### Phase 6: 终验交付
**Done when**: verification.md + check-complete + push + 记忆同步 — Status: `in_progress`

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 双子代理审计报告（findings §Research Findings） | Phase 3 修复清单逐项溯源到 A1-A18/B/C 编号 | 符合 |
| 部署拓扑 9 位 + SOP（memory deploy-flow） | Phase 5 按 rm+cp -rL + diff -r 复验执行 | 符合 |
| 用户宪法 §十一 worktree 条款 | Phase 3-4 全程 worktree 隔离 + 合并合约 + 清理 | 符合 |
| v053 deferred-issues 5 条 | 逐条核对，本轮不扩 scope（#5 origin/main 仍挂账等用户决策） | 符合 |

## 委派统计复验（Rule 25.4）
- [x] 委派率已统计:子代理执行 Phase 2 / 总数 6（Phase 1 审计 = explore→general-purpose×2 改派；Phase 3 批修 = executor×2）。**执行型 Phase 委派率 2/2 = 100%**；其余 4 Phase（2 簿记/4 合并/5 部署/6 终验）为主进程白名单内专属（Rule 25.3 ①计划系统文件与簿记、合并合约编排、⑤既定部署 SOP、终验编排），例外理由均已登记在各 Phase Executor 字段
- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由
- [x] 无白名单外直做 → 不触发 PARTIAL 降级（对齐 v053 先例：直做全部白名单内 → COMPLETE 可达）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查:触发 0 项,豁免 0 项,未处置 0 项（无伪造证据；无验证跳过——子代理产出全部独立复核；批量批修有双 executor 分批 + 主进程 diffstat/grep 三重抽查）
- [x] Evidence 抽查 ≥3 条:①SKILL.md:302 合法分组语境 Read 核实 ②config.json:77 autonomous_resume grep+JSON 解析 ③README L93-96/L131-134 新增条目 grep ④9 位 diff -rq 实跑 ⑤smoke/verify 输出实跑 —— 均可复现
- [x] 豁免登记: 无
- [x] 无未处置违规 → 不触发 Rule 26.3 降级

## Goal Gate (终验)

```
## Goal Verification — 文档对齐 + 遗漏补全 + 簿记对齐 + 重部署
- [x] VC-1 ~ VC-10: 见上，全部 PASS（证据可查）
- [ ] VC-11: push origin/master → Phase 6 执行后回填

 outcome: COMPLETE（以 VC-11 push 成功为最终生效条件；若 push 网络失败 → PARTIAL 并记 deferred）
```

---

## 5-Question Reboot Check
| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 6（终验交付） |
| 2 | Where am I going? | push + 记忆同步 + 交付总结 |
| 3 | What's the goal? | 见 Goal |
| 4 | What have I learned? | findings.md（含 install.log 真相修正/A16 自愈/attest 用法） |
| 5 | What have I done? | progress.md（Phase 1-5 全记录） |
| 6 | Which tasks need processing? | INDEX 待处理区：v055（并行会话持有，非本任务） |
