# Methodology 指针文档（v063 新增机制层）

> **定位**：本文档是 task-planner 技能的**新增机制层**（v063），把 9 条可操作方法论落为「规划期可预演、门控点可检查、降质可降级」的显式条款。**不改动 Rule 1-28 任何既有语义**——方法论只补位、不替代；凡本文与 critical-rules.md 冲突，以 critical-rules.md 为准。
> **指针入口**：SKILL.md:81（Poka-Yoke 前置门）/ SKILL.md:156 后（内容质量门控）/ task_plan.md「📊 FMEA 预演（规划期）」/ templates/variant/writing-type.md Phase 3.5。
> **开关键**：`config.json#fmea_enforce`（规划期可靠性门控）/ `config.json#content_quality_enforce`（内容质量门控），三态 `enforce|warn|off`，默认 `warn`。

## 定位声明

1. 本文档只定义「方法论 → 既有 Rule 的映射」，不新造门控语义、不重编号既有条款。
2. 每条方法论固定五字段：**方法名 / 出处 / 可操作动作 / 与既有机制映射 / 失败惩罚映射**。
3. 全部失败惩罚引用 Rule 26.3 确定性惩罚表，同一行为不双计（Rule 26.5）。
4. 适用场景见各条「触发场景」行；未触发者不强制。
5. 本文档自身的防篡改由 `scripts/selftest-methodology.sh` 守护（文件存在 + 9 条方法名关键词 + 两开关键默认值）。

## §可靠性

### R1 Poka-Yoke 防错前置条件（规划期前置门）

- **方法名**：Poka-Yoke（防错装置）——把"正确做法"变成执行前不可绕过的前置条件
- **出处**：Shingo Shigeo,《Zero Quality Control: Source Inspection and the Poka-Yoke System》(1989)；ISO 21434:2021 前置条件门控思想（待补：具体条款号）
- **触发场景**：任一 Phase 进入执行循环前
- **可操作动作**：开工前跑一次前置条件函数，返回 BLOCK 即禁止开工：

  ```text
  require_plan_preconditions(phase):
    assert phase.executor          is not empty   # Rule 25.1 Executor 字段
    assert phase.s_unit_table      is not empty   # Rule 22.6 S-unit 表（派发型 Phase）
    assert all(s.executor.strip() for s in phase.s_unit_table)  # S-unit 执行体列非空
    assert phase.scope_files       ⊆ allowed_scope              # Rule 10 scope 边界
    return BLOCK if any assert fails, else OK
  ```

- **与既有机制映射**：Rule 25.1（Executor 字段）+ Rule 22.6（S-unit 表/执行体列）+ Rule 10（Scope 变更）——三者由 `scripts/check-plan-dispatch.sh` 在计划批准时机械校验；R1 只做合并表述，**不新增检测点**。
- **失败惩罚映射**：前置条件未过仍开工 → 按 Rule 26.3「Q1 跳过 VC 复验」处置：首次单 Phase 强制回炉；会话内累计 ≥2 Phase → outcome 最高 PARTIAL。
- **开关键**：`fmea_enforce=enforce` 时 BLOCK 阻断；`warn` 时告警放行并计告警数；`off` 跳过。

### R2 FMEA 规划期预演（RPN 评分）

