# Task Plan: [视频生成提示词转换任务]
<!-- template_type: video-prompt -->
<!-- 图→视频转换写词工序：镜头行→视频提示词映射、参考组配置、机械门、spec 登记。边界：纯写词+spec 层零视频调用（发视频入 video-type）；图像提示词入 prompt-struct-type；缺陷重出入 video-fix-type。触发词：视频提示词/转换/reference 配置/epNN-prompts -->
<!-- 五要素：①编号原子步骤+显式状态定义（逐镜转换卡+槽位配置）+合规检（机械门+语言音色子句）+静默迭代（机械门 FAIL 回改环）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——全程零视频调用零秒数消耗；唯一合法打断=Rule 28 D6；批次末单份收尾报告 -->

<!-- plan_tier: standard -->
## Goal
[一句话：把哪一集的哪些镜头行转换为可投生成的视频提示词与 spec，达成标准（机械门全过+逐镜转换卡齐+spec 登记）]

## 任务分型（三选一）
| 型 | 场景 | 差异 |
|----|------|------|
| A 全集转换 | 定稿剧本整集转词 | 按镜序逐镜 |
| B 局部重转 | 修正件/替换段转词 | P1 并入缺陷归因；同镜同槽位复用核对 |
| C 试水镜 | 单镜先行验证 | 天然 ≤1 件，机械门照过 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：五相顺序；上游镜头行必须来自已放行剧本（无放行=STOP）；转换卡未过机械门禁入 spec | Phase 链+放行指针 | task_plan |
| VC-2 | 显式状态定义：逐镜转换卡（镜号×说话描述×语言子句×音色子句×参考组槽位×负向集）；reference 配置 ≤5 张逐张点名（槽 1 风格锚/关键帧九宫格/角色 multiview/道具） | 转换卡 grep 逐镜 | prompts/ 提示词档案 |
| VC-3 | 合规检：语言锁（说话描述必带语言限定子句，三层优先级）+音色子句逐字抄角色卡+行驶镜强化负向+生成层零文字（弹幕/框=后期叠层零提及）+安全子句 | 逐镜合规核对行 | progress.md |
| VC-4 | 静默迭代：机械门 FAIL→回 P2/P3 修正环（静默）；同型 FAIL ≥2=子句固化 | 回改环计数 | progress.md |
| VC-5 | 验收判据（机械门）：参考图宽高比 0.4-2.5+disposition_ref 合规+关键帧模式仅用户点名锁首帧时启用且首帧 16:9+seed 可复现任务必传并登记 | 机械门校验输出（gen.py 前置校验口径） | 校验记录 |
| VC-6 | 登记收口：spec 落 tmp/<任务>/specs/+逐镜 URL/seed 台账位预留；废弃版归档 | spec 文件+登记行 | specs/+output 台账 |

## Phases（五原子步骤）

### Phase 1: ① 镜头行映射
- [ ] 已放行剧本镜头行逐镜提取（画面行/说话描述/装备状态/出场角色）；产出=镜序清单（状态：待转换）
- **V-N:** VC-2, VC-1
- **Status:** pending
- **Executor:** 主进程（需剧本上下文）

### Phase 2: ② 逐镜转换卡组装
- [ ] 画面行→英文视频提示词（七要素保留）；语言子句按三层优先级取词；音色子句逐字抄角色卡；产出=转换卡草案（状态：待配参考）
- **V-N:** VC-2, VC-3
- **Status:** pending
- **Executor:** 写词执行体（子代理）

### Phase 3: ③ 参考组配置
- [ ] 逐镜 reference ≤5 张配置（按槽位规范逐张点名：风格锚/关键帧九宫格/角色 multiview 唯一件/道具 sheet）；关键帧模式仅在用户点名锁首帧时配置；产出=完整转换卡（状态：待机检）
- **V-N:** VC-2, VC-5
- **Status:** pending
- **Executor:** 写词执行体/主进程复核

### Phase 4: ④ 机械门校验
- [ ] 逐镜机械门（比例 0.4-2.5/disposition_ref/首帧比例/seed）；FAIL 回 P2/P3 环（静默）；产出=全过卡池（状态：待登记）
- **V-N:** VC-5, VC-4
- **Status:** pending
- **Executor:** 主进程机械校验（白名单③，校验命令只读）

### Phase 5: ⑤ spec 登记收尾
- [ ] 逐镜 jobs 写入 spec（gen.py 规格：镜号×卡×refs×参数×seed）；台账位预留；单份收尾报告（逐镜清单+机械门结论+下游发批前置提示：本 spec 投产前须过 video-type 人工门）
- **V-N:** VC-6, VC-5
- **Status:** pending
- **Executor:** 主进程

## 🔗 隔离与静默纪律
- 组词（P2/P3）与机械门（P4）分离；本模板全链零视频调用——spec 投产属 video-type 域，其人工门不在本模板内
- 静默环：机械门 FAIL 回改不呈送中间态；用户可见=批次末收尾报告
- 同型 FAIL ≥2 → 子句固化进 prompts/ 模板件（当日）

## 📚 必要知识储备（均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 转换基线 | 元素优先协议（reference 混交/关键帧模式边界/行驶强化负向） | AGENTS.md 约束 9；prompts/structured-shot-template.md | 必读 | ☐ |
| 槽位 | 参考槽位规范 v2.3 | prompts/reference-slots-v2.md | 必读 | ☐ |
| 机械门 | gen.py 比例 0.4-2.5/disposition_ref/规格 | tools/README.md | 必读 | ☐ |
| 语言音色 | 语言锁三层+音色子句（逐字抄卡） | AGENTS.md 约束 11/12；assets/<series>/cards/characters/ | 必读 | ☐ |
| 判定层 | review-refgroup/review-prompt 技能 | 仓库技能层 .zcode/skills/videop1-review-*/ | 参考 | ☐ |

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
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | | | queued | | | | | - / 0 / ☐ |
| 2 | | | | | | | | | - / 0 / ☐ |
| 3 | | | | | | | | | - / 0 / ☐ |

