# Task Learnings: task-v085-task-type-mechanism-profile

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
- 2026-09-20 交付前指令「修改完成后部署到各个平台，然后提交修改到 github」→ 按 v077 后 SOP 走 smart-merge-back --deploy + 三位部署 diff 亲验 + push（计划 Phase 4 既有范围，无扩展）

## What Worked
- 机制画像映射层（Rule 37+§九 矩阵）一次收口：14 行矩阵为唯一权威源，规则/主文件/守卫全部指针化，零 per-type 开关键爆炸
- 逐 S-unit 串行派发 + checkpoint 检查点（4 个 code-assistant 槽全部落盘 checkpoint），返工面小

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环（用户指出错误/重复反馈/打断补充数据）与三击协议 -->
- check-dispatch 守卫「计划自声明」误锚（执行偏差）：派发 prompt 内出现与计划文件同名的目标路径（templates/task_plan.md）→ 被当计划自声明锚误判 findings/progress 缺失 + 材料包正文 S 编号被打包检测。触发条件=派发 prompt 含同名文件路径或「S3/S5」类编号字样；防线=目标路径放材料包不放 prompt，多 S 编号说明写 checkpoint
- 「Rules 1-3N」索引多锚位漂移（数据源过时）：Rule 37 新增后 SKILL 3 处 + README 1 处 + 4 个 selftest 宽容锚（1-3[56]/1-3[1-6]）仍指 36，级联 3 处 FAIL。触发条件=新增 Rule 编号后；防线=收尾必 grep 全仓「1-36」类字面并扩宽容锚区间（1-3[5-7]/1-3[1-7]）
- 空返回子代理（执行偏差）：S9 断言同步单元「completed 但无输出」且未落盘未 commit → 主进程 3-Strike 接管。触发条件=子代理返回无内容；防线=产出必须 checkpoint+git status 双证据，无产出=白做按 22.3④ 接管
- check-complete 注释形态 template_type 提取盲区（规则缺位，低优先登记不修）：`<!-- template_type: writing -->` 形态两路提取均失败静默跳过，与既有 check-template-type.sh 同盲区；属沿袭约定，修需两处同步

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。
     32.2 计划期/32.3 执行期提出任何方案候选前必查本段（plans/ 历史 notepad 同查）；32.4 无新验证证据禁止重提——
     重提须标注「此前被否决于 <日期/出处>，现因 <新证据> 申请重议」交用户裁决；解禁仅限用户显式撤销（veto-lift 行）。
     31.5 消费侧联动：下一 Phase 开工前/新任务 init-session 后必读本段。 -->
- （本任务无新增用户否决；历史两条 veto（无试点批量/速度理由压缩验证，v083 登记）继续有效）

## Files Modified
- skills/task-planner/references/critical-rules.md（+12 Rule 37）
- skills/task-planner/SKILL.md（+4 纯增量 + 1-37 索引级联 3 处行内改写）
- skills/task-planner/references/template-mapping.md（+31 §九）
- skills/task-planner/templates/task_plan.md（+2 画像注记）
- skills/task-planner/references/template-guide.md（+1 指针）
- skills/task-planner/config.json（+6 mechanism_profile_enforce）
- skills/task-planner/scripts/check-complete.sh（+10 画像抽查段）
- skills/task-planner/scripts/selftest-mechanism-profile.sh（新建 151 行）
- skills/task-planner/scripts/selftest-template-lifecycle.sh（+TL-18）
- skills/task-planner/scripts/selftest-{batch-pilot,execution-stability,knowledge-brief,skill-collab}.sh（行数断言 548→549）
- skills/task-planner/scripts/selftest-{reflect-verify,veto,conclusion-discipline,error-loop}.sh（宽容锚 1-3[5-7]/1-3[1-7]）
- skills/task-planner/README.md（1-37 级联）+ CHANGELOG.md（v085 条目）

## Verification Results
- Verified: 全量 24 selftest 402 PASS / 0 FAIL（主进程逐 Total 行求和）；Code Review Gate APPROVED（5 findings 全处置）；委派率 0.75 verdict=ok；config json 合法
- Failed: 无未处置项（CD-11/CD-19/EL-11 索引 FAIL 已级联修复复跑 0 FAIL）

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源:
- 值得入库的书目/文献:
- 待补齐的知识缺口: check-dispatch 同名文件自声明误锚（可提任务：decl_taskdirs 排除非计划目录的 task_plan.md 同名文件场景）

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话；31.5 ① 下一 Phase 开工前 Read 未消费项命中即执行并记 [learn-apply]；31.5 ② 新任务 init-session 后 Read 上一 completed 任务同段作风险预演输入 -->
- 新增 Rule 编号时：先 grep 全仓「1-3N」类字面（SKILL/README/selftest 宽容锚），与 Rule 正文同批级联
- 派发 prompt 禁含与计划文件同名的目标路径字样与多 S 编号说明（守卫误拦两案例）
