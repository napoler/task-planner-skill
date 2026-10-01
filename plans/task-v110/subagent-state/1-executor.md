# checkpoint 1-executor — Phase 1 影响面普查（task-v110）
status: done

## 里程碑
- M1 (done) 计划三文件+brief+主对象读取完成；grep 全集采集完成（维度 2/3/5 行号已实测锁定）
- M2 (done) check-dispatch.sh serial_slot_check 行号级解剖完成（维度 4）
- M3 (done) 五维结论+修订三件套落盘（本文件正文）
- M4 (done) 最终结论段+findings/progress 回填

## 维度 1：Rule 21.4 现行全文逐句拆解（critical-rules.md:144）

标题：`21.4 **串行派发铁律(P0,2026-09-12 task-v061)+逐个执行+即时验收+首败即评估拆细**`

| # | 语义成分（原文关键词） | 判定 | 说明 |
|---|------------------------|------|------|
| a | "执行期同一时刻**至多 1 个活跃子代理**" | **演进** | 绝对化串行表述，与 10-02 裁决冲突→改为「并行默认允许」 |
| b | "上一 S-unit 完成三证据验收(执行记录/产出 Read 复核/验证证据)之前,**禁止派发下一个**" | **演进**（条件保留） | 三证据验收机制本身保留；触发条件从「上一」收窄为「同组（独立性四问任一 yes 同组）」 |
| c | "无论其是否依赖前序产出,'互不依赖'不构成并行理由" | **演进（废弃）** | 直接被 10-02 裁决否定，须删 |
| d | "后台派发(run_in_background)视为持续占用串行槽" | **保留** | 后台占用槽语义仍成立（声明组内后台同样受锁约束） |
| e | Why 段（sess_1316c7f8 实证/质量优先速度 Rule 26 同源） | **保留** | 作为演进链 09-12 锚点入演进标注 |
| f | "唯一例外:用户显式说'可以并行'须登记 Decisions Made" | **演进（升级）** | 例外→默认；登记制升级为「独立性四问守门+声明制」 |
| g | "完成一个验收一个(Read 复核产出/命令输出确认)" | **保留** | 验收纪律不变 |
| h | 首败评估（对照 21.1b 拆细→22.3 ②/③；≥2 次禁同法+Rule 7） | **保留** | 失败兜底链不变 |
| i | "（机器守护:check-dispatch.sh 串行槽+打包检测）" | **保留（改写措辞）** | 守卫改名为「串行槽/并行组槽」，指向更新 |
| j | 只读分槽豁免（[task-v094 T-B1] 09-28：frontmatter `parallel_readonly: true` ∧ prompt `[readonly-parallel]`；写类仍独占槽） | **演进（并入）** | 并入新「独立性四问」为预置场景 ①（文件集不相交∧只读）；机制保留 |

## 维度 2：全库「21.4」引用面（grep -rn "21\.4" skills/，companion/.backup* 不计）

