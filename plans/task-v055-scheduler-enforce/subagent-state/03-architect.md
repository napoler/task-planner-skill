# 03-architect — 「指令性文本 → 机制性强制」修复方案设计

- 状态: 完成
- 日期: 2026-09-07
- 输入: findings.md 根因 1-5 + 7 处必读源码(全部 Read 验证, 见 §1)
- 产出: 方案矩阵(§2) + 推荐方案详细设计(§3) + 副作用评估(§4)
- 约束遵守: 只读分析 + 本检查点, 未改 skills/ 任何源码

## 1. 设计事实基线(全部一手 Read 验证)

| # | 事实 | 位置 | 对设计的影响 |
|---|------|------|-------------|
| F1 | PreToolUse 现有逻辑 = 哨兵检查(调 check-scope.sh) + Rule 23 并发提醒, 恒 exit 0(除哨兵 exit 2) | zcode-pretooluse.sh:13-18, 21-47, 48 | 新拦截分支插入点 = 哨兵检查之后、Rule 23 之前 |
| F2 | hook stdin 已解析 .tool_name / .tool_input.file_path(jq) | zcode-pretooluse.sh:8-9 | 同款 jq 方式可取 .tool_input.new_string / .content(行数判定) |
| F3 | ZCode hook 约定: exit 0 放行 / exit 2 阻断(PreToolUse deny) / stdout 严格 JSON 仅 additionalContext 合法 | ~/.zcode/.../zcode-guide/diagnosing-hooks/SKILL.md:36 | 阻断=exit 2(stderr 文案); 警告=additionalContext+exit 0 |
| F4 | matcher "Write\|Edit", timeout 5s; 无 Stop hook 注册; 全局 hook(所有会话跑) | ~/.zcode/cli/config.json:36-49 | 改脚本内容零注册变更即生效; 逻辑须 <100ms; 无计划会话必须放行 |
| F5 | matcher 别名: ApplyPatch→Write/Edit, Task↔Agent | diagnosing-hooks/SKILL.md:29 | 工具过滤须含 ApplyPatch |
| F6 | check-complete.sh 的 phase_entries 扫描器已提取 `### Phase` + `- **Status:**` | check-complete.sh:134-149 | Executor 行与 Status 相邻(模板), 同扫描器扩展提取, 成本最低 |
| F7 | Executor 字段格式: `- **Executor:** explore（mini）` / `- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）` | templates/task_plan.md:143,169,180,191,202 | 解析规则: 行首匹配 `- **Executor:**`, 值以「主进程」开头=直做(须含例外理由), 否则=子代理 |
| F8 | 委派统计现有人工位: verification.md:75-78 checkbox + task_plan.md:312-322 表格 | 两模板 | 自动统计输出到 stdout, 手填以脚本输出为准; 脚本不写回文件(见 F10) |
| F9 | delegation_rate_floor: default 0.7, JSON-Schema 形态(.properties.X.default), 无任何脚本消费 | config.json:36-41 | 接线 = python json.load 取 .properties.delegation_rate_floor.default, 失败兜底 0.7 |
| F10 | attest-plan.sh 对 task_plan.md 做 SHA-256 锁, userpromptsubmit 校验, 不匹配=[PLAN TAMPERED] | attest-plan.sh:1-9 | check-complete.sh 绝不能写回 task_plan.md(破锁); 执行期改 Executor 会被检出=统计源可信 |
| F11 | claude 位 PreToolUse hook 直接参数式调 check-scope.sh, Stop hook 调 check-complete.sh | register-hooks-cj.ts:116-137 | 参数式共享脚本 check-delegation.sh 可被两平台适配器复用; claude 位参数无 new_string→无 trivial 行数豁免 |
| F12 | 体检清单 = lib/verify.sh 8 项(check 5=check-complete.sh runs OK, check 8=hooks per platform) | lib/verify.sh:17-26 | 新脚本+gate 行为须同步 verify.sh |
| F13 | check-scope.sh 白名单语义: walk-up 找 plans/ 祖先 + 三件套文件名豁免 | check-scope.sh:46-67 | 新白名单复用同款语义, 追加 .claude/plan-templates/、.zcode/plans/、SKILL_ROOT 自身 |
| F14 | SKILL.md 570 行、P0 字样 28 次(grep 验证); 定位块 1 行; 最佳实践段 34 行与定位内容重叠 | SKILL.md:29, 37-70 | 收敛 = 合并重叠区块 + P0 分级, 净减 ≥70 行 |
| F15 | 活跃计划解析链已有现成脚本(.active_plan 指针→mtime→legacy, 恒 exit 0) | resolve-plan-dir.sh:1-14 | 新分支直接复用, 不重造 |
| F16 | opencode 位 hook 注册 = SKILL.md frontmatter hooks 块(stub 说明) | SKILL.md:20-21; lib/verify.sh:25-26 | opencode 位拦截可行性未证实, 不做跨平台假承诺 |

