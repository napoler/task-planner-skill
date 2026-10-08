# Verification Contract & Phase Gates — task-v145-four-file-dataflow

## Goal (1 sentence)

新增 Rule 62（六子条，原 60 两轮改号）把四文件体系制度化为主子代理数据流转协议介质：调研双落盘、派发契约不可收窄 lint、kb 增量门控，selftest 守护+全量回归+双部署位同步。

---

## Verification Contract 复验（2026-10-08 终验，全部带第一手证据）

- [x] VC-1: Rule 62 六子条条款落地（纯增量）
  Evidence: master `skills/task-planner/references/critical-rules.md` — `^### 62 四文件罗盘`=1、`^62\.[1-6] \*\*`=6（grep 实测）；合并后结构 58(v143)/60(v142 改号)/62(本任务) 各=1；本任务增量为追加式（Phase 1 diff +18/-0）
- [x] VC-2: 契约措辞 lint 机制化
  Evidence: `check-dispatch.sh:152-175 scan_contract_narrowing()`（双条件∧，append 锚点短路）；负样例 check exit=1/enforce pretool exit=2、正样例放行、误报 edge×3 放行（subagent-state/2-S1 检查点+findings [sub:2-S1-executor] 节原文）；**部署位实弹**：videop1 式「主进程回填，你只写检查点」fixture 于 /home/terry/.zcode 位 exit=1 拦截
- [x] VC-3: 派发模板四文件契约齐装
  Evidence: `templates/subagent_dispatch.md` — `knowledge-brief: {plan_dir}` 行 grep=1；findings 可写行既有语义 0 删行（git diff 验证）
- [x] VC-4: SKILL 三触点（C41 让位 v143 后顺延 **C42**，覆盖判据等价）
  Evidence: `SKILL.md` — 产出落盘映射表蒸馏行（`主进程单写者蒸馏，Rule 62.3 双落盘`）=1、Rule 62 摘要行=1、`^| C42 |` 合规行=1（grep 实测）；C41 归 v143 Rule 58（合并仲裁，见 e870f83）
- [x] VC-5: kb 增量门控机制
  Evidence: `check-3file-gate.sh:126-139 kb_distill_activity()/173-197 --require-kb` 沙箱五态实测（无旗标 parity 逐字节一致/无增量 exit1 含 Rule 62.5 提示/touch kb 或 ledger kb_distill 后 exit0/锚点前 kb_distill 不放行 T9）；`ledger-append.sh` `VALID_EVENTS=.*kb_distill` 行=1
- [x] VC-6: 新静态守护
  Evidence: `scripts/selftest-four-file-dataflow.sh` Total: 18 PASS=18 FAIL=0 exit=0（仓库/worktree/双部署位四处跑通）；`selftest-registry.tsv` 已登记（62 块尾 63.x 负断言口径）
- [x] VC-7: 全量回归（口径=本任务引入 FAIL=0，存量漂移分类登记）
  Evidence: 57 脚本双侧比对（/tmp/v145-regression-{master,wt}.out）：master FAIL=21 条/15 脚本 vs wt FAIL=22 条/15 脚本；唯一增量（iteration-persistence）经 `git archive a7c01a8` 合并基线复现证明预存在；合并 master 后复跑 IP-15（config 42≠40）与 master 同 FAIL=存量（config 41/42 键为 v141-v143 期间演进，非本任务）；**本任务引入 FAIL=0**
- [x] VC-8: 双审查 APPROVED
  Evidence: code-quality-review 14/14 维度 APPROVED（4 P2→其中 2 条守护加固已修：FF-08 无括号计数/FF-09 VALID_EVENTS 行锚，commit 3e2ab6b）；alignment-review 14/14 维度 APPROVED（0 P0/P1；纯增量/引用完整/术语统一/锚完整/结构对齐五面全 PASS）
- [x] VC-9: 合并回+部署一致
  Evidence: smart-merge-back V1-V6 全过 → master merge commit **b7c46ce**；主仓 Read 复验（### 62=1/lint 函数=2/C42=1）；双部署位 `~/.zcode`+`~/.claude` rsync 只补后 `diff -rq` **IDENTICAL**（顺带补齐 v142/v143 存量漂移）；worktree remove+branch -d 清理完成
- [x] VC-10: 簿记闭环
  Evidence: rule-reserve `rule 62 landed by task-v145-four-file-dataflow`；INDEX 刷新（sync-todos --index）；本文件；delivery-summary.md 落盘

## 委派统计（Rule 25）

- 总 Phase=6；子代理执行=Phase 2（S1+S2）、Phase 4 回归（S1）、Phase 5 双 CR（Handoff #3/#4）→ 委派覆盖 4/6 Phase；主进程直做=Phase 1/3（白名单② 条款与模板措辞，同 v136/v141/v143 先例）/Phase 6（白名单② 簿记）+Phase 5 合并编排（白名单①）——全部登记白名单理由，verdict=WHITELIST-EXEMPT
- Handoff 4 行全 done+findings 落点双锚回填+checkpoint 在位（subagent-state/ 4 文件）

## 质量门控统计（Rule 26）

Q1 批量门=N/A（无批量）；Q2 委派率=上段（WHITELIST-EXEMPT）；Q3 内容质量=N/A（代码组）；Q4 抽检=3 条 Evidence 复验通过（VC-2 部署位实弹/VC-6 四处跑通/VC-9 IDENTICAL）；Q5 违规=0（skill-modify 写守卫 warn 系路径启发式误报，已核对计划 scope_files 在册）；Q6 惩罚=0

## Phase Gates

### Phase 1: Rule 62 条款撰写 — complete（fa5ea7a）
### Phase 2: 守卫脚本扩展 — complete（c8df05b）
### Phase 3: 模板与 SKILL 联动 — complete（62ecaef）
### Phase 4: selftest 守护+全量回归 — complete（b65af69+3e2ab6b）
### Phase 5: 双 CR+合并回+部署同步 — complete（d735917+e870f83+b7c46ce）
### Phase 6: 簿记交付 — complete
