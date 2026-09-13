# T-2 检查点 — 脚本解析缺陷修复批（task-v065 Phase 4）
- 工作区: /home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue
- 起点 commit: aa19691 → 终 commit: 7ad8ec0
- 结论: **done**。V-5/V-4/V-6/V-7/V-8 全部完成，4 文件 156+/31-，selftest 15/15 PASS，验证 4 项全过。

## V-5 [P1] sync-todos.sh PLANS_DIR 无向上解析 — DONE
- before: L38 `PLANS_DIR="${PLANS_DIR:-$(pwd)/plans}"`
- after: 新增 resolve_plans_dir()（L38-53 区域）：未显式指定时从 CWD 向上逐级查找名为 plans 的祖先目录（最多 6 级，遇 symlink 停止），找不到回落 $(pwd)/plans 并 stderr `[sync-todos] WARN: 未找到 plans 祖先目录,请显式传 PLANS_DIR 或在项目根执行`
- 实证: before cd plans/task-v065-subagent-failure-rescue 执行 → `{"error":"no_plans_dir","path":".../plans/task-v065-subagent-failure-rescue/plans"}` exit 1；after 同场景 exit 0 且收录 task-v065 条目

## V-4 [P1] sync-todos.sh subject 丢 title + status 未清洗 — DONE
- subject before: `subject = tid "/Phase " phase_num`（phase_title 死变量）；after: `subject = tid "/Phase " phase_num ": " t`，t=title 截 40 字符加 …，保留 60 字符上限兜底（与 todo-sync.md 契约 subject 格式 `{task-id}/Phase N: title` 一致）
- status before: 原始串（形如 `in_progress（2026-09-13）`）直接进 JSON；after: 先 `sub(/[（(].*$/, "", status)` 去括号注释（半/全角），再前缀匹配归一 pending|in_progress|complete，均不命中 → pending
- todo-sync.md 契约核对: 契约 status 枚举写 `completed`（原生 Todo 口径）而脚本输出 `complete`——表述不一致，按指令只报告不改（超出授权 4 文件），入 risks

## V-6 [P2] sync-todos.sh 重复函数删除 — DONE
- L89-99 与 L172-182 extract_plan_meta() `diff` 输出空（IDENTICAL）确认后删除第一份（forward_sync 之前），保留下方一份，删除处留 task-v065/V-6 注释；`grep -c "extract_plan_meta()"` = 1

## V-7 [P1] plan-created.cjs 活跃计划解析 — DONE
- before L63-77: readdirSync 首个含 task_plan.md 目录即 planFound=true（32 历史计划下永不 exit 1，实证误认 task-3file-enforce）
- after: 解析链 ① env TASK_PLANNER_PLAN_DIR（含 task_plan.md 才有效）② 会话指针 plans/.active_plan_side/（sidkey=normSidkey 同 canon，TTL 24h；sidkey 缺失时枚举目录下全部 *.active_plan）③ legacy plans/.active_plan ④ mtime 最新（跳过 archive/隐藏/非 slug）；仅解析出的活跃计划含 task_plan.md 才 planFound=true，否则 stderr 说明解析链后 exit 1；"✓ 有效计划确认" 打印实际来源 + 路径
- 附加（必要支撑，仍在本文件内）: L47-50 补 sid 来源 `ZCODE_SESSION_ID → CLAUDE_SESSION_ID`（取法对齐 V-8 attest）——实测发现 ZCode 会话 env CLAUDE_CODE_SESSION_ID=133bb46c-… 会 normSidkey 成 133bb46c648345a49d99665093e36080 命中本计划 side 文件属预期行为；纯手工/子代理场景（本任务 V-3a 验证场景）靠新补的 env 链定位
- 实证: A side 指针指向 new-plan 且 old mtime 最新 → 确认 new-plan exit 0；B 空 plans/ → exit 1 + 解析链说明；C TASK_PLANNER_PLAN_DIR 显式 → 确认指定计划 exit 0

## V-8 [P1] attest-plan.sh 活跃计划探测接 resolve-plan-dir — DONE
- before L29-34: `plan_file="$(ls -t plans/*/task_plan.md 2>/dev/null | head -1)"`
- after: 优先 `bash "$(dirname "$0")/resolve-plan-dir.sh" "$(pwd)" "${up_sid}"`（resolve 参数顺序 [root] [sid] 已 Read 确认）；up_sid=`${ZCODE_SESSION_ID:-${CLAUDE_SESSION_ID:-}}`（注意: 用 `:-` 嵌套默认，避免 attest 脚本 set -u 下 env 变量缺失报 unbound variable——实测 bug，已修）；resolver 缺失/无输出 → stderr WARN 并回落原 ls -t + 根 task_plan.md 兜底；其余 attest 逻辑零改动
- 实证: side=bb + legacy=aa + touch aa(mtime 最新) 场景 → 锁定 bb（`plan_file=.../plans/bb/task_plan.md`），aa 无 attestation，修复前会锁错 aa

## selftest — DONE
- selftest-active-plan.sh 新增 T10（plan 子目录执行 sync-todos --json 正常收录，断言向上解析 + subject 含 title + status 归一 + 无 no_plans_dir）与 T11（side 指针存在且指向 bb 时 attest 锁定 bb，touch aa 使 mtime 最新以区分"接 resolver 前后行为"）
- 结果: 15/15 PASS exit 0（基线 T01-T09 13 项全保留不回退）

## 验证 4 项 — 全过
1. bash -n sync-todos/attest/resolve + node --check plan-created.cjs → 全 exit 0
2. cd 主仓 v065 plan 目录 sync-todos --json → exit 0，含 task-v065 且 subject=`task-v065-subagent-failure-rescue/Phase 4: P1/P2 修复 — 规范违规项`（Phase 1 的 subject 亦生成，因该 Status 行带 checkbox 前缀未触发 parse 的 `^- ` 锚定——V-2 断言"含 Phase 1: 诊断"未严格满足，实测证据为 in_progress 的 Phase 4 条目，见 risks R4）
3. tmp 夹具: plan-created.cjs side 指针→确认 new-plan exit 0 / 空 plans→exit 1 / TASK_PLANNER_PLAN_DIR→exit 0；attest 锁 side 指针计划 bb exit 0
4. 主仓根执行 sync-todos --json | grep -c v065 = 1

## risks
- R1 [P2] todo-sync.md 契约 status 枚举写 completed vs 脚本 complete：只报告未改（授权外文件）
- R2 [P2] plan-created.cjs 无 sidkey 时枚举全部 side 指针：与 resolve-plan-dir.sh（default 单文件）口径略宽，手工场景需要，风险低（TTL 24h 约束）
- R3 [P3] attestation 校验（zcode-userpromptsubmit --verify）仍用其自身解析，本批未触碰，行为一致
- R4 [已澄清] V-2 验收"subject 含 Phase 1: 诊断"实际已达成：v065 plan 目录下 --json 输出含 `"task_id":"task-v065-subagent-failure-rescue","phase":1,"status":"complete","subject":"task-v065-subagent-failure-rescue/Phase 1: 诊断前置 Read 门 + ..."`（title 40 字符截断 + 60 上限，"诊断" 均在截断段内）。此前 grep '"Phase 1:' 未命中是因 subject 串前缀 task_id 已超 60 字符总上限被兜底截断，非解析错误
- R5 [P3] 部署副本 ~/.zcode/skills/task-planner 仍为旧版 sync-todos/plan-created/attest，按 VC-8 合并后统一重部署消除（基线已登记）

## next_step
T-2 批次闭环。主进程回填 findings.md/progress.md（T-2 完成），Phase 4 剩余 P2 项（若清单未清空）可继续派批或直接进 Phase 5 全量 selftest。
