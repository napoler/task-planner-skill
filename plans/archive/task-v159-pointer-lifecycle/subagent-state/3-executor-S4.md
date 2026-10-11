# 部署单元 checkpoint — F5 staging 原子化（D4 根治）

> 任务: task-v159-pointer-lifecycle / 施工图 design-pointer-fix.md F5 节
> 改动文件: skills/task-planner/scripts/smart-merge-back.sh（唯一）
> 日期: 2026-10-10

## 改动摘要

deploy 段（基线 ~590-640）重构为 F5 staging 原子化三段，替代旧直写路径：

1. **staging**：全部 slot 先行 `cp -rL "$DEPLOY_SRC" <slot>.stage.$$`（同父目录，跨 slot 无依赖）；任一 slot stage 失败 = 整体 `exit 1` 不进入 swap，已 stage 残留由 EXIT trap 清理。
2. **swap**：逐 slot `rm -rf <slot> && mv <slot>.stage.$$ <slot>`（rename(2) 原子切换）；rm 失败 = 原 slot 保留未动；mv 失败 = stage 回原位恢复；任一失败整体 `exit 1`。
3. **post-verify**：每 slot 存在性 + `diff -r <slot> "$DEPLOY_SRC"` 零差异；任一失败 `exit 1` 并输出 slot 缺失/diff 详情，禁止部分 slot 成功当整体成功。

其他改点：
- 参数新增 `--legacy`（DO_LEGACY）：旧直写路径（cp→rm→mv 改名换位 + 两级对账 L1/L2）保留为 fallback，失败语义 exit 6 不变。
- EXIT trap（cleanup_tmpdirs）增强：清理 `.stage.$$` 残留；异常中断（TERM/INT）时若 slotdir 缺席且 stagedir 尚在 → 先 mv 回原位再清理其余残留。
- 头注释/usage/退出码说明同步更新（Rule 45 What+Why 注释：D4 事故根因=2026-10-10 04:45-04:49 claude 写入后 zcode 删除致技能全局停摆）。
- 池成员挂载（install_pool_links）保留于 post-verify 通过后（增强段，失败不改 exit 码）。

## 验收结果（逐项原文）

- `bash -n scripts/smart-merge-back.sh` → exit 0
- grep 关键串：`stage.$$`（:696/:711）、`diff -r`（:749/:751）、`exit 1`（:707/:736/:757）、STAGE-FAIL/SWAP-FAIL/VERIFY-FAIL、DO_LEGACY 全部命中
- 隔离夹具（/tmp 假仓 + 假 slot 父目录 + DEPLOY_SRC 指向小样本目录，零触碰真实部署 slot）：
  - 正常路径：三假 slot 全部落位 + diff -r 全 IDENTICAL + rc=0 + stage 残留 0 + LINK-OK
  - staging 失败（slot2 父目录只读）：rc=1，STAGE-FAIL 输出，三 slot 全保持原位，stage 残留 0（trap 清理）
  - swap 失败（中断注入：watcher 检测 s2 stagedir 后删除，模拟 stage 源丢失）：rc=1，s1/s3 已 swap 一致态（diff IDENTICAL），s2 部分成功被 post-verify VERIFY-FAIL 拦截（diff 差异详情输出原文），stage 残留 0
- 真实 slot 零触碰证明（stat 前后对比）：
  - ~/.zcode/skills/task-planner mtime=1791584325 2026-10-10 06:18:45.063970169 +0800（前=后）
  - ~/.claude/skills/task-planner mtime=1791584326 2026-10-10 06:18:46.437985680 +0800（前=后）
  - ~/.config/opencode/skills/task-planner mtime=1791584327 2026-10-10 06:18:47.827001358 +0800（前=后）
- `git -C <worktree> diff --stat master -- skills/task-planner/scripts/smart-merge-back.sh` → 仅该文件，1 file changed, 173 insertions(+), 57 deletions(-)

## 夹具说明

- 夹具脚本: /tmp/f5-run-fixture.sh（置于 /tmp 根，避免 setup_repo 的 rm -rf "$FIX" 自删）
- 夹具布局贴近生产: slot 直接在 skills 父目录下（parent-sX/task-planner），DEPLOY_SRC=假主仓 skills/task-planner（102 文件样本）
- 场景3 注入说明: watcher 轮询检测 s2.stage.* 出现后删除（中断注入），因与 cp 竞态导致 s2 stagedir 部分残留，swap mv"成功"但内容不全，post-verify diff -r 拦截（VERIFY-FAIL）——完整演示"禁止部分 slot 成功当整体成功"语义
- 环境限制记录: mount --bind 需 superuser、chattr +i 操作不允许，均不可用；swap 失败注入采用 watcher 删除 stagedir 方案

## 净改动行数

230 行变更（173 insertions + 57 deletions），仅 scripts/smart-merge-back.sh 一个文件。
