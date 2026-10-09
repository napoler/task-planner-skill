# Delivery Summary — task-v157-error-fix-prompt-forge

> 模板：templates/delivery-summary.md（五要素）/mnt/data/dev/task-planner-skill/skills/task-planner/templates/delivery-summary.md；数据引 verification.md/progress.md/subagent-state 指针不重写。

## 1. 任务说明

用户指令（原话）：「创建一个skill」+「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」。

交付物=仓库新建顶层执行型 skill `error-fix-prompt-forge`（排查结果→修正提示词锻造器）：把已完成根因定位的错误排查调研结果，经「输入校验→结构化抽取→缺口分析→模板渲染→自包含自检」五步闭环，转化为可直接派发子代理执行修正的自包含任务书（fix prompt），含 QC-FP 六条自检与 READY/PARTIAL/BLOCKED 三态结论。与既有能力划界：根因定位归 debugger/systematic-debugging，本 skill 只消费已定位结论并锻造任务书（不重排查、不实施修复）。

## 2. 产出清单

| 产出 | 绝对路径 | 验证 |
|------|---------|------|
| SKILL.md（84 行，六区块） | /mnt/data/dev/task-planner-skill/skills/error-fix-prompt-forge/SKILL.md | `bash ~/.zcode/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh` → 8/8 exit 0 |
| fix-prompt 渲染模板（49 行，九槽位+DoD） | /mnt/data/dev/task-planner-skill/skills/error-fix-prompt-forge/templates/fix-prompt-template.md | 槽位 grep 逐词 8/8 命中 |
| selftest 静态守护（FP-01..08） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh | CR 加固版；主进程复跑 8/8 |
| registry 登记行 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv（末行区，与 v155 行解并集） | `bash skills/task-planner/scripts/selftest-registry.sh` → 5/5 |
| 行为冒烟产物（Rule 43.5 生成测试） | /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/fix-prompt-sample.md + qc-fp-selfcheck.md | QC-FP 6/6 PASS，结论 READY |
| 冒烟 fixture（真实排查调研产物） | /mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/fix-prompts.md | v153 幻觉补位事故 fix-prompts A/B/C |
| 计划六文件+11 个 subagent-state 检查点 | /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/ | verification.md Goal Gate outcome=COMPLETE |

部署位（三宿主，diff IDENTICAL）：~/.zcode/skills/error-fix-prompt-forge、~/.claude/skills/error-fix-prompt-forge、~/.cursor/skills/error-fix-prompt-forge；task-planner 本体三位（~/.zcode、~/.claude、~/.config/opencode/skills/task-planner）均 IDENTICAL。合并回 commit：`6d46d3ec`（master）。

## 3. 审查详细

- **Code Review Gate（code_review: required）**：code-reviewer(sonnet-1) 单轮轻量审查（唯一代码文件=selftest 脚本）→ **APPROVED**，问题清单 P1×3/P2×2/Nit×1（断言强度加固建议）→ CR 修复轮全修（FP-01 name=目录名做实/FP-04 锚定表行/FP-05 逐词 8/8/FP-06 精确措辞+FAIL 诊断）。证据：subagent-state/07-code-reviewer.md + 08-code-assistant.md。
- **alignment-review（Rule 42.6）**：APPROVED（P0/P1=0，P2=1 不阻断）；证据落 findings.md [sub:aln-01]（登记联动/计数级联/引用完整性/术语/多副本/变更日志七维机器证据）。
- **回归**：Round 1-6 全程落盘 progress.md（Rule 57 四要素）；终态 MASTER-FINAL 68 脚本/836 断言/FAIL=0（主进程独立复算，非子代理自报）。
- **委派统计**：check-delegation stats verdict=ok（ Executor 档位后缀致 violation 一次→Rule 51.7 登记+裸名规范化+重签 attest(b3d78832)→复跑 ok；rate 0.4，直做理由全命中白名单②①③，WHITELIST-EXEMPT）。
- **drift 检查**：4 次 ALIGNED（drift-checker provider 3 连拒→Rule 22.3 永久切 61.5 check-drift.sh 降级佐证，三件套留痕齐全）。

## 4. 风险点（必须列举）

1. **宿主生效需新会话**：skill frontmatter 为快照语义，~/.zcode/~/.claude/~/.cursor 已安装但当前会话不重载（install-companion NOTE 明示）——重启会话后生效。
2. **冒烟自检表一处计数偏差**：sub:04 自检 QC-FP-1 自报绝对路径 7 行，主进程复算 8 行（行号列举正确、判据不受影响）——已如实登记 progress.md，未伪造修正。
3. **cursor 位原本滞后**：部署时 cursor 缺 39 个既有 skill 文件，install-companion canonical 全量补齐（有备份 ~/.task-planner-backups/companion/20261010-061550/）——补齐动作超出本任务新增范围但属工具既有 SOP 幂等同步。
4. **v150 教训本轮复发一次**：Executor/Handoff 档位后缀致委派统计 violation——已修+复跑 ok，建议后续任务计划期直接裸名（见下）。
5. **行为面收敛依赖排查结果包质量**：skill 的输入契约靠用户/上游提供合格的排查产物；首实战后经验回灌路径=iterative-optimizer（未闭环，不阻断）。

## 5. 下一步建议

1. **生效验证（新会话）**：重启 ZCode 会话后跑 `Skill(skill="error-fix-prompt-forge")` 或用一次真实排查结果实跑，验证触发与五步流程端到端可用（对象：~/.zcode/skills/error-fix-prompt-forge/SKILL.md）。
2. **模板沉淀评估（Rule 34.3②）**：variant 目录缺 skill-creation 类型模板；若年内出现第 2 次同类任务（新建顶层 skill），按 34.4 提炼 `skill-creation-type.md` 入库（本次已登记 template-sense）。
3. **教训固化**：把「Executor=裸注册名、selftest 落位 task-planner/scripts、registry 行用含口径断言」三条写入计划期 checklist（本轮 3 个 P1/级联/统计问题的共同根因都是既有教训未前置消费）。
4. **遗留清理（非本任务范围，仅呈报）**：plans/INDEX.md 仍有 v152/v154/v155/v156 等 in_progress 任务与 3 个未清理 wt/ worktree（v152/v154/v155）属并行会话资产；另 task-v150 计划文件存在 attest 后修改未重签的流程违规（详见会话终报）。
