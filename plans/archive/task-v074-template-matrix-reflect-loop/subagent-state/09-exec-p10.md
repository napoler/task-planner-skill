# 09-exec-p10 检查点 | executor(sonnet) | 2026-09-16

## 范围
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v074-p10/（只在此编辑；未 commit；未碰主仓/部署位）

## 项 A：sid 兜底链统一
- skills/task-planner/scripts/init-session.sh
  - :149-163 PLAN_ROOT 解析修正（P1-2 根因之一）：原 `cd .. && pwd` 把指针写到 <root>/.active_plan{,_side}，
    与 canonical 侧 <root>/plans/（task-plan-init.cjs :76 / resolve-plan-dir.sh :33 / set-active-plan）错位。
    现：CWD=plans/ → PLAN_ROOT=CWD；CWD=plans/<task-id>/（既有标准运行方式）→ PLAN_ROOT=..（行为不变）；非标准 → cd .. 降级。
  - :168-191 sid 哨兵探测 fallback：env sid 无对应 .plan_required_side/<sidkey>.plan_required 时，
    扫该目录取 mtime 最新哨兵 stem 为 sidkey（SessionStart 刚写入=本会话真实 sid 落地物）。
    注释锚 `[2026-09-16 task-v074 P10 sid 哨兵探测 fallback]` + 多会话并发局限（最新 mtime 启动会话优先，已知取舍）。
  - 语义红线保持：env sid 有对应哨兵 → 行为完全不变（:176 条件 `! -f` 命中即跳过探测）。
- skills/task-planner/scripts/plan-created.cjs
  - :60 `SIDKEY0 = normSidkey(sid)`；:63-95 `sentinelFallbackSidkey(primaryKey)`：primary 有对应哨兵 → 原样返回；
    否则扫 <root>/plans/.plan_required_side/ mtime 最新 stem，经 normSidkey canon 后作为 fallback sidkey；
    无哨兵目录/无哨兵 → 维持 primaryKey（零破坏）。:97 `const sidkey = sentinelFallbackSidkey(SIDKEY0);`
    后续双清除逻辑（side 哨兵清除 :204 / legacy 仲裁 :185 / 无 sid 兜底枚举）全部复用 fallback 后的 sidkey，代码不变。
- selftest-active-plan.sh 新增 T12a-d（编号接续 T11）：
  - T12a：env sid(133bbenvdead1) 无对应哨兵 + 目录内有 sess038ddeadbeef 哨兵 → init 写
    plans/.active_plan_side/sess038ddeadbeef.active_plan（断言非 env sid 名），PASS
  - T12b：env sid 有对应哨兵 → 指针名=env sid（回归不变），PASS
  - T12c：无 env sid → legacy plans/.active_plan（零破坏回归），PASS
  - T12d：plan-created.cjs 造哨兵(ffff0011aaaa2233)+side 指针+计划目录+无关 env sid(deadbeef44)
    → 哨兵被清、输出「会话哨兵已清除」，PASS（node 缺失时自动跳过）

## 项 C：fail-open 显式化
- attest-plan.sh :65-73 dispatch 门：`[ -x "$cpl" ]` 不可执行分支加 stderr
  `[plan-dispatch] SKIPPED (check-plan-dispatch.sh 不可执行)`（原静默跳过→显式化，行为仍放行）
- attest-plan.sh :91-98 template 门：`[ -x "$ctt" ]` 不可执行分支加 stderr
  `[template-gate] SKIPPED (check-template-type.sh 不可执行)`，t_rc=0 保持
  验证：/tmp 沙箱 chmod -x 两脚本 + 复制 attest → 两行 SKIPPED 均出现，attest 仍 exit 0 放行。

## 项 D：文档悬空清理
- README_zh.md :88：`INSTALL.md` → `INSTALL_zh.md`（INSTALL.md 不存在于仓顶）
- README_zh.md :96-99 目录树：README.md/INSTALL.md 行删除；补 CONTRIBUTING_zh.md；
  scripts/ 顶层块删除（仓顶无 scripts/，install.sh 实为 skills/task-planner/install.sh）；
  补 INSTALL.md（skill 包内真实路径 skills/task-planner/INSTALL.md）、companion/agents/（3 agent）、
  templates/knowledge-brief.md、templates/variant/（13 变体一行）；镜像目标 ~/.claude/ → ~/.zcode/
- README_zh.md 英文文档段（:215 原）：改为「暂无独立英文 README/安装文档，英文贡献见 CONTRIBUTING.md」
- README_zh.md 文档索引表：`INSTALL.md / INSTALL_zh.md` → `INSTALL_zh.md`
- CHANGELOG.md :60（原 :42 附近历史条目）：`docs/ARCHITECTURE.md §4.5.2` → §2.6（文件真实存在，
  ARCHITECTURE.md 无 4.5.2 章节，§2.6「Companion 同步器设计决策」即该主题实际章节）；行内标注修正出处
- CHANGELOG.md [Unreleased] 新增段补 P10 条目（A/C/D 三项 + 副作用登记）
- :180 VC-1 示例表格 `README.md` 为示例文字非链接，未动（超出本次范围，记录在 deviations）

## 验证
- bash -n：init-session.sh / attest-plan.sh / selftest-active-plan.sh 全过；node --check plan-created.cjs 过
- 全量 selftest 19 脚本：全部 rc=0，FAIL 合计 0。逐脚本 Total：active-plan 19（含 T12a-d）/ context-hygiene 12 /
  delegation 38 / dispatch 18 / error-loop 16 / execution-stability 17 / fallback 31 / interaction 11 /
  knowledge-brief 16 / methodology 7 / plan-dispatch 8 / reflect-verify 12 / rescue-chain 11 /
  shared-tracker 11 / skill-collab 19 / smart-merge 14 / template-lifecycle 17 / vc-gate 11 / veto 13 = 293 条断言
- grep 验证：README_zh 无 `](README.md)`/`](INSTALL.md)` 悬空链接（RC=1）；ls 确认引用目标存在
- /tmp 沙箱（attest-skip-*、t12x-*、dbg-*、st-out）已清理

## 遗留/风险
- init-session PLAN_ROOT 修正副作用：CWD=plans/<task-id> 运行时 legacy/side 指针落点从 <root>/.active_plan
  迁至 <root>/plans/.active_plan（对齐 canonical 侧）——既有 T08 selftest 未回归该布局，已跑 19 脚本全绿。
  主进程部署 3 位后建议观察一次 7am cron 场景（无 sid 走 legacy 分支）。
