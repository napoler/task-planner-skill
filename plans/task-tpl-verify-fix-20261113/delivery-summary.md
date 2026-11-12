# 交付总结 — task-tpl-verify-fix-20261113（outcome: COMPLETE）

## 1. 做了什么（对 R1-R3）
- **R1 模板问题（含验证区块缺失实锤）**：六处模板-门漂移全修——①task_plan 模板 S-unit 表 11→10 列（类别=目标列内（An）前缀）②**verification 模板补验证区块**（每 VC 条目三行结构，含行首 `**Verify command**:` 纯命令行+禁占位/禁真空引导——attest vc-gate 判据面）③Goal 单元表列名补空格（对应 S-unit/Phase）④Phase 4 示例补 S-unit 表⑤Batch Report 实值引导（n/a 形态）⑥SG-12/13 断言翻转（第六漂移：门断言落后于示例表正当演进，冒烟抓到）。
- **R2 模板 skill 同步纠正**：plan-template-kit 落双契约条款（template-mapping.md:232-238 验证区块契约+10 列序契约；template-guide.md:167 指针）——模板与门漂移从此有契约防线。
- **R3 顺序铁律执行**：先模板（Phase 2）→再他处（Phase 3）：真传播面×2 清零（selftest SA-19 守卫翻转+task-dispatch Rule 104 三锚措辞）；SKILL.md 注释块=无锚诚实关闭（CA-7）。
- **冒烟实证**：tmp 计划按新模板真跑 init 渲染+门校验 **EXIT:0 零拒锁**（3 派发 Phase 全有表）——「新计划一次过门」得证；smoke 用完即删。

## 2. 如何验证（全 PASS）
- 六 VC 全勾：VC-2 模板 grep/VC-3 kit 契约/VC-4 残留=0（负向守卫字面白名单）/VC-5 冒烟+基线 97/95=2 预存/VC-6 七文件×三位 ALL-SYNCED+三仓 push。
- S7 独立复检 **APPROVED**（五维零 CHANGES，checkpoint 08）；CR-GATE 实测未触发（diff 94 行<阈值）。
- 委派 stats verdict=ok；三源一致 PASS；check-complete 终跑 exit 0。

## 3. 未完成项与遗留
1. **执行面新规待条款化（建议另行任务）**：本任务 progress 收口暴露「结构文件插段吞锚」惯犯第 4-7 犯（Error Log 已析因）——建议 Rule 106.1 演进补「结构文件插段后强制回读段清单」条款。
2. 项目级覆盖 .zcode/plan-templates/ 仅 knowledge-brief.md，与本次模板修正无冲突（CA-8 diff 判向登记）。
3. 上任务遗留继承：master 2 预存 selftest FAIL / NIT×2——均与本任务无关，已在上任务登记。

## 4. 生效与指针
- 合并 5a0e410（stash 窗口原样恢复他任务变更）；三仓：源 4d269d1..5a0e410 / zcode 9c4c35c..a2bf941 / claude 228d17b..056e5e0；cursor 落盘 7 文件。
- 复验命令：`grep -c 'Verify command' skills/task-planner/templates/verification.md`（≥7）+ `bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -1`（97/95/2）。

## 5. 知识沉淀
- knowledge/entries/tplfix-template-gate-alignment.md（六漂移+冒烟法+断言随契约演进原则）；memory：task-tpl-verify-fix-20261113。
