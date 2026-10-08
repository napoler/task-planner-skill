# S4 部署位对账检查点 — task-v149（只读审计）

- 执行体：general-purpose（S4 部署位对账员）
- 时间：2026-10-08（审计会话）
- 仓侧基准：/mnt/data/dev/task-planner-skill @ master 21f7e6b
- 权限约束：只读；本文件为唯一写入。全部结论附命令证据。
- 状态：DONE

## 0. 部署拓扑事实（install.sh / INSTALL.md / detect-tools.sh / v148 交付文档）

**install.sh 无 `--target`/`--dest` 参数**。其参数集（install.sh:32-45）= `--canonical <path>`（改 canonical 源，非部署目标）、`--tools <csv>`、`--no-verify`、`--no-backup`、`--dry-run`。
部署目标由 `lib/detect-tools.sh:17-26` TOOL_PROBES 决定（5 工具候选）：

| 工具 | 部署目标位（stub_dir） | 探测路径 |
|------|----------------------|---------|
| claude-code | `~/.claude/skills/task-planner` | `~/.claude` |
| zcode | `~/.zcode/skills/task-planner` | `~/.zcode` |
| opencode | `~/.config/opencode/skills/task-planner`（物理路径；`~/.opencode` 为 symlink） | `~/.config/opencode` |
| cursor | `~/.cursor/skills/task-planner` | `~/.cursor` |
| continue | `~/.continue/skills/task-planner` | `~/.continue` |

`lib/install-companion.sh:9,33` 另有 `--target <tool-root>`（默认自动探测 `~/.zcode` → `~/.claude`），用于伴随 agents/外围 skill 分发。
INSTALL.md:34 承诺：安装源**全量副本**同步到 `~/.zcode`、`~/.claude`、`~/.config/opencode`、cursor 位；INSTALL.md:31 探测清单含 `~/.cursor/`、`~/.continue/`。

**v148「三部署位」原文（delivery-summary.md:20 / verification.md:24）**：`~/.zcode/skills/task-planner`、`~/.claude/skills/task-planner`、`~/.config/opencode/skills/task-planner`——三位 8 文件 diff -q 全 IDENTICAL。cursor/continue 位不在 v148 对账范围。

**实盘（本审计 ls 验证）**：
- `~/.zcode/skills/task-planner`：存在，全量副本（含 lib/tests/docs/install.sh，非 install-stub.sh 产物形态），mtime 10-08 20:28
- `~/.claude/skills/task-planner`：存在，mtime 10-08 20:28
- `~/.config/opencode/skills/task-planner`：存在，mtime 10-08 20:28
- `~/.cursor/skills/task-planner`：**存在但陈旧**，mtime 10-05 20:27
- `~/.cursor/skills/planning-with-files`：**不存在**（v146 曾以该名称为 cursor 位）
- `~/.continue`：**不存在**（未部署）

## 1. zcode 位 diff 对账 — IDENTICAL（v148 声称成立）

命令：`diff -rq /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.zcode/skills/task-planner --exclude=.backup --exclude=__pycache__`
输出：**空**，`exit=0` → 零差异，IDENTICAL。
说明：仓侧已推进到 master 21f7e6b（v148 交付在 5200380/18b281d 之后又有 v147 合并 e18045d、605541a 等），而部署位 mtime=20:28（晚于仓侧 SKILL.md 20:26）→ 部署位在 v148 之后被重新全量同步，故当前与 HEAD 一致，非 v148 快照。

## 2. claude 位 / opencode 位 diff — IDENTICAL

- `diff -rq repo ~/.claude/skills/task-planner` → 空，exit=0
- `diff -rq repo ~/.config/opencode/skills/task-planner` → 空，exit=0
（与 v148 三位 IDENTICAL 一致，且已跟进到 HEAD）

## 发现

