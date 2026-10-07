# 检查点 2-code-assistant — Phase2-S1 脚本组B(active-plan 指针写入方 canon 统一 + 兜底两级化)

日期: 2026-10-07
状态: DONE

## 修改摘要(2 文件,均在 worktree /mnt/data/dev/task-planner-skill-worktrees/fix-pointer-race/)

### 1. skills/task-planner/scripts/init-session.sh
- 位置: 原 613-641 行(SIDKEY= 行至首个含 fallback 最新哨兵逻辑的 if 块结束 fi),SIDE_DIR 写指针块与 PLAN_ROOT 推导块均未动
- RC-1: SIDKEY canon 对齐——tr 剥非字母数字后新增 `case sess*` 剥 sess 前缀(与 task-plan-init.cjs normSidkey / resolve-plan-dir.sh / set-active-plan.sh / check-scope.sh 一致)
- RC-2: 兜底两级化——① 新增 `.sidmap` 确定性映射探测(<env_sidkey>.sidmap 首行映射到 hook sidkey,且映射目标哨兵须存在才采用);② 无映射才探测最新哨兵,且仅当 mtime age ≤120s 才抢用;陈旧哨兵(>120s)拒抢 + WARN 提示跑 set-active-plan.sh set <task> --sid
- _sent_sid 同样剥 sess 前缀(canon 一致性)

### 2. skills/task-planner/scripts/zcode-userpromptsubmit.sh
- 位置: 原 179-182 行(认领块 side_dir 起)
- side 指针文件名改用剥前缀的 `_ups_sidkey`(case sess* 剥前缀);.session-owner 读写与 if 条件行保持裸 UPS_SID 口径不动(与 zcode-posttooluse.sh 比对侧自洽)

注释纪律: 既有注释保留(仅按任务规格改写 P10 fallback 注释段,并入 RC-1/RC-2 What+Why);新增注释均为 What+Why 双层。

## 验收输出

### a) bash -n(两文件,均无输出)
```
$ bash -n init-session.sh && bash -n zcode-userpromptsubmit.sh && echo "SYNTAX_OK"
SYNTAX_OK
```

### b) grep -n 'sess\*)' init-session.sh(命中 2 处 ≥2)
```
620:        sess*) SIDKEY="${SIDKEY#sess}" ;;
654:                case "$_sent_sid" in sess*) _sent_sid="${_sent_sid#sess}" ;; esac
```

### c) grep -n 'sidmap' init-session.sh(命中 4 处 ≥3)
```
625:    # [2026-10-07 fix-pointer-race RC-2] 兜底两级化:① .sidmap 确定性映射(SessionStart 写
626:    # <env_sidkey>.sidmap=hook sidkey)优先——消除"最新哨兵=本会话"猜测;② 无映射才探测最新哨兵,
631:        _map="${_sent_dir}/${SIDKEY}.sidmap"
636:                echo "[init] INFO: env sid(${SIDKEY}) 经 sidmap 映射到会话哨兵 sid(${_mapped})"
```

### c-2) grep -n '_ups_sidkey' zcode-userpromptsubmit.sh(命中 3 处 ≥3)
```
183:      _ups_sidkey="$UPS_SID"
184:      case "$_ups_sidkey" in sess*) _ups_sidkey="${_ups_sidkey#sess}" ;; esac
187:      [ -n "$side_tmp" ] && printf '%s\n' "$pid" > "$side_tmp" 2>/dev/null && mv -f "$side_tmp" "$side_dir/${_ups_sidkey}.active_plan" 2>/dev/null || true
```

## 负结果报告(排除了的风险)
- 检查了 init-session.sh 600-660 与 zcode-userpromptsubmit.sh 130-199 区域:SIDE_DIR 写指针块(642-657)、owner 读/写(172-174)、if 条件(173) 均未触碰,无残留裸 UPS_SID 写 side 指针
- 无 git 命令执行;未触碰 2 个授权文件之外的任何路径(本检查点文件为任务显式授权的落盘例外)
- `stat -c %Y` 在 Linux 下可用,age 计算依赖 date +%s,无跨平台风险引入

## 结论
DONE — 验收 a/b/c 全部通过,两文件语法检查通过。
