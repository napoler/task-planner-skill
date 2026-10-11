# Verification Contract & Phase Gates

## Goal (1 sentence)

新建顶层 skill skills/iterative-optimizer/SKILL.md（五步迭代闭环:评估→诊断弱点→定向改进→门控三态;输入契约 QC≥3 且≥1 机器可检查+max_iterations 默认 5;门控铁律禁自报/PARTIAL 禁宣称 RESOLVED/连续 2 轮无改善停止;状态文件断点续跑;迭代摘要+RESOLVED/PARTIAL/BLOCKED）+selftest IL-01..08+registry;全量 660/0 后合并、三宿主部署、push、清理。

---

## Verification Contract

- [x] VC-1: SKILL.md 在位(97 行,fix-phase 后)——frontmatter 两字段;五步锚各≥1;输入契约表(QC≥3/机器可检查/max_iterations/默认 5);门控铁律 5 条(禁自报/PARTIAL 禁宣称 RESOLVED/最小定向/连续 2 轮停止/回归重跑);状态文件锚;摘要表+三枚举;用户原话八锚全入位;banned 词零命中
  Evidence: CR 专项 1/2 PASS(逐行 file:line);grep 复现 banned=0
- [x] VC-2: selftest IL-01..08 全 PASS(`Total: 8 PASS=8 FAIL=0`)+registry 43 行(SR-12 动态咬合 42 脚本+表头)
  Evidence: 实跑 8/0;SR-12 12/0「43=脚本数+表头(动态)」
- [x] VC-3: 全量回归 **42 脚本 660 PASS / 0 FAIL**（=652+IL 8 咬合,主进程定数）
- [x] VC-4: 合并部署 push 清理——merge b5acff6+fix 4e55894;task-planner 三位 IDENTICAL+池软链 33 链 LINK-OK(v105 幂等顺带验证);新 skill 三宿主 install-companion 分发+diff IDENTICAL;push ls-remote 终验;清理 0/0
- [x] VC-5: 边界零回归+CR **APPROVED**（0 P0/P1;4 P2→fix-phase 处置 P2-a/b/c 三处一词级,P2-d 证伪登记）;diff 面=新建 2 文件+registry 1 行,既有守护零改动

---

## 委派统计复验（Rule 25.4）
- delegated=1(P2 executor S1→S2;P5-CR code-reviewer);main_direct=3-4(P1/P3/P4/P5 簿记),verdict=ok,rate≈0.2
- [x] 25.4a WHITELIST-EXEMPT(直做理由全白名单①②③⑤)

## 质量门控统计（Rule 26）
- [x] Q1-Q6: 触发 1 项(CR P2-d 证伪:CR 报「仓内不存在 lib/install-companion.sh」实为把仓根当根目录——文件实存 task-planner/lib/,登记证伪不修);未处置 0
- [x] Evidence 抽查 ≥3: ①三宿主新 skill diff IDENTICAL ②全量 660/0 主进程定数 ③ls-remote 4e55894 ④池软链 33 链 LINK-OK
- [x] 未处置违规: 无 → COMPLETE

## Goal Gate (终验)

```
## Goal Verification — 循环迭代优化 skill 全链交付
- [x] VC-1: SKILL.md 设计完备 → PASS
- [x] VC-2: selftest 8/0+registry → PASS
- [x] VC-3: 全量 660/0 → PASS
- [x] VC-4: 合并部署 push 清理 → PASS
- [x] VC-5: CR APPROVED(fix-phase 处置) → PASS
```

outcome: **COMPLETE**

**遗留披露（不阻塞）**: ① skill 为行为面制度,实际迭代收敛质量依赖使用时 QC 定义质量——首次实战使用后可回灌经验;② CR Nit: gate 三态与 BLOCKED 已补「补充出口」交叉引用,若后续增第四态需同步结论枚举
