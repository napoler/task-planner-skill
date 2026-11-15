# fix-f2b (C-2/C-9) checkpoint

- batch: F2b (critic C-2/C-9)
- worktree: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115
- scope_files_modified:
  - skills/task-planner/README.md
  - skills/task-planner/docs/ARCHITECTURE.md

## C-2 幽灵 references/ 路径修正
- grep -rn 'plan-template-advisor/references' (worktree, before): 4 hits
  - README.md:72
  - docs/ARCHITECTURE.md:69,78,105
- fixes:
  - README.md:72 `../plan-template-advisor/references/` -> `../plan-template-advisor/SKILL.md`（调用条件列补实：激活后分析项目→预测问题→缺口映射→产出候选模板→审查→登记）
  - ARCHITECTURE.md:69 注释路径 `../../plan-template-advisor/references/` -> `../../plan-template-advisor/SKILL.md`
  - ARCHITECTURE.md:105 §3 路由表路径 `../../plan-template-advisor/references/` -> `../../plan-template-advisor/SKILL.md`（调用条件列同语义充实）
- verify: `grep -c 'plan-template-advisor/references' skills/task-planner/README.md skills/task-planner/docs/ARCHITECTURE.md` => `0` / `0`; SKILL.md 指向 README=1, ARCHITECTURE=4

## C-9 ARCHITECTURE §2.1 advisor 行列语义充实
- 对照邻行语义（task-dispatch/task-discipline/media-planner: 定位=管「…」职责；域边界=不管…；规则数；规则全文路径）
- ARCHITECTURE.md:78 §2.1 表 advisor 行改为：
  - 定位: 管「项目模板适配与沉淀生产」——激活后分析当前项目→预测执行问题→缺口映射→产出候选模板→审查→登记入库的轻量 SOP 执行体
  - 域边界: 不管官方模板选型/生命周期（归 plan-template-kit）、机械发现/模板校验脚本（归 task-planner 脚本层）；规则承载=Rule 34.8/34.9 随 SKILL 内联
  - 规则数: 0（内联）（原“0”空洞值充实为内联说明，非“规则数 0”类空洞填充残留）
  - 规则全文: `../../plan-template-advisor/SKILL.md`
- 表结构与邻行一致，Read 回读 §2.1 表头/分隔线/advisor 行完整。

## 约束遵守
- 仅修改上述 2 文件；未改其他文件；未触碰 tmp/worktrees/task-clause-generalize-20261115。
- 基于 advisor SKILL.md（SOP 六步+边界铁律）充实语义，列结构对齐邻行。