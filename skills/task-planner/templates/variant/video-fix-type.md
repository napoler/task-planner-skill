# Task Plan: [视频修正/重生成任务]
<!-- template_type: video-fix -->
<!-- 家族=video 专模板 C 修正分支展开（EP6 四根因→机械门+门禁升级）；A/B 型任务回 video-type.md；用法：bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/init-session.sh <任务名> video-fix -->
<!-- 触发词：视频修正/局部重生成/缺陷段重生成/QC FAIL 处置/成片修复/user-fix/full-regen 全量重试/换代集重生成 -->
<!-- 配套：处置 SOP=/mnt/data/dev/videop1/.zcode/skills/videop1-video-fix/SKILL.md；八类 QC=/mnt/data/dev/videop1/tools/specs/qc-items-video-8cat.json；常识子句=/mnt/data/dev/videop1/prompts/common-sense-clauses.md；机械门=tools/gen.py video_ref_gate（refs 1-5+宽高比 0.4-2.5）+ spec kind=fix|regen 必填 disposition_ref -->
<!-- 人工门：替换件/回拼件/试水件未过 AGENTS.md 关键约束 14 用户定稿任何 video 调用 STOP；[full-regen] 仅 d 级且用户显式批准（约束 17④） -->
<!-- plan_tier: standard -->
## Goal
[一句话：对问题件/段按四级阶梯取最小范围修正到八类 QC 全过 + 收口三登记（台账/NAS VERSIONS/归档）齐全；禁未定位重发、禁默认全量]
## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` / `required` |
| `对齐审查` | `[登记]` | Rule 42.6 消费：完成前跑 alignment-review;变更记录随交付落盘;mini 豁免 |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` | Rule 44 消费：默认项+超时 5 分钟;低区分度 44.2 直接裁决;mini 豁免 |
| `质量审查工具` | `[检测结论]` | Rule 42 消费：42.2 四级检测登记;执行期用登记工具;mini 豁免 |
## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 缺陷定位先行：每问题件有缺陷定位行（件号×缺陷时间段×描述×类别）才允许任何重发；用户未点名件/段=先呈对账清单指认，禁推定全量（判例：段一 7 段全票作废） | grep progress.md 缺陷定位行 | progress.md |
| VC-2 | 处置对账表逐件路由：四级阶梯（a 剪辑补救/b 片内段级/c 整件/d 全量）逐件登记 件号×时间段×路径×日期；能小不大，a 可行禁发起生成；b/c spec 必带 kind+非空 disposition_ref（gen.py 机械门缺=exit 2） | 处置对账表逐行对账 | progress.md |
| VC-3 | [full-regen] 门槛（仅 d 级）：五条件核验表全 ✓ + progress.md `[full-regen]` 登记行（范围×批准原话×日期）+ Decisions Made；无登记发起全量=违规，产出按"未经门"作废 | grep [full-regen] 行+核验表 | progress.md + task_plan Decisions |
| VC-4 | 参考完备机检：gen.py video_ref_gate（refs 1-5 张+本地参考图宽高比 0.4-2.5，超限列文件与比值 exit 2；判例 EP4 r=6.0/EP7 r=3.56 四连败 400）+ 换代集逐槽实扫缺件=STOP；试水门不豁免 | 机检输出+逐槽实扫登记行 | 生成 spec + progress.md |
| VC-5 | 试水+人工门不豁免：批次第 1 件=试水件走完整链路（出件→机器 QC→tmp/ 呈示附审查地址→用户放行）后才展开其余件；段间复试水；替换件 r2 亦过人工门；[gate-skip] 仅限用户显式指令逐字登记 | grep 放行/试水/否决登记行 | progress.md |
| VC-6 | 八类 QC：重生成/修正批成片 QC 按 tools/specs/qc-items-video-8cat.json 八类（T1-T8）全执行；UNVERIFIED 记缺陷待人工，禁凭满分放行（EP6 判例：五类盲区 17/17 段带错放行） | qc.py verdict JSON 8 item 落盘 | tmp/<任务前缀>/qc/ |
| VC-7 | N 维对拍双查：生成前 epNN-prompts 逐镜 vs epNN-script 画面行核对四要素（地点/动作/在场角色/事件），镜头词错先修词再重生成；生成后抽帧对拍同四要素 | 对拍核对表+T8 evidence | progress.md 对拍行 |
| VC-8 | 收口三登记+seam QC：拼接件过 seam QC（否定式接缝 item）才入台账；台账逐段注记（S\<NN\>.\<seg\> 与回拼终态关系×处置路径）；NAS 覆盖同步+VERSIONS.md 更新+逐件 stat 核对；被替换旧件当日归档（-superseded） | 台账行+NAS stat+归档簿行 | output/ 台账 + docs/archive/README.md |
## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
<!-- 🚫 禁止发散规则: 只操作本列表内文件; 未列出=不碰; 扩展须用户授权 -->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 待修视频件 | [tmp/<epNN>/fix/<件名>.mp4] | 其他视频件 |
| 工具 | [tools/edit.py, tools/gen.py, tools/qc.py] | 其他脚本 |
| 登记册 | [output/<台账>.md, NAS VERSIONS.md, docs/archive/README.md] | 其他文档 |
| 进程件 | [progress.md, task_plan.md] | 其他计划文件 |
**执行前自检：** 文件在列表内？对完工必要？用户明确要求？全 Yes → 可以执行 | 任一 No → 先问用户
## Phases
### Phase 1: 缺陷定位（禁止未定位重发）
- [ ] 问题件 tmp/ 副本 + tools/qc.py frames 抽帧（缺陷邻域加密，判例五帧 0.3/1.5/3.0/4.5/6.0s）或 analyze_video 实检
- [ ] 缺陷定位行逐件落 progress.md（件号×[in_s,out_s]×描述×类别，类别对齐八类 T1-T8）；用户报障未点名 → 逐件对账清单呈用户指认
- **Status:** pending
- **Executor:** 主进程/executor
### Phase 2: 处置对账表（AGENTS 约束 17④ 四级阶梯逐件路由）
- [ ] 逐件路由：a 剪辑补救（0 生成调用，优先）→ b 片内段级重生成（缺陷段±上下文窗裁剪→同参考组同规格族重生成→回拼，正确部分零重发）→ c 整件重生成 → d 全量（仅换代级+批准，入 Phase 3）
- [ ] 对账表落 progress.md；b/c 路径生成 spec 必带 kind="fix"或"regen" + 非空 disposition_ref（gen.py 机械门缺=exit 2）；视频类重试=三连败 STOP 门（同型缺陷连续 3 轮未收敛=强制停批+4 维归因+用户三选项裁决；约束 19⑤ 图片 10 次择优不适用视频）
- **Status:** pending
- **Executor:** 主进程/executor
### Phase 3: [full-regen] 门槛（仅 d 级行触发；a/b/c 级=登记 skip 理由后跳过）
- [ ] d 级五条件核验全 ✓ 才开批：①缺陷定性=换代级（全批失效非单点）②四级阶梯排除确认且对账表留痕 ③用户批准原话逐字登记 progress.md `[full-regen]` 行（范围×出处×日期）④task_plan.md Decisions Made 同步 ⑤最小化预案+新参考组定档先行
- **门控语义：** 任一 ✗ 或无批准登记 = 本 Phase 停留 in_progress 呈用户，禁入 Phase 5；子代理无权代批
- **Status:** pending
- **Executor:** 用户裁决（主进程 STOP 呈示）
### Phase 4: 参考完备机检（先读下方「换代集分支」节定门禁等级）
- [ ] 对齐原则核对：每实体/形态/状态可溯源锚件或剧本画面行，无法溯源=编造=FAIL；gen.py video_ref_gate 机械门（refs 1-5+宽高比 0.4-2.5，超限 exit 2）；换代集逐槽实扫缺件=STOP 先走 B 型补资产，禁槽留空开批（母图补制走 video-type.md B 型资产链，定稿后回本 Phase）
- [ ] 镜头词组装核对：structured-shot-template 四段式+五问自检 + common-sense-clauses 子句族 + model-limit-avoidance 盲区逐条过（元素可见性二选一/行驶镜禁清晰面部）
- **Status:** pending
- **Executor:** 主进程/executor
### Phase 5: 重生成批（子代理 B 任务——试水件先行+段间复试水+八类 QC+N 维对拍）
- [ ] 开批前置 grep：Phase 3 放行登记行存在（d 级）或 skip 登记存在（a/b/c 级），缺=STOP；试水件=批次第 1 件走完整链路（出件→八类 QC→tmp/ 呈示+审查地址清单→等用户放行）后才展开其余件；风格/锚点换代后既有段全部重试水
- [ ] 生成前 N 维对拍先修词；逐段生成（reference 混交 4-5 张，约束 4 成本警示在前）→ 八类 QC（T1-T8 全执行）→ 生成后抽帧对拍；重发件 PASS 项回退须全量复 QC 登记
- **Status:** pending
- **Executor:** 子代理 B（与词修/机检任务分派不同子代理；派发 prompt 含 Rule 32.2 禁令行）
### Phase 6: 收口（seam QC + 三登记 + NAS VERSIONS + 旧件归档）
- [ ] 拼接件过 seam QC（否定式接缝 item，±0.2s 覆盖）FAIL 回 Phase 5 重生成该段；三登记：①output/ 台账逐段注记 ②NAS 覆盖同步+VERSIONS.md+逐件 stat 核对 ③docs/archive/README.md 旧件当日归档（-superseded）
- [ ] 成片 tmp/ 下载 Read 呈示（批量逐条附审查地址清单）；处置范围逐件收尾对账（VC-1/VC-2 闭环）
- **Status:** pending
- **Executor:** 子代理 B → 主进程验收
## 🔁 换代集分支：对象先验等级 × 门禁等级联动（EP6 判例固化）
> **EP6 判例一句话**：S04 座驾换代槽留空（座驾换代无母图可挂）无人拦截 → 车辆全片崩坏、17/17 段带错放行；试水门不豁免本节
| 对象先验等级 | 判定（模型对该对象的先验） | 门禁等级 | 开批前必做 |
|--------------|---------------------------|----------|-----------|
| 高（常驻已建模） | 剧本常驻座驾/道具/场景，现役 multiview 母图在库且已入参考组 | 常规机检 | gen.py video_ref_gate |
| 低（换代集/定制对象） | 座驾/道具/场景换代件、任何模型先验≈0 的定制对象 | **mandatory** | 常规机检+逐槽实扫缺件=STOP+母图 B 型补制先行+镜头词点名该对象；先验判不准一律就高按低档 |
## 🔗 子代理隔离铁律（AGENTS.md 约束 15 执行序）
- 词修/机检/对拍（P1-P4）与重生成批（P5）分派不同子代理任务；同任务自动衔接=违规（判例：段一 7 段全票作废）；子代理只能产出替换件+机器 QC 结论+呈示，人工放行判定只有用户能做，子代理完成态=STOP；派发 P5 的 prompt 必含「前置=放行/批准登记行 progress.md grep 可查（缺=STOP 不得发起 video）」+ 约束 4 成本警示
## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 处置 SOP | videop1-video-fix skill §0-§11（四级阶梯/八类 QC/换代集门禁） | /mnt/data/dev/videop1/.zcode/skills/videop1-video-fix/SKILL.md | 必读 | ☐ |
| 八类 QC | qc-items-video-8cat.json（T1-T8 items） | /mnt/data/dev/videop1/tools/specs/qc-items-video-8cat.json | 必读 | ☐ |
| 常识子句 | common-sense-clauses.md（§4 状态链载体句等） | /mnt/data/dev/videop1/prompts/common-sense-clauses.md | 必读 | ☐ |
| 原始判例 | EP6 审计（四根因+59 项硬错误） | /mnt/data/dev/videop1/docs/series/jipin-nvdiaoshou/ep06-error-audit.md | 必读 | ☐ |
| 项目指令 | AGENTS.md 关键约束 4/8/11/12/13/14/15/16/17④/18 | <repo-root>/AGENTS.md | 必读 | ☐ |
| 参考组定档 | 集级规格卡 §13 固定 5 槽 + p5-reflock §v6 | <repo-root>/docs/series/<series>/ + <repo-root>/plans/ | 必读 | ☐ |
## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- WHAT: 本计划子代理 vs 主进程执行分布统计；WHY: 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL；WHEN: 每个 Phase complete 后更新, 终验交付前必须完整 -->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |
## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
每次 Agent() 派发前填一行；子代理返回后 Read 产出+findings 回填双条件才勾 verify_done（Rule 22.5）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |
