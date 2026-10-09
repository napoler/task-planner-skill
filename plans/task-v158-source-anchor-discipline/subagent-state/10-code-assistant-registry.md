# checkpoint 10-code-assistant-registry | T1

- 时间: 2026-10-10
- T1 完成: registry.tsv 追加新行（67→68 行）
  - 行: selftest-source-anchor-discipline.sh \t Rule 71 …（task-v158 守护载体）\t 触发场景（52 行形态/三态/SA-11 转正）\t 依赖锚（critical-rules.md;selftest 脚本;registry 自登记）
  - 证据: grep -c 'selftest-source-anchor-discipline.sh' = 1（锚: wc -l 67 → 追加后 tail 命中）
  - 既有行零改动: 追加用 >>，未触碰 1-67 行（锚: 本会话仅一次追加操作）
- 待办: T2 reserve 71 → T3 复验 → T4 git diff 验收

## T5 最终结论 (2026-10-10)

- T2: `rule-reserve.sh reserve 71` → EXIT=0，输出 "rule 71 reserved by task-v158-source-anchor-discipline"（锚: stderr/stdout 原文）；台账 .rule-reservations.jsonl 追加 71 行（git diff 确认 +1，零既有行改动）
- T3: selftest 复跑 = SA-01~12 全 PASS，"Total: 12 pass, 0 fail"，SELFTEST_EXIT=0（SA-11 转正 = registry 登记行命中）；`check 71` 输出 "rule 71 held by task-v158-source-anchor-discipline (reserved)"（CHECK_EXIT=3 为 check 的"有主"正常返回码，非 reserve 冲突码）
- T4: git diff 验收 = 已跟踪文件仅 2 处 +1 行（registry.tsv / .rule-reservations.jsonl）；自 test 脚本与 09/10 检查点为 untracked（此前 S-unit 产物 + 本次检查点，非既有行改动）
- 验收 4/4 全过；禁区（registry.tsv 既有行、其他文件）零触碰

- 补充事实锚: check 的 exit 3 = 「被持有」正常码（脚本头部注释 L10/L39: "被持有 → 持有人行 + exit 3"），reserve 的 exit 3 才是冲突码——本次 reserve EXIT=0 无冲突
