<!-- template_type: diagnostic -->
<!-- 适用: 行为级冒烟测试（Task ID 不在编号账本体系内——编号账本只管 Rule 号） -->
# Task Plan: 行为级冒烟 — 媒体专业执行体 + Rule 52 选型

<!-- plan_tier: standard | execution_lane: L1（多代理派发+API 调用） -->
<!-- interaction_mode: silent（用户 2026-10-04 显式指令「你直接测试 你直接创建新的任务……直接添加 测试」=预授权） -->

## Goal
验证 task-v124/v125 落地的行为面：两个新专业执行体（image/video-generation-executor）可派发性、SOP 守卫（HARD_BLOCK 前置检查）正确触发、Agnes API 最小真实生成全链（1 张 + 三检）、以及计划门控对新执行体类型名的接受度；产出冒烟报告（含「若当前会话类型不可见 → 计划任务定时到新会话」兜底）。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯测试，无仓内代码产物） |
| `session_id` | `6321d679-29244e3a-b3d5-c4fc2b773741` |
| `interaction_mode` | `silent` |
| `worktree_path` | `n/a`（direct；纯测试，§11.5③ 只读/测试类） |
| `对齐审查` | n/a（无文档更新） |
| `自动超时默认项` | 无 2+ 选项询问点 |
| `质量审查工具` | n/a（无质量审查面） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 可派发性：image/video-generation-executor 均可被 Agent 派发并返回合法 8 字段 | 派发返回原文 | plans/task-v130/subagent-state/ |
| VC-2 | SOP 守卫：故意缺输入的两路派发均返回 `HARD_BLOCK: <缺项>` 且零 API 调用 | 返回原文含 HARD_BLOCK；无生成产物 | 同上 |
| VC-3 | 全链：最小真实生成（1 张）返回产物 URL + 三检结论（key 缺失则记 BLOCKED 原因） | 返回原文 | 同上 |
| VC-4 | 冒烟报告落盘（可复现命令 + 逐项判定） | Read 报告 | plans/task-v130/smoke-report.md |
| VC-5 | 计划门控接受度记录：attest/check-dispatch 对两新类型名的处理（含任何告警原文） | 命令输出原文 | progress.md |

**终验规则**: 全部 VC 通过 → COMPLETE；类型不可见且兜底计划任务已排 → PARTIAL（如实标注）

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 计划系统 | plans/task-v130/** | 其他 plans |
| 仓内 | 无（纯测试零仓内写） | 任何技能/仓库文件 |
| 外部 | Agnes API 调用（经 image-generation-executor；单张试水 ≤2 抽） | 批量生成；video 真实生成（仅守卫路径） |

**执行前自我检查:** 全部 Yes（用户显式授权测试）

## ⚠️ 核心问题定义
**核心问题**: v124/v125 的交付只完成了静态面（文件/断言），行为面（agent 可见可派、SOP 生效、API 全链）未验证——本任务补此最后缺口。

## Current Phase
交付终态（P1-P4 complete；VC-1/2/4/5 PASS，VC-3 BLOCKED 外因（凭证）+复测已排；outcome=PARTIAL）

## Next Step
交付报告（smoke-report.md 为机器档案）+ 记忆追加；计划任务 2h 后自动复测全链

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| P1 | 机械验证命令 | 只读预检 |
| P2/P3 | Agent 子代理（**被测体直派**） | 测试对象即新执行体 |
| P4 | （主进程）+ 备选 CronCreate | 汇总；类型不可见时定时兜底 |

**workflow 编排判定**: 未命中 **/goal 对齐**: 无

## Phases

### Phase 1: 预检
- agent 文件双位在位 / AGNES key env / agnes skill script 在位 / 部署位一致
- **V-N:** VC-5
- **Status:** complete
- **Executor:** 主进程（白名单③ 机械验证）
- **Evidence:** 4/4 agent 文件双位+agnes 脚本+key 存在性；attest SHA 2a8ddab5…（零告警）

