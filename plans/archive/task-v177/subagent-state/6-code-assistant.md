# Subagent Checkpoint — 6-code-assistant（task-v177 索引级联单元）

status: done
date: 2026-10-15
scope: task-planner 侧 Rule 86 索引级联 + 「Rules 1-84」陈旧措辞刷（85 欠账一并）

## 改动清单（worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v177）

### skills/task-planner/SKILL.md（5 处）
1. :9 frontmatter 行 8「Rules 1-84」→「Rules 1-86」+ 级联注
2. :17 frontmatter 卫星行 task-discipline 枚举 `,85`→`,85,86` + 级联注
3. :162 卫星路由表 task-discipline 行枚举 `,85`→`,85,86` + 级联注
4. :175 「Rules 1-84 全集索引」→「Rules 1-86 全集索引」+ 级联注
5. :217 References 表行「1-84 全集索引」→「Rules 1-86 全集索引」（保持 `Rules 1-86` 三连形态）+ 级联注

### skills/task-planner/references/critical-rules.md（1 处）
6. :182 卫星路由索引 task-discipline 行全展开枚举末位 `,85`→`,85,86` + 级联注
   - grep「1-84」：本文件无同款陈旧措辞，无需刷

### selftest 级联（被钉值 grep 命中 3 个脚本，均属「被钉值的 selftest 级联」授权范围）
7. scripts/selftest-parallel-scheduling.sh:120-126 — P-05 `Rules 1-84`→`Rules 1-86`，skill_max 84→86，演进史注释补 task-v177 行
8. scripts/selftest-requirement-grading.sh:91-101 — RG-06 全集锚 `1-8[0134]`→`1-8[01346]`，注释补 1-86 对齐
9. scripts/selftest-verification-gate.sh:79-86 — VG-06 `Rules 1-84`→`Rules 1-86`，注释补纪元 1-84→1-86

未动：scripts/selftest-media-dispatch.sh 的 47.5 改动属 media 单元（47.4→47.5 五子条），非本单元范围，本单元零触碰。
selftest-input-consistency.sh IC-03 锚 = task-discipline 行含「85」（弱锚设计，改后仍命中 85,86，无需级联）。

## 验证
- grep -c "Rules 1-86" SKILL.md = 3（≥3 PASS）
- grep -n ",85,86" 三处命中（SKILL.md:17/:162 + critical-rules.md:182）PASS
- bash -n 三脚本语法 OK；实跑 selftest-parallel-scheduling（9 PASS）/ requirement-grading（7 PASS）/ verification-gate（12 PASS）全 0 FAIL
- git status：本单元改动 = SKILL.md / critical-rules.md / 3 selftest；media-dispatch 改动为前置 media 单元遗留，非本单元写入
