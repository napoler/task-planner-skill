# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
-->

## Requirements
- 背景：用户"进行部署"指令后核验发现 `~/.agents/skills/plan-resume/scripts/select-and-resume.sh` 于 18:07 被直接写入 v0.5.1 改进（未回写 canonical）；用户选定 **选项 A**：收编回 canonical → 提交 → 全平台部署。

## 📚 必要知识储备对齐记录
| 知识源 | 定位 | 是否已消费 | 结论落点 |
|--------|------|-----------|---------|
| v0.5.1 差异全文 | diff -u（@@ -219,7 +219,28 @@） | ☑ | §1 |
| 部署 SOP | memory task-planner-repo-deploy-flow.md | ☑ | §2 |
| plan-resume smoke 套件 | skills/plan-resume/tests/smoke.sh | ☑（实跑 39/39） | §2 |

## Research Findings

### §1 v0.5.1 改动内容审定
- 位置：select-and-resume.sh 第 5 步检查 `[auto-pushed-by-cron]` 标记处。
- 原行为：任一候选已被标记 → 直接 `exit 0`（本轮无 plan 可推）。
- v0.5.1 新行为：遍历 `FILTERED_OUT` 候选改选下一个未被 `auto-pushed-by-cron|circuit-break-by-cron` 标记者（更新 TASK_ID/PLAN_PATH/SCORE_VAL）；全部候选被标记才报告退出。
- 审定结论：逻辑自洽（含 python3 JSON 解析的 `|| _tid=""` 降级、`[[ -z ]] && continue` 防空、双标记复查），带 `v0.5.1 改进` 注释——是有意的功能演进，非误改。

### §2 收编与部署结果
- 收编：部署位版本原样拷入 worktree → diff -q 与部署位 IDENTICAL（零改写确认）→ plan-resume smoke **39/39 PASS** → commit e87cde5 → merge 48340c0（+22/−1,仅 1 文件）。
- 部署：2 个 plan-resume 位（claude 旧版→v0.5.1;agents 原位整目录替换）tar 备份后 rm+cp -rL；**9/9 位 diff -rq 全 IDENTICAL**；v0.5.1 双位生效抽查 ×1 处命中。
- canonical 副作用核验：`git show --stat HEAD` 仅 1 文件;skills/ porcelain 空。
- 回滚点：`/tmp/deploy-backup-9b167fe/`（plan-resume-2targets-pre-v051.tar.gz 50K + 此前 task-planner 3 位包）。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 原样收编零改写 | 收编=纳既有改动为正典;改写即偏离用户确认版本 |
| 先拷回再覆盖部署位 | 顺序保证 v0.5.1 在任何 rm 操作前已安全入库 |
| 只部署 2 个 plan-resume 位 | 变更范围仅此 skill;其余 7 位同轮已验证一致 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| MEMORY.md 索引行 Edit 首次失败（未先 Read） | Read 后重改成功,已登记 |
| [plan-compass] 对已终态计划（task-deploy-9b167fe）的陈旧升级警告 | 判定为误报（计划已 COMPLETE+attest 锁定）,未据警写入,避免篡改终态 |

## Resources
- master 48340c0（v0.5.1 收编 merge）;e87cde5（收编 commit）
- /tmp/deploy-backup-9b167fe/plan-resume-2targets-pre-v051.tar.gz

## Visual/Browser Findings
- （无多模态输入）
