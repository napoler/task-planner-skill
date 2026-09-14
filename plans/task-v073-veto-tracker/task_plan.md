# Task Plan: task-v073 用户否决与禁令追踪（Rule 32 防倒退门控）

## Goal
用户 2026-09-14 指出：历史中多次裁决"不允许 X / X 是错的"，后期提建议时 agent 仍把已否决方案重新投进计划（倒退式改法）→ 循环开发浪费。落地 Rule 32：禁令登记 → 计划期/执行期提方案前必查 → 无新验证证据禁止重提/改回 → 解禁仅限用户显式撤销或可引用新证据。

## 31.2 归因（dogfood，本计划立项依据）
现象=已否决方案被复推；直接原因=提方案无禁令检查步骤；根因=禁令无结构化登记源+无消费点（Decisions Made 任务级沉没，宪法 §四 无 skill 机制层落地）；类别=规则缺位。

## Phases
### Phase 1: 规则层 — critical-rules.md Rule 32（32.1-32.5）+ 31.5 消费侧联动
- **Status:** pending
- **Executor:** 主进程（白名单②计划系统文件维护；纯 .md 条款）
- **VC-1:** `^32\.[1-5]` 五子条在位；32.2 含"提出方案前必查"锚点；32.4 含两条解禁条件
- **VC-2:** 31.5 消费侧含「被否决方案」段阅读联动

### Phase 2: 模板 + SKILL.md 联动
- **Status:** pending
- **Executor:** 主进程（同上）
- notepad-learnings.md 加「🚫 被否决方案（User Rejected — Rule 32）」段；SKILL.md：frontmatter 1-32 / 摘要行 Rule 32 / References 表 / C20 / 错误指出特判段补"用户说'不允许/禁止 X'"登记句
- **VC-3:** SKILL.md 5 处联动 grep 通过；C20 在位
- **VC-4:** notepad 模板段在位

### Phase 3: config + selftest-veto.sh + 行数上限同步
- **Status:** pending
- **Executor:** 主进程（③机械验证）
- config.json `veto_enforce`（默认 warn）；scripts/selftest-veto.sh ~14 断言；selftest-skill-collab T10 / execution-stability T8b 行数上限 530→538
- **VC-5:** jq 合法 + 键默认 warn
- **VC-6:** selftest-veto 全绿 + 全量回归 0 FAIL

### Phase 4: 部署 + 簿记
- **Status:** pending
- **Executor:** 主进程（①编排+②簿记）
- 3 实体位 rm+cp -rL + diff -r=0；INDEX v073 + ledger done 条目；push
- **VC-7:** 3 位 diff=0；canonical push 成功

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 独立 Rule 32 而非并入 31 | 31 管错误归因防复现，32 管用户否决防倒退——数据源（用户裁决 vs 根因分析）与消费点（提方案前 vs Phase 开工前）不同 |
| 禁令登记落 notepad 段（不另建文件） | 三文件罗盘原则；31.5 消费侧已有 notepad 阅读链路可搭 |
| 不主动批量回填历史否决 | YAGNI；32.2 禁令源含 plans/ 历史 grep，用户点名时再回填 |
| direct 开发（不建 worktree） | 延续本会话 v072 既定模式；改动集中 skills/task-planner + plans/，冲突面小，用户要求即时修正 |

## 隔离决策
direct（主仓）；部署时 rm+cp -rL 3 实体位
