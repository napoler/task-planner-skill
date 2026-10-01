# [sub:5-executor] Phase 2 S3 卫星+配套 9 技能文档审查 checkpoint

任务：9 个 skill（plan-collab-router / plan-cost-guard / plan-research-router / plan-template-kit /
plan-resume / todo-skill / task-drift-guard / progress-tracker / iterative-optimizer）四维内容质量审查。
Scope：只读 skills/ + plans/task-v107/（findings 追加小节 + progress 追加行 + 本 checkpoint）。

## 里程碑（逐维落盘）

- [x] Init：task_plan/findings/progress 已读；9 skill 文件树盘点（26 文件）
- [x] 维度1 引用路径实存：20+ 条抽验 0 MISSING
- [x] 维度2 跨技能一致性：主→卫星 6 条 + 卫星→主 6 锚全实存；三族成员数 13/11/10 实测一致
- [x] 维度3 registry/清单：tsv 42=42、iter-optimizer selftest 实存实跑、review-library 11、variant 16
- [x] 维度4 过期数字/自引用：1 P1 + 3 P2 + 1 待复核

## 维度1 引用路径实存（抽验清单，20 条）

| # | 引用 | 位置 | 结果 |
|---|------|------|------|
| 1 | plan-cost-guard/references/{cost-control,billing,cost_log}.md | SKILL.md:14-16,29 | EXISTS×3 |
| 2 | plan-collab-router/references/skill-collaboration.md | SKILL.md:8,10,40 | EXISTS |
| 3 | plan-research-router/references/research-routing.md | SKILL.md:8,10,17,39 | EXISTS |
| 4 | plan-template-kit/references/{template-mapping,template-guide}.md | SKILL.md:12-13 | EXISTS×2 |
| 5 | progress-tracker/references/ledger-format.md | SKILL.md:52,92,156 | EXISTS |
| 6 | plan-resume/scripts/{scan-plans.sh,extract-meta.sh,score-plans.py,select-and-resume.sh} | SKILL.md:44,74,260-263 | EXISTS×4 |
| 7 | plan-resume/{config.json,tests/smoke.sh,README.md} | SKILL.md:264/README:36 | EXISTS×3 |
| 8 | todo-skill/tools/cli_todo-manager.ts + _meta.json + WORKFLOW.md + tools/store.json | SKILL.md:40/文件树 | EXISTS×4 |
| 9 | task-planner/scripts/{selftest-template-lifecycle,check-complete,check-scope,init-session,sync-todos,check-conflicts,check-drift,check-template-type}.sh | template-mapping:26,167-195 / template-guide:286-290 | EXISTS×8 |
| 10 | task-planner/companion/agents/plan-writer.md（34.2 落点） | critical-rules:314 | EXISTS |
| 11 | task-planner/review-library/（池） | — | EXISTS 11 目录 |
| 12 | 卫星本地无 references/critical-rules.md | 4 卫星 grep local | MISSING（见 C-P2 判读） |

结论：无路径断裂。#12 非缺陷——satellite 侧裸 `references/critical-rules.md` 为指针惯用写法，
plan-cost-guard/SKILL.md:29 明言跨技能指针指向主技能；判读见 C-P2。

## 维度2 跨技能引用一致性

卫星→主锚点抽验 6 条（全部实存）：
- Rule 17.1 → critical-rules.md:80 `17.1 opus Skill 节流... ≤1 次`
- Rule 17.5 → :84 `≥10 次 → AskUserQuestion`
- Rule 17.8 → :87（17.8 原文已改写指向 `../plan-cost-guard/references/cost_log.md`，主侧指针正确）
- 22.3.3 → :153（尾句「唯一权威源 = ../plan-collab-router/references/skill-collaboration.md」闭环）
- Rule 34.1 → :313；Rule 37.1 → :348（37.1 声称「矩阵 14 行」与 §九 实测 14 行一致）
- config 键：skill_collab_enforce / shared_tracker_enforce / template_gate_enforce / knowledge_brief_enforce
  均在 task-planner/config.json；autonomous_resume 在 plan-resume/config.json（+主 config）

反向主→卫星 6 条（全部实存）：SKILL.md:307/308 billing+cost-control、:311 skill-collaboration、
:431 research-routing、:251/:442 template-mapping、:80 progress-tracker、:96/:125/:169 task-drift-guard、
:178 plan-resume。

三族成员数实测：`ls -d ~/.zcode/skills/comet*`=13、`openspec-*`=11、`~/.agents/skills/`（10 名单）=10
——与 skill-collaboration.md §一 声称 13/11/10 完全一致。

## 维度3 registry/清单一致性

- **selftest-registry.tsv**：43 行（表头 1 + 数据 42）= 实际 `scripts/selftest-*.sh` 42 个；
  4 列制每行成立、无重、无孤儿；实跑 `selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=42, actual selftest=42)`。
  iterative-optimizer 行在末行（`selftest-iterative-optimizer.sh`），与 42 selftest 计数一致。
- **plan-template-kit 16 类**：`ls templates/variant/` 实测 16；SKILL.md:19/145、mapping:26「v093 起 16 类」✓；
  TL-17 断言 grep「16 个」实跑 PASS（template-lifecycle 18/18）。注意 mapping §一 仅列 14 文件（缺 video-type、
  mini-lite-type）→ 计 C-P3。
- **review-library**：`ls review-library/`=11 目录（alignment/code-quality/content-quality/data-quality/
  documentation/general/image/release/security/test-quality/ui-quality）与「11 池」一致。

## 维度4 过期内容/数字

实测 vs 声称对拍（节选）：selftest 42 ✓、脚本 75（Phase 1 基线，本面未复测）、variant 16 ✓、
templates 实测 25 个 .md ≠ guide「实际 26」✗、grep 锚「## 📚 必要知识储备」=22 ✓（guide :69/:77 写 22，
但同文件 :63/:65 写 26/23）✗、iter-optimizer SKILL.md 97 行 ∈ [90,120] ✓、IL-08 banned 词命中 0 ✓
（`selftest-iterative-optimizer.sh` 实跑 8/8 PASS）。

## 问题清单

### C-P1 (P1) plan-cost-guard 17.5 阈值断言无主侧来源
- 锚点：skills/plan-cost-guard/SKILL.md:21
- 原文：`**Rule 17.5**：单会话 opus 累计调用（主进程+嵌套+subagent 升级）≥10 次 → 触发 AskUserQuestion；>15 次强制 STOP`
- 证据：主侧 critical-rules.md:84 `17.5 opus 调用门控:...≥10 次 → AskUserQuestion`（无 STOP 档）；
  `grep -n "STOP" critical-rules.md | grep 17` 仅命中 18.3；「15」在该文件 17 节 0 命中。卫星侧多出「>15 强制 STOP」档 = 过期或无源断言。
- 修复建议：与主侧 17.5 对齐——删除「>15 强制 STOP」或在主侧 Rule 17.5 增补该档（同源同改，v093 教训）；references/cost-control.md:33 仅写 ≥10 未含 15，三处口径需统一。

### C-P2 (P2) 卫星侧裸 `references/critical-rules.md` 指针歧义
- 锚点：skills/plan-cost-guard/references/cost-control.md:168、cost_log.md:69、template-mapping.md:26
- 证据：四卫星本地 `ls references/critical-rules.md` 均 MISSING（grep -l 无命中）；plan-cost-guard/SKILL.md:29 已声明该指针指向主技能；template-mapping.md:26 句末「完整条款见 `references/critical-rules.md` Rule 34」无主技能限定词，读者在卫星目录内解析会落空。
- 修复建议：三处裸路径改 `../task-planner/references/critical-rules.md`（或沿用 :29 的「主技能」措辞）。

### C-P3 (P2) template-mapping §一/§六 枚举 14 < 16 类
- 锚点：skills/plan-template-kit/references/template-mapping.md:31-44（14 条文件清单）、:128-146（速查表 14 行）
- 证据：`ls templates/variant/ | wc -l` = 16；缺失两条 = `video-type.md`（§六 表无行）与 `mini-lite-type.md`（§一 清单无、§六 表无；:242 却引用 mini-lite 档）。TL-17 只断言「16 个」计数不断言清单逐行，故机器面未抓出。
- 修复建议：§一 补 2 行文件 + §六 补 2 行速查（video 家族 B、mini-lite 轻量档）；或加「完整清单以 ls variant/ 为准」注脚。

### C-P4 (P2) template-guide 数字簇 26/23 过期
- 锚点：skills/plan-template-kit/references/template-guide.md:63（「templates/ 实际 26 个 .md」）、:65（「23/26 个模板文件统一含」）
- 证据：`find templates -name '*.md' | wc -l` = 25（2026-09-28 v093 后无新增却写 26）；实测缺锚文件恰 3（knowledge-brief/shared-tracker/mini-lite → 22 含锚），与同文件 :69/:77 grep 锚=22、:102「task_plan 系含锚 15」三口径互斥。
- 修复建议：:63 改 25、:65 改「22/25」（=25−3 例外）或统一指向 grep 锚口径 22。

### C-P5 (P2) progress-tracker 边界表幽灵技能 plan-bookkeeper
- 锚点：skills/progress-tracker/SKILL.md:192（`| plan-bookkeeper | task-planner 三文件机械回填 |...`）
- 证据：`ls -d ~/.zcode/skills/plan-bookkeeper ~/.claude/skills/plan-bookkeeper ~/.agents/skills/plan-bookkeeper` 0 命中；仓内 `ls skills/plan-bookkeeper` 不存在；全仓 grep 仅 progress-tracker/SKILL.md:192 一处引用（无定义/部署位）。
- 修复建议：该行改指向实存职责承接方（task-planner 侧 Plan bookkeeper/主进程簿记职能）或标注「已移除」。

### C-P6 (待复核) session-catchup 口径
- 锚点：skills/plan-resume/SKILL.md:246（`session-catchup` 技能行）、skills/plan-cost-guard/references/billing.md:40/58（`session-catchup.ts`）、skills/task-planner/SKILL.md:57（`bun scripts/session-catchup.ts`）
- 证据：实存 = task-planner/scripts/session-catchup.ts（EXISTS）；但 plan-resume 表格把 `session-catchup` 当独立 skill 名引用（三部署位无此 skill 目录），billing.md 写作 `.ts` 文件名而非相对路径。疑为脚本名/技能名混用，影响面=口径不清非路径断裂。
- 修复建议：主进程裁决：三处统一为「task-planner scripts/session-catchup.ts」口径。

### 负结果（无异常项）
- plan-research-router / plan-collab-router / plan-resume / task-drift-guard / todo-skill / iterative-optimizer 六技能文档面：引用、数字、锚点全部一致，0 问题。
- iterative-optimizer SKILL.md 97 行与 selftest IL-02 [90,120] 吻合；banned 词 0；registry 末行登记在位；install-companion 顶层分发注脚（:97）与 v106 交付一致。

## 最终结论

```
status: done
acceptance: 3/3 pass — [1:四维结论 2:问题清单格式合规 3:检查点落盘]
files: /mnt/data/dev/task-planner-skill/plans/task-v107/findings.md(+1 小节) ; /mnt/data/dev/task-planner-skill/plans/task-v107/progress.md(+1 行) ; /mnt/data/dev/task-planner-skill/plans/task-v107/subagent-state/5-executor.md(+本文件)
evidence: critical-rules.md:84→"17.5 ... ≥10 次 → AskUserQuestion"(无 15/STOP,对照 plan-cost-guard/SKILL.md:21); find templates -name '*.md'|wc -l → 25(对照 template-guide.md:63 "26"); tail -n+2 selftest-registry.tsv|wc -l → 42 = ls selftest-*.sh 42; selftest-registry.sh → "Total: 5 PASS=5 FAIL=0"; selftest-iterative-optimizer.sh → "Total: 8 PASS=8 FAIL=0"; grep -rl "## 📚 必要知识储备" templates/ → 22
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v107/subagent-state/5-executor.md (status: done)
findings_written: #### [sub:5-executor] 卫星配套技能审查
blockers: none
confidence: HIGH
```
