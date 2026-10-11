# Verification Contract & Phase Gates

## Goal (1 sentence)

整理更新模板体系全部文件对齐最新规范（含验证独立性制度化），全部验证动作由全新独立子代理执行，worktree 隔离实施后合并回。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 模板修复后全量 42 selftest 回归 0 FAIL（独立子代理执行，逐脚本 rc 回报）
  Evidence: 验证一（worktree，subagent-state/5-executor.md+results.txt 42 行 rc=0）+ 终验回归（主仓 master 5a30382，subagent-state/8-executor.md 42 行 rc=0），双场 660/0 与基线一致，无基线漂移
- [x] VC-2: 模板声明形态统一 16/16 variant 含 template_type 注释
  Evidence: 验证二（subagent-state/6-executor.md）16 行 grep 逐项=1 且值与文件名匹配（无 -type 后缀）；主仓合并后复验 diagnostic-type.md 命中
- [x] VC-3: 独立子代理 alignment-review 对齐审查完成，CHANGES_REQUESTED 项全处置
  Evidence: 验证三（subagent-state/7-executor.md）：四要素全过，仅 P2×1（mapping:232 缺「表」字）→ 主进程白名单⑥ 一字接管处置并 commit（f75793f）
- [x] VC-4: 干净上下文实测通过
  Evidence: 验证二：mktemp 临时目录 init-session 6/6 建成 + 生成 task_plan.md:48「验证独立性」行命中（M-13-B 生效实证）+ check-template-type exit 0 + 临时目录清理确认
- [x] VC-5: worktree 合并回成功+部署对账结论明确+主仓 scope 无未提交变更
  Evidence: smart-merge-back V1-V6 全过 MERGED 5a30382；worktree/分支已清理；对账（subagent-state/9-executor.md）：claude/opencode 纯落后 23 文件可全量同步、zcode 落后 20+videop1 独立迭代 3 文件+独有 12 variant（部署待用户裁决）；主仓 porcelain 干净
- [x] VC-6: 修复清单逐项闭环+变更记录三要素
  Evidence: M-01~M-13 逐项落地（M-11 裁决不实施+理由登记 task_plan Decisions Made）；变更记录见下方

**终验规则**：6/6 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: 模板全量普查（只读）
**Done when**: [x] 六维普查+修复清单 v1（M-01~M-13）
**Verification**:
- [x] V-1.1: 清单逐项锚点+修法+性质+联动面（subagent-state/1-executor.md）
Status: `complete` Last verified: 2026-10-02

### Phase 2: 修复方案定稿与计划增补
**Done when**: [x] 三裁决（M-11 不镜像/M-12 补区块/M-13 双落点）+D6 核查无功能性删除
**Verification**:
- [x] V-2.1: Decisions Made 表三裁决行+Phase 3 三批次 S-unit 增补（计划重锁 e4e31534）
Status: `complete` Last verified: 2026-10-02

### Phase 3: worktree 隔离修复实施
**Done when**: [x] 三批次 23 文件 +333/-8+四点同步+worktree commit 干净
**Verification**:
- [x] V-3.1: 主进程抽验（M-01:249 新约定/M-06 注释/M-10 注脚/M-08 节标题字样/M-12 三行/mini-lite 零改动）全证实
- [x] V-3.2: TL 18/18+plan-tier 32/32 PASS（批次内自检+Phase 4 独立复验双覆盖）
Status: `complete` Last verified: 2026-10-02

### Phase 4: 独立子代理验证（用户 P0 — 全部全新会话）
**Done when**: [x] 五波独立验证全 PASS
**Verification**:
- [x] V-4.1: 验证一回归 660/0（sub:5）+ 验证二形态 16/16+干净上下文（sub:6）+ 验证三对齐审查（sub:7）——三个 fresh 会话 checkpoint
- [x] V-4.2: P2×1 处置 commit f75793f
Status: `complete` Last verified: 2026-10-02

### Phase 5: 合并回与终验簿记
**Done when**: [x] 合并 5a30382+清理+对账+终验回归 660/0
**Verification**:
- [x] V-5.1: 终验回归（sub:8 fresh）主仓 master 42/42 rc=0 无基线漂移
- [x] V-5.2: 部署对账（sub:9 fresh）三宿主结论+部署建议（待用户裁决）
Status: `complete` Last verified: 2026-10-02

