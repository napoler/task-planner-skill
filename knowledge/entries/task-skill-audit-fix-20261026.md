---
id: task-skill-audit-fix-20261026
title: "skill 深度审查缺陷修复：跨技能引用深度规则/索引级联漏号/僵尸计划收口范式"
tags: [skill-audit, 跨技能引用, 委派门, 僵尸计划, 收口]
sources: [plans/skill-audit-20261026/report.md, plans/task-skill-audit-fix-20261026/findings.md]
updated: 2026-10-26
---

# task-skill-audit-fix-20261026 知识蒸馏

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响 |
|------|---------------------|------|
| 跨技能引用相对前缀由**文件深度**决定：技能根 SKILL.md=`../<目标>/`，references/ 子目录=`../../<目标>/`；机器守护=selftest-doc-script-paths.sh T03 | skills/plan-template-kit/SKILL.md:17（正确根形态）vs skills/plan-cost-guard/SKILL.md:29（本轮修正）；审计证据「同技能他用 ../../」可指向同族错形本身（错错相证） | 修跨技能引用必须先判文件所在目录深度，禁照抄邻行形态；守护会抓 |
| Rule 落地级联时卫星路由索引行（critical-rules.md 的「Rule N,…」清单）可能漏号——Rule 95（nopause 10-24 落地）漏 task-discipline 行、Rule 91 漏 plan-collab-router 行 | skills/task-planner/references/critical-rules.md:194/:198（本轮补 ,95 / ,91）；对照各卫星 `### NN` 标题实测在位 | 新 Rule land 的级联清单必须含「task-planner/references/critical-rules.md 卫星路由行规则号清单」这一面；SKILL.md 索引表与该文件是两张不同的清单，都要核 |
| INDEX 状态 ≠ 实况：task-v188/v189 均为「工作已提交+合并但 task_plan 状态未回写」僵尸（INDEX 0/5 vs progress 全 complete） | plans/archive/task-v18{8,9}-*/progress.md（10-19 执行记录）+ commits 4722bb1/3fa1e02 | 恢复僵尸计划第一步=git log+progress 实证实况，再「真实 Phase 映射回填」收口；禁止按 INDEX 0/5 当作未开工重做 |
| 历史直改无白名单命中时如实登记 → check-delegation verdict=violation → Rule 25.4 outcome 封顶 PARTIAL（合法终态，不虚构派发记录） | check-delegation.sh:413-480（flush_phase 白名单编号判定）；两计划 verification.md 委派统计段 | 收口老计划遇委派门 exit 1：先验证工作产品面 VC 全过，再以 PARTIAL 终态留档，不回炉重做已入库工作 |
| 25.4a 白名单豁免路径：rate<floor 但主进程直做理由全命中 ①-⑥ 关键词 → WHITELIST-EXEMPT 放行 | check-complete.sh DELEGATION 段（wl_match 正则：白名单[①-⑥]|git 编排|计划系统文件|机械验证|…） | 新计划编排时主进程 Phase 的理由句必须含白名单编号+关键词，可合规通过 0.4 rate |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-planner/scripts/check-delegation.sh | :413-480 | flush_phase：主进程白名单编号判定+delegated 类型 Handoff 交叉校验（token 归一化含去空格） |
| skills/task-planner/scripts/check-complete.sh | :455-527 | DELEGATION GATE：rate<floor 白名单豁免路径+exit 1 条件（verdict=violation ∨ rate 未豁免） |
| skills/task-planner/scripts/archive-plan.sh | :88-110 | 归档守卫三拒：active 指针/.session-owner<24h/Status 未全 complete（fail-closed） |
| skills/task-planner/references/critical-rules.md | :194/:198 | 卫星路由行规则号清单（新 Rule 级联易漏面） |

## §4 易错点与禁止假设清单

1. 禁止为凑委派率把历史主进程执行虚写为子代理派发（Handoff 表造行）——violation 如实登记+PARTIAL 才是合法路径（本轮 v188/v189 两例）。
2. 禁止假设 INDEX/任务状态正确——0/5 可能是簿记中断；先 git log+progress.md 实证（v188/v189 教训）。
3. 运行时迁移（bun→node）后文档层残留是独立缺陷族：INSTALL/MIGRATION 可执行 bash 块、依赖表、注释都要扫（`grep -rn "bun run"`）；selftest 内测试素材字符串与模板泛化示例属登记例外，改词=用例语义变化。
4. 修 SKILL.md 规则范围串（如 69-76）时必须同步镜像文档：README.md 盒图+docs/ARCHITECTURE.md（本轮 CR 抓出 4 处镜像漏改）。
5. drift-checker 打回「缺计划载体」时：新建载体（init-session）同时会清会话哨兵，一石二鸟；S-unit 表给已执行工作补真实派发行（ID 纯数字/NNmin 时长/粒度三值）可通过 check-plan-dispatch。
6. FMEA RPN>100 兜底指针：本任务无 RPN>100 项（文本面批量修，回滚点=git）。
