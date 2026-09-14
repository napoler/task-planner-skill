# sub:07-executor fix-b checkpoint
status: done
started: 2026-09-13
finished: 2026-09-14
## 已完成
- [x] Init: checkpoint 创建
- [x] S1 P1-2 zcode-posttooluse.sh:81-84: 同步执行 + env fallback (`${ZCODE_SESSION_ID:-$SID}`)
- [x] S2 P2-1 plan-created.cjs:194: 缓存 `const ptrExists = fs.existsSync(ptr)`, L197/L202 共用
- [x] S3 canon check-delegation.sh:96/255: `a-zA-Z0-9_-` → `a-zA-Z0-9`（:186 timestamp 未动）
- [x] S4 验收 6/6 PASS:
  1. bash -n 三脚本 PASS
  2. P1-2 行为复验: OUTER unset → attested_by_sid=sesssessabc123; OUTER=OUTERSID → attested_by_sid=OUTERSID; 无孤儿进程
  3. P2-1 逻辑核对: L194 唯一缓存调用点; 行为复验 3 类哨兵（stale ptr / no ptr / active ptr）分类正确
  4. grep -n "tr -cd" check-delegation.sh: L96/L255 均为 `a-zA-Z0-9`, L186 `0-9` 未动
  5. 跨脚本 canon 复测: sess-abc123 → sessabc123 三侧逐字节一致
  6. git diff --stat: 3 文件（zcode-posttooluse.sh / plan-created.cjs / check-delegation.sh）
- [x] S5 findings.md 追加 `#### [sub:07-executor] S5b 产出` 小节
## 残余
- zcode-userpromptsubmit.sh M 状态为 S5a 遗留, 非本 S-unit 改动, 未触碰

## 追加: 主进程复验 P0-1 修复 (2026-09-14)
- P0-1 `zcode-posttooluse.sh:57-79` case 三分支重构:
  1. `/*)` 绝对路径: 不动
  2. `*/*)` 相对含 slash: `[ -n "$CWD" ] && [ -f "$CWD/$fp" ] && fp="$CWD/$fp"` (存在才归一化, 零子进程短路)
  3. `*)` 纯文件名: 保留 CWD 直拼 + plans/* glob 探测 (原 E2-fix 逻辑不变)
- 复验 4/4 PASS:
  - 主进程失败场景 (相对含 slash, cwd 归一化): attested_by_sid=sessabc123 非空, plan_sha256 与文件 sha256sum 一致
  - 纯文件名正例 (task_plan.md): plans/* 探测命中, attested_by_sid=sessabc123
  - owner 负例 (.session-owner=othersid999): 不重锁, NO-RELOCK-OK
  - 不存在的相对含 slash 负例 (plans/nope/task_plan.md): 静默跳过, NO-RELOCK-OK
  - P1-2 回归: OUTER unset → attested_by_sid=sessabc123; OUTER=OUTERSID → attested_by_sid=OUTERSID; 无孤儿进程
- bash -n PASS
- 本 S-unit 仅改 zcode-posttooluse.sh 一个文件 (git diff 含 S5a/S5b 全部 4 文件 M 状态, zcode-userpromptsubmit.sh 为 S5a 遗留)
