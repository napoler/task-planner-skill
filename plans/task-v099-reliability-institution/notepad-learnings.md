# Task Learnings: task-v099-reliability-institution

## New Requests
<!-- 用户注入指令登记 -->
- 2026-09-30（D 类新任务,/goal 自主会话延续, interaction_mode: silent）:
  ① 「主动为项目补充质量审查技能——执行任务时主动检测,涉及质量审查/发布等场景缺专业质量审查技能就补充（项目级）；原『每项目≥10 个』固定数想法过呆板,改按需检测制」
  ② 「通过制度性确保执行可靠性——不要相信模型口供（模型常说貌似正确其实是幻觉）,靠验证确保执行可靠度；用更小模型消耗解决问题（不可能全用巨大模型,成本受限）,通过 Agent 制度解决」
  ③ 「候选/建议目前比较弱智——以后遇到问题应主动选择最优解,可通过多种方式验证方案的可靠性」
  → 拆解落地为 Rule 42（质量审查技能主动检测与补充,5 子条）+ Rule 43（执行可靠性制度化,4 子条：43.1 证据先行/43.2 小模型档位经济/43.3 候选预验证/43.4 机制）

## What Worked
- **D2 已裁方案骨架 + 43.2 首示范自洽**：本计划 S-unit 表逐行标「建议档位」（mini/haiku-1/sonnet-1 最小可承载）——Rule 43.2 落地即 dogfooding,撰写期 executor 实测 435 行净增→级联值 wc 实测 439 禁手估
- **worktree 隔离 + smart-merge-back 三位部署**（v084/v098 范式）：合并 d066159 + 三部署位 IDENTICAL + push 6789780 备份,全程零主仓直改
- **CR 双 P2 非阻断项当场处置**（SR 头注释同步=白名单②;exec bit=家族惯例登记不处理）——41.3 trivial 直接做示范
- **全量回归 39 脚本 0 FAIL**（基线 616 + R 断言 12 = 628,主进程逐脚本求和定数,双形态 Total 正则）

## What Didn't Work
<!-- Rule 31.4 结构化：错误描述 + 类别标签 -->
- **委派率机器口径 0.2 vs 计划口径 0.4 偏差**（规则缺位+机器解析口径）：check-delegation stats 只认 Phase 标题行 `**Executor:** executor（sonnet-1）` 的纯 token;P3 字段写成「executor（S-unit 表见下，逐行建议档位…）」带括号注解 → 机器未识别为 delegated,计入 main_direct。根因=Executor 字段是机器事实源,执行体 token 后接注解即解析为直做。预防=executor 字段只写纯 token（`executor（sonnet-1）`）,S-unit 说明挪到表下独立注释行（Rule 43 43.1 证据先行同源——机器字段禁混注解）。
- **plan-writer 撰写期 provider 失败 2 次**（reasoning-level-missing,档位快照）:22.3④ executor 接管先登记后执行（25.3 白名单⑤）——v081/v083 同型,已知档位死活勿跨会话推断。

## 🚫 被否决方案（User Rejected — Rule 32）
- **每项目≥10 个质量审查技能固定数**（用户 09-30 主动撤销）：原话「可能这样的话会过于呆板」→ 否决,改 Rule 42 按需检测制。范围=task-planner 质量审查补充机制,禁再提「固定 10 个」配额。
- （历史禁令源=各任务 notepad 本段 + memory,plan 期 32.2 已查未命中其他）

## Files Modified
- 主仓 master（经 worktree d066159 + CR P2 注释 6789780,已 push）: critical-rules.md(+19 Rule 42/43)/SKILL.md(C30/C31+摘要行+括注,439 行)/templates/task_plan.md(+1 质量审查工具行)/templates/variant/mini-lite-type.md(+1 42.5 豁免行)/companion/agents/plan-writer.md(+1 义务行)/scripts/selftest-reliability-institution.sh(新建 R-01..12)/scripts/selftest-registry.tsv(+1=40 行)/scripts/selftest-skill-split.sh(级联 435→439)/scripts/selftest-self-resolution.sh(SR-11/12 锚值级联+注释同步)
- 部署位: ~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner 三位 IDENTICAL + agents/plan-writer.md 两部署位（opencode 位 plan-writer 现状保持）

## Verification Results
- Verified: 全量 39 脚本 628/0（主仓+worktree 双口径）；三部署位 diff -r IDENTICAL；CR APPROVED（0 P0/P1,2 P2 已处置）；委派率机面 0.2 WHITELIST-EXEMPT verdict=ok；^42.=5/^43.=4 主仓亲验
- Failed: 无阻塞；遗留见下

## 📚 必要知识储备备注
- 本次新发现的知识源: check-delegation.sh stats 的 Executor 字段纯 token 解析口径（P3 带注解被计 main_direct）——机器事实源字段禁混注解范式
- 值得入库的书目/文献: 无
- 待补齐的知识缺口: ① Rule 42 首个真实消费场景（文章/发布类任务实际触发质量审查技能缺口补建）尚未出现,待实战验证 ② 43.2 小模型档位经济在本仓 skill 编辑面的实测成本数据（本任务 executor 接管+判断型 sonnet-1 已用,成本对照待量化）

## Notes for Next Time
<!-- Rule 31.4/31.5 消费侧契约：触发条件 + 防线一句话 -->
- 触发=计划派发型 Phase 的 `**Executor:**` 字段撰写: 防线=只写纯执行体 token（`executor（sonnet-1）`）,S-unit/档位注解一律挪到 S-unit 表下独立注释行——禁在字段值内加括号注解（check-delegation stats 据此计委派率）
- 触发=全量 selftest 回归求和: 防线=主进程逐脚本 Total 行求和（双形态正则 `^(Total:|==== selftest).*PASS`）,禁采信子代理自报总数（v091 计数铁律）
- 触发=SKILL.md 行数级联: 防线=级联值一律 `wc -l` 实测禁手估（v098 先例,本任务 435→439 再次验证）
- 触发=CR P2 非阻断项: 防线=trivial 直接做+登记（41.3）,不阻塞 APPROVED 交付;家族惯例类（如 exec bit）登记不处理
