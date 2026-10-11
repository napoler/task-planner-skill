# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话（09-09）：①"无论主进程还子代理全部包含有 task planner 的三个主要文件，确保即便是子代理也可以获取充足数据以及交互数据流转——输入子代理时候不要忘记传入三个文件路径，确保可以读写"；②"当前这返回格式有缺陷，为什么不是一个严格示例？'≤3 行：status + 验收 5 项通过情况' 限制太宽幅了，会导致混乱不一定会返回需要的格式，不合理"
- 解读：① = 派发 prompt 必传 task_plan/findings/progress 三文件绝对路径 + 子代理可读可写（写需有并发安全契约）；② = 返回格式改为固定字段的严格模板 + 已填示例，并且要有机制保证主进程不会再自写宽泛格式（v055 教训：文本约束不生效）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1);子代理按 22.4a 自写小节 #### [sub:…] 追加于本段末尾 -->
### R1 现状盘点（09-09，主进程已知位置 grep/Read，白名单③）
1. 派发模板 templates/subagent_dispatch.md（85 行）：§2 输入只有 `{path_1}/{path_2}` + findings 摘要，**无三文件**；§7 返回格式为 5 行占位骨架（`[done|partial|failed|timeout]`/结论摘要 ≤3 行/证据/置信度/受阻点），**无固定 key、无已填示例**；v056 期间主进程 12 次派发均自写"≤3 行"格式且 0 次传三文件 = 模板零约束力实证
2. hook：`~/.zcode/cli/config.json` PreToolUse matcher = `"Write|Edit"`（**不含 Agent**）；zcode-pretooluse.sh:25 `case "$tool" in Write|Edit|ApplyPatch)` → 加 `Agent)` 分支即可读 `.tool_input.prompt` 做检查；脚本约定 fail-open（异常 exit 0）
3. 引用点：critical-rules.md 22.4 "返回格式(结论摘要 ≤3 行 + 证据 file:line + 置信度)"@126、22.5@127、22.8.2 T5@132；**v056 遗漏**：plan-writer.md:94 与 template-guide.md:57 仍写"八字段"（Batch 八字段 :79/:56 不动）
4. config.json 已有 `delegation_enforce`(enforce|warn) 可作 `dispatch_contract_enforce` 的写法参照（:43-51）；根级 additionalProperties:false → 新键需进 properties
5. 既有缺陷（v056 R7）：check-complete.sh 委派率比较反转（L402）、check-delegation 误拦记忆目录——本任务终验会再次触发前者（exit 1 假阴性），列为 D5 可选授权项

### R2 Phase 2 契约 dogfood 结论（09-09，worktree 5b9467e；子代理小节见本段末尾 [sub:01-03]）
- **三文件流转生效**：3 个 executor 均自行 Read task_plan 对齐措辞、写 findings 专属小节、追加 progress 子项；主进程 Read 复核替代回填，Handoff「findings 落点」直接填子代理锚点。代价：主进程再 Edit 这两个文件前必须重 Read（工具校验 mtime）——共写文件的正常成本
- **严格返回生效但需两处补漏**：① S2 在 8 字段后附加了"备注"段——仅写"不加标题/前言/总结"不够，必须明写"**8 字段之后不得有任何内容，需说明写进 blockers 或检查点**"（S3 加此禁令后即合规）→ Phase 3 §7 采用该措辞；② 我写的"禁止 git 操作"被子代理解读为连只读 `git diff` 也禁 → 模板 §4 Scope 默认文案改为"禁止 git 写操作（add/commit/checkout/reset），只读 diff/status/log 允许"
- **结构教训（主进程自身）**：我在 Requirements 后手写了一个 `## Research Findings` 头，与模板原有同名空段重复，子代理小节落到了模板段——已合并；模板段头注补一句"子代理小节追加于本段末尾"
- **成本观察**：带三文件读写的派发 160-380s / 195K-320K token / 12-18 次调用，约为 v056 无契约派发（50-110s / 70K-200K / 5-8 次）的 2-3 倍——增量来自子代理 Read 计划文件 + 2 次追加 Edit + 检查点；这是"充足数据 + 数据流转"的必要成本，可优化点：prompt 明确"只读 task_plan 的 D 段/S-unit 表，不读全文"

