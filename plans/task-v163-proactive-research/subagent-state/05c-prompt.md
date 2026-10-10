# S14 详细派发 prompt（Rule 35.3 大内容落盘）

## 1. 目标
完成 Rule 75 的 SKILL.md 级联与全仓宽容锚修齐：① SKILL.md 三处计数位 1-72→1-75 + Rule 75 摘要 bullet + C51 合规清单行；② 全仓 14 脚本宽容锚扩展（覆盖 75 纪元）；③ README/CLAUDE.md/README_zh.md 计数标签（grep 命中才动）。

## 3. Scope
- 允许写入：
  - worktree skills/task-planner/SKILL.md（计数位+bullet+C51 行，行位替换优先，净增 ≤10 行）
  - worktree skills/task-planner/scripts/（宽容锚扩展，仅改锚正则+注释）
  - worktree README.md / CLAUDE.md / README_zh.md（grep "1-7" 命中才改计数标签）
- 禁止：修改其他任何文件；git 操作；网络访问

## 4. 步骤（≤4）
- ① SKILL.md 级联：
  a. 三处计数位 1-72→1-75（grep -n "1-72" 定位，行位替换）
  b. 在 Rule 72 摘要 bullet 后追加 Rule 75 bullet：`- **Rule 75（网络调研主动激活与外部数据依赖纪律 — task-v163）**：公理=本地有界·网络扩展（75.0）/计划期调研需求三态分析+关键词预设（75.1）/执行期反死磕主动激活（75.2）/现成方案优先（75.3）/GitHub 检索纪律（75.4）/外部工具强制+安装建议（75.5）/模板层调研触点+生成判定（75.6）；零新 config 键+selftest-proactive-research.sh 守护`
  c. 合规清单追加 C51 行：`| C51 | 网络调研主动激活自查（Rule 75）：计划期已做调研需求三态分析（75.1，NET-* 条目含关键词+渠道+产出形态）；执行期遇阻已评估网络检索而非死磕（75.2，死磕判定式=同思路≥2 次无外部输入→转检索）；实现类任务动手前已检索现成方案（75.3/75.4，gh CLI 必用）；外部工具缺失已登记+安装建议（75.5，禁默默降级纯本地路径）；本任务无网络调研场景时登记豁免一行（机器面=selftest-proactive-research.sh 静态断言，核查过程人工；mini 档豁免） | ☐ |`
- ② 全仓宽容锚扩展（findings S3 清单）：
  a. selftest-self-resolution.sh `1-(6[0-9]|7[0-2])` → `1-(6[0-9]|7[0-5])`
  b. selftest-tool-selection.sh `1-(6[0-9]|7[0-2])` → `1-(6[0-9]|7[0-5])`
  c. selftest-root-resolution.sh `1-(5[3-9]|6[0-9]|7[0-2])` → `1-(5[3-9]|6[0-9]|7[0-5])`
  d. selftest-conclusion-discipline.sh `1-7[0-2]` → `1-7[0-5]`
  e. selftest-research-first.sh:76 `1-(69|71|72)` → `1-(69|71|72|75)`
  f. selftest-requirement-coverage.sh / selftest-lane-advancement.sh：实测正则确认覆盖 75，不覆盖则扩
  g. selftest-parallel-scheduling.sh `1-72` → `1-7[0-5]`
  h. selftest-context-pressure.sh `1-(69|71)` → `1-(69|71|75)`
  i. selftest-workflow-orchestration.sh:70-76 实测确认
  （已覆盖 75 的 4 处不动）
  每处修改后更新注释加 `[2026-10-10 task-v163 级联: ...]` 行
- ③ 验证：全仓 grep "1-7" 确认 75 纪元全覆盖 + SKILL.md wc -l 行数复核 + bash -n 全部改动脚本
- ④ 写检查点 + findings 追加段

## 5. 验收
- SKILL.md 三处计数位=1-75 + Rule 75 bullet + C51 行在位
- 全仓 grep "1-7" 确认 75 纪元全覆盖
- 改动脚本 bash -n 语法全通过
- SKILL.md 行数上限断言同步上调+label 注明 task-v163

## 6. 产出
- SKILL.md + scripts/ 宽容锚扩展（~8 文件）
- findings.md 追加 `#### [sub:05c-executor] SKILL 级联与全仓锚修齐` 段
- 检查点：/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/05c-executor-s14.md

## 7. 返回格式(严格 8 字段)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass
files: <绝对路径>(+N/-M)
evidence: <file:line>
checkpoint: <绝对路径> (status: done)
findings_written: #### [sub:05c-executor]
blockers: none
confidence: HIGH | MED | LOW
```
