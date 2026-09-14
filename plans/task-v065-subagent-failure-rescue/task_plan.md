<!-- template_type: skill-fix -->
# Task Plan: task-v065-subagent-failure-rescue
<!-- skill-fix 定制型模板 — task-planner 技能审计与修复（诊断→修复→测试副本→验证→合并部署） -->

## Goal
对 task-planner 技能（源：/mnt/data/dev/task-planner-skill/skills/task-planner/**）完成深度审计与修复：(1) 强化「子代理失败后挽救」机制——失败必走检查点续跑→五档兜底串行，穷尽后才可 STOP，消除"失败即摆烂/BLOCKED 不留证据"路径；(2) 修复审计发现的其他可机械验证技能规范违规项。交付 = 修复后技能源文件（worktree 隔离开发）+ 诊断报告 + selftest 全绿 + smart-merge-back 合并 + 9 位部署 diff=0。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本时实质审查；纯 .md 改动时清单过滤后自动通过） |
| `session_id` | 133bb46c648345a49d99665093e36080 |
| `worktree_path` | /home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue |
| `scope_files` | [skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, skills/task-planner/templates/*, skills/task-planner/scripts/*(按诊断清单), skills/task-planner/tests/*(按需)] |
| `interaction_mode` | `silent` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 审计 Gate：前置 Read 门完成（S59） | 目标 skill 全部相关文件（SKILL.md + references/ + config.json + scripts/ 清单）已由审计子代理 Read 且主进程抽查复核 | 工具调用记录 + 诊断报告 |
| VC-2 | 审计 Gate：引用路径存在性验证（S64） | bun 可用时跑 path_existence_validator.ts --scope all；bun 缺失则 grep 替代并登记 | validator 输出 JSON |
| VC-3 | 审计 Gate：迁移性检查（S75 三维度）+ 并行安全扫描（S76 四维度） | 扫描命令输出入诊断报告 §S75/§S76 | 诊断报告 |
| VC-4 | 修复 Gate：修复授权已获 | 用户原话"还有其他的不符合技能规范的，也需要纠正"= 显式授权（Decisions Made 登记） | 对话记录 |
| VC-5 | 失败挽救机制已强化（用户核心诉求） | Rule 22 相关条款中"失败→挽救→穷尽兜底→才 STOP"链路可 grep 验证；反摆烂条款落地 | 修改后文件 grep 证据 |
| VC-6 | 规范违规项已修复 | 诊断报告 P0/P1 清单逐项有 before/after 证据 | 修复 diff |
| VC-7 | selftest 全绿 | skills/task-planner/tests/ 下 selftest 套件 exit 0（全量基线 113/0 不回退） | 测试输出 |
| VC-8 | 合并回 + 部署完成 | smart-merge-back.sh 成功 + --deploy 后 9 位部署 diff=0 | 智能门输出 |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 目标 skill | skills/task-planner/**（经 worktree） | 其他 skill 文件 |
| 诊断报告 | plans/task-v065-subagent-failure-rescue/diagnostic-report.md | 根目录临时文件 |
| 测试副本 | skill-fix tmp/ test-backup（仅不确定修改） | 真实文件直接改（未过 S66 前） |
| 计划文件 | plans/task-v065-subagent-failure-rescue/* | 其他 plan 目录 |
| 部署 | ~/.zcode/skills/task-planner/（仅合并后 deploy 步骤） | 执行期触碰部署副本 |

**执行前自我检查**：该文件在上表内？该修改对任务必要？用户授权范围内？任一不过 → STOP。

## 🔀 隔离决策
- check-conflicts.sh 结果：仅信号①（plans/ 计划系统文件未提交变更：.active_plan 指针更新 + 会话哨兵 + v059 .session-owner 遗留 + 本计划目录）；无 wt 遗留分支 / 无运行中基础设施冲突
- **决策：worktree 隔离**（实现类任务默认首选；修改 skills/task-planner/** 命中 §十一 P0 保护区）。路径 = /home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue，分支 = wt/task-v065-subagent-failure-rescue。计划文档留在主仓 plans/。
- 基线备注：部署副本 sync-todos.sh 与仓库存在 1 文件差异（合并后统一重部署消除）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位（路径/URL/版本） | 必读级别 | 已确认 |
|------|-----------|----------------------|---------|--------|
| 项目内部文档 | 目标 skill 全文（SKILL.md + references/ + config.json + scripts 清单） | /mnt/data/dev/task-planner-skill/skills/task-planner/ | 必读 | ☐ |
| 规范/标准 | skill-fix 56 标准 + S54/59/61/64/65/66/74/75/76 | ~/.zcode/skills/skill-fix/SKILL.md | 必读 | ☐ |
| 审计基线 | 既往遗留问题（v062/v063 deferred + deferred-issues.log） | plans/task-v053-skillfix-deploy/deferred-issues.log + 各 plan 遗留段 | 参考 | ☐ |
| 用户诉求锚点 | 子代理失败挽救（非摆烂） | 本计划 Goal(1) + 用户原话 | 必读 | ☐ |

**填写规则**：① 定位必须可唯一定位；② 必读项缺失 → STOP 记入 Errors，禁止凭记忆硬写。

## S57 复杂度自评表（D1-D5 权重表 — 原样复刻）

| 维度 | 指标 | 权重 |
|------|------|------|
| D1 Phase 数量 | ≤1 / 2-3 / ≥4 | ×2 |
| D2 Agent() 调用数 | 0 / 1 / ≥2 | ×2 |
| D3 步骤数（SKILL.md 中 -[] 条目） | ≤2 / 3-5 / ≥6 | ×1 |
| D4 跨 skill 依赖 | 0 / 1-2 / ≥3 | ×1 |
| D5 文件修改范围 | 单文件 / ≤3 / ≥4 | ×1 |

- **总分**: 12（D1=4分×2 D2=2×2 D3=2 D4=1 D5=1）
- **复杂度等级**: 复杂(9+)
- **已用模板**: skill-fix 定制模板 plan-skill-fix-type.md（复杂级 + 技能审计/修复类强制）
- **自身任务复杂度**: 同上（skill-fix S57 2.5 扩展口径：本任务即 skill-fix 自身执行任务）

## Phases

### Phase 1: 诊断前置 Read 门 + 机械扫描（S59 / S64 / S75 / S76）
- [ ] 委派审计子代理（串行）Read 目标 skill 全部相关文件（S59 门控），重点审「子代理失败处理链路」（Rule 22.3/22.5/22.7/22.8 + critical-rules + completion-gate + hook 脚本）与 56 标准违规
- [ ] S64 路径存在性验证（bun 可用性先查，S74）
- [ ] S75 三维度 + S76 四维度机械扫描
- [ ] 主进程 Read 诊断报告 + 抽查关键文件段复核（不信自报）
- [ ] 必要知识储备必读项全部确认
- **Status:** complete（2026-09-13，审计报告 552 行+主进程 5 处复核通过）
- **V-N:** VC-1, VC-2, VC-3（S59 Read 门/路径验证/迁移扫描）
- **Executor:** general-purpose（sonnet-1，审计）

| ID | 目标(≤1 句) | 执行体 | 验收 |
|----|-------------|--------|------|
| S1 | 全量审计+机械扫描出诊断报告 | general-purpose（sonnet-1） | diagnostic-report.md 含 F/V 编号+file:line |

### Phase 2: 诊断报告定稿 + 修复计划 + 授权 Gate（silent 自主处置）
- [x] 56 标准逐项审计结论整合 → diagnostic-report.md（每项含 evidence：path/size/mtime/sha256/file:line）
- [x] 根因分析 + 修复清单（P0→P1→P2 排序）；范围外发现 → deferred-issues.log
- [x] **授权 Gate**：用户指令已显式授权（VC-4）；silent 模式自主处置并登记 Decisions（D6 硬停点除外）
- [x] **门控**：诊断报告无 evidence → 回退重跑
- **Status:** complete（2026-09-13，清单定稿+范围决策+授权登记）
- **V-N:** VC-4, VC-6（授权登记/清单定稿）
- **Executor:** 主进程（计划系统文件维护 + 诊断整合，白名单②）

### Phase 3: P0 修复 — 子代理失败挽救机制强化（用户核心诉求）
- [x] worktree 内实施：失败→挽救链路（检查点续跑前置 → 五档兜底串行穷尽 → 才可 STOP；STOP 报告必须含已尝试挽救清单）
- [x] Handoff 登记表增挽救状态口径；反摆烂反模式条款补全
- [x] Rule 22.7 连续失败语义校准（≥2 次失败 = 强制换档挽救而非直接 STOP；穷尽五档仍失败才 STOP）
- [x] 不确定修改先测试副本验证（S66）
- **Status:** complete（2026-09-13，F-1..F-9 全修，3 commit，selftest 48 用例全绿）
- **V-N:** VC-5, VC-6（挽救机制落地/违规修复）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 验收 |
|----|-------------|--------|------|
| S1 | F-2 门控判定键+F-1 挽救链机械门 | executor（sonnet-1） | selftest 19 用例绿+commit |
| S2 | F-3/F-4/F-5/F-8/F-9 条款 | executor（sonnet-1） | grep 复核+commit |
| S3 | F-6/F-7 fallback 衔接 | executor（sonnet-1） | selftest-fallback 绿+commit |

### Phase 4: P1/P2 修复 — 规范违规项
- [x] P1 修复项实施（按 Phase 2 清单）
- [x] P2 修复项实施
- [x] 完整性反思 Q1-Q9 + Standard 54 Loop 决策记录
- **Status:** complete（2026-09-13，V-1..V-18 全修 6 commit，新增 selftest 62 用例全绿）
- **V-N:** VC-6, VC-7（违规修复/selftest 回归）
- **Executor:** code-assistant / executor（按清单规模）

| ID | 目标(≤1 句) | 执行体 | 验收 |
|----|-------------|--------|------|
| S1 | V-1/V-2/V-10/15/17/18 微改批 | executor（sonnet-1） | 5 项 grep 验证+commit |
| S2 | V-4/V-5/V-6/V-7/V-8 脚本批 | executor（sonnet-1） | selftest-active-plan 绿+commit |
| S3 | V-9 VC/V-N 门控 | executor（sonnet-1） | selftest-vc-gate 绿+commit |
| S4 | V-12/V-11②③ 迁移性 | executor（sonnet-1） | grep 验证+commit |
| S5 | V-13/V-14 锁与登记 | executor（sonnet-1） | selftest-delegation 绿+commit |
| S6 | V-12 遗留+锁名统一+枚举 | executor（sonnet-1） | selftest 双绿+commit |

### Phase 5: 验证 — selftest 全量 + 56 标准复验
- [x] selftest 套件全量跑（基线 113/0 不回退；新增挽救链路用例如需补测则补）
- [x] 逐条复验 56 标准 + VC-5/VC-6 grep 证据
- [x] 测试副本清理（S66）
- **Status:** complete（2026-09-14 簿记补正:本 Phase 实际已于 v065 交付时完成,状态行滞留 pending 致 INDEX 4/6 误挂账,现翻正）
- **V-N:** VC-6, VC-7（复验/selftest 全绿）
- **Executor:** code-runner-agent（mini）+ 主进程复核

| ID | 目标(≤1 句) | 执行体 | 验收 |
|----|-------------|--------|------|
| S1 | 全量 selftest 回归 | code-runner-agent（mini） | 总表 FAIL=0 |

### Phase 6: 合并回 + 部署 + 交付（S58）
- [x] worktree 全 VC 复验且 git 干净 → smart-merge-back.sh [--deploy]
- [x] worktree/分支清理 + 主仓 Read 关键文件复验
- [x] 9 位部署 diff=0 对账 + Standard 58 中文总结 + W1-W5 核查 → 交付结论
- **Status:** complete（2026-09-14 簿记补正:同上,merge edb8f0b 已在册,outcome COMPLETE）
- **V-N:** VC-7, VC-8（回归不破/合并部署）
- **Executor:** 主进程（git/worktree 编排，白名单①）

## 📦 Batch Report（批量质量门控 — 批量 N>1 时必填）
| 字段 | 值 |
|------|-----|
| total | n/a（单 skill 任务） |

## 📝 Standard 58 中文总结占位（交付前必填）
- **已完成**: 诊断(F-1..F-9+V-1..V-18 27 项)→修复(11 S-unit 串行 9 commit)→验证(selftest 159/159+Code Review APPROVED)→合并部署(edb8f0b)
- **产出**: worktree 9 commits→master edb8f0b；check-rescue-chain.sh/selftest-rescue-chain/selftest-vc-gate 新建；diagnostic-report.md 552 行；verification.md 终验记录
- **遗留**: D-1..D-11（deferred-issues.log，含 V-11① companion UUID 安装期注入、INDEX 历史缺口、VC-GATE 内联拆分）
- **下一步建议**: ① 后续轮处理 deferred D-6/D-7/D-9 ② 观察期后评估 rescue_chain_enforce/vc_gate_enforce 升 enforce ③ push master 至 origin

## Current Phase
交付完成（6/6 complete，outcome COMPLETE）

## Next Step
派发 executor 串行 S-unit S-1(脚本门控 F-2/F-1) → S-2(条款) → S-3(fallback)
创建 worktree → 委派审计子代理执行 Phase 1（S59 Read 门 + 机械扫描）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: interaction_mode=silent | 用户当前指令"对当前技能进行深度优化……也需要纠正"= 显式修复授权；autonomous 环境等待确认将阻塞；计划全文落盘可查 + 交付报告附静默决策清单 |
| silent: 目标技能=task-planner | CWD=task-planner-skill 仓库 + 诉求直指子代理派发协议 + hook 哨兵上下文 |
| silent: 新任务而非 session-catchup 恢复 | 全新用户指令；v064 已交付 COMPLETE；跳过 session-catchup（记忆：可能挂起陷阱） |
| 部署基线 | 仓库与部署副本仅 sync-todos.sh 1 文件差异，合并后 --deploy 统一 |
| silent: 修复范围=F-1..F-9 全量+V-1..V-18(用户授权①②);D-1..D-6 范围外 → deferred-issues.log | 用户原话"深度优化...也需要纠正"显式授权;V-11① UUID 占位化破坏本机运行时故 deferred(D-6) |
| 观察项:plan-created 清哨兵校验到 task-3file-enforce 非 v065;sync-todos 未收录 v065;attest 判 legacy 跳过派发门控 | 三者为脚本解析与计划格式兼容性线索,记入 Phase 1 审计输入,不阻塞 |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
|       |         |            |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | checkpoint 路径 |
|---|------|--------------|---------|------|---------|------|----------------|
|   |      |              |         |      |         |      |                |
| 001 | 2026-09-13 | general-purpose | Phase1 技能深度审计(失败挽救链路+规范违规) | done | F-1..F-9+V-1..V-18, P0×8; 92/100 | diagnostic-report.md 552行 | 01-general-purpose.md |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |
