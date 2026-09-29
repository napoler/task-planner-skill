# Verification Contract & Phase Gates

## Goal (1 sentence)

落地 critical-rules.md Rule 40「harness 工具面主动选择」（六子条,零新 config 键），同步 SKILL.md 四锚 + 三类模板 + 卫星两文档 + plan-writer 契约 + 新建 selftest-tool-selection.sh，全量 selftest 0 FAIL 后合并回 master（52b434f）且三部署位 IDENTICAL、worktree 清理。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: Rule 40 六子条全文在位且 grep 可验
  Evidence: `grep -c '^40\.' skills/task-planner/references/critical-rules.md` = 6（L397-402）;40.3 含「不可代调、不可读取其运行态」;40.6 含「零新 config 键」+`selftest-tool-selection.sh`;纯增 deletions=0（progress.md Phase 2 + selftest TS-01..03 PASS）
- [x] VC-2: SKILL.md 四锚同步 + 行数断言过
  Evidence: `grep -c 'Rule 40' SKILL.md` = 5（协同路由 L48/C28 L193/索引 L241/摘要 L271/References L295）;`grep -c 'Rules 1-39'` = 2、`1-40` = 0;SKILL 433 行,selftest-skill-split 上限 433;knowledge-brief/skill-collab/skill-split/execution-stability/batch-pilot 五脚本 Total 0 FAIL（progress.md Phase 2）
- [x] VC-3: 模板层三落点在位
  Evidence: general 模板 L133「🧰 工具选择与编排」区块（+14,含定位声明「上游分析记录,不替代」）;mini-lite 豁免声明行（45≤80）;subagent_dispatch 工具面提示行;init-session /tmp 冒烟 6/6;selftest-plan-tier 32/0+selftest-dispatch 29/0（progress.md Phase 3）
- [x] VC-4: 卫星与 agent 契约在位 + 零回归
  Evidence: template-mapping §十 L232（+15 纯增,§九 零删改）;template-guide 场景 5（+11）;plan-writer.md 义务行（+1）;methodology 16/0 + conclusion-discipline 24/0;锚「问题解构四问」「纯数字」计数改前改后相等（progress.md Phase 4）
- [x] VC-5: 新 selftest 过 + 全量回归 0 FAIL
  Evidence: selftest-tool-selection.sh `Total: 12 PASS=12 FAIL=0`;registry tsv 38 行 rows=actual=37（selftest-registry 5/0）;全量 **37 脚本 604 PASS / 0 FAIL**（主进程逐 Total 行机械求和,P5-S3;基线 592+新增 12 咬合）（progress.md Phase 5）
- [x] VC-6: 合并部署收尾闭环
  Evidence: smart-merge-back RC=0（V1-V6 全 OK）→ merge commit **52b434f**;三部署位 IDENTICAL（对账基准=主仓,CR P2-a 修复后 diff -r 三位复验再确认）;`git worktree list` 无本任务残留=0、`git branch --list 'wt/task-v097*'`=0;merge_back=merged(52b434f)（progress.md Phase 6）
- [x] VC-7: 边界与无回归
  Evidence: 39.1（CRIT L373）与 39.7 区块零进变更集（CR 专项① PASS: CRIT diff 0 deletions in 1-391 段）;39.7.2 未触碰;40.3 披露措辞在位（CR 专项② PASS）;36 既有脚本零回归（604/0 全量含既有 592 全绿）+ CR 独立复跑 12 个受影响 selftest 全 0 FAIL（11-code-reviewer.md）

---

## Phase Gates

### Phase 1: 基线测绘与 worktree 创建
**Goal**: worktree 隔离区就绪 + 全量基线定数 + 级联锚清单
**Depends on**: none
**Done when**: worktree 创建且干净;基线求和落 progress
**Verification**:
- [x] V-1.1 (VC-5): worktree 内全量 36 脚本 592/0（含 final-gate-hash 22）
- [x] V-1.2 (VC-7): 级联锚清单（5 处 ≤558+≤430+4 宽容锚+WF-10）登记,对策 b 确证
Status: `complete` Last verified: 2026-09-30

### Phase 2: 条款层 Rule 40 与 SKILL 同步
**Goal**: Rule 40 六子条纯增 + SKILL 四锚同步 + 行数级联
**Depends on**: Phase 1
**Done when**: `^40\.` =6;四锚在位;断言过;commit
**Verification**:
- [x] V-2.1 (VC-1): 六子条在位,纯增 11 行
- [x] V-2.2 (VC-2): SKILL 433 行,五脚本 0 FAIL
- [x] V-2.3 (VC-7): WF 锚保全,commit a83a8c6
Status: `complete` Last verified: 2026-09-30

### Phase 3: 模板层
**Goal**: general 区块 + mini-lite 豁免 + dispatch 提示行
**Depends on**: Phase 2
**Verification**:
- [x] V-3.1 (VC-3): 三落点 grep 全中,冒烟 6/6
- [x] V-3.2 (VC-7): plan-tier 32/0 + dispatch 29/0,commit 676319a
Status: `complete` Last verified: 2026-09-30

### Phase 4: 卫星层与 agent 契约
**Goal**: mapping §十 + guide 场景 5 + plan-writer 义务行
**Depends on**: Phase 3
**Verification**:
- [x] V-4.1 (VC-4): 三落点在位,锚零破坏
- [x] V-4.2 (VC-7): methodology 16/0 + conclusion-discipline 24/0,commit 21ae9f1
Status: `complete` Last verified: 2026-09-30

