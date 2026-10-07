# checkpoint: 6-code-assistant（task-v144 S6，2026-10-08）
status: done

## 产出
- 文件: /mnt/data/dev/task-planner-skill-worktrees/task-v144/skills/task-planner/scripts/check-dispatch.sh
  diff = +96/-0 单文件（worktree 内其他 M 文件属并行单元 S1-S5 产物，未触碰；未 git add/commit）
- 改动位置: fine_grain_checks() 内 ④ 步骤枚举之后插入 ⑥⑦ 两项检测 + 文件头新增 [2026-10-08 task-v144 S6] 注释段

## ⑥ 粒度三值（Rule 59.1）
- 提取器 gran_tok(): 全文 grep -oE `[0-9]+f/[0-9]+l/[0-9]+min` 候选 → grep -F 逐行 + awk 行级边界双验证
  （前界∈行首/空白/|，后界∈行尾/空白/|——裸独立行与表格列内嵌 `| 1f/150l/20min |` 均合法入口，
  自由文本粘连剔除防误报；全角中文粘连实测不误报）
- 任务书分支同步提取（59.5 豁免收窄口径，与 ②④ 同源 extract_subagent_state_refs）
- 上限: jq 读 config 既有键 subagent.step_max_files/step_max_lines/step_max_minutes（顶层覆盖优先，
  现行默认 2/100/15，59.7 零新键）；jq 缺失/非数字 → 回退默认 + SKIPPED 一行（禁静默失败）
- 首个 token 三值任一超限 → 计 hits 走既有档位管线（enforce=exit 2 硬阻断），
  提示串: `[dispatch-guard] ⚠ 粒度三值 <tok> 超限(files≤/lines≤/min≤)（Rule 59.1 粒度三值硬门）`

## ⑦ 伴飞技能路径存在性（Rule 59.2）
- 提取器: 仅「伴飞」关键行内 .md 路径 token（grep 伴飞行 → grep -oE `[A-Za-z0-9._/-]+\.md`）——
  路径样本域=伴飞声明行而非全文（防误抓 prompt 内 plan 三文件/subagent-state 引用）；
  任务书分支对引用任务书伴飞行同步提取
- 占位符口径裁决: <path>/SKILL.md 中 < > 不属字符类，最长匹配得 /SKILL.md → -f 必失败按违规计
  （单一判据零剔除特例；伴飞路径未实例化=注入未声明完成本就不应放行）
- 逐路径 -f 校验，首个不存在短路违规（fail-closed），提示串含「Rule 59.2 伴飞路径不存在」；
  无伴飞声明 → esrcs 空 → 跳过不误报
- 踩坑记录: `esrcs="()"` 被 bash 当字符串字面量（set -u 下 ${#esrcs[@]} 报 unbound variable）→ 改 `esrcs=()`

## 验收实测证据（enforce 档，全新 fixture /tmp/v144-s6-test-final）
| 样例 | 输入 | 结果 |
|------|------|------|
| p1 | 裸行 3f/150l/20min | rc=2, 命中「Rule 59.1 粒度三值硬门」 |
| p1-7 | 粘连「见 3f/150l/20min 页」/ 全角「见3f/150l/20min页」 | 空格粘连=合法入口命中；纯 CJK 粘连=剔除不误报 |
| p1-8 | 任务书表格内嵌 `| S6 ... 1f/150l/20min |` | rc=2 命中（59.5 收窄口径） |
| p2 | 伴飞行声明 /tmp/.../NO-SUCH/SKILL.md（不存在） | rc=2, 命中「Rule 59.2 伴飞路径不存在」 |
| p3 | 伴飞路径存在 + 1f/40l/10min 不超限 | rc=0 静默 |
| p4 | 无三值无伴飞（既有基线） | rc=0 静默 |
| p10 | 3581 字符 | 既有 ① 长度超限回归命中 rc=2 |
| p11 | S3+S6 双 ID | 既有 ② 多 S-unit 打包回归命中 rc=2 |
| p12 | <path>/SKILL.md 占位符 | 按裁决 rc=2（/SKILL.md -f 失败计违规） |
| warn 档 p1 | | rc=0 + 计数文件行含「粒度三值超限」 |
| off 档 p1 | | rc=0 静默 |

回归: bash -n 通过；selftest-dispatch.sh 31/31、selftest-dispatch-grain.sh 10/10、
selftest-fine-grain-steps.sh 11/11 全 PASS（既有 4 项校验零回退）；
git diff --numstat = 96 0（仅 check-dispatch.sh 单文件）

## 负结果/排除项
- check-plan-dispatch.sh 表侧三值 enforce 升级 = 后续单元范围，本单元未改（brief §5 口径）
- knowledge-brief.md 由 S4 改好，本单元未触碰
- 既有 ①-⑤ 分支代码零改动，仅插入 ⑥⑦；串行槽/off 档/三级目录解析语义不变

## findings/progress 落盘
- findings.md `## Research Findings` 段末追加 `#### [sub:6-code-assistant]` 块（在 sub:3 块之后、`## Technical Decisions` 之前）
- progress.md Phase 3「Actions taken」下追加 `  - [sub:6]` 一行
