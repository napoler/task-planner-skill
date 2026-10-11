# 009 code-assistant S6 (set-active-plan.sh gc archive 跳过 + plan-created.cjs 复核)

milestones:
- 2026-10-12 T1 里程碑1: set-active-plan.sh set 分支 F3 所有权守卫 for 循环加 `*"$PLAN_ROOT"/archive/*` case 跳过(+8 行含双层注释, 原 L237-241 区); bash -n OK; node --check plan-created.cjs OK(未改码)
- 2026-10-12 T5 最终结论: commit 4122454(set-active-plan.sh +8/-0, plan-created.cjs 零改动)
## plan-created.cjs 复核留痕(验收2)
- L197(④ mtime 最新层): `entry.startsWith('archive')` 跳过 readdirSync(PLANS_DIR) 单层枚举 — archive/<id>/task_plan.md 在 depth 2, 枚举只取直接子目录, 且 'archive' 前缀命中, 零命中 ✓
- L229(legacy 哨兵仲裁层): `entry.startsWith('archive')` 跳过同单层枚举 — archive 计划 mtime 不会触发"比 legacy 新"误删 ✓
- 漏洞排查: 指针层(L184 path.join(PLANS_DIR,pid,'task_plan.md'))依赖 L183 isValidSlug 拒绝穿越+archive 目录本身无 task_plan.md 直接文件, 非递归, 不可达 ✓; sentinelFallbackSidkey(L82-127)只枚举 .plan_required_side/(非 plans/ 任务面)与 archive 无关 ✓; L197 隐藏目录 startsWith('.') 与 slug 校验同闸 ✓
- 结论: 既有跳过(L197/L229, 即 findings 所称 L10/L122 语义先例)完整覆盖新归档形态(archive/<id>/task_plan.md 单层枚举不可达), 无需改码; 实跑 fixture C(exit 1 零误触)/D(exit 0 正常清除)佐证。
- 负结果报告: 检查 set-active-plan.sh 全部扫描面 — gc 分支 L158/166/173/220 均针对 .active_plan_side/.plan_required_side 定点 find -name(不扫 plans/*, archive 零命中); set 分支 L240 glob plans/*/.session-owner 单段可及 archive 层=唯一需改点(已修); 旧模式 L273-279 无扫描。未发现其他冲突扫描面。
