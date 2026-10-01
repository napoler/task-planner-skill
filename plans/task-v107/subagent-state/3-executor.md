# checkpoint: sub:3-executor (Phase 2 S1 主文档面审查)
status: done
- [01:35] Init 完成：Read SKILL.md(443行)/critical-rules.md(445行)/task_plan/findings/progress
- [01:40] 维度1 完成：Rule 1-44 主编号 44 个、无跳号无重复（python 核对 count=44 dup=[] missing=[]）
- [01:42] 维度2 完成：:246/:304 均覆盖 Rule 40-44，但括注写法「Rules 1-39（含 Rule 40/41/42/43/44）」自相矛盾；selftest WF-10 断言 "Rules 1-39" 命中≥6 为机器锚
- [01:44] 维度3 完成：C1-C33 表编号连续无跳号无重复
- [01:48] 维度4 完成：发现 4 处过期计数锚（SKILL:64 5文件 / Rule16:75 21锚 / Rule38.2:361 13variant / Rule34.5:317 13变体）
- [01:50] 维度5 完成：20 路径抽查，两文件引用路径 19/19 实存；install-companion.sh 缺失属 out-of-scope
- [01:52] 最终结论落盘

## 最终结论（8 字段块）
status: done
acceptance: 3/3 pass — [1:五维结论 2:问题清单格式合规 3:检查点落盘]
files: /mnt/data/dev/task-planner-skill/plans/task-v107/subagent-state/3-executor.md(+1) | /mnt/data/dev/task-planner-skill/plans/task-v107/findings.md(+1 小节,追加) | /mnt/data/dev/task-planner-skill/plans/task-v107/progress.md(+1 行,追加)
evidence: skills/task-planner/SKILL.md:64 vs scripts/init-session.sh:3/:210; critical-rules.md:75 vs grep -rl 实测 22; SKILL.md:246/:304 括注原文; python Rule 编号核对 count=44
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v107/subagent-state/3-executor.md (status: done)
findings_written: #### [sub:3-executor] S1 主文档面审查
blockers: none
confidence: HIGH

## 五维结论
1. Rules 编号连续性：无问题。`grep -oE '^### [0-9]+' critical-rules.md` 提取 44 主编号，python 核对 1-44 无缺无重（证据：count: 44 dup: [] missing_in_1_44: []）。
2. SKILL 文档索引面：覆盖完整（:246 正文括注 + :304 References 索引行均列明 Rule 40-44；正文摘要行 Rule 40/41/42/43/44 共 6 行齐备，grep -cE '^- \*\*Rule 4[0-4]' = 6），但存在写法瑕疵 P-4（P2）与 frontmatter :9 摘要面未同步 P-5（P2 待复核）。
3. C1-C33：无问题。合规表 C1..C33 行首编号唯一且连续（grep '^\| C[0-9]+' 提取 33 号）；全文 C 号引用（C4/C30/C31/C33 各出现 2 次）为 cross-reference，非表内重复。
4. 计数锚 vs 实测：实测基线 selftest=42、池=11、variant=16、脚本=75。两文件内 11 类池锚（critical-rules.md:420）✓ 与实测 11 一致、16 类（:75）✓ 与实测 16 一致；42/75 未出现在两文件（属 task_plan 锚）。发现 4 处过期锚：P-1（SKILL.md:64 "5 个文件" vs 实建 6 文件）、P-2（Rule 16:75 验收锚 "=21" vs 实测 22）、P-3（Rule 38.2:361 "现有 13 个 variant" 与 34.5:317 "既有 13 变体" vs 实测 variant/ 16 个，standard 档语义待复核）。
5. 引用路径实存：从两文件提取 19 条 references/templates/scripts 相对路径逐一 `[ -e ]` 验证全部实存（completion-gate/goal-gate/todo-sync/worktree-isolation/batch-quality-gate/methodology/dispatch-examples/subagent_dispatch/knowledge-brief/shared-tracker/cost-control/billing/template-mapping/template-guide/skill-collaboration/smart-merge-back/subagent-fallback/reference.md/examples.md，20 抽查位中 19 属两文件引用，第 20 位 install-companion.sh 属 task_plan 知识储备行 out-of-scope）。

