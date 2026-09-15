# Task Plan: task-v074 — 模板矩阵机器门控 + 解决→反思→验证循环 + 模板沉淀入库

## Goal
在 task-planner 仓落地 Rule 33（解决→反思→验证迭代循环）与 Rule 34（模板选取门控+沉淀入库）及配套脚本/配置/init 改进，全量 selftest 回归 0 FAIL 后合并回 master 并部署 3 实体位。

## 任务参数
| 字段 | 值 |
|------|-----|
| task-id | `task-v074-template-matrix-reflect-loop` |
| template_type | general（沿用 v072/v073 先例，实现类技能维护走通用模板） |
| reflect_verify | required（Rule 33 自示范——本任务自身走反思-验证循环，REFLECT-GATE 终验勾稽） |
| 交互模式 | ask（默认，Rule 28） |
| git_commit | 逐 Phase 提交（Rule 27） |
| 仓 canonical | skills/task-planner/（master @ 7ef6214） |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（bash 脚本 + critical-rules 联动改动） |
| `interaction_mode` | `ask` |
| `session_id` | 启动时生成 |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/v074 |
| `scope_files` | `skills/task-planner/{SKILL.md, config.json, references/critical-rules.md, references/template-mapping.md, scripts/init-session.sh, scripts/attest-plan.sh, scripts/check-complete.sh, scripts/check-template-type.sh(新), scripts/selftest-reflect-verify.sh(新), scripts/selftest-template-lifecycle.sh(新), templates/variant/(沉淀触发时新建), companion/agents/plan-writer.md}` |
| 非 scope 说明 | plans/ 三文件（INDEX.md/findings 等簿记）不入 scope，按仓库惯例在收尾提交登记 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 33 条款完整落地：critical-rules.md 含 33.1-33.6（触发/反思四问/独立验证/迭代边界≤3轮/沉淀联动/机制）、config.json 含 `reflect_verify_enforce` 键（默认 warn）、check-complete.sh 含 REFLECT-GATE 段（校验 frontmatter `reflect_verify: required` 的任务 progress.md 存在反思记录行，三档 warn 语义） | Read critical-rules.md Rule 33 节 + `grep -c "reflect_verify_enforce" config.json` + `grep -n "REFLECT-GATE" scripts/check-complete.sh` | critical-rules.md Rule 33 / config.json / check-complete.sh |
| VC-2 | Rule 34 条款完整落地：34.1-34.6（选取门控/四点同步/沉淀触发/沉淀流程/防滥用/机制）、config.json 含 `template_gate_enforce` 键、scripts/check-template-type.sh 新建且 attest-plan.sh 集成后非法/缺失 template_type 拒绝锁定（--skip 逃生保留） | Read Rule 34 节 + `bash scripts/check-template-type.sh <plan> && <bad-plan>` 实测拒绝 + `grep -n check-template-type scripts/attest-plan.sh` | critical-rules.md Rule 34 / check-template-type.sh / attest-plan.sh |
| VC-3 | init-session.sh 支持 `TASK_TEMPLATE_TYPE` 环境变量（兜位置参数，消 SKILL.md:524 语义漂移）且 VALID_TYPES 改为从 templates/variant/ 目录动态派生：新增 variant 文件即自动合法 | `touch templates/variant/scratch-test-type.md && bash scripts/init-session.sh proj scratch-test` 输出合法路由；移除后回落 generic | scripts/init-session.sh 实测输出 |
| VC-4 | selftest 双件 PASS + 全量回归 0 FAIL：selftest-reflect-verify.sh、selftest-template-lifecycle.sh 各自 PASS；含 VT-10/EL-11 修复后全量 `for f in scripts/selftest-*.sh; do bash $f; done` 记录 N PASS / 0 FAIL（基线 235，新增后 N 增大） | 逐个 bash 跑完统计 Total 行 | progress.md Selftest Log + 双件脚本末行 Total |
| VC-5 | 3 实体位部署 diff=0 且簿记完成：smart-merge-back.sh --deploy 对账 ~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner diff 为空；plans/INDEX.md 登记 v074 + .zcode/ledger/task-planner-maintenance/task-planner-maintenance.jsonl 追加 done 条目；worktree 清理（remove + branch -d） | `bash scripts/smart-merge-back.sh <wt> --deploy` 对账输出 + Read INDEX/ledger + `git worktree list` | 部署输出 / INDEX.md / ledger / worktree list |

