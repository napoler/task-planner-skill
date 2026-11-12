# Findings — task-anchor-eread-20261113

## §1 106.1a 条款逐字（S1 执行体消费面）
落点：skills/task-discipline/references/critical-rules-discipline.md 的 Rule 106 段内、106.1 之后新增子条（纯追加）：

**106.1a 结构文件插段纪律（P0，判例=sess_30f4af3e 会话吞锚惯犯 4-7 犯）**：对多段结构文件（计划三文件/规则文/模板——以 ##/### 段落组织的受管文档）做插入型修改前，必须先 grep 段落清单（`grep -nE '^#{2,3} '`）确认锚点行的结构角色（标题行=结构锚，吞它=伤邻接结构）与目标位置；插入型 Edit 的 new_string 必须包含 old_string 锚行原文为子串（锚行在头或在尾，禁止只当定位）；每次此类 Edit 后**强制**跑同一 grep 复检段清单——段数守恒且无重复标题=放行，违者当轮修复。判例：task-docmod-recheck（三犯：消费点标题×2+106.4 整段）+task-tpl-verify-fix（四犯：误插标题/模板残段/📚 双标题/吞 📚+表头重复），全部当轮被 grep 结构回读拦截修复——本条为 106.1 写后回读门对结构文件的细化执行面。

## §2 传播面（S1 一并处置）
- task-planner/SKILL.md 3i 行（docmod 任务落）尾追加：「；结构文件插段另守 106.1a」——最小改。

## §3 决策
- 归属：106.1a 子条（非新 Rule，无需 rule-reserve）；纯文本增量；部署=discipline+SKILL 两文件×3 位。
- 用户裁决 #3：否决另立任务拖延，就地落地（archive/user-session-log #3）。
