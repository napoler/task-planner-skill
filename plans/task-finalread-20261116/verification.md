# Verification Contract & Phase Gates

## Goal (1 sentence)

superpowers 创作执行链（executing-plans / subagent-driven-development / using-superpowers）在交付前强制对最终成品文件做全文通读审查：新增 final-readthrough 技能+三处接线，文本条款零脚本。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: final-readthrough 技能在位且七铁律完整（整读/逐单元/全局一致性/需求对照/多文件逐一整读/留痕裁决/反作弊 七关键词各≥1；frontmatter name/description 合规）
  Evidence: /home/terry/.agents/skills/final-readthrough/SKILL.md（41 行）；grep 计数：整读:4 逐单元核对:1 全局一致性:1 需求对照:1 多文件逐一整读:1 留痕裁决:1 反作弊:2（Verifier 独立取证+主进程 Read 全文复核一致）
  **Verify command**: test -f /home/terry/.agents/skills/final-readthrough/SKILL.md && grep -c "整读" /home/terry/.agents/skills/final-readthrough/SKILL.md && grep -c "反作弊" /home/terry/.agents/skills/final-readthrough/SKILL.md
- [x] VC-2: executing-plans 含交付前通读门接线（REQUIRED SUB-SKILL 行+Integration 行；原 Step 3 顺延 Step 4 仍在）
  Evidence: /home/terry/.agents/skills/executing-plans/SKILL.md:36-37（Announce+REQUIRED SUB-SKILL）、:40（### Step 4: Complete Development）、:79（Integration 行）；grep final-readthrough=3
  **Verify command**: grep -c "final-readthrough" /home/terry/.agents/skills/executing-plans/SKILL.md && grep -n "Step 4: Complete Development" /home/terry/.agents/skills/executing-plans/SKILL.md
- [x] VC-3: subagent-driven-development 四锚点接线（流程图节点/边、正文 Final Read-Through 段、Integration 列、Red Flags 行）
  Evidence: /home/terry/.agents/skills/subagent-driven-development/SKILL.md:66（图节点）、:82-83（两条新边）、:221-223（正文段）、:396（Red Flags）、:421（Integration）；grep final-readthrough=5
  **Verify command**: grep -c "final-readthrough" /home/terry/.agents/skills/subagent-driven-development/SKILL.md && grep -n "## Final Read-Through" /home/terry/.agents/skills/subagent-driven-development/SKILL.md
- [x] VC-4: using-superpowers 双位（zcode+agents）Red Flags 含通读条款且 diff=0
  Evidence: 双位 :51 同一行条款；diff 双位=空 → TWIN-IDENTICAL（主进程与 Verifier 双取证一致）
  **Verify command**: diff /home/terry/.zcode/skills/using-superpowers/SKILL.md /home/terry/.agents/skills/using-superpowers/SKILL.md && grep -c "final-readthrough" /home/terry/.zcode/skills/using-superpowers/SKILL.md
- [x] VC-5: zcode 位改动经 worktree 开发 merge 回 main 且 worktree/分支清理
  Evidence: git log 5cd47a2 merge(task-finalread-20261116)+dd35940 feat；worktree list 无 task-finalread；branch wt/task-finalread* 空
  **Verify command**: git -C /home/terry/.zcode log --oneline -2 && git -C /home/terry/.zcode worktree list && git -C /home/terry/.zcode branch --list "wt/task-finalread*"
- [x] VC-6: agents 位 3 被改文件改前备份在位（md5 一致）且改动为纯文本条款（零脚本零 hook）
  Evidence: backups/ 3 .bak 与记录 md5 一致（b54aa371/ddce193f/49ffa86b）；diff backup vs current 仅文本条款新增/顺延（sdd 一处图边替换属流程图文本重排）；Verifier 判定无脚本/hook/机器门内容
  **Verify command**: md5sum /mnt/data/dev/task-planner-skill/plans/task-finalread-20261116/backups/executing-plans.SKILL.md.bak /mnt/data/dev/task-planner-skill/plans/task-finalread-20261116/backups/subagent-driven-development.SKILL.md.bak /mnt/data/dev/task-planner-skill/plans/task-finalread-20261116/backups/using-superpowers.SKILL.md.bak

---

## Phase Gates

### Phase 1: Requirements & Discovery
**Goal**: 定位创作链交付前通读缺口的技能载体与镜像拓扑
**Depends on**: none
**Done when**: 四技能现状+镜像差异+git 归属证据落 findings.md
**Verification**:
- [x] V-1.1 (VC-4): 双位镜像拓扑与 diff 形态已实测 — **Verify command**: diff /home/terry/.zcode/skills/using-superpowers/SKILL.md /home/terry/.agents/skills/using-superpowers/SKILL.md
- [x] V-1.2 (VC-1): 缺口定位=执行链两路径无成品通读（executing-plans:33-38 直进 finishing；sdd 最终审查=code-reviewer diff 向） — **Verify command**: grep -n "Complete Development" /home/terry/.agents/skills/executing-plans/SKILL.md
Status: `complete` Last verified: 2026-11-16

### Phase 2: Planning & Structure
**Goal**: CA-1..6 变更标注+设计文本定稿+VC 表+隔离决策
**Depends on**: Phase 1
**Done when**: task_plan.md 含 R 逐字原文/R→VC/CA 表/设计文本唯一真源
**Verification**:
- [x] V-2.1 (VC-6): 备份先行（S1） — **Verify command**: ls /mnt/data/dev/task-planner-skill/plans/task-finalread-20261116/backups/
- [x] V-2.2 (VC-1): 设计文本七铁律完整 — **Verify command**: grep -c "铁律" /mnt/data/dev/task-planner-skill/plans/task-finalread-20261116/task_plan.md
Status: `complete` Last verified: 2026-11-16

