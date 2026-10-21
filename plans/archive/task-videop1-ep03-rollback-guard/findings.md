# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1-R4 逐字锚见 task_plan.md「🎯 用户需求原文」+ user-session-log.md #1；核心=①保全已确认定稿母图 ②真投毒=重复生成/未授权改定稿件 ③机制级纠正（质询≠授权/禁连带回退）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 复核取证（G1，2026-10-21 13:37-13:40 主进程独立执行）
- **4 件定稿母图全部在位**：`assets/shiyan-lihua/masters/characters/character-guyu-multiview-v1.png`(1035763B, 864x1152 PNG)、`character-xiaoman-multiview-v1.png`(939737B, 864x1152)、`character-akai-multiview-v1.png`(1087716B, 864x1152)、`assets/shiyan-lihua/masters/scenes/scene-maixiangxiang-hewan-diaodian-v1.png`(1409680B, 1312x736)——size 与 sess_38fd8af3 档案逐件一致，mtime=2026-10-21 06:30:04（恢复时刻），`file` 验证 PNG 头有效
- **三簿一致**：`tools/asset-registry.json` `.assets|length`=414 且 4 件 state=active；`upload-map.json`=74；`masters-registry.md`=104 行——与恢复后档案（414/74/104）完全吻合
- **双保险源区完整**：`tmp/ep03/assets-review/` 含 guyu r1-r7(5-best)/xiaoman r1-r4(2-best)/akai r1-r4(2-best)/diaodian r1-r12(11-best) + qc/verify/urlcheck 全套
- **回退留底区正确**：`tmp/ep03/unauthorized-masters-20261021/` 仅 4 件 facegrid（chenjie-v3/daoba-v3/shouyi-v3/milkcat-v6），EP3 4 件不在其中
- **事实认定**：06:30 用户裁决恢复之后**未发生第二次回退**；用户所指「一致性退回」=当日晨 sess_38fd8af3 内已纠正的误退事件（台账第 3/6 行逐字在档）
- **附带观察**：`tmp/ep03/restore-registry-4.json` 13:28 被截断 0 字节（13:28-13:29 为 mastergen-gate 会话 E2E 收尾窗口；该文件为 tmp 检查点、全仓 tools/scripts 零引用、三簿为唯一事实源——不重建，留痕）
- **机制缺口定位**：AGENTS 约束 25 红线（10-15 定令）已禁「未经授权动 masters/」，但「什么才算授权」无条款——10-21 误退根因=把用户提问当授权；教训只在记忆文件（概率性召回）与台账（历史记录），未入每会话必加载宪法 → 修法=新增 25d
- 生成侧闸已存在：`tools/gen.py` master_gen_gate（L2277-2480，纯校验 fail-closed，零文件移动逻辑，E2E 13:28-13:29 收尾）——回退侧为本任务补齐面

### 测试门结论（G4/VC-4，2026-10-21 14:06）
- 全新上下文 Simple Agent(haiku-1) 仅凭 /mnt/data/dev/videop1/AGENTS.md 判定三场景全对：A 不能执行（25d① 质询≠授权，判例原话逐字命中）；B 不允许（25d②③ 双命中）；C 验收=五处一致+size/md5 逐件验证（25d④）——零口头补充=自含性 PASS（videop1 AGENTS 技能测试门判据）
- 子代理负结果报告：全文 165 行无并行冲突条款（约束 13 废弃件归档/约束 22 已发布集数不回溯均不同口径不冲突）
- 检查点：plans/task-videop1-ep03-rollback-guard/subagent-state/1-simple-agent.md（主进程已 Read 复核）

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
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
