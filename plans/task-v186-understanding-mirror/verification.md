# Verification Contract & Phase Gates

## Goal (1 sentence)

核心 Rule 80 增补 80.7「理解镜像」配对机制并更新模板/指针配对格式，回归零破坏合并回 master。

---

## Verification Contract (6 items)

- [ ] VC-1: 80.7 条款在位且 80.1-80.6 零改动
  **Verify command**: grep -c "^80.7 \*\*理解镜像" skills/task-planner/references/critical-rules.md; git diff 16951ff..HEAD -- skills/task-planner/references/critical-rules.md | grep -c "^-80\."
  Evidence: 首条=1；次条=0（80.x 无删改行）
- [ ] VC-2: 配对格式落位（专档模板/计划模板指针/SKILL 指针）
  **Verify command**: grep -c "理解镜像" skills/task-planner/templates/user-session-log.md skills/task-planner/templates/task_plan.md skills/task-planner/SKILL.md
  Evidence: ≥2 / ≥1 / ≥1
- [ ] VC-3: 80.7 语义承载 R3-R5
  **Verify command**: grep -c "非权威" skills/task-planner/references/critical-rules.md; grep -c "镜像更正" skills/task-planner/references/critical-rules.md; grep -c "理解偏差" skills/task-planner/references/critical-rules.md
  Evidence: 各 ≥1
- [ ] VC-4: 全量回归零破坏
  **Verify command**: bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 | tail -3
  Evidence: 末行 FAIL=0
- [ ] VC-5: dogfood 配对在本任务专档生效
  **Verify command**: grep -c "#1 理解镜像" plans/task-v186-understanding-mirror/user-session-log.md
  Evidence: =1 且 #1 逐字条目在位
- [ ] VC-6: 合并收口干净
  **Verify command**: git status --short | grep -v "^?? plans/" | wc -l; git worktree list | grep -c task-v186; git log --oneline -5 | grep -c "merge(task-v186)"
  Evidence: 0 / 0 / 1

---

## Phase Gates

### Phase 1: 计划与隔离基线
**Goal**: 计划锁定+worktree 就绪+专档 dogfood 配对
**Done when**: attest exit 0；worktree 干净；#1 配对条目在位
**Verification**:
- [ ] V-1.1: VC-5 命令（映射 VC-5）
- [ ] V-1.2: resolve/worktree 核验（映射 VC-6）
Status: `in_progress` Last verified: 2026-10-17

### Phase 2: 80.7 与配对格式落地
**Goal**: 四文件编辑点落地（worktree）
**Done when**: S1/S2 产物 grep 验收过+主进程复核+drift 检查
**Verification**:
- [ ] V-2.1: VC-1 命令组（映射 VC-1）
- [ ] V-2.2: VC-2/VC-3 命令组（映射 VC-2, VC-3）
Status: `pending` Last verified: —

### Phase 3: 全量回归
**Goal**: selftest FAIL=0
**Done when**: 末行 FAIL=0
**Verification**:
- [ ] V-3.1: 汇总行贴 progress（映射 VC-4）
- [ ] V-3.2: SL-01..11 脚本单独 rc=0 抽查（映射 VC-4）
Status: `pending` Last verified: —

### Phase 4: 合并回主仓
**Goal**: --no-ff 合并+清理
**Done when**: merge 在 log+worktree=0
**Verification**:
- [ ] V-4.1: VC-6 命令组（映射 VC-6）
- [ ] V-4.2: 主仓 grep 复验（映射 VC-1）
Status: `pending` Last verified: —

### Phase 5: 终验与交付
**Goal**: CR+独立复验+对齐审查+簿记收口
**Done when**: 三门 APPROVED+VC 全 PASS+归档簿记
**Verification**:
- [ ] V-5.1: 六项 VC 终态全 PASS（映射 VC-1..6）
- [ ] V-5.2: delivery-summary 五要素落盘（映射 VC-6）
Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| Rule 80 现行全文 | VC-1 次条（80.x 零删改） | （终验填） |
| SL 断言面 | VC-4（含 session-log selftest 抽查） | （终验填） |

## 委派统计复验（Rule 25.4）

```bash
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-v186-understanding-mirror
```
JSON 输出：（终验粘贴）
- [ ] 主进程直做 Phase 均登记白名单例外理由
- [ ] stats verdict 以实跑为准

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 终验核查（终验填）；豁免：无

## Goal Gate (终验)
（终验填 outcome）

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 1 |
| 2 | Where am I going? | Phase 2-5 |
| 3 | What's the goal? | Goal 段（80.7 配对机制） |
| 4 | What have I learned? | findings.md |
| 5 | What have I done? | progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（他任务） |
