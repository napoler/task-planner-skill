# Task Plan: task-v057 子代理 I/O 契约 — 三文件路径必传 + 严格返回格式 + 机械守卫

## Goal
让每次 `Agent()` 派发都**必传计划三文件绝对路径**（task_plan/findings/progress，含读写契约）并要求子代理按**8 固定字段的严格返回模板**逐字段返回；用 PreToolUse hook 对 Agent 调用做机械检查（缺三文件/缺返回字段/缺检查点 → 拦截或告警），终结"靠主进程记得"的文本约束。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（新增 shell 脚本 check-dispatch.sh + selftest-dispatch.sh + zcode-pretooluse.sh 改动，终验前 Code Review Gate） |
| `session_id` | sesse6240c6794f0479b9803f00676539b6b |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v057-subagent-io-contract` |
| `scope_files` | `skills/task-planner/references/critical-rules.md`, `skills/task-planner/templates/subagent_dispatch.md`, `skills/task-planner/config.json`, `skills/task-planner/scripts/check-dispatch.sh`, `skills/task-planner/scripts/selftest-dispatch.sh`, `skills/task-planner/scripts/zcode-pretooluse.sh`, `skills/task-planner/SKILL.md`, `skills/task-planner/companion/agents/plan-writer.md`, `skills/task-planner/references/template-guide.md`, `skills/task-planner/README.md`, `skills/task-planner/INSTALL.md`, `skills/task-planner/scripts/check-complete.sh`(可选授权), `skills/task-planner/scripts/check-delegation.sh`(可选授权), `skills/task-planner/scripts/selftest-delegation.sh`(可选授权) |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 派发模板 §2 含「计划三文件（必传）」块：三条绝对路径占位 + 读写契约（task_plan 只读 / findings·progress 仅追加专属小节）；§7 为 **8 固定字段**严格模板 + 一份已填示例 + "不得增删字段/不加前言总结" | Read 复核 | templates/subagent_dispatch.md §2/§7 |
| VC-2 | critical-rules：22.4 ② 输入必含三文件；新增 22.4a 三文件读写契约、22.4b 严格返回格式（缺字段/自由文本 = partial，以检查点最终结论为准）；22.5 子代理自写 findings 小节时主进程"复核"替代"回填"；22.8.2 T5 最终结论 = 同一 8 字段块 | grep + Read | references/critical-rules.md |
| VC-3 | `scripts/check-dispatch.sh`：合规 prompt exit 0；缺三文件任一 / 缺返回字段（status:/acceptance:/checkpoint: 任一）/ 缺 subagent-state 检查点路径 → enforce=exit 2、warn=exit 0+告警；无活跃计划 exit 0（fail-open）；`selftest-dispatch.sh` ≥6 用例全过 | `bash scripts/selftest-dispatch.sh` | selftest 输出 |
| VC-4 | zcode-pretooluse.sh 新增 `Agent)` 分支（读 `.tool_input.prompt`，调 check-dispatch.sh，异常 exit 0）；config.json 新键 `dispatch_contract_enforce`（enforce/warn/off，默认 enforce）jq 合法 | Read + jq | scripts/zcode-pretooluse.sh, config.json |
| VC-5 | 文档对齐：plan-writer.md:94 / template-guide.md:57 "八字段"→"九字段"；SKILL.md ≤500 行且 P0 计数不减并提及 Agent 派发守卫；README/INSTALL 记录 hook matcher 须含 `Agent` | grep + wc | 对应文件 |
| VC-6 | worktree 内 selftest-delegation/fallback/dispatch 全过 + verify.sh 无非 drift 失败；合并后 3 位部署 diff=0、verify 25/0 ×3；plan-writer agent 副本 ×2 对齐 | 命令输出 | progress Phase 6/7 |
| VC-7 | hook matcher 注册 `Write\|Edit\|Agent`（**需用户显式授权**，`~/.zcode/cli/config.json` 为基础设施配置）后实测：缺三文件的 Agent 派发被拦（enforce）/告警（warn）；合规派发放行 | 本会话实测 1 次 | progress Phase 7 |
| VC-8 | （可选，需用户显式授权）check-complete.sh 委派率比较反转修复：rate≥floor exit 0 / rate<floor exit 1 两侧 selftest 用例过；check-delegation.sh 白名单放行 `~/.zcode/cli/memories/**` | selftest-delegation 新增用例 | 对应脚本 |

**终验规则**：全部 VC 通过 → COMPLETE；VC-7/VC-8 因未获授权而未执行 → 其余全过则 PARTIAL（列出待授权项）；≥1 VC 失败 3 次 → BLOCKED。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则 | references/critical-rules.md | 其他 references（template-guide 除外） |
| 模板 | templates/subagent_dispatch.md | 其他模板、variant/* |
| 配置 | config.json（新键）；`~/.zcode/cli/config.json` hooks matcher **仅在用户授权后**由主进程改一处 | 其他配置 |
| 脚本 | scripts/check-dispatch.sh（新）、scripts/selftest-dispatch.sh（新）、scripts/zcode-pretooluse.sh（加 Agent 分支）；可选授权：check-complete.sh / check-delegation.sh / selftest-delegation.sh | 其他 scripts |
| 文档 | SKILL.md（净零行）、companion/agents/plan-writer.md:94、references/template-guide.md:57、README.md、INSTALL.md（hook 说明处） | 其他 |
| 部署 | 3 位 task-planner + ~/.zcode/agents & ~/.claude/agents plan-writer（若改动） | 其他部署位 |

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部 | 派发模板现状（85 行） | skills/task-planner/templates/subagent_dispatch.md | 必读 | ☑（09-09 Read 全文） |
| 项目内部 | hook 入口与 case 结构 | scripts/zcode-pretooluse.sh:8-45；hook matcher 现值 "Write\|Edit" | 必读 | ☑ |
| 项目内部 | 22.4/22.5/22.8 现文 | references/critical-rules.md:126-135 | 必读 | ☑ |
| 项目内部 | v056 交付与遗漏（八字段残留、check-complete 反转、记忆目录误拦） | plans/task-v056-fine-grained-dispatch/findings.md R4-R7 | 必读 | ☑ |
| 项目内部 | 部署拓扑 + agent 副本 2 位 + install-companion 陷阱 | memory task-planner-repo-deploy-flow | 必读 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: 派发 prompt 的"输入"与"返回格式"都是文本层弱约束——三文件路径靠主进程记得传（v056 实际 12 次派发 0 次传三文件），返回格式靠主进程自写（每次"≤3 行"各不相同）。解决 = 模板固定结构（三文件块 + 8 字段严格返回）+ hook 机械检查 Agent 调用；解决后子代理有充足上下文可读写、返回可机器解析。

**核心问题判断**:
- [x] 解决后能交付（派发契约结构化 + 可拦截）
- [x] 不解决其他工作白费（v056 的步级拆分若子代理拿不到三文件、返回不可解析，"计划做细"的价值折半）
- [x] 方法清晰（模板 + 规则 + hook 分支 + selftest，全部仓内可控；唯一仓外动作 = hook matcher 一行，需授权）

## 设计方案（Phase 1 产出 — 用户确认后生效）

### D1 计划三文件必传 + 读写契约（模板 §2 + Rule 22.4a）
派发 prompt §2 输入首块固定为：
```
- 计划三文件(必传,绝对路径):
  - task_plan: {plan_dir}/task_plan.md — 只读(对齐 Goal/VC/Scope/S-unit 表;状态由主进程翻转,禁止修改)
  - findings:  {plan_dir}/findings.md  — 可读;可写=仅追加自己的小节 `#### [sub:{seq}-{type}] <标题>` 到对应段末尾,禁止改动既有内容
  - progress:  {plan_dir}/progress.md  — 可读;可写=仅在当前 Phase 段「Actions taken」下追加 `[sub:{seq}]` 子项,禁止改 Status/Started
```
读 = 子代理按需 Read 相关段（不通读，受 §9 预算约束）；写 = 追加专属小节（并行子代理各写各的锚点，冲突概率低；主进程终验以检查点为准复核）。22.5 相应改为：子代理已自写 findings 小节 → 主进程 Read 复核该小节并在 Handoff「findings 落点」填锚点；未自写 → 主进程回填（原义务保留为兜底）。

### D2 严格返回格式（模板 §7 + Rule 22.4b + 22.8.2 T5）
8 个固定字段、固定顺序、逐字段填写、无内容填 `none`、不加标题/前言/总结：
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS 2:PASS 3:FAIL(<≤20 字原因>) ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
模板附一份**已填示例**；主进程收到缺字段/自由文本 = 视为 partial，以检查点「最终结论」段（同一 8 字段块）为准（22.8.5 已有）。

### D3 机械守卫（hook）
- 新 `scripts/check-dispatch.sh pretool <prompt-file|-> [sid]`：解析活跃计划目录（plans/.active_plan → 绝对路径）→ 检查 prompt 含 `<plan_dir>/task_plan.md`、`findings.md`、`progress.md` 三绝对路径；含 `status:`、`acceptance:`、`checkpoint:` 三返回字段 key；含 `subagent-state/` 检查点路径。缺项 → 按 `config.json#dispatch_contract_enforce`：enforce=exit 2 + 缺项清单；warn=exit 0 + 告警 + 计数；off=exit 0。无活跃计划/解析异常 → exit 0（fail-open，与 v055 一致）
- `zcode-pretooluse.sh` 加 `Agent)` 分支：`prompt=$(jq -r '.tool_input.prompt')` → 写临时文件 → 调 check-dispatch.sh → rc=2 则 stderr 打缺项 + exit 2
- `selftest-dispatch.sh`：≥6 用例（合规/缺三文件/缺返回 key/缺检查点/warn 档/无活跃计划）
- **hook 注册**：`~/.zcode/cli/config.json` PreToolUse matcher `"Write|Edit"` → `"Write|Edit|Agent"`——基础设施配置，**仅在用户显式授权后**由主进程改（展示 diff）

### D4 文档对齐（净零 SKILL.md）
plan-writer.md:94 与 template-guide.md:57 "八字段"→"九字段"（v056 遗漏）；SKILL.md 在铁律 2 / Rule 22 摘要处以行内方式提及"Agent 派发受 check-dispatch 守卫"（500 行不增）；README/INSTALL 的 hook 章节记录 matcher 须含 `Agent`

### D5（可选，需用户明确授权）既有缺陷顺带修复
- check-complete.sh ~L402 `exit !(r+0 < f+0)` → `exit (r+0 < f+0)` + selftest-delegation 加 rate≥floor / rate<floor 两侧用例
- check-delegation.sh 白名单加 `~/.zcode/cli/memories/**`（记忆写入是系统指令要求主进程直做）

### 明确不做
- 不改 Agent 工具本身/不改 ZCode 内核；不给子代理 task_plan.md 写权限（状态一致性由主进程单写者保证）
- 不给 12 个 variant 模板加内容；不重构 check-delegation.sh 结构（只加白名单一行，且需授权）

## Current Phase
Phase 7（complete — 已交付，见 verification.md）

## Next Step
无剩余 Phase；hook 守卫下个会话起生效；后续建议见 verification.md「遗留」（子代理写计划文件的 PostToolUse diff 校验 / Claude 侧 Task matcher / mini runner 改派 haiku-1）

## Phases

### Phase 1: 调研 + 方案 + 计划撰写
- [x] 派发模板全文 / hook case 结构 / matcher 现值 / 引用点盘点
- [x] 设计 D1-D5
- [x] 用户确认计划 + 两项授权答复（09-09 `yes +hook +fix`：授权改 ~/.zcode/cli/config.json matcher 加 Agent；授权 D5 两处既有缺陷修复）
- **Status:** complete（2026-09-09）
- **Executor:** 主进程（例外理由:② 计划系统文件维护 + ③ 已知位置只读 grep——Rule 25.3 白名单）

### Phase 2: 规则层 critical-rules.md（worktree）
- [x] S-unit 全部 complete（3/3 串行，同文件；worktree commit 5b9467e）
- **Status:** complete（2026-09-09）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 输入(路径 + 摘要) | 验收(可观察) | 预估 | 状态 |
|----|------------|------------------|-------------|------|------|
| S1 | 22.4 ② 输入改为"必含计划三文件绝对路径（22.4a）+ 材料包"；新增 22.4a 三文件读写契约行（D1 文案） | critical-rules.md:126 + D1 | grep "22.4a" 命中；22.4 行含"计划三文件" | 10min | done(380s) |
| S2 | 新增 22.4b 严格返回格式行（D2：8 字段/缺字段=partial/以检查点为准）；22.4 原"返回格式(结论摘要 ≤3 行…)"改为指向 22.4b | critical-rules.md:126 + D2 | grep "22.4b" 命中；grep -c "≤3 行" 在 22.4 = 0 | 10min | done(161s，+22.4c) |
| S3 | 22.5 加"子代理自写 findings 小节 → 主进程复核替代回填"；22.8.2 T5 改"最终结论 = 22.4b 同一 8 字段块" | critical-rules.md:127,132 | grep "复核替代回填\|同一 8 字段" 命中 | 10min | done(340s，+19.1 尾注) |

### Phase 3: 派发模板 + config（worktree）
- [x] S-unit 全部 complete（S1∥S3 并行 + S2 串行；worktree commit bd4cd2c）
- **Status:** complete（2026-09-09）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 输入(路径 + 摘要) | 验收(可观察) | 预估 | 状态 |
|----|------------|------------------|-------------|------|------|
| S1 | §2 首块插入「计划三文件(必传)」三路径 + 读写契约（D1 文案原样）+ §4 git 只读措辞 | subagent_dispatch.md:10-19,34 + D1 | grep -c "计划三文件(必传" = 1；三路径占位各 1 | 10min | done(232s) |
| S2 | §7 重写为 8 固定字段严格模板 + 已填示例 + 禁令；§8 T5 引用同步 | subagent_dispatch.md:50-64,72 + D2 | grep -c "^status: " = 2；"8 字段之后不得有任何内容" 命中 | 15min | done(246s) |
| S3 | config.json 根级新增 `dispatch_contract_enforce`（enum enforce/warn/off，default enforce） | config.json:43-51（参照 delegation_enforce） | jq empty；default = "enforce" | 5min | done(195s) |

### Phase 4: 机械守卫 hook + selftest（worktree）+ D5 缺陷修复（已授权）
- [x] S-unit 全部 complete（S1∥D5 并行 → S2 → S3 串行；worktree commit 2944bf8）
- **Status:** complete（2026-09-09）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 输入(路径 + 摘要) | 验收(可观察) | 预估 | 状态 |
|----|------------|------------------|-------------|------|------|
| S1 | 新建 scripts/check-dispatch.sh（≤120 行，bash，fail-open，读 config 档位，解析 .active_plan，5 项检查，exit 0/2） | check-delegation.sh 的 config 读取与 active_plan 解析写法（参照）+ D3 | `bash -n` 通过；合规样例 exit 0；缺三文件样例 exit 2 | 15min | done(480s，117 行) |
| S2 | zcode-pretooluse.sh 加 `Agent)` 分支（prompt→临时文件→check-dispatch→rc 2 阻断；其余 exit 0） | zcode-pretooluse.sh:25-45 + D3 | grep -c "Agent)" = 1；`bash -n` 通过；原 Write\|Edit 分支不变 | 10min | done(131s) |
| S3 | 新建 scripts/selftest-dispatch.sh（≥6 用例，输出 "Total: N PASS=N FAIL=0"，参照 selftest-delegation.sh 风格） | selftest-delegation.sh 头部 + D3 用例清单 | 运行 exit 0 且 FAIL=0 | 15min | done(**1098s 超步长**，11 用例；应拆 2 步 — R3） |
| S4（授权后） | check-complete.sh L402 去掉 `!` + selftest-delegation 加两侧用例 | check-complete.sh:396-419 + v056 findings R7 | rate 0.714 vs 0.7 → exit 0；0.5 → exit 1 | 10min | done(与 S5 合并 377s) |
| S5（授权后） | check-delegation.sh 白名单加 `$HOME/.zcode/cli/memories/` 前缀 | check-delegation.sh 白名单段 | selftest-delegation 新用例：记忆目录 Write 放行 | 5min | done(合并) |

### Phase 5: 文档对齐（worktree）
- [x] S-unit 全部 complete（3/3 并行；worktree commit c67af56）
- **Status:** complete（2026-09-09）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 输入(路径 + 摘要) | 验收(可观察) | 预估 | 状态 |
|----|------------|------------------|-------------|------|------|
| S1 | plan-writer.md:94 与 template-guide.md:57 "八字段"→"九字段"（各 1 处行内）+ 拆步纪律补测试类 ≤6 用例/步 | 两文件行号 | grep -c "八字段" plan-writer = 1（仅 :79 Batch）；template-guide = 1（仅 :56 batch_report） | 5min | done(444s) |
| S2 | SKILL.md 行内联动：铁律 2 加"（三文件必传 + 8 字段严格返回，check-dispatch 守卫）"；Rule 22 摘要加"三文件契约/严格返回"；**净零行** | SKILL.md:37,270 | wc -l = 500；grep "check-dispatch" ≥1；P0 计数不变 | 10min | done(206s) |
| S3 | README.md / INSTALL.md hook 章节：matcher 须为 `Write\|Edit\|Agent` + check-dispatch 说明各 ≤5 行 | 两文件 hook 段（grep "PreToolUse\|matcher"） | grep -c "Write|Edit|Agent" 各 ≥1 | 10min | done(264s) |

### Phase 6: worktree 内验证
- [x] selftest-dispatch 11/11、selftest-delegation 38/38、selftest-fallback 21/21；verify.sh 22/3（全 deploy drift）；jq enforce；bash -n ×6；SKILL 500；porcelain 0
- **Status:** complete（2026-09-09；code-runner 违约翻状态/填段已由主进程复核纠正，见 R4）
- **Executor:** code-runner-agent（mini）— prompt 强制 `| tail -N` + 只记汇总行（v056 R5 教训）

### Phase 7: Code Review Gate + 合并 + 部署 + hook 注册 + 终验
- [x] Code Reviewer 5/6 → fix 1d2fbf4 → 复验 6/6 APPROVED
- [x] 主仓 merge --no-ff 83282d2（14 文件 +340/−22）+ 9 项关键串复验；worktree remove + branch -d
- [x] 3 位部署 diff=0 + verify 25/0 ×3 + agent 副本 ×2 + 部署位 selftest-dispatch 12/12
- [x] （已授权）config.json L38 matcher → `Write|Edit|Agent`（备份 /tmp/zcode-cli-config-backup-20260909-063756.json）；本会话固化未即时拦，等效实测 rc=2/0/0
- [x] 终验 VC 逐条 + 委派统计 + check-complete（见 verification.md）
- **Status:** complete（2026-09-09）
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排 + ② 计划系统 + ④ 用户显式授权的 config 一行——Rule 25.3 白名单）

## 🔗 Subagent Handoff 登记表

| 时间 | subagent_type | 目标 | 状态 | 结论 | 证据 | findings 落点 | checkpoint 路径 | verify_done |
|------|--------------|------|------|------|------|--------------|----------------|-------------|
| 09-09 | executor | P2-S1 22.4 输入子串改三文件首块 + 新增 22.4a 读写契约 | done | 22.4@126 首块三文件；22.4a@127；210 行；子代理自写 findings/progress | worktree critical-rules.md:126-127 | findings #### [sub:01-executor]（复核 ✓） | subagent-state/01-executor-p2s1.md | ☑ |
| 09-09 | executor | P2-S2 22.4 返回格式子串 + 新增 22.4b 严格返回 + 22.4c 机械守卫 | done | 22.4b@128 / 22.4c@129；212 行；返回附带"备注"段（违反 8 字段后无内容 → Phase 3 §7 加禁令） | worktree critical-rules.md:126,128-129 | findings #### [sub:02-executor]（复核 ✓） | subagent-state/02-executor-p2s2.md | ☑ |
| 09-09 | executor | P2-S3 22.5 复核替代回填 + 22.8.2 T5 同一 8 字段块 + 19.1 联动 | done | 22.5@130 / T5@135 / 19.1 尾注；212 行；8 字段返回无多余（禁令生效） | worktree critical-rules.md:90,130,135 | findings #### [sub:03-executor]（复核 ✓） | subagent-state/03-executor-p2s3.md | ☑ |
| 09-09 | executor | P3-S1 模板 §2 计划三文件块 + §4 git 只读措辞 | done | §2@11-17 三文件块；§4@39；89 行 | worktree templates/subagent_dispatch.md:11-17,39 | findings #### [sub:04-executor]（复核 ✓） | subagent-state/04-executor-p3s1.md | ☑ |
| 09-09 | executor | P3-S3 config.json 根级 dispatch_contract_enforce 键 | done | default enforce / enum 3 / required 6 不变 | worktree config.json:52-62 | findings #### [sub:05-executor]（复核 ✓） | subagent-state/05-executor-p3s3.md | ☑ |
| 09-09 | executor | P3-S2 模板 §7 严格 8 字段 + 已填示例 + 禁令 + §8 T5 对齐 | done | §7 重写（status 行 ×2/禁令/示例/旧骨架 0）；T5 对齐；104 行；返回带 1 行前言（残余噪声） | worktree templates/subagent_dispatch.md:50-84 | findings #### [sub:06-executor]（复核 ✓） | subagent-state/06-executor-p3s2.md | ☑ |
| 09-09 | executor | P4-S1 新建 scripts/check-dispatch.sh（守卫核心） | done | 117 行；合规 0 / 缺项 enforce 2 + 列表 / warn 0 + 告警 / off 0 / 无计划 0；主进程独立复跑 3 例一致 | worktree scripts/check-dispatch.sh | findings #### [sub:07-executor]（复核 ✓） | subagent-state/07-executor-p4s1.md | ☑ |
| 09-09 | executor | P4-S4+S5 D5 已授权：check-complete 反转修复 + check-delegation 记忆白名单 + selftest-delegation 3 用例 | done | check-complete:404 去 `!`；check-delegation:171 白名单；selftest 38/38（主进程复跑一致） | worktree 三脚本 | findings #### [sub:08-executor]（复核 ✓） | subagent-state/08-executor-p4d5.md | ☑ |
| 09-09 | executor | P4-S2 zcode-pretooluse.sh 加 Agent 分支 | done | @54-66 +13 行；缺项 JSON exit 2 / 合规 0 / Write 基线 0 不变 / off 0 | worktree scripts/zcode-pretooluse.sh:54-66 | findings #### [sub:09-executor]（复核 ✓ 由 S3 selftest 集成覆盖） | subagent-state/09-executor-p4s2.md | ☑ |
| 09-09 | executor | P4-S3 新建 scripts/selftest-dispatch.sh（≥8 用例含 hook 集成） | done | 121 行 11/11；off 反验 FAIL=1 非恒真；**18min/1.24M token/46 calls 超步长（findings R3）** | worktree scripts/selftest-dispatch.sh | findings #### [sub:10-executor]（复核 ✓ 主进程复跑 11/11） | subagent-state/10-executor-p4s3.md | ☑ |
| 09-09 | executor | P5-S1 plan-writer:94 + template-guide:57 八→九 + 拆步纪律补测试类 ≤6 用例/步 | done | plan-writer 261 行 frontmatter 未动；template-guide 57 行内；八字段各剩 1（Batch） | worktree plan-writer.md:94,186 / template-guide.md:57 | findings #### [sub:11-executor]（复核 ✓） | subagent-state/11-executor-p5s1.md | ☑ |
| 09-09 | executor | P5-S2 SKILL.md 净零联动（铁律 2 / Rule 22 摘要 / ≤3 行残留） | done | 500 行 / P0 10 / 22.4a×2 / check-dispatch×1；无派发语义残留 | worktree SKILL.md:37,270 | findings #### [sub:12-executor]（复核 ✓） | subagent-state/12-executor-p5s2.md | ☑ |
| 09-09 | executor | P5-S3 INSTALL/README hook 段：matcher 须含 Agent + check-dispatch 说明 | done | INSTALL 5.1a@179（+4）；README:19 行内 | worktree INSTALL.md:179-182 / README.md:19 | findings #### [sub:13-executor]（复核 ✓） | subagent-state/13-executor-p5s3.md | ☑ |
| 09-09 | code-runner-agent | P6 worktree 全量验证（selftest×3 / verify / jq / bash -n / 模板串）— tail 截断纪律 | done | 8/8（11/11、38/38、21/21、verify 22/3 全 drift、enforce、bash -n×6、SKILL 500、porcelain 0）；**违约：翻 Status/填满段/留占位符/findings 拼接两遍**（R4） | subagent-state/14-code-runner-p6.md | findings #### [sub:14-code-runner]（复核 ✓ 与主进程独立复跑一致） | subagent-state/14-code-runner-p6.md | ☑ |
| 09-09 | Code Reviewer | P7 Code Review Gate：6 脚本改动按 6 判据审查 | done | 5/6；CHANGES_REQUESTED(MINOR)：① warn 计数文件无 TTL/selftest 残留 ② plan_dir 尾斜杠/符号链接假阴性 | subagent-state/15-code-reviewer-p7.md | findings #### [sub:15-code-reviewer]（复核 ✓） | subagent-state/15-code-reviewer-p7.md | ☑ |
| 09-09 | executor | P7-fix check-dispatch.sh plan_dir 归一化 + warn 文件 24h TTL + selftest 残留清理 | done | pd_real×4 / TTL / 12/12 / 尾斜杠 rc=0 / 残留 0；commit 1d2fbf4 | scripts/check-dispatch.sh:24-27,83-91 / selftest-dispatch.sh:127-131 | findings #### [sub:16-executor]（复核 ✓） | subagent-state/16-executor-p7fix.md | ☑ |
| 09-09 | Simple Agent | P7 守卫实测（故意缺契约） | done | 未被拦 → hook 注册会话启动固化；等效实测 rc=2/0/0 通过 | progress Phase 7 | findings R5 | （无检查点，实测用） | ☑ |

## 🔀 隔离决策
- check-conflicts：主仓干净（v056 已全部提交）；无 wt 分支/额外 worktree
- **决策：worktree 隔离**（§十一 11.1-1/-2：技能保护区 + hook 脚本）
- 路径 `/mnt/data/dev/task-planner-skill-worktrees/task-v057-subagent-io-contract`，分支 `wt/task-v057-subagent-io-contract`，基于 master 584dd54
- merge_back: **merged(83282d2)**，worktree 已 remove，wt 分支已删；部署 3 位 diff=0 + agent 副本 ×2；hook matcher 已改（09-09）

## Decisions Made

| 时间 | 决策 | 理由/参考依据 |
|------|------|--------------|
| 09-09 | 新开 v057 而非扩展已交付的 v056 | v056 终态 COMPLETE 已合并部署；Rule 9 |
| 09-09 | 三文件放 §2 输入首块（不另开字段） | 用户原话"输入子代理时候不要忘记传入"；hook 按内容检查与位置无关 |
| 09-09 | task_plan.md 对子代理只读；findings/progress 仅追加专属小节 | 状态字段单写者防 attest/Current Phase 混乱；并行子代理各写各锚点冲突概率低 |
| 09-09 | 返回格式 = 8 固定 key: value 行 + 已填示例 | 用户指出"≤3 行"宽泛不可解析；固定 key 便于主进程 grep 与 hook/脚本解析 |
| 09-09 | hook matcher 与 D5 缺陷修复列为"需授权"而非默认执行 | §六/§十一：基础设施配置与 scope 外保护区脚本须用户显式授权 |

## Errors Encountered

| 时间 | 错误 | 处置 |
|------|------|------|
