# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话(09-20): 使用当前 skill 执行任务时非常缓慢,怀疑与任务复杂度无关都使用统一模板有关; 要求提供不同级别模板按难度选择, 确保不让任务缓慢
- 诊断结论(主进程实读代码): 四大慢源 ①每 Phase 6 步闭环仪式(SKILL L87-107) ②重仪式区块全量标配(VC≥5+FMEA+知识储备+委派统计, 机器校验) ③模板 418 行 ④强制串行子代理派发。用户痛点=全流程慢, 最大慢源①②为执行期仪式
- 用户选定方案 B: 轻量模板 + 门控放松双轨(09-20「好的 b」)

## 设计·门控豁免插入点锚(P1 实勘, P2 S3 照单实施)
<!-- worktree: /home/terry/task-planner-skill-worktrees/task-v086-mini-fast-path/skills/task-planner -->

| # | 脚本 | 段位置(锚 grep) | 现状行为 | mini 豁免改造 | 非 mini 零影响保证 |
|---|------|----------------|---------|--------------|------------------|
| 1 | scripts/attest-plan.sh:119-180 | `check-fmea-gate` + `resolve_fmea_tier`(grep「FMEA 预演」段) | fmea_enforce 三档, RC=2 无 FMEA 段=违规 | 计划 frontmatter `plan_tier: mini` 时 FMEA 段缺失 → 直接 OK(等价 RC=0)并打一行 [fmea-gate] MINI-TIER SKIP | if 前置: `grep -q 'plan_tier: mini'` 命中才走跳过分支; 其余路径逐字节不动 |
| 2 | scripts/check-complete.sh:521-660 | VC-GATE 段 `resolve_vc_gate_tier` + VC≥5/V-N≥2 校验 | vc_gate_enforce 三档, 缺 VC 阻断 | mini 计划: VC 最低要求 5→2, 每 Phase V-N 映射最低 2→1; 无 V-N 映射行不阻断 | 同法: plan_tier: mini 才读降档阈值, 否则走既有默认值 |
| 3 | scripts/check-complete.sh:378-400 | 委派统计段 `check-delegation.sh stats` 消费(verdict/rate/floor 0.7) | 委派率 <0.7 或 violation → 阻断交付 | mini 计划: floor 0.7→0.0 且 main_direct 全部理由视白名单(WHITELIST-EXEMPT 直通), 仅 violations 仍计 | if 前置同法; 非 mini 取 config 原值 |
| 4 | scripts/check-plan-dispatch.sh:128-140 | 派发型 Phase 缺 S-unit 表=违规(attest 内置调用) | 无 S-unit 表拒绝锁定 | mini 计划且 Executor 字段全为「主进程」→ 视为非派发型, 豁免 S-unit 表要求; 仍声明子代理 Executor 的 Phase 不豁免 | grep 计划内是否存在非主进程 Executor, 存在即回落全量校验 |
| 5 | knowledge-brief.md 第 6 文件(消费点=SKILL 指针+plan-writer 契约行, 无机器钩子, knowledge_brief_enforce 默认 warn) | 流程层 | plan-writer 产出五段 brief | mini 计划: brief 降为可选单段「速览」, SKILL 指针行注明「plan_tier: mini 时 brief 降档」 | 默认档行为不动, 仅文字说明 |

**判定标准(机器可测, 落 check-plan-dispatch 前置 + init-session 分流)**:
```
mini ⇔ (计划 frontmatter 声明 plan_tier: mini) ∧ (scope_files 文件数 ≤2) ∧ (预估时长 ≤15min, 写 Goal 行) ∧ (单模块)
声明 plan_tier: mini 但任一机器条件不满足 → check-plan-dispatch 打 [plan-tier] MISMATCH 提示(warn, 不阻断, 由用户改回 standard)
未声明 plan_tier 的既有计划 → 全部按 standard, 零影响
```

## 设计·模板档位矩阵(P1, P2 S2 照单实施)
| 档 | 模板 | 行数预算 | VC | 仪式区块 | 说明 |
|----|------|---------|----|---------|------|
| mini(新增) | templates/variant/mini-lite-type.md(frontmatter: `plan_tier: mini`) | ≤80 行 | ≥2 条, 无 V-N 映射表 | 跳 FMEA/知识储备表/委派统计/Batch 区块; 2 个 Phase(实施+验收); 每 Phase 仪式降为 Phase 级一次 3-File 回填 | 中/重任务禁用 mini 模板 |
| standard(中档, 现有) | 现有 13 个 variant | 现状 | ≥5 | 全量 | 不新造, frontmatter 注 `plan_tier: standard`(缺省即 standard, 零改动亦可) |
| full(重档, 现有) | templates/task_plan.md general | 现状 418 行 | ≥5 | 全量 | 不变 |

- init-session.sh 改动: 位置参数第 3 参或 env `TASK_PLAN_TIER=mini` → task_plan.md 复制源改为 `variant/mini-lite-type.md`(与 template_type 正交, 同命中时 mini 优先于 general, variant 场景 mini 不生效=variant 本身即中档定制)
- 机器门控消费 frontmatter 标记而非模板文件名(防手搓计划绕过): 三处脚本统一 `grep -m1 'plan_tier: mini' task_plan.md`

## 设计·Rule 38 条款草案(P2 S1 照写, 全文由 executor 落盘)
- 38.1 判定: 三条件机器可测 + MISMATCH 提示
- 38.2 档位矩阵: mini/standard/full 三档表(同上设计节)
- 38.3 轻量模板契约: mini-lite-type 区块白名单(仅 Goal/VC≥2/2 Phase/范围表/Handoff 表)
- 38.4 门控豁免清单: 锚表 5 点(1-5), 非 mini 路径零影响铁律
- 38.5 机制: config 键 `plan_tier_enforce`(enforce/warn/off 默认 warn: off=mini 声明也走全量门控; warn=豁免生效+MISMATCH 提示; enforce=豁免生效+MISMATCH 阻断锁定) + selftest-plan-tier.sh 守护 + SKILL 联动(索引行 Rules 1-38 + C26 + 摘要行)
- SKILL 联动插入点: L9 索引行「1-35…36…37」→「1-38」; C25 后追加 C26; Critical Rules 段末追加 Rule 38 摘要行(净增 ≤10 行, 行位替换优先)
- 锚级联注意: selftest 中宽容锚 `1-3[5-7]`/`1-3[56]` 需扩围为含 38 的形态(先例: v085 1-36→1-37 级联 6 处); 行数断言 T2b ≤549 视 SKILL 净增上调

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

## 实施记录·S3 锚5 确认（2026-09-20）
- 锚 5（knowledge-brief 降为可选单段「速览」）= 纯文字层，无脚本改动：消费点=SKILL 指针行+plan-writer 契约行（knowledge_brief_enforce 默认 warn），机器钩子 S3 不实施，仅文字说明（38.4⑤）。✅ 已确认（S3 executor）

## 实施记录·S5/S6（2026-09-21）
- S5 既有锚修复: 4 处 SKILL 行数断言 549→552（knowledge-brief T2b/batch-pilot BP-08/execution-stability T8b/skill-collab T10, label 注 task-v086）; 宽容锚 4 脚本扩围（reflect-verify 1-3[5-7]→1-3[5-8] / veto+error-loop 1-3[1-7]→1-3[1-8] / conclusion-discipline CD-11 1-3[5-7]→1-3[5-8] + CD-18/19 断言正则扩围文案同步）; README L67 1-37→1-38。variant 数量断言扫描: 无 selftest 断言 13（TL-17 锚「13 个」=template-guide 文本计数, 13 类不变仍命中; mini-lite 为 tier 模板不改变 13 任务类型分类面, 不动）
- S6（用户 09-21 指令扩围）: init-session.sh 多模板极简机制——项目 plan-templates 目录 *-type.md 并入 VALID_TYPES / default 文件 > env TASK_TEMPLATE_DEFAULT > general 回落 / --list 子命令 / 自造模板复制后头部插 frontmatter 行; 全缺省路径与改前逐字节一致（旧版脚本对照 diff 仅任务名差异 + 产物逐字节一致）
