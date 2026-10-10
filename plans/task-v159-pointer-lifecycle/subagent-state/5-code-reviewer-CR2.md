#### [sub:CR2] Code Review 复审（第二轮增量）— verdict CHANGES_REQUESTED（2026-10-10）
- 基准：首轮报告 subagent-state/4-code-reviewer-CR.md + 修复证据 subagent-state/5-executor-crfix.md；范围=worktree 相对 HEAD 的 5 文件净改动（set-active-plan / init-session / smart-merge-back / selftest-pointer-lifecycle / selftest-smart-merge）。
- 客观证据：`bash -n` 五脚本全 exit 0；selftest-pointer-lifecycle 10/10 PASS；selftest-smart-merge 17/17 PASS；selftest-registry 5/5（rows=69）。

- 复核结论（首轮八项逐条）：
  - BLOCKER-1（F1 completed-ttl 误删面）→ **partial（回归化）**：误删在途计划已堵（真 in_progress 计划实测保留），但新判据引入反向漏清。
  - MAJOR-2（F3 双形态 owner）→ **fixed**：夹具实测裸 uuid 与 sess 前缀两形态均触发 skip+WARN（side 未写）；init-session.sh 同步修复，口径与 .session-owner 写入口径（zcode-userpromptsubmit 保持裸 UPS_SID）自洽。
  - MAJOR-3（selftest grep 计注释腐化）→ **fixed**：cnt() 管道 `grep -v '^\s*#'` 实测注释独占文件 cnt=0、代码行 cnt=1（GNU grep 支持 \s），PL-03/05/06/07 生效。
  - MAJOR-4（PL-05 自愈式 SKIP）→ **fixed**：SKIP 分支已删，改为 `.stage`+`diff -r` 硬断言，缺任一即 FAIL。
  - MAJOR-5（VC-3 措辞与实现分叉）→ **维持（口径待确认）**：task_plan.md:55 VC-3 原文已写「不写该键」，与实现一致；设计稿 design-pointer-fix.md:32 仍写「只写 env-sid 键」。非代码缺陷，属文档口径差。
  - MINOR-6（OK 文案无条件打印）→ **fixed**：条件 `DRIFT=0 && SWAP_FAIL=0 && VERIFY_FAIL=0 && ${#SLOTDIRS[@]}>0` 生效，reconcile 失败(DRIFT=1)路径不再先打印 OK；数组空守卫位置正确（&& 短路后 `-gt 0` 安全）。
  - MINOR-7（F2 巡检双命名空间）→ **fixed**：同时查 `${sidkey}.active_plan` 与 `sess${sidkey}.active_plan`，与 resolve-plan-dir.sh:64-66 双形态读取一致，无误报亦无新增漏报。
  - MINOR-8（旧位置参数模式 exit 2）→ **not-fixed（设计 scope 外，非回归）**：F4 仅 scope set 关键字模式；设计稿未纳入。

- 增量发现（新 diff）：
  - 🔴 BLOCKER B1：F1 新判据 `[ -z "$(grep -Ei 'Status.*in_progress' task_plan.md)" ]` 未锚定真实状态行，命中所有模板派生计划内固定行 `- Update phase status as you progress: pending → in_progress → complete`（templates/task_plan.md:221/395/400 默认生成）→ 真·完成态计划被判「非整体完成」而永不清除。实测：多阶段全 complete 且含模板行（mtime 25h）→ 指针保留、无 completed-ttl；纯 complete 无模板行 → 正常清除。影响面：101 计划中 34 个「完成态但仅含模板 in_progress 行」将不被清理，F1/VC-1 目标落空。位置 set-active-plan.sh:181-183。置信度 HIGH。
    - 修法：锚定真实行 `grep -Eq '^[[:space:]]*[-*][[:space:]]*\*\*Status:\*\*[[:space:]]*in_progress'`；实测该式排除模板行、命中真实 in_progress/complete 行（全库真实 in_progress 仅 3 计划）。
  - 🟡 MAJOR M1：F1 判据未拦「部分完成」=1 阶段 complete + 其余 pending（既无 in_progress 又有 complete → 误判整体完成）。建议 not_done 集合扩为 in_progress+pending。位置 set-active-plan.sh:182。置信度 MEDIUM。
  - 🟡 MAJOR M2：F1 修复偏离施工权威设计 design-pointer-fix.md:12（仍为裸 `grep 'Status.*complete'`），未同步更新设计/VC 机制描述 → 未来按设计重实现复发风险。置信度 HIGH。
  - 💬 NIT N1：`--legacy` 部署回退路径在 selftest-smart-merge 中已无覆盖（SM-06/SM-14 改断默认 staging 路径，仅存注释提及）。F5 fallback 缺回归钉子。置信度 MEDIUM。
  - 已排查且无新问题：`grep -qE "^(sess)?${SID}$"` 无正则注入（SID norm 后仅 [a-zA-Z0-9]）；F1 两处 `$(grep ...)` 空结果在 set -u 下安全；SWAP_FAIL/VERIFY_FAIL 定义位于使用前；外层成功路径 `[DEPLOY] OK: 全部部署位 IDENTICAL` 在 DRIFT=0 时唯一，二义性已消。
