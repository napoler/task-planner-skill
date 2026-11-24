# 项目深度巡检 + 全技能审核 总报告

- **任务**：`task-project-audit-20261123`
- **巡检日期**：2026-11-23
- **仓库**：`/mnt/data/dev/task-planner-skill`
- **用户原始指令（逐字）**：「开始对整个项目进行深度巡检，分析到底哪里出了问题。尤其你可以使用Scaler Fix进行嗯对所有的技能进行审核，哪里不合理给出建议。」
- **结论标记**：**COMPLETE**（两项目标均完成；全程只读诊断，未修改任何技能/配置/计划/保护区文件）

---

## 0. 方法与范围

- **"Scaler Fix" 解读**：本机无 `scaler/scaler-fix` 工具，唯一匹配为 `skill-fix` 技能（`~/.zcode/skills/skill-fix/SKILL.md`），其自带批量审核 SOP（Step0–1.13 + G1–G28 门控 + `subagent_skill_auditor.ts`）。按此执行。
- **审核范围裁定**：仓库 `skills/` 下 **32 个正式 SKILL.md**（21 顶层 + 11 个 `task-planner/review-library` 子技能），排除 288 个 `.backup` 副本、32 个 worktree 镜像、5 个归档副本。（探索阶段曾报 31，系漏算 `ui-quality-review`，已由 `find` 实测修正。）
- **执行方式**：Phase 1 三个只读诊断子代理 + Phase 2 三个审核子代理 + 1 次 drift-checker 偏移检查（判定 ALIGNED）。所有结论带可复现命令/文件行号，检查点见 `forensics/`。
- **口径瑕疵标注**：质量层子报告标题写"31 个正式技能"，但其清单为 21+11=32 且逐项评级覆盖 32 项，属子代理算术笔误；本报告一律以实测 **32** 为准。

---

## 1. 项目级诊断：「到底哪里出了问题」

