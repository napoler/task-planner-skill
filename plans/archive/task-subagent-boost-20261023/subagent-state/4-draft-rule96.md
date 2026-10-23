# Seq-4 规则起草员检查点 — Rule 96 起草与可执行编辑计划

- status: done
- date: 2026-10-24
- 起草对象：Rule 96（子代理激活默认档与并行推进强化），编号 96 已由 attest 台账预留（plans/.rule-reservations.jsonl:85，持有人=task-subagent-boost-20261023；95=task-nopause-execfirst-20261023 占用禁用）
- 产出：draft-rule96.md 已写入 plans/task-subagent-boost-20261023/draft-rule96.md

## 最终结论（8 字段块）

```
status: done
acceptance: 3/3 pass — [1:PASS 2:PASS 3:PASS]
  1: 三份前置检查点(1-rule-mapper/2-anchor-mapper/3-deploy-reserve)全读并消费——Rule 96 落点按证据校正为卫星 critical-rules-dispatch.md（21.4/22/46/52 权威全文所在），非任务书字面的核心 critical-rules.md；后者只动 :193 卫星路由行枚举
  2: Rule 96 六子条(96.1-96.6)全文+6 文件编辑计划+15 断言 selftest 设计全部落盘 draft-rule96.md，每个锚为本会话亲读亲证（worktree 内 Read/sed/grep 实测）
  3: 增量立法合规——21.4「未声明者默认串行」/68.2「不新建机器门 opt-in」/59.4「超档拆细不升档」/22.3「拆细先于升档」四条既有语义零改写，96 全文以互引+强化层声明承载；SA-14/15 负断言防回删
files: /mnt/data/dev/task-planner-skill/plans/task-subagent-boost-20261023/draft-rule96.md(+1); /mnt/data/dev/task-planner-skill/plans/task-subagent-boost-20261023/subagent-state/4-draft-rule96.md(+1)
evidence: worktree 实读=dispatch.md 全文185行+核心critical-rules.md全文203行+SKILL.md全文267行+subagent_dispatch.md:1-113+task_plan.md:1-40,255-374,470-514+registry尾6行；亲验命令=sed -n '423,427p;438,442p;616,623p' check-plan-dispatch.sh(:425「模板无『并行组』列」/:439-441 frontmatter解析/:618-622 H3 hard)、sed -n '644,648p' check-dispatch.sh(:646 .dispatch-inflight)、grep '1-94' SKILL.md(恰3处:9/209/251)、grep '77 条'(恰:9/209)、grep -c . selftest-registry.tsv(93行)、wc -l SKILL.md(267≤275钉,边距8)、grep -ln '委派统计' selftest-*.sh(仅plan-tier.sh:114关键词存在断言,加行安全)、grep -nE '1-96([^0-9]|$)' SKILL.md(0,基线零噪声)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-subagent-boost-20261023/subagent-state/4-draft-rule96.md (status: done)
findings_written: none（本 ask 产出=draft 文件本体，结论已全量入本检查点）
blockers: none
confidence: HIGH
```

## 证据基座（本会话亲读，行号为 worktree wt/task-subagent-boost-20261023 实测）

1. 卫星规则全文 skills/task-dispatch/references/critical-rules-dispatch.md（185 行）：头注:4；13:10-11；14:13-14；21.3:24；21.4:25-32（「未声明者默认串行」:27；GLM5.3/Opus 级备用:30）；21.4.2:34；22.4:58；22.6:64；25.3:105；25.4:106；46:112-130；52:133-143；59:148-166；68:171-185（68.1:173 前置依赖列；68.2:175 惰性论证+opt-in 不新建机器门；68.5:181 playbook；68.6:183 hard/advisory）
2. 核心 skills/task-planner/references/critical-rules.md（203 行）：:193 task-dispatch 卫星行枚举尾 68
3. SKILL.md（267 行）：:9/:209/:251 纪元字面 1-94；:9/:209「其余 77 条」；:16 frontmatter 卫星行枚举；:195 卫星路由表行枚举；:80 步骤 2.5；:117 委派率统计；:239-244 派发与执行纪律指针段；行数钉 BP-08 ≤275（selftest-batch-pilot.sh:63-65，实值 267 边距 8）
4. templates/subagent_dispatch.md：:17 46.1 引导语；:34 并行组声明段（尾=「未声明组=串行槽」）
5. templates/task_plan.md：:6-8 frontmatter 三键（无 parallel_groups）；:318-327 S-unit 表注释（:326 68.1 前置依赖行）；:328 表头十列（无并行组列）；:483-493 委派统计区块；:495-509 Handoff 表
6. 脚本：check-plan-dispatch.sh:425（「模板无『并行组』列，真实计划以注解形态承载」）/:439-441（frontmatter parallel_groups 解析）/:618-622（H3 hard）；check-dispatch.sh:646（.dispatch-inflight 单一全局锁）；run-selftests.sh:11（「76 脚本」注释）/:79（「72 脚本」注释）；selftest-registry.tsv 93 行 TSV 四列
7. 基线零噪声：worktree 内 `grep -nE '1-96([^0-9]|$)' SKILL.md`=0、`grep -c '96\.[1-6]'` dispatch.md=0——selftest 断言无历史误命中

## 级联要点（消费检查点 2 清单）

- 必改面=SKILL.md 三处字面 1-94→1-96 + 两处 77→78 条 + :16/:195 枚举追加 96 + 核心 :193 枚举追加 96
- scripts/ 63 条可执行断言在 96 纪元全部免改（宽容正则 1-[89][0-9] 等已覆盖 1-96，检查点 2 §6）；skill_max≥84 下限免改（96≥84）
- AD-12 pin 家族免改（活锚形态不动）；run-selftests.sh 两处注释随动 76→77/72→73（新增脚本时）
- SKILL.md 增行约 +1~2 行 → 269 ≤275 免调 BP-08；超限才按「实值+25 边距」先例上调
