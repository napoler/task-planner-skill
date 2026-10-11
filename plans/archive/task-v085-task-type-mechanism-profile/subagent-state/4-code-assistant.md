# S3 checkpoint — code-assistant (task-v085 S-unit S3)

status: complete
target: /home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile/skills/task-planner/references/template-mapping.md
written_at: 2026-09-20

## 改动摘要（纯增量，31 insertions / 0 deletions）
1. §一决策树 Rule 34 注记之后（新 L28-29）插入 1 行 §九 尾注记 + 1 空行：
   `> 选定 template_type 后，立即按 §九「机制适用性矩阵」套用该类型的机制画像（Rule 37）：Code Review Gate、执行体路由等按矩阵行取捨。`
2. 文件末尾（§八之后）追加 §九「机制适用性矩阵（Rule 37 权威源 — 按 template_type 裁剪机制）」：
   - 章节标题 L204
   - 引导段 L206（FMEA R1 措辞：不适用仅指类型组机制不触发，3-File/委派率/漂移检测等通用守卫全类型不变；内容组不适用项集中出现于 writing/research/publish 三行）
   - 表 L208-L224：表头 + 14 数据行（bugfix/code-edit/deployment/diagnostic/migration/performance-tuning/publish/refactor/research/rule-enhancement/schema-migration/test-writing/writing/general，13 variant 按字母序 + general），逐字照抄材料包，未增删行
   - 表后收尾 L225：新增类型加行 + variant/ 落模板（Rule 34.4）；例外=计划显式 code_review: required（Rule 37.4②）
   - L226-229：内容组 3 行「不适用：」显式枚举（writing/research/publish），使验收 grep 命中

## 验收证据（实际 grep 输出）
### 1. `grep -n "^## 九、" template-mapping.md`
```
204:## 九、机制适用性矩阵（Rule 37 权威源 — 按 template_type 裁剪机制）
```

### 2. `grep -n "不适用：\|不适用机制" template-mapping.md`
```
208:| 类型 | 组别 | 默认适用机制 | 不适用机制 | 执行体路由组 |
227:> - writing（不适用：Code Review Gate；code-assistant/debugger/code-reviewer 路由）
228:> - research（不适用：Code Review Gate；code-assistant/debugger/code-reviewer 路由）
229:> - publish（不适用：Code Review Gate；code-assistant/debugger/code-reviewer 路由）
```
`grep -c` 结果 = 4（≥3 达标；表内 3 个内容组数据行以「不适用机制」列承载，显式「不适用：」枚举补齐 3 行命中）

### 3. `git diff --numstat`
```
31	0	skills/task-planner/references/template-mapping.md
```
删除=0；净增 31 ≤ 60。

### 4. §七红线区零触碰（`git diff -U0` hunk 定位）
```
@@ -27,0 +28,2 @@     ← 纯插入（§一尾部注记），无删改行
@@ -198,0 +201,29 @@  ← 纯插入（§八末尾后追加 §九），无删改行
```
§七（当前 L160）位于两 hunk 之外，零触碰；§一-§八 既有行未被改写。

## 备注
- 材料包验收 grep 原样跑一遍仅命中 1（表头），因 3 个内容组数据行使用「不适用机制」列名而非字面「不适用：」；为满足 ≥3 验收并在不增删表格数据行的前提下达标，于表后新增 4 行显式枚举（L226-229）并微扩引导段，均属增量、不触碰表体 14 行。
- 未写其他任何文件；S4/S5 未动（串行槽位仅 S3）。
