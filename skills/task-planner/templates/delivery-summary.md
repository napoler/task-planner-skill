<!-- delivery-summary.md — 任务交付总结五要素模板（SKILL 终验交付段配套，用户面） -->
<!-- 使用方式: 终验结论（COMPLETE/PARTIAL/BLOCKED）判定后、会话退出前，按本模板向用户输出交付总结；
     需要跨会话存证/独立子代理验收（VC 类条款要求落盘）时，同步落 plans/<task-id>/delivery-summary.md -->
<!-- 定位: 用户面总结 = 引用机器面档案而非重写——数据源指针: verification.md（VC/委派/门控/Goal Gate）、
     progress.md（每 Phase Files created-modified/Error Log）、subagent-state/（独立验证 checkpoint）、
     report.md / memory-hygiene-report.md（如有）；本模板不复述证据原文，只写指针+一句话结论 -->
<!-- 详略标准: 以「用户可独立决策」为准——用户读完不查三文件即可回答: 产出物在哪/哪些可信/风险是什么/我下一步做什么 -->
<!-- 可定位性硬规则（Rule 48，2026-10-03 task-v123；用户裁决原话「让人审查接下来做什么时候竟然不包含
     审查内容路径或者网址，让人完全不知道到哪里审查」）:
     ① 文件/对象指针 = 绝对路径，或仓内路径 + 全文给出仓库根绝对路径（定位栏）；禁止裸文件名（「见 verification.md」）
     ② 线上内容 = 完整 URL；操作 = 可直接执行的完整命令（含工作目录/前置 cd）
     ③ 禁止未解析占位符（<merge-hash> 之类原样输出）、模糊指代（「相关文件」「上文」「另行确认」）
     ④ 行动项定位三要素（§5 逐条必填）: 对象（要打开/审查的东西: 路径 或 URL）+ 看点（锚点/段落，看什么）
        + 动作（用户做什么 + 期望反馈形态）；审查类条目必须含审查对象路径或网址
     ⑤ 指针相对本总结语义自足——读者未读过三文件也能直接定位（机器档案路径见「定位栏」） -->
<!-- 反模式 → 修法对照（Rule 48.2 自查）:
     「见 verification.md」→ 「见 <绝对路径>/verification.md VC 复验段」
     「请审查」/「建议观察 1-2 周」→ 对象（路径/URL）+ 看点 + 动作三要素补齐（去哪看/看什么/回什么）
     「git revert <merge-hash>」→ 「cd <仓库绝对路径> && git revert <具体hash>」
     「部署位已同步」→ 逐位绝对路径列表    「bash xxx.sh」→ 前置 cd 绝对路径或写全绝对路径命令 -->
<!-- 头部形态: HTML 注释指引区（同 batch_report.md/knowledge-brief.md 根模板惯例），无 <!-- template_type: -->
     （非计划模板，不进 check-template-type 白名单，不入 25 模板口径） -->

# Delivery Summary — {task-id}（任务交付总结）

> **定位栏（Rule 48.2）**: 机器档案=`<plans/<task-id>/ 绝对路径>` ｜ 仓库=`<仓库根绝对路径>` ｜ 交付基线=`<merge commit hash，或「未合并（分支 <branch>）」>` ｜ 部署位=`<逐位绝对路径列表；无部署写「无」>`

## 1. 任务说明
- **Goal 回顾**: [一行，引 task_plan.md Goal 原文]
- **执行过程摘要**: [Phase 序列 + 各 Phase 执行体（子代理/主进程）+ 关键裁决点（含 silent 自动裁决清单，
  Decisions Made 表 `silent:` 前缀行逐项列出），3-6 行；数据源 = progress.md Phase 段 + task_plan.md Decisions Made]
- **行为面变化**: [必填行——本任务完成后用户可感知的变化（下次会看到什么不一样/能做什么新事）；无则写「无」，禁止省略]
- **交付结论**: COMPLETE / PARTIAL / BLOCKED [引 verification.md Goal Gate outcome]

