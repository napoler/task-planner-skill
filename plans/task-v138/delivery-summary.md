# task-v138 交付总结（delivery-summary — Rule 48 五要素）

> 交付日期：2026-10-06 ｜ 终态：**COMPLETE** ｜ 交互模式：silent（静默决策清单见 §6）

## 1. 任务说明

用户原始诉求：视频创作链中「查 Agnes 剩余生成额度」这类高频可复用操作从未落盘成固定脚本，执行体每次现场发明「第一次耗几秒、第二次耗几秒」的耗时累计推算法，产出完全错误的额度结果。要求：常用/可复用功能第一次成功执行即落盘到固定脚本/固定文档，之后一律复用。

解法：在 task-planner 技能新增 **Rule 55「可复用能力落盘纪律」**（复用前置检查/权威来源优先禁令/首次成功即落盘/固定位置与注册表/执行体接线/机制守护六子条）+ 固定能力脚本目录与唯一注册表 + 首个落盘实例（Agnes 额度直查脚本）+ 两个生成执行体 SOP 接线 + selftest 静态守护，全量回归后合并回 master 并部署三宿主。

## 2. 产出清单（全部已合并 master@5ed69e7，三宿主部署 IDENTICAL）

| 资产 | 位置（绝对路径） | 说明 |
|------|-----------------|------|
| Rule 55 条款 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:613-623 | 六子条+R1-R4 原文锚+本任务判例；纯增量 |
| SKILL 索引 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（:9 全集 1-55 / :268 / :311 bullet / :334） | 三处联动零净删 |
| 能力脚本 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/capabilities/agnes-quota.sh | 211 行；key 候选链（env 三键→~/.bashrc）+零成本鉴权校准+强制绕 CDN 缓存+直查 billing+**禁二次推算**（计费层未填充时如实判定）；退出码 0/2/3/4/5；`--json` 机读 |
| 能力注册表 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/capability-registry.md | Rule 55.4 唯一索引，首条 agnes-quota（8 列） |
| 执行体接线 | /mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/video-generation-executor.md:43 与 image-generation-executor.md:42 | 前置检查段复用指向行（对称） |
| 守护 selftest | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-capability-persistence.sh | 20 断言（含 python3 mock 负向咬合 CP-19/20）；selftest-registry.tsv 53 行登记 |
| 用法 | `bash /home/terry/.zcode/skills/task-planner/scripts/capabilities/agnes-quota.sh`（或 `--json`） | 以后查 Agnes 额度一律跑它，禁再手工推算 |

## 3. 审查信息

- **全量回归**：53/53 脚本 FAIL=0（Phase 4 S1 52 个+Phase 4b 后主进程机械重跑 53 个，v136 并行新增脚本计入）——证据 /mnt/data/dev/task-planner-skill/plans/task-v138/verification.md §VC-5
- **代码审查（Code Review Gate）**：首轮 CHANGES_REQUESTED（F1=非 200 伪成功缺陷，mock 可复现）→ fix-phase 闭环（commit 8b12495：200-only 判据+exit 5+mock 断言）→ 复验通过
- **对齐审查（Rule 42.6.2）**：APPROVED（0 P0/P1；R1-R4 载体 4/4、八工序核销 8/8、交叉引用 11/11）——报告 /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/18-alignment-review.md
- **终验门控**：check-complete rc=0（DELEGATION 0.833≥0.7 / VC-GATE 6/6 / 3-File / Learning Gate / rescue 完好）
- **关键事实更正**：Phase 1 四波探针推翻两个中间误判——①env key「失效」实为非交互 shell 不达 .bashrc export；②「billing 不可得」实为 CDN 缓存态 200 冒充鉴权证据。终态定论（HIGH）：**Agnes billing 端点存在（/v1/dashboard/billing/{subscription,usage}）但计费层未回传有效配额**（limit=1e8 占位、total_usage 恒 0 与日期窗无关）；官方文档无额度端点、无配额回传头——剩余额度权威面=登录仪表板 Usage/Billing，HTTP 402=耗尽事后信号

## 4. 风险点（必须列举）

1. **计费层未填充**：脚本直查真实但 Agnes 不经 API 回传有效配额——「剩余视频额度」数字**不可由 API 获得**，脚本已显式判定并禁推算；若未来 Agnes 填充数据，脚本自动转为有效数字（无需改码）
2. **LOW-1（deferred）**：critical-rules.md 55.2 内嵌注记「Rule 54.1 预留未落地」已滞后（v136 已落地）——单行行内改写可修，留给下一轮技能维护
3. **LOW-2（deferred）**：计划 VC-5 字面「52 脚本」与实测 53 差额=v136 并行新增，历史时点值不回改
4. **key 解析依赖**：脚本 key 候选链含 `~/.bashrc` 的 `export AGNES_API_KEY=`；用户若更换 key 存放方式需同步该行（脚本 exit 3 时有指引输出）
5. **并行会话竞态**（已消化）：本任务 worktree 曾被并行会话提前合并（1992566）；fix 波以新 worktree（基于 fed4393）重放，无丢失

## 5. 下一步建议

1. **消费验证（对象=/home/terry/.zcode/skills/task-planner/scripts/capabilities/agnes-quota.sh，看点=新会话里执行体是否自动复用而非手算，动作=下次视频创作时观察）**：Rule 55 行为面生效需新会话（部署位已同步）
2. **LOW-1 修正（对象=/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:618 附近，看点=「预留未落地」字样，动作=下一轮技能维护任务顺带单行改写）**
3. **Agnes 计费层观察（对象=脚本 verdict 行，看点=limit 是否仍 1e8 占位，动作=如 Agnes 官方后续开放真实配额字段无需改码，直接生效）**

## 6. 静默决策清单（silent 模式，供复核）

| # | 决策 | 依据 |
|---|------|------|
| 1 | 交互模式 silent（无人值守+指令明确） | Rule 28；D6 硬停点保留 |
| 2 | 探针 GET 只读 ≤3/波，自主迭代三轮（key 候选链→鉴权控制组→日期参数） | 41.2 门槛外+35.6 最小探针+Error Log 登记 |
| 3 | 端点「数据未填充」不伪造直查成功；终验不落 PARTIAL（脚本真跑成功故 V2 PASS） | 43.1/51.8+计划 PARTIAL 分支适用性复核 |
| 4 | 授权既有 selftest 纪元/行数钉同步（RR-09/RR-16/R-09/SR-08/skill-split ≤490） | KQ3 预判+FMEA 兜底+v117/v109 判例 |
| 5 | Phase 4b B 类扩展（fix-phase）+ 承接他会话未完成的三宿主部署 | 用户新指令处理 B 类+live race 判例 |
| 6 | 2 LOW 项 deferred 不阻断终验 | 对齐审查判定+比例原则 38.7 |
