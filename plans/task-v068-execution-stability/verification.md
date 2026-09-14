# Verification Contract & Phase Gates — task-v068-execution-stability

## Goal (1 sentence)

让 task-planner 技能族的 hook 链路具备「环境级中断自愈」能力：本会话产生的 5 类中断事件（E1-E5）在满足 sid 护栏的前提下自动自愈或降噪，使执行不被中途打断，且全量 selftest 无回归。

---

## Verification Contract（终验复验 2026-09-14）

- [x] VC-1: 哨兵自愈落地（E1 双层）
  Evidence: check-scope.sh:63-68 memories 前缀豁免（主进程实测 memory 写入 exit 0、非白名单仍拦）；plan-created.cjs:175-212 无 sid 兜底清除（主进程实测：真实 E1 场景清零 ✓/活跃指针<24h 保留 ✓/指针>24h 删除 ✓）；v065 D-12+v060 缺陷关闭
- [x] VC-2: tamper 自愈落地（E2,方案 A'）+ 护栏
  Evidence: zcode-posttooluse.sh:57-79 三分支路径归一化（绝对/相对含 slash CWD 直拼/纯文件名 glob）+ owner==sid 护栏 + 同步重锁 + attestation attested_by_sid（attest-plan.sh:70）；主进程实测：相对含 slash+连字符 sid 重锁 by_sid=sessabc123 ✓、owner 不匹配不重锁 ✓、外层 ZCODE_SESSION_ID 尊重 ✓；CR 两轮：首轮 CHANGES_REQUESTED 2×P0 → 修复轮 A/B/补修全核销 → 复审 APPROVED
- [x] VC-3: observe 降噪落地（E3）
  Evidence: zcode-userpromptsubmit.sh:24-35 UPS_SID env 兜底链（主进程实测 env-only sid 写 owner=sessTEST123）+ check-delegation.sh:260-265 observe 会话级节流（执行器 run1 注入/run2 静默实测）+ tr 规范全仓统一剥除（canon 逐字节一致实测含 sess-abc123 三侧）
- [x] VC-4: SKILL「环境级中断自愈」条款 + config 键
  Evidence: SKILL.md:409 段（516 行,净+3 ≤10）；config.json:111-121 hook_self_heal_enforce（default warn,enum 三值,29 键,properties 合规；off 档读取守卫登记后续=D-1）
- [x] VC-5: 新 selftest 全绿 + 全量 0 fail
  Evidence: selftest-execution-stability 17 断言（含 T11 行为级重锁正负例/T12 三侧 canon 对比/破坏性自检）；全量 13 套件 213 例 0 fail（基线 196+17 无回归）；smoke 17/0
- [x] VC-6: 跨文件一致
  Evidence: hook_self_heal_enforce config+SKILL 同拼写变体 0；tr canon 七文件统一 'a-zA-Z0-9'（13 处+timestamp 2 处豁免,复审 grep 核销）；attested_by_sid/observe flag/memories 白名单 6 脚本锚点一致
- [x] VC-7: Code Review APPROVED + 合并回 + 部署对账
  Evidence: 复审 VERDICT=APPROVED（首轮 CHANGES_REQUESTED 2×P0 全核销:修复轮 A=P0-1 三分支+P0-2 canon 回归剥除/B=P1-2 同步+P2-1 缓存+check-delegation canon/补修=含 slash 分支/C=selftest 行为断言/D=T20b flag 自洁）；merge f783880；skills 3 位 IDENTICAL（本轮无 companion agent 改动,agent 位不涉及）；worktree/分支已清理

**终验规则核对**：7/7 VC 通过 → outcome: **COMPLETE**

## Phase Gates

