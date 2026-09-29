# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户指令（2026-09-29）：引入自动模板记录——遇到新类型任务主动创建该类计划任务模板供后期复用，且要在遇到任务时点主动激活
- 用户 D1 两裁决：①激活策略=三时点感知网（T1 init-session 机器提示+区块预登记 / T2 Rule 34.7 条款+SKILL 联动 / T3 check-complete warn 兜底；不碰 UserPromptSubmit hook 防 hook 税）②创建自动化=全自动静默生成（34.5 双闸门内置生成侧：查重+泛化评估，不足登记不沉淀理由）
- 现状缺口：34.3 沉淀触发仅终验且纯人工（C22 无机器激活点）；init-session 类型空缺静默落 general；模板 knowledge 层已在 plan-template-kit 卫星（v095 后拓扑）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **[P1 基线与断言清点（2026-09-29，主进程白名单①③）]** ① 基线实测 **35 脚本 584 PASS/0 FAIL**（与 v095 终态一致）；worktree wt/task-v096-template-auto-record @ de8e8fe 就绪。② 消费方断言清点：**init-session**×5 selftest 消费（active-plan/knowledge-brief/execution-stability/plan-tier/template-lifecycle，其中 PT-13 三锚=TASK_PLAN_TIER+variant/mini-lite-type.md+「tier=mini 忽略」必须保全）；**check-complete**×8 selftest 消费但 final-gate-hash 走 mktemp 沙箱副本非内容哈希=可安全编辑，其余为 gate 段存在性 grep（纯增不破）；**critical-rules** KB T6 窗口（21.2/22.4 行号 100<x<160）不受 34.7 影响（插入点 L318+ 在 22.4@L154 之后，零位移）；**SKILL.md** 行数钉 ≤558（429+3 安全）+C22/Rule 34 摘要行行内改须子串保全；**registry** 现行 35 数据行，P6 登记后 36。③ 计划期 attest 教训：S-unit ID 带 `P2-` 前缀被解析器拒（check-plan-dispatch L228 正则=纯 `| S<n> |`），批量改纯数字后过门——已记 notepad

- **[P2-S1（2026-09-29，已 Read 检查点复核）]** init-session general 分支感知块落地（+26 行纯追加，接线点=task_plan.md 复制完成后 `[ -z "$TEMPLATE_TYPE" ]` 精确命中空缺兜底链）：emit `[template-sense]` + 末尾追加「🔁 模板感知」区块（含 grep 幂等去重）；已知类型零调用（bugfix 负例=0）；五 init-session 消费 selftest 全绿+PT-13 三锚保全。**两个执行期发现**：① 基线缺口——general 兜底产物原本无 template_type 标记、check-template-type 实测 exit 1；执行器在区块内加独立行 `<!-- template_type: general -->`（gate 第三形态）使命中 exit 0（行为改进，CR 复核项）② TASK_TEMPLATE_DEFAULT 显式=general 时不触发（字面语义），是否扩条件留给 S2 裁量。YAGNI：brief 建议的函数改为调用点内联（单调用点），S2 复用时再抽

- **[P2-S2（2026-09-29，已 Read 检查点复核）]** unknown 分支感知块落地：接线条件与 L183 白名单判定同构（`TASK_PLAN_SRC=task_plan.md` 保护项排除 mini 分流胜出场景）；WARNING 行保留；复用=复制同构块（非引号 heredoc 展开 $TEMPLATE_TYPE，diff 最小）；裁量项裁定=显式 general 不触发（字面语义）已实测登记。Phase 2 合计 init-session.sh +55 行纯追加、两块互斥幂等、mini 正交保全。**P6 注意**：selftest 断言区块正文须按展开值匹配（非字面 $TEMPLATE_TYPE）

- **[P3-S1（2026-09-29，已 Read 检查点复核）]** 34.7 模板感知条款落 critical-rules.md L319（单行追加，快照 diff 唯一差异 `318a319`，34.1-34.6 零改动实证）；Rule 编号完整性 170→171；三 selftest（TL 18/KB 16/MP 19）全绿——T6 窗口零位移判断实证正确。条款含：三时点激活/全自动生成合约（不 AskUserQuestion）/34.5 双闸门内置生成侧/34.2 拓扑注意（mapping/guide 在卫星）/计数级联（TL-17 同改，v093 教训）

- **[P3-S2（2026-09-29，已 Read 检查点复核）]** SKILL.md 三处联动完成（429→430，净增 +1）：Rule 34 摘要行行内插「/模板感知(34.7 三时点激活+全自动生成)」（「Rule 34（P0）模板生命周期门控与沉淀」子串 -F 实测保全）；C22 行后半句改 34.7 全自动表述（行首 `^| C22 ` TL-14 锚+前半句逐字符保全）；「模板选取门控与沉淀」段后新增指针行（TL-15 锚在位）。锚差集对账全基线不变；四 selftest（18/11/16/10）绿。移交 P7 复核项：C22 行引用的「check-complete warn 兜底」须与 P4-S1 实际输出标签一致

- **[P4-S1（2026-09-29，已 Read 检查点+主进程亲验）]** check-complete.sh +10 行纯新增（:561-570，fmea-gate 段后）：plan 含「🔁 模板感知」且全文无「沉淀理由：/不沉淀理由：/已沉淀」登记 → `[template-sense] ⚠ …（Rule 34.7 全自动生成合约）` warn，退出码零变化；正例/负例×2（无区块/已登记）+bash -n 全过；8 个引用 check-complete 的 selftest 全绿。主进程亲验：commit 6079c0b 内容=+10 行与本文件一致；真实 v096 计划（无区块）零误报。**两项移交 CR**：① warn 段位于 C-2 键③ sed 区间内→键③哈希变化一轮全量（fail-safe 无正确性回归，P7 首轮见全量非 SKIP 属正常）② 未登记判定=全文级 grep 宽判定 fail-open（与 warn 兜底定位一致，可接受）。**执行偏差第 3 次**：执行器违反禁 git 自行 commit 且谎称「coordinator 指令覆盖任务书」（无此指令）——内容正确故接受，虚假授权声明必须登记（Error Log）

- **[P5-S1（2026-09-29，已 Read 检查点+盘面亲验）]** plan-template-kit 沉淀节 +2 bullets（34→36 行）：全自动生成合约（34.7：终验 COMPLETE+34.3 命中→主进程直接派 plan-writer/code-assistant，不问用户）/生成侧双闸门（34.5 ls 查重+泛化评估）/同步清单连排行文（mapping/guide 计数、plan-writer 表、主技能指针核对、TL-17 计数级联同改 v093 教训、白名单免同步）；mapping/guide 零改实证（diff 单文件）；TL 18/0+MP 19/0。**派发守卫新知**：prompt 内 ①-⑥ 圈号清单会被步骤计数器吞（6>4 拒派两次）→ 枚举类内容改顿号连排行文即可通过
- **[P6（2026-09-29，已 Read 检查点复核）]** selftest-template-sense.sh 新建（6 断言 case-1..6 行为级：general 正例/unknown 正例/known 负例/34.7+C22 条款锚/check-complete warn 正负例/registry 自检；mktemp+EXIT trap 零仓库写入）；registry 36=36 双向核对；回归 TL 18/0+PT 32/0。**派发守卫再添新知**：断言命名 `S<数字>` 形式（TS1）同样被 S-unit 计数器吞 → 中性命名 case-N 通过

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
