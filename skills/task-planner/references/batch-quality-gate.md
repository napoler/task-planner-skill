# 批量处理质量门控 — Rule 18 详解（v2.3）

> **核心原则**：批量操作（脚本/并发/多文件处理）**禁止以牺牲内容质量或准确性为代价**。
> 批量脚本撰写之前，必须先做质量影响评估；明显降低质量 → 必须停下慎重决策，禁止静默执行。
> 与 Rule 17（成本控制）对仗：Rule 17 节流 opus 数量（防过度消耗），Rule 18 节流批量质量损失（防质量不足）。

---

## 一、批量前置 3 问（撰写批量脚本前必须回答）

任何批量操作（≥5 单元的脚本/并发/多文件处理）动工前，主进程必须逐条回答：

| # | 问题 | 判定 | 不通过时的强制动作 |
|---|------|------|------------------|
| **Q1** | 该操作是否依赖"每单元独立判断"？ | 生成型/判断型操作（写作/翻译/修复决策/内容改写）= 是；纯机械 IO（复制/改名/格式转换）= 否 | **是 → 禁止纯脚本批量**。改用子代理逐单元处理（code-assistant/executor 每单元独立判断），或人审抽检 + 小批量试点 |
| **Q2** | 批量后有没有客观验收手段？ | 有可执行验收命令（schema 校验/diff/测试/一致性检查）= 有；只能"肉眼看"= 无 | **无 → 先建验收再批量**。验收手段写入 VC 后才允许动工 |
| **Q3** | 最坏情况能否回滚？ | 有 backup/git tag/幂等 down 脚本 = 能；无 = 不能 | **不能 → 缩小批次规模**（先 3-5 单元试点），验证后逐步放大；全程保留回滚点 |

**三问的判定结果写入 task_plan.md「📦 Batch Report」区块的 `pre_check` 字段**（见 templates/batch_report.md）。任一问不通过且未采取对应强制动作 → 禁止进入批量实施。

**为什么**：历史教训显示，批量质量损失几乎都源于"跳过这三问"——`--skip-quality-gate` 一键关闭门控（clife/778 六项 blocker）、无验收的批量字段修复、不可回滚的并发覆写（session.json 竞争实锤）。

---

## 二、Rule 18 十一条款（与 critical-rules.md Rule 18 同步）

| # | 条款 | 门控机制 | 违反信号 |
|---|------|---------|---------|
| **18.1** | **门控 flag 禁止一刀切跳过**：批量禁止用单一布尔 flag（如 `--skip-quality-gate`）绕过全部门控；允许"分项跳过 + 理由必填"（如 `--skip-cover-check=reason:已人工抽检5篇`）；跳过单元 ≥总数 10% → AskUserQuestion 重审 | 脚本参数审查 | 批量命令中出现无理由的全局 skip flag |
| **18.2** | **批次前后双采样**：批量 ≥10 单元时，**运行前随机抽 2 单元完整跑**（ground truth），**运行后随机抽 10% 单元跑 verify**；任一抽检失败 → 整批熔断，禁止部分回滚 | 抽检脚本（sample-before / sample-after） | 无抽检记录直接全量跑 |
| **18.3** | **失败隔离硬约束**：单单元失败不阻塞其他单元继续，但必须累计 `failure_rate`；>5% → STOP 报告用户等决策；>20% → 自动熔断 + 回滚到最近 backup | failure_rate 计数器 | 失败被 `except: pass` 吞掉 / 失败率超阈继续跑 |
| **18.4** | **跨单元一致性闸门**：批量 ≥5 单元且属生成型操作（写作/翻译/格式化），必须跑跨单元一致性检查（标题去重/模板克隆检测/数值范围 sanity）；命中 ≥1 → STOP 报告重复模式 | 一致性检查脚本 | N 篇输出高度雷同（模板化失真）未被察觉 |
| **18.5** | **并发覆写隔离**：批量写共享状态文件（session.json/global index）必须按"按单元分文件"或"加文件锁"二选一；禁止多并发 worker 直写同一 JSON | 写入规范 | 多 worker 并发写同一状态文件 |
| **18.6** | **批次元数据必填**：每次批量在 task_plan.md 追加「📦 Batch Report」区块，含 `total/success/failed/failure_rate/sampled_pass/sampled_fail/pre_check/rollback_point` 八字段；缺项 → 视为 Phase 未完成 | 模板强制（templates/batch_report.md） | 批量完成但无 Batch Report |
> 零单元逃生（2026-09-16 task-v074 P9）：正文含 "Batch Report" 但任务无批量生成单元（如纯验证型）时，Batch Report 段内写一行 `不适用（无批量生成单元）` 即跳过 8 字段校验（check-complete.sh 门控），其余情况仍 fail-closed。
| **18.7** | **fan-out 必含聚合 Phase**：`chain_mode: fan-out` 时 task_plan.md 必须含一个聚合 Phase（`### Phase N: Aggregator`），负责收集子任务结果 + 跑 18.2 抽检 + 写 Batch Report；无此 Phase → plan-writer 输出校验失败 | plan-writer 产出校验 | fan-out plan 无聚合 Phase |
| **18.8** | **批量质量回看强制**：批量任务完成后 `failure_rate > 10%` → 触发 `Skill("meta-corrector")` 结构化复盘 → 经验写入 memory（`batch-quality-YYYYMMDD.md`，§八闭环） | 记忆沉淀 | 批量失败后无复盘直接进下一任务 |
| **18.9** | **试点先行硬门（task-v083）**：批量启动前必须先对 1 个代表性样本完成单件「处理→端到端验证」试点且通过（证据落 progress.md）；试点未通过或未做 → 禁止批量；「十足把握」最低构成 = 试点通过 + 首批小步（≤5 单元）+ 批间抽检（18.2）+ 可回滚/可枚举已写对象 | 试点证据检查（progress.md） | 无试点记录直接全量跑 |
| **18.10** | **单件失败禁批量（投毒红线，task-v083）**：单件失败且根因未定位/未修复复验时启动或继续批量 = P0 投毒级违规；立即中止 + 盘点已写对象 + 逐对象回滚或修复 + Rule 31 归因 | 批量启动前置检查 | 单件 FAIL 后批量照跑 |
| **18.11** | **宁慢勿错（task-v083）**：「为了快/省时间/任务急」一律无效理由；宁单件串行慢速，不赌未验证批量；用户 2026-09-18 明示接受降速换正确性 | 理由审查 | 以速度为由跳过试点/抽检 |

