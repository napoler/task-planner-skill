# Verification Contract & Phase Gates

## Goal (1 sentence)

在 skills/task-planner/review-library/ 内建 10 个通用质量审核技能兜底池（随部署分发三平台）+ Rule 42.2 检测链四级化（插入④层兜底池）+ SKILL C30 同步 + selftest-review-library.sh 守护，全量 0 FAIL 后合并回 master、三部署位 IDENTICAL、push GitHub、worktree 清理。

---

## Verification Contract

- [x] VC-1: review-library 恰 10 个技能目录,四要素齐备,name 互异
  Evidence: `ls review-library | wc -l`=10（主仓+三部署位亲验）;10 个 `name:` 全表互异=目录名（P2-S4 evidence 全表+主进程复核）;RL-01..03 PASS
- [x] VC-2: 10 类通用审核面覆盖,各清单 ≥8 条（实际 11-15 条）非空壳
  Evidence: 逐文件 `grep -c '^- \[ \]'`=15/14/14/14/11/12/11/11/11/11（主进程定数）;CR 专项 1 逐个 Read 全 PASS（07-cr-p5.md「10 文件清单 11-15 条,每条有动作+判定标准,领域互异」）
- [x] VC-3: Rule 42.2 四级化（④层插入+「均未命中=缺口」保留+①②③原文零改动）+C30 同步
  Evidence: `grep -c '四级检测顺序' CRIT`=2、`'三级检测顺序'`=0、42.2 行含「④ task-planner 内置 review-library 兜底池」;CR 专项 3「①②③层 byte 级保留」（07-cr-p5）;diff numstat CRIT=2/2（42.2+42.5 两行）
- [x] VC-4: 新 selftest 10/0+registry 41 行双向一致+全量回归（40 脚本）0 FAIL
  Evidence: selftest-review-library `Total: 10 PASS=10 FAIL=0`;selftest-registry `rows=40, actual=40`;全量 **40 脚本 638 PASS / 0 FAIL**（主进程定数 628+RL 10 咬合;CR 复核一致;CR P2-a 口径校正后 threshold 自洽）
- [x] VC-5: 合并部署 push 清理闭环
  Evidence: merge 9b17c05（V1-V6 OK）;三部署位 IDENTICAL 且 `ls review-library`=10（三平台亲验）;push 539adcc..9b17c05 与 ecae12d（CR P1 后）两轮,`git ls-remote origin master`=ecae12d=master;worktree/branch 残留 0/0
- [x] VC-6: 边界零回归+CR APPROVED——CRIT 42.2/42.5 外零改动（numstat 2/2）;SKILL 仅 C30+摘要行（2/2）;config.json 零改动（properties=40）;CR Gate 首审 CHANGES_REQUESTED→fix-phase→**复验 APPROVED**
  Evidence: 06/07 两次 CR 检查点;R-12 config=40 PASS;P1 修复 ecae12d 单 hunk（CR 复验 git show 确认）;SR-12 动态口径根治登记 B 类扩围

---

## 委派统计复验（Rule 25.4）
- 机器 stats: phases_total=5, delegated≈2（P2/P3 经 executor 派发;P5-CR 子代理）, main_direct=3（P1/P4/P5 簿记）, rate≈0.4, violations=[], verdict=ok
- [x] 主进程直做理由全命中 25.3 白名单（①git 编排/②簿记/③机械验证/⑤终验复核）→ 25.4a WHITELIST-EXEMPT（v098/v099 同批先例）
- [x] 教训沉淀: Executor 字段纯 token 口径（v099 教训延续,本计划 P2/P3 字段已按纯 token 撰写）

## 质量门控统计（Rule 26）
- [x] Q1-Q6: 触发 1 项（CR P1=B 类澄清未回溯已产出工件,fix-phase 闭环处置+Error Log 沉淀防线）;豁免 0;未处置 0
- [x] Evidence 抽查 ≥3: ①池 10 目录三平台亲验 ②全量 638/0 主进程定数 ③P1 修复点 CR 复验 file:line ④ls-remote 终验亲验
- [x] 未处置违规: 无 → outcome 不降级

## Goal Gate (终验)

```
## Goal Verification — 10 个通用质量审核技能兜底池+Rule 42.2 四级化全链交付
- [x] VC-1: 池 10/10+四要素 → PASS
- [x] VC-2: 10 类覆盖+清单 11-15 条 → PASS
- [x] VC-3: 42.2 四级化+①②③保留+C30 同步 → PASS
- [x] VC-4: 新 selftest 10/0+全量 638/0 → PASS
- [x] VC-5: 合并 9b17c05+三位 IDENTICAL+push ecae12d+清理 0/0 → PASS
- [x] VC-6: 边界零回归+CR 复验 APPROVED → PASS
```

outcome: **COMPLETE**

**遗留披露（不阻塞）**:
1. SR-12 helper 假设备忘（CR P2-b,方向 fail-closed 可接受——未来 selftest- 前缀 helper 需避开命名或改断言口径）
2. VC-4 计划期阈值估算 628+12 偏高（RL 实为 10 断言）——CR P2-a 已校正口径并留痕
3. 兜底池真实消费场景待实战（首个三级未命中任务触发④层命中）
