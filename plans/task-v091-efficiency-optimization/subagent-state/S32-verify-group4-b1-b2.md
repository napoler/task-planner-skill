# S32 组4 B-1/B-2 干净上下文验证 checkpoint（全新子代理，不信任既有验证结论）

- 执行: 2026-09-27 | worktree /mnt/data/dev/task-planner-skill-worktrees/task-v091 (HEAD=a05bd5e) | 只读验证，零文件修改
- 判定: **全 PASS**（B-1①②③ + B-2①② 六项无 FAIL）

## B-1① 模板 122→60 行契约零丢失对照 — PASS
- 原 122 行版取法: `git show '349d94e^:skills/task-planner/templates/subagent_dispatch.md'`（存 /tmp/v091-b1/orig_dispatch.md，wc=122）
- 新版 wc=60（templates/subagent_dispatch.md:60 行）。注意路径前缀是 `skills/task-planner/`（任务书给的裸路径在 349d94e^ 不存在，已按仓内实际路径取证）
- 九字段占位符对照（orig/new 计数，全部 new≥orig 或已外置）:
  goal_one_sentence 1/1, plan_dir 3/3, path_1 1/1, path_2 1/1, findings_excerpt 1/1,
  context_dependencies 1/1, knowledge_brief 1/1, acceptance_1..4 各 1/1,
  forbidden_path_1/2 各 1/1, forbidden_op_1/2 各 1/1, worktree_abs_path 1/1,
  cwd 1/1, timeout_minutes 1/1; checkpoint_path orig=2/new=1 — 差额 1 处=外置段
  （resume_from §22.8.4 模板段含 {checkpoint_path}，已整体外移至 dispatch-examples.md §2，非丢失）
- 三文件契约锚（全部在新版在位）: L9「Rule 22.4a 读写契约」、L10 task_plan 只读、L11 findings
  仅追加 `#### [sub:{seq}-{type}]` 到 Research Findings 段末（Technical Decisions 前）、L12 progress
  仅追加 Actions taken 下 `[sub:{seq}]`、禁改 Status/Started
- 8 字段返回模板: 新版 L35-46 完整 8 key（status/acceptance/files/evidence/checkpoint/
  findings_written/blockers/confidence）+ 统计类任务禁自报汇总行（L39）逐字保留；
  计数 orig>new 的差额全部=已填示例块（原 L66-73）外置到 dispatch-examples.md §1（该处原文逐字在位，head 实证）
- 22.8 引用: 「Rule 22.8」计数 4/4 一致；22.8.5、22.8.2 T5、22.8.4、22.7.1、prompt_max_chars、
  step_max_steps、「8 字段」、subagent-state 锚点全部在位（subagent-state 3→2 差额=外置 STOP 模板段 L118）

## B-1② 好/坏样例双向 rc — PASS
- 夹具: /tmp/v091-b1/planfx/{task_plan,findings,progress}.md + good_prompt.md（压缩 60 行模板独立构造，
  含三文件绝对路径+8 字段块+subagent-state 检查点）+ bad_prompt.md（缺三文件路径，打包 S1/S2 两个 S-unit）
- 跑法: `TASK_PLANNER_PLAN_DIR=<pd> TASK_PLANNER_DISPATCH_ENFORCE=enforce bash check-dispatch.sh pretool <prompt>`
- 好样例: **rc=0 静默放行**（pretool 与 check 子命令均 0）
- 坏样例: **rc=2 拦截**，stderr 原文:
  `[dispatch-block] 🚫 派发契约缺项(Rule 22.4a/b/22.8.1): task_plan.md,findings.md,progress.md,acceptance:,checkpoint:,subagent-state/ — prompt 须含计划三文件绝对路径 + 8 字段返回模板 + subagent-state 检查点路径(templates/subagent_dispatch.md §2/§7/§8)`
- check 子命令对照: 好 rc=0 / 坏 rc=1 且逐行点名同 6 项缺项（stdout: task_plan.md / findings.md / progress.md / acceptance: / checkpoint: / subagent-state/）

## B-1③ 22.4b 路径引用绑定 — PASS
- critical-rules.md L134（22.4b）原文含: 「派发 prompt 必须附模板路径引用(`templates/subagent_dispatch.md`)；已填示例以 `references/dispatch-examples.md` §1 落盘承载，派发 prompt 只放路径、需对照示例时 Read(原句『必须附该模板与一份已填示例』语义改写为路径引用，与 dispatch-examples.md 同 commit，静态断言 selftest-dispatch.sh DX 组;[2026-09-27 task-v091 B-1])」
- references/dispatch-examples.md 存在，41 行非空，头部声明双向锚 DX-01..DX-03 守护
- selftest-dispatch.sh 实跑: **DX-01..DX-05b 全 PASS，Total: 29 PASS=29 FAIL=0**

