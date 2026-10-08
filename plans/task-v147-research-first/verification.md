# Verification Contract & Phase Gates

## Goal (1 sentence)

落地 Rule 63「检索优先与反推诿纪律」（条款+SKILL/派发模板传播+selftest 守护+锚宽容化），全量 selftest 无回归增量后合并回 master 并部署 3 实体位 IDENTICAL——终态达成（master=e18045d，三位 diff=0）。

---

## Verification Contract（终验逐条，全部 PASS）

- [x] VC-1: critical-rules.md 含 Rule 63 全六子条（`^### 63 `=1 且 `^63.[1-6] `=6，纯追加零删改）
  Evidence: 主进程 grep 实测 6/1（Phase 2 验收）；部署位冒烟同值（~/.zcode/skills/task-planner/references/critical-rules.md）
- [x] VC-2: SKILL.md 三处计数联动+Rule 63 摘要 bullet+合规清单 C44（判据经第二世代演进 1-63→1-64，Decisions 已登记）
  Evidence: `grep -c '1-64' SKILL.md`=3、`grep -c 'Rule 63' SKILL.md`=4、C44 行在位（:213 区）；索引枚举含 63+64（S7 审查后补）
- [x] VC-3: subagent_dispatch.md §2 检索优先契约行（引用 Rule 63）
  Evidence: subagent_dispatch.md:27 单行插入（+1/-0），主进程 grep 复验
- [x] VC-4: selftest-research-first.sh 全 PASS+registry 登记
  Evidence: `Total: 12 PASS=12 FAIL=0` exit=0（三处复跑一致）；selftest-registry.tsv 含 research-first 行
- [x] VC-5: 无回归破坏（ΣFAIL ≤ 基线 4 且构成不变）
  Evidence: Round 3 终态 ΣPASS=969/ΣFAIL=4（基线 934/4；+12=RF 新增、+23=v148 drift-enforcement 协同落地；FAIL=4 全为 periodic PR-03/04/05/10 基线预存）；采集日志 /tmp/tpv147_regression_r2.txt
- [x] VC-6: 合并回 master+部署三位 IDENTICAL
  Evidence: master=e18045d（merge commit）；`diff -rq` 三位（~/.zcode、~/.claude、~/.config/opencode）各 0 项差异；zcode 位经原子换位部署（运行位自保护 REJECTED→v126/v129 先例手动原子换位，smart-merge-back exit 6 已如实登记）
- [x] VC-7: rule-reserve land 63+CHANGELOG 条目
  Evidence: 账本 landed 行（rule=63, task_id=task-v147-research-first）；CHANGELOG.md [Unreleased] Rule 63 条目（含第二世代演进补记）

## 双审闭环（Code Review Gate+对齐审查）

- Code Review（.sh 面）：**APPROVED**（checkpoint 6-code-reviewer.md）——P2 EG 注解历史链已恢复+补首代记录（追加不改写约定）；P1 v148 drift-enforcement 头注 DCE 描述偏差=他任务财产，豁免登记转交
- 对齐审查文档面：**APPROVED**（checkpoint 7-alignment.md）——SKILL:9 枚举已补 64；「61 预留未落地」存量括注定性=应记债（pre-existing）
- 对齐审查模板/日志面：CHANGES_REQUESTED→已处置（checkpoint 8-alignment-b.md）——P2a CHANGELOG 净态补记已落；P1 同上豁免转交；P2b「Rule 26 Q3」措辞变体保留（Rule 28.2 先例）

## 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 2/3/4：S1-S4/S5 两轮派发+接管/S6-S9 审查+两轮锚级联宽化+第二世代演进） |
| 主进程直做 Phase 清单 | Phase 1（②计划系统文件）、Phase 5（①git 编排+②簿记+③机械验证）；执行中白名单接管与 trivial 修复各已登记（S5 接管=⑤、三处 ≤3 行修正=⑥） |
| 委派率 | 0.6——**WHITELIST-EXEMPT**（直做理由全部命中 25.3 白名单①②③⑤⑥） |

## 质量门控统计（Rule 26）

| 项 | 结果 |
|----|------|
| Q1 VC 复验 | 全勾+Evidence 在案 |
| Q2 验证步骤 | 回归 Round 1-3 逐轮落盘（Rule 57 四要素） |
| Q3 证据抽查（≥3 条） | RF Total 行（三处复跑一致）/ 三位 diff -rq=0 / 账本 landed 行——均可复现 |
| Q4 子代理产出 Read | 全部 Handoff 行 verify_done ☑（8 行 done，含自写 findings 复核） |
| Q5 委派率 | 0.6+白名单豁免（上表） |
| Q6 批量 | 不适用（无批量操作） |

## 需求覆盖核对表（Rule 51.3）

| R | 判据 | 状态 |
|---|------|------|
| R1 解决问题不变目标+反推诿 | 63.1/63.3 条款在位（VC-1） | covered |
| R2 检索优先=首要信息源 | 63.2 四步检索链+派发模板契约行（VC-1/3） | covered |
| R3 禁未检索「不知道」 | 63.3 持证上岗+合法形态（VC-1） | covered |
| R4 有理有据禁编造 | 63.4 边界+Q3 最高档（VC-1） | covered |
| R5 网络资源充分利用 | 63.2 依据段+部署生效三位（VC-4/6） | covered |

## 🎯 核心目标达成裁决（Rule 58.5）

| 字段 | 值 |
|------|-----|
| 裁决 | **solved** |
| 解决证据锚 | VC-1..7 全 PASS（本文件）+ master e18045d + 三位 diff=0 + 运行位冒烟 63 六子条在位 |
| 备注 | 规则类任务的「问题解决判据」=条款落地+守护绿+部署生效三件齐——全部达成 |

## 登记债与移交项（非本任务阻断）

1. v148 drift-enforcement 头注与 registry:63 行 DCE 区间描述（DCE-11~16 vs 实态 01..23）——他任务财产，移交 v148 会话/后续簿记任务
2. SKILL 索引行「（61 预留未落地）」存量 stale 括注——应记债（对齐审查定性）
3. set-active-plan.sh `set` 子命令路径解析异常（pid 被当 ROOT 拼接）——登记遗留，建议后续任务核查
4. plans/INDEX.md 待处理区 v133/v135/v138 条目与 memory「COMPLETE」矛盾（陈旧索引）——建议簿记任务清账
