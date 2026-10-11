# Checkpoint: P2-S1 smart-merge-back.sh 增 install_pool_links（task-v105）

时间: 2026-10-01 | 执行体: executor | 状态: done

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v105-pool-host-enumerable/skills/task-planner/scripts/smart-merge-back.sh

## 已执行操作（3 处,逐字取用任务书）
1. 头注释 :20 行后（`逐位 [DEPLOY] 判定, 任一 DRIFT exit 6` 行之后）追加 1 行 --deploy 挂载说明 [task-v105]（任务书③逐字）
2. deploy_reconcile 定义收尾（`return 0` + `}`）之后、`IFS=':' read` 之前插入 `install_pool_links()` 函数全文（任务书①逐字,4 空格缩进与部署 if 块内既有函数一致）
3. 逐 slot 循环内 `deploy_reconcile` 成功分支 IDENTICAL echo 之后追加 1 行 `install_pool_links "$slotdir"`（任务书②,仅加 1 行）

## 验证证据（原始输出）
- `bash -n skills/task-planner/scripts/smart-merge-back.sh` → `SYNTAX-OK`
- `grep -c 'install_pool_links'` → `3`（头注释③ + 定义 + 调用）
- `grep -c 'LINK-WARN'` → `5`（≥2 ✓）
- `grep -c 'LINK-OK'` → `2`（≥1 ✓）
- `git diff --numstat` → `35  0  skills/task-planner/scripts/smart-merge-back.sh`（仅该文件,0 删除行）
- `git status --short` → ` M skills/task-planner/scripts/smart-merge-back.sh`（仅此一条）
- 全 diff 逐行核对: 仅 "+" 新增行,无 "-" 删除/改写行 → deploy_reconcile/validate_slot/原子替换(cp→bak→mv→rm)/DRIFT 判定/exit 路径/既有 echo 全部零改动
- 函数体逐行对照任务书①: 一致（LINK-SKIP/LINK-OK/LINK-WARN 语义、冲突跳过、挂载失败仅 rm 本次新建链、函数结尾 return 0、调用处无 DRIFT 逻辑）
- 冒烟按任务书指定静态核对方式执行（脚本有入口门槛,不 source 冒烟,不碰真实宿主）

## 偏差说明（1 处,任务书级）
acceptance 第 2 条预期 `grep -c 'install_pool_links'=2`,实测 =3——因任务书③指定的头注释行本身含该字面量（任务书作者未计入③行）。三处操作均逐字执行,无执行偏差;该数差异需主进程/verifier 确认口径（若以「定义+调用」计则 =2 成立,总行匹配数 =3）。

## 未触碰
未 git commit/add;未改其他文件;未碰主仓与真实宿主部署位。
