# sub:1-executor 检查点 — 模板全量普查（修复清单 v1）
启动: 2026-10-02 · 只读普查 · cwd=/mnt/data/dev/task-planner-skill

## 里程碑
- [M0] init: 检查点建立; templates/ 9 核心 + variant/ 16 = 25 .md（ls 实测）
- [M1] 维度1 完成:
  - task_plan.md:249 `worktree_path` 仍写旧约定 `../<repo>-wt-<task-id>`（sed 240-260 原文证实）; 而 references/worktree-isolation.md:32,37,43,50 已立新约定 `<repo-parent>/<repo>-worktrees/<task-id>` 并明文废止旧约定 → v107 结论「旧 worktree 约定」坐实（HIGH）
  - knowledge-brief.md:9 头部注释「grep 锚计数维持 20」; 实测 `grep -rl "## 📚 必要知识储备" templates/ | wc -l` = 22 → 20≠22 坐实（HIGH）
  - mapping §一 文件清单 14 项（L32-44 逐行数）、§六 速查表 13 行 variant（L133-145 grep 计 13）+ §九 矩阵「14 行:13 variant+general」→ 均 ≠16（video/video-fix 缺行）坐实（HIGH）
  - guide L63「templates/ 实际 26 个 .md」≠ 实测 25（9 核心+16 variant=25; 26 为 v093 历史误计或含目录误算 — 待复核 26 的口径来源）; L65「23/26」标题计数 ≠ 实测 22/25 → 坐实 22 漂移（L77 已写 22,与 L65「23/26」自相矛盾,同文件内双数）（HIGH）
  - 4 variant（diagnostic/publish/research/writing）缺 template_type 注释: grep -ln 证实 12 个 variant 含 template_type,4 个（diagnostic-type/publish-type/research-type/writing-type）零命中; 16 个全部含 plan_tier → v107 结论坐实（HIGH）
  - T-1 坐实: writing:11-12(article_json_editor.py/verify_content_originality.py)、:63 assemble_article.py; research:14(keyword_coverage.py); publish:12,15,34,90(verify_content_originality.py/rollback.sh) 所引 4+ 脚本全仓 find 0 命中 → 目标项目侧示例值,建议加「示例值(目标项目相对)」注脚（HIGH）
- [M2] 维度2 完成: 主模板 task_plan.md 三区块全在（委派统计 L361/Handoff L373/Drift Log L334）; 16 variant 中:
  - 委派统计: 全 16 variant 零命中（委派统计为 verification.md 侧「委派统计复验」段承载 Rule 25.4 落点,task_plan 侧仅主模板有节）
  - Handoff: 仅 mini-lite L44「Subagent Handoff 登记表」（Rule 22.5）,其余 15 零命中
  - Drift Log: 7 variant 有（diagnostic:82/publish:108/writing:75/research:82/video:81/video-fix:130 + 主模板）,9 标准 variant 无（bugfix/code-edit/deployment/migration/performance-tuning/refactor/rule-enhancement/schema-migration/test-writing）
  - mini-lite 按 Rule 38.3 白名单（①Goal②VC③单 Phase④执行范围限制⑤Handoff 登记表）豁免: 缺委派统计/Drift Log 属合法缺失（白名单外区块本就不允许）; 缺 Handoff 不可能（白名单⑤要求,且 mini-lite L44 实有）
