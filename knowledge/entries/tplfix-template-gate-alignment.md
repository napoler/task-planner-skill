---
id: tplfix-template-gate-alignment
title: 模板-门六漂移对齐——验证区块契约+10 列序+断言随契约演进
tags: [templates, verification, attestation, 冒烟, 判例]
sources:
  - knowledge/entries/_draft-task-tpl-verify-fix-20261113.md
  - plans/task-tpl-verify-fix-20261113/delivery-summary.md
  - skills/task-planner/templates/
updated: 2026-11-13
---

# 模板-门六漂移对齐（task-tpl-verify-fix-20261113）

## 1. 六漂移清单与修法
事实源：`plans/task-tpl-verify-fix-20261113/delivery-summary.md:4-7`。六处模板-门漂移对齐修法：

| # | 漂移 | 修法 | 锚点 |
|---|------|------|------|
| 1 | task_plan 模板 S-unit 表 11→10 列 | 类别并入目标列内（An）前缀，统一 10 列序 | `skills/task-planner/references/template-mapping.md:232-238`（10 列序契约） |
| 2 | verification 模板缺验证区块 | 补每 VC 条目三行结构：含行首 `**Verify command**:` 纯命令行 + 禁占位/禁真空引导（attest vc-gate 判据面） | `skills/task-planner/references/template-mapping.md:232-238`（验证区块契约）, `skills/task-planner/references/template-guide.md:167` |
| 3 | Goal 单元表列名缺空格 | 列名补空格（对应 S-unit/Phase） | `skills/task-planner/references/task-dispatch.md:244,256,278` |
| 4 | Phase 4 示例缺 S-unit 表 | 示例补 S-unit 表 | `skills/task-planner/references/task-dispatch.md:244,256,278` |
| 5 | Batch Report 实值引导缺失 | 补 n/a 形态实值引导 | `skills/task-planner/references/task-dispatch.md:244,256,278` |
| 6 | SG-12/13 断言落后于示例表正当演进 | 断言翻转对齐新契约（冒烟抓到） | `skills/task-planner/scripts/selftest-guards.sh:148-158`, `skills/task-planner/scripts/selftest-acceptance.sh:97-99`（SA-19 守卫翻转） |

顺序铁律：先模板（Phase 2）→再他处（Phase 3），真传播面清零后 SKILL.md 注释块无锚诚实关闭（CA-7）。

## 2. 冒烟验证法
- 方法：用 tmp 计划按新模板真跑 init 渲染 + 门校验，验证“新计划一次过门”可用性。
- 判据：**EXIT:0 零拒锁**（3 派发 Phase 全有表）= 新模板可用性证明（delivery-summary: `3 派发 Phase 全有表`）。
- 清理：smoke 用完即删，不留残留计划。

## 3. 易错点
- **断言随契约演进，非为绿弱化**：门/自测断言必须跟随模板契约与示例表正当演进同步翻转（如 SG-12/13、SA-19），不可为保绿弱化判据。
- **教学面可能在模板本体而非 SKILL 注释**：传播面排查要覆盖模板/契约文档/脚本守卫，不可只盯 SKILL 注释；无锚则诚实关闭（CA-7 判例）。
- **vc-gate 判据严格**：验证区块每 VC 条目须含行首 `**Verify command**:` 纯命令行，禁占位、禁真空；模板契约见 `skills/task-planner/references/template-mapping.md:232-238`，引导见 `skills/task-planner/references/template-guide.md:167`。
