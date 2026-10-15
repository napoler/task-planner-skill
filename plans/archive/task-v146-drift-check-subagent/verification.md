# Verification Contract & Phase Gates — task-v146-drift-check-subagent

## Goal (1 sentence)
偏移检查载体从主上下文 `Skill("task-drift-guard")` 切换为 `drift-checker` 伴随 agent 子代理派发（新 Rule 61），全链（规则/SKILL/模板/联动文档/hook/守卫）一致落地、合并 master 并同步部署位。

---

## Verification Contract（终验勾稽）

- [x] VC-1: Rule 61 条款完整（61.1-61.6）+ 15.4 载体条款 + 索引括注演进
  Evidence: `grep -c '^### 61 '`=1；`**61.1`..`**61.6` 六锚各 1；`**15.4`=1；`Skill("task-drift-guard")` critical-rules.md=0（S1 checkpoint + 主进程复验）；合并后括注=`Critical Rules 1-62（含 Rule 40-62 全集…/ Rule 61 偏移检查子代理化）`（SKILL.md:275，与 v144/v145 并存合流）
- [x] VC-2: drift-checker agent 定义 + 覆盖矩阵登记 + AC 守护
  Evidence: `companion/agents/drift-checker.md`（name/model=haiku-1/tools=[Read, Write, Bash, Grep, Glob]，见文件）；agent-coverage.md 行 27 + 矩阵 129 行；合并部署后 `selftest-agent-coverage.sh` Total: 9 PASS=9 FAIL=0（AC-04 转 PASS=部署后实证，2026-10-08）
- [x] VC-3: SKILL.md 执行链路旧载体串 0 命中 + 六处+增补点全切换 + hook 文案
  Evidence: `grep -rn 'Skill("task-drift-guard")' skills/` 仅 selftest-drift-check-subagent.sh 自身负断言命中（实体面=0）；SKILL.md 488→合并后 ~490 行 ≤558；hook `:220` 新串「偏离即派发 drift-checker 子代理偏移检查(Rule 61 载体)」（S3/S4 checkpoint + 复验）
- [x] VC-4: selftest 守护 ≥15 断言 + registry 登记 + 全量回归口径
  Evidence: `selftest-drift-check-subagent.sh` Total: 20 PASS=20 FAIL=0（DCS-01..20 与 KB §5.7 一一对应）；registry.tsv 行在位且 rows=60=scripts（T02/SR-12 转 PASS）；回归三轮账：①分支回归 876/28（6 条 40-61 级联）→②S7-S9 六锚宽容化（master 侧统一为 40-[56][0-9]）→③终态回归见 progress.md Selftest Log（合并 v144/v145 后 config=42 合法化+periodic 补登记，FAIL 大幅收敛）
- [x] VC-5: 合并回 master + 部署位一致 + land 61 + CR/align 双审
  Evidence: master merge commit e54973d（`Merge branch 'wt/task-v146'`）；smart-merge-back ALREADY_MERGED 确认；部署=zcode 位原子换位（备份 ~/skill-deploy-backups-task-v146/task-planner-20261008095516）+ claude/opencode IDENTICAL + 卫星（task-drift-guard/plan-cost-guard）同步 + `~/.zcode/agents/drift-checker.md` 与 `~/.claude/agents/drift-checker.md` 双位 installed；`rule-reserve.sh land 61`=landed；CR=APPROVED（checkpoint 13，2 minor 已修复）；alignment-review 初判 CHANGES_REQUESTED（1P1+3P2）→ 3 项修复（checkpoint 16）+1 项按审查建议登记 deferred（SKILL.md 多处上界 58/55 措辞——v145 已在 :345 统一 56-62 枚举，残余为 frontmatter 描述行，deferred）

---

## 终验规则裁决
全部 VC 通过（VC-4 终态回归行见 progress.md Round 4），CR APPROVED + alignment 修复闭环 → **COMPLETE**

## 委派统计（Rule 25.4）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 2/3/4 全委派：executor×9 + code-runner×3） |
| 主进程直做 Phase 清单 | Phase 1（白名单① git/worktree 编排 + ③ 机械只读命令）、Phase 5（白名单① git 编排/合并部署 + ② 计划系统文件簿记） |
| 委派率 | 0.6（<0.7 floor，但两 Phase 直做理由全命中 Rule 25.3 白名单 → **WHITELIST-EXEMPT 放行**） |

## 静默决策清单（Rule 28，silent 模式呈报复核）
1. interaction_mode: silent（先例 v142/v144；用户指令明确）
2. Rule 61 编号（避开并行预留 59/60；attest 自动登记）
3. 专用 drift-checker 伴随 agent（Rule 52.1 专用体优先；先例 task-v124）
4. task-drift-guard 卫星保留双载体（36.5 零删除）
5. SOP 嵌入 agent 定义（消除路径耦合）
6. 零新 config 键（53.5/54.6 惯例）
7. 触发频率语义不变，仅载体切换 + 61.4 防自触发清零
8. 检查点沿用 22.8 命名
9. 载体切换全仓联动扩展（S4b/S4c，变更联动审计 P0 + Rule 53 根源解决；同义传播非新语义）
10. CR 用 code-reviewer agent 替代 Skill("code-review")（该 skill 环境不可用，路由表等效项）
11. 守卫锚级联修复取 master 侧 40-[56][0-9] 方案（v144/v145 已演进的更优宽容式，超集覆盖我方 40-61）
12. alignment P2「SKILL frontmatter 上界 58 措辞」登记 deferred（v145 已统一 References 行；frontmatter 描述行涉其他任务联动，Rule 59/62 land 后复查）
