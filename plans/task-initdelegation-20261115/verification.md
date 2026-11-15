# Verification Contract & Phase Gates

## Goal (1 sentence)

将 task-planner 技能固化为：L1+ 任务在初始化阶段（需求分析+计划文档创建）首动作委派子代理执行，主代理仅回收结构化收据并承担会话绑定/展示确认职责，同时保持 L0/mini/trivial 轻量路径不变。

---

## Verification Contract（VC→验证命令映射，Rule 84.1）

> 终验前逐条执行 Verify command；证据落盘到 progress.md / findings.md 对应锚点。以下命令以源仓根 `/mnt/data/dev/task-planner-skill` 为基准执行。

- [ ] VC-1: R1 首动作委派条款落位（L1+ init 后第一动作委派计划子代理，产出需求分析+计划文档）
  Evidence: `skills/task-planner/SKILL.md` 初始化/计划确认相关段落 diff + 关键行
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -nE "首动作委派|计划子代理|需求分析.*计划文档|L1\+" skills/task-planner/SKILL.md
- [ ] VC-2: R1 收据契约与主代理最小回收落位（含 task_id/files_created/open_questions/摘要；主代理仅回收收据）
  Evidence: `skills/task-planner/SKILL.md` 或 `references/critical-rules.md` 收据契约文本
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -nE "task_id|files_created|open_questions|收据|摘要" skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md
- [ ] VC-3: R2 动机与轻量豁免明确（隔离/激活率/降上下文；L0/mini/trivial 豁免不变）
  Evidence: 条款文本包含动机与豁免语句
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -nE "隔离|激活率|上下文占用|L0/mini/trivial|豁免|比例原则" skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md
- [ ] VC-4: 会话绑定脚本与确认流程归主进程边界清晰（init-session/attest/set-active/plan-created/哨兵/D1 不由计划子代理执行）
  Evidence: 条款边界声明 + 与现有 D1/attest 描述一致
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -nE "init-session.sh|attest-plan.sh|set-active-plan.sh|plan-created.cjs|哨兵|主进程|会话绑定" skills/task-planner/SKILL.md
- [ ] VC-5: R3 固化为技能条款且编号/索引一致（若新增 Rule：已 reserve/land 且索引更新；若仅 SKILL 条款：有明确可审计条款块）
  Evidence: git diff + rule-reserve 账本/条文存在性
  **Verify command**: cd /mnt/data/dev/task-planner-skill && (grep -nE "^### 109 |Rule 109" skills/task-planner/references/critical-rules.md || grep -n "首动作委派" skills/task-planner/SKILL.md)
- [ ] VC-6: 改前基线与改后自测零增量 FAIL（记录基线与回归结果）
  Evidence: progress.md 基线/回归表 + selftest 输出摘要文件或日志路径
  **Verify command**: cd /mnt/data/dev/task-planner-skill && test -f plans/task-initdelegation-20261115/progress.md && grep -nE "基线|零增量|FAIL|PASS" plans/task-initdelegation-20261115/progress.md
- [ ] VC-7: 源仓与部署位对账完成（~/.zcode/skills/task-planner、~/.agents/skills/task-planner 关键文件一致或差异已登记）
  Evidence: diff 输出/摘要记录于 progress.md
  **Verify command**: cd /mnt/data/dev/task-planner-skill && diff -rq skills/task-planner ~/.zcode/skills/task-planner >/tmp/task-initdelegation-diff-zcode.txt; echo "zcode_diff_exit=$?"; diff -rq skills/task-planner ~/.agents/skills/task-planner >/tmp/task-initdelegation-diff-agents.txt 2>/tmp/task-initdelegation-diff-agents.err; echo "agents_diff_exit=$?"

---

## Phase Gates

### Phase 1: 锚定、基线与设计定稿

**Goal**: 锁定 SKILL/规则改动锚点、建立 selftest 基线、定稿条款形态与 Rule 编号策略。

**Depends on**: none

**Done when**:
- [x] 改动锚点与条款形态（SKILL + 是否新增 core Rule）在 findings/decisions 定稿
- [x] selftest 基线记录在位
- [x] Rule 编号 check/next 证据记录（实施前 reserve 计划明确）

**Verification**:
- [x] V-1.1: [mapped to VC-5 设计输入] 规则编号候选与账本状态已核对
  **Verify command**: cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/rule-reserve.sh next
- [x] V-1.2: [mapped to VC-6 基线前置] 基线证据已写入 progress.md
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -n "基线" plans/task-initdelegation-20261115/progress.md

Status: `complete` Last verified: 2026-11-15（next=109 只读留痕；Q1 定稿 SKILL-only 不占号；基线 97 脚本 PASS=94 FAIL=3 落 progress.md:38-49）

---

### Phase 2: 条款实现（worktree）

**Goal**: 在隔离 worktree 中完成 SKILL.md 与 core 规则/必要文档条款落地。

**Depends on**: Phase 1

**Done when**:
- [x] L1+ 首动作委派、收据契约、主进程边界、轻量豁免条款落位
- [x] 文档间引用/索引一致

**Verification**:
- [x] V-2.1: [mapped to VC-1, VC-2, VC-4] SKILL 条款与边界关键字可检索
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -n "首动作委派" skills/task-planner/SKILL.md
- [x] V-2.2: [mapped to VC-3, VC-5] 豁免与规则条款/索引在位
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -nE "L0/mini/trivial|豁免" skills/task-planner/SKILL.md

Status: `complete` Last verified: 2026-11-15（worktree 2bb24f4 +9 行；V-N 直跑 VC-1..VC-5 全 PASS；critical-rules.md 按 Q1 无操作）

---

### Phase 3: 守护与自测回归

**Goal**: 补齐必要守护/selftest 并证明零增量 FAIL。

