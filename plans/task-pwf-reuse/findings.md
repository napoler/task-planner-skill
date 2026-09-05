# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话（2026-09-05）："该项目 已有 实现 可以复用该项目的 已有实现 https://github.com/OthmanAdi/planning-with-files"
- 意图：上游有成熟实现,自研弱信号部分应复用上游方案,不重造轮子
- 约束：本仓 task-planner 已深度本土化（Rule 1-26/worktree/委派/五文件+知识储备/plan-resume 生态）——复用=移植适配,非整体替换

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 上游 v2.4x/v3 实现盘点（zread @master,2026-09-05）
- **ledger-append.sh**(300 行 sh,全文已读):追加式 JSONL 账本 `<plan-dir>/ledger-<agent>.jsonl`,每行 `{"tick","ts"(ISO8601Z),"agent","phase","event","summary"(≤200 字符),"files":[...]}`;事件枚举 progress/phase_complete/error/gate_block/attest/note;tick=目录内全部 ledger-*.jsonl 的 max+1(flock 保护,并发 agent 共享单调流);UTF-8 截断修复(iconv 主路径+od/dd 字节级兜底);JSON 转义(sed+tr 控制字符)
- **完成门五守卫**(zread 14-completion-gate 提炼):G1 .mode 含 gate token / G2 存在 in_progress Phase / G3 stop_hook_active 防递归 / G4 阻断上限(默认 20,PWF_GATE_CAP) / G5 停滞检测(ledger 总行数 vs .gate_last_ledger,BLOCKS>0 才触发,停滞→放行停止防死循环)。设计原则 issue#178"未完成计划是常态非错误",fail-open
- **上游对 mtime 的明确否定**(G5 设计注记):"the gate deliberately does not use progress.md mtime — that moves on any file touch and is thus unreliable"——直接命中 task-3file-enforce 自研门控的弱点(touch 即可骗过,我在脚本注释里也自认了"宁可误报")
- **plan-doctor.sh**(全文已读):六段一键自检——①canonicalizer 探测 ②计划解析(resolver/legacy/.planning 歧义) ③hook 注入暗火检测(含 PLAN TAMPERED/未 attest/会话隔离/嵌套歧义四种特征文案) ④attestation 在位 ⑤安装面盘点 ⑥hook 单次延迟。诊断"静默失效",恒 exit 0
- **宿主能力梯队**:Tier1 硬阻断(Claude Code/Codex/Continue.dev,Stop 事件 JSON block)/Tier2 跟进注入(Cursor/Pi/Kiro)/Tier3 仅通知(OpenCode/Gemini)。**ZCode 实测仅 4 事件(SessionStart/PreToolUse/PostToolUse/UserPromptSubmit,config.json 查证)——无 Stop 事件,gate-stop.sh 五守卫无宿主载体,不移植**
- **不移植清单与理由**:gate-stop(无 Stop 事件)/inject-plan(本仓 4 hook 自研已有 smart 注入+attest 校验,上游加固点嵌套歧义/会话隔离列后续可选)/resolve-plan-dir+set-active-plan(本仓 plans/<task-id> 显式传参惯例,多计划 .active_plan 指针列后续可选)/check-continue(与 session-catchup.ts 功能重叠)
- **知识储备消费**:ledger-append/plan-doctor/gate-stop 全文✅、完成门提炼✅、本仓 check-3file-gate(自研)✅、ZCode hook 面✅——结论即上列

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
