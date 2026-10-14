# s4 cascade-editspec（task-v172 config 键数锚级联 44→46）— 供 code-assistant 精确执行

worktree 根目录：`/home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt`
背景：task-v172 合法新增 2 个 config properties 键（smart_inject_interval、light_tier_interval_multiplier），properties 键数 44→46。17 个 selftest 的「零新 config 键」断言硬编码 44，须同步 46（先例=task-perf-opt 42→44）。逐条 Edit，old_string 必须精确匹配（先 Read 目标文件确认）。

---

## E1 文件：skills/task-planner/scripts/selftest-reliability-institution.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 12 "config.json properties 键数 44（零新增, 基线含 v145 2 键 + task-perf-opt smart_inject_type_gate+selftest_heavy_concurrent 2 键）"; else bad 12 "config.json properties 键数=$keys（应 44）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 12 "config.json properties 键数 46（基线含 v145 2 键 + task-perf-opt 2 键 + task-v172 合法新增 smart_inject_interval+light_tier_interval_multiplier 2 键 44→46）"; else bad 12 "config.json properties 键数=$keys（应 46）"; fi
```

## E2 文件：skills/task-planner/scripts/selftest-agent-coverage.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 07 "config.json properties 键数 44（零新增）"; else bad 07 "config.json properties 键数=$keys（应 44，零新键承诺被破坏）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 07 "config.json properties 键数 46（task-v172 合法新增 smart_inject_interval+light_tier_interval_multiplier 2 键 44→46）"; else bad 07 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
```

## E3 文件：skills/task-planner/scripts/selftest-requirement-grading.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 07 "config.json properties 键数 44（零新增）"; else bad 07 "config.json properties 键数=$keys（应 44，Rule 50 零新键被破坏）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 07 "config.json properties 键数 46（task-v172 合法新增 2 键 44→46）"; else bad 07 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
```

## E4 文件：skills/task-planner/scripts/selftest-decision-drift.sh
old_string:
```
  [ "$_KEYS" = "44" ] && ok "DD-20 config.json properties 键数=44（零新键）" || bad "DD-20" "got=$_KEYS expect=44"
```
new_string:
```
  [ "$_KEYS" = "46" ] && ok "DD-20 config.json properties 键数=46（task-v172 合法新增 2 键 44→46）" || bad "DD-20" "got=$_KEYS expect=46"
```

## E5 文件：skills/task-planner/scripts/selftest-four-file-dataflow.sh
old_string:
```
if [ "$NEWKEY" -eq 0 ] && [ "$PROPS" -eq 44 ]; then
    ok "FF-15 config 零新键(相关字面=0 ∧ properties=44 时点基线; task-perf-opt 合法新增 smart_inject_type_gate+selftest_parallel_mode 2 键, 42→44)"
else
    bad "FF-15 config 零新键" "got=(newkey=$NEWKEY,props=$PROPS) expect=(0,44)"
```
new_string:
```
if [ "$NEWKEY" -eq 0 ] && [ "$PROPS" -eq 46 ]; then
    ok "FF-15 config 零新键(相关字面=0 ∧ properties=46 时点基线; task-v171 40→42、task-perf-opt 42→44、task-v172 合法新增 smart_inject_interval+light_tier_interval_multiplier 2 键 44→46)"
else
    bad "FF-15 config 零新键" "got=(newkey=$NEWKEY,props=$PROPS) expect=(0,46)"
```

## E6 文件：skills/task-planner/scripts/selftest-media-dispatch.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 08 "config.json properties 键数 44（零新增）"; else bad 08 "config.json properties 键数=$keys（应 44，Rule 47 零新键被破坏）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 08 "config.json properties 键数 46（task-v172 合法新增 2 键 44→46）"; else bad 08 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
```

## E7 文件：skills/task-planner/scripts/selftest-ask-default-timeout.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 09 "config.json properties 键数 44（零新增）"; else bad 09 "config.json properties 键数=$keys（应 44）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 09 "config.json properties 键数 46（task-v172 合法新增 2 键 44→46）"; else bad 09 "config.json properties 键数=$keys（应 46）"; fi
```

## E8 文件：skills/task-planner/scripts/selftest-capability-persistence.sh（2 处）
old_string(1):
```
  if [ "$keys" = "44" ]; then ok 16 "config.json properties 键数 44（零新增）"; else bad 16 "config.json properties 键数=$keys（应 44，零新键被破坏）"; fi
```
new_string(1):
```
  if [ "$keys" = "46" ]; then ok 16 "config.json properties 键数 46（task-v172 合法新增 2 键 44→46）"; else bad 16 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
```
old_string(2):
```
  if [ "$keys" = "44" ]; then ok 16 "config.json properties 键数 44（python3 校验）"; else bad 16 "config.json properties 键数=$keys（应 44）"; fi
```
new_string(2):
```
  if [ "$keys" = "46" ]; then ok 16 "config.json properties 键数 46（python3 校验; task-v172 合法新增 2 键）"; else bad 16 "config.json properties 键数=$keys（应 46）"; fi
