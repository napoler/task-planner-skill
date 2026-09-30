# Knowledge Brief — task-v099-reliability-institution（任务知识简略要点）

<!--
  本文件由 init-session.sh 模板复制；S0（executor 接管 plan-writer 面）全量撰写，五段非空。
  定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期产出，执行期回填。
-->

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 S0（executor 接管 plan-writer 面）产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：在 task-planner 技能内纯增量落地 Rule 42（五子条）+ Rule 43（四子条）+ selftest 静态守护（R-01..R-12）+ SKILL 三锚联动 + 模板/契约消费面，worktree 隔离交付 + 三位部署 + push；达成标准 = VC 6 条全过（task_plan.md「Verification Contract」）。
- 背景/动机：用户三条原话（2026-09-30）点名质量审查缺制度、完成声称靠模型自觉（幻觉面）、候选呈报未预验证（01-task-brief.md :5-8 全文引录）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| Rule 42 质量审查技能主动检测与补充 | 任务涉质量审查面时按「项目级→用户级→环境 agents」三级检测，缺口=项目级补建专用技能并作为 S-unit 登记，计划配置表「质量审查工具」行消费登记（42.1-42.5） |
| Rule 43 执行可靠性制度化 | 证据先行反幻觉（43.1）+ S-unit 逐行建议档位取最小可承载档（43.2）+ 候选预验证 ≥2 方案选最优（43.3）+ C30/C31 检查点消费零新键（43.4） |
| 三锚 | SKILL.md 的 C30/C31 合规清单行 + Rule 42/43 摘要行 + :242「含 Rule 42/43」括注（v098 先例：C29+摘要行+括注三锚范式） |
| S-unit 建议档位 | S-unit 表新增列，取值 mini/haiku-1/sonnet-1/opus 中可承载该步的最小档（43.2 首个示范：本计划 S1=sonnet-1/S2=haiku-1/S3=haiku-1/S4=sonnet-1） |
| Total 行双形态 | selftest 脚本结尾行两种形态：`Total: N PASS=x FAIL=y`（37 脚本）与 `==== selftest xxx 结果: PASS=x FAIL=x ====`（selftest-final-gate-hash.sh 独有）——求和正则必须双覆盖 |
| 级联 | 追加 SKILL 行后 selftest-skill-split.sh:41 的 `-le 435` 上限须随 wc 实测值更新（label 注明 task-v099），既有 ≤558 上限维持 |

## §2 已验证关键事实