---

## 三、Batch Report 格式（eight-field standard）

批量任务完成后，task_plan.md 中「📦 Batch Report」区块必须包含以下八字段（模板见 `templates/batch_report.md`）：

```markdown
| 字段 | 值 |
|------|-----|
| `total` | 批量单元总数（如 20） |
| `success` | 成功数（如 18） |
| `failed` | 失败数（如 2） |
| `failure_rate` | 失败率（failed/total，如 10%） |
| `sampled_pass` | 运行后抽检通过数/抽检数（如 2/2） |
| `sampled_fail` | 运行前 ground truth 失败数（如 0） |
| `pre_check` | 前置 3 问判定（Q1:否/Q2:有/Q3:能） |
| `rollback_point` | 回滚点（git tag / backup 路径） |
```

**字段校验规则**：
- `failure_rate` >5% → 该 Phase 禁止标记 complete，STOP 报告
- `sampled_fail` >0 → 整批视为未验证，禁止交付
- `pre_check` 任一问未答 → plan-writer 产出校验失败
- `rollback_point` 为空 → 禁止批量（违反 Q3）

---

## 四、抽检脚本示例（18.2 参考）

```bash
#!/bin/bash
# sample-check.sh — 批次前后双采样（18.2）
# 用法: bash sample-check.sh <unit-list.txt> <verify-cmd> <phase=before|after>

UNITS="$1"; VERIFY_CMD="$2"; PHASE="$3"
TOTAL=$(wc -l < "$UNITS")

if [ "$PHASE" = "before" ]; then
  # 运行前:随机抽 2 单元完整跑(ground truth)
  SAMPLE=2
else
  # 运行后:随机抽 10% 单元跑 verify(至少 1)
  SAMPLE=$(( TOTAL / 10 )); [ "$SAMPLE" -lt 1 ] && SAMPLE=1
fi

PASS=0; FAIL=0
shuf -n "$SAMPLE" "$UNITS" | while read -r unit; do
  if bash -c "$VERIFY_CMD $unit"; then
    echo "SAMPLE_PASS: $unit"
  else
    echo "SAMPLE_FAIL: $unit"; exit 1
  fi
done

# 任一抽检失败 → 整批熔断(禁止部分回滚)
```

**抽检失败处理**：整批熔断 = 停止批量的后续单元 + 已跑单元回滚到 `rollback_point` + 报告用户。禁止"抽检失败但继续跑完剩下单元"。

---

## 五、与既有规则/机制的关系

