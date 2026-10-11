# Executor fix-review Checkpoint — task-v055 (10-executor-fixreview)

- **agent_type**: executor
- **task**: CodeReview 批修 fix-phase(09-code-reviewer.md → 1 BLOCKER + 6 MAJOR + 5 MINOR + 4 NIT,本批 9 项)
- **worktree**: `/mnt/data/dev/task-planner-skill-worktrees/task-v055-fix-review` (分支 `wt/task-v055-fix-review`,base 1d73577)
- **commit**: `7ab28e2` — `fix(task-planner): task-v055 — CodeReview批修:B-1白名单措辞冲突+M1-M6+m4m5文案(9项)+自测+6断言`
- **status**: 完成
- **timestamp**: 2026-09-07

---

## 1. 范围与边界

- **worktree 路径隔离**: 仅在 `/mnt/data/dev/task-planner-skill-worktrees/task-v055-fix-review/` 写入
- **禁止触碰**:
  - 主仓 `plans/task-v055-scheduler-enforce/{tmp,subagent-state}/` 之外(仅追加本 checkpoint + enforce-demo.txt)
  - 其他 worktree / 部署位 / 用户主进程钩子配置
- **修改文件**(6 个,全部位于 worktree 内):
  - `skills/task-planner/SKILL.md` (文案/行号修正)
  - `skills/task-planner/scripts/allow-direct.sh` (M-4 sid 维度+--force)
  - `skills/task-planner/scripts/check-delegation.sh` (B-1/M-1/M-2/M-5/M-6)
  - `skills/task-planner/scripts/selftest-delegation.sh` (+6 断言)
  - `skills/task-planner/scripts/zcode-pretooluse.sh` (M-3/M-4 阻断文案+通道)
  - `skills/task-planner/templates/verification.md` (PARTIAL 文案对齐)

## 2. 9 项修复明细

### B-1 [BLOCKER] self_declared 白名单措辞冲突
- **修法**: 删除旧正则 `(用户显式|规划|验收|编排|簿记)`,改白名单编号标识判定 —
  `_flush_phase` 内: reason 为空 → `missing_reason`;reason 非空且含 ①-⑥ 或 `白名单[1-6]` → 已登记 (self_declared=0);否则 → `self_declared_reason`
- **位置**: `check-delegation.sh` `_flush_phase()` + 文件头注释更新
- **验证**: T12(旧样例 `编排与交付属主进程白名单` 无标识 → 仍报 violation) + T17(`白名单④：xxx` → verdict=ok,2 项 self_declared=0)
- **置信度**: HIGH

### M-1 [MAJOR] 无理由 Executor 判 violation
- **修法**: 同 B-1,`reason=""` 路径 → violation `{type:"missing_reason"}`
- **位置**: `_flush_phase` 内 `if [ -z "$reason" ]; then self_declared=1; violation_type="missing_reason"`
- **验证**: T18/T18b
- **置信度**: HIGH

### M-2 [MAJOR] session-owner 健壮化
- **修法**: 新增 `read_session_owner()` (首行+规范化 `[a-zA-Z0-9_-]{1,40}`);`mode_pretool` ② 段:
  - 缺失/空 → 降级观察模式:stdout 输出 `additionalContext` (`[delegation-observe] .session-owner 未初始化...`) + exit 0(首轮不阻断)
  - 多行 → head -n 1 后 trim,抵御注入绕过
  - 对比 = 规范化后严格相等(双方先 tr)
- **位置**: `check-delegation.sh` `read_session_owner()`/`emit_owner_observation()` + `mode_pretool` ② 段改写
- **验证**: T19(多行注入)/T19b(主进程链)/T20(缺失观察模式)/T20b(grep hit)
- **置信度**: HIGH

### M-3 [MAJOR] 阻断反馈通道统一
- **修法**: `zcode-pretooluse.sh` enforce 阻断 (`rc==2`) 改 `printf '%s' "$msg" >&2; exit 2`(stderr 通道,与 check-scope 路径一致);warn 档 `emit_warn` 保留 stdout JSON(`additionalContext` 注入)
- **位置**: `zcode-pretooluse.sh:42-49`
- **验证**: 现有 T07(仍 exit 2)+T08(仍 stdout additionalContext) 全 PASS;stderr 通道无需新增断言(已对齐 check-scope 模式)
- **置信度**: HIGH

### M-4 [MAJOR] bypass 人类在场约束 + 文案自洽
- **修法 双管**:
  1. **文案**: `zcode-pretooluse.sh` 阻断 msg + `check-delegation.sh emit_warn` 删除可执行 bash 命令原文;改为「请用户确认后运行技能目录下 allow-direct.sh」+ 提示 on 子命令参数
  2. **allow-direct.sh sid 维度闸门**:
     - 新增 `detect_caller_sid` (从 `$ZCODE_SID`/`$UPS_SID` 提取,默认 "default",规范化)
     - 写入 `/tmp/task-planner-bypass-<sid>`(取代旧 `.allow-direct.bypass-count` 永久闸门)
     - 新增 `--force` 参数:plan-dir ledger 已有 `"event":"bypass"` 时,二次 bypass 需 `--force`,并额外 ledger 标 `"force":true`
     - 三档 exit: 0(成功)/ 2(缺 confirm)/ 3(sid 已用)/ 4(plan-dir 已 bypass 需 --force)
- **位置**: `zcode-pretooluse.sh:42-49` + `check-delegation.sh emit_warn` + `allow-direct.sh` 全函数重写
- **验证**: T11a(同 sid 首次)/T11b(同 sid 二次 rc=3)/T22a(测试 sid-a)/T22b(测试 sid-a 二次 rc=3)/T22c(测试 sid-b 独立放行)
- **置信度**: HIGH

### M-5 [MAJOR] plans 白名单收紧
- **修法**: `is_whitelisted_path` plans 祖先命中后追加扩展名检查 `case "$ext" in md|json) return 0 ;; *) return 1 ;;`;业务项目 `plans/<...>/.ts`/`.py` 等继续走拦截链
- **位置**: `check-delegation.sh` `is_whitelisted_path()`
- **验证**: T21(.ts → exit 2)/T21b(.md → exit 0)
- **置信度**: HIGH

### M-6 [MAJOR] EOF-flush 补交叉校验
- **修法**: 提取 `_flush_phase()` 单函数(动态作用域写回 mode_stats 局部变量:total/delegated/main_direct_count/main_direct_json/violations_json)。Phase 头/## 分支/EOF 三处统一调用 `(_flush_phase "$current_executor" "$current_reason" "$current_phase_name" "$plan_file")`。函数内统一带 `colon-prefix 剥离` + Handoff 复合 Executor 按 + 拆分校验。EOF 分支从此获得完整校验(此前仅 delegated++ 不校验)
- **位置**: `check-delegation.sh` 新增 `_flush_phase()` + `mode_stats` 三处 flush 改调用
- **验证**: T13 Handoff 校验 + T15 复合 Executor + T16 部分缺失(现有 PASS)继续验证函数逻辑
- **置信度**: HIGH

### m-4 [MINOR] SKILL.md 悬空指针
- **修法**: `:397`「代码编辑三行(343-345)」→「(322-324)」(路由表实际行号);`:448`「反模式 379-381 行」→「(353-361)」(反模式列表实际行号)
- **位置**: `SKILL.md:397, :448`
- **验证**: 全文件 grep `\([0-9]+-[0-9]+\)` 类行号引用仅剩这 2 处且已 Read 复核准确
- **置信度**: HIGH

### m-5 [MINOR] 文案与实现对齐
- **修法**:
  - 「同会话仅一次」→「同 sid 仅一次 `/tmp/task-planner-bypass-<sid>`;同 plan-dir 二次 bypass 需 `--force`」
  - 「outcome 最高 PARTIAL」→「stats verdict=violation 或率<floor → check-complete.sh `exit 1` 阻断交付,须按 violations 清单回炉补 plan 或转 PARTIAL 重跑」
- **位置**:
  - `SKILL.md:38`(bypass 条款)/`:150`(委派率统计段)
  - `templates/verification.md:90`(委派率段)
