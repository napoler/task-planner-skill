# 交付总结 — fix-pointer-race（2026-10-07）

## 说明
active-plan 指针被并行会话抢占覆盖事故的机制修复：指针链 sid canon 写读分裂（RC-1）+ init-session"抢最新哨兵"兜底跨会话互抢（RC-2）+ mtime 兜底放大（RC-3）。本会话 init 实时复现 RC-2（抢用 4272173a 会话哨兵）。

## 产出（可定位）
- master 合并: `b7967db`（7 文件 +309/-14）；fix commit `8f6c0f3`；簿记 `290e630`/`ff91534`
- 修改文件: skills/task-planner/scripts/{resolve-plan-dir,set-active-plan,init-session,zcode-userpromptsubmit}.sh + {task-plan-init,plan-created}.cjs + selftest-active-plan.sh
- 部署位: ~/.zcode/skills/task-planner/scripts/ 同 7 文件，diff IDENTICAL 7/7（即时生效）
- 机制: 双命名空间兼容读写 + <env_sidkey>.sidmap 确定性映射（SessionStart 落盘）+ 兜底两级化（映射权威优先→≤120s 新鲜窗→拒抢 WARN）+ gc 扫 *.sidmap

## 审查详细
- selftest-active-plan 29/29 PASS（T12a-I/T12j-l/T13/T14，CR 变异测试证实判别力）；定向回归 execution-stability 19/19、delegation 38/38
- CR（Code Reviewer）: NEEDS_FIXES 4 项 → 3 修 1 deferred；报告 plans/fix-pointer-race-20261007/subagent-state/6-code-reviewer.md
- 全量 selftest: 51 PASS / 15 FAIL——15 项经 master 对照均为既有问题，与本修复零增量

## 风险（必须列举）
1. deferred: plan-created 哨兵删除 write-delete 竞态（窗口窄，CR 置信 LOW，master 既有）
2. master 全量 selftest 基线漂移：15 脚本 FAIL（含 v142 在途 periodic-review），需独立排查，勿默认全绿
3. 其他部署位未同步：本修复仅落 zcode 主部署位；videop1 等其他仓/宿主的 skills 副本仍带缺陷（事故首发仓在列）
4. 陈旧全局指针 plans/.active_plan（指向 task-v098，9-30）未清理（数据面，避免误伤 cron）

## 下一步建议
- 如其他部署位（尤其事故首发仓）需要同修：以 master b7967db 为源同步 7 文件
- 15 个既有 selftest FAIL 建议开独立排查（区分环境依赖 vs 真回归）
- 并行会话临时缓解口诀仍有效：set-active-plan.sh set <task> --sid（修复后通常不再需要）
