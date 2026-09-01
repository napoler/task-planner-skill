# Task Plan: [发布任务名称]
<!-- 发布型模板 — 适用于 API 发布/批量部署/数据同步 -->
<!-- 批量发布(≥5 单元)时必须遵守 Rule 18 批量处理质量门控(references/batch-quality-gate.md) + 填写 Batch Report 区块 -->

## Goal
[一句话描述发布目标]

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 发布前二次验证通过 | python3 scripts/verify_content_originality.py --threshold 0.85 | tmp/pre-publish-check.json |
| VC-2 | API 响应码 200 | curl -I {publish-endpoint} | tmp/api-response.log |
| VC-3 | 幂等性检查 | POST 两次结果一致 | tmp/idempotency-check.json |
| VC-4 | 回滚策略就绪 | rollback script exists | scripts/rollback.sh |
| VC-5 | 发布后验证通过 | GET {resource-id} | tmp/post-publish-check.json |
| VC-6 | 无数据丢失 | diff 原数据与新数据 | tmp/data-diff.txt |
| VC-7 | 批量前置 3 问已通过(Rule 18,批量 ≥5 单元必填) | Batch Report `pre_check` = Q1:否/Q2:有/Q3:能 | task_plan.md Batch Report 区块 |
| VC-8 | 批量双采样抽检通过(Rule 18.2,批量 ≥10 单元必填) | 运行前抽 2 + 运行后抽 10% 全 PASS | Batch Report `sampled_pass`/`sampled_fail` |
| VC-9 | 批量失败率 ≤5%(Rule 18.3,批量必填) | failure_rate ≤5% | Batch Report `failure_rate` |

**终验规则**：
- 全部 VC 通过 → COMPLETE
- VC 通过但有已知风险 → PARTIAL（记录风险 + 回滚步骤）
- ≥1 VC 失败 → BLOCKED（执行回滚，报告用户）
- **批量任务:Batch Report 八字段缺一 → 视为 VC-7/8/9 未通过,Phase 禁止 complete（Rule 18.6）**

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 发布配置 | config/publish-* | 其他配置目录 |
| 临时文件 | tmp/publish-* | 根目录临时文件 |
| 日志文件 | logs/publish-* | 其他日志目录 |
| 回滚脚本 | scripts/rollback.sh | 未授权脚本 |

## Phases

### Phase 1: 发布前验证
- [ ] 二次内容原创性验证
- [ ] API 端点可用性检查
- [ ] 权限/token 有效性验证
- [ ] 回滚脚本就绪确认
- **Status:** pending

### Phase 2: 执行发布
- [ ] 执行幂等性预检
- [ ] 批量 ≥5 单元:先跑前置 3 问(Rule 18),判定写入 Batch Report `pre_check`
- [ ] 批量 ≥10 单元:运行前抽 2 单元 ground truth(Rule 18.2),FAIL → 整批熔断
- [ ] 分批发布(每批失败率 >5% → STOP,Rule 18.3)
- [ ] 批量生成型内容:跑跨单元一致性检查(标题去重/克隆检测,Rule 18.4)
- [ ] 记录每批次响应
- **Status:** pending

### Phase 3: 发布后验证
- [ ] GET 资源验证
- [ ] 数据完整性检查
- [ ] 监控指标确认
- **Status:** pending

### Phase 4: 清理与交付
- [ ] 清理临时文件
- [ ] 生成发布报告
- [ ] 更新发布日志
- **Status:** pending

## 🚨 回滚策略
**触发条件**：≥1 VC 失败 / 批量 failure_rate >20%（Rule 18.3 自动熔断）
**执行步骤**：
1. 停止新发布
2. 执行 `bash scripts/rollback.sh --backup {backup-id}`
3. 验证回滚结果
4. 报告用户 + 记录到 progress.md
5. 批量任务:填写 Batch Report `rollback_point` + 失败清单

## 📦 Batch Report（批量发布必填 — Rule 18.6）
<!-- 批量 ≥5 单元时必填;完整模板见 templates/batch_report.md -->
| 字段 | 值 |
|------|-----|
| `total` |  |
| `success` |  |
| `failed` |  |
| `failure_rate` |  |
| `sampled_pass` |  |
| `sampled_fail` |  |
| `pre_check` |  |
| `rollback_point` |  |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |
