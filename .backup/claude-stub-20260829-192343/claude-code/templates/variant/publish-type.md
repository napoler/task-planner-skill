# Task Plan: [发布任务名称]
<!-- 发布型模板 — 适用于 API 发布/批量部署/数据同步 -->

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

**终验规则**：
- 全部 VC 通过 → COMPLETE
- VC 通过但有已知风险 → PARTIAL（记录风险 + 回滚步骤）
- ≥1 VC 失败 → BLOCKED（执行回滚，报告用户）

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
- [ ] 分批发布（如适用）
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
**触发条件**：≥1 VC 失败
**执行步骤**：
1. 停止新发布
2. 执行 `bash scripts/rollback.sh --backup {backup-id}`
3. 验证回滚结果
4. 报告用户 + 记录到 progress.md

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |
