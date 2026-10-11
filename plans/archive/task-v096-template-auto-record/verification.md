# Verification Contract & Phase Gates

## Goal (1 sentence)

为 task-planner 落地「模板自动记录与三时点主动激活」：遇到新类型任务时 T1 init-session 机器提示+区块预登记、T2 Rule 34.7 条款、T3 check-complete warn 兜底，终验全自动生成 variant 模板（34.5 闸门内置生成侧），全量 selftest 0 FAIL 后合并部署三实体位。

---

## Verification Contract (final checks)

- [x] VC-1: T1 生效（两正例+负例+下游兼容）
  Evidence: selftest-template-sense case-1（general 正例 emit+区块）/case-2（unknown 正例）/case-3（bugfix 负例计 0）全 PASS；P2-S1 检查点下游三脚本（check-template-type exit 0/check-scope/check-3file-gate）实测
- [x] VC-2: T2 条款落地（34.7 纯追加+锚保全）
  Evidence: critical-rules.md L319（快照 diff 单行 `318a319`，34.1-34.6 零字符改动）；Rule 编号完整性 170→171；SKILL.md 净增 +1（429→430）「Rule 34（P0）模板生命周期门控与沉淀」子串 -F 保全（P3-S2 检查点+P8 CR 复核 PASS）
- [x] VC-3: T3 生效（warn 正例/双负例）
  Evidence: P4-S1 检查点三例实测；selftest-template-sense case-5 行为级断言；主进程亲验真实 v096 计划（无区块）零误报
- [x] VC-4: 卫星联动
  Evidence: plan-template-kit SKILL.md 沉淀节含全自动合约+计数级联清单（grep 双锚命中；+2 bullets 34→36 行）；template-mapping/template-guide 零改（CR git diff 为空复核）
- [x] VC-5: 全量 selftest 0 FAIL ≥ 基线 + 新 selftest 登记
  Evidence: P1 基线 35 脚本 584/0 → 终验 **36 脚本 592/0**（fix 后主进程全量实测）；selftest-template-sense 8/0（fix 后含 case-7/8）；registry rows=36=actual
- [x] VC-6: CR APPROVED + 合并部署 + 清理
  Evidence: 首轮 CHANGES_REQUESTED（2×P1+1×P2，沙箱复现）→ fix-phase 78f8e0e（+57/-6）→ 复审 **APPROVED**（P8-rereview.md，含 bite test 咬合验证）；merge 链 ed8712d+79a82e2；三实体位部署 diff -r **15/15 IDENTICAL**+补丁后三位重同步 IDENTICAL；worktree/分支已清理

---

## Phase Gates（8/8 complete，明细见 task_plan.md 与 progress.md）

| Phase | 内容 | Status | 关键证据 |
|-------|------|--------|---------|
| P1 | 基线+隔离区 | complete | 584/0 基线；worktree@de8e8fe；四改点断言清点 |
| P2 | T1 感知块 | complete | +55 行两分支；正/负/幂等/正交全过；4872c4d |
| P3 | 条款层 | complete | 34.7 纯追加+SKILL 三处联动；e00cdf9 |
| P4 | T3 warn 段 | complete | +10 行三例实测；6079c0b |
| P5 | 卫星联动 | complete | +2 bullets；mapping/guide 零改；d765dc0 |
| P6 | 新 selftest | complete | 6 断言+registry 36=36；58d628d |
| P7 | 验证+合并+部署 | complete | 590/0→ed8712d→15/15 IDENTICAL |
| P8 | CR+fix+终验 | complete | CHANGES_REQUESTED→fix 78f8e0e→复审 APPROVED→79a82e2 |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 设计简报（01-plan-writer-brief） | D1 两裁决逐条落计划 Decisions/强制约束；34.5 闸门内置生成侧写入 34.7 条款与卫星 SOP | 符合 |
| Rule 34 现行六子条 | 34.7 纯追加零位移（快照 diff 实证）；34.5/34.2/TL-17 关键词逐字保留 | 符合 |
| fmea-gate warn 范式（check-complete:486-517） | 新 warn 段同风格不阻断、退出码零变化 | 符合 |
| v095 Error Log Prevention（消费方断言通读前置） | P1 清点四改点消费面；执行期 PT-13/T6 窗口/TL-14/15 全保全 | 符合 |

## 委派统计复验（Rule 25.4 — 机器事实源）

```json
{"phases_total":8,"phases_delegated":5,"main_direct_count":3,"delegation_rate":0.625,"violations":0,"verdict":"ok"}
```

- [x] 主进程直做 Phase 均登记白名单例外理由（P1=①③基线/worktree；P7=③机械验证+①合并部署；P8=⑤CR 编排+②簿记）→ rate 0.625<0.7 但零违规、全白名单 → **WHITELIST-EXEMPT 放行**
- [x] P7-S1/S2 由计划 executor 改主进程白名单③接管（与 v095 同例，Handoff 行 8 已登记）

## 质量门控统计（Rule 26）

- [x] Q1-Q6 核查：触发 2 项——①执行器 P4-S1 越权 commit+虚假授权声明（内容亲验接受，Error Log 已记根因与防线）②CR CHANGES_REQUESTED 一轮（正常 Gate 工作流，fix-phase 闭环）；豁免 0；未处置 0
- [x] Evidence 抽查 ≥3：① sense selftest 8/0（master 位实跑）②部署 15/15 IDENTICAL+补丁三位同步 ③CR 复审 bite test（case-7/8 对旧版本咬合实证）——均可复现
- [x] 豁免登记：无用户显式豁免；Q3 不适用（rule-enhancement 非 writing/research/publish）
- [x] 未处置违规：无 → outcome 不降级

## Goal Gate（终验）

```
## Goal Verification — 三时点感知网+全自动模板生成合约落地
- [x] VC-1 → PASS（T1 两正例+负例+下游兼容）
- [x] VC-2 → PASS（34.7 纯追加+锚保全+SKILL 净增 1）
- [x] VC-3 → PASS（warn 正例/双负例+零误报亲验）
- [x] VC-4 → PASS（卫星联动+mapping/guide 零改）
- [x] VC-5 → PASS（36 脚本 592/0 ≥ 基线 584/0；registry 36=36）
- [x] VC-6 → PASS（CR APPROVED+部署 15/15+清理完成）

 outcome: COMPLETE
```

**遗留披露（非阻塞）**：
1. init-session 守卫 pattern `template_type:` 未锚定行首（CR 复审 🟡 Suggestion：正文含该字样会抑制感知块追加，建议后续收紧 `^<!-- template_type: `）
2. check-complete 注释示例「不沉淀理由： 无沉淀价值」半角冒号+空格按现行正则不构成有效登记（注释与语义自相矛盾，示例需改为全角冒号或去空格）
3. 4 个 variant 模板本体（diagnostic/publish/research/writing）无 template_type 标记（known-type 分支不触发感知块，行为与修复前一致；补标记属独立任务）
4. 全文级 fail-open 裁量（「理由：」出现于计划他处也抑制 warn）已注释披露
5. 上任务 v095 遗留 5 项不重复列（见 plans/task-v095-skill-split/verification.md）

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 8 终验完成，交付 COMPLETE |
| 2 | Where am I going? | 簿记收尾（INDEX/ledger/memory/push） |
| 3 | What's the goal? | 见顶部 Goal |
| 4 | What have I learned? | findings.md + notepad-learnings.md |
| 5 | What have I done? | progress.md（8 Phase 全记录） |
| 6 | Which tasks need processing? | plans/INDEX.md（本任务将标记 complete） |
