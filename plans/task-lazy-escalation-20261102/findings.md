# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户 2026-11-02 投诉（逐字）：「解决当前技能执行过程中的惰性：不是解决问题，而是将问题推给用户；或者不去主动寻找问题真正的解决方案，而是直接判别为不可用。必须修正。」拆解=两类反模式：①惰性上抛（把消解成本转嫁给用户）②无证据不可用判词（不枚举替代/不试 ≥3 策略/不附输出即宣告不可用）。方案=新增 Rule 97 惰性上抛禁令与不可用判词证据门（纪律域 satellite）+ selftest 静态守护（38.7 L0-T opt-in 守护机器化，经用户显式诉求授权）+ 全量索引/计数/纪元级联。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 既有规则 41/60/86/95/43/35/22.3/26 | skills/task-discipline/references/critical-rules-discipline.md 既有条目 | 是 | Technical Decisions（Rule 97 定位=41/60/86/95 后置纪律层） |
| Rule 20.6 预留制账本 | plans/.rule-reservations.jsonl + skills/task-planner/scripts/rule-reserve.sh | 是 | Technical Decisions（rule 97=next，reserved 登记） |
| LANE-L0 GATE 三段校验 | skills/task-planner/scripts/check-complete.sh:1897-1945 | 是 | Issues Encountered（全量终验 Total 行+单 commit 声明口径） |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- 级联面实测（grep 全仓 skills/ 非 plans/）：'1-96' 残留位=CLAUDE.md:33 / README_zh.md:136,229 / skills/task-planner/SKILL.md(L9/L210/L253) / skills/task-planner/README.md(L36/L81/L123) / docs/ARCHITECTURE.md(L4/L13/L42/L113/L115/L137/L139)；'79 条' 同上分布；'46 条' 仅 skills/task-discipline/SKILL.md(L15/L79/L90 原 46→现 47)。
- 文档级联修正发现：docs/ARCHITECTURE.md L115「3 新域 61 条」与「合计 79」口径需 +1 同步（实测 3 新域=dispatch 12+discipline 47+media 3=62；62+17 收编+1 验证域=80 全集），本任务已按 62/80 同批修正，防「61+17+1=79」残留自相矛盾。
- skills/task-planner/README.md:69 路由枚举止于 76（v171 快照陈旧）=既有欠账，非本任务范围，仅 grep 证（'69-74,76' 命中 2 处：L48 框图+L69 路由表行）。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| Rule 97 编号=next（rule-reserve.sh next=97，reserved 登记 task-lazy-escalation-20261102） | Rule 20.6 预留制：账本 check 97=reserved exit 3 非 free；land 步骤推迟至用户 commit 收口（铁约束禁 git commit/push） |
| Rule 97 落位=纪律域 satellite critical-rules-discipline.md 末追加，核心 14 条不动 | Rule 82 分层纪律：非核心域规则勿在核心展开；26/41/43/54/60/83/86/89/95 原文零改动（Rule 36.5 纯增量） |
| 守护面=selftest-anti-deferral.sh（AD-01..12 静态断言）+registry.tsv 自登记，零新 config 键（properties 维持 53 同 LA-14 口径） | Rule 38.7 L0-T 纯文本档 + 守护机器化 opt-in（用户显式诉求授权建 selftest）；判定面=LLM 行为（无法机器自证） |
| 97.6 升级优先级仲裁=固定裁定面（41.4 优先于 D3 / 83 是 60 的特例 / 资料先行档替代路径 / worktree 冲突 41.1 尝试配额 / 不自动乱解保留） | 用户投诉两类惰性形态的仲裁落点；worktree 冲突配额仅许并集解/手动解+复验（§5 反模式原文不变），smart-merge-back.sh exit 7 机械行为零改动（+1 注释行标 97.6 锚） |
| 级联面=SKILL.md 1-97×3/其余 80 条×2/94,95,97 + task-discipline 47 条/索引表 97 行 + critical-rules.md:194 +97 + ARCHITECTURE/README/CLAUDE/README_zh 计数与尾注链 | 索引计数/纪元锚/registry 逐一 grep 核对（VC-4）；ARCHITECTURE:125 历史 epoch-log + 各仓根历史尾注链原样保留 |
| 单 commit（38.7 簿记精简） | task_plan.md「## Decisions Made」区块声明；本任务=单 commit feat 交付 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 首次 Edit 被 PreToolUse check-scope.sh `.plan-required` 哨兵拦截（rc=1→exit 2） | 走仓内授权路径=init-session.sh 建 plans/task-lazy-escalation-20261102（7 文件）；D10 mtime 仲裁后 TASK_PLANNER_SID 放行（rc=0） |
| run-selftests.sh 全量=FAIL 1（selftest-rule-reserve-pairing PR-02：rule 97 reserved 未 land 非豁免悬空） | 预期瞬态：land 设计语义=合并后 land（账本追加+commit 收口成对），铁约束禁 commit → 推迟用户 commit 时执行 `rule-reserve.sh land 97 task-lazy-escalation-20261102`，届时 PR-02 归位 FAIL=0；非本次改动引入的回归（PR-01/PR-03 PASS，其余 92 脚本全 PASS） |
| LANE-L0 GATE ③「单 commit 惯性缺口」（feat\|fix 提交数=260≠1 且无声明） | task_plan.md 增「## Decisions Made」区块含「单 commit」机理由声明（check-complete.sh:1931-1937 判定口径=计划内任意位置含声明即合规） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- skills/task-planner/scripts/rule-reserve.sh（reserve/land/check/next）；账本=plans/.rule-reservations.jsonl
- skills/task-planner/scripts/run-selftests.sh（全量回归统一入口，末行 Total: N PASS=x FAIL=y（reused=z））
- skills/task-planner/scripts/check-complete.sh LANE-L0 GATE（:1897-1945）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
- （本任务暂无多模态发现——纯文本级联 L0-T 档，未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
