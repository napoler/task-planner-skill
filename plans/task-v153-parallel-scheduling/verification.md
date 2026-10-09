# Verification Contract & Phase Gates

## Goal (1 sentence)

task-planner 技能新增 Rule 68（计划期强制依赖分析→并行分组推导→组内异构 agent/模型分摊→组域写一致性），计划初期即可分组并行、依赖者串行、并行更新不错乱，纠正 workflow 单模型缺陷，机制经模板列/守卫两档/selftest 固化长期生效。

---

## Verification Contract（终验 8 条=VC-a~VC-h，全部通过=COMPLETE）

- [x] VC-a: critical-rules.md 含 Rule 68 完整条款（68.1-68.7）
  Evidence: 合并后 master `grep -cE '^68\.[1-7] '` =7（含「依赖分析/并行分组/异构分摊/组域写隔离」四关键词，master 66.2 v151 增强新文同步在位）；file=/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:862 起
- [x] VC-b: templates/task_plan.md S-unit 表含「前置依赖」列
  Evidence: 模板表头 :279 + 注释 :277；file=skills/task-planner/templates/task_plan.md
- [x] VC-c: check-plan-dispatch.sh 扩展校验（依赖-同组矛盾 reject+组内全同 WARN）
  Evidence: fixA 跑 H4 矛盾夹具 `exit 1` 原文 + W1 WARN rc=0 原文 + 真实计划零误报 + F8 双夹具（裸管道 reject/转义放行）+ CR 二轮复验 eight findings fixed
- [x] VC-d: selftest-parallel-scheduling.sh 存在、registry 登记、断言通过
  Evidence: `Total: 9 PASS=9 FAIL=0`（P-09 硬 PASS）；`selftest-registry.sh Total: 5 PASS=5 FAIL=0 (registry rows=65, actual selftest=65)`
- [x] VC-e: 全量 selftest FAIL=0（相对基线零新增失败）
  Evidence: 基线 baseline-selftest.log 64 脚本全 rc=0 ΣFAIL=0 → Round4/合并态 R5 回归 65 脚本全 rc=0 ΣFAIL=0（零新增；新增 1=本任务 selftest）
- [x] VC-f: SKILL.md 计数级联正确，含 Rule 68 索引行与合规清单行
  Evidence: `Critical Rules 1-68` ×3 + 枚举补 66 + Rule 68 摘要 bullet + C46 行 + 计划期强制步骤行（CR F5/F6/F7 修复后）
- [x] VC-g: 本计划自身含 parallel_groups 声明+组内异构执行体分配+组域写隔离协议行（吃狗粮）
  Evidence: task_plan frontmatter `parallel_groups: [p3-core, p3-guard, p3-docs]`；三组内 haiku-1/sonnet-1（三 provider：longcat/agnes×2）混派；68.4 组域协议行在 S-unit 表注；并行实证 p3-core 三成员 6min vs 串行预估 ~40min
- [x] VC-h: 三部署位 IDENTICAL（合并后对账）
  Evidence: git merge b20974f 零冲突自动归并；repo/`~/.zcode`/`~/.claude` 关键文件 diff -q 全 OK

---

## Phase Gates

### Phase 1: 设计定稿 — complete（design-rule68.md 68.1-68.7 全文+六校验点+级联表+T1-T9+P12）
### Phase 2: worktree+基线 — complete（ebb5fba 三面 IDENTICAL；64 脚本 ΣFAIL=0）
### Phase 3: 实施 — complete（三批+G-07+S7+commit 5c5b3f6 十文件 +417/-12）
### Phase 4: 验证 — complete（V1 R1-R4+CR R1-R2 APPROVED+fixC+对齐六维+commit 74177a6 十五文件 +153/-73）
### Phase 5: 合并部署薄记 — in_progress（merge b20974f+三部署位 IDENTICAL+land 68；终验收尾在途）

---

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| Rule 21.4 声明制/23.9-23.13/43.2/52 | 68.2/68.3 条款引用+守卫四问口径+P12 模式伴飞 | 符合（21.4 默认串行语义不回退，P-08 负断言守护） |
| dynamic-workflows 三文档 | 68.5 三要点引证（先收窄/唯一 join/落盘）+findings §A A4 缺陷实证 | 符合（不搬运行时，68.x 未引入 subagent_model） |
| check-plan-dispatch 现状 | F1/F2/F8 修复对齐其 66.5 awk 范式+add_violation 管线 | 符合（fixA 前后对照实证） |
| v151/v152 在途事实 | 编号避让 68、计数递推不硬编码、67 预留不列名 | 符合 |

## 委派统计复验（Rule 25.4）

主进程直做 Phase 白名单映射：P1=②计划系统文件（design 落 plans/）；P2=①git/worktree 编排+③机械验证；P3=①编排面（派发/验收/merge 编排）+②三文件簿记；P5=①合并/部署编排+②簿记。S-unit 执行层 100% 委派：7/7 实施单元+6/6 修复轮单元（Handoff #2-#17）。委派率按 Phase Executor 字段=1/5<0.7 floor → 命中 WHITELIST-EXEMPT（全部直做理由∈25.3 六项白名单），check-complete 统计以机器为准。

## 质量门控统计（Rule 26）

- Q1-Q6：Q1 提示词/参数类修改（68 条款=规则文本）→ 触发验证型：selftest+CR+回归三轮，无未处置；Q3 伪造证据零容忍：所有通过项均附实测原文行（bash/grep/diff 输出贴回），无一来源虚构；Q4 串联模板拼凑无；Q5 占位符无；Q6 用户否决禁令无命中（C20 已过 notepad/memory 禁令源）
- Evidence 抽查 3 条：VC-a（grep=7 实测）、VC-d（P-09 硬 PASS+registry 65/65）、VC-g（frontmatter+三组执行体列+并行墙钟 6min 对照）
- 发现治理：自曝 1 起幻觉注入（findings 初版食物照片段）当次删除+Error Log；plan-writer/drift-checker/alignment 载体 provider 故障/取消 5 起按 22.3.1 改派或路由变更，全部登记无静默

## Goal Gate（终验）

```
## Goal Verification — Rule 68 全链落地（R1-R7 → VC-a~VC-h 全覆盖）
VC-a PASS（grep=7+66.2 在位） / VC-b PASS（:277+:279） / VC-c PASS（H4 rc=1+W1 WARN+F8 双夹具） / VC-d PASS（9/9+65/65） / VC-e PASS（R5 合并态 65/65 ΣFAIL=0） / VC-f PASS（1-68×3+C46+bullet+步骤行） / VC-g PASS（三组混派+6min 并行实证） / VC-h PASS（b20974f+三部署位 diff OK）
 outcome: COMPLETE（待 check-complete 终态确认）
```

> 验证独立性：V1 回归=code-runner-agent 独立执行体；CR=code-reviewer 两轮独立执行体；主进程仅执行对齐机械核验（载体取消降级已登记）+编排/簿记。三份子代理检查点可独立复核。
