# Task Learnings: task-v164-pointer-worktree-local

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
- 2026-10-10 11:2x（用户 mid-turn 反馈，语音转写）：「既然已经有基于工作数这个隔离机制了……为什么不将这个指针存放于……工作数的相应的文件下？……以后合并的时候，只需要……忽略掉这个状态临时文件就可以了」+「当前的工作存在严重的问题……指针问题，依旧存在着混乱的情况，依旧……被无端地切换来回切换去」+ 实证（v163 执行会话："指针侧已归位但全局指针仍是已完成的 v152——先移交全局指针到 v163"）
  - implied scope：活跃计划指针工作树内本地化 + 瞬态状态文件治理 + 合并零摩擦
  - plan impact：**D 类新任务**（Rule 8.1：与 v152 Rule 67/v163 调研诚实性均无关联）→ 开 task-v164-pointer-worktree-local 独立承载，R1-R5 逐字归档于 task_plan.md「🎯 用户需求原文」；v152/v163 不收编

## What Worked
- 先第一手机制审计（读两脚本全文+git log+side 清单+gitignore）再定方案 → 发现"指针路径已随 $PWD 工作树本地化"纠正用户模型，方案聚焦真缺陷（git 跟踪态+移交叙事），避免按字面做路径大改
- 用户反馈里带实证（v163 会话实录）直接定位全局层漂移，与 side 层保护事实交叉验证，归因一次到位

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签 -->
- （本轮无）

## 🚫 被否决方案（User Rejected — Rule 32）
- 无用户否决项。进程内比选淘汰：D2（保留跟踪+合并约定）/D3（删全局只留 side）见 findings.md Technical Decisions——属主进程方案比选非用户否决，不适用 32.4 重提限制

## Files Modified
- 新建：`plans/task-v164-pointer-worktree-local/{task_plan,findings,progress,knowledge-brief,notepad-learnings,verification}.md`（6 件）
- 未动任何技能文件/配置（§六/§十一：技能修改待本计划批准后按 worktree 流程执行）

## Verification Results
- Verified: `.active_plan` 跟踪态（git ls-files）/HEAD=已完成 v152/git log 8 连 churn/side 8 会话并行实况/.gitignore 兄弟四类已 ignore/引用面 28 文件 166 hits/3 个飞行 worktree/INDEX:101 v146 陈旧行致 conflict hook 误报（命令+输出见 progress.md 计划期取证段）
- Failed: 无

## 📚 必要知识储备备注
- 本次新发现的知识源: 无（既有机制审计）
- 值得入库的书目/文献: 无
- 待补齐的知识缺口: critical-rules.md 指针相关段行号锚（Phase 1 定位）；selftest-active-plan.sh/selftest-pointer-lifecycle.sh 断言细节（Phase 1 复读）

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话 -->
- 触发条件=用户再报"指针漂移/被切换" → 防线=先 `set-active-plan --show --sid` 看三层（side/全局/解析结果），再 `git log -- plans/.active_plan` 判是否跟踪态 churn，禁凭单表象归因 side 层失效
- 触发条件=写任何 plans/ 新文件触发 conflict hook → 防线=查 INDEX 对应行状态与计划目录 task_plan.md 是否归档（v146 陈旧行误报先例），确认无真实冲突后续写

## 通用规则（General Rules — Rule 31.7）
| 规则名称 | 适用条件 | 具体措施 |
|----------|----------|---------|
| 瞬态状态文件治理 | 任何"即写即弃"运行态文件（指针/哨兵/sidmap/检查点/节奏态） | 创建即入 .gitignore；入库=每次会话移交都变永久提交噪音（.active_plan 8 连 churn 实证）；合并规则按"瞬态处置=取删除/重生态" |
| 用户提案先审计再裁量 | 用户提出机制性修改方向（"为什么不 X"） | 先第一手读实现验证前提是否既成（本例：路径本地化已是事实），再对真缺陷出最小方案；禁按字面直接大改 |
