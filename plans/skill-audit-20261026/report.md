# task-planner-skill 深度审查报告（2026-10-26）

- 审查触发：用户 /goal「完成当项目进行深度审查 对skill 各种缺陷进行分析挖掘 并修正」
- 方法：两路 general-reviewer 并行隔离审计（A 引用完整性+计数算术 / B 运行时+硬编码+登记现势）+ 全量 selftest 回归（93/93 基线）+ drift-checker 独立对齐判定 + CR 轻量单轮审查
- 检查点：`subagent-state/{A-ref-integrity.md, B-runtime-hardcoded.md}`
- 修复载体计划：`plans/task-skill-audit-fix-20261026/`（S-unit 派发单元表/VC/委派 stats verdict ok）

## 1. 审查结论总览

| 面 | 结论 |
|----|------|
| 机器守护面（selftest 93 脚本） | **全绿**（93/93 PASS，修复前后均验证；修复过程被 selftest-doc-script-paths 抓获 1 处错形并当场修正——守护有效性正面实证） |
| 计数/纪元声明 | 核心 14 条/卫星 79 条/discipline 46 条/11 卫星 **全部实测无错账** |
| 硬编码迁移性 | 残留缺陷 **0**（videop1 5 处+MIGRATION sed 旧值为登记例外） |
| 遗留登记现势（v188 register-deferred 4 项） | **全部 resolved**（bun→node 已落地并实跑验证/F5 双平台探测/F11 verify_io+schema/S76 原子写+O_EXCL 锁） |
| 引用一致性 | 发现 P1×2+P2×7：卫星路由索引漏已落地规则 2 处 + 裸引用/双形态 8 处（已全修） |
| 运行时文档 | 发现 MAJOR×3+MINOR×2：可执行 bash 块残留 `bun run`（照做即失败）等（已全修） |

## 2. 缺陷清单与处置（22 项发现 → 19 修复 + 3 登记例外）

### 已修复（commit 253f8a0 + 镜像同步提交）
| 编号 | 等级 | 位置 | 缺陷 | 处置 |
|------|------|------|------|------|
| A-01 | P1 | critical-rules.md:194 | task-discipline 卫星索引漏 Rule 95 | 补 `,95` |
| A-02 | P1 | critical-rules.md:198 | plan-collab-router 索引漏 Rule 91 | 补 `,91` |
| A-03(+镜像) | P2 | SKILL.md:17,197→220,235 + README:48,69 + docs/ARCHITECTURE.md:54,101 | 范围串 `69-76` 误含 Rule 75（属 research 域） | 全部改 `69-74,76`（CR 观察补镜像 4 处） |
| A-04/05/06 | P2 | SKILL.md:225/230/242/238 | verification-gate/agent-coverage/split-pattern-library/research-routing 裸引用 | 补卫星前缀 |
| A-07(+回归修复) | P2 | plan-cost-guard/SKILL.md:29 | 裸 `task-planner/` 引用 | 技能根正确形态 `../task-planner/`（初修 `../../` 错形被 selftest 抓获后修正+注释） |
| A-08/09 | P2 | execution-recall-card.md:2 / critical-rules-verification.md:7 | 裸 `task-planner/` | `../../task-planner/`（references/ 子目录双级，正确） |
| A-10 | INFO | template-guide.md:86 | `lib/plan-parse.sh` 路径不精确 | `scripts/lib/plan-parse.sh` |
| A-12 | INFO | collab:35/drift:65/discipline:387,390/agent-coverage:36,40 | 裸 `companion/agents/` | `../../task-planner/companion/agents/` |
| B-01 | MAJOR | INSTALL.md:199,273 | bash 块 `bun run`（bun 不存在，照做即失败） | `node --experimental-strip-types` |
| B-03 | MAJOR | MIGRATION.md:100 | 同上 | 同上 |
| B-02 | MINOR | INSTALL.md:15 | bun 依赖行陈旧 | 删（node 行已覆盖+CA-2 补 22.6+ 注记） |
| B-04 | MINOR | install.sh:8 | 头注释与实检不符 | `git/bash` |

### 登记例外（不动，理由在案）
1. `selftest-evidence-goal-gate.sh` 内 5 处 `bun run` = 测试用例字符串素材（改词=用例语义变化，需单独任务）
2. `templates/variant/code-edit-type.md` 2 处 = 泛化项目示例语境
3. videop1 外部仓路径 5 处 = 设计意图（外部仓非本仓迁移缺陷）

## 3. 僵尸计划治理（plans/ 卫生）

| 计划 | 实况 | 处置 |
|------|------|------|
| task-v188-skill-audit-fix | 批次1-4 已修（4722bb1）但簿记中断 7 天 | ✅ 本轮收口+归档，outcome=PARTIAL（Phase 3 历史直改如实登记） |
| task-v189-skill-audit-deferred-fix | 4 项已修+合并（3fa1e02）但状态未回写 | ✅ 本轮收口+归档，outcome=PARTIAL（同上） |
| task-v190-skill-audit-legacy-fix | **v189 逐字节副本，零独立工作（幽灵）** | ⚠ 处置待用户裁决（删除需授权，Rule 74.3；建议删除或封存） |
| task-P01-evidence-anchor | P-01 已由 task-skill-audit-20261021 落地（63c70ae） | ⚠ 建议封存（待裁决） |
| task-defect-rrv13-dg12-false-pass | pending 无 goal（10-16 登记） | 留待（未启动，非本轮范围） |
| task-v192-deploy-zcode | pending 部署同步 | 留待（另行任务） |

## 4. 流程面自省（本轮产生并已处置）

- drift-checker 判 ⚠️DRIFT 一次（新修复批初期缺计划载体）→ 打回项 ①②③④ 全部处置（建 task-skill-audit-fix-20261026 载体/双批子代理派发/归档结果回填/Drift Log 改写）
- 修复批一处错形（技能根 `../../`）被 selftest-doc-script-paths 抓获 → 当场修正+Error Log 留根因（跨技能引用须先判文件深度：skill 根=`../`，references/=`../../`）
- v188/v189 两计划收口均为 outcome=PARTIAL（产品面全过，流程债=历史直改委派纪律违规，如实留档不虚构派发记录）

## 5. 终验证据

- 全量回归：`run-selftests.sh --fresh` = **93 PASS / 0 FAIL**（/tmp/selftest-final2-20261026.log）
- CR：APPROVED（轻量单轮，17 项一一对应+抽查对照，2026-10-26）
- 委派 stats：rate=0.4 白名单豁免路径，violations=[]，verdict=**ok**
- 提交链：253f8a0（17 项主修复）→ CR 镜像同步提交 → 收口簿记若干（git log 可溯）
