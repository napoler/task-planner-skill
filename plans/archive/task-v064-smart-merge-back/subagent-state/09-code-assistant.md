# 09-code-assistant checkpoint — task-v064 Phase 5 修复轮 4（Code Review Gate R3）

## status: done（全部 14 项 findings 修复完成，验收 5/5 通过）

## 修复落点（均在 worktree /mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back）

### P0 · SMB home 白名单（SMB:325,384-387）
- 废除 "home 类型整体豁免 inside"；新增 `DEFAULT_DEPLOY_ROOTS`（三根冒号分隔）+ `default_roots_norm` 规范化数组
- validate_slot home 分支：norm 位于任一部署根内（或等于）→ 放行；否则 inside 规则 REJECTED
- 显式逃生口 `--allow-home-slot`（默认关，ALLOw_HOME_SLOT 参数解析 + usage/头注释同步）
- SKILL_ROOT/WT_PATH/MAIN_REPO 维持 full 三向

### P2 · EXIT trap（SMB:328）
- 清理体封成 `cleanup_tmpdirs()` 函数（顶层 local 报错消除），trap 体 stderr 零输出
- 同 trap 兜底恢复：`[ -n slotbak ] && [ ! -e slotdir ] && [ -e slotbak ] && mv slotbak slotdir`
- 常规失败路径各 mv 处均置 `slotbak=""` 避免误恢复；`slotdir` 预初始化

### P2 · SM-10 相对推导（ST:259-260/14）
- `git -C "$(dirname "${BASH_SOURCE[0]}")/../.." rev-parse --show-toplevel` 替代硬编码 /mnt/data 任务路径
- 推导失败且 env 未注入 → SM-10 记 SKIP（`SM10_INJECTED=0` → 打印 SKIP 行，不计 PASS/FAIL；Total 口径 = PASS+FAIL+SKIP，FRAMEWORK_BROKEN 自检同步）
- SM-10 md5 基线增加 `[ -f ... ]` 条件（主仓非 worktree 形态下目标脚本可能缺位）

### P2 · V3 两侧口径（SMB:246,260）
- BRANCH_FILES 改 `git -c core.quotePath=false diff --name-only -z "$MB" "$BRANCH" | tr '\0' '\n'`（NUL 解析，原始字节）
- MAIN_DIRTY 同加 `-c core.quotePath=false`；非 ASCII 路径重叠可检出

### P3 · 头注释/注释/默认值
- 头注释替换序列改改名换位措辞（slot→.bak.$$ → tmp→slot → rm .bak）；"slot 永不在盘中缺席" 降级为 "常规失败路径可恢复；进程级中断由 EXIT trap 兜底恢复"
- SLOTS 默认值 `${HOME:-}` 三路赋值；HOME 空 → `[DEPLOY] REJECTED: (HOME 未设置 — 默认部署位不可解析)` + DRIFT=1 + exit 6
  - **过程发现 2 处自产缺陷并实证修复**（修 4c/4d/4e commit）：① HOME 空分支漏赋 SLOTS → set -u 风险+假绿；② 部署循环条件包裹吞 DRIFT；③ DRIFT=0 初始化在循环前重置吞掉分支置位 → 全部实证 rc=0 假绿后修复
- 删除孤立重复注释（R2 P1-2 注释块）；MERGE_HEAD/V4 顶层块缩进归零
- ST SM-08 详情改 `grep -oF 'REJECTED' | wc -l` 真实计数

## 验收证据
1. `bash -n` 两文件通过（SMB-SYNTAX-OK / ST-SYNTAX-OK）
2. selftest 连跑两遍一致：`Total: 12 PASS=12 FAIL=0` EXIT=0，stderr 零输出（差异仅 SM-10 的 commit sha 尾注，非结果差异）
3. P0 三场景实测（HOME=/home/terry 真实环境）：
   - `TASK_PLANNER_DEPLOY_SLOTS=$HOME/.zcode` → `[DEPLOY] REJECTED`（白名单外）+ RC=6，`$HOME/.zcode` md5/目录清单 before=after 零改动
   - `slot=$HOME/.zcode/skills/task-planner` → `[DEPLOY] IDENTICAL` RC=0（放行，真部署到真实 zcode 位，按规格保留）
   - `slot=$HOME/.ssh` → `[DEPLOY] REJECTED` RC=6
   - 附加：`env -u HOME`（HOME 未设 + 无 env 覆盖）→ `[DEPLOY] REJECTED: (HOME 未设置 — 默认部署位不可解析)` RC=6（非 4e 前的 rc=0 假绿）
   - 附加：`--allow-home-slot` + 白名单 slot → RC=0（逃生口生效）
4. `git diff --stat 6bb9bb9..HEAD` 仅 2 文件（selftest-smart-merge.sh +71/-..., smart-merge-back.sh +173/-...；共 180 insertions/64 deletions）
5. 未触碰 Scope 外文件（worktree-isolation.md 退出码措辞复核后无需改动；plans/ 主仓目录只读）

## commit 序列（6bb9bb9 之后，均在 worktree 分支）
d0b2ee1(4) → eb4d027/dae3238(merge) → fa85f68(4b) → 461c5ae/a9dd5da(sync) → f7d7a2e(4d) → 96c866c(merge) → 9e9384f(4e) → cd73e5a/83a10ef(sync master)

## 遗留/风险
- worktree 分支含 2 次 "sync master" merge 提交（为消除 MASTER_AHEAD 以到达 deploy 阶段实证；内容与 master 6bb9bb9 一致，无行为漂移）
- 真实位 $HOME/.zcode/skills/task-planner 已部署 master 内容（spec 允许，测后保留）
- SM-10 SKIP 路径未在 hermetic 环境实证（套内推导恒命中；SKIP 分支逻辑经代码走查：SM10_INJECTED=0 → 打印 SKIP 行 + SKIPPED=1 → Total 行含 SKIP=%d）
