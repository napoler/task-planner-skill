# 02-design 三载体 diff 方案 + selftest 锚点断言清单

> 本文件是 Phase 3 四个 S-unit 的输入材料包。各子代理自行定位精确锚点（语义描述见各节），禁止假设行号。

## §1 S1 — dispatch 规则载体（general-coder, sonnet-1）

- **目标文件**：`<WT>/skills/task-dispatch/references/critical-rules-dispatch.md`（WT=/mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105）
- **插入位置**：`## Rule 96` 段落整体结束之后、下一个 `## Rule`（若为 Rule 97+/尾部附录区则插在其前）——语义定位：作为新规则段紧跟 Rule 96，编号顺序自然递增。
- **插入内容**：`plans/task-subagent-markup-20261105/rule104-draft.md` 全文（60 行，逐字插入，不改一字）
- **验收**：`grep -c "^## Rule 104" <文件>` = 1；`grep -c "^### 104\." <文件>` ≥ 6
- **约束**：不动文件其他任何内容；插入处与相邻段落间保留一个空行。

## §2 S2 — SKILL.md 就地速查表载体（general-coder, sonnet-1）

- **目标文件**：`<WT>/skills/task-planner/SKILL.md`
- **插入位置**：Phase 执行循环内 `2.5 [A] **委派检查点（Rule 25）**：…` 这一行之后（即 2.5b 之前），作为 2.5 段的就地速查附表。
- **插入内容**（逐字）：

```markdown
     **使用点标注速查（Rule 104.2 就地版 — 默认执行体，偏离须 `[markup-exempt] 理由`）**：
     搜索定位→Explore｜网络调研→Web Search Agent/general-researcher｜官方文档→Doc Search Agent｜
     大文件/日志→log-distiller｜检查验证审查→Verifier/Code Reviewer/critic｜批量既定步骤→executor｜
     媒体批量质检循环→image/video-generation-executor｜长耗时管道→code-runner 或后台执行｜
     批量簿记→plan-bookkeeper｜单文件小改→Code Assistant｜中等编码→general-coder｜
     独立创作→general-writer｜分析归因→general-analyst｜偏移检查→drift-checker｜方案终裁→decision-arbiter
     （全文与触发判据见 `../task-dispatch/references/critical-rules-dispatch.md` Rule 104；主进程保留=编排/路由/派发/回收/决策/三文件回填/白名单①-⑥）
```

- **验收**：`grep -c "使用点标注速查" <文件>` ≥ 1
- **约束**：只插入，不改 SKILL.md 其他行；缩进对齐 2.5 段的子行风格（5 空格起）。

## §3 S3 — task_plan 模板标注列载体（general-coder, haiku-1）

- **目标文件**：`<WT>/skills/task-planner/templates/task_plan.md`
- **改动 1 — S-unit 表头加列**：定位 `| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入…` 表头（约 1 处 + 数据行），在「执行体」列后插入「96 类别」列：
  - 表头变为：`| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入…`
  - 分隔行同步加 `|--------|` 一列
  - 数据行（S1/S2 两行示例）在执行体列后各加 `A6` / `A7` 占位值
- **改动 2 — 表注释补一行**（插在 S-unit 表注释块内任意合适处，如 Rule 96.3 并行硬标注说明行之后）：
  ```markdown
  - Rule 104.3 计划期标注：「96 类别」列逐行填命中类别（A1-A7 / 47.2 具名 / LOCAL 纯执行），命中标注表（dispatch Rule 104.2）而执行体=主进程须例外理由或 [markup-exempt] token
  ```
- **验收**：`grep -c "96 类别" <文件>` ≥ 2（表头+注释）
- **约束**：只做上述两改动；模板其他区块（Executor 字段行等）一律不动。

## §4 S4 — selftest 锚点（general-coder, sonnet-1）

- **目标文件**：`<WT>/scripts/selftest-subagent-activation.sh`
- **前置动作**：先 Read 脚本尾部既有断言（SA-14/SA-15 形态），完全模仿其写法（变量/断言函数/pass-fail 计数风格）。
- **新增断言（SA-16..SA-20）**（2026-11-05 修正：锚形态对齐既有惯例——规则主标题=三级 `### 104 `，子条=正文行 `104.x **`）：
  - SA-16: `grep -c "^### 104 子代理使用点显式标注纪律"` = 1 且 `grep -c "^## Rule 104"` = 0（修正后形态在位+旧二级标题零残留）
  - SA-17: `grep -c "^104\.2 \*\*使用点标注总表"` ≥ 1 且表内锚「媒体批量生成」命中（判例 EP-3 对应动作类型在位）
  - SA-18: `grep -c "使用点标注速查" $REPO/skills/task-planner/SKILL.md` ≥ 1
  - SA-19: `grep -c "96 类别" $REPO/skills/task-planner/templates/task_plan.md` ≥ 2
  - SA-20: `grep -c "markup-exempt" $REPO/skills/task-dispatch/references/critical-rules-dispatch.md` ≥ 2（104.1.2+104.6.1 双在位）
- **验收**：`bash scripts/selftest-subagent-activation.sh` exit 0 且输出含 SA-16..SA-20 PASS
- **约束**：若脚本无 $REPO 形态变量则沿用其既有路径基准写法；只追加不改动既有断言行。

## §5 执行顺序与并行

- S1/S2/S3 并行（parallel-group:pg1，文件集互不重叠）；S4 在三者完成后执行（锚点断言引用落地后内容）。
- 各子代理返回后主进程 Read 产出文件复核 + findings 回填。