## 1. cursor 位陈旧且分叉（第 4 候选位在役但落后一个多代）
**H**（若 cursor 为活跃宿主则为行为分叉；如未使用则降级为 M）
证据：
- `diff -rq repo ~/.cursor/skills/task-planner` → 77 行差异（55 differ + 22 Only-in），exit=1
- 缺失 v146/v147/v148 全部产物：`companion/agents/drift-checker.md`（Only in repo）、`scripts/selftest-drift-check-subagent.sh`、`selftest-drift-enforcement.sh`、`selftest-research-first.sh`、`references/capability-registry.md`、`scripts/capabilities/`、`periodic-review.sh` 等（均 Only in repo）
- 内容分叉实例（diff 首行）：`critical-rules.md:40` 仓侧=`派发 drift-checker 子代理偏移检查（Rule 61 载体）` vs cursor位=`Skill("task-drift-guard")`；`SKILL.md:9` 仓侧 `Critical Rules 全集 1-64` vs cursor位 `1-53`；`scripts/ledger-append.sh:9` 仓侧枚举含 `drift_check` vs cursor位不含
- 陈旧基准：cursor位 SKILL.md 89242B@10-05 20:27 vs 仓侧 102115B@10-08 20:26；config.json 缺 `periodic_review_enforce` 键
建议处置：确认 cursor 是否为活跃宿主——是则按 detect-tools.sh 口径全量重同步 `~/.cursor/skills/task-planner`（并重注册 hooks）；否则在 v149 findings 显式登记「cursor 位弃用」并考虑 uninstall/移除，消除分叉面。

## 2. 备份污染复发——`.backup-*` 落回 cursor 技能扫描路径内
**H**（v146 已判例的 13 处移出后复发）
证据：
- `find ~/.cursor/skills ... \( -name "*.backup*" -o -name ".backup*" \)` → 命中 6 个：
  `~/.cursor/skills/task-planner/companion/.backup-20260930-105447`、`-105448`、`.backup-20261001-071943`、`-071945`、`.backup-20261004-072724`、`-072729`
- zcode/claude/opencode 位扫描路径内**无** .backup（find 无命中；`~/.zcode/skills/task-planner/.backup` 不存在）
- `~/skill-deploy-backups-*` 共 12 个目录均在 `/home/terry/` 下（扫描路径外，合规）
根因：`lib/install-companion.sh:63` `BACKUP_DIR="$COMPAANION_DIR/.backup-$(date...)"`，`COMPAANION_DIR=${TASK_PLANNER_ROOT:-$SKILL_ROOT}/companion`。当以 TASK_PLANNER_ROOT 指向某部署位运行时，备份落进该部署位自身的 `companion/.backup-*`（即技能扫描路径内）。cursor 位 6 个时间戳（09-30/10-01/10-04）与该脚本对该位的历次运行吻合。
建议处置：备份根移出扫描路径（如统一 `~/skill-deploy-backups-*`）；清理 cursor 位现存 6 个 `.backup-*`；为 install-companion.sh 增加「备份路径必须在技能扫描根之外」的守卫/自检。

## 3. DCS-20 部署债确认仍存在，且 v148 指向对象有误
**M**
证据：
- `bash repo/.../selftest-drift-check-subagent.sh` → `Total: 20 PASS=20 FAIL=0`
- `bash ~/.zcode/skills/task-planner/scripts/selftest-drift-check-subagent.sh` → `DCS-20 FAIL 全 skills/ 树存在 Skill("task-drift-guard") 残留`，`Total: 20 PASS=19 FAIL=1`
- 实际命中串位置（`grep -rn 'Skill("task-drift-guard")' ~/.zcode/skills/`，排除 selftest 自身）：4 处
  `~/.zcode/skills/skill-fix/SKILL.md:1398`、`~/.zcode/skills/skill-fix/references/self-correction-during-execution.md:82`、`~/.zcode/skills/references/cost-control.md:13`、`~/.zcode/skills/references/cost_log.md:18`
