# Knowledge Brief — task-v128（规则编号预留登记制）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：落地「规则编号预留登记制」（账本+六命令脚本+attest 查重挂点+守卫+追溯登记 46-50），全量 selftest 0 FAIL 后合并部署 3 位。
- 背景/动机：Rule 编号并发竞态两轮复现（47: v122/v123；49: v125/v126），v127 只能人工自取 50——把事后仲裁变事前登记。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 编号预留登记 | 新增 Rule 的任务在计划声明 `new_rule: <NN>`，attest 时自动查重/登记（Rule 20.6） |
| 账本 | `plans/.rule-reservations.jsonl`（append-only；status: reserved/landed/contested/abandoned） |
| contested | 多方同瞄同一编号的如实标记（49=v125/v126）；机制只呈现不代裁 |
| 挂点 | `attest-plan.sh` 追加查重段（fail-open；默认 WARN；`TASK_PLANNER_RULE_RESERVE_STRICT=1` 阻断） |
| 编号自避 | 本机制不新增 Rule 号（扩 Rule 20.6）——践行「能扩不新占」 |

## §2 已验证关键事实
| 事实 | 证据 | 影响 |
|------|------|------|
| 编号全景：48 landed / 49 **landed(v126)** / 50 **contested(v125,v127)** / 51 reserved(v129) / next=52 | findings R1（2026-10-04 04:0x 更新） | 种子数据 6 条 + `next` 期望值=52 |
| attest-plan.sh 是全部计划的锁定入口 | `scripts/attest-plan.sh`（template-gate/fmea-gate 段） | 挂点必须 fail-open（脚本缺失/解析失败→跳过） |
| SKILL.md 现 449 行，T-主 锚 ≤449 | `selftest-skill-split.sh:41`（v122/v126 演进链 440→…→449） | 本任务净增 ≤4 行 → T-主 定数上调预计 451 |
| registry 45 行（+本次=46） | `selftest-registry.tsv` | +1 行须与 selftest-registry 计数断言同步 |
| v126 已合并；v124 转 Phase 3 / v125 待启动（已改号 50）/ v127 规划中 / v129 在途 | `git worktree list`、各 plan | 禁触；合并乱序预案=序号并存+按实际重锚 |
| 工具脚本范式= bash+jq（缺失降级 grep）+ 头注释四要素 | `ledger-append.sh`、`subagent-fallback.sh` | S2/S5 实现基线 |

## §3 关键文件锚点表
| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| `scripts/attest-plan.sh` | 尾部 gate 段后 | 查重段追加点（attestation 写入之前） |
| `scripts/init-session.sh` | :1-30 | usage/提示区（+1 行编号预留提示） |
| `scripts/selftest-registry.tsv` | 尾 | +1 行登记 `selftest-rule-reserve.sh` |
| `scripts/selftest-skill-split.sh` | :41 | T-主 行数定数（447→新值，label 注明 task-v128） |
| `SKILL.md` | 初始化/终验段 | 两行新增点 |
| `references/critical-rules.md` | Rule 20 块 | 20.6 子条追加点（不改号） |
| `templates/task_plan.md` | 配置表 | `new_rule` 字段行 +1 |
| `plans/.rule-reservations.jsonl` | — | 新建账本（种子 5 条） |

## §4 易错点与禁止假设清单
1. 挂点必须 fail-open —— `rule-reserve.sh` 缺失/账本损坏/解析失败 → 打印 SKIPPED 并继续（禁阻断全仓 attest）
2. 未声明 `new_rule` 的计划必须**原行为逐字节不变**（F4 fixture diff 零硬门）
3. 禁触 `plans/task-v124|125|126|127/**` 与 `/home/terry/task-planner-skill-worktrees/task-v126`（并行会话）
4. SKILL 净增 ≤4 行，改后 `wc -l` 复核 + T-主 定数同步（否则自撞断言）
5. 账本写入一律 append（`>>`）；禁止改写既有行（查询按同 rule 取最后一条）
6. 编号自避：本任务**不声明**具体编号（`new_rule: none`）——若误声明会自占新号，违反 D1
7. contested 不得被 land/release 误清——contested 成员 land 时才置 landed 并清 claimants
- FMEA 最高项指针：→ task_plan.md FMEA「P3 attest 挂点缺陷致全仓后续 attest 受损」行（fail-open+四态 fixture）

## §5 S-unit 材料包索引
| S-unit | 应读本 brief 哪节 | 额外材料 |
|--------|------------------|---------|
| S1 | §2 | —（直接跑脚本） |
| S2 | §1 + §3 + §4 | `plans/task-v128/findings.md` §设计冻结 D2 |
| S3 | §2 + §3 + §4 | findings §D3（挂点契约+四态 fixture） |
| S4 | §3 | findings §D4（文案定稿） |
| S5 | §3 + §4 | findings §D5（TL 清单 RR-01..10） |
| S6 | §1 | findings §D4b（种子 JSONL 逐行） |
| S7 | §2 | — |
| S8 | §1 + §2 | findings 全文 |
| S9 | §1 + §4 | findings §D2/§D3（复跑判据） |
| S10 | §1 + §2 | wt diff + 本任务 task_plan.md |
