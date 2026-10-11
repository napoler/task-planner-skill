# 19-merge-resolution — Phase 6 合并冲突机械解决单元

**执行时间**: 2026-10-10
**Worktree**: /mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context
**状态**: complete

## 逐文件策略与核验

### 1. selftest-research-first.sh
- **冲突位置**: 行 73-79（RF-06/RF-07 断言块）
- **策略**: 取 HEAD 侧（1-67 演进），RF-06 `cnt '1-67'`、RF-07 整串 `Critical Rules 1-67（含 Rule 40-67 全集`
- **核验**: bash -n OK；单跑 12/12 PASS exit 0

### 2. selftest-lane-advancement.sh
- **冲突位置**: 行 132-141（LA-12 断言块）
- **策略**: 保留 master 侧演进注释（旧代 1-66），代码取 HEAD 侧（1-67）；`1-39` 负断言零改动
- **核验**: bash -n OK；单跑 14/14 PASS exit 0

### 3. selftest-self-resolution.sh
- **冲突位置**: 行 74-84（SR-07 断言块）
- **策略**: 保留 master 侧演进注释（旧代 1-66），放 HEAD 侧演进注释+代码（新代 1-67）；SR-12 零改动
- **核验**: bash -n OK；单跑 13/13 PASS exit 0

### 4. selftest-tool-selection.sh
- **冲突位置**: 行 60-70（TS-05 断言块）
- **策略**: 保留 master 侧演进注释（旧代 1-66），放 HEAD 侧演进注释+代码（新代 1-67）
- **核验**: bash -n OK；单跑 12/12 PASS exit 0

### 5. selftest-requirement-coverage.sh
- **冲突位置**: 行 127-141（RC-11 断言块）
- **策略**: 保留 master 侧演进注释（旧代 1-66），放 HEAD 侧演进注释+代码（新代 1-67）；RC-15 `^66\.`=6 正钉原样保留（不在冲突块内，零改动）
- **核验**: bash -n OK；单跑 23/23 PASS exit 0

### 6. selftest-workflow-orchestration.sh
- **冲突位置**: 无冲突标记（已自动合并）
- **策略**: 无需处理；WF-10 循环 grep 与文案已正确演进到 1-67
- **核验**: bash -n OK；单跑 16/16 PASS exit 0

### 7. selftest-skill-split.sh
- **冲突位置**: 行 46-52（T-主 行数钉断言块）
- **策略**: 保留 master 侧演进注释（旧代 515），放 HEAD 侧演进注释（新代 518，C45→C46 折叠）+代码（-le 518，取大并集）
- **核验**: bash -n OK；单跑 41/41 PASS exit 0

### 8. selftest-registry.tsv
- **冲突位置**: 行 65-69（两行新登记）
- **策略**: 两行都保留；按"旧代在前"原则，goal-unit（v151）在前，context-pressure（v152）在后（尾行）；TAB 4 列维持
- **核验**: awk -F'\t' 全部 66 行=4 列；registry.sh 5/5 PASS exit 0；context-pressure.sh 9/9 PASS exit 0

## 验收汇总

| 检查项 | 结果 |
|--------|------|
| git diff --check | 无冲突标记 |
| bash -n（7 脚本） | 全部 OK |
| research-first 单跑 | 12/12 PASS exit 0 |
| lane-advancement 单跑 | 14/14 PASS exit 0 |
| self-resolution 单跑 | 13/13 PASS exit 0 |
| tool-selection 单跑 | 12/12 PASS exit 0 |
| requirement-coverage 单跑 | 23/23 PASS exit 0 |
| workflow-orchestration 单跑 | 16/16 PASS exit 0 |
| skill-split 单跑 | 41/41 PASS exit 0 |
| registry.sh 单跑 | 5/5 PASS exit 0 |
| context-pressure 单跑 | 9/9 PASS exit 0 |
| registry.tsv 4 列 | 66 行全部 4 列 |

## 备注

- SKILL.md 与 critical-rules.md 的冲突块不在本单元处理范围（用户指定 8 文件），留给主进程或后续步骤解决。
- selftest-workflow-orchestration.sh 无冲突标记，已自动合并，WF-10 断言已正确演进到 1-67。
