# Verification Contract & Phase Gates

## Goal (1 sentence)

落地 Rule 46「子代理单任务专注度」：单次子代理会话只领 1 个 S-unit（禁批次连做）+ check-dispatch 双豁免收窄 + 拆分单一性引导 + 派发模板显式条款，零新 config 键，全量 selftest 0 FAIL 后合并回 master 并部署。

---

## Verification Contract (5 items)

- [x] VC-1: Rule 46 条款完整落地（46.1-46.5 子条，范式对齐既有规则）
  Evidence: `grep -c '^46\.' references/critical-rules.md` = 5；`### 46 子代理单任务专注度` L474-483（wt commit e145555，主进程直读复核）
- [x] VC-2: 守卫豁免收窄行为实测（①任务书含 ≥2 S-id → enforce 拦截 ②任务书 >4 步行首编号 → 拦截 ③正常单 S-unit 派发不误伤）
  Evidence: S4/S5 fixture 三态×2 全过（任务书检出/步骤枚举超限/SKIPPED fail-open 各态）；CR 复审 8 形态提取器探测 + 21 次复跑全绿；GR-07/08/09/10 机器断言固化（selftest-dispatch-grain 10/10）
- [x] VC-3: 全量 selftest 回归 0 FAIL（主进程逐脚本 Total 求和）
  Evidence: 终验 43/43 脚本 rc=0，ΣPASS=676 ΣFAIL=0（subagent-state/13-executor.md，基线 666→终验 676 自洽：+GR-01..10 十断言）；S7 中间态曾暴露 CD-12 失配（674/1）已修（10-executor.md 24/24+负向自检）
- [x] VC-4: SKILL.md 联动 + 净增 ≤10 行 + 行数断言不破
  Evidence: SKILL.md L9 frontmatter 全集 1-46 / L85 委派检查点 2.5 单会话单 S-unit 措辞 / L247 摘要行 /45/46 / L305 References 行；wc -l = 444（净增 0）+ 模板 +2 = 总净增 2 ≤10；`grep -c 'Rules 1-39'` = 2（SR-07 保持）；T2b ≤558 不破
- [x] VC-5: 合并回 master（--no-ff）+ 部署 3 实体位 diff=0 + worktree/分支清理
  Evidence: smart-merge-back.sh --deploy 输出（见 progress.md Phase 5 段）+ `git worktree list` 空 + 主仓 Read 复验

**终验规则**: 全部 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: 隔离与基线 — complete
- worktree /home/terry/task-planner-skill-worktrees/task-v118（wt/task-v118 自 master 06b31d8）
- 基线 42/42 GREEN ΣPASS=666 ΣFAIL=0（1-code-runner.md）
- 锚级联八锚清单（findings.md；CD-12 行后有 S7 修正记录）

### Phase 2: Rule 46 条款 + SKILL 联动 + 模板引导 — complete
- commit e145555（3 files +16-4）
- S1 executor：条款 10 行；S2∥S3 并行组：SKILL 四处 + 模板双引导

### Phase 3: check-dispatch.sh 守卫豁免收窄 — complete
- commit 0c110c4（+47/-9）；守卫②任务书内容计数 + 守卫④tb 模式 markdown 口径
- fixture 三态×2 全过；dispatch 31/0 + fine-grain-steps 11/0

### Phase 4: selftest 守护 + 锚扩展 + 全量回归 — complete
- commit fc6caff（5 文件：dispatch-grain 新建 + registry 43 行 + RT-08/PT-08/CD-12 三锚宽容化）
- S7 暴露 CD-12 失配 → S6c 修复 → 终验 43/43 全绿 676/0

### fix-phase（Code Review Gate）: complete — APPROVED
- 初审 CHANGES_REQUESTED（1 BLOCKER：提取器全角标点盲区 + 2 SUGGESTION + 2 NIT）
- F1（共用提取函数 extract_subagent_state_refs + 序号 {1,2} 位限）+ F2（RT-08 逐匹配粒度 + 字面锚 + GR-10 全角 fixture）
- 复审 APPROVED：五项逐条销项、8 形态提取探测、自由 prompt 与 master 字节对比一致、21 次复跑全绿
- commit：fix-phase（3 files +55/-8）

### Phase 5: 合并回 + 部署 + 簿记 — 见 progress.md

---

## 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 2/3/4 全 S-unit 级子代理执行 + fix-phase F1/F2 + CR×2 + 终验回归） |
| 主进程直做 Phase 清单 | Phase 1（① git/worktree 编排 + 改派后基线由 executor 承担）、Phase 5（① git 编排 ② 计划系统文件/簿记） |
| 委派率 | 0.6 < 0.7 → WHITELIST-EXEMPT（直做理由均命中 Rule 25.3 白名单①②；S-unit 级委派率 100%——13 次派发全部单 S-unit 单目标，Rule 46 自示范） |

## 质量门控统计（Rule 26）

- Q1 伪造证据：无（全部产出主进程 Read/diff 复核，总数主进程独立求和）
- Q2 抽查：S7 后直跑 conclusion-discipline 复验；CR 复审独立复跑 7 套件×3 轮
- Q3 能力否定：无否定性结论收场
- Q4 未验证内容：CR notes 两条 LOW 观察已登记（裸相对引用形态属边缘，Rule 22.4a 绝对路径契约覆盖）
- Q5 降质行为：无
- Q6 错误学习：Error Log 3 条（CD-12 误判/provider 端点/git checkout 禁令）均带 Root Cause+Prevention