### Phase 5: selftest 与全量回归
**Goal**: selftest-tool-selection 12 断言 + registry + 全量 0 FAIL
**Depends on**: Phase 4
**Verification**:
- [x] V-5.1 (VC-5): 12/0 首跑,registry rows=actual=37
- [x] V-5.2 (VC-1): 全量 604/0,commit ccfc70f
Status: `complete` Last verified: 2026-09-30

### Phase 6: 合并回与三位部署
**Goal**: smart-merge-back --deploy + companion 同步 + 清理
**Depends on**: Phase 5
**Verification**:
- [x] V-6.1 (VC-6): RC=0,52b434f,三位 IDENTICAL,清理 0/0
- [x] V-6.2 (VC-4): companion zcode/claude 位义务行各 1;opencode 位现状保持（silent 决策）
Status: `complete` Last verified: 2026-09-30

### Phase 7: CR Gate 与终验簿记
**Goal**: CR APPROVED + 终验交付
**Depends on**: Phase 6
**Verification**:
- [x] V-7.1 (VC-7): CR 结论 APPROVED（7 专项全 PASS,零 P0/P1;11-code-reviewer.md）
- [x] V-7.2 (VC-6): CR P2-a 修复（注释 430→433）+commit+三位 diff -r 复验 IDENTICAL
Status: `complete` Last verified: 2026-09-30

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| Rule 39 全文（CRIT L339-390） | Rule 40 格式同构（节头/子条行首形态） | 符合（`^40\.` =6 同构 `^39\.`） |
| SKILL 四锚现状 | 四锚逐字落位（L48/L193/L271 行内括注 ×2） | 符合（WF-07/08/09 锚保全双证） |
| 行数断言基线五处 | skill-split 上限 433+label;四处 ≤558 复跑 0 FAIL | 符合（偏离仅计划内上调,登记 task-v097） |
| rule-enhancement 模板范式 | 计划结构（VC/约束/FMEA）对标 | 符合 |
| selftest+registry 范式 | TS-01..12 同构 WF ok/bad/Total;registry 动态口径 | 符合（registry.sh 零改动=动态 comm 口径正确理解） |

## 委派统计复验（Rule 25.4）

JSON 输出（check-delegation.sh stats 原文,2026-09-30）:
```json
{"phases_total":7,"phases_delegated":4,"main_direct_count":3,"delegation_rate":0.571,"main_direct":[Phase 1 ①③/Phase 6 ①③/Phase 7 ⑤② 全白名单理由],"violations":[],"verdict":"ok"}
```
- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（①③⑤② 全中 Rule 25.3 六项白名单）
- [x] 委派率 0.571 < 0.7 → **25.4a WHITELIST-EXEMPT 放行**（理由全白名单,verdict=ok,violations 空）;另 P5-S3/P2-S3/备份移出由主进程直做,已登记 Decisions Made（理由同白名单③①）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查: 触发 1 项（P4 两次 partial 的任务书验收口径缺陷→已裁定+Error Log+Prevention 沉淀）;豁免 0 项;未处置 0 项
- [x] Evidence 抽查 ≥3 条: ① CRIT `^40\.`=6 主进程亲跑 ✓ ② 全量 604/0 主进程求和 ✓ ③ 三位 diff -r IDENTICAL 主进程亲跑 ✓;子代理产出全部 Read 复核（05/06/07/08/09/10/11 checkpoint 或 diff 亲验）
- [x] 豁免登记: 无（无用户显式豁免需求）
- [x] 未处置违规: 无 → outcome 不降级

## Goal Gate (终验)

```
## Goal Verification — Rule 40 工具面主动选择落地+全链同步+合并部署
- [ ] → [x] VC-1: 六子条 grep=6,纯增（progress P2/selftest TS-01..03/CR 专项⑤） → PASS
- [x] VC-2: SKILL 五锚+433 行+五脚本 0 FAIL → PASS
- [x] VC-3: 模板三落点+冒烟+plan-tier/dispatch 0 FAIL → PASS
- [x] VC-4: 卫星两文档+plan-writer 契约+四脚本 0 FAIL → PASS
- [x] VC-5: selftest 12/0+registry rows=actual+全量 604/0 → PASS
- [x] VC-6: 52b434f+三位 IDENTICAL+清理 0/0 → PASS
- [x] VC-7: 39 系原文零触碰+40.3 披露+CR APPROVED → PASS

 outcome: COMPLETE
```

**遗留披露（不阻塞 COMPLETE）**:
1. CR P2-b: companion/.backup-* 安装备份残留 → 已按用户既有政策（memory: 备份禁留技能扫描路径）移出至 ~/skill-deploy-backups-task-v097/（未删除,规避 rm -rf 授权门槛）;`.gitignore` 增补 `.backup-*/` 模式属基建配置修改,留用户后续裁决
2. CR P2-c: SKILL.md:10 frontmatter 索引未括注 Rule 40（PT-08 锚约束下的有意保守,CR 自评信息性缺口非违约）→ 维持现状
3. opencode 位无 agents/plan-writer.md（该平台 agent 生态异构,现状保持;其 skills 消费面已 IDENTICAL 覆盖）
4. install-companion 部署提示"更新的文件需重启会话生效"——plan-writer 契约改动对新会话生效

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 7 complete（终验交付） |
| 2 | Where am I going? | 交付报告+memory 沉淀 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | findings.md+notepad-learnings.md |
| 5 | What have I done? | progress.md（7 Phase 全 complete） |
| 6 | Which tasks need processing? | 无（INDEX complete） |