| 文件:line | 语义 | 类型 |
|-----------|------|------|
| critical-rules.md:144 | 21.4 正文 | 主对象 |
| critical-rules.md:155 | 22.4a「写只追加不改写,各子代理只写自己的锚点(派发本身仍按 21.4 串行)」 | 文档引用，含「仍按 21.4 串行」旧断言 |
| critical-rules.md:198 | 25.2「所有 S-unit 严格串行派发——一次一个、验收一个再派下一个,Rule 21.4 串行派发铁律,'互不依赖'不构成并行理由」 | **硬锚**（断言类，须改写） |
| critical-rules.md:371 | 39 导语「未点名任务保持 Rule 21.4 串行铁律零改动」 | 硬锚（39 语境零改动声明） |
| critical-rules.md:373 | 39.1「未点名 → 一律走既有 Rule 21.4 串行派发」 | 硬锚 |
| critical-rules.md:385 | 39.4「Rule 21.4 串行铁律在该 workflow run 内部豁免……Rule 21.4 文本零改动」 | 硬锚（与新语义「并行默认」需调和） |
| critical-rules.md:400 | 40.4「未命中且用户未点名 → 维持 Rule 21.4 串行零改动」 | 硬锚 |
| config.json:343 | `retry_limit` description "Rule 21.4" | **悬挂引用（既有缺陷，非 21.4 语义面——retry_limit 权威源是 Rule 22.3；建议顺手修正为 22.3，登记 Phase 2 决策）** |
| subagent-fallback.sh:284 | "先按 Rule 21.4 对照 21.1b 评估 ② 拆细重派" | 文档引用（指向 21.4 内失败评估段，该段保留→无需改，可加新锚） |
| check-dispatch.sh:344/348 | 串行槽守卫注释「Rule 21.4 配对/后台条款」 | 代码注释，随守卫改动同步 |
| check-dispatch.sh:371/374 | block/warn 输出文案「Rule 21.4 串行派发铁律」 | 代码输出文案（Tier-B 测试 grep '串行' 依赖此文案） |
| zcode-posttooluse.sh:23 | 清锁注释「串行槽清锁(Rule 21.4 配对)」 | 代码注释 |
| SKILL.md:47 | 「未点名一律走既有 Rule 21.4 串行 Agent 派发」 | 文档引用 |
| SKILL.md:85 | 2.5 委派检查点「严格串行:一次一个、验收通过再派下一个 — Rule 21.4」 | **硬锚** |
| SKILL.md:132 | fan-out「串行逐个派发(Rule 21.4 铁律)」 | 硬锚（fan-out 恰是并行场景，措辞自相矛盾，优先改） |
| SKILL.md:192 | C27「21.4 并行豁免已登记……未点名则走 21.4 串行」 | 硬锚（与新语义下 39.4 调和） |
| SKILL.md:242 | 「fan-out(一对多派发,派发仍守 Rule 21.4 串行铁律)」 | 硬锚 |
| SKILL.md:256 | 「派发严格串行——一次一个、验收通过再派下一个(21.4 串行派发铁律)」 | 硬锚 |
| SKILL.md:275 | Rule 39「未点名=既有 21.4 串行零改动」 | 硬锚 |
| reference.md:312/316/322 | chain linked「派发仍串行 — Rule 21.4」/「互不依赖不构成并行理由」 | 文档引用（linked 串行场景**合法保留**；:322 句「互不依赖不构成并行理由」须删） |
| completion-gate.md:22/26 | 「S-unit 1→…→S-unit 2(Rule 21.4 串行派发铁律)」「一次只派一个……'互不依赖'不构成并行理由」 | 硬锚（完成门时序图） |
| methodology.md:86 | 「Rule 21.4(串行派发,一次一个)」 | 文档引用 |
| plan-template-kit/references/template-guide.md:228 | 「未命中编排条件写'维持 Rule 21.4 串行'」 | 文档引用（判定短语） |
| plan-template-kit/references/template-mapping.md:255/258 | 「默认 21.4 串行」「未命中维持 Rule 21.4 串行」 | 文档引用（判定短语） |
| templates/task_plan.md:149 | 「未命中编排条件 → 维持 Rule 21.4 串行」 | 模板判定短语（Phase 2 模板面已列） |
| templates/variant/memory-hygiene-type.md:128/137 | `grep 21.4=7 命中` 验收锚+`grep -c "21.4" $CR` | **计数锚**：critical-rules 内 21.4 行数实测=**7**（:144/:155/:198/:371/:373/:385/:400，与 v109 盘点一致；本任务**不改 21.4 行数、只改 144 行内文本**→计数 7 保持） |
| memory serial-dispatch-iron-rule.md（§六保护区外，memory 面） | 09-12 裁决原文 | 演进记录落点（Phase 4） |

## 维度 3：「串行」措辞面（排除 21.4 命中重复）

| 文件:line | 措辞 | 判定 |
|-----------|------|------|
| critical-rules.md:144 | 串行派发铁律/至多 1 个活跃/严格独占槽 | 主对象重写 |
| critical-rules.md:198 | 严格串行派发 | 硬锚 |
| critical-rules.md:369/371 | 「既有串行派发零改动」 | 硬锚（39 导语） |
| SKILL.md:11 | 「completion-gate.md: 子代理验证 + 串行同步」 | 文档 |
| SKILL.md:85/132/242/256/275 | 见上 | 硬锚 |
| completion-gate.md:19 | 段标题「## 多任务同步（串行）」 | 需挂演进标注 |
| completion-gate.md:22/26 | 见上 | 硬锚 |
| reference.md:291 | 「linked（串行接力）」 | **保留**（linked=有依赖接力，串行保留场景） |
| reference.md:312/316 | 「派发仍串行 — Rule 21.4」 | 硬锚（linked 语境可保留串行，但「铁律」定性措辞弱化） |
| CLAUDE.md:33 | 「completion-gate.md← 子代理验证 + 串行同步协议」 | 文档（CLAUDE.md 不在 scope_files，登记 Phase 2 决策是否顺手改） |
| examples.md:109 | 「linked（串行接力）」 | 保留 |
| templates/variant/rule-enhancement-type.md:63 | 「严格串行派发」 | 模板示例，挂演进标注 |
| 宪法 ~/.zcode/AGENTS.md §一 | 串行派发铁律条目 | **禁区**（scope 排除，交付时提醒用户） |

