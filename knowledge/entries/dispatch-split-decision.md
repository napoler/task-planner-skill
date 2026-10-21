---
id: dispatch-split-decision
title: "派发与拆分决策"
tags: [子代理派发, 拆分粒度, 并行调度, 单任务专注度, 拆分模式库]
sources:
  - plans/archive/task-v194-subagent-unit-cap/findings.md
  - plans/archive/task-v150-split-skill-integration/knowledge-brief.md
  - plans/archive/task-v150-split-skill-integration/findings.md
  - plans/archive/task-v153-parallel-scheduling/knowledge-brief.md
  - plans/archive/task-v153-parallel-scheduling/findings.md
  - plans/archive/task-v153-parallel-scheduling/design-rule68.md
  - plans/archive/task-v061-serial-dispatch/findings.md
  - plans/archive/task-v056-fine-grained-dispatch/findings.md
  - plans/archive/task-v185-file-split-discipline/findings.md
  - skills/task-dispatch/references/critical-rules-dispatch.md
updated: 2026-10-22
---

# 派发与拆分决策

## 结论（可直接复用）

1. **拆多重 = 体量门 + 单元数门两道闸，缺一即漏**（来源：task-v194 / Rule 21.1b·59.1·46.6）
   - 体量门（21.1b / 59.1 粒度三值）：单 S-unit ≤ `2 文件 / 100 行 / 15 分钟`；S-unit 表必填三值 `Nf/Nl/Nmin`（模板格式 `1f/65l/13min`），任一超限 → attest 拒锁（超限行原为 SKIPPED 提示，task-v144 起升为 enforce）。
   - 单元数门（46.6 单子代理生产单元上限表）：内容生产/修正类 **1 个生产单元/派发**；媒体生成类 **1 个生产单元/派发**；批量小操作类（单单元 ≤2 分钟机械动作）**≤5 个/派发 + 逐单元检查点落盘**；其他可数交付类（兜底）**≤3 个/派发**；豁免仅两类（纯只读调研无逐单元写入产物 / 用户对该次派发显式豁免）。
