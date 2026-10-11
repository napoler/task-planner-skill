# S5 checkpoint — template-guide.md 计数联动核对（code-assistant）

## 状态
status: COMPLETE（本 S-unit 验收全部通过）
完成时间: 2026-09-20

## 判定（材料包 S5 规则）
- 本任务未新增/删除模板（13 variant 不变），计数锚**无需改动**：
  - L32 `### 2.2 Variant 模板（13 个 — 任务开启期选其一）` 原文保留
  - L60 `**总文件数**:5 核心 + 3 辅助 + 13 variant = **21 个模板**` 原文保留
- 按 S5 第 2 条在 guide §二.2「决策树」指针行（原 L50）末尾追加 1 行指针（纯增量，行尾追加不新增行号），净增 1 行、删除 0 行。

## 改动位置
`skills/task-planner/references/template-guide.md` L50（worktree 内）

改动前（原文）:
```
**决策树**详见 `references/template-mapping.md`;`plan-writer` agent 按关键词自动匹配。
```

改动后:
```
**决策树**详见 `references/template-mapping.md`;`plan-writer` agent 按关键词自动匹配。各类型适用的机制画像见 template-mapping.md §九（Rule 37）。
```

## 验收证据（实际 grep/diff 输出）

### 1) TL-17「13 个」锚（改动后仍命中）
```
$ grep -n "13 个" skills/task-planner/references/template-guide.md
32:### 2.2 Variant 模板（13 个 — 任务开启期选其一）
```

### 2) guide 净增 1 行 / 删除 0 行
```
$ git diff --numstat skills/task-planner/references/template-guide.md
1	1	skills/task-planner/references/template-guide.md
```
diff 为行内 +1/-1（同一行尾追加），净增 1 行，无删除。

### 3) §九 指针落点确认（S3 产出已在 worktree 在位，S5 指针目标有效）
```
$ grep -n "^## 九、" skills/task-planner/references/template-mapping.md
204:## 九、机制适用性矩阵（Rule 37 权威源 — 按 template_type 裁剪机制）
```

### 4) selftest-template-lifecycle.sh 全量运行（worktree 内）
```
$ bash skills/task-planner/scripts/selftest-template-lifecycle.sh
TL-01 PASS Rule 34 头
TL-02 PASS 34.1 选取门控
TL-03 PASS 34.2 四点同步
TL-04 PASS 34.3 沉淀触发三条件
TL-05 PASS 34.4 沉淀流程（≤100 行+登记）
TL-06 PASS 34.5 防滥用（查重）
TL-07 PASS 34.6 机制（开关键+门控+selftest）
TL-08 PASS config.json template_gate_enforce（warn 默认+三档）
TL-09 PASS check-template-type.sh 动态派生白名单
TL-10 PASS attest 集成门控+逃生
TL-11 PASS init-session env 兜底+动态派生
TL-12 PASS 行为: bugfix 计划 exit 0
TL-13 PASS 行为: nonexistent 计划 exit 1
TL-14 PASS SKILL.md 检查清单 C22 行
TL-15 PASS SKILL.md「模板选取门控与沉淀」段
TL-16 PASS template-mapping.md Rule 34 门控提示
TL-17 PASS template-guide.md 含 rule-enhancement 且计数 13 个
Total: 17 PASS=17 FAIL=0
EXIT=0
```
全量 17 断言 0 FAIL，TL-17 命中。

## worktree 全局 git status --short（S5 时点）
```
 M skills/task-planner/references/template-guide.md   (S5 本行)
 M skills/task-planner/references/template-mapping.md (S3 已交付)
 M skills/task-planner/templates/task_plan.md         (S4 已交付)
```
S5 只写 guide + 本 checkpoint，未触碰其他文件。逐 Phase git commit 由主进程编排（Phase 2 收尾时统一提交），本子代理不 commit。

## 负结果报告
- 检查依赖文件: template-guide.md 全文、selftest-template-lifecycle.sh 全文（TL-17 断言 L80-82）、template-mapping.md §九 标题 grep
- 未发现冲突: guide 计数锚与总数锚均未被 S3/S4 触碰；TL-17 双锚（rule-enhancement + 「13 个」）改动前后均命中
- 排除风险: FMEA R2（TL-17 计数断言被 §九 联动改坏）已排除——本任务未改模板数量，锚原样保留，selftest 实测 0 FAIL

## 8 字段返回（供主进程）
1. status: COMPLETE
2. files_written: [skills/task-planner/references/template-guide.md (worktree, 行尾 +1 指针), plans/task-v085-task-type-mechanism-profile/subagent-state/6-code-assistant.md]
3. key_outputs: TL-17「13 个」锚保持命中；guide L50 行尾追加 §九 指针（净增 1 行/0 删除）；selftest-template-lifecycle 全量 17 PASS / 0 FAIL / exit 0
4. evidence: 见上「验收证据」节四条实际输出
5. issues: 无
6. next_step: 主进程对 Phase 2 做逐 Phase git commit（guide+S3+S4 三文件），随后按登记表派发 S6（json-edit-agent, config 新键）
7. checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v085-task-type-mechanism-profile/subagent-state/6-code-assistant.md
8. verify_hint: 主进程 Read guide L50 核对指针行 + `bash skills/task-planner/scripts/selftest-template-lifecycle.sh` 复核 Total: 17 PASS=17 FAIL=0；`grep -n "13 个" skills/task-planner/references/template-guide.md` 须命中 L32

## 缺陷修复记录（主进程复核反馈，2026-09-20）
缺陷：L50 行尾指针句被重复写入两次（`各类型适用的机制画像见…Rule 37。` ×2）。
修复：Edit 删除重复一句，保留原句 + 指针句各一次（净增语义 1 处）。

修复后 `git diff skills/task-planner/references/template-guide.md` 实际输出：
```
diff --git a/skills/task-planner/references/template-guide.md b/skills/task-planner/references/template-guide.md
index 8c4c3d3..9c87d0c 100644
--- a/skills/task-planner/references/template-guide.md
+++ b/skills/task-planner/references/template-guide.md
@@ -47,7 +47,7 @@ task-planner 提供 **双层优先级** 的模板机制：
 | `variant/schema-migration-type.md` (v2) | DB schema 变更 | 可逆 up/down / 数据零丢失 |
 | `variant/rule-enhancement-type.md` (v2,沉淀) | 技能规则增强/新增 Rule/门控守护 | 条款锚 / 三档键 / selftest 守护 |
 
-**决策树**详见 `references/template-mapping.md`;`plan-writer` agent 按关键词自动匹配。
+**决策树**详见 `references/template-mapping.md`;`plan-writer` agent 按关键词自动匹配。各类型适用的机制画像见 template-mapping.md §九（Rule 37）。
 
 ### 2.3 辅助模板（v2.1 新增）
```
复核证据：
```
$ grep -c "机制画像" skills/task-planner/references/template-guide.md
1
$ bash skills/task-planner/scripts/selftest-template-lifecycle.sh | tail -2
TL-17 PASS template-guide.md 含 rule-enhancement 且计数 13 个
Total: 17 PASS=17 FAIL=0
$ grep -n "13 个" skills/task-planner/references/template-guide.md
32:### 2.2 Variant 模板（13 个 — 任务开启期选其一）
```
状态：修复完成，status 维持 COMPLETE。