## 维度 4：check-dispatch.sh serial_slot_check 解剖

- 入口 :199/:212 — 两处置：`ro=0; if grep -qm1 'parallel_readonly: true' "$pd/task_plan.md" && grep -qm1 '\[readonly-parallel\]' "$pf"; then ro=1; fi; serial_slot_check "$pd" "$mode" "$sid" "$ro"`（第④参=readonly 放行开关）
- 函数 :350-381：锁=`<plan-dir>/subagent-state/.dispatch-inflight`（unix 时间戳）；age<120s 判槽占用；ro=1→:366-369 放行且不覆盖写类锁（`[dispatch-readonly]` 提示）；否则 warn 档 :370-373 告警放行 / enforce 档 :374-375 `exit 2`（文案含「Rule 21.4 串行派发铁律」——selftest TS-02/03 grep '串行' 依赖）；空闲→:379 写新锁放行
- 清锁：zcode-posttooluse.sh:23-34，Agent 返回即 `rm -f .dispatch-inflight`（已知边界：run_in_background 立即返回即清锁，后台占用靠 21.4 文本条款承载，见 check-dispatch.sh:347-348 注释）

**并行组放行的最小改动点建议**（三选一，推荐①）：
1. **声明组标记**（推荐，与计划 Decisions「声明制」一致）：新增 prompt 标记 `[parallel-group]`（或 frontmatter `parallel_groups:` 组清单 + S-unit 行 `[P]` 标注三态择一）。守卫改动=入口 :199/:212 的 ro 检测逻辑扩展为 `pg`（parallel-group）开关；:366 条件 `if [ "$ro" = "1" ] || [ "$pg" = "1" ]` 放行；输出文案 `[dispatch-parallel-group]`。**写类锁语义不变**（组内成员若文件集相交由 21.4 四问①在计划期拦截，守卫不做文件集比对——计划已裁决机器全量比对方案 B 不做）。改动面=check-dispatch.sh 4 行 + selftest 新增 1-2 用例。
2. 复用 `[readonly-parallel]` 标记扩义为 `[parallel]` 通用标记——语义漂移，不建议（会破坏 T-B1「只读」语义锚）。
3. frontmatter 纯声明组+组名——计划期声明、执行期 prompt 无标记可验，守卫无法在派发时刻校验，不建议作唯一面。

## 维度 5：selftest 断言锚全集

**selftest-dispatch.sh**（TS 组）：
- :90/:91 注释（T05 清锁范式，「串行槽守卫扰动」）
- :125-126 注释（T11 清锁防互扰）
- :137 「TS-01..06 [task-v061] 串行槽守卫」段注释
- :164-169 TS-02：新鲜锁+enforce→exit 2 且 stderr `grep -qF '串行'`（:168 断言）
- :172-177 TS-03：新鲜锁+warn→放行且 stderr 含「串行」（:176）
- :199-207 TS-06：清锁后放行（:203 注释「子代理验收通过后串行槽释放」）
- 结论：**只要 :374 拦截文案保留「串行」字样，TS-02/03 零改动**；守卫改动后仅需**新增** parallel-group 放行用例（TS-07+）

**selftest-tier-b.sh**（T-B1 组）：
- :45 夹具：`<!-- parallel_readonly: true -->` frontmatter
- :48 夹具 prompt：`只读探查 [readonly-parallel]`
- :67 `sed -i '/parallel_readonly: true/d'` 删声明
- :68-70 ok 14/15/16：只读声明+标记槽占用放行 / 写类槽占用仍拦截 / 缺声明仍拦
- :71 `grep -q '只读分槽豁免（\[task-v094 T-B1\]' "$CR"` → ok 18「21.4 豁免子条在位」——**21.4 新文本须保留该锚串或改写此断言**（建议新文本保留「只读分槽豁免」字样作演进子条锚，改动=0）

**memory 计数锚**：MEMORY.md:101「Rule 21.4 grep=7 在位」；memory-hygiene-type.md:128 `grep 21.4=7`。

## 修订方案三件套

### 件 1：Rule 21.4 新文本草案（critical-rules.md:144 整行替换）

