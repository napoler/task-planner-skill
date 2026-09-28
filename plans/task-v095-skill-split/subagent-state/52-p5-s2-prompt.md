# P5-S2 派发任务书（全文即指令）

task-v095 Phase 5 的第 2 个 S-unit：协同路由迁移的七文件一致性同步。工作区 = worktree：/mnt/data/dev/task-planner-skill-worktrees/task-v095-skill-split（下称 WT）。

## 材料包
- /mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/knowledge-brief.md §5「P5-S2」行 + §4 易错点第 1 条（锚保全）
- 消费方清点（已实测）：selftest-skill-collab.sh L9 COLLAB 变量 + T2b（SKILL.md 引用 ≥2）+ T9a（skill_collab_enforce 在 CONFIG/references/SKILL ≥2 文件）；selftest-shared-tracker.sh L25 COLLAB；selftest-fallback.sh T10a（hint 全序精确串含「(见 references/skill-collaboration.md)」）；subagent-fallback.sh L288 hint；registry.tsv L11/23/24 dep_anchors；SKILL.md L44 标题/L52 指针/L306 Rule 30 摘要行/L346 表行/L351 外部 skill 行；critical-rules.md L131（22.3.3 尾部权威源）/L253（30.5 详见）。行号会漂移，全部 grep 重定位，禁盲信行号。

## 允许写入（7 文件 + 检查点）
1. WT/skills/task-planner/SKILL.md
2. WT/skills/task-planner/references/critical-rules.md
3. WT/skills/task-planner/scripts/selftest-skill-collab.sh
4. WT/skills/task-planner/scripts/selftest-shared-tracker.sh
5. WT/skills/task-planner/scripts/selftest-fallback.sh
6. WT/skills/task-planner/scripts/subagent-fallback.sh
7. WT/skills/task-planner/scripts/selftest-registry.tsv

## 操作步骤
1. SKILL.md §协同路由段（grep `专业技能协同路由`，自 `### 🤝` 标题至下一同级标题）：收敛为 ≤8 行指针节——必须保留：标题关键词「专业技能协同路由」；`config.json#skill_collab_enforce` 键名完整出现（T9a 依赖）；comet/OpenSpec/superpowers/dynamic-workflows 四族名各 ≥1；判定顺序敏感一句；22.3.3 卡壳接管一句；Skill("plan-collab-router") 主路由行；`skill-collaboration.md` 全文出现 ≥2 次（T2b 依赖）
2. SKILL.md 其余三处（Rule 30 摘要行/References 表行/外部 skill 行）：路径前缀 `references/skill-collaboration.md` → `../plan-collab-router/references/skill-collaboration.md`，「共享内容认领追踪」关键词保留
3. critical-rules.md 两处路径前缀随迁（L131 尾部/L253）；22.3.3 与 30.5 条款正文一字不动（仅路径 token）
4. selftest-skill-collab.sh：COLLAB 变量（L9）→ `$ROOT/../plan-collab-router/references/skill-collaboration.md`（沿用既有 $ROOT 风格）；断言块前加注释 `# [task-v095 P5] skill-collaboration.md 迁至卫星 plan-collab-router，COLLAB 路径跟随迁移`；断言语义零改动
5. selftest-shared-tracker.sh：COLLAB 变量（L25）同上
6. subagent-fallback.sh L288 hint 与 selftest-fallback.sh T10a 期望串成对同步：`(见 references/skill-collaboration.md)` → `(见 ../plan-collab-router/references/skill-collaboration.md)`，两文件字符串必须逐字符一致
7. registry.tsv L11/23/24 dep_anchors 中 `references/skill-collaboration.md` → `../plan-collab-router/references/skill-collaboration.md`（3 行，分隔符格式保持）
8. 验证链（留输出）：
   a. `bash scripts/selftest-skill-collab.sh` → 期望 25/0
   b. `bash scripts/selftest-shared-tracker.sh` → 期望 11/0
   c. `bash scripts/selftest-fallback.sh` → 期望 31/0
   d. `bash scripts/selftest-registry.sh` → 期望 5/0
   e. 全量：`(cd scripts && for f in selftest-*.sh; do bash "$f" >/dev/null 2>&1 || echo "FAIL $f"; done; echo SUITE-DONE)` → 无 FAIL 行；非预期 FAIL → STOP 上报禁硬修

## 硬约束
- 仅改路径/指针，禁改条款语义与断言强度；禁 git；禁网络；禁碰卫星文件
- T10a 双文件字符串不一致 = 必然 FAIL，验证有 FAIL 先查此项

## 计划三文件（只读）
- /mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/task_plan.md
- /mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/findings.md
- /mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/progress.md

## 检查点
/mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/subagent-state/52-p5-s2.md（逐处前后对照 + 验证链输出）

## 返回（8 字段严格格式）
status: / acceptance: / 产出文件: / 关键结论: / 证据: / 未完成项: / 失败与原因: / checkpoint: / 风险提示:

时间盒 ≤20min。
