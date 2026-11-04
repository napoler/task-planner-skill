# E 组 spec：Rule 102 落地 + 级联 + hook 五类反思 + selftest 顶锚预放宽（task-crossprojauth-20261104 R5）

任务仓：/mnt/data/dev/task-planner-skill（L0-T 主仓直改，无 worktree；11-03 L0-lite 先例）
检查点：plans/task-crossprojauth-20261104/subagent-state/05-executor-rule102.md（每完成一项追加一行；最终结论必写入）

## 执行顺序（严格）
S1 selftest 顶锚预放宽（G）→ S2 规则段追加（A）→ S3 级联 4 文档（B/C/D）→ S4 hook 编辑（E）→ S5 自检 6 条（F）→ 检查点收尾。
**顺序原因**：S1 先放宽顶锚，S2/S3 落地 1-102/85 条后回归才不炸（纪元顶字面每纪元必炸已知风险族；D 组先例）。

## S1 selftest 顶锚预放宽（3 脚本 4 断言行，全部先于 102 落地）
### G1 `skills/task-planner/scripts/selftest-anti-deferral.sh`
- L86 `ad09="$(cnt '1-101' "$SKILLMD")"` → `ad09="$(cntE '1-(8[0-9]|9[0-9]|10[0-9])([^0-9]|$)' "$SKILLMD")"`（cntE 若该脚本无定义则顶部补一行 `cntE(){ grep -cE "$1" "$2" 2>/dev/null || true; }`，与兄弟脚本同形态；阈值 ≥3 不变）
- L87 ok/bad 消息 `纪元字面 1-101` → `纪元窗 1-(8x|9x|10x)`（消息随动，判据不动）
- L89 `ad10="$(cnt '其余 84 条' "$SKILLMD")"` → `ad10="$(cntE '其余 8[0-9] 条' "$SKILLMD")"`（阈值 ≥2 不变）
- L90 消息同步；L13-14 头 docblock AD-09/AD-10 行补 `[2026-11-04 task-crossprojauth-20261104-R5: 纪元 1-102, 顶锚放宽 10x/8x 窗]`
### G2 `skills/task-planner/scripts/selftest-subagent-activation.sh`
- L65 `sa11="$(cntE '1-101([^0-9]|$)' "$SKILLMD")"` → `sa11="$(cntE '1-(8[0-9]|9[0-9]|10[0-9])([^0-9]|$)' "$SKILLMD")"`（阈值 ≥3 不变）
- L68 `sa12b="$(cnt '其余 84 条' "$SKILLMD")"` → `sa12b="$(cntE '其余 8[0-9] 条' "$SKILLMD")"`（阈值 ≥2 不变；sa12a `cnt '52,59,68,96'` 不动）
- L66/L69 消息随动；L14-15 头 docblock 补 R5 纪元随动行（SA-12 行加「2026-11-04 task-crossprojauth-20261104-R5 84→85，Rule 102 并入纪律域」）

## S2 规则段追加（A）
`skills/task-discipline/references/critical-rules-discipline.md` 文件尾（### 101 段后，现 689 行）追加：
**逐字追加 `plans/task-crossprojauth-20261104/subagent-state/rule102-section.md` 全文**（主进程已审定，勿改写；追加前空一行与上段分隔）。

## S3 级联 4 文档
### B `skills/task-planner/SKILL.md`
- L9 `Rules 1-101 全集索引` → `Rules 1-102 全集索引`；同行 `其余 84 条` → `其余 85 条`
- L210 `Rules 1-101 全集索引` → `Rules 1-102 全集索引`；`其余 84 条` → `其余 85 条`；纪律域枚举 `Rule 85/86/87/88/89/90/92/93/94/95/97/98/99/100/101 纪律域` → `…101/102 纪律域`
- L253 `核心域 1-101 全集索引` → `核心域 1-102 全集索引`
### C `skills/task-planner/references/critical-rules.md`
- L194 task-discipline 路由行：枚举 `…,99,100,101）` → `…,99,100,101,102）`；「调用条件=」句末（…git 使用加强相关时。）补「新请求计划同步反思/取消撤销文档同步/打断接续顺序执行相关时」
### D `skills/task-discipline/SKILL.md`
- L15 `…git 使用加强纪律等共 51 条` → `…git 使用加强纪律、新请求计划同步与反思门纪律等共 52 条`
- L24 `（Rule 4,6,…,100,101）` → `（…100,101,102）`
- L82 表 `| 101 | git 使用加强纪律 | …` 行后加表行 `| 102 | 新请求计划同步与反思门纪律 | \`references/critical-rules-discipline.md\` \`### 102\` 段 |`
- L84 `Rule 101（task-crossprojauth-20261104-R3 git 使用加强纪律——…）已后补落盘——本索引现共 51 条` → 在 101 括注后追加 `、Rule 102（task-crossprojauth-20261104-R5 新请求计划同步与反思门纪律——五类判定+计划优先门+取消同步+痕迹累积）已后补落盘——本索引现共 52 条`
- L95 `51 条规则全文（含后补落盘的 Rule 85/…/101）` → `52 条规则全文（…101/102）`