```

## E9 文件：skills/task-planner/scripts/selftest-context-pressure.sh
old_string:
```
if [ "$props" -eq 44 ]; then
  ok "CP-09" "config properties=$props=44"
else
  bad "CP-09" "config properties=$props≠44"
```
new_string:
```
if [ "$props" -eq 46 ]; then
  ok "CP-09" "config properties=$props=46"
else
  bad "CP-09" "config properties=$props≠46"
```

## E10 文件：skills/task-planner/scripts/selftest-self-resolution.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 09 "config.json properties 键数 44（v145 已合法加 2 键）"; else bad 09 "config.json properties 键数=$keys（应 44）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 09 "config.json properties 键数 46（v145 2 键 + task-v172 合法新增 2 键）"; else bad 09 "config.json properties 键数=$keys（应 46）"; fi
```

## E11 文件：skills/task-planner/scripts/selftest-media-agents.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 10 "config.json properties 键数 44（零新增）"; else bad 10 "config.json properties 键数=$keys（应 44，零新键承诺被破坏）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 10 "config.json properties 键数 46（task-v172 合法新增 2 键 44→46）"; else bad 10 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
```

## E12 文件：skills/task-planner/scripts/selftest-requirement-coverage.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 13 "config.json properties 键数 44（零新增，基线含 v145 2 键）"; else bad 13 "config.json properties 键数=$keys（应 44，Rule 51 零新键被破坏）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 13 "config.json properties 键数 46（基线含 v145 2 键 + task-v172 合法新增 2 键）"; else bad 13 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
```

## E13 文件：skills/task-planner/scripts/selftest-session-log.sh
old_string:
```
    t "SL-09 config.json properties 键数 = 44（零新 config 键, jq; task-perf-opt 合法新增 2 键 42→44）" bash -c "
        [ \"\$(jq '.properties|keys|length' '$CONFIG')\" -eq 44 ]"
```
new_string:
```
    t "SL-09 config.json properties 键数 = 46（零新 config 键, jq; task-perf-opt 42→44, task-v172 合法新增 2 键 44→46）" bash -c "
        [ \"\$(jq '.properties|keys|length' '$CONFIG')\" -eq 46 ]"
```

## E14 文件：skills/task-planner/scripts/selftest-iteration-persistence.sh（2 处）
old_string(1):
```
  if [ "$keys" = "44" ]; then ok 15 "config.json properties 键数 44（Rule 57 零新增，v145 基线演进）"; else bad 15 "config.json properties 键数=$keys（应 44，零新键基线被破坏）"; fi
```
new_string(1):
```
  if [ "$keys" = "46" ]; then ok 15 "config.json properties 键数 46（v145 基线演进 + task-v172 合法新增 2 键）"; else bad 15 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
```
old_string(2):
```
  if [ "$keys" = "44" ]; then ok 15 "config.json properties 键数 44（python3 校验）"; else bad 15 "config.json properties 键数=$keys（应 44）"; fi
```
new_string(2):
```
  if [ "$keys" = "46" ]; then ok 15 "config.json properties 键数 46（python3 校验; task-v172 合法新增 2 键）"; else bad 15 "config.json properties 键数=$keys（应 46）"; fi
```

## E15 文件：skills/task-planner/scripts/selftest-workflow-orchestration.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 12 "config.json properties 键数 44（基线演进 40→42，零新增于本体系）"; else bad 12 "config.json properties 键数=$keys（应 44）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 12 "config.json properties 键数 46（基线演进 40→42→46, task-v172 合法新增 2 键）"; else bad 12 "config.json properties 键数=$keys（应 46）"; fi
```

## E16 文件：skills/task-planner/scripts/selftest-lane-advancement.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 14 "config.json properties 键数 44（零新增，基线含 v145 2 键 + task-perf-opt 2 键）"; else bad 14 "config.json properties 键数=$keys（应 44，Rule 49 零新键被破坏）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 14 "config.json properties 键数 46（基线含 v145 2 键 + task-perf-opt 2 键 + task-v172 合法新增 2 键）"; else bad 14 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
```

## E17 文件：skills/task-planner/scripts/selftest-tool-selection.sh
old_string:
```
  if [ "$keys" = "44" ]; then ok 12 "config.json properties 键数 44（v145 已合法加 2 键）"; else bad 12 "config.json properties 键数=$keys（应 44）"; fi
```
new_string:
```
  if [ "$keys" = "46" ]; then ok 12 "config.json properties 键数 46（v145 2 键 + task-v172 合法新增 2 键）"; else bad 12 "config.json properties 键数=$keys（应 46）"; fi
```

---

## 完成后自检（命令原文+结果写入检查点）
1. `cd /home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt && bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -3`（期望 Total: 77 PASS=77 FAIL=0）
2. 若仍有 FAIL，逐个跑失败脚本定位，**禁止改断言以外的东西**，把新失败写入检查点「错误与受阻」段
