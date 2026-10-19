# B 核心技能审计检查点 — task-planner 核心技能复核

- 子代理: B-core-skill (只读审计)
- 审计时间: 2026-10-19
- 审计对象: `skills/task-planner/` 核心技能 + `skills/todo-skill/tools/cli_todo-manager.ts` (S76)
- 基线: `plans/skill-audit-20261019/diagnostic-report.md` 的 F3/F5/F11/P0/S76 五项，逐条复核当前状态
- 方法: 只读 Read/grep + `bash -n` / `node --experimental-strip-types --check` / `python3 -c json.load` 实证，零写入被审计文件
- 环境实证: node=v22.22.0 / python3=3.12.3 / bash=5.2（bun 缺失常态，本审计未再验证 bun，因 P0 修复已脱离 bun）

---

## 一、旧报告 5 项逐条判定

### [F3] 模板+selftest 硬编码 `/mnt/data/dev/task-planner-skill/` → **已修**
判定依据（grep `/mnt/data/dev/task-planner-skill` 四文件 = 0 命中）:
- `templates/verification.md:77,81` 现用 `bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh`
- `templates/task_plan.md:3,29,90,371,373,402,466,497` 全改 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}`
- `scripts/selftest-decision-drift.sh:27` 现用 `REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"`（动态仓根解析，:96-97 缺失=部署位 SKIP）
- `scripts/selftest-subagent-return.sh:26-40` 现用 `PLAN="$SCRIPT_DIR/../../../plans/archive/task-v161-subagent-return-format"`（相对锚 archive/ 归档位，头部注释已登记「主仓绝对路径硬编码=残留脆弱点，后续可改 $TMP hermetic 夹具」但未做设计级重构——属已声明待办，非缺陷）
- 备注: 模板层默认值 `$HOME/.zcode/skills/task-planner` 是 home 相对 + env 可覆盖（运行时探测范式），非机器特定路径，符合旧 F3 建议修法。置信度 HIGH。

### [F5] .claude 与 .zcode 平台路径混用 → **已修**
- `scripts/init-session.sh:31-32,64-73` `find_project_templates` 现同时探测 `.claude/plan-templates` 与 `.zcode/plan-templates`（与 SKILL.md:43「.claude 或 .zcode 覆盖」承诺对齐，旧 :67 只找 .claude 的问题已消除）
- `SKILL.md:43` 现用占位符 `<platform-home>/skills/task-planner/templates/`（旧 :47 写死 `~/.zcode/...` 已改）
- `SKILL.md:40` `node --experimental-strip-types scripts/session-catchup.ts`（相对路径）/ `:47` `node scripts/plan-created.cjs`（相对路径，双清除 side+legacy）——可执行指引全部相对化，零写死平台前缀
- `SKILL.md:21` `# See: ~/.claude/.../SKILL.md (Claude Code) / ~/.zcode/.../SKILL.md (ZCode)` = 双平台注释，合理多工具部署设计，非可执行指引
- `config.json:228,347` 的 `.zcode/.claude` 均在**描述字段**（非可执行命令），属合理双平台文案。
- 置信度 HIGH。

### [F11] task-planner I/O 契约无 JSON Schema + verify_io → **已修**
- `scripts/schemas/check-delegation-stats.schema.json` 实存，`python3 json.load` 合法，draft-07，`required=[phases_total,phases_delegated,main_direct_count,delegation_rate,main_direct,violations,verdict]`
- `scripts/verify_io.sh`（85 行）实存且非空壳：`SEVEN_FILES=(task_plan.md findings.md progress.md notepad-learnings.md verification.md knowledge-brief.md user-session-log.md)` 7 文件在位断言 + check-delegation stats JSON 经 `jq`（缺失 SKIP）+ python3 迷你 schema 断言（不引 jsonschema 依赖，环境实测无该模块）
- `scripts/selftest-verify-io.sh` 已注册 `scripts/selftest-registry.tsv:93`（守护对象=verify_io.sh / schema / SKILL.md I-O 区，标记 task-v189 F11 修复）
- `SKILL.md:203` I/O 契约段已补机器面指针:「机器面=`scripts/schemas/check-delegation-stats.schema.json` + `scripts/verify_io.sh <plan-dir>`（…`scripts/selftest-verify-io.sh` 守护，task-v189 F11 修复）」
- 三脚本 `bash -n` 全通过。置信度 HIGH。

### [P0] 3 个 .ts 脚本 bun 依赖不可运行 → **已修**
- `scripts/session-catchup.ts:1` / `register-hooks-cj.ts:1` / `sync-ide-folders.ts:1` shebang 全部 = `#!/usr/bin/env node --experimental-strip-types`（旧 bun/ts-node 已清零）
- 三文件含真实 TS 类型标注（`detectIDE(): string` / `interface MetaInfo` / `type RefStyle`），`node --experimental-strip-types --check` 逐一 rc=0（node v22.22.0，strip-types 生效）
- `SKILL.md:40` 已改 `node --experimental-strip-types scripts/session-catchup.ts`（旧 `bun scripts/session-catchup.ts` 消失）；SKILL.md 全文 grep `\bbun\b` 零命中
- 残留项见下方 P2-4/P2-5（register-hooks-cj.ts:32 examples 仍写 bun；sync-ide-folders.ts:33,181 仍写 ts-node）——非 BLOCKED，属文档/提示漂移。置信度 HIGH。

### [S76] todo-skill cli_todo-manager.ts 原子写+锁 → **已修**
- `skills/todo-skill/tools/cli_todo-manager.ts:224-244` 原子写=write→`${STORE_FILE}.${pid}.tmp`+`fs.fsyncSync(fd)`+`fs.renameSync(tmpPath, STORE_FILE)`（POSIX 同目录 rename 原子，pid 后缀避免并行写者互踩，失败 best-effort 清理 tmp 不掩盖原错）
- `:250-300` O_EXCL lockfile 互斥（`fs.openSync(LOCK_FILE,"wx",0o600)`=O_CREAT|O_EXCL；EEXIST 探活锁内 pid + mtime 判 stale 锁；Node 无原生 flock，O_EXCL=零依赖最简互斥，不破坏 META_DEPS 无外部依赖契约）
- `:607` 写命令（create/update/clear/plan）取 O_EXCL 锁，只读命令免锁（原子写已保证读一致性）
- 全段标 `[task-v189 S76 修复]`。文件 645 行。置信度 HIGH。

---

## 二、新发现（第一手验证）

### [P1] N-1 — templates/variant/video-fix-type.md 硬编码 `/mnt/data/dev/videop1/` 伴飞绝对路径（S75 D1 迁移性）
- 位置: `skills/task-planner/templates/variant/video-fix-type.md:5`（HTML 注释）+ `:79,80,81,82`（「必要知识储备」表 4 行）
- 证据原文:
  - `:79` `| 处置 SOP | videop1-video-fix skill §0-§11… | /mnt/data/dev/videop1/.zcode/skills/videop1-video-fix/SKILL.md | 必读 | ☐ |`
  - `:80` `… | /mnt/data/dev/videop1/tools/specs/qc-items-video-8cat.json | …`
  - `:81` `… | /mnt/data/dev/videop1/prompts/common-sense-clauses.md | …`
  - `:82` `… | /mnt/data/dev/videop1/docs/series/jipin-nvdiaoshou/ep06-error-audit.md | …`
- 问题: 同表 `:85` 用 `<repo-root>/AGENTS.md`、`:86` 用 `<repo-root>/docs/series/<series>/` 可移植占位符，唯独 :79-82 写死当前部署机 `/mnt/data/dev/videop1/`——同表风格自相矛盾；template 是机器行为面，复制即固化该部署者路径，换机失效（同旧 F9 split-pattern-library.md 的 S75 D1 病型，此处为新实例）。
- 建议: :79-82 伴飞绝对路径改 `<repo-root>/.zcode/skills/videop1-video-fix/SKILL.md` 等占位符（与 :85/:86 同范式），:5 注释同步；或登记为「videop1 专属 variant，部署方本地注入」豁免注。
- 判定: **未修**（旧报告未列此项，属本轮新发现 P1）

### [P2] N-2 — SKILL.md:158 行号锚漂移（critical-rules-discipline.md:191 应为 :195）
- 位置: `skills/task-planner/SKILL.md:158`
- 证据原文: `:158` `…`../task-discipline/references/critical-rules-discipline.md:191`（逐字双载，域归属=模板域+执行纪律域）…`
- 实测: `task-discipline/references/critical-rules-discipline.md:191` = `45.7 **机器承载与落地边界**…`（Rule 45.7），而 Rule 38.7 实际在 `:195`（grep `195:38.7 **执行通道分级…**` 命中）；锚点漂移 4 行。
- 佐证: 同句另一锚 `plan-template-kit/references/critical-rules-template.md:45` 实测 `:45` = `38.7 **执行通道分级…**` 起点，**正确**（该文件 53 行，:45 非越界）；核心 `task-planner/references/critical-rules.md` grep `^38\.7` 0 命中，与 :158「原核心锚已失效（0 命中）」注记一致。
- 建议: `:158` 的 `critical-rules-discipline.md:191` 改 `:195`（段落锚/关键词锚 `grep '^38\.7'` 更稳，防再次漂移）。
- 判定: **未修**（P2 行号锚漂移，同旧 P2-10 病型）

### [P2] N-3 — SKILL.md:157 行号锚 off-by-one（lane-detect.sh:85 应为 :86）
- 位置: `skills/task-planner/SKILL.md:157`
- 证据原文: `:157` `…如代码文件改动被 lane-detect.sh:85 禁滥用条款排除 → 已补 trivial 第四条件…`
- 实测: `scripts/lane-detect.sh:85` = `[ -n "$l2_hits" ] && { lane=L2; reason="L2 命中: …" }`（L2 赋值行）；「禁滥用」块实为 `:86` 注释 `# L0 三条件 + 禁滥用机器化（任一命中 → L1…）` + `:87-88` 代码（`abuse=""` / `[ -n "$NEW_HIT" ] && abuse=…`），锚 off-by-one。
- 建议: `:157` 的 `lane-detect.sh:85` 改 `:86`；或改关键词锚「lane-detect.sh 禁滥用机器化段」。
- 判定: **未修**（P2 轻微 off-by-one）

### [P2] N-4 — register-hooks-cj.ts:32 帮助 examples 仍写 bun（P0 修复残留文档漂移）
- 位置: `skills/task-planner/scripts/register-hooks-cj.ts:32`
- 证据原文: `examples: "$ bun scripts/register_hooks_cj.ts\n$ bun scripts/register_hooks_cj.ts --dry-run\n$ bun scripts/register_hooks_cj.ts --canonical ~/dev/task-planner",`
- 问题: 同文件 `:1` shebang 已改 node、`:14` docstring `Usage: node --experimental-strip-types register-hooks-cj.ts…`，但 MetaInfo.examples（`--help` 实出文案）仍三行写 `bun`，与 shebang/docstring 自相矛盾；bun 本机缺失，按 examples 复制即 rc=127。
- 建议: :32 examples 三行 `bun` 全改 `node --experimental-strip-types`。
- 判定: **未修**（P2 文档漂移）

### [P2] N-5 — sync-ide-folders.ts:33,181 仍写 ts-node（P0 修复残留文档漂移）
- 位置: `skills/task-planner/scripts/sync-ide-folders.ts:33` + `:181`
- 证据原文:
  - `:33` ` *   ts-node`（META_DEPS 依赖声明，实为 `Node.js >= 18` 即可 strip-types 运行，ts-node 已不再需要）
  - `:181` `console.log("Run 'ts-node sync-ide-folders.ts' to fix.");`（漂移修复提示，本机 ts-node 缺失，按提示复制即失败）
- 佐证: 同目录 `session-catchup.ts` 头注释已无 ts-node/bun 残留（范式=改净），仅本文件残留两处；`register-hooks-cj.ts` 亦无 META_DEPS ts-node 残留（仅 :32 bun examples，见 N-4）。
- 建议: `:33` META_DEPS 删 `ts-node` 行；`:181` 提示改 `node --experimental-strip-types sync-ide-folders.ts`。
- 判定: **未修**（P2 文档漂移）

---

## 三、负结果（已搜索未发现 / 已排除）

1. `templates/**` 全量 grep `/mnt/|/home/terry/`（去示例/占位过滤后）仅命中 N-1 的 video-fix-type.md 5 处；`task_plan.md`/`verification.md` 等其余 12 个非 variant 模板 + 45 个 variant 模板**无**机器特定路径（均走 `${TASK_PLANNER_ROOT:-…}` 或 `<repo-root>/` 占位符）。
2. `scripts/selftest-*.sh` 全部 grep `/mnt/|/home/terry`：可执行（非 `#` 注释）行 0 命中；唯一 2 处为注释（`selftest-smart-merge.sh:308` 说明「相对推导替代硬编码 worktree 路径」、`check-dispatch.sh:23,33,130,281` 说明「兼容 /home 与 /mnt/data 双视图」——均为解释兼容逻辑的注释，非写死命令）。
3. SKILL.md 指向 `scripts/` 的 16 个本地脚本引用逐一 `test -f` 全部 EXISTS（archive-plan/attest-plan/check-3file-gate/check-complete/check-conflicts/check-context-hygiene/init-session/ledger-append/plan-created.cjs/rule-reserve + schema/selftest-verify-io/session-catchup/smart-merge-back/sync-todos/verify_io）。唯一 `MISSING` 假阳性 = `run-verification.sh`——实为 SKILL.md:83 `<verification-gate>/scripts/run-verification.sh` 跨技能引用（带 `<verification-gate>/` 前缀指向卫星 `skills/verification-gate/scripts/run-verification.sh`，实测 EXISTS），非 task-planner 本地缺失。
4. SKILL.md 可执行指令 grep `~/.zcode/skills/task-planner|/mnt/data` 仅 `:21` 双平台注释命中（合理）；可执行面（:40,:47 等）全相对路径，无写死平台前缀。
5. `selftest-registry.tsv:93` 确认 selftest-verify-io.sh 已登记，F11 机器面非孤儿脚本。

---

## 四、修复优先级建议

1. P1 N-1（video-fix-type.md 伴飞路径）: 文本面改 5 处占位符，低风险，随 P1 迁移性批修。
2. P2 N-2/N-3（行号锚漂移）: 文本面改 2 处锚，改关键词锚更稳。
3. P2 N-4/N-5（bun/ts-node 残留提示）: 文本面改 3 处 examples/提示/META_DEPS，随 P0 修复收口。

（以上全部为文本面/注释面低风险修，无逻辑改动；修复按 §十一 worktree 流程，本审计只读未改任何被审计文件。）
