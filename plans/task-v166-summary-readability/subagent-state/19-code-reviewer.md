# S19 Code Reviewer Checkpoint — task-v166 .sh 代码面审查
T1 里程碑: 2026-10-11 (审查启动+输入四文件+diff 基线确认)

## 审查基线（Step 1 证据）
- worktree=/mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability, branch=wt/task-v166-summary-readability
- git status: 11 个 .sh/.tsv modified + 1 个 untracked 新脚本 = 12 文件（与计划 S19 scope 一致）
- 清单: check-complete.sh / selftest-summary-readability.sh(新,177L) / selftest-absorption-discipline.sh / selftest-context-pressure.sh / selftest-lane-advancement.sh / selftest-requirement-coverage.sh / selftest-research-first.sh / selftest-root-resolution.sh / selftest-self-resolution.sh / selftest-source-anchor-discipline.sh / selftest-tool-selection.sh / selftest-registry.tsv(+1 行)

## 客观验证记录
- bash -n: 11 脚本全 SYNTAX-OK
- 新脚本实跑: Total PASS=13 FAIL=0 WARN=0, rc=0（含 SRV-12 级联 9/9 实跑）
- 环境事实: 交互 shell 的 grep=ugrep7.8.4 函数壳(-G)；bash 子进程内=/usr/bin/grep GNU 3.11；两者 BRE 下 `[0-9]+` 的 + 均按字面解析
- 决定性复现: /tmp/cnt_repro.md 含「### Phase 1: ① x」→ BRE `grep -c 'Phase [0-9]+: [①-⑨]'`=0, `grep -cE`=1

## Verdict: CHANGES_REQUESTED

### 🟡 F-1 selftest-summary-readability.sh:100-102 — SRV-07 三列断言未锚定表头行
- 原文: `SRV07_PATH=$(cnt '路径' "$DS")`（同式 FN/DESC 三行，:100-102）
- 原因: 全文件计数，「路径」在 DS:10「绝对路径，或仓内路径」、「文件名」在 DS:52 指引文均存在；§3 表格段整体被删断言仍 PASS。弱于同仓 check-complete.sh 检查④（awk 抽表头行判三列）与计划判据「表头含三列」→ 断言不减维度不达标
- 修复: 锚定表头行计数，如 `cntE '^\|[[:space:]]*文件名[[:space:]]*\|.*路径.*描述' "$DS"` ≥1
- 置信度: HIGH

### 🟡 F-2 selftest-summary-readability.sh:110,118,167 — 装饰圈号负断言为死守卫（BRE + 字面 +）
- 原文: `SRV08_DECO=$(cnt 'Phase [0-9]+: [①-⑨]' "$IMG")`（SRV-09 :118、SRV-13 :167 同式）
- 原因: cnt()=plain grep(BRE)；子 bash 环境（脚本实际运行态 /usr/bin/grep 3.11）实测旧式标题「Phase 1: ①」BRE 命中=0 / -E 命中=1 → 模板回退出现装饰圈号时 SRV-08/09/13 恒 0 恒 PASS，Rule 76.1 防复发守护空转。对照: check-complete.sh 检查⑦同模式用 `grep -E` 是活的（实测=1）
- 修复: 三处改 ERE（新增 cntE helper，范式=selftest-research-first.sh:cntE）或 BRE 兼容式 `Phase [0-9][0-9]*: [①-⑨]`
- 置信度: HIGH（决定性复现）

### 💬 F-3 selftest-summary-readability.sh:25 — 头注「SRV-08..SRV-13: 预留骨架（S10 追加上半）」与实现脱节（已全部实现）。修复: 头注改已实现摘要。置信度 HIGH
### 💬 F-4 check-complete.sh 检查⑦区（~:1017）— `local vf rl_ph_n rl_circ` 中 rl_circ 未使用、rl_ph_n 跨检查⑤⑦复用。修复: 删 rl_circ、⑦改独立名。置信度 HIGH
### 💬 F-5 登记（非 .sh 缺陷）— registry.tsv 实测 77 行，VC-4 预期 74（73+1）：本任务 diff 仅 +1（76+1=77），计划期基线算术过时，簿记层知晓即可

## 通过项（负结果报告）
- fail-open 语义保持: 新增检查④⑤⑥全 stderr printf + return 0（check-complete.sh:1035）✓
- 1-74→1-7[4-9] 语义等价: '1-76'∈'1-7[4-9]'；SKILL.md '1-76'×3 实测 ✓；负向锚（1-39/1-40=0、1-71 残留=0、config 零新键）全保留=断言不减 ✓
- SA-07 -cF→-cE 迁移正确（-cF 匹配正则字面恒 0，注释已载明）✓；AD-12 pin 11 处与目标文件字面同步 ✓
- 检查⑦两段式 grep（^#{1,6} 标题行限定）排除正文合法圈号误报 ✓；registry 新行 4 列、watch 17 路径全存在 ✓；chmod +x ✓
- 安全面: 全部只读 grep/awk/sed -n，无 eval/写操作/注入面；排除: 变量名错位疑云（Read 权威比对+set -u 实跑 13/13 排除工具输出伪影）

T5 最终结论:
```
status: done
acceptance: 3/3 pass — [1:PASS(checkpoint 含 verdict 行=CHANGES_REQUESTED) 2:PASS(问题清单 5 条逐条 file:line) 3:PASS(12 文件全覆盖清单见上)]
files: none
evidence: selftest-summary-readability.sh:100-102(SRV-07 未锚定); :110,118,167(BRE 死断言,复现 BRE=0/ERE=1); check-complete.sh:1035(fail-open return 0); git diff 12 文件清单; bash selftest-summary-readability.sh→13/13 rc=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/subagent-state/19-code-reviewer.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
