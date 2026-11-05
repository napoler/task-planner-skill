# 诊断报告 — task-planner-skill 全技能 skill-fix 审计

- **范围**：`/mnt/data/dev/task-planner-skill/skills/` 全部 15 个技能
- **方法**：skill-fix 机械工具（validate_skill / path_existence_validator / detect_drift / subagent_skill_auditor / completeness_checker，bun 1.4.0）+ 智能层判定（S40 frontmatter / S56 allowed-tools / S18 P0 位置 / S25 触发词正交 / S78 SOP / S79 跨技能冗余 / S64 引用歧义）
- **执行**：子代理 A（Codebase Analyzer，task-planner+plan-resume 深度）+ 子代理 B（Code Reviewer，6 中等卫星）+ 主进程兜底（8 轻技能，因 frontmatter-linter / Simple Agent provider 连拒）
- **检查点**：`subagent-state/01-auditor-core.md`（468 行）/ `02-auditor-mid.md`（80 行）/ `03-linter-lite.md`（18 行）
- **日期**：2026-11-05 · **性质**：只读诊断，**未修改任何 skills/ 文件**（修复待用户逐项确认）

## 一、总览结论

| 项 | 结果 |
|---|---|
| 15 技能机械 `valid` | 全 `true`（0 个硬失败） |
| 真 P0（阻断级） | **0**（子代理 A 报的 2 个 P0 经主进程核实全部撤销/降级，见 §二） |
| 真实 P1 | 3 项（task-planner 无锁 RMW + 跨技能引用缺前缀 + plan-resume frontmatter 缺 model/agent） |
| 系统性 P2 | 全 15 技能无 `@config.json` 引用；8 轻技能 model 未配（走宿主默认） |
| 跨技能冗余（S79） | 无 R1 逐字节镜像 / 无 R2 漂移双份 / 无 R3 同义条款（规则均经 pointer 引用，无双份） |

**总体健康度良好**：无阻断级缺陷，核心问题集中在「并行安全」与「引用前缀」两类工程细节，其余为一致性/外置化的设计口径项。

## 二、主进程交叉验证记录（§三 子代理产出核查）

子代理 A 报的 2 个 P0，主进程 Read 原文全部推翻，**印证 skill-fix 自身"子代理须主进程盘上核实"的纪律**：

| 子代理结论 | 主进程核实（证据） | 校准 |
|---|---|---|
| task-planner「P0 铁律距 frontmatter 后第 4 行偏远，违反 S18」 | frontmatter 第二 `---`=行 23，`[P0]` 铁律=行 25（后第 2 行），在 S18「≤3 行」内**合规** | **撤销**（子代理数错行） |
| task-planner「path P0 MISSING（xmlrpc_client 类）阻断」 | SKILL.md 无 xmlrpc_client；该 P0 实为跨技能引用 `plan-cost-guard/references/critical-rules-cost.md` 缺 `../` 前缀，工具 hint 明示"存在于 sibling"，属 S64 **P1 歧义** | **降级 P0→P1** |
| plan-resume「缺 model/agent = P0」 | 亲自 Read L1-4 确认 frontmatter 仅 name+description；但 ZCode **skill** frontmatter（非 agent）不强制 model，走宿主默认 | **降级 P0→P1 一致性** |

## 三、真实 P1（建议修复，非阻断）

| # | 技能 | 问题 | 证据锚 | 建议 |
|---|---|---|---|---|
| P1-1 | task-planner | `register-hooks-cj.ts` 状态 read-modify-write 无锁（缺 lockfile/wx/O_EXCL），多会话并行写竞争 | `01-auditor-core.md` parallel_safety「State read-modify-write without lockfile/wx/O_EXCL」 | 补文件锁或改原子写（tmp+rename） |
| P1-2 | task-planner | 跨技能引用 `plan-cost-guard/references/critical-rules-cost.md` 缺 `../` 前缀，path validator 判 MISSING（实存于 sibling） | `01-auditor-core.md` L95 hint「存在于 sibling，建议加 ../references 前缀」 | 补 `../` 前缀消除歧义 |
| P1-3 | plan-resume | frontmatter 缺 `model`/`agent`/`allowed-tools`（仅 name+description），与同仓配 model 的技能（task-planner/verification-gate/progress-tracker）口径不一致；且 description 超长（塞入大量正文） | 亲自 Read `plan-resume/SKILL.md` L1-4 | 补 model 行 + description 瘦身（正文移入 §） |

