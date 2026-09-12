# 08-code-assistant checkpoint — task-v064-smart-merge-back / Phase 5 修复轮 3 (复审 14 项)
status: done
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back

## 修复逐项落点
- P0 SMB:304-320 norm_path(): smart-merge-back.sh:331-351(realpath -m 优先, 失败回退纯串归并
  //→/、剥 .、.. 弹出; 实测 //tmp/x、/tmp/./x、/tmp/y/../x 全部 → /tmp/x, / → /)
- P0 SKILL_ROOT 推导 :319 改 `cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P`(消除 /scripts/.. 字面量)
- P0 validate_slot :366-392 slot 先 norm_path; guard 循环外一次性算 norm 数组(guard_norm/guard_type)
  再执行三向判定; norm="/" 显式拒绝保留
- P1-1 :321-324 GUARDS="${HOME:-}:home|$SKILL_ROOT:full|$WT_PATH:full|$MAIN_REPO:full"(带类型;
  home=豁免 inside, 仅 exact+ancestor; ${HOME:-} 防 env -u HOME set -u 中止); 头注释 +usage 同步
- P1-2 :215-227 MERGE_HEAD 检测改 --path-format=absolute, 不支持时回退 --git-dir(相对拼 MAIN_REPO 前缀)
- P2 selftest: 记账真累计 PASS+FAIL=TOTAL_CASES 断言, 不一致 → FRAMEWORK_BROKEN exit 97(selftest:316-320);
  SM-03 MERGE_HEAD 残留断言改绝对路径(selftest:141-158); SM-11 新增 exit 8 正向覆盖
  (T11 主仓 update-ref --no-deref MERGE_HEAD HEAD, selftest:296-308); SM-10 头注释一致化 + 套内
  默认路径推导注入(selftest:254-264), 未注入记 FAIL 不静默降级
- P2 awk :161-167 branch 行累积至下一 worktree 行/END 才输出(path|branch 配对, 兜底判据③可达)
- P2 V3 rename :252-259 R??/C?? 状态额外消费下一条 NUL 旧路径, 新路径计入重叠集
- P3 原子替换改改名换位 :415-428(mv slot→.bak.$$ && mv tmp→slot && rm .bak; mv 失败 .bak 恢复原位,
  slot 永不缺席); trap 改 BATCH_TMPDIRS 数组逐个清理 :327; cp 前 rm -rf tmpdir :406(防 PID 复用)
- P3 删死变量 DO_MERGED(grep 已零残留)
- worktree-isolation.md :72 退出码 2-7→2-8, 注明 6 可能在合并已成功后出现(部署位不齐)

## 验收 5/5
1. bash -n 两文件 PASS
2. 裸跑 selftest: Total: 12 PASS=12 FAIL=0 EXIT=0, 连跑 2 遍一致(RUN1/RUN2 输出逐行相同);
   SM-11 exit 8 正向覆盖在列; SM-10 真实 wt 注入=是(套内推导默认路径命中)
3. P0 规范化实证: HOME=夹具, slot 变体拼写(//F/F 族) → REJECTED exit 6, 哨兵 md5 前后不变
   (9c60de4f... 两次一致, 对照洞②绕过场景)
4. P1-1 实证: HOME=夹具不设 env → 三默认位输出 cp 失败 DRIFT(非 REJECTED), rc=6,
   证明 home 类型豁免 inside 生效
5. git diff --stat 仅 3 文件: worktree-isolation.md +1/-1, selftest-smart-merge.sh +47/-31,
   smart-merge-back.sh +139/-43(共 +186/-74); 未触碰 Scope 外任何文件

## 负结果/排查记录
- 曾误用 `${BASH_SOURCE%/*}/..`(Bash 数组展开 → 输出 scripts/..)导致 cp ENOTDIR 假故障, 改 dirname 后消除
- 曾手工 mkfix 夹具忘配 user.email → V6 MERGE_CONFLICT exit 7 假故障(非脚本缺陷), 补配后全通
- V3 rename 双记录实证: git mv 且内容改动产生 RM 状态, -z 输出 R??<新>\0<旧>\0, 解析正确
- SM-08 3REJECTED 显示 1: 因 grep -c 统计 DEPLOY_DRIFT 汇总行(含 REJECTED 字样)被合并计数, 断言逻辑按
  3 个具体 REJECTED 行分别 grep -qF, 判定不受影响

## blockers / 残留
none
