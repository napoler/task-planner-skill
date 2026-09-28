# P7-S1 派发任务书（全文即指令）

task-v095 Phase 7 的第 1 个 S-unit：安装面四件套。工作区 = worktree：/mnt/data/dev/task-planner-skill-worktrees/task-v095-skill-split（下称 WT）。

## 材料包
- /mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/knowledge-brief.md §5「P7-S1」行 + §3 check-skill-modify/install-stub 锚行
- 事实：4 卫星 = skills/{plan-research-router, plan-template-kit, plan-cost-guard, plan-collab-router}（各含 SKILL.md + references/，零 config 零 hook 零硬编码绝对路径，卫星→主技能引用全为 `../task-planner/...` 同级相对）

## 允许写入（5 文件 + 检查点）
1. WT/skills/task-planner/install.sh
2. WT/skills/task-planner/lib/install-stub.sh（仅当 rsync/复制清单在此）
3. WT/skills/task-planner/scripts/check-skill-modify.sh
4. WT/skills/task-planner/scripts/selftest-skill-split.sh（新建）
5. WT/skills/task-planner/scripts/selftest-registry.tsv

## 操作步骤
1. Read install.sh 与 lib/install-stub.sh，弄清当前部署面（哪些工具位走全量复制、哪些走 stub+sed 重写）。**最小 diff 扩展**：使 4 个卫星技能目录与 task-planner 一样被安装到各工具位（全量位=整目录复制；stub 位=按既有模式处理——卫星无 scripts/config，stub 只需 SKILL.md+references/ 或直接整目录，选择 diff 最小方案）。禁止改动与卫星无关的安装逻辑
2. check-skill-modify.sh 保护 pattern（grep 定位 case 块，约 L25-33）：追加 4 个卫星路径匹配（对齐既有 pattern 风格，如 `*plan-research-router*|*plan-template-kit*|*plan-cost-guard*|*plan-collab-router*` 或逐条 case），注释注明 `[task-v095 P7] 卫星技能纳入 Rule 36 保护`
3. 新建 selftest-skill-split.sh（沿用仓内 selftest 惯例——先 Read 一个现有 selftest 学 t/ok/bad 助手与输出格式），断言清单（≥20 条）：
   - 4 卫星目录与 SKILL.md 存在；frontmatter name 与目录名一致；各 SKILL.md <100 行（薄正文）
   - 主 SKILL.md 行数 ≤430 且 ≤558；四个路由指针在位（grep plan-research-router / plan-template-kit / plan-cost-guard / plan-collab-router 各 ≥1）
   - 迁移内容抽检：卫星 references/research-routing.md 含「强制引用格式」；plan-template-kit/references/{template-guide,template-mapping}.md 存在且 guide 含「16 个」；plan-cost-guard/references/ 含 cost-control/billing/cost_log 三件；plan-collab-router/references/skill-collaboration.md 存在且 ≤300 行
   - 主 SKILL.md 死路径零残留：grep 旧路径（references/template-guide.md 等 5 个迁移源）经 `grep -v 'plan-'` 过滤后零命中
   - 锚点抽验：主 SKILL.md 含「Rule 17 成本控制」「| C19 |」「| C25 |」「| C26 |」「Rules 1-3」
   - check-skill-modify.sh 含 4 卫星名；registry.tsv 含 selftest-skill-split 行
4. registry.tsv 追加一行（格式对齐既有行：脚本名<TAB>描述<TAB>触发条件<TAB>dep_anchors，dep_anchors 写 4 卫星 SKILL.md 相对路径）
5. 验证链（留输出）：
   a. `bash scripts/selftest-skill-split.sh` → 全 PASS
   b. `bash scripts/selftest-registry.sh` → 5/0 且 rows=35（registry 行数与 selftest 文件数相等断言）
   c. 守卫行为级验证：以卫星文件路径为入参调用 check-skill-modify.sh（按其 CLI 用法，先读文件头 Usage），确认卫星路径被识别为保护区（观察输出/退出码）；再以一个非保护路径对照确认不误伤
   d. 全量：`(cd scripts && for f in selftest-*.sh; do bash "$f" >/dev/null 2>&1 || echo "FAIL $f"; done; echo SUITE-DONE)` → 无 FAIL；非预期 FAIL → STOP 上报

## 硬约束
- config.json 与 hook 接线零改动；禁 git（含 stash/restore/checkout）；禁网络；禁碰卫星文件与主 SKILL.md
- install.sh 改动保持向后兼容：不运行安装（S4 才部署），只改逻辑 + 语法自检（bash -n）

## 计划三文件（只读）
- /mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/task_plan.md
- /mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/findings.md
- /mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/progress.md

## 检查点
/mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/subagent-state/71-p7-s1.md（install diff 摘要+pattern 前后+selftest 断言清单+验证链输出）

## 返回（8 字段严格格式）
status: / acceptance: / 产出文件: / 关键结论: / 证据: / 未完成项: / 失败与原因: / checkpoint: / 风险提示:

时间盒 ≤25min。
