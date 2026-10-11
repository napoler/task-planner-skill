# 02c-executor-s3 checkpoint — task-v065 Phase 3 S-3（subagent-fallback.sh 衔接修复）

status: done

## 完成项（每项即时记录）

### 1. F-6-1 timeout 拆出独立分支 ✅
- 位置: skills/task-planner/scripts/subagent-fallback.sh cmd_next case 块（原 :260 附近）
- 原 `provider|network|timeout|400|unknown|"")` 拆为 `provider|network|400|unknown|"")` + 独立 `timeout)` 分支
- timeout 分支输出: `{"dispatch_as":null,"reason":"timeout_split_first","decision":"timeout_split_first","hint":"首败超时第一假设是任务过大:先按 Rule 21.4 对照 21.1b 评估 ② 拆细重派(不改模型档位);判定非任务过大才转 provider 通道改派(...)","tier_order":[...]}`
- 其余枚举（provider/network/400/unknown/""）行为不变

### 2. F-6-2 no_healthy_channel 编号错位修正 ✅
- 原 hint `③ 主进程接管 / ④ AskUser` → `④ 主进程接管 / ⑤ AskUser`（22.3 实际 ④=主进程接管 ⑤=AskUser）

### 3. F-6-3 非 provider 分支五档全序 + tier_order ✅
- 原四档 `①换类型 → ②降档 → ③主进程接管 → ④AskUser` → 完整五档 `①改派(换类型) → ②拆细 → ③降档 → ④主进程接管 → ⑤AskUser（消耗 retry_limit）`
- 新增结构化字段 `"tier_order":["dispatch_swap","split","model_downgrade","main_takeover","ask_user"]`

### 4. F-7-1 no_healthy_channel escalation 升级 ✅
- escalation: `main_takeover_or_askuser` → `split_then_takeover_or_askuser`
- hint 追加: `（任务>300行/多文件时先回计划层拆细到单文件≤300行再逐片 ④ 接管——22.3.2）`
- 注: `no_health_file` 分支（无 health 文件）保留原 `main_takeover_or_askuser` 未改（任务范围限定为 best 为空的输出）

### 5. F-7-2 critical-rules.md 22.3.1 追加 22.3.2 ✅
- 位置: references/critical-rules.md :125 22.3.1 段「边界(如实)」句尾 `连续 2 个通道全灭 → 22.7 STOP` 后
- 追加原文: `;22.3.2 **provider 全灭挽救档**:provider 全灭且任务超 ④ 上限(单文件 ≤300 行)时,禁止直接 STOP——先回计划层拆细到每片 ≤300 行单文件,再逐片 ④ 主进程接管;拆细后仍无法接管的部分登记未完成清单交付(降级交付点,禁裸 BLOCKED)`

### 6. F-7-3 SKILL.md Provider Scaling 段补句 ✅
- 位置: SKILL.md :405 `**Provider 失败主动 Scaling(task-v055-fallback)**` 段句尾
- 追加: `provider 全灭且任务超 ④ 接管上限(单文件 ≤300 行)时禁直接 STOP:先回计划层拆细到每片 ≤300 行单文件再逐片 ④ 接管(22.3.2)。`

### 7. selftest-fallback.sh 补 3 用例 ✅
- T09 (a/b): err_kind=timeout → 输出含 timeout_split_first 与 21.1b 拆细指引
- T10 (a/b/c): 非 provider 分支 → hint 含完整五档全序且 tier_order 数组 5 项含 "split"
- T11 (a/b/c): no_healthy_channel（全 err health fixture）→ escalation=split_then_takeover_or_askuser 且 hint 含 22.3.2 与 ④/⑤ 编号
- 断言由 8 组扩至 29 条

## 验证证据

1. `bash -n scripts/subagent-fallback.sh scripts/selftest-fallback.sh` → `SYNTAX_OK`（exit 0）
2. `bash scripts/selftest-fallback.sh` → `Total: 29  PASS=29  FAIL=0`（基线 T01-T08 不回退 + 新增 T09-T11；commit 后复跑同样 29/29 全绿）
   - 注: T07 前后有 2 条 `jq: error ... .files[\"executor-fb.md\"].hash` stderr 噪声，为既有基线（S-3 未触碰 T07 代码），T07a-c 仍 PASS，非本步引入
3. 手动三场景实跑（fake ZCODE_HOME + health fixture）:
   - timeout: `{"dispatch_as":null,"reason":"timeout_split_first","decision":"timeout_split_first","hint":"首败超时第一假设是任务过大:先按 Rule 21.4 对照 21.1b 评估 ② 拆细重派(不改模型档位)...","tier_order":["dispatch_swap","split","model_downgrade","main_takeover","ask_user"]}`
   - non-provider: `{"dispatch_as":null,"reason":"non_provider_error","hint":"非 provider 类失败按 Rule 22.3 原顺序: ①改派(换类型) → ②拆细 → ③降档 → ④主进程接管 → ⑤AskUser（消耗 retry_limit）","tier_order":[...5项...]}`
   - no healthy channel: `{"dispatch_as":null,"reason":"no_healthy_channel","escalation":"split_then_takeover_or_askuser","hint":"主通道与 fallback 通道均不可用 → Rule 22.3 ④ 主进程接管 / ⑤ AskUser（任务>300行/多文件时先回计划层拆细到单文件≤300行再逐片 ④ 接管——22.3.2）"}`
   - 回归: provider + 健康通道 → `{"dispatch_as":"executor-fb","model":"custom:p1:m1","reason":"provider_failure_scaling","zero_cost":true,...}` 不变

## 提交

- commit: `6f2611a` worktree 分支 `wt/task-v065-subagent-failure-rescue`
- stat: 4 files changed, 31 insertions(+), 5 deletions(-)（SKILL.md 2± / critical-rules.md 2± / selftest +20 / fallback +12-3）
- 提交后 `git status --short` 干净

## 未改动（负结果确认）

- 未改 no_health_file / provider_fallback_disabled 两个既有分支的 escalation 值（任务范围外）
- 未触碰其他 worktree、主仓工作区、~/.zcode/skills/**
- resolve_candidates/cmd_probe/cmd_bind 逻辑未改

## resume 断点

无（全部完成）。下一步 = S-3 收尾：合并回合约（VC 复验后 merge --no-ff + worktree remove + branch -d）。
