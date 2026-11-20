---
id: spec-baseline-freeze-anti-regression
title: "规范基线冻结防倒退闭环（Spec-Baseline Freeze，sess_ba603cf5 4-12s 判例）"
tags: [kb, anti-regression, spec-baseline, attest-lock, verification-gate, vacuous-gate-fix]
sources: [plans/task-spec-baseline-freeze-20261119/findings.md, plans/task-spec-baseline-freeze-20261119/progress.md, plans/task-spec-baseline-freeze-20261119/verification.md, skills/task-planner/references/critical-rules.md]
updated: 2026-11-19
---

# 规范基线冻结防倒退闭环（task-spec-baseline-freeze-20261119）

## 问题判例（sess_ba603cf5，一手取证）
- 用户原话：33 集前严格遵守 4-12s 单镜限制，sess_ba603cf5 产出 3s/15s 违规分镜（EP33-44 共 59 镜）致工作不可用，属倒退式开发/规范被篡改。
- 根因（git blame + 文件取证，非脑补）：4-12s 双界只定义在弧规格与 script-craft M0 模板层，**从未下沉**到 storyboard-craft（其 SKILL.md:11 明确时长"非门控"）；C87 只写 `≤12s` 缺 ≥4s 下限，越界可走"超拍登记/NOTE"软豁免放行。**无单点篡改**——真实机制=硬约束从未固化为技能/QC 强制门。

## 解法：Spec-Baseline Freeze 闭环（零新脚本，复用 attest SHA-256 锁）
把"已确立且影响验收的业务硬约束"登记进 task_plan.md「🔒 规范基线」区块（随 task_plan 纳入 Rule 20.1 attestation 锁定面），四环消费：
1. **冻结** critical-rules 51.15：区间硬约束必须登记**上下界**（`4s≤单镜≤12s`），禁只写单边（单边=无下限=3s 过审机制根因）；篡改/软豁免放行=[SPEC-BASELINE TAMPERED] P0。
2. **派发携带** dispatch 22.4e：prompt 必带 spec_id+约束原文 verbatim+双向判定式+sha256，禁子代理转译/重建/放宽。
3. **复检回归** dispatch 103.3b：第 5 维"基线-产物一致性回归"，拦三类倒退信号（软豁免/降单边/前序合规本轮退化）。
4. **返工续写回归** discipline 106.7 + **终验门** verification 84.15：触发点全量回归 + 终验逐条验真产出核验表；流程绿≠规范合规。

## 易错点与禁止假设
- **双边登记铁律**：区间约束只写单边上限等于无下限——这是 3s/15s 类违规过审的机制根因，必须双向判定式。
- **Verify command 负控制**（本次实测教训）：验收命令的 `$pos/$f` 曾拼成 `skills/skills/` 使 `[ ! -f ]&&continue` 全部跳过 + 末尾 echo 恒真——**恒真假门**。写完验收命令必须注入负例（错锚/错路径）确认能抓 FAIL；标题数字（"5 部署位 diff=0/19 文件 64 锚"）须与实测口径一致，不可夸大。
- **占位专档≠空专档**：user-session-log.md 只有 #N 示例行不算真实逐字记录，Rule 80.8 完成声称前须补 #1 逐字原话条目。
- **跨仓边界**：StoryLab 项目层规范下沉 + EP33+ 违规分镜修复属另一仓 `task-storyboard-duration-fix-001`，跨项目修改需显式授权（§五）；本 skill 层机制对新会话生效，不回溯历史产物。
- **并行会话指针**：归档前 side 指针按 sid 分属；全局指针为空但 side 指针可能指向他会话任务（本次 a6eb…=本任务 / 5263…=他任务 task-skill-loop-guard），清理只动自己的 sid，禁 --clear 全局误伤。

## 验证状态（2026-11-19）
- commit 7db7a25（7 文件 +18/-0，零新脚本零 config 键）→ merge 879fb48；主仓 8 锚全=1；selftest 4 脚本 84 PASS/0 FAIL；3 部署位核心规则锚 12/12+模板 4/4。
- drift-checker 判 ALIGNED（P0=无）；VC-3 恒真假门已修并经负控制验证非恒真；他会话 17 staged 经 stash→wt→merge→pop --index 完整保留。
