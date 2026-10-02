# Task Plan: [视频修正/重生成任务]
<!-- template_type: video-fix -->
<!-- 家族对齐：AGENTS「任务规划模板」节 video 家族专用模板（video-type.md C 修正分支的展开与加固）；类型名 video-fix 由本文件名派生（init-session/check-template-type 动态白名单，无硬编码副本）。用法：bash ~/.zcode/skills/task-planner/scripts/init-session.sh <任务名> video-fix -->
<!-- [源] docs/series/jipin-nvdiaoshou/ep06-error-audit.md（EP6 全片审计 59 项硬错误·四根因）+ 用户 2026-09-28 批准（task-videop1-videoedit-skill-001 Phase2 D3 固化） -->
<!-- 触发词：视频修正/局部重生成/缺陷段重生成/QC FAIL 处置/成片修复/用户不满意视频/重试范围裁决/full-regen 全量重试/换代集重生成 -->
<!-- 配套：处置 SOP=.zcode/skills/videop1-video-fix/SKILL.md（§0-§11）；八类 QC=tools/specs/qc-items-video-8cat.json；常识子句=prompts/common-sense-clauses.md；机械门=tools/gen.py video_ref_gate（refs 1-5+宽高比 0.4-2.5）+ spec kind=fix|regen 必填 disposition_ref -->
<!-- 人工门：替换件/回拼件/试水件未过 AGENTS.md 关键约束 14 用户定稿，任何 video 调用 STOP；[full-regen] 仅 d 级且用户显式批准（约束 17④） -->

<!-- plan_tier: standard -->
## Goal
[一句话：对问题件/段按四级阶梯取最小范围修正到八类 QC 全过 + 收口三登记（台账/NAS VERSIONS/归档）齐全；禁止未定位重发、禁止默认全量]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` / `required` |
| `对齐审查` | `[登记]` | Rule 42.6 消费：完成前跑 alignment-review;变更记录随交付落盘;mini 豁免 |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` | Rule 44 消费：默认项+超时 5 分钟;低区分度 44.2 直接裁决;mini 豁免 |
| `质量审查工具` | `[检测结论]` | Rule 42 消费：42.2 四级检测登记;执行期用登记工具;mini 豁免 |

## 任务分型（本模板固定 = C 修正，不可改选 A/B）
| 型 | 场景 | 本模板 Phase 骨架 |
|----|------|------------------|
| **C 修正（固定）** | 既有镜头/成片缺陷修正、局部/整件/全量（获批）重生成、用户 user-fix | P1 缺陷定位 → P2 处置对账表（四级路由）→ P3 [full-regen] 门槛（仅 d 级）→ P4 参考完备机检（换代集 mandatory）→ P5 重生成批（试水+八类 QC+对拍，子代理 B）→ P6 收口（seam QC+三登记+NAS+归档） |

