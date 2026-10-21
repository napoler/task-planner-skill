# S2-explore · task-planner 主仓 vs 部署位漂移侦察（只读）

- 侦察时间：2026-10-22
- 主仓源：`/mnt/data/dev/task-planner-skill/skills/task-planner`（1792 文件 / 223 目录）
- 方法：`diff -rq`（每站点一次，输出 `head` 限流）、`comm` 文件清单对比、`stat`/`wc -l` 行数字节差、`git show HEAD:<path>` 对照
- 全部只读；本次仅写入本检查点文件，未改任何技能文件、未做任何 git 写操作

---

## ① 部署位清单表

枚举命令：`ls -d /home/terry/.*/skills/task-planner` + `find /home/terry -maxdepth 3 -type d -name task-planner`

| # | 绝对路径 | 存在性 | 文件数 | 目录数 | 宿主 | 会话态残留 | 临时文件(*.bak/*.orig/*.tmp/*~/*.rej) | mtime 分布（排除 .backup/.drift-rhythm/.zcode） |
|---|---------|--------|--------|--------|------|-----------|------|--------|
| 1 | `/home/terry/.zcode/skills/task-planner/` | ✅ 存在（ZCode 实际加载位） | 1794 | 224 | ZCode | `.drift-rhythm/` 4 文件（2 会话 state × 2 层嵌套）+ `.backup/`（1556 文件 / 43 目录 / 23M）+ `.zcode/workflow-drafts/task-planner-技能审查.dwf.ts`（11820B） | 无 | 最新：10-19(37)/10-20(14)/10-21(1)/10-22(1)；最老 10-06 |
| 2 | `/home/terry/.claude/skills/task-planner/` | ✅ 存在 | 1791 | 223 | Claude Code | 同上：`.drift-rhythm/` 4 + `.backup/` 1556 文件/23M + `.zcode/workflow-drafts/`（11820B） | 无 | 最新 10-18(5)；最老 10-01；10-12~10-17 为主峰 |
| 3 | `/home/terry/.cursor/skills/task-planner/` | ✅ 存在 | 1790 | 223 | Cursor | 同上：`.drift-rhythm/` 4 + `.backup/` 1556 文件/23M + `.zcode/workflow-drafts/`（11820B） | 无 | 最新 10-22(1, selftest-dispatch-grain.sh)；10-16(58)/10-17(2)/10-18(5) |
| 4 | `/home/terry/.opencode/skills/task-planner/` | ✅ 存在 | 1791 | 223 | OpenCode | 同上：`.drift-rhythm/` 4 + `.backup/` 1556 文件/23M + `.zcode/workflow-drafts/`（11820B） | 无 | 最新 10-17(35)；最老 09-30；**全站最旧** |
| 5 | `/home/terry/.agents/skills/task-planner/` | ❌ 不存在（`ls` 报 No such file or directory） | – | – | – | – | – | – |
| 6 | `/home/terry/skill-deploy-backups-20261005/skills-pre-v137b/task-planner/` | ✅ 存在（历史归档，非加载位） | 189 | – | 备份 | – | – | 2026-10-05 前后；SKILL.md 478 行 |

补充：`/home/terry/.agent/`、`/.hermes/`、`/.iflow/`、`/.openclaw/`、`/.qwen/` 下均无 `task-planner`。
`/home/terry/skill-deploy-backups-20261005/` 另有 `task-planner-pre-v137-cursor`、`task-planner-pre-v137-zcode` 两个快照目录。

**会话态残留判定**：4 个部署位 **均未发现** `.plan-attestation` / `.session-owner` / `.active_plan` / `.plan_required_side` / `plans` 目录（`find -maxdepth 4` 排除 `.backup` 后 0 命中）。
但 `.drift-rhythm/` 目录确实携带 2 个会话 state 文件（`sessdwfdwfrun376c72bd...state`、`sessdwfdwfrun6b3716ca...state`），且 4 个站点各自**多出一层嵌套** `.drift-rhythm/.drift-rhythm/`（部署脚本重复展开导致）。主仓源 `.drift-rhythm/` 只有 2 文件、无嵌套层。

---

## ② 逐部署位 vs 主仓漂移表

命令：`diff -rq /mnt/data/dev/task-planner-skill/skills/task-planner <部署位>`

| 部署位 | diff 总行 | differ | only-in | 仅源侧存在（SRC-ONLY） | 仅部署侧存在 | 落后判定 | 证据锚 |
|--------|----------|--------|---------|------------------------|------------|---------|--------|
| `.zcode` | 7 | **6** | 1 | 无（文件集完全一致，1792 全在） | `.drift-rhythm/.drift-rhythm/*.state`（2） | **轻度落后（≈19 提交 / 1 天）** | SKILL.md 265 行/39352B vs src 266 行/39875B；`diff` 命中 30 行差异，实为 **Rules 1-92 vs 1-93**（部署位缺 Rule 93 规范召回）。critical-rules.md 193 行 vs src 203 行、vs HEAD 差 2 行（缺 Rule 93）。task_plan.md 缺 1 行「规范召回（Rule 93）」 |
| `.claude` | 54 | **50** | 4 | `scripts/schemas/`（含 check-delegation-stats.schema.json）、`scripts/selftest-verify-io.sh`、`scripts/verify_io.sh` | `.drift-rhythm/.drift-rhythm/*.state`（2） | **严重落后（≈49 提交 / 4 天）** | SKILL.md 237 行/34927B vs src 266 行/39875B（-29 行/-4948B）；部署位 SKILL.md 内容等于 commit `3004687`(2026-10-18 01:43)，落后 HEAD 49 提交。运行时仍为 `bun scripts/session-catchup.ts`（src 已改 `node --experimental-strip-types`） |
| `.cursor` | 76 | **71** | 5 | `scripts/schemas/`、`scripts/selftest-gate-injection.sh`、`scripts/selftest-verify-io.sh`、`scripts/verify_io.sh` | `.drift-rhythm/.drift-rhythm/*.state`（2） | **最严重落后（≈59 提交 / 5 天）** | SKILL.md 237 行/34927B；部署位 SKILL.md == commit `9c560d2`(2026-10-17 16:33)，落后 HEAD 59 提交。**config.json 486 行/23985B vs src 546 行/28659B（-60 行/-4674B）**：缺 `vc_nonvacuous_enforce` / `rvc_coverage_enforce` / `step_placeholder_enforce` 等档位键。scripts/selftest-requirement-coverage.sh 与 HEAD 差 14 行 |
| `.opencode` | 57 | **53** | 4 | `scripts/schemas/`、`scripts/selftest-verify-io.sh`、`scripts/verify_io.sh` | `.drift-rhythm/.drift-rhythm/*.state`（2） | **严重落后（≈50 提交 / 4 天）** | SKILL.md 237 行/34808B vs src 266 行/39875B；部署位 SKILL.md == commit `9c560d2`(2026-10-17)，落后 HEAD 59 提交。critical-rules.md 193 行（vs src 203）。配置层另有 `companion/agents/plan-writer.md` 差异 |

### 差异样例（各站代表性差异文件，≤10）

| 文件 | src | .zcode | .claude | .cursor | .opencode |
|------|-----|--------|--------|--------|-----------|
| SKILL.md | 266 行 / 39875B | 265 / 39352 | 237 / 34927 | 237 / 34927 | 237 / 34808 |
| references/critical-rules.md | 203 / 50541 | 193 / 46562 | 193 / 46573 | 191 / 45088 | 193 / 46573 |
| templates/task_plan.md | 556 / 35071 | 555 / 34877 | 555 / 35024 | 555 / 35024 | 555 / 35059 |
| scripts/selftest-requirement-coverage.sh | 590 / 44239 | 538 / 39876 | 538 / 39876 | 538 / 39399 | 538 / 39876 |
| config.json | 546 / 28659 | 546 / 28659（= src） | 546 / 28659（= src） | **486 / 23985** | 546 / 28659（= src） |
| docs/ARCHITECTURE.md | 306 / 24636 | 305 / 24269 | 304 / 22563 | 304 / 22563 | 304 / 22563 |
| README.md | 299 / 23015 | 299 / 22860 | 299 / 22678 | 299 / 22678 | 299 / 22678 |
| references/worktree-isolation.md | 124 / 8791 | 124 / 8791（= src） | 124 / 8801 | 124 / 8801 | 124 / 8801 |
| install.sh / install.log / INSTALL.md / lib/install-stub.sh / MIGRATION.md / scripts/sync-ide-folders.ts | src 唯一尺寸 | **与 src 字节全等** | 均与 src 差 93B/1140B/170B/24B/200B/75B | 同 .claude | 同 .claude |

**关键内容级漂移（不是行数差，而是语义差）**：
1. **Rule 93 缺失**：src `SKILL.md` 含「3g 规范召回（Rule 93）」2 处、`templates/task_plan.md` 含 `execution-recall-card` 1 处；**4 个部署位全部 0 命中**（`.zcode` 是当前 ZCode 加载位 → 现行会话拿不到 Rule 93 规范召回机制）。
2. **Rule 51.9–51.13 缺失**：src `critical-rules.md` 含 `51.9 ` / `51.12 ` 各 1 命中；4 部署位全 0。该 5 子条来自事故判例（videop1 beka-trailer 0 母图即 COMPLETE），当前只在主仓工作区未提交。
3. **运行时 bun→node 迁移未落地**：src 与 `.zcode` 用 `node --experimental-strip-types`；`.claude`/`.cursor`/`.opencode` 仍写 `bun scripts/session-catchup.ts`（bun-refs=1，node-strip-refs=0），且其 `install.sh` 仍执行 `bun run register-hooks-cj.ts`——若宿主无 bun，hook 注册会被跳过。
4. **`scripts/verify_io.sh` / `selftest-verify-io.sh` / `scripts/schemas/check-delegation-stats.schema.json`** 三个文件（提交 `5516cf0`）**只存在于 .zcode**，另 3 站全无。
5. **`scripts/selftest-gate-injection.sh`**（提交 `e1ec737`）存在于 src/.claude/.opencode/.zcode，**唯 .cursor 缺失**。

---

## ③ 主仓 git 状态摘要

`git -C /mnt/data/dev/task-planner-skill status --short | head -40`：

```
 M plans/.rule-reservations.jsonl
 M skills/task-planner/SKILL.md
 M skills/task-planner/references/critical-rules.md
 M skills/task-planner/scripts/selftest-requirement-coverage.sh
?? .video_agent/
?? .zcode/plans/plan-sess_3bf065d7-261b-47ab-893d-4d545d1f9594.md
?? plans/archive/.drift-rhythm/
?? plans/s77-p2-fix/
?? plans/skill-audit-s77-20261019/
?? plans/skill-audit-s77-fix-20261019/
?? plans/task-defect-rrv13-dg12-false-pass/ledger-delegation.jsonl
?? plans/task-skill-audit-20261021/
?? plans/task-v193-skill-goal-drift-fix/
```

`git log --oneline -5`：

```
2448e01 bookkeeping(ep3-rollback-guard): EP3 误退投诉闭环计划档案归档入库 + INDEX 刷新（AGENTS 25d 判例）
42bfdb8 bookkeeping(v194): [judge] 留痕行（Rule 73.4）
5f1c932 bookkeeping(v194): Phase 5 R 锚定行位置修正（段首在案）
496aa40 bookkeeping(v194): G2 翻格 + 五 Phase 段 R 锚定复诵行（v168 两锚点）
b68f21c bookkeeping(v194): goal 单元 G1/G2/G4/G5 证据行补齐（Rule 66.3）
```

**未提交在途变更（3 个技能文件，已 READ 复核，未修改）**：

| 文件 | 变更 | 性质 | 是否已部署 |
|------|------|------|-----------|
| `skills/task-planner/SKILL.md` | +1/-1（Rule 51 bullet 增补「可计数交付物全 R 化 + 禁 0 产出为 covered 判据 + 留口逐字让步锚（51.9-51.12）」） | 在途 | ❌ 4 站全无 |
| `skills/task-planner/references/critical-rules.md` | +10/-0（新增 51.9 / 51.10 / 51.11 / 51.12 / 51.13 五子条 + 判例锚 videop1 beka-trailer） | 在途 | ❌ 4 站全无 |
| `skills/task-planner/scripts/selftest-requirement-coverage.sh` | +60 行（RC-01 断言由「51.1-51.8 八子条」改「51.1-51.13 十三子条」；新增 RC-24 行锚+语义锚断言） | 在途 | ❌ 4 站全无 |

`plans/.rule-reservations.jsonl` 亦为未提交修改（计划台账，非技能文件）。
HEAD = `2448e01`（2026-10-21 21:27:54 +0800）。

**提交历史锚**（用于定位各部署位版本）：
- `419dfb3` 2026-10-21 10:16 — Rule 93 规范召回机制 Phase 2（SKILL.md 3g 接线 + 纪元计数 1-93 + task_plan 召回行）
- `19e66fe` 2026-10-21 11:27 — 合并冲突补全（master 侧执行循环 4 行）
- `0c9a408` 2026-10-21 10:04 — s77-exec Phase 执行循环 + 内联 [M]/[A]
- `5516cf0` — skill-fix 审计四项 deferred（verify_io.sh / selftest-verify-io.sh / schemas 引入）
- `e1ec737` — selftest-gate-injection 11 断言 + registry 91 行

**部署位版本回溯**（`git log` 逐提交比对部署位 SKILL.md 找出内容完全匹配的提交）：
- `.zcode` → `0c9a408`（2026-10-21 10:04），落后 HEAD **19 提交**
- `.claude` → `3004687`（2026-10-18 01:43），落后 HEAD **49 提交**
- `.cursor` → `9c560d2`（2026-10-17 16:33），落后 HEAD **59 提交**
- `.opencode` → `9c560d2`（2026-10-17 16:33），落后 HEAD **59 提交**
（部署位 mtime 与提交时间自洽：`.zcode/SKILL.md` mtime = 2026-10-21 10:05:18，紧随 `0c9a408` 10:04:22 之后 1 分钟。）

---

## ④ 3 条最值得深挖的漂移观察

### 观察 1：现行 ZCode 加载位（`.zcode`）缺 Rule 93 规范召回机制——当前会话正受影响的漂移

- **证据锚 A**：`diff /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md /home/terry/.zcode/skills/task-planner/SKILL.md | grep -c '^[<>]'` = 30 行差异；其中 5 处为 `Rules 1-92` vs `1-93`、`其余 73 条` vs `74 条`、卫星 Rule 列表缺 `93`。
- **证据锚 B**：`grep -c '规范召回' src/SKILL.md` = 2；`.zcode` = 0。`grep -c 'execution-recall-card' src/templates/task_plan.md` = 1；`.zcode` = 0。
- **证据锚 C**：引入该机制的是 commit `419dfb3`（2026-10-21 10:16），而 `.zcode` 部署位停在 `0c9a408`（10:04）——**部署动作比功能提交早 12 分钟，之后未再同步**，落后 19 提交。
- **深挖方向**：`.zcode` 是唯一文件集完整（1792/1792）的部署位，也是当前唯一带 `verify_io.sh` 的位，说明它是「最近一次同步」的目标；但同步时点早于 `419dfb3`，此后主仓连续 3 个功能性提交（`419dfb3`/`19e66fe`/`0c9a408` 之后）未回流。

### 观察 2：`.cursor` 是唯一「配置层残缺」的部署位——档位键丢失，机器门会静默降级

- **证据锚 A**：`config.json` 部署位 486 行 / 23985B vs src 546 行 / 28659B；`diff` 命中 60 行差异，开头即删除块含 `vc_nonvacuous_enforce` / `rvc_coverage_enforce` / `step_placeholder_enforce` 三个档位键及其 description。
- **证据锚 B**：`.cursor` 独缺 `scripts/selftest-gate-injection.sh`（src/.claude/.opencode/.zcode 均有）；`.cursor` SKILL.md 停在 `9c560d2`（2026-10-17），落后 HEAD 59 提交。
- **证据锚 C**：`.cursor` 的 `scripts/selftest-requirement-coverage.sh` 与 HEAD 差 14 行（另 3 站与 HEAD **相同**），说明 `.cursor` 的停滞点比 `.claude`/`.opencode` 更早——尽管其 `scripts/selftest-dispatch-grain.sh` mtime 为 2026-10-22 00:42（最新），即**部分文件被单独更新过，整体版本却仍停留在 10-17**。
- **深挖方向**：非原子性局部更新导致「同站内文件版本混杂」——这是漂移审计中比整体落后更难发现的一类；需确认是人工 cp 还是 sync-ide-folders.ts 部分执行。

### 观察 3：未提交在途变更（Rule 51.9–51.13）尚未进入任何部署位，且部署位 `.backup/` 残留 4×23M 会话态副本

- **证据锚 A**：`git status --short` 显示 3 个技能文件为 ` M`（未提交）：`SKILL.md`(+1/-1)、`critical-rules.md`(+10/-0)、`selftest-requirement-coverage.sh`(+60)。`grep -c '51\.9 ' src/references/critical-rules.md` = 1，4 部署位全部 = 0。
- **证据锚 B**：`grep -c '51\.12 '` 同样 src=1 / 部署位=0。随附的 RC-24 静态断言（`^51\.9 ` 行锚 + 「可计数交付物」/「非数字锚」语义锚 + 事故判例锚）也仅存在于主仓工作区。
- **证据锚 C**：4 个部署位**各自**持有 `.backup/claude-stub-20261012-235503/{claude-code,zcode,opencode,cursor}/` 四份快照，合计 **4 × 1556 文件 / 4 × 23M**（`du -sh` 实测），快照内 SKILL.md 为 561 行（vs 现行 src 266 行，形态完全不同——疑似旧版大文件结构）；同时 4 站 `.drift-rhythm/` 各多出一层嵌套 `.drift-rhythm/.drift-rhythm/`（主仓源无此嵌套层），证明部署脚本对会话态目录的复制是**递归复制自复制**，会随部署次数放大。
- **深挖方向**：① 51.9–51.13 是事故判例驱动的规则文本，在途未提交状态下若发生部署，会造成「部署位规则数（1-92/1-93）与主仓实际可执行条款集不一致」的错位；② `.backup/` 是 4 份各 23M 的同一快照冗余复制，且递归嵌套 `.drift-rhythm` 表明 `sync-ide-folders.ts` / `install.sh` 的排除清单未覆盖 `.drift-rhythm` 与 `.backup`。

---

## 附：证据命令清单（可复跑）

```bash
ls -d /home/terry/.*/skills/task-planner
find /home/terry -maxdepth 3 -type d -name task-planner
diff -rq /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.zcode/skills/task-planner | head -100
comm -23 <(cd SRC && find . -type f | sort) <(cd DEPLOY && find . -type f | sort)
wc -l < F ; stat -c%s F
git -C /mnt/data/dev/task-planner-skill show HEAD:skills/task-planner/<F> | diff - <DEPLOY>/<F>
git -C /mnt/data/dev/task-planner-skill status --short | head -40
git -C /mnt/data/dev/task-planner-skill log --oneline -5
find DEPLOY -path DEPLOY/.backup -prune -o \( -name '.plan-attestation*' -o -name '.session-owner*' -o -name '.active_plan*' -o -name '.plan_required_side*' \) -print
du -sh DEPLOY/.backup
```