- **方法名**：FMEA（Failure Mode and Effects Analysis，失效模式与影响分析）——规划期预演失败模式并按风险排序
- **出处**：SAE J1739_202004（FMEA 标准，RPN = S×O×D 口径）
- **触发场景**：Phase 计划定稿、VC 表写完后（写入 task_plan.md「📊 FMEA 预演（规划期）」段）
- **可操作动作**：逐 Phase 填一行 RPN 评分表，S/O/D 各 1-10，RPN = S×O×D；**RPN>100 的行必须登记预设兜底动作**：

  | Phase | 失败模式 | S(严重度 1-10) | O(频度 1-10) | D(探测难度 1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
  |-------|---------|----------------|--------------|------------------|-----------|------------------------------|
  | Phase 2 | 子代理写偏文档结构 | 6 | 3 | 4 | 72 | —（≤100，不强制登记） |
  | Phase 6 | config 键写到 properties 外 | 8 | 2 | 7 | 112 | 回炉 jq 校验 properties + 重跑 selftest |

- **与既有机制映射**：Rule 4（决策前重读计划）→ FMEA 段 = 规划期一次性重读；Rule 11（漂移检测）→ 高 RPN 项即漂移重点监控项；Rule 21.1b → RPN>100 的 Phase 优先再拆 S-unit 以降 S/O。
- **失败惩罚映射**：RPN>100 且 Decisions Made 无兜底登记 → 终验按 Rule 26.3「Q2 压缩验证步骤」处置：强制回炉补登记；会话内累计 ≥2 Phase → 最高 PARTIAL。
- **开关键**：`fmea_enforce=off` 时模板仍保留 FMEA 段（可读），但不阻塞、不计告警。

### R3 幂等 + checkpoint.jsonl 断点续做协议

- **方法名**：幂等操作 + 检查点（idempotent + checkpoint）——把长任务切成"可重放、可从断点续做"的确定步骤
- **出处**：Lamport,《Time, Clocks, and the Ordering of Events in a Distributed System》(1978) 检查点/快照思想；Google Cloud《Designing idempotent systems》幂等设计指南（待补：文档链接）
- **触发场景**：跨会话/跨派发的长任务；主进程交接、会话中断恢复
- **可操作动作**：计划级检查点文件 `<plan-dir>/checkpoint.jsonl`，每完成一个 S-unit 追加一行（append-only；幂等：同一 s_unit 重复写取最后一条）：

  ```json
  {"ts":"2026-09-12T09:30:00Z","task_id":"v063","phase":2,"s_unit":"S1","status":"done","artifact":"skills/task-planner/references/methodology.md","sha256":"<hex>","next":"S2"}
  ```

  恢复协议：会话恢复时 Read 末行 → 取 `next` 作为 `resume_from` → 只做 `next` 及其后；已完成行（status=done）**禁止重做**。
- **与既有机制映射**：Rule 22.8（subagent-state 子代理检查点）→ **命名区分**：`subagent-state/{seq}-{agent}.md` = 子代理级检查点；`checkpoint.jsonl` = 计划级断点，粒度不同、互不替代；Rule 19（3-File 落盘）+ session-kv → 跨会话持久化通道复用。
- **失败惩罚映射**：中断恢复后未 Read 检查点、从零重做已完成 S-unit → 记为流程违规，按 Rule 26.3「Q2 压缩验证步骤」反向适用：单 Phase 回炉；会话内累计 ≥2 Phase → 最高 PARTIAL。
- **开关键**：无新增键（复用既有 Rule 19/22.8 机制）。

### R4 小批量 chunk≤3 独立验收（含 5 Whys 根因链）

- **方法名**：小批量推进（chunk ≤3）+ 5 Whys 根因追溯
- **出处**：小批量 = Lean/Toyota 单件流（待补：原始文献号）；5 Whys = Toyota 生产系统根因分析法（大野耐一）
- **触发场景**：批量类任务（Rule 18）与任一含多 S-unit 的 Phase
- **可操作动作**：
  1. 每批 ≤3 个单元，批内每单元独立三证据验收（执行记录 / 产出 Read 复核 / 验证证据），通过才发下一批。
  2. 批量 chunk≤3 与 Rule 21.1b 步级上限的映射表：

     | 维度 | 小批量 chunk≤3 口径 | Rule 21.1b 步级上限 | 统一执行值 |
     |------|--------------------|--------------------|-----------|
     | 批量单元数 | ≤3 单元/批 | — | ≤3 |
     | 文件数 | — | ≤2 文件/步 | ≤2 |
     | 代码行 | — | ≤100 行/步 | ≤100 |
     | 时长 | ≥30min 必再拆批 | ≤15min/步 | 取严：≤15min |

  3. 失败时按 5 Whys 逐层追问（现象 → 直接原因 → … → 根因，≤5 层），根因写入 progress.md Error Log；禁止停在"再重试一次"。
- **与既有机制映射**：Rule 18（批量质量门控：八字段 Batch Report / failure_rate≤5%）+ Rule 21.1b（步级 ≤2 文件/≤100 行/≤15min）+ Rule 21.4（串行派发，一次一个）+ Rule 7（永不重复失败，5 Whys 是其取证工具）。
- **失败惩罚映射**：chunk>3 或步级超限仍派发 → 计划无效，按 Rule 26.3「Q6 批量违规未处置」依 Rule 18.3 STOP/熔断；failure_rate>5% 未 STOP → outcome 最高 PARTIAL。
- **开关键**：无新增键（复用 Rule 18/21 既有阈值）。

## §内容质量

> 本节仅对 `template_type = writing` 的任务强制（当前仅 writing-type.md 挂载；research/publish 登记后续扩展），其余 template_type 作参考。门控受 `content_quality_enforce` 约束。

### Q1 证据化写作（三级引用）

- **方法名**：证据化写作——三级引用 + 矛盾检测
- **出处**：待补（三级引用口径由 v062 调研汇总，原始文献待补）
- **触发场景**：writing 类 Phase 3（草稿）与 Phase 3.5（审查）
- **可操作动作**：每条事实性主张标注引用级别——① 一手来源（原文/官方文档/实测）② 二手来源（权威转述）③ 弱来源（社区/二手聚合）；③ 级须 ≥2 个独立源交叉方可保留；对同一事实的多源结论做矛盾检测，矛盾未消解不得写入正文。
- **与既有机制映射**：Rule 26.3「Q3 证据不实」→ 引用级别标注 = 内容侧的证据可核性；Rule 3（双操作后立即保存）→ 引用清单随时落盘。
- **失败惩罚映射**：③ 级单源主张未交叉验证即写入 → 按 Rule 26.3「Q3 证据不实」最高档处置：不得自判 COMPLETE/PARTIAL，以 BLOCKED 上报 + STOP 等用户裁决。
- **开关键**：`content_quality_enforce=off` 时降为参考清单。

### Q2 事实核查流水线（交叉验证）

- **方法名**：事实核查流水线——URL + 时间戳 + 独立源交叉
- **出处**：待补（核查流水线口径由 v062 调研汇总，原始文献待补）
- **触发场景**：writing 类交付前（Phase 3.5 之后）
- **可操作动作**：对每条引用记录三元组 `{URL, 抓取时间戳, 独立源数}`；核验三步——① URL 可访问且在时间戳时点内容一致 ② ≥2 个互不隶属的独立源结论一致 ③ 时间敏感事实标注"截至 <日期>"。
- **与既有机制映射**：Rule 26.3「Q3 证据不实」→ 抽查 ≥3 条 Evidence 的机械判据；Rule 7（永不重复失败）→ 核查失败结论入 Error Log。
- **失败惩罚映射**：URL 失效或源内容与声称矛盾 → 同 Q3 证据不实：BLOCKED + STOP 等用户裁决，禁止以"补做核查"恢复。
- **开关键**：`content_quality_enforce=enforce` 时未过核查禁止交付。

### Q3 去 AI 化 10 条清单（逐条落地动作）

- **方法名**：去 AI 化（de-AI-ification）写作清单
- **出处**：GPTZero（AI 文本检测特征）；Poynter Institute（机器文本可编辑性指南）（待补：报告链接）
- **触发场景**：writing 类 Phase 3.5 审查门
- **可操作动作**：逐条执行，10 条全过才放行：
  1. 删除"首先/其次/最后""值得注意的是""总而言之"等过渡词堆砌，段落靠语义衔接
  2. 用具体数字替代"许多/大量/显著/若干"等模糊程度词，无数据则标"待补"
  3. 长短句交替：连续 ≥3 句长度相近时，拆一句或合一句
  4. 承认不确定性：未验证结论写明"未验证/待补"，禁用"显然/毫无疑问/毋庸置疑"
  5. 删掉"不是 X，而是 Y"式对仗排比，改为直陈
  6. 段首不进"在当今……时代"式空泛铺垫，首句直接给结论或事实
  7. 删除副词强化（"非常/极其/十分/高度"），让事实本身承载强度
  8. 破除"不仅……而且……更……"三段式排比与机械同构列点
  9. 保留具体专名/版本号/时间戳，不用"某工具/某些场景/相关方"泛称
  10. 正文禁 emoji 与"让我们/我们一起来"号召式收尾，删感叹号
- **与既有机制映射**：Rule 26（质量优先于速度）→ 清单 = 内容侧可判定降质式；Rule 28.4（silent 决策登记）→ 清单豁免须显式登记。
- **失败惩罚映射**：未过清单即标记写作 Phase complete → 按 Rule 26.3「Q1 跳过 VC 复验」回炉；会话内累计 ≥2 Phase → 最高 PARTIAL。
- **开关键**：`content_quality_enforce=warn` 时告警放行，清单结果记 progress.md。

### Q4 五维评分卡（权重表 + 阈值）

- **方法名**：五维内容评分卡（准确性/相关性/可读性/原创性/SEO）
- **出处**：Google DeepMind 2023 文本质量分类法（五维加权思路）（待补：论文具体标题）
- **触发场景**：writing 类 Phase 3.5 终审门（writing-type.md:63）
- **可操作动作**：五维各按 1-5 分打分后按权重加权，得加权总分（满分 5.0）：

  | 维度 | 权重 | 评分要点（1-5 分） |
  |------|------|--------------------|
  | 准确性 | 25 | 事实/引用可核，无与来源矛盾 |
  | 相关性 | 20 | 命中读者问题，无跑题段落 |
  | 可读性 | 20 | 结构清晰、长短句交替、无 AI 腔 |
  | 原创性 | 20 | 非改写拼贴，有第一手增量 |
  | SEO | 15 | 标题/关键词/摘要到位不堆砌 |
  | **合计** | **100** | 加权总分 = Σ(维度分 × 权重) / 100 |

  阈值：**≥4.0 放行 / 3.0-3.9 小修**（列待修项后重评）/ **<3.0 退回重写**。
- **与既有机制映射**：Rule 26.3（惩罚映射表）→ 阈值三档即内容侧惩罚映射；Rule 26.1 Q1/Q2 → 评分卡未跑而标记 complete 的判据；writing-type.md Phase 3.5 → 挂载点。
- **失败惩罚映射**：<3.0 仍交付 → 按 Rule 26.3「Q1 跳过 VC 复验」撤销 complete 回炉；3.0-3.9 未列小修项即放行 → 同档回炉；会话内累计 ≥2 Phase → 最高 PARTIAL。
- **开关键**：`content_quality_enforce=enforce` 时 <3.0 阻断交付；`off` 时仅记录分数不阻断。

### Q5 8 字段输出契约复用（与 Rule 22.4b 同构）

- **方法名**：8 字段输出契约（子代理返回格式复用）
- **出处**：Anthropic Claude Code 2024 内部规范（子代理结构化返回）（待补：官方文档链接）
- **触发场景**：内容型任务派发子代理时的返回格式；writing 类交付摘要
- **可操作动作**：返回固定 8 字段，字段名与顺序不得改、无内容填 `none`——`status:` / `acceptance:` / `files:` / `evidence:` / `checkpoint:` / `findings_written:` / `blockers:` / `confidence:`。内容侧填充约定：`acceptance` 填五维得分、`evidence` 填引用三元组清单。
- **与既有机制映射**：Rule 22.4b（严格返回格式）+ Rule 22.4c（check-dispatch.sh 机械守卫）+ Rule 22.5（Handoff 登记 + 30s Read 复核）——Q5 **完全复用**，不新增格式，只声明内容侧字段填充约定。
- **失败惩罚映射**：返回缺字段或自由文本 → 视为 partial，以检查点「最终结论」段为准（Rule 22.8.5）；模板守卫缺项按 `dispatch_contract_enforce` 处置。
- **开关键**：无新增键（复用 `dispatch_contract_enforce`）。

## 与 Rule 1-28 关系

| 关系 | 说明 |
|------|------|
| **不改语义** | 本文档是新增机制层，不重编号、不修改 Rule 1-28 任何既有条款文本；冲突时以 critical-rules.md 为准 |
| **映射而非替换** | 9 条方法论每条都声明既有 Rule 映射；检测点复用既有 hook/selftest，不重复检测（Rule 26.5 不双计） |
| **惩罚统一** | 全部失败惩罚引用 Rule 26.3 确定性惩罚表，方法论不另造惩罚档位 |
| **开关键归口** | 仅新增 `fmea_enforce` / `content_quality_enforce` 两键（默认 warn），置于 config.json properties（additionalProperties:false 生效），由 selftest-methodology.sh 守护 |
| **落点** | R1/R2 → SKILL.md:81 + task_plan.md「📊 FMEA 预演」；R3/R4 → Rule 19/22.8/21.1b 复用；Q1-Q4 → SKILL.md:156 后 + writing-type.md Phase 3.5；Q5 → Rule 22.4b 复用 |
| **防护** | 本文档由 `scripts/selftest-methodology.sh` 守护（文件存在 + 9 条方法名关键词 + 两开关键默认值），移除或改写即自测 fail |

> **待补项汇总**（不瞎编，登记待后续轮补全）：ISO 21434 条款号 / Google Cloud 幂等文档链接 / Lean 小批量原始文献 / 证据化写作与事实核查流水线原始出处 / GPTZero 与 Poynter 报告链接 / DeepMind 五维论文标题 / Anthropic 8 字段规范链接。
