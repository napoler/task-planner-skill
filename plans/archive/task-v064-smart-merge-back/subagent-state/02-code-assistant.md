# Checkpoint: code-assistant (seq 02) — task-v064-smart-merge-back / Phase 2 / S1

## 里程碑 1: 接口定稿 — done
- 规格源: findings.md「smart-merge-back.sh 设计」段(逐字照实现)
- 接口: `smart-merge-back.sh <worktree-path> [--base master] [--deploy] [--force]`
  - branch = `git -C <wt> branch --show-current`(须 `wt/<task-id>` 且目录名=task-id 双校验)
  - 主仓 = `git -C <wt> worktree list` 解析(主仓行 = `[ ]` 空分支行), 禁止假设 CWD
  - 退出码: 0 成功/已合并; 2 PRECHECK_INVALID; 3 PRECHECK_DIRTY; 4 SCOPE_OVERLAP; 5 MASTER_AHEAD; 6 DEPLOY_DRIFT; 7 MERGE_CONFLICT; 1 参数/环境错误
- 风格参照: check-dispatch.sh([tag] 前缀, 失败详情走 stderr)
- 输出序列: V1→V2→V3→V4→(V5)→(V6) → [CLEANUP] 提示 → (--deploy [DEPLOY] 行)

## 里程碑 2: 实现完成 — done (2026-09-12)
- 新建: /mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back/skills/task-planner/scripts/smart-merge-back.sh (chmod +x)
- `bash -n` 通过(SYNTAX_OK); set -u; 无 jq; 头注释含 [task-v064-smart-merge-back] 标注 + 退出码表
- 未触碰 scope 外任何文件(仅新增此 1 文件 + checkpoint)

## 里程碑 3: 自检完成 — done
- 夹具: mktemp -d + git init --bare + clone + worktree add ../wt-task-test -b wt/task-test(目录名 wt-<task-id> 带前缀, 脚本 case 兼容 `*"-$TASK_ID"`)
- 场景 a: clean → MERGED, exit 0, master log 出现 --no-ff merge commit ✓
- 场景 b: re-run → ALREADY_MERGED, exit 0, master HEAD unchanged ✓
- 场景 c: echo dirty > newfile → exit 3, 列出 ?? newfile ✓
- 场景 d: main commit 后 → exit 5 MASTER_AHEAD; --force 则 MERGED exit 0 ✓
- 场景 e: env 双 slot(slot1 空=旧, slot2 预置=同结构) → 两 slot 均 IDENTICAL, exit 0; 槽位不可写时 DRIFT exit 6(cp 失败触发)✓
- 临时目录已清理

## 最终结论 — done
- 新建 1 文件: skills/task-planner/scripts/smart-merge-back.sh (chmod +x, 约 280 行)
- `git -C worktree status --short` 仅显示 `?? skills/task-planner/scripts/smart-merge-back.sh`, 未触碰其他文件
- 5 场景实测全通过(详见上方)
- 已知边界: V1 主仓解析兼容 [base] 带分支行(bare+worktree add 场景), 非 detached 主仓也正确识别