### 1.1 git 健康 —— 1 个 P1，其余为在途/封存（P2，禁止清理）
| 项 | 现象 | 证据 | 判定 |
|---|---|---|---|
| 分支分叉 | `master=e3206b3` 领先 `origin/master` 40 提交未推送；`main=origin/main=15a3ecf`；`merge-base master main` rc=1（**无共同祖先**） | `git branch -a -vv`；`git rev-list --left-right --count origin/master...master`=`0 40` | **P1**：双主线无共同祖先 + 40 提交悬置 |
| worktree | 仅 1 个有效注册 `tmp/worktrees/wt-tplsys-upgrade-20261117`（在途） | `git worktree list --porcelain` | P2 在途，非孤儿 |
| wt/* 分支 | 2 个：`wt/tplsys-upgrade-20261117`（在途）、`wt/task-v168-machine-parked`（10-11 封存） | `git for-each-ref refs/heads/wt` | P2，非垃圾 |
| stash | 1 条（2026-10-07，3 文件 WIP） | `git stash list` | P2，未确认勿动 |
| 工作区脏 | 26 条：1 条本任务新增 + 25 条他会话在途（`task-cli-help-examples-20261122` 等） | `git status --short` | P2，非本任务产生，禁止清理 |

> **建议（仅文字，未执行）**：P1 分支问题需用户裁决 master/main 的合并策略（本仓已知无共同祖先，禁盲目 merge）；其余在途工作保持原状。证据：`forensics/git-health.md`

### 1.2 计划体系执行层漂移 —— 核心命题「部分成立」
- **积压**：40 计划 = 16 complete / 23 pending / 1 in_progress；pending 中 **0/0 且无 goal 的空壳 10 个，空壳率 43.48%**。（`plans/INDEX.md`）
- **JSON/MD 背离**：plan-state.json 覆盖仅 **7/44 = 15.91%**；典型 `task-jsonderive-deploy-20261122` 的 `plan-state.json` 342B 且业务字段全空，而 `task_plan.md` 48253B——执行层 SOFT_ONLY 实证。
- **引导层已纠偏**：hook/模板/SKILL 现均指导"planctl 写 JSON → render"，未见"直接 Edit MD"指引（`zcode-posttooluse.sh:267-269,296-330` 等）。但 `attest-plan.sh:82-102` 对空壳仅 WARN 不阻断。
- **结论**：历史记忆所述"planctl 替换 markdown 未起效"在**引导层已修复、执行层仍残留**——残留集中于存量任务的 JSON 空壳与机器门软判定。
> **建议**：对 23 个 pending 空壳做一次归档/补齐裁决；将 attest 空壳从 WARN 升为阻断需单独授权（涉及 hook，保护区）。证据：`forensics/plan-drift.md`

### 1.3 部署一致性 —— 2 个 P1 漂移（只报告不改）
- 21 技能 × 2 部署位（SKILL.md + scripts）比对：**漂移 2**
  - `progress-tracker`：zcode 位多 `scripts/ledger-append.sh`（仓库/agents 无）
  - `task-planner`：agents 位 `SKILL.md` 缺 §4.6 弃旧开新 / Rule 27（diff 11 行）
- 其余 19 技能两部署位均 IDENTICAL，无 MISSING。
- **口径说明**：Phase 2b 的 S79 仅比 SKILL.md，故只报 1 个漂移（task-planner）；Phase 1c 含 scripts，报 2 个。两者不矛盾，按比对维度区分。
> **建议**：将 §4.6 同步到 agents 位、确认 ledger-append.sh 去留——属保护区写操作，需单独授权。证据：`forensics/deploy-selftest.md`

### 1.4 selftest 真实基线 —— 96 PASS / 8 FAIL（实跑，非采信文本口径）
- 命令：`bash skills/task-planner/scripts/run-selftests.sh --fresh`，UTC 2026-11-22T16:05:52Z，**Total 104 / PASS 96 / FAIL 8**。
- FAIL 8 个脚本（初判真实断言失败，非环境缺失）：
  | 脚本 | 失败点 | 性质 |
  |---|---|---|
  | selftest-active-plan | T14 汇总 1 FAIL（具体断言待定位） | 需定位 |
  | selftest-batch-pilot | BP-08 SKILL.md 440 行 > 311 门槛 | 文档行数门槛/基线漂移 |
  | selftest-enumerate-first | EN-06 缺 `1-108`/`,107` 路由 | 规则编号/路由文本不匹配 |
  | selftest-execution-stability | T11b 重锁 owner 行为不符预期 | hook 自愈行为偏差 |
  | selftest-registry | 孤儿行 + registry 105 vs 实际 104 | registry 漂移 |
  | selftest-rule-reserve-pairing | PR-02 悬空编号 110 | 规则编号配对 |
  | selftest-self-resolution | SR-12 registry 漂移 | registry 漂移 |
  | selftest-summary-readability | SRV-11/12 registry 登记 + 9 级联脚本 | registry + 级联传播 |
- **根因归纳**：8 个 FAIL 中 **5 个与 registry/编号/行数门槛漂移直接相关**——反映"规则与文档持续扩张、机器断言基线未同步"的系统性欠账。
> **建议**：以一次"基线重锁"任务统一刷新 registry 与编号断言（涉及 selftest 脚本，需单独授权）。证据：`forensics/deploy-selftest.md`

---

## 2. 全技能审核（skill-fix SOP，32 技能）

### 2.1 frontmatter 机械层（R1–R5）
- **32 文件：ERROR 21 / WARN 41 / 通过 0**；R2/R3/R5 无违规。
- **R1 ERROR 21**：21 个顶层技能缺 `model`/`tools` 字段——但**多为 `allowed-tools` 惯例**（如 `media-planner` 用 `allowed-tools`，`task-planner` 用 `allowed-tools` 无 `tools`）。这是 frontmatter-linter 的 agent 向契约与 skill 实际惯例的结构性不匹配，**需甄别是否真缺陷**，不宜直接批量补齐。
- **R4 WARN 41**：正文提及工具但 frontmatter 未用 `tools` 声明。
- 11 个 review-library 子技能按 stub 契约降级为 WARN（仅 name/description），非缺陷。
> **建议**：先裁决 skill frontmatter 是否强制 `tools` 字段（影响 21 文件），再决定是否批量修正。证据：`forensics/skill-audit-frontmatter.md`

### 2.2 调用方式层（S39/S39a）—— PASS
- `bun subagent_skill_auditor.ts` 扫 **3259 文件、0 违规**；grep 命中 `WebSearch(`/`Skill(`/`mcp__` 等经逐条复核均非 SUB-AGENT 指令。**无 P0 越权调用**。证据：`forensics/skill-audit-calls-redundancy.md`

### 2.3 冗余/漂移层（S79）—— WARN
- 部署漂移 1（task-planner agents 位，见 1.3）；双树同名：11 个 review-library × 24 个 `.backup` 副本（220 diff / 44 same），仅登记不建议合并；`.backup/**/SKILL.md` 288 份。
> **建议**：备份体量大，建议另行评估归档策略（不在这次改）。证据：`forensics/skill-audit-calls-redundancy.md`

### 2.4 质量层（S78/S82/S83/S85/S86 + G1–G28）—— FAIL 0 / P0 0 / P1 5
| 技能 | 严重度 | 关键问题（证据） | 建议 |
|---|---|---|---|
| `task-planner` | P1 | 440 行超载混合路由/规则/SOP；163 scripts 中 133 未直接索引（`SKILL.md:196-433`） | 拆分或建脚本索引表；降 description 漂移风险 |
| `task-dispatch` | P1 | 规则索引称 12 条但正文 15 条含 Rule 96/103/104 未入表（`SKILL.md:59`） | 对齐索引表与正文规则数 |
| `todo-skill` | P1 | Step 5b 缺每步完成判据；"重试一次仍失败则跳过并标记 completed"掩盖未完成（`SKILL.md:105-109`） | 改为 blocked + 留痕，而非 completed（与证据铁律张力） |
| `task-discipline` | P1 | `references/execution-recall-card.md` 未被 SKILL 索引却被 `critical-rules-discipline.md:604` 引用 | 补索引，统一引用面 |
| `plan-resume` | P1 | 规则守卫全，但缺"执行后证据字段"最小格式示例 | 补 S82 证据模板 |
- 11 个 review-library 子技能全部 PASS（结构完整、二值结论、证据要求齐）。
- **共性问题**：① 路由/知识型卫星 S82 验收点偏弱；② S85/S86 资产发现性不一致（存在脚本/模板未被 SKILL 引用）；③ 大文档历史注记引发漂移；④ 完成态缺"无证据不得 completed"硬门。
> 证据：`forensics/skill-audit-quality.md`

---

## 3. 根因分析（系统性，非孤立缺陷）

1. **规则/文档扩张快于机器基线**：编号编到 110、SKILL.md 440 行，但 registry 与行数/编号断言未同步 → selftest 8 FAIL 中 5 个同源。这是当前最活跃的技术债。
2. **部署传播链不完整**：改仓库源未全量同步到 agents/zcode 位（task-planner §4.6、progress-tracker 脚本），历史反复出现。
3. **计划体系执行层未闭环**：引导层（hook/模板）已改对，但存量任务 JSON 空壳率高（43.48% pending 空壳、15.91% JSON 覆盖），且 attest 软判定。
4. **完成态防作弊不足**：todo-skill 失败仍标 completed、attest 空壳不阻断——与全局证据铁律存在张力。
5. **git 双主线无共同祖先**：master/main 分叉 + 40 提交悬置，历史长期未裁决。

---

## 4. 分级建议清单（仅文字，本次全部未执行）

| 级别 | 建议 | 涉及范围 | 授权需求 |
|---|---|---|---|
| **P0** | 无 | — | — |
| **P1** | 统一基线重锁：刷新 registry/编号/行数断言，修复 8 个 selftest FAIL | selftest 脚本（仓内） | 需单独任务授权 |
| **P1** | 裁决 master/main 合并策略（无共同祖先，禁盲 merge） | git 历史 | 需用户裁决 |
| **P1** | 同步 task-planner §4.6 到 agents 位、确认 ledger-append.sh 去留 | 全局保护区 | 需用户明确授权 |
| **P1** | todo-skill 失败态改 blocked + 留痕，补每步完成判据 | skills/（仓内） | 需单独任务授权 |
| **P1** | task-planner 脚本索引表 / task-dispatch 规则表对齐 / task-discipline 引用面 / plan-resume 证据模板 | skills/（仓内） | 需单独任务授权 |
| **P1** | 裁决 skill frontmatter 是否强制 `tools` 字段（影响 21 文件） | skills/（仓内） | 需用户裁决方向 |
| **P2** | 23 个 pending 空壳归档/补齐；.backup 288 份归档策略评估 | plans/ | 需单独授权 |
| **P2** | 保持所有在途 worktree/分支/stash 原状，勿清理 | git 状态 | 无需动作 |

---

## 5. 收尾总结（skill-fix S58）

- **已完成**：Phase 0 意图切换登记（挂起旧计划、init 新计划、指针切换）；Phase 1 项目级四维诊断；Phase 2 全技能四层审核；drift-checker 偏移检查（ALIGNED）。
- **产出**：`forensics/` 下 7 份检查点（git-health / plan-drift / deploy-selftest / drift-check-p1 / skill-audit-frontmatter / skill-audit-calls-redundancy / skill-audit-quality）+ 本报告。
- **遗留**：所有 P1/P2 修复均**未执行**（本次定位为纯诊断，且多处触及保护区）；frontmatter R1 的 21 ERROR 需先裁决契约方向再动。
- **下一步**：按第 4 节建议清单，用户裁决后开独立任务逐项修复；优先"基线重锁"与"git 主线裁决"两个 P1。
- **结论**：**COMPLETE**（诊断与审核目标达成；修复类为后续独立任务，不在本次范围）。

> 合规声明：本次全程只读；未修改任何技能、脚本、hook、配置、`~/.zcode`/`~/.agents` 保护区文件；未做 git 写操作；未清理任何在途工作。唯一写入为新任务目录内的计划数据与本报告。
