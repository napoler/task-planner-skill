# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

为 markdown 多次编辑高频出错建跨项目工具级防护：结构化 edit-ops JSON 编辑指令单 + 校验/原子应用/回读验证/回滚脚本 + 技能接线，使编辑错误被机制性拦截/检测/回滚

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面——模板必须预置该行（缺失验证区块判例 task-tpl-verify-fix-20261113）。

- [ ] VC-1: P2 方案裁决入口齐备，四候选方向（高级工具/JSON中间件/编辑脚本/有效工具或引入已有工具）逐项评估且推荐项明确标注 `(Recommended)` 含取舍理由
  Evidence: `task_plan.md` Phase 2 裁决矩阵与 Decisions/Key Questions
  **Verify command**: grep -n "候选方向" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "(Recommended)" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md
- [ ] VC-2: 设计覆盖四类失败模式并给出机制性对策：edit-ops JSON 指令单 + 预校验 + 原子应用(全过才写) + 回读验证 + 备份回滚
  Evidence: `task_plan.md` 根源覆盖表、Phase 3 S-unit 与 VC 映射
  **Verify command**: grep -n "原子应用" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "预校验" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "回读验证" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "回滚" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md
- [ ] VC-3: 跨项目落地路径明确：技能接线点与多环境部署（zcode/claude/cursor/agents）在 P4/P6 与知识底座中可追踪
  Evidence: `task_plan.md` Scope/Phase 4/6、`knowledge-brief.md` §1/§3/§5
  **Verify command**: grep -n "zcode" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "cursor" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "agents" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md
- [ ] VC-4: Phase 1-6 全部声明 `**Executor:**`；派发型 Phase 附 S-unit 表且数据行含执行体/输入摘要/验收/≤15min 预估
  Evidence: `task_plan.md` Phases 与 S-unit 表
  **Verify command**: test "$(grep -c "^- \*\*Executor:\*\*" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md)" -ge 6 && grep -n "^| S[0-9]" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md
- [ ] VC-5: verification.md 为各 VC 提供 V-N 验证段且每段含行首 `**Verify command**:` 可执行命令
  Evidence: 本文件 V-1..V-6 段
  **Verify command**: test "$(grep -cE "^  \*\*Verify command\*\*:" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/verification.md)" -ge 6
- [ ] VC-6: R 锚与知识底座落盘完整：R1 逐字锚 user-session-log.md #1；findings.md 含四失败模式+Rule 106/106.1a+markdown-editor 摘要；knowledge-brief.md §2/§3 含架构/部署位族/Rule 106/markdown-editor 事实
  Evidence: `user-session-log.md`, `findings.md`, `knowledge-brief.md`
  **Verify command**: grep -n "锚点失配" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/findings.md && grep -n "吞块" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/findings.md && grep -n "静默失配" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/findings.md && grep -n "106.1a" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/knowledge-brief.md && grep -n "markdown-editor" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/knowledge-brief.md

---

## Phase Gates

### V-1 (VC-1): 四候选方向裁决入口与推荐项
**Goal**: P2 方案裁决可审计，四方向齐备且推荐项明确。
**Depends on**: P1 调研证据回填
**Done when**:
- [ ] task_plan.md P2 含四候选方向评估与 `(Recommended)` 标注
**Verification** (run before moving on):
- [ ] V-1.1: 候选方向与推荐项在位
  **Verify command**: grep -n "候选方向" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "(Recommended)" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md
- [ ] V-1.2: R2-R5 映射可追溯
  **Verify command**: grep -n "R2" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "R5" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md

Status: `pending` Last verified: —

### V-2 (VC-2): 四失败模式机制性对策设计
**Goal**: edit-ops 链路覆盖预校验/原子应用/回读验证/回滚。
**Depends on**: P2 设计定稿
**Done when**:
- [ ] task_plan.md 明确四失败模式对策与 P3 实现链路
**Verification**:
- [ ] V-2.1: 关键机制关键词齐备
  **Verify command**: grep -n "原子应用" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "预校验" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md
- [ ] V-2.2: 回读与回滚机制齐备
  **Verify command**: grep -n "回读验证" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "回滚" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md

Status: `pending` Last verified: —

### V-3 (VC-3): 跨项目技能接线与部署路径
**Goal**: 接线点与 zcode/claude/cursor/agents 部署路径可执行可追踪。
**Depends on**: P4/P6 产出
**Done when**:
- [ ] task_plan.md/knowledge-brief.md 记录接线与部署位族
**Verification**:
- [ ] V-3.1: 部署位族关键词在计划中可检索
  **Verify command**: grep -n "zcode" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "cursor" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "agents" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md
