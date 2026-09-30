# Verification Contract & Phase Gates

## Goal (1 sentence)

落地纯增量 Rule 42「质量审查技能主动检测与补充」（五子条）+ Rule 43「执行可靠性制度化」（四子条）+ SKILL 三锚联动 + 模板/契约消费面 + 新建 selftest-reliability-institution.sh（R-01..12）守护，全量 selftest 0 FAIL 后合并回 master、三部署位 IDENTICAL、push GitHub 备份、worktree 清理。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: Rule 42/43 条款完整——critical-rules.md EOF 纯追加（既有 413 行零改动），`grep -c '^42\.'`=5 且 `'^43\.'`=4；42.2 含三级检测顺序；42.3 含「S-unit 登记（禁无登记私建技能）」；43.1 含「未验证」显式登记 + 8 字段 evidence 无证据=未完成；43.2 含「最小档位」；43.3 含「候选对比表」；42.5/43.4 各含「零新 config 键」
  Evidence: `grep -c '^42\.'`=5、`'^43\.'`=4（主仓亲验）；P2-S1 产出纯追加 19 行 deletions=0（03-executor-p2s1.md + git diff）；06-cr-p5 专项 1 PREFIX-IDENTICAL 复验
- [x] VC-2: SKILL.md 三锚落地——C30/C31 两行、Rule 42/43 摘要行、:242 括注「含 Rule 40/41/42/43」+References 枚举追加；`grep -c 'Rules 1-39'`=2 且 `1-40`/`1-41`=0；级联 selftest-skill-split.sh:41 `-le 435`→`-le 439`（label task-v099）
  Evidence: `grep -c 'Rule 42'`=3、`Rule 43`=3、`| C30 |`=1、`| C31 |`=1、`Rules 1-39`=2、`1-40`=0（主仓亲验）；skill-split `Total: 41 PASS=41 FAIL=0`；06-cr-p5 专项 2/3 全 PASS
- [x] VC-3: 模板与契约落地——templates/task_plan.md 配置表「质量审查工具」行；mini-lite-type.md「Rule 42.5 豁免」行；companion/agents/plan-writer.md 义务行（S-unit 建议档位 + 质量审查工具检测登记 + 候选对比表三要素）
  Evidence: 主仓 `grep -c '质量审查工具' templates/task_plan.md`=1、`~/.zcode` 部署位亲验=1；plan-writer 义务行 06-cr-p5 专项复验；三文件各 +1 行（P3 提交 2494ef7）
- [x] VC-4: 新 selftest 守护 + registry + 全量回归 0 FAIL——selftest-reliability-institution.sh R-01..12 全 PASS；selftest-registry.tsv 40 行且 `selftest-registry.sh` PASS（rows=actual）；worktree 全量回归（39 脚本）0 FAIL 且总 PASS ≥ 616 + R 增量（主进程逐脚本求和定数，Total 双形态正则）
  Evidence: `bash scripts/selftest-reliability-institution.sh` → `Total: 12 PASS=12 FAIL=0`；`selftest-registry.sh` → `rows=39, actual=39 PASS=5 FAIL=0`；worktree 全量求和（P3）= 39 脚本 0 FAIL；主仓 39 脚本 0 FAIL 复核
- [x] VC-5: 合并部署清理闭环——`git merge --no-ff` 成功；`smart-merge-back.sh --deploy` 三位 IDENTICAL；`git push origin master` 成功（推送前只读预检 origin 无领先量）；`git worktree remove`+`git branch -d` 无残留；主仓 Read 关键文件复验（部署位 `grep -c '^42\.'`=5）
  Evidence: smart-merge-back [DEPLOY] 三位 IDENTICAL（P4）；worktree/branch 残留 0/0；origin push 成功（B 类 09-30 持久指令）；`~/.zcode` 位 `grep -c '^42\.'`=5、`质量审查工具`=1 亲验
- [x] VC-6: 边界与零回归——Rule 22-41 任何原文零改动（diff 面仅限 8 scope 文件）；config.json 零改动（properties=40，R-12 断言）；Code Review Gate 输出 APPROVED；SR-11/12 旧守护锚级联为登记扩围（断言语义零改动）
  Evidence: 06-cr-p5 **APPROVED（0 P0/0 P1/2 P2 非阻断）**，专项 1 前缀 IDENTICAL、专项 3 越界字面零命中、专项 5 SR 仅锚值改动；R-12 config properties=40 PASS；SR-11/12 扩围已登记范围表+Decisions

---

## 委派统计复验（Rule 25.4）

机器统计为事实源（check-delegation.sh stats 原文,2026-09-30）：
```json
{"phases_total":5,"phases_delegated":1,"main_direct_count":4,"delegation_rate":0.200,"main_direct":[P1/P3/P4/P5——P3 因 Executor 字段措辞「executor（S-unit 表见下）」未登记白名单关键词被机器计入直做面;P1/P4 全白名单①②③] ,"violations":[],"verdict":"ok"}
```
- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（P1=①②③；P4=①②③；P5=②⑤；P3 机面口径=直做,实际执行经 executor 派发（S3/S4）——机器 stats 与计划口径偏差已如实披露,不掩盖）
- [x] 委派率 0.2（机面口径）<0.7 → **25.4a WHITELIST-EXEMPT 放行**（violations=0、verdict=ok、main_direct 理由全白名单命中）；教训沉淀：派发型 Phase 的 Executor 字段须直接写执行体 token（P2 字段=「executor（sonnet-1）」则计入 delegated——P3 字段带 S-unit 注解致机器解析为直做）→ notepad「Notes for Next Time」

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项
- [x] Evidence 抽查 ≥3 条:VC-1 条款 grep（主仓 5/4）、VC-4 selftest 12/12+全量 0 FAIL、VC-5 部署位 42 计数=5 抽查可 Read 复现
- [x] 豁免登记:无（Q3 不适用，非批量任务 0 单元声明）
- [x] 无未处置违规 → outcome 不降级；CR 两条 P2 非阻断（SR 头注释同步/exec bit）已在本 Phase 注释同步项处置（见下）

## Goal Gate (终验)

```
## Goal Verification — 纯增量落地 Rule 42/43 并全链部署备份
- [x] VC-1: 条款 ^42.=5/^43.=4 纯增 → PASS
- [x] VC-2: 三锚+级联 439+字面保全 → PASS
- [x] VC-3: 模板/契约三落点在位 → PASS
- [x] VC-4: 新 selftest 12/0+registry 40 行+全量 0 FAIL → PASS
- [x] VC-5: 合并+三位 IDENTICAL+push+清理闭环 → PASS
- [x] VC-6: 边界零回归+CR APPROVED+零新键 → PASS
```

outcome: **COMPLETE**

**CR P2 处置（非阻断，随终验收尾）**：
- P2-a（SR 头注释 :15/:16 未随代码级联同步）→ 已在本 Phase 主进程白名单②同步（`selftest-self-resolution.sh` :15/:16 注释改 task-v099/行数 40，断言代码零改动，`selftest-self-resolution.sh` 复跑 12/0）
- P2-b（新 selftest 无 exec bit）→ 家族内 10/39 同为 -rw-rw-r-- 且统一 `bash scripts/` 调用，无实际影响，维持现状不单独处理（登记）

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 5 complete（终验交付） |
| 2 | Where am I going? | 交付报告 + INDEX/账本/memory 收尾 |
| 3 | What's the goal? | Goal 语句（上） |
| 4 | What have I learned? | 见 findings.md + notepad-learnings.md |
| 5 | What have I done? | 见 progress.md（P0-P4 段全 complete） |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