- [M3] 维度3 完成: 12/16 variant 含 template_type 注释; 4 缺(diagnostic/publish/research/writing, grep -ln 零命中); 16/16 均含 plan_tier; 主模板 task_plan.md:8 仅 plan_tier:standard(L22 提 template_type 但无 `template_type:` 注释行)。critical-rules 过期计数: 37.1(:348)「14 行:13 variant+general」/ 38.2(:361)「现有 13 个 variant」/ SKILL.md:274「standard 13 variant」均 ≠16。
- [M4] 维度4 完成: 「自动超时默认项/质量审查工具/对齐审查」3 行仅主模板 task_plan.md:31-33 在位(+mini-lite L7-10 豁免声明行);15 标准 variant 配置表仅 code_review 单行零 3 行;「🧰 工具选择与编排」区块仅主模板 L136 在位(Rule 40.2 明言「general 模板承载」+mini 豁免→variant 层 15 个均缺,机器面 selftest 只锚 general 模板)。
- [M5] 维度5 完成: task_plan.md/verification.md/templates 全库「验证由独立子代理」类表述 grep 0 命中(零命中证据: grep -rn "验证由独立子代理\|独立子代理执行验证" templates/ → 0);现有最近锚=Rule 33.3「独立验证(不信自报)」。候选落点: ①verification.md L108 Goal Gate 段后加「验证独立性」行 ②task_plan.md L35 VC 段头部加原则行 ③task_plan.md L214 Phase 4 Testing&Verification 节 ④verification.md L74 委派统计复验段注「独立验证子代理执行」。推荐 ①+②。
- [M6] 维度6 完成: 四点同步面(mapping §一 13 variant 缺 mini-lite/video; §六 13 行缺 mini-lite/video/video-fix; §九 矩阵 14 行缺同 3; plan-writer.md L53-66 14 行缺 mini-lite/video; SKILL.md:274「13 variant」; critical-rules:348「14 行:13 variant+general」; critical-rules:361「13 个 variant」; guide §2.2 已 16 行同步 ✓; selftest-template-lifecycle.sh TL-17 只锚 guide「16 个」PASS(实测 18/18),对 SKILL/critical-rules 的「13」串无机器断言→修正 13→16 无 selftest 断裂风险)。
- [M7] 追加发现: critical-rules.md:49 Rule 12 旧 worktree 约定 `../<repo>-wt-<task-id>` 与主模板 :249 同源旧文(worktree-isolation.md:37 明文废止);check-complete.sh:999/1014 机器锚「委派统计段/Subagent Handoff 登记表」只对主模板+verification.md 生效,variant 生成计划无 Handoff 节时 :1014 awk 找节失败→合规检查 silently 跳过(风险=机器门控对 variant 计划失效,需裁决)。

