# Verification Contract & Phase Gates

## Goal (1 sentence)

新建 complex-planner agent（GLM5.3 完整版/Opus 级）作为高复杂度任务的解决规划备用方案：canonical 入库 + 部署 zcode/claude 2 位 + skill-agent-router 路由登记。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.

- [x] VC-1: canonical 文件 frontmatter 四要素完整（name/tools/model 双引号 GLM 裸式/thoughtLevel）
  Evidence: `<worktree已合并→master>/skills/task-planner/companion/agents/complex-planner.md:2,4,5,6`——主进程 Read 一手复核（findings R8）；model 行=`model: "account:zai-individual-coding-plan/GLM-5.3"`
- [x] VC-2: description 含高复杂度门控语义+≥3 触发词+分工边界句
  Evidence: 同文件 `:3`——含「仅当任务复杂度过高(跨模块架构级/高不确定/常规档sonnet/haiku同法失败≥2次)才启用」+ 触发词 5 个（complex planning|升级规划|备用方案|任务过于复杂|deep plan）+「禁用:常规/单文件/低复杂度任务」
- [x] VC-3: 正文五段锚+禁用清单+证据要求+禁止行为齐全
  Evidence: 同文件 `:13 触发门槛 / :18 禁用清单 / :23 规划产出契约（五段 :24-28）/ :30 证据要求 / :37 禁止行为`
- [x] VC-4: 全量 selftest 回归 fail=0（基线 42 脚本不降）
  Evidence: worktree 内 `TOTAL=42 FAIL=0` + smoke `17 pass / 0 fail`（progress.md Phase 2 Test Results；subagent-state/2-code-runner-agent.md）
- [x] VC-5: 部署 2 位到位（zcode 位 md5=canonical；claude 位仅 model 行=opus）
  Evidence: md5 `6bcf4195a5669d0cbff476ecf9046a03` 双位一致；diff 输出仅 `5c5 model: "account:zai-individual-coding-plan/GLM-5.3"` → `model: opus`（progress.md Phase 4 段；部署前 ls 确认目标原不存在=纯新增无覆盖）
- [x] VC-6: skill-agent-router 路由表 complex-planner 行在位
  Evidence: `~/.zcode/skills/skill-agent-router/SKILL.md:98`（主进程 Read :92-103 一手复核；表行 55→56；`~/.agents/skills/skill-agent-router/` 不存在=计划预期分支记行跳过）
- [x] VC-7: 合并回完成+worktree/分支清理
  Evidence: `git log` 含 `a4bbd19 Merge branch 'wt/task-v119'`（b7e8988 Phase 1 提交随之入 master）；`git worktree list` 仅剩并行任务的 task-v118；`git branch` 无 wt/task-v119

---

## Phase Gates

### Phase 1: 撰写 complex-planner.md（worktree 内）
**Done when**: 文件按规格逐字落盘+三组 grep 断言过
**Verification**:
- [x] V-1.1 → VC-1（frontmatter 四要素）
- [x] V-1.2 → VC-2（门控语义）
- [x] V-1.3 → VC-3（五段锚）
Status: `complete` Last verified: 2026-10-03（主进程 Read 一手复核，非子代理自报采信）

### Phase 2: 全量 selftest 回归
**Done when**: 42 脚本 FAIL=0
**Verification**:
- [x] V-2.1 → VC-4（TOTAL=42 FAIL=0）
- [x] V-2.2 → VC-1（回归不破坏既有断言）
Status: `complete` Last verified: 2026-10-03（执行体=主进程接管白名单③：provider 2 连拒后 Rule 22.7 换道）

### Phase 3: skill-agent-router 路由登记
**Done when**: 路由表 +1 行且列对齐
**Verification**:
- [x] V-3.1 → VC-6（:98 行在位）
Status: `complete` Last verified: 2026-10-03（主进程 Read :92-103 复核）

### Phase 4: 合并回 + 部署 2 位 + 终验簿记
**Done when**: merge 落 master + 2 位部署复验 + 全 VC 复验
**Verification**:
- [x] V-4.1 → VC-5（md5+diff）
- [x] V-4.2 → VC-7（merge a4bbd19 + 清理）
Status: `complete` Last verified: 2026-10-03

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| ListModels 模型清单 | model 行值与清单 id 逐字一致 | 符合（`account:zai-individual-coding-plan/GLM-5.3`） |
| complex-problem-solver 结构先例 | 新 agent frontmatter 五字段同构 | 符合（name/description/tools/model/thoughtLevel） |
| executor.md 裸式 model 行先例 | 双引号裸 providerId/modelId 同构 | 符合（引号为 D2 防御性增强，已登记） |
| 路由表锚 :97 | 新行插 :98 紧随其后、列对齐 | 符合 |
| 守卫面调研（selftest 锚 plan-writer） | 回归 42/0 | 符合（零破坏实证） |

## 委派统计复验（Rule 25.4）

JSON 输出（机器口径）：
```json
{"phases_total":4,"phases_delegated":2,"main_direct_count":2,"delegation_rate":0.5,"violations":[],"verdict":"ok"}
```
（修正 Handoff 裸类型名后复跑：rate 0.5，violations 0，verdict ok）

- [x] 主进程直做 Phase 均在白名单内：Phase 2=白名单③（机械验证命令，provider 2 连拒后 Rule 22.7 换道接管）；Phase 4=白名单①②（git/worktree 编排+簿记；部署 cp 属编排）
- [x] 委派率 0.5 < 0.7 但全部直做理由命中 Rule 25.3 六项白名单 → **WHITELIST-EXEMPT 放行**（无白名单外理由，stats verdict=ok）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查：触发 0 项，豁免 0 项，未处置 0 项（无降质行为：无伪造证据/无跳过验证/无静默失败；provider 失败已按链登记并换道）
- [x] Evidence 抽查 3 条：VC-1（Read :2-6 复核）✓、VC-4（TOTAL=42 FAIL=0 命令输出）✓、VC-5（md5 6bcf4195 双位一致+diff 单行）✓——路径可 Read、结论可复现
- [x] 豁免登记：无
- [x] 未处置违规：无 → outcome 不降级

## Goal Gate (终验)

```
## Goal Verification — 新建 complex-planner agent（GLM5.3/Opus 级）作为高复杂度规划备用方案
- [x] VC-1 frontmatter 四要素 → PASS（一手 Read）
- [x] VC-2 门控+触发词+分工 → PASS（:3）
- [x] VC-3 五段锚+禁用清单 → PASS（:13-41）
- [x] VC-4 selftest 回归 → PASS（42/0 + smoke 17/0）
- [x] VC-5 部署 2 位 → PASS（md5 一致/diff 仅 model 行）
- [x] VC-6 路由登记 → PASS（:98）
- [x] VC-7 合并回+清理 → PASS（a4bbd19，worktree/分支已清）

 outcome: COMPLETE
```

**未验证显式登记（Rule 43.1）**：GLM-5.3 model 行的**行为级可派发性**本会话未验证（agent 类型列表会话启动固化，D6）——结构级证据=格式与 executor.md 在用先例同构+宿主模型清单在位；行为级冒烟=交付后新会话建议（见 delivery-summary 下一步建议①）。

> **验证独立性**：VC-4 由子代理承担（派发失败后按白名单③主进程接管，机械命令输出可控）；VC-1/2/3/5/6/7 均以主进程第一手 Read/命令输出为准（grep/md5/diff 客观证据，非自报采信）。

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 4 complete，终验通过 |
| 2 | Where am I going? | 簿记收尾（INDEX/memory/交付总结） |
| 3 | What's the goal? | 见 Goal |
| 4 | What have I learned? | findings.md R0-R8 |
| 5 | What have I done? | progress.md Phase 0-4 |
| 6 | Which tasks need processing? | plans/INDEX.md 刷新随簿记完成 |
