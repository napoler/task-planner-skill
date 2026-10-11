# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话：「优化当前技能 就是 调研网络访问时候 使用 browser-use 插件 和 research-assistant 来完成网络调研 访问网络内容 确保 在zcode中优先使用 适配当前平台的工具」
- 拆解：①SKILL.md 调研链显式指向 browser-use 插件（control-browser/mcp__node_repl__js）与 research-assistant（主通道）②新增平台适配优先声明 ③纯增量（Rule 36.5），selftest 全量 0 FAIL，合并回+3 位部署

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 勘察材料包 | plans/task-v080-web-research-routing/subagent-state/00-materials.md | ☑ | Research Findings 全段 |
| ZCode 宪法 §七/§十 | ~/.zcode/AGENTS.md | ☑ | Requirements/路由语义（WebSearch 实测可用；浏览器=Browser Use 唯一入口；不存在 playwright/context7 MCP） |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **P2-S1/S2 落地结果（主进程接管，2026-09-17）**：SKILL.md=543 行（+2），L458 链注记已显式化 browser-use 插件（control-browser/mcp__node_repl__js）与 research-assistant 主通道定位，新增平台适配声明（禁假设 playwright/context7）；路由表新增「网页访问」行（Browser Automation，6 列）。collab §二矩阵 L61/L62 新增 research-assistant/browser-use 两行（4 列范式）。验收 grep 全过（checkpoint=01-code-assistant.md）。skill-modify 守卫在 worktree 解析不到主仓授权表 → warn 假阳性放行，已记录。
- **Explore 勘察（agent_60fd2900，2026-09-17）**：SKILL.md 541 行，调研章节 L452-490，降级链 L458（①WebSearch→②WebFetch→③web_reader/defuddle→④splash/Browser Use→⑤research-assistant）；`browser-use`/`agent-browser` 0 命中；playwright/context7 残留 0。行数断言三处：skill-collab.sh:81(≤548)/execution-stability.sh:72(≤548)/knowledge-brief.sh:38(≤545 最紧)。collab 触发矩阵 L51-60（4 列范式），research-assistant/browser 0 命中（现 111 行/上限 300）。check-skill-modify.sh 对仓内 skills/** 也触发（is_skill_file 匹配 */skills/*，task_plan 执行范围表 token=授权）。config.json additionalProperties:false(L421) 无 research 键。证据：00-materials.md §1-§10
- **全量 selftest 基线（P1，worktree=f0fa427）**：21 个 selftest 主进程逐 Total 行求和 = **349 PASS / 0 FAIL**，日志=plans/task-v080-web-research-routing/subagent-state/p1-baseline-selftest.log（与 v079 交付基线 349/0 一致）
- **执行体可用性实证（P1）**：sonnet-1 档（plan-writer/general-purpose）与 mini 档（Simple Agent）Agent 派发全部失败，错误=`No reasoning level selected / 未选择思考档位 [reason=reasoning-level-missing]`；haiku-1 档可用（Explore agent_60fd2900 成功执行 28 次工具调用）。结论：本会话执行体只可用 code-assistant(haiku-1)/Explore(haiku-1)，机械验证走主进程白名单③

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 路由内容落 SKILL.md（≤+7 行）+ skill-collaboration.md（+2 行），不新增 Rule、零新 config 键 | 路由=操作指引非流程铁律；新增 Rule 引发 1-37 全链级联（selftest 锚/合规清单/文档同步）；v076 零新键先例 |
| L458 链改写定性=注记增补（非语义改写） | 链序①-⑤与工具集合不变，仅扩写④⑤注释+声明行；Rule 36.4 D6 不触发 |

## 🔒 Rule 36.3 删除基线（修改前）
- 基线版本：master f0fa427（worktree wt/task-v080-web-research-routing 同源）
- **删除性行为清单 = 空（纯增量任务，Rule 36.5）**
- 唯一允许的既有行修改：scripts/selftest-knowledge-brief.sh:38 行数断言数值 545→548（行数上限上调，非功能删除；v079 先例）
- L458 既有文字（改前原文，改后必须仍含①-⑤全部工具名与顺序）：`阶段与工具：**①WebSearch**（关键词/英文/技术，ZCode 实测可用）→ **②WebFetch**（已知 URL 纯静态页）→ **③web_reader MCP / defuddle**（需 JS 渲染）→ **④splash / Browser Use**（动态页/登录态）→ **⑤Skill("research-assistant") → bing-intl → searxng**（中文/多源交叉）。`

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| attestation 前置门控两次拒锁/告警（S-unit 行 ID `2.1` 不匹配 `^| S<n> |` 正则；template_type 写在 HTML 注释未被 `^template_type:` 识别；FMEA 表 6 列不匹配 $7=RPN 口径） | S-unit ID 改 S1/S2 每Phase 内编号；template_type 升级为 YAML frontmatter；FMEA 表加编号列成 7 列（$7=RPN/$8=兜底）；三处修后 attest 一次通过（SHA 22e42d82） |
| sonnet-1/mini 档子代理无法启动（思考档位缺失，环境级） | Rule 22.3 ①改派③降档穷尽后④主进程接管计划撰写（白名单②）；执行体改 code-assistant/Explore(haiku-1)；已登记 Decisions #5 |
| haiku-1 档 code-assistant 也 spawn 失败（Explore 同档曾成功）→ 全档位不可用 | Rule 22.3④ 主进程接管 P2-P4 全部（Decisions #9）；CR 降级为主进程 diff 自审+355/0 全量回归独立兜底 |

## Code Review（P4-S2 主进程自审，spawn 失败降级）
- **结论：APPROVED**（2026-09-17）
- 范围：git diff f0fa427 = 5 文件 +18/-2，全部在计划执行范围白名单内
- 纯增量（VC-5）：删除行恰 2 行=L458 原链行（注记替换，五记号①-⑤与工具集合 grep 验证不变）+T2b 旧断言行（545→548），零功能性删除
- 正确性：S1/S2 验收 grep 9/9 过；链序完整；SKILL.md 543≤548
- 断言质量：T11a-d/T12a-b 沿用 t-范式；阈值语义=下限守卫（browser-use≥3）与禁入守卫（playwright=1），意图明确
- CHANGELOG：条目与实际一致（功能文本净增 4=SKILL+2/collab+2）
- 联动（P4-S3）：README/critical-rules/templates/config 零级联需要（模板无旧链原文引用；无新 Rule/config 键）；SKILL 内部 L113/L368 与新增行语义一致；collab T1/T2/T3 联动断言经全量回归证明仍过

## Resources
- 材料包：plans/task-v080-web-research-routing/subagent-state/00-materials.md（现状 file:line/修改设计 S-A..S-E）
- 基线日志：plans/task-v080-web-research-routing/subagent-state/p1-baseline-selftest.log
- worktree：/mnt/data/dev/task-planner-skill-worktrees/task-v080-web-research-routing（分支 wt/task-v080-web-research-routing @ f0fa427）

## Visual/Browser Findings
-（无多模态产出）
