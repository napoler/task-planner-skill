# task-v117 P3-S1 executor 批次 1 — 42 selftest 全量回归（worktree 场，只读）

执行时刻: 2026-10-02 | 场: /mnt/data/dev/task-planner-skill-worktrees/task-v117 @ HEAD=7b9ff95
完整输出: /mnt/data/dev/task-planner-skill/plans/task-v117/subagent-state/p3-selftest-results.log
清单口径: `ls selftest-*.sh | wc -l` = 42（含 selftest-registry.sh，registry 行=42/actual=42 自守护 PASS）
未使用 registry 统一入口（registry.tsv 无聚合 runner 脚本，逐脚本 bash 执行）

## 结果表（脚本 | rc | FAIL 数 | 首条 FAIL 摘要）

| 脚本 | rc | FAIL | 首条 FAIL |
|------|----|------|-----------|
| selftest-active-plan.sh | 0 | 0 | NOFAIL (19/19) |
| selftest-ask-default-timeout.sh | 1 | 1 | RT-08 FAIL 越界 1-4x 字面命中（CRIT 44 节=0 / SKILL.md=1,均应 0） |
| selftest-batch-pilot.sh | 0 | 0 | NOFAIL (10/10) |
| selftest-check-conflicts.sh | 0 | 0 | NOFAIL (7/7) |
| selftest-check-drift.sh | 0 | 0 | NOFAIL (6/6) |
| selftest-conclusion-discipline.sh | 1 | 1 | CD-12 FAIL SKILL.md '1-3[5-8]' 计数 ≥3（兼容 1-35-38 过渡，当前=2）（断言体 :62，消息标签沿用 1-34 旧名） |
| selftest-context-hygiene.sh | 0 | 0 | NOFAIL (12/12) |
| selftest-delegation.sh | 0 | 0 | NOFAIL (38/38) |
| selftest-dispatch.sh | 0 | 0 | NOFAIL (31/31) |
| selftest-error-loop.sh | 0 | 0 | NOFAIL (16/16) |
| selftest-execution-stability.sh | 0 | 0 | NOFAIL (19/19) |
| selftest-fallback.sh | 0 | 0 | NOFAIL (31/31) |
| selftest-final-gate-hash.sh | 0 | 0 | NOFAIL (22/22) |
| selftest-fine-grain-steps.sh | 0 | 0 | NOFAIL (11/11) |
| selftest-interaction.sh | 0 | 0 | NOFAIL (11/11) |
| selftest-iterative-optimizer.sh | 0 | 0 | NOFAIL (8/8) |
| selftest-knowledge-brief.sh | 0 | 0 | NOFAIL (16/16) |
| selftest-mechanism-profile.sh | 0 | 0 | NOFAIL (19/19) |
| selftest-methodology.sh | 0 | 0 | NOFAIL (16/16) |
| selftest-plan-dispatch.sh | 0 | 0 | NOFAIL (12/12) |
| selftest-plan-tier.sh | 1 | 1 | PT-08 FAIL SKILL.md frontmatter 缺「1-39」 |
| selftest-reflect-verify.sh | 0 | 0 | NOFAIL (12/12) |
| selftest-registry.sh | 0 | 0 | NOFAIL (5/5, registry rows=42, actual=42) |
| selftest-reliability-institution.sh | 0 | 0 | NOFAIL (12/12) |
| selftest-rescue-chain.sh | 0 | 0 | NOFAIL (11/11) |
| selftest-review-library.sh | 0 | 0 | NOFAIL (15/15) |
| selftest-rule23-conflict-scan.sh | 0 | 0 | NOFAIL (3/3) |
| selftest-self-resolution.sh | 0 | 0 | NOFAIL (13/13) |
| selftest-shared-tracker.sh | 0 | 0 | NOFAIL (11/11) |
| selftest-skill-collab.sh | 0 | 0 | NOFAIL (25/25) |
| selftest-skill-modify.sh | 0 | 0 | NOFAIL (9/9, SKIP=0) |
| selftest-skill-split.sh | 0 | 0 | NOFAIL (41/41) |
| selftest-smart-merge.sh | 0 | 0 | NOFAIL (17/17) |
| selftest-sync-index.sh | 0 | 0 | NOFAIL (13/13) |
| selftest-task-boundary.sh | 0 | 0 | NOFAIL (11/11) |
| selftest-template-lifecycle.sh | 0 | 0 | NOFAIL (21/21) |
| selftest-template-sense.sh | 0 | 0 | NOFAIL (8/8) |
| selftest-tier-b.sh | 0 | 0 | NOFAIL (18/18) |
| selftest-tool-selection.sh | 0 | 0 | NOFAIL (12/12) |
| selftest-vc-gate.sh | 0 | 0 | NOFAIL (11/11) |
| selftest-veto.sh | 0 | 0 | NOFAIL (13/13) |
| selftest-workflow-orchestration.sh | 0 | 0 | NOFAIL (16/16) |

