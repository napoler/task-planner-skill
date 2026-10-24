# 01 检查点：task-planner 初始化/模板机制现状（只读调查）

调查对象=/mnt/data/dev/task-planner-skill（源仓；部署位 ~/.zcode/skills/task-planner/ 同步，以源仓为准）。
全部路径简写 `S` = `skills/task-planner/`。调查日期 2026-10-24。

## 1. scripts/init-session.sh（1023 行）

### ① 参数/env 清单
**位置参数**（`S/scripts/init-session.sh:9,395-403`）：
- `$1` PROJECT_NAME（`L395: PROJECT_NAME="${1:-project}"`）——仅用于 L481 echo 文案，不写入任何文件
- `$2` TEMPLATE_TYPE（`L396: TEMPLATE_TYPE="${2:-${TASK_TEMPLATE_TYPE:-}}"`，positional 优先、env 兜底）
- `$3` PLAN_TIER（`L403: PLAN_TIER="${3:-${TASK_PLAN_TIER:-}}"`；=mini 时路由 `variant/mini-lite-type.md`，L541-548；已命中 variant 定制时 mini 不生效 L543）
- 特殊子命令 `--list`（L24-53）：只列可用模板（内置 variant+项目 `*-type.md`+当前 default），不建文件

**env 变量**（逐个）：
| env | 行号 | 作用 |
|---|---|---|
| `TASK_TEMPLATE_TYPE` | L396 | `$2` 缺省时的模板类型兜底 |
| `TASK_PLAN_TIER` | L403 | `$3` 缺省时的档位 |
| `TASK_TEMPLATE_DEFAULT` | L499-514（L506-508） | 类型空缺时默认模板（优先级低于项目 `default` 文件） |
| `TASK_AUTO_TIER` | L457 | =1 才进入 auto-tier 判定（opt-in） |
| `TASK_EST_MINUTES` | L427,L469 | 预估分钟 ≤15 条件（auto-tier 四条件之一） |
| `TASK_SCOPE_FILES` | L426,L470 | 1-2 文件条件 |
| `TASK_SCOPE_MODULES` | L426,L471 | =1 单模块条件 |
| `TASK_TIER_EXCLUDE` | L458 | =1 命中④排除（保护区/Rule36/D6 高危）→ 不降 mini |
| `TASK_SCOPE_FILE_LIST` | L429-435 | 逗号分隔文件名列表；唯 1 个 ∧ 代码扩展名（.sh/.ts/.cjs/.js/.py/.json）→ trivial 档 |
| `TASK_EST_LINES` | L428 | ≤3 行条件（trivial 第四条件） |
| `CLAUDE_CODE_SESSION_ID` | L918 | 会话 sid→写 side 指针 `.active_plan_side/<sidkey>.active_plan`；无值→全局 fallback `.active_plan` |
| `TASK_PLANNER_INTERACTION_MODE` | L862 | =silent → 即时 attest 落锁（防窗口期篡改，G3） |
| `TASK_LANE_BASE` | L687-689 | lane-detect 的 git BASE（默认 HEAD），决定 execution_lane L0/L1/L2 |

派生标记（脚本内部）：`AUTO_TIER_FIRED`（L414，auto 降 mini 事实）、`TRIVIAL_CODE_TIER`（L419，trivial 档→文件集缩 3 个 + user-session-log 改按需 + L0 通道）。
保护区强判：`_trivial_code=1` 时文件名命中 `*/.zcode/skills/*` 等 case 列表强制回 0（L441-455，H2-fix 2026-10-14）。

### ② task-id/计划目录名的获取方式
**脚本不知道 task-id 参数**——靠 CWD 守卫反推：`L56-59` 要求 CWD 的父目录 basename 必须 = `plans`（否则 exit 1）；目录名=模型事先 `mkdir -p plans/task-XXX/ && cd $_` 建好的目录名；脚本内只用 `$(basename "$PWD")`（L1011,1018）写指针、`$(pwd)` 传 resolve-interaction-mode/attest（L869,882,884）。`DATE=$(date +%Y-%m-%d)` 在 L479 定义但**全文 0 处使用**（`grep '\$DATE'` 无命中，只作 echo 行间的死变量——日期未注入任何模板）。