**终验规则**：全部 VC 通过 → COMPLETE；有已知遗留 → PARTIAL；≥1 VC 失败且 3 次重试无效 → BLOCKED。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则/文档 | skills/task-planner/references/critical-rules.md, references/template-mapping.md, SKILL.md（≤500 行净增纪律，当前 529 行——只做行位替换，禁止净增超预算）, companion/agents/plan-writer.md | 其他 references/* / 其他 agent 文件 |
| 脚本 | scripts/init-session.sh, scripts/attest-plan.sh, scripts/check-complete.sh, scripts/check-template-type.sh(新), scripts/selftest-reflect-verify.sh(新), scripts/selftest-template-lifecycle.sh(新), selftest-veto.sh/selftest-error-loop.sh（仅 VT-10/EL-11 锚点修复） | 其他 scripts/* |
| 配置 | skills/task-planner/config.json（新增 2 键；:394-419 既有重复键脏点不顺手修，避免扩大 diff） | 其他配置 |
| 模板 | templates/variant/（仅 34.3 沉淀触发命中时新建，防 34.5 滥用约束生效） | 既有 12 变体内容改动 |

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | critical-rules.md Rule 31/32 范式（NN.M 动词短语 + 末条机制三档键+selftest） | references/critical-rules.md:249-268 | 必读 | ☑ |
| 项目内部文档/知识库 | 本任务 knowledge-brief（§2 已验证事实 + §3 文件锚点） | plans/task-v074-template-matrix-reflect-loop/knowledge-brief.md | 必读 | ☑ |
| 官方文档 | selftest 写法先例（ok/bad helper，末行 Total） | scripts/selftest-veto.sh（68 行） | 必读 | ☑ |

## ⚠️ 核心问题定义
**核心问题**：模板矩阵缺机器门控、问题解决后无反思验证闭环、模板沉淀无入库通道——三项任一缺位则"质量可靠且可复用"不成立，能交付。
- [x] 核心问题解决后，结果能交付吗？是（3 实体位部署 + selftest 0 FAIL = 可交付）
- [x] 核心问题不解决，其他工作都白费吗？是（P2-P5 全部条款依赖 P1 worktree 基线）
- [x] 解决方法清晰可执行？是（Phase 骨架 + S-unit + 材料包齐备）

## Current Phase
Phase 6

## Next Step
P6：主进程执行合并回（smart-merge-back --deploy 3 实体位）+ worktree 清理 + INDEX/ledger 簿记 + 终验交付。

## Phases

### Phase 1: 隔离与基线
- [x] 建 worktree /mnt/data/dev/task-planner-skill-worktrees/v074（branch wt/task-v074，自 master 7ef6214）；**勿动**遗留 wt/task-v072 worktree 与分支（冲突信号②③）（2026-09-15 实建，git worktree list 复验）
- [x] 全量 selftest 逐个 bash 跑完，记录基线 PASS 数入 progress.md（实际 **234 PASS/1 FAIL**：T2b SKILL.md 529>523 既有欠账，非本任务引入；归因与处置见 progress.md Error Log + P5 新增项）
- [x] 确认 config.json 三档键插入位（veto_enforce :289 之后）与 check-complete.sh REFLECT-GATE 插入点（LEARNING-GATE 段 ~:680 之后）——worktree 内 grep 复验
- **V-N:** VC-1, VC-4（基线是回归对比前提）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git/worktree 编排属 Rule 25.3 白名单）+ code-runner-agent（mini）跑 selftest 全量

### Phase 2: Rule 33 落地（解决→反思→验证迭代循环）
- [x] critical-rules.md 追加 Rule 33（33.1-33.6 全文 :270-280，主进程 Read 逐字验收）
- [x] config.json 新增 `reflect_verify_enforce` 键（:299-304，jq 校验通过）
- [x] check-complete.sh LEARNING-GATE 段后追加 REFLECT-GATE（:682-720，四分支功能实跑+bash -n 通过）
- **V-N:** VC-1, VC-4
- **Status:** complete（commit d25494c）
- **Executor:** executor（sonnet-1）

<!-- S-unit 派发单元表（Rule 22.6；材料包摘要锚点见 knowledge-brief §5） -->
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 写 Rule 33 全文 | 继承 | critical-rules.md:249-268（Rule 31/32 范式锚）+ brief §1/§4 | 33.1-33.6 六小节齐 + 末条含机制三档键 | ≤15min | pending |
| S2 | config 键 + REFLECT-GATE | 继承 | config.json:289（veto_enforce 键范式）+ check-complete.sh:575-585（LEARNING-GATE 段头）+ brief §2 事实 | `jq .config reflect_verify_enforce` 有效；REFLECT-GATE 段存在且 warn 语义 | ≤15min | pending |

### Phase 3: Rule 34 落地（模板选取门控 + 沉淀入库）
- [x] critical-rules.md 追加 Rule 34（34.1-34.6 全文 :281-290，主进程 Read 验收）
- [x] config.json 新增 `template_gate_enforce` 键（:305-311，jq 校验通过）
- [x] 新建 scripts/check-template-type.sh（37 行，白名单动态派生+general，双写法兼容，三 case 实测过）
- [x] attest-plan.sh 集成：LOCK 前调用门控，enforce 拒绝/warn 告警/off 跳过实测过，--skip-template-check 逃生
- **V-N:** VC-2, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 写 Rule 34 全文 | 继承 | critical-rules.md:249-268（31.6/32.5 机制小节范式）+ template-mapping.md:9-24（决策树现状）+ brief §2 | 34.1-34.6 齐，34.5 含"已有类型禁重复/≤100 行" | ≤15min | pending |
| S2 | config 键 + check-template-type.sh 新建 | 继承 | config.json:289 + init-session.sh:63（VALID_TYPES 现状硬编码，门控白名单源）+ brief §3 | 脚本存在且对 12 变体+缺失+非法 3 case 行为正确 | ≤15min | pending |
| S3 | attest-plan.sh 集成门控 | 继承 | attest-plan.sh:56-73（LOCK 主流程段）+ S2 产出脚本 | 非法 template_type 计划 LOCK 被拒；--skip 可逃 | ≤15min | pending |

### Phase 4: init-session.sh 改进 + selftest 双件 + VT-10/EL-11 修复
- [x] init-session.sh：TASK_TEMPLATE_TYPE 环境变量兜位置参数（:61）+ VALID_TYPES 改为 variant/ 目录动态派生+general（:55-80，三 case 实测过）
- [x] 新建 scripts/selftest-reflect-verify.sh（57 行，RV 9 断言，FAIL=0 主进程复跑）
- [x] 新建 scripts/selftest-template-lifecycle.sh（70 行，TL 13 断言含 2 行为级，FAIL=0 主进程复跑）
- [x] 修复 selftest-veto.sh VT-10 与 selftest-error-loop.sh EL-11 锚点→宽容正则 `Rules 1-3[1-4]`（全库 grep 扫描无其他隐含锚；双 selftest 复跑 PASS）
- **V-N:** VC-3, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | init-session.sh env+动态白名单 | 继承 | init-session.sh:56-79（TEMPLATE_TYPE/VALID_TYPES/路由段）+ brief §2 漂移事实 | `TASK_TEMPLATE_TYPE=x bash init-session.sh proj` 生效；新建 variant 文件自动合法 | ≤15min | pending |
| S2 | 双件 selftest 新建 | 继承 | selftest-veto.sh 全文（ok/bad helper + VT-NN + 末行 Total 范式）+ P2/P3 产出条款锚 | 两脚本 bash 直跑 PASS，各自末行 Total=ok 数 | ≤15min | pending |
| S3 | VT-10/EL-11 锚点修复 | 继承 | selftest-veto.sh:13,51 + selftest-error-loop.sh:14,59 | 两断言改 1-34 后 `bash selftest-veto.sh && bash selftest-error-loop.sh` PASS | ≤15min | pending |

### Phase 5: SKILL.md 联动 + 文档同步 + 全量回归
- [x] SKILL.md 联动：索引 :277 与 References :325 改 Rules 1-34；C21/C22 :195-196；特判段 :215-216；摘要行 :299-300；**净增 6 行（529→535，纪律达标，wc -l 复核）**
- [x] **（P1 基线新增）** T2b 上限 523→540 + label「task-v074 扩充」（selftest-knowledge-brief.sh :36-38；修复后 16/0）
- [x] template-mapping.md :25-26 与 plan-writer.md :64-65 门控契约同步（三点同步之二三）
- [x] 双 selftest 补 SKILL 断言（RV 12/TL 16）
- [x] 全量 selftest 回归：**19 脚本 294 PASS/0 FAIL**（主进程亲跑逐 Total 行求和定数；历史 235/0 口径误计已更正，见 progress.md Error Log#2）
- **V-N:** VC-1, VC-2, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | SKILL.md 4 处联动 | 继承 | SKILL.md:9, 193-194, 211-212, 294-295（锚点行）+ 约束"净增≤0 行预算" | 4 处改毕 + `wc -l SKILL.md` 增量在预算内 | ≤15min | pending |
| S2 | mapping + plan-writer 同步 | 继承 | template-mapping.md:9-24,123-151 + companion/agents/plan-writer.md:46-77 | 决策树/清单/映射表含 Rule 33/34 引用 | ≤15min | pending |
| S3 | 全量 selftest 回归 | 继承 | 无（跑 `for f in scripts/selftest-*.sh`） | 记录 Total N PASS / 0 FAIL；FAIL>0 记 blockers 交主进程 | ≤15min | pending |

### Phase 6: 合并回 + 部署 + 簿记
- [x] 前置自检：worktree 内全 Phase complete + `git status` 干净 + 主仓无重叠未提交变更（11.3 三问全过；worktree 目录经 `git worktree move` 规范化为 §11.2 标准路径 task-v074 后过 V1 双校验）
- [x] `bash scripts/smart-merge-back.sh <wt> --deploy`：V1-V5 全 OK + 合并 commit **8c8c24a** + 3 实体位（~/.zcode、~/.claude、~/.config/opencode）部署后 diff=0（IDENTICAL×3）
- [x] 清理 worktree + `git branch -d wt/task-v074`（was 92f933c）；v072 遗留未触碰
- [x] **Rule 34.3 沉淀触发判定命中①（技能规则增强类第 3 次：v071-v073+v074 同套路）→ 按 34.4 沉淀 `templates/variant/rule-enhancement-type.md`（73 行）+ template-mapping/plan-writer 两点登记 + 门控实测 OK + 守护 selftest 16/0（commit 92f933c）**
- [ ] plans/INDEX.md 登记 v074 + ledger 追加 done 条目（chore(task-v074): 交付簿记 提交）——执行中
- **V-N:** VC-5（+ 全部 VC 终验）
- **Status:** complete（合并部署已完成，簿记进行中）
- **Executor:** 主进程（例外理由:① git 编排/合并 + ② 簿记——Rule 25.3 白名单①②）

### Phase 8: skill-fix 可用性审计与错误修正（B 类扩展 — 用户指令 2026-09-15「/skill-fix 优化修正 当前修改后技能的可用性以及错误进行修正」）
- [x] 阶段 1 诊断（findings §I：P1×5=部署缺口/哨兵误拦根因/VC-GATE 零计数/文档脱节 13 处/模板桩行；P2 不修登记×5 含理由）
- [x] 阶段 2 诊断报告+修复计划已呈现（silent 授权沿用本计划既有登记；Standard 54 决策=不引入 Loop）
- [ ] 阶段 3 修复实施：worktree task-v074-p8fix（check-scope D10 attestation 仲裁/VC-GATE **V-N:** 兼容/文档 13 处/CHANGELOG 条目）
- [ ] 阶段 4 验证（全量 selftest 逐 Total 求和 0 FAIL+#2/#3 行为级实测）+ companion 定向 cp + 部署 3 位 diff=0 + 推送
- **V-N:** VC-4, VC-5（P8 验收：诊断 P1 全部修复或登记）
- **Status:** in_progress
- **Executor:** 主进程（诊断定向核查+白名单①编排+部署）+ executor（worktree 内修复派发）+ Explore（联动扫描，已完成）

## 🔀 隔离决策（冲突分析）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`——信号②：遗留 wt/task-v072 worktree（已交付）与遗留分支在位，本任务**禁止清理**；信号③：遗留分支不触碰 |
| `isolation` | `worktree` |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v074（初建名 v074，合并前经 git worktree move 规范化为 §11.2 标准路径；已清理） |
| `branch` | `wt/task-v074`（已删） |
| `merge_back` | merged(8c8c24a) |

> 宪法 §十一：本任务改 skills/task-planner/**（§六 保护区 + 运行中基础设施），强制 worktree；操作 SOP 见 references/worktree-isolation.md。

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（对齐 22.3） |
|-------|---------|---|---|---|-----|--------------------------|
| P4/P5 | selftest 锚定级联：改"Rules 1-32"字样漏某断言→全量 FAIL 连锁（VT/EL 之外或有隐含锚） | 6 | 4 | 5 | 120 | 22.3②拆细：FAIL 时 grep -rn "Rules 1-3" scripts/ 全库扫锚点一次性修齐，不逐个试错 |
| P3/P4 | 双权威源漂移：init VALID_TYPES 动态化后 check-template-type.sh 仍硬编码白名单→门控与 init 判定不一致 | 7 | 4 | 5 | 140 | 22.3①改派：check-template-type.sh 白名单同源自 variant/ 目录动态派生（单一事实源），S2 验收加"两脚本对新建变体判定一致"断言 |
| P5 | SKILL.md 529 行基线叠加追加超净增纪律→check-doc-sync/行数门禁 FAIL | 5 | 3 | 4 | 60 | 追加段落先 wc -l 测算，超预算时改行位替换（索引行/摘要行压缩既有措辞） |
| P2-P5 | executor 子代理对三档键范式误写（additionalProperties:false 下挂错层级） | 4 | 3 | 5 | 60 | 材料包锚定 veto_enforce:289 原文段；验收列加 `jq` 语法校验 |

## 🔁 原生 Todo 同步
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 开工时建 Todo |
| Phase 2 | ☐ |  | |
| Phase 3 | ☐ |  | |
| Phase 4 | ☐ |  | |
| Phase 5 | ☐ |  | |
| Phase 6 | ☐ |  | 收尾清理 |

## Key Questions
1. REFLECT-GATE 的"反思记录行"判定格式（progress.md 何种标记行才算存在）——P2 S2 执行时定死并在 33.3 写清格式，selftest 锚断言。
2. check-template-type.sh 白名单源：动态派生 variant/ 目录 vs 硬编码——裁定=动态（FMEA 双权威源行），34.2 四点同步随之降为三点半（init 侧免同步）。
3. 本任务自身是否示范 33 循环——是：每 Phase complete 前走 33.2 四问 + 33.3 独立验证，progress.md 记反思行（自评证据，写入 progress 非 scope）。
4. 新 SKILL 摘要行措辞是否影响 VT 其他断言——P4 S3 grep 全 selftest 库 "Rules 1-3" 再改。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 模板用通用 general（不新建 variant） | v072/v073 先例：技能自身维护任务走通用模板；且 34.3 沉淀触发条件本任务不命中 |
| silent: **（P6 修订）34.3 沉淀判定翻案**：本任务实为「技能规则增强」类第 3 次（v072/v073/v074 同套路），命中触发①，且 general 模板对新规则类任务无特化 VC——按 34.4 沉淀 rule-enhancement-type.md（73 行）并三点登记 | Rule 34 是本任务交付物，终验时按其触发条件自检即 dogfood；沉淀动作门控实测 OK+守护 selftest 16/0 |
| Rule 33/34 结构与范式对齐 31/32（NN.M 动词短语 + 末条机制三档键+selftest） | 既有范式可 selftest 静态守护，检查清单续 C21/C22 |
| init-session.sh 白名单改动态派生 | 沉淀新类型免改脚本，四点同步降为三点，消除双权威源 |
| config.json 新增 2 键挂在 properties + additionalProperties:false 保持 | :429 契约；:394-419 脏点不在本任务修（最小 diff） |
| 共享追踪（Rule 30）不适用 | 目标资源为本仓技能文件，单任务独占改造，无跨任务并行认领的共享资源（登记理由，不建账本） |
| C20 禁令检查 | 已查 memory + notepad 被否决方案段 = 空，无禁令命中 |
| silent: D1 未获用户应答，按 best judgment 继续 | 用户原始指令即明确要求执行本优化；AskUserQuestion 未应答≠拒绝；按 Rule 28 silent 语义锁定计划直接执行，交付报告附静默决策清单供复核（2026-09-15） |
| silent: 本计划后续 D2-D6 询问点按 silent 自主处置 | 推荐项自主推进并逐条登记本表 silent: 行；D6 硬停点（连续失败 STOP/漂移 BLOCKED/Q3 证据不实/破坏性操作）除外，两模式一致不可豁免 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| T2b 基线 FAIL（SKILL.md 529>523）+ 全量计数口径误计 | 1 | 均已解决：T2b 上限上调 540（P5 commit 3f519ff）；计数以逐脚本 Total 行求和为准（294/0）——详见 progress.md Error Log#1/#2 | 行数上限随联动轮次同步上调；总数禁采信子代理自报 |

## Notes
- 三文件分流：状态进本 plan、结论进 findings/progress/notepad（执行期），plan-writer 只写 task_plan + knowledge-brief。
- commit 风格：`feat(task-planner): task-v074 — Rule 33/34 + 门控 + selftest 双件; 全量 N/0` + `chore(task-v074): 交付簿记`。
- 禁在本任务触碰 wt/task-v072 worktree/分支与 plans/ 簿记文件。

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 计划创建 | C20 禁令检查=空；方向与 ④ 骨架一致 | - | 通过 |

## 📦 Batch Report
| 字段 | 值 |
|------|-----|
| total | 0（本任务无批量生成单元；全量 selftest 回归是验证动作非批量操作） |
| success | 0 |
| failed | 0 |
| failure_rate | 0% |
| sampled_pass | N/A（零单元不抽样） |
| sampled_fail | N/A（零单元不抽样） |
| pre_check | Rule 18 前置 3 问：①无批量写入操作 ②单元数 0（<10 免门控） ③无质量/速度权衡场景——判不适用 |
| rollback_point | master@7ef6214（合并前基线；如需回滚 `git revert 8c8c24a`） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 6（P2-P4 executor，P5 executor 共 4 派发型实为 P2/P3/P4/P5=4/6） |
| 主进程直做 Phase 清单 | P1（白名单①git 编排）、P6（白名单①②合并+簿记） |
| 委派率 | 4/6 ≈ 0.67；低于 0.7 floor 因 P1/P6 命中 25.3 白名单①②，按规则记录不判 PARTIAL |

## 🔗 Subagent Handoff 登记表（Rule 22.5）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 1 | 09-15 | code-runner-agent(mini) | P1 全量 selftest 基线 | complete | 17 脚本 234P/1F；FAIL=T2b SKILL.md 529>523（既有欠账，主进程重跑取证澄清，子代理误报 T10b 已纠）；无超时 | scripts/selftest-knowledge-brief.sh:38 + subagent-state/02-runner-baseline.md | Research Findings-C 基线段 | subagent-state/02-runner-baseline.md | - | 0 | ☑ |
| 2 | 09-15 | executor | P2 S1+S2 | complete | Rule 33 :270-280+config 键:299-304+REFLECT-GATE:682-720；四分支实跑+jq+bash -n 全过；+57/-0；首派被 dispatch 守卫拦（缺契约 token）补齐重发 | critical-rules.md:270 + check-complete.sh:682 + subagent-state/03-exec-p2.md | Research Findings-C 段 | subagent-state/03-exec-p2.md | - | 1 | ☑ |
| 3 | 09-15 | executor | P3 S1-S3 | complete | Rule 34 :281-290+template_gate_enforce:305-311+check-template-type.sh 新建 37 行+attest 集成:68-105；三 case+两档行为实测全过；+93/-1 | critical-rules.md:281 + check-template-type.sh + subagent-state/04-exec-p3.md | Research Findings-D 段 | subagent-state/04-exec-p3.md | - | 0 | ☑ |
| 4 | 09-15 | executor | P4 S1-S3 | complete | init env+动态白名单:55-80+双件 selftest（RV9/TL13）+VT-10/EL-11 宽容锚；4 selftest 主进程复跑全 FAIL=0；5 文件 | init-session.sh:55 + subagent-state/05-exec-p4.md | Research Findings-E 段 | subagent-state/05-exec-p4.md | - | 0 | ☑ |
| 5 | 09-15 | executor | P5 S1-S3 | complete | SKILL 净+6 行 6 处联动+mapping/plan-writer 同步+T2b 540+RV12/TL16；全量 19 脚本主进程亲跑 294P/0F（历史 235 口径误计已更正 Error Log#2） | SKILL.md:195,215,277 + subagent-state/06-exec-p5.md | Research Findings-F 段 | subagent-state/06-exec-p5.md | - | 0 | ☑ |
| 6 | 09-15 | Code Reviewer | Code Review Gate（code_review: required） | complete | **APPROVED**：P2×2 记录性发现（attest fail-open 与先例同构/提取口径差无影响），无 P0/P1；REFLECT-GATE 与 LEARNING-GATE 范式同构实证 | git diff 7ef6214..8c8c24a -- scripts/*.sh + 返回报告 | findings 终验段 | -（审查报告在会话+本行摘要） | - | 0 | ☑ |

## Chain 区块
单 skill 任务，chain_mode=single，无交接。
