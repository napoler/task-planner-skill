# Verification Contract & Phase Gates

## Goal (1 sentence)

将池内 8 技能拆分实践集成为 references/split-pattern-library.md（P1-P11+伴飞映射表），以 Rule 21.6 接入计划期拆分决策链，使低档模型执行拿到明确目标与方案；回归零新增 FAIL，部署位 IDENTICAL。

---

## Verification Contract（终验逐条复验，2026-10-09）

- [x] VC-1: 拆分模式库在 master 落地（≥8 源技能吸收，每模式含来源锚+判据+反例+消费时机+低档贡献行，伴飞映射表在位）
  Evidence: `master:skills/task-planner/references/split-pattern-library.md`（126 行，`grep -c '^### P'`=11，来源总表 8 行，伴飞表 8 行路径 `[ -f ]` 全存在）
- [x] VC-2: Rule 21.6 纯增量落地 critical-rules.md（21.6.1-21.6.6），21.1-21.5 零改动
  Evidence: `grep -cE '21\.6\.[1-6]'`=6；`git diff 21f7e6b..998d6e4 -- references/critical-rules.md` 全程零删除行（S3 段 diff 复核+drift-checker 三轮验证）
- [x] VC-3: SKILL.md 接线 ≥3 锚 + dispatch 模板 No-Placeholder 契约行
  Evidence: `grep -c 'split-pattern-library' SKILL.md`=4（References 表/2.5 检查点句/C43a 行/Rule 21.6 摘要条目）；dispatch 模板 §3 契约行 `grep 'No-Placeholder'`=1
- [x] VC-4: selftest-split-pattern-library.sh 全 PASS + 全量回归零新增 FAIL
  Evidence: `Total: 13 PASS=13 FAIL=0`（master 侧复跑）；全量 63 脚本三桶分类：已知基线 1（periodic-review 4 FAIL=master 同态）+ 新增 0（S7 抓 3 级联→S10 清零，fix 后 4 脚本 rc=0，master 侧抽核 registry/skill-split/plan-dispatch rc=0）
- [x] VC-5: CR APPROVED + alignment-review 通过
  Evidence: S16 复审 `VERDICT: APPROVED`（11/11 闭环，残留 grep 零命中；checkpoint subagent-state/24-code-reviewer-S16.md）；S12 ISSUES_FOUND 6 条全部纳入修复（checkpoint subagent-state/20-alignment-S12.md）
- [x] VC-6: master 合并完成 + 部署位 IDENTICAL
  Evidence: `master=998d6e4`（merge commit，3 worktree commits d4fb622/788a4bd/1e5dd98）；部署对账：`~/.claude`+`~/.config/opencode` IDENTICAL（smart-merge-back --deploy 输出）；`~/.zcode` 原子换位后 `diff -rq` = ZCODE-IDENTICAL（备份 ~/skill-deploy-backups-task-v150/）
- [x] VC-7: 术语语义锚定机制落地（R5）
  Evidence: 库 P11（:99-108，实验犬误读真实反例 :105）+ critical-rules 21.6.6（:168 术语锚定与反幻觉）+ SP-04 扩 [1-6] 守卫 + CHANGELOG 条目（:12）

**终验规则**：全部 VC 通过 → outcome: **COMPLETE**

---

## 🎯 核心目标达成裁决（Rule 58.5）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1（优化拆分能力）+ R5（术语语义幻觉根治） |
| **裁决** | `solved` |
| **解决证据锚** | 拆分判定从纯数值上限升级为「数值硬门（21.1b/59.1 不变）+定性判据（21.6 模式库强制消费+边界三判据）」双层：master 998d6e4 三载体在位（库 126 行/21.6 六子条/SKILL 四锚）；R5 幻觉类=21.6.6 术语回写+溯源锚为派发前置（P11 真实反例入库）；机器面=selftest-split-pattern-library.sh 13 断言全 PASS |
| **未解决面+原因** | 无（R4 截断语义待用户澄清，不属未解决——按主诉求交付） |
| **已排除路径** | 新开顶层 Rule（避让 v149 已预留 65）；运行时直调池内技能替代吸收式集成（选双轨：模式库+伴飞映射） |
| **下一步建议** | 新会话消费验证：下一真实任务计划期观察 21.6.1 模式库消费与 21.6.6 术语回写行为面生效（frontmatter 行为需新会话加载） |

## 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 6（Phase 3/4/5 全由子代理承载：executor×6、code-assistant×4、code-runner×1、code-reviewer×2、general-purpose×2、Explore×2，另 drift-checker 改派×6） |
| 主进程直做 Phase 清单 | Phase 1（②簿记+③机械验证基线）、Phase 2（①git 编排+规划职责）、Phase 6（①②合并部署簿记+1 行 CHANGELOG trivial 修正⑥） |
| 委派率 | 0.5 <0.7，但主进程直做全部命中 Rule 25.3 白名单①②③⑥ → **WHITELIST-EXEMPT 放行** |

## 已知遗留（deferred）

1. selftest-split-pattern-library.sh :29/:45/:69 注释残留「kb §5⑤/53.3」引用（3 行，S16 nit 非阻断，下轮顺手清理）
2. selftest-periodic-review.sh 4 FAIL=master 已知基线（v141 缺口，非本任务范围）
3. R4 截断句「还有就是拆分非」语义待用户澄清
4. 行为面冒烟（21.6.1/21.6.6 在真实计划期的消费行为）待新会话验证