## 需求覆盖核对（Rule 51.3 — 交付必载）
<!-- task-v129：逐需求条目判定；任一用户显式核心需求 uncovered/partial 且无用户让步登记 → 终态禁 COMPLETE -->
| 需求# | 用户原话（摘） | 判定(covered/partial/uncovered) | 证据路径 |
|-------|--------------|-------------------------------|---------|
| R1 | （摘录） |  | （绝对路径/命令） |

> 无用户原文锚定的任务（纯调研/无显式核心需求）须登记一行「51.1 豁免：<理由>」，不得留空。

## 2. 产出清单（文件级）
| 文件（绝对路径，或仓内路径并已在定位栏给出仓库根） | 变更摘要（新增/修改/删除 + 一句话） | 验证状态 |
| ... | ... | VC-N PASS / N selftest rc=0 / grep 锚实测 / Read 复验 |

[数据源 = progress.md 每 Phase「Files created/modified」+ verification.md VC Evidence 逐条指针；
 合并类任务附 merge commit hash（如 5a30382）；有部署时逐位列部署绝对路径 + 对账结论（diff=0）]

## 3. 审查信息（尽量详细）
- **VC 复验**: N/N 条 PASS（指针: <机器档案绝对路径>/verification.md Goal Gate 段）
- **回归**: <N> 个 selftest / SUM-ASSERTIONS=<数值>（独立子代理 sub:<k>，checkpoint: <机器档案绝对路径>/subagent-state/<k>-<agent>.md）
- **快速复核入口（Rule 48.4）**: [1-3 条用户可直接执行的最轻复核命令（含前置 cd 绝对路径），复验最关键结论的入口；
  例: `cd <仓库绝对路径> && bash skills/task-planner/scripts/selftest-template-lifecycle.sh`]
- **对齐审查**: verdict（APPROVED / CHANGES_REQUESTED + 处置项清单）（指针: checkpoint sub:<k>）
- **委派统计**: check-delegation.sh stats JSON 原文（phases_total/delegated/rate/verdict）+ 白名单豁免判定行
- **质量门控**: Q1-Q6 触发/豁免/未处置计数 + Evidence 抽查 ≥3 条记录（指针: verification.md 质量门控统计段）
- **验证独立性**: 本任务验证动作由 <N> 个全新独立子代理执行，主进程零自测替代验收（2026-09-26 裁决）

## 4. 风险点（必须列举；无则逐项写「无」，禁止整块省略）
- **已知遗留**: [PARTIAL 的已知缺陷 / 未授权零修复的候选清单指针（绝对路径）/ 无]
- **待裁决**: [需用户拍板的事项逐项列出（部署同步/D6 授权等），每项含对象定位（绝对路径/URL）+ 上下文一句话]
- **失效条件**: [本任务结论何时会过时——逐条给失效判据 + 验证方式（可执行命令或明确动作），消费方触发即重验；
  例「基线 43 脚本 676/0 — 失效条件: 任一新增/删除 selftest 脚本或计数漂移；重验: cd <仓库绝对路径> && bash <script>」]
- **回滚方式**: [可直接执行的完整命令 + 仓库/分支/具体 commit（`cd <仓库绝对路径> && git revert <具体hash>`）/
  备份文件绝对路径 / 无]

## 5. 下一步建议（用户可执行行动项，按推荐排序；默认项排第 1 位并标注「推荐」）
> 每条必须含定位三要素（Rule 48.3）：**对象**（要打开/审查的东西：绝对路径 或 URL）｜**看点**（具体位置/锚点）｜
> **动作**（做什么 + 期望反馈形态）；审查类条目必须给审查对象路径或网址；操作类必须给可执行命令。

1. **[推荐]** <行动项 1 — 对象: `<绝对路径/URL>` ｜ 看点: <锚点/段落> ｜ 动作: <做什么/期望反馈>>
2. <行动项 2>
3. ...
[多待决项按 Rule 41.5 打包呈报 + Rule 44.1 默认项排序；无待决项时写「本任务无待用户行动项」]
