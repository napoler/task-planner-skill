# [REVIEW] S7 独立复检 + alignment 对齐审查（全新视角，未参与前期执行）

**时间戳**: 2026-11-13T02:10:00+08:00  
**审查对象 worktree**: /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112（commit 9162a3f）  
**对照材料**: plans/task-docmod-recheck-20261112/findings.md（§Rule106 草案+§todo 契约草案+§1 判例）、task_plan.md（CA-1~CA-10）

## 1. 逐字一致性（discipline 新增 Rule 106 段 vs findings §Rule106 草案）
结论：**基本一致，仅格式对齐差异，无语义偏移**。

- findings §Rule106 草案（原文）与 worktree `skills/task-discipline/references/critical-rules-discipline.md:721-734` 完全一致：标题、判例锚、106.1-106.5 全文、B1-B5 列表、门禁挂钩、Why 均逐字相符。
- 唯一差异：findings 将 "Rule 106 文档修改复检纪律（...）" 作为 "Rule 106 草案" 段落标题，落地文件同样保留完整标题和判例锚。**无语义偏移**。

证据：`plans/task-docmod-recheck-20261112/findings.md:197-255` vs `worktree/skills/task-discipline/references/critical-rules-discipline.md:721-734`

## 2. 边界互洽（重点）
### 2.1 106.1 豁免口径 vs SKILL Rule 20.5 行尾追加句（是否自洽无循环）
结论：**自洽，无循环**。

- SKILL.md:152 追加：`（20.5 豁免写入确认型重读；跨字段一致性复检不豁免，见 Rule 106.1）`
- 106.1 明确区分："20.5 豁免「确认写入成功」型重读（内容仍在上下文），不豁免「跨字段一致性」型复检（校验对象在本次修改点之外、上下文中未必有）"
- 边界清晰，非循环引用（106.1 定义例外，20.5 定义豁免范围，两者互补）。

证据：`worktree/skills/task-planner/SKILL.md:152`, `worktree/skills/task-discipline/references/critical-rules-discipline.md:723`

### 2.2 106.3（≥2 次全量回归）vs 67.1（≥3 次上下文压力）分工是否清晰无重叠
结论：**清晰无重叠，互补**。

- 106.3 管理"同文件二次修改后的**一致性回归**"（全文档不变量校验，过程期复检面升级）
- 67.1 管理"≥3 次往复"的**上下文压力评估与升级**（评估视角，非一致性回归门禁）
- 106.3 显式标注："与 Rule 67.1 分工：67.1 管「≥3 次往复」的上下文压力评估与升级，106.3 管「≥2 次修改后」的一致性回归，互补不替代。"

证据：`worktree/skills/task-discipline/references/critical-rules-discipline.md:727`, `worktree/skills/task-discipline/references/critical-rules-discipline.md:380,727`（交叉引用）

### 2.3 106/106.5（过程期）vs verification-gate 84.3/84.5/84.7/84.14（终验期）互指句是否禁互吞成立
结论：**成立，分工清晰且禁互吞**。

- verification-gate 新增：`**过程期文档修改复检（改后即刻）= Rule 106（task-discipline 卫星）**；本域 84.x 仅覆盖终验期——过程期与终验期分工，禁互吞。` (line ~56)
- SKILL Phase 循环新增 3i：将过程期动作（106.1/106.3）纳入循环，细则指向 task-discipline Rule 106
- 84.14 明确"全部 Phase complete 之后、outcome 判定之前"，84.7 为"交付物语义审查"（子代理视角），106 为"过程期每次修改即刻复检"。互指单向且限定范围，未形成镜像。

证据：`worktree/skills/verification-gate/references/critical-rules-verification.md:56`, `worktree/skills/task-planner/SKILL.md:105`, `worktree/skills/verification-gate/references/critical-rules-verification.md:59-84`

### 2.4 todo-sync 两组块 vs 既有 S1-S5 契约语义是否零冲突
结论：**零冲突，增量扩展**。

- todo-sync 在 S1 段落后**增量追加** "S1 两组结构（任务组+基线组，Rule 106.5）" 块，原有 S1-S5 编号及动作未改动
- 明确"任务组（Phase 映射，既有规则）+基线组（固定五项 B1-B5，措辞以 Rule 106.5 为准）"，两组同为原生条目
- S3/S4 增加两组回写、基线组丢失重建、B1-B4 门禁要求，均为既有流程的强制细化，未破坏既有契约

证据：`worktree/skills/task-planner/references/todo-sync.md:29-46`

### 2.5 SKILL「3i」步与 3h/84.3 翻转门是否衔接（3i 在 Phase 循环内位置语义正确）
结论：**衔接正确，位置合理**。

- Phase 循环（SKILL.md:95-110 附近）在 3h（"双轮质检与完整性复核（Rule 103）"）后新增 **3i "修改后复检（Rule 106）"**，内容明确过程期动作（106.1、106.3），并指向细则
- 3i 处于循环内（Phase 执行循环），与过程期性质匹配；84.3（Phase 翻转前 V-N 校验）由 B2 挂钩 todo 门禁，3i 负责过程期复检，二者不冲突
- todo-sync 明确 B2 每 Phase 翻转前勾检，符合 84.3

证据：`worktree/skills/task-planner/SKILL.md:105`, `worktree/skills/task-planner/references/todo-sync.md:34`

## 3. 级联正确性
### 3.1 SKILL.md 六锚（1-106×3、路由 ,106、指针段、3i、20.5、Todo 指针）内容与位置
结论：**全部到位，内容正确**。

