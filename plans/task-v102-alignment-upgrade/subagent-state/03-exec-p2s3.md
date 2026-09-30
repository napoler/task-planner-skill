# P2-S3 checkpoint — C32+摘要+模板行+豁免行（executor, haiku-1）

状态: 本步 4 处编辑全部完成;acceptance 1/2/3/4 通过;5 中 4 脚本复跑发现 2 项 FAIL,根因排查确认**非本步引入**（前序 S1/S2 存量改动 + 本步 1 行级联漂移所致）,须由后续 S4 级联修复。
未执行 git commit/add。基线 HEAD=5ddc317。

## 本步 4 处编辑（全部完成,逐字按任务书）
1. SKILL.md C32 行:C31 行后新增 `| C32 | 对齐审查标准流程（Rule 42.6）…（机器面=selftest-review-library RL-11 静态断言，校验过程人工核查；mini 档豁免） | ☐ |`
   - 位置: `skills/task-planner/SKILL.md` C31 行（约 :196）之后
2. SKILL.md Rule 42 摘要行行末追加:「零新 config 键+mini 档豁免（42.5）」后追加 `；对齐审查前置与收尾消费——写入前版本一致性校验闸门（42.6.1 未经校验不追加）+任务完成前对齐标准流程（42.6.2 全文档过 alignment-review）+变更记录输出（42.6.3）+零新键机制（42.6.4,task-v102）`;行内既有 42.1-42.5 措辞零删改
3. templates/task_plan.md 配置表 `对齐审查` 行:追加于 `interaction_mode` 行之后、`质量审查工具` 行之前
4. templates/variant/mini-lite-type.md 头部注释区 `Rule 42.6 豁免声明` 行:追加于 42.5 豁免行（:8）之后

## 验收证据
- A1: `grep -c '| C32 |'` = 1;`| C30 |` = 1;`| C31 |` = 1 ✅
- A2: Rule 42 摘要行含「42.6.1」「未经校验不追加」「对齐标准流程」各 1;「零新 config 键+mini 档豁免（42.5）」原文在位 ✅
- A3: `grep -c '对齐审查' templates/task_plan.md` = 1;mini-lite `grep -c 'Rule 42.6 豁免'` = 1 ✅
- A4: `grep -c 'Rules 1-39' SKILL.md` = 2;`grep -nE '1-4[0-9]' SKILL.md` 零命中（exit 1）✅
- A5（4 脚本复跑,worktree scripts/）:
  - selftest-review-library: Total 10 PASS=10 FAIL=0 ✅（RL-11 未加,符合任务书预期）
  - selftest-self-resolution: Total 12 PASS=12 FAIL=0 ✅
  - selftest-reliability-institution: Total 12 PASS=11 FAIL=1 ❌
    - FAIL 断言: `R-01 FAIL critical-rules.md Rule 42 子条数 10（应 5）`
    - 根因: S2 给 critical-rules.md 追加 42.6.x 后 `grep -c '^42\.'` 由 5 变 10;R-01 期望值未级联。**非本步引入**（S2 存量）
  - selftest-skill-split: Total 41 PASS=40 FAIL=1 ❌
    - FAIL 断言: `T-主 行数 ≤439 …` 现 SKILL.md = 440 行
    - 根因: 基线(HEAD 439 行)恰在钉上,S1/S2 存量改动已推到 439;本步 C32 行使其 440>439。**行钉级联**（任务书 S4 计划含「计数级联」,需 439→新钉 或 压缩）
    - 基线验证: 临时 detached worktree(HEAD) 复跑同 4 脚本全 exit=0,R-01 PASS=12/T-主 PASS=41 —— 证明两 FAIL 均由工作树未提交存量改动(S1/S2)引入,非本步锚行编辑逻辑错误
- A6: `git diff --stat` 本步面=3 文件（SKILL.md / templates/task_plan.md / mini-lite-type.md）;完整 5 文件 diff 中 critical-rules.md(+5) 与 alignment-review/SKILL.md(+27) 为前序 S1/S2 存量,符合任务书预期

## 硬约束自查
- C29/C30/C31 行、Rule 40/41/43 摘要行、「Rules 1-39」字面 2 处、「质量审查工具」行:零改动 ✅（diff 仅 3 目标文件,且 SKILL.md diff 仅 C32 新增行 + Rule 42 摘要行行末追加）
- 「1-4x」越界字面:零命中 ✅
- 零新 config 键:未动 config.json ✅
- 未 git commit/add ✅

## 恢复点/待办（交主进程）
- 修复 1（属 S4 或新增子步）: selftest-reliability-institution.sh R-01 期望值 5→10（含头注释级联）
- 修复 2（属 S4「计数级联」范围）: selftest-skill-split.sh T-主 行钉 439→≥440（现值 440）并同步头注释
- 修复后复跑 4 脚本至 0 FAIL,再进 P3-S4（RL-11 断言将把 selftest-review-library 提至 11 断言,注意其计数级联）
