# S21 C-3 sync-todos --index 单 awk 全量重算 — checkpoint

- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091 (wt/task-v091-efficiency-optimization)
- 基线: 216e912 (进场核对 PASS: HEAD 前缀匹配 + status clean)
- 提案: efficiency-proposal.md C-3 (v3: 删除 mtime 行级选项; :215-233 每 plan ≈8 子进程 → 单 awk 多文件聚合; 输出逐字节一致)
- 关键事实(已核):
  - rollup_task/extract_plan_meta 无 sync-todos.sh 之外消费者(grep rc=1)
  - INDEX.md 消费方: check-conflicts.sh:97(待处理区 ^- \*\* 计数)+:144(表行解析)、zcode-sessionstart.sh(待处理区) → 字节级一致即受保护
  - 主仓 plans/ 37 个 task_plan.md(maxdepth 2); plans/archive/ 存在(深度 3 天然排除)
  - awk = GNU Awk 5.2.1; 现行代码无 mtime 比较优化分支 → v3"删除"落在提案侧, 代码侧行为=保持全量重算, 无需删分支
- 状态: **done** — commit d3a787c(wt/task-v091-efficiency-optimization), worktree clean, /tmp 已清理
- 实现纪要:
  - write_index 重写: find -printf '%p\t%TY-%Tm-%Td' + sort -t$'\t' -k1,1(37/37 等价验证)
    + 单 awk getline 流式解析(goal/phase/状态计数/sid/wt/scope 内联) → R/T/D/S 四类行, bash 仅回写骨架
  - rollup_task+extract_plan_meta 删除(无外部消费者, grep rc=1); lib source 行保留(S17 注释原样)
  - 插曲: 首版正则手误 [Ss]atus 丢 t → selftest T01/T04/T05/T07/T09/T13 红, 定位修复后 13/13
  - FS 显式 \t 加固(路径含空格对齐旧 while read 整行语义, 夹具验证过)
- 验收数据:
  - selftest: 改前 13/13 + 改后 13/13
  - 对拍: /tmp 37 计划快照 INDEX.md 逐字节一致(diff 空, 含时间戳行同分钟); console 仅路径差异
  - 归档夹具: 新造 archive 计划(深度3)不出现 + mv 现存计划入 archive → 37→36 行/complete 36→35, 双实现一致
  - fork: strace execve 861→8; 耗时 2744ms→107ms/轮(36 计划快照, 3 轮均值)
  - bash -n 双脚本 OK; worktree 干净度: 仅 sync-todos.sh M + selftest-sync-index.sh ??
- 待办: commit → /tmp 清理(s21-cmp/s21dbg*/s21-space/x3/s21-iso/s21-real/s21-probe/s21-manifest)
