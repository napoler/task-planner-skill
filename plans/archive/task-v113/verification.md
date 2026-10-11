# Verification Contract & Phase Gates

## Goal (1 sentence)

将用户问题解决灵活性裁决沉淀为 Rule 22.3.0 资料先行档+22.3.0b 换道义务（反死循环）+41.1 扩档，推演自证实证新链改变决策路径，全部验证由独立子代理执行。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 修订后全量 selftest 回归 0 FAIL（独立子代理）
  Evidence: worktree 回归（sub:3，42/42 rc=0，666 PASS=基线 660+SR-13 新增 6；fallback 31/31+rescue 11/11+self-resolution 13/13+skill-collab 25/25 验收锚全绿）
- [x] VC-2: 新链语义落地且全库一致
  Evidence: 22.3.0/22.3.0b 落地（critical-rules:159-160，grep 22.3.0=9）+41.1⑤ 扩档引用+级联 14 项（5 文件 +29/-17）；「五档→六档」演进口径三处一致（对齐审查核）
- [x] VC-3: 语义推演自证——新链提供实质决策差异
  Evidence: sub:4 两案例推演：案例二（守卫连续误拦）**HIGH 差异**——22.3.0b 第 2 次失败强制换道，换道评估序①=读守卫源码+dispatch-examples 方案集（O(1) 权威对齐）替代实际发生的 O(n) 试错；案例一 MEDIUM（provider 面 22.3.1 部分覆盖，资料档仍补 ④ 前评估）
- [x] VC-4: 对齐审查通过（独立子代理）
  Evidence: sub:4 四要素 APPROVED（P0/P1=0，P2×1=CD-13 注释旧措辞登记后续顺手）
- [x] VC-5: worktree 合并回+对账+porcelain 干净
  Evidence: V5 拦截→预案→MERGED 7e82231；清理；主仓复验（grep 22.3.0=9+self-resolution 13/13）；部署对账随交付呈报（四批+本轮=五批积压延续）
- [x] VC-6: memory feedback 条目（三要素）+变更记录
  Evidence: flexible-problem-solving-2230.md（裁决原话+How to apply+验证锚+失效条件）+MEMORY.md 索引行（62 行 14.1KB）

**终验规则**：6/6 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: 消解链普查+方案
**Done when**: [x] 四部分（链拆解/引用面 13 文件/宪法落差确认/方案三件=22.3.0 前置零冲突+22.3.0b+级联 14 项）
**Verification**:
- [x] V-1.1: skill-collab T4 实证 22.3.0 无既有断言（前置方案零冲突依据）
Status: `complete` Last verified: 2026-10-02

### Phase 2: 扩档修订与级联
**Done when**: [x] 22.3.0/22.3.0b+41.1⑤+级联 14 项（5 文件 +29/-17）+四 selftest 全绿
**Verification**:
- [x] V-2.1: 偏差披露 2 处（SR-11 基线 pre-existing 正则修复+SKILL 444 满额演进注净 0 行）
Status: `complete` Last verified: 2026-10-02

### Phase 3: 独立验证（含推演自证）
**Done when**: [x] 回归 42/42（666 PASS）+推演实证（案例二 HIGH）+对齐 APPROVED
**Verification**:
- [x] V-3.1: 推演合格标准达成（案例二实质决策差异=O(1) 对齐替代 O(n) 试错）
Status: `complete` Last verified: 2026-10-02

### Phase 4: 合并回与终验簿记
**Done when**: [x] MERGED 7e82231+清理+memory+簿记
**Verification**:
- [x] V-5.1: 主仓复验（grep 22.3.0=9+self-resolution 13/13）全过
Status: `complete` Last verified: 2026-10-02

---

## Evidence 抽查记录（主进程第一手复现）

| # | 抽验项 | 结果 |
|---|--------|------|
| 1 | 普查硬锚（fallback T10a 全序断言/selftest-skill-collab T4） | 证实 |
| 2 | 22.3.0/22.3.0b 落地（grep=9+:159-160 原文） | 证实 |
| 3 | 回归 666 PASS（含 SR-13 新增） | 证实 |
| 4 | 推演案例二决策差异（换道评估序①=读源码） | 证实 |
| 5 | 合并后主仓 grep+self-resolution | 证实 |
| 6 | memory 条目+索引行 | 证实 |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 用户裁决原话 | 22.3.0/22.3.0b 条款语义一一对应+memory 原话存档 | 符合 |
| Rule 22.3/41.1 现行链 | 前置插入零冲突（既有档位编号不动） | 符合 |
| 宪法 §七落差 | 22.3.0 声明为「宪法 §七 执行层落点」 | 符合（弥合） |
| 级联先例 | 引用面 14 项清单驱动+全库复验 | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":4,"phases_delegated":3,"delegation_rate":0.750,"verdict":"ok","violations":[]}
```

- [x] verdict=ok；主进程直做=Phase 4（① git+② 簿记+③ memory）全白名单；验证独立性：四波 fresh 子代理（sub:1/2/3/4）

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 0 项（偏差披露 2 处均合理处置）；豁免 0；未处置 0
- [x] Evidence 抽查：6 条全证实
- [x] 未处置违规：无 → 不降级

## Goal Gate (终验)

```
## Goal Verification — 问题解决灵活性规范
- [x] VC-1: 回归全绿 666 PASS → PASS
- [x] VC-2: 新链落地+全库一致 → PASS
- [x] VC-3: 推演实证决策差异（案例二 HIGH） → PASS
- [x] VC-4: 对齐 APPROVED → PASS
- [x] VC-5: 合并 7e82231+porcelain 干净 → PASS
- [x] VC-6: memory 三要素 → PASS

 outcome: COMPLETE
```

## 变更记录（42.6.3 三要素）

| 变更 | what | why | 验证 |
|------|------|-----|------|
| Rule 22.3.0 资料先行档+22.3.0b 换道义务（merge 7e82231） | 失败后先查官方文档/网络现成方案；≥2 次同法强制换道（评估序=现成方案→子代理→拆解）；3 次禁第 4 次同法 | 用户 10-02 灵活性裁决；弥合宪法 §七执行层落差 | 推演实证（案例二 HIGH）+四 selftest 全绿 |
| 41.1⑤/SKILL/templates/dispatch-examples 级联 | 消解链与派发契约同步资料档引用 | 引用面一致 | 全库 grep+对齐 APPROVED |
| SR-13 断言+selftest-self-resolution 扩展 | 新链静态守护 | 机器承载 | 13/13 |
| memory feedback 条目 | 裁决原话+How to apply+验证锚 | 裁决沉淀 | 主进程 Read 复核 |

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 全 Phase complete，终验 COMPLETE |
| 2 | Where am I going? | 交付；部署同步（五批积压）待用户裁决 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md（宪法-执行层落差模式/推演自证法） |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
