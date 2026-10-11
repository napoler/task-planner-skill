# P3-S4 任务书: RL-11+三处计数级联（task-v102,扩围后完整版）

任务: worktree 内 selftest 层收尾——① selftest-review-library.sh 追加 RL-11+头注释计数级联 ② selftest-reliability-institution.sh R-01 锚级联 ③ selftest-skill-split.sh T-主 行钉级联。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v102-alignment-upgrade/（只读;范围表已登记三脚本扩围）
- progress.md: 同目录（子代理禁写）

## 目标文件（worktree skills/task-planner/scripts/ 下）
1. selftest-review-library.sh（RL-11 追加+头注释 RL 计数 10→11 条级联+RL-10 全池计数措辞核对）
2. selftest-reliability-institution.sh（R-01 锚级联）
3. selftest-skill-split.sh（T-主 行钉级联）

## 操作内容
### ① selftest-review-library.sh
- 头注释区（RL-01..RL-10 描述清单）末尾追加 RL-11 描述行: `#   RL-11     alignment-review 验证优先升级锚：「写入前校验」≥2、「未经一致性校验，不直接追加新内容」=1、「变更记录输出」≥1（task-v102）`
- 断言区（RL-10 之后）追加 RL-11 断言（照 RL-05 循环外单文件断言写法,目标文件=alignment-review/SKILL.md）: 三个锚各 grep ≥1/=1/≥1,全过 ok 11 否则 bad 11
- 头注释「SR/RL 范式」行若有「RL-01..RL-10」计数措辞 → 「RL-01..RL-11」;若 Total 行格式行有断言计数描述同步
- **RL-01..RL-10 既有断言零改动**（RL-01 已=11/DIRS 已含 alignment,由 S2 完成）
- Total 行输出格式不变（`Total: N PASS=x FAIL=y`,N 自然变 11）
### ② selftest-reliability-institution.sh
- R-01 断言: `grep -c '^42\.'` 期望 5 → 10（42.1-42.5 五子条+42.6 主体+42.6.1-.4 五行——S2 追加后实际 10 行,先实测确认再改）,行内注释注明「[2026-10-01 task-v102 B 类扩围: 42.6 追加级联,5→10]」;若断言写法是 `-eq 5` 改 `-eq 10`,错误消息文本同步
### ③ selftest-skill-split.sh
- T-主 断言: `-le 439` → `-le 440`（实测 SKILL.md 当前 440 行,以 wc 实测为准禁手估）,label「（task-v099 Rule 42/43 联动 435→439）」→「（task-v102 C32 联动 439→440）」;`-le 558` 不动

## acceptance: 验收标准
1) `bash scripts/selftest-review-library.sh` → `Total: 11 PASS=11 FAIL=0`（RL-01..11 全过）
2) `bash scripts/selftest-reliability-institution.sh` → 12/0（R-01 级联后仍 PASS）
3) `bash scripts/selftest-skill-split.sh` → 41/0（行钉 440）
4) 三脚本 `bash -n` 全过
5) `grep -c 'RL-11' scripts/selftest-review-library.sh` ≥2（注释+断言）
6) `git -C <wt> status --short` scripts/ 下恰 3 个 M（alignment-review/SKILL.md 与 CRIT 为前序存量）

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v102-alignment-upgrade/subagent-state/04-exec-p3s4.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P3-S4
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 三个 Total 行+bash -n 输出
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
