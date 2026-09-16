# Verification Contract & Phase Gates

## Goal (1 sentence)

落地 Rule 36 技能修改保守化与功能删除防护（36.1-36.7 七子条 + skill_modify_enforce 三档键 + check-skill-modify.sh 守卫接线 + SKILL-MODIFY GATE + selftest 守护 + SKILL 联动与 1-36 锚级联），全量 selftest 0 FAIL 后合并 master 并部署 3 实体位。

---

## Verification Contract（终验逐条）

- [x] VC-1: Rule 36 条款完整且既有行零改写
  Evidence: `grep -cE '^36\.[1-7] '` = 7（critical-rules.md @L305-311）；36.2 含 31.3 衔接句（grep=1）；`git diff 187194b HEAD --stat -- references/critical-rules.md` = 12 insertions(+) 0 deletions（Rule 28/31/32/35 既有行零改写）；36.4 D6 引用句在位（progress.md P2 段）
- [x] VC-2: config 键三档默认 warn
  Evidence: `python3 json.load` → `warn ['enforce','warn','off']`；键位 @config.json L311-316（template_gate_enforce 后，additionalProperties:false 不破）
- [x] VC-3: 消费侧三件实测
  Evidence: ① check-skill-modify.sh（新建 92 行）三档实跑：enforce 未授权 rc=2+BLOCKED / warn 注入 additionalContext JSON / off 静默；已授权（scope token 子串）enforce 档 rc=0 授权优先——主进程亲测（progress.md P2 段 + subagent-state/08-executor-s5.md 六条证据）② `grep -c check-skill-modify zcode-pretooluse.sh` = 2（L57 调用+注释）③ `grep -c 'SKILL-MODIFY GATE' check-complete.sh` = 6（resolve_skill_modify_tier + REFLECT-GATE 后追加，fixture 六场景 rc 正确，subagent-state/09-executor-s6.md）
- [x] VC-4: 全量 selftest 0 FAIL（主进程机械求和）
  Evidence: 任务分支终跑 21 脚本 **346 PASS / 0 FAIL**（subagent-state/p4-regression-final.md，主进程按'='分列 awk）；**合并后 master 重跑 21 脚本 349/0**（p5-merged-regression.md，=337 基线+v079 新增 9+v078 并行新增 3，账目吻合）；首跑 344/2（行数断言越限）→ B 类扩围修复（Decisions ⑧）→ 终跑归零
- [x] VC-5: SKILL 联动四件 + 锚级联零残留 + 3 实体位 diff=0
  Evidence: `grep -c 'Rule 36' SKILL.md` = 5、`| C24 |` @L198、特判段 @L219、frontmatter/索引 1-36（SKILL.md 541 行，净增 3 ≤10）；`grep -rn 'Rules 1-35' SKILL.md README.md references/` = 0（唯一命中为自条款示例，已泛化 `Rules 1-N→1-N+1`）；smart-merge-back --deploy rc=0 + 主进程 `diff -r` 三实体位（~/.zcode、~/.claude、~/.config/opencode）全 IDENTICAL + 关键件抽查（7 条款/1 键/2 接线）三处一致

---

## Phase Gates

### Phase 1: 隔离与基线
**Done when**: worktree 建于集中目录 + 基线定数 + 锚点复验
- [x] V-1.1: worktree@187194b 干净（→ VC-4 基线）
- [x] V-1.2: 基线 20 脚本 337/0（主进程求和，弃子代理自报 352）
Status: `complete` Last verified: 2026-09-17

### Phase 2: 条款 + config 键 + 消费侧门控
**Done when**: S3-S6 串行验收 + commit 144664e
- [x] V-2.1: VC-1/VC-2 证据（上表）
- [x] V-2.2: VC-3 三件实测（上表）
Status: `complete` Last verified: 2026-09-17

### Phase 3: selftest 守护 + 锚点级联
**Done when**: SM 全绿 + 四 selftest 锚宽容化 + commit 041fc0e
- [x] V-3.1: selftest-skill-modify 9 断言（SM-08 P4 后自动转实 9/9）
- [x] V-3.2: CD 23/23、RV 12/12、VT 13/13、EL 16/16 主进程亲跑；功能性严格锚残留=0
Status: `complete` Last verified: 2026-09-17

### Phase 4: SKILL 联动 + 全量回归
**Done when**: 联动四件 + 回归 0 FAIL + commit fa19384
- [x] V-4.1: 联动/级联/净增证据（VC-5）
- [x] V-4.2: 终跑 346/0（首跑 2 FAIL → B 类扩围 Decisions ⑧ → 归零）
Status: `complete` Last verified: 2026-09-17

### Phase 4.5: Code Review Gate
**Done when**: APPROVED
- [x] V-4.5: Code Reviewer 上下文隔离审查 10 个 .sh → **APPROVED**（bash -n 全过/退出码语义/注入面/跨会话授权实测；建议项 SID 拼接保持现状）
Status: `complete` Last verified: 2026-09-17

### Phase 5: 合并回 + 部署 + 簿记
**Done when**: merge --no-ff + 部署亲验 + 清理
- [x] V-5.1: merge 8aba15d（15 文件 239+/24-，与 scope 精确一致）；合并后 master 全量 349/0（Base 漂移处置，v078 并行交付）
- [x] V-5.2: 三实体位 IDENTICAL；worktree/分支清零（git worktree list 仅主仓）
Status: `complete` Last verified: 2026-09-17

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 01-explore-conventions.md | Rule 31/32 范式被 S3 条款采用；GATE 追加范式被 S6 采用；pretooluse 接线点被 S5 采用 | 符合 |
| 02-rule36-design-brief.md | 36.1-36.7 逐字采用（S3）；机制三件落地（S5/S6/S7） | 符合（条款排版密度对齐 31.x，单行密排） |
| critical-rules.md Rule 31/32 坟 | 36.2/36.4 衔接句在位 | 符合 |
| knowledge-brief.md | 全程 22.4 材料包引用（8 次派发均过 check-dispatch brief 锚检查） | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":5,"phases_delegated":2,"main_direct_count":3,"delegation_rate":0.400,"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 白名单理由：P1=① git 编排；P4 定数=③ 机械求和；P5=①③ 部署/push（另有 ⑤ 接管一次：36.1 示例泛化单行修订，progress.md P5 段登记）
- [x] 委派率 0.400 < 0.7 但全部直做理由命中白名单 → **WHITELIST-EXEMPT 放行**（机器 verdict=ok，violations=[]）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 核查：触发 1 项（Q4 类——S10 首跑 2 FAIL 属测试先行暴露，当 Phase 内回炉归零，无降级）；豁免 0 项；未处置 0 项
- [x] Evidence 抽查 ≥3 条：VC-1 grep/VC-2 python3/VC-3 三档实跑/VC-4 双份全量落盘——均可 Read 可复现
- [x] 豁免登记：无
- [x] 未处置违规：无 → outcome 不降级

## Goal Gate 终验

```
## Goal Verification — 落地 Rule 36 技能修改保守化与功能删除防护
- [x] VC-1: 条款七锚+零改写 → PASS
- [x] VC-2: config 键 warn 三档 → PASS
- [x] VC-3: 守卫/GATE 实测 → PASS
- [x] VC-4: 346/0 + 合并后 349/0 → PASS
- [x] VC-5: 联动+级联零残留+三位 IDENTICAL → PASS

 outcome: COMPLETE
```

**交付说明（静默决策清单供复核）**：① D1 批准询问未获答复按 harness 自主指令转 silent（Decisions ⑤）② S8 锚宽容化策略（⑥）③ S8 拆两次派发（⑦）④ S10 行数断言 B 类扩围（⑧）⑤ 36.1 示例泛化（P5 白名单⑤ 接管）。

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 终验 COMPLETE |
| 2 | Where am I going? | 交付报告+push+memory |
| 3 | What's the goal? | 见上 |
| 4 | What have I learned? | findings.md（并行会话 base 漂移/awk 计数陷阱/宽容锚两阶段策略） |
| 5 | What have I done? | progress.md P1-P5 |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
