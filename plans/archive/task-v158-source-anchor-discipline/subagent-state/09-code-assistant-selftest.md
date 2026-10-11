# 09-code-assistant-selftest — checkpoint

## T1 里程碑：脚本落盘 ✅
- 文件：skills/task-planner/scripts/selftest-source-anchor-discipline.sh（52 行，bash，≤95）
- 断言 SA-01..SA-12 逐条实锚于 worktree 现行文件（grep 实测后写死，非凭空）
- 关键锚实测（2026-10-10）：critical-rules.md:888 起 71 条款/890-902 七子条；SKILL.md:288,372（1-71×2）、:347（Rule 71 bullet）、:225（C48）；subagent_dispatch.md:88（## 10. 防幻觉契约）、:91（写入前五问）；findings.md:6,41 + progress.md:6（Rule 71 锚合计 3）；仓根 plans/task-v153-parallel-scheduling/fix-prompts.md:9（提示词 A — 溯源审计，脚本相对路径 ../../plans/… 实存）；selftest-registry.tsv 无 source-anchor 行（SA-11 预期 FAIL）；config.json 无 source_anchor/anti_halluc/no_source 键（SA-12 PASS）

## 中途修复记录
- 首版 bug：SA-02/03/04/05/06 用「单行 grep 结果 | grep -qF a | grep -qF b」链式管道——grep -q 成功即静默吞掉管道后段输出，后段断言恒对空输入判定而 FAIL（首跑 SA-06 误报）
- 修法：统一改为 line=$(grep '^71.x ' "$RULES"); test -n "$line" && grep -qF '…' <<<"$line" 链（herestring，锚不腐）

## T5 最终结论 ✅
- bash -n 通过；wc -l = 52（≤95）
- 运行输出：SA-01..SA-10、SA-12 = 11 PASS；SA-11 = FAIL（registry 未登记，归 S10，预期内）；汇总行 `Total: 11 pass, 1 fail`；exit=1
- git status --short 仅 `?? skills/task-planner/scripts/selftest-source-anchor-discipline.sh`（本 S-unit 零其他文件改动；registry.tsv 归 S10，未碰）
- 交付 = 目标验收 5/5（SA-11 FAIL 属任务书声明的预期形态）