## 四、系统性 / 设计口径项（P2，非缺陷）

- **全 15 技能无 `@config.json` 引用**（detect_drift `config_not_externalized`）：多数轻/中技能无 config.json 属正常设计（Standard 10 配置外置仅对"有可变阈值/参数"的技能有意义）。若统一要求，需逐技能判断是否真有外置价值，**不建议一刀切**。
- **8 轻技能 model 未配**（context-corrector / task-drift-guard 配 haiku，其余 6 个走宿主默认）：属可选，非缺陷；建议是否统一配 model 由用户定口径。
- **task-planner `/mnt/data` 命中多为文档注释**（"兼容 /home 与 /mnt/data 双视图"说明），detect_drift 误报，非真硬编码；真正的相对路径推导（L204 R3 注释"相对推导替代硬编码"）已做对。

## 五、修复执行结果（用户 2026-11-05 授权修正后，深挖复核收敛执行）

**深挖后 P1 三项收敛为 1 项真缺陷**：
- **P1-3 plan-resume frontmatter 补 `model: haiku` —— 已修**：worktree 隔离（db689dd）→ merge --no-ff（master 1a143f9）→ 部署 3 位（zcode/claude/cursor）diff=0 → selftest 95/95 零回归 → 主仓+claude 已 push；zcode 仓仅 commit（ahead 夹带 5 个 task-agents-execfix 未推 commit，跨任务不替推）
- **P1-1 无锁 RMW —— 不修**：`register-hooks-cj.ts` L94 已用 `process.pid` 隔离 tmp + 写入幂等 canonical hooks + 一次性安装场景；加 flock=过度工程（Karpathy 简洁 / S54 反模式「给一次性操作加锁」）
- **P1-2 引用前缀 —— 不修**：validator 报的 21 references+1 scripts 命中经源文件核对全为跨技能 sibling 引用或 `<...>` 尖括号占位符，真实可执行引用已带正确 `../`；盲改反把正确的改错
- **P2 口径项不修**：@config.json / 轻技能 model 口径属设计选择非缺陷；task-planner `/mnt/data` 命中多为说明性注释（工具误报）

### 第二轮终态（用户 2026-11-05「1 解决 2 认可」执行结果）

- **P1-2 逐条核对 —— 终局该改=0，零文件改动**：validator 实报 22 非 OK（references `missing=0, ambiguous=21` + scripts `missing=1`）。21 条 AMBIGUOUS（severity=P1 提示级）全部为 validator 把源文件中「已带正确 sibling 前缀的完整路径」（`../task-dispatch/references/...`、`$SKILL_ROOT/../task-dispatch/...` 等）中的 `references/...` 子串提取出来当裸引用误判——每条 actual 均指向 sibling 真实存在的文件；1 条 MISSING（P0）= SKILL.md:117 尖括号占位符 `bash <verification-gate>/scripts/run-verification.sh`（卫星统一入口模板写法，真实文件在 verification-gate/scripts/ 下）被提取 `scripts/` 子串误判。config.json:99 description 裸字样为说明文字非可执行引用→记录不改。全 22 条证据档案落盘 `subagent-state/04-p12-refaudit.md`（1133 行，含主进程 Rule 84.4 终局判定区）——**validator 对本仓 references/scripts 维度的告警可安全忽略，无真缺陷**
- **P1-3 sonnet —— 已改**：worktree a52a909 → merge --no-ff master b6f3581 → 部署 3 位 diff=0（zcode a1cbddc 只 commit 不 push / ahead 7 跨任务隔离；claude 17fed7d 已 push 5758b95..17fed7d；cursor 落盘）。worktree+分支已清
- **selftest 如实口径（Rule 94.6 诚实边界）**：93/95 全绿；2 FAIL（selftest-active-plan / selftest-execution-stability 各 1 用例，T11b 贱例重锁类）经主仓 master 基线对照（无改动侧同样 FAIL 同样用例）证实为**预存环境态失败，与改动无关**

## 六、遗留与风险

- frontmatter-linter / Simple Agent 两 agent 类型本轮 provider 连拒，8 轻技能由主进程兜底完成（已落盘 03）；核心/中等由 Codebase Analyzer / Code Reviewer 正常完成
- 本报告为**只读诊断**，未改任何运行文件；任何修复都将触发 §十一 worktree 隔离 + §六 技能保护区授权流程
- 未跑 completeness_checker 全 15 技能的 `--phase post`（仅 task-dispatch 抽样），如需完整前后置对比可补跑