### ③ 占位符替换逻辑
**无任何文本变量替换**（无 envsubst/sed 变量展开/perl 替换模板内容；`grep envsubst` 全仓 0 命中）。脚本做的只有**条件行注入/追加**（非变量渲染）：
- `copy_template`（L83-97）：纯 `cp`（项目级>内置级），零改写
- L605-606：项目模板缺 `template_type` 标识时 awk 头插一行 `<!-- template_type: X -->`
- L615-617：auto-tier 命中时 awk 在 `plan_tier: mini` 行后插 `<!-- auto_tier: mini -->`
- L694：sed 第 2 行前插 `execution_lane: L0|L1|L2`
- L728-740 / L761-771：general 兜底/unknown 类型 → 末尾追加「🔁 模板感知」区块（heredoc）
- `inject_requirement_block`（L135-266）/`inject_evidence_goal_block`（L292-386）：缺 🎯/🧮 或 🔍/🎯裁决 锚时 awk 在 Goal/Current Phase 行前插**带占位符的脚手架**（注释 L109 明示「占位符保留供规划者填写」；quoted heredoc L206「占位符 <...> 与 ** 须原样保留，禁展开」）

### ④ "Initializing planning files for: project" 兜底词来源
`L395: PROJECT_NAME="${1:-project}"` → L481 `echo "Initializing planning files for: $PROJECT_NAME"`。模型通常不传 `$1` → 恒定打印 `project`。纯回显，不进文件。

### ⑤ 模板优先级实现
`find_project_templates`（L65-79）：从 CWD **向上逐级**找 `.claude/plan-templates/` 或 `.zcode/plan-templates/`（先 .claude 后 .zcode，命中即停）；`copy_template`（L87-96）逐文件：项目级同名文件存在→`cp` 项目文件（打印 "project-level"），否则内置 `templates/`（"built-in"）。variant task_plan 路由（L487-537）：VALID_TYPES=内置 `variant/*-type.md` 动态派生（L488）+ 项目目录 `*-type.md` 并入（L492-496）；内置未命中→查项目 `<type>-type.md`（L526-528，复制源=绝对路径，置 `PROJECT_TPL_USED=1` L587-591）；未命中/unknown→WARNING 回落 generic `task_plan.md`（L530-535）。默认模板：项目 `plan-templates/default` 文件（内容=模板名，head -1）> env `TASK_TEMPLATE_DEFAULT` > general（L499-514）。

## 2. 占位符全清单（templates/*.md + variant/*，grep 实测）

**机械类（可脚本渲染）——文件×token×次数：**

| token 形态 | 位置（典型） | 总次数 |
|---|---|---|
| `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}`（markdown 内 shell 展开式，**永远不会被 shell 展开=已知失修 bug**） | task_plan.md:3,29,90,354,372,373,376,378,407,471,505；session-handoff.md:1,30,35；subagent_dispatch.md:2,85,109；batch_report.md:5；deprecated.md:47,48；verification.md:77,81；user-session-log.md:1；knowledge-brief.md:4,12；delivery-summary.md:3,24,26；variant/{publish:4,113 video-fix:4 script-dev:96 character-design:106 motion-camera:71,94 memory-hygiene:46,76,95} 等 | 约 27 文件行/27+ 处（模板内 grep -c=27 行） |
| `{task-id}` / `{task-name}`（小写单花） | delivery-summary.md:24；knowledge-brief.md:1；notepad-learnings.md:1；user-session-log.md:1；variant/research-type.md:30；variant/video-type.md:36,39,40；`<task-id>` 变体：task_plan.md:28,29,354,372,373；session-handoff.md:1；knowledge-brief.md:4,12；delivery-summary.md:3,26；user-session-log.md:7；16 个 variant（refactor/bugfix/code-edit/schema-migration/test-writing/performance-tuning/deployment/memory-hygiene 等各 2 处） | 单花 8 + 尖花 `<task-id>`/`<task>` 约 35 |
| `[DATE]` | progress.md:11（`## Session: [DATE]`） | 1 |
| `[YYYY-MM-DD HH:MM]` | progress.md:15（Started 行，check-3file-gate mtime 锚） | 1 |
| `YYYY-MM-DD` | user-session-log.md:10,14,18；progress.md 注释；deprecated.md:14；batch_report.md:65；variant/memory-hygiene-type.md:71,97 | 8 |
| `[Brief Description]` | task_plan.md:1（`# Task Plan: [Brief Description]`） | 1 |
| `XXX` | knowledge-brief.md:33；variant/writing-type.md:7 | 2 |
| `task-{id}` 字面（SKILL.md 指令句内） | SKILL.md:40,233（`mkdir -p plans/task-001/` 示例） | 6（全仓） |

**语义类（模型填写，禁机器替换）**：`<用户原话第 1 条…>` task_plan.md:19-20；`<按需增行>` task_plan.md:20；`<判据：…>` task_plan.md:25；V-N 占位行 task_plan.md:88；`#N 必须替换为真实数字序号` user-session-log.md:10,17；`<工序 1>/<缺陷面>/<修复 S-unit/Phase>/<VC-n>` 根源覆盖表（init 注入版 L237/模板内同名区块）；「填写」指令词 47 处（分布见 grep 输出：knowledge-brief 12、task_plan 13、progress 1 等）；「占位」15 处；subagent_dispatch.md:2「字段值使用占位符 {placeholder} 形式,调用方替换」。

**.zcode/plan-templates/（项目级）**：仅 1 文件 `knowledge-brief.md`（≈内置模板的本地覆盖版）；含 `<task-id>`×3（L4,12,82）+ 6 段「填写说明」注释，**0 个 `${TASK_PLANNER_ROOT}`**（本地版已手工展开路径）——证明项目级覆盖模板的占位符面与内置不一致，机械渲染须双轨覆盖。

## 3. 模型侧「初始化后填写/替换/修正」指示清单（文件:行 + 短摘）

- `SKILL.md:40` — 创建 `plans/{task-id}/`，运行 `bash scripts/init-session.sh`（task-id 由模型自拟，无脚本参数通道）
- `SKILL.md:233` — 示例 `mkdir -p plans/task-001/ && cd $_ && bash <skill>/scripts/init-session.sh`（任务名/ID 只出现在 echo）
- `init-session.sh:110,116` — 注入注释「占位符保留供规划者填写」「…由规划者在表格区填写」
- `init-session.sh:259,261,263,379-383` — 注入后回显「规划者填写 R 行/映射/覆盖表后 attest 校验」「规划者填写取证行/裁决表后 attest 复核」
- `templates/user-session-log.md:10,17` — 「复制模板后把 #N 替换为 #1、#2 顺延」「示例行的 #N 必须替换为真实数字序号」
- `templates/progress.md:16` — 「Started…开启 Phase 时必须填写真实时间」（[YYYY-MM-DD HH:MM]）
- `templates/knowledge-brief.md:12` — 「init-session.sh 建 plans/<task-id>/knowledge-brief.md 后即按 §1-§5 填写」
- `templates/subagent_dispatch.md:2,4` — 「主进程读本模板填九字段」「逐项替换占位符」「字段值使用占位符 {placeholder} 形式,调用方替换」
- `templates/task_plan.md:88` — 「补 - **V-N:** 占位行，填写本 Phase 验收映射的 VC 编号」
- `templates/variant/video-fix-type.md:4` — 用法注释含 `<任务名> video-fix`（任务名只喂 echo 参数）
- `references/critical-rules.md` / `goal-gate.md` 无占位符替换条款（grep 命中 0；critical-rules 里「修正」均指锚校准，非模板填写）

## 4. selftest/check 级联面

**断言 init-session.sh 内容/行为的（改 init 必级联）：**
| 脚本 | 断言要点 |
|---|---|
| `selftest-knowledge-brief.sh:46-47` | T3a init 含 'knowledge-brief.md' ≥2 ∧ T3b '6/6' ≥1 |
| `selftest-session-log.sh:79-80` | SL-07 init 含 `copy_template "user-session-log.md"` ≥1 ∧ '6/6'=1 |
| `selftest-execution-stability.sh:92` | T10b init '6/6' ≥1 |
| `selftest-plan-tier.sh:61,119,121,323-334` | PT-13 init 含 TASK_PLAN_TIER+variant/mini-lite+「tier=mini 忽略」锚；PT-11 模板 ≤80 行+frontmatter；PT-24 项目 default 文件+frontmatter 插入行为（跑真 init） |
| `selftest-template-lifecycle.sh:54,89` | TL-11 init 含 TASK_TEMPLATE_TYPE+variant+`ls ` 动态派生 |
| `selftest-active-plan.sh:17,104,167-196` | T08/T12a-T12c init 的 sid/sidmap/哨兵 fallback 行为（跑真 init） |
| `selftest-evidence-goal-gate.sh:294-303` | EG-21 init 含 `inject_evidence_goal_block()` 定义=1+调用=1 |
| `selftest-requirement-coverage.sh` | init 注入兜底（51.1 双锚）在位断言 |
| `check-complete.sh:367,1376` | 缺文件提示走 init-session.sh；SESSION-LOG baseline（init 建档）enforce |
| `plan-doctor.sh:58` | 无计划提示跑 init |

**断言 templates/ 内容的（改模板必级联）**：selftest-plan-tier（mini-lite 行数/前缀、variant 全集 `plan_tier: standard` 计数 L121）、selftest-knowledge-brief（六段骨架+subagent_dispatch 锚）、selftest-session-log（#N 占位口径）、selftest-template-lifecycle（TL-19 delivery-summary 五要素=5、TL-22 可定位性三锚）、selftest-requirement-coverage（delivery-summary）、check-template-type（模板 template_type 三形态）。另有约 40 个 selftest-*.sh 在测试夹具里 `cp`/引用 `templates/`（grep 'templates/' 命中 45 文件——多为 fixture 生成，非内容断言；真实内容断言以上表为准）。
**运行机制**：`run-selftests.sh` 指纹=全部 selftest 内容+git porcelain/HEAD（L5-7）→ 改 init-session.sh 或 templates/ 即 git dirty → 全量重跑。
**install/deploy 级联**：`tests/smoke.sh`、`selftest-doc-script-paths.sh`（L33 专门豁免 `${TASK_PLANNER_ROOT:-…}` 单元格为「env 根路径非仓库相对引用」——把模板占位符当合法人读路径的机器豁免，改占位符形态须同步此面）、`sync-companion.sh`/`install.sh`（TASK_PLANNER_ROOT 消费面）。

## 5. 周边脚本消费面（一句话 each）

- `set-active-plan.sh`：`set <task-id> [--sid s]` 写 `<root>/plans/.active_plan{,_side/<sidkey>.active_plan}`，task-id 由调用方（模型）自拟，norm_sid 剥非字母数字取 40+去 sess（:20-25,:27）
- `resolve-plan-dir.sh`：按 ①side 指针 ②全局 fallback ③mtime 最新 ④legacy 根单文件 四级解析 `plans/<task-id>/task_plan.md` 路径，slug 校验（:17-19,:101）
- `sync-todos.sh`：解析 plan 目录的 task_plan.md Phase→原生 Todo 同步；plans 目录从 CWD 向上 6 级找（:44-50）
- `attest-plan.sh`：对 task_plan.md 计算 SHA-256 写同目录 `.plan-attestation`（:3）；init silent 路径在 attest 前模板已定型，替换逻辑放在 init 内=哈希锁定前，无 attestation 冲突
- `lane-detect.sh`：读 git diff（BASE=`TASK_LANE_BASE` 默认 HEAD）判 execution_lane L0/L1/L2，trivial 档传 `--trivial`（init-session.sh:687-689）

## 6. 既有渲染先例

- **无 envsubst、无模板变量渲染器**（`grep envsubst` 全仓 0；`grep render` scripts/ 无命中）。
- 先例 1（行级注入）：init-session.sh awk/sed/heredoc 五处条件插入（§1③ 列表）——「锚定位+插整块」范式，未做变量展开。
- 先例 2（shell 变量展开=安装期渲染）：`register-hooks-cj.ts:109-165`——生成 hook 命令时保留 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}` 字面量，仅 log 时正则替换为 canonicalRoot（L159-165）；即仓内唯一「占位符→真实值」先例是**构建期字符串替换**，可作改造范式参照。
- 先例 3（约定式占位符+调用方替换）：subagent_dispatch.md:2 明示 `{placeholder}` 由主进程（模型）逐项替换——与用户投诉同构的既有模式。
- 附带失修事实：模板 markdown 里 27 行 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}` 是 shell 展开语法但 markdown 永不展开→活体计划（grep `plans/*/task_plan.md` 命中 8 份）保留字面 `${TASK_PLANNER_ROOT…}` 文本，读者/模型须自行脑补；`selftest-doc-script-paths.sh:33` 已将其当「合法 env 根路径」豁免，说明这是被机器接受的病态。

## 7. 最值得改造的 3 个点

1. **init-session.sh 增加机械占位符渲染层（cp 后 sed 替换）**：task-id 已可从 CWD basename 确定性获得（L56 守卫保证 `plans/<task-id>`，目录名即 task-id，L1011 已有 `$(basename "$PWD")`）；可新增 `TASK_ID/PLAN_DIR/DATE/ROOT` 四个内部变量，对 7 文件做一次性 sed 替换：`{task-id}`/`<task-id>`/`<task>`→TASK_ID，`[Brief Description]`→PROJECT_NAME，`[DATE]`/`[YYYY-MM-DD HH:MM]`→date，`${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}`→真实 `$BUILTIN_TEMPLATES/../` 绝对路径（顺带修复 27 处永不展开 bug + selftest-doc-script-paths.sh:33 豁免可退役）。约束：替换须在 attest 之前（init 内）=哈希锁无冲突；`{{` 双花 0 命中可安全作分隔符选型；`#N`（user-session-log）与 `<用户原话…>` 语义占位**不**进替换面。
2. **任务名/描述参数化**：现 `$1` 仅回显（L395/L481，'project' 兜底）——把任务简述升为可写入模板头（task_plan.md:1 `[Brief Description]`）的渲染变量，替换当前纯 echo 通道；`<按需增行>`/R 行等语义占位保留模型填写（init 回显语 L259 已声明「规划者填写」，替换面与填写面在注释里划界）。
3. **selftest 级联登记（改前必跑面）**：改 init-session.sh 内容/回显 → selftest-{knowledge-brief,session-log,execution-stability,plan-tier,template-lifecycle,active-plan,evidence-goal-gate,requirement-coverage}；改 templates/ 文件 → 上表全部 + check-template-type + run-selftests.sh 指纹（git dirty 触发全量）；改 `${TASK_PLANNER_ROOT…}` 字面形态 → selftest-doc-script-paths.sh:33 豁免条款同步。项目级 `.zcode/plan-templates/knowledge-brief.md`（已手工展开路径）证明双轨（内置+项目覆盖）都要过渲染层。
