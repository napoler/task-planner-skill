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

### 指针切换设计缺陷根因（2026-11-20，Explore 子代理全链路调查）

**结论先行**：三层设计缺陷叠加，导致 D 类意图切换/新任务 init 时必现「指针仍被旧计划声明，需 --force 覆盖」，模型需 2-3 次交互才完成切换。

**缺陷链（三环）**：
1. **init-session.sh:1235-1238 无 force 通道**：同 sid 在途 claimant（扫 `plans/*/.session-owner` 匹配 + claimant task_plan.md 含 `Status.*in_progress`）→ `SKIP_SIDE_WRITE=1` 静默失切，只输出 WARN。init 的「指针自动切换」承诺落空（SKILL.md:220 写「②新计划 init（指针自动切换）」）。
2. **D 类挂起登记不释放占用**：SKILL.md 意图切换清单①只写「[intent-switch] 行+断点检查点」，不删旧计划 `.session-owner`、不改 Status——旧计划 Status 仍 in_progress，守卫必然命中。
3. **set-active-plan.sh:265-278 skip 时 exit 0**：不带 --force 被拒后指针未变但命令返回成功，易被误判已切换，需第三次带 --force 才成功。

**守卫误伤面（潜在 bug）**：`grep -qi 'Status.*in_progress'` 扫 claimant task_plan.md **全文任何行**——模板示例/Phase 状态表/说明文字含该字样即误命中，误拦面大于真实在途计划。

**设计矛盾本质**：守卫目的是「防沿袭互踩」（防指针被误切走），但 init 有 CWD 守卫（必须 plans/<task-id>/ 内执行）+ 建 7 文件重动作 = 强意图信号；系统无法区分「误切」与「用户决策的切换」，把 D 类明确切换也拦了。

**指针体系事实**（修复面依据）：
- side 指针：`plans/.active_plan_side/<sidkey>.active_plan`，sid 取 CLAUDE_CODE_SESSION_ID，TTL 24h，resolve 优先级 side→全局→mtime→legacy
- `.session-owner`：每计划目录一份，由 zcode-userpromptsubmit.sh:244-246 认领（仅 owner 空或==自己时写）——挂起后删除安全，回切时 hook 自动重建
- 源仓与 ~/.zcode 部署位 5 个指针脚本 diff 为空，缺陷同构（修复需双落点同步）
- fail-open 已是既有方向（claimant complete/不存在时 :269 继续写入）

**修复方案（四件套）**：
- G1（核心）：init-session.sh 同 sid 在途 claimant 分支改为「明确通告+直接写」——init 于新计划目录执行=明确切换意图，内置 force 语义
- G2（流程）：SKILL.md D 类清单①挂起登记追加「删除旧计划 .session-owner（挂起=会话不再认领）」；E 类/Rule 94 隔离处置同步
- G3（收窄）：set-active-plan.sh/init-session.sh 守卫 in_progress 判定从全文 grep 收窄为状态控制行锚定（防模板字样误命中）
- G4（增强）：set-active-plan skip 时输出升级「指针未切换」明确前缀（exit code 是否改需查调用点）

### S1 实施结论（2026-11-20，主进程 diff 复核通过）
- init-session.sh +30/-4：`_sid_fallback` 门控标记（:1176-1182/:1213-1217）；claimant 守卫重构（:1244-1265）——身份确定通告+直写（NOTICE 两行含 claimant/挂起/恢复/session-owner 字样）、fallback 保留 skip+WARN（D3 路径防护）；in_progress 锚定正则 `^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress`（:1255）
- 子代理自验 16/16：F1 在途拦截转直写/F2 非加粗不漏判/F3 注释散文 fail-open/F4 fallback 保留拦截
- 编辑中曾误删 `_sidmap_checked` 被 F4 夹具捕获后恢复（:1182 有注释说明）——过程质量证据