| 事实 | 证据（命令 + 输出，2026-09-30 实测） | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| worktree 基线 SHA = master@55c24fc | `git -C /mnt/data/dev/task-planner-skill rev-parse master` → `55c24fcf7bb88a3af044437d13e2ee3a20557ddd` | P1 建 worktree 分支 wt/task-v099-reliability-institution @55c24fc；Batch Report rollback_point 即此值 |
| SKILL.md = 435 行 | `wc -l skills/task-planner/SKILL.md` → 435 | P2-S2 级联输入下限；级联值以 P2-S2 完成后 worktree 内 wc 实测为准（FMEA RPN=144 行兜底） |
| critical-rules.md = 413 行，EOF 即 Rule 41.6 末行 | `wc -l skills/task-planner/references/critical-rules.md` → 413 | P2-S1 追加起点=L413 后；`grep -c '^42\.'` 现为 0、`'^43\.'` 现为 0（追加前负基线确认） |
| 全量 selftest = 38 脚本，总 PASS = 616 / 0 FAIL | 逐脚本实跑 + `grep -oE 'PASS=[0-9]+'` 求和（awk 汇总 scripts=38 totalPASS=616） | VC-5 基线：P3 全量回归 0 FAIL 且总 PASS ≥616 + R 断言增量（主进程定数） |
| selftest 结尾行双形态实证 | selftest-final-gate-hash.sh 输出 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`（无 `Total:` 行）；其余 37 脚本均 `Total:` 行；registry.tsv 39 行（表头+38 脚本） | 求和正则须覆盖 `Total:` 与 `==== selftest` 双形态（v098 教训：单正则漏 final-gate-hash 22 断言）；registry 现 39 行 → P3 +1 = 40 行 |
| `grep -c 'Rules 1-39' SKILL.md` = 2（:242/:297） | 实测输出 2（v098 簿记后未漂移） | 不 STOP；P2-S2 括注扩写后须保 =2（VC-2 硬断言）；越界数字子串负断言同法 grep（v097 对策 b 锁，越界子串指 Rules 序列号跳出 1-39 字面的 4 开头子串） |
| 三锚位行号 | `grep -n` 实证：C29=:194；Rule 41 摘要行=:273；「Rules 1-39（含 Rule 40/41）」括注=:242；References 行=:297；级联断言行 selftest-skill-split.sh=:41（`-le 435`，label「task-v098 Rule 41 联动 433→435」） | P2-S2 插入点=：C30/C31 在 :194 后、摘要行在 :273 后、括注改 :242、级联改 :41 |
| 模板配置表 5 行（code_review/session_id/worktree_path/scope_files/interaction_mode）= :25-30；「质量审查工具」行现不存在 | `grep -n 'code_review\|scope_files'` 实证 + `grep -c '质量审查工具'` = 0 | P3-S3 在 :26 后插 1 行；完成后双模板 grep 各 ≥1 |
| mini-lite-type.md 豁免行范式 = :7（「Rule 40.2 豁免声明（task-v097）…mini 免计划期工具分析仪式」） | Read 实证 | P3-S3 豁免行对齐 :7 形态写「质量审查工具」行 mini 豁免（Rule 38.3 区块白名单） |
| plan-writer.md 撰写义务区 = :40-45（任务分解/VC 设计/S-限定/隔离/knowledge-brief/工具选择六行） | Read 实证；「建议档位」字面现不存在 | P3-S3 在义务区 +1 行（建议档位必填+质量审查工具检测登记+候选对比表义务） |
| 主仓工作树有并行残留 | `git status --short` → ` M plans/task-v098-auto-resolution/.plan-attestation` + `?? plans/task-v099-reliability-institution/` | 均为计划系统文件（25.3 白名单②面），与 8 文件 scope 零重叠 → 隔离决策 conflict_scan=safe；P4 合并前复扫 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/critical-rules.md | :383-413 | Rule 40 节头+:383 段、Rule 41 节头+:393、41.1-41.6 子条全文（节头+行首 N.N+机制收尾格式范式）；L413=EOF，P2-S1 追加起点 |
| skills/task-planner/SKILL.md | :193-194 | C28/C29 合规清单行（句式=「本任务…（Rule N.x；机器面=selftest-xxx 静态断言）」）；C30/C31 插 :194 后 |
| skills/task-planner/SKILL.md | :272-273 | Rule 40/Rule 41 摘要行（「子条一句话分解+零新键+守护脚本名」句式）；Rule 42/43 摘要行插 :273 后 |
| skills/task-planner/SKILL.md | :242 | `详见 references/critical-rules.md（Rules 1-39（含 Rule 40/41））`——括注扩写位（字面本体不动） |
| skills/task-planner/SKILL.md | :297 | References 表 critical-rules.md 行（含 13-18/21-23/25-28 + 33-41 逐条列举）；括注面 2（「Rules 1-39」第 2 处） |
| skills/task-planner/scripts/selftest-skill-split.sh | :41 | `t "T-主 行数 ≤435（task-v098 Rule 41 联动 433→435）且 ≤558 上限"`——级联断言行，值改 wc 实测 N |
| skills/task-planner/templates/task_plan.md | :24-30 | 配置表 5 行（code_review/session_id/worktree_path/scope_files/interaction_mode）；「质量审查工具」行插 :26 后 |
| skills/task-planner/templates/variant/mini-lite-type.md | :7 | `<!-- Rule 40.2 豁免声明（task-v097）: mini 档不加「🧰 工具选择与编排」区块… -->` 形态范式；+1 豁免行对齐此 |
| skills/task-planner/companion/agents/plan-writer.md | :40-45 | 撰写义务 6 行（任务分解/VC/Scope/隔离/knowledge-brief/工具选择）；义务行插此区 |
| skills/task-planner/scripts/selftest-self-resolution.sh | :1-99 | SR 范式全文（变量头/ok()/bad()/12 编号断言/exit 语义，99 行）——P3-S4 新脚本对齐此范式 |
| skills/task-planner/scripts/selftest-registry.tsv | :1-39 | 四列表头（script/domain/trigger_scenarios/dep_anchors）+38 脚本行；末行=selftest-self-resolution.sh；+1 行=40 行 |
| subagent-state/01-task-brief.md | :10-22 | Rule 42/43 六（九）子条方案骨架全文（主进程 D2 已裁，P2-S1 内容源） |

## §4 易错点与禁止假设清单
1. **级联字面锚**：selftest-skill-split.sh:41 的 `-le 435` 必须改为 P2-S2 完成后 worktree 内 `wc -l SKILL.md` 实测值（label 改注 task-v099）；既有 ≤558 上限与 4 条宽容正则锚不动；禁手估级联值（FMEA RPN=144 行兜底）
2. **越界数字子串禁引入（v097 对策 b 锁）**：SKILL/模板/条款新增文本禁产生越界数字子串（Rules 序列号跳出字面 1-39 的 4 开头子串）；「Rules 1-39」字面 2 处（:242/:297）本体不可动，只可括注扩写（`grep -c 'Rules 1-39'`=2 硬断言 + 越界子串 grep=0 负断言，P2-S2/S4 验收前置）
3. **registry 双向一致**：新建 selftest-reliability-institution.sh 必须同步 selftest-registry.tsv +1 行（四列齐，tsv=40 行），否则 selftest-registry.sh T02/T03 双向断言 FAIL（改名/删除残留旧行亦 FAIL）
4. **Total 行双形态（v098 教训）**：全量回归求和正则须同时覆盖 `Total:` 行（37 脚本）与 `==== selftest` 行（selftest-final-gate-hash.sh，22 断言）；单正则漏数=基线误判；定数由主进程求和，禁采信子代理自报
5. **push 前只读预检 origin 领先量**：`git rev-list --count master..origin/master` 须 = 0；非 0 → STOP 报告用户（G3 对外不可撤回面，Rule 41.2 四门槛，禁自行 force 推）
6. 禁止假设：Rule 42/43 原文零改动、模板契约机读标记零改动、config.json 零新键（properties=40 维持）；模板/契约改动仅新会话生效（Decisions silent: 行登记）
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 2 SKILL 行数级联断裂（RPN=144）」行与「Phase 2 Rules 1-39 字面保全失败（RPN=120）」行

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P2-S1 | §1 + §2（42/43 计数=0 负基线+413 行 EOF 锚）+ §3（critical-rules.md :383-413 范式行） | /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/subagent-state/01-task-brief.md :10-22（子条骨架全文）；仓内 references/critical-rules.md :383-413 |
| P2-S2 | §3（SKILL.md :194/:242/:273/:297/:41 行号表）+ §4（级联字面锚/越界子串禁引入两条） | 仓内 skills/task-planner/SKILL.md（三锚区段）+ skills/task-planner/scripts/selftest-skill-split.sh :41；P1 基线值 435 作级联输入下限 |
| P3-S3 | §3（模板 :25-30/mini-lite :7/plan-writer :40-45 行号表）+ §4（模板契约标记零改动约束） | 仓内 templates/task_plan.md :24-30 + templates/variant/mini-lite-type.md :7 + companion/agents/plan-writer.md :40-45 |
| P3-S4 | §2（registry 39→40 行+Total 双形态实证）+ §4（registry 双向一致/双形态两条）+ §5 | 仓内 scripts/selftest-self-resolution.sh :1-99（SR 范式全文）+ scripts/selftest-registry.tsv :1-39（四列表头+末行格式） |