| 对象 | 关系 |
|------|------|
| Rule 5（Phase 完成后更新） | 18.6 Batch Report 缺项 = Phase 未完成，两者协同 |
| Rule 9（错误提前暴露） | 18.3 failure_rate >5% STOP = Rule 9 的批量特化 |
| Rule 11/15（漂移检测） | 漂移检测比对 Goal/VC；18.3/18.6 补上"批量累积指标"这一盲区 |
| Rule 17（成本控制） | 对仗关系：17 节流 opus 数量，18 节流质量损失；批量子代理派发同时受两者约束 |
| publish-type.md 模板 | 唯一提到批量的 variant，其批量 VC 由本文件 §三 八字段支撑 |
| fan-out chain_mode | 18.7 把"结构标记"升级为"质量责任"（聚合 Phase 强制） |
| article-batch-publisher 等 agent | 本文件是规则层；agent 层 flag 改造（分项跳过）为 follow-up，待用户授权 |
| Rule 31（错误学习闭环） | 18.10 投毒红线处置链直接消费 31.2（根因定位）/31.4（沉淀）；单件失败先归因再谈批量，禁直接重跑 |

---

## 六、历史教训佐证（memory）

| 教训 | 对应条款 |
|------|---------|
| clife/778 六项 quality-gate blocker（单篇微改累积批量损失） | 18.2（无 ground truth 抽检） |
| session.json 并发覆写竞争实锤 | 18.5 |
| 重复发布处置协议首撞（782→783 canonical） | 18.3（失败隔离 + 回滚点） |
| anypowerrun/1788100098 16 条 gate cookbook 反批量失真 | 18.4（模板克隆检测） |
| unfoldtech/1788088607 subagent 全断后主进程兜底 | 18.7（聚合 Phase 兜底） |
| 用户 2026-09-18 投毒训诫（单件未验证即批量） | 18.9/18.10/18.11（试点先行 + 投毒红线 + 宁慢勿错） |

---

## 七、关联文档

| 文档 | 用途 |
|------|------|
| `references/critical-rules.md` | Rule 18 十一条款（核心载体，隶属 Rules 1-36） |
| `templates/batch_report.md` | Batch Report 区块模板（双仓） |
| `templates/variant/publish-type.md` | 批量发布模板（含批量专属 VC） |
| `references/cost-control.md` | Rule 17 成本控制（对仗规则） |
| `agents/plan-writer.md` | 18.7 聚合 Phase 产出校验 + 批量关键词匹配 |

---

## 八、试点先行硬门详解（18.9-18.11，task-v083）

> 用户训诫原文（2026-09-18）：「单个处理都做不好，还恶意批量处理，和投毒有什么区别。记住在没有十足把握之前不要轻易尝试批量处理。我接受速度慢一点，但不能接受批量处理出现问题。」

### 批量定义（18.9 适用范围）
对 **≥2 个同构对象**执行**同一写操作**即为批量——含脚本 for 循环、循环派发子代理、批量 API 调用、批量文件写入。纯读操作（批量 grep/批量 Read）不在此门内（仍受 Rule 13 隔离约束）。

### 试点流程（批量启动前置，四步）
1. **选样**：从待处理全集选 1 个代表性样本（优先中等难度/含边界特征，禁挑最容易的）
2. **单件处理**：按正式流程完整处理该样本（禁用"先随便跑跑"的简化版逻辑）
3. **端到端验证**：用与批量验收相同的客观标准验证（18.2 ground truth 同款），禁"看着没问题"
4. **证据落盘**：命令+输出结论写入 progress.md；试点未通过或未做 → 禁止启动批量

### 与既有门控的分层关系（防误读）
| 门 | 时机 | 适用 |
|----|------|------|
| **18.9 试点先行** | 批量**启动前** | 任何批量（≥2 单元）——单件都做不好就没有批量的资格 |
| §一 Q3「3-5 单元试点」 | 批量**启动前**（仅不可回滚时） | Q3 失败的补救动作，是 18.9 的子集场景 |
| **18.2 双采样** | 批量**运行前/后** | ≥10 单元——批中抽检，不豁免 18.9 前置 |
| **18.3 熔断** | 批量**运行中** | failure_rate 超阈止损 |

### 投毒红线处置（18.10 触发后）
立即中止在跑批量 → 枚举盘点已写对象（`rollback_point` 起增量清单）→ 逐对象回滚或修复 → Rule 31.2 归因（禁直接重跑）→ notepad 沉淀后重来（含 18.9 试点）。

### 宁慢勿错（18.11）
「为了快/省时间/任务急」在 18.9/18.10 语境下自动无效。用户明示（2026-09-18）：接受速度慢，不接受批量出错。单件串行慢速完成 > 未验证批量赌运气。