### Phase 3: Implementation
**Goal**: 五文件落盘（新建 1+编辑 4）+worktree merge+清理
**Depends on**: Phase 2
**Done when**: S1-S5/S7 全 complete，主进程 diff 复核原文零删
**Verification**:
- [x] V-3.1 (VC-2/VC-3): 两执行链接线在位 — **Verify command**: grep -c "final-readthrough" /home/terry/.agents/skills/executing-plans/SKILL.md /home/terry/.agents/skills/subagent-driven-development/SKILL.md
- [x] V-3.2 (VC-5): merge 回 main+清理 — **Verify command**: git -C /home/terry/.zcode log --oneline -2
Status: `complete` Last verified: 2026-11-16

### Phase 4: Testing & Verification
**Goal**: Verifier 独立复核 VC-1..6
**Depends on**: Phase 3
**Done when**: Verifier 报告全 PASS 且与主进程实测交叉一致
**Verification**:
- [x] V-4.1 (VC-1..6): Verifier status=PASS，证据逐条贴命令输出 — **Verify command**: bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-finalread-20261116
- [x] V-4.2 (VC-4): 双取证面交叉一致（主进程 grep/diff + Verifier 独立命令） — **Verify command**: diff /home/terry/.zcode/skills/using-superpowers/SKILL.md /home/terry/.agents/skills/using-superpowers/SKILL.md && echo TWIN-IDENTICAL
Status: `complete` Last verified: 2026-11-16

### Phase 5: Delivery
**Goal**: 簿记 commit+check-complete+归档+记忆+交付总结
**Depends on**: Phase 4
**Done when**: 本仓 plans/ 目录入库；check-complete exit 0；记忆落盘
**Verification**:
- [x] V-5.1: scope porcelain 清空（Rule 27.3） — **Verify command**: git -C /mnt/data/dev/task-planner-skill status --porcelain -- plans/task-finalread-20261116/
- [x] V-5.2: 记忆文件在位 — **Verify command**: test -f /home/terry/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/task-finalread-20261116.md && echo MEMORY-OK
Status: `complete` Last verified: 2026-11-16

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| superpowers 家族既有技能风格（executing-plans/writing-plans 原文） | 新技能与接线文本沿用 REQUIRED SUB-SKILL/Red Flags/Integration 惯例 | 符合（家族英文框架+条款中文，与用户自有技能一致） |
| Rule 25.3 六项白名单（critical-rules-dispatch.md:108） | Executor 字段例外理由逐条带编号 | 符合（①②③ 编号命中，stats verdict=ok） |

## 委派统计复验（Rule 25.4）

JSON 输出（2026-11-16 终验实测）：
```json
{"phases_total":5,"phases_delegated":2,"main_direct_count":3,"delegation_rate":0.400,"main_direct":[{"phase":"1 Requirements & Discovery","reason":"例外理由:③ 机械验证命令——只读调研四技能+镜像 diff+git 归属, 输出可控, 证据在 findings.md——Rule 25.3 白名单③","self_declared":0},{"phase":"2 Planning & Structure","reason":"例外理由:② 计划系统文件维护——Rule 25.3 白名单","self_declared":0},{"phase":"5 Delivery","reason":"例外理由:① git 编排+② 簿记——Rule 25.3 白名单","self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单③/②/①②）
- [x] 委派率 0.4 < 0.7 但直做理由全部命中白名单 → 按 25.4a `DELEGATION RATE WHITELIST-EXEMPT` 放行不降级（verdict=ok, violations=[]）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 2 项（写守卫拦截、分支名不存在）,豁免 0 项,未处置 0 项（均已进 Error Log 闭环）
- [x] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录=VC-1/4/5 三条主进程亲测复跑
- [x] 豁免登记: 无（无用户文字豁免需求）
- [x] 无未处置违规 → outcome 不降级

## Goal Gate (终验)

```
## Goal Verification — superpowers 创作链交付前强制全文通读审查
对照 Verification Contract 逐条复验：
- [x] VC-1: 技能在位七铁律全（Verifier: 关键词计数全≥1; 主进程 Read 全文复核） → PASS
- [x] VC-2: executing-plans :36-37/:40/:79 接线 → PASS
- [x] VC-3: sdd :66/:82-83/:221-223/:396/:421 五处接线 → PASS
- [x] VC-4: 双位 :51 TWIN-IDENTICAL → PASS
- [x] VC-5: merge 5cd47a2+清理完成 → PASS
- [x] VC-6: 备份 md5 一致+纯文本条款 → PASS

 outcome: COMPLETE
```

## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| 五文件改动正确性 | 主进程 diff backup vs current+grep -c 计数（本会话实测） | Verifier 独立只读取证（agent_4294c53c，VC-1..6 全 PASS） | 一致 PASS |
| 双位同步 | diff 双位 SKILL.md=空 → TWIN-IDENTICAL | Verifier 独立 diff+grep :51 双位命中 | 一致 PASS |
| 隔离合规 | git log 5cd47a2/dd35940+worktree list+branch 空 | Verifier 独立 git 三命令取证 | 一致 PASS |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 5 收尾 |
| 2 | Where am I going? | 簿记 commit→归档→交付总结 |
| 3 | What's the goal? | 见 Goal 行 |
| 4 | What have I learned? | 见 findings.md |
| 5 | What have I done? | 见 progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
