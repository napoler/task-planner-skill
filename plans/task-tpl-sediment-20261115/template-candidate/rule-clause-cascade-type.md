<!-- template_type: rule-clause-cascade -->
# 规则/条款级联修订（本仓项目适配）

**template_type**: rule-clause-cascade
**适用**: task-planner-skill 源仓内规则增款、条款修订、纪律域级联同步（高频：Rule 编号增补/子条插段/卫星路由与计数联动）。

## Goal
- [ ] 在受管范围内完成目标规则/条款修订，并完成级联面同步、验证与证据回填（单一可追溯判例锚）。

## VC 表（≥2）
| VC-ID | 验收项 | Verify command | 证据落点 |
|------:|--------|----------------|----------|
| VC-1 | 目标条款/锚点落位且无吞锚（新串在位、相邻锚行仍在） | `grep -nF "<RuleID-or-anchor>" skills/task-planner/references/critical-rules.md skills/task-planner/SKILL.md` | findings/progress 对应证据行 |
| VC-2 | 级联计数串/索引/路由面同步（纪元、卫星数、索引枚举、README/ARCH 计数按需同改） | `grep -nE "纪元|卫星|其余 [0-9]+ 条|Rule <N>" skills/task-planner/SKILL.md skills/task-planner/README.md skills/task-planner/docs/ARCHITECTURE.md` + 人工核对 diff | diff 摘要/回读记录 |
| VC-3 | 既有门禁/自测无回归（按改动面最小子集） | `for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f"; done`（等价聚合口径；针对性跑单个 selftest-*.sh） | 终验日志片段 |

## Phase 骨架
### Phase 1：取证与插段设计
- 盘点落位与级联面清单（条款正文、SKILL 索引/路由表/纪元计数、critical-rules 索引、install-stub `SATELLITE_SKILLS`、skills/task-planner/README.md、skills/task-planner/docs/ARCHITECTURE.md、selftest 锚与计数窗如 DQ-08、模板/计数硬断言）；确认编号账本/预留态。
- 插段前逐文件 `grep` 段清单与锚行子串；`new_string` 必含锚行子串；Edit 后强制结构回读（防吞锚，判例 106.1a/5f8d119）。

### Phase 2：落位、级联与本地化验证
- 按清单实施最小增量修订；同步所有计数串与枚举面（禁漏改纪元/“N 卫星”/“其余 M 条”等，判例 2eded71）。
- 判例锚用机制名/稳定标识，禁硬编码行号锚（判例 b3e671f）；落位文内指针用机制名避免悬空（机制：落位指针机制名锚定，禁任务本地编号引用）。
- 跑 VC 命令与针对性 selftest；失败先修因再复验，记录证据。

### Phase 3：收尾与回填
- 回填 findings/progress/verification；若涉计划模板/变体计数，同步对应硬断言与文档；三部署位按需对账（若本次要求部署）。
- 主进程/收尾回读确认无残留占位与未同步计数串。

## 执行范围限制
- **受管面**：`skills/**`（含 `task-planner/SKILL.md`、`references/critical-rules.md`、`scripts/selftest-*`、`lib/install-stub.sh` 等）、`plans/**`；按需同步三部署位 `~/.zcode/skills/task-planner`、`~/.claude/skills/task-planner`、`~/.config/opencode/skills/task-planner`（及本任务明确授权的卫星位）。
- **禁止**：未授权改 `~/.zcode/AGENTS.md` 等保护区；未要求不得新增脚本/hook/机器门；不改与本任务无关的在途 worktree/计划。
- **纪律**：写前 Read 目标；展示后执行；改后 Read 回读；最小化 diff。

## 必要知识储备
- `skills/task-planner/SKILL.md`（卫星路由表、纪元/索引计数面）、`skills/task-planner/references/critical-rules.md`（规则正文与路由索引）、`skills/task-planner/scripts/selftest-registry.tsv` 与相关 selftest（锚/计数窗）。
- `skills/task-planner/lib/install-stub.sh`（`SATELLITE_SKILLS`）、`skills/task-planner/README.md`、`skills/task-planner/docs/ARCHITECTURE.md`（卫星表与计数串）。
- `plans/.rule-reservations.jsonl` 与编号账本现状；Rule 106.1a 插段纪律、Rule 71 无源不写；历史坑：吞锚(5f8d119)、计数窗漏改(2eded71)、硬编码行号锚(b3e671f)、悬空指针（落位指针机制名锚定）、init/render 签名误用（init-session.sh 调用签名契约）。