**置信度标注**:
- exit 2 阻断/JSON 约定: HIGH(F3 文档 + F1 现网同款在用)
- Edit stdin 含 new_string: MEDIUM(工具参数惯例, 未实证, Phase 0 实测)
- 子代理 stdin 区分字段: LOW-MEDIUM(diagnosing-hooks 无载 → Phase 0 实测是 enforce 前置条件)

## 2. 方案矩阵

### 方案 A: 最小方案(终验统计 + 文案收敛, 无执行期拦截)

| 维度 | 内容 |
|------|------|
| 改动文件 | ① check-complete.sh python 段(:134-149 扫描器扩展 Executor 提取 + :269-320 间新增 Delegation Gate) ② SKILL.md(:29 定位块 + :37-70 最佳实践段合并, 六项白名单内联, P0 分级) ③ config.json(delegation_enforce 新 key 暂不用或只做文档) ④ lib/verify.sh(check 5 说明) |
| 覆盖根因 | 2(终验统计)/3(白名单进 SKILL)/4(文案收敛)/5(floor 接线); **根因 1 不覆盖** |
| 风险 | 低: 纯终验 gate + 文档, 无执行期误伤面 |
| 缺陷 | 最强根因(执行期零拦截)未治; 主进程亲为仍无任何机制在「发生瞬间」响应 |
| 工作量 | ~0.5 天 |

### 方案 B: 完整方案(A + PreToolUse 执行期硬拦截)— **推荐**

| 维度 | 内容 |
|------|------|
| 改动文件 | A 全部 + ⑤ scripts/check-delegation.sh(新, 参数式共享核心, ~120 行) ⑥ scripts/zcode-pretooluse.sh(哨兵检查后加委派门控分支, ~60 行) ⑦ scripts/register-hooks-cj.ts(:119 PreToolUse 命令追加 check-delegation 调用, claude 位, 需用户授权重注册) ⑧ templates/task_plan.md(委派统计表加「以 check-complete.sh 输出为准」注) ⑨ scripts/allow-direct.sh(新, bypass 标记管理, ~30 行) |
| 覆盖根因 | 1(执行期硬拦截)/2/3/4/5 全部 |
| 风险 | ①子代理误伤(最高, 缓解见 §4.1: stdin 探测+warn 默认+Phase 0 实测) ②timeout 5s(逻辑 <100ms, 必要时提至 10s) ③跨平台差异(claude 位无 trivial 豁免, 如实标注) |
| 工作量 | ~1.5-2 天(含 Phase 0 实测与两阶段 rollout) |

### 方案 C: 渐进方案(B 的两阶段 rollout 策略, 非独立架构)

= 方案 B, 但 delegation_enforce 初始 "warn"(警告不阻断), Phase 0 实测子代理 stdin 可区分后切 "enforce"。**C 是 B 的落地路径, 不是第三个备选架构**。

### 推荐: 方案 B, 以 C 的两阶段 rollout 落地

理由(权衡): A 治标不治本——用户诉求是「机制性强制」, 根因 1(执行期零拦截)是解释力最强的根因, 绕过它 = 修复不达标(findings.md:12 VC-2 门控「纯文案修改不算达标」)。B 的最大风险(子代理误伤)有三层缓解且可控(warn 默认兜底), 不会卡死会话; B 另有三个正外部性: ①check-delegation.sh 参数式设计使 claude 位可低成本复用 ②与 attest 锁(F10)形成「计划期锁定→执行期拦截→终验统计」三层闭环 ③delegation_rate_floor 从死配置变为双消费者接线。