汇总: 39/42 rc=0，3 FAIL。

## FAIL 项根因初判（只读 grep/Read 定位，未修）

### FAIL-1 RT-08 — selftest-ask-default-timeout.sh（v117 P1 引入的新 FAIL，严重度中）
- 证据: skills/task-planner/scripts/selftest-ask-default-timeout.sh:60 `b="$(grep -cE '1-4[0-9]' "$SKILLMD")"` 应=0；SKILL.md:9 命中 `Critical Rules 全集 1-45`（P1 321ae79 将「全集 1-39（含 40-45）」具名为「全集 1-45（…45 注释完整性规范）」，+「1-45」字面）
- 判定面: 仅 1 处（SKILL.md:9），非 44 节越界（CRIT 44 节=0 PASS）
- 根因初判: P-5 裁决「具名补齐 37-45」把 1-45 写进 frontmatter，与 RT-08 负断言口径（v44 时点设立，防 1-4x 越界字面）冲突。守卫意图=防「引用不存在的 44 之后规则」，而 45 在 v44 时点尚未存在 → RT-08 为过期口径
- 处置建议（供主进程）: RT-08 口径更新为 `1-4[0-4]`（45 已登记在 critical-rules 全集，越界=≥46），或 SKILL.md:9 改回括注式「全集 1-39（含 40-45）」绕开 1-4x 字面；两案需主进程定夺（改守卫=守卫面变更；改 SKILL=回退 P-5 具名裁决，不建议）
- 分类: v117 P1 引入（非 v116 WF-10 同款）

### FAIL-2 CD-12 标签/宽容锚失配 — selftest-conclusion-discipline.sh（v117 P1 引入的新 FAIL，严重度中）
- 证据: scripts/selftest-conclusion-discipline.sh:61-63 断言体 `n35=$(grep -cE '1-3[5-9]' "$SKILL"); test $n35 -ge 3`，消息标签沿用旧名「1-3[5-8]」且注释残留「当前=2」误导；P1 前（fad9138）SKILL.md 命中 1-3[5-9]=3（含 frontmatter「Critical Rules 全集 1-39」行）+「Critical Rules 全集 1-39」=1；P1 后 frontmatter 行改为「全集 1-45」，1-3[5-9] 命中降为 2（仅 :247/:305 正文 1-39）< 3
- 判定面: SKILL.md:247/:305 两处 1-39 仍在，:9 frontmatter 是唯一失配面
- 根因初判: 与 FAIL-1 同源（P-5 具名改动使 frontmatter 退出宽容锚判定面）；CD 侧守卫 v44 时点尚未把 1-3[5-9] 面纳入（脚本注释 :25 声明过渡口径为 [5-7]，断言体 [5-9]，本就半失配，P1 前恰好 3 压线通过）
- 处置建议（供主进程）: 与 RT-08 同批扩口径——或断言面改为「1-3[5-9] 或 1-45」双锚合计 ≥3（守住过渡兼容意图），或阈值降 ≥2（需主进程定夺）
- 分类: v117 P1 引入（同根因）

### FAIL-3 PT-08 — selftest-plan-tier.sh（v117 P1 引入的新 FAIL，严重度中）
- 证据: scripts/selftest-plan-tier.sh:75 `grep -q 'Critical Rules 全集 1-39' "$SKILLMD"` 0 命中（该字面在 P1 前 frontmatter 存在，P1 改「全集 1-45」后消失；正文 :247 的写法为「Rules 1-39（含…」非「Critical Rules 全集 1-39」）
- 判定面: 仅 frontmatter 单面
- 根因初判: 同根因（P-5 具名改 SKILL.md:9），PT-08 字面锚过期；v116 前该断言以 frontmatter 面通过
- 处置建议（供主进程）: PT-08 字面锚更新为「全集 1-45」（或双字面 `全集 (1-39（含|1-45)` 容过渡），与 RT-08/CD-12 同批
- 分类: v117 P1 引入（同根因）

