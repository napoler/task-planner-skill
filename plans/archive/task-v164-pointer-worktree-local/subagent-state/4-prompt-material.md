# S4 引用面分级材料（executor，2026-10-10）

## 任务（只读判定，零文件编辑）
对 `grep -rn 'active_plan' skills/task-planner/` 的 **28 个文件 / 166 hits** 逐个判定分级，产出级联清单。本 S-unit **禁止编辑任何技能文件**（编辑是 S5-S7 的事）。

## 执行步骤
1. 取全集：`grep -rln 'active_plan' skills/task-planner/`（28 文件）+ `grep -rn 'active_plan' skills/task-planner/`（166 行带行号）
2. 逐文件看每个 hit 的上下文（读该行±5 行），按下方判据分类
3. 清单写入 findings.md 追加段 `#### [sub:4-executor] S4 引用面分级`（28 行表格 + 汇总行）

## 分类判据（二选一，禁第三类）
- **只读消费方（登记不改）**：hit 出现在代码逻辑中——调用 resolve-plan-dir.sh / set-active-plan.sh / 读写指针文件的路径拼装 / 守卫断言（如 `[ -f "$ACTIVE_FILE" ]`）。无语义描述或描述已中性
- **措辞更新方（列入 S5-S7 编辑清单）**：hit 出现在**注释或文档正文**中，且把全局指针描述为旧语义——「入库 / git 跟踪 / 全局 legacy / 移交 / 跨树共享」等与 2026-10-10 task-v164 改述后语义（工作树内瞬态 fallback、合并零冲突）矛盾的表述

## 已知事实（供对照，防重复劳动）
- `set-active-plan.sh` 与 `resolve-plan-dir.sh` 已在 S3 完成头注释改述（`:3-6/:9-16/:21/:33-34` 与 `:7-14/:19/:29-30` 带 `[2026-10-10 task-v164]` 锚）→ 判「已改述（S3）」，列入编辑清单时标注"已完成"
- `plans/.active_plan` 已瞬态化（git rm --cached + .gitignore:15）

## 输出格式（findings.md 追加段内）
```
| 文件(相对 skills/task-planner/) | hits | 分类 | 依据(file:line + 一句理由) |
|--------|------|------|---------------------------|
| scripts/set-active-plan.sh | N | 已改述（S3） | :9-16 [task-v164] 三点块在位 |
| scripts/zcode-userpromptsubmit.sh | N | 只读消费方/措辞更新方 | :<行> <理由> |
...（28 行全覆盖，缺一行=验收不过）
汇总：只读 X 个 / 措辞更新 Y 个 / 已改述 2 个（X+Y+2=28）
```

## 边界
- 禁改任何技能文件；唯一可写=findings.md 的追加段（`## Research Findings` 段末，`## Technical Decisions` 前）
- 禁 git 写操作；每行判定必须带 file:line 锚（Rule 71 无源不写）
