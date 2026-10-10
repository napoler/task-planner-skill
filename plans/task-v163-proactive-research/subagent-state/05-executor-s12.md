# 05-executor-s12 — S12 selftest-proactive-research.sh 新建

- status: partial
- s_unit: S12（Phase 5 机器守护）
- 任务: 新建 worktree `skills/task-planner/scripts/selftest-proactive-research.sh`（Rule 75 静态守护，PR-01..15 断言）
- 时间: 2026-10-10

## 产出
- 新建: `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/scripts/selftest-proactive-research.sh`（81 行，+81/-0，chmod +x，`bash -n` SYNTAX OK）
- 范式对齐 `selftest-research-first.sh`：头注 What/Why + `ok/bad/eq/ge/cnt/cntF` 助手 + 逐行 `PASS/FAIL PR-NN` + 末行 `Total: 15 PASS=x FAIL=y` + `[ "$FAIL" -eq 0 ] && exit 0 || exit 1`

## 断言设计（15 条）
- PR-01..09: critical-rules.md `^### 75 ` =1 ∧ `^75\.0 `..`^75\.7 ` 八子条各 ≥1
- PR-10: templates/task_plan.md 含 `## 🔍 调研需求与检索计划（Rule 75.1`
- PR-11: companion/agents/plan-writer.md 含 `调研需求区块（Rule 75.1）`
- PR-12: scripts/check-plan-dispatch.sh 含 `Rule 75.1 调研需求区块 advisory`
- PR-13: skills/plan-template-kit/references/template-guide.md 含 `2.6 新模板调研需求判定条目`
- PR-14: selftest-registry.tsv 含 `selftest-proactive-research.sh` 登记行
- PR-15: config.json `"properties"` 计数=基线 4 ∧ Rule 75 键字面=0

## 第一手验证输出
```
PASS PR-01..PR-13（13 条全 PASS）
FAIL PR-14 registry 含本脚本登记行 (got=0 expect>=1)
PASS PR-15 config 零新键(properties=4 ∧ Rule75 键字面=0)
Total: 15 PASS=14 FAIL=1
EXIT=1
```
- 路径解析复核：`GUIDE=$SCRIPT_DIR/../../plan-template-kit/references/template-guide.md` → 实测 `template-guide.md`（17228 字节）命中（worktree/skills/plan-template-kit/references/）
- config 基线：`grep -c '"properties"' config.json` = 4（provider_fallback/subagent/timeout_by_type + 顶层）；`proactive_*` 字面 = 0

## 阻塞点（PR-14）
- 根因：`scripts/selftest-registry.tsv` 尚无 `selftest-proactive-research.sh` 登记行（`grep -c` = 0）。
- 归属：按 task_plan.md Phase 5 S-unit 表，registry 登记行 = **S13**（"selftest-registry.tsv +1 行"）的产出；本 dispatch scope 明确"禁止修改其他任何文件"且"本会话只执行本 S-unit（Rule 46.1）"，故 S12 未写入 registry 行。
- 恢复点：S13 落盘登记行后，重跑本脚本即 `Total: 15 PASS=15 FAIL=0`（脚本 PR-14 断言为前向守护，已在头注注明）。
- 注：S13 若追加登记行，请先 `grep -c 'selftest-proactive-research.sh' selftest-registry.tsv` 判重，避免重复行触发 `selftest-registry.sh` T04 FAIL。

## 结论
脚本本体（S12 核心交付）已落盘且 14/15 断言 PASS；唯一 FAIL=PR-14 依赖 S13 registry 登记行（本 dispatch scope 外）。验收 14/15（脚本 exit 1，因 PR-14 前向守护未转绿）。
