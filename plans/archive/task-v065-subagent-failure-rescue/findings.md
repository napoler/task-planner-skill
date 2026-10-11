# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

## Research Findings（Phase 1 审计 — 2026-09-13）
- 审计报告: plans/task-v065-subagent-failure-rescue/diagnostic-report.md（552 行，general-purpose 子代理产出，主进程 5 处 file:line 逐字复核通过）
- 核心判定 [P0]: 失败挽救链路"文本齐备、机制全缺"——`grep -rniE "salvage|挽救|摆烂|放弃"` 全库 92 文件零命中；Rule 22.3 五档兜底为可整体跳过的软文本，而 22.7 STOP 是 D6 两模式一致硬停点 → "跳过挽救+强制停止"=用户观察的摆烂
- F 系列（失败挽救缺口）9 条: F-1 零机械门控（check-dispatch.sh:48 全是派发前检查）/ F-2 check-plan-dispatch.sh:30 legacy 键错（字面量"执行体"，已实测放行 v065 自身）/ F-3 22.7 连续失败≥2 直接 STOP 无"穷尽挽救"限定 / F-4 STOP 上报无"已尝试挽救清单"要求 / F-5 Handoff 表无 rescue 列 / F-6 subagent-fallback.sh:260,270,280 timeout 误分类+编号错位+五档写成四档（剔除"拆细"）/ F-7 provider 全灭+任务>300行 = 无挽救路径 / F-8 silent+D6 硬停+第5档推荐项未定义 = autonomous 必挂起死结 / F-9 D3 询问时点与五档表矛盾
- V 系列（规范违规）18 条: P0×7（V-1 allowed-tools 缺 AskUserQuestion/WebSearch/WebFetch；V-2 7 个 variant 模板把 Skill() 放进子代理 Executor Phase；V-3=F-2）+ P1×12（V-4 sync-todos subject 丢 title+status 未清洗 / V-5 PLANS_DIR 无向上解析 / V-7 plan-created.cjs readdirSync 首命中即判有效计划（实测认定 task-3file-enforce）/ V-8 attest-plan ls -t 探测 / V-9 VC/V-N 零机械校验 / V-11 写死路径 3 类 / V-12 .claude/.zcode 混用 / V-13 3 个 .ts 无 @configurable / V-14 账本无锁并发追加 / V-16 verify.sh 自测清单缺 6 个 selftest）+ P2×5（V-6 重复函数 / V-10 锚点过期 / V-15 默认值不一致 / V-17 引用不存在模板 / V-18 Rule 编号 1-27 应为 1-28）
- 机械扫描: bash -n 42 文件全 exit=0；S64 validator PASS（但存在 references/*.md 盲区 → V-17 由人工扫描补出）；S76 D2 无锁追加 P1（V-14）
- 范围外 D-1..D-5（skill-fix 工具盲区/历史遗留/归档策略）→ deferred-issues.log

## Technical Decisions
- 修复范围锁定: F-1..F-9 全量（用户授权①）+ V-1..V-18（用户授权②"其他不符合技能规范的"）；V-11① companion model UUID 占位化不做结构性改造（破坏本机运行时），改文档登记+deferred；V-11②③ 执行
- 修复依赖顺序（采诊断报告 §4）: F-2/V-3 门控恢复 → F-1 挽救链路机械门 → F-3/F-4/F-5/F-6/F-7/F-8/F-9 → V-1/V-2 → 其余 P1 → P2；V-9 与 F-1 共用 check-complete.sh 同批提交

## Phase 3 修复记录（2026-09-13，worktree 内 3 S-unit 串行）
- S-1 commit 1b84ca3: F-2 门控判定键修复(check-plan-dispatch.sh:30 legacy 键改 `^- \*\*Executor:\*\*`)+F-1 新建 check-rescue-chain.sh(+286 行,failed/timeout 行三查门控,rescue_chain_enforce 档位 env>config>fail-open warn)+check-complete.sh 接入+selftest 8+11 用例全绿
- S-2 commit 38d6ced: F-3 22.7 换档语义(≥2 次失败未穷尽①-④禁止 STOP)/F-4 22.7.1 STOP 上报六字段最小集(缺=摆烂上报)/F-5 Handoff 表+22.5 增 rescue/retry_count 列+scaling-redispatch 枚举/F-8 28.4.1 D6 silent 例外(降级交付禁空等,推荐项=拆细后接管≤300行子集)/F-9 D3 询问时点统一(Recommended=继续降档保持挽救链推进)+28.2 D6 联动修正
- S-3 commit 6f2611a: F-6 三处(timeout 独立分支 timeout_split_first 拆细优先/编号④⑤/五档全序+tier_order 结构化数组)/F-7 22.3.2 provider 全灭挽救档(先拆细到≤300行再逐片接管,降级交付点禁裸 BLOCKED)+selftest 29/29
- 风险登记: v065 自身计划派发型 Phase 无 S-unit 表,合并后终验会被新门控拦(S-1 修复生效所致)→终验前补 S-unit 表; no_health_file 分支未升级 22.3.2(S-3 范围限定,登记观察)

## Phase 4 修复记录（2026-09-13，worktree 内 6 S-unit 串行）
- T-1 aa19691: V-1 allowed-tools 补 AskUserQuestion/WebSearch/WebFetch + V-2 七 variant 模板 Skill() 主进程标注 + V-10 锚点/V-15 默认值/V-17 引用/V-18 Rule 1-28（11 文件 +17/-18）
- T-2 7ad8ec0: V-5 sync-todos 向上解析(resolve_plans_dir 6 级) + V-4 subject 补 title(40 字符截断)+status 归一 complete + V-6 去重 extract_plan_meta + V-7 plan-created 四级解析链(env>side 指针>legacy>mtime,无活跃计划 exit 1) + V-8 attest-plan 接 resolve-plan-dir（4 文件 +156/-31，selftest-active-plan 15/15）
- T-3 7f1a0a9: V-9 check-complete.sh VC≥5+每Phase≥2 V-N 门控(vc_gate_enforce 默认 warn,env TASK_PLANNER_VC_GATE_ENFORCE) + 模板 V-N 占位行 + selftest-vc-gate 9 用例（+292/-5）
- T-4 f175210: V-12 SKILL.md:66 兜底行{platform-home} 化+template-guide/template-mapping 双平台+V-11② plan-writer cwd $HOME 化+V-11③ worktree-isolation ${REPO_PARENT} 参数化（5 文件 +10/-9）
- T-5 39dc8b9: V-13 三 .ts @configurable 登记块 + V-14 check-delegation/allow-direct 账本追加 flock 化（并发 10 路实测无交错，selftest-delegation 38/38）
- T-6 b15d42a: V-12 遗留 4 处双平台化 + 三路径锁名统一 .ledger_lock + todo-sync 枚举补注(原生 completed/脚本归一 complete) + no_health_file 分支 22.3.2 对齐（selftest-fallback 30/30）
- 裁决记录: V-18.4 hooks 注释行=显式双平台声明设计(保留)；variant 注释/节奏行 Skill(=主进程视角说明非子代理指令(保留)；V-11① companion model UUID=deferred D-6(占位化破坏本机运行时)
