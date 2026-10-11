# Verification Contract & Phase Gates

## Goal (1 sentence)

落地纯增量 Rule 41「问题自主消解与升级纪律」（六子条，零新 config 键）+ selftest-self-resolution.sh 守护 + SKILL 四锚联动 + 仓根 .gitignore 增补（41.3 首个消费示范），全量 selftest 0 FAIL 后合并回 master（88eca16）、三部署位 IDENTICAL、push GitHub 备份、worktree 清理。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: Rule 41 条款完整——`grep -c '^41\.' critical-rules.md` = 6；41.2 含 G1-G4；41.4 含「已尝试清单」「D6 硬停点语义保留不弱化」；41.3 含「直接做」「留用户裁决」禁令；41.6 含「零新 config 键」
  Evidence: 主进程亲验 `grep -c '^41\.'` = 6（worktree L403-413）；selftest-self-resolution SR-01..05 PASS；checkpoint 02 字面锚实测（G1/G4/直接做/留用户裁决/已尝试清单/D6 保留/零新键全命中）；Rule 22.3/28/39/40 段 diff 零改动（deletions=0 纯增 11 行）
- [x] VC-2: SKILL.md 四锚落地——C29 行/Rule 41 摘要行/「含 Rule 40/41」括注/References 行；字面 `Rules 1-39`=2 且 `1-40`=0；行数级联 skill-split 上限 433→435（label task-v098）
  Evidence: 主进程亲验 wc=435；`grep -c 'Rule 41'`=3、`'| C29 |'`=1、`'Rules 1-39'`=2、`'1-40'`=0、`'含 Rule 40/41'`=1；skill-split:41 `-le 435` 与实测一致；6 脚本复跑 0 FAIL（checkpoint 03）
- [x] VC-3: 新 selftest 过 + 全量回归 0 FAIL——SR-01..12 全 PASS；全量 38 脚本求和 0 FAIL 且 ≥616；registry +1 双向一致
  Evidence: 主进程亲跑 selftest-self-resolution `Total: 12 PASS=12 FAIL=0`、registry `rows=actual=38`；全量求和 **38 脚本 616 PASS / 0 FAIL**（=基线 604+SR 12 咬合；workflow 446 误值=正则漏解析 6 个「====」格式脚本，主进程修正复核定数）
- [x] VC-4: .gitignore 增补落地（41.3 消费示范）——仓根 +1 行 `.backup-*/`，check-ignore PASS，git status 不再出现 companion/.backup-*/
  Evidence: worktree 内 `git check-ignore .backup-20260930-demo` exit 0；commit 4bd9cc0；主仓合并后 .gitignore L8 在位（主仓亲验）；demo 未留仓（P4 全程无 demo 文件创建，check-ignore 即时判定）
- [x] VC-5: 合并部署清理闭环——smart-merge-back RC=0（V1-V6 全 OK）→ merge 88eca16 → 三位 IDENTICAL → worktree/分支清理 0/0 → **push origin master 成功（用户 B 类指令，26f938c..88eca16）**
  Evidence: smart-merge-back 输出 [DEPLOY] 三位 IDENTICAL；`git worktree list` 0 残留、`wt/task-v098*` 分支 0；`git rev-parse origin/master` = 88eca16 = master（主仓亲验）；主仓 grep `^41\.` = 6
- [x] VC-6: 边界与零回归——22.3/28/D6/33.4/35.6/39.x/40.x 原文零改动（diff 面仅 6 scope 文件）；config.json 零改动（properties=40，SR-09 断言）；CR（workflow 独立评审员）APPROVED
  Evidence: `git diff --stat` 面=SKILL+6/-2、critical-rules+11、registry+1、skill-split±2、新 selftest、.gitignore+1——全部 scope 内；config.json 未进变更集；workflow Wave4 独立 cr-reviewer 只读审 .sh diff → **APPROVED，issues=0**（评审 4 项核对:断言锚抽 3 条 grep 对照/静态只读/Total 同构/级联值=wc 实测/bash -n）

---

## 委派统计复验（Rule 25.4）
- 机器 stats（check-complete 内联输出）: phases=5 delegated=2（P2/P3,经 workflow dwfrun-9a720fe2 编排）main_direct=3（P1/P4/P5）violations=0 rate=0.4 verdict=ok
- [x] 主进程直做理由全命中 Rule 25.3 白名单（①git 编排/②计划系统文件/③机械验证/⑥trivial 1 行）→ **25.4a WHITELIST-EXEMPT 放行**（<0.7 不降级）
- [x] workflow 编排本身=用户显式点名 /workflow（Rule 39.1），并行豁免已按 39.4 登记 Decisions Made + progress（silent: P2/P3 经 CreateWorkflow 编排）

## 质量门控统计（Rule 26）
- [x] Q1-Q6: 触发 0 项（无降质行为；workflow 446 误值=解析偏差非质量降级，已主进程复核定数 616 并登记 Error Log）；豁免 0；未处置 0
- [x] Evidence 抽查 ≥3: ① `^41\.`=6 主仓亲验 ② 全量 616/0 主进程求和 ③ 三位 diff -r IDENTICAL（smart-merge 输出+主仓 grep 41=6 复验）④ origin/master=88eca16 rev-parse 亲验
- [x] 未处置违规: 无 → outcome 不降级

## Goal Gate (终验)

```
## Goal Verification — Rule 41 问题自主消解与升级纪律落地（用户反馈「需要自动处理问题的能力」）
- [x] VC-1: 六子条 grep=6+四门槛/消解清单/D6 保留措辞全中 → PASS
- [x] VC-2: SKILL 四锚+级联 435+字面锚保全 → PASS
- [x] VC-3: SR 12/0+全量 616/0+registry 双向一致 → PASS
- [x] VC-4: .gitignore .backup-*/ 落地（41.3 示范，未再推给用户）→ PASS
- [x] VC-5: merge 88eca16+三位 IDENTICAL+清理 0/0+push 成功 → PASS
- [x] VC-6: 既有 Rule 原文零改动+CR APPROVED → PASS

 outcome: COMPLETE
```

**遗留披露（不阻塞 COMPLETE）**:
1. **deferred 缺陷（v096 同族新变种）**: check-delegation(enforce) 对 CreateWorkflow 子代理系统性误拦 Write/Edit（workflow run 会话与子代理会话 sid 管道错位，.session-owner=工作流 sid）——本任务经两次 ResolveWorkflowQuestion 批准 Bash 等价写入绕过；hook sid 管道修复建议开专项任务。
2. allow-direct.sh `sid_already_used` 不可自愈（同 sid 一次性标记被早期会话消耗）——机制行为符合设计（防绕行），非缺陷；workflow 场景下不可作为子代理写入通路，Bash 等价写入为已裁定替代。
3. workflow world.run 回归正则对「==== selftest … 结果: PASS=x」格式 6 脚本漏解析（报 446 非 616）——FAIL=0 判定不受影响，主进程修正正则复核定数；若修该正则属 workflow 脚本层（一次性 draft），非仓内资产。
4. SKILL.md frontmatter 索引区（L10 区）未括注 Rule 41（PT-08 锚约束下有意保守，同 v097 P2-c 先例）。