## B-2① 22.4a 单写者澄清新旧对照 — PASS
- 新版（现行 L133）尾部新增原文: 「[2026-09-27 task-v091 B-2] 单写者澄清:findings.md/progress.md 的追加(22.4a 允许的 `#### [sub:…]` 小节与 `[sub:seq]` 子项)由子代理**必做**；主进程仅在子代理未自写时兜底回填(缺漏兜底,见 19.1/22.5)，**禁止双侧同写同一锚点**——同文件同段双侧并发追加 = 双写不确定性；主进程 Read 复核义务(22.5 30s Read 实际产出 + 复核/回填 findings)不变」
- 旧版 `git show '1b9437e^:…critical-rules.md'` L133 止于「主进程终验以检查点为准复核(22.5)」，无双侧同写禁止/兜底语义 → 确认 B-2 增补语义在位
- 旧 12 列 Handoff 表（task_plan.md L365, `1b9437e^`）vs 新 10 列（现行 L367）: 列位折叠 rescue/retry_count/verify_done →「备注(rescue/retry/verify_done)」单列，列说明注释明示「字段内容不删，仅列位折叠；verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中)」

## B-2② 等价旧/新 Handoff 表 stats 对拍 — PASS
- 源码读码: check-delegation.sh stats 只按「### Phase N + **Executor:**」状态机 + Handoff 表按
  `| subagent_type |` 列做类型 grep 交叉校验（:388 `grep -qE "\|[[:space:]]*${_tok_norm}[[:space:]]*\|"`）；
  **不按列位解析 verify_done/retry_count/rescue**（`grep verify_done|retry_count|rescue scripts/check-delegation.sh` 零命中，与 B-2 披露一致——机器门边界如实）
- 夹具 A（ok 变体，/tmp/v091-b1/{old12,new10}）: 3 Phase（2 委派 + 1 主进程白名单①），旧 12 列/新 10 列
  等价填好后跑 stats，两者 JSON 逐字节一致:
  `{"phases_total":3,"phases_delegated":2,"main_direct_count":1,"delegation_rate":0.667,"main_direct":[…],  "violations":[],"verdict":"ok"}` rc=0 / rc=0
- 夹具 B（violation 变体，/tmp/v091-b1/{old12b,new10b}）: Executor 含未登记 critic 类型，两者一致:
  `{"phases_total":2,"phases_delegated":0,"main_direct_count":1,"delegation_rate":0.000,… "violations":[{"type":"unverified_delegation","phase":"1 调研","executor":"critic（方案挑刺）",…}],"verdict":"violation"}` rc=1 / rc=1
- check-delegation 既有 selftest 实跑: `bash scripts/selftest-delegation.sh` → **Total: 38 PASS=38 FAIL=0**

## 负结果/边界报告
- 未发现的 FAIL 项: 无。契约丢失、双向 rc 不符、stats 不一致均未发生
- 路径澄清: 任务书写的 `templates/subagent_dispatch.md` 裸路径在 git 历史 349d94e^ 不存在；实际仓内前缀为 `skills/task-planner/templates/`，按实际路径取证（不影响结论）
- 模板 L48 写「已填示例…见 references/dispatch-examples.md §1」，而 22.4b 与 examples 头部均称静态断言 DX-01..03 绑定，selftest 实跑含 DX-04/DX-05/DX-05b 共 29 项——断言组比提案口径宽，无缺失
- /tmp/v091-b1 夹具用完即清（本 checkpoint 落盘后删除）

## 8 字段
status: done
acceptance: 6/6 pass — [B-1①:PASS B-1②:PASS B-1③:PASS B-2①:PASS B-2②:PASS selftest:PASS]
files: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S32-verify-group4-b1-b2.md(+1)；/tmp 夹具已清
evidence: check-dispatch pretool 好 rc=0/坏 rc=2（缺项点名 6 项原文见上）；check-delegation stats 双夹具 JSON 逐字节一致；selftest-dispatch Total 29 PASS / selftest-delegation Total 38 PASS
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S32-verify-group4-b1-b2.md (status: done)
findings_written: findings.md #### [sub:S32-verify-g4] B-1/B-2 干净上下文验证全 PASS
blockers: none
confidence: HIGH
