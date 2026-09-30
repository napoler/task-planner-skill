# P2-S1 任务书: smart-merge-back.sh 增 install_pool_links 池挂载函数（task-v105）

任务: worktree 内 `skills/task-planner/scripts/smart-merge-back.sh` 新增 `install_pool_links()` 函数并在部署成功段调用——11 个 review-library 池成员以**相对软链**挂载到宿主顶层 skills/，使宿主 skill 发现面可枚举。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v105-pool-host-enumerable/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v105-pool-host-enumerable/skills/task-planner/scripts/smart-merge-back.sh

## 硬约束
- **零改动面**: deploy_reconcile/validate_slot/原子替换（cp→bak→mv→rm）/exit 语义/DRIFT 判定/既有 echo 行——全部不动;只做「新增函数 + 1 处调用」
- 挂载是部署成功后的**增强段**:LINK-* 输出**不得改变函数返回值与脚本 exit 码**（selftest-smart-merge 断言 exit/DRIFT 语义,不能破）
- **禁止覆盖/删除任何顶层既有条目**（opencode 独立 security-review 必须保留）
- 禁「1-4x」越界字面

## 操作内容
### ① 在 `deploy_reconcile()` 函数定义之后（同层,部署 if 块内）新增函数（逐字使用）:
```bash
    # [task-v105] 池成员顶层枚举挂载: 宿主 skill 发现面=顶层 <skills>/<member>/SKILL.md,
    # 池嵌套在 task-planner/review-library/ 下对宿主不可见 → 每成员建相对软链
    # <parent>/<m> → task-planner/review-library/<m>(单一维护源,池更新自动同步)。
    # 冲突语义: 顶层已有条目→跳过+LINK-WARN(独立 skill 不覆盖);挂载后校验失败→仅回滚本次新建的链。
    # 增强段: 失败不改 exit 码(部署判定已定),LINK-* 仅输出。
    install_pool_links() {
        local slotdir="$1" parent m link tgt
        parent="$(dirname "$slotdir")"
        [ -d "$parent" ] || { echo "[DEPLOY] LINK-SKIP: $slotdir (父目录缺失,跳过池挂载)"; return 0; }
        local members
        members="$(ls -d "$slotdir/review-library/"*/ 2>/dev/null | xargs -n1 basename 2>/dev/null | LC_ALL=C sort)"
        [ -n "$members" ] || { echo "[DEPLOY] LINK-SKIP: $slotdir (池目录缺失/空,跳过挂载)"; return 0; }
        for m in $members; do
            link="$parent/$m"
            tgt="task-planner/review-library/$m"
            if [ -e "$link" ] || [ -L "$link" ]; then
                if [ -L "$link" ] && [ "$(readlink "$link")" = "$tgt" ]; then
                    echo "[DEPLOY] LINK-OK: $link (既有挂载有效)"
                else
                    echo "[DEPLOY] LINK-WARN: $link (顶层已被独立条目占用,不触碰)"
                fi
                continue
            fi
            ln -s "$tgt" "$link" 2>/dev/null || { echo "[DEPLOY] LINK-WARN: $link (ln 失败,跳过)"; continue; }
            if [ -f "$link/SKILL.md" ] && grep -q '^name:' "$link/SKILL.md" 2>/dev/null; then
                echo "[DEPLOY] LINK-OK: $link → $tgt"
            else
                rm -f "$link"
                echo "[DEPLOY] LINK-WARN: $link (挂载后校验失败,已回滚)"
            fi
        done
        return 0
    }
```
### ② 在逐 slot 循环内、`deploy_reconcile` 成功分支追加调用（该处现文为:
```bash
        if deploy_reconcile "$slotdir"; then
            echo "[DEPLOY] IDENTICAL: $slotdir (基准=主仓 skills/task-planner)"
        else
            DRIFT=1
        fi
```
改为（仅加 1 行,其余逐字保留）:
```bash
        if deploy_reconcile "$slotdir"; then
            echo "[DEPLOY] IDENTICAL: $slotdir (基准=主仓 skills/task-planner)"
            install_pool_links "$slotdir"
        else
            DRIFT=1
        fi
```
### ③ 文件头注释区（--deploy 说明附近,如 :15-28 区）追加一行说明:
`#                    --deploy 对账通过后自动执行池成员顶层枚举挂载(install_pool_links): <skills>/<member> 相对软链→task-planner/review-library/<member>;冲突跳过 LINK-WARN;增强段不改 exit 码 [task-v105]`

## acceptance: 验收标准
1) `bash -n scripts/smart-merge-back.sh` 语法过
2) `grep -c 'install_pool_links'`=2（定义+调用）;`grep -c 'LINK-WARN'`≥2;`grep -c 'LINK-OK'`≥1
3) `git diff --numstat` 仅该文件;deploy_reconcile/validate_slot/DRIFT/exit 0 既有行零变化（diff 上下文核对）
4) 行为冒烟（临时目录,不碰真实宿主）: 构造 `T=$(mktemp -d); mkdir -p $T/skills/task-planner/review-library/{alpha,beta}; echo '---\nname: alpha' > $T/skills/task-planner/review-library/alpha/SKILL.md`（SKILL.md 含 name: 行）;source 或直接以 bash -c 方式调用 install_pool_links 不可行（脚本有入口门槛）——改为**静态核对**: 函数体逐行对照本任务书逐字一致
5) `git -C <wt> status --short` 仅该文件 M

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v105-pool-host-enumerable/subagent-state/01-exec-p2s1.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
