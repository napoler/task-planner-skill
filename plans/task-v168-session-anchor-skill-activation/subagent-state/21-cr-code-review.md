# 21 · Code Review 记录 — task-v168 Phase 4（逻辑层+设置层）

- 审查对象: worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation`
- 分支: `wt/task-v168-session-anchor-skill-activation`（基线 39c41fa，两个新 commit: 8d5f4be 逻辑层 / 5f1c371 设置层）
- 审查人: 独立 code-reviewer 子代理（只读）
- veredict: **CHANGES-REQUESTED**
- 时间: 2026-10-11

## 0. 全量 diff 范围（`git diff --stat 39c41fa..HEAD`）
```
skills/task-planner/SKILL.md                     |  6 +++++-
skills/task-planner/config.json                  |  6 +++---
skills/task-planner/references/critical-rules.md |  4 ++--
skills/task-planner/templates/progress.md        | 10 ++++++----
4 files changed, 16 insertions(+), 10 deletions(-)
```
符合声明范围（仅 4 文件）。worktree `git status` 干净。

## 1. VC 逐条判定
| VC | 结论 | 证据 |
|----|------|------|
| VC-1 | PASS | SKILL.md:87 步骤 1.1 含 "Read task_plan.md「🎯 用户需求原文」区 → 在本 Phase progress 段首行写 `- **R 锚定**…`" 强制动作 |
| VC-2 | PASS | 1.1 / :92 动作相关性三问 / :93 2.5b 技能激活确认 / :99 3c 错误同轮四步 / :102 3f 周期三文件对照，grep 原文均在位 |
| VC-3 | PASS | critical-rules.md:322 31.1 增⑤、:345(33.1) 增④；原 ①②③(④) 语义未改（diff 仅追加 ⑤/④+括注） |
| VC-4 | PASS | config.json error_loop_enforce(:287)/reflect_verify_enforce(:302) default 均=enforce；键总数 314==314（jq 实测）未变 |
| VC-5 | **FAIL** | 回归日志 `Total: 76 PASS=74 FAIL=2`，Failed: selftest-error-loop / selftest-reflect-verify（worktree 内实测 rc=1 复现） |
| VC-6 | PASS | diff 仅 4 文件；零新 hook/零新脚本/零新 config 键；check-complete.sh Learning/REFLECT 段未改；zcode-pretooluse.sh 不在 diff |

## 2. Findings

🔴 **BLOCKER [门控/VC-5]** `skills/task-planner/config.json:287` + `:302` — enforce 翻档直接使两个静态守护回归 FAIL
- 原文: `"default": "enforce"`（error_loop_enforce 与 reflect_verify_enforce 两键）
- 复现:
  - `scripts/selftest-error-loop.sh:62-70` 断言 `k.get('default')=='warn'` → EL-12 FAIL
  - `scripts/selftest-reflect-verify.sh:46` 断言 `.properties.reflect_verify_enforce | .default=="warn"` → RV-08 FAIL
  - 后台回归 `/home/terry/.zcode/cli/exec/sess_f68c3bf8.../call_47fbb8370d5f422da44b7e98-stdout.log`: `Total: 76 PASS=74 FAIL=2`
- 原因: 两个 selftest 硬编码 `default=="warn"`；本任务把默认值改为 enforce 后断言不再成立。VC-5 要求 76 脚本 FAIL=0，现 FAIL=2 → G4（回归 + CR）门无法通过。
- 修复（三选一，须显式登记 Decisions Made，禁止静默放过）:
  (a) 同步更新 EL-12 / RV-08 断言为 `default=="enforce"` —— 属 `scripts/` 机器面改动，超出计划声明的 4 文件范围，需用户授权+登记；
  (b) 回退 Phase 3 翻档，两键保持 warn（放弃 VC-4 的"翻档"表述）；
  (c) 取得用户显式豁免，并在计划/验证记录中登记两个已知守护失败。
- 置信度: **HIGH**

🟡 **MAJOR [行为/正确性]** `skills/task-planner/references/critical-rules.md:322`（31.1⑤ 触发条件过宽）
- 原文: `⑤ 执行期机器可观察错误信号：工具 exit code 非零`
- 原因: `grep` 无匹配返回 1、`git diff` 存在差异返回 1、`test` 为假返回 1 等均属**正常**非零退出。31.1 规定"任一命中即 STOP 当前写入"，会把常规命令误判为错误、强制走 31.2-31.5 全链并停机 → 告警疲劳，规则反被忽略（正是 R4 要防的反效果）。
- 修复: 收窄为"命令自身成功语义未满足（预期成功的动作实际失败）"，或显式排除已知 benign 非零工具（grep/git diff/test/条件判断）。
- 置信度: MEDIUM

🟡 **MAJOR [门控影响/存量计划]** `scripts/task-planner.../scripts/check-complete.sh:1185`（Learning Gate `cell = a[c + 1]`）
- 原文（脚本内逐字 awk）: `cell = a[c + 1]`，其中 c=Root Cause 列号 6 → 实际读取 `a[7]`=**Prevention** 列
- 复现: 以脚本内逐字 awk 对"新模板"与"基线 6 列模板"（占位行 `|  |  | 1 |  |  | <待沉淀> |`）运行，均输出 `bad_lines=[占位行(第4行)]`，`rc=1`；结合逻辑 `if [ -n "$bad_lines" ]; then rc=1`，即便 `template_rows=1` 也判 FAIL。
- 对审查问题的回答: 新增「触发命令/工具」列位于表尾 index 8，**不移动** a[7]，故**列增补本身不引入新误报**（"缺触发列"不会误报）。但 config 翻 enforce 把既有 `c+1` 偏移的后果由 warn 告警**升级为 exit 1 硬阻断**——含未回填 Prevention/占位行的 progress.md 在终验会被 Learning Gate 硬挡。
- 原因: 非本次 diff 引入（基线同现，属机器面既有实现）；但设置层翻档使其从"不阻断"变为"阻断"，是本任务翻档的可观察后果，必须复核。
- 修复: 复核 `c+1` 是否为有意读 Prevention（若否改 `a[c]`）；在翻转 enforce 的同一批次验证"无错误计划 + 模板占位行"路径不会误阻断（或明确要求执行期删除占位行）。
- 置信度: MEDIUM

💬 **MINOR/NIT [可执行性]** `skills/task-planner/SKILL.md:92` — 动作相关性三问以「- 」项目符号插入，非编号步
- 原文: `  - **动作相关性三问（每动作前默念）**`
- 原因: 位于 2.5 与 2.5b 之间、与既有「拆分前已查…」「变更型决策点…」注记同级（2 空格 bullet），流式执行时易被当注记滑过，削弱"每动作前"强制力（R1 事前过滤诉求）。其余四锚点（1.1/2.5b/3c/3f）均在编号步序列内，可执行性无疑。
- 修复: 升格为编号步骤（如 2.5a）或并入 2.5b 前置，使其进入主流程序列。
- 置信度: MEDIUM

💬 **NIT [一致性]** `skills/task-planner/SKILL.md:99` — 原 3c 句与新「错误同轮四步」并存，语义自洽但冗余
- 原文: `错误同轮四步（Rule 31.1⑤ 执行期信号）`
- 原因: 原句"错误发生 → **立即**写 progress.md Error Log（19.4）"与新四步①「progress Error Log 记错误原文+触发命令/工具」重复表述；不自相矛盾，但同段两处指令增加歧义面。
- 修复: 合并——原"立即落盘"改为四步链第①步的指针。
- 置信度: HIGH

💬 **NIT [规则交互]** `skills/task-planner/references/critical-rules.md:322` vs `:177`（Rule 22.3）
- 原文: `子代理返回 failed|partial——出现即触发 31.2-31.5 全链`
- 原因: 子代理 failed 同时命中 31.1⑤（根因链）与 22.3（兜底链 改派/拆细/降档/接管）。31.1 要求"先走 31.2 再动手"，但未与 22.3 兜底动作显式排序，可能并行/遗漏其一。**非矛盾**（22.3 管恢复、31.1 管归因，互补），仅次序需明确。
- 修复: 在 31.1⑤ 或 22.3 加交叉引用句"22.3 兜底动作前先在 Error Log 落 31.2 根因"。
- 置信度: MEDIUM

## 3. 负结果报告（已排除项）
- 排除了"新增触发列破坏 Learning Gate 列定位"：实测 Root Cause 列号仍=6，尾列不移动既有列序。
- 排除了"翻档与 selftest 键总数钉冲突"：键总数 314（基线）==314（HEAD），无计数钉被触发。
- `scripts/` 全量 grep 两个键的消费者：仅 selftest-error-loop.sh / selftest-reflect-verify.sh / check-complete.sh，无其他级联。
- 锚点交叉引用真实存在：Rule 65.4 `[corrected]`(critical-rules.md:850-851)、Rule 8.1(:29)、knowledge-brief §6「可用强化技能清单」(templates/knowledge-brief.md:71)、task_plan 「🎯 用户需求原文」区(:8)。
- 安全面：本次为纯文档+配置改动，无新增运行时代码执行路径；未发现 SQL 注入/XSS/路径遍历/认证绕过类问题。
- VC-3 原文 4 条件/3 触发点经 diff 核对未被修改（仅追加 ⑤/④+括注）。

## 4. 结论
**CHANGES-REQUESTED**：1 BLOCKER（VC-5 回归 FAIL=2，由 config 翻档与既有 selftest 断言冲突导致）+ 2 MAJOR（31.1⑤ 触发过宽；翻 enforce 激活 Learning Gate 既有 `c+1` 偏移）。BLOCKER 未闭环前 G4/VC-5 不成立，禁止进入 Phase 6 终验。
