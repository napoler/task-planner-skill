# 04-critic — 「主进程=调度器」机制化方案 魔鬼代言人审查

- 状态: 完成
- 日期: 2026-09-07
- 输入: 03-architect.md(方案 B)、findings.md(根因 1-5)、zcode-pretooluse.sh(48 行)、check-complete.sh(349 行,关键段 134-149 / 269-320)、SKILL.md(570 行)、critical-rules.md(207 行,Rule 25/26/27)、diagnosing-hooks/SKILL.md(zcode hook 协议)、verify.sh(245 行)、register-hooks-cj.ts(200 行)、check-scope.sh(84 行)、resolve-plan-dir.sh(65 行)、zcode-posttooluse.sh(state 文件范式)、attest-plan.sh(63 行,SHA-256 锁)、templates/task_plan.md(143/169/180/191/202 Executor 实例)
- 产出: 缺陷清单(2 BLOCKER / 4 MAJOR / 6 MINOR / 3 QUESTION)+ 裁决: 方案 B **条件性可实施**,必须先修 BLOCKER + 关键 MAJOR
- 约束遵守: 只读分析 + 本检查点,未改 skills/ 任何源码

## 1. 验证协议结果(原文 grep 全部已验证)

| # | 验证项 | Grep 结果 | 通过 |
|---|--------|-----------|------|
| V1 | zcode hook 阻断=exit 2 约定 | diagnosing-hooks/SKILL.md:36「`0` passes, `2` blocks ... any other non-zero raises an error」 | ✓ |
| V2 | 现有 zcode-pretooluse.sh 哨兵拦截用 exit 2 | zcode-pretooluse.sh:15-17 `rc=1 → exit 2` | ✓ |
| V3 | SKILL.md:107 写「exit 1 阻断」与实现漂移 | SKILL.md:107 原文存在 | ✓(佐证 #6 漂移) |
| V4 | SKILL.md 570 行 / P0 字样 28 次 | wc -l 570, grep -c P0 = 28 | ✓(验证 F14) |
| V5 | critical-rules.md Rule 25 6 项白名单 | critical-rules.md:163 六项 | ✓ |
| V6 | templates/task_plan.md Executor 实例 5 处 | task_plan.md:143/169/180/191/202 | ✓ |
| V7 | 模板占位「explore（mini）」是子代理格式 | task_plan.md:143 原文 | ✓(佐证 #E 统计污染) |
| V8 | posttooluse 的 /tmp/task-planner-hook-<sid>.state 模式 | posttooluse.sh:4/20/66 | ✓ |
| V9 | PreToolUse hook stdin 含 session_id 字段(供新状态文件 <sid>) | posttooluse.sh:20 `.session_id` 提取;pretooluse.sh 现状未取 | ✓(佐证 #B 实现细节未定) |
| V10 | attest 锁存于 plan_dir/.plan-attestation | attest-plan.sh:39 | ✓ |
| V11 | Rule 25.3 ④「用户显式要求主进程亲为」WL 正则能匹配 | 方案 §3.3 正则含 `④\|用户显式` | ✓(佐证 #4 绕过) |
| V12 | check-scope.sh basename 白名单放行任意目录下的 findings/progress | check-scope.sh:59 | ✓(佐证 #C 继承缺陷) |
| V13 | Claude Code hook JSON 严格校验+多 hook 聚合语义 | diagnosing-hooks/SKILL.md:36 严格 JSON,无多命令聚合说明 | ✓(佐证 #6 QUESTION) |
| V14 | 子代理 SubagentStop 不在 ZCode 支持事件集 | diagnosing-hooks/SKILL.md:26「SubagentStop 是不支持事件」 | ✓(佐证 #1 Phase 0 必须实测) |
| V15 | verify.sh check 3 硬编码路径扫描 | verify.sh:110-115 扫描 $HOME/.zcode\|.claude/skills/task-planner | ✓(佐证 #5 文案硬编码风险) |

**验证摘要**: 15 项全部 grep 复现, 通过率 100%。

## 2. 缺陷清单(按严重度排序)

### 2.1 BLOCKER 级别(必须修复才能进入实施)

---

#### [B-1] 阻断文案把逃生门钥匙挂在门上 — 子代理/主进程一键自开 bypass,机制形同虚设

- **位置**: 03-architect.md:108-110(§3.1 阻断文案「合法路径三选一」第 3 条) + 03-architect.md:115-116(「Bash 工具不在 Write|Edit matcher 内 → 主进程/用户天然可达,这是逃生门的物理基础」)
- **原文**: "3. 临时放行: bash ~/.zcode/skills/task-planner/scripts/allow-direct.sh on [默认 30 分钟窗口, expire 后自动恢复拦截]"
- **攻击场景**: 主进程模型 Edit 业务文件 → 触发 PreToolUse exit 2 阻断 → 收到文案 → 模型第一反应跑 `Bash("bash ~/.zcode/skills/task-planner/scripts/allow-direct.sh on")`(Bash 不在 Write|Edit matcher,确实可达)→ 30 分钟窗口内白做任意文件 → 完成后再 on 一次续期(方案 §3.1 描述 "on/off/status 幂等重置 epoch",未限制次数)。整条「硬拦截」机制对模型自利的耐心边界 = 0,只是把「用户去问」省略为「模型自助」。
- **后果**: 修复不达标,用户复测「还是没效果」概率高;且模型学会把 allow-direct 当默认开门钥匙,机制的精神失效。
- **修复建议**:
  1. 阻断文案删除「路径 3」(或改为「须用户在 prompt 显式说『开 bypass』后手动执行」)
  2. allow-direct.sh on 必须要求 stdin 来自用户在主对话的明文确认(类似 attest 锁)或仅由用户在 shell 终端手动执行(模型触达不到的环境)
  3. 任何 bypass 期间的 Write/Edit 必须落 ledger(行: plan-dir/ledger-bypass.jsonl),终验 Delegation Gate 把「bypass 使用次数」作为统计项输出(不拦但曝光——用户/VC-2 看得到)
  4. 30 分钟窗口加单会话硬上限(如 1 次),on 第二次拒并 stderr 提示「请联系用户授权」
- **置信度**: HIGH(Grep 验证文案内容 + Bash 工具可达性 + on 幂等续期描述)

---

#### [B-2] 终验统计存在三处「口供源」系统性绕过,白名单⑥/④让委派率 0% 也能 PASS

- **位置**: 03-architect.md:135-148(§3.3 统计块 WL 正则) + 03-architect.md:155-156(§3.3 三层闭环「统计源可信度由 attest 背书」)
- **原文**: "WL = re.compile(r'例外理由[:：].*?(①|②|③|④|⑤|⑥|git|worktree|计划系统|验证命令|用户显式|22\.3|兜底|trivial|3\s*行)')"
- **攻击场景**(三处,任一独立成立即可全绿):
  1. **计划期口供**: 主进程写计划时每个 Phase 都写 `- **Executor:** 主进程（例外理由:④ 用户显式要求主进程亲为）`。理由④是自由文本,WL 正则 `④` 和 `用户显式` 双重命中 → bad_mains 为空 → 判定 3「全部直做理由白名单内 → 放行」触发 → 委派率 0% 也 PASS。
  2. **模板占位污染**: templates/task_plan.md:143 占位 `- **Executor:** explore（mini）` 是子代理格式 → 计入 sub_n(子代理数)。即使主进程亲为,只要没改这条占位,统计分子虚高。配合 ① 整体效果: 部分 Phase 占位不真改 + 部分 Phase 用理由④ → 两边都白。
  3. **Handoff 登记表未交叉**: 方案无「Executor=子代理 的 Phase 必须有 Handoff 表对应行」交叉校验。声称委派但 Handoff 表为空 = 谎报委派。
- **后果**: 用户实测中,任何「学会了规则的模型」都能让委派率恒绿,机制的真实强制力上限被口供源限制。用户复测「怎么没 PARTIAL」= 仍是文本层失守。
- **修复建议**:
  1. **脱字面匹配**: WL 正则去掉 `④|用户显式` 与 `②|计划系统` 的自动通过——这两类理由机器不可验证,改为「含不可验证理由时单独输出『需用户确认行』+ 统计 expose 不拦」(透明度提升而非强拦)
  2. **加交叉校验**: Executor 字段是子代理的 Phase 终验时 Handoff 登记表必须存在对应行(grep -F "Phase N" handoff.md 命中 ≥1)→ 否则告警此 Phase 「声称委派但无 Handoff 记录」
  3. **占位检测**: Executor 字段值在模板占位集合 `{explore（mini）, code-assistant（haiku-1）, code-runner-agent（mini）}` 内 → 「占位未替换」告警(不拦,统计时把占位归为 `missing` 等价)
  4. **理由⑥机器可证**: ⑥「单文件≤3 行 trivial」在终验期可取本 Phase 实际产物的 git diff 行数(若 Phase 改过文件)作硬校验——diff 行数 ≤3 + 路径非保护区 = 真⑥,否则不算。
- **置信度**: HIGH(模板占位 grep V7、WL 正则文本 V11、attest 锁 V10 三者已验证)

### 2.2 MAJOR 级别(强烈建议修复,否则特定场景会翻车)

---

#### [M-1] warn 档没有「统计触发次数」的可观测设计,「观察 1-2 个真实任务后切 enforce」无法操作化

- **位置**: 03-architect.md:163-165(§3.4 rollout「初始 warn... → 切 enforce」) + 03-architect.md:96-98(§3.1 warn 档 emit additionalContext)
- **原文**: "rollout: 初始 warn(观察 1-2 个真实任务 + Phase 0 实测) → 切 enforce。切换判据: 实测确认子代理 Write 触发 hook 时 stdin 含可区分字段..."
- **攻击场景**: warn 档期间模型主进程亲为 → 只收到 additionalContext 文本(本质提示词约束,与 SKILL.md 文本层同款)。若 Phase 0 判定「子代理 stdin 无可区分字段」(方案已承认「LOW-MEDIUM」),则 warn 档是「永久兜底」——没有 owner、没有 deadline、没有自动切换机制;「观察 1-2 个真实任务」既无触发计数器也无报告机制,会自然演变为「一直 warn」。用户复测期间看到「warn 档不阻断」=「还是没效果」。
- **后果**: 切 enforce 的状态机无法自驱,实测中大概率永远停在 warn 档,用户再次得出修复不达标结论。
- **修复建议**:
  1. warn 档每次触发累加 /tmp/task-planner-warn-${SID}.state
  2. 终验 check-complete.sh 末尾输出 `[plan] Delegation warn-triggered: N times in this session`
  3. config.json 新增 `warn_trigger_threshold_for_enforce`(默认 10),check-complete.sh 在该 session warn 触发 ≥ 阈值时 stderr 提示 `[plan] warn 已触发 N 次, 建议切 enforce`
  4. 切换 enforce 的 owner 写明 = 开发者本人(非模型),方案文档写「warn → enforce 由用户在 plan 文档或 prompt 显式说『切 enforce』触发」
- **置信度**: HIGH(grep 方案文本确认无计数设计;posttooluse 状态文件模式 V8 证明工程上可实现)

---

#### [M-2] 子代理误伤场景的子代理自纠 + warn 噪音 token 成本被低估

- **位置**: 03-architect.md:202-203(§4.1 缓解 ①②③④) + 03-architect.md:91-93(§3.1 步骤 6 降级策略)
- **原文**: "① stdin agent 特征字段探测放行(§3.1 步骤 2) ② Phase 0 沙箱实测 dump stdin, 主/子代理 diff ... ③ 实测无区分字段 → delegation_enforce 停留 warn, 硬拦截暂缓并如实报告"
- **攻击场景**:
  1. **warn 噪音**: 即使 Phase 0 决定「停留 warn」,子代理每次 Write/Edit 仍被注入 additionalContext(`[delegation] ⚠️ 主进程亲为: <file>...`)。子代理的上下文被这个 8-15 token 的提醒按 N 次工具调用累加,长期跑批处理子代理时显著抬高 token;且子代理若判定自己「不算主进程」误认为 plan 系统在警告自己 → 触发它重读 task_plan.md 或写 findings.md「规避」,造成不必要的工作流干扰。
  2. **子代理自开 bypass**: 子代理通常具备 Bash 工具,若子代理被 PreToolUse 阻断(Phase 0 失误的边界场景),子代理会读 stderr 文案并执行「路径 3」允许 direct 命令——见 [B-1] 这是同一把钥匙,这次由子代理持有,登记混乱(子代理无 task_plan.md 写权限语义,写不了 Executor 字段「理由」)。
  3. **降级策略矛盾**: §3.1 步骤 6「new 为空(字段缺失无法判定)→ 第 2 次起按当前 enforce 档处置」。PreToolUse stdin new_string 字段缺失是「工具调用本身形态」(如 Bash 重定向到文件)而非「用户在配 bypass」。把工具形态当用户意图 = 误拦。
- **后果**: 子代理 token 成本增加 + 偶发误拦 = 「修复反而让子代理难用」的负外部性,可能在批处理任务上反向逼迫用户走 bypass 或回退方案。
- **修复建议**:
  1. warn 档 additionalContext 限制条件: 仅在「主进程会话进程路径」命中时注入(用 process parent 路径或 $PPID 区分主/子代理进程——若 ZCode 暴露),或用 stdin 特征字段探测(放行的同款机制)反向 = 不命中则不注入,降低子代理噪音。
  2. 阻断文案(被 stderr 输出)把「路径 3」改写为「主进程不得自助执行,必须用户在主对话确认」——子代理即使读到文案也无合适的执行上下文。
  3. 降级策略(2 次后强制 enforce)改 5 次,且配套 hook 调用计数 state 文件按 sid 隔离(参考 posttooluse.sh:66 模式,grep V8)。
- **置信度**: HIGH(子代理 Bash 可达性 = 现有工具配置,文案自开 bypass 路径 = 方案原文 V15 + [B-1])

---

#### [M-3] 方案无 canonical 改后多部署位同步 SOP,findings R1 部署一致性会再次被打破

- **位置**: 03-architect.md:188-197(§3.6 多部署位生效矩阵「部署同步即有」) + 03-architect.md:118(「依赖逻辑轻量」不提同步)
- **原文**: "check-delegation.sh + allow-direct.sh(新脚本) | 部署同步即有 | 同左(文件存在)"
- **攻击场景**: findings R1 已证三部署位 (zcode/claude/opencode) 必须 IDENTICAL 才能保「用户实测的是最新版」。本方案在 canonical (本仓 /mnt/data/dev/task-planner-skill/skills/task-planner) 改 5 个文件 + 2 个新脚本;不显式同步到 ~/.zcode/skills/... 等三部署位 → 用户在 ~/.zcode/skills 部署位实际跑的还是旧版 → PreToolUse 仍调旧 zcode-pretooluse.sh → 没有新拦截分支 → 用户「实测还是没效果」,且本次与上轮 findings R1 的「部署滞后假设证伪」对冲——这次真的是部署滞后。
- **后果**: 复刻 findings R1 排查的「部署滞后」根因(虽然已证伪),直接破坏「机制性修复」的承诺。
- **修复建议**:
  1. 实施 Phase 的最后一步必须显式执行 sync-companion.sh 三部署位(方案有 sync-companion.sh 脚本可复用,grep 已证存在)
  2. 方案「部署同步即有」改写为「commit + sync-companion.sh + install.sh + verify.sh 依次 exit 0」4 步硬 SOP
  3. lib/verify.sh 新增 check 9(方案 §4.10 已提)实际跑通: `bash check-delegation.sh --self-test` + `bash allow-direct.sh status` + 3 部署位 SKILL.md cmp 一致
  4. 阻断文案「合法路径三选一」第 3 条的 `bash ~/.zcode/skills/task-planner/scripts/allow-direct.sh on` 改为 `bash ${TASK_PLANNER_ROOT}/scripts/allow-direct.sh on`(满足 verify.sh check 3 薄壳模型硬编码扫描——V15 已证)
- **置信度**: HIGH(findings R1 文本 + 部署位 list 验证)

---

#### [M-4] PreToolUse 计时含 walk-up + 多次 grep,虽轻量但 timeout 5s 在大目录/网络盘上有风险

- **位置**: 03-architect.md:116-117(「全链 bash+jq+awk <100ms, 5s(F4)富余」)
- **原文**: "timeout 预算: 全链 bash+jq+awk <100ms, 5s(F4)富余; 不做 git 调用等慢操作"
- **攻击场景**:
  1. resolve-plan-dir.sh:48 `stat -c %Y` 在 plans/ 下几十个子目录做循环 + mtime 比较。在用户同时跑多 plan 任务(方案并行开发场景)时 plans/ 下几十个目录 → ls + stat + python 解 .active_plan → 可能 200-500ms,但还远小于 5s。
  2. 真正风险: hook stdin 的 .tool_input.content/new_string 字段在 Write 大文件时(>100KB)→ `printf '%s' "$new" | wc -l` 走 pipe → 在 content 很大时显著耗时,主进程大块 Write 触发慢 hook。
  3. 现有 zcode-pretooluse.sh 没有处理 content 字段,本方案新增 trivial 判定是引入 content 解析的第一个消费点。
- **后果**: 5s timeout 实际被触发概率低,但一旦超时行为不可控(ZCode 杀死 hook = 视同 fail-open 放行,无错误暴露)。用户感观是「hook 有时没反应」间歇性。
- **修复建议**:
  1. trivial 判定仅取 content 前 4KB 判断行数: `head -c 4096 \| wc -l` 即可,不必解析整个 content
  2. resolve-plan-dir.sh 调用加超时保护: `timeout 1s bash resolve-plan-dir.sh \|\| echo ""`
  3. 计时最后打 stderr 一行 `[hook] elapsed: Nms` 累计到 /tmp/task-planner-perf-${SID}.log, verify.sh check 9 抽查平均耗时
- **置信度**: MEDIUM(实施 phase 实测才能定夺,理论上风险存在)

### 2.3 MINOR 级别(建议处理,边缘场景)

#### [m-1] SKILL.md:107 已有「exit 1 阻断」错误描述,方案新文案应同步修正以免继续误导

- **位置**: SKILL.md:107「PreToolUse hook 自动拦截所有非 plans/ 路径的 Write/Edit 操作(exit 1 阻断)」 vs zcode-pretooluse.sh:17 实际 `exit 2`
- **原文**: "**门控**: 哨兵存在期间, PreToolUse hook 自动拦截所有非 plans/ 路径的 Write/Edit 操作(exit 1 阻断)"
- **修复建议**: SKILL.md 收敛阶段一并改为「exit 2 阻断(符合 ZCode hook 约定, 见 references/.../diagnosing-hooks)」
- **置信度**: HIGH(grep V3 验证)

#### [m-2] check-scope.sh basename 白名单「任何目录下 findings/progress.md 都放行」被新委派门控原样继承

- **位置**: 03-architect.md:87(§3.1 步骤 5c 复用 check-scope.sh:46-67 语义) + check-scope.sh:59(原文)
- **原文**: "task_plan.md\|findings.md\|progress.md\|notepad-learnings.md\|verification.md"
- **攻击场景**: 用户业务项目本身有 `findings.md`(比如 docs/findings.md, 业务进度汇报)→ 主进程亲为该文件 → 白名单(c)永远放行 → 委派率 0% 也能用「业务文档不算业务代码」为理由继续。findings.md 业务化在用户项目里非常常见(grep V12 已证)。
- **修复建议**: 白名单(c) 改为「相对 plans/<task-id>/ 祖先的 findings/progress/notepad/verification/task_plan.md」,即必须位于 plan 目录树下。SKILL.md 的白名单②「计划系统文件维护」语义本就是这样。
- **置信度**: HIGH(grep V12 + 业务项目实践)

#### [m-3] WL 正则 `3\s*行` 宽松到可被无关文本命中(如「超 3 行即派子代理」)

- **位置**: 03-architect.md:142
- **原文**: "WL = re.compile(r'例外理由[:：].*?(①|②|③|④|⑤|⑥|git|worktree|计划系统|验证命令|用户显式|22\.3|兜底|trivial|3\s*行)')"
- **修复建议**: `3\s*行` 收紧为 `(≤\s*3\s*行\|<=?\s*3\s*行\|trivial.*3\s*行\|3\s*行\s*trivial)`,或干脆删除,理由⑥通过 `trivial` 或 `⑥` 命中。
- **置信度**: MEDIUM(实现细节)

#### [m-4] fail-open 路径完全静默,环境退化(jq 缺失/JSON 烂)时拦截悄悄失效,无告警

- **位置**: 03-architect.md:117(「脚本无 set -e(现状), jq 失败 → 变量空 → 各判定 return 0」)
- **攻击场景**: 边缘风险。模型不能控制 hook stdin(threat model 已限定),但环境退化(jq 卸载、JSON 烂)→ 整个 delegation gate 全 return 0 放行 + 无任何 stderr 提示 → 用户/开发者无从发现「拦截今天没工作」。
- **修复建议**: fail-open 路径 stderr 写一行 `[delegation] FAIL-OPEN: <reason>` + 累计 /tmp/task-planner-failopen-${SID}.log 计数,verify.sh check 9 报警。
- **置信度**: MEDIUM(理论风险,实测罕见)

#### [m-5] resolve-plan-dir.sh 解析链多会话下可能把 A 会话亲为误配到 B 会话 plan 状态

- **位置**: 03-architect.md:202-203(§4.7「worktree 内拦截行为漂移」已覆盖 worktree, 未覆盖同仓双会话) + zcode-posttooluse.sh:30(同款 mtime 解析已用)
- **攻击场景**: 用户按宪法 §十一「并行开发」同时开两个会话,A 跑 plan-X, B 跑 plan-Y(均同仓 plans/ 下)。`ls -t plans/*/task_plan.md` 命中 mtime 最新者,可能不是 A 的。outcome COMPLETE 检查就用错 plan → 误判放行;或反之 A 完成 plan 写 outcome COMPLETE → B 看到后 return 0 跳过提示。
- **后果**: 状态错配,拦截精度降级。继承自 posttooluse.sh 既有缺陷,非新引入但新机制放大了错配后果(把别人 plan 的 outcome 当放行依据)。
- **修复建议**: 新分支仅信任 .active_plan 指针(已由 set-active-plan.sh 维护,grep 现状可查);若 .active_plan 不存在 → 视为「无活跃计划」走 return 0(与原意一致),不依赖 mtime 兜底。
- **置信度**: MEDIUM(继承缺陷,但应记录在案)

#### [m-6] Claude Code hook 数组多条命令的退出码聚合语义未验证,register-hooks-cj.ts:119 改造存在技术不确定点

- **位置**: 03-architect.md:189-195(§3.6 多部署位 claude 行: 「需改 register-hooks-cj.ts:119 命令 + 用户重跑注册(授权项)」)
- **原文**: "PreToolUse 执行期拦截 \| 需改 register-hooks-cj.ts:119 命令 + 用户重跑注册(授权项)"
- **攻击场景**: register-hooks-cj.ts:116-121 现有 PreToolUse 数组只有 1 条命令(调 check-scope.sh)。方案追加 check-delegation 调用后,Claude Code hooks 数组里有 2 条 PreToolUse 命令,Claude Code hook 协议下「任一 exit 2 即 block」还是「最后一条决定」未在 diagnosing-hooks/SKILL.md 验证(V13)。如不熟悉语义,可能让两条命令相互覆盖或聚合行为错位。
- **修复建议**: 实施 phase 用 Claude Code 实际跑两条命令 1) `exit 0` 2) `exit 2` 验证聚合;若不熟悉,合并两条命令为单条 `bash check-scope.sh ... && bash check-delegation.sh ...`,串联后整体退出码受最后一条子命令影响可控。
- **置信度**: LOW-MEDIUM(平台实现细节,Phase 0 实测)

### 2.4 QUESTION 级别(需用户/Phase 0 实证确认)

#### [Q-1] 子代理 stdin 区分字段探测的具体字段名,Phase 0 须实测确认

- **位置**: 03-architect.md:32-33(置信度标注「LOW-MEDIUM」) + 03-architect.md:74-75(§3.1 步骤 2 列了 5 个候选)
- **原文**: "子代理放行: jq 探测 '.agent_type // .agentType // .agent_id // .subagent_type // .parent_tool_use_id' 任一非空 → return 0"
- **疑问**: ZCode 官方 hook 协议 stdin schema 未公开,诊断文档 V14 也没列字段。这 5 个候选从何而来?Phase 0 是否真能确认其中之一在子代理工具调用时非空?
- **建议**: Phase 0 第一步用 `bash zcode-pretooluse.sh <(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/x",...}}')` 加不同 subagent context dump 出来对比;不假设任何候选字段,实测验证。

#### [Q-2] 阻断文案 `bash ~/.zcode/skills/task-planner/scripts/allow-direct.sh on` 的硬编码路径与 verify.sh check 3 矛盾

- **位置**: 03-architect.md:109(§3.1 阻断文案) + verify.sh:110(扫描硬编码路径)
- **疑问**: 用户/项目如果用 verify.sh 薄壳部署位(独立 ~/.claude/skills/task-planner 副本),该文案里的 `~/.zcode/skills/...` 路径不在用户部署位,文案对 claude 部署位用户不可执行。verify.sh check 3 会因这段文案扫到 `~/.zcode/skills/task-planner` 字符吗?(grep 脚本扫的是 scripts/ 目录,文案在 stderr 输出里,check 3 不扫 stderr——技术上当 pass,但语义混乱)
- **建议**: 文案改 `${TASK_PLANNER_ROOT}/scripts/allow-direct.sh on` 让两端用户都能解析。

#### [Q-3] PreToolUse 新分支插在「Rule 23 之前」,Rule 23 自身的并发检测有 $PWD 依赖,在 hook 进程非项目根 PWD 时会否失准?

- **位置**: 03-architect.md:66(§3.1「插入哨兵检查:13-18 之后、Rule 23:21 之前」) + zcode-pretooluse.sh:24(「CWD=${PWD}」)
- **疑问**: 既有 Rule 23 用 `$PWD` 判定,若 ZCode spawn hook 时 PWD 是 ZCode 主目录(非项目根),并发检测会失准。本方案 delegation gate §3.1 步骤 4 也用 `bash resolve-plan-dir.sh "$PWD"`,继承同款 $PWD 不确定性。方案 §4.7 仅讨论 worktree CWD,未讨论主仓 $PWD 偏差。
- **建议**: 方案 §3.1 步骤 4 改为「CWD = jq -r '.cwd // empty' $input \|\| PWD」(与 posttooluse.sh:18-19 同款),不依赖 hook 进程的 PWD。

## 3. 负结果报告(检查了什么,排除了什么)

### 已穷尽检查的项(未发现问题)

| 检查项 | 结果 |
|--------|------|
| check-complete.sh :320-337 exit 0 链是否能插入 gate(sys.exit(1)) | 可行, 链结构简单 |
| attest-plan.sh SHA-256 锁能否被主进程悄悄绕开 | 不能, 锁文件存在 + 每次 userprompt 校验; 修改 task_plan.md → [PLAN TAMPERED](V10) |
| new_string/content 字段在 Write/Edit stdin 的实际命名 | posttooluse 现状取 .cwd/.session_id, 未取 tool_input 字段; new_string/content 的真实字段名 Phase 0 实测(标记为 [Q-1] 同步) |
| templates/task_plan.md outcome 字段格式 | task_plan.md:46-48 `outcome: **COMPLETE/PARTIAL/BLOCKED**`, posttooluse.sh:39 用 `outcome: *(COMPLETE\|BLOCKED)` 正则, 方案 §3.1(4) 同款可用 |
| Rule 26 Q5 与 Rule 25.4 是否重复定义 | critical-rules.md:177「此处不重复定义」明示引用 25.4, 方案 25.4 自动统计落地后 Q5 自动生效 |
| multi hook JSON 严格 schema 严格性 | diagnosing-hooks/SKILL.md:36 「strict schema - any extra key fails validation」,方案 §3.1 的 additionalContext 字段是合法 key ✓ |

### 已排除的可行性(挑刺不构成问题)

- **「构造畸形 stdin 让拦截永远放行」**(#7 攻击场景): 威胁模型不成立。hook stdin 由 ZCode 客户端生成,模型没有 stdin 注入面。fail-open 的真实风险是环境退化(jq 缺失)而非模型主动攻击,已纳入 [m-4] 改进。
- **「opencode 位 PreToolUse 可行性」**: 方案 §3.6 已明确标注不承诺,文档诚实, 不构成缺陷。
- **「verify.sh check 5 在有未完成 plan 时 exit 1」**: 既有行为,非方案引入。
- **「§3.1(6) trivial 判定降级第 2 次强制 enforce」**: 第 2 次拦的是同 session 内白名单外 Edit,非关键路径(白名单文件占大多数),策略本身可接受。

## 4. 裁决

### 方案 B 条件性可进入实施(修改优先级排序)

**必须先修才能开 Phase 0**(否则实测无意义):
1. [B-1] 阻断文案删除 allow-direct 自助路径 → 阻断钥匙不挂门上
2. [B-2] 终验统计加交叉校验(Handoff 表对齐 + 占位检测 + 理由不可机器验证项 expose)

**强烈建议同步修**(否则特定场景会翻车):
3. [M-1] warn 档触发计数 + 切 enforce 路径明确化
4. [M-2] 子代理噪音缓解 + 子代理自开 bypass 文案收敛
5. [M-3] 部署同步 SOP 列入实施最后一步 + verify.sh check 9 真实跑通

**可延后但须记录**(Phase 0 期间验证):
6. [Q-1] 子代理 stdin 字段实测 — Phase 0 第一动作
7. [Q-3] $PWD 改用 stdin .cwd — 顺手改

**可单独追修**(其他缺陷):[M-4] [m-1] [m-2] [m-3] [m-4] [m-5] [m-6] [Q-2]

### 总体评估

- **方案设计的核心洞察**(执行期拦截 + 终验统计 + SKILL 收敛 + 三层闭环)思路正确
- **核心失败模式**不是设计错,而是「机制在攻击者(模型)面前不够硬」——逃生门自助打开 + 终验统计信口供。两个 BLOCKER 都属此性质
- **修复后方案 B 仍是推荐方案**(A 治标不治本;C 只是 B 的 rollout 路径)
- **预计净工作量**: 修 BLOCKER + 关键 MAJOR 共 +1.0-1.5 天, 总计 2.5-3.5 天
- **不修复 BLOCKER 强行实施** = 用户第三轮反馈「还是没效果」概率高(findings R1+R2 之后, 第三次没效果基本是机制信任破产)

### 流程门控建议

- 实施前先发一封「修改点摘要」给用户确认(BLOCKER 2 项的修法属方案级变更, 用户有权否决)
- Phase 0 子代理 stdin 实测用 [Q-1] 的具体方法, 不要用方案里「LOW-MEDIUM 置信度」的 5 个候选字段名硬猜
- 任何 BLOCKER 修法用户否决 → 退回 architect 重做方案, 不进入 Phase 0

## 5. 总结: Top 3 风险

1. **逃生门钥匙挂在门上**(B-1) — 阻断文案主动教模型自助 bypass, 机制对模型自利行为零约束
2. **终验统计信口供**(B-2) — 三处「主进程自填即合规」漏洞让委派率 0% 也 PASS, WL 正则过宽
3. **warn 档无观测无 owner**(M-1) — 切 enforce 的状态机不自驱, 极易永远停在 warn 档变成「永久软约束」

## 6. 验证摘要

- 总发现: 15 项(2 BLOCKER / 4 MAJOR / 6 MINOR / 3 QUESTION)
- 已验证: 15 项(全部通过 Grep 复现原文)
- 通过率: 100%
- 写入检查点: /mnt/data/dev/task-planner-skill/plans/task-v055-scheduler-enforce/subagent-state/04-critic.md
- 修改 skills/ 源码: 0 处
