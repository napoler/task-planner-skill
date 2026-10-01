# Verification Contract & Phase Gates

## Goal (1 sentence)

创建 templates/delivery-summary.md 五要素交付总结模板（说明/产出/审查/风险/下一步）并规范终验交付流程，模板自证样例达标，全部验证由独立子代理执行。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 修订后全量 selftest 回归 0 FAIL（独立子代理）
  Evidence: worktree 回归（sub:3，42 行逐项；skill-split T-主 442 定数漏网抓出→修正 commit a3730c9→41/41）+sub:4 重跑三 selftest（TL 21/21+knowledge-brief 16/16+skill-split 41/41）
- [x] VC-2: 模板落地+终验段指针+口径一致
  Evidence: delivery-summary.md 46 行五区块（TL-19）+SKILL :158 指针+:316 References（TL-20，grep delivery-summary=2）+template-guide:64 口径句（TL-21）；既有锚零破坏
- [x] VC-3: 模板自证：fresh 子代理按新模板产出 task-v112 真实交付总结样例
  Evidence: plans/task-v112/delivery-summary-sample.md（五区块 grep=5；基于真实产出含回归失败根因/commit 锚/诚实标注 Phase 4 未执行项；主进程抽验头 25 行确认达「用户可独立决策」标准）
- [x] VC-4: 对齐审查通过（独立子代理）
  Evidence: sub:4 四要素全过+锚三重跑佐证（无 P0/P1 登记）
- [x] VC-5: worktree 合并回+对账结论+porcelain 干净
  Evidence: V5 拦截→预案处置→MERGED 20b1930；worktree/分支清理；主仓复验（delivery-summary grep=2+TL 21/21）；部署对账待派（三宿主积压状态延续 v108-v111，随交付报告呈报）
- [x] VC-6: memory feedback 条目（三要素）+变更记录
  Evidence: delivery-summary-template.md（裁决原话+划界+验证锚+失效条件）+MEMORY.md 索引行（60→61 行，11.9KB 量级维持）

**终验规则**：6/6 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: 交付面普查+模板草案
**Done when**: [x] 三部分（现状/草案/级联清单）+模板位置裁决（templates/ 根）
**Verification**:
- [x] V-1.1: 五要素缺漏实证（风险/下一步常缺）+check-template-type 白名单影响评估
Status: `complete` Last verified: 2026-10-02

### Phase 2: 模板创建与终验段级联
**Done when**: [x] 模板 46 行+SKILL 两处+口径句+TL-19/20/21
**Verification**:
- [x] V-2.1: TL 21/21+knowledge-brief 16/16（既有锚零破坏）
Status: `complete` Last verified: 2026-10-02

### Phase 3: 独立验证（含模板自证）
**Done when**: [x] 回归（抓 T-主 定数漏网已修）+自证样例达标+对齐通过
**Verification**:
- [x] V-3.1: 主进程抽验样例头 25 行（五区块/诚实标注/可独立决策）
Status: `complete` Last verified: 2026-10-02

### Phase 4: 合并回与终验簿记
**Done when**: [x] MERGED 20b1930+清理+memory+簿记；交付报告按新模板输出（首证）
**Verification**:
- [x] V-5.1: 主仓复验两项全过
Status: `complete` Last verified: 2026-10-02

---

## Evidence 抽查记录（主进程第一手复现）

| # | 抽验项 | 结果 |
|---|--------|------|
| 1 | 模板五区块齐备（TL-19） | 证实 |
| 2 | SKILL 双指针（TL-20 grep=2） | 证实 |
| 3 | T-主 定数漏网（442→444） | 证实并修正 |
| 4 | 自证样例五区块+诚实标注 | 证实（Read 头 25 行） |
| 5 | 合并后主仓 TL 21/21 | 证实 |
| 6 | memory 条目+索引行 | 证实 |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 用户裁决五要素原话 | 模板五区块一一对应+memory 原话存档 | 符合 |
| SKILL 终验段现状 | 指针插入 :158（普查定位） | 符合 |
| 机器面/用户面划界 | 模板数据源指针引用 verification 不重写 | 符合 |
| 级联先例 | TL 断言同批落地（v111 F-1 教训前置规避） | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":4,"phases_delegated":3,"delegation_rate":0.750,"verdict":"ok","violations":[]}
```

- [x] verdict=ok；主进程直做=Phase 4（① git+② 簿记+③ memory）+少量 ⑥ 机械修正，全白名单；验证独立性：五波 fresh 子代理（sub:1/2/3/4+对账待派合并后）——部署对账随交付报告披露

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 1 项（T-主 定数漏网——回归抓出已修）；豁免 0；未处置 0
- [x] Evidence 抽查：6 条全证实
- [x] 未处置违规：无 → 不降级

## Goal Gate (终验)

```
## Goal Verification — 交付总结模板五要素
- [x] VC-1: 回归全绿（含漏网修正复验） → PASS
- [x] VC-2: 模板+指针+口径一致 → PASS
- [x] VC-3: 自证样例达标 → PASS
- [x] VC-4: 对齐审查通过 → PASS
- [x] VC-5: 合并 20b1930+porcelain 干净 → PASS
- [x] VC-6: memory 三要素+变更记录 → PASS

 outcome: COMPLETE
```

## 变更记录（42.6.3 三要素）

| 变更 | what | why | 验证 |
|------|------|-----|------|
| 新增 delivery-summary.md 46 行（merge 20b1930） | 五要素用户面交付总结模板+数据源指针+详略标准 | 用户 10-02 裁决（交付总结结构化强制） | TL-19+自证样例实证 |
| SKILL 终验段指针+References 行+口径句 | 终验交付时消费模板的规范承载 | 流程绑定（非可选） | TL-20/21+grep=2 |
| TL-19/20/21+T-主 定数级联 | 模板存在/双指针/行数 444 | 机器承载+级联纪律 | 回归 42/42 等效全绿 |
| memory feedback 条目 | 五要素规范+划界+验证锚 | 裁决沉淀 | 主进程 Read 复核 |

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 全 Phase complete，终验 COMPLETE |
| 2 | Where am I going? | 交付（按新模板输出首证）；部署同步待用户裁决 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md（行数定数同族第 2 次/样例自证法） |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