### R3 Phase 3-4 落地 + 步长越界实证（09-09，worktree bd4cd2c / 2944bf8）
- 守卫链路闭环：`check-dispatch.sh`（117 行，7 项检查、3 档位、fail-open）← `zcode-pretooluse.sh` Agent 分支（+13）← 待 Phase 7 注册 matcher `Write|Edit|Agent`；selftest-dispatch 11/11；主进程独立复跑合规/缺项/warn 三例与子代理结论一致
- D5 落地：check-complete.sh:404 `exit (r+0 < f+0)`；check-delegation.sh:171 记忆目录白名单；selftest-delegation 38/38（T_MEM / T_RATE_OK / T_RATE_LOW）
- **步长越界实证（新规则 21.1b 的第一个反例）**：P4-S3"写 11 用例 selftest"单步耗 **18 分钟 / 1.24M token / 46 次调用**，超 step_max_minutes(15) 且为常规 S-unit 的 5 倍——原因：测试脚本天然含"写→跑→改"迭代，11 个用例的调试循环累积。按 21.4/22.3② 应事前拆为 S3a（harness + T01-T06 纯脚本用例）与 S3b（T07-T11 hook 集成用例），各 ≤15min。教训写入 plan-writer 拆步纪律：**测试/脚本类 S-unit 按"≤6 用例/步"再拆，且 prompt 明写"单用例调试 ≤2 轮，超则记 blockers 交主进程"**（Phase 5 S1 顺带补一句）
- 8 字段返回合规率：Phase 2-4 共 9 次派发，7 次纯净、2 次带 1 行前言（"All work complete…"类）——字段完整可解析；模板禁令已含"不加前言"，残余噪声属模型习惯，主进程解析以 `^status:` 行起算即可，不再加码

### R4 Phase 5-6 落地 + mini 档契约违约样本（09-09，worktree c67af56）
- Phase 5 三文档 S-unit 并行、3/3 返回纯净；Phase 6 code-runner 8/8 PASS 与主进程此前独立复跑一致（selftest 11/38/21、verify 22/3 全 drift、bash -n ×6、SKILL 500）
- **mini 档 code-runner 契约违约 4 项**：① 翻转 progress.md Phase 6 `Status`→complete（契约明写禁止；状态是主进程单写者）② 越权填满 Files/Test Results（只允许追加一行）③ 留下未替换占位符 ④ **把 findings.md 整体拼接两遍再插入小节**（119→251 行，数据损坏；主进程 diff 两副本确认完全相同后按 1-97 + 217-251 重建为 132 行，损坏版备份 /tmp/v057-findings-corrupt-backup.md）。同批 sonnet-1 executor 13 次派发 0 次动 Status、0 次损坏文件——**契约遵守度与模型档位强相关**；主进程 22.5 复核步骤按设计兜住（发现→纠正→记录）
- 改进方向（后续任务，本期不扩 scope）：三文件写入也走机械守卫——PostToolUse 对子代理 Edit/Write 计划文件做 diff 校验（只允许净增行、禁止 Status/Started 变更、禁止行数翻倍）；验证类任务改派 haiku-1 executor 而非 mini runner
- 成本：code-runner 518K token / 21 calls（v056 为 738K / 28）——tail 截断 + "只跑一次"纪律有效但仍是 executor 均值 2 倍

