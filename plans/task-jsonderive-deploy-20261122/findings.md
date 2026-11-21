# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

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
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

## Research Findings
<!-- [2026-11-22] 判例锚：sess_3c52df8e（StoryLab task-nvdiaoshou-ep36plus-quality-revamp-001）plan-state.json 23:37:55 建后 updated_at 恒等 created_at、全数组空，而 4 MD 被直接写 11-33KB —— SOP 未生效铁证 -->
- F1: 三层判定=文档 FULLY_DEPLOYED（三部署位逐字一致 sha256 同）/脚本 SCRIPT_OK（selftest 17/17+shim 15/15+端到端冒烟）/执行层 SOFT_ONLY（无强制门+hook 仍教直接 Edit+簿记提交仍改 MD）。证据：check-delegation.sh planctl 零命中；zcode-posttooluse.sh:267/302/330 旧文案
- F2: 根本矛盾=cmd_render（planctl.py:768-845）全量覆盖 4 MD 为极简表格，丢弃模板全部语义段（progress 的 Actions/Error Log/5Q、findings 的 Research/Decisions 等），Rule 19.2/19.4/31 留痕失去落盘对象——全面派生必须 render 重建全部语义段
- F3: 机器门文本锚依赖=3file-gate(:106-128 Started 锚)/evidence-anchor(:513 [goal:Gn] 行)/context-hygiene(:60-96 Action 行数)/check-complete(Phase [x]+LEARNING/REFLECT/judge gate)——render 锚格式须逐字保真
- F4: S-unit 10 列列序被 check-plan-dispatch.sh $4/$5/$7/$8 依赖；task_plan.md 受 attest SHA 锁=先 render 后 attest
- F5: 用户裁决链（防重提）：否 PreToolUse 硬门→裁软堵 render 覆盖→否部署位 symlink 手术（超出项目）→否 21合1→定=升级 skill 定义文件+完成后一通部署
- F6: VC 终验对照——VC-1(21/21) VC-2(36 section 写入往返) VC-3(render 全锚+plan-dispatch 真消费) VC-4(改动面=5 文件+254 部署) VC-5(四位 IDENTICAL+selftest 绿) VC-6(全量回归 2 项引入已修，预存 8 项同 master) VC-7(口径修正落地：init 不 render+首次写入后 render——VC-7 原判据"init 后立即 render"经实证回撤，修正为软堵等效口径) 全 PASS
- F7: 教训两条——①init 时机设计缺陷由全量回归 master 对照法抓获（PT-26 首行证据链）；②render meta 反引号会使所有裸 grep 门静默失效，派生视图输出格式必须按门解析器逐字适配
