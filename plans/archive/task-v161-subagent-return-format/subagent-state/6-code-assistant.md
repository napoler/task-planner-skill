# 检查点: 6-code-assistant (task-v161 S6 check-dispatch.sh 返回格式段结构校验)

status: done

## 已完成里程碑
- 2026-10-10 11:35 M1 材料包 Read 全文 + 目标文件 Read + 模板 §7/findings 污染样本对齐（判据 A/B/C 口径定案）
- 2026-10-10 11:40 M2 return_section_check() 实现（check-dispatch.sh:195）+ 文件头 2026-10-10 说明段（:84）；挂入 pretool 两条成功路径（:306 warn 兜底 / :321 enforce 主路径，均 fine_grain_checks 后、serial_slot_check 前）+ cmd_check 尾部（:358-361，子 shell 承接违规 exit 2→check exit 1）
- 2026-10-10 11:55 M3 双夹具（/tmp/v161-s6-test 内构造，含三文件路径+subagent-state 路径+需求锚声明）四条命令自跑全过 + selftest 31/31 PASS
- 2026-10-10 12:02 M4 numstat 压到 +31/-0（≤35/0 达标）

## 关键取舍（What+Why）
- 标题正则双形态 `^## ([0-9][.] )?返回格式`：兼容模板「## 7. 返回格式」与判例「## 返回格式」两种行首形态；判例拼接态「## 返回格式## 返回格式」单行内双写按 1 行计（grep -cE 行数口径），标题判据 A 仅在 ≥2 行时命中，段内清单判据 C 承接单行双写污染——两判据分工，误报面最小
- 段界取「至下一个 '^## ' 标题行(含)或文件尾」：含边界行的取舍=模板 §7 段尾紧邻 §8 标题时四 key 仍在 8 字段模板块内（§8 标题行本身不含 key，零影响）；干净夹具模板 §7 原文（62-83 行）验证通过
- 无「## 返回格式」段 fail-open 静默放行：与既有 ⑤⑥ 口径一致，成功路径零输出语义不变（selftest T01/FG-01 零细粒度输出断言依赖此）
- check 模式以 `( return_section_check "$pf" "enforce" )` 子 shell 承接：函数内 exit 2 不终止主脚本，rc=2 判违规→check exit 1；违规 stderr 行经子 shell 原样透传

## 产出文件清单
- M /home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/check-dispatch.sh (+31/-0；新增 return_section_check 函数 :195-221、文件头说明 :84-86、三处挂点 :306/:321/:358-361)

## 错误与受阻
- 首版实现 sed 段提取表达式语法错（`extra characters after command`）→ 改写为 awk NR 窗口段提取，一次修通
- 首版挂点续行破坏两条成功路径既有长行（git diff 出现 -2 行）→ 调整为独立行插入 + 原行零改动，最终 numstat +31/-0
- 复验时 clean_enforce 一度 rc=2：排查为串行槽锁残留（前次 enforce 调用写锁未清，120s TTL 内误拦）→ rm 锁后复验 rc=0；120s TTL 自愈语义与设计一致，非代码缺陷

## 最终结论
```
status: done
acceptance: 6/6 pass — [1:PASS 污染夹具 enforce rc=2+stderr「[dispatch-guard] ✗ 返回格式段结构违规: C: 段内序号清单行 3 行且缺 key( confidence:)」 2:PASS 判据A夹具 rc=2+「A: 标题重复(共 2 处, 拼接污染形态)」 3:PASS 干净夹具(模板§7原文+三文件+subagent-state) enforce/warn rc=0 4:PASS check 模式 污染 rc=1/干净 rc=0 5:PASS bash -n SYNTAX_OK 6:PASS selftest-dispatch.sh Total: 31 PASS=31 FAIL=0]
files: /home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/check-dispatch.sh(+31/-0)
evidence: check-dispatch.sh:195 return_section_check 函数体; :306/:321 两条成功路径挂点; :358-361 cmd_check 尾部子 shell 承接; git diff --numstat → 31 0 check-dispatch.sh（≤+35/-0 达标）; 污染夹具 pretool enforce→rc=2 stderr「✗ 返回格式段结构违规: C: 段内序号清单行 3 行且缺 key( confidence:)」; 干净夹具 pretool enforce→rc=0; bash -n→SYNTAX_OK; selftest→Total: 31 PASS=31 FAIL=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format/subagent-state/6-code-assistant.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
