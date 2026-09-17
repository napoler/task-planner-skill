# Knowledge Brief — task-v080-web-research-routing（任务知识简略要点）

> 定位：执行期执行体的稳定知识底座——只读本文件 + 材料包即可获得本任务全部已对齐知识。

## §1 任务速览与核心概念
- 任务一句话：在 SKILL.md 调研章节与 skill-collaboration.md 触发矩阵中，把网络调研显式路由到 research-assistant 技能、网页访问显式路由到 browser-use 插件（Browser Use），并声明 ZCode 平台适配工具优先；纯增量，selftest 全量 0 FAIL 后合并部署 3 位。
- 背景/动机：用户指令——调研网络访问时应使用 browser-use 插件与 research-assistant，技能文本需与 ZCode 实际可用工具对齐（当前 L458 链未点名插件、无平台适配声明）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| browser-use 插件 | ZCode 官方插件，skill=control-browser/web-gui-tester，浏览器控制走 mcp__node_repl__js（宪法 §十：浏览器能力唯一入口） |
| research-assistant | 用户级调研技能（bing-intl-splash→bing-intl-search→searxng-search 链），中文/多源交叉验证主通道 |
| 平台适配工具 | ZCode 实存：WebSearch(web_search_prime 后端)/WebFetch/mcp__web_reader__webReader/mcp__node_repl__js；不存在：playwright/context7/codegraph MCP |
| 纯增量（Rule 36.5） | 只增不改语义：L458 链序①-⑤与工具集合不变，仅注记扩写+新增行；删除性行为清单=空 |

## §2 已验证关键事实

| 事实 | 证据 file:line | 影响 |
|------|---------------|------|
| SKILL.md 共 541 行，调研链在 L458 | skills/task-planner/SKILL.md:458（全文见 §4） | 增补锚点；改后 wc -l 必须 ≤548 |
| `browser-use`/`agent-browser` 在 SKILL.md 0 命中 | grep 实证（材料包 §3） | 确属缺失，非重复添加 |
| playwright/context7/codegraph/claude-mem 残留 0 | grep 实证（材料包 §9） | 无需清理，只需新增防假设声明 |
| 行数断言三处，T2b 545 最紧（仅余 4 行） | selftest-knowledge-brief.sh:38；另两处=skill-collab.sh:81、execution-stability.sh:72（均 548） | 必须前置把 T2b 545→548，否则 +5 行即回归 FAIL |
| collab 触发矩阵行范式（4 列） | references/skill-collaboration.md:60（progress-tracker 行样例） | 新增两行必须对齐该列结构 |
| research-assistant/browser 在 collab 文件 0 命中；该文件 ≤300 行限，现 111 | 材料包 §3/§4 | 加行安全 |
| config.json additionalProperties:false；无 research 路由键 | config.json:421（材料包 §5） | 本轮零新 config 键（D1c），不碰 config.json |
| check-skill-modify.sh 对仓内 skills/** 也触发 | scripts/check-skill-modify.sh:21-35（is_skill_file 匹配 */skills/*） | task_plan「执行范围限制」反引号 token=授权依据 |
| 无相关历史否决（Rule 32 禁令源空） | plans/*/notepad-learnings.md grep 实证 | 方案可放心进候选 |
| 环境事实：mini/sonnet-1 档 agent 无法启动（思考档位缺失），haiku-1 可用 | 本会话三次 spawn 失败记录（plan-writer/general-purpose=sonnet-1，Simple Agent=mini）；Explore=haiku-1 成功 | 执行体只能用 code-assistant/Explore；机械验证走主进程白名单③ |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-planner/SKILL.md | :452-490 | 「## 🔍 调研类操作」章节：L456 路径 1 标题、L458 ①-⑤降级链（增补主锚点）、L460-474 github 路径、L484-488 禁止清单 |
| skills/task-planner/SKILL.md | :364-368 | 子代理路由表调研三行（L364 关键词搜索/L365 github/L368 综合调研→research-assistant）；新增网页访问行插 L365 后 |
| skills/task-planner/references/skill-collaboration.md | :51-60 | §二触发矩阵：L55-59 表头+三族行、L60 progress-tracker 行（范式样例） |
| skills/task-planner/scripts/selftest-skill-collab.sh | :81 | T10 SKILL 行数 ≤548 断言；T11/T12 追加在文件末尾断言序列后 |
| skills/task-planner/scripts/selftest-knowledge-brief.sh | :38 | T2b SKILL 行数 ≤545 断言（本轮唯一允许修改的既有行：545→548） |
| CHANGELOG.md | :10 附近 | `## [Unreleased]` 下 bullet 区，新条目插最前 |
| plans/task-v080-web-research-routing/subagent-state/00-materials.md | 全文 | 材料包：§S-A SKILL 精确 old/new、§S-B 矩阵两行、§S-C selftest 设计、§S-D CHANGELOG 文案 |

## §4 易错点与禁止假设清单
1. **L458 原文（改前必照此核对，仅允许注记扩写）**：
   `阶段与工具：**①WebSearch**（关键词/英文/技术，ZCode 实测可用）→ **②WebFetch**（已知 URL 纯静态页）→ **③web_reader MCP / defuddle**（需 JS 渲染）→ **④splash / Browser Use**（动态页/登录态）→ **⑤Skill("research-assistant") → bing-intl → searxng**（中文/多源交叉）。`
2. T2b（≤545）是最紧行数断言——任何 SKILL.md 增行前先确认 3.1 已把断言改 548 或增行后总数 ≤545。
3. check-skill-modify.sh 对仓内 skills/** 的 Edit 也触发（warn 档提醒放行）；授权依据=task_plan「执行范围限制」表反引号 token，勿在 prompt 里让子代理改表外文件。
4. 禁止假设 browser-use 插件的调用方式是 Agent 派发——它是 Skill（browser-use:control-browser），浏览器控制经 mcp__node_repl__js；文本表述照宪法 §七/§十。
5. S-unit ID 纯数字；执行体 spawn 失败（sonnet-1/mini 档）不要重试同档——降 haiku-1 或主进程白名单③。
6. 全量 selftest 总数以主进程逐 Total 行求和为准，禁采信子代理自报（v074 教训：三次算术错）。
7. 部署对账后必须主进程 diff -r 亲验三位（v077 假 IDENTICAL 教训；DEPLOY_SRC=主仓副本已修复但验证不可省）。
- FMEA RPN>100 兜底指针：→ task_plan.md「📊 FMEA 预演」表 RPN=120 两行（派发被拒→按 22.4 补字段；Edit 走样→精确 old/new+验收不过即拆细重派）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P2-S1 | §1 + §3 + §4.1 | /mnt/data/dev/task-planner-skill/plans/task-v080-web-research-routing/subagent-state/00-materials.md（§S-A） |
| P2-S2 | §1 + §3 + §4.4 | 同上（§S-B，含 L60 范式样例） |
| P3-S1 | §2 + §3 | 同上（§S-C） |
| P4-S1 | §3 | 同上（§S-D） |
| P4-S2 | §2 + §4（纯增量判据） | worktree 内 git diff f0fa427..HEAD |