## 问题清单
| ID | 严重度 | 锚点 file:line | 证据 | 修复建议 |
|----|--------|---------------|------|---------|
| P-1 | P1 | skills/task-planner/SKILL.md:64 | 原文「确认创建了 5 个文件（task_plan.md / findings.md / progress.md / notepad-learnings.md / verification.md）」vs scripts/init-session.sh:3 注释「[2026-09-13 task-v067] 第 6 文件 knowledge-brief.md 纳入建立/复核（5 文件→6 文件）」+ :210 循环建 5 文件 + SKILL.md:313「init-session 第 6 文件」 | :64 更新为 6 个文件（列表补 knowledge-brief.md）；执行步骤验证锚过期，主进程照做会误报缺文件 |
| P-2 | P1 | skills/task-planner/references/critical-rules.md:75（Rule 16） | 验收锚「`grep -rl "## 📚 必要知识储备" templates/ \| wc -l` = 21」，实测 grep -rl = 22（顶层 7 + variant 15） | 锚值 21→22 或改区间表述；机械执行该验收命令会误判 FAIL |
| P-3 | P2 | skills/task-planner/references/critical-rules.md:361（38.2）与 :317（34.5） | 「现有 13 个 variant」「对齐既有 13 变体」，实测 variant/ 目录 16 个（bugfix/code-edit/deployment/diagnostic/migration/mini-lite/performance-tuning/publish/refactor/research/rule-enhancement/schema-migration/test-writing/video/video-fix/writing）；standard 档是否含 video 类语义待复核 | 13→16 或显式注明 standard 档排除清单（mini-lite 属 mini 档）；静态计数锚随新 variant 沉淀漂移 |
| P-4 | P2 | skills/task-planner/SKILL.md:246 与 :304 | 原文「Rules 1-39（含 Rule 40/41/42/43/44）」/「Critical Rules 1-39（含 ... Rule 44 ...）」——主范围 1-39 与括注 40-44 逻辑矛盾（40-44 不在 1-39 内）；且 critical-rules.md:387（39.6）记载 WF-10 断言「Rules 1-39 命中总和≥6」，selftest-workflow-orchestration.sh:52-57 实测仍在跑该断言，:246/:304 的 "Rules 1-39" 是机器锚 | 收敛为 "Rules 1-44"（须同步 WF-10 自测断言与 4 索引文档，同源锚必同改）；若保留 1-39 机器锚则括注改为「（1-39 存量锚 + Rule 40-44 新增）」明示口径 |
| P-5 | P2 待复核 | skills/task-planner/SKILL.md:9（frontmatter references 摘要行） | 该行仅枚举至 Rule 36（「...Rule 36 技能修改保守化与功能删除防护」），37-44 未列入；正文 :246/:304 两处已覆盖 40-44；本行是否属"索引面"口径存疑 | 待复核：若 frontmatter 属索引面则补齐 37-44；非索引面则豁免 |
| P-6 | P2 待复核（out-of-scope） | task_plan.md 知识储备行（:61）引用 skills/task-planner/scripts/install-companion.sh | `[ -e ]` 实测 MISSING（skills/task-planner/scripts/ 下无该文件）；两审查目标文件均未引用此路径，超出 S1 范围 | 移交主进程核实 install-companion.sh 是否已改名/迁移（S1 不断言） |

## 负结果记录
维度1/3 无异常（44 主编号与 C1-C33 全连续）；维度5 两文件内 19 条引用路径全部实存，无缺失引用；P-4 中 "Rules 1-39" 非拼写错误而是 selftest 机器锚（selftest-workflow-orchestration.sh:52-57 证实），修复时须同步自测面。
