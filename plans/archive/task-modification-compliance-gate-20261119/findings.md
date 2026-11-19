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
- **R1（[目标]）**：用户逐字「核心问题就是 为什么会将一个原本有理有据的 模型能力限制 被恶意的修改了这才是关键 必须解决这个问题 也就是修改是否合规 连合规性都没有就做恶意修改 只会导致投毒 破坏原本可以正确任务被恶意篡改 我的目的以后不会出现这种 合规性都没有就做恶意修改」——诉求=建立**通用「修改前合规论证+授权」硬门**，让任何对已确立规范/约束/阈值的修改必须先证明合规再落地，杜绝无依据放宽/投毒。
- 与已归档 `task-spec-baseline-freeze-20261119` 的关系：后者只冻结「已登记 Spec-Baseline」，本任务补「未登记规范/执行期就地放宽/单边口径」三类覆盖缺口（F2/B1-B4），目标与交付物不同 → 反思门判 D 类新任务（见 Technical Decisions）。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 一手取证报告 | forensics/modification-compliance-gap-20261119.md（116 行） | 是 | Research Findings F1-F7 |
| 核心规则 51.15 | skills/task-planner/references/critical-rules.md:109 | 是 | F2 |
| 纪律域 74.6/74.7 位 | skills/task-discipline/references/critical-rules-discipline.md:493 | 是 | F3/F6（74.7 空位已 grep=0 确认） |
| 纪律域 106.7 | skills/task-discipline/references/critical-rules-discipline.md:756 | 是 | F4 |
| 派发面 22.4e | skills/task-dispatch/references/critical-rules-dispatch.md:66 | 是 | F4 |
| SKILL 变更判定 2.5d | skills/task-planner/SKILL.md:118 | 是 | F4 |
| 模板变更标注表 | skills/task-planner/templates/task_plan.md:184-189 | 是 | F5 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **F1（取证产物）**：Explore 子代理只读产出 `forensics/modification-compliance-gap-20261119.md`（30,600 字节/116 行），含 A 机制清单（file:line 表）、B1-B5 缺口、C1 根因、C2 最小修复面、C3 结论；主进程盘上抽验锚行原文与编号避碰全部吻合（74.7 空位 grep=0）。
- **F2（现有机制均作用域受限）**：20.1 锁 task_plan 完整性；51.15（critical-rules.md:109）仅锁「已登记 Spec-Baseline」；判据冻结锁 verification 判据行；74.3 是方案/修订期语义纪律；36.x/§六 保护技能文件授权与范围；check-delegation 控写权限非内容合规。→ 无「覆盖所有已确立规范」的通用修改前合规硬门。
- **F3（B1/B4 缺口）**：无通用「修改合规四元组」登记要求；基线保护依赖「先登记」前提，源规范/项目侧已确立硬约束未被同等纳管；登记遗漏无机器检查（none-justified 未强制）。
- **F4（B2/B3 缺口）**：74.3 以计划/方案载体为主，执行期对规范/阈值的就地放宽无强制回填与运行绑定；「禁无依据放宽约束」未成通用显式铁律，单边/软豁免检出仅在 51.15 注册四环链内成立。
- **F5（B5）**：宪法/委派/范围门是过程约束，不构成「修改合规性」判定。
- **F6（根因 C1）**：sess_ba603cf5 无单点篡改（git blame 佐证）——真实机制=4-12s 硬约束从未下沉为技能/QC 门（C87 只写 ≤12s 缺 ≥4s 下界、超拍登记/NOTE 软豁免放行），属硬约束未固化→逐步弃用；51.15 落地后缺口收窄为「未登记/执行期就地放宽/单边口径未识别」三类。
- **F7（C3 定论）**：体系已有强门但缺覆盖所有已确立规范的通用「修改前合规论证+授权」硬门；根因定性=「合规门作用域与登记前置不足 + 缺通用无依据放宽铁律」。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| D1（反思门 Rule 102.0）：判 **D 类新任务**，独立计划 `task-modification-compliance-gate-20261119`，不并入已归档 spec-baseline-freeze | 诉求层级=制度层（Rule 31.8，交付物=规则文本条款）；旧计划已归档无法扩展；目标（通用修改合规门）与旧目标（已登记基线冻结）不同；用户当前指令具最高优先级（P0-1） |
| D2：纯文本条款、零新脚本/零新 config 键，复用 74.3 表 / 20.1 attest / 51.15 四环 | 宪法 §二「文本优先铁律」；C2 最小修复面；避免范围扩张 |
| D3：通用铁律落纪律域 **Rule 74.7**（74.6 后、74.7 空位已确认），核心域 51.15 加跨域指针 | 分层：纪律域管执行期行为铁律、核心域管基线定义；避免规则孤岛 |
| D4：worktree 从 master（非 main）隔离；stash 他会话 17 staged + 1 unstaged（knowledge/INDEX.md）后合并回 pop --index | 宪法 §十一；main 为无关陈旧历史；已验证 SOP |
| D5：条款编号避碰——74.7 空位（grep=0）；不改既有 51.15/22.4e/106.7 编号，仅在其段尾追加指针句 | 避免撞号/改判据（判据冻结协议） |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 会话恢复后指针解析到他会话活跃计划 task-model-tier-dispatch-20261119 | set-active-plan.sh set 本任务 --sid a6eb… 绑定会话私有指针；不触碰他会话 5263/aa69 两个 side 指针 |
| 15 个历史未完成任务 hook 提醒 | 判定为他人遗留、未经用户确认不动（§四专注性） |

## Resources
- forensics/modification-compliance-gap-20261119.md（本任务一手取证底稿）
- /home/terry/.zcode/skills/task-planner/references/worktree-isolation.md（隔离 SOP）

## Visual/Browser Findings
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
