# Verification Contract & Phase Gates

## Goal (1 sentence)

SKILL.md 调研链与 skill-collaboration.md 触发矩阵显式路由 research-assistant（网络调研主通道）与 browser-use 插件（网页访问）并声明 ZCode 平台适配工具优先，纯增量，全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位。

---

## Verification Contract (final)

- [x] VC-1: SKILL.md 调研路由三处增补（L458 链注记 browser-use/research-assistant、平台适配声明、路由表网页访问行）
  Evidence: 主仓与 worktree grep：browser-use=3 行 / mcp__node_repl__js=3 行 / playwright=1 / 网络调研主通道=1 / wc -l=543；链序①②③④⑤ grep 输出有序（progress.md P2 段）
- [x] VC-2: skill-collaboration.md §二矩阵新增两行（4 列对齐 L60 范式）
  Evidence: grep 'research-assistant（嵌入，网络调研触发' / 'browser-use（嵌入，网页访问触发' 各 1 命中（L61/L62）；NF-2=4；wc -l=113≤300
- [x] VC-3: selftest-skill-collab.sh T11a-d/T12a-b（19→25）+ selftest-knowledge-brief.sh T2b 545→548
  Evidence: 单跑输出 25 PASS/0 FAIL 与 16 PASS/0 FAIL（progress.md P3 段）
- [x] VC-4: 全量 selftest 0 FAIL 且 SKILL.md ≤548（worktree 与合并后 master 双跑）
  Evidence: worktree 355 PASS/0 FAIL + master 合并后 355 PASS/0 FAIL（p3-full-regression.log / p5-master-regression.log；主进程逐 Total 行求和）
- [x] VC-5: 纯增量核验——git diff f0fa427 删除行恰=2 允许项（L458 注记替换行、T2b 旧断言行），零功能性删除
  Evidence: `git diff f0fa427 | grep '^-‘` 输出恰 2 行（findings.md Code Review 段）；五记号顺序 grep 不变
- [x] VC-6: 合并回 master（merge 2a2df8f）+ 3 部署位 diff -r 全量 IDENTICAL（主进程亲验）
  Evidence: smart-merge-back --deploy 输出（首次 .zcode 位 REJECTED=运行位自保护，改主仓副本重跑 → 三位 IDENTICAL）+ diff -r 亲验输出（progress.md P5 段）
- [x] VC-7: CHANGELOG.md Unreleased/新增 顶部 task-v080 条目
  Evidence: CHANGELOG.md L12（commit 20d6186）

---

## Phase Gates

### Phase 1: 隔离与基线 — `complete`（2026-09-17）
worktree 创建 + Rule 36.3 删除基线（空）+ 基线 349/0。V-1.1 worktree 在册 ✓ V-1.2 基线求和 ✓
### Phase 2: 调研路由增补 — `complete`（2026-09-17，主进程接管 5163462）
V-2.1 S1 验收 6/6 ✓ V-2.2 S2 验收 3/3 ✓
### Phase 3: selftest 守护 + 全量回归 — `complete`（2026-09-17，0f4d750）
V-3.1 双 selftest 单跑 PASS ✓ V-3.2 全量 355/0 ✓
### Phase 4: CR + CHANGELOG + 联动核查 — `complete`（2026-09-17，20d6186）
V-4.1 CR APPROVED（diff 自审+回归兜底）✓ V-4.2 联动零遗漏 ✓
### Phase 5: 合并回 + 部署 + 簿记 — `complete`（2026-09-17）
V-5.1 merge 2a2df8f ✓ V-5.2 三位 IDENTICAL 亲验 ✓ V-5.3 master 全量 355/0 ✓ V-5.4 worktree/分支清理 ✓

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|-----|
| 材料包 00-materials.md | S1/S2 编辑内容与 §S-A/§S-B 逐条对照 | 符合（old/new 精确落地） |
| SKILL.md L452-490 现状 | L458 原文与 findings §🔒 基线段一致后才替换 | 符合 |
| 行数断言三处 | T2b 545→548 与另两处 548 对齐 | 符合 |
| 宪法 §七/§十 | 路由语义（research-assistant 链/Browser Use 唯一入口/禁假设不存在 MCP） | 符合 |

## 委派统计复验（Rule 25.4）

JSON 输出（check-delegation.sh stats）：
```json
{"phases_total":5,"phases_delegated":0,"main_direct_count":5,"delegation_rate":0.000,"violations":[],"verdict":"ok"}
```
- [x] 主进程直做 Phase 均登记白名单内例外理由（①③⑤②；P2-P4=Rule 22.3④ 接管+白名单⑤，环境 spawn 全档位失败 4 次实证）
- [x] 委派率 0 < 0.7 但全部理由命中白名单 → **WHITELIST-EXEMPT**（violations=[]/verdict=ok，不阻断）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查：触发 0 项，豁免 0 项，未处置 0 项（无伪造证据/无静默降级/错误全部落 Error Log 且 Root Cause 非占位）
- [x] Evidence 抽查 ≥3 条：VC-1 grep（可复现）、VC-4 两份回归日志（可 Read）、VC-6 diff -r 输出（可复跑）
- [x] 豁免登记：无
- [x] 未处置违规：无 → 不降级

## Learning Gate（Rule 31.5）
- [x] progress.md Error Log 5 行 Root Cause 全部非 <待沉淀>；notepad-learnings.md 已沉淀（Notes for Next Time 四条防线）

## Goal Gate (终验)

```
## Goal Verification — 网络调研/网页访问工具路由明确化
- [x] VC-1: grep 三锚+wc=543 → PASS
- [x] VC-2: 矩阵两行 4 列 → PASS
- [x] VC-3: 25/0 + 16/0 → PASS
- [x] VC-4: 355/0（worktree+master 双跑）→ PASS
- [x] VC-5: 删除行=2 允许项 → PASS
- [x] VC-6: merge 2a2df8f + 三位 IDENTICAL → PASS
- [x] VC-7: CHANGELOG 条目 → PASS

 outcome: COMPLETE
```
