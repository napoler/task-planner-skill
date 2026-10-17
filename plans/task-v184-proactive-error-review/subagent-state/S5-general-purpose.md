# S5 general-purpose 检查点 — P-06 接线 check-3file-gate 第 6 条件 + 阈值语料校准

- 日期: 2026-10-17 | 执行体: general-purpose（S5 执行单元，Phase 2 最后接线单元）
- 任务: P-06 纯中文 Goal 漂移补检接线进 check-3file-gate.sh 第 6 条件 + 阈值经 ≥30 条中文 Goal 语料校准后固化
- 上游: report §5 P-06 原文「新增脚本 + 接线 check-3file-gate 第 6 条件消费面 + 阈值经 ≥30 条中文 Goal 语料校准」（终审修订 5：30% ASCII 判定线放大误报 → 语料校准固化）

## M1 前置契约（Read 结论）

**判定器 check-goal-cjk.sh（v183 已落地，本任务零改动）**:
- 输入: `<plan-dir>`，取 task_plan.md 的 `## Goal` 段（到下一 `## ` 止，剥 `<!--`/`-->` 注释行；同 check-drift.sh:179 口径）
- 分词: `od -An -tx1` + awk 3 字节 UTF-8 状态机（LC_ALL=C，locale 鲁棒，纯 bash+awk+od 无 python）→ 输出 `词数 CJK_PRESENT`
- rc 语义: 0=Goal 无 CJK（无判定面）或抽出 ≥1 词（check-drift 可消费）; 1=含 CJK 但抽出 0 词（分词失败，漂移检测将静默跳过）; 2=输入缺失
- 输出前缀 `[goal-cjk]`; `--fault-inject` 仅 selftest GCK-06 负例面

**校准关键代码级事实（副产物）**: awk 中 `seen=1 → word 追加 "c" → END 尾 flush 必计 N≥1` → **正常 UTF-8 输入下 rc=1 数学不可达**。门的 ⚠/✗ 分支是分词器回归 tripwire（GCK-05 静态锚 + GCK-06 fault-inject 行为守护），生产真实可达面=无。

**config.json**: `properties` 共 53 键；`goal_cjk_enforce` 位于 properties 下（S2 批前置 default=warn）；键数断言 4 处（CP-09/迭代持久/agent-coverage/decision-drift）仅计键数。

**参考接线**: check-complete.sh `resolve_vc_nonvacuous_tier()` + `run_vc_nonvacuous()`（env>config>默认 + 缺失/异常 fail-open + PASS stdout/FAIL stderr，set -e 安全取 rc 用 `|| var=$?`）。

**编号裁决**: plan CA-3/S5 行/根源覆盖表 + config description 三源一致要求 P-06 占「第 6 条件」；drift 门（task-v148）原注释占 6。全仓 grep 确认 drift「第 6 条件」无他处引用 → goal-cjk 插为第 6（require-kb 后、drift 前），drift 重编号 6→7，行为零变化（enforce/warn 降级四 selftest 实证）。

## M2 语料校准数据表

**语料源**: plans/archive 146 个 task_plan.md → Goal 段含 CJK 基本区（U+4E00-U+9FFF）字符 = **143 条**（≥30 达标）。

| 项 | 数量 | 误报（rc=1） | 静默跳过（CJK 目标报「无 CJK」） |
|----|------|------------|--------------------------------|
| archive 语料 143 条 Goal | 143 全 TOKENIZED | **0** | **0** |
| 活计划 task-v184 Goal | rc=0 抽出 21 词 | 0 | 0 |
| 5 抽样（fix-pointer-race-20261007 / task-3file-enforce / task-active-plan / task-bak-policy-20260905 / task-batch-report-tmpl-fix） | 10/24/18/17/14 词 | **0** | 0 |

- 独立交叉验证: python3 码点扫描（U+4E00-U+9FFF）对同提取段 → 判定器「无 CJK」报 0 次（误判=0）。
- 量化: 误报 0/148（语料 143 + 活计划 1 + 抽样 5 去重后），误报率 0%。

**E5 缺口探针（代码级发现，非语料触发）**:
- `is_cjk` E5 分支 `b2≤BC ∨ (b2==BD ∧ b3≤A3)` → 上界 U+5F63 → **U+5F64-U+5FFF（256 码位，含 心U+5FC3/得U+5F97/德U+5FB3/律/往/征/待/很/影/役/微/後/復/循/徹/念/志/忘/忙/快/忠/忧/忽/必 等常用字）未判 CJK**。
- 探针实证: 「心得」（全区）→「无 CJK」rc=0（静默跳过，非误报）; U+5F63 判 CJK / U+5F64 起不判; 一二三（U+4E00-4E02）与 U+9FFF 边界锚正常。
- 影响面: 语料 0 触发（需全缺口区字符 Goal，概率≈0）; 不产生 rc=1; 产生静默跳过=保护缺口（该 Goal 逃过漂移检测）。
- **裁决: 不修**。依据: ① dispatch 阈值调整授权条件「误报>0」未命中; ② 计划执行范围限制「判定器只读消费，判定逻辑重构禁止，仅接线需输出/接口微调」; ③ 语料实证零触发。登记为潜伏缺陷+修法备查: is_cjk E5 分支改 `b2 80-BF` 全域（一行、rc 中性、GCK-01..11 与既有 selftest 不受影响）——留待独立授权任务。

**档位裁决**: 语料+活计划+5 抽样 误报均=0 → 可 enforce（dispatch 规则 4 + plan Decisions「阈值/内容类门 warn 起步，语料实证校准后再升 enforce」）→ config `goal_cjk_enforce`: warn→**enforce**（键数 53 不变，jq 复核）。

## M3 接线

**改动清单（2 文件，git 终态仅此 2 个 modified）**:
1. `skills/task-planner/scripts/check-3file-gate.sh`（+65/-5）:
   - 头部条件清单: 插第 6 条 [P-06] goal-cjk 门控；drift 门 6→7
   - 修改说明块（What/Why/兼容，日期 2026-10-17/task-v184-S5）
   - 门控代码块（require-kb 段后、drift 段前）: `resolve_goal_cjk_tier()`（env TASK_PLANNER_GOAL_CJK_ENFORCE > jq `.goal_cjk_enforce // .properties.goal_cjk_enforce.default // "warn"` > warn）+ shell-out 消费: off=跳过 / 缺失脚本 fail-open ⚠ / rc=2 fail-open ⚠ / rc=0 判器行中继 stdout / rc=1→stderr+档位（enforce ✗ exit 1 / warn ⚠ 不阻断）
2. `skills/task-planner/config.json`（+2/-2）: `goal_cjk_enforce.default` warn→enforce + description 同步校准实证

**判定器零改动**（check-goal-cjk.sh md5 复核 a40ad5d4… 不变，git clean）。

## M4 验收证据（逐条命令+rc+关键行）

1. **跑题夹具 s5a**（Goal=「搭建一个在线商城系统」progress/findings=「修复登录 bug」，无 drift 痕迹）:
   - 默认档（final=enforce）: `bash check-3file-gate.sh plans/.fixture-s5a` → **rc=1**, `[goal-cjk] ✓ 抽出 1 个 CJK 词` + `[drift-gate] Rule 64.2…`（阻断由 drift 门执行，goal-cjk 段留痕）
   - warn 档: `TASK_PLANNER_GOAL_CJK_ENFORCE=warn TASK_PLANNER_DRIFT_ENFORCE=warn …` → **rc=0**, `[goal-cjk] ✓` + `[drift-gate] ⚠` + PASS + state-consistency PASS
2. **干净夹具 s5b**（内容一致 + ledger drift_check 痕迹）: `bash check-3file-gate.sh plans/.fixture-s5b` → **rc=0**, `[goal-cjk] ✓ 抽出 1 个 CJK 词` + PASS（**无 ✗/⚠**）
3. **活计划零误报**: `bash check-3file-gate.sh plans/task-v184-proactive-error-review` → **rc=0**（无 in_progress Phase → 条件 2 早退，[goal-cjk] 段不达，零误报平凡成立）; 补强: `bash check-goal-cjk.sh plans/task-v184-proactive-error-review` → **rc=0 抽出 21 个 CJK 词**（无 ✗/⚠）
4. **selftest 全绿**: `--only vc-gate` 11/11; `--only state-consistency` 5/5; `--only goal-cjk` 11/11; `--only gate-degraded` 16/16; `--only four-file-dataflow` 18/18; `--only drift-enforcement` 23/23（后三者=3file 相关回归面，registry 实证 watch 我改的文件）。3file 无独立命名 selftest（`ls selftest-*.sh | grep -i '3file\|gate'` 清单=evidence-goal-gate/final-gate-hash/gate-degraded/goal-cjk/vc-gate/verification-gate；state-consistency 行为级覆盖 3file STATE-CONSISTENCY GATE 段，已跑）
5. **夹具清理**: `rm -rf plans/.fixture-s5a plans/.fixture-s5b`（已复核不存在）; 终态 `git status --short` = 仅 config.json + check-3file-gate.sh 两 modified

**门分支全矩阵实证**（临时 judge stub=恒 rc=1，用后 md5 逐字节还原+git clean 复核）:
- enforce: rc=1 + `[goal-cjk] ✗`（判器行）+ `[goal-cjk] ✗ GOAL-CJK FAILED…`（门行）
- warn: rc=0 + `[goal-cjk] ⚠ GOAL-CJK WARNING…`（即 dispatch 验收文字「warn=rc=0 含 [goal-cjk] ⚠ 留痕」的字面实证）
- off: `[3file-gate] TASK_PLANNER_GOAL_CJK_ENFORCE=off — 跳过…`
- fail-open: 判器移走 → `[goal-cjk] ⚠ 门脚本缺失（fail-open 不阻断）`，rc 不受影响

## 限制/未做事项/风险

1. **E5 缺口**（M2）: U+5F64-U+5FFF 未判 CJK — 潜伏保护缺口（全缺口区 Goal 静默跳过漂移检测）; 未修（超授权面），修法已备查，建议独立任务处理。
2. **⚠/✗ 分支真实不可达性**: 正常 UTF-8 Goal 下判器 rc≠1 → 门 warn/enforce 档差异仅 tripwire 生效; 真实跑题夹具的阻断/告警来自 drift 门（第 7 条件），goal-cjk 门恒 ✓。dispatch 验收文字「含 [goal-cjk] ⚠」按字面需判器失败（stub 实证可达，见上），按机制语义应读作「[goal-cjk] 段留痕+⚠ 不阻断」——两读法证据均已落此文件。
3. rc=2 fail-open 从门侧不可达（条件 1 先验 task_plan.md 存在; 判器 rc=2 仅在 plan-dir 缺失，已被条件 1 前置拦截）。
4. 活计划当前无 in_progress Phase → 门早退; 活计划零误报由「早退+判器直测 21 词」双证据成立。
5. 全量回归（run-selftests --fresh，S9）未跑; 本任务验收面按 dispatch 全绿（vc-gate+state-consistency+3file 相关专属 6 个 selftest）。
6. 门缓存 cksum 遗留（4cb8f4a 登记「S7 顺手补」）与 S1 级联漏网 8 FAIL 为前序单元遗留，不在 S5 范围。

## checkpoint
本文件 = S5 最终检查点（M1 契约/M2 校准/M3 接线/M4 验收）。findings 回填与 git 收口由主进程/S9 执行。
