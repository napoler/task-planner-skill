# checkpoint 03-code-assistant (S1: selftest-smart-merge.sh)
- [x] 夹具就绪
- [x] 用例完成
- [x] 全绿

## 最终结论
- 文件: /mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back/skills/task-planner/scripts/selftest-smart-merge.sh (+1, chmod +x, 10675 字节)
- 验收: 5/5 pass
  1. bash -n 通过
  2. 裸跑 Total: 7 PASS=7 FAIL=0 EXIT=0
  3. 连跑两遍一致(noise=0, diff 一致)
  4. git status 仅新增 selftest-smart-merge.sh
  5. 真实部署位 mtime 不变(1789210545/544/545)

## 关键实现决策
- 夹具: mk_fixture 函数(bare+clone+worktree add), 禁用全局 hooksPath, stderr 静默降噪
- SM-01 脏 worktree exit3 ✓
- SM-02 干净合并 exit0 + rev-list --merges HEAD | wc -l = 1 ✓
- SM-03 已合并 ALREADY_MERGED exit0 + master 无新 commit ✓
- SM-04a master 前进 exit5 MASTER_AHEAD ✓; SM-04b --force exit0 MERGED(分支改 new.txt, master 改 base.txt, 不同文件无冲突) ✓
- SM-05 scope 重叠 exit4(主仓未提交 base.txt ∩ 分支变更 base.txt) ✓
- SM-06 --deploy exit6: env 前缀显式传参, s1 可写 IDENTICAL, s2 只读 → cp 失败 DRIFT ✓
- SM-07 [CLEANUP] 行 + worktree 目录保留 ✓
- DRIFT 机制: s2 置只读后 cp -rL 失败 → 脚本打印 [DEPLOY] DRIFT + exit 6
- 噪声治理: 所有 git 操作 stderr 2>/dev/null, 连跑 2 遍 noise=0

## 风险/已知
- git 2.43 无 -c 短选项, 用 rev-list --merges HEAD | wc -l 等价判定
- 临时仓内 clone 时 "a branch named 'master' already exists" 噪音由 stderr 静默消除, 不影响 ref 实际更新
- 真实 worktree/部署位全程未触碰, 仅操作 /tmp 下夹具
