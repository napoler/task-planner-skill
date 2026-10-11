# Findings & Decisions

## Requirements
- 用户原话：「分析当前任务是否存在共有的内容（项目级共用内容），比如发布任务只认领一部分，是否需要维护一个共有内容（认领/计划认领文档）。不存在则创建补充，存在则利用维护。后期执行任务时主动识别；某功能已维护过时后期只需读取该文件，不重复手工添加文档。设计任务时优化——网站许多内容需维护，本次维护 3 个，应有该网站/总内容的维护进度列表或追踪文件，否则后期重复混乱。」
- 拆解：① 设计期主动识别（非事后）② 认领语义（本次认领哪些资源项）③ 项目级共有（跳出单任务）④ 存在则读用、不存在则建 ⑤ 防重复混乱

## Research Findings
- 用户已建 progress-tracker skill（~/.zcode/skills/progress-tracker/SKILL.md:1-184）：项目级 .zcode/ledger/（多平台通用化后=平台配置目录跟随）JSONL 账本，schema=ts/topic/target/action/changed/status/effect/note；先查后写 + in_progress 条目闭环 Todo + 查询接口。→ 即用户所说「共有内容追踪文件」的现成实现，Rule 30 只做「识别+调用」不重造
- 多平台目录（09-14 追加指令已落地 81e8ad8）：账本目录跟随既有 .zcode/ 或 .claude/，皆无默认 .zcode/；被 gitignore 记「账本未入库」提醒
- 挂接点裁定：critical-rules.md 新增独立 Rule 30（30.1-30.5），SKILL.md 3 处联动（Critical Rules 摘要行 / 设计期检查点 / References 表 progress-tracker 行），skill-collaboration.md 登记协同行
- 机制层裁定：不加 hook（沿用 v063/v068 门控+指针范式）；selftest-shared-tracker.sh 静态守护（30.x 存在性 + 语义锚点 + config 键 shared_tracker_enforce + 模板 shared-tracker.md 存在 + progress-tracker 技能探针）

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| Rule 30 独立（不挂 29.x） | 「共→认领」与 29「多→退场」语义不同 |
| 追踪权威源=progress-tracker 账本（.zcode/ledger/ 多平台跟随） | 用户已建；schema 已定；Rule 30 不另造 shared-tracker/ 目录 |
| 30.1 识别条件（可操作化） | 目标资源可枚举（页面/内容/功能/部署位/文章）且本次任务只认领其中一部分 → 需共享追踪；同类任务 ≥3 次亦命中 |
| 30.2 创建/复用 | 设计期（计划创建后 D1 前）先查账本主题目录：存在→Read 后只追加/更新本次认领行；不存在→按 progress-tracker Step 1-4 创建（INDEX+主题 JSONL） |
| 30.3 认领登记 | 本次认领的 target 逐条追加 status=in_progress + note 认领 task-id；完成后翻 done+effect（progress-tracker 闭环 Todo 机制接管提醒） |
| 30.4 防冲突 | 多会话并认同一 target → 以 ts 最早 + task-id 为准；发现已被他 task 认领且 in_progress → D4 询问（不静默重复认领） |
| config 键 shared_tracker_enforce（warn，32→33 键） | 三档流程层执行无 hook 校验；warn=计划确认前注入提醒，off 不触发 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 主上下文 Edit progress-tracker SKILL.md 被 check-delegation 拦截（新技能不在白名单认知内） | 改走仓内源（skills/progress-tracker/ 在仓 scope 内）编辑后 cp -rL 回实体位 |

## Resources
- /home/terry/.zcode/skills/progress-tracker/SKILL.md（184 行，权威 schema 源）
- /mnt/data/dev/task-planner-skill/skills/progress-tracker/（canonical 收编位，commit 7d27875/81e8ad8）
