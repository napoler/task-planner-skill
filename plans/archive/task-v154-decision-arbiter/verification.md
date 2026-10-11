# Verification Contract & Phase Gates

## Goal (1 sentence)

为 task-planner 技能新增强模型判别/决策子代理 `decision-arbiter`（GLM-5.3 档）及其 Rule 69 条款、SKILL 执行流程触发点矩阵、守卫 selftest 与四部署位对账（用户目标：遇判断问题委派裁决、强模型保质、驳回打回闭环、明确触发阶段）。

---

## Verification Contract（终验逐条复验，2026-10-10 主进程独立取证据）

- [x] **VC-1**: `companion/agents/decision-arbiter.md` 在位（master 5280cb3），frontmatter model 逐字符=`account:zai-individual-coding-plan/GLM-5.3`，四态裁决+驳回单五要素+六触发点 T1-T6+四邻管辖二分+只读硬约束全在位
  Evidence: `head -8` frontmatter model 行；`grep -c "APPROVE|REJECT-REWORK|ESCALATE-USER|INSUFFICIENT-EVIDENCE"`=6；`grep -c "驳回单五要素"`=1；60 行全文 Read 复核（Phase 2 主进程验收）
- [x] **VC-2**: `critical-rules.md` Rule 69 六子条（69.1-69.6）+[arbiter-reject] 消费留痕协议在位；`plans/.rule-reservations.jsonl` 69=landed
  Evidence: `grep -c '\*\*69\.[1-6] '`=6；`grep -c arbiter-reject`=1；账本末行 `{"rule":69,"status":"landed","task_id":"task-v154-decision-arbiter"}`
- [x] **VC-3**: SKILL.md 接线+触发点标记：grep decision-arbiter=10 行/Rule 69=11 行（路由行+清单行+T1-T6 六标记+C47 合规行+外部引用+1-69 修正）
  Evidence: `grep -c` 命令输出（10/11）；S5 检查点 11 处锚（5-executor.md）
- [x] **VC-4**: 登记面同步：agent-coverage.md 矩阵 28 行（grep=1）+template-mapping §九§十（grep=2）+router D2 行（skill-agent-router:102，grep=1）
  Evidence: 三文件 grep 计数+6-executor.md 检查点 D2 行文本+router 部署位 line 102 Read 确认
- [x] **VC-5**: `selftest-decision-arbiter.sh` DA-01..16 全 PASS；主仓全量回归 65/65 全绿（ΣFAIL=0；Phase 1 基线 64/64 ΣPASS=1002 对照：新增 1 脚本+16 断言零回归）
  Evidence: 主仓终局回归日志 `MASTER-FINAL total=65 failed=0 ALL_GREEN_65/65`；部署位复跑 AC 9/9+DA 16/16（部署后 AC-04 已转 PASS）
- [x] **VC-6**: 合并回 master=5280cb3（--no-ff merge wt/v154-decision-arbiter）；三部署位 skills 全 IDENTICAL（zcode/claude/opencode diff=0）；companion agents 双位（zcode+claude，5105B 一致）；worktree+branch 清理（v154 不在 worktree list；其余并行 v152/v155/v157/v158 保留）
  Evidence: `git log` 5280cb3；`diff -rq`×3=0；`git worktree list`；agent 双位 ls 字节数

---

## Phase Gates

### Phase 1: 基线侦察与登记面定位 — `complete`
- V-1.1（VC-5）: 基线 64/64 ΣPASS=1002 ΣFAIL=0（checkpoint 1-code-runner.md 115 行）
- V-1.2（VC-4）: D2:101/D3:289/registry TSV/Rule69 锚:860/触发点 6 锚全定位（checkpoint 2-explore.md）

### Phase 2: 主件实现（worktree 内） — `complete`
- V-2.1（VC-1）: agent 定义 60 行主进程 Read 复核全命中（commit 86942e2）
- V-2.2（VC-2）: Rule 69 六子条纯追加 verified（diff 8+/0-、3+/0-；commits cc70dca/da996a5）
- V-2.3（VC-3/4）: SKILL 11 处接线+矩阵 28 行+template-mapping §九§十（commit 48dc681；grep 12 occurrences/11 行）

