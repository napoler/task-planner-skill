# sub:15 code-reviewer Phase 7 检查点

## 里程碑
- [M1] 读完 check-dispatch.sh(117行) + selftest-dispatch.sh(121行) 全文;bash -n 全 6 脚本 OK
- [M2] git diff 4 改动文件读完;zcode-pretooluse.sh 上下文核实(W|E|AP 分支未动,Agent 分支新增独立 case);config.json dispatch_contract_enforce 键存在且 jq 取值="enforce"
- [M3] 实跑 selftest-dispatch.sh:11/11 PASS rc=0;路径探测(空格OK/末尾斜杠与符号链接三文件匹配假阴性/memory 白名单位置)完成

## 最终结论
status: done
acceptance: 5/6 pass — [1:PASS 2:PASS 3:PASS 4:PASS(尾部斜杠/符号链接为 MINOR 隐患) 5:PASS 6:FAIL(warn 计数文件残留 /tmp,非 hermetic)]
files: plans/task-v057-subagent-io-contract/{subagent-state/15-code-reviewer-p7.md,findings.md,progress.md}
evidence: c1=check-dispatch.sh:70,73,78,82 + zcode-pretooluse.sh:59,60 (缺参/不可读/无jq/无计划均exit0); c2=check-dispatch.sh:29 grep -qF -- 无eval/无shell展开 + hook:59 mktemp/63 rm -f 全路径清理; c3=check-dispatch 仅exit 0/1/2(70,80,84,90,93,108,110) + hook:64 [rc -eq 2]&&exit2 后 exit0, zcode-pretooluse.sh:26 W|E|AP 分支 diff 无改动; c4=实测 空格plan_dir rc=0 通过, 末尾斜杠$pd/与符号链接 $pd/link 时三文件串不匹配→假阴性MINOR; c5=check-complete.sh:404 awk 'exit (r+0<f+0)' r<f→exit1→rate_ok=0 ✓ + check-delegation.sh:171 新 case 分支纯追加不改既有判定; c6=selftest-dispatch 11/11 PASS 实跑确认, 用例含 T08 恰2行/T09-11 真走 hook, 但 check-dispatch.sh:89 warn 档写 /tmp/task-planner-dispatch-warn-${sid} 且 selftest T05 未清理、T_MEM 未清 /tmp/task-planner-warn-main-sid.count → 非严格 hermetic
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v057-subagent-io-contract/subagent-state/15-code-reviewer-p7.md (status: done)
findings_written: findings.md §#### [sub:15-code-reviewer] Code Review 结论 (## Technical Decisions 前)
blockers: CHANGES_REQUESTED(MINOR,非阻断级): ①check-dispatch.sh:89 warn 计数文件 /tmp/task-planner-dispatch-warn-${sid} 无 TTL/清理 + selftest T05/T_MEM 未 rm,跨会话残留; ②check-dispatch.sh:26 prompt 三文件串用 $pd 精确拼接,plan_dir 带尾部斜杠或经符号链接时匹配失配→假阴性报缺项(判据4隐患,建议归一化 $pd 去尾斜杠)
confidence: HIGH
