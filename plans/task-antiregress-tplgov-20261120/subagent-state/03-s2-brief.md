# S2 任务书：Rule 111 进度产出防倒退 + 主模板两区块（2026-11-20）

执行体：在 worktree 内落地防倒退机制核心载体。只改下列 4 个文件，禁碰其他任何文件（含主仓、其他 variant、SKILL/scripts——那是 S3 范围）。全程中文。

## 0. 绝对路径（全部在 worktree 内）
- W=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120
- core 规则：$W/skills/task-planner/references/critical-rules.md（233 行，最大号 ### 109）
- discipline 规则：$W/skills/task-discipline/references/critical-rules-discipline.md（最大号 ### 106）
- dispatch 规则：$W/skills/task-dispatch/references/critical-rules-dispatch.md（最大号 ### 110）
- 主模板：$W/skills/task-planner/templates/task_plan.md（601 行）
- 范式参考（必读原文）：core 内 `### 51.15`（规范基线冻结）、discipline 内 `### 74.7`（约 :495）与 `### 106.7`（约 :758）、dispatch 内 `### 22.4e`（约 :66）
- 参考实现（区块范式样例，必读）：/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md 的「📦 进度产出基线」与「🛡 防倒退终检」两区块

## 1. 交付物（4 处）

### ① core 新增 `### 111 进度产出基线防倒退（Progress-Output Baseline，P0）`
结构对照 51.15 范式（登记义务→登记格式→双向判定→attest 锁→四环绑定→分工互锁），要点：
- **计划期登记**：存在项目级进度/产出基线候选时，计划期必须在 task_plan.md「📦 进度产出基线」区块逐条登记：`基线项 | 动工前快照 | 关键产出/指标 | 禁倒退清单 | 状态`；来源=对项目关键产出/能力面盘点（如模板数与结构、规则编号面、selftest 基线、部署位状态、核心流程可用性）；确认无候选须显式 `none-justified`，禁静默遗漏。
- **attest 锁**：该区块随计划纳入 Rule 20.1 SHA-256 attestation 锁定面（同 51.15 口径，零新脚本）。
- **拆东墙补西墙机器化判定（净效果门）**：执行期对既有产出的任何删除/降级/替换（含"用新实现替代旧实现""重构时顺手移除""为让 A 过验收而削弱 B"），落地前须登记**消费方影响评估**（谁在消费该产出、替代面是否等价或更优）且**净效果≥0**；净效果<0 或影响未登记=禁止落地。违规=`[PROGRESS-REGRESSION]`（P0，PLAN TAMPERED 同族），唯一合法路径=STOP→用户显式授权→Decisions Made 登记→更新基线→重跑 attest 重锁。
- **交付/合并前终检**：对照「🛡 防倒退终检」区块逐项判定（模板区块承载，本规则定义触发义务）。
- **分工互锁（显式写明）**：Rule 74.7=一切修改的通用前置合规门（依据面）；Rule 51.15=已登记规范阈值冻结（参数面）；本条=项目进度产出面（能力/进度/产出清单不许净倒退）。执行顺序=先过 74.7，再判是否叠加 51.15/本条；三门互补，禁以「未登记」为由绕过。
- **四环绑定**：派发必带（22.4f）、返工/续写/合并回归（discipline 106.8）、终检（🛡 区块+84 面）、verification 收尾对照。
- 机制=L0-T 文本锚+复用现有 attest/check 门，零新脚本零新 config 键。Why 段写清：拆东墙补西墙（改 A 坏 B）在无基线对照时不可检，判例=本仓部署/级联面多次"修一处破一处"漂移。
- 文末（`### 109` 条款之后）追加，禁改任何既有条款一字。

### ② discipline 新增 `### 106.8 进度产出防倒退回归门`
对照 106.7 范式：触发点（①同一交付物每轮返工后 ②序列任务续写新单元 ③合并回主仓/部署前 ④QC FAIL 重开双轮前）必须对全部基线项重跑逐条对照（非抽样）；发现退化（既有产出被删/降级/净效果<0 且无登记授权）=倒退事件：STOP+`[progress-regression]` 三件套（退化项/触发点/换策略）登记 progress；禁默认「前序合规则本轮必合规」。置于 `### 106.7` 之后。

### ③ dispatch 新增 `### 22.4f 进度产出基线强制携带`
对照 22.4e 范式：存在基线的任务派发 prompt 必须携带基线清单（基线项+禁倒退清单+判定式）+ 明示「禁删除/降级/替换既有产出，发现需要动既有产出即回传主进程按 74.7/111 处置」；子代理就地删除/降级=`[PROGRESS-REGRESSION]` P0。模板面注记指向 subagent_dispatch.md 既有 {spec_baseline} 行同位承载（本轮不改模板 dispatch 文件本身，只写规则条款+模板面注记）。置于 `### 22.4e` 之后。

### ④ 主模板两区块（$W/skills/task-planner/templates/task_plan.md）
- 「## 📦 进度产出基线（Rule 111 进度产出防倒退）」：插入位置=「🔒 规范基线（Spec-Baseline，Rule 51.15）」区块（grep `## 🔒 规范基线` 定位）之后；内容=登记前置说明+5 列表头（基线项|动工前快照|关键产出/指标|禁倒退清单|状态）+`none-justified` 义务+与 attest 锁关系一行。
- 「## 🛡 防倒退终检（交付/合并前强制）」：插入位置=「## 🔁 收尾回读梳理记录」区块（grep 定位）之前；内容=检查表（既有能力未削弱/模板解析兼容/净效果≥0 逐项对照/selftest 同集零增量/部署位无漂移）+净效果 BLOCK 判据一行（对照 111）。
- 格式约束：遵循文件头渲染契约注释（禁引入 {{VAR}} 未注册 token；尖括号中文占位=模型填写面合法）；风格与既有区块一致；**禁改既有区块任何一行**。

## 2. 验收（完成自查，写入 checkpoint 自审段）
1. `grep -h -c "^### 111 " <三份 rules>` 合计=1 且 111 条款含「拆东墙补西墙|净效果|51.15|74.7|PROGRESS-REGRESSION」关键词（VC-02 面）
2. 主模板 `grep -c "📦 进度产出基线"`≥1、`grep -c "🛡 防倒退终检"`≥1、`grep -c "净效果"`≥1（VC-03/04 面）
3. 既有条款零改动：`git -C $W diff --stat` 仅 4 文件、且 core/discipline/dispatch 的 diff 只含新增行（无删除行；主模板 diff 中删除行=0 或仅区块间空行调整需说明）
4. `bash $W/skills/task-planner/scripts/selftest-template-lifecycle.sh` rc=0（模板结构未破坏）
5. 完成 103.2 自审：逐项对照本节 5 条，证据锚 file:line 写入 checkpoint

## 3. 禁改面
- 上述 4 文件外一切文件（worktree 内外均禁）；既有条款一字不动；不新增脚本；不动主仓 plans/ 与部署位。