```
21.4 **子代理调度铁律（P0；演进链 09-12 串行铁律[task-v061]→09-28 只读分槽豁免[task-v094 T-B1]→10-02 并行默认+独立性守门[task-v110]）+逐个执行+即时验收+首败即评估拆细**：
**默认语义（[EVOLVED 2026-10-02] 用户裁决：「子代理调度可以并行运行，但必须确保互不影响、互不依赖——用错误的资料或依赖只会产出错误内容」）：并行默认允许**——同一时刻可存在多个在飞子代理，当且仅当同一**并行组**内成员通过**独立性四问**（①文件集相交？②资源相争（部署位/分支/同一交付物/同一计划文件锚点）？③输入依赖他者产出？④验收依赖他者结果？——**任一 yes = 不同组，必须串行**：前者三证据验收（执行记录/产出 Read 复核/验证证据）通过后才派发后者）；
**声明制（机器承载）**：并行组须在计划 frontmatter 声明（`parallel_groups:` 组名清单）∧ S-unit 行/派发 prompt 含组标记 `[parallel-group:<组名>]`（沿承 09-28 只读分槽豁免：`parallel_readonly: true`+`[readonly-parallel]` 为只读类预置组，机制保留）；未声明者默认串行（守卫对无标记派发按串行槽拦截，行为同旧 09-12 铁律）；
**串行保留场景枚举**：① linked 接力（同一上游产物多下游依次消费）② 写类 S-unit 文件集相交（四问①）③ 同一计划三文件同锚点双写（22.4a 单写者条款）④ 验收链依赖（四问④，如汇总/Aggregator 必须等全部组内成员）⑤ 用户显式要求串行；
**验收纪律不变**：完成一个验收一个（Read 复核产出/命令输出确认），每个并行组成员独立三证据+独立 Handoff 行；后台派发（run_in_background）视为持续占用所在组槽，收取结果前不得派发同组新 S-unit；
**失败兜底链不变**：子任务首次失败/超时→对照 21.1b 评估拆细重派（22.3 ②）/降档（③）；同一子任务失败 ≥2 次→禁止同法重试（Rule 7 三击），重拆或升级 Complex Problem Solver；
（机器守护：check-dispatch.sh 串行槽/并行组槽守卫+打包检测；无组标记=串行槽拦截，有组标记=组内放行不覆盖他组锁）；
Why 锚（保留）：09-12 实证 sess_1316c7f8（16 编辑批并行→千级机械残迹）确立质量优先于速度（Rule 26 同源）；10-02 演进=该风险由「禁止并行」转为「独立性守门拦截有依赖的并行」，错误跨单元放大风险由四问②③+验收拦截
```

要点：保留「只读分槽豁免（[task-v094 T-B1]」锚串（tier-b :71 断言零改动）；旧「至多 1 个活跃子代理」「互不依赖不构成并行理由」删除。

### 件 2：级联清单（Phase 2 逐处，改写 vs 挂演进标注）

| 位置 | 改法 |
|------|------|
| critical-rules.md:144 | 整行替换为件 1 草案 |
| critical-rules.md:155（22.4a） | 「(派发本身仍按 21.4 串行)」→「(派发本身按 21.4 独立性守门：声明组内并行、未声明串行)」改写 |
| critical-rules.md:198（25.2） | 「所有 S-unit 严格串行派发——一次一个、验收一个再派下一个,Rule 21.4 串行派发铁律,'互不依赖'不构成并行理由」→「S-unit 按 21.4 调度铁律派发——声明并行组内成员可并行、组间及未声明者串行（一次验收一组成员再派下一组成员）；'互不影响、互不依赖'为并行前提（10-02）」改写 |
| critical-rules.md:371/373（39） | 挂演进标注「[EVOLVED 10-02] 未点名任务按 21.4 独立性守门调度（并行默认+声明制）」；「零改动」定性句随 39.4 一并调和 |
| critical-rules.md:385（39.4） | 调和改写：workflow run 内部并行原即 21.4 默认语义（10-02 后），豁免登记制保留为留痕手段；「Rule 21.4 文本零改动」删除（本任务 10-02 改写 21.4） |
| critical-rules.md:400（40.4） | 「维持 Rule 21.4 串行零改动」→「按 Rule 21.4 独立性守门调度（10-02 后并行默认允许，未命中编排条件不登记 CreateWorkflow）」 |
| SKILL.md:47/85/132/192/242/256/275 | 逐处替换「串行铁律/严格串行/互不依赖不构成并行理由」为件 1 新语义短语；:132/:242 fan-out 句改为「fan-out 成员按 21.4 声明组并行（组内独立性四问通过）」 |
| completion-gate.md:19/22/26 | 段标题「（串行）」→「（按 21.4 调度：声明组并行/未声明串行）」；:22 时序图加 `[P] 组` 标注；:26 句改写 |
| reference.md:312/316/322 | linked 场景保留串行（合法场景①），:322「互不依赖不构成并行理由」删除→「linked 块间存在输入依赖（四问③）→串行」 |
| methodology.md:86 | 「Rule 21.4(串行派发,一次一个)」→「Rule 21.4(独立性守门调度，10-02)」 |
| plan-template-kit/template-guide.md:228 + template-mapping.md:255/258 | 判定短语「维持/默认 21.4 串行」→「按 21.4 独立性守门（并行默认+声明组）」 |
| templates/task_plan.md:149 | 同上（模板面，scope 内） |
| templates/variant/rule-enhancement-type.md:63 | 「严格串行派发」→「按 21.4 调度铁律派发（未声明组=串行）」 |
| subagent_dispatch.md（模板面） | 工具面提示行加 1 行：「并行组声明：frontmatter parallel_groups + S-unit 行/标记 [parallel-group:<组名>]；独立性四问见 Rule 21.4」 |
| check-dispatch.sh:344-348 注释 + :371/:374 文案 + zcode-posttooluse.sh:23 注释 | 随守卫改动同步（件 3）；文案保留「串行」字样于无标记拦截路径（TS-02/03 依赖） |
| config.json:343 | retry_limit description 悬挂引用 21.4→修正 22.3（登记 Phase 2 决策；scope_files 未列 config.json——**越出 scope_files，须主进程确认或剔除**） |
| CLAUDE.md:33 | 不在 scope_files，登记「交付报告提醒」 |
| MEMORY.md:101 + memory-hygiene-type.md:128/137 计数锚 | 21.4 行数=7 保持（本任务只改 :144 行内容不加行）；MEMORY.md 行 Phase 4 memory 演进时同步 |
| 宪法 AGENTS.md §一 | **禁区**，交付报告提醒用户自行同步 |

