# Verification Contract & Phase Gates

## Goal (1 sentence)

把 task-planner 技能的子代理任务拆分从 Phase 级细化到步级（S-unit 派发单元）：计划期强制步级拆分（每步短小、短上下文、自带材料包），执行期失败兜底优先"拆细"而非"升模型档位"，提高小模型执行可靠性。

---

## Verification Contract（终验 2026-09-09，主仓 master 2d3c017 合并后 + 3 位部署后逐条复验）

- [x] VC-1: Rule 22.3 兜底顺序含「拆细」档且先于「降档」，含每子任务限 1 次防循环
  Evidence: `skills/task-planner/references/critical-rules.md:124` — "① 改派 → ② **拆细**(…每子任务拆细限 1 次防无限拆分…)→ ③ 降档 → ④ 主进程接管 → ⑤ AskUserQuestion"；`grep -o 拆细 | wc -l` = 7；22.3.1@125 引用同步为 ④/⑤
- [x] VC-2: Rule 22.6 Subtasks 转正为派发型 Phase 计划期必填 S-unit 表 + 步级数值写入规则 + 模板可见结构
  Evidence: critical-rules.md:128 "S-unit 派发单元表(计划期必填 — Subtasks 转正)…凡 Executor ≠ 主进程的 Phase,**计划期必须**展开"；:114 21.1b "≤step_max_files(默认 2)文件、≤step_max_lines(默认 100)行、预估 ≤step_max_minutes(默认 15)分钟"；templates/task_plan.md:130 头注 + :173-177 可见表（`grep -c "S-unit 派发单元表"` = 2，`grep -c "Subtasks 子表"` = 0）；init-session 流通测试 /tmp/v056-init-test 生成的计划含该表
- [x] VC-3: config.json 新增 4 步级键、JSON 合法、默认值与规则一致
  Evidence: `jq -c '.properties.subagent.default' config.json` → 含 step_max_files:2 / step_max_lines:100 / step_max_minutes:15 / prompt_max_chars:3000（default 9 键）；`jq empty` exit 0；schema.default 与 default 块逐键一致 ×4
- [x] VC-4: subagent_dispatch.md 含「上下文预算」字段（总量 ≤prompt_max_chars + 材料最小化）
  Evidence: templates/subagent_dispatch.md:2 "填九字段"；:19 "材料包来源…只填路径 + ≤10 行摘要"；:71-75 "## 9. 上下文预算(强制 — Rule 22.4 第 ⑨ 字段…)…禁止贴 task_plan.md / findings.md 全文"
- [x] VC-5: plan-writer.md 含拆步纪律（S-unit 必产出 + 材料包预写 + 可观察验收）
  Evidence: companion/agents/plan-writer.md:40 任务分解句；:107 产出契约；:154-157 Phase 1 示例 S-unit 骨架；:185-186 禁止 2 条；:195/:207 S-unit 数（`grep -c S-unit` = 7）；frontmatter 未动
- [x] VC-6: SKILL.md ≤500 行、P0 计数不减、verify.sh 全 pass
  Evidence: `wc -l SKILL.md` = 500（VC 边界值）；`grep -c P0` = 10（前后一致）；五档兜底表 @375-380；`TASK_PLANNER_ROOT=<位> bash lib/verify.sh` → **25 pass / 0 fail ×3**（zcode/claude/opencode，部署后复跑；部署前 worktree 内 22/3 的 3 fail 均为预期 deploy drift）
- [x] VC-7: selftest 全 pass 无回归
  Evidence: subagent-state/11-code-runner-p6.md — selftest-delegation.sh "Total: 35 PASS=35 FAIL=0"；selftest-fallback.sh "Total: 21 PASS=21 FAIL=0"（worktree 50450ea，内容与 master 合并后一致）
- [x] VC-8: 合并回 master 后部署点重部署 diff=0
  Evidence: merge 2d3c017（--no-ff，6 文件 +70/−29）；`rm -rf + cp -rL` 重部署 ~/.zcode/skills/task-planner、~/.claude/skills/task-planner、~/.config/opencode/skills/task-planner → `diff -rq` = 0 ×3（各 99 文件）；companion 6 位无源码变更（install-companion dry-run 全 identical）；plan-writer agent 副本：~/.zcode/agents 与 master `cmp` IDENTICAL，~/.claude/agents 仅 model 行平台适配（`model: sonnet`，复现 install-companion v2.2.2 adapt_model_line 逻辑）；worktree remove + `wt/*` 分支 0 遗留

---

## Phase Gates（摘要 — 详细动作见 progress.md）

| Phase | Goal | Done when | Verification | Status |
|-------|------|-----------|--------------|--------|
| 1 调研 | 10 项机制盘点 | 检查点落盘 | V-1.1 01-explore.md 10/10 带 file:line ✓ | complete 09-09 |
| 2 计划 | D1-D5 方案 + 计划获批 | 用户 yes + attest | V-2.1 attest 403ae8d1 ✓；V-2.2 哨兵清除 ✓ | complete 09-09 |
| 3 规则 | critical-rules 3 S-unit | 3/3 Read 复核 | V-3.1 VC-1 ✓；V-3.2 VC-2 规则部分 ✓；V-3.3 commit 3164591 ✓ | complete 09-09 |
| 4 config+模板 | 3 S-unit 并行 | 3/3 复核 | V-4.1 VC-3 ✓；V-4.2 VC-4 ✓；V-4.3 VC-2 模板部分 ✓；commit 61a0238 | complete 09-09 |
| 5 plan-writer+SKILL | 3 S-unit 并行 | 3/3 复核 | V-5.1 VC-5 ✓；V-5.2 VC-6 行数/P0 ✓；V-5.3 25.2 并行例外 ✓；commit 50450ea | complete 09-09 |
| 6 验证 | 6 项校验 | 全过/drift 判定 | V-6.1 VC-7 ✓；V-6.2 verify 22/3 drift 预期 ✓ | complete 09-09 |
| 7 合并部署终验 | merge+deploy+VC | 8 VC 全过 | V-7.1 VC-8 ✓；V-7.2 verify 25/0×3 ✓；V-7.3 check-complete：7/7 complete + porcelain clean + verdict ok 全过，但脚本 exit 1 = 委派率比较反转 bug 的假阴性（遗留 #0） | complete 09-09 |

