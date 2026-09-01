<!-- batch_report.md — 批次报告区块模板（v2.2 Rule 18.6 配套） -->
<!-- 使用方式:批量任务(chain_mode: fan-out 或 批量操作 ≥5 单元)时,复制本区块到 task_plan.md 末尾并填写八字段 -->
<!-- 字段校验:failure_rate >5% → Phase 禁止 complete;sampled_fail >0 → 整批未验证;pre_check 缺项 → plan-writer 校验失败 -->
<!-- 详见:references/batch-quality-gate.md §三/§四 -->

## 📦 Batch Report（批量处理质量门控 — Rule 18.6 必填）

<!-- 批量任务(chain_mode: fan-out / 批量 ≥5 单元)时此区块必填;纯单次任务可删除整个区块 -->

### 前置 3 问（批量动工前必须回答 — Rule 18 前置评估）

| # | 问题 | 判定 | 不通过的强制动作 |
|---|------|------|----------------|
| Q1 | 是否依赖每单元独立判断？ | 是 / 否 | 是 → 禁纯脚本批量,改子代理逐单元 |
| Q2 | 有无客观验收手段？ | 有 / 无 | 无 → 先建验收(写入 VC)再批量 |
| Q3 | 最坏情况能否回滚？ | 能 / 不能 | 不能 → 缩小批次(3-5 单元)试点 |

> **任一问不通过且未采取强制动作 → 禁止进入批量实施。**

### 批次八字段（Rule 18.6 强制）

| 字段 | 值 |
|------|-----|
| `total` | [批量单元总数] |
| `success` | [成功数] |
| `failed` | [失败数] |
| `failure_rate` | [failed/total 百分比]（>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | [运行后抽检通过数/抽检数]（Rule 18.2:抽 10%） |
| `sampled_fail` | [运行前 ground truth 失败数]（Rule 18.2:抽 2,>0 → 整批熔断） |
| `pre_check` | [Q1:否/Q2:有/Q3:能 格式] |
| `rollback_point` | [git tag / backup 路径]（为空 → 禁止批量） |

### 抽检记录（Rule 18.2）

| 阶段 | 抽检单元 | 验证命令 | 结果 |
|------|---------|---------|------|
| before(ground truth) | [单元 id ×2] | [命令] | PASS / FAIL |
| after(10% 抽检) | [单元 id] | [命令] | PASS / FAIL |

### 失败清单（Rule 18.3,如有）

| 单元 | 失败原因 | 处置(重试/隔离/回滚) |
|------|---------|---------------------|
|      |         |                     |

### 一致性检查（Rule 18.4,生成型批量必填）

| 检查项 | 命令 | 结果 |
|--------|------|------|
| 标题去重 | [命令] | 通过 / 命中 N 个重复 |
| 模板克隆检测 | [命令] | 通过 / 命中 N 个高相似 |
| 数值范围 sanity | [命令] | 通过 / 异常 N 处 |

### 复盘触发（Rule 18.8）

- [ ] `failure_rate > 10%` → 已触发 `Skill("meta-corrector")` 复盘
- [ ] 复盘经验已写入 `~/.zcode/cli/memories/.../batch-quality-YYYYMMDD.md`
- n/a（failure_rate ≤10% 时勾选）
