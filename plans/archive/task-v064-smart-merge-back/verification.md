# Verification Contract & Phase Gates — task-v064-smart-merge-back

## Goal (1 sentence)

把"合并回 master"机制化为智能门 `scripts/smart-merge-back.sh`（V1-V6 预检 + ALREADY_MERGED 已合并检测 + --no-ff 合并 + --deploy 部署对账），hermetic selftest 14 用例守护，经 6 轮 Code Review Gate 闭环（R6 APPROVED），dogfood 首跑即真实拦截 ALREADY_MERGED 场景并完成 3 位部署对账。

---

## Verification Contract（终验逐条复验 — 2026-09-12 23:0x）

- [x] VC-1: 智能门脚本落地 — smart-merge-back.sh（539 行）：V1 双校验/V2 干净/V3 scope 重叠(-z+quotePath=false NUL 安全)/V4 ALREADY_MERGED(merge-base --is-ancestor)/V5 MASTER_AHEAD(--force 逃生)/V6 --no-ff 合并+冲突 STOP(exit 7)+MERGE_IN_PROGRESS(exit 8)+--deploy（validate_slot 四向守卫+规范化 norm_path+默认部署根白名单+--allow-home-slot 逃生+改名换位原子替换+trap 兜底）全部判定路径就位
  Evidence: 终态脚本 Read + 各场景实测（R1-R6 审查与主进程复测记录）
- [x] VC-2: selftest 14 用例全过 — SM-01..13（含 SM-11 exit 8 正向、SM-12 $HOME 白名单外 REJECTED、SM-13 真 P0 形态 .git 存活）+ SKIP 口径（/tmp 非 git 环境跑 Total: 13 PASS=13 SKIP=1 rc=0 无 FRAMEWORK_BROKEN）
  Evidence: worktree 内 Total: 14 PASS=14 ×3 一致；R6 复审变异测试（break 2 回归被 SM-13 单独抓住）
- [x] VC-3: 无回归 — worktree 内 7 套件 113/113 fail=0（verify 22/3=部署滞后预期项，部署后归零 25/0）
  Evidence: subagent-state/05-executor.md + progress Phase 5
- [x] VC-4: 联动完整 — worktree-isolation.md §4 机制化入口（合约原文零改动，纯插入）+ SKILL.md :158/:216 两处 bullet + README 16→17 ×2；宽口径扫描无失效引用
  Evidence: progress Phase 4 + R1-R6 审查（联动文件每轮均在 scope 核对内）
- [x] VC-5: dogfood 实证 — **首跑 [V4] ALREADY_MERGED 真实触发**（外部窗口已合并修复轮 6 → 零考古判定，v062 教训机制化首战）；--deploy 3 位 IDENTICAL rc=0；部署位 verify 25/0 + 套件 14/14+18/18
  Evidence: progress Phase 6 段（主进程白名单①③接管，executor 2×ECONNREFUSED）
- [x] VC-6: 合并回 + 部署对账 — master c878dd3（含全部 6 轮修复）；worktree remove + branch -d（was f0b76dc），wt/* 零残留；companion 6 位无差异 + plan-writer agent zcode 位一致/claude 位仅 model 行
  Evidence: git worktree list + git log + 复验输出
- [x] VC-7: 全程隔离与簿记 — 全程串行派发（14 行 Handoff 实时登记，含 provider 接管行）；Rule 27 逐 Phase 提交（9d60da2/19a929e/928febb/cd70ce5/583305c/bb5bdf9/6664aa8/e2a0bf1）；INDEX/attest/ledger 齐备
  Evidence: Handoff 表 + git log

**outcome: COMPLETE**

---

## Code Review Gate 全程（6 轮 — 质量优先的实证）

| 轮次 | 结论 | 核心发现 | 修复 |
|------|------|---------|------|
| R1 | CHANGES_REQUESTED | P0: --deploy rm -rf 无防呆可摧毁任意路径且假绿；P1 空格分词 | cd70ce5+583305c（守卫重写+祖先守卫） |
| R2 | CHANGES_REQUESTED | P0: 字面串比较可被 `//x`、`/x/../y` 别名绕过；P1-1 默认位全在 $HOME 守卫内必失败；P1-2 死代码 | bb5bdf9（norm_path 规范化+守卫分级+绝对路径） |
| R3 | CHANGES_REQUESTED | P0: home 豁免过宽（$HOME/.zcode、$HOME/.ssh 被放行替换） | 9e9384f/83a10ef（默认部署根白名单+--allow-home-slot） |
| R4 | CHANGES_REQUESTED | P0: `break 2` 单词级错误（白名单命中跳过全部后续守卫） | 6664aa8（continue 2，复审已验证正解） |
| R5 | CHANGES_REQUESTED | 仅 selftest 质量（SKIP 记账回归/SM-13 无鉴别力） | e2a0bf1（动态记账+真 P0 形态夹具） |
| R6 | **APPROVED** (HIGH) | 余 5 P3 注释类不阻断；变异测试证明 SM-12/13 对 break 2/豁免回归有隔离鉴别力 | — |

> 期间真实事故 1 起：R2 修复后主进程实测旧守卫绕过时，`--deploy` 祖先路径漏拦导致 v064 worktree 被删（.git+工作树）——**全部提交在主仓分支，零数据损失**，worktree 重建后继续；该事故反向证明了 Gate 逐轮收紧的必要性，祖先守卫即为此增设。

## 委派统计复验（Rule 25.4）

- [x] 子代理执行 Phase 4/7（Phase 2/3/4/5，含 6 轮 Gate 修复派发）；委派率 **0.571** < floor 0.7
- [x] 主进程直做 3 Phase 全部白名单：Phase 1（① git/worktree 编排+③ 机械验证）、Phase 6（①③ **provider 故障接管**——executor 派发 2×ECONNREFUSED ccr 代理不可达，Rule 22.3④）、Phase 7（② 计划系统文件维护）→ **WHITELIST-EXEMPT 不降级**（Rule 25.4a）
- 诚实登记：接管使委派率跌破 floor；provider 故障属不可抗，且 Phase 6 的 dogfood 语义（脚本执行合并）未因接管打折

## 质量门控统计（Rule 26）

- [x] Q1-Q6：无降质违规；2 起环境事件如实登记——① 派发夹具泄漏真实仓 wt/task-test（主进程查验后清理，Error Log 在案）；② v064 worktree 被守卫测试误删（git 分支零损失，重建后继续）
- [x] Evidence 抽查 ≥3 条：ALREADY_MERGED 判定（主进程首跑复现）/REJECTED 守卫（$HOME/.zcode rc=6 零改动）/部署位 verify 25/0——均主进程第一手
- [x] Gate 6 轮 5 次 CHANGES_REQUESTED 全部闭环，R6 APPROVED；无伪造证据（每轮修复均附复审可复现的实测输出）

## 已知遗留（不阻塞）

1. 复审 P3 ×5（注释归因/冗余措辞/缩进——R6 判定不阻断，登记后续轮顺手清）
2. realpath 缺失环境的回退分支不做 symlink 解析（norm_path 边界，复审确认既有设计边界）
3. master 领先 origin 未 push（含 v061-v064 四批）——用户决策
4. `set-active-plan.sh set` 子命令路径嵌套 bug（v060 挂账，本轮再次实锤，未修——scope 外）