> 与 video 模板关系：本模板 = video-type.md C 型分支展开加固（EP6 四根因 → 机械门+门禁升级）；A/B 型任务回 video-type.md。

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 缺陷定位先行：每个问题件有缺陷定位行（件号×缺陷时间段 [in_s,out_s]×描述×类别）才允许任何重发；用户未点名件/段=先对账清单呈用户指认，禁推定全量（判例：段一 7 段全票作废） | grep progress.md 缺陷定位行 | progress.md |
| VC-2 | 处置对账表逐件路由：逐件登记 件号×缺陷时间段×路径(a 剪辑补救/b 片内段级/c 整件/d 全量)×日期；能小不大，a 可行禁发起生成调用；b/c 路径 spec 必带 kind="fix"或"regen"+非空 disposition_ref（gen.py 机械门，缺=exit 2） | 处置对账表逐行对账 | progress.md 处置对账表 |
| VC-3 | [full-regen] 门槛（仅 d 级）：五条件核验表全 ✓ + progress.md `[full-regen]` 登记行（批次范围×用户批准原话出处×日期）+ Decisions Made；无登记发起全量=违规，产出按"未经门"作废 | grep [full-regen] 行+核验表 | progress.md + task_plan Decisions |
| VC-4 | 参考完备机检：gen.py video_ref_gate（refs 1-5 张+本地参考图宽高比 0.4-2.5，超限列出文件与比值 exit 2；判例 EP4 r=6.0/EP7 r=3.56 四连败 400）+ 换代集逐槽实扫（见换代集分支节）缺件=STOP；试水门不豁免 | 机检输出+逐槽实扫登记行 | 生成 spec + progress.md |
| VC-5 | 试水+人工门不豁免：批次第 1 件=试水件走完整链路（出件→机器 QC→tmp/ 呈示附审查地址→用户放行）后才展开其余件；段间复试水；替换件 r2 亦过人工门；[gate-skip] 仅限用户显式指令逐字登记 | grep 放行/试水/否决登记行 | progress.md |
| VC-6 | 八类 QC：重生成/修正批成片 QC 按 tools/specs/qc-items-video-8cat.json 八类（T1-T8）全执行；UNVERIFIED 记缺陷待人工，禁止凭满分放行（EP6 判例：五类盲区 17/17 段带错放行） | qc.py verdict JSON 8 item 落盘 | tmp/<任务前缀>/qc/ |
| VC-7 | N 维对拍双查：生成前 epNN-prompts 逐镜 vs epNN-script 画面行核对四要素（地点/动作/在场角色/事件），镜头词错先修词再重生成；生成后抽帧对拍同四要素（QC T8 对应；判例 EP6 S03-S05 三层错配） | 对拍核对表+T8 evidence | progress.md 对拍行 |
| VC-8 | 收口三登记+seam QC：拼接件过 seam QC（否定式接缝 item）才入台账；台账逐段注记（S\<NN\>.\<seg\> 与回拼终态关系×处置路径）；NAS 覆盖同步+VERSIONS.md 更新+逐件 stat 核对；被替换旧件当日归档（-superseded）登记 docs/archive/README.md | 台账行+NAS stat+归档簿行 | output/ 台账 + docs/archive/README.md |

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
逐 Phase 登记工具面与理由;Executor 字段仍是委派门控机器事实源;mini 豁免
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

## Phases

### Phase 1: 缺陷定位（禁止未定位重发）
- [ ] 问题件 tmp/ 副本 + `tools/qc.py` frames 抽帧（缺陷邻域加密，判例五帧 0.3/1.5/3.0/4.5/6.0s）或 analyze_video 实检
- [ ] 缺陷定位行逐件落 progress.md（件号×[in_s,out_s]×描述×类别，类别对齐八类 T1-T8）
- [ ] 用户报障未点名 → 逐件对账清单呈用户指认；同型缺陷复现 ≥2 = 模板级，先按约束 8c 固化 prompts/ 子句再分流
- **Executor:** 主进程/executor

| ID | 目标 | 执行体 | 输入 | 产出 | 时长 | 状态 |
|----|------|--------|------|------|------|------|
| S1 | 抽帧实检定位各问题件缺陷时间段 | executor | 问题件 mp4; tools/qc.py | 缺陷定位行 | 15min | pending |
| S2 | 定位行+对账清单落 progress.md 呈用户指认 | 主进程 | progress.md | 用户指认结论 | 10min | pending |

### Phase 2: 处置对账表（AGENTS 约束 17④ 四级阶梯逐件路由）
- [ ] 逐件路由：a 剪辑补救（edit.py cut/concat/xfade，0 生成调用，优先）→ b 片内段级重生成（缺陷段±上下文窗裁剪→同参考组同规格族重生成→回拼，正确部分零重发）→ c 整件重生成（缺陷遍布/回拼不可行）→ d 全量（仅换代级+批准，入 Phase 3）
- [ ] 处置对账表落 progress.md；b/c 路径生成 spec 必带 kind="fix"或"regen" + 非空 disposition_ref（指向处置对账表/批准登记，gen.py 机械门缺=exit 2）
- [ ] 视频类重试轮次=三连败 STOP 门（同型缺陷连续 3 轮未收敛=强制停批+4 维归因+用户三选项裁决；约束 19⑤ 图片 10 次择优不适用于视频）
- **Executor:** 主进程/executor

| ID | 目标 | 执行体 | 输入 | 产出 | 时长 | 状态 |
|----|------|--------|------|------|------|------|
| S1 | 逐件四级路由并落处置对账表 | 主进程 | progress.md | 处置对账表 | 10min | pending |

### Phase 3: [full-regen] 门槛（仅 d 级行触发；a/b/c 级=登记 skip 理由后跳过）
- [ ] d 级须五条件核验表逐条 ✓ 后方可展开：

