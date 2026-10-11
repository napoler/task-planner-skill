# 07-s4-selftest 检查点 — task-v136 Phase 4 / S4: selftest-execution-honesty.sh 新建

> 执行体: executor（sonnet-1）；写前锚确认 → 写后实跑 → 破坏测试 → 既有 3 脚本回归，全程只写 1 个仓库文件。
> 产物: `/home/terry/task-planner-skill-worktrees/task-v136/skills/task-planner/scripts/selftest-execution-honesty.sh`（14 断言 EH-01..EH-14）

## 一、写前锚确认清单（写断言前逐条 grep 实测，全部命中后才写入）

| 锚 | 目标文件 | 实测结果（2026-10-05） |
|----|---------|------------------------|
| `^54\.[0-6]` 七子条 | critical-rules.md L597-609 | 计数=7（54.0:597 / 54.1:599 / 54.2:601 / 54.3:603 / 54.4:605 / 54.5:607 / 54.6:609），块头 `^### 54` 在 L595 |
| 54.0 标题全字面 `54.0 **有依据原则（evidence-first reporting）**` | 同上 L597 | 存在（EH-01 锁 =1） |
| 54.1 `54.1 **就绪语义（ready-state honesty）**` / 54.2「阻塞影响矩阵」/ 54.3「仪式性进展禁令」/ 54.4「推迟举证四要素」/ 54.5「决策依据落盘与引用义务」 | L599-607 | 各存在（EH-02..06 锁 =1） |
| 54.6 标题前缀 `54.6 **机制（零新 config 键`（尾部含 Why 说明故只锁前缀） | L609 | 存在（EH-07） |
| 关键短语 `evidence-first reporting`=1 / `decision-basis persistence`=1 / `零新 config 键`=33 | critical-rules.md | 各 ≥1（EH-08；「零新 config 键」在 54.0 块头+54.6+索引等多处复现，取 ≥1 口径） |
| SKILL.md `Rule 54`=3（:206 C38 行/:309 摘要 bullet/:333 References 行） | SKILL.md | =3，≥1 口径 |
| SKILL.md `C38`=1（:206 唯一） | SKILL.md | =1（EH-09 锁 =1） |
| SKILL.md `Rule 40-54`=1（:268 索引行「（Rules 1-39（含 Rule 40-54 全集））」） | SKILL.md | =1（EH-09） |
| delivery-summary.md `54.1`=1 / `54.4`=1（:34 真实进展对照行「Rule 54.1③/50.3 … Rule 54.4 四要素举证 … Rule 54.5」） | 模板 :34 | 各 =1（EH-10 双锚） |
| image-generation-executor.md `Rule 54`=1（:37）/ video-generation-executor.md `Rule 54`=1（:38） | companion 两文件 | 各 =1（EH-11/EH-12） |
| critical-rules.md `55\.[0-9]` 全文 =0（RC-15 前移防线在位：selftest-requirement-coverage.sh:167 `grep -c '^55\.'`=0） | 同目录脚本实测 | 0（EH-13 语境锚定到 54.6 行 L609 起至文件尾，tail 窗口扫描而非全文裸匹配，v127/RR-09 判例） |
| config.json `"execution_honesty`=0（零新键佐证） | config.json | 0（EH-14 负断言） |

## 二、写后实跑输出（worktree 原文件，bash 直跑）

