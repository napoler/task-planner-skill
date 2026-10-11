# Delivery Summary — task-v162-change-absorption-safety（Rule 74 变更吸收三判纪律）

## ① 说明（What）

用户报告严重系统性缺陷：吸收用户新指令/修改时，后续条目**整体替代**既有条目（增量vs替代不判），反复污染可用内容（技能bug修复把整个技能改错实证）。用户要求：① 吸收时先判增量还是替代（增量优先）；② 制定方案时逐条标注变更类型；③ 定稿方案交隔离子代理判别可行性后再执行。

本任务在 task-planner 技能内建立 **Rule 74 变更吸收三判纪律**，三支柱：
- **74.2 变更三判门控**：增量（默认且优先）/替代（四条件全满足才可）/删除（逐项授权）
- **74.3 逐条变更标注**：修订方案必填「📋 变更标注表」（编号/对象/类型/增量或替代/依据/执行动作），无表=无效方案
- **74.4 定稿可行性判别门**：隔离子代理判三维（可执行性/相容性/风险性）→三态结论（PASS/PASS-WITH-RISKS/FAIL）

## ② 产出（Deliverables）

| 产出 | 位置 | 形态 |
|------|------|------|
| Rule 74 条文 74.1-74.6 | skills/task-planner/references/critical-rules.md EOF | 新增（grep=6 PASS） |
| SKILL.md 七处接线 | skills/task-planner/SKILL.md:9,173,234,264,299,360,386 | 数值演进+新增段/行 |
| 触点五处引用 | critical-rules.md:29,374,644 + SKILL.md:248,264 | 纯增量追加 |
| 变更标注表区块 | templates/task_plan.md:137-145 | 新增区块 |
| 可行性判别契约段 | templates/subagent_dispatch.md:94-96 | 新增区块 |
| selftest-absorption-discipline.sh | scripts/（新建） | AD-01..14 静态守护 |
| 级联清账 12 断言 | scripts/ 10 脚本 | 1-71→1-74 字面锚+宽容锚演进 |
| 全量回归 | master 74 脚本 | ΣFAIL=0 ΣPASS=1094 |
| 双审查 | S12 APPROVED + S13 CHANGES→S14 修复 10 条 | 闭环 |
| 合并回 | master d45e8e2 | smart-merge-back 成功 |

## ③ 审查详细（Review Details）

- **代码面审查（S12）**：APPROVED（2 Suggestion：AD-12 _pin_lit 判别力弱 + AD-13 硬编码绝对路径）
- **对齐面审查（S13）**：CHANGES_REQUESTED（P1×2：critical-rules.md:942/875 守卫计数字面未级联；P2×6：措辞/注释/格式微调）
- **修复档（S14）**：CHANGES 10 条全数修复，复验 ΣFAIL=0，AD-01..14 全 PASS
- **可行性判别门（S11）**：PASS-WITH-RISKS（R1 并行 worktree 合并冲突概率高→并集解兜底；R2 标注层漂移；R3 74.3(b) 措辞微强；R4 部署债务待授权）

## ④ 风险必须列举（Risks）

| 风险 | 等级 | 缓解 |
|------|------|------|
| 部署位同步漂移 | 中 | CA-14 deferred 待用户授权；v158 遗留债务（部署位 1-69+70 vs 主仓 1-74） |
| 并行任务合并冲突 | 中 | 已并集解 11 文件（v152-154/v160-164/v162 三方条文保全）；FMEA RPN=84 兜底 |
| R2 标注层漂移 | 低 | Phase 6/7/8 V-N 列与 VC 定义错位，簿记层非语义层，终验前未修正 |
| R3 74.3(b) 措辞微强 | 低 | AD-06/AD-13 只护模板锚/本计划，其他计划标注表未机械化 |
| AD-12 已知形态联合断言 | 低 | S14 已收紧为 live 锚断言（回退探针实证检出） |

## ⑤ 下一步建议（Next Steps）

1. **部署同步**（待用户授权）：`bash skills/task-planner/scripts/smart-merge-back.sh --deploy` 或手动 cp 到 ~/.zcode/skills、~/.agents/skills、opencode 位——部署位 1-69+70 vs 主仓 1-74 diff 面需对账
2. **R2 标注层修正**：Phase 6/7/8 V-N 列与 VC 定义对齐（簿记层，可下轮处理）
3. **74.3(b) 机器面增强**：将变更标注表守护从 AD-06/AD-13（模板锚+本计划）扩展到通用计划自检（check-plan-dispatch 或新 selftest 断言）
4. **Rule 74 实战验证**：后续任务吸收用户补充指令时，观察三判门+变更标注表+可行性门是否按设计生效

## 需求覆盖核对表（R→VC 映射全勾）

| R | 映射 VC | 覆盖判据 | 状态 |
|---|---------|---------|------|
| R1 | VC-1,2,7,8 | 三判门条款在位+SKILL 接线+机器守护+全量回归防复发 | ☑ |
| R2 | VC-3,4,6 | 变更标注表模板+触点引用+机器断言 | ☑ |
| R3 | VC-5,6,8 | 74.4+dispatch 契约+可行性门实战+双审查 APPROVED | ☑ |

**outcome: COMPLETE**（全部 VC 通过，已知遗留不阻塞）