---

## Evidence 抽查记录（主进程第一手复现）

| # | 抽验项 | 结果 |
|---|--------|------|
| 1 | M-01 task_plan.md:249 新约定串 | 证实（sed -n 249p） |
| 2 | M-06 diagnostic-type.md 头部注释行 | 证实（head -4） |
| 3 | M-10 writing-type.md:19 统一注脚 | 证实（grep 示例值） |
| 4 | M-08 bugfix-type.md:165 节标题逐字含「Subagent Handoff 登记表」 | 证实 |
| 5 | M-12 refactor-type.md 配置 3 行 | 证实（grep -c=3） |
| 6 | mini-lite-type.md 零改动 | 证实（porcelain 空） |
| 7 | 合并后主仓 template_type/验证独立性/16 variant/Handoff 四锚 | 证实（Read 复验） |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| v107 报告模板类结论 | Phase 1 六维逐项核实（M-01~M-10 对应 v107 R 系列/T 系列） | 符合 |
| Rule 34.2/38.3/44.1 | 四点同步全链落地+mini-lite 白名单零破坏（plan-tier 32/32）+三行配置 15 variant 补齐 | 符合 |
| 验证独立性裁决（9-26） | M-13 双落点制度化+本任务五波验证全部 fresh 子代理执行 | 符合 |
| check-template-type 白名单派生 | 16/16 声明值合法+干净上下文 gate exit 0 | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":5,"phases_delegated":1,"main_direct_count":4,"delegation_rate":0.200,"verdict":"ok","violations":[]}
```

- [x] 机器 verdict=ok、violations=[]；rate 0.2 系 Executor 混合字段解析面局限（Phase 3 三批次/Phase 4 五波实际全部 executor fresh 执行，主进程仅 worktree 生命周期①/簿记②/白名单⑥ 一字接管）——主进程直做面全部命中 Rule 25.3 白名单①②⑥ → **WHITELIST-EXEMPT 放行**（先例 v099-v107）
- [x] **验证独立性专项**：Phase 4 全部验证动作（回归×2/形态/干净上下文实测/对齐审查/部署对账）由 5 个全新独立子代理会话执行，主进程零自测替代验收（用户 P0 达成）

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 0 项（批次偏差披露 1 项=M-04 §一 回填 rule-enhancement 行，属数据对齐修正且验收口径达成），豁免 0，未处置 0
- [x] Evidence 抽查 ≥3 条：7 条全证实（上表）
- [x] 未处置违规：无 → 不降级

## Goal Gate (终验)

```
## Goal Verification — 模板体系整理更新+验证独立子代理化
- [x] VC-1: 双场 660/0（worktree+主仓） → PASS
- [x] VC-2: 16/16 声明形态 → PASS
- [x] VC-3: 对齐审查 P2×1 处置闭环 → PASS
- [x] VC-4: 干净上下文 6/6+独立性行生效 → PASS
- [x] VC-5: 合并 5a30382+对账结论+porcelain 干净 → PASS
- [x] VC-6: M-01~M-13 闭环+变更记录 → PASS

 outcome: COMPLETE
```

## 变更记录（42.6.3 三要素）

| 变更 | what | why | 验证 |
|------|------|-----|------|
| 23 文件模板体系修复（merge 5a30382） | 计数锚 16/22/25 口径全链统一+worktree 新约定 2 处+16/16 template_type 声明+9 Drift Log+15 Handoff 节+15 配置 3 行+🧰 区块+验证独立性双落点+T-1 示例注脚 | v107 审查结论 M-01~M-13+用户「模板对齐最新规范+验证独立子代理化」指令 | 五波独立子代理验证（回归 660/0×2/形态/干净上下文/对齐审查） |
| mapping §一 补 rule-enhancement 行 | §一 13→16 与 variant/ 实测对齐（原清单漏列） | 数据对齐修正（批次二偏差披露） | §一 grep=16+TL 18/18 |

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 全 Phase complete，终验 COMPLETE |
| 2 | Where am I going? | 簿记 commit 后交付；部署同步待用户裁决 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