2. **46.6 判定口径两条不可绕**（来源：task-v194）：单元计数与「是否写 S-unit 编号」**无关**（防不写编号即绕过）；按**声明的交付物粒度**计数，**不按承载文件数折算**——4 篇并入 1 个 .md 仍按 4 单元计 = 打包违规。
3. **单任务专注度 = 两闸 + 一禁止**（来源：task-v194 / Rule 46.1·46.3·46.4）：46.1 单会话单 S-unit（一次 Agent() 派发只领 S-unit 表一行，禁批次追加）；46.3 拆分单一性（普查/方案分离；目标句含「并/且/再」或预估 >15min → 回炉拆分）；46.4 模板引导语显式写「本会话只执行本 S-unit，完成后交回主进程再派下一个」。
4. **翻车判例（第一手会话证据，来源：task-v194 §1）**：8 篇打包给 1 个子代理 → 跑 44 分钟后 LLM 网关 ECONNREFUSED 挂死、几乎无产出；重派仍是 2 个并行子代理各 4 篇（要求「每完成 1 篇立即落检查点」）；更早 9 篇后台批静默失败（无落盘产物、无检查点）。用户在同会话 msg62 裁决：「单子代理一次执行 4 篇错误率太高，违背『单个子代理执行小任务、避免上下文被占满』原则 → 后续派发粒度应缩至每子代理约 1 篇」。另一判例：19 个视频片段打包一个子代理，被判「烂透了」。**该会话在用 task-planner**（计划七文件在位 + attest 锁定）→ 排除「会话没用技能」的解释：规则在位仍会打包。
5. **并行独立性四问（任一 yes = 不同组，必须串行）**（来源：task-v153 / Rule 21.4·68.1）：① 文件集相交？② 资源相争（部署位/分支/同一交付物/同一计划文件锚点/额度窗口）？③ 输入依赖他者产出？④ 验收依赖他者结果？—— 声明制（机器承载）：frontmatter `parallel_groups:` 组名清单 **∧** S-unit 行/派发 prompt 含 `[parallel-group:<组名>]` 标记；**未声明 = 默认串行**。
6. **计划期依赖分析为强制步骤**（来源：task-v153 Rule 68.1）：S-unit 表定稿后、attest 前对全部 S-unit 过四问静态版，结论落 S-unit 表**「前置依赖」列**（无依赖显式填 `-`，多依赖顿号分隔并引用被依赖单元 ID）；该列空白 = 计划无效回炉（与 59.1 硬门同档）。
7. **并行演进史与当前口径**（来源：task-v061 → task-v153 / Rule 21.4 演进链）：09-12 绝对串行铁律（至多 1 活跃子代理，「互不依赖」不构成并行理由；Why=sess_1316c7f8 实证：16 编辑批并行 → 1051 悬空代词/440 断裂句/548 主题跑偏重写/两轮补研子代理零产出需主进程接管 48 次搜索）→ 10-02 废止绝对化串行、改「并行默认允许 + 独立性守门」（错误放大风险由四问②③ + 验收 Read 复核承载）→ 21.4.2 执行期扩组协议（`parallel-uplift` 四步：Decisions Made 登记四问依据 → S-unit 行补组标记 → frontmatter 补声明）。**当前口径 = 并行默认 + 四问守门 + 声明制**，不是「并行禁止」也不是「互不依赖即可并行」。
8. **并行组内纪律三条**（来源：task-v153 Rule 68.3-68.5）：68.3 组内异构（成员 subagent_type 或 model 至少一项不同，整组「继承」同一 Phase Executor 禁止；43.2 最小可承载档优先于异构，禁为追求异构而升/降档）；68.4 组域写隔离（成员只写自己检查点 / findings.md 追加小节 / 自己 scope_files，计划三文件 + Handoff 表由主进程**按组串行回写**）；68.5 唯一 join 原则（每组仅一个汇合点，禁多 barrier）+ 先收窄再 fan-out（禁对未收窄全集并行派发）。
9. **拆分模式库（Rule 21.6，计划期拆分前必读）**（来源：task-v150）：`skills/task-planner/references/split-pattern-library.md`，11 模式 P1-P11，每模式五要素（判据 / 反例 / 消费时机 / 来源锚 / **对低档模型执行明确性的贡献**）。核心要点：P1 任务边界三判据（Right-Sizing：独立可测试 + 评审者可独立否决）；P2 Bite-Sized 步级粒度（一步 2-5 分钟）；P4 No-Placeholder 双明确（禁 TBD/占位符，执行者无需追问即知目标+方案+验收）；P6 派发 Prompt 四要素（Focused / Self-contained / Specific output / Constraints）；P8 简单任务禁 spawn（≤60s 主进程直做）；P10 拆细先于升档；P11 术语语义锚定（关键领域名词先「理解回写」+ 溯源锚，禁凭模型先验赋义）。配套 Rule 21.6.2 边界三判据（独立可验收 / 独立可理解 / 接口清晰，任一不满足回炉重切而非升档）、21.6.3 步内 bite-sized（步骤 ≤4）、21.6.5 伴飞映射表（技能扫描先查表再全池）。
10. **拆细前移到计划期**（来源：task-v056 / Rule 59.4）：计划期预估超目标执行体档位承载能力 → **先拆细再派**，不等失败再兜底；22.3 ② 拆细时**不改模型档位**、每子任务拆细限 1 次（防无限拆分）。
11. **媒体轴 = 制作阶段 × 生产单元**（来源：task-v194 / media Rule 47.1）：单 S-unit = 单生产单元 × 单工序阶段；禁止「整集生成」式粗粒度派发；46.6 媒体生成类 1 单元/派发与之同源。
12. **测试/脚本类 S-unit 的经验拆法**（来源：task-v057）：单步「写 11 用例 selftest」实测 18 分钟 / 1.24M token / 46 次调用（超 step_max_minutes=15，约常规 5 倍）→ 事前按 **≤6 用例/步**再拆，prompt 明写「单用例调试 ≤2 轮，超则记 blockers 交主进程」。
13. **派发粒度 ≠ 产出文件粒度（两条线别混）**（来源：task-v185 Rule 92.2）：产出物尺寸参考线=代码 >300 行 / 文档 >500 行 / 任意单文件 >5K 字符 → 触发拆分评估，沿**内聚边界垂直切**（禁按行数机械横切；≤10 行孤儿文件=过度拆分）。此线管「产出文件多大」，不替代「单次派发装几个单元」。

## 证据锚