**Depends on**: Phase 2

**Done when**:
- [x] 受影响 selftest 执行完成并记录
- [x] 相对基线无新增 FAIL

**Verification**:
- [x] V-3.1: [mapped to VC-6] 回归结果记录在 progress.md
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -n "零增量" plans/task-initdelegation-20261115/progress.md
- [x] V-3.2: [mapped to VC-6] 关键自测脚本可执行/存在性核对（按实施定稿清单）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && ls skills/task-planner/scripts/selftest*.sh | wc -l

Status: `complete` Last verified: 2026-11-15（终态 FAIL=2 全为基线既有环境差异；BP-08 插入致超限已最小修复 dcf7190；本任务引起 FAIL=0）

---

### Phase 4: 部署与对账

**Goal**: 源仓改动部署到运行位并完成 diff 对账。

**Depends on**: Phase 3

**Done when**:
- [x] ~/.zcode 与 ~/.agents 部署位同步
- [x] diff 结果记录（无意外差异）

**Verification**:
- [x] V-4.1: [mapped to VC-7] zcode 部署位 diff 已执行
  **Verify command**: test -d ~/.zcode/skills/task-planner && diff -rq /mnt/data/dev/task-planner-skill/skills/task-planner ~/.zcode/skills/task-planner; echo $?
- [x] V-4.2: [mapped to VC-7] agents 部署位 diff 已执行
  **Verify command**: test -d ~/.agents/skills/task-planner && diff -rq /mnt/data/dev/task-planner-skill/skills/task-planner ~/.agents/skills/task-planner; echo $?

Status: `complete` Last verified: 2026-11-15（4 位同步：zcode/agents/claude/cursor scope 2 文件 diff=0 主进程实锚复核；位上既有差异（zcode 2/agents 175/cursor 8）登记未动）

---

### Phase 5: 终验与交付

**Goal**: 全 VC 复验、收尾回读、交付结论与归档前置条件就绪。

**Depends on**: Phase 4

**Done when**:
- [x] VC-1..VC-7 全部有证据
- [x] 收尾回读梳理记录完成且 outcome 判定明确

**Verification**:
- [x] V-5.1: [mapped to VC-1..VC-5] 条款与契约关键证据齐备
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -n "首动作委派" skills/task-planner/SKILL.md
- [x] V-5.2: [mapped to VC-6, VC-7] 回归与部署证据已登记
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -nE "零增量|diff|部署" plans/task-initdelegation-20261115/progress.md

Status: `complete` Last verified: 2026-11-15（run-verification PASS=8 FAIL=0 统一入口实测）

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| skills/task-planner/SKILL.md 计划制作循环 | 改后条款与 D1/attest/sentinel 语义一致性对照 | **符合**——条款为纯增量插入（前锚清除哨兵行/后锚智能子动作行完整保留），D1/attest/哨兵段零改动（结构回读+VC-4 grep 佐证） |
| references/critical-rules.md（核心域约束） | 新增/修改 Rule 编号、索引、域边界检查 | **符合**——Q1 定稿 SKILL-only，本文件零改动（CA-2 关闭），无编号占用（109 水位释放） |

## 委派统计复验（Rule 25.4）

```bash
# 终验时执行并粘贴
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-initdelegation-20261115
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"main_direct":[{"phase":"5 终验与交付","executor":"主进程（例外理由:② 簿记与终验编排/证据汇总——Rule 25.3 白名单）"}],"violations":[]}
```
（2026-11-15 终验实测；P2 Executor 字段曾误写 code-assistant(sonnet)=未登记类型名致 verdict=violation，已校正为实际执行体 general-purpose 并重锁 attest 后复跑=ok）

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [x] 委派率达标或白名单例外合法（0.80 ≥ 0.7）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（无降质行为观察：无伪造证据/无静默失败/无范围蔓延；子代理产出全部盘上复核）
- [x] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 ① evidence/VC-1.out（grep 条款锚实跑）② evidence/VC-7.out（部署位 diff 实跑）③ progress.md Phase3 段 BP-08 修复+dcf7190 提交（git 实测）——3/3 复现
- [x] 豁免登记:无
- [x] 存在未处置违规 → outcome 已按 Rule 26.3 降级（无未处置违规，不适用）

## Goal Gate (终验)

- [x] VC-1: evidence/VC-1.out（条款锚 grep 实跑 exit=0）→ PASS
- [x] VC-2: evidence/VC-2.out（收据契约字段 grep 实跑 exit=0）→ PASS
- [x] VC-3: evidence/VC-3.out（动机+豁免 grep 实跑 exit=0）→ PASS
- [x] VC-4: evidence/VC-4.out（会话绑定边界 grep 实跑 exit=0）→ PASS
- [x] VC-5: evidence/VC-5.out（SKILL-only fallback 分支命中 exit=0）→ PASS
- [x] VC-6: evidence/VC-6.out（基线/零增量证据 grep exit=0）→ PASS
- [x] VC-7: evidence/VC-7.out（部署位 diff 实跑 exit=0；zcode 既有差异 2 项已登记）→ PASS

 outcome: COMPLETE（2026-11-15，run-verification PASS=8 FAIL=0 统一入口实测）

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1（计划已产出，待执行） |
| 2 | Where am I going? | Phase 1-5 完成条款固化、回归、部署与终验 |
| 3 | What's the goal? | L1+ 初始化首动作委派子代理固化入 task-planner，主代理仅回收收据 |
| 4 | What have I learned? | 见 findings.md / knowledge-brief.md |
| 5 | What have I done? | 见 progress.md（含 dogfood 派发降级留痕） |
| 6 | Which tasks need processing? | 本任务执行与终验；完成后按 Rule 81 归档 |