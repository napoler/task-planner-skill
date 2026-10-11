# P2-S2 executor 检查点 — init-session.sh unknown 类型分支感知块

- status: success
- 时间盒: ≤15min（实际用时 <15min）
- 产出文件: /mnt/data/dev/task-planner-skill-worktrees/task-v096-template-auto-record/skills/task-planner/scripts/init-session.sh（唯一代码文件，本 S-unit 净增 ~29 行纯追加）

## 实现摘要

接线点：P2-S1 块（L273-297 区）之后、`echo ""`（Rule 19.5 复核段）之前，调用点在 task_plan.md 复制完成之后：
- 判定条件（与 L180/L183 白名单判定同构）：`[ -n "$TEMPLATE_TYPE" ] && ! echo " $VALID_TYPES " | grep -q " $TEMPLATE_TYPE " && [ "$TASK_PLAN_SRC" = "task_plan.md" ] && [ -f "task_plan.md" ]`
  - TEMPLATE_TYPE 非空 ∧ 不在 VALID_TYPES（含项目级并入扩展）∧ 最终复制源仍是 generic task_plan.md
  - L183-186 WARNING 行为原样保留不删（L184-185 逐字节未动）
- emit 措辞区分：`[template-sense] ⚠ 任务类型未知（$TEMPLATE_TYPE 不在白名单）——将落 general 兜底，按 Rule 34.3②/34.7 评估沉淀，终验必查`
- 追加同款「🔁 模板感知」区块：机读注释行同款 `<!-- template_type: general -->`（unknown 最终落 general 产物，gate 第三形态命中）；区块正文与注释行区分 unknown 语义（触发信号=显式类型 X 不在白名单；注释行标 task-v096 P2-S2，正文 `$TEMPLATE_TYPE` 变量展开故该块用非引号 heredoc `<<EOF`，P2-S1 块仍为 `<<'EOF'`）
- 幂等去重与 P2-S1 同款 `grep -q '🔁 模板感知'`
- 与 P2-S1 块互斥（P2-S1 为 `-z TEMPLATE_TYPE`、P2-S2 为 `-n`）；两分支语义不重叠
- 未抽函数（P2-S1 裁量项②「S2 复用时再抽」的处置）：选**复制同构块**而非抽函数——区块正文需区分 unknown 措辞与 `$TEMPLATE_TYPE` 变量展开，抽函数需 3+ 个变量入参且两块 heredoc 引导符不同，diff 最小=同构复制块（P2-S1 块零改动，known-type 路径逐字节不变）

## 裁量项处置（TASK_TEMPLATE_DEFAULT 显式=general）

**维持不触发**（字面语义=用户显式选了 general，不算空缺/未知）。理由：
- P2-S1 块按 brief「空缺兜底链」字面语义以 `-z TEMPLATE_TYPE` 精确命中全链空缺→缺省 general；TASK_TEMPLATE_DEFAULT=general 时 TEMPLATE_TYPE 被赋值为 "general"（非空、在白名单内），与「显式 positional general」同义——都是用户显式选定合法类型
- 扩条件为「决议=general 一律触发」（如 `[ "$TASK_PLAN_SRC" = "task_plan.md" ]`）会把合法显式选择稀释为 unknown 信号，削弱 34.3② 预登记的意义（general 是 16 类之外的兜底命名而非未知类型）
- 行为差异（已实测登记）：TASK_TEMPLATE_DEFAULT=general 时输出仅路由行 `Template routing: 未显式给 template_type, 采用默认模板 general (env TASK_TEMPLATE_DEFAULT, task-v086 S6)`，无 [template-sense]、无区块
- P2-S2 块同样不触发（general 在 VALID_TYPES 内），与 S1 行为一致

## 验收自验输出（原文留证）

1. a. 未知类型正例（mktemp 计划目录，`init-session.sh proj foobar`）：
   - `WARNING: unknown template_type 'foobar' — valid: general bugfix ...`（原 WARNING 保留）
   - `[template-sense] ⚠ 任务类型未知（foobar 不在白名单）——将落 general 兜底，按 Rule 34.3②/34.7 评估沉淀，终验必查`
   - `    [template-sense] task_plan.md 末尾已追加「🔁 模板感知」区块`；task_plan.md 末尾含区块、区块计数=1、exit 0
   - gate：`check-template-type.sh task_plan.md` → `[template-gate] OK: template_type=general` exit 0
2. b. 负例 `init-session.sh proj bugfix`：`grep -c template-sense` = 0；task_plan.md 区块计数 = 0；gate OK template_type=bugfix exit 0
3. c. 幂等：同目录 foobar 重跑，区块计数 first=1 second=1（不重复追加）
4. c. mini 正交：`TASK_PLAN_TIER=mini` + foobar → mini 分流胜出（`task_plan.md <- variant/mini-lite-type.md`），区块计数=0（产物非 general 不触发，判定条件中 TASK_PLAN_SRC 保护项生效）
5. c. `bash -n` OK；五 selftest 全 PASS：plan-tier 32/0、knowledge-brief 16/0、execution-stability 19/0、active-plan 19/0、template-lifecycle 18/0
6. d. git status/diff（只读查询）：仅 `M skills/task-planner/scripts/init-session.sh`，1 file changed, 55 insertions(+)（含 P2-S1 未提交 +26，本 S-unit 净增 ~29）
7. PT-13 三锚保全：`grep -c "TASK_PLAN_TIER\|variant/mini-lite-type.md\|tier=mini 忽略"` = 7（三锚全在）；L184-185 WARNING/Falling back 行逐字节未动；known-type 路径（L180-194 路由与 tier 分流、复制段）零改动

## 风险提示

1. P2-S1 块内注释行「unknown 类型分支（L183-186 区段）本 S-unit 不动（P2-S2）」在 P2-S2 落地后语义过时（历史注记，P2-S2 新块注释已自我声明范围）——按最小 diff 原则未改 S1 块；若 verifier 认为需更新该注释行，属本文件 1 行内改动
2. P2-S1 的 +26 行在本 worktree 尚未 git 提交（commit 属 Phase 级动作，由主进程执行）——git diff 的 55 insertions = P2-S1(26) + P2-S2(~29)，两者合并提交即可
3. P2-S2 heredoc 用非引号 `<<EOF`（变量展开 $TEMPLATE_TYPE）——若未来类型值含 shell 特殊字符无法经由位置参数安全到达（类型名源自模板文件 basename，白名单派生），无实际注入面；区块内展开值与 emit 行同源
4. 测试临时目录 /tmp/t96a~e 已清理
