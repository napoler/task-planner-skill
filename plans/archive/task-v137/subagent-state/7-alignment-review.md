# 7-alignment-review — task-v137 台账供料四落点 对齐/同步一致性审查

**结论：CHANGES_REQUESTED**（1 项 P0 失效引用 + 2 项 P2 建议；无多副本漂移、无越界改动、守卫全 PASS）

- 审查对象：commit `8a8d9e5`（feature）/ `4bca3dd`（merge 进 master）
- 机制权威源：`plans/cost-analysis-2026-10-05/design-input-narrowing-proposal.md`
- 执行体：alignment-review（review-library 领域成员）
- 审查时间：2026-10-05

---

## 逐项证据

### 项1 越界自检：PASS

```
git show 8a8d9e5 --name-only | tail -4
→ skills/task-planner/references/critical-rules.md
→ skills/task-planner/templates/knowledge-brief.md
→ skills/task-planner/templates/subagent_dispatch.md
→ skills/task-planner/templates/variant/rule-enhancement-type.md
（4 files changed, 11 insertions(+)）

git show 8a8d9e5 --name-only | grep -c 'SKILL.md\|config.json\|scripts/'  → 0
git diff --name-only 4f85538 4bca3dd  → 同上 4 文件（merge 未夹带）
```

`git show 4bca3dd --stat` = `4 files changed, 11 insertions(+)`，与 plan `scope_files` 逐一相等。SKILL.md / config.json / scripts/ **零变更**承诺兑现。

### 项2 引用完整性：FAIL（1 处 P0）

| 引用目标 | 验证命令 | 结果 |
|---|---|---|
| `plans/.rule-reservations.jsonl` | `ls -la` | 存在，1450B / 12 行 |
| 台账角色=编号账本 | `cat plans/.rule-reservations.jsonl` | 字段 `{rule,status:landed/contested/reserved,task_id,ts,note}`，与 `02-ledger-map.md:34`「B8 Rule 编号预留账本」描述**一致** |
| brief §2/§3/§5 锚 | `grep -c '^## §' templates/knowledge-brief.md` | **5**（:23 §1 / :35 §2 / :45 §3 / :54 §4 / :62 §5）✅ |
| `Rule 22 §9`（CR:146） | `sed -n '182p' references/critical-rules.md` | 22.9 = **活跃计划解析会话隔离(active-plan-race,2026-09-10)** — 与「上下文预算,禁贴全文」**无关** ❌ |

### 项3 多副本同步：PASS（无 DRIFT）

```
diff -rq skills/task-planner {zcode,claude,opencode,cursor} → 四处均无输出（含 Only in）
```

四文件 × 四部署位 md5 全等（示例）：`critical-rules.md main=bc17a077 zcode=bc17a077 claude=bc17a077 opencode=bc17a077 cursor=bc17a077`；其余三文件同形态（`e3ee5213` / `cb129c3c` / `47a38f44`）。

### 项4 守卫锚级联：PASS（26/26）

```
bash skills/task-planner/scripts/selftest-knowledge-brief.sh  → Total: 16  PASS=16  FAIL=0
  [PASS] T1b 五段标题 grep -c '^## §' = 5
  [PASS] T1c 行数 ≤150                    （实测 wc -l = 68）
  [PASS] T6 critical-rules 21.2(145)+22.4(168) 命中且 100<行号<200
bash skills/task-planner/scripts/selftest-skill-split.sh      → Total: 41  PASS=41  FAIL=0
  [PASS] T-主 ≤478 行（SKILL.md 零改动故未位移）
```

三关键锚行级证据：21.2@`critical-rules.md:145` / 22.4@`:168` / brief 模板 68 行、5 段。

### 项5 术语一致性：PASS

```
grep -rn '台账供料|台账路径锚供料|台账喂养|账本供料' skills/task-planner/  → 8 处命中，全部落在本次 4 文件
```

三种形态均为有意层级：`台账供料优先`（规则名，CR:146 / dispatch:38）/ `台账供料源`（brief §2 行型名）/ `台账路径锚供料`（brief:33 / dispatch:38 / variant:100）。**无第三种变体**（`台账喂养` / `账本供料` 命中数 0）。

### 项6 条款挂点核验：FAIL（1 处 P0）

| 子项 | 结果 |
|---|---|
| §2/§3/§5 五段真实存在 | PASS（`grep -n '^## §'` = :35/:45/:62） |
| `:146` 行不含 `22.4` 子串 | PASS（`sed -n '146p' … \| grep -c '22\.4'` → 0）——**但见 P0-1：规避方式制造了错挂引用** |
| 「Rule 22 §9」指向真实载体 | **FAIL** → 见问题清单 P0-1 |

### 项7 计数联动：PASS

```
grep -rn '21\.2\.1' skills/  → 7 处：knowledge-brief.md :33 :40 :44 :61（4）
                              subagent_dispatch.md :34 :38（2）
                              critical-rules.md :146（1，唯一条款定义行）
grep -c '21\.2\.1' skills/task-planner/SKILL.md  → 0
```

SKILL.md 零引用与「推荐零改动」决策（提案落点 5）一致 → **非缺陷，登记即可**。

### 项8 变更记录：PASS

`plans/task-v137/progress.md:49-52` 四单元实施记录齐全（S1 brief +7 / S2 dispatch +2 / S3 CR +1 / S4 variant +1），`:61-64` 验收表四行全 PASS，`:72` 守卫复验摘要。

---

## 问题清单

### P0-1 「Rule 22 §9」错挂引用（critical-rules.md:146）— 必须修

**事实**：`sed -n '146p'` 末句为「禁双份供料由 **Rule 22 §9**(上下文预算,禁贴全文)既有纪律承载」。
**证据**：

1. 字面解析 `Rule 22 §9` → Rule **22.9**，其正文为「活跃计划解析会话隔离(active-plan-race,2026-09-10)」（`sed -n '182p'`）——与「上下文预算/禁贴全文」无任何关系。
2. 真实载体是 **Rule 22.4 的第 ⑨ 字段**：`templates/subagent_dispatch.md:75` 原文「## 9. 上下文预算(强制 — **Rule 22.4 第 ⑨ 字段**,小模型短上下文友好)」；`critical-rules.md:168`（22.4）内含「上下文预算(prompt 总长 ≤…**禁止**把 task_plan/findings 全文…贴进 prompt)」。
3. **同 commit 内两种写法并存**：dispatch:34 写「(22.4 §9 既有纪律)」（正确），CR:146 写「Rule 22 §9」（错挂）→ 术语/引用不一致。
4. **该写法在 critical-rules.md 中无先例**：`grep -c 'Rule [0-9.]* §' references/critical-rules.md` → **1**，唯一命中就是本次新增的 :146。文件内其余 47 处 `§` 全为跨文档引用（brief §1-§5、dispatch §7、sync.md §4）。
5. **根因（可复现）**：`progress.md:51` 记载「S3 → 发现「22.4」字面会致 T6 行号提取失真 → SendMessage 微调去除」。机制见 `selftest-knowledge-brief.sh:57`：
   ```bash
   L_224=$(grep -n "knowledge-brief" "$CRULES" | grep -F '22.4' | head -1 | cut -d: -f1)
   ```
   该行同时含 `knowledge-brief` 与 `22.4` 时会被 `head -1` 抢先命中 :146，使 T6 报出错误行号。**规避手段制造了语义回归**——且即使命中 :146，窗口断言 `100<146<200` 仍会 PASS（假通过 + 误导性证据）。

**建议修法（二选一，推荐 a）**：

- (a) 把 T6 的 `grep -F '22.4'` 收紧为 `grep -E '^22\.4 '`（锚定规则号在行首），再把 CR:146 改回「**Rule 22.4 第 ⑨ 字段**（上下文预算,禁贴全文）」，与 dispatch:34/dispatch:75 写法统一；改后须重跑 T6 确认仍报 `:168`。
- (b) 最小改动：CR:146 改为「dispatch 模板 **§9 上下文预算**(Rule 22.4 第 ⑨ 字段)」，明确指向模板节而非规则号。

**影响面**：仅 1 行文本 + 1 处 selftest 锚收紧；不影响 21.2.1 的供料纪律本体语义（台账供料优先条款本身成立）。

### P2-1 「B8」任务局部代号泄漏进永久模板（variant:100、knowledge-brief:44）

- `templates/variant/rule-enhancement-type.md:100`：「台账供料简报（**B8 编号账本**+审计台账路径等）」
- `templates/knowledge-brief.md:44`：「（来源=编号账本推最大 landed Rule）…**源=B8** landed 最大号」
- B8 的定义**只存在于任务产物** `plans/cost-analysis-2026-10-05/02-ledger-map.md:34`，技能仓内无任何 B1-B14 编号体系（`grep -rn '\bB[0-9]\b' skills/` 命中的 T-B1/B2/B4 等均为 task-v094 测试编号，非台账代号）。
- 措辞由提案落点 4 逐字规定（`design-input-narrowing-proposal.md:74`），**执行体照抄无过**；且同表「定位」列指向 brief §2/§3/§5，而 `knowledge-brief.md:33/:40` 已把真实路径 `plans/.rule-reservations.jsonl` 拼出 → 两跳可解析，非 P0。
- 建议：长期把 `B8 编号账本` 改为「Rule 编号账本 `plans/.rule-reservations.jsonl`」，避免未来会话读到不可解代号。

### P2-2 T6 行号提取脆弱性（既存缺陷，本次被触发）

`selftest-knowledge-brief.sh:56-57` 用 `grep -F '21.2'` / `grep -F '22.4'` 全文子串匹配规则号，任何在正文提及规则号的行都会被误取。建议随 P0-1 一并收紧为行首锚定（`grep -nE '^22\.4 '`），避免同类规避-回归循环。

---

## 变更记录（三要素）

| 要素 | 内容 |
|---|---|
| **变更范围** | `8a8d9e5` / `4bca3dd`，4 文件 +11/-0 纯增量：`critical-rules.md`(+1 @:146)、`knowledge-brief.md`(+7，61→68)、`subagent_dispatch.md`(+2，76→78)、`variant/rule-enhancement-type.md`(+1，122→123)。范围外零变更（SKILL.md/config.json/scripts 命中 0）。 |
| **冲突处理结果** | **无合并冲突**（`git merge --no-ff wt/task-v137` 干净落地，net diff = 同一 4 文件）。**唯一实质冲突是语义级**：`critical-rules.md:146` 新增条款引用「Rule 22 §9」与既有 Rule 22.9（active-plan-race）撞号，且与同 commit dispatch:34 的「22.4 §9」写法不一致——判定为 P0 未解决项，由主进程回填修正。 |
| **文档当前状态** | 计划文档已同步（`progress.md` :49-64 四单元 + 验收表全 PASS；`findings.md` :26/:29 S1/S4 结论；`knowledge-brief.md` 已实例化）。**规则正文 1 处引用待修**：CR:146「Rule 22 §9」→「Rule 22.4 第 ⑨ 字段」+ T6 锚收紧。四部署位与主仓 md5 一致，无需重新同步（P0-1 修复后需再跑一次四位同步）。 |

---

## 放行条件

修复 P0-1（CR:146 引用改挂 + T6 锚收紧）并重跑 `selftest-knowledge-brief.sh`（T6 仍报 `:168`）+ 四部署位 md5 对照，即可转 APPROVED。P2 两项不阻塞。