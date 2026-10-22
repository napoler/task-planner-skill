# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1「修正 未清项（计划已登记的 8 项非阻断遗留，」= 修完 plans/task-kb-deploy-20261022/findings.md:49-62 登记的 L-1~L-8 全部 8 项
- R2「部署 并且推送到远程」= 修复合并 master 后三位部署位同步 + push origin/master（会话前一条指令的收口口径延续）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| L-1~L-8 登记原文+待修方向 | plans/task-kb-deploy-20261022/findings.md:49-62 | 是 | 现场勘察（L 逐条） |
| 10-22 口径①修复先例（轻量放行语义收紧） | plans/task-kb-deploy-20261022/findings.md:46 + check-scope.sh:115-130 注释 | 是 | 现场勘察 L-6/L-7 |
| L0-E 权重 0 豁免口径 | SKILL.md L0-E 段 + check-delegation.sh ④c/stats | 是 | 现场勘察 L-2 |

## Research Findings — L-1~L-8 现场勘察（2026-10-23 主进程逐一 Read 实证）
**登记源**：plans/task-kb-deploy-20261022/findings.md:49-62（CR APPROVED WITH NITS 遗留 8 项表）。现场逐条核实（定位行号以当前 master 923aa54 为准）：

- **L-1** `scripts/check-delegation.sh`：④c 函数 `is_protected_path()`（:246-255，k8s 行=**:251** `*package.json|*pyproject.toml|*/.github/*|*/.gitlab-ci.yml|*/.k8s/*`）vs ④b mini 分支 case（**:351** 同清单但 `*/k8s/*`）——同清单两版，k8s glob 互斥（`.k8s/` vs `k8s/`）。修=两侧同列 `*/.k8s/*|*/k8s/*`（fail-closed 并集，见 D-L1）。
- **L-2** `scripts/check-tier-consistency.sh:61`：`LANE="$(grep -m1 -E '^execution_lane:' "$PLAN_FILE" | grep -oE 'L[012]' | head -n 1)"`——`L0-E` 被截前缀为 `L0`；下游 **:127** `if [ "$LANE" = "L0" ]` 套 L0 单 Phase cap → 2-Phase L0-E 计划误 FAIL。修=精确 token 解析 `L[012]([_-][A-Za-z0-9]+)*`；`l0`/`l0-t` 入 L0 检查族（l0-t 沿用 :128-129 IS_L0T cap 逻辑），`l0-e` 豁免（P4 权重 0 口径，见 D-L2）。**勿破坏**：IS_L0T（:63 `grep -q 'L0-T'`）对 lane 声明 L0-T 的情形仍须生效。
- **L-3** `scripts/selftest-requirement-coverage.sh`：RC-24..RC-27（:537/:551/:563/:576）仅覆盖 51.9-51.12；**51.13 全文锚=`references/critical-rules.md:106`**（机制段：51.9-51.13 子条文本锚 + 事故判例锚「0 母图即 COMPLETE」+ SKILL 51 bullet 联动 + media-planner Rule 50 计数指针 + 零新键负断言）。修=仿 RC-27 范式加 RC-28（51.13 行锚+语义锚），脚本跑 `Total: 28 PASS=28`。
- **L-4** 同脚本 **:8** 头注 `RC-01..RC-23 逐行 PASS/FAIL` 与实际最大 RC 号脱节（加 RC-28 后应为 `RC-01..RC-28`）。修=头注计数随 L-3 一并同步。
- **L-5** `README.md:81`（「其余 74 条已按域迁至上表 11 卫星」）/ `docs/ARCHITECTURE.md:4`（计数 74，登记实测 76——**执行时 S2 须重实测唯一规则编号数**，禁直接抄 76）。修=两处同步实测值。
- **L-6** `scripts/task-plan-init.cjs:103-115`：10-22 P1 修复后轻量档=不写哨兵+写 `.plan_lightweight` 标记；但 10-22 口径①修订（CR blocker，14d6673）后 check-scope.sh 轻量分支已收紧为「仅机械产物区/gitignore 区放行，受管文件仍拦」（check-scope.sh:115-130 注释实证）→ init.cjs 侧文案「跳过计划门控（check-scope.sh 轻量放行分支消费…）」失准。修=择 (b) 改真语义文案（见 D-L6），并注 `fix`/`简单` 等 LIGHTWEIGHT_KW 子串命中连带面。
- **L-7** `scripts/check-scope.sh:121-130`（口径①轻量分支）vs `:133-142`（口径②原分支）：同构判定（`$ROOT/tmp|output|.cache` case + `git check-ignore`）双份易漂移。修=抽函数 `_is_mechanical_artifact_path()` 两处复用（check-delegation.sh:255-265 已有同名函数可参照形态）。
- **L-8** 三 nit：① `check-scope.sh:22-23` 头注 exit code 说明未列 10-22 新增放行来源（轻量标记/机械产物区/gitignore 区）；② 留痕 echo 走 stdout（:123/:128/:131 等 `[PLAN-GUARD]` 行）——**改 >&2 前先查 PreToolUse hook 对 check-scope 输出的消费面**（stdout 被展示为放行原因则保 stdout；查不清=保现状仅清①③，登记决定）；③ `check-delegation.sh:437` 注释日期 `2026-10-07 task-v055-fix-review` 与同族 09 月式日期混用 + `templates/task_plan.md:353,355` 相邻两行路径基准混用（`<skill>/scripts/...` vs `bash scripts/kb-sync-from-plan.sh`）——统一为 `<skill>/scripts/` 基准并注明。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| D-L1 k8s glob 两侧并集（`.k8s/`+`k8s/` 同列） | fail-closed：dot 目录与仓内目录两形态皆基础设施保护面（宪法 §5 清单 k8s/*.yaml + ④b 原 k8s/ 口径），缺一侧即开放行口 |
| D-L2 L0-E 豁免 L0 体量复核 | L0-E=纯执行档（P4 权重 0 先例，check-delegation stats 同口径）；套 L0 单 Phase cap 与「零受管变更」定义冲突；L0-T 仍走 L0T cap 不豁免 |
| D-L6 文案改真语义（不回写哨兵） | (a) 恢复哨兵=回退 10-22 videop1 停摆投诉修复（用户已裁决 P1 级变更，判例 F2）；(b) 零行为变更、纯文案对齐，符合 §十三 精准改动 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| （执行期登记） | |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 缺陷登记源：plans/task-kb-deploy-20261022/findings.md:49-62
- worktree：/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023（分支 wt/task-kb-cr-lits-20261023）
- 51.13 全文锚：skills/task-planner/references/critical-rules.md:106
- 遗留无关分支 `wt/task-v168-machine-parked`（3a68579，10-11 用户裁决封存态）——非本任务产物，不触碰，交付呈报

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

## S1-S7 子代理返回结论（19.1 回填，2026-10-23）
| S-unit | 状态 | 结论摘要 | 检查点（worktree 内） |
|--------|------|----------|----------------------|
| S1 L-1+L-8(delegation) | done | k8s 双清单并集（:251/:351 同列 .k8s+ k8s 双 glob）；:437 日期 2026-10-07→2026-09-07（全文件 grep 确证 task-v055-fix-review 族=09-07） | subagent-state/1-s1-check-delegation.md |
| S2 L-2 tier LANE | done→修正轮在途 | LANE 精确 token+L0-E 豁免；三夹具首测过；HIGH 标记=L0-T 单 Phase cap 收窄超射程，主进程裁决回补（L0-T 全量继承 L0 三项检查，仅 L0-E 豁免；四夹具 l0e=0/l0=1/l0t-single=0/l0t-2ph=1） | subagent-state/2-s2-tier.md |
| S3 L-7+L-8(scope) | done | 抽 `_is_artifact_or_gitignored_path` 双调用；头注 9 条放行来源枚举；>&2 判定=查 zcode-pretooluse.sh:18-20 只读 rc 不消费 stdout→留痕改 >&2（阻断文案保 stdout+既有 stderr 兜底，登记 CR 项）；跨文件行号锚 zcode-userpromptsubmit.sh:36 引 :85 漂移=登记 | subagent-state/3-s3-scope.md |
| S4 L-6 init.cjs | done | 文案改真语义（仅免无计划门控+机械产物区/gitignore 区放行+受管文件仍拦+LIGHTWEIGHT_KW 子串连带面），零行为变更（+10/-1 仅注释/字符串） | subagent-state/4-s4-init-cjs.md |
| S5 L-8(模板) | done | :355 三处 kb-* 命令统一 `<skill>/scripts/` 基准+注明；日期项=git log 确证无矛盾保持原样 | subagent-state/5-s5-nits.md |
| S6 L-3+L-4 selftest | done | RC-28 新增（51.13 行锚+3 scoped 语义锚，锚写前实测）；头注 RC-01..RC-28；单脚本 28/28 + 全量 run-selftests --fresh 92/92 PASS | subagent-state/6-s6-selftest-rc.md |
| S7 L-5 计数 | done→扩面轮在途 | 实测卫星侧 dedup=76（11+44+3+3+4+3+1+1+1+4+1；77/78/79 无实体 abandoned）；核心 14；全集 90；两处计数词已改；扩面指令=残留 5 处 74 口径+193→203 行数注 | subagent-state/7-s7-counts.md |

**裁决登记（主进程）**：
- D-L2b：L0-T 语义收窄撤销（S2 HIGH 标记采信）——L-2 最小修口径=仅 L0-E 豁免，L0-T 全量继承 L0 三项检查；修正轮进行中
- D-L5b：L-5 扩面=同文件残留 74 口径 5 处+行数 193→203 同步（L-5 方向=「口径同步」射程内）；路由表编号列 v195 前快照=独立缺陷族不扩面，留 CR 裁决
- 登记不修（CR 呈现）：① 阻断文案 stdout（zcode-pretooluse.sh:21 有 stderr 兜底）② 跨文件行号锚漂移（userpromptsubmit.sh:36→check-scope:85）③ 路由表 task-discipline 编号列快照 ④ registry.tsv:48「八子条」历史口径

## CR 一轮裁决（S9，2026-10-23）
- **VERDICT: CR CHANGES REQUIRED**（Blocker 0 / Major 2 / NIT 6；检查点 9-s9-cr.md）
- MAJOR-1（模板 :355 kb-* 基准失准）=属实→D-L8b 回退修正（S5 回退轮在途）
- MAJOR-2（progress.md 证据空白）=**误判驳回**：主进程 Read 实证 79 行含 [backfill]/[complete]/[vc]/[drift]/[decision] 六组证据行（CR 读取面陈旧或 grep 词面未命中）
- NIT 登记不修（6 条，检查点 §分级别清单）：NIT-1 tier 输出样例未含 L0-T / NIT-2 check-scope ⚠ 行归拦截文案 / NIT-3 verification.md「74 零残留」字面不可满足（纪元注释保留）/ NIT-4 README 注追加 vs ARCHITECTURE 注前置 / NIT-5 三处跨文件行号锚 base 即错+再 +11（zcode-userpromptsubmit.sh:36、template-guide.md:157、template-mapping.md:222）/ NIT-6 L0-E 豁免兜底面未注明（check-delegation:373-377）
- 独立缺陷族登记（不扩面）：templates/ 未纳入 selftest-doc-script-paths.sh 扫描面（无静态守护）
