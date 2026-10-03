# Checkpoint — task-v128 S9 executor（独立行为审计）
status: done

## 里程碑
- M1: 读齐 4 输入（task_plan VC-1/VC-2 / findings D2+D3+D4b / progress / knowledge-brief §1§4）；只读 Read 审计对象三件：wt `rule-reserve.sh`（408 行）/ `attest-plan.sh` 查重段（:202-265）/ `plans/.rule-reservations.jsonl`（6 行种子）
- M2: A 组六命令独立复跑（自建种子账本 `/tmp/s9-audit-v128/seed.jsonl`：5 landed / 6 reserved / 7 contested / 8 abandoned；全部 `RULE_RESERVE_LEDGER=` 指 /tmp，真账本零写入）
- M3: B 组 attest 四态独立复跑（自建 fixture 计划 `/tmp/s9-audit-v128/attest/fx{1,2,3,4}/`，`--skip-template-check --skip-fmea-check --skip-dispatch-check` 三逃生参命中查重段；独立账本 `attest/ledger.jsonl`=真账本 6 行副本）
- M4: C 组 schema 校验（`jq -c` 逐行 6/6 VALID + 字段集 OK×6 + ts 全在）
- M5: D 组反例区分度（坏账本/全坏账本/降级路径/非法编号/未知命令/exit5 六坏输入）
- M6: 对照 CR 检查点 8-executor.md 2 项 P2，给出差异说明（见下）

## A 组 — 六命令独立复跑（自建场景，seed: 5/6/7/8）
| # | 命令 | 输出原文 | rc | 判 |
|---|------|---------|-----|----|
| A1 | `reserve 9 task-audit` | `[rule-reserve] rule 9 reserved by task-audit` | 0 | PASS 空闲成功 |
| A2 | `reserve 7 task-audit`（非 claimant） | `CONFLICT: rule 7 被持有: contested[task-c task-d] (status=contested…)` | 3 | PASS 冲突+持有人 |
| A3 | `check 9` | `rule 9 held by task-audit (reserved)` | 3 | PASS 持有态 |
| A4 | `check 99` | `free` | 0 | PASS 空闲态 |
| A5 | `next` | `8` | 0 | PASS（自设场景推算=8：>max landed 5 且跳过占位 5/6/7/9；**abandoned(8) 回池不占位，符合 D2「land/release 后编号回池」契约**） |
| A6 | `list` | 表 5 行含 `7  contested  contested[task-c task-d]` | 0 | PASS 全景含 contested |
| A7 | `land 5 task-audit`（越权，holder=task-a） | `DENIED: rule 5 非由 task-audit 持有（当前: landed / holder: task-a）` | 4 | PASS 越权 rc4 |
| A8 | `release 6 task-audit`（越权） | `DENIED: rule 6 非由 task-audit 持有（当前: reserved）` | 4 | PASS 越权 rc4 |
| A9 | 真账本复核（只读） | `next`→**52**；`check 50`→`rule 50 contested: [contested[task-v125 task-v127]]` rc=3；list 49/50/51 三行在位 | 0/3 | PASS 与 D4b 种子契约一致 |

## B 组 — attest 四态（fx 计划目录名即 task-id）
| # | 场景 | 输出原文 | rc | 判 |
|---|------|---------|-----|----|
| B1 | 空闲 `new_rule: 99` | `[rule-reserve] INFO: rule 99 空闲 → 自动登记 (task=fx1…)`；`grep -c '"rule":99'`=1 已入账 | 0 | PASS |
| B2 | 冲突 `new_rule: 50`（contested 他持） | `[rule-reserve] WARN: rule 50 contested: [contested[task-v125 task-v127]] (task=fx2; 建议改号 next=52…)` 且计划仍锁定（`[attest] ✅`） | 0 | PASS WARN+next 不阻断 |
| B3 | 同 B2 + `STRICT=1` | `[attest] ✗ Rule 编号冲突: new_rule=50 被持有/contested, 拒绝锁定…`；`.plan-attestation` 未写（阻断成立） | 2 | PASS |
| B4 | 未声明 new_rule | `grep -c rule-reserve`=0（零输出），原锁定行为不变 | 0 | PASS |
| B5 | 幂等（fx1 二次 attest，99 本持） | `[rule-reserve] INFO: rule 99 已由本任务登记/持有 (rule 99 held by fx1 (reserved)…)` | 0 | PASS（D3 ⑤） |

## C 组 — 账本 schema 校验（真账本 6 行，只读）
- `jq -c` 逐行：line 1..6 全 VALID
- 字段集：46/47/48/49/51（landed/reserved 有 task_id）+ 50（contested 有 claimants 双成员）→ `OK:rule=46..51` 六行全 OK；ts 全在位（C2b 无 BAD 输出）

## D 组 — 反例区分度（坏输入 → 判定）
| 坏输入 | 系统行为 | 契约符合 |
|--------|---------|---------|
| D1 账本混入非 JSON 垃圾行（合法 6 行+1 垃圾） | `check 5`→free、`next`→52、`list` 正常 6 行——按「机器产出格式稳定+垃圾行无匹配=忽略」语义 fail-open，**不静默误判**（垃圾行无法伪造 task_id 字段，last_entry 取不到→视为无记录） | PASS |
| D2 同坏账本 + `RULE_RESERVE_FORCE_NO_JQ=1` 降级 | `check 5`→free rc=0 / `check 50`→contested rc=3，与 jq 路径一致 | PASS |
| D3 全坏账本（单行垃圾） | `check 5`→free、`next`→1、`list`→`(no entries)`，等价空账本，不崩溃 | PASS |
| D4 非法编号 `reserve abc` / `check 2.5` | `非法 rule 编号: abc` rc=2 / `非法 rule 编号: 2.5` rc=2（非静默通过，报错退出） | PASS |
| D5 未知命令 `boguscmd` | usage 输出 rc=2 | PASS |
| D6 三级解析全失败（无 env + CWD=/tmp） | `无法解析账本：CWD=/tmp…` rc=5（与头注释契约一致） | PASS |

## 对照 CR（8-executor.md）2 项 P2 — 差异说明
1. **P2-1（reserve read-then-write 非原子，双登记竞态）**：本审计独立复跑**认同**——append `>>` 单行原子，但 check+append 两步间无锁；末条归并下查询结果正确，双持有人仅语义瑕疵（CR 已按 FMEA P5 登记兜底）。无新增意见；S9 视角补充：该瑕疵在「登记凭证而非强锁」定位下可接受，flock 建议留后续迭代。
2. **P2-2（attest :246 grep 未转义 task-id 特殊字符）**：本审计实测 task-id=fx1/fx2/fx3/fx4（含 CR 所述 task-vNN 形态）行为均正确；**与 CR 结论一致**，额外观察：正则未转义仅影响「本任务持有 INFO」判定的漏报方向（漏报→走 WARN 分支，仍阻断性安全），无安全反向风险——风险等级 P2 定档合理。

## 产出清单
- 本检查点（唯一写入物）；fixture：`/tmp/s9-audit-v128/{seed.jsonl, attest/}`（临时，可弃）
- 被审文件零修改（wt `git status --porcelain` 空；真账本仅读；/tmp 临时账本全为自建副本）

## 最终结论（8 字段块，同返回消息）
```
status: done
acceptance: 4/4 pass — A 六命令全 PASS（reserve 空闲 rc0/冲突 rc3+持有人 / check 双态 / next=8〔自建场景推算〕+真账本 52 / list 含 contested / land、release 越权 rc4）；B 四态全 PASS（INFO 自动登记+入账实证 / WARN next=52 不阻断 / STRICT exit2 且 attestation 未写 / 未声明零输出 rc0）；C schema 6/6 VALID+字段集全 OK；D 六坏输入全部 fail-open 或按契约报错（rc2/rc5），无静默通过
files: /mnt/data/dev/task-planner-skill/plans/task-v128/subagent-state/9-executor.md (+1)
evidence: 逐组证据见上表（命令→输出原文→rc）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v128/subagent-state/9-executor.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
