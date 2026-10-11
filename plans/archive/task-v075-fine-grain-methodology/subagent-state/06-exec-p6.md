# Checkpoint 06-exec-p6 (模板同步 S1a/S1b/S2)

## 状态: complete

## 里程碑 ① 两模板落盘 ✅
- `skills/task-planner/templates/task_plan.md` :182-188 区域 S-unit 注释扩展 6 行(+5/-1,净增 5 行内注释):
  - ① 预估时长列一律 NNmin 格式且 ≤15min,attest 时 check-plan-dispatch.sh 逐行数值校验(超限拒绝/不可解析 SKIPPED 显式报错)
  - ② 输入列文件路径 token 计数 ≤2,超限拒绝
  - 表结构与既有文字零改动
- `skills/task-planner/templates/variant/rule-enhancement-type.md` Phase 2 段(:51-58)追加 5 行:
  - 一行 HTML 注释「派发型 Phase 必附 S-unit 7 列表,attest 机器校验时长 NNmin 列与输入路径 ≤2 列」
  - 7 列表头 `| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |`
  - 2 数据行 S1/S2,时长 10min/12min(合规 NNmin),输入列各 ≤2 路径
  - 模板既有内容零删改
- git diff --stat: 2 files changed, 10 insertions(+), 1 deletion(-)

## 里程碑 ② 验证通过 ✅
- `bash skills/task-planner/scripts/selftest-template-lifecycle.sh`:
  - `Total: 17 PASS=17 FAIL=0`(既有 17 断言无回归)
- `grep -n "NNmin" templates/task_plan.md` :184 命中(≥1)
- rule-enhancement 模板 :55 含 7 列表头行

## 约束合规
- 只改上述两模板文件;未触碰 scripts/ 与 config.json
- 模板改动未引入 "Batch Report" 等契约标记
- 全程在 worktree /mnt/data/dev/task-planner-skill-worktrees/task-v075-fine-grain-methodology 内,未触碰主仓与其他 worktree

## deviations
- 无

## risks
- ① check-plan-dispatch.sh 的数值校验实现(P4 产物)尚未在本 worktree 验证与注释描述的一致性,合并后需复跑全量 selftest 确认契约对齐
- ② 示例数据行(S1/S2 目标文本)可能被后续实例化者照抄,存在误用为真实计划内容的低风险;注释已标明「示例行,实例化时替换」

## next_step
主进程回填 progress.md P6 完成态,进入合并回合约(全量 selftest 基线复核 → merge --no-ff → worktree 清理)
