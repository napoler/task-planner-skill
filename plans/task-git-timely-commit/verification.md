# Verification Contract & Phase Gates

## Goal (1 sentence)

为 task-planner skill 新增 Rule 27「工作产物及时提交」Phase 级 git 门控：实现类 Phase 翻转 complete 前产物必 commit（禁攒批/禁盲扫），终验与恢复场景联动核验，合并回 master 9b167fe。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: SKILL.md 执行循环含步骤 4.5「提交工作产物（Rule 27）」，位于步骤 4 与 5 之间
  Evidence: 主仓 `grep -n "4.5 \*\*提交工作产物" skills/task-planner/SKILL.md` → :120；Read :118-123 复核位置正确（回写计划之后、同步 Todo 之前）
- [x] VC-2: critical-rules.md Rule 27 全文（27.1-27.6）+ 注册表行 + References 表 1-27 + frontmatter 描述
  Evidence: `grep "### 27 工作产物及时提交" references/critical-rules.md` → :194；SKILL.md "Rule 27" 提及 ×5；References 表 :335 为 1-27
- [x] VC-3: 合规清单 C17 + 终验「git 提交核验」项
  Evidence: SKILL.md :216（C17）/ :189（终验项）
- [x] VC-4: worktree-isolation.md §4 ③ 逐 Phase 提交（Rule 27 联动,禁 add -A）
  Evidence: `grep -n "Rule 27" references/worktree-isolation.md` → :54
- [x] VC-5: smoke 全过 + master --no-ff 合并 + 清理完成 + 主仓范围无未提交变更
  Evidence: smoke **17 pass / 0 fail**；merge commit **9b167fe**（3 files +21/−4）；`git worktree list` 仅主仓；分支已删（was e99c34b）；`git status --porcelain -- skills/task-planner/` 为空

---

## Phase Gates

### Phase 1: 计划初始化与隔离区建立
**Depends on**: none
**Done when**: [x] 计划落盘+attest（06531a96）+worktree@5228d06+S1 映射
**Verification**: [x] V-1.1 conflict 预判安全（基线干净） [x] V-1.2 worktree 建立成功
Status: `complete` Last verified: 2026-09-05

### Phase 2: Rule 27 规则层编辑（worktree 内）
**Depends on**: Phase 1
**Done when**: [x] SKILL.md ×6 + critical-rules.md Rule 27 全文 + worktree-isolation.md ③
**Verification**: [x] V-2.1 grep VC-1~4 全过 [x] V-2.2 smoke 17/17 [x] V-2.3 Rule 27 dogfood：产物 e99c34b 逐 Phase 提交+porcelain 自检空
Status: `complete` Last verified: 2026-09-05

### Phase 3: 验证、合并回与终验
**Depends on**: Phase 2
**Done when**: [x] merge 9b167fe + 主仓 Read/grep 复验 + worktree/分支清理 + scope porcelain 空
**Verification**: [x] V-3.1 VC-5 全部证据 [x] V-3.2 check-complete exit 0（见终验记录）
Status: `complete` Last verified: 2026-09-05

---

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| SKILL.md 全文 | 4.5/C17/终验/注册表/References/frontmatter 六处插入点与既有措辞风格一致 | 符合 |
| critical-rules.md 全文 | Rule 27 编号顺延（1-26→27）、条文风格/半角标点/交叉引用格式对齐既有规则 | 符合 |
| worktree-isolation.md 全文 | §4 ③ 重写保持最小命令集形态,§4 合并回合约未动 | 符合 |
| check-3file-gate.sh / check-complete.sh | 确认零改动（职责单一原则）,脚本化硬门控列为遗留建议 | 符合 |

## 委派统计复验（Rule 25.4）
- [x] 委派率已统计:子代理执行 Phase 0 / 总数 3
- [x] 主进程直做 Phase 均在计划 Executor 字段登记例外理由（P1 git 编排 / P2 .md 白名单 / P3 git 编排+终验）
- [x] 委派率 0% 但均有登记理由 → 不触发 PARTIAL 降级

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查:触发 0 项,豁免 0 项,未处置 0 项
  - Q1 VC 5/5 全勾带证据;Q2 Test Results 全填;Q3 抽查 3 条（9b167fe diff/SKILL.md:120 Read/smoke 输出）均可复现;Q4 无子代理派发;Q5 见委派统计;Q6 非批量无 Batch Report 义务
- [x] Evidence 抽查 ≥3 条:路径可 Read、结论可复现（记录见 progress.md Phase 2/3）
- [x] 豁免登记:无
- [x] 无未处置违规 → 不触发 Rule 26.3 降级

## Goal Gate (终验)

```
## Goal Verification — Rule 27 工作产物及时提交门控落地
对照 Verification Contract 逐条复验：
- [x] VC-1: SKILL.md:120 步骤 4.5 → PASS
- [x] VC-2: critical-rules.md:194 全文 + 注册表/References/frontmatter 同步 → PASS
- [x] VC-3: SKILL.md:216 C17 + :189 终验项 → PASS
- [x] VC-4: worktree-isolation.md:54 逐 Phase 提交 → PASS
- [x] VC-5: smoke 17/17 + merge 9b167fe + 清理完成 + skills/ porcelain 空 → PASS

 outcome: COMPLETE
```

**遗留（不影响 COMPLETE,范围外/待用户决策）**：
1. 9 实体部署副本仍为 ad7900d（落后 master:去重 5228d06 + 本任务 9b167fe）——重部署待用户决策
2. 27.3 脚本化硬门控（check-complete.sh 增范围化 porcelain 检查）——可选后续任务
3. critical-rules.md:129 存在既有缺陷:重复的「21.5 拆分自检」段（22.7 与 23 之间）——本轮不修,建议随下次规则文件维护清理

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 已交付（outcome: COMPLETE） |
| 2 | Where am I going? | 无剩余 Phase;仅遗留项待用户决策 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
