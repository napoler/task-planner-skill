# Fix R6a — task-auditgate-machine-20261116（R6 APPROVED 后单点加固）

- 轮次: R6a（单主题加固轮，**未新增 [plan-audit-RN] 段**）
- 执行体: plan-writer（独立上下文）
- 开始时间: 2026-11-17T04:5x+08:00（动工前登记）
- 完成时间: 2026-11-17T05:3x+08:00
- 任务书: `subagent-state/fix-R6a-prompt.md`
- 主题: checker 末段聚合的**中间态假阳性**加固（主进程 2026-11-17 /tmp 一手实测发现，非 critic 提出）
- 状态: DONE

## 范围（单主题）

| # | 落点 | 动作 | 状态 |
|---|------|------|------|
| 1 | `task_plan.md` 根源覆盖表「门控判定器实现」行 | 缺陷面补中间态假阳性；修复点补 ① 聚合边界止下一个 H2 ② 结论行 ERE 行首结构锚定 | done |
| 2 | `task_plan.md` CA-7 行 | 依据补主进程实测证据；执行动作写入 ①② | done |
| 3 | `task_plan.md` Phase 3 S1 验收（+ 输入列标注先例命令假阳性） | 两约束写入判据 + 中间态假阳性负例（必 rc1） | done |
| 4 | `verification.md` VC-1 判据 + Verify command + VC-3 fixture 清单 + 知识储备核验行 | 两约束 + r4 中间态负例（承重实测）+ VC-3 用例标注 | done |
| 5 | `knowledge-brief.md:27`（先例聚合命令行） | 补加固说明（实测证据 + 两约束 + 存量先例不改写） | done |
| 6 | 同义面一致性（task_plan VC-1 / Phase 2 规格 checkbox / Phase 3 S1 checkbox / Notes） | 同步两约束（防残留矛盾） | done |
| 7 | 簿记（findings / notepad / progress / 本 checkpoint / 状态块） | 发现登记 + 修订对照 + 教训 + 状态块同步至 R6a 态 | done |

## 判别性实测（`/tmp/r6a`，两形态 mock，真实输出）

| 状态 | 构造 | OLD rc | NEW rc |
|------|------|--------|--------|
| s1 | 终态：末段审计=R6 结论 APPROVED（fixture） | 0 | 0 |
| s2 | 中间态：R5 结论 REJECTED + 后随修复轮块含反引号元引用 | **0（假 PASS）** | **1** |
| s3 | 真实 progress.md `head -304` 截断态 | **0（假 PASS）** | **1** |
| s4d | 真实全文件 + 追加无结论行簿记块 | 0 | 0 |
| s5 | 审计段内唯一 APPROVED 为行中反引号元引用 | 0 | 1 |
| s6 | 真实全文件现状 | 0 | 0 |
| s7 | 追加本轮 R6a 块后（真实终态+修复块串联） | 0 | 0 |

## VC-1 Verify command 端到端（逐字提取 :17，仅替换 C= 为 mock）

```
bash -n          rc=0
RUN NEWFORM      rc=0    # SUBS r1=1 r2=1 r3=0 r4=1
RUN OLDFORM      rc=1    # SUBS r1=1 r2=1 r3=0 r4=0 → r4 假 PASS 被抓（承重）
backticks        =0
```

## 机械门（真实 rc）

check-rvc-coverage / check-vc-nonvacuous / check-tier-consistency / check-plan-dispatch / check-template-type / check-step-placeholders / check-goal-cjk / check-delegation stats 全 **rc=0**；
check-plan-dispatch 仅余既有 2 条非阻断 WARN（plan-tier 提示 / p1-baseline 组内执行体同质）。

## 本轮自身两处缺陷（已修正，如实披露）

1. **表格内 `\|` 致列错位**：首版把完整 ERE 写进 S1 验收格（含 `\|`）→ `check-plan-dispatch.sh` 的 `awk -F'|'`（:246-305 不剔除 `\|`）错列，报「S1 时长不可解析 / 粒度三值不可解析 / 输入 3 个文件路径」。修正=表格内禁裸/转义管道，完整正则单点存 `verification.md` VC-1（列表项），其余落点改「三段结构 + 指路」；输入列第三路径（kb）改散文指路。复跑后 SKIPPED 噪声全部消失。
2. **mock 自测首版 bug**：在首个 `## ` 处 `exit` → 只聚合首个审计段 → 终态 fixture 假 FAIL。修正为 `inbuf=0; next`。

## 三约束自证

① `sed -n '16,18p' task_plan.md` 与 R6 复核时逐字一致（R1/R2/R3 锚未动）。
② `user-session-log.md`：mtime `2026-11-16 23:39:23.409788871 +0800` / 4355 B / sha256 前 12 位 `d12cd51f8604`。
③ `progress.md` 未锚定结论 token 计数=6（写入前后同值，均规则说明/自述句）；锚定形态计数=1（仅 `[plan-audit-R6]` 真实终态段）；未新增 `[plan-audit-RN]` 段。

## 未改

`skills/**`（保护区）、`user-session-log.md`、其他计划目录、仓库脚本；无新增仓库脚本（mock/fixture 全在 `/tmp/r6a`）。
