# 04-executor-epoch101 checkpoint（D 组：纪元 1-101 四位顶字面炸点级联）

## 脚本修复明细（脚本/断言ID/旧模式→新模式/rc）

- absorption-discipline | AD-04 | 1-[7-9][0-9] → 1-(7[0-9]|[89][0-9]|10[0-9]) | rc=0
- capability-persistence | CP-05 | 1-[89][0-9] → 1-(8[0-9]|9[0-9]|10[0-9]) (消息文本 1-80→1-101) | rc=0
- conclusion-discipline | CD-12 | 1-(3[5-9]|9[0-9]) → 1-(3[5-9]|9[0-9]|10[0-9]) (消息文本同步 1-35..101) | rc=0
- context-pressure | CP-07 | 1-[89][0-9] (c1/c2 面) → 1-(8[0-9]|9[0-9]|10[0-9]) (消息文本同步) | rc=0
- decision-drift | DD-21 | 1-[89][0-9] → 1-(8[0-9]|9[0-9]|10[0-9]) (ok 文本同步) | rc=0
- decision-drift | DD-21 | 1-[89][0-9] → BRE 1-\(8[0-9]\|9[0-9]\|10[0-9]\) (cnt=字面 grep, ERE 括号按字面失配, 改 BRE 等价; ok 文本同步) | rc=0
- drift-check-subagent | DCS-11 | 1-[89][0-9] → 1-[89][0-9]\|10[0-9] (字面 grep BRE 并联; 特例 8 未触发: 「偏移检查子代理化」/「Rule 61」内容行实测均在位, 根因=纯纪元锚) | rc=0
- error-loop | EL-11 | Rules 1-(3[1-9]|[4-7][0-9]|8[0-9]|9[0-9]) → 补 10[0-9] 分支 (ERE; 消息文本 1-3x..7x|8[01]→1-3x..10x) | rc=0
- execution-honesty | EH-09 | 1-[89][0-9] → 1-(8[0-9]|9[0-9]|10[0-9]) (z 面 ERE; 消息文本 1-80→1-101) | rc=0
- iteration-persistence | IP-12 | 1-[89][0-9] → 1-(8[0-9]|9[0-9]|10[0-9]) (ERE; 消息文本 1-80→1-101) | rc=0
- lane-advancement | LA-12 | 1-[89][0-9] → 1-(8[0-9]|9[0-9]|10[0-9]) (正锚; 负断言 1-39/1-40 不动; 消息文本 1-80→1-101) | rc=0
- parallel-scheduling | P-05 | Rules 1-[89][0-9] (skill_max 提取式) → Rules 1-([89][0-9]|10[0-9]) (阈值 ≥84 不动; bad 消息文本未动因其语义描述) | rc=0
- plan-tier | PT-08 | Critical Rules 核心域.*Rules 1-[89][0-9] → .*Rules 1-([89][0-9]|10[0-9]) (ERE; 消息文本 1-80→1-101) | rc=0
- reflect-verify | RV-10 | Rules 1-(3[5-9]|[4-9][0-9]) → 补 10[0-9] 分支 (ERE; 消息文本同步 1-35..1-101) | rc=0
- reliability-institution | R-09 | 1-[89][0-9] → 1-(8[0-9]|9[0-9]|10[0-9]) (正锚; 负断言 1-40=0 不动; 消息文本 1-80→1-101) | rc=0
- requirement-coverage | RC-11 | 1-[89][0-9] → 1-(8[0-9]|9[0-9]|10[0-9]) (正锚; 负断言 1-39=0 不动; 消息文本 1-80→1-101) | rc=0
- requirement-grading | RG-06 | 1-[89][0-9] → 1-[89][0-9]\|1-10[0-9] (字面 grep BRE 并联, 紧 1-10 前缀防 incidental; 消息文本同步) | rc=0
- research-first | RF-06: 1-[7-9][0-9] → 1-[7-9][0-9]\|1-10[0-9] (cnt=字面 grep BRE 并联, 紧 1-10 前缀; 标签 1-6X→1-7X..10X) | RF-07: Rules 1-[89][0-9] 全集 → Rules 1-(8[0-9]\|9[0-9]\|10[0-9]) 全集 (cntE ERE; 标签 1-80→1-101) | rc=0
- root-resolution | RR-09: Rules 1-[89][0-9] 全集索引： → Rules 1-(8[0-9]\|9[0-9]\|10[0-9]) 全集索引：(ERE =1; 负断言 {51,53,55} 不动) | RR-16: 行内 1-[89][0-9] → 1-(8[0-9]\|9[0-9]\|10[0-9]) (ERE) | rc=0
- self-resolution | SR-07: 1-[89][0-9] → 1-(8[0-9]\|9[0-9]\|10[0-9]) (正锚; 负断言 1-39=0 不动) | SR-08: 同前 ERE 扩展 (^40\.=6 不动) | rc=0
- session-log | SL-05 | 1-[89][0-9]([^0-9]|\$) → 1-(8[0-9]\|9[0-9]\|10[0-9])([^0-9]|\$) 尾边界同步; 负样本探针 79/90→79/110 | rc=0
- skill-split | T-锚 | Rules 1-(3[0-9]\|[4-9][0-9]) → 补 10[0-9] 分支 (ERE; 标签 1-3..83→1-3..101) | rc=0
- source-anchor-discipline | SA-07 | 1-[89][0-9] → 1-(8[0-9]\|9[0-9]\|10[0-9]) (chk cmd 内 ERE, ≥2 不变) | rc=0
- absorption-discipline | AD-12(pin 级联, 因 AD-04 首跑 rc=0 但 SRV-12 暴露) | _pin_lit ×5 目标字面 grep -cE '1-[89][0-9]' → '1-(8[0-9]|9[0-9]|10[0-9])'; _pin_tol research-first/context-pressure '1-[89][0-9]'→'1-(8[0-9]|9[0-9]|10[0-9])'、skill-split 补 10[0-9] 分支 (ad12=0 判据不变) | rc=0
- source-anchor-discipline | SA-07 | 1-[89][0-9] → 1-(8[0-9]\|9[0-9]\|10[0-9]) (chk cmd ERE, ≥2 不变) | rc=0
- tool-selection | TS-05 | 1-[89][0-9] → 1-(8[0-9]\|9[0-9]\|10[0-9]) (正锚; 负断言 1-39=0 不动; 消息文本 1-80→1-101) | rc=0
- verification-gate | VG-06 | Rules 1-[89][0-9] → Rules 1-[89][0-9]\|Rules 1-10[0-9] (字面 grep BRE 并联, 紧 1-10 前缀; 消息文本同步) | rc=0
- veto | VT-10 | Rules 1-(3[1-9]\|[4-7][0-9]\|8[0-9]([^0-9]\|$)\|9[0-9]([^0-9]\|$)) → 补 10[0-9]([^0-9]|\$) 分支 (ERE 尾边界; 消息文本 1-3x..99→1-3x..101) | rc=0

## 总账
- 26/26 脚本修复完成（无 BLOCKED；特例 8 未触发：DCS-11 探针实测「偏移检查子代理化」「Rule 61」内容行均在位，根因=纯纪元锚，SKILL.md 正文零改动）
- AD-12 pin 级联注：absorption-discipline AD-12（11 处 pin 锚）随兄弟脚本 live 锚形态演进同步（_pin_lit ×5 目标字面→grep -cE '1-(8[0-9]|9[0-9]|10[0-9])'；_pin_tol research-first/context-pressure/skill-split 目标字面同步；conclusion-discipline '1-[4-7][0-9]'/workflow-orchestration '1-(68|69|71)'/SA '^71\.[1-7] ' 不动；判据 ad12=0 不变）
- run-selftests.sh 原始输出（全量跑 run=94 reused=0）:
Total: 94 PASS=94 FAIL=0 (run=94 reused=0)
[run]    selftest-verify-io (rc=0 PASS=0 FAIL=0)
[run]    selftest-veto (rc=0 PASS=13 FAIL=0)
