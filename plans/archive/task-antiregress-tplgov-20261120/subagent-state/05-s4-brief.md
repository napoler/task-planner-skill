# S4 任务书：variant lineage/spec_version 批量注入（2026-11-20）

执行体：在 worktree 内为 31 个 variant 注入 lineage 元数据头（R5 模板分级派生机制载体）+ base 声明 + kit spec_version 声明 + 注入脚本。全程中文。前序已就绪：Rule 111 已落地（commit 15fc6c5）；plan-template-kit/scripts/ 目录可能不存在（需创建）。

## 0. 绝对路径（worktree 内）
- W=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120
- variant 目录：$W/skills/task-planner/templates/variant/（31 个 *-type.md；**禁碰 mini-lite-type.md 与 l0-lite-type.md**——轻量档豁免仪式区块先例，此 2 个不注入并在 findings 登记豁免理由，实际注入=29 个）
- base 主模板：$W/skills/task-planner/templates/task_plan.md（只在头部加 1 行声明，禁改其他内容）
- kit：$W/skills/plan-template-kit/SKILL.md（头部或规范段加 1 行 spec_version 声明）；新建 $W/skills/plan-template-kit/scripts/inject-template-lineage.sh
- 兼容性脚本：$W/skills/task-planner/scripts/check-template-type.sh（只跑不改）

## 1. 设计规范（按此实现，不得自行变更格式）
**lineage 头格式**（HTML comment，插入 variant 文件**第 1 行**之前独立成行；重跑幂等=已存在则替换不叠加）：
```
<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 pruned="<block1,block2,...>" pruned_reason="<一句话|none>" -->
```
- `pruned` = base 主模板有而本 variant 无的区块名清单（按 `## ` 标题名去 emoji/空格取核心词，逗号分隔；差集为空则 none）。**由脚本自动计算**：对每个 variant，diff base 与 variant 的 `^## ` 标题集。
- `pruned_reason`：统一填「variant=领域裁剪全文，裁剪面以本清单显式登记（Rule 34.5 派生登记）」。
- **base 声明**（templates/task_plan.md 首行前插入）：
```
<!-- template-lineage: level=base spec_version=1 -->
```
- **kit spec_version 行**（plan-template-kit/SKILL.md）：在 SKILL 头部说明区加一行 `> 模板规范版本: spec_version=1（2026-11-20 task-antiregress-tplgov-20261120 建立；模板规范升级时递增并按 retrofit SOP 改造存量，见 S6）`

## 2. 交付物（4 项）
① inject-template-lineage.sh：幂等注入脚本（支持 --dry-run；逐 variant 计算 pruned 差集→写/替换 lineage 头；base 行与 kit 行由脚本 --with-base 选项处理或手动均可，但脚本本身只管 variant）。
② 29 个 variant 的 lineage 头落盘（dry-run 预览→实跑）。
③ base 主模板 1 行声明 + kit SKILL 1 行声明。
④ 兼容校验记录：注入后依次跑 `check-template-type.sh`（逐 variant 循环调用，脚本不支持 --all 时用 for 循环，输出登记）、`selftest-template-lifecycle.sh`、`selftest-antiregress.sh`、全量 `run-selftests.sh`（FAIL 集==基线 8 集：active-plan/batch-pilot/enumerate-first/execution-stability/registry/rule-reserve-pairing/self-resolution/summary-readability，零新增）。

## 3. Batch Report 义务（31 文件批量面）
- pre_check：Q1 可脚本化=是（注入器）/Q2 回滚点=`git checkout templates/variant/`（worktree commit 15fc6c5 干净基线）/Q3 幂等可重跑=能
- 全量注入后抽检 ≥3 个 variant（大中小各一）：lineage 头 pruned 列表与实际 heading 差集逐一人工核对一致
- failure_rate>5% STOP；记录写入 findings `#### [sub:05-s4]`（含 Batch Report 八字段）

## 4. 验收（自查 5 条，写入 checkpoint 自审段）
1. VC-13 面：`grep -q "lineage" templates/task_plan.md` 且 `grep -rl lineage templates/variant | wc -l` ≥29（30 个非豁免档至少 29；31 减 2 豁免=29）
2. VC-15 面：check-template-type 逐 variant 循环全 PASS（或等效口径输出全绿）
3. VC-11 局部：kit SKILL 与主模板 grep spec_version 命中
4. 全量 selftest FAIL 集==基线 8 集零新增；selftest-template-lifecycle/antiregress rc=0
5. 103.2 自审逐条对照+抽检记录，证据锚 file:line 入 checkpoint

## 5. 禁改面
上列文件外一切禁改（含三份 rules/SKILL.md/scripts 既有文件——P1 产物禁再动）；variant 的 lineage 头之外**零内容改动**（pruned 列表自动计算产生的行除外）；主仓与部署位禁碰。