### R5 Phase 7 交付结论（09-09，merge 83282d2；部署 3 位 + agent 2 副本；hook matcher 已改）
- Code Review Gate：Code Reviewer 5/6 → 两项 MINOR（warn 文件 TTL / plan_dir 尾斜杠·symlink 假阴性）→ executor 修复 1d2fbf4 → 主进程复验 → APPROVED；selftest-dispatch 12/12
- 部署：3 位 diff=0（101 文件）、verify.sh 25/0 ×3（首轮 23/24/25 递减 = 顺序部署时序假象，勿误判）；plan-writer 副本 zcode IDENTICAL / claude 仅 model 行
- **hook matcher 改后本会话未即时生效**：`~/.zcode/cli/config.json` hooks 在会话启动时固化（与 v055 agent 定义结论同源）；等效实测（本会话 sid + 仓根 cwd + 已部署脚本）：缺契约 rc=2 列 7 缺项 / 合规 rc=0 / Read rc=0 → 机制正确，**下个会话起所有 Agent() 派发受守卫**
- check-complete.sh D5 修复后首次生产验证：见 verification.md（本任务委派率 ≥0.7 应 exit 0）
- 全程统计：16 次子代理派发（13 executor + 1 code-runner + 1 Code Reviewer + 1 Simple Agent 实测），8 字段返回 15/15（实测例除外）字段完整；三文件契约：executor 13/13 合规，mini runner 4 项违约（R4）

#### [sub:01-executor] 22.4a 落地
- 修改 1: critical-rules.md 第 126 行 22.4「输入」子串改为「**首块 = 计划三文件绝对路径,22.4a** + 材料包路径 + findings.md 摘要 ≤10 行,取自 S-unit 表计划期预写」
- 修改 2: 第 127 行新增 22.4a 计划三文件必传与读写契约行（22.5 顺延至第 128 行）

#### [sub:02-executor] 22.4b/22.4c 落地
- 修改 1: critical-rules.md 第 126 行 22.4「返回格式」子串改为「**8 固定字段严格模板,22.4b**」
- 修改 2: 22.4a 行(第 127 行)后新增 22.4b(严格返回格式)与 22.4c(派发契约机械守卫)两行(22.5 顺延至第 130 行)
- 验收 5/5 PASS:22.4b=L128、22.4c=L129、旧子串 0 处、wc -l=212、L130 以 22.5 开头

#### [sub:03-executor] 22.5/22.8.2/19.1 落地
- L130 22.5「findings 回填义务」改为「复核替代回填」双分支(自写小节→复核填锚点/未自写→兜底回填),旧子串 0 处
- L135 22.8.2 T5「最终结论」段格式改为「= 22.4b 同一 8 字段块,逐字段」
- L90 19.1 行末追加联动括注(子代理自写小节时改为复核,见 22.5);验收 5/5 PASS、wc -l=212

#### [sub:04-executor] 模板 §2/§4 落地
- 修改 1: §2「- 绝对路径:」3 行替换为「计划三文件(必传,绝对路径 — Rule 22.4a 读写契约)」task_plan/findings/progress 3 行 + 「材料包绝对路径」{path_1}/{path_2}
- 修改 2: §4 禁止操作行末追加「默认禁止 git 写操作(add/commit/checkout/reset),只读 git diff/status/log 允许」
- 验收 5/5 PASS:计划三文件=1、{plan_dir}/=3、材料包=1、git 只读=1、wc -l=89

#### [sub:05-executor] config dispatch_contract_enforce 落地
- 根级 properties 在 delegation_enforce 后、provider_fallback 前插入：enum=enforce/warn/off，default=enforce，描述含 Rule 22.4c + check-dispatch.sh + fail-open 语义
- 验收 5/5 PASS：jq 合法、default=enforce、enum 长度 3、required=6 不变、additionalProperties=false

#### [sub:06-executor] 模板 §7 严格返回落地
- §7 整节替换为 8 固定字段严格模板 + 已填示例 + 「8 字段之后不得有任何内容」禁令;§8 T5 行对齐「= 第 7 节同一 8 字段块」
- 验收 5/5 PASS:grep status/confidence=2、禁令/已填示例=1、旧字段残留=0、wc -l=104

