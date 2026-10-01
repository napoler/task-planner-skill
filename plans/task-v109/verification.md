# Verification Contract & Phase Gates

## Goal (1 sentence)

新增 memory-hygiene 记忆整理模板固化「验证锚/时效/整理」三道防线，并以 dogfood 整理 57 条记忆恢复可用性，全部验证由全新独立子代理执行。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 模板增补+级联后全量 selftest 回归 0 FAIL（独立子代理，主仓 master 合并后终验场）
  Evidence: worktree 回归（sub:3，抓漏网锚 skill-split:50 → 已修）+ 主仓终验回归（sub:8，master@d8eb770，42/42 rc=0，SUM-ASSERTIONS=660）
- [x] VC-2: 新模板形态合规+17 variant 计数全链一致
  Evidence: 验证二（sub:4）17/17 声明+区块核对；对齐审查（sub:5）全库「16 variant/16 个 variant」零残留、mapping §一=17/§六=17/§九=18 行、TL-17+skill-split:50 断言健康、gate exit 0
- [x] VC-3: 干净上下文实测：fresh 子代理用新模板对 3 条真实记忆四维校验跑通
  Evidence: subagent-state/4-executor.md（task-v091→updated/task-v056→stale-marked/clean-context→verified，各含验证锚）+ 协议缺口 G-1/G-2 已补强
- [x] VC-4: dogfood 整理产出完整+主进程抽验通过后应用
  Evidence: memory-hygiene-report.md（57 行总表：verified 49/updated 2/stale-marked 4/删除建议 0）+MEMORY.md.proposed（57 行 ≤200 字符+验证戳）；主进程六项抽验全过 → 已应用：MEMORY.md 45.4KB→11.9KB（原版备份 MEMORY.md.backup）+6 条 topic 标注（STALE×5+UPDATE×1）落位复验
- [x] VC-5: worktree 合并回成功+对账结论+主仓 porcelain 干净
  Evidence: smart-merge-back V5 拦截（master 领先）→ worktree merge master 处置 → MERGED d8eb770 → worktree/分支清理；主仓 variant=17+级联 4 处命中复验；部署对账（sub:9）三宿主结论+分级部署建议
- [x] VC-6: 对齐审查通过+变更记录三要素
  Evidence: sub:5 四要素全过 P0=0/P1=0/P2×3（1 处已处置+2 处超 scope 登记）；变更记录见下方

**终验规则**：6/6 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: 记忆体系全量盘点+模板设计
**Done when**: [x] 57 条四维盘点（33 条风险清单）+设计稿 M1-M5
**Verification**:
- [x] V-1.1: 子代理「43 脚本 655 PASS」数字错误由主进程第一手证伪（42 .sh+1 tsv 误计）——防错误传播机制首次实战
Status: `complete` Last verified: 2026-10-02

### Phase 2: 模板编写+四点同步级联
**Done when**: [x] memory-hygiene-type.md 230 行（标准区块全集+M1-M5 协议）+7 文件级联+TL-17 锚
**Verification**:
- [x] V-2.1: TL 18/18+gate exit 0+主进程抽验 M1-M5 节在位（:121-167）
Status: `complete` Last verified: 2026-10-02

### Phase 3: 独立子代理验证（fresh ×3+两次缺陷处置）
**Done when**: [x] 三波验证全过+两处真缺陷（漏网锚/Drift Log 缺失）抓出并处置
**Verification**:
- [x] V-3.1: 漏网锚补修 6 处（skill-split:50+guide:64,71+README×3）复跑 41/41+18/18；Drift Log+M2/M3 补强 commit；P2 处置 commit
Status: `complete` Last verified: 2026-10-02

### Phase 4: dogfood 记忆整理
**Done when**: [x] 57 条处置+报告+proposed+抽验后应用
**Verification**:
- [x] V-4.1: 六项抽验（行数/超长/锚实存/STALE 格式）全过；应用后复验（11.9KB/57 行/6 标注在位）
Status: `complete` Last verified: 2026-10-02

### Phase 5: 合并回与终验簿记
**Done when**: [x] MERGED d8eb770+清理+对账+终验 660/0
**Verification**:
- [x] V-5.1: V5 拦截处置（worktree merge master）后合并成功——FMEA 预案实战
Status: `complete` Last verified: 2026-10-02