## 3. 推荐方案(方案 B)详细设计

### 3.1 PreToolUse 拦截逻辑(zcode-pretooluse.sh 新增分支, 插入哨兵检查:13-18 之后、Rule 23:21 之前)

```bash
# ─── [新增] Rule 25 执行期委派门控(fail-open 总则: 本分支任何异常 → 放行) ───
delegation_gate() {
  # (0) 开关: SKILL_ROOT/config.json → delegation_enforce ∈ {enforce, warn, off}
  #     解析失败/缺失 → warn(保守默认; Phase 0 实测后切 enforce)
  # (1) 工具过滤: tool ∈ {Write, Edit, ApplyPatch} 否则 return 0(F5 别名)
  # (2) 子代理放行: jq 探测 '.agent_type // .agentType // .agent_id
  #     // .subagent_type // .parent_tool_use_id' 任一非空 → return 0
  #     [置信度 LOW-MEDIUM: Phase 0 实测 dump stdin 确认, 是 enforce 前置条件]
  # (3) bypass 逃生门(先于一切重判定, 保证不被卡死):
  #     a. 活跃 plan 目录存在 .allow-direct 标记 → return 0 + stderr 提示
  #        「直做窗口开启中, 完成后在 Executor 字段补 Rule 25.3 理由」
  #     b. 环境变量 TASK_PLANNER_ALLOW_DIRECT=1 → return 0(仅用户 shell 启动场景可达)
  # (4) 活跃计划: plan=$(bash resolve-plan-dir.sh "$PWD"); 空 → return 0
  #     (无计划会话归哨兵机制管辖, F4 全局 hook 不扰无关会话)
  #     plan 含 outcome: COMPLETE|BLOCKED → return 0(完结静默, 同 posttooluse.sh:39)
  # (5) 文件白名单(复用 check-scope.sh:46-67 语义, F13):
  #     a. walk-up 祖先含 plans/ → 放行(天然覆盖 worktree 内 plans/** 同步)
  #     b. 路径含 /.claude/plan-templates/ 或 /.zcode/plans/ → 放行
  #     c. basename ∈ {task_plan,findings,progress,notepad-learnings,verification}.md → 放行
  #     d. 路径位于 SKILL_ROOT 内部 → 放行(技能自维护 = 白名单②)
  # (6) trivial 行数判定(Rule 25.3 ⑥):
  #     new=$(jq -r '.tool_input.new_string // .tool_input.content // empty')
  #     new 非空且 $(printf '%s' "$new" | wc -l) ≤ 3 → return 0
  #     new 为空(字段缺失无法判定) → 会话计数(复用 /tmp/task-planner-hook-<sid>.state 模式):
  #       首次 → emit 警告 + 放行; 第 2 次起 → 按当前 enforce 档处置(降级策略, 任务约束指定)
  # (7) 触发处置:
  #     enforce 档 → stderr 阻断文案 + exit 2(F3)
  #     warn 档 → emit '{"additionalContext": "[delegation] ⚠️ 主进程亲为: <file> 不在
  #               调度器白名单(Rule 25), 应派子代理或登记 25.3 理由"}' + return 0
}
```

阻断文案(教育式, exit 2 时 stderr):
```
task-planner [Rule 25] 🚫 主进程亲为拦截: <file> 不在调度器白名单
主进程 = 调度管理器(规划/拆分/派发/验收/簿记), 业务写入派子代理(Rule 13/14/25)
合法路径三选一:
  1. 派发: Agent(subagent_type=...) 执行, 主进程只验收 Read + 回填三文件
  2. 登记: 在 task_plan.md 对应 Phase 的 Executor 字段补白名单理由(25.3 六项)
     [attest 锁定中 → 先 attest-plan.sh --clear, 改完重锁(F10)]
  3. 临时放行: bash ~/.zcode/skills/task-planner/scripts/allow-direct.sh on
     [默认 30 分钟窗口, expire 后自动恢复拦截]
误报 → 开启放行后向用户报告案例, 用于修正白名单
```