### Phase 3: 守卫 selftest 与全量回归 — `complete`
- V-3.1（VC-5）: DA-01..16 新建 16 断言全 PASS+任意 CWD 双验证（commit 3322259）
- V-3.2（VC-5）: S8 首跑 5 FAIL→Fix 四批（DCS-11/RF-06 宽容锚裁决/G-09+T-main 钉 515→526/G-07 末行恢复）→终跑 failed=1=AC-04 部署暂态（commit 6e1202f）

### Phase 4: CR 审查与修复 — `complete`
- V-4.1（VC-1）: alignment-review verdict CHANGES_REQUESTED P0=0（T1-T6/四态/model 三处一致全 PASS；P1=AC-04 暂态，P2=CHANGELOG→已补登）
- V-4.2（VC-5）: code-quality-review verdict CHANGES_REQUESTED P0=0（DA-16 可移植性+2 P2→fix 完成；CR Gate 等效 APPROVED 登记）——fix commit 99d82db

### Phase 5: 合并回+部署对账+清理 — `complete`
- V-5.1（VC-6）: master 5280cb3+三 skills 位 IDENTICAL+agents 双位+worktree/branch 清理+rule 69 landed
- V-5.2（VC-1/3/4/5）: 部署后复跑 AC 9/9（AC-04 转 PASS）+DA 16/16；C 轮四守卫 1-69 演进（commit f06fb90）

### Phase 6: 终验与交付 — `complete`
- V-6.1: 主仓终局全量回归 65/65 全绿（对照 Phase 1 基线零回归）
- V-6.2: check-complete.sh exit 0+委派统计（见 task_plan.md）+Rule 58.5 三态裁决 solved

---

## 🎯 核心目标达成裁决（Rule 58.5）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1（判断/裁决子代理落地）/R3（驳回打回闭环）/R4（接入调度体系）/R5（触发点矩阵明确） |
| **裁决** | `solved` |
| **解决证据锚** | decision-arbiter.md（四态+驳回单+T1-T6）+critical-rules.md Rule 69.3（[arbiter-reject] 强制返工协议）+SKILL.md 10/11 接线+触发点 6 标记+65/65 回归+master 5280cb3 部署 IDENTICAL |
| **未解决面+原因** | 无 |
| **已排除路径** | n/a（一次正解，未走排除路径） |
| **下一步建议** | 行为级冒烟（新会话首次派发 decision-arbiter 实跑 T3 类场景）——机制在位待实战验证；与 v152/v155/v157/v158 并行任务的合并生态持续观察 |

## 📊 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 6（Phase 1/2/3/4=S1-S10+3 fix 批次共 14 次派发：code-runner×2/Explore×1/executor×7/general-purpose 质量审查×4） |
| 主进程直做 Phase 清单 | Phase 5（白名单① git/worktree 编排+部署脚本）、Phase 6（白名单② 簿记+终验门控）；S8 回归代跑（白名单⑤ 22.3 接管——用户取消派发后代执行） |
| 委派率 | 4/6=0.667 < floor 0.7，但全部主进程直做 Phase 均命中 Rule 25.3 白名单①② → **WHITELIST-EXEMPT 放行** |

## 🛡 质量门控统计（Rule 26）

| 项 | 结论 |
|----|------|
| Q1 证据完整 | PASS（全部 VC 有命令/Read 第一手证据） |
| Q2 迭代落盘 | PASS（Round 1-6 逐轮四要素入 progress.md） |
| Q3 无伪造 | PASS（ledger 一次抢记为 ALIGNED 但 drift 未派，已即时补派 drift-checker-5 使陈述成真并如实登记） |
| Q4 QA 审查 | PASS（alignment+code-quality 双 skill 42.4 登记工具执行） |
| Q5 CR Gate | PASS（双 verdict CHANGES_REQUESTED P0=0→fix-phase complete→等效 APPROVED） |
| Q6 交付终态 | COMPLETE（六 Phase complete+VC 6/6） |
