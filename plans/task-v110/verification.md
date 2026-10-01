# Verification Contract & Phase Gates

## Goal (1 sentence)

将用户 2026-10-02「子代理可并行，前提互不影响互不依赖」裁决沉淀为 Rule 21.4 演进规范（并行默认+独立性四问守门），守卫适配+级联+并行实测+memory 演进记录，全部验证由独立子代理执行。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 修订后全量 selftest 回归 0 FAIL（独立子代理）
  Evidence: worktree 回归（sub:4，41/42→knowledge-brief T6 窗口漏网已修）+主仓终验复验（dispatch 31/31+knowledge-brief 16/16+tier-b 18/18 合并后实测）
- [x] VC-2: Rule 21.4 新语义全库一致
  Evidence: 「至多 1 个活跃子代理」全库零残留；「只读分槽豁免（[task-v094 T-B1]」逐字保留（tier-b 18/18）；25 处引用面级联（批次一 10 文件）+对齐审查 APPROVED（P0/P1=0）
- [x] VC-3: 并行行为实测——真并行成立
  Evidence: 同消息双派发（声明 parallel_groups+组标记）：组 A 时间线 1790893626-640 ∩ 组 C 3633-662 **交叠 7s**；产出正确互不干扰（A=17 variant/Rule 语义 ✓；C=INDEX 三任务 complete ✓）
- [x] VC-4: 串行保留场景仍被约束（守卫双态实测）
  Evidence: 无标记双派发实 **战拦截**（串行槽 age=0s<120s，组 A 被拦组 B 完成）+TS-08 断言（无标记 rc=2 拦截）+TS-07（组标记放行）——「拦截-放行」完整证据链
- [x] VC-5: worktree 合并回+对账+porcelain 干净
  Evidence: V5 拦截→worktree merge master 预案→MERGED e0527b6；worktree/分支清理；主仓复验（Rule :144 新语义+parallel_groups 6 处+dispatch 31/31）；部署对账（sub:10 三宿主 13/13 落后，zcode 累积 31 文件积压待裁决）；porcelain 干净
- [x] VC-6: 对齐审查通过+memory 演进记录（三要素）
  Evidence: sub:8 对齐审查 APPROVED；serial-dispatch-iron-rule.md 演进链三段（09-12→09-28→10-02）+验证锚（critical-rules:144）+失效条件+边界披露（宪法 §一未同步）；MEMORY.md 索引行同步更新

**终验规则**：6/6 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: 影响面普查
**Done when**: [x] 五维普查（21.4 十成分拆解/25 处引用面/守卫解剖/断言锚/三件套方案）
**Verification**:
- [x] V-1.1: 硬锚抽查（critical-rules grep 21.4=7+:144 全文）证实
Status: `complete` Last verified: 2026-10-02

### Phase 2: 规范修订与守卫适配
**Done when**: [x] 批次一 Rule 重写+10 文件级联；批次二守卫+12/-4+TS-07/08 断言
**Verification**:
- [x] V-2.1: 旧措辞零残留+tier-b 全角锚保留（偏差披露：草案半角→实测全角已修）+三 selftest 全 PASS
Status: `complete` Last verified: 2026-10-02

### Phase 3: 独立验证（fresh，含并行实测）
**Done when**: [x] 回归（抓 T6 窗口漏网已修）+双态并行实测+对齐审查 APPROVED
**Verification**:
- [x] V-3.1: 四份 fresh checkpoint（sub:4/5/6/7/8）——「无标记拦截+有标记放行」双态+时间线交叠
Status: `complete` Last verified: 2026-10-02

### Phase 4: 合并回与终验簿记
**Done when**: [x] MERGED e0527b6+对账+memory 演进+簿记
**Verification**:
- [x] V-5.1: 主仓复验三项（Rule 语义/守卫/回归）全过
Status: `complete` Last verified: 2026-10-02

---

## Evidence 抽查记录（主进程第一手复现）

| # | 抽验项 | 结果 |
|---|--------|------|
| 1 | 普查硬锚（critical-rules 21.4 grep=7+:144 全文在位） | 证实 |
| 2 | 守卫实战拦截（组 A 无标记被拦，返回原文） | 证实 |
| 3 | 并行时间线交叠（A:626-640 ∩ C:633-662） | 证实（双 checkpoint date +%s） |
| 4 | knowledge-brief T6 窗口漏网（22.4 行号 161>160） | 证实并修正（160→200） |
| 5 | 主仓 Rule :144 新语义+parallel_groups 6 处 | 证实 |
| 6 | memory 演进记录+索引行更新 | 证实（Read/grep） |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 用户裁决链三代 | Rule 21.4 新文本演进链标注+memory 三段记录 | 符合 |
| Rule 21.4 现行全文+只读豁免 | 保留成分逐项落地（验收纪律/兜底链/T-B1 锚） | 符合 |
| 「21.4」引用面 | 25 处普查→批次一级联+VC-2 全库复验 | 符合 |
| Rule 23 安全网 | 未改动（并行化的既有冲突检测面保留） | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":4,"phases_delegated":3,"delegation_rate":0.750,"verdict":"ok","violations":[]}
```

- [x] verdict=ok violations=0；rate 0.75 ≥ floor 0.7；主进程直做=Phase 4（① git+② 簿记+③ 记忆职责面）全白名单；验证独立性：七波 fresh 子代理（sub:1/2/3/4/5/6/7/8/10——含双代理并行实测）

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 1 项（T6 窗口漏网——回归抓出已修）；豁免 0；未处置 0
- [x] Evidence 抽查 ≥3 条：6 条全证实
- [x] 未处置违规：无 → 不降级

## Goal Gate (终验)

```
## Goal Verification — Rule 21.4 并行调度演进
- [x] VC-1: 回归全绿（worktree+主仓） → PASS
- [x] VC-2: 新语义全库一致（零残留+APPROVED） → PASS
- [x] VC-3: 真并行实证（时间线交叠 7s） → PASS
- [x] VC-4: 串行保留双态实测（拦截+TS-08） → PASS
- [x] VC-5: 合并 e0527b6+对账+porcelain 干净 → PASS
- [x] VC-6: 对齐 APPROVED+memory 演进三要素 → PASS

 outcome: COMPLETE
```

## 变更记录（42.6.3 三要素）

| 变更 | what | why | 验证 |
|------|------|-----|------|
| Rule 21.4 演进（merge e0527b6） | 「串行铁律」→「子代理调度铁律：并行默认允许+独立性四问守门+声明制（parallel_groups/[parallel-group:]）+串行保留 5 场景」；演进链三代标注 | 用户 10-02 裁决（原话入 Rule） | 对齐审查 APPROVED+全库 grep 零残留 |
| check-dispatch 并行组放行（+12/-4） | serial_slot_check 第⑤参组标记分支；无标记路径零变化 | 新机制机器承载 | TS-07/08 双态断言+实战拦截-放行 |
| 13 文件级联+selftest 断言 | 「21.4」引用面新语义+T6 窗口放宽+TS-07/08 | Rule 34.2 级联纪律 | 双场回归全绿 |
| memory 演进记录 | serial-dispatch-iron-rule 三段演进链+现行 How to apply+宪法未同步边界 | 裁决沉淀防旧记忆误导（v109 机制首次消费） | 主进程 Read 复核 |

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 全 Phase complete，终验 COMPLETE |
| 2 | Where am I going? | 交付；部署同步（v108-v110 三批积压）待用户裁决 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md（行号窗口锚新变种/守卫双态实证法） |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