### 件 3：check-dispatch.sh 守卫最小 diff 建议

1. :199/:212 入口：在现有 `ro` 检测后追加 `pg` 检测——`grep -qm1 '\[parallel-group:' "$pf"`（有组标记即 pg=1）；调用改 `serial_slot_check "$pd" "$mode" "$sid" "$ro" "$pg"`
2. :351 函数签名：`local ... ro="${4:-0}" pg="${5:-0}"`
3. :366 放行条件：`if [ "$ro" = "1" ] || [ "$pg" = "1" ]; then` + 文案 `[dispatch-parallel-group] 并行组标记命中(10-02 独立性守门), 槽占用(age=${age}s)放行——组内四问责任在计划期声明, 组间串行不变`
4. 无组标记路径（:370-375）**零改动**——TS-02/03 断言「串行」文案继续通过；新语义下「无声明=默认串行」= 旧铁律行为，正是计划期声明制的兜底
5. selftest-dispatch.sh 新增 TS-07（组标记+新鲜锁+enforce→放行）+ TS-08（无标记+新鲜锁+enforce→exit 2 回归，即现 TS-02 语义防回归）；tier-b 零改动
6. 已知边界（新语义下如实披露）：`[parallel-group:]` 是信任标记，守卫不做四问机器校验（文件集比对方案 B 已裁决不做）；四问失守由计划期声明质量 + 验收 Read 复核 + VC-2 全库 grep 承载

## 最终结论
status: done
acceptance: 3/3 pass — ①五维逐维有结论=正文维度1-5各表 ✅ ②修订方案三件套=件1/件2/件3 ✅ ③检查点含最终结论 8 字段块=本段 ✅
files: /mnt/data/dev/task-planner-skill/plans/task-v110/subagent-state/1-executor.md (+1); /mnt/data/dev/task-planner-skill/plans/task-v110/findings.md (追加 #### [sub:1-executor] 段); /mnt/data/dev/task-planner-skill/plans/task-v110/progress.md (追加 [sub:1] 行); 主对象 0 改
evidence: critical-rules.md:144(21.4 正文逐句拆解 10 成分)→全库 21.4 引用面 25 处 file:line 清单; check-dispatch.sh:350-381 serial_slot_check 行号级解剖(第④参 ro :351/:366; 无标记路径 :370-375 文案含「串行」=TS-02/03 锚); selftest-tier-b.sh:71 断言 '只读分槽豁免（[task-v094 T-B1]'→新文本保留该锚串改动=0; memory/MEMORY.md:101 计数锚 21.4=7 行(改 :144 行内容不加行→保持)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v110/subagent-state/1-executor.md (status: done)
findings_written: #### [sub:1-executor] 影响面普查
blockers: 发现 2 处越 scope_files 候选（config.json:343 悬挂引用 21.4→22.3 / CLAUDE.md:33 串行措辞）须主进程 Phase 2 决策是否纳入
confidence: HIGH
