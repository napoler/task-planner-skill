# Verification Contract & Phase Gates — task-v082

## Goal (1 sentence)

Rule 35 族新增 35.6 最小探针原则（验证/查证动作默认 `echo ok` 类单条最小输出测试，禁一上来复杂化）+ SKILL/CD selftest/CHANGELOG 联动，全量 selftest 0 FAIL 后合并 master、部署 3 实体位、push。

---

## Verification Contract 终验（2026-09-18 01:4x）

- [x] VC-1: critical-rules.md 35.6=最小探针原则条款（含 echo ok 示例+升级需怀疑点纪律）；35.7=机制（原 35.6 重编号，内容零改动）
  Evidence: grep `^35\.6 \*\*最小探针原则`=L299 命中；35.7 行 vs P1 快照原 35.6 机制行 diff 空=逐字节一致；git diff c10e8f2..e120331 恰 4 文件 11+/5-，除预期行外零删改
- [x] VC-2: SKILL.md C23 行+Rule 35 摘要行两处行内并入「最小探针」，wc -l=543（净增 0，≤548 断言未触）
  Evidence: grep -c '最小探针' SKILL.md=2（L197/L305）；wc -l=543（P2 实查）；selftest-skill-collab T10/execution-stability T8b 全量回归中 PASS
- [x] VC-3: CD selftest 头注记 35.1-35.7、CD-07 双锚（^35.6 最小探针+^35.7 机制）、新增 CD-25「最小探针」双文件断言；本文件全 PASS
  Evidence: bash selftest-conclusion-discipline.sh → Total: 24 PASS=24 FAIL=0（多轮实跑）
- [x] VC-4: worktree 全量 0 FAIL 且合并后 master 全量 0 FAIL（主进程逐 Total 求和）
  Evidence: worktree(e120331 前) 22 脚本 367/0；master(e120331) 精确口径 367/0 异常=0；最终 master(8fed498，含并行 v083) 23 脚本 377/0 异常=0
- [x] VC-5: 仓库根 CHANGELOG.md 条目在位（含最小探针原则摘要）
  Evidence: grep -c 'task-v082' CHANGELOG.md=1；条目位于 [Unreleased]→新增 首位；diff 证实 0 删行纯增
- [x] VC-6: 3 实体位 diff -r IDENTICAL；origin/master push 完成；worktree/分支已清理
  Evidence: 主进程 diff -r 亲验 ~/.zcode、~/.claude、~/.config/opencode 三位 IDENTICAL ✓✓✓（v083 合并后复验仍 IDENTICAL）；本地=远端 8fed498（v083 会话 merge master 后 push，e120331 为其祖先链，内容已上远端）；worktree remove+branch -d 完毕（was b9ba09a）

**终验规则**: 全部 VC 通过 → COMPLETE ✅

## 委派统计（Rule 25）

- 总 Phase=5；子代理执行=0/5；主进程直做=5/5（委派率 0.0）
- 直做理由清单：P1/P5=白名单①②③（git 编排/计划文件/机械验证）；P2/P3=Rule 22.3④ 兜底接管（白名单⑤：code-assistant(haiku-1) 首派 reasoning-level-missing，与 v081 同因实证，预登记 Decisions ④，单文件 ≤300 行）；P4 CR=预登记降级（Explore(mini)×2 provider server error，v081 先例，对照 diff 只读复审+机械验证白名单③）
- **verdict: WHITELIST-EXEMPT**（全部直做理由均命中 Rule 25.3 白名单；rate<0.7 不降级）

## 质量门控统计（Rule 26）

- Q1 伪造证据：无（三证据链：执行/产出/验证逐 Phase 落盘）
- Q2 跳过验证：无（VC-1..6 全部实跑取证）
- Q3 内容质量门：N/A（rule-enhancement 非内容类）
- Q4 抽查 Evidence：35.7 逐字节 diff、CD 24/0、三位 diff -r、CHANGELOG 纯增——4 条抽查全部可复现 ✓
- Q5 未处置违规：无
- Q6 自报采信：子代理 0 次成功返回，无自报总数采信场景；全部求和=主进程逐行
- C19 错误学习：P2/P4 两次环境性失败已落 Error Log（Root Cause 分类=环境性，非技能本体）
- C24 Rule 36：纯增量+编号级联（36.1 豁免），P1 快照基线 diff 对照零语义删除 ✓