- 1. **1-106 出现次数**：grep 实测 3 次（符合 EN-06 要求 ≥3）——分布在 3i 描述、todo 同步段、全集索引段
- 2. **路由行含 ,106**：卫星路由表 task-discipline 行尾已追加 `,106`（line 210: "...Rule 105,106）"）
- 3. **指针段**：全集索引段（line 223）明确 "Rule 106 文档修改复检与 todo 驱动对齐纪律域（均 task-discipline 卫星）"
- 4. **3i**：Phase 循环 line 105 正确新增
- 5. **20.5**：line 152 追加豁免边界说明
- 6. **Todo 指针**：line 173 追加 "S1 两组结构（任务组+基线组 B1-B5，Rule 106.5）详见 references/todo-sync.md"

证据：`worktree/skills/task-planner/SKILL.md:105,152,173,210,223`, `grep -o '1-106'` 返回 3

### 3.2 verification-gate:56 互指
结论：**正确，单向且限定范围**。

互指句清晰界定过程期归 Rule 106、终验期归 84.x，避免互吞，符合分工原则。

证据：`worktree/skills/verification-gate/references/critical-rules-verification.md:56`

### 3.3 EN-06 纪元翻转（git show 中该脚本 diff 是否仅纪元语义）
结论：**仅纪元语义，符合预期**。

- selftest-enumerate-first.sh diff 将断言从 `1-105` 翻转为 `1-106`，新增 EN-06 相关检查（含 `grep -c '1-106'`、`',106'` 路由校验），注释也更新为"EN-06 SKILL.md 含 `1-106` ≥3 处 且 discipline 路由行含 `,106'"`
- 无业务逻辑改动，仅维护级联锚与断言阈值，符合 findings §5 "EN-06 断言纪元语义翻转=预期维护面" 的定性

证据：`git -C worktree show HEAD -- skills/task-planner/scripts/selftest-enumerate-first.sh`

## 4. 判例锚
结论：**一致，无夸大**。

- findings §1 明确判例会话：sess_1378b365-f324-4ec0-b6ea-842163462b4e（标题：重构罗布湖钓鱼点剧本大纲与剧情设计），描述三方时间口径矛盾（段标题 40-46s / 台词〔全稿41-45s〕〔全稿46-49s〕/ 段末 46s 拆点），自检字段仍写 PASS，派生值未全链重算导致镜内溢出等
- discipline Rule 106 标题直接引用同一判例："判例=sess_1378b365「G22-05a 三方时间口径不一致仍放行」——段标题 40-46s / 台词〔全稿41-45s〕〔全稿46-49s〕/ 段末 46s 拆点互相矛盾且自检字段仍写 PASS"
- 106.1、106.2、106.3、106.4 的判例均与 findings §1 取证一致（C87 拆分、修复器 v4→v6、整合版 v2.18 vs 用户所见本体两态），表述克制且符合"两态兼容"（106.4 未强行下定本体是否同步的唯一结论）

证据：`plans/task-docmod-recheck-20261112/findings.md:64-100`, `worktree/skills/task-discipline/references/critical-rules-discipline.md:721,723,725,727,729`

## 5. 措辞风险（不可执行/歧义/与 Rule 82 冲突/verification-gate 互指是否越界成镜像）
结论：**总体可执行，无明显越界，风险可控**。

### 5.1 可执行性/歧义
- 106.1 "复检一行留痕 progress.md（`[recheck] 对象×不变量×结论`）" - 格式明确，可执行
- 106.2 "明确以哪一侧为准=source of truth" - 要求锚定基准，操作性强
- 106.3 阈值清晰（≥2 次修改），升级面明确（全文档不变量回归）
- 106.5 B1 定义"持续项：status=in_progress 直至终验，完成判据=期间全部 `[recheck]` 留痕齐备" - 可判定
- 门禁表述（"B1 未勾=修改步不得声称完成" 等）具体且可执行

**轻微歧义（INFO）**：106.5 中"B1 持续项"在 todo 系统中如何表示（持续 in_progress vs 动态更新）需执行时按实际 todo 工具行为处理，但契约已在 todo-sync 明确，影响不大。

### 5.2 与 Rule 82（禁回潮镜像）冲突
结论：**无冲突**。

- Rule 106 落在 task-discipline 卫星，verification-gate 仅一行互指（非镜像副本条款）
- todo-sync 仅追加契约块，未复制全部 S1-S5
- SKILL 仅做指针、锚位、循环接线，无大段规则复述
- 符合"卫星归属+最小指针"原则

### 5.3 verification-gate 互指是否越界成镜像
结论：**未越界，恰当**。

互指仅声明分工（过程期 vs 终验期）和归属（Rule 106 在 task-discipline），不复制 106.1-106.5 内容，属于分工声明而非镜像。

## 总裁决：**APPROVED**

五维度均符合要求：
1. 逐字一致性：仅格式对齐，无语义偏移 ✓
2. 边界互洽：各对（20.5/106.1、67.1/106.3、106/84.x、todo 两组/S1-S5、3i/3h）自洽无循环/重叠/互吞 ✓
3. 级联正确性：六锚齐全、位置正确、互指恰当、EN-06 仅纪元语义 ✓
4. 判例锚：sess_1378b365 一致且无夸大，106.4 两态兼容 ✓
5. 措辞风险：可执行，无 Rule 82 冲突，无越界镜像 ✓

**建议（非阻塞，INFO）**：
- 执行落地时注意 106.5 B1 持续项在 TodoWrite/Task 工具中的具体状态流转（持续 in_progress 直至终验），按 todo-sync 契约处理即可