## 最终结论
status: done
acceptance: 3/3 pass — [1:六维结论 2:清单 v1 格式合规 3:检查点落盘]
files: /mnt/data/dev/task-planner-skill/plans/task-v108/subagent-state/1-executor.md (+新), /mnt/data/dev/task-planner-skill/plans/task-v108/findings.md (追加小节), /mnt/data/dev/task-planner-skill/plans/task-v108/progress.md (追加 1 行)
evidence: task_plan.md:249「../<repo>-wt-<task-id>」 vs worktree-isolation.md:32/37/50 新约定; grep -rl "## 📚 必要知识储备" templates/|wc -l→22 vs knowledge-brief.md:9「维持 20」; mapping L32-44=13 variant vs ls variant/|wc -l→16; guide:63「26 个」vs ls→25、:65「23/26」vs 实测 22/25; grep -ln template_type variant/→12 命中/4 缺(diagnostic/publish/research/writing); writing:11 article_json_editor.py 全仓 find 0 命中; grep -c 委派统计 variant/*.md 全 0、Handoff 仅 mini-lite:44、Drift Log 9/16 缺; grep -rn "独立子代理执行验证" templates/ →0; selftest-template-lifecycle.sh 实跑 18 PASS/0 FAIL
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v108/subagent-state/1-executor.md (status: done)
findings_written: #### [sub:1-executor] 模板普查
blockers: none
confidence: HIGH

## 修复清单 v1（ID/锚点/修法一句话/性质/联动面）
| ID | 锚点(file:line) | 修法（一句话） | 性质 | 影响联动面 |
|----|----------------|---------------|------|-----------|
| M-01 | skills/task-planner/templates/task_plan.md:249 | `worktree_path` 示例值 `../<repo>-wt-<task-id>` → `<repo-parent>/<repo>-worktrees/<task-id>`（对齐 worktree-isolation.md:32/50 新约定） | 修正 | critical-rules.md:49 Rule 12 同文（并入 M-02）；selftest 无该串机器锚（grep -rn "repo]-wt-" 全仓 0 命中脚本）；8 variant 已新约定（bugfix:110 等），主模板+Rule12 为仅剩 2 处 |
| M-02 | skills/task-planner/references/critical-rules.md:49 | Rule 12 旧目录约定 `../<repo>-wt-<task-id>` → `<repo-parent>/<repo>-worktrees/<task-id>` | 修正 | 与 M-01 同源同改；worktree-isolation.md:37 已载明废止理由（不动） |
| M-03 | skills/task-planner/templates/knowledge-brief.md:9 | 头注释「grep 锚计数维持 20」→ 22（实测 grep -rl 知识储备锚 = 22；guide:77 已 22，此注释未回写） | 修正 | 无脚本断言该「20」串（grep "维持 20\|= 20" scripts/ 0 命中）；联动 guide:77 一致口径 |
| M-04 | skills/plan-template-kit/references/template-mapping.md:32-44 | §一 文件清单 13 variant → 补 mini-lite-type/video-type 至 16 | 修正 | §六速查表(L133-145,13 行,缺 mini-lite/video/video-fix)、§九矩阵(L209-226,14 行同缺 3)同补；critical-rules:348「14 行:13 variant+general」→「17 行:16 variant+general」(并入 M-09)；selftest-template-lifecycle TL-18 只断言 §九节存在不断言行数→安全 |
| M-05 | skills/plan-template-kit/references/template-guide.md:63,65 | L63「templates/ 实际 26 个 .md」→ 25（9 核心+16 variant，ls 实测）；L65 标题「23/26」→「22/25」（与 L77 的 22 及 grep 实测 22 对齐，消同文件双数矛盾） | 修正 | selftest-template-lifecycle TL-17 只锚 guide「16 个」+rule-enhancement，不锚 25/22 串→安全；knowledge-brief:9 口径同源（M-03） |
| M-06 | skills/task-planner/templates/variant/{diagnostic,publish,research,writing}-type.md（头部注释区，如 diagnostic:2-4） | 补 `<!-- template_type: <X> -->` 注释声明（对齐其余 12 variant 现有范式，如 bugfix-type.md:12 `<!-- template_type: bugfix -->`） | 增量 | task-v108 VC-2 直接验收项（16/16 含 template_type）；可选加 selftest-template-lifecycle 新断言「16 variant 全含 template_type 注释」(增量机器面,待裁决)；check-template-type.sh 白名单动态派生不受影响 |
| M-07 | 9 个无 Drift Log 的 variant：{bugfix,code-edit,deployment,migration,performance-tuning,refactor,rule-enhancement,schema-migration,test-writing}-type.md（追加于节末） | 补「## 🚨 Drift Log」表（对齐主模板 task_plan.md:334 四列范式；7 个 variant 已在位=diagnostic:82/publish:108/writing:75/research:82/video:81/video-fix:130，另 mini-lite 合法豁免）；v107 T-2 裁决落地=模板补全（plan-writer 不代补） | 增量 | check-drift.sh 消费「执行范围限制」节(已有)，Drift Log 为其记录落点；selftest-template-lifecycle 无 Drift Log 断言→可选新增(待裁决)；mini-lite 按 Rule 38.3 白名单豁免=合法缺失，不动 |
| M-08 | 同上 15 variant（缺 Handoff 节全部：除 mini-lite 外 15 个） | 补「## 🔗 Subagent Handoff 登记表（Rule 22.5）」节（对齐主模板 task_plan.md:373 六列范式；mini-lite:44 已有） | 增量 | **高风险联动**：check-complete.sh:1014-1017 以「Subagent Handoff 登记表」字样为节锚做 Handoff 抽查——variant 生成计划缺该节时 awk 静默跳过=机器门控对 variant 计划失效，补节后机器面生效；selftest-plan-tier.sh 38.3 断言 mini 白名单（mini-lite 不受影响）；Rule 22.5 措辞「必填」口径归位 |
| M-09 | ① skills/plan-template-kit/references/template-mapping.md §六 L133-145 + §九 L209-226 ② skills/task-planner/companion/agents/plan-writer.md:53-66 ③ skills/task-planner/SKILL.md:274 ④ skills/task-planner/references/critical-rules.md:348(:361 同) | 34.2 四点同步补齐：mapping §六/§九 与 plan-writer 映射表补 mini-lite/video/video-fix 行至 16；SKILL.md:274「standard 13 variant」→16；critical-rules:348「14 行:13 variant+general」→17 行:16 variant+general、:361「现有 13 个 variant」→16 | 修正 | 四点同步全链；selftest-template-lifecycle TL-17 锚 guide「16 个」(已 PASS,不动 guide §2.2 16 行)；对 SKILL/critical-rules「13」串无机器断言(grep 证实)→改 16 零自测断裂 |
| M-10 | skills/task-planner/templates/variant/writing-type.md:11-12,63；research-type.md:14；publish-type.md:12,15,34,90 | VC 表引用脚本（article_json_editor.py/verify_content_originality.py/keyword_coverage.py/rollback.sh，全仓 find 0 命中）加「示例值（目标项目相对路径）」注脚——v107 T-1 建议方案，不删行 | 修正 | 无机器锚（脚本路径非 grep 断言对象）；对齐 v107 裁决口径 |
| M-11 | skills/task-planner/templates/verification.md（全模板面，主模板+16 variant 共用） | 「委派统计复验」段（verification.md:74）已为主验证模板在位；裁决项：15 标准 variant 的 task_plan 侧是否镜像主模板 task_plan.md:361「## 📊 委派统计」节——待主进程裁决（Rule 25.4 落点=verification.md，task_plan 侧节为登记习惯） | 待裁决 | check-complete.sh:999 只校验 verification.md 委派统计段（variant 计划共用 verification.md→已覆盖）；若裁决 task_plan 侧补节则联动 15 variant + 38.3 mini 白名单（不加） |
| M-12 | skills/task-planner/templates/variant/*.md 配置表区（如 bugfix-type.md:12-14 仅 code_review 1 行） | 15 标准 variant「🔍 Code Review 配置」表补「对齐审查/自动超时默认项/质量审查工具」3 行（对齐主模板 task_plan.md:31-33 行范式；mini-lite 已有 42.5/42.6/44 豁免声明 L8-10 不动）；同补「🧰 工具选择与编排」区块（Rule 40.2「general 模板承载」口径需裁决：variant 补区块 或 40.2 改「standard 各模板承载」表述） | 增量 | Rule 42.4/42.6/44.1 消费面归位；selftest-ask-default-timeout RT-05 只锚主模板 task_plan.md「自动超时默认项」行(不锚 variant→补 variant 不断裂)；selftest-reliability-institution 同范式；selftest-tool-selection 静态守护面(待复核其断言是否覆盖 variant)；40.2 表述改=增量文档面 |
| M-13 | ① skills/task-planner/templates/verification.md:108（Goal Gate 段） ② skills/task-planner/templates/task_plan.md:35（VC 段头部） | 「验证由独立子代理执行」原则制度化：候选落点 A=verification.md Goal Gate 后加「验证独立性」行（终验由独立子代理/V-代理执行,主进程仅编排+簿记,对齐 Rule 33.3「独立验证(不信自报)」）；候选落点 B=task_plan.md VC 段头部加原则行（终验/Goal Gate 动作=独立子代理,干净上下文）；理由:A 载终验判定面(与 task-v108 VC-1~VC-4 用户铁律同构)、B 载计划期声明面(Executor 字段可据此填 V-类执行体)。C=task_plan.md:214 Phase 4 节、D=verification.md:74 复验段注 为备选 | 增量 | 制度层=critical-rules 可新增锚或挂 33.3 延伸(待裁决是否升 Rule)；selftest 机器面可选新增(待裁决)；task-v108 task_plan「验证独立性铁律」段为现成先例文本 |

### 负结果报告（未发现问题/排除风险面）
- guide §2.2 variant 表 16 行完整（video/video-fix 在位）→ 四落点中 guide 无缺口，不需改
- selftest-template-lifecycle.sh 实跑 18/18 PASS；TL-17「16 个」锚健康
- check-template-type/init-session 白名单动态派生（ls variant/）→ 补行不涉脚本改动
- verification.md 主模板委派统计/质量门控/Goal Gate 节完整在位（:74/:84/:108）
- 无脚本以「13」串为机器锚（SKILL:274/critical-rules:348,361 的 13 仅文档面）
- mini-lite 三缺失（委派统计/Handoff/Drift 中无委派统计与 Drift）= Rule 38.3 白名单合法豁免，非缺陷
