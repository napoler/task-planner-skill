# B-运行时/硬编码/平台/登记现势 审计检查点

- 审计对象: /mnt/data/dev/task-planner-skill
- 审计时间: 2026-10-26
- 范围: 硬编码路径 + bun 运行时残留 + 平台一致性 + 遗留登记 4 项现势
- 铁律: 只读; 除本文件零写入; 不动 git

## 一、硬编码路径扫描（grep -rn '/mnt/data/dev\|/home/terry' skills/）

| 命中 | 分类 | 判定 |
|------|------|------|
| templates/variant/video-fix-type.md:6,80,81,82,83（5 处 /mnt/data/dev/videop1/...） | (b) 已登记例外 | v188 progress.md:42「videop1 外部项目路径保留（5 处，设计意图：外部仓非本仓迁移缺陷）」——与实扫 5 处精确吻合，非缺陷 |
| MIGRATION.md:94（`s|bash "/home/terry/\.zcode/...`） | (b) 已登记例外 | v188 progress.md:40「排除 MIGRATION.md sed 旧值」——sed 旧值锚，非缺陷 |

**结论: 残留缺陷 0 处**（/mnt 命中全为 videop1 登记例外；/home/terry 命中仅 1 处 = MIGRATION sed 旧值登记例外）。

## 二、运行时验证（bun）

`grep -rn 'bun run\|env bun\|command -v bun' skills/` 命中逐条分类：
- **缺陷（可执行语境，非零残留）**：
  - B-01 [MAJOR] INSTALL.md:200 `bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts`（bash 代码块=用户可执行指引）
  - B-01 [MAJOR] INSTALL.md:274 同上（bash 代码块）
  - B-03 [MAJOR] MIGRATION.md:100 `bun run ~/.claude/...register-hooks-cj.ts`（bash 代码块）——注: MIGRATION 的登记例外仅限 :94 sed 旧值，:100 bun 不在登记范围
  - 修法: 三处 `bun run <path>.ts` → `node --experimental-strip-types <path>.ts`（与 install.sh:159-166 口径对齐）
- **非可执行（示例/测试数据/注释，非缺陷）**：
  - selftest-evidence-goal-gate.sh:29,309,357,362,366,368（测试夹具输入串 `bun run x`）
  - todo-skill/tools/cli_todo-manager.ts:62（设计理由注释，记录 bun 不可用降级决策）
  - templates/variant/{code-edit,bugfix,test-writing,performance-tuning,refactor}-type.md（示例命令 `bun test`/`bun run lint`，均带「或对应语言命令」限定语）

**3 个 .ts 脚本 node 实测**：
| 脚本 | shebang | 副作用 | 实测 | EXIT |
|------|---------|--------|------|------|
| session-catchup.ts | `#!/usr/bin/env node --experimental-strip-types` | 纯只读（head: 纯只读扫描） | 实跑 `node --experimental-strip-types scripts/session-catchup.ts` | **0**（无输出=无中断恢复点） |
| register-hooks-cj.ts | 同 node shebang | 有写（写 settings.local.json tmp+rename）→ 只静态检查 | grep Bun=0；import node:fs/path/os；process.argv（无 Bun.argv） | N/A |
| sync-ide-folders.ts | 同 node shebang | 有写（copyFileSync 覆盖目标）→ 只静态检查 | grep Bun=0；import node:fs/path/crypto | N/A |

- 3 脚本 `grep -n 'Bun'` = **零命中**（v189 已彻底去 Bun 依赖）。

## 三、平台一致性

- **init-session.sh 双平台探测（F5 修复验证）= 通过**：
  - find_project_templates 同时覆盖两目录：`init-session.sh:68-69`(.claude) + `:72-73`(.zcode)
  - `--list` 分支同样双覆盖：`init-session.sh:31`(.claude) + `:32`(.zcode)
  - 注释已平台中性化：`init-session.sh:61` `# <platform-home>/skills/task-planner/templates/ ... 平台无关`
- **SKILL.md 正文写死单平台家目录 = 残留仅 2 处非可执行**：
  - B-05 [INFO] SKILL.md:21 `# See: ~/.claude/.../SKILL.md (Claude Code) / ~/.zcode/.../SKILL.md (ZCode)`——双平台并列指针，非单一写死
  - B-05 [INFO] SKILL.md:190 `不修改 ~/.zcode/ 下的记忆文件（§六 保护区）`——§六 保护区叙述，非命令行
  - 可执行指引已相对化（v189 修复生效）：SKILL.md:40 `node --experimental-strip-types scripts/session-catchup.ts`、:42 `bash scripts/init-session.sh`、:47 兜底 `<platform-home>/skills/...` 平台中性
- 附注 B-04 [MINOR] install.sh:8 注释 `# 1. Pre-flight: checks git/bun/jq availability` 陈旧——实代码 install.sh:56 仅检 `git bash`（bun/jq 均未检）；建议改注释。

## 四、遗留登记现势性（plans/task-v188-skill-audit-fix/register-deferred.md 4 项）

| # | 登记项 | 现状 | 证据（第一手） |
|---|--------|------|----------------|
| 1 | P0 bun 缺失 | **resolved（脚本层）**；**still-open（文档层 B-01/B-03）** | session-catchup.ts:1 = `#!/usr/bin/env node --experimental-strip-types`；register-hooks-cj.ts:1 / sync-ide-folders.ts:1 同；`node ... session-catchup.ts` EXIT=0；3 脚本 grep Bun=0。残留=INSTALL.md:200/274 + MIGRATION.md:100 仍写 `bun run` |
| 2 | F5 平台混用 | **resolved** | init-session.sh:31-32/68-73 双平台探测齐；SKILL.md:40/42 相对化、:47 平台中性；残留仅 SKILL.md:21/190 非可执行叙述 |
| 3 | F11 I/O Schema + verify_io | **resolved** | verify_io.sh 在位（`test -f` YES）；schema 在位 = `skills/task-planner/scripts/schemas/check-delegation-stats.schema.json`（注: 实际路径在 scripts/schemas/ 下，非 task 提示的 skills/task-planner/schemas/）；verify_io.sh:15 `SCHEMA="$SCRIPT_DIR/schemas/..."` 引用正确 |
| 4 | S76 todo-skill 非原子写 | **resolved** | cli_todo-manager.ts:233-242 saveStore=tmp(pid 后缀)+fsync+rename 原子写；:253-315 O_EXCL lockfile(acquireLock/maybeStaleLock/releaseLock)；:607-641 写命令取锁、只读免锁 |

## 五、语法门（bash -n）

`for f in skills/task-planner/scripts/*.sh skills/*/scripts/*.sh skills/task-planner/lib/*.sh scripts/*.sh` → **TOTAL_FAILS=0**（全部 .sh 语法通过，无 SYNTAX-FAIL）。

## 六、结论

- 硬编码路径残留缺陷: **0**
- bun 运行时残留缺陷（可执行语境）: **3**（B-01×2 + B-03，均文档 bash 代码块）
- 平台一致性: 功能层 resolved；残留 2 处非可执行叙述 + 1 处陈旧注释
- 登记 4 项: 4/4 resolved（bun 项文档层另有 3 处残留，见 B-01/B-03）
- 语法门: 0 失败
