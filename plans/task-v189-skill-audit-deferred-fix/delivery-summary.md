# Delivery Summary: task-v189 skill-fix 审计四项 deferred 修复

## 1. 说明（做了什么）

修复 task-v188 skill-fix 审计登记的 4 项 deferred 高风险项，全部经用户「1,2,3,4」授权：

| 项 | 编号 | 问题 | 修复 |
|----|------|------|------|
| 项1 | P0 bun | 3 .ts 脚本 `#!/usr/bin/env bun` 但 bun 未安装（node v22.22.0 可用） | shebang 改 `node --experimental-strip-types`；`Bun.argv`→`process.argv`；`require('node:fs')`→import；调用方（install.sh/install-stub.sh/SKILL.md/session-handoff.md）同步 |
| 项2 | F5 平台 | init-session.sh 缺 `.zcode/plan-templates` 探测 + SKILL.md:47 硬编码 `~/.zcode` 绝对路径 | init-session.sh L31+L67 补探测（additive，.claude 优先级保留）；注释平台中性化；SKILL.md:47 相对化 `node scripts/plan-created.cjs` |
| 项3 | F11 I/O Schema | task-planner I/O 契约纯文本，无机器可校验 JSON Schema | 新建 `check-delegation-stats.schema.json`（draft-07，7 required keys）+ `verify_io.sh`（7 文件存在断言 + stats JSON 校验）+ `selftest-verify-io.sh`（4 断言）+ SKILL.md 机器指针 |
| 项4 | S76 todo-skill | `cli_todo-manager.ts` writeFileSync（ENOSPC 截断风险）+ store.json 无锁（并行竞态） | saveStore 原子写（tmp+fsync+rename）+ O_EXCL lockfile 互斥（写命令取锁，只读免锁）+ maybeStaleLock 双判据陈旧锁修复 |

## 2. 产出（改了哪些文件）

### 修改（10 文件）
- `skills/task-planner/SKILL.md`（Item 1+2+3：bun→node strip / plan-created.cjs 相对化 / I/O 机器指针）
- `skills/task-planner/install.sh`（Item 1：bun run→node strip + command -v bun→node）
- `skills/task-planner/lib/install-stub.sh`（Item 1：bun→node strip）
- `skills/task-planner/scripts/init-session.sh`（Item 2：补 .zcode/plan-templates 探测）
- `skills/task-planner/scripts/register-hooks-cj.ts`（Item 1：Bun.argv→process.argv + require→import）
- `skills/task-planner/scripts/session-catchup.ts`（Item 1：shebang + Bun.argv→process.argv）
- `skills/task-planner/scripts/sync-ide-folders.ts`（Item 1：shebang）
- `skills/task-planner/scripts/selftest-registry.tsv`（Item 3：登记 selftest-verify-io.sh）
- `skills/task-planner/templates/session-handoff.md`（Item 1：bun→node strip）
- `skills/todo-skill/tools/cli_todo-manager.ts`（Item 4：原子写 + O_EXCL lockfile，+133 行）

### 新增（3 文件）
- `skills/task-planner/scripts/schemas/check-delegation-stats.schema.json`（draft-07）
- `skills/task-planner/scripts/verify_io.sh`（chmod +x）
- `skills/task-planner/scripts/selftest-verify-io.sh`（chmod +x，4 断言）

### 计划文件
- `plans/task-v189-skill-audit-deferred-fix/`（task_plan/progress/verification/findings/delivery-summary）

## 3. 审查详细（验证结果）

### selftest 套件（VC-5 零回归）
| 基线 | 脚本数 | PASS | FAIL |
|------|--------|------|------|
| master（合并前） | 91 | 89 | 2 |
| worktree（合并前） | 92 | 90 | 2 |

**FAIL 清单完全一致**（`selftest-split-pattern-library` + `selftest-tier-b`，pre-existing，非本次引入）。PASS +1 = 新增 `selftest-verify-io.sh` 通过。

### 项4 S76 竞态验证（VC-4）
- 修复前：20 路并行 create 偶发丢 1（~33% 概率 count=19）
- 修复后：**5 轮 20 路并行 create 全部 count=20**（双判据陈旧锁修复消除竞态）
- 只读命令（list/status）免锁验证：lockfile 不创建 ✓
- store.json 原子写非零：333 bytes ✓

### 合并回 master
- `git merge --no-ff wt/task-v189-skill-audit-deferred-fix`（3fa1e02，22 files +1338/-38）
- worktree 清理：`git worktree remove` + `git branch -d`（5516cf0 已删）✓
- 主仓 git status clean ✓

## 4. 风险必须列举

| 风险 | 状态 | 说明 |
|------|------|------|
| 2 pre-existing selftest FAIL | 已知遗留 | `selftest-split-pattern-library`（SP-03 伴飞表路径硬编码 `/.agents/...` 缺 `/home/terry` 前缀）+ `selftest-tier-b`（TB-02 mini 保护区被放行）— master 基线同样 FAIL，非本次引入 |
| register-hooks-cj.ts L98 bug | 未修（out-of-scope） | `process.unlinkSync(tmp)` 应为 `fs.unlinkSync`（Item 1 修复时发现的存量 bug，未在本次范围） |
| install.log 未 revert | 已知遗留 | untracked 运行时产物（git ls-files 确认未跟踪），install 时重新生成，未 revert |

## 5. 下一步建议

1. **push 到远程**（待确认）：合并后未 push，建议 `git push` 同步远程
2. **可选：修 2 pre-existing selftest FAIL**：
   - `selftest-split-pattern-library` SP-03：伴飞表路径硬编码 `/.agents/...`→`/home/terry/.agents/...`（或改用 `$HOME`）
   - `selftest-tier-b` TB-02：mini 保护区放行逻辑需调查（可能 SKILL.md mini 档通道条款需修）
3. **可选：修 register-hooks-cj.ts L98**：`process.unlinkSync`→`fs.unlinkSync`（一行修复）

---
**outcome: COMPLETE**（全部 VC 通过，零回归，合并回 master；已知遗留见 §4）