设计要点:
- allow-direct.sh on/off/status: 在 plan 目录写 .allow-direct(内容=过期 epoch), hook 检查未过期才放行; Bash 工具不在 Write|Edit matcher 内 → 主进程/用户天然可达, 这是逃生门的物理基础
- timeout 预算: 全链 bash+jq+awk <100ms, 5s(F4)富余; 不做 git 调用等慢操作
- fail-open 实现: 脚本无 set -e(现状), jq 失败 → 变量空 → 各判定 return 0; 超时被 kill 的行为不可控 → 依赖逻辑轻量, 必要时 cli/config.json timeout 5→10(部署位操作, 需用户执行)

### 3.2 check-delegation.sh(新, 参数式共享核心)

```
Usage: check-delegation.sh <tool> <file> [content_file]
  content_file: 可选, 存放 new_string/content 的临时文件(zcode 适配器从 stdin 解出后写入)
Exit: 0=放行 1=白名单外主进程亲为(调用方决定 exit 2 还是警告)
stdin 依赖: 无(平台无关)
```
架构理由: claude 位 PreToolUse 本就是参数式(register-hooks-cj.ts:119 `check-scope.sh "$HOOK_TOOL" "$HOOK_FILE"`, F11), zcode 位适配器解 stdin 后传参 → 一处逻辑两平台复用; claude 位无 content_file → 无 trivial 豁免(平台差异如实标注, 不假承诺)。zcode-pretooluse.sh 调用后聚合退出码: 哨兵(rc=1→exit 2)优先, 委派(rc=1→按 enforce 档 exit 2 或警告), 之后才进 Rule 23。

### 3.3 委派率自动统计算法(check-complete.sh 接入)

接入点(精确到行):
1. **扫描器扩展** :134-149: while 循环内 `- **Status:**` 提取旁加 `elif ls.startswith("- **Executor:**"): exec_txt = ls`; phase_entries 变三元组 (ph_line, status_txt, exec_txt)
2. **统计块**(新增, 放 :269 3-File Gate 之前):
   ```python
   exec_total = len(phase_entries)
   sub_n   = sum(1 for _,_,e in phase_entries if e and not "主进程" in e.split("（")[0])
   mains   = [e for _,_,e in phase_entries if e and "主进程" in e.split("（")[0]]
   missing = [ln+1 for ln,_,e in phase_entries if not e]
   # floor 接线(F9): json.load(SKILL_ROOT/config.json)["properties"]
   #   ["delegation_rate_floor"]["default"], 异常 → 0.7 + stderr 提示(fail-open 于阈值)
   # 白名单理由正则(宽松, 防 Executor 手写格式漂移误伤):
   WL = re.compile(r'例外理由[:：].*?(①|②|③|④|⑤|⑥|git|worktree|计划系统|验证命令|用户显式|22\.3|兜底|trivial|3\s*行)')
   bad_mains = [e for e in mains if not WL.search(e)]
   ```
3. **Gate 判定**(接入 :320 `complete == total` 出口链):
   - missing 非空 → `[plan] Delegation Gate: Phase 行 N 缺 Executor 字段(Rule 25.1 计划无效) — 补字段后重跑 attest` + sys.exit(1)【任何时刻拦: 结构错误】
   - complete==total 且 sub_n/exec_total < floor 且 bad_mains 非空 → `[plan] Delegation Gate failed (Rule 25.4): 委派率 sub/total < floor, 白名单外直做 K 项 → outcome 最高 PARTIAL, 禁止 COMPLETE` + sys.exit(1)
   - complete==total 且全部直做理由白名单内 → 放行 + `[plan] Delegation: sub/total (编排型任务, 白名单直做 K 项, 不降级)`(Rule 25.4 尾句: 编排/簿记型属正常形态)
   - 未全 complete → 仅 print 统计(执行中途可见性, 不拦)
4. **一致性校验**(轻量): task_plan.md「📊 委派统计」表(:312-322)分子分母与计算不一致 → WARNING 不拦(手填格式容错)
5. **红线**: 脚本只读不写(F10 attest 锁)——统计权威数字走 stdout, verification.md 由主进程手填(SKILL.md 终验步骤改述「数字以脚本输出为准」)

三层闭环(本设计与既有机制的化学反应): 计划期 attest 锁定 Executor 字段(执行期篡改 → [PLAN TAMPERED]) → 执行期 PreToolUse 拦截亲为 → 终验按 Executor 算委派率。统计源可信度由 attest 背书, 主进程无法靠改字段洗白委派率。

