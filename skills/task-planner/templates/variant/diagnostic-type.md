# Task Plan: [诊断任务名称]
<!-- template_type: diagnostic -->
<!-- 诊断型模板 — 适用于 skill 审计/bug 排查/代码审查 -->

<!-- plan_tier: standard -->
<!-- execution_lane: L1 -->
## Goal
[一句话描述诊断目标]

## 🔍 Code Review 配置（Rule 37 代码组默认）
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`/`required` |
| `对齐审查` | `[登记]` Rule 42.6;mini 豁免 |
| `超时/质量审查` | `[登记]` Rule 42/44;mini 豁免 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 前置 Read 门完成（S59） | 所有相关文件已 Read | 工具调用记录 |
| VC-2 | 引用路径存在性验证（S64） | python3 tools/path_existence_validator.py | tmp/validator-output.json |
| VC-3 | 诊断报告含 evidence | path/size/mtime/sha256 | 诊断报告.md |
| VC-4 | 修复计划获用户授权 | 用户显式 "yes" | 对话记录 |
| VC-5 | 修改后验证通过 | Read 确认/测试通过 | 验证输出 |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 目标 skill | {target-skill}/* | 其他 skill 文件 |
| 诊断报告 | tmp/diagnostic-* | 根目录临时文件 |
| 计划文件 | plans/task-{id}/* | 其他 plan 目录 |
| 测试副本 | tmp/{skill}.test-backup/* | 真实文件直接修改 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
> 目的：对齐任务知识库。列出本任务依赖的规范/文档等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 审计基线/历史 issue | 既有结论与已知问题清单 | 内部路径/URL | 参考 | ☐ |

**填写规则**：① `定位` 可唯一定位（绝对路径/URL+版本）；② `必读` 缺失 → 停止执行并登记 Errors；③ 引用格式对齐 SKILL.md 调研类强制引用格式。

- **调研需求三态（Rule 75.1）**：诊断型任务默认 **可选**——审计/bug 排查通常依赖项目内部证据，若涉及未知框架/外部缺陷则需网络调研；调研 Phase 须登记检索关键词+渠道+预期产出。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

## Phases
### Phase 1: 诊断前置 Read 门（Standard 59）
- [ ] Read 目标 skill 全部相关文件（SKILL.md + references/*.md + config/*.json）
- [ ] **门控**：未 Read 全部文件 → 禁止进入诊断
- [ ] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **Status:** pending
- **Executor:** debugger（sonnet-1）
### Phase 1.5: 引用路径存在性验证（Standard 64）
- [ ] 运行 `python3 tools/path_existence_validator.py <skill-dir> --scope all`
- [ ] 记录 P0 缺失和 P1 歧义
- [ ] **门控**：有 P0 缺失 → 阶段 2 必须包含修复计划
- **Status:** pending
- **Executor:** debugger（sonnet-1）
### Phase 2: 诊断报告
- [ ] R1-R8 调研 → C1-C5 证据完整性
- [ ] 56 标准审计 + Standard 39 Skill() 调用扫描
- [ ] 根因分析 → 产出诊断报告
- [ ] **门控**：诊断报告无 evidence → 回退重跑
- **Status:** pending
- **Executor:** debugger（sonnet-1）
### Phase 3: 修复实施
- [ ] 按优先级修复（P0 → P1 → P2）
- [ ] 完整性反思 Q1-Q9 + 参数同步 Q7-Q9
- [ ] Standard 54 Loop 决策 + 57 模板适配
- **Status:** pending
- **Executor:** code-assistant（haiku-1）
### Phase 4: 验证 + 总结
- [ ] 逐条复验 56 标准 + Standard 58 中文总结块
- [ ] Wait 完成强制核查（W1-W5）
- [ ] 交付结论：COMPLETE/PARTIAL/BLOCKED
- **Status:** pending
- **Executor:** code-runner-agent（mini）

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |
## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |
