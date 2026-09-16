# 检查点 01 — Explore 结构侦察结论（task-v079 计划期）
> 代理: Explore(agent_907443c6) 完成于 2026-09-17 05:40 前后；代理无 Write 工具，由主进程代为落盘（内容=代理返回消息全文整理）。
> 用途: Rule 36「技能修改保守化与功能删除防护」设计的结构惯例依据。

## 1. references/critical-rules.md
- 总行数：300 行；最大 Rule 编号 = **35**（`### 35 执行结论纪律` @ line 292）
- Rule 31（错误学习闭环）@ lines 249-258，范式：`### 31 错误学习闭环（P0 — task-v072，目标：…）` + 引言段 + 31.1 触发（①②③④）/31.2 结构化根因分析（4 维归因表：现象/直接原因/根因 5 Whys ≤5 层/类别=信息缺失|假设未验|规则缺位|数据源过时|执行偏差；**分析未完成禁止执行修复动作**）/31.3 修正路由（**「技能规则本体（critical-rules.md）缺口 → 登记 Decisions Made + 提案写 notepad『Notes for Next Time』（宪法 §六 保护区，本体修改走后续任务）」@ line 255**）/31.4 沉淀（notepad 两段+Error Log Prevention 列）/31.5 消费侧（Learning Gate: Error Log Root Cause 列非空）/31.6 机制（config#error_loop_enforce 默认 warn + selftest-error-loop.sh + 模板联动）
- Rule 32（用户否决与禁令追踪）@ lines 260-268：32.1 禁令登记（veto: 行+notepad「🚫 被否决方案」段双写）/32.2 计划期消费（提方案前必查三禁令源）/32.3 执行期消费/32.4 解禁仅两条（显式 veto-lift 或新证据标注否决出处，禁静默改回）/32.5 机制（config#veto_enforce 默认 warn + selftest-veto.sh + C20）
- Rule 26 惩罚映射表 @193-199：`| 触发 | 处置 |` 表头；例 `| Q3 证据不实 | 最高档:不得自判 COMPLETE/PARTIAL,以 BLOCKED 上报 + STOP 等用户裁决 |`

## 2. config.json（416 行，JSON Schema draft-07，键在 properties 下）
- 顶级键 28 个 + subagent 对象；required 含 subagent 等 6 键；**additionalProperties: false → 新键必须同时进 properties**
- **14 个三档 `*_enforce` 键全部默认 "warn"**：content_quality/fmea/skill_collab/knowledge_brief/hook_self_heal/vc_gate/rescue_chain/context_hygiene/plan_hygiene/shared_tracker/error_loop/veto/reflect_verify/template_gate
- 例外：delegation_enforce 两档默认 enforce；dispatch_contract_enforce 三档默认 enforce
- 命名模式 `<域>_<对象>_enforce`；description 单行含「Rule NN 三档: enforce=…; warn=…; off=…」（近期先例 reflect_verify_enforce/template_gate_enforce @ lines 299-310 短描述风格）
- 档位解析范式：`env TASK_PLANNER_X_ENFORCE > config.json#X > warn`

## 3. scripts/ 清单与 selftest 范式
- check-*.sh 12 个：3file-gate/complete/conflicts/context-hygiene/delegation/dispatch/doc-sync/drift/plan-dispatch/rescue-chain/scope/template-type
- selftest-*.sh 20 个：active-plan/conclusion-discipline/context-hygiene/delegation/dispatch/error-loop/execution-stability/fallback/interaction/knowledge-brief/methodology/plan-dispatch/reflect-verify/rescue-chain/shared-tracker/skill-collab/smart-merge/template-lifecycle/vc-gate/veto
- selftest-veto.sh 范式：头部逐条 VT-01..13 注释 + PASS/FAIL 计数 + `ok/bad` 双函数 + 宽容锚 `Rules 1-3[1-5]` + config 键 python3 json 校验 + `| C20 |` grep 断言 + 结尾 `exit $((FAIL > 0))`
- selftest-conclusion-discipline.sh 变体：`check(){ eval; }` 单函数 + Total/PASS/FAIL 计数

## 4. check-complete.sh（834 行）GATE 顺序
porcelain 预检(27.3) → python 主段(3-File/19.6/18.6/23.6/全 complete) → DELEGATION(25.4) → PLAN-DISPATCH(22.6) → FMEA GATE → RESCUE-CHAIN → VC-GATE → LEARNING GATE(31.5) → REFLECT GATE(33) → warn 计数 → `exit $python_rc`
- 统一范式 `resolve_X_tier(){env>jq config>warn}`；enforce FAIL = stderr `[plan] X-GATE FAILED (task-vXXX Rule NN: …)` + exit 1；warn = 同文案+「warn 档不阻断…可升级」
- 新增 GATE 先例：LEARNING/REFLECT 均为 python 主段后追加 shell 段，锚点注释带 task 代号

## 5. SKILL.md（538 行）联动锚
- `## Critical Rules` @276 起；开头「（Rules 1-35）」；每条格式 `- **Rule N（P0）标题**：子条(NN.1)/…——链路一句话；开键 config.json#xxx_enforce（默认 warn，详见 references/critical-rules.md Rule N）`
- 合规清单最大 **C23**（无 C24+）；C19/C20/C23 格式=触发场景+门控+不适用记一行语义 `| ☐ |`
- 级联锚清单：frontmatter references 行、L278「Rules 1-35」、L327 References 表、README.md:67、batch-quality-gate.md「隶属 Rules 1-35」；CD-11 断言 `1-35` 计数≥3 / CD-12 断言 `1-34`=0（锚级联维护范例）
- 其他锚：L25「技能文件修改需逐项授权」；L386 反模式行；路由表 L372；L214-217 用户新指令处理段（Rule 31/32/33/34 特判指针块——Rule 36 指针段加在此）

## 6. templates/variant/rule-enhancement-type.md（79 行）Phase 骨架
P1 隔离与基线（主进程白名单①+code-runner）/ P2 条款+config+门控（executor sonnet-1 串行+S-unit 7 列表：|ID|目标|执行体|输入|验收|预估时长|状态|）/ P3 selftest+锚点修复（executor）/ P4 SKILL 联动+四点同步+全量回归（executor）/ P5 合并回+部署+簿记（主进程白名单①②）；VC-5=3 实体位 diff=0；强制约束「SKILL 净增 ≤10 行」「改 Rules 1-N 前 grep -rn "Rules 1-" scripts/ 全修齐」

## 7. 既有保护条款（防重复冲突）
- **critical-rules.md:255（31.3）**「本体修改走后续任务」= 最直接先例，Rule 36 须显式引用衔接
- Rule 14:53 / 25.3:171 六项白名单覆盖「谁改」，未覆盖「保守化/删功能=高危」；SKILL.md:25 一句总纲
- grep「删除.*功能」零命中 = 语义空白区，无锚冲突；grep「保守」仅脚本注释，无关

## 8. hook 接线模式
- config.json 无 hooks 字段；注册在平台侧（register-hooks-cj.ts）
- PreToolUse 链：zcode-pretooluse.sh（stdin JSON→jq 提取 tool/file）→ check-scope.sh（rc=1→exit 2）→ Write/Edit/ApplyPatch→check-delegation.sh pretool（rc=2→exit 2）/ Agent→check-dispatch.sh → Rule 23 冲突警告（不阻断）
- check-delegation 白名单：plans/ 祖先(.md/.json)、$SKILL_ROOT 自身、memories、≤3 行 trivial、allow-direct 30min TTL；**sid ≠ .session-owner（子代理）→ exit 0 放行（子代理不受 delegation 拦截——新守卫需自行覆盖子代理）**
- check-scope：哨兵机制+文件名 case 豁免表+D10 仲裁；0=ALLOWED/1=BLOCKED（适配器映射为 2）
- 新守卫接线点 = zcode-pretooluse.sh Write/Edit 分支内追加 check-skill-modify.sh；配置键 skill_modify_enforce 三档默认 warn
