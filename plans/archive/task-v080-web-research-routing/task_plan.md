---
template_type: rule-enhancement
---
<!-- task-id: task-v080-web-research-routing -->
<!-- 沉淀出处: rule-enhancement variant（task-v074 起入库）；本轮=网络调研/网页访问工具路由明确化 -->

# Task Plan: task-v080-web-research-routing — 网络调研/网页访问工具路由明确化

## Goal
优化 task-planner 技能的网络调研/网页访问路由：调研网络、访问网页内容时明确路由到 research-assistant 技能（网络调研主通道）与 browser-use 插件（Browser Use，网页访问：JS 渲染/登录态/交互），并声明优先使用 ZCode 平台实际可用工具（WebSearch、mcp__web_reader__webReader、mcp__node_repl__js）。纯增量修改（Rule 36.5），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位。

## ⚙️ 交互配置
| 键 | 值 | 依据 |
|----|-----|------|
| interaction_mode | silent | D1a（无人值守会话；env 未设+config 默认 ask 不可阻塞；v076 先例），交付报告附静默决策清单 |
| reflect_verify | required | 本任务含问题解决动作（执行体启动失败的兜底接管），REFLECT-GATE 纳入终验 |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本：selftest-skill-collab.sh / selftest-knowledge-brief.sh） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | SKILL.md 调研路由三处增补到位：①L458 链注记含 browser-use 插件（control-browser/mcp__node_repl__js）与 research-assistant 主通道定位 ②平台适配声明 1 行（禁假设不存在 MCP） ③子代理路由表新增网页访问行 | grep 断言（`browser-use`、`research-assistant`、`mcp__node_repl__js`）+ Read 目检 | worktree 内 skills/task-planner/SKILL.md |
| VC-2 | skill-collaboration.md §二触发矩阵新增 research-assistant 与 browser-use 两行（4 列范式对齐 L60 progress-tracker 行） | grep + Read 目检 | worktree 内 references/skill-collaboration.md |
| VC-3 | selftest-skill-collab.sh 新增 T11/T12 断言通过；selftest-knowledge-brief.sh T2b 断言 545→548 | 单跑两 selftest 全 PASS | 两 selftest 运行输出 |
| VC-4 | worktree 内全量 selftest 21 个 0 FAIL（**总数=主进程逐 Total 行求和，禁采信子代理自报**）且 SKILL.md 行数 ≤548 | `for f in selftest-*.sh` 逐个跑求和 + wc -l | progress.md Selftest Log |
| VC-5 | 纯增量核验：worktree `git diff f0fa427` 无功能性删除行（允许的修改行仅两类：①SKILL.md L458 链行注记扩写——五记号①-⑤与工具集合不变（grep 验证） ②selftest-knowledge-brief.sh T2b 断言数值行 545→548） | git diff 逐文件审阅 + 五记号顺序 grep | git diff 输出存 progress.md |
| VC-6 | 合并回 master + 3 部署位（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）diff -r 全量 IDENTICAL | smart-merge-back.sh --deploy + 主进程 diff -r 亲验 | 部署对账输出 |
| VC-7 | CHANGELOG.md `## [Unreleased]` 新增本任务条目 | Read | CHANGELOG.md |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| SKILL | `skills/task-planner/SKILL.md`（净增 ≤7 行：L458 行内注记扩写+新增 ≤3 行） | 大段新增；改①-⑤链顺序与工具集合 |
| 引用文档 | `skills/task-planner/references/skill-collaboration.md`（§二矩阵加 2 行） | 改既有行语义；动其他 references |
| 脚本 | `skills/task-planner/scripts/selftest-skill-collab.sh`（追加 T11/T12）、`skills/task-planner/scripts/selftest-knowledge-brief.sh`（仅 T2b 断言行 545→548） | 其他脚本 |
| 文档 | `CHANGELOG.md`（Unreleased 加 1 bullet） | 其他文档 |
| 配置 | （无——零新 config 键，D1c） | config.json 任何改动 |
| 路径 | worktree=`/mnt/data/dev/task-planner-skill-worktrees/task-v080-web-research-routing`；部署位=`/home/terry/.zcode/skills/task-planner`、`/home/terry/.claude/skills/task-planner`、`/home/terry/.config/opencode/skills/task-planner` | 主仓工作树任务范围外文件；其他 worktree |

