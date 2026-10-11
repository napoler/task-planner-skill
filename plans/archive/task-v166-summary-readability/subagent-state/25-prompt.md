# S25 任务书 — 合并冲突并集解（Rule 75 + Rule 76 共存，索引演进 1-77）

## 1. 目标
在 worktree 内解决 master 合并的 10 文件冲突（并集解：Rule 75+Rule 76 共存，SKILL 索引演进 1-77），保持零冲突标记+断言不减。

## 2. 输入（计划三文件必传，绝对路径 — Rule 22.4a）
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/task_plan.md — 只读
- findings:  /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/findings.md — 可读；本任务不写 findings
- progress: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/progress.md — 可读；本任务不写 progress
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/knowledge-brief.md — 只读（§3 文件锚点）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability（merge master 冲突态，10 文件带冲突标记）

## 3. 执行步骤（严格 4 步，禁加更多）
1. SKILL.md 五处冲突并集解（规则：HEAD=v166 侧，master=v163 侧；规则条文互不删减，索引号演进为 1-77）：
   - :9 全集行：改为「Critical Rules 全集 1-77（67-72/73-76 均经并行任务合流落地）」；规则名清单保留两侧全部条目（含 72=决策分级与用户打断纪律、73=执行期决策对齐与不变量纪律、74=变更吸收三判纪律、75=网络调研主动激活与外部数据依赖纪律、76=总结阶段格式可读性与审查清单实体化纪律、36 技能修改保守化与功能删除防护）
   - :244 C 行区：master 侧 C54（Rule 75 网络调研）保留为 C54；HEAD 侧 Rule 76 行改为 C55
   - :315 Critical Rules 行：改为「Critical Rules 1-77（含 Rule 40-76 全集」并在名目加「Rule 75 网络调研主动激活与外部数据依赖纪律 / Rule 76 总结阶段格式可读性与审查清单实体化纪律」
   - :385 摘要 bullet 区：两侧 bullet 全保留（Rule 75 bullet + Rule 76 bullet）
   - :413 References 表行：同 :315 口径演进 1-77+40-76+75/76 名目
2. critical-rules.md（:1010-1050 冲突）：74.6 行保留一份；master 侧「### 75 网络调研…」全文（75.0-75.7）保留在前；HEAD 侧「## Rule 76（…）」全文（76.1-76.6）保留在后——顺序=74.6→Rule 75→Rule 76，标题形态各自原样不动
3. 七个 selftest 脚本冲突（research-first/self-resolution/requirement-coverage/context-pressure/root-resolution/tool-selection/lane-advancement 共 8 处）：一律取 HEAD 侧断言行（v166 宽容锚如 Critical Rules 1-7[4-9] 覆盖 1-74..1-79 已含 77），master 侧断言行删除，但 master 侧注释行（[2026-10-10 task-v163 级联…]）作为历史演进记录保留在 HEAD 注释之后
4. 验证：grep 冲突标记全部 10 文件=0；bash -n 七个 .sh 全过；对并集后 SKILL.md（1-77 实态）跑九个脚本（absorption-discipline/summary-readability/context-pressure/research-first/self-resolution/requirement-coverage/root-resolution/tool-selection/lane-advancement），逐行记录 Total 行；FAIL>0 只记录不超出范围修

## 4. 验收标准（可观察证据，无序列表）
- 10 文件冲突标记 grep=0
- SKILL.md：grep -c '1-77' ≥3；'Rule 75' 与 'Rule 76' 名目均在位；C54（75）/C55（76）两行并存
- critical-rules.md：76.1-76.6 六子条 grep=6 且 75.0-75.7 在档（grep -cE '^75\.[0-7] ' ≥7）
- 七 .sh bash -n 通过；九脚本自跑 Total 行逐行记录（FAIL 明细列出）

## 5. Scope 禁改清单
- 只准解决上述 10 文件的冲突；禁止改其他文件；禁止 git commit/add（合并提交由主进程执行）；禁止删减 Rule 75/76 任一条文或断言

## 6. 工作路径
worktree 绝对路径：/mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability（不切换 CWD）

## 7. 时长预算
超时阈值：15 分钟；超过返回 partial（附已解决文件清单）。

## 8. 返回格式（严格 8 字段）
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS 2:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 9. checkpoint 落盘路径（强制，路径逐字核对禁 typo）
- /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/subagent-state/25-code-assistant.md
- T1 里程碑带时间戳；T5 最终结论段=第 7 节同一 8 字段块

## 10. 上下文预算
每文件先 Read 冲突块全文再 Edit，禁凭摘要盲改。

**需求锚（Rule 51.1a）**: 不适用（纯机械单元——合并冲突并集解，Rule 74 增量默认/零删除）
