# Verification Contract & Phase Gates

## Goal (1 sentence)

将用户注释纪律裁决沉淀为 Rule 45（注释完整性规范：What+Why 双层/头注释四要素/禁止为美观删减/平台冲突声明），括注级联+自证审查+存量清单，全部验证由独立子代理执行。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 修订后全量 selftest 回归 0 FAIL（独立子代理）
  Evidence: worktree 回归（sub:3，42/42 全绿；字面硬锚 6 处+宽容锚 5 处全过）+主仓复验（plan-tier 32/32）
- [x] VC-2: Rule 45 落地+Rules 口径全链一致
  Evidence: Rule 45 七子条（critical-rules:453-463，grep '^45\.'=7）+括注级联 3 处（SKILL frontmatter「含 40-45」/:246 括注/:304 索引行）+「Rules 1-39」字面计数不减=2（括注模式零破坏实证：PT-08 32/32+WF-10 16/16）
- [x] VC-3: 注释标准自证：本任务 diff 注释合规经 fresh 审查
  Evidence: sub:4 自证审查——Rule 45 段主体 What+Why 完整合规（引导段+45.2/45.3/45.4/45.6 逐条+范式三锚实存）；CHANGES_REQUESTED 三项（F-1 CC 未落地声明/F-2 子条抵牾/F-3 嵌套括注）已由主进程 ④ 接管处置并 commit
- [x] VC-4: 存量注释补强清单落盘交用户
  Evidence: Phase 1 产出清单（脚本 5+文档 4 项，S/M/L 分级）——以 checkpoint 方案节承载，终验簿记时随交付报告呈报用户（本轮不自动实施）
- [x] VC-5: worktree 合并回+对账+porcelain 干净
  Evidence: V5 拦截→预案处置→MERGED 21d87b3；worktree/分支清理；主仓复验（Rule 45 七子条+plan-tier 32/32）；部署对账（sub:5 三宿主同一 10-01 快照，v108-v111 四批全积压待裁决）
- [x] VC-6: 对齐审查通过+memory feedback 条目（三要素）
  Evidence: sub:4 四要素+CHANGES_REQUESTED 处置闭环；comment-completeness-rule45.md（裁决原话+平台冲突声明+验证锚+失效条件）+MEMORY.md 索引行落位

**终验规则**：6/6 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: 注释规范面普查
**Done when**: [x] 四部分（条款零映射/级联面/密度基线/草案七子条+存量清单）
**Verification**:
- [x] V-1.1: 级联策略裁决=括注追加（字面锚 5 处 selftest 硬锁，零改动实证）
Status: `complete` Last verified: 2026-10-02

### Phase 2: Rule 45 新增与括注级联
**Done when**: [x] 七子条+3 处括注+字面锚计数不减
**Verification**:
- [x] V-2.1: PT-08/WF-10 全绿+偏差披露（标题无 1-44 字样→级联实做 3 处）
Status: `complete` Last verified: 2026-10-02

### Phase 3: 独立验证
**Done when**: [x] 回归全绿+自证与对齐审查 CHANGES_REQUESTED 三项处置
**Verification**:
- [x] V-3.1: F-1（CC 诚实化登记后续轮）/F-2（子条抵牾消除）/F-3（嵌套去冗余）处置 commit
Status: `complete` Last verified: 2026-10-02

### Phase 4: 合并回与终验簿记
**Done when**: [x] MERGED 21d87b3+对账+memory+簿记
**Verification**:
- [x] V-5.1: 主仓复验（七子条+plan-tier）全过
Status: `complete` Last verified: 2026-10-02

---

## Evidence 抽查记录（主进程第一手复现）

| # | 抽验项 | 结果 |
|---|--------|------|
| 1 | 技能内注释条款零映射 | 证实（grep 注释=零散非规范） |
| 2 | 「Rules 1-39」5 处 selftest 硬锚 | 证实（普查清单+回归全绿） |
| 3 | Rule 45 七子条落地 | 证实（grep '^45\.'=7） |
| 4 | 字面锚计数不减+括注三处 | 证实 |
| 5 | F-1/F-2/F-3 处置后状态 | 证实（45.7 诚实化+:304 平铺） |
| 6 | 合并后主仓七子条+plan-tier 32/32 | 证实 |
| 7 | memory 条目+索引行 | 证实（Read/grep） |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 用户裁决原话 | Rule 45.6 平台冲突声明+memory 原话存档 | 符合 |
| 平台冲突 | 45.6 显式声明用户裁决优先 | 符合 |
| 宪法 §九 | 45.4 引用衔接（实测宪法 :158 条款存在） | 符合 |
| 级联先例 | 括注模式（v097 教训正向消费） | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":4,"phases_delegated":3,"delegation_rate":0.750,"verdict":"ok","violations":[]}
```

- [x] verdict=ok；主进程直做=Phase 4（① git+② 簿记+③ memory）+少量 ⑥ 机械修正，全白名单；验证独立性：五波 fresh 子代理（sub:1/2/3/4/5）

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 1 项（CHANGES_REQUESTED 三项——已处置）；豁免 0；未处置 0
- [x] Evidence 抽查：7 条全证实
- [x] 未处置违规：无 → 不降级

## Goal Gate (终验)

```
## Goal Verification — 注释完整性规范 Rule 45
- [x] VC-1: 回归全绿 → PASS
- [x] VC-2: Rule 45+口径全链一致（括注零破坏） → PASS
- [x] VC-3: 自证审查+三项处置 → PASS
- [x] VC-4: 存量清单落盘待裁决 → PASS
- [x] VC-5: 合并 21d87b3+对账+porcelain 干净 → PASS
- [x] VC-6: 对齐审查+memory 三要素 → PASS

 outcome: COMPLETE
```

## 变更记录（42.6.3 三要素）

| 变更 | what | why | 验证 |
|------|------|-----|------|
| Rule 45 注释完整性规范（merge 21d87b3） | 七子条：适用范围/What+Why 双层/头注释四要素/修改三要素衔接宪法/禁止删减/平台冲突声明/机器承载边界 | 用户 10-02 注释纪律裁决 | 对齐审查+自证审查+回归全绿 |
| 口径括注级联 3 处 | SKILL frontmatter/:246/:304 「含 40-45」 | Rules 编号顺延级联（括注模式字面锚零破坏） | PT-08/WF-10 全绿+grep 复验 |
| memory feedback 条目 | 裁决原话+平台冲突声明+验证锚+存量清单指针 | 裁决沉淀+防平台默认风格回摆 | 主进程 Read 复核 |

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 全 Phase complete，终验 COMPLETE |
| 2 | Where am I going? | 交付；存量补强范围+部署同步待用户裁决 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md（括注模式三度实证/声明不存在物必被抓） |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