### 排除项
- WF-10（预期 FAIL）: 实测 rc=0 PASS（16/16）。v116 fad9138 已把守卫扩为「Rules 1-39 + Rules 1-45 合计 ≥6」；P1 后现行口径实测=SKILL 2+0 / CLAUDE 1+0 / README_zh 0+2 / skills-README 1+0 合计=6，恰好压线通过（与 knowledge-brief §2「P-1 后 4<6」的 v116 旧口径预测不同——v116 扩口径已在 7b9ff95 前入库，预测基于旧守卫文本）。主进程「同步扩守卫口径」可跳过 WF-10（已扩），但零余量=后续任何索引面文案改动再破 6 即 FAIL，风险登记
- knowledge-brief §2 预测「其余 41 个脚本预期 0 FAIL」未兑现: 实际 3 FAIL（RT-08/CD-12/PT-08），三者同根因=P1 commit 321ae79 的 SKILL.md:9 具名改动
- 负结果申报: 42 脚本全跑；未触碰任何文件（git status 干净，worktree porcelain 无输出）；已排除「守卫脚本自身被 P2 改动」风险（P2 7b9ff95 仅动 29 variant .md，SKILL/README/CLAUDE 触碰=0）

## 最终结论
- status: **partial**（39/42 rc=0；3 FAIL 全部同根因=v117 P1 321ae79 SKILL.md:9 具名改动撞 v44 时点旧口径守卫，无 P2 或仓外因素引入；非 WF-10 预期项——WF-10 已 PASS）
- 下一步（主进程裁决面）: 三守卫（RT-08/CD-12 断言体/PT-08 字面）批量扩口径 1-45（同 WF-10 v116 处置范式）→ 重跑 3 脚本回归 → 42/42 后放行 S2 smart-merge-back
- 禁改面遵守: 本 executor 零文件改动（只读跑测+输出落盘）

---
# M2 里程碑 — task-v117 P3-S1b 三守卫口径扩展（executor 批次 2，worktree 写场）

执行时刻: 2026-10-02 | 场: /mnt/data/dev/task-planner-skill-worktrees/task-v117 @ HEAD=7b9ff95（未 commit，主进程保留禁 git commit 约束）

## diff --stat（3 文件，15 insertions / 9 deletions）
```
skills/task-planner/scripts/selftest-ask-default-timeout.sh   | 10 ++++++----
skills/task-planner/scripts/selftest-conclusion-discipline.sh |  9 ++++++---
skills/task-planner/scripts/selftest-plan-tier.sh             |  5 +++--
3 files changed, 15 insertions(+), 9 deletions(-)
```

## 逐守卫处置（锚口径扩展，断言语义零改动，行内 label「task-v117 口径扩展」）
1. **RT-08**（selftest-ask-default-timeout.sh:60-66）：负断言 `grep -E '1-4[0-9]'` 改加白形态——命中行经 `grep -vcE '1-45'` 剔除合法「1-45」后计数，越界口径=除 1-45 外的 1-4x 字面（1-46..1-49），语义=防越界规则引用不变
2. **CD-12 断言体即 CD-11 宽容锚**（selftest-conclusion-discipline.sh:62-66，M1 段「断言体 :62」处）：双锚扩面 `n35(1-3[5-9]) + n45(1-45)` 合计 ≥3，阈值不变；注释同步清残留「当前=2」误导；实测 2+1=3 压线通过
3. **PT-08**（selftest-plan-tier.sh:75-76）：字面锚 `Critical Rules 全集 1-39` → `Critical Rules 全集 1-45`（frontmatter 索引面存在性守护，语义等价演进，同 WF-10 先例）

## 重跑结果
- 3 脚本单独重跑：ask-default-timeout rc=0（9/9）/ conclusion-discipline rc=0（24/24）/ plan-tier rc=0（32/32）
- 42 全量重跑（逐脚本 bash，输出 /tmp/t117-full/rc.log）：**42/42 rc=0，FAIL=0**
- WF-10（selftest-workflow-orchestration.sh）：rc=0 Total 16 PASS=16 FAIL=0（v116 双口径 ≥6 压线 6=6 维持 PASS，零余量风险登记不变）
- `git status --short` 仅 3 脚本 M；主仓 /mnt/data/dev/task-planner-skill 零触碰；未 git commit（遵守禁改面）

## 最终结论
- status: **done**（3 脚本 rc=0 + 42/42 rc=0 + WF-10 维持 PASS；改动=3 脚本锚断言行+行内注释 label，断言语义零改动；SKILL.md 未触碰）
- 风险：① CD-11 双锚 2+1=3 零余量，后续索引面文案再改任一命中面即 FAIL（同 WF-10 性质）② RT-08 加白 1-45 后，若未来全集 1-46+ 越界字面出现将被捕获，口径自洽 ③ 三脚本为 worktree 未 commit 态，S2 smart-merge-back 前主进程须放行 42/42 后 commit
- 负结果申报：无——未发现 42 全量中其他异常；排除「主仓被触碰」「commit 误发生」风险（git status 仅 3 脚本 M，HEAD 未动）