### 3.4 delegation_rate_floor / delegation_enforce 接线

- delegation_rate_floor 消费者: check-complete.sh Delegation Gate(唯一; 不加第二消费者, YAGNI)
- config.json 新增:
  ```json
  "delegation_enforce": {"type":"string","enum":["enforce","warn","off"],
   "default":"warn","description":"Rule 25 execution-time gate mode in PreToolUse hook
   (consumed by check-delegation.sh); start warn, switch enforce after Phase-0
   subagent-stdin probe confirms agent-distinguishing fields"}
  ```
- rollout: 初始 warn(观察 1-2 个真实任务 + Phase 0 实测) → 切 enforce。切换判据: 实测确认子代理 Write 触发 hook 时 stdin 含可区分字段, 或确认子代理工具调用不经 PreToolUse hook(后者直接无误伤)。

### 3.5 SKILL.md 收敛策略

预算: 570 → ≤500 行(净减 ≥70), P0 字样 28 → ≤10。
手法(区块级):
1. **合并重叠区块**: 「主进程定位(P0)」(:29, 1 行) + 「专业代码编辑最佳实践」(:37-70, 34 行) → 单一「调度器定位(P0)」区块 ≤20 行: 定位 3 行 + 六项白名单内联 9 行 + 逃生门/机制提示 3 行。两段同讲「主进程不直接 Edit」(F14), 合一后权重集中, 净省 ~15 行
2. **六项白名单内联格式**(自 critical-rules.md:163 提炼, 9 行):
   ```
   主进程直做白名单(Rule 25.3, 仅此六项; Executor 字段引用格式 = 括号序号):
   ① 纯 git/worktree 编排    ② 计划系统文件维护(三件套/INDEX/ledger/attest/模板)
   ③ 机械验证命令(只读,输出可控)    ④ 用户显式要求主进程亲为
   ⑤ Rule 22.3 兜底接管(单文件≤300行)   ⑥ 单文件≤3行 trivial 修改(非保护区)
   白名单外亲为 = PreToolUse 直接拦截(exit 2); 终验委派率 < floor 且含白名单外理由
   → outcome 最高 PARTIAL(Rule 25.4)
   ```
3. **P0 分级**: 保留真 P0 ≤8 处(调度定位/禁止虚构/跨项目隔离/哨兵门控/委派门控/验证门控/worktree 隔离/技能保护), 其余 20 处 P0 字样逐处降级或删(grep 清单进实现 Phase)
4. 步骤 2.5(:116)追加半句: 「hook 已机制化拦截白名单外亲为(exit 2, scripts/check-delegation.sh)」
5. 终验步骤(:188)改述: 「运行 check-complete.sh, 委派率自动统计; verification.md 委派统计段手填, 数字以脚本输出为准」
6. 细节下沉: 最佳实践段表格中低频行迁 references/(配 critical-rules.md 既有条目), 省 ~40 行

### 3.6 多部署位生效矩阵(不做跨平台假承诺)

| 改动 | zcode 位 | claude 位 | opencode 位 |
|------|----------|-----------|-------------|
| check-delegation.sh + allow-direct.sh(新脚本) | 部署同步即有 | 同左(文件存在) | 同左 |
| check-complete.sh Delegation Gate | 生效(平台无关) | 生效(且 Stop hook 自动触发, F11) | 生效(手动 bash 调用) |
| SKILL.md 收敛 + 白名单内联 | 生效 | 生效 | 生效 |
| delegation_rate_floor/enforce 接线 | 生效 | 生效 | 生效 |
| PreToolUse 执行期拦截 | **生效**(hook 已注册, 零注册变更, F4) | 需改 register-hooks-cj.ts:119 命令 + 用户重跑注册(授权项) | **未证实**(F16 frontmatter 机制, 不承诺) |
| trivial 行数豁免(new_string) | 可行(stdin 可解析) | 不可行(参数式无 new_string) | 未证实 |
| Stop hook 自动终验 | 无注册; 可选加(用户授权改 cli/config.json) | 已有 | 未证实 |

## 4. 副作用评估(逐条: 谁被误伤 + 缓解)

