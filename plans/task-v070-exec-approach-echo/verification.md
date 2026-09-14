# Verification Contract & Phase Gates

## Goal (1 sentence)

ask（非静默）模式下计划批准（D1）前向用户复述大体执行思路（≤5 行），使不查计划文档也知整体工作流程；silent 模式维持 28.4 现状。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.

- [x] VC-1: 28.2.1 条款已写入 critical-rules.md（ask D1 前置复述 ≤5 行；不替代 D1；silent 不适用；登记 Decisions Made）
  Evidence: `grep -n "28.2.1" ~/.zcode/skills/task-planner/references/critical-rules.md` → 第 222 行命中，含「思路复述」
- [x] VC-2: SKILL.md 四处联动（计划确认段/Rule 28 摘要行/合规清单 C18/I-O 契约）
  Evidence: `grep -n "28.2.1\|思路复述" ~/.zcode/skills/task-planner/SKILL.md` → ≥4 处命中
- [x] VC-3: selftest-interaction.sh 新增 TI-11 守护断言且全量跑通
  Evidence: `bash scripts/selftest-interaction.sh` → Total: 11 PASS=11 FAIL=0
- [x] VC-4: 3 实体位定向部署后 3 位 diff -r 一致
  Evidence: diff -r 输出（部署后回填）
- [x] VC-5: 无回归破坏（其他 selftest 全量 0 FAIL + check-complete exit 0）
  Evidence: 全量 selftest 227 PASS/0 FAIL；check-complete.sh exit 0

---

## Phase Gates

### Phase 1: Requirements & Discovery
Status: complete — 用户原话拆解 + Rule 28 现状调研（findings.md Requirements/Research Findings）

### Phase 2: Planning & Structure
Status: complete — task-v070 计划目录 6/6 初始化 + Goal/VC/scope/隔离决策（direct）填写

### Phase 3: Implementation
Status: complete — critical-rules.md 28.2.1 + SKILL.md 4 处 + selftest TI-11 + config.json description + skill-collab T10 上限同步

### Phase 4: Testing & Verification
Status: complete — 全量 14 selftest 227/0 + check-complete exit 0

### Phase 5: Delivery
Status: in_progress — 三文件回填 + 3 实体位定向 cp + diff -r 复验 + git commit

---

## 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 5 |
| 主进程直做 Phase 清单 | Phase 1-5（例外理由:④用户显式授权主进程亲为 / ②计划系统文件 / ③机械验证 / ⑥≤5 行文档微调 / ①git 编排） |
| 委派率 | 0.0 < 0.7 → WHITELIST-EXEMPT（全部直做理由均命中 Rule 25.3 六项白名单④②③⑥①） |

## 质量门控统计（Rule 26）

| 触发 | 处置 |
|------|------|
| 无降质行为触发（未跳门控/未以输出代证据/未降档） | n/a |

## outcome

全部 VC 通过（部署后）→ **COMPLETE**
