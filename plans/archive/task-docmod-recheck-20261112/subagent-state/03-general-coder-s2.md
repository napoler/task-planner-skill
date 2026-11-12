# 03-general-coder-s2 checkpoint

- timestamp: 2026-11-12T16:42:30Z
- task: S2 worktree 级联编辑 `skills/task-planner/SKILL.md`（6 处锚点）

## 六锚前后行号与内容

| 锚点 | 编辑前定位(首动作) | 编辑后行号/内容 |
|---|---|---|
| 1a 索引(frontmatter refs) | L9 含 `Rules 1-105 全集索引` | L9: `- references/critical-rules.md: Critical Rules 核心域——Rules 1-106 全集索引...` |
| 1b 索引(核心规则指针段) | L222 含 `Rules 1-105 全集索引` | L223: `Rules 1-106 全集索引...其余 88 条...Rule 105 可枚举集合全量枚举优先纪律域、Rule 106 文档修改复检与 todo 驱动对齐纪律域（均 task-discipline 卫星）...` |
| 1c 索引(References 表) | L265 含 `1-105 全集索引` | L266: ``| `references/critical-rules.md` | Critical Rules 核心域 1-106 全集索引... |`` |
| 2 卫星路由表 task-discipline 行 | L209 尾部 `...,100,101,105）` | L210: 尾部追加 `,106）` |
| 3 核心规则指针括注 | L222 括注仅含 Rule 105 归属 | L223: `Rule 105 可枚举集合全量枚举优先纪律域、Rule 106 文档修改复检与 todo 驱动对齐纪律域（均 task-discipline 卫星）` |
| 4 Phase 3h 后新增 3i | L104 为 `3h 双轮质检（Rule 103）`，L105 为 `4. [M] 回写计划` | L105 新增 `- **3i 修改后复检（Rule 106）**：受管文档每次修改后回读校验跨字段不变量（106.1）；同文件 ≥2 次修改后全量回归（106.3）——细则→task-discipline Rule 106`（原 4. 下移至 L106） |
| 5 Read vs Write 决策矩阵 20.5 | L151 句尾无 106 引用 | L152: 追加 `（20.5 豁免写入确认型重读；跨字段一致性复检不豁免，见 Rule 106.1）` |
| 6 原生 Todo 同步段尾 | L172 段尾无 S1 两组结构句 | L173: 追加 `S1 两组结构（任务组+基线组 B1-B5，Rule 106.5）详见 references/todo-sync.md` |

## 自检输出（原文）

```
$ grep -c '1-106' skills/task-planner/SKILL.md
3
$ grep -c 'Rules 1-105' skills/task-planner/SKILL.md
0
$ grep -n '3i 修改后复检' skills/task-planner/SKILL.md
105:  - **3i 修改后复检（Rule 106）**：受管文档每次修改后回读校验跨字段不变量（106.1）；同文件 ≥2 次修改后全量回归（106.3）——细则→task-discipline Rule 106
$ grep -n '106.1' skills/task-planner/SKILL.md
105:  - **3i 修改后复检（Rule 106）**：受管文档每次修改后回读校验跨字段不变量（106.1）；同文件 ≥2 次修改后全量回归（106.3）——细则→task-discipline Rule 106
152:> 权威源=`references/critical-rules.md` Rule 20.5。场景速查：刚写完的文件→**不要再 Read**（内容还在上下文）（20.5 豁免写入确认型重读；跨字段一致性复检不豁免，见 Rule 106.1）；看过的图/PDF/网页/搜索返回→立即写 findings；开新 Phase→读 plan+findings；出错→读相关文件；中断/压缩恢复→读全部三文件（Rule 19.3）＋执行规范召回卡（Rule 93.3）。
$ grep -n '两组结构' skills/task-planner/SKILL.md
173:计划文档=唯一事实源，原生 Todo（`TodoWrite`/Task）=执行视图。五个强制同步时机：**S1** 计划创建后建映射→**S2** Phase 状态变更后紧邻同步→**S3** `[plan-sync]` hook 提醒立即回写→**S4** 会话结束前终态同步+`--index`→**S5** 用户新指令影响计划后先改计划再重映射。映射规则与响应协议详见 `references/todo-sync.md`。S1 两组结构（任务组+基线组 B1-B5，Rule 106.5）详见 references/todo-sync.md
$ git diff -- skills/task-planner/SKILL.md --stat
 skills/task-planner/SKILL.md | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)
$ git diff --stat   # worktree 全局（含并行/既有改动，非本次 S2 修改）
 skills/task-discipline/references/critical-rules-discipline.md | 15 +++++++++++++++
 skills/task-planner/SKILL.md                                   | 13 +++++++------
 skills/task-planner/references/todo-sync.md                    | 11 +++++++++++
 skills/verification-gate/references/critical-rules-verification.md |  1 +
 4 files changed, 34 insertions(+), 6 deletions(-)
```

## 自审（≤5 行）

- 仅按 6 锚逐字/同口径修改 `skills/task-planner/SKILL.md`，未改其他段落与表格列结构。
- `1-105` 全清零，`1-106` 三处落位；task-discipline 路由行与核心括注均追加 106 归属。
- 3i 插入 3h 与步骤 4 之间；20.5 与 Todo 同步句尾按指定文本追加，语法/编号保持通顺。
- 目标文件单文件 diff `7 insertions(+), 6 deletions(-)`；未执行 git commit。
- 风险：worktree 全局 diff 另含 3 个并行改动文件（discipline/todo-sync/verification），非本次 S2 产出，已在记录中区分。
