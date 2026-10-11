# P2-S1 executor 检查点 — init-session.sh general 分支模板感知块

- status: success
- 时间盒: 用时 <15min
- 产出文件: /mnt/data/dev/task-planner-skill-worktrees/task-v096-template-auto-record/skills/task-planner/scripts/init-session.sh（唯一代码文件，+26 行纯追加）

## 实现摘要

接线点：task_plan.md 复制完成之后（原 L268-271 块尾，"echo """ 之前），条件 `[ -z "$TEMPLATE_TYPE" ] && [ -f "task_plan.md" ]`：
- L149-165 空缺兜底链走到缺省 general（TEMPLATE_TYPE 全程为空）→ emit 一行 `[template-sense] ⚠ 任务类型空缺（general 兜底）——按 Rule 34.3②/34.7 评估沉淀，终验必查`
- 向 task_plan.md 末尾追加「🔁 模板感知」区块（标题 + `<!-- template_type: general -->` 机读标记 + 注释说明 + 4 条正文：触发信号 / 34.3② 预登记 / 终验必查 / 处置登记处指向 plan-template-kit 卫星 SOP）
- `<!-- template_type: general -->` 行是 check-template-type.sh 第三形态（HTML 注释）命中项 —— general 兜底产物从 gate INVALID 变 exit 0
- 已知类型（TEMPLATE_TYPE 非空，含 16 类 variant 与项目自造模板）本块零调用，known-type 路径逐字节不变
- 正交性：调用点在 tier 分流（L189-194）与复制之后，mini 档只改 tier 不碰 sense（TASK_PLAN_TIER=mini 且类型空缺 → 区块照常追加到 mini-lite 产物，语义无害；mini+variant 定制场景 TEMPLATE_TYPE 非空 → 本块不触发，PT-17「tier=mini 忽略」提示保全）
- unknown 类型分支（约 L183-186）本 S-unit 未动（P2-S2 范围）
- 幂等：同目录重复 init 时区块 grep 去重不重复追加；但 emit 行每次重跑都会输出（T3 检索 token 可复现，无害）
- 幂等边界：区块追加发生在 6/6 复核之前，非空追加不影响复核

## 验收自验输出

1. 空类型正例（mktemp 临时计划目录）：`bash init-session.sh proj | grep -c "template-sense"` = **2**（≥1 PASS）；task_plan.md 末尾含「🔁 模板感知」区块（tail -9 原文见证据）
2. 负例：`bash init-session.sh proj bugfix` → `grep -c "template-sense"` = **0**；task_plan.md 内「🔁 模板感知」计数 = **0**（PASS）
3. 下游兼容（含区块产物）：`check-template-type.sh task_plan.md` → `[template-gate] OK: template_type=general` **exit 0**；`check-scope.sh Edit /tmp/outside.md` → **exit 0**（无项目根放行）；`check-3file-gate.sh <计划目录>` → **exit 0**（PASS，mtime 判定，区块追加未造成误判）
   - 注：改动前基线 general 兜底产物 check-template-type exit 1（缺失 template_type）——本 S-unit 顺带修复该 gap（区块内注释行提供第三形态标记）
4. `bash -n` OK；五 selftest 全 PASS：plan-tier 32/0、knowledge-brief 16/0、execution-stability 19/0、active-plan 19/0、template-lifecycle 18/0
5. git diff：仅 1 文件 +26 行（下方原文）

PT-13 三锚保全验证：`grep -q 'TASK_PLAN_TIER' && grep -q 'variant/mini-lite-type.md' && grep -q 'tier=mini 忽略'` → selftest-plan-tier PT-13 PASS（32/0 内含）

mini 正交冒烟：`TASK_PLAN_TIER=mini bash init-session.sh proj`（类型空缺）→ template-sense 计数 2、区块 1 份（幂等重跑仍 1 份）

## git diff（init-session.sh，唯一变更文件）

```diff
diff --git a/skills/task-planner/scripts/init-session.sh b/skills/task-planner/scripts/init-session.sh
index 498ee03..918fc57 100755
--- a/skills/task-planner/scripts/init-session.sh
+++ b/skills/task-planner/scripts/init-session.sh
@@ -270,6 +270,32 @@ else
     fi
 fi
 
+# [2026-09-29 task-v096 P2-S1 T1 分支①] template-sense 区块（Rule 34.3② 预登记触发点）：
+# 仅当 TEMPLATE_TYPE 最终决议为 general（类型空缺落 general 兜底）时 emit 提示行并向 task_plan.md
+# 末尾追加「🔁 模板感知」区块。已知 16 类（bugfix 等）零调用，known-type 路径逐字节不变。
+# 区块内同时声明 template_type: general + 34.3② 预登记 → check-template-type 三形态命中
+# （模板本体 task_plan.md 无 template_type 标记，运行时追加而非改本体，§4 条 1 约束）。
+# 正交性（§4 条 10）：本调用点在 tier 分流/复制之后，mini 档只改 tier 不碰 sense；
+# unknown 类型分支（L183-186 区段）本 S-unit 不动（P2-S2）。
+# 追加后幂等保护：同任务目录重复运行 init（task_plan.md 已存在=skip 分支）不重复追加。
+if [ -z "$TEMPLATE_TYPE" ] && [ -f "task_plan.md" ]; then
+    echo "[template-sense] ⚠ 任务类型空缺（general 兜底）——按 Rule 34.3②/34.7 评估沉淀，终验必查"
+    if ! grep -q '🔁 模板感知' "task_plan.md" 2>/dev/null; then
+        cat >> "task_plan.md" <<'EOF'
+
+## 🔁 模板感知
+<!-- template_type: general -->
+<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
+     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
+- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
+- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
+- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
+- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
+EOF
+        echo "    [template-sense] task_plan.md 末尾已追加「🔁 模板感知」区块"
+    fi
+fi
+
 echo ""
 # [2026-09-04 Rule 19.5 配套] 文件存在性复核：缺失或空 → exit 1
 # [2026-09-13 task-v067] 5 文件→6 文件（+knowledge-brief.md）
```

## 风险提示

1. 区块内 `<!-- template_type: general -->` 超出 brief 原文（brief 只列 4 条正文）——为满足验收 3（check-template-type exit 0 且不可改模板本体/known 路径）而必须，属合理扩展，已在区块注释中自我声明
2. 设计取舍：brief 建议的可复用函数 `emit_template_sense_block` 未采用函数形态，改为调用点内联块（单一调用点，YAGNI；若 P2-S2 unknown 分支需复用，届时再抽函数，两个分支语义可不同）
3. TASK_TEMPLATE_DEFAULT 命中 general（经 env 默认落到 general 但 TEMPLATE_TYPE 被赋值为 "general"）的场景不触发本块（TEMPLATE_TYPE 非空）——符合 brief「空缺兜底链」字面语义（仅 L149-165 全链空缺→缺省 general）；若后续要求「决议为 general 一律触发」需扩条件为 `[ "$TASK_PLAN_SRC" = "task_plan.md" ]`，P2-S2 可裁量
4. 重跑 init 时 emit 行重复输出（区块幂等、emit 不幂等）——T3 token 检索场景无害，若要求 emit 亦幂等需加标记判断
5. 测试临时目录（mktemp）自验后未清理（/tmp 下，不影响仓库）；未做 git 操作（遵守硬约束，diff 以 git diff 只读产出）
