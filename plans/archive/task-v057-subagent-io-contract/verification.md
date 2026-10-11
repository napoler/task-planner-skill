# Verification Contract & Phase Gates

## Goal (1 sentence)

让每次 `Agent()` 派发都必传计划三文件绝对路径（含读写契约）并按 8 固定字段严格返回；用 PreToolUse hook 对 Agent 调用做机械检查——终结"靠主进程记得"的文本约束。

---

## Verification Contract（终验 2026-09-09，主仓 master 83282d2 合并后 + 3 位部署 + hook matcher 已改）

- [x] VC-1: 派发模板 §2「计划三文件（必传）」块 + 读写契约；§7 = 8 固定字段严格模板 + 已填示例 + "8 字段之后不得有任何内容"禁令
  Evidence: `templates/subagent_dispatch.md:11-17`（三路径 + task_plan 只读 / findings·progress 仅追加专属小节）；`:50-84` §7（`grep -c "^status: "` = 2 模板+示例；禁令 1；旧骨架 `[done|partial|failed|timeout]` 0）；§4 git 只读措辞 `:39`；§8 T5 "= 第 7 节同一 8 字段块"
- [x] VC-2: critical-rules 22.4 ② 输入含三文件、22.4a 读写契约、22.4b 严格返回、22.4c 机械守卫、22.5 复核替代回填、22.8.2 T5 同一 8 字段块、19.1 联动
  Evidence: `references/critical-rules.md:126`（首块 = 计划三文件 / 返回格式(8 固定字段严格模板,22.4b)）、`:127` 22.4a、`:128` 22.4b、`:129` 22.4c、`:130` 22.5 复核替代回填、`:135` T5、`:90` 19.1 尾注；212 行
- [x] VC-3: `scripts/check-dispatch.sh` 合规 exit 0 / 缺项 enforce exit 2 + 缺项清单 / warn exit 0 + 告警计数 / off 0 / 无活跃计划 0（fail-open）；`selftest-dispatch.sh` 12/12
  Evidence: 主进程独立复跑（合规 0 / 缺项 2 列 findings.md,progress.md,acceptance:… / warn 0 + `[dispatch-warn]`）；部署位 `selftest-dispatch.sh` → `Total: 12 PASS=12 FAIL=0`；off 反验 FAIL=1（非恒真）；plan_dir 尾斜杠/symlink 归一化（code review 修复，T12）
- [x] VC-4: zcode-pretooluse.sh `Agent)` 分支（读 `.tool_input.prompt` → 临时文件 → check-dispatch → rc=2 透传，mktemp/jq 失败 exit 0）；config.json `dispatch_contract_enforce`（enforce/warn/off，默认 enforce）jq 合法
  Evidence: `scripts/zcode-pretooluse.sh:54-66`；`jq -r .properties.dispatch_contract_enforce.default` = enforce；Write|Edit|ApplyPatch 分支零改动（code review c3 + diff）
- [x] VC-5: 文档对齐：plan-writer.md:94 / template-guide.md:57 八→九字段（Batch 八字段 :79/:56 保留）；SKILL.md 500 行 / P0 10 / 含 22.4a·22.4b·check-dispatch；INSTALL 5.1a matcher 须含 Agent；README:19
  Evidence: `grep -c 八字段` plan-writer=1 template-guide=1；`wc -l SKILL.md` = 500；`grep -c 22.4a SKILL.md` = 2；INSTALL `### 5.1a`@179 < `### 5.2`@183；README `matcher 须含 Agent` = 1；plan-writer 禁止行为补"测试类 ≤6 用例/步"@186
- [x] VC-6: worktree 内 selftest-delegation 38/38 + selftest-fallback 21/21 + selftest-dispatch 12/12；verify.sh 仅 deploy drift；合并后 3 位 diff=0、verify 25/0 ×3；plan-writer agent 副本 ×2 对齐
  Evidence: subagent-state/14-code-runner-p6.md（8/8）；部署 `diff -rq` = 0 ×3（101 文件）；verify.sh 25 pass / 0 fail ×3（全部部署后复跑）；`~/.zcode/agents/plan-writer.md` cmp IDENTICAL、`~/.claude/agents` 仅 model 行
- [x] VC-7: hook matcher 注册 `Write|Edit|Agent`（用户授权 `+hook`）；机制实测
  Evidence: `~/.zcode/cli/config.json:38` diff `"Write|Edit"`→`"Write|Edit|Agent"`（jq 合法，备份 /tmp/zcode-cli-config-backup-20260909-063756.json）；等效实测（本会话 sid + 仓根 cwd + 已部署 hook）：缺契约 rc=2 列 7 缺项 / 合规 rc=0 / Read rc=0；**本会话内派缺契约 Simple Agent 未被拦 = hook 注册会话启动固化（同 v055 结论），新会话起生效**
- [x] VC-8: （用户授权 `+fix`）check-complete.sh 委派率比较反转修复 + check-delegation.sh 记忆目录白名单 + selftest-delegation 3 用例
  Evidence: `scripts/check-complete.sh:404` `exit (r+0 < f+0)`（旧 0 处）；`scripts/check-delegation.sh:171` `"$HOME/.zcode/cli/memories/"*) return 0`；selftest T_MEM/T_RATE_OK/T_RATE_LOW → 38/38；**生产验证：本任务 check-complete.sh `DELEGATION GATE PASSED (rate=0.714 >= floor=0.7)`，真实 exit 0**（v056 时同数据假阴性 exit 1）

---

## Phase Gates（摘要 — 详细见 progress.md）

| Phase | Done when | Verification | Status |
|-------|-----------|--------------|--------|
| 1 调研+计划 | 用户 yes +hook +fix | V-1.1 attest 1e74bcc7 ✓ | complete |
| 2 规则层 | 3 S-unit 串行 | V-2.1 VC-2 ✓；commit 5b9467e | complete |
| 3 模板+config | S1∥S3 + S2 | V-3.1 VC-1 ✓；V-3.2 VC-4 config ✓；commit bd4cd2c | complete |
| 4 守卫+selftest+D5 | S1∥D5 → S2 → S3 | V-4.1 VC-3 ✓；V-4.2 VC-4 hook ✓；V-4.3 VC-8 ✓；commit 2944bf8 | complete |
| 5 文档 | 3 并行 | V-5.1 VC-5 ✓；commit c67af56 | complete |
| 6 验证 | code-runner 8/8 | V-6.1 VC-6 worktree 部分 ✓（mini 违约 4 项已纠正） | complete |
| 7 review+合并+部署+hook+终验 | 全 VC | V-7.1 review 6/6（fix 1d2fbf4）✓；V-7.2 merge 83282d2 ✓；V-7.3 VC-6/7 ✓；V-7.4 check-complete exit 0 ✓ | complete |

---

## 📚 必要知识储备符合性核验

| 必读知识源 | 核验方式 | 结论 |
|-----------|----------|------|
| 派发模板现状（85 行） | §2/§7 改动对照原结构 | 符合 |
| hook 入口 case 结构 + matcher 现值 | Agent 分支插入位置 / matcher 唯一性（全文仅 1 处） | 符合 |
| 22.4/22.5/22.8 现文 | 派发 prompt 逐字引用 old→new | 符合 |
| v056 遗漏与缺陷（R4-R7） | 八字段残留清零 / check-complete 反转修复生产验证 / 记忆白名单 | 符合 |
| 部署拓扑 + agent 2 位 + install-companion 陷阱 | 定向 cp，未跑分发脚本 | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":7,"phases_delegated":5,"delegation_rate":0.714,"verdict":"ok","violations":[]}
```
- [x] 主进程直做 Phase 1（② 计划 + ③ 只读 grep）/ Phase 7（① git 编排 + ② 簿记 + ④ 用户授权的 config 一行）均在白名单
- [x] 委派率 0.714 ≥ 0.7；verdict ok；**check-complete.sh exit 0（修复后）**
- 子代理明细：16 次派发 = executor ×13（Phase 2 串行 3 / Phase 3 并行 2+1 / Phase 4 并行 2+串行 2 / Phase 5 并行 3 / Phase 7 fix 1）+ code-runner ×1 + Code Reviewer ×1 + Simple Agent ×1（守卫实测）；0 改派 / 0 降档 / 0 主进程接管

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 0 项，豁免 0 项，未处置 0 项（Q4：Handoff 17 行 verify_done 全 ☑，每行主进程 Read/命令复核）
- [x] Evidence 抽查 ≥3：① `grep -n '^22.4[abc] ' critical-rules.md` → 127/128/129 ✓；② 部署 hook 等效实测 rc=2/0/0 复现 ✓；③ `check-complete.sh` 真实 exit 0 复现 ✓；④ `diff -rq` 3 位 = 0 复现 ✓
- [x] 豁免登记：无

## Goal Gate

```
## Goal Verification — 子代理 I/O 契约（三文件必传 + 8 字段严格返回 + 机械守卫）
- [x] VC-1 模板三文件块 + 严格 §7 → PASS
- [x] VC-2 规则 22.4a/b/c + 22.5/T5/19.1 → PASS
- [x] VC-3 check-dispatch + selftest 12/12 → PASS
- [x] VC-4 hook Agent 分支 + config 键 → PASS
- [x] VC-5 文档对齐 → PASS
- [x] VC-6 验证 + 部署 25/0×3 + agent 副本 → PASS
- [x] VC-7 matcher 已改 + 机制等效实测 → PASS（会话内即时拦截受平台固化限制，新会话生效）
- [x] VC-8 D5 两缺陷修复 + 生产验证 → PASS

 outcome: COMPLETE
```

**遗留（非阻塞，建议后续立项）**：
1. **子代理写计划文件的机械守卫**：mini 档 code-runner 违反三文件契约 4 项（翻 Status / 填满段 / 占位符 / **findings.md 整体拼接两遍**，已由主进程复核纠正）。建议 PostToolUse 对子代理 Edit/Write `plans/*/{findings,progress}.md` 做 diff 校验：只允许净增行、禁止 `**Status:**`/`**Started:**` 变更、行数增幅 >50% 即回滚告警；task_plan.md 对子代理直接拒写
2. **Claude Code 侧同等守卫**：其子代理工具名为 `Task`，需在 `register-hooks-cj.ts` PreToolUse matcher 加 `Task` 并复用 check-dispatch.sh（INSTALL 5.1a 已注明）
3. **验证类任务改派 haiku-1 executor**：mini runner 两次任务（v056 738K / v057 518K token）均 2 倍于 executor 且契约遵守差
4. **测试类 S-unit 拆分**：11 用例单步 18min/1.24M token 超 step_max_minutes——plan-writer 已补"≤6 用例/步"纪律，需在下次派发中验证
5. hook 变更需新会话生效（平台属性）；TodoWrite 参数偶发 `\r` 序列化异常（harness 侧，不影响计划文件）

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 7 complete — 已交付 COMPLETE |
| 2 | Where am I going? | 无剩余 Phase；遗留 1-5 待立项 |
| 3 | What's the goal? | 见上 Goal |
| 4 | What have I learned? | findings.md R1-R5 + 16 个子代理小节 |
| 5 | What have I done? | progress.md Phase 1-7 + Error Log 5 条 |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（pending=0） |
