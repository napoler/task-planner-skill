# S-unit 03 — 全模板族与模板 skill 推广任务包

## 0. 唯一允许写入路径
`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-template-propagation-20261125`（分支 `wt/task-template-propagation-20261125`）。
禁止写主仓根目录、其他 worktree、部署位（`~/.zcode/skills`、`~/.agents/skills` 等）。

## 1. 背景
前序 S-unit 01 已在主 task_plan 模板 + `planctl.py` render + task-planner SKILL/todo-sync 建立「🧹 收尾对齐与清理（交付前必填）」。用户核查「是否将模板推广到所有的模板以及模板skill」，确认需补齐教学面/治理面一致性。

## 2. 铁律
- **新增内容禁止带 task-id、日期戳、"本次改了什么"等修改痕迹**——只写规则语义。这正是反屎山任务的核心精神。
- **不批量清存量注释**；不新增脚本门/hook/selftest/config 键。
- 只做下方明确列出的改动，**禁止扩范围**。

## 3. 改动

### A. 29 个标准 variant 的 lineage `pruned` 声明
- 范围：`skills/task-planner/templates/variant/*.md` 中**除** `mini-lite-type.md`、`l0-lite-type.md` 之外的 29 个文件（它们带 `template-lineage: ... pruned="..."` 声明）。
- 动作：在每个文件的 `pruned="..."` 清单中，紧接 `收尾回读梳理记录` 之后追加 `,收尾对齐与清理`（与既有 `防倒退终检,收尾回读梳理记录` 同形态，**只声明裁剪，不往 variant 正文塞板块**）。
- 幂等：若某文件已含 `收尾对齐与清理`，跳过；每个文件必须恰好改 1 处 lineage 行。
- 建议用审查过的批量脚本处理（Bun+TS 优先；脚本落 worktree 的 `tmp/` gitignore 区），处理后逐文件复核 `git diff` 确认只改 lineage 行。

### B. 模板 skill 教学面补承载关系（精确插入，不堆砌）
在 `skills/plan-template-kit/` 内**一处最合适的教学位置**（读 `SKILL.md`、`references/template-guide.md`、`references/template-mapping.md` 后自行判断），补一句说明：
> 收尾对齐与清理板块由 task_plan 基座模板 + `planctl.py` render 承载；variant 通过 template-lineage 的 `pruned` 声明裁剪该板块；mini-lite/l0-lite 档豁免，不进入正文。
只写语义，不带日期/task-id；只补这一处，不扩散到多处。

## 4. 明确不改（越界即失败）
- `mini-lite-type.md`、`l0-lite-type.md`（最小白名单/豁免契约）。
- 11 个功能模板（progress/findings/verification/delivery-summary/subagent_dispatch/notepad-learnings/batch_report/knowledge-brief/session-handoff/shared-tracker/deprecated/user-session-log）。
- 守卫/注册面：`check-template-principles.sh`、`principle-template-registry.md`、`selftest-*.sh`、`template-mapping` 的断言——不把 cleanup 提升为机器门（用户裁决"文本条款即可"）。
- `plan-template-advisor/SKILL.md`（不硬编码为项目级模板生成必填）。

## 5. 验收（逐条执行，报告真实输出）
```
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-template-propagation-20261125
grep -rlF '收尾对齐与清理' skills/task-planner/templates/variant/*.md | wc -l     # 期望 29
grep -cF '收尾对齐与清理' skills/task-planner/templates/variant/mini-lite-type.md  # 期望 0
grep -rlF '收尾对齐与清理' skills/plan-template-kit/                                 # 期望 ≥1
git diff --stat                                                                       # 期望 ~30 文件，每文件仅 lineage 行 + kit 1 处
bash -n skills/task-planner/scripts/*.sh
python3 -m py_compile skills/task-planner/scripts/planctl.py
```
另做一次抽样：`git diff -- skills/task-planner/templates/variant/bugfix-type.md` 确认只改 lineage 行、无正文膨胀。

selftest 与 verify 由主进程稍后统一跑，你不跑。

## 6. 检查点落盘纪律
检查点文件见派发 prompt 的 checkpoint 字段。每完成一个逻辑块（A/B）追加带时间戳里程碑行；遇错写「错误与受阻」段；结束写「最终结论」段（= 8 字段返回块）。

## 7. 返回
严格 8 字段（见派发 prompt §7），字段后不得有任何内容。
