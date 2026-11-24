# 任务收尾「对齐 & 清理」机制 — 设计规格

- 日期：2026-11-25
- 状态：设计已批准（用户当日选方案 A，原话「好的，遵循三段式的个推进」）
- 范围：4 个源文件；纯文本条款；**不新增脚本门 / 不新增 config 键 / 不批量清存量 / 不动部署位**

## 1. 背景与证据

用户诉求（原话要点）：项目经反复修改后「屎山成堆」；代码注释可保留，但技能定义文件里堆了大量无价值的历史注释/旁注，只增负担。要求加强 task-planner：分析是否需要「反屎山」操作，并在**任务执行后做清理工作**。后续两次追加把形态锁定为：

> 「清理任务或者对齐任务，可以在 todo 以及模板中进行要求就可以，比如说在 todo 的最后两步进行对齐以及清理，还有就是在 task 模板中列出一个板块，列出需要清理、对齐的必要步骤。」

只读取证（两名子代理，关键点已由主进程 Read 复核）：

| 病灶 | 实证 |
|---|---|
| 垃圾：历史痕迹注释 | `skills/` 137 个 .md 中 142 行/68 文件含 task-id/日期/判例/原行为标记；`skills/task-planner/SKILL.md:34` 单行 400+ 字 What/Why/原行为内嵌；`skills/task-planner/templates/task_plan.md:2` 单行叠 3 个任务号 |
| 不对齐：过期口径 | `skills/task-planner/README.md:83`「Rules 1-97 / 核心 14 条 / 203 行」vs `skills/task-planner/SKILL.md:233`「Rules 1-112 / 核心 17 条」；`skills/task-planner/references/critical-rules.md:145`「维持 1-80」已过期 |

缺口确认：现有收尾链（`SKILL.md:140` 终验强制对齐、`SKILL.md:142` Rule 84.14 回读、`references/todo-sync.md:31` S4）均不覆盖文档口径拉平与注释垃圾清理；`Rule 100.6 trash` 是文件判废，非注释清理。

## 2. 目标 / 非目标

**目标**：在 todo 与 task 模板中建立「任务完成后 → 对齐 + 清理」的必填文本条款，使后续任务无法无声跳过，逐步消化屎山。

**非目标**（防范围蔓延）：
- 不批量修改现有 68 个含历史注释的文件；存量由机制在后续任务中渐进消化。
- 不新增脚本门、hook、守护断言、selftest 脚本或 config 键（项目「文本优先铁律」）。
- 不改 Rule 100.6 / trash / 归档等既有判废与归档规则。
- 不触碰部署位（`~/.zcode/skills`、`~/.agents/skills` 等）。

## 3. 方案选型

| 方案 | 做法 | 结论 |
|---|---|---|
| **A（采纳）** | todo 基线组追加 B17 对齐 / B18 清理 + task_plan 模板新增独立板块 + `planctl.py` render 同步 + SKILL 收尾指针 | 逐字贴合用户「todo 最后两步 + 模板一个板块」 |
| B | 复用 B7/B15，只在模板列清单 | 不满足「todo 最后两步」，且语义错位 |
| C | 清单塞入现有「收尾回读梳理记录」板块 | 语义混杂，且用户明确要独立「一个板块」 |

## 4. 详细设计

### 4.1 段 1 — todo 收尾两步

落点：`skills/task-planner/references/todo-sync.md` S1 基线组（现 B1-B16）追加 **B17/B18**，S4 终态同步增加前置约束。

- **B17 口径对齐**：交付前拉平本任务触及的过期计数/冲突条款。判据：`grep -nE 'Rules 1-97|203 行|维持 1-80'` 无本任务新增命中；证据落 progress `[align-final]` 行。
- **B18 垃圾清理**：删除本任务新增的无价值历史注释（`<!--...task-vNNN...-->`、What/Why/原行为内嵌注、过期日期注）；**保留**描述字段语义/消费方/脚本锚点的高价值契约注；含守卫盲区事实的判例注**归档 forensics，不直接删**。证据落 progress `[cleanup-final]` 行。

两步均为基线组必选项，在列表中排在末尾（B16 之后）构成「最后两步」；**执行时机在 outcome 判定之前、B16 合并回动作之前**——清理/对齐产生的改动必须先落盘并提交，才能合并回主仓，禁止倒置为「合并后才清理」。

### 4.2 段 2 — task 模板板块 + render 同步

落点：`skills/task-planner/templates/task_plan.md`，紧挨 `## 🔁 收尾回读梳理记录`（:419）之后新增：

```
## 🧹 收尾对齐与清理（交付前必填）
| 类别 | 检查项 | 判据 | 证据 |
| 对齐 | 口径计数 / 冲突条款 / 行数快照 | grep 冲突锚无新增命中 | progress [align-final] |
| 清理 | 历史注释 / 过期注 / 残留物 | 本任务新增痕迹注为 0 | progress [cleanup-final] |
```

`planctl.py:_render_task_plan`（:1506，重建式渲染）同步输出该板块：**mini / L0-lite 档按现有白名单不输出该板块**（与 mini-lite「禁加仪式区块」一致，不新增负担）；standard / full 档全量输出。模板教学面与 render 执行面必须双写，否则新板块不会被渲染。

### 4.3 段 3 — 边界与验证

- 文件清单（均在 `skills/task-planner/`）：`references/todo-sync.md`、`templates/task_plan.md`、`scripts/planctl.py`、`SKILL.md`。
- 验证：`bash -n` + `py_compile` 语法检查；`run-selftests.sh --fresh` 与基线同集、零新增 FAIL；`verify.sh` 0 fail；实测 `planctl render` 后 task_plan.md 出现新板块；`grep` 确认 B17/B18 条款在位。
- 实施在 worktree（`tmp/worktrees/task-cleanup-alignment-20261125`，分支 `wt/task-cleanup-alignment-20261125`）隔离，完成并验证后合并回 `master`，清理 worktree/分支。

## 5. 决策记录

- 2026-11-25 用户裁决：方案 A；三段式推进；范围严格限定为文本条款，不扩基建。
- 用户「因为」后半句未说完（语音截断），理由不影响需求，未据此推断任何额外范围。
