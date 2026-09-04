# Task Plan: [调研任务名称]
<!-- 调研型模板 — 适用于关键词调研/SERP分析/竞品研究 -->

## Goal
[一句话描述调研目标]

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 调研策略 ≥3 种 | grep `_channel_attempts[]` findings.md | findings.md |
| VC-2 | 至少 2 个独立数据源 | ls research/ | research/ |
| VC-3 | 数据完整性检查通过 | jq '.data | length' research_data.json | research_data.json |
| VC-4 | 关键词覆盖率 ≥80% | python3 scripts/keyword_coverage.py | tmp/coverage-report.json |
| VC-5 | 无重复/冲突数据 | diff <(sort data1) <(sort data2) | tmp/diff-output.txt |

**终验规则**：
- 全部 VC 通过 → COMPLETE
- VC 通过但有已知遗漏 → PARTIAL
- ≥1 VC 失败且重试 3 次无效 → BLOCKED

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 研究数据 | data/{site}/{id}/research/* | 其他站点数据 |
| 临时文件 | tmp/research-* | 根目录临时文件 |
| 计划文件 | plans/{task-id}/* | 其他 plan 目录 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 文献/论文 |  |  | 参考 | ☐ |
| 图书/教程 |  |  | 参考 | ☐ |
| 领域权威文献 | 综述/白皮书/竞品公开资料 | URL/书目 | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## Phases

### Phase 1: 调研策略制定
- [ ] 确定 ≥3 种搜索策略（关键词/Bing/文档）
- [ ] 记录 `_channel_attempts[]` 到 findings.md
- [ ] 确认数据源列表
- [ ] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **Status:** pending
- **Executor:** research-assistant（sonnet-1）

### Phase 2: 数据收集
- [ ] 执行策略 1：{strategy-1}
- [ ] 执行策略 2：{strategy-2}
- [ ] 执行策略 3：{strategy-3}
- [ ] 验证数据来源完整性
- **Status:** pending
- **Executor:** research-assistant（sonnet-1）

### Phase 3: 数据清洗与验证
- [ ] 去重检查
- [ ] 冲突检测
- [ ] 覆盖率计算
- **Status:** pending
- **Executor:** code-runner-agent（mini）

### Phase 4: 结果整合
- [ ] 合并调研结果
- [ ] 生成 summary.md
- [ ] 标注关键发现
- **Status:** pending
- **Executor:** research-assistant（sonnet-1）

### Phase 5: 交付验证
- [ ] 逐条复验 VC
- [ ] 输出调研报告
- **Status:** pending
- **Executor:** 主进程（例外理由:编排与交付属主进程白名单）

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |
