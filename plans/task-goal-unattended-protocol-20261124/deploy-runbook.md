# 部署操作手册（S13）— task-goal-unattended-protocol-20261124

> 执行体（general-ops）的唯一施工依据。分两阶段：**阶段 A 只备份与预演，不写运行位**；主进程复核预演结果后，才下发阶段 B。
> 原则（用户裁决的护栏）：逐位 diff 判向、禁整文件覆盖、部署前备份、部署后 verify 对账。

## 固定量

- `REPO=/mnt/data/dev/task-planner-skill`
- `BASE=9e42c0b`（改动前的 master 提交）
- `BK=$REPO/tmp/deploy-backups/task-goal-unattended-protocol-20261124`
- `SITES="/home/terry/.zcode /home/terry/.agents /home/terry/.claude /home/terry/.config/opencode /home/terry/.cursor"`
- `FILES`（9 个，相对各根）：
  1. `skills/task-discipline/references/critical-rules-discipline.md`
  2. `skills/task-planner/SKILL.md`
  3. `skills/task-planner/references/critical-rules.md`
  4. `skills/verification-gate/references/critical-rules-verification.md`
  5. `skills/verification-gate/SKILL.md`
  6. `skills/task-dispatch/references/critical-rules-dispatch.md`
  7. `skills/task-dispatch/references/agent-coverage.md`
  8. `skills/task-planner/scripts/selftest-decision-arbiter.sh`
  9. `skills/plan-template-kit/references/template-mapping.md`
- **不在部署范围**：`skills/task-planner/companion/agents/decision-arbiter.md`（agent 定义。仅 `~/.zcode/agents/decision-arbiter.md` 已是目标配置；其余四个运行位的同名定义副本仍是旧配置，须用户显式授权才可改，由主进程在交付中报告）；仓库根 `AGENTS.md`（非部署物）。

## 为什么用逐文件补丁

改前实测（`plans/task-goal-unattended-protocol-20261124/pre-deploy-site-state.log`）：`~/.zcode` 位 6/6 与源一致；其余各位存在其他任务留下的既有差异（agents 的 SKILL.md 差 5 行；claude 的 discipline 差 4 行、SKILL.md 差 5 行；opencode 5 个文件各差 1-10 行；cursor 的 discipline 差 4 行、SKILL.md 差 10 行）。整文件覆盖会抹掉这些内容；逐文件 `patch` 只落本次增量。

## 第 7-9 三个文件为何入列（2026-11-24 修订，计划 decisions D-16、D-17）

- 三者都是 decision-arbiter 配置对齐（用户裁决③）时随动的引用面与断言面，属 `skills/` 内容，落在 goal 模式部署预授权范围内。不同步的后果：运行位覆盖表与模板映射表仍写旧版本号，运行位自测脚本仍钉旧值，与源码互相矛盾。
- 改前实测（2026-11-24）：这三个文件在 5 个运行位相对 `BASE` 的差异行数均为 0，补丁可干净落位。

## 阶段 A（只读 + 备份 + 预演；禁止写运行位）

- A1 建目录：`mkdir -p "$BK/patches" "$BK/pre"`
- A2 生成补丁（每个文件一份）：`git -C "$REPO" diff --no-color "$BASE" HEAD -- "$f" > "$BK/patches/<f>.patch"`，其中 `<f>` = 文件相对路径把 `/` 换成 `_`。
- A3 备份（每个 site × file）：`mkdir -p "$BK/pre/<site>/<dirname>" && cp -p "<site>/<f>" "$BK/pre/<site>/<f>"`（`<site>` = site 路径把 `/` 换成 `_`）。
- A4 改前差异（每个 site × file）：`git -C "$REPO" show "$BASE:<f>" | diff - "<site>/<f>" | grep -c '^[<>]'`，记入 `$BK/pre-diff.txt`（每行：`<count> <site>/<f>`）。
- A5 预演（每个 site × file）：`patch --dry-run -p1 -d "<site>" -i "$BK/patches/<f>.patch"`，完整输出记入 `$BK/dry-run.txt`，并在 `$BK/dry-run-summary.txt` 逐行汇总：`OK|FAIL <site>/<f>`（patch 退出码 0 记 OK，否则 FAIL；FAIL 行附失败 hunk 编号）。
- A6 报告：`$BK/deploy-report.md` 的「阶段 A」段——45 行明细表（site / file / 改前差异 / 预演结果）+ FAIL 清单。

阶段 A 验收：45 个备份文件齐全且与运行位逐字节一致（`cmp`）；9 份补丁非空；预演汇总 45 行；运行位零写入（`git -C "$REPO" status --short -- skills | head` 与阶段 A 前一致，且 $BK 之外无新文件）。

## 阶段 B（执行；仅在主进程明确下发后）

- B1 只对预演 `OK` 的 site × file 执行：`patch -p1 -d "<site>" -i "$BK/patches/<f>.patch" --no-backup-if-mismatch`；输出记入 `$BK/apply.txt`。预演 `FAIL` 的一律不执行，列入报告待主进程处置。
- B1-特殊（主进程处置，2026-11-24，D-18）：opencode 位的 `skills/task-dispatch/references/critical-rules-dispatch.md` 预演 FAIL（该位是比 BASE 更旧的版本，22.3 行有既有差异），**不得**使用原补丁；改用主进程已生成并预演通过（rc=0）的专用补丁：`patch -p1 -d /home/terry/.config/opencode -i "$BK/patches/site-opencode_critical-rules-dispatch.md.patch" --no-backup-if-mismatch`。该补丁只做本次三处片语替换（3 行增 3 行删），保留该位既有内容；其输出同样记入 `$BK/apply.txt`。除此之外不存在第二个特殊项。
- B2 验证（每个 site × file）：
  - 新锚（按文件分型）：第 1-6 个条款载体 `grep -c '28\.9' "<site>/<f>"`（要求 ≥1）；第 7 个 `grep -c -F 'decision-arbiter(D1, GLM-5.4 强档)'`（要求 =1）；第 8 个 `grep -c -F 'account:zai-individual-coding-plan/GLM-5.4'`（要求 ≥1）且 `bash -n "<site>/<f>"` 通过；第 9 个 `grep -c -F 'decision-arbiter(GLM-5.4)'`（要求 =1）。
  - 改后差异：`git -C "$REPO" show "HEAD:<f>" | diff - "<site>/<f>" | grep -c '^[<>]'`，要求 **等于** A4 的改前差异（本次增量已消、既有差异保留），记入 `$BK/post-diff.txt`
  - 硬校验（每个 site × file；口径 2026-11-24 修订，D-19）：用**整行相等**匹配核对补丁内容是否如实落位——补丁中每个 `+` 行（去掉前导 `+`，跳过空行）必须在运行位文件中整行存在，每个 `-` 行（去掉前导 `-`，跳过空行）必须整行不存在。命令（`<patch>` = 该 site × file 实际使用的补丁；opencode 位 dispatch 文件用专用补丁）：
    `pb=0; mb=0; while IFS= read -r l; do [ -n "$l" ] || continue; grep -q -x -F -- "$l" "<site>/<f>" || pb=$((pb+1)); done < <(grep '^+' "<patch>" | grep -v '^+++' | sed 's/^+//'); while IFS= read -r l; do [ -n "$l" ] || continue; grep -q -x -F -- "$l" "<site>/<f>" && mb=$((mb+1)); done < <(grep '^-' "<patch>" | grep -v '^---' | sed 's/^-//'); echo "$pb $mb"` —— 要求输出 `0 0`。
    （必须 `-x` 整行相等：追加型改动的旧行是新行的前缀，子串匹配会误判。口径自检：对主仓当前源码 9 个文件均为 `0 0`；对未部署的基线版本可判出 `6 6` / `1 1`。）
  - 强校验（仅改前差异为 0 的 site × file）：`git -C "$REPO" show "HEAD:<f>" | cmp -s - "<site>/<f>" && echo SAME` —— 要求输出 `SAME`。
- B3 报告：在 `$BK/deploy-report.md` 追加「阶段 B」段——45 行明细表（site / file / 预演 / 是否执行 / 改前差异 / 改后差异 / 新锚计数 / 硬校验）+ 未执行清单。
- B4 任一项校验不符：立即停止后续项，用 `$BK/pre/` 中对应备份恢复该文件（`cp -p`），在报告中如实列出并返回 REJECTED，不得继续、不得手工修补。

## 阶段 B 续做说明（2026-11-24，主进程下发）

首轮阶段 B 的实际情况：B1 的 45 项补丁全部落位（rc=0）；B2 校验到第 2 项时，因当时手册的硬校验口径有误（要求新条款整行在前 6 个载体都为 1，实际只有 discipline 一个载体含该整行）触发 B4，执行体停止并恢复了 `/home/terry/.zcode/skills/task-planner/SKILL.md`。主进程随后用上面修订后的口径对全部 45 项做了只读复核：44 项达标，仅该 1 项处于未部署状态（与备份逐字节相同）。

续做范围：
- 只对 `/home/terry/.zcode` 位的 `skills/task-planner/SKILL.md` 执行一次 B1（原补丁；阶段 A 预演为 OK），其余 44 项**不得再次打补丁**。
- 然后对全部 45 项执行 B2（按修订后的口径），产出完整的 post-diff.txt 与 45 行明细表。
- 若续做中出现任一项不符，仍按 B4 处置。

## 禁止事项

- 禁止 `cp` 或 `install.sh`、`smart-merge-back.sh --deploy` 整文件/整槽覆盖运行位。
- 禁止改 `~/.zcode/agents/`、`~/.agents/` 下任何 agent 定义；禁止改 `~/.zcode/commands/`。
- 禁止任何 git 写操作（add/commit/merge/push/stash/checkout/reset）。
- 禁止删除或改写 `$BK` 之外的任何文件；禁止派发子代理。
- 任一步报错：停止后续步骤，保留现场，如实报告，不得静默跳过。
