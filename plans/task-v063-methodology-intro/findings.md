# Findings — task-v063-methodology-intro

## Requirements
- 用户 09-12 指令：引入方法论（网络调研结论已有），提升执行质量与可靠性；方案 A（双层完整引入）已确认
- 范围 = 可靠性侧 4 条（Poka-Yoke/FMEA 预演/checkpoint.jsonl 断点/chunk≤3 映射）+ 内容质量侧 5 条（三级引用/交叉验证/去 AI 化 10 条/五维评分卡/8 字段契约复用）
- 原则 = 不改 Rule 1-28 既有语义，走「门控点+指针+references/methodology.md+config 开关键+selftest 守护」增量方式

## Research Findings
[2026-09-12 调研结论全文 + 出处，见 task-v062-interaction-modes/findings.md「方法论调研」段（Poka-Yoke Shingo 1989 / FMEA SAE J1739 / 5 Whys Toyota / 幂等+checkpoint Lamport 1978 / 去 AI 化 GPTZero+Poynter / 五维评分卡 Google DeepMind 2023 分类法 / 8 字段契约 Anthropic Claude Code 2024 内部规范）]

## 嵌入点调研（Explore 子代理 2026-09-12 返回，主进程复核采信）
1. **task_plan.md 段落全貌**（worktree 内实测行号）：Goal :8 / Code Review 配置 :16 / VC :30 / 执行范围限制 :53 / 必要知识储备 :74 / 核心问题定义 :93 / Current Phase :110 / Next Step :117 / Phases :126 / 隔离决策 :202 / 原生 Todo 同步 :219 / ... / 委派统计 :310 / Subagent Handoff :322。
   **FMEA 段插入点 = 「🔀 隔离决策」段之后（:217 后）、「🔁 原生 Todo 同步」（:219）之前**；理由：FMEA 表按 Phase 编号引用，Phases 段在其上；与隔离决策同属规划期风险决策块。段名 `## 📊 FMEA 预演（规划期）`（与既有 📊 委派统计图标风格一致）。
2. **SKILL.md Poka-Yoke 指针 = :80（Rule 28 交互模式行）与 :82（Phase 执行循环）之间的 :81 空行**，新增 1 个顶级 checkbox 项，不动「6 步」计数语义。
3. **内容质量门控指针 = SKILL.md :156（质量门控统计 Rule 26 bullet）之后新增 1 个同级 bullet**；Phase 级落点 = `templates/variant/writing-type.md:63`（`- [ ] Phase 3.5: quality-reviewer 审查`）扩写。
4. **references/ 实为 10 文档**（非 9）：batch-quality-gate/billing/completion-gate/cost-control/critical-rules/goal-gate/template-guide/template-mapping/todo-sync/worktree-isolation；新文档命名 `references/methodology.md`（或 content-quality-gate.md，对仗 batch-quality-gate）。
5. **variant 12 个**，内容类 = `writing`（writing-type.md，Phase 0→6 管线）；research/publish 未显式注释 template_type，分流真源 = `scripts/init-session.sh:62` 白名单 VALID_TYPES（13 值）。
6. **config.json 顶层 properties 实为 22 键**（非 19——19 是 README「常用键」表行数口径）；无 quality/fmea/rubric 语义键；**新增 2 键必须写入 properties（additionalProperties:false）+ 仿 interaction_mode 范式（enum+default+description）+ 加 selftest 守护**，命名沿用 enforce/warn/off 三态（delegation_enforce/dispatch_contract_enforce 先例）：`fmea_enforce`、`content_quality_enforce`，默认 warn。
7. **selftest 布局**：6 套平铺在 scripts/，selftest-methodology.sh 命名完全一致直接放 scripts/；注册点 = `lib/verify.sh:227` 的 for 循环需追加；`tests/smoke.sh` 只对 lib/*.sh 与 install 脚本做语法检查，不跑 selftest。
8. **负结果**：全仓 grep `FMEA|Poka|checkpoint.jsonl|去 ?AI|五维|评分卡|rubric` 零命中（v063 全新引入无冲突）；既有 `checkpoint` 语义仅指子代理断点（SKILL.md:374 subagent-state/），v063 的 checkpoint.jsonl 是计划级断点，命名需在 methodology.md 中显式区分。

#### [sub:02-plan-writer] methodology.md 结构

- **文件**: worktree 内 `skills/task-planner/references/methodology.md`（新，176 行，commit 32d0d9e）
- **骨架**: `# Methodology 指针文档（v063 新增机制层）` → `## 定位声明`(5 条) → `## §可靠性`(R1-R4) → `## §内容质量`(Q1-Q5) → `## 与 Rule 1-28 关系`(6 行关系表 + 待补项汇总)
- **五字段范式**: 每条 R/Q 固定 `方法名 / 出处 / 触发场景 / 可操作动作 / 与既有机制映射 / 失败惩罚映射`(+ 开关键行)
- **Rule 映射落点**: R1→25.1+22.6+10; R2→4+11+21.1b; R3→22.8(计划级 checkpoint.jsonl vs 子代理级 subagent-state 命名区分)+19; R4→18+21.1b+21.4+7; Q1/Q2→26.3 Q3 证据不实; Q3/Q4→26.3 惩罚表+writing-type.md:63; Q5→22.4b/22.4c/22.5/22.8.5
- **待补项(如实登记未瞎编)**: ISO 21434 条款号 / Google Cloud 幂等链接 / Lean 小批量文献 / 三级引用与核查流水线原始出处 / GPTZero+Poynter 链接 / DeepMind 论文标题 / Anthropic 规范链接
- **自查**: `grep -c '出处\|映射\|惩罚'`=34(≥20)、`grep -c '^### \|^## '`=13(≥10)、wc -l=176(120-400)、9 条五字段齐

#### [sub:03-code-assistant] 模板 2 处插入

- **文件**: worktree 内 `skills/task-planner/templates/task_plan.md`(+15/-0, commit 9072009)：「🔀 隔离决策」段末契约行(:217)后插入「## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）」段(注释块 + 7 列 RPN 表 + 填写规则)，位于「🔁 原生 Todo 同步」前
- **文件**: worktree 内 `skills/task-planner/templates/variant/writing-type.md`:63(+1/-1)：Phase 3.5 行整行扩为「quality-reviewer 审查（含去 AI 化 10 条清单 + 五维评分卡 ≥4.0 门控，指针 references/methodology.md §内容质量 Q3/Q4；开关键 content_quality_enforce）」
- **验收**: grep "FMEA 预演"=1、"五维评分卡"=1、RPN 表头 7 列在位、diff 仅 2 处、commit 9072009 后 git status 空
- **负结果**: 两文件其余内容零改动；未触碰 methodology.md/SKILL.md/config.json/其他 11 个 variant

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| methodology.md 而非内联 SKILL.md | SKILL.md 已 500+ 行近边界；references/ 10 文档先例；指针范式 |
| config 开关键默认 warn | 新增机制观察期，不直接阻断既有任务流（Rule 26 降质可观察） |
| 只动 writing-type.md（不动 12 个 variant 全量） | 内容质量门控仅对内容类任务有意义，YAGNI；research/publish 登记后续扩展 |
| FMEA 段插在隔离决策后而非 VC 后 | 不打断 Goal→VC→Scope 既有阅读序，且 FMEA 需引用 Phase 编号 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| Explore 报告与任务描述有 3 处口径不符（references 10 非 9/config 22 键非 19/selftest 静态可数 67 非 106） | 以实测 grep 为准（主进程已 grep config.json properties 复核 22 键）；106 用例口径=运行时计数，静态 grep 口径不同，两者不矛盾 |

## Resources
- task-v062-interaction-modes/findings.md「方法论调研」段（调研全文+出处）
- worktree 内 templates/variant/writing-type.md（Phase 0-6 管线，:63 Phase 3.5 行）
- critical-rules.md 25.1-25.6（Rule 25 降级范式行文样板，methodology.md 每条「失败惩罚映射」字段照此风格）

#### [sub:05-code-assistant] config +2 键

- **文件**: worktree 内 `skills/task-planner/config.json`(properties +2 键, commit 01e936e)：按字母序插在 `dispatch_contract_enforce` 与 `provider_fallback` 之间新增 `content_quality_enforce`/`fmea_enforce`（enum enforce/warn/off + default warn，对齐既有 enforce 键范式）；additionalProperties:false 不变
- **文件**: worktree 内 `skills/task-planner/README.md`：「常用键 19 项」→「常用键 21 项」；键说明表末追加 2 行（fmea_enforce / content_quality_enforce，关联列 v063）
- **验收**: jq properties keys length=24(22+2)、两键 default=warn、jq 合法、README grep "21 项"=1 且新键 grep=2、commit 01e936e 后 git status 空
- **负结果**: schema 其余 22 键零改动；未触碰 .sh/模板/SKILL.md；无 push

#### [sub:07-code-reviewer] 全量回归 + CR

- **S1 全量回归**: 7 套 selftest 全 EXIT=0 — active-plan 13/13 / delegation 38/38 / dispatch 18/18 / fallback 21/21 / interaction 10/10 / plan-dispatch 6/6 / **methodology 7/7**；既有 6 套 = 106 用例口径无回归，合计 113 用例 0 fail；methodology 套件连跑两遍一致（幂等），跑前后 `git status --porcelain` 为空（hermetic 不污染真实仓）
- **verify.sh**: 中性 CWD(/tmp) + TASK_PLANNER_ROOT=worktree → `22 pass / 3 fail`；3 fail = claude-code/zcode/opencode deploy drift。**基线实测对照**：`git archive 1df5bb4` 导出后同法跑 = `25 pass / 0 fail` → 3 项 drift 系本轮 SKILL.md 改动引入的新增 fail（成因=canonical 领先 3 部署位未重部署，非代码缺陷；计划 Phase 8 S2 已排"重部署 + verify 25/0×3"清除）。**修正 brief 口径**：不是"既有假象/非新增 fail"，而是"预期中间态新增 fail"
- **diff 范围核实**: 实际 7 文件（brief 称 5）—— README.md +3/-1、SKILL.md +4/-0、config.json +20/-0、references/methodology.md +176/-0、scripts/selftest-methodology.sh +96/-0、templates/task_plan.md +15/-0、templates/variant/writing-type.md +1/-1
- **CR 判定: APPROVED**（P0=0 / P1=0 / P2=4 / P3=4）
  - P2① `references/methodology.md:4` 与 `:173` — 锚点 `SKILL.md:81` 实为 `:82`（`grep -n "Poka-Yoke 前置条件检查" SKILL.md` → 82；:81 为空行）。修复：两处 `SKILL.md:81` → `SKILL.md:82`（或将锚点改为标题文本，免行号漂移）
  - P2② verify.sh 3 项 deploy drift（见上，Phase 8 S2 覆盖，非本轮 scope）
  - P2③ `lib/verify.sh:227` §9 循环 `for _script in check-delegation.sh allow-direct.sh selftest-delegation.sh` 未含 `selftest-methodology.sh` → 登记遗留（本轮 scope 不含 verify.sh 改动，不阻断）
  - P2④ `references/methodology.md:137` `Google DeepMind 2023 文本质量分类法` / `:158` `Anthropic Claude Code 2024 内部规范` — 不可核（后者为"内部规范"不可公开引用）。虽已标"待补"，出处字段仍断言具体机构+文献，下游有引用不存在的来源之风险。修复：改为泛化表述（如"五维加权评分法为通用内容评估实践"）+ 保留待补登记
  - P3⑤ `scripts/selftest-methodology.sh:72` `[ "${N_A:-0}" -eq 1 ]`、`:78` `[ "${N_C:-0}" -eq 1 ]` — 精确计数断言，未来文档良性增写（如再加一处"FMEA 预演"）会误 FAIL。建议 `-ge 1`
  - P3⑥ `scripts/selftest-methodology.sh:64/:83` 用 `grep -c`（计匹配行数）但注释/描述称"9 条方法名关键词"/"3 处指针"（`:6`/`:9`）— 语义为"9 行/3 行"。建议描述改"≥9 行含关键词"或改用 `grep -o | wc -l`
  - P3⑦ `references/methodology.md:173` 落点表漏记 `SKILL.md:283`（Critical Rules 摘要指针）与 README 两键行
  - P3⑧ brief/Phase 7 文述"scope 内 5 文件"与实际 7 文件不符（README.md 与 writing-type.md 未计入），仅为口径描述问题，commit 信息已覆盖
- **负结果（排除项）**: config.json 既有 22 键零改动（numstat 20/0 纯新增；键集 diff 仅 +2；:68 后按字母序插入）；jq 合法；`additionalProperties: false` 在根（config.json:297）存在 → methodology.md:172 该论断**正确**（初查用 `jq '.additionalProperties // "ABSENT"'` 误得 ABSENT，因 `//` 视 false 为 empty，已复验删除该候选发现）；`grep -rn "FMEA\|📊" scripts/ lib/` 仅命中 selftest 自身 → 无脚本依赖模板 FMEA 段/emoji 锚点，模板新增段对下游 parser 安全；check-complete.sh rc=0、check-doc-sync.sh rc=2（无 task_plan.md → SKIP，verify 已列为 OK）非新增 fail；未发现安全/数据丢失/API 破坏类问题

#### [sub:08-executor-deploy] 合并+重部署

- **S1 合并回**: 主仓 scope(skills/task-planner/**)`git status --short` 无未提交变更(仅 plans/ 簿记残留,零重叠) → `git merge --no-ff wt/task-v063-methodology-intro` = merge commit **9f89908c9a54275e783a80d13286c2aed1f7ec96**（ort, 7 files +315/-2）。worktree `remove` OK + `branch -d`(was 119dcff) OK；filesystem 目录已消失, `git worktree list` 仅剩主仓 + 其他并行任务位
- **主仓探针 3 项**: `grep -c methodology SKILL.md`=**3**（≥3）；`test -f references/methodology.md` + `test -x scripts/selftest-methodology.sh` 均 OK；`bash scripts/selftest-methodology.sh` = **7 PASS=7 FAIL=0 EXIT=0**
- **S2 重部署（先 diff 后删拷）**: 删前预 diff 3 位均**零「Only in 部署位」**（仅 5 differ + 2 canonical 独有新增）→ 无部署位独有未收编修复,安全覆盖；逐位 `rm -rf && cp -rL` → `diff -rq` 3 位全 **IDENTICAL**。`.opencode`=软链 `-> /home/terry/.config/opencode`, readlink -f 真实目标 `/home/terry/.config/opencode/skills/task-planner`（操作路径经软链解析落在真实目录）
- **S2b verify 对账（中性 CWD /tmp + TASK_PLANNER_ROOT）**: 3 位各 **25 pass / 0 fail** → Phase 7 CR P2② 记录的 22/3 deploy drift（canonical 领先部署位引入）随重部署彻底消除
- **S2c 部署位 selftest**: 3 位 `selftest-methodology.sh` 各 **7 PASS=7 FAIL=0 EXIT=0**
- **S3 agent 2 位**: `grep -rln "methodology|fmea_enforce|content_quality_enforce|FMEA"` 于 2 个 plan-writer agent 位 = **0 命中**（与预测一致,本轮未改 companion/agents）→ 只读复验：zcode 位 diff 空 + md5 `f9a55d9a28b0bfb7c661f4bd3decda9e` 双同 = **逐字节一致**；claude 位 diff 仅 `7c7 model:` 行（`custom:...:sonnet-1` vs `sonnet`）= **仅 model 行差异**（adapt_model_line 预期）
- **S3 companion 6 位**: todo-skill(zcode/claude)/task-drift-guard(zcode/claude)/plan-resume(claude/.agents) `diff -rq` **全 0 行 = 无新差异**；`/home/terry/.zcode/skills/plan-resume` ABSENT = v062 遗留①（历史缺位）,非本轮新增
- **负结果（排除项）**: 无任何「部署位比 canonical 新」的位（预 diff 零 Only-in）；未触碰 task-v064/task-test 等其他 worktree 与任何其他技能目录写操作；未手改 skills/ 文件（合并仅经 git merge）；未 push；merge 仅动 skills/task-planner/** 7 文件故 companion canonical 零变更,6 位 diff=0 符合预期
- **交接遗留**: verify.sh:227 §9 循环未含 selftest-methodology.sh（CR P2③, 登记不阻断）；plan-resume@.zcode 历史缺位（v062 遗留①）

#### [sub:09-executor] 簿记收尾

- **task_plan.md**: Phase 2-8 由实测未勾选 → 全部 `[x]`+`Status: complete`（各附完成记录 + commit 证据）；Phase 9 complete；Current Phase=`Phase 9 complete`；Next Step=交付说明；Subagent Handoff 表 0 行 → **8 行**（对应 subagent-state 02-08 检查点）；委派统计段填机器口径
- **progress.md**: Phase 1 模板占位段 → 实段；Phase 2-8 Status→complete（补 Files/Test）；新增 Phase 9 段；📚 必要知识储备使用记录 6 行；Error Log 2 行；5-Question Reboot Check 填实；plan-resume 报告行注明 13:33（v063 串行未触发更新）
- **verification.md**: stub → 终验完成（VC-1..7 全 `[x]` 逐条 Evidence + Phase Gates 9 Phase 表 + 必要知识储备符合性核验 5 行全「符合」+ 委派统计复验粘贴机器 JSON 原文 + 质量门控 Q1-Q6 触发 0 + Goal Gate `outcome: COMPLETE` + 遗留 4 项 + 观察项 51b3057）
- **INDEX.md**: v062 行后补 `- task-v063-methodology-intro ✓ (9/9, merge 9f89908, deploy 3+2, CR APPROVED, 遗留 4) — 2026-09-12`；汇总 complete **29→30**
- **attest 重锁**: SHA-256 `48f1835579f4aef1fc5d3a090c4882f842d2f38a62c02ee9a4a99adf43563b27`（`--verify` exit 0）；attest 前置 `check-plan-dispatch.sh` = 「✓ 7 个派发型 Phase 均有带执行体的 S-unit 表」
- **机器委派统计**: `{"phases_total":9,"phases_delegated":7,"main_direct_count":2,"delegation_rate":0.778,"violations":[],"verdict":"ok"}`（EXIT=0）
- **终验抽查（主进程第一手 Repro，canonical 仓）**: `wc -l references/methodology.md`=176；`grep -c methodology SKILL.md`=3；`jq '.properties|keys|length'`=24 + 两键 default=warn/enum 三态；`grep -c "FMEA 预演" templates/task_plan.md`=1、`grep -c "五维评分卡" templates/variant/writing-type.md`=1；`bash scripts/selftest-methodology.sh` = `Total: 7 PASS=7 FAIL=0`
- **输入 brief 偏差修正（负结果）**: ①brief 称「Phase 1-8 已逐步勾选」实为仅 Phase 1 勾选（2-8 均 pending）——已据 findings/progress/subagent-state 证据回填；②brief 预估「子代理 6 Phase/委派率 0.667/WHITELIST-EXEMPT」实为 7 Phase 委派、rate=**0.778**≥0.7 floor、verdict=ok，无需豁免（机器统计为事实源）
- **负结果（排除项）**: 未触碰 `skills/` 任何文件（仅读抽查）；未 push；未 add 其他计划目录（v059 .session-owner / v064 / .plan_required_side / .active_plan 均未纳入 commit）；master 侧观察到 1 个空提交 `51b3057`「init」（author t，无文件变更，为 merge 9f89908 第一父），非 v063 产物，未改写历史仅登记