---

## Evidence 抽查记录（主进程第一手复现）

| # | 抽验项 | 结果 |
|---|--------|------|
| 1 | 盘点「43 脚本」数字 | 证伪（ls 实测 42 .sh+registry.tsv） |
| 2 | report 总表 57 行+proposed 57 行 0 超长 | 证实 |
| 3 | task-v091 基线漂移判定（42 实测） | 证实 |
| 4 | commit 锚 c91677d/5a30382 实存 | 证实 |
| 5 | STALE 标注文案格式与依据 | 证实 |
| 6 | 漏网锚全库扫残留=0+skill-split 41/41 | 证实 |
| 7 | 新模板 M1-M5+Drift Log 补齐后 grep | 证实 |
| 8 | 应用后 MEMORY.md 11.9KB/57 行/6 标注 | 证实 |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| v108 模板新范式 | 新模板区块对照 bugfix-type.md（验证二核对） | 符合（Drift Log 缺失被抓出并补） |
| 记忆系统契约 | MEMORY.md 行 ≤200 字符+验证戳；topic frontmatter 未动 | 符合 |
| 记忆痛点实测 | Phase 1 盘点 42 条易过时面→dogfood 全量处置 | 符合 |
| TL-17 锚现状 | 级联 16→17+skill-split 漏网锚补修 | 符合（回归抓漏兜底） |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":5,"phases_delegated":3,"delegation_rate":0.600,"verdict":"ok","violations":[]}
```

- [x] verdict=ok、violations=0；rate 0.6 略低于 floor 0.7 但主进程直做面全部命中白名单（② 计划簿记/① git 编排与合并/⑥ 少量 ≤3 行机械修正）→ **WHITELIST-EXEMPT**；验证独立性专项：六波验证（sub:3/4/5/8/9+盘点 sub:1）全部 fresh 子代理，主进程零自测替代验收

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 1 项（盘点子代理数字错误 43 脚本——已证伪并登记勘误，未进入决策链），豁免 0，未处置 0
- [x] Evidence 抽查 ≥3 条：8 条全证实
- [x] 未处置违规：无 → 不降级

## Goal Gate (终验)

```
## Goal Verification — 记忆整理模板+记忆可用性治理
- [x] VC-1: 双场回归全绿（worktree+master 660/0） → PASS
- [x] VC-2: 17/17 形态+计数全链一致+锚健康 → PASS
- [x] VC-3: 干净上下文 3 条抽样校验跑通+协议补强 → PASS
- [x] VC-4: 57 条处置+抽验后应用（MEMORY.md 45.4→11.9KB+6 标注） → PASS
- [x] VC-5: 合并 d8eb770+对账+porcelain 干净 → PASS
- [x] VC-6: 对齐审查 P0/P1=0+变更记录 → PASS

 outcome: COMPLETE
```

## 变更记录（42.6.3 三要素）

| 变更 | what | why | 验证 |
|------|------|-----|------|
| 新增 memory-hygiene-type.md（230 行，merge d8eb770） | 记忆整理任务模板：M1 盘点表/M2 四维机械校验/M3 处置枚举（删除仅建议）/M4 验证锚+MEMORY.md.proposed 契约/M5 写入三要素 | 用户「防错误落伍记忆被当正确内容使用」指令+记忆整理可反复执行化 | 五波独立子代理验证+干净上下文抽样实测 |
| 17 计数级联 7 文件+漏网锚补修 6 处 | mapping/plan-writer/SKILL/critical-rules/guide/selftest×2 全链 16→17 | Rule 34.2 四点同步 | 全库 grep 零残留+双 selftest 断言健康 |
| 记忆目录治理（dogfood 应用） | MEMORY.md 45.4→11.9KB（57 行+验证戳）+6 条 topic 标注（STALE×5/UPDATE×1）；原版备份 plans/task-v109/MEMORY.md.backup | 恢复记忆可用性：过时基线/遗留/部署拓扑断言全部带失效条件 | 主进程六项抽验+应用后复验 |

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 全 Phase complete，终验 COMPLETE |
| 2 | Where am I going? | 交付；部署同步待用户裁决（zcode 合入式/claude+opencode 全量） |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md（漏网锚模式/盘点数字错误证伪/协议缺口实战反哺） |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
