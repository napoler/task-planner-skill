# Verification Contract & Phase Gates

## Goal (1 sentence)
机器化强制小步快跑（attest S-unit 数值门控 + dispatch 长度/打包检测 + fmea_enforce 双点消费 + v063 遗留清理），全量 selftest 0 FAIL 后合并 master、部署 3 实体位并 push GitHub。

---

## Verification Contract（终验复验 2026-09-16，逐条带证据）

- [x] V1 attest 数值门控生效：主进程 attest 端到端夹具（16min+3 路径同行）rc=1 双违规齐捕 `✗ 预估时长 16min > step_max_minutes(15)` + `✗ 输入列 3 个文件路径` + 拒绝锁定；SKIPPED 空时长行放行；selftest-plan-dispatch 12/0（T09-T12）
  Evidence: progress.md P2 段 Test Results / worktree commit c506349 / /tmp/v075-baseline.txt
- [x] V2 check-dispatch 三项增量+selftest 22/0+默认档零回归：executor 基线四项 diff 一致（rc/stdout/stderr/计数文件）；主进程双探针（合规短 prompt 静默 rc=0；超长 5488 字符告警+enforce 阻断）；config default=enforce 实测已记 findings
  Evidence: progress.md P3 段 / commit 6c51c24 / selftest-dispatch FG-01..04
- [x] V3 fmea_enforce 三档分化可观测：三档×双点矩阵（attest+check-complete）全过；主进程双档探针复现（warn=⚠+锁定成功 / enforce=双 ✗+拒绝锁定）；selftest-methodology 11/0（M-08..M-11）
  Evidence: progress.md P4 段 / commit fdff22b
- [x] V4 全量 selftest 0 FAIL：主进程 worktree 逐脚本 19 个全 rc=0，逐 Total 行 PASS=/FAIL= 字段直加 **313 PASS/0 FAIL**（基线 301+新增 12 恰合）；lib/verify.sh 部署后复跑 **26 pass/0 fail**（P9 时 23/3 全为部署漂移中间态，P10 --deploy 后归零）
  Evidence: /tmp/v075-final.txt + progress.md P9 段 + P10 verify 复跑输出
- [x] V5 模板/文档同步无遗漏：`grep NNmin templates/task_plan.md` :184；rule-enhancement 模板 7 列表头 :55；「机器校验已生效」SKILL 3 处+critical-rules 3 处（V5 字面 grep 双文件达标，含 SendMessage 补丁一轮）；CHANGELOG 5 条目/README 2 处 task-v075 计数
  Evidence: progress.md P6/P7/P8 段 / commits 5d215b6, 9f75354, 23a2a45
- [x] V6 部署 3 实体位对账=0：smart-merge-back --deploy 输出 `IDENTICAL: /home/terry/.zcode` + `IDENTICAL: /home/terry/.claude` + `IDENTICAL: /home/terry/.config/opencode` + `全部部署位 IDENTICAL`
  Evidence: P10 smart-merge-back 输出（progress.md P10 段）
- [x] V7 push 后远端一致：`git push origin master` 3e9a451..d975ee0；`git rev-parse HEAD` = `git rev-parse origin/master` = d975ee07bb68d1fd97e726bc2a81b3811573910b；worktree 已 remove + `git branch -d` 已删，`git worktree list` 仅主仓
  Evidence: P10 git 输出（progress.md P10 段）

---

## Phase Gates

P1-P10 全部 complete（逐 Phase Status 字面量已翻转，见 task_plan.md Phases 表与各 Phase 段）：
P1 complete（worktree+基线 301/0）→ P2 complete（c506349）→ P3 complete（6c51c24）→ P4 complete（fdff22b）→ P5 complete（685b206）→ P6 complete（5d215b6）→ P7 complete（9f75354）→ P8 complete（23a2a45）→ P9 complete（313/0+APPROVED+9a45d3d）→ P10 complete（d975ee0 合并部署推送）。
派发严格串行（Rule 21.4）：全程任意时刻至多 1 个活跃子代理；8 次派发 + 2 次 SendMessage 原子补丁均逐一验收后放行下一个。

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| knowledge-brief §1-§5 | 各派发 prompt 材料包引用 §2/§3/§4 锚点；S-unit 输入列互链 | 符合 |
| template-gate 三档解析范式（attest-plan.sh:80-97） | P4 S1 resolve_fmea_tier 照抄同构（Code Review 档位一致性项过） | 符合 |
| selftest hermetic 夹具范式（selftest-methodology M-01..M-07） | T09-T12/FG-01..04/M-08..M-11 均 mktemp+trap 范式 | 符合 |

## 委派统计复验（Rule 25.4 — 机器统计）
```json
{"phases_total":10,"phases_delegated":7,"main_direct_count":3,"delegation_rate":0.700,"violations":[],"verdict":"ok"}
```
- [x] 主进程直做 P1/P9/P10 均登记白名单内例外理由（①git 编排 ②簿记 ③机械验证）
- [x] 委派率 0.700 ≥ delegation_rate_floor 0.7 且 stats verdict=ok → 不阻断

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查：触发 1 项（Rule 19.7 findings 两次未回填——[plan-compass] 升级警告），已**当轮回炉处置**（P5-P8 结论补填 findings + Error Log #1 登记 Root Cause/Prevention），无未处置违规；豁免 0 项
- [x] Evidence 抽查 ≥3 条：V1 attest 夹具输出（可复现命令）、V4 /tmp/v075-final.txt（可 Read）、V6 deploy IDENTICAL 输出（progress 可查）——均路径可 Read、结论可复现
- [x] Rule 26.3 处置：回炉已完成 → 不降级，outcome 维持 COMPLETE 判定依据（处置证据：findings.md P5-P8 行+P8 要点节、progress.md Error Log #1）
- [x] Rule 33 [reflect]：progress.md 已落反思/验证两行（见 P10 段）
- [x] Rule 31 Learning Gate：Error Log 4 行 Root Cause/Prevention 均非占位

## Goal Gate（终验）
```
## Goal Verification — 机器化强制小步快跑 + methodology 消费兑现，0 FAIL 合并部署推送
- [x] V1 attest 数值门控 → PASS
- [x] V2 dispatch 三项增量 → PASS
- [x] V3 fmea 三档分化 → PASS
- [x] V4 全量 313/0 + verify 26/0 → PASS
- [x] V5 模板/条款/文档同步 → PASS
- [x] V6 三部署位 IDENTICAL → PASS
- [x] V7 push 后 local==remote==d975ee0 → PASS
 outcome: COMPLETE
```

---

## 5-Question Reboot Check
| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | P10 终验完成，交付 COMPLETE |
| 2 | Where am I going? | 无剩余 Phase（deferred 6 项登记供后续轮） |
| 3 | What's the goal? | 见 Goal |
| 4 | What have I learned? | findings.md（A/B 缺口+P2-P8 落地裁定+config enforce 实测） |
| 5 | What have I done? | progress.md P0-P10 |
| 6 | Which tasks need processing? | 无（INDEX 已登记 ✓） |