| Phase | Status | 关键证据 |
|-------|--------|---------|
| 1 调研 | complete | checkpoint 01（六项根因全落点+5 风险注记+负结果报告）|
| 2 设计 | complete | findings「Phase 2 设计定稿」自愈矩阵 6 行（E1 双层/E2 方案 A'/E3 env 兜底+节流/E4 deferred/E5 不动）+KQ1-4 |
| 3 实现 | complete | S1-S4 全 done（Handoff 02-05 ☑）,commit 8039feb,9 文件（7 改 2 新）|
| 4 验证 | complete | 全量 213 例 0 fail + CR 首轮 CHANGES_REQUESTED→修复轮 A/B/补修/C/D 全核销→复审 APPROVED,commit 99df9ab+ea6ffa6 |
| 5 合并部署 | complete | merge f783880 + skills 3 位 IDENTICAL + worktree 清理 + 主仓复验 17/17 |

## 📚 必要知识储备符合性核验
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| hook 收编脚本全集 | Phase 1 explore 六项锚点 + 各 S-unit 先 Read 再改 | 符合 |
| 哨兵/attestation 机制 | E1/E2 修复均以勘察行号为锚,负例实测护栏 | 符合 |
| E1-E5 设计输入表 | 实现期逐项对照根因（progress Phase 3） | 符合 |

## 委派统计复验（Rule 25.4）
- 子代理执行 Phase：1（explore）/3（executor×4+修复轮 4 次）/4（行为实测由主进程白名单③+执行器混合）= 3/5
- 主进程直做：Phase 2（②设计）、Phase 5（①③ git/部署）、Phase 4 机械验证（③）——白名单内 → WHITELIST-EXEMPT
- 实际派发：plan-writer 1 + explore 1 + executor 8 + Code Reviewer 2 = 12 次,全程串行 Rule 21.4
- verdict=ok（check-delegation stats,violations=[]）

## 质量门控统计（Rule 26）
- [x] Q1-Q6：CR 两轮拦截 2×P0（质量门有效行使）；修复全核销后复审放行；无伪造证据（所有行为断言主进程一手复验）
- [x] Evidence 抽查 ≥3：①哨兵兜底正负例主进程实测 ②重锁 by_sid 翻转+负例主进程实测 ③全量 213 例主进程亲跑
- [x] 遗留项登记如下（均不阻断）
- [x] 未处置违规：无

## 遗留项（deferred,均不阻断）
| # | 内容 | 建议 |
|---|------|------|
| D-1 | hook_self_heal_enforce off 档读取守卫未实现（三档当前 warn=默认行为,off 不生效） | 后续轮三 hook 加读取守卫 |
| D-2 | E4 慢注入未修（Rule 23 O(N) 全 plans/ 循环+resolve 7 级盲找,32 计划放大） | 独立性能轮（FMEA 216 削链风险,须带护栏实测） |
| D-3 | allow-direct.sh:41 与 ledger-append.sh:69 tr canon 残留 '_-'（复审 P1,方向保守非阻断） | 下轮 canon 全仓清扫 |
| D-4 | check-delegation.sh:84 注释口径陈旧；posttooluse 带空格相对路径静默 fail-open（P3）；attested_by_sid 外层注入未剥除（P3 LOW） | 清理轮 |
| D-5 | /tmp/task-planner-observe-*.flag 无 gc（与既有 /tmp warn-count 同类约定） | 清理轮顺带 |

## Goal Verification（Goal Gate）
- [x] VC-1 → PASS　[x] VC-2 → PASS　[x] VC-3 → PASS　[x] VC-4 → PASS　[x] VC-5 → PASS　[x] VC-6 → PASS　[x] VC-7 → PASS

 outcome: **COMPLETE**

## 5-Question Reboot Check
| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 已交付（COMPLETE, merge f783880） |
| 2 | Where am I going? | 交付报告 |
| 3 | What's the goal? | 见顶部 Goal |
| 4 | What have I learned? | findings.md（六项根因/自愈矩阵/canon 教训） |
| 5 | What have I done? | progress.md（5 Phase+修复轮全程） |
| 6 | Which tasks need processing? | 无挂账（D-1..D-5 已登记） |
