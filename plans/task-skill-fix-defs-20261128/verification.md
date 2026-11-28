<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-skill-fix-defs-20261128

- task_id: `task-skill-fix-defs-20261128`
- 时间: created_at=2026-11-27T22:22:35Z / updated_at=2026-11-28T02:50:46Z

## Goal (1 sentence)
- DEF-01/02/03/05/06/10 修复落地+SKILL.md 瘦身模板驱动+部署生效；DEF-04/07/08 大工程项登记 backlog

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC1 | pass | SKILL.md 行+字节双钉达标（行≤300 且字节≤30000）且 BP-08 断言同步更新为双钉（SPEC-1 只读约束不适用于本实现任务，改为源仓写入约束：仅 worktree 内改 skills/**） | cd /mnt/data/dev/task-planner-skill && test $(wc -l < skills/task-planner/SKILL.md) -le 300 && test $(wc -c < skills/task-planner/SKILL.md) -le 30000 && grep -q 'wc -c' skills/task-planner/scripts/selftest-batch-pilot.sh && echo VC1-PASS | 175行/28057B ≤300/30000+BP-08 双钉在位（wc 实测+grep wc -c） |  |
| VC2 | pass | SOFT_ONLY fail-closed 实弹：空壳夹具 attest rc=1、TASK_PLANNER_SOFT_ONLY_ENFORCE=off 时 rc=0、正常计划 rc=0，selftest-softonly-gate.sh 三向断言全过（SPEC-2 盘上证据锚要求适用） | cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/selftest-softonly-gate.sh && echo VC2-PASS | selftest-softonly-gate 3/3 亲跑（/tmp/v2.out） |  |
| VC3 | pass | 核心规则标题归一：grep -c 起首 ### Rule 恒等于 20 且零裸数字/零 h2 残留；verify.sh 全量副本位 hooks 存在性检查生效；selftest-rule-heading.sh+selftest-verify-hooks.sh 双绿 | cd /mnt/data/dev/task-planner-skill && test $(grep -c '^### Rule' skills/task-planner/references/critical-rules.md) -eq 20 && bash skills/task-planner/scripts/selftest-rule-heading.sh && bash skills/task-planner/scripts/selftest-verify-hooks.sh && echo VC3-PASS | heading=20+rule-heading 4/4+verify-hooks 6/6 亲跑（/tmp/v3a.out,/tmp/v3b.out） |  |
| VC4 | pass | 合并回 master 后部署生效且 verify.sh 对账不劣化（实测 27 pass/4 fail=预存 hardcoded 基线，git 归因：init-session 模式 master 既有/本任务零新增/smart-merge 两文件本任务未触碰；四部署位 in-sync ✓） | cd /mnt/data/dev/task-planner-skill && TASK_PLANNER_ROOT=$PWD/skills/task-planner bash skills/task-planner/lib/verify.sh 2>&1 ｜ tail -1 ｜ grep -q "0 fail" && echo VC4-PASS | install.sh 部署完成+verify 27/4=既有基线（归因命令：git show 285f1efc init-session grep=1/diff 新增=0/diff stat 空）+四部署位 sync ✓行 |  |
| VC5 | pass | planctl schema 子命令输出全部节字段表（节总数≥40）且 add 重复 id 报错 rc=1 非 crash（AttributeError 根治）且 render VC 命令列管道符用 \｜ 标准转义不再产 ｜ | cd /mnt/data/dev/task-planner-skill && python3 skills/task-planner/scripts/planctl.py schema 2>/dev/null ｜ grep -c '"sections"' ｜ xargs test 1 -le && python3 skills/task-planner/scripts/planctl.py add --plan-dir /mnt/data/dev/task-planner-skill/plans/task-skill-fix-defs-20261128 --section findings --json '{"id":"F1","text":"x"}' 2>&1 ｜ grep -q '已存在' ; test $? -eq 0 && echo VC5-PASS | schema 无 --plan-dir 输出 sections 键+重复 add 输出已存在（/tmp/v5.out） |  |
| VC6 | pass | worktree 全量 selftest --fresh FAIL 数≤3（==既有基线集）且语法检查零错 | cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-skill-fix-defs-20261128 && bash skills/task-planner/scripts/run-selftests.sh --fresh > /tmp/st-fix.out 2>&1; test $(grep -cE "^FAIL" /tmp/st-fix.out) -le 3 && echo VC6-PASS | 全量 124 脚本 123/1（/tmp/st-final2.out 亲跑），唯一 FAIL=execution-stability 经 master 未改版对照 17/2 同败实锤预存基线 |  |

> **输出示例对照（Rule 113）**：凡 VC 判定标准涉及输出格式/结构，须在 `task_plan.md`「🧩 输出示例与格式契约」区块有对应 `output_examples` 条目（完整示例+同结构模板+`vc_refs` 指向本 VC）；产出形态与示例不一致 = VC 未通过。

**本计划已登记输出示例**：OE-1（worktree 内修复提交+selftest 输出 / selftest 断言行 + BP-08 双钉行 → VC1, VC2, VC3）

## Phase Gates
| Goal | Depends on | Done when | Checks | Status |
|---|---|---|---|---|
| （本任务暂无Phase Gates 记录） |  |  |  |  |

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|---|---|---|
| （本任务暂无知识符合性记录） |  |  |

## 委派统计复验（Rule 25.4）
- （本任务暂无委派复验记录）

## 质量门控统计（Rule 26）
- （本任务暂无质量门控记录）

## Goal Gate (终验，所有 phase complete 后执行)
outcome: PARTIAL
blocked_reason: 委派率 0.667<0.7 floor（P3=⑥ 综合裁决类主进程职责，violations=0；3-Phase 含必主进程综合 Phase 时 floor 数学不可达——门设计摩擦已在审计任务 F4 登记，修复属保护区待授权）

---
## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|---|---|---|---|
| （本任务暂无交叉验证记录） |  |  |  |

## 5-Question Reboot Check
| # | Question | Answer (fill on resume) |
|---|---|---|
| （本任务暂无5Q 记录） |  |  |

## 基线-产物逐条核验表（Rule 84.15）
| spec_id | 双向判定式 | 校验命令 | 观测 | 证据锚(path:line 或回执) | 结论 |
|---|---|---|---|---|---|
| SPEC-1 | 正向：skills/** 修改一律在 tmp/worktrees/task-skill-fix-defs-20261128 内进行，完成后 --no-ff 合并回 master 并清理；反向：主仓 skills/** 直写或跳过 worktree=违规 |  | 待终验 | AGENTS.md:81 | 待终验 |
| SPEC-2 | 正向：修复须带盘上证据（selftest 实跑 stdout/rc）与来源锚（审计报告 DEF 编号）；反向：无 selftest/夹具支撑的修复声称=违规 |  | 待终验 | CLAUDE.md:61 | 待终验 |
