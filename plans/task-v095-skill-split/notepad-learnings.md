# Task Learnings: {task-name}

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
- 2026-09-29 **D 类判定（Rule 8.1）**：新指令「拆分 task-planner 技能」与当时活跃计划 v094-tier-b-rollout（Tier B 效率项 rollout）Goal/范围/交付物均无关联 → 开新计划 `task-v095-skill-split`，v094 原样保留（其 worktree wt/task-v094-tier-b-rollout 属并行会话，本任务禁碰）。init 已将全局 `.active_plan` 指向 v095——v094 所属会话走会话级 side 指针（Rule 22.9）不受影响；两任务范围均触 skills/task-planner/**，合并顺序需协调（FMEA 登记）

## What Worked
- 三步式拆分范式（骨架→外迁+指针化→锚点同步+全量 selftest 绿）在 P2 试点后复制到 P3-P5，每 Phase 独立全绿可回滚
- 「消费方断言清点前置于每个迁移 S-unit」防住了 N 个潜在断链（P3/P4/P5 清点直接生成派发输入）
- 主进程白名单③机械验证接管（P4/P5/P6/P7 的 S3/S2）节省派发且验证独立可信；smart-merge-back V1-V6 预检零人工干预通过
- git mv 迁移保历史（rename 92-100% similarity），CR 对读基线原文零语义丢失实证

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环（用户指出错误/重复反馈/打断补充数据）与三击协议 -->
- [执行偏差] 测绘报告锚点清单漏内容型锚（T11/TB-11/WF-09/T6 四组均为执行期由 selftest/执行器兜出）→ 防线=P3 起每迁移 S-unit 前置「消费方 selftest 全断言通读」（Error Log P2-S3 行）
- [执行偏差] 子代理两度违反「禁 git」约束（S2 stash 对照/P5 提交缺删除侧；P6-S2b HEAD 还原对照）→ 防线=commit 后 status 终检捕获+amend 修补；后续派发 prompt 显式列禁 stash/restore/checkout
- [规则缺位] Handoff subagent_type 列写 `executor(sonnet-1)` 致委派统计 verdict=violation（v077/v092 教训第 3 次复发）→ 防线=本次当场修正为纯 token 并补登记 CR/nit 两行；后续建计划时 Handoff 模板列示例应为纯 token
- [假设未验] 测绘口径两处偏差（references 14 篇实为 13；plan-writer L22/39/50-64 引用在 v094 后已不存在）→ 防线=一切以执行期 grep/ls 实测为准，测绘仅作导航

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。 -->
- 本任务无新增用户否决项；D1 决策用户选「标准 4+3」并否决「全量拆（含高风险三项）」与「轻量内敛（不建卫星）」两候选（AskUserQuestion 2026-09-29）——后续任务提拆分方案时不再推荐全量拆 methodology/批量/workflow（除非有新证据交用户裁决）

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。
     32.2 计划期/32.3 执行期提出任何方案候选前必查本段（plans/ 历史 notepad 同查）；32.4 无新验证证据禁止重提——
     重提须标注「此前被否决于 <日期/出处>，现因 <新证据> 申请重议」交用户裁决；解禁仅限用户显式撤销（veto-lift 行）。
     31.5 消费侧联动：下一 Phase 开工前/新任务 init-session 后必读本段。 -->
-

## Files Modified
- master（aa092cc+052cf94+738e635+6d8e98f 等合并链+bea7341）：skills/task-planner/{SKILL.md,reference.md,references/critical-rules.md,references/batch-quality-gate.md,README.md,docs/ARCHITECTURE.md,lib/install-stub.sh,scripts/6 个脚本}；CLAUDE.md/README_zh.md；新增 4 卫星 skills/plan-{research-router,template-kit,cost-guard,collab-router}/
- 部署面：三实体位（~/.zcode、~/.claude、~/.config/opencode）五技能全量重部署 diff -r 15/15 IDENTICAL+单文件 Nit 补丁同步

## Verification Results
- Verified: 全量 selftest 35 脚本 584/0（基线 543/0+41 新断言）；主 SKILL.md 429 行锚点 24 项全在；三部署位 diff -r 15/15；CR APPROVED
- Failed: 无阻塞失败；5 项遗留披露见 verification.md（均基线既有或登记 defer）

## 📚 必要知识储备备注
- 本次新发现的知识源: 测绘报告+消费方断言清点方法论（拆分/迁移类任务的可复用 SOP，已体现于本任务各 S-unit prompt 结构）
- 值得入库的书目/文献: 无新增外部源
- 待补齐的知识缺口: §九机制矩阵 mini-lite/video/video-fix 三行；config.json:99 描述文本旧路径（待 config 授权维护窗口）

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话 -->
- 触发「迁移/拆分技能内容」→ 先 grep 全部 selftest 对源段落的断言（含内容型锚非仅 Rule 锚），测绘报告只作导航不作权威
- 触发「Handoff/委派统计 verdict=violation 且原因=未登记子代理类型」→ 查 Handoff 类型列是否纯 token（括号/空格后缀都会阻断 `| token |` grep）
- 触发「给主技能瘦身」→ 行数钉均为上界（≤558），缩减安全；Rule 摘要行/C 项行/计数锚是下界集合，动前先建锚点全集清单做前后差集对账
- 触发「新任务计划 init-session」→ 本任务遗留 5 项见 verification.md 遗留披露段（config.json:99/§九矩阵 3 行/T11a 贴线/jq 噪音/uninstall 默认根）