```
$ bash selftest-execution-honesty.sh
EH-01 PASS critical-rules.md 54.0「有依据原则」=1
EH-02 PASS critical-rules.md 54.1「就绪语义」=1
EH-03 PASS critical-rules.md 54.2「阻塞影响矩阵」=1
EH-04 PASS critical-rules.md 54.3「仪式性进展禁令」=1
EH-05 PASS critical-rules.md 54.4「推迟举证四要素」=1
EH-06 PASS critical-rules.md 54.5「决策依据落盘」=1
EH-07 PASS critical-rules.md 54.6「机制（零新 config 键」=1
EH-08 PASS critical-rules.md 关键短语 evidence-first=1≥1 / decision-basis=1≥1 / 零新 config 键=33≥1
EH-09 PASS SKILL.md Rule 54=3≥1 且 C38 行=1 且索引括注「Rule 40-54」=1
EH-10 PASS delivery-summary.md「54.1」=1≥1 且「54.4」=1≥1（真实进展对照行双锚）
EH-11 PASS image-generation-executor.md「Rule 54」指针行=1
EH-12 PASS video-generation-executor.md「Rule 54」指针行=1
EH-13 PASS critical-rules.md 54 块尾上下文（L609起）「55.x」=0（RC-15 前移防线呼应，55 号未被顺手创建）
EH-14 PASS config.json 零新键：「"execution_honesty」命中=0（54.6 零 config 键声明成立）
Total: 14 PASS=14 FAIL=0
（exit=0）
```

## 三、破坏测试记录（/tmp 复制试验，仓库文件零触碰，试验目录已删）

方法：整棵 skill 目录树复制到 /tmp/selftest_eh_destruct_*，只改副本再跑副本内脚本（脚本基于自身位置解析路径，天然支持该试验），跑完 `rm -rf` 删净。

1. **正向破坏（标题裁剪）**: 副本 critical-rules.md 内 `54.0 **有依据原则（evidence-first reporting）**` → `54.0 stripped`。
   结果: `EH-01 FAIL …锚命中=0（应 =1）` + `EH-08 FAIL（evidence-first=0）`，`Total: 14 PASS=12 FAIL=2`，exit=1。断言可触发，FAIL 链正确（同一变异被 EH-01 标题锚与 EH-08 语义内核双探测，符合 54 死文探测设计）。
2. **负断言破坏（55.x 顺手写入）**: 副本 critical-rules.md 末尾追加 `55.9 **假子条（破坏测试注入）**：占位`。
   结果: `EH-13 FAIL …54 块尾上下文「55.x」命中=1（应 =0）`，`Total: 14 PASS=13 FAIL=1`，exit=1。语境锚定负断言正确触发（tail 自 54.6 行起窗口捕获尾部注入）。
3. **tmp 清理确认**: `rm -rf` 后 `ls /tmp/selftest_eh_*` 无残留（试验 2 目录亦删）。

## 四、既有 selftest 抽 3 回归（与 S2 改锚无冲突）

| 脚本 | 结果 |
|------|------|
| selftest-root-resolution.sh | exit=0，`Total: 17 PASS=17 FAIL=0`（RR-16 S2 宽容化 40-5[3-9] 命中「Rule 40-54」PASS 在位） |
| selftest-requirement-coverage.sh | exit=0，`Total: 23 PASS=23 FAIL=0`（RC-15 `'^55.'`=0 前移防线与新脚本 EH-13 呼应面一致） |
| selftest-reliability-institution.sh | exit=0，`Total: 16 PASS=16 FAIL=0` |

## 五、scope 合规

- 仓库写入仅 1 文件: scripts/selftest-execution-honesty.sh（Write 新建，无 Edit 触其他文件）。
- 脚本约定合规: `#!/usr/bin/env bash` 开头；`$SCRIPT_DIR/$SKILL_ROOT` 自身位置解析（镜像 selftest-veto.sh L21-26，零硬编码绝对路径）；末行 `Total: N PASS=x FAIL=y` + `exit $((FAIL > 0))`（与 root-resolution/veto 同构，供 Total 行求和消费）；每断言行首 `# Why:` 双层注释（Rule 45）。
- 14 断言 ≥ 验收线 12。
- **遗留登记（不属本单元 scope）**: selftest-registry.tsv 无 execution-honesty 登记行——按 root-resolution 同先例（registry T02：新增未登记脚本→FAIL），登记行须由后续 S-unit/主进程追加，本单元 scope=仅 1 脚本文件，故登记挂起待补（Phase 5 全量回归跑 registry 时若 T02 FAIL 即补登记）。