## S4 hook 编辑（E）`skills/task-planner/scripts/zcode-userpromptsubmit.sh`
保持 fail-open、`n` 计数逻辑（L263-266）、CA-1 重注入限流（inject_interval 面 L125-129 及 smart_inject 相关分支）**全部不动**。改动 4 处：
1. **L14 头注释**：`节流:第 1 条 + 每 prompt_note_interval 条一次;已完结计划(COMPLETE/BLOCKED)静默。` → `note: 每 prompt 触发一次五类反思提示(2026-11-04 R5 Rule 102.4); prompt_note_interval 键失活(保留避免 config 面变动); 重注入块 CA-1 mtime+interval 限流不变; 已完结计划(COMPLETE/BLOCKED)静默。`
2. **L268 限流门**：`if [ "$n" -eq 1 ] || [ $(( n % interval )) -eq 0 ]; then` → `if [ "$n" -ge 1 ]; then  # [2026-11-04 R5 Rule 102.4] note 每 prompt 触发(与 10 计数限流解耦); interval/prompt_note_interval 键失活保留`
3. **E 类取消关键词检测**（L271-277 `_near_ref` 块内追加，同 case 风格、同一 `$_ups_prompt_np` 变量）：
   ```bash
   _cancel_ref=0
   case "$_ups_prompt_np" in
     *取消*|*撤销*|*作废*|*不做了*|*不要了*|*放弃*|*停掉*|*不继续做*|*不开发这个*) _cancel_ref=1 ;;
   esac
   ```
   （检测块位置：`_near_ref` case 之后；仅当 `$_ups_prompt_np` 非空时检测，沿用 L273 guard）
4. **note 文案三选一**（L278-282）改为：
   ```bash
   if [ "$_cancel_ref" = "1" ]; then
     note="[取消/E 类] [plan-note] 检测到取消/撤销指令 — 先同步文档再推进(Rule 102.1e): 单项取消=在 task_plan.md 对应 Phase/VC/需求行标 cancelled(不删条目,保留审计痕迹+一行理由); 整体取消=task_plan.md 头部 outcome: CANCELLED+全部未完成 VC 标 cancelled(理由); Decisions Made 必填(指令摘要→E 类判定→受影响文档→理由→时间戳); 既有产物/分支未明示清理=保留登记。口头取消不落盘=P0 违规(Rule 51.1/102.2)。"
   elif [ "$_near_ref" = "1" ]; then
     note="[邻近引用→B 类] [plan-note] 新指令到达 — 先做影响判定: 检测到同文件邻近行引用词(第 N 行/上一句/继续/接着等),归为 B 类(扩展)而非 D 类(新计划); 先 Edit task_plan.md 更新 Phase/VC/范围 + 同步 Todo(S5) 落盘后再执行; D 新任务边界(与当前 Goal/范围/交付物均无关联)→开新计划目录,旧任务记录断点检查点; A 无影响→照常; E 取消/撤销→102.1e 文档同步。禁止口头接受不落盘(Rule 8.1/102.2)。"
   else
     note="[plan-note] 新指令到达 — 先做反思门(Rule 102.0): A 无影响→照常执行(登记一行); B 扩展/C 矛盾→先同步文档(task_plan.md Phase/VC/范围 + progress/需求锚 + Todo S5)落盘后再按文档执行; D 新任务边界→开新计划目录+旧任务断点检查点(打断接续: 在途单元做完或显式挂起登记); E 取消/撤销→标 cancelled 不删条目+Decisions Made 理由。B/C/D/E 先落盘后执行;口头接受不落盘=P0 违规(Rule 8.1/51.1/102.2)。"
   fi
   ```
   （原「不相干内容禁止混入当前计划(Rule 8.1)」语义保留在 B/E 两条内；文案中的「取消」字面共 ≥2 处满足 VC③）

## S5 自检 6 条（全部跑一遍并把输出摘要写检查点）
V1 `grep -c '^### 102' skills/task-discipline/references/critical-rules-discipline.md` = 1
V2 `grep -c '1-102' skills/task-planner/SKILL.md` ≥3 且 `grep -c '其余 85 条' skills/task-planner/SKILL.md` = 2 且 `grep -c '共 52 条' skills/task-discipline/SKILL.md` ≥1
V3 `grep -c '取消' skills/task-planner/scripts/zcode-userpromptsubmit.sh` ≥2 且 `grep -n 'n % interval' skills/task-planner/scripts/zcode-userpromptsubmit.sh` 无命中（note 门控已解耦；`inject_interval` CA-1 面保留=`grep -c 'inject_interval'` ≥2）
V4 语法：`bash -n skills/task-planner/scripts/zcode-userpromptsubmit.sh && bash -n skills/task-planner/scripts/selftest-anti-deferral.sh && bash -n skills/task-planner/scripts/selftest-subagent-activation.sh` 全 rc=0
V5 `bash skills/task-planner/scripts/selftest-anti-deferral.sh` 与 `bash skills/task-planner/scripts/selftest-subagent-activation.sh` 各 rc=0（顶锚放宽后对 1-102/85 条应全 PASS——这是 S1 先行的验证点）
V6 `bash skills/task-planner/scripts/zcode-userpromptsubmit.sh` 冒烟：无活跃计划态下直接跑（cd 到本仓）应静默 exit 0 无输出（fail-open 未破坏）
完成后写检查点 05：S1-S5 逐项 + 输出摘要 + 任何偏差登记（勿越 spec 改写 rule102-section.md 与级联字面；偏差=登记不擅改）。

## 禁改清单（管辖边界）
- `rule102-section.md` 内容不得改写（逐字追加）
- config.json 不动（零新键、AD-11 键数=53 守护不破）
- 其他 24 个宽容窗 selftest 脚本（`1-(8[0-9]|9[0-9]|10[0-9])` 窗已覆盖 1-102，勿动）
- Rule 8/8.1/8.1.1/10 既有段原文零改动（36.5 管辖二分）
- 宪法 AGENTS.md / §六 保护区不动