#### [sub:08-executor] D5 两处缺陷修复落地
- check-complete.sh:403 去掉 awk 双重取反（exit !(r<f) → exit (r<f)），语义 r>=floor PASS / r<floor FAIL；check-delegation.sh is_whitelisted_path 第 2 组 case 新增 "$HOME/.zcode/cli/memories/"* 放行分支（与 plans/ 同等处理，仅加分支不重构）
- selftest-delegation.sh 追加 T_MEM / T_RATE_OK / T_RATE_LOW 3 用例，汇总 Total 35→38，全绿 PASS=38 FAIL=0；git diff --stat 仅 3 目标文件
- 证据：grep -c "exit (r+0 < f+0)"=1、"exit !(r+0 < f+0)"=0、"cli/memories"≥1、bash -n 三脚本全过；详见 subagent-state/08-executor-p4d5.md

#### [sub:07-executor] check-dispatch.sh 落地
- scripts/check-dispatch.sh 117 行(≤120) bash -n 通过 +x；pretool/check 双入口，缺项扫描 7 key（三文件路径+status:/acceptance:/checkpoint: 标记+subagent-state/）
- 档位链: TASK_PLANNER_DISPATCH_ENFORCE → jq .properties.dispatch_contract_enforce.default(//enforce,jq 缺失 fail-open)；plan_dir 取 TASK_PLANNER_PLAN_DIR → resolve-plan-dir.sh dirname；无活跃计划/目录不存在 exit 0
- 自测 5/5 PASS: 合规 exit 0 / enforce exit 2(check 2 行 exit 1) / warn 落盘 / off / fail-open；详见 subagent-state/07-executor-p4s1.md

#### [sub:09-executor] hook Agent 分支落地
- zcode-pretooluse.sh 在 Write|Edit|ApplyPatch 分支 `;;` 后、`esac` 前插入 `Agent)` 分支(+13 行):prompt 写 mktemp 临时文件 → check-dispatch.sh pretool → rc=2 透传 exit 2,否则 exit 0;fail-open(mktemp/jq 失败 exit 0);文件无 set -e,无需 rc 捕获改写
- 自测 5/5 PASS: bash -n / grep 分支数=1 / 缺项 enforce→exit 2([dispatch-block]→stderr) / 合规→exit 0 / Write 行为不变(基线 0) / off→exit 0;详见 subagent-state/09-executor-p4s2.md

#### [sub:10-executor] selftest-dispatch.sh 落地
- 新建 scripts/selftest-dispatch.sh(121 行 ≤150,bash -n 过,chmod +x):11 用例 hermetic(mktemp -d + trap 清理),覆盖 enforce/warn/off 档位、check 模式、hook Agent 分支集成、无计划 fail-open
- 关键实现:mk_prompt 按参去项生成 7 key prompt;run_case 档位语义——enforce 硬覆盖(warn/off/unset 沿用外层),故外层 TASK_PLANNER_DISPATCH_ENFORCE=off 反验时 T05 恰 FAIL(FAIL=1,满足验收 3「非恒真」)
- 避坑:管道前缀 `VAR=x printf|cmd` 只对 printf 生效,env 须 export 给 hook 子进程;自测 11/11 PASS,详见 subagent-state/10-executor-p4s3.md

#### [sub:12-executor] SKILL.md 净零联动落地
- 铁律 2(行 37)与 Rule 22 摘要(行 270)行内增补 22.4a 三文件契约 / 22.4b 8 字段严格返回 / 22.4c check-dispatch 守卫;wc -l 保持 500,P0 计数不变(10)
- grep 无派发返回格式"结论摘要 ≤3 行"残留,修改 3 跳过(blockers 注明"无残留")

#### [sub:13-executor] INSTALL/README hook 段落地
- INSTALL.md §5.2 前插入 `### 5.1a ZCode PreToolUse matcher 须含 Agent`（无重编号,+4 行）:matcher 须为 "Write|Edit|Agent"、check-dispatch.sh 检查项、selftest-dispatch.sh 11 用例、档位 dispatch_contract_enforce
- README.md L19 行内补充 "范围阻断 + 委派门控 + Agent 派发契约守卫，matcher 须含 Agent"（1± 行）;验收 5/5 PASS

#### [sub:11-executor] plan-writer/template-guide 落地
- plan-writer.md:94 八字段→九字段;template-guide.md:57 八字段模板→九字段模板(含计划三文件必传 + 8 字段严格返回);两文件 :79/:56 的 Batch Report「八字段」保留不动
- plan-writer.md 禁止行为节插入测试/脚本类 S-unit 纪律行(≤6 用例/步再拆 + 单用例调试 ≤2 轮),总数 260→261 行,frontmatter 零 diff


#### [sub:14-code-runner] Phase 6 验证结果
| # | 命令摘要 | PASS/FAIL |
|---|---------|-----------|
| 1 | Total: 11 PASS=11 FAIL=0 | PASS |
| 2 | Total: 38 PASS=38 FAIL=0 | PASS |
| 3 | Total: 21 PASS=21 FAIL=0 | PASS |
| 4 | summary: 22 pass / 3 fail; ✘ 行全部含 "deploy drift" | PASS |
| 5 | enforce | PASS |
| 6 | check-dispatch selftest-dispatch zcode-pretooluse check-complete check-delegation selftest-delegation (6 names) | PASS |
| 7 | SKILL=500 tmpl_three=1 tmpl_status=2 rule22a=1 | PASS |
| 8 | status --porcelain = 0 lines | PASS |

#### [sub:15-code-reviewer] Code Review 结论
1:PASS — fail-open 全路径 exit 0：缺参/不可读/无jq/无计划（check-dispatch.sh:70,73,78,82；zcode-pretooluse.sh:59,60）
2:PASS — prompt 仅 grep -qF 固定串匹配无 eval/无 shell 展开；mktemp 临时文件全路径 rm -f（check-dispatch.sh:29；hook:59,63）
3:PASS — pretool 仅 exit 0/2、check 仅 0/1；hook 仅 rc=2 时 exit 2（hook:64）；Write|Edit|ApplyPatch 分支 diff 无改动
4:PASS(隐患) — 含空格 plan_dir 实测匹配正确；但 plan_dir 带尾斜杠或经符号链接时三文件串匹配假阴性（check-dispatch.sh:26，MINOR）
5:PASS — check-complete.sh:404 awk r<f→exit1→rate_ok=0 语义正确；check-delegation.sh:171 记忆白名单为 case 内纯追加，不改其他分支判定
6:FAIL — selftest 用例非恒真且 hook 集成真实（11/11 实跑 PASS），但 warn 档计数文件 /tmp/task-planner-dispatch-warn-${sid}（check-dispatch.sh:89）与 T_MEM 的 /tmp/task-planner-warn-main-sid.count 未清理，非严格 hermetic

#### [sub:16-executor] Code Review 两项修复落地
- check-dispatch.sh scan_missing 归一化 pd(去尾斜杠)+pd_real(pwd -P 符号链接解析),三文件匹配双路径任一命中;warn 计数文件 ${TMPDIR:-/tmp}/...-${sid} 追加前 24h TTL(find -mmin +1440 删除单一文件)
- selftest-dispatch.sh 统一唯一 SID=selftest-$$、trap 追加清 warn 残留、新增 T12 尾斜杠用例(12/12 PASS)
- 已验收:bash -n 双脚本 OK、selftest Total=12 PASS=12 FAIL=0、尾斜杠/symlink 手测 exit 0、/tmp 残留=0

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