**强制约束**:
- Rule 36.5 纯增量：L458 为注记增补（顺序①-⑤与工具集合不变），非功能性删除/语义改写 → 36.4 D6 不触发；删除性行为清单=空（基线照登 findings.md）
- check-skill-modify.sh 对仓内 skills/** 同样触发（warn 档）——本表反引号路径 token 即其授权依据
- S-unit ID 纯数字；派发 prompt ≤3000 字符，大材料走 35.3 落盘引用（材料包=00-materials.md）

## 🔀 隔离决策
| 信号 | 结果 |
|------|------|
| ①未提交变更 | 仅本计划目录 plans/task-v080-web-research-routing/（预期） |
| ②额外 worktree / ③遗留 wt 分支 | 无（git worktree list 仅主仓） |
| ④待处理任务在册 / ⑤运行中基础设施改动 | 无（master=origin/master=f0fa427 干净） |
| **决策** | **worktree 隔离**（宪法 §11.1 命中：skills 保护区），路径与分支见执行范围表；合并回 smart-merge-back.sh --deploy；CWD 不迁移 |

## 📊 FMEA 预演
| 编号 | 失败模式 | S | O | D | RPN | 兜底动作 |
|------|----------|---|---|---|-----|---------|
| F1 | 派发 prompt 被 check-dispatch 拒（缺字段/超长） | 6 | 4 | 5 | 120 | 按 22.4 九字段模板补齐；材料走落盘引用 |
| F2 | SKILL.md 越行数断言（T2b 545 最紧） | 5 | 3 | 6 | 90 | 已前置 545→548；仍越限则压缩增补行数 |
| F3 | haiku 档子代理 Edit 走样（错行/漏锚） | 6 | 4 | 5 | 120 | prompt 附精确 old/new+验收 grep；不过验收即重派拆细（22.3②） |
| F4 | 部署位 diff 非 IDENTICAL | 5 | 2 | 7 | 70 | DEPLOY_SRC=主仓副本（v077 修复）+主进程 diff -r 亲验兜底 |
| F5 | attest 机器校验拒锁（S-unit 表/时长/输入列不合规） | 5 | 3 | 5 | 75 | 按 check-plan-dispatch 报错逐项修表重锁 |

## Phases

### Phase 1: 隔离与基线
- **Status:** complete
- worktree 建立（宪法 §十一：`git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-v080-web-research-routing -b wt/task-v080-web-research-routing master`）+ findings.md 登记 Rule 36.3 删除基线（清单=空）+ 全量 selftest 基线（主进程逐 Total 行求和，预期 349/0）
- **Executor:** 主进程（例外理由：Rule 25.3 白名单① 纯 git/worktree 编排 + ③ 机械验证命令）

### Phase 2: 调研路由增补
- **Status:** complete
- **Executor:** 主进程接管（原派 code-assistant 串行；例外理由：Rule 22.3④+白名单⑤——sonnet-1/mini/haiku-1 全档位 spawn 失败共 4 次[reasoning-level-missing]，S1/S2 的精确 old/new 设计不变，主进程逐条执行并按验收 grep 自验）
<!-- S-unit 表（attest 机器校验：时长 NNmin ≤15；输入路径 ≤2） -->
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | SKILL.md 三处增补（L458 链注记扩写/平台适配声明/路由表网页访问行，净增 ≤7） | 主进程(22.3④接管) | plans/task-v080-web-research-routing/subagent-state/00-materials.md（§S-A 精确 old/new）+ worktree 内 SKILL.md L360-495 区段 | grep `browser-use`/`mcp__node_repl__js`/`research-assistant` 三锚命中；wc -l ≤548 | 10min | pending |
| S2 | skill-collaboration.md §二矩阵加 research-assistant 与 browser-use 两行 | 主进程(22.3④接管) | 同上材料包（§S-B 范式+L60 样例）+ worktree 内 skill-collaboration.md L51-70 区段 | grep 两行命中；4 列结构与 L60 一致；wc -l ≤300 | 8min | pending |

### Phase 3: selftest 守护 + 全量回归
- **Status:** complete
- **Executor:** 主进程接管（原派 code-assistant S1 + code-runner-agent S2；例外理由：Rule 22.3④ 全档位 spawn 失败；白名单⑤ 编辑接管 + 白名单③ 机械验证求和）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | selftest-skill-collab.sh 追加 T11/T12 断言；selftest-knowledge-brief.sh T2b 545→548 | 主进程(22.3④接管) | 同上材料包（§S-C）+ worktree 内两 selftest 目标区段 | 两 selftest 单跑全 PASS（含新断言） | 12min | pending |
| S2 | 全量回归 21 个 selftest 主进程逐 Total 行求和 | 主进程（白名单③） | worktree 内 scripts/selftest-*.sh | 0 FAIL；总数 ≥ 基线；SKILL.md wc -l ≤548 | 15min | pending |

### Phase 4: CR + CHANGELOG + 联动核查
- **Status:** complete
- **Executor:** 主进程接管（原派 Explore CR + code-assistant CHANGELOG；例外理由：Rule 22.3④ 全档位 spawn 失败[含 haiku-1]；CR 降级=主进程对照 VC 逐条 diff 自审+全量 selftest 独立回归兜底，白名单⑤/③）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | CHANGELOG.md Unreleased 加 1 bullet（task-v080 路由明确化） | 主进程(22.3④接管) | 同上材料包（§S-D）+ CHANGELOG.md L1-15 | Read 复核条目在位 | 5min | pending |
| S2 | Code Review：worktree 全量 diff 审查（正确性/纯增量/守卫断言质量） | 主进程(接管，spawn 失败降级自审) | worktree 路径 + `git diff f0fa427..HEAD`（基线=master f0fa427） | 输出 APPROVED 或 CHANGES_REQUESTED+清单 | 12min | pending |
| S3 | 变更联动宽口径核查（memory：change-linkage-audit）——SKILL 增补行与 L113/L364-368/collab/selftest 引用一致性 | 主进程（白名单③ 只读核查） | worktree 内改动文件 | grep 无失效关联；结论记 findings | 8min | pending |

### Phase 5: 合并回 + 部署 + 簿记
- **Status:** complete
- VC 逐条复验 → `bash scripts/smart-merge-back.sh <worktree> --deploy` → 3 位 diff -r 主进程亲验 → `git worktree remove` + `git branch -d` → INDEX 刷新 + verification.md 终验 + notepad 沉淀 + memory 更新 + push origin master
- **Executor:** 主进程（白名单① git/worktree 编排 + ② 计划系统簿记）

## 🔗 Subagent Handoff 登记表

| 时间 | seq-agent_type | 目标 S-unit | checkpoint 路径 | 状态 | verify_done | findings 落点 |
|------|---------------|------------|----------------|------|-------------|--------------|
| （执行期登记） | 主进程接管(spawn 失败) | P2-S1/P2-S2 | plans/task-v080-web-research-routing/subagent-state/01-code-assistant.md | done | ☑ | Research Findings |
|  | 主进程接管(spawn 失败) | P3-S1/P3-S2 | plans/task-v080-web-research-routing/subagent-state/03-code-assistant.md | 主进程接管 | ☐ | Research Findings |
|  | 主进程接管(spawn 失败) | P4-S1/P4-S2 | plans/task-v080-web-research-routing/subagent-state/04-code-assistant.md | 主进程接管 | ☐ | Research Findings |

## Decisions Made

| # | 决策 | 理由 |
|---|------|------|
| 1 | silent: 交互模式=silent | 无人值守会话，ask 门控不可阻塞；v076 先例；交付报告附静默决策清单 |
| 2 | silent: 纯增量定性（Rule 36.5）——L458 链为注记增补非语义改写，删除性行为清单=空，36.4 D6 不触发 | 链序①-⑤与工具集合保持不变，仅扩写注释与新增行；36.3 基线照登 findings |
| 3 | silent: 零新 config 键 + 不新增 Rule | 路由为操作指引非流程铁律（v076 零新键先例）；新增 Rule 会引发 1-37 全链级联 |
| 4 | silent: SKILL.md 净增 ≤7 且 T2b 断言 545→548 前置对齐 | v079 B 类扩围教训（行数断言计划期易漏）前置化；548 与另两处断言对齐 |
| 5 | silent: 执行体降档——plan 撰写主进程接管（Rule 22.3④+白名单②），编辑派 code-assistant(haiku-1)，CR 派 Explore(haiku-1)，selftest 求和主进程白名单③ | 环境实证：sonnet-1/mini 档 agent 因思考档位缺失无法启动（plan-writer/general-purpose/Simple Agent 三次 spawn 失败），haiku-1 可用（Explore 成功）；frontmatter 为 truth source 不改，只按 22.3 降档兜底 |
| 6 | silent: worktree 隔离于 /mnt/data/dev/task-planner-skill-worktrees/task-v080-web-research-routing | 宪法 §11.1 命中（skills 保护区）；命名与集中目录新约 |
| 7 | silent: Rule 30 共享追踪不适用 | 部署位为合并窗口独占认领，非部分认领、非同类 ≥3 批量场景 |
| 8 | silent: 禁令源检查（Rule 32.2/C20）已做 | plans/*/notepad 无调研/网络/browser/research 相关否决条目（Explore 实证） |
| 9 | silent: 全档位 spawn 失效 → Rule 22.3④ 主进程接管 P2-P4 全部编辑与验证（spawn 失败记录：plan-writer/general-purpose=sonnet-1、Simple Agent=mini、code-assistant=haiku-1，均 reasoning-level-missing；Explore 初期成功后会话档位选择整体失效） | frontmatter 为 truth source 不改；22.3①改派③降档已穷尽；CR 以「全量 selftest 独立回归 + VC 逐条 diff 自审」替代并登记 FMEA F3 残余风险 |
| 10 | silent: VC-5 措辞修订（B 类）——允许修改行从「仅 T2b 断言行」扩为「L458 注记替换行+T2b 断言行」 | P2 提交实际 +5/-1，-1 即 L458 计划内注记替换（S1 编辑 1 的设计原意，五记号/工具集合 grep 验证不变）；原措辞漏列该行属计划笔误非范围扩张 |

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 任务材料 | 勘察材料包（现状 file:line/决策/修改设计 S-A..S-E 全量） | plans/task-v080-web-research-routing/subagent-state/00-materials.md | ☑ |
| 项目内部 | 调研类操作章节现状 | skills/task-planner/SKILL.md L452-490 | ☑ |
| 项目内部 | 触发矩阵行范式 | references/skill-collaboration.md L51-70 | ☑ |
| 项目内部 | 行数断言三处 | selftest-skill-collab.sh:81 / selftest-execution-stability.sh:72 / selftest-knowledge-brief.sh:38 | ☑ |
| 平台语义 | ZCode 宪法 §七（调研链路）/§十（环境事实：可用工具清单） | 用户级 AGENTS.md | ☑ |