### Phase 2: 可见性 + 守卫冒烟（HARD_BLOCK 路径，零成本）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** image-generation-executor + video-generation-executor（被测体直派=冒烟本体；多类型分隔符用 `+`——check-delegation 复合解析口径）
- **Evidence:** S1/S2 均派发成功（**可见性 PASS**）；双 HARD_BLOCK 列全缺项、零调用零产物（s1-image.md / s2-video.md）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 缺输入守卫自检（禁生成/禁 API）：按前置检查规程返回 HARD_BLOCK + 8 字段 | image-generation-executor（agent 自带档） | 本任务书（故意缺 单元清单/提示词/参数） | 返回含 `HARD_BLOCK:` 与缺失项名；零产物 | 5min | pending |
| S2 | 缺放行登记守卫自检（禁生成/禁 API）：返回 HARD_BLOCK + 8 字段 | video-generation-executor（agent 自带档） | 本任务书（故意缺 放行登记/镜头清单/参数） | 同上 | 5min | pending |

### Phase 3: 最小真实生成（全链）
- **V-N:** VC-3
- **Status:** complete（结果=BLOCKED 外因：Agnes 凭证 401；计划任务已排复测）
- **Executor:** image-generation-executor
- **Evidence:** 核词冻结→试水被拒 401「无效的令牌」（curl+BASE_URL 双证排除域名陷阱；重抽 0）；故障模式行为面 PASS（s3-image.md）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S3 | 单张 t2i 全链：核词→试水 1 抽→三检→回执（URL+三检） | image-generation-executor（agent 自带档） | agnes 技能路径 + 主题=简笔蓝色方块 | 返回 URL + 三检逐项结论；≤2 抽；不扩批 | 10min | pending |

### Phase 4: 汇总与交付
- 冒烟报告（逐 VC 判定 + 复现命令）→ 交付；若 P2 类型不可见：CronCreate 定时兜底（新会话重试）登记
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（白名单② 计划簿记）
- **Evidence:** smoke-report.md 落盘（4 层判定+复现入口）；计划任务 automation-13c74ca0 已排（2h 复测）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | 他会话并行保留（未重扫，低风险） |
| `isolation` | `direct`（§11.5③ 纯测试类，零仓内写） |
| `merge_back` | n/a |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P2 | agent 类型本会话不可见（列表固化） | 6 | 5 | 1 | 30 | 按用户提示的「计划任务」兜底：CronCreate 定时新会话重试 |
| P3 | API 拒绝/超时 | 5 | 3 | 2 | 30 | ≤2 抽后上报；按 agent 负结果报告规程 |

## 🔁 原生 Todo 同步
| Phase | Todo 已建 | 备注 |
|-------|-----------|------|
| P1-P4 | ☑ | 计划创建时建立 |

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent 交互模式 | 用户显式「直接测试」预授权（P0-1） |
| 守卫冒烟用「故意缺输入」设计 | 零成本 + 同时验证可派发性与 SOP 守卫（HARD_BLOCK 是本 agent 的核心安全契约） |
| video 不做真实生成 | 昂贵且需 G1 放行前置（隔离铁律）；守卫路径足够冒烟 |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-04 18:45 | ✅ ALIGNED | VC-1/2/3/4/5 | 全程零仓内写、零批量、video 未真实生成——与范围表一致；S3 外因阻塞如实记录 |

## 📊 委派统计（Rule 25.4）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 4（P2/P3） |
| 主进程直做 Phase 清单 | P1（白名单③）、P4（白名单②） |
| 委派率 | 0.5 < 0.7 → WHITELIST-EXEMPT（预期） |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint 路径 | 备注 |
|---|------|--------------|----------------|------|---------|------|--------------|----------------|------|
| 1 | | image-generation-executor | S1 守卫自检 | queued | | | | subagent-state/s1-image.md | - / 0 / ☐ |
| 2 | | video-generation-executor | S2 守卫自检 | queued | | | | subagent-state/s2-video.md | - / 0 / ☐ |
| 3 | | image-generation-executor | S3 最小真实生成 | queued | | | | subagent-state/s3-image.md | - / 0 / ☐ |
