# DOCFIX-critic — 对齐审查 14 项修正落地检查点

- 执行者：docfix 子代理（仅改 audit-report.md / revision-proposals.md / findings.md 三文件）
- 事实源：`subagent-state/S7-verifier.md`（22 条 = verified 17 / partial 3 / fp 2）+ `subagent-state/ALIGN-review.md`
- 纪律：只改指定 3 文件；未改 task_plan.md / progress.md / verification.md；无 git 写操作；除本检查点外未写其他文件
- 状态：**done**（14/14 落实）

---

## 逐条落实与证据

| # | 清单项 | 落点 | 落实证据 |
|---|--------|------|----------|
| 1 | A §1.4 verify_done 机器门锚 497→502 | `audit-report.md:84` | 「模板 `templates/task_plan.md:**502**` 的 Handoff 表列头把 verify_done 折叠进…（列说明句在 :497）」；同段「模板 :497 还写着…」保留 |
| 2 | B RP-04 对象锚 497→502 + 注明 :497 为列说明句 | `revision-proposals.md:18` | 对象栏「`:502` Handoff 表头列定义；`:497` 为列说明句」；执行动作改 `templates/task_plan.md:502`（Handoff 表头行） |
| 3 | B RP-01 对象 = 卫星路由表 task-discipline 行（SKILL.md:195） | `revision-proposals.md:15` | 对象栏「卫星路由表 task-discipline 行（SKILL.md:195）」；依据栏「卫星路由表 SKILL.md:195 调用条件无触发词」 |
| 4 | A §1.1 时间序最后一行 | `audit-report.md:51` | 「2026-10-22 01:29:32 / 01:30:00　ep03-prompts.md 更新（FACT LOCK 命中 32）；spec 重建（FACT LOCK 命中 18）——该 spec 文件其后于 02:09:05 被再次写入，与本案无关」；原「00:21:39 spec 重建 / FACT LOCK 命中 32」错误归属已删（grep 00:21:39 = 0 命中） |
| 5 | C FACT LOCK 行改写 + D-F4 改名 + [fp-已撤回] | `findings.md:37`、`:46` | 事实栏按清单原句（01:03/01:06 截断快照；Edit 20 / Write 3、output.txt 3214B、mtime 01:29:32 命中 32、spec 命中 18）；D-F4 =「产出延迟落盘（非虚假进展——原判定已被复核推翻）」+ [fp-已撤回] |
| 6 | A / B 各增「VC 映射」段 | `audit-report.md:24`（§0.1）、`revision-proposals.md:95`（§八） | 两处同款 VC-1~VC-6 三列表；A 在 §0 之后、B 在「方案统计」之前 |
| 7 | A 缺口编号 D-01~D-05 → G-01~G-05 + 编号体系说明 | `audit-report.md:82-88`、`:182-184`、`:194` | 表内 5 行改 G-01~G-05；§7 引用同步（G-01/G-02/G-03）；说明句含「S9 D-02=check-complete:1747 消费点、S9 D-03=warn 升 exit 1」「两套编号不可混用」 |
| 8 | B 方案统计行 | `revision-proposals.md:110` | 「提案 31 条 = P0 15 条（生效通道 4 + 守卫 7 + 部署 3 + 跨项目裁决 RP-30 1）+ P1 15 条（簿记索引 6 + 契约文本 8 + 跨项目裁决 RP-31 1）+ P2 1 条（RP-29）」，保留「替代 3 条 / 删除 2 条（需授权）/ 其余增量」 |
| 9 | B RP-19 对象脚本 | `revision-proposals.md:54` | 对象 = `skills/task-planner/scripts/check-delegation.sh`（Executor 匹配与委派率统计口径）；依据保留锚 `check-delegation.sh:421-424,445` |
| 10 | B RP-07 前置引用 | `revision-proposals.md:28` | 「先补 landed 行（RP-17）」 |
| 11 | A §0 P0/P1/P2 计数 | `audit-report.md:20` | 「P0 共 15 项（生效通道 4 + 守卫 7 + 部署 3 + 跨项目裁决 1…），P1 15 项…，P2 10 项（S6 的 P2 9 条 + RP-29 1 条；其中方案级 P2 仅 RP-29 1 条）」；同步 A §8 表（`:213-215`）拆出 P2 1 条与跨项目裁决 2 条，合计仍 31 |
| 12 | A §7 三列表（报告条目 / S7 判定 / 判定结果） | `audit-report.md:162-186` | 22 行严格按 S7-verifier.md 清单 [1]-[22] 映射；含「口径说明（17/3/2 的计数基础）」 |
| 13 | A §7 FACT LOCK 由 partial 移入 fp | `audit-report.md:190-195` | partial 3 = [9]/[12]/[8d]（各写明未复现部分）；fp 2 = FP-1（FACT LOCK 零产出）/ FP-2（acceptance 值域措辞），互不重复 |
| 14 | A §4 B-02 与 §7 跳过项统一表述 | `audit-report.md:125`、`:196` | 统一为「8 个 Status 全 complete 计划仍留根，其中 7 个当下即可归档（未被 .session-owner 24h TTL 拦），仅 s77-p2-fix 被 TTL 拦；archive-plan dry-run 会产生写操作，S5 未实跑（豁免登记）」 |

## 连带修正（因 item 7 改名而必须同步，非新增范围）

- `revision-proposals.md:3` 「A-/B-/C-/D- 与 S9 补强方向 D-01~D-14 一一对应」为假（ALIGN 丁 HIGH）→ 改为「A-/B-/C-/G-；S9 补强方向 D-01~D-14 为独立编号空间…两套编号不可混用」
- B 依据列 6 处对报告缺口编号的引用同步改名：RP-01/02（D-02、D-03→G-02/G-03）、RP-03、RP-04（D-01→G-01）、RP-12（D-04→G-04）、RP-28（D-03→G-03）

## 未处理（不在本次 14 项清单内，报主进程决定）

1. `findings.md:114`（S9 缺口 D-01 行）仍写「模板 `templates/task_plan.md:497` 把该列折叠成…」——A/B 已按 S7 更正为 :502，此处仍为旧锚
2. `findings.md:115`（S9 缺口 D-02 行）仍写「卫星路由表 `SKILL.md:196`」——S7 复核正确值为 :195
3. A §1.2 D-F4/D-F5 与 C D-F4/D-F5 同号不同义（ALIGN 甲 HIGH）；本次仅按清单改写 C 的 D-F4，A 侧未动
4. A §0 核心结论三的「（V-C5 面实测）」为不可解析锚（ALIGN 丁 NIT）；本次未在清单内
5. ALIGN 甲/乙 指出的 progress.md Test Results / git status 基线为空（VC-3/VC-5）——progress.md 由主进程处理