- **v148 指向的 `~/.zcode/skills/task-drift-guard/` 无该串**：`diff -rq repo/skills/task-drift-guard ~/.zcode/skills/task-drift-guard` → 空 exit=0（IDENTICAL）
- 各部署位命中数：claude 位=2（`skill-fix/SKILL.md:1369` + `self-correction-during-execution.md:82`）、opencode 位=2（`plan-cost-guard/references/cost_log.md:18` + `cost-control.md:13`）、cursor 位=32（陈旧树）
- DCS-20 扫描根 `SKILLS_ROOT="$(cd "$SKILL_ROOT/.." && pwd)"`（selftest:19）= 部署位的 `skills/` 全树。仓内 `skills/` 仅本技能族 → 0；部署位 `skills/` 含无关 skill（skill-fix / plan-cost-guard / references），它们合法引用旧载体串 → 部署位必然 FAIL。
结论：DCS-20 是**仓域负断言**，在部署位运行属环境敏感伪失败；v148 把它记为「task-drift-guard 版本差部署债」是**归因错误**。
建议处置：清偿动作应为①修正 DCS-20 扫描根（限定 task-planner 技能族或排除无关 skill）或②在部署位运行场景显式豁免，而非去同步 task-drift-guard；同步更新 v148/v149 findings 的归因。

## 4. v146「cursor 位缺失」部分消解 + 命名口径分歧
**M**
证据：
- v146 delivery-summary.md:28「cursor 部署位不存在（`~/.cursor/skills/planning-with-files` 缺失）」
- `ls -ld ~/.cursor/skills/planning-with-files` → No such file or directory（**该名位仍缺失**）
- 但 install.sh/detect-tools.sh 定义的 cursor 位 = `~/.cursor/skills/task-planner`，**该位存在**（10-05 20:27，见发现 1）
- INSTALL.md:34 承诺 cursor 位随检测安装；INSTALL.md:31 探测 `~/.cursor/`；install-stub.sh:274 注释「四位宿主位 …~/.cursor 的 skills/task-planner/」
结论：v146 用的 `planning-with-files` 与安装脚本口径（`task-planner`）不一致——历史「cursor 位缺失」是按错误名核查。按安装脚本口径 cursor 位**存在但陈旧**（发现 1）。
建议处置：v149 统一「cursor 位」定义 = `~/.cursor/skills/task-planner`；澄清 planning-with-files 是否为独立技能（非本技能部署位）。

## 5. install-companion.sh 备份路径拼装不一致（潜在静默丢结构）
**L**
证据：`lib/install-companion.sh:118` `mkdir -p "$BACKUP_DIR/$(dirname "${dst#$TARGET_ROOT/}")"` 建的是带子目录的结构；`:119` `cp "$dst" "$BACKUP_DIR/$(basename "$dst")"` 却拍平写入 `$BACKUP_DIR/` 根 → mkdir 出的子目录为空，备份被扁平化（agents 与 skills 同名文件会互相覆盖）。
建议处置：`:119` 改为 `"$BACKUP_DIR/${dst#$TARGET_ROOT/}"`（与 mkdir 对齐）。

## 6. 「三部署位」口径 vs 实盘（文档/对账口径缺口）
**L**
证据：v148 仅对账 3 位；detect-tools.sh 有 5 候选（多 cursor、continue）；实盘 cursor 位在役但未纳入对账（发现 1）、continue 位不存在。
建议处置：v149 明确在役位清单（zcode/claude/opencode 三主位 + cursor 位状态），并在部署对账脚本/文档固定「在役位集合」以免再次漏位。

## 未验证项
- cursor 位是否被 cursor 宿主实际加载（无运行时探针，仅静态存在性核查）——「在役」判定需用户确认。
- 各部署位 hooks 是否已在宿主 config 注册（本次仅比对脚本文件内容，未读 `~/.zcode/cli/config.json` / `~/.claude/settings.local.json` 注册项）。
- `~/skill-deploy-backups-*` 12 目录的内容与归属（仅确认位置在扫描路径外）。
