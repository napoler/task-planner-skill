# Checkpoint 1-research-a (sub:research-a)

status: done
budget: 30min (实际 ~10min 完成)
scope: 只读调研 task-planner 仓 companion agents 定义/部署/守卫机制

## 结论（五项）

### A1 格式规范（逐文件一行）
- complex-planner.md:48行: frontmatter=name/display 显示名 `name: Complex Planner` + tools 含 Agent + `model: "account:zai-individual-coding-plan/GLM-5.3"`（引号式 account: 格式）+ `thoughtLevel: enabled`；正文骨架=定位/触发门槛/禁用清单/规划产出契约五段/证据要求/禁止行为/输出模板
- plan-writer.md:288行: `name: Plan Writer` + `model: "custom:9e221f47-...:sonnet-1"` + tools 含 Write/Edit；正文=超时约束开头+模板映射表+产出契约
- article-batch-publisher.md:156行: `name: article-batch-publisher`（小写连字符名）+ model=sonnet-1 + `color: '#E63946'`；正文=超时约束+定位
- article-field-fixer.md:59行: model=haiku-1 + color 字段；最简骨架
- 注：frontmatter 首行是空行（`---` 后有空行），4 文件一致；complex-planner 用 display name，其余 article 系用 kebab name——两种 name 风格并存

### A2 部署链路
- 安装到哪: `lib/install-companion.sh` glob 循环 `for f in "$COMPAANION_DIR"/agents/*.md`（install-companion.sh:163 段）逐文件 cp 到 `$TARGET_ROOT/agents/<basename>`，TARGET_ROOT 自动探测 ~/.zcode → ~/.claude
- install.sh:183-188 = Phase 5.6 调用点（仅当 companion/ 存在）；幂等 cmp 跳过；非 FORCE 时旧内容备份 companion/.backup-<date>/
- Claude 平台 model 行适配: adapt_model_line（install-companion.sh:52-90）把 `custom:<uuid>:<slug>` 转纯档名（sonnet-1→sonnet, haiku-1→haiku, opus-1→opus）
- 新增 agent **零机制改动**：glob 通配自动覆盖；但 `account:` 前缀模型（complex-planner 的 GLM-5.3 格式）不在 adapt 映射内 → 部署到 ~/.claude 会落入 default 分支 `"<slug 反转义>"` 引号串
- 「部署 2 位」证据: plans/task-v119/progress.md:81（定向 cp ~/.zcode/agents/complex-planner.md + cp/sed model 行→~/.claude/agents/ model: opus）；verification.md:21-22（VC-5 md5 双位一致 + diff 仅 model 行）
- 反向同步: scripts/sync-companion.sh 把部署位改动拉回 canonical（本机 UUID 从 ~/.zcode/agents 提取重绑）
- README_zh.md 提示（行末注释，INSTALL_zh 尾部）：companion agent 变更后需重跑 lib/install-companion.sh 或定向 cp

### A3 守卫级联面
- 无 registry 式 agent 登记表：selftest-registry.tsv 只登记 selftest 脚本自身（域/触发/锚点），不含 agent 枚举
- 新增 1-2 agent 命中断言面 = **零**（全仓 selftest 无一断言 agent 清单/数量；v119 先例 findings 亦确认「selftest 仅锚 plan-writer 单文件，新增文件零守卫破坏」）
- 单文件锚引用（新增 agent 不触发但风格参照）: selftest-knowledge-brief.sh:18（PLANWRITER 变量）、selftest-tool-selection.sh:32、selftest-reliability-institution.sh:28、selftest-conclusion-discipline.sh:40、selftest-methodology.sh:54-55,215——全部指向 companion/agents/plan-writer.md 单文件内容断言
- 文档级联面（v119 后已 stale，新增 agent 需一并更新）:
  - install.sh:179 注释「plan-writer/article-batch-publisher/article-field-fixer」（漏 complex-planner）
  - README_zh.md:114「3 个伴生 agent（plan-writer 等）」（实为 4 个）
  - INSTALL_zh.md:306-308 树状图「3 个配套 agent」（实为 4 个）
  - INSTALL.md:137-139 表格仅列 3 行（无 complex-planner 行）
- smart-merge-back.sh --deploy: **不处理 companion/agents**——其 SLOTS=3 个 skills/task-planner 部署位（smart-merge-back.sh:377-381），DEPLOY_SRC=主仓 skills/task-planner 整目录（L1 文件集合差 + L2 内容 diff）；companion/agents 在 skills/task-planner/ 树下 → L1 `find -L` 会将其计入文件集合，但 cp -rL 实体化整目录，新增 .md 自动随槽位复制；对账差异仅当部署位缺文件时报 DRIFT。即 --deploy 覆盖 skill 树（含 companion），但 agents 用户目录（~/.zcode/agents）不在 SLOTS 内

### A4 complex-planner 先例要点（v119, merge commit a4bbd19）
- 改动面: 仅 1 文件 +48 行（`git show a4bbd19 --stat`: companion/agents/complex-planner.md 单文件 merge）
- 部署: 主进程白名单直做 cp 2 位（zcode 原样 / claude model 行改 opus），不经 install-companion（先于日常同步）
- 路由登记: ~/.zcode/skills/skill-agent-router/SKILL.md:98 加 1 行（agent 名 | 触发场景 | 禁用边界 三列）
- 明确不联动（D4 deferred）: 仓内「升级 ComplexProblemSolver」叙事 3 处（SKILL.md:339/349 + critical-rules.md:149）不动——Rule 36 保守化 + v117 守卫教训
- VC 设计: 4 条 grep 逐行断言 frontmatter/正文段 + 全量 selftest 42 脚本 660 用例零回归
- 全仓引用点: install.sh:179 注释、INSTALL.md:137-139（漏登记=stale）、README_zh:114/INSTALL_zh:306（3→4 stale）、complex-planner.md:47 自引用 plan-writer、plans/task-v119/{task_plan,findings,progress,verification}.md

### A5 description 触发词惯例摘要
- 结构: 职责一句话 | 能力/定位 | MUST BE USED / 启用门槛 | `触发:<词1>|<词2>|...` 显式触发词段（竖线分隔）| 与同类 agent 区别句
- complex-planner: 触发词 5 个（complex planning/升级规划/备用方案/任务过于复杂/deep plan）+ 独立「禁用:」段显式列禁用场景与改派去向（code-assistant/executor）
- article-batch-publisher: `MUST BE USED for 批量发布|article publish|publish articles。触发:批量发布|publish articles|批量发布文章|Django API发布`（中英混排）
- article-field-fixer: 同模式，MUST BE USED + 触发 5 词
- plan-writer: 触发 7 词 + 双区别句（与 planner 区别 / 与 executor 区别）——无「MUST BE USED」措辞
- 共性: 中文为主+英文词混排、竖线 `|` 分隔、禁用/区别句指向具体改派对象

## T5 最终结论

```
status: done
acceptance: 5/5 pass — [A1 格式规范逐文件一行✓ A2 部署链路✓ A3 守卫级联面✓ A4 complex-planner先例+全仓引用✓ A5 description触发词惯例✓]
files: /mnt/data/dev/task-planner-skill/plans/task-v124/findings.md(+1 追加段); /mnt/data/dev/task-planner-skill/plans/task-v124/subagent-state/1-research-a.md(+1 本检查点)
evidence: complex-planner.md:4-7 frontmatter四要素; install-companion.sh agents glob 循环(~:163); smart-merge-back.sh:377-381 SLOTS=3 skills 槽; task-v119/progress.md:81 部署2位; skill-agent-router/SKILL.md:98 complex-planner 行; selftest 无 agent 枚举断言(6 脚本仅锚 plan-writer 单文件)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v124/subagent-state/1-research-a.md (status: done)
findings_written: findings.md「## Research Findings」段末 #### [sub:research-a] companion agents 机制调研
blockers: none
confidence: HIGH
```
