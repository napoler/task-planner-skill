# Findings & Decisions — task-v128（规则编号预留登记制）

## Requirements
- 用户指令（2026-10-04）：「处理」= 执行 `plans/round-retrospective-2026-10-04.md` 推荐 #1（F1 编号竞态机制化）。
- 直接动机（已两轮复现）：47 号 v122/v123 争（本任务避让）；**49 号 v125/v126 争**（v126 在途、v125 挂起待改号）；v127 只能**人工自取 50** 止损——需要机制承接。

## Research Findings
### R1. 编号占用全景快照（2026-10-04 04:0x 更新——B 类修订后）
| 编号 | 状态 | 任务 | 证据 |
|------|------|------|------|
| 45/46 | landed | task-v111 / task-v118 | critical-rules.md 块在位 |
| 47 | landed | task-v122 | merge bf9bb97/a183a99 |
| 48 | landed | task-v123 | merge 5f250f8 |
| 49 | **landed** | task-v126（已合并 48c6952，CR :506 49.1-49.5；v125 原同瞄已改号） | master log + `### 49` 块 |
| 50 | **contested** | **task-v125（由 49 改号：标题/条款/VC 已全量写 50，但 :2 适用场景注释仍残留 49 未清）** + **task-v127（侦察后自取 50：标题/VC/追加点全量写 50）** | `plans/task-v125/task_plan.md:5,12,34,45,119`；`plans/task-v127/task_plan.md:3,6,36,55` |
| 51 | reserved | task-v129（`new_rule: 51` 已写入计划头并 attest；其显式请求本任务补录「持有人 task-v129」） | `plans/task-v129/task_plan.md:3`；.plan-attestation 在位 |
| next | — | **52**（机制上线后 `next` 应输出此值） | 本表推算 |
> 注：50 竞态**正在发生**（v125/v127 各自成文，均未察觉对方）——本机制落地后双方可经 `check 50` 获得 WARN+`next` 建议（52）自行改号；追溯登记如实记 contested 不代裁。
### R2. 在途会话面（禁触）
- v124（pending 0/5，媒体执行体）、v125（pending 0/5，覆盖矩阵+Rule 49）、v126（in_progress，wt/task-v126 已提交 5f66bd8）、v127（in_progress，权重分级）——本任务与其**零文件接触**；同文件区（SKILL/selftest-skill-split/CR 尾）冲突按「序号并存+按实际重锚」预案。
### R3. 挂点与范式
- `attest-plan.sh`：既有 gate 段（template-gate/fmea-gate/plan-dispatch）可直接加一段；**本任务改动必须 fail-open**（脚本缺失/解析失败跳过），因为它是全仓计划的锁定入口。
- 工具脚本范式：bash + jq（jq 缺失降级 grep）+ 头注释四要素；断言范式见 `selftest-template-lifecycle.sh`（ok/bad + 负向 fixture）。

## 📐 设计冻结（§D2/§D3 实施依据）

### D2 定稿 — `scripts/rule-reserve.sh` 接口与账本 schema
```
用法: rule-reserve.sh <cmd> [args]
  reserve <N> <task-id> [--note "..."]   # 登记；已被其他任务持有 → stderr 持有人详情 + exit 3
  check <N>                              # 查询：空闲 exit 0 + "free"；被持有 exit 3 + 持有人行
  next                                   # 建议下一可用编号（>max landed 且跳过 reserved/contested 占位）
  list                                   # 全景输出（表格：rule/status/task_id 或 claimants/note）
  land <N> <task-id>                     # 置 landed（仅当前持有人；否则 exit 4）
  release <N> <task-id>                  # 置 abandoned（仅当前持有人；否则 exit 4；防误删他人登记）
账本: plans/.rule-reservations.jsonl（仓库 plans/ 根；append-only 原子行写入 >>）
  schema（每行一 JSON 对象，jq -c）:
   {"rule":<int>,"status":"reserved|landed|abandoned","task_id":"<task-id>","ts":"<YYYY-MM-DD>","note":"<可选>"}
   {"rule":<int>,"status":"contested","claimants":["<task-id>",...],"ts":"...","note":"..."}
  • 占位判定: status ∈ {reserved,landed,contested}（contested 视为被占，建议改号）
  • land/release 对 contested: claimants 中任一成员可 land（置 landed 并清 claimants）；release 需 --note 说明
  • 无账本文件时: reserve/check/next 按「空账本」工作（首次 reserve 自动创建）
  • 并发安全: 仅 append；查询按「同 rule 取最后一条」归并
  • **账本路径解析**（三级）: env `RULE_RESERVE_LEDGER` 覆盖 > 从 CWD 向上直至 / 找含 `plans/` 的祖先（账本=该祖先/plans/.rule-reservations.jsonl）> 均未找到 → stderr 报错 exit 5
  • 自测台阶: 测试一律用 `RULE_RESERVE_LEDGER=/tmp/xxx.jsonl` 指向临时账本，**禁写仓库 plans/ 真账本**（真账本由 S6 种子步骤首次创建）
```
头注释四要素（Rule 45.3）：用途（编号预留登记，锚 Rule 20.6/task-v128）/ 输入（位置参）/ 输出（exit 语义+stdout）/ 依赖（jq、plans/ 目录）。

### D3 定稿 — `attest-plan.sh` 查重段契约（fail-open）
```
追加段（位置: 既有 gate 段之后、attestation 写入之前）:
  1) 解析计划是否声明 new_rule:
     - 正文含 `<!-- new_rule: <N> -->` 或配置表行 `| `new_rule` | <N> |`；值为 none/缺失 → 跳过（零输出）
  2) task-id = 计划目录名; 调 scripts/rule-reserve.sh check <N>（脚本缺失 → 打印 SKIPPED 并继续）
  3) 空闲 → reserve <N> <task-id>; INFO 一行
  4) 被他人持有/contested → WARN 行（含持有人 + next 建议），默认不阻断；
     env TASK_PLANNER_RULE_RESERVE_STRICT=1 → exit 2（阻断锁定）
  5) 被本任务持有（reserved）→ INFO 已登记
四态 fixture（fixture 计划放 /tmp 临时目录，禁动在册计划）:
  F1 空闲声明 → 自动登记 + INFO; F2 声明 49（contested）→ WARN+建议 51; F3 同 F2 + STRICT=1 → exit 2;
  F4 未声明 new_rule 的老计划 → 输出与改前逐字节 diff 零
```

### D4 定稿 — 文档联动文案
- **Rule 20.6 子条**（追加于 critical-rules.md Rule 20 块内，纯增量）：
  `20.6 规则编号预留登记（编号所有权凭证，task-v128）：新增 Rule 编号的任务在计划中声明 new_rule: <NN>；attest-plan.sh 锁定前调用 scripts/rule-reserve.sh 查重——空闲自动登记（账本 plans/.rule-reservations.jsonl），被持有/contested 时 WARN + next 建议（默认不阻断；TASK_PLANNER_RULE_RESERVE_STRICT=1 阻断）；合并后 land、废弃 release。零新 config 键；selftest-rule-reserve.sh 守护。Why: 编号竞态两轮复现（47: v122/v123；49: v125/v126），事后仲裁成本=全量重编号。`
- **SKILL 两行**（净增 2）：
  ①（初始化/计划确认区）：`**规则编号预留（Rule 20.6）**：新增 Rule 编号时在计划声明 \`new_rule: <NN>\`；attest 自动查重登记（账本 \`plans/.rule-reservations.jsonl\`），冲突时按 \`next\` 建议改号。`
  ②（终验簿记区）：`**编号账本**：任务合并后运行 \`bash scripts/rule-reserve.sh land <NN> <task-id>\`（无新增编号则跳过）。`
- **templates/task_plan.md 配置表 +1 行**：`| \`new_rule\` | \`<NN>\` / 留空 | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空） |`

### D4b 定稿 — 账本种子（S6 写入 6 条；2026-10-04 04:0x B 类修订版）
```jsonl
{"rule":46,"status":"landed","task_id":"task-v118","ts":"2026-10-03","note":"子代理单任务专注度"}
{"rule":47,"status":"landed","task_id":"task-v122","ts":"2026-10-03","note":"媒体制作任务派发纪律"}
{"rule":48,"status":"landed","task_id":"task-v123","ts":"2026-10-03","note":"交付总结可定位性与实用性"}
{"rule":49,"status":"landed","task_id":"task-v126","ts":"2026-10-04","note":"单元线多路并行推进（merge 957a7a8/48c6952；v125 原同瞄已改号 50）"}
{"rule":50,"status":"contested","claimants":["task-v125","task-v127"],"ts":"2026-10-04","note":"v125 由 49 改号至 50（残留注释待清）与 v127 自取 50 同瞄；待仲裁/改号（next=52）"}
{"rule":51,"status":"reserved","task_id":"task-v129","ts":"2026-10-04","note":"videop1 mvlock 事故整改（new_rule: 51 已 attest；应其请求补录）"}
```
（`next` 在种子后应输出 `52`）

### D5 定稿 — TL 定义（`selftest-rule-reserve.sh` 断言清单）
RR-01 脚本存在且可执行 / RR-02 usage 含六命令串 / RR-03 账本路径常量在 / RR-04 STRICT env 名在 / RR-05 行为：reserve 冲突 exit 3（临时账本 fixture）/ RR-06 行为：next 跳过占用（seed 49/50 → 输出 51）/ RR-07 行为：release 越权 exit 4 / RR-08 contested 可表达且 list 可见 / RR-09 attest 挂点引用在（grep attest-plan.sh 含 rule-reserve）/ RR-10 负向自检：抽一锚缺则 FAIL（有牙齿实测）。

### R4. 基线快照（S1，2026-10-04 04:2x 返回）
- worktree@48c6952：**45 脚本 45/45 rc=0，ΣPASS=702 ΣFAIL=0**（主进程 bc 逐行求和复核一致；检查点 `subagent-state/1-executor.md` + 原文 `1-executor-results.txt`）。
- 回归对比基准锚（VC-4 失效判据）：改动后须 46 脚本（+selftest-rule-reserve）rc 全 0；ΣPASS = 702 + RR 断言数（预计 +10 → 712）。

### R5. S2 实现记录（2026-10-04 04:5x 返回）
- `scripts/rule-reserve.sh` 新建：git 实测 **+408 行**（0→408，executable 位 100755；commit **46bb036**〔原记 622ca3e 笔误，S10 对齐审查 P2 修正〕）；六命令 / contested 读写 / append-only（旧 6 行逐字不变仅增行）/ jq 降级（`RULE_RESERVE_FORCE_NO_JQ=1` 与 jq 路径结果一致）全部自测通过（8/8）。
- 主进程独立抽查：`bash -n` OK；临时账本 `next`→**52**、`check 50`→contested rc=3；头注释四要素在位。
- 测试台阶确认：账本路径 `RULE_RESERVE_LEDGER` env 覆盖已实现（S3/S6/S9 测试统一指向 /tmp，禁写真账本）。

### R6. Phase 3 落地记录（S3/S4/S4b，2026-10-04 05:1x）
- **S3**：`attest-plan.sh` **+64/-0**（查重段仅锁定路径；四态 fixture：F1 空闲→自动登记 INFO / F2 contested→WARN+next=52 不阻断 / F3 `STRICT=1`→exit 2 / F4 未声明计划新旧脚本输出逐字节 diff 零；rule-reserve 缺失→SKIPPED fail-open）。主进程 git diff 逐行复核 ✓。
- **S4**：`SKILL.md:75`「规则编号预留（Rule 20.6）」+ `:158`「编号账本」；449→**451**；`selftest-skill-split.sh:41` T-主 ≤451（演进链 440→…→451，label task-v128）；skill-split 复跑 41/41。
- **S4b**：`critical-rules.md:135` 20.6 子条（逐字同 §D4 定稿）；`templates/task_plan.md:33` `new_rule` 字段行。两文件纯增（+2/-0、+1/-0）。
- 主进程复核：sed/grep/diff 五锚全符；零删除行；仅登记范围内 5 文件变更。

### R8. Phase 5-6 记录（S8-S12，2026-10-04 06:3x）
- **S8 CR**：APPROVED（P0/P1=0；P2×2=reserve 竞态建议 flock / task-id 正则转义；20 路并发 append 无撕裂、exit 契约 0/3/4/5 四点实测）。
- **S9 独立审计**：4/4（六命令独立复跑 + attest 四态独立复跑 + 账本 schema 6 行 + 六坏输入契约 fail-open/rc2/rc5）。
- **S10 alignment**：APPROVED（四要素全过；P2=hash 笔误已修正）。
- **合流（B 类修订 #2 落地）**：master 含 v126/v127/v129；单点冲突（T-主 定数）按 **454** 解决（S11，+1/-5，双 label 入演进链）；merge 提交 b5318a0；**合流后全量 48 脚本 48/48 rc=0，ΣPASS=734 FAIL=0**（S12；bc 复核）。
- **部署与运维**：方向审计（位内专有=历史备份目录，非前向更新）→ `smart-merge-back --deploy`：merge **67e6c3f**，3 位 ALL IDENTICAL；**账本首次真实运维** `land 50 task-v127`、`land 51 task-v129`（contested 解除，next=52；commit 31e4230）；worktree/分支清理完毕。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 扩展 Rule 20 不新增编号 | 机制属规划/防篡改域；践行「能扩不新占」；避免自造一次协调 |
| 账本放仓库 `plans/.rule-reservations.jsonl` | 与 .active_plan/.plan_required_side 同级惯例；随仓库走、随档案入库 |
| attest 挂点 fail-open + 默认 WARN | 全仓锁定入口，稳定性优先；STRICT env 提供硬档 |
| contested 一等状态 | 忠实表达 v125/v126 现状；机制不代裁、只呈现 |
| 零新 config 键 | 对齐既有 enforce env 先例（TASK_PLANNER_SKILL_MODIFY_ENFORCE 等） |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 与 v125 计划同改 `selftest-skill-split.sh` | 预案=合并乱序后按实际行数重锚（label 各自注明），FMEA 已登记 |

## Resources
- 复盘：`plans/round-retrospective-2026-10-04.md`
- 挂点：`scripts/attest-plan.sh`、`scripts/init-session.sh`
- 范式：`scripts/ledger-append.sh`（append-only jsonl）、`scripts/selftest-template-lifecycle.sh`（断言）