| # | 被误伤者 | 场景 | 缓解 |
|---|---------|------|------|
| 4.1 | **子代理**(最高风险) | 子代理 Write 白名单外文件被 exit 2 → 技能瘫痪 | ①stdin agent 特征字段探测放行(§3.1 步骤 2) ②Phase 0 沙箱实测 dump stdin, 主/子代理 diff ③实测无区分字段 → delegation_enforce 停留 warn, 硬拦截暂缓并如实报告 ④结论写进 config description |
| 4.2 | 无 task-planner 计划的普通会话 | 全局 hook(F4)在任意会话触发 | 无活跃计划 → 判定(4)放行; 哨兵机制行为完全不变(新分支在其后) |
| 4.3 | 其他项目的活跃计划会话 | 用户/主进程临时手改白名单外文件被拦 | .allow-direct 30 分钟窗口(Bash 可达) + warn 默认档 + TASK_PLANNER_ALLOW_DIRECT=1(用户级) |
| 4.4 | 会话被卡死 | jq 缺失/JSON 烂/脚本异常 | fail-open 全链 return 0; 无 set -e; 超时依赖逻辑 <100ms + 可提 timeout 至 10s |
| 4.5 | 旧格式计划(手写无 Executor) | missing gate 拦截变严 | 拦截文案给修复指引(补字段+重 attest); 解析容错(**Executor:** 后任意格式, 仅识别「主进程」前缀); Executor 惯例自 v0.5x 模板已存在(F7), 存量计划少 |
| 4.6 | 编排/簿记型任务(全直做) | 委派率天然 < floor 被误判 PARTIAL | Rule 25.4 尾句已内置: 全部直做理由在白名单内 → 不降级放行(§3.3 判定 3) |
| 4.7 | worktree 隔离场景 | worktree 内拦截行为漂移 | resolve-plan-dir 按 worktree CWD 解析 → worktree 的 plans/ 副本被识别, plans/** 白名单照常放行, 行为与主仓一致 |
| 4.8 | attest 锁交互 | 阻断文案引导改 task_plan.md 会破锁 | 文案内嵌「先 --clear 改完重锁」提示(§3.1 文案 2) |
| 4.9 | 既有机制回归 | 哨兵/plan-sync/3-File Gate/Rule 23 提醒被破坏 | 新分支插入位置后于哨兵、先于 Rule 23(阻断优先于提醒, 可接受); check-complete 改动只在既有判定链上追加, 3-File Gate/Batch/Aggregator 行为不变; lib/verify.sh check 5/8 同步验证 |
| 4.10 | verify.sh 体检 | check 5 行为变化(有 Phase 无 Executor 的 fixture 会 exit 1) | 同步 verify.sh: 更新 check 5 fixture 说明 + 新增 check 9(check-delegation.sh --self-test: 白名单/逃生门/行数判定各 1 例) |

## 5. 负结果报告(检查了什么、排除了什么)

- 检查模块: scripts/(全部 25 个文件清单 + 7 个精读)、templates/(task_plan/verification)、config.json、SKILL.md(1-200 行 + 全文 grep 验证)、lib/verify.sh、~/.zcode/cli/config.json、register-hooks-cj.ts、attest-plan.sh、resolve-plan-dir.sh、zcode-guide/diagnosing-hooks
- 排除的可能性: ①「部署滞后致定位未落地」已被 findings R1 证伪(三部署位 IDENTICAL), 无需部署同步类改动 ②「PostToolUse 加拦截」被排除——PostToolUse 无法阻断已发生的写入, 只能提醒, 不满足「硬拦截」; 它保留为 warn 档的备选注入位(本方案 warn 档实际经 PreToolUse stdout 注入, 效果等价且时点更早) ③「hook 内读 plan 的 Executor 字段判断当前 Phase 是否允许亲为」被排除——hook 无法知道当前正在执行哪个 Phase(无此上下文), 且理由字段是自由文本不可靠; 改用固定白名单+行数+逃生门三要素, 不依赖 plan 内容解析(除活跃/完结判定) ④「check-complete.sh 写回委派统计到 task_plan.md」被排除——attest SHA-256 锁(F10)会破
- 遗留不确定项(实现 Phase 必须先做): Phase 0 子代理 stdin 实测(§3.4 切换判据); Edit stdin new_string 字段实测; opencode 位 PreToolUse 可行性(已标注不承诺)