| # | 核验条件 | 判定 |
|---|----------|------|
| 1 | 缺陷定性=锚点/风格/参考组换代级（同批件全部失效，非单点缺陷） | ☐ |
| 2 | 四级阶梯排除确认：a/b/c 逐件评估均不可行且对账表留痕 | ☐ |
| 3 | 用户批准原话/指令出处逐字登记 progress.md `[full-regen]` 行（批次范围×出处×日期） | ☐ |
| 4 | task_plan.md Decisions Made 同步登记 | ☐ |
| 5 | 重试范围最小化预案：换代对象补制清单+新参考组定档先行，重试仅覆盖受失效影响件 | ☐ |

- **门控语义**：任一 ✗ 或无批准登记 = 本 Phase 停留 in_progress 呈用户，禁入 Phase 5；子代理无权代批
- **Executor:** 用户裁决（主进程 STOP 呈示，含"主进程"免 S-unit 检）

### Phase 4: 参考完备机检（先读下方「换代集分支」节定门禁等级）
- [ ] **第零条·对齐原则核对（2026-09-28 用户定档）**：成片每个实体/形态/状态可溯源到锚件（multiview/sheet/场景件）或剧本画面行，无法溯源=编造=FAIL（判例：jeep 化 compact/车顶的狗/第三台房车/行车天篷）；T3 判定挂 sheet 图对照
- [ ] gen.py video_ref_gate 机械门：video spec refs 1-5 张；本地参考图宽高比 w/h ∈ [0.4, 2.5]（超限列出文件与实际比值后 exit 2，判例 EP4 r=6.0/EP7 r=3.56 四连败 400）
- [ ] 换代集逐槽实扫：含该对象的段 refs vs 固定 5 槽清单，缺该对象件=STOP 先走 B 型补资产，禁槽留空开批（EP6 S04 起槽留空判例）
- [ ] 参考组锚点单一事实源核对：**参考组 v2.2 布局（唯一事实源=`prompts/reference-slots-v2.md`，2026-09-28 用户锁定）**：槽1=线稿净版格拼图（排除误导走位）/槽2-3=主角 multiview 整件×2/槽4=道具 sheet 合版整件/槽5=关键帧九宫格（链式 i2i：后帧含前帧+铆钉件满配，场景切换可断链）；**四铁律**：单一实体单格/服装=本镜事实/线稿净版/双车间距硬子句；**multiview 唯一件**（约束 18①，禁裁格重拼、禁单视角混入）；旧规格卡 §13 五槽已作废
- [ ] 镜头词组装核对：structured-shot-template 四段式+五问自检 + common-sense-clauses 子句族（外景零提及制/升顶行驶禁令/状态链载体句）+ model-limit-avoidance 盲区逐条过（元素可见性二选一/行驶镜禁清晰面部）
- **Executor:** 主进程/executor

| ID | 目标 | 执行体 | 输入 | 产出 | 时长 | 状态 |
|----|------|--------|------|------|------|------|
| S1 | 机械门+换代集逐槽实扫全部待重生成段 | executor | tools/gen.py; 槽位清单 | 机检+实扫登记行 | 15min | pending |

### Phase 5: 重生成批（子代理 B 任务——试水件先行+段间复试水+八类 QC+N 维对拍）
- [ ] 开批前置 grep：Phase 3 `[full-regen]` 放行登记行存在（d 级）或 Phase 3 skip 登记存在（a/b/c 级）；缺=STOP
- [ ] 试水件=批次第 1 件：出件→八类 QC→tmp/ 呈示+审查地址清单+对照行→STOP 等用户放行→才展开其余件；分段批次每段第 1 件=该段试水件；风格/锚点/参考组换代后既有段全部失效须重试水
- [ ] 生成前 N 维对拍（prompts vs script 四要素）先修词；每段镜头词带状态链载体句（common-sense-clauses.md §4，取值=剧本道具状态表）；talking 镜带语言锁+音色子句（约束 11/12 逐字抄角色卡）
- [ ] 逐段生成（reference 混交 4-5 张，约束 4 成本警示在前）→ 八类 QC（T1-T8 全执行）→ 生成后抽帧对拍；重发件 PASS 项回退须全量复 QC 登记
- **Executor:** 子代理 B（与词修/草稿任务分派不同子代理；派发 prompt 含 Rule 32.2 禁令行）

| ID | 目标 | 执行体 | 输入 | 产出 | 时长 | 状态 |
|----|------|--------|------|------|------|------|
| S1 | 试水件生成+八类 QC+呈示 STOP 等放行 | 子代理 B | tools/gen.py; tools/qc.py | 试水件+verdict JSON | 15min | pending |
| S2 | 获放行后批内其余件逐段生成+QC+对拍（批量大按段拆行，每行 ≤15min 口径） | 子代理 B | 段级 spec | 逐段 mp4+verdict | 15min | pending |

