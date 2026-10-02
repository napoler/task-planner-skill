# Task Plan: [调研任务名称]
<!-- template_type: research -->
<!-- 调研型模板 — 适用于关键词调研/SERP分析/竞品研究 -->

<!-- plan_tier: standard -->
## Goal
[一句话描述调研目标]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` / `required` |
| `对齐审查` | `[登记]` | Rule 42.6 消费：完成前跑 alignment-review;变更记录随交付落盘;mini 豁免 |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` | Rule 44 消费：默认项+超时 5 分钟;低区分度 44.2 直接裁决;mini 豁免 |
| `质量审查工具` | `[检测结论]` | Rule 42 消费：42.2 四级检测登记;执行期用登记工具;mini 豁免 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 调研策略 ≥3 种 | grep `_channel_attempts[]` findings.md | findings.md |
| VC-2 | 至少 2 个独立数据源 | ls research/ | research/ |
| VC-3 | 数据完整性检查通过 | jq '.data | length' research_data.json | research_data.json |
| VC-4 | 关键词覆盖率 ≥80% | python3 scripts/keyword_coverage.py | tmp/coverage-report.json |
| VC-5 | 无重复/冲突数据 | diff <(sort data1) <(sort data2) | tmp/diff-output.txt |

> 注：VC 表中脚本路径为示例值（目标项目相对路径），非本技能仓文件

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

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
逐 Phase 登记工具面与理由;Executor 字段仍是委派门控机器事实源;mini 豁免
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

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

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |
