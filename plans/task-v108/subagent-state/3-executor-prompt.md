# 批次二修复任务书（subagent-state/3-executor-prompt.md）

执行体：executor · WT = /mnt/data/dev/task-planner-skill-worktrees/task-v108

## 修复项（M-04/M-09：16 variant 四点同步面，全部修正类）

**M-04** — `WT/skills/plan-template-kit/references/template-mapping.md`：
- §一 文件清单（约 :32-44，现 13 行）补 2 行至 16：
  - `- \`templates/variant/video-type.md\`(v3，task-v093 收录；视频生产任务模板，video 家族主分支)`（插在 video-fix-type.md 行之前）
  - `- \`templates/variant/mini-lite-type.md\`(v2，task-v086 新增；轻量档 mini 计划模板，Rule 38.3 区块白名单承载)`（插在清单末尾或按 v2 系列相邻位置）
- §六 速查表（约 :133-145，现 13 行）补 3 行至 16：video-type、video-fix-type 若缺则补、mini-lite-type（对齐表内现有列范式：类型/适用场景/机制画像要点；video 家族两行标注「内容组-视频」画像，mini-lite 标注「轻量档豁免」）
- §九 矩阵（约 :209-226，现 14 行=13 variant+general）补 video-type/video-fix-type/mini-lite-type 3 行至 17 行（16 variant+general；对齐表内现有列范式）

**M-09** — 四点同步补齐（13→16 口径）：
- `WT/skills/task-planner/companion/agents/plan-writer.md` :53-66 映射表（现 14 行）补 mini-lite/video/video-fix 3 行至 17（对齐现有行范式）
- `WT/skills/task-planner/SKILL.md` :274「standard 13 variant」→「standard 16 variant」
- `WT/skills/task-planner/references/critical-rules.md` :348「14 行:13 variant+general」→「17 行:16 variant+general」；:361「现有 13 个 variant」→「现有 16 个 variant」
- 注意：guide §2.2 已是 16 行完整（无需动）；selftest-template-lifecycle TL-17 只锚 guide「16 个」串（勿动该串）；TL-18 只断言 §九节存在不断言行数

## 验收
1. `git -C WT diff --stat` 涉及恰好 4 文件（template-mapping.md/plan-writer.md/SKILL.md/critical-rules.md）
2. 计数一致性：mapping §一 `grep -c "variant/" `段内清单行=16；§六/§九 行数=16/17；grep「13 variant」「14 行」在四文件零残留
3. `bash WT/skills/task-planner/scripts/selftest-template-lifecycle.sh` → 18/18 PASS
4. checkpoint 落盘含最终结论 8 字段块

## Scope 禁改
只改上述 4 文件；selftest 只读运行；禁止 git add/commit；禁动 worktree 外文件；guide §2.2 不动

## 返回格式（8 字段，无内容填 none，8 字段后不得有任何内容）
```
status: done | partial | failed | timeout
acceptance: <n>/<4> pass — 逐项原文行
files: <绝对路径>(+N/-M); ...
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:3-executor]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
