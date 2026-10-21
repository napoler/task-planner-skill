# P2-S1 执行检查点（域 A：子代理派发/拆分/并行/路由 知识蒸馏）

- 角色：Executor（域 A 蒸馏，写 2 个新条目）
- 日期：2026-10-22
- 写入目标（仅 worktree）：`/home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/entries/`
- 产出文件（恰好 2 个，未动 INDEX.md / scripts / 其他文件，未写主仓内容，仅本检查点除外）：
  1. `knowledge/entries/dispatch-split-decision.md`（80 行）
  2. `knowledge/entries/dispatch-lifecycle-return-contract.md`（78 行）

## 读过的任务清单（域 A 14 任务）

| 任务 | 读到的文件 | 采信内容要点 |
|-----|-----------|-------------|
| task-v194-subagent-unit-cap | findings.md（全文 90 行） | ★核心源：8 篇/单代理 44min 挂死判例 + 用户裁决「每子代理约 1 篇」；四结构性缺口；46.6 五要素草案；媒体 1 单元/派发；调研 1 方向（Rule 75.8） |
| task-v150-split-skill-integration | knowledge-brief.md（110 行）、findings.md（134 行） | ★核心源：拆分模式库 11 模式 P1-P11 与五要素；Rule 21.6 六子条；P1-P10 对标面；拆分判定现状=纯数值 |
| task-v153-parallel-scheduling | knowledge-brief.md（72 行）、findings.md（§A/§B）、design-rule68.md:12 | ★核心源：68.1 独立性四问静态版 + 「前置依赖」列；68.3 组内异构 / 68.4 组域写隔离 / 68.5 唯一 join；21.4 声明制双条件 |
| task-v161-subagent-return-format | findings.md（99 行） | ★核心源：污染三面 + 24.1% 合规率 + 58 份抽样 + 用户 mid-turn 原话 + check-subagent-return.sh 四判据 + return_section_check |
| task-v057-subagent-io-contract | findings.md（§R1-R5） | 模板原状（§7 5 行占位骨架）；「8 字段之后不得有任何内容」补漏；Scope git 只读措辞；步长越界 18min/1.24M token/46 calls；mini 档 4 项违约 |
| task-v058-plan-dispatch-gate | findings.md（§R1 + sub 小节）、verification.md:77 | 委派率机器口径（check-delegation stats 为事实源）；S-unit 表缺「执行体」列；无脚本校验=纯文本约束失效 |
| task-v065-subagent-failure-rescue | findings.md（§Research + Phase 3 修复记录） | F-1..F-9 缺口（F-6 五档写成四档 / F-7 全灭无路径 / F-8 裸 BLOCKED）；22.3 五档 + 22.3.0/0b/1/2；22.7/22.7.1 六字段 |
| task-v061-serial-dispatch | findings.md（grep 定位 §并行条款盘点/§串行铁律设计） | 09-12 绝对串行铁律 + sess_1316c7f8 并行质量崩塌实证 + 并行条款盘点 6 处 |
| task-v056-fine-grained-dispatch | findings.md（§R1/R7） | 拆分约束全挂 Phase 层（21.1/22.1 同值）；Subtasks 形同虚设；委派率比较反转 bug（0.714 假阴性） |
| task-v185-file-split-discipline | findings.md（Rule 92 草稿） | 92.2 尺寸参考线（300/500 行/5K 字符）+ 92.5 垂直切分边界（≤10 行孤儿=过度拆分） |
| task-v146-drift-check-subagent | knowledge-brief.md（§5.3 drift-checker 全文） | 正确范式：按派发 prompt 8 字段模板返回（kb:96） |
| task-v088-workflow-orchestration | findings.md（Rule 39 段，grep 定位） | 显式点名 /workflow 才路由 + 21.4 并行豁免登记制（背景，未入条正文） |
| task-v095-skill-split | knowledge-brief.md（99 行） | 拆分技能本体（卫星技能/行数钉）— 与派发域弱相关，未入条正文 |
| task-v064-smart-merge-back | findings.md（委派率 grep） | 委派率 0.571 < 0.7 → WHITELIST-EXEMPT 判例（并入条目 2 结论 8） |

补充读取（现行条文核对）：`skills/task-dispatch/references/critical-rules-dispatch.md`（21.1b/21.4/46.1-46.6/52.1-52.2/22.3-22.8.x/25.3/68.1-68.7），用于核对数值与行号锚。

## 条目摘要

### 条目 1 `dispatch-split-decision.md` — 派发与拆分决策
- 结论 13 条：① 体量门（≤2f/100l/15min）+ 单元数门（内容 1 / 媒体 1 / 机械 ≤5 / 其他 ≤3，豁免仅 2 类）双闸缺一即漏 ② 46.6 判定与 S-ID 无关、按声明交付物粒度计数不按文件折算 ③ 单任务专注度三闸（46.1 单会话单 S-unit / 46.3 拆分单一性 / 46.4 模板引导语）④ 翻车判例（8 篇 44min 挂死 → 用户裁决 1 篇/代理；19 片段打包判例；规则在位仍翻车）⑤ 并行独立性四问 + 声明制双条件 ⑥ 68.1 计划期强制依赖分析落「前置依赖」列 ⑦ 并行演进史（09-12 绝对串行 → 10-02 并行默认+守门 → 21.4.2 扩组协议）⑧ 68.3/68.4/68.5 组内纪律三条 ⑨ 拆分模式库 11 模式 + 21.6 六子条 ⑩ 拆细前移（59.4）⑪ 媒体轴=工序×单元 ⑫ 测试类 S-unit ≤6 用例/步 ⑬ 派发粒度 ≠ 产出文件粒度（92.2 线）
- 证据锚 16 行、易错点 10 条、适用场景 5 条。

### 条目 2 `dispatch-lifecycle-return-contract.md` — 子代理生命周期与返回契约
- 结论 11 条：① 8 字段严格模板 + acceptance 禁自报汇总 ② 污染三面根因 + 24.1% 合规率 + bind 变体传播 ③ 两道机器校验（prompt 侧 return_section_check / 返回侧 check-subagent-return.sh 四判据）+ 主进程闭环 ④ 生命周期六段 checklist（九字段→checkpoint→T1-T5→resume_from→返回缺失→只读代建）⑤ provider 失败五档（改派→拆细→降档→接管→AskUser）⑥ 22.3.0/0b/1/2 外围三档 ⑦ STOP 六字段最小集 ⑧ 委派率机器口径 + 25.3 白名单字面卡口 ⑨ 专用体优先与 general-purpose 边界 + Handoff 裸名 ⑩ 22.4c 守卫判据 + 步骤枚举 ≤4 ⑪ 档位与遵守度相关
- 证据锚 15 行、易错点 12 条、适用场景 5 条。

## 自测结果（全部通过）

1. frontmatter 提取：`awk '/^---$/{c++;next} c==1{print}'` 两文件均完整取出 `id/title/tags/sources/updated`，首行均为 `---`，第二分隔行正确收口。
2. sources 抽验：两文件各 10 条，逐条 `[ -f /mnt/data/dev/task-planner-skill/<path> ]` → 全部 OK（Rule 71 无源不写：每条均为本次实际读过或 grep 取证过的文件）。
3. `wc -l`：dispatch-split-decision.md = 80 行；dispatch-lifecycle-return-contract.md = 78 行（均在 40-80 行区间）。
4. 范围纪律：worktree `git status --short` 仅见 `?? knowledge/entries/dispatch-*.md` 两个新文件（其余 `??` 为并行子代理产物，非本人写入）；未改 INDEX.md / scripts / 任何受管文件；主仓仅新增本检查点文件。