---

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 01-explore.md 现状调研 | D1-D5 每项对应调研发现（R1 六条） | 符合 — 兜底顺序/Subtasks 注释/无步级键三大缺口全部对应改动 |
| critical-rules.md:110-167 原文 | Phase 3 派发 prompt 逐字引用原文做 old→new | 符合 — 3 S-unit 验收含"邻行未变"检查 |
| worktree-isolation.md SOP | 集中目录路径 + --no-ff merge + remove/branch -d | 符合 — worktrees=1（主）/wt 分支 0 |
| task-planner-repo-deploy-flow memory | rm+cp -rL 重部署 + diff -r + verify.sh 需 TASK_PLANNER_ROOT | 符合 — 3 位 diff=0，verify 25/0×3；**补充发现**：plan-writer agent 副本不在"9 位"拓扑内且此前已漂移（zcode 副本停在 09-03 旧版），本次一并对齐 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":7,"phases_delegated":5,"main_direct_count":2,"delegation_rate":0.714,"main_direct":[{"phase":"2 方案设计与计划撰写","executor":"主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）","reason":"例外理由:② 计划系统文件维护——Rule 25.3 白名单","needs_git_evidence":0,"self_declared":0},{"phase":"7 合并回 + 9 位重部署 + 终验交付","executor":"主进程（例外理由:① 纯 git/worktree 编排——Rule 25.3 白名单）","reason":"例外理由:① 纯 git/worktree 编排——Rule 25.3 白名单","needs_git_evidence":0,"self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase（2/7）均在白名单内（② 计划系统文件维护 / ① 纯 git 编排）
- [x] 委派率 0.714 ≥ 0.7；verdict=ok；violations=[]
- 子代理明细：explore ×1、executor ×9（Phase 3 串行 3 + Phase 4 并行 3 + Phase 5 并行 3）、code-runner ×1 = 11 次派发，全部一次通过，0 改派 / 0 拆细 / 0 降档 / 0 接管

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成：触发 0 项，豁免 0 项，未处置 0 项（Q1 VC 全勾且 Evidence 非空；Q2 各 Phase Test Results 已填；Q4 Handoff 11 行 verify_done 全 ☑；Q5 委派率达标；Q6 非批量任务不适用）
- [x] Evidence 抽查 ≥3 条：① critical-rules.md:124 Read 复核含"② **拆细**"→ 复现 ✓；② `jq -c .properties.subagent.default` 复跑 → 9 键 ✓；③ verify.sh 25/0 ×3 复跑 ✓；④ `git worktree list` = 1 / `git branch --list 'wt/*'` = 0 ✓
- [x] 豁免登记：无
- [x] 无未处置违规，outcome 不降级

## Goal Gate

```
## Goal Verification — 子代理拆分粒度精细化（S-unit 步级 + 拆细先于升档 + 小模型短上下文友好）
- [x] VC-1 拆细档先于降档 → PASS
- [x] VC-2 S-unit 计划期必填 + 步级数值 + 模板转正 → PASS
- [x] VC-3 config 4 键 → PASS
- [x] VC-4 派发模板上下文预算 → PASS
- [x] VC-5 plan-writer 拆步纪律 → PASS
- [x] VC-6 SKILL.md 500 行/P0 10/verify 25/0×3 → PASS
- [x] VC-7 selftest 35/35 + 21/21 → PASS
- [x] VC-8 merge 2d3c017 + 3 位 diff=0 + agent 副本对齐 → PASS

 outcome: COMPLETE
```

**已知非阻塞遗留（建议后续，不影响 COMPLETE）**：
0. **P1 — check-complete.sh 委派率门控比较反转**（findings R7）：`scripts/check-complete.sh` ~L402 awk `exit !(r+0 < f+0)` 与外层 `if !` 双重取反，达标判 FAIL / 不达标判 PASS（三组实证）。本任务 7/7 complete、porcelain clean、verdict ok、rate 0.714≥0.7 实质全过，`check-complete.sh` 真实 exit 1 **纯由此 bug 造成**。引入 4420c08（v055），canonical + 3 部署位同款。修法 1 行（去掉 `!`），须用户授权 + worktree + 重部署 + selftest 补两侧用例
1. `lib/install-companion.sh` 对 zcode 目标会把 plan-resume 技能新装进 `~/.zcode/skills/`（当前 ZCode 从 `~/.agents/skills/plan-resume` 加载，新装 = 同名遮蔽）——本次未运行该脚本，改为定向更新 agent 副本；脚本的目标发现逻辑值得单独立项核查
2. code-runner-agent（mini）跑 6 条验证命令消耗 738K token（executor 同批 70K-200K）——运行类子代理的输出截断纪律可作下一轮优化（findings R5）
3. SKILL.md 已到 500 行边界，后续增行须等量删行

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 7 complete — 任务交付 |
| 2 | Where am I going? | 无剩余 Phase |
| 3 | What's the goal? | 见上 Goal |
| 4 | What have I learned? | findings.md R1-R6 |
| 5 | What have I done? | progress.md Phase 1-7 |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（pending=0） |
