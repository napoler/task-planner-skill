# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
-->

## Requirements
- R1（[目标]）：模板存在很多问题——实锤=验证机制「模板中缺失验证区块」。
- R2（[目标]）：同源问题在模板编辑 skill（plan-template-kit）——模板 skill 必须同步纠正。
- R3（[目标]+顺序铁律）：先修正模板 skill，再按修正后模板 skill 纠正其他错误问题。

## 📚 必要知识储备对齐记录
| 知识源 | 定位 | 已消费 | 结论落点 |
|--------|------|--------|---------|
| 上任务全档（attest 三轮实录） | plans/archive/task-docmod-recheck-20261112/ | ☑ | §1 |
| check-plan-dispatch 列定位 | skills/task-planner/scripts/check-plan-dispatch.sh:246-278 | ☑ | §2 |
| attest vc-gate 判据 | skills/task-planner/scripts/attest-plan.sh:244-285 | ☑ | §2 |
| 现行模板全文 | skills/task-planner/templates/{task_plan,verification}.md | ☐（S1/S2 首动作） | §3 |

## §1 五处模板-门漂移实录（一手证据=上任务本会话 attest 三轮 + progress Error Log）
1. **S-unit 表 11 列 vs 校验器 10 列**：模板表头含「96 类别」列（templates/task_plan.md，grep 实证；本计划 init 渲染物同源），check-plan-dispatch.sh:246-278 按 awk -F'|' 定位 $4=执行体/$5=输入/$7=时长/$8=粒度——多一列整体错位 → attest 第一轮拒锁「时长不可解析/粒度三值格式不可解析」。
2. **verification.md 模板缺失验证区块**：模板 VC 条目仅有 `VC-N: [What to check / test command]`+Evidence 行，**无 `**Verify command**:` 行结构**（grep 'Verify command' templates/ 仅命中 knowledge-brief.md）→ vc-gate 拒锁「7 条 VC 中仅 0 条含可执行验证命令」（Rule 84.1）。**=用户实锤「模板中缺失验证区块」的机器佐证**。
3. **Goal 单元表列名缺空格**：模板「对应S-unit/Phase」vs 66.5 校验要求「对应 S-unit」→ 拒锁「表头缺列」。
4. **Phase 4 示例无 S-unit 表**：模板 Phase 4（Executor=code-runner-agent≠主进程）不带 S-unit 示例表 → 派发门拒锁「缺 S-unit 表或数据行」（Rule 22.6）。
5. **Batch Report 空默认**：模板字段留空 → check-complete 拦「missing: success, failed, …」（Rule 18.6 要求八字段填齐才放行）。

## §2 机器门期望（判据源码锚）
- S-unit 列序（10 列）：check-plan-dispatch.sh:246-278（$4 执行体非空/$5 输入路径计数≤2/$7 ^NNmin$/$8 ^Nf/Nl/Nmin$）；单元格禁管道转义（v150+上任务双判例）。
- VC 验证区块：attest-plan.sh:244-285——verification.md 每条 VC 需行首 `**Verify command**:` + 非占位文本；vc-nonvacuous（同文件 :310）禁 true/echo 真空命令，命令须引用本 VC 产出物。
- Goal 单元表列名：含「对应 S-unit」字面（Rule 66.5 消费）。
- Phase 状态三源一致：checkbox↔Status↔progress（P-04）；goal 行 [goal:Gn] 落对应 Phase 段（上任务终门两轮拦截实录）。

## §3 修正文本草案（S1-S3 执行体逐字消费面）
### 3.1 templates/task_plan.md（S1）
- 新 S-unit 表头（10 列，逐字）：`| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |`
- 注释块口径行（替换原「96 类别」列指引，逐字）：`  - Rule 104.3 计划期标注：类别以目标列内（An）前缀标注（A1-A7 / 47.2 具名 / LOCAL 纯执行）——S-unit 表为 10 列固定列序（ID/目标/执行体/输入/验收/预估时长/粒度/伴飞/前置/状态，check-plan-dispatch.sh $4/$5/$7/$8 定位），禁增列、禁单元格管道转义`
- 示例数据行同步改 10 列（（A6）前缀示范）。
- Goal 单元表列名：`对应 S-unit/Phase`（补空格）。
- Phase 4 示例段补最小 S-unit 表（表头+1 示例行，注明「Executor≠主进程的 Phase 必附（Rule 22.6）」）。
- Batch Report 每字段默认值引导形态：`n/a（<一句理由>）`（模板注释注明：留空会被 18.6 门拦）。
### 3.2 templates/verification.md（S2）
- VC 条目模板行改（逐字）：
  `- [ ] VC-N: [判定标准：可观察判据]`
  `  Evidence: [file path / command output]`
  `  **Verify command**: <可执行纯命令——禁占位（must be runnable 类模板串会被拒）；禁真空（true/echo 类）；命令须引用本 VC 产出物；判据=退出码>`
### 3.3 plan-template-kit 契约条款（S3，落 SKILL.md 或 references 实测锚位）
- **验证区块契约**：每个计划的 verification.md VC 条目必须含行首 `**Verify command**:` 纯命令行（判据源=attest-plan.sh:244-285 vc-gate）；task_plan/verification 模板必须预置该行格式——模板缺失验证区块=模板缺陷（判例 task-tpl-verify-fix-20261113）。
- **S-unit 10 列序契约**：模板 S-unit 表固定 10 列（清单同 3.1），与 check-plan-dispatch.sh:246-278 定位一致；类别=目标列内（An）前缀（Rule 104.3 适配），禁「96 类别」独立列。

## §4 存量面清单法（S5 消费面）
1. `grep -rn '96 类别' skills/` → 逐处分类：A=列名/列指引（必改，按 §3.1 口径）；B=负面/迁移说明表述（保留，如「禁 96 类别独立列」）。
2. `.zcode/plan-templates/` 与仓内 templates diff 判向：项目级覆盖若同漂移 → 同步修正（CA-8）；方向不明 → STOP 登记。
3. variant 16 类模板（templates/variant/*-type.md）grep 同法；命中则逐个登记入 scope 后修。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 不新增 Rule 编号；契约落 plan-template-kit 既有条款域 | 模板生命周期归 Rule 16/34；§四.6 文本优先 |
| 冒烟=真跑 init 渲染+门校验（tmp 目录用完即删） | 只有渲染+过门才能证明模板修好（上任务判例：改模板不渲染=盲改） |
| 本计划 S-unit 表已按 10 列新口径写 | dogfood 新口径 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| （输入面问题见 §1，非本任务执行错误） | - |

## Resources
- 判例档：plans/archive/task-docmod-recheck-20261112/（attest 三轮输出+Error Log）
- 判据源：check-plan-dispatch.sh:246-278；attest-plan.sh:244-285,310

## Visual/Browser Findings
（本任务暂无多模态发现——未产生截图/PDF/网页证据）
