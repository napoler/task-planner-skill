# checkpoint 08-executor (Fix-C: P2-2 行为级断言)
status: done
time: 2026-09-14
worktree: /home/terry/task-planner-skill-worktrees/task-v068-execution-stability
target: skills/task-planner/scripts/selftest-execution-stability.sh (唯一改动文件, +90/-0)

## 完成项
- T11a (B1 正例): mktemp fixture $T/plans/task-x/{task_plan.md,.session-owner=sessabc123};
  env -u ZCODE_SESSION_ID attest-plan.sh --skip-dispatch-check 建基线 (attested_by_sid 空);
  改 task_plan.md → 相对含 slash file_path 的 Edit stdin → env -u ZCODE_SESSION_ID zcode-posttooluse.sh;
  断言 plan_sha256==sha256sum 新值 且 attested_by_sid==sessabc123。实测 PASS。
- T11b (B1 负例): 同 fixture, 先改内容再把 owner 换 othersid999, 重跑同 stdin;
  断言 plan_sha256 仍为旧 h1(哈希不更新) 且 attested_by_sid 保持空串(不产生新归属, 不被洗白)。实测 PASS。
- T12 (B2 跨脚本 canon): sid=sess-abc123, 三条管道 (pretooluse L17 式 jq 全链路 / UPS L34 式 tr /
  bash -c 全链复刻) 输出逐字节一致; FAIL 分支自带 [B2-diag] 输出三侧实际值。实测 PASS。
- 破坏性自检 (可选加分): 独立 harness 复现负例 → NEG-OK (stored==h1, bysid 空, FAIL 路径可达)。
- 验证: bash -n 过; 全量 selftest Total: 17 PASS=17 FAIL=0 exit 0;
  git diff --stat 恰 1 文件 (selftest-execution-stability.sh +90); 未 commit。

## 排除的风险
- T1-T10 原 14 断言全部保持 PASS (无回归); 临时 fixture 与 /tmp/task-planner-hook-sessabc123.state 测后清理;
  未触碰任何 hook 脚本/SKILL/config; worktree 中既有 4 个 M 文件 (check-delegation/plan-created.cjs/
  zcode-posttooluse/zcode-userpromptsubmit) 属 Fix-A/Fix-B 轮次遗留, 本轮未再改。

## 备注
- B2 选行为式 (管道输出对比) 而非 grep 源码字符集断言: 两侧 tr 字符集若分侧被改动, grep 断言仍全绿,
  正是 P2-2 要防的盲点; 行为式在真实管道输出分叉时立即 FAIL。