| 事实 | 锚 |
|----|----|
| 8 篇/单代理 44min 挂死 → 用户裁决缩至每子代理约 1 篇；19 片段打包判例 | plans/archive/task-v194-subagent-unit-cap/findings.md:29-31 |
| 46.1 定性无数量口径 / 59.1 只管体量不管单元数 / 47.1 定性 | plans/archive/task-v194-subagent-unit-cap/findings.md:36-39 |
| 四结构性缺口（无数量上限表 / 守卫不识自然语言单元量且 fail-open / 自由 prompt 行首编号被排除 / 无会话级累积） | plans/archive/task-v194-subagent-unit-cap/findings.md:41-45 |
| 46.6 五要素草案（内容 1 / 媒体 1 / 机械 ≤5 / 豁免两类 / 判定口径与 S-ID 无关） | plans/archive/task-v194-subagent-unit-cap/findings.md:66 |
| 调研方向粒度：单子代理 1 个方向（Rule 75.8），grep 零命中=调研域无方向数约束 | plans/archive/task-v194-subagent-unit-cap/findings.md:50-52 |
| 拆分模式库 11 模式冻结名与五要素契约 | plans/archive/task-v150-split-skill-integration/knowledge-brief.md:61-65 |
| Rule 21.6 五子条（模式库强制消费 / 边界三判据 / bite-sized / No-Placeholder / 伴飞映射） | plans/archive/task-v150-split-skill-integration/knowledge-brief.md:67-74 |
| P1-P10 对标面与来源技能（writing-plans / dispatching-parallel-agents / sub-agent-protocol 等） | plans/archive/task-v150-split-skill-integration/findings.md:30-40 |
| 拆分判定现状=纯数值（21.1b + 59.1 + analyze-splits.sh），缺定性判据层 | plans/archive/task-v150-split-skill-integration/findings.md:44 |
| 68.1 计划期强制依赖分析四问静态版 + 「前置依赖」列显式填写 | plans/archive/task-v153-parallel-scheduling/design-rule68.md:12 |
| 21.4 声明制原文（未声明默认串行）位置锚 | plans/archive/task-v153-parallel-scheduling/knowledge-brief.md:38 |
| 派发守卫契约三文件绝对路径 + 三返回 key + 步骤枚举 ≤4（本会话被拦 5 次） | plans/archive/task-v153-parallel-scheduling/knowledge-brief.md:49 |
| 并行条款盘点 6 处 + 串行铁律设计（至多 1 活跃子代理，唯一例外=用户显式授权） | plans/archive/task-v061-serial-dispatch/findings.md:33-55 |
| 并行→质量崩塌会话取证（16 编辑批并行→千级机械残迹） | plans/archive/task-v061-serial-dispatch/findings.md:27-31 |
| 用户原话「子代理一次性分配的任务过大…小步快跑」+ 拆分约束全挂 Phase 层（21.1/22.1 同值） | plans/archive/task-v056-fine-grained-dispatch/findings.md:10,20-22 |
| 92.2 尺寸参考线（300 行 / 500 行 / 5K 字符）+ 92.5 垂直切分边界 | plans/archive/task-v185-file-split-discipline/findings.md:89,92 |
| 现行条文：21.1b 三值 / 21.4 铁律与四问 / 46.1-46.6 / 68.1-68.7 | skills/task-dispatch/references/critical-rules-dispatch.md:21,25-32,110-130,173-185 |

## 易错点

1. **只查体量不查单元数**：4 篇文章若每篇都不超 2 文件/100 行/15min，三值门照样放行——这正是 v194 事故复发的原因（先过体量门 ≠ 合规）。
2. **用「不写 S 编号」绕开守卫**：46.6 判定与 S-ID 无关；且 check-dispatch 对自由 prompt 的行首 markdown 编号刻意排除（GR-09 实测 exit 0 不拦），罗列式 prompt 不触发任何门。
3. **规则在位 ≠ 不会翻车**：v194 事故会话正在用 task-planner、attest 锁定，仍然 8 篇打包——把「已加载技能」当免责理由是错的。
4. **并行声明只做一半**：frontmatter 声明了 `parallel_groups` 但 S-unit 行缺 `[parallel-group:X]` 标记 → 守卫按串行槽拦截（v126 实证：`.dispatch-inflight` age<120s 对同批并行组派发直接拦截）；改派前先等锁过期。
5. **组内全继承同一 Executor**：68.3 禁止整组同体；成员执行体列必须逐行具体化。
6. **计数锚漂移**：模式库已扩到 11 模式（P1-P11），正文里「10 模式」「21.6 五子条」等旧措辞会造成文本与实现不一致（v150 修复波实证）。
7. **Handoff 写带后缀的执行体名**：`executor(sonnet-1)` 形式会被判「未登记子代理类型」，须写裸名 + 模型档位移备注（v194/v153 复发判例）。
8. **拆细无限递归**：22.3 ② 每子任务拆细限 1 次；拆完仍失败走 ③ 降档，不要连续拆。
9. **把 Rule 92 产出文件尺寸线当派发粒度线**：一条管产出物多大，一条管单次派发装几件单元，混用会拆错方向。
10. **验收只信 status 不复核单元数**：46.6 机制面=主进程派发前自检 + 验收 Read 复核单元数，跳过复核等于放弃最后一道闸。

## 适用场景

- 计划期拆 S-unit、判断「这次派发该拆多细」时先查本条；
- 决定某批任务能否并行、要不要声明 `parallel_groups`、是否需执行期扩组时先查本条；
- 子代理失败后判断走「拆细」还是「升档」时先查本条；
- 媒体/内容批量生产任务的派发粒度与工序切分（单元 × 阶段）先查本条；
- 遇到「已按规则派发仍翻车」的复盘，先用本条判例三（第 4 条）与缺口四（第 3 条）定位是体量门还是单元数门漏管。
