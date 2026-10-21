# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### [sub:explore] 知识沉淀设施盘点（2026-10-22）
- **核心结论**：单任务内沉淀已完备（knowledge-brief 第 7 文件+Rule 62 双落盘门控，113 份归档实证）；真正缺两个连接件——①跨任务聚合层（152 归档任务在 plans/INDEX.md 零条目，归档即失联，无「知识→来源任务→锚点」聚合表）②项目知识域检索入口（scripts/ 22 个含 kb/knowledge 的脚本全是单计划守卫；唯一有 FTS 的 research-kb 入口已腐化：CLI 二进制与 research_kb.py 全域不存在，DB mtime 停在 2026-06-25）。
- **关键数字**：archive 152 目录；kb 113 份（55 实质+58 模板占位）；findings 148/152 份有内容；MEMORY.md 136 记忆文件（用户级、任务摘要粒度）；terry-vault 1199 笔记（电商域无关）；Rule 62 块=critical-rules.md:108-123。
- **证据**：subagent-state/01-explore-kb-infra.md（211 行全量报告，§1 设施清单/§2 三能力缺口/§3 证据附录）
- **Handoff**：agent_0c88f28c-2045-48dd-9e61-b99ce22547f0

### [sub:P1-S1~S4] KB 载体与检索工具建成（2026-10-22，worktree wt/task-kb-persist-20261022）
- **产出**：scripts/kb-search.sh(86l，rg 优先/grep 回落，--tag frontmatter 过滤，空库 exit 0)、kb-rebuild-index.sh(60l，frontmatter→INDEX 表，tmp+mv 原子写，跳过 _draft-)、kb-sync-from-plan.sh(79l+5l 修复，kb §2/§3/§4 提取→draft，占位 fallback findings 骨架)、knowledge/README.md(63l)+entry-template.md(40l)+INDEX.md(空表态)
- **执行期修缺陷**（主进程直做，白名单①单文件小改）：sync 脚本初版把 sources 写成 worktree 绝对路径→合并回后锚失效；已改 rel_to_repo() 规约为仓相对路径（scripts/kb-sync-from-plan.sh:63-71）。执行期第一版误用变量名 REPO_ROOT（实际 ROOT）→ unbound variable，已修正复测。
- **冒烟实弹**（worktree 内主进程跑）：kb-search 空库 exit 0；rebuild-index exit 0；sync plans/archive/task-v122 → _draft-task-v122.md 47 行（sources 仓相对）exit 0；kb-search 已验证 命中 draft 带摘要 exit 0
- **事实修正**：计划原引样例目录 plans/archive/task-v122-rule47-media-dispatch 不存在，实际为 plans/archive/task-v122——VC-3/G3/V-3.1 已随修正重 attest（SHA 6139edca）
- **证据**：subagent-state/P1-S{1,2,3,4}-*.md 四份检查点；worktree git status 仅 ?? knowledge/ ?? scripts/（零既有文件改动）

### [sub:P1-S1] gawk 陷阱（ERE 字符类）
- GNU awk 中 `[[:blank:]]+` 在 ERE 里只匹配单空白，2 空格缩进的 YAML 列表项不命中——改 `^ *- `。坑位注释保留在 scripts/kb-search.sh 内。
- **证据**：subagent-state/P1-S1-code-assistant.md（实测修复记录）

### [sub:P2 六域] 存量回填蒸馏结论（2026-10-22）
- **产出**：12 主题条目入库（dispatch×2/guard×2/worktree×2/planflow×2/discipline×2/misc×2），每条 56-80 行、四段结构、sources 8-12 条全存在性验证、结论全部带来源任务标注+行号级证据锚。INDEX 派生重建 12+1 行。
- **抽样质量判词**：dispatch-split-decision.md 含 13 条可复用结论（46.6 单元上限表数值、21.4 独立性四问、v194 打包翻车第一手判例、P1-P11 模式库要点），均为「解决类似问题直接查表」级知识。
- **执行期发现**：① 域分类关键词 `*ask*` 误匹配 `task-*` 前缀（首轮 E 域吸入 87 项）——子串匹配必须防任务名前缀污染；② C 域 3 个 ★ 标注 kb（v159/v165/v182）实为未填写模板——manifest 的行数≥75 判据可被模板骨架行数欺骗，占位检测应以「（待填充」计数为主判据；③ F 域裸编号任务（task-v122 等）靠目录名无法域归类，靠 executor 主题化兜住。
- **证据**：subagent-state/P2-S{1..6}-executor.md 六份检查点；knowledge/INDEX.md

### [sub:P4-S1] 全量 selftest 回归结论（2026-10-22）
- **92/92 PASS，FAIL=0，A 类（本任务引入）=0**；结构性佐证=worktree diff vs 基线 534255c 纯新增 20 文件（1310 插入/0 删除），92 个 selftest/SKILL.md/config.json 与基线逐字节相同——零回归属结构性结论而非碰巧。
- **重要负结果**：「零回归」≠「新代码被验证」——全部 selftest 对 knowledge//kb-*.sh/plan-templates 零命中，KB 新机制无直接测试覆盖（守护机器化 opt-in 未授权不建，登记遗留）。「套件有牙」已负验证：/tmp 副本删 config 键→rc=1。
- **证据**：subagent-state/P4-S1-code-runner.md

### [sub:P4-S2] 终验独立复验结论（2026-10-22，主仓 master 03ffb94）
- **VC-1~7 全 PASS + 对齐审查 4/4 + R1/R2 双 solved → outcome=COMPLETE**。三主题查询均为语义主命中（派发→dispatch-*、worktree→worktree-lifecycle-mergeback、部署位→同条目 staging/swap/revert 条款）。
- **对齐偏差 2 处（非阻断）**：README 称 --tag「仅命中带该 tag」实为子串匹配（kb-search.sh:48/:71）；114 条 sources 中 2 条指向 skills/ 而非 plans/archive/（存在性成立）。
- **新发现的 wart**：kb-sync 重跑会改写 draft 正文标题行内嵌的 worktree 绝对路径（frontmatter 已合规）→ 重跑使 tracked draft 变脏；一行级修复留独立小任务。
- **合并回机制发现**：smart-merge-back V1 门要求 worktree 目录名含完整 task-id——`git worktree move` 原生改名即可过门（无需重建）。
- **证据**：subagent-state/P4-S2-verifier.md（91 行全命令+输出）

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| provider 派发故障 3 次（Explore/drift-checker/verifier 首派 "Model request failed"） | 均按 22.3① 改派 general-purpose 成功；无阻塞 |
| attest 三连拒（VC 命令位置/时长格式/R3 映射） | 读门逻辑后逐一补齐（VC 命令入 verification.md、裸 NNmin、R3→VC-1 映射行） |
| kb-sync sources 绝对路径缺陷（合并回后锚失效） | 主进程 5 行级修复 rel_to_repo() 仓相对化，复测通过 |
| smart-merge-back V1 门拒（worktree 目录名缺 task-id 前缀） | `git worktree move` 原生改名后过门 |
| check-delegation verdict=violation（P4 Handoff 未登记 token） | 补 Handoff 行 15/16，复检 verdict=ok |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 知识库：/mnt/data/dev/task-planner-skill/knowledge/（INDEX.md 为派生勿手改）
- 检索：bash scripts/kb-search.sh <关键词> [--tag <tag>]
- 入库：bash scripts/kb-sync-from-plan.sh plans/archive/<task-id>
- 模板覆盖机制锚：init-session.sh:65-79（find_project_templates 按文件名优先 .zcode/plan-templates/）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
