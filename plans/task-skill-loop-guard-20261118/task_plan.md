<!-- plan_tier: L1 -->
# task-skill-loop-guard-20261118: 长序列执行失控防护（sess_ba603cf5 判例）

## Goal
根治 sess_ba603cf5 会话暴露的 6 项技能规则缺口（全局子代理预算、goal 范围锚定、同文档返工上限、公共上下文传递、worktree 规则版本校验、创作型 .md 提交豁免），文本条款级最小修复 + 部署位对齐，防复发。

## 🎯 用户原始诉求（逐字锚）
「分析这个会话为什么会一直消耗大量的时间在检索本地文档上…每一集的剧本也就只有一个文档，为什么会一直来回的改，还每次都改错…去分析为什么会出现这种缺陷，然后从技能底层改观。我希望可以优化当前的技能中的问题…一个任务给我解决到上到八九个小时还解决不了。」

## 判例与证据（已取证，forensics/）
- 会话跨 2026-11-17T06:50Z→11-18T03:41Z（约 9h）；54 子代理；1797/2036 工具调用来自 subagent。
- `forensics/sess-ba603cf5-transcript-findings.md`、`...-project-findings.md`、`...-skill-gap-analysis.md`（六缺口逐条 file:line 锚 + 复核通过）。

## Scope（4 文件 6 处纯文本条款，零脚本零新 config 键）
- `skills/task-dispatch/references/critical-rules-dispatch.md`：新增 96.7（全局预算闸门）、103.8b（同文档返工上限）
- `skills/task-discipline/references/critical-rules-discipline.md`：28.8 追加范围锚定例外、94.7 豁免收紧、27.1 创作型 .md 不豁免
- `skills/task-planner/references/critical-rules.md`：新增 62.4b（公共上下文一次读取+引用传递）
- `skills/task-planner/references/worktree-isolation.md`：§4 新增 ①-校验（规则版本一致性硬门）
- 部署位 `~/.zcode/skills`、`~/.agents/skills` 对应 8 文件逐位同步（防运行时漂移复发）
- 机器契约同步（新增条款撞旧守护，授权范围内级联）：`skills/task-planner/scripts/selftest-subagent-activation.sh`（SA-15 六子条上限→允许 96.7、禁 96.8+）；同批 dispatch 文件 103.8b 采用加粗行首对齐 103.3a 先例，避免 DQ-01 八子条计数误伤（不改 selftest-dual-qc.sh）

## VC
- [x] VC1: 6 处条款逐字在位（grep 锚点 + Read 复核）— PASS（主仓+部署位 7 锚各 1）
- [x] VC2: 现有 selftest/回归无新增 FAIL（条款编号/计数未破坏机器门）— PASS（6 脚本全绿，DQ-01/SA-15 契约已同步）
- [x] VC3: 源仓 master 与 2 部署位对应文件 diff=0 — PASS（5 源 × 2 位 = 10 文件逐对 SAME）

## merge_back
merged(be068da)

## B 类扩展状态（2026-11-18 用户新指令：全平台部署 + GitHub 推送）
- 部署：5 源 × 5 活跃平台位（zcode/agents/claude/cursor/opencode）= 25 文件 cmp 差异 0（一手 md5 复核）。详见 progress.md。
- 推送：源仓(be068da)/zcode(23f5934)/claude(e7a849e) 三仓 push 成功 ahead=0；cursor/agents 非 git 无 push 义务；**opencode 分叉受阻**（本地 f24c8f0 已 commit，ahead3/behind3，4 个交集为他会话活跃工作，禁强推/rebase，标 BLOCKED 待他会话收口）。
- 净结论：部署全部完成；推送 3/4 git 仓完成，opencode 1 仓因他态分叉未推（如实登记，非本任务可自动化解决）。

## 隔离决策
- 4 目标文件在主仓预存其他在途任务未提交改动（goal 自治/worktree 免询问）→ 按 worktree §4①-备份 stash（排除 plans/tmp/forensics），worktree **从 master 创建**（main 为陈旧无关历史，禁作基线）；合并回后 stash pop 恢复，锚点相邻处做并集解。