- [ ] V-3.2: 知识底座记录接线/部署事实
  **Verify command**: grep -n "部署位族" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/knowledge-brief.md && grep -n "P6" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/knowledge-brief.md

Status: `pending` Last verified: —

### V-4 (VC-4): Phase Executor 与 S-unit 结构完整
**Goal**: 计划可派发、可校验（Executor + S-unit 具备执行契约）。
**Depends on**: 计划定稿
**Done when**:
- [ ] 六个 Phase 均有 Executor；派发型 Phase 有 S-unit 数据行
**Verification**:
- [ ] V-4.1: Executor 字段数量满足 6
  **Verify command**: test "$(grep -c "^\*\*Executor:\*\*" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md)" -ge 6
- [ ] V-4.2: 存在 S-unit 数据行
  **Verify command**: grep -n "^| S[0-9]" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md

Status: `pending` Last verified: —

### V-5 (VC-5): verification.md 可执行验证命令齐备
**Goal**: 每个 VC 对应 V-N 段均有行首 Verify command 可执行。
**Depends on**: verification.md 填充完成
**Done when**:
- [ ] V-1..V-6 段均含 `**Verify command**:` 行
**Verification**:
- [ ] V-5.1: Verify command 行数 >= 6
  **Verify command**: test "$(grep -c "^\*\*Verify command\*\*:" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/verification.md)" -ge 6
- [ ] V-5.2: 每段命令引用本计划产物路径
  **Verify command**: grep -n "/mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/verification.md

Status: `pending` Last verified: —

### V-6 (VC-6): R 锚与知识底座证据落盘
**Goal**: 需求原文锚、失败模式、Rule 106/markdown-editor 事实在计划文件中可追溯。
**Depends on**: findings/knowledge-brief 填充完成
**Done when**:
- [ ] R1 逐字锚在 user-session-log.md #1；findings/knowledge-brief 含必备事实
**Verification**:
- [ ] V-6.1: findings 含四失败模式关键词
  **Verify command**: grep -n "锚点失配" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/findings.md && grep -n "吞块" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/findings.md && grep -n "静默失配" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/findings.md
- [ ] V-6.2: knowledge-brief 含 Rule 106/markdown-editor 事实
  **Verify command**: grep -n "106.1a" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/knowledge-brief.md && grep -n "markdown-editor" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/knowledge-brief.md

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| Rule 106/106.1a 纪律现状 | findings.md/knowledge-brief.md 引用与 P3/P4 设计对齐 | 待终验 |
| markdown-editor 现状 | findings.md 摘要与 P2/P4 复用裁决对齐 | 待终验 |
| P1 外部调研证据 | findings.md Research Findings 外部对标段含 URL/对比 | 待终验 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116
```

JSON 输出：
```json
{粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付,须按 violations 清单回炉补 plan 或转 PARTIAL 重跑

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 为 markdown 多次编辑高频出错建跨项目工具级防护：结构化 edit-ops JSON 编辑指令单 + 校验/原子应用/回读验证/回滚脚本 + 技能接线，使编辑错误被机制性拦截/检测/回滚
对照 Verification Contract 逐条复验：
- [ ] VC-1: {evidence} → PASS/FAIL
- [ ] VC-2: {evidence} → PASS/FAIL
- [ ] VC-3: {evidence} → PASS/FAIL
- [ ] VC-4: {evidence} → PASS/FAIL
- [ ] VC-5: {evidence} → PASS/FAIL
- [ ] VC-6: {evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

---

## 交叉验证记录（Rule 108）
<!-- 触发面见 critical-rules-verification.md 108.1（L2+/≥2受管文件/子代理验证产出采信前/用户明确要求）；mini/L0 豁免。未触发登记：`未触发（原因）`；触发但单路径=FAIL。 -->

| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| 计划期 5 文件填充完整性 | `grep -n "^\*\*Executor:\*\*" task_plan.md` / `grep -n "^\*\*Verify command\*\*:" verification.md` | 主进程回读+需求对照（本次交付） | 待执行期复检时登记 |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 计划期完成，Phase 1 待启动 |
| 2 | Where am I going? | Phase 1-6（调研→裁决→实现→接线→验证→部署） |
| 3 | What's the goal? | 为 markdown 多次编辑高频出错建跨项目工具级防护：结构化 edit-ops JSON 编辑指令单 + 校验/原子应用/回读验证/回滚脚本 + 技能接线，使编辑错误被机制性拦截/检测/回滚 |
| 4 | What have I learned? | 见 findings.md 与 knowledge-brief.md |
| 5 | What have I done? | 5 份计划文档实质填充完成，VC/V-N/Executor/S-unit/四方向裁决入口已落盘 |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（如需登记） |