### Phase 6: 收口（seam QC + 三登记 + NAS VERSIONS + 旧件归档）
- [ ] 拼接/回拼件过 seam QC（qc.py 接缝 item 否定式 "no visible hard cut, black frame, freeze frame, or audio pop at splice points"；frames.times_s 覆盖接缝点 ±0.2s）；FAIL 回 edit.py 调整或回 Phase 5 重生成该段
- [ ] 三登记：① output/ 台账逐段注记（替换片段 S\<NN\>.\<seg\>.mp4 与回拼终态件关系×处置路径）② NAS 覆盖同步 /mnt/nas/Photos/<epNN>/epNN-videos/ + VERSIONS.md（★推荐/✗废弃点名错在哪/⚠带缺陷放行）+ 逐件 stat 字节数核对 ③ docs/archive/README.md 旧件归档行（-superseded 当日）
- [ ] 成片 tmp/ 下载 Read 呈示（批量逐条附审查地址清单）；处置范围逐件收尾对账（VC-1/VC-2 闭环）
- **Executor:** 子代理 B → 主进程验收

| ID | 目标 | 执行体 | 输入 | 产出 | 时长 | 状态 |
|----|------|--------|------|------|------|------|
| S1 | seam QC+三登记+NAS 同步+归档收口（量大按件拆行） | 主进程 | tools/edit.py; output/ 台账 | 收口登记全套 | 15min | pending |

## 🔁 换代集分支：对象先验等级 × 门禁等级联动（显式成节，EP6 判例固化）
> **EP6 判例一句话**：S04 起参考组座驾槽留空（座驾换代无母图可挂）无人拦截 → 车辆全片崩坏、17/17 段带错放行。[源]=ep06-error-audit.md §四根因2
> **试水门不豁免本节**：换代集的试水件也必须先过参考完备机检才允许发起。

| 对象先验等级 | 判定（模型对该对象的先验） | 门禁等级 | 开批前必做 |
|--------------|---------------------------|----------|-----------|
| 高（常驻已建模） | 剧本常驻座驾/道具/场景，现役 multiview 母图在库且已入参考组 | 常规机检 | gen.py video_ref_gate（refs 1-5 + 宽高比 0.4-2.5） |
| 低（换代集/定制对象） | 座驾/道具/场景换代件、任何模型先验≈0 的定制对象（新车型/新道具/新装备等） | **mandatory** | 常规机检 + 逐槽实扫「含该对象的段 vs refs」缺件=STOP + 该对象母图 B 型补制先行 + 逐段镜头词点名该对象（含状态链载体句） |

- 先验等级判不准 → 一律按低档 mandatory 处置（就高不就低）
- 换代对象母图补制走 video-type.md B 型资产链（根图先行→multiview→G1 人工门），补制定稿后回本模板 Phase 4

## 🔗 子代理隔离铁律（AGENTS.md 约束 15 执行序，同 video 模板强制）
- 词修/机检/对拍（P1-P4）与重生成批（P5）分派不同子代理任务；同任务自动衔接=违规（判例：段一 7 段"只过 subagent analyze 就发起"全票作废）
- 子代理只能产出替换件+机器 QC 结论+呈示；人工放行判定只有用户能做；子代理完成态=STOP
- 派发 P5 的 prompt 必含：「前置=放行/批准登记行 progress.md grep 可查（缺=STOP 不得发起 video）」+ 约束 4 成本警示已完成

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 处置 SOP | videop1-video-fix skill §0-§11（四级阶梯/八类 QC/换代集门禁） | .zcode/skills/videop1-video-fix/SKILL.md | 必读 | ☐ |
| 八类 QC | qc-items-video-8cat.json（T1-T8 items） | tools/specs/ | 必读 | ☐ |
| 常识子句 | common-sense-clauses.md（§4 状态链载体句等） | prompts/ | 必读 | ☐ |
| 原始判例 | EP6 审计（四根因+59 项硬错误） | docs/series/jipin-nvdiaoshou/ep06-error-audit.md | 必读 | ☐ |
| 项目指令 | AGENTS.md 关键约束 4/8/11/12/13/14/15/16/17④/18 | AGENTS.md | 必读 | ☐ |
| 参考组定档 | 集级规格卡 §13 固定 5 槽 + p5-reflock §v6 | docs/series/<series>/ + plans/ | 必读 | ☐ |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |
