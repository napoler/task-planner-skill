# Knowledge Brief — task-v164-pointer-worktree-local（任务知识简略要点）
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：把 `plans/.active_plan` 从 git 跟踪文件改为工作树内瞬态状态文件（`git rm --cached`+`.gitignore`），引用面措辞级联+selftest 回归 0 FAIL+合并规则登记，合并回 master 并部署
- 背景/动机：用户 2026-10-10 反馈指针并行混乱（R2[目标]），实证 v163 会话"移交全局指针"漂移（R5）；git log 实证跟踪态 8 次 churn chore

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| worktree（工作数） | git 隔离开发区，实现类任务必须在其中开发（宪法 §十一）；本任务执行阶段在 `wt/v164-pointer-worktree-local` |
| 全局指针 | `plans/.active_plan`，单文件，`$PWD/plans/` 相对路径（工作树各自一份），当前被 git 跟踪（缺陷） |
| side 指针 | `plans/.active_plan_side/<sid>.active_plan`，会话私有，已 gitignore；resolve 链第一优先（2026-10-07 修复后权威层） |
| 瞬态状态文件 | 即写即弃的运行态（指针/哨兵/检查点），应 ignore 不入库；兄弟范式=.gitignore:1-10 四类 |
| sidmap | `.plan_required_side/<env_sidkey>.sidmap`，env sid→hook sid 映射（SessionStart 写），resolve 侧转译用 |
| mtime 兜底 | resolve 链第三级：plans/*/task_plan.md 更新的最新目录；无 side 无全局时生效 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 指针路径已随工作树本地化（ROOT=$PWD） | set-active-plan.sh:69,84-85；resolve-plan-dir.sh:30 | 用户"路径诉求"已既成，方案只改跟踪态+措辞，禁做路径大改 |
| `.active_plan` 被 git 跟踪，HEAD=已完成 v152 | `git ls-files --error-unmatch plans/.active_plan` + `git show HEAD:plans/.active_plan` | VC-1 判定对象；sid-less 消费者现解析到已完成计划 |
| 跟踪态 churn 8 连（chore 移交/收尾） | `git log --oneline -8 -- plans/.active_plan`（f6d6158…26878fe） | 瞬态化后 churn 止息；VC-4 合并规则要覆盖飞行 worktree |
| side 层已保护真实会话（本会话=v152 side 在 TTL 内） | resolve-plan-dir.sh:58-95；`.active_plan_side/1cefd1cf….active_plan` | 用户所感=全局层漂移+churn 噪音，非 side 失效；级联时禁动解析链 |
| 兄弟瞬态四类已 ignore | 仓根 .gitignore:1-10 | D1 范式依据；`.active_plan` 是唯一漏网 |
| 引用面 28 文件 166 hits | `grep -rn 'active_plan' skills/task-planner/` | Phase 3 逐文件人工判定工作量；多数只读不改 |
| 飞行 worktree 3 个携带 tracked .active_plan | `git worktree list`（v161/v156-decision-alignment/v160-decision-grading） | 合并规则：删除态冲突取删除、指针 set 再生 |
| INDEX:101 v146 行陈旧（pending vs 实际 COMPLETE 10-08） | plans/INDEX.md:101 + 该计划目录 task_plan.md 已归档 | conflict hook 误报来源；不修，登记待后续 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/scripts/set-active-plan.sh | :69 | ROOT 默认 $PWD（F4 修复：计划目录内运行时取上上级） |
| skills/task-planner/scripts/set-active-plan.sh | :84-87 | PLAN_ROOT/ACTIVE_FILE/SIDE_DIR/SID 定义（SID=norm_sid(CLAUDE_CODE_SESSION_ID)） |
| skills/task-planner/scripts/set-active-plan.sh | :116-132 | `--show`：全局+side+解析三行输出 |
| skills/task-planner/scripts/set-active-plan.sh | :169-194 | gc 全局指针生命周期（dead-ref/completed-ttl→置空不删文件） |
| skills/task-planner/scripts/set-active-plan.sh | :215-259 | `set` 模式：**只写 side**（含所有权守卫+--force）；legacy 位置参数模式 :260-267 才写全局 |
| skills/task-planner/scripts/set-active-plan.sh | :1-21 | 头注释（"全局 legacy"叙事所在，S2 改述对象） |
| skills/task-planner/scripts/resolve-plan-dir.sh | :30-46 | ROOT/SID 规范化（norm_sid 剥非字母数字+sess 前缀） |
| skills/task-planner/scripts/resolve-plan-dir.sh | :58-95 | side 层：双命名空间兼容读+sidmap 转译+TTL 24h |
| skills/task-planner/scripts/resolve-plan-dir.sh | :97-105 | 全局层（legacy 文件形态；目录形态=迁移残留忽略） |
| skills/task-planner/scripts/resolve-plan-dir.sh | :107-129 | mtime 兜底+legacy 根单文件 |
| skills/task-planner/scripts/resolve-plan-dir.sh | :1-27 | 头注释（解析链描述，S2 改述对象） |
| 仓根 .gitignore | :1-10 | 运行时瞬态 ignore 四类（S1 追加点=同段风格） |
| skills/task-planner/scripts/selftest-active-plan.sh | 全文 | 指针解析断言（Phase 1 复读+Phase 4 重点回归） |
| skills/task-planner/scripts/selftest-pointer-lifecycle.sh | 全文 | 指针生命周期（F1-F4/gc）断言（同上） |
| skills/task-planner/references/critical-rules.md | 实施日重测 | 指针/active-plan 相关段+S-unit 合并规则登记段（Phase 1 定位行号） |
| plans/fix-pointer-race-20261007/ | 目录 | 上一轮修复先例（RC-1/2/3+sidmap），禁重复设计 |

## §4 易错点与禁止假设清单
1. 禁改解析链顺序与语义（side→global→mtime→legacy 冻结）：本任务只改 git 跟踪态与措辞；任何"顺手优化解析"= scope 蔓延
2. 禁 `grep+sed` 批量替换 166 hits：多数是只读消费方（hooks/check-*/selftest 跑 resolve），批量替换必误伤；须逐文件人工判定记录
3. 禁删工作区 `.active_plan` 文件：`git rm --cached` 保留工作区文件为瞬态；删文件=sid-less 消费者丢锚点（D3 已否决同思路）
4. `.gitignore` 是仓根文件**不随技能部署**：VC-5 部署 diff 不含它是预期差，禁"补部署"造差异
5. 新 worktree 无全局指针（瞬态化副作用）=mtime 兜底竞态：Phase 4 VC-2 行为验证必覆盖；如需 seed 属备选，默认不改
6. 飞行 worktree（v156/v160/v161）合并回时 `.active_plan` 冲突=按瞬态处置（取删除态，指针 set 再生），禁手工抢救指针值
7. `set` 模式只写 side（:215-259），legacy 位置参数才写全局（:260-267）——验证 VC-1 时用对模式，禁误判"set 没写全局=bug"
- FMEA RPN>100 兜底指针：→ task_plan.md Phase 4「行为验证漏新 worktree 无全局指针场景」行

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|-------------------|-------------|
| S1（基线跑批） | §2（side 保护事实）+ §3（selftest 锚） | worktree 根（master FF 后 79cd10a 态） |
| S2（git 索引瞬态化） | §2（跟踪态事实）+ §3（.gitignore 锚） | /mnt/data/dev/task-planner-skill/.gitignore |
| S3（头注释改述） | §3（两脚本头注释锚）+ §4.7 | skills/task-planner/scripts/set-active-plan.sh、resolve-plan-dir.sh |
| S4（引用面分级） | §2（引用面规模）+ §4.2 | `grep -rn 'active_plan' skills/task-planner/` 输出 |
| S5（critical-rules+SKILL 改述） | §3（critical-rules 指针段锚，实施日重测） | findings.md [sub:4] 级联清单 |
| S6（README+INSTALL 改述） | §3（文档锚） | findings.md [sub:4] 级联清单 |
| S7（userpromptsubmit+posttooluse 注释） | §3（hooks 锚） | findings.md [sub:4] 级联清单 |
| S8（pretooluse+task-plan-init.cjs 注释） | §3（hooks 锚） | findings.md [sub:4] 级联清单 |
| S9（init-session+plan-created.cjs 注释） | §3（hooks 锚） | findings.md [sub:4] 级联清单 |
| S10（check-dispatch+check-complete 注释） | §3（hooks 锚） | findings.md [sub:4] 级联清单 |
| S11（回归跑批） | §2（基线事实）+ §4.5 | baseline-selftest.log（对照） |
| S12（行为验证） | §4.5/§4.6 | 主进程给定验证命令原文 |
| S13（CR） | §4.3 | worktree `git diff master...HEAD` |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| git-ops | ~/.zcode/skills/git-ops/SKILL.md | git rm --cached/合并规则/worktree 操作规范 | 子代理 prompt 挂载 / 主进程 Skill 调用 |
| using-git-worktrees | ~/.zcode/skills/using-git-worktrees/SKILL.md | Phase 1 worktree 建立与清理 SOP | 主进程 Skill 调用 |
| verification-before-completion | ~/.zcode/skills/verification-before-completion/SKILL.md | 完成声称前三要件（执行/产出/验证证据） | 主进程 Skill 调用（终验前） |
| receiving-code-review | ~/.agents/skills/receiving-code-review/SKILL.md | Phase 4 CR 意见分类处置 | 子代理 prompt 挂载 |
| alignment-review | ~/.zcode/skills/alignment-review/SKILL.md | 交付前对齐审查（Code Review 配置登记项） | 子代理 prompt 挂载 |