- **验证**: 全文 grep「同会话仅一次」三处脚本层文案已更新;SKILL.md / verification.md 与 check-complete.sh:418 exit 1 路径对齐
- **置信度**: HIGH

## 3. 自测验证(35/35 全 PASS)

```
T01-T22 + T17/T17b/T18/T18b/T19/T19b/T20/T20b/T21/T21b/T22a/T22b/T22c
Total: 35    PASS=35  FAIL=0
```

- **基线 22 断言** PASS(B-1/M-1/M-2/M-3/M-4/M-5/M-6 修复未破坏既有路径)
- **新增 13 断言** PASS:
  - T17 白名单④ 不触发 self_declared
  - T17b 白名单标记 main_direct self_declared=0
  - T18 无理由 → missing_reason
  - T18b verdict=violation exit=1
  - T19 owner 多行注入 sid → 子代理放行
  - T19b owner 首行主进程 + 白名单外 → exit 2
  - T20 owner 缺失 → exit 0
  - T20b owner 缺失输出观察模式 (grep hit)
  - T21 plans/.ts → exit 2
  - T21b plans/.md → exit 0
  - T22a 同 sid 首次 on 成功
  - T22b 同 sid 二次 on 拒绝
  - T22c 不同 sid 独立放行

**幂等性**: 连续两次运行均 35/35 PASS,无状态残留。

## 4. 落盘产物(主仓)

- `/mnt/data/dev/task-planner-skill/plans/task-v055-scheduler-enforce/tmp/enforce-demo.txt`:
  - 追加「=== fix-review 批次 ===」段,含完整 35 断言输出 + exit_code=0
  - 文件 90 行 → 138 行(+48)

## 5. 已知遗留 / 下一迭代项

- **n-1 /tmp/task-planner-warn-${sid}.count 可预测文件名 + 跨 sid 计数报告** (check-complete.sh:429-437) — 未在本批范围,允许下一迭代收口
- **n-2 stats error JSON 在 check-complete 中被解析为 pass** — 未在本批范围
- **n-3 SKILL.md:46 锚点 `#code-review-gate...` 非标题** — 历史问题,本批未引入也未修
- **m-1 ledger bypass trigger 字段不记录 file_path** — 未在本批范围
- **m-2 Edit trivial 仅看 new_string 前 4KB 换行数** — 未在本批范围(双条件 old/new max 提案待实施评估)
- **m-3 占位检测死代码** — 已被 B-1/M-1 重写覆盖(白名单编号标识判定),死代码自然消除

## 6. 风险与回归评估

- **check-complete.sh 兼容性**: 本批修改 stats 输出 schema 未破坏 — `violations` 数组新增 `missing_reason` type,`check-complete.sh:387-394` 通过 `.violations | length` 聚合,不影响 verdict 计算
- **ledger 兼容性**: ledger 行增加 `sid`/`force` 字段(向后兼容,旧消费者不解析则忽略)
- **脚本 API**: `allow-direct.sh` 增加 `--force` 参数(向后兼容,旧调用无 `--force` 走原路径)
- **部署位同步**: 修复位于 worktree 分支,合并回 master 后由部署位拉取

## 7. 复验路径**

```bash
cd /mnt/data/dev/task-planner-skill-worktrees/task-v055-fix-review
bash skills/task-planner/scripts/selftest-delegation.sh
# 预期: 35/35 PASS,exit 0
git log --oneline -2
# 预期: 7ab28e2 fix(task-planner): task-v055 — CodeReview批修:...
#       1d73577 merge: task-v055-fix-composite — ...
```

## 8. 移交清单(merge 准备)

- [x] worktree 内 git status 干净
- [x] self 验证 35/35 PASS
- [x] commit hash 落 checkpoint
- [x] enforce-demo.txt 已追加 fix-review 段
- [x] 9 项修复全部 HIGH 置信度 + 实测
- [ ] 主仓合并: `git merge --no-ff wt/task-v055-fix-review` (待 VC/Verifier 复验)
- [ ] worktree 清理: `git worktree remove` + `git branch -d wt/task-v055-fix-review`