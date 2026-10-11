# task-v080 材料包（勘察结论，供 plan-writer 与执行 S-unit 引用）

仓库=/mnt/data/dev/task-planner-skill @ f0fa427（master=origin/master，工作树干净，无遗留 worktree）
技能根=skills/task-planner/（部署副本 3 位：~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）

## 任务定义（用户原话→等价目标）
优化 task-planner 技能：调研网络/访问网页内容时，明确路由到 research-assistant 技能（网络调研）与 browser-use 插件（Browser Use，网页访问），并声明优先使用 ZCode 平台实际可用工具（WebSearch、mcp__web_reader__webReader、mcp__node_repl__js）。纯增量，禁止功能删除。

## 关键现状（file:line 实测）
1. SKILL.md 共 541 行；「## 🔍 调研类操作」L452-490；降级链在 L458：
   `阶段与工具：**①WebSearch**（关键词/英文/技术，ZCode 实测可用）→ **②WebFetch**（已知 URL 纯静态页）→ **③web_reader MCP / defuddle**（需 JS 渲染）→ **④splash / Browser Use**（动态页/登录态）→ **⑤Skill("research-assistant") → bing-intl → searxng**（中文/多源交叉）。`
   缺：browser-use 插件名（browser-use:control-browser / mcp__node_repl__js）显式指向；research-assistant 主通道定位；平台适配优先声明。
2. SKILL.md 子代理路由表 L364-368：L364 关键词搜索→web-search-agent；L365 github 调研→web-search-agent+gh；L368 综合调研→research-assistant(sonnet-1)。无「网页访问（JS 渲染/登录态）」行。
3. `browser-use`/`agent-browser` 在 SKILL.md 0 命中；playwright/context7/codegraph/claude-mem 残留 0（无需清理）。
4. skill-collaboration.md 共 111 行（上限 300）；§二 触发矩阵 L51-60；行范式样例 L60（progress-tracker 行）：
   `| progress-tracker（嵌入，Rule 30 专属触发，task-v071） | <触发条件→动作> | <成本> | <CLI 探针前置> |`
   research-assistant / browser 在该文件 0 命中。§五 反模式清单 L104。
5. 行数断言三处：
   - scripts/selftest-skill-collab.sh:81 `t "T10 SKILL.md 行数 ≤548" ...-le 548`
   - scripts/selftest-execution-stability.sh:72 `t "T8b SKILL.md 行数 ≤548" ...-le 548`
   - scripts/selftest-knowledge-brief.sh:38 `t "T2b SKILL.md 行数 ≤545（task-v076 扩充）" ...-le 545`（最紧，仅余 4 行）
6. config.json 421 行 JSON-Schema，additionalProperties:false(L421)；无 research/网络路由键；本轮零新 config 键（v076 先例）。
7. critical-rules.md 311 行，Rules 1-36，无任何 WebSearch/网络工具路由 Rule（不新增 Rule，避免 1-37 级联）。Rule 36=L301-311。
8. selftest 共 21 个；selftest-skill-collab.sh 19 断言 T1-T10（T1 含 collab ≤300 行+含「三族、触发矩阵、22.3.3、移交」）。
9. check-skill-modify.sh 会拦截仓内 skills/task-planner/** 的 Edit（is_skill_file 匹配 */skills/*；默认 warn 档放行+提醒；计划「执行范围限制」表登记反引号路径 token=显式授权 exit 0）。
10. 否决扫描（Rule 32）：plans/*/notepad-learnings.md 无调研/网络/browser/research 相关否决条目。
11. CHANGELOG.md 存在（根目录，## [Unreleased] 下加 bullet）；plans/INDEX.md 由 sync-todos.sh --index 刷新。
12. 模板 templates/variant/rule-enhancement-type.md（78 行）：Goal/Code Review 配置/VC/执行范围限制/Phases 1-5/必要知识储备。

## 设计决策（D1 已定，silent 模式）
- D1a 交互模式=silent（无人值守会话，env/config 均未定 ask 生效场景；v076 先例），交付报告附静默决策清单。
- D1b 纯增量（Rule 36.5）：L458 链为「注记增补」（顺序①-⑤与工具集合不变，仅扩写 ④⑤ 注释+平台声明），非功能性删除/语义改写 → 不触发 36.4 D6 硬停；删除性行为清单=空（36.3 基线照登）。
- D1c 零新 config 键；不新增 Rule（路由属操作指引非流程铁律）。
- D1d SKILL.md 净增上限 7 行（≤548）；selftest-knowledge-brief.sh T2b 断言 545→548 与另两处对齐（v079 B类扩围教训前置化）。
- D1e worktree 隔离：/mnt/data/dev/task-planner-skill-worktrees/task-v080-web-research-routing，分支 wt/task-v080-web-research-routing，基于 master；合并回用 smart-merge-back.sh --deploy；禁止动主仓工作树任务范围外文件。
- D1f 共享内容追踪（Rule 30）不适用：部署位为合并窗口独占认领，非部分认领、非同类 ≥3 批量。

## 修改内容设计（执行 S-unit 据此实施）
S-A SKILL.md（≤+7 行）：
  A1 L458 链注记增补：④ 扩为 `**④splash / Browser Use**（browser-use 插件 control-browser / mcp__node_repl__js；动态页/登录态/交互）`；⑤ 扩为 `**⑤Skill("research-assistant") → bing-intl → searxng**（网络调研主通道；中文/多源交叉）`。
  A2 L458 行后新增 1 行平台适配声明：非英文快查与需渲染页面优先 research-assistant/Browser Use 等 ZCode 适配工具；禁假设 playwright/context7 等不存在 MCP（宪法 §十对齐）。
  A3 路由表 L365 后新增 1 行：`| **网页访问（JS 渲染/登录态/交互页）** | Browser Automation（browser-use 插件 control-browser / mcp__node_repl__js） | mini | ❌ | ≤1 批 URL，≤120s/次 | 超时降级 web_reader/splash 链 |`（列结构对齐 L364-368 现有 7 列）。
S-B skill-collaboration.md（≤+4 行）：
  B1 §二矩阵加 research-assistant 行（范式对齐 L60：嵌入，调研类任务触发→子代理内 Skill 调用，成本中，探针=无纯 .md 缺失降级 WebSearch 链并提醒）。
  B2 §二矩阵加 browser-use 行（嵌入，网页访问触发→control-browser/mcp__node_repl__js，成本中，探针=插件启用，缺失降级 web_reader/splash 链并提醒）。
S-C selftest（+断言与对齐）：
  C1 selftest-skill-collab.sh 新增 T11：SKILL.md 含 browser-use 插件路由（grep 'browser-use' SKILL）+ research-assistant 主通道；T12：collab 矩阵含 research-assistant 行与 browser-use 行。
  C2 selftest-knowledge-brief.sh:38 断言 545→548（文案同步）。
S-D CHANGELOG.md：Unreleased 下加 1 bullet（网络调研/网页访问工具路由明确化，task-v080）。
S-E 部署与簿记：smart-merge-back --deploy → 3 位 diff -r IDENTICAL → INDEX 刷新 + verification + notepad。
