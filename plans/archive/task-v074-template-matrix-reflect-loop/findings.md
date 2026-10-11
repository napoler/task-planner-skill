# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
- 用户 2026-09-15 三项诉求（原话等价改写）：
  1. **模板矩阵**：task-planner 提供多种计划模板，按任务类型选取适用模板
  2. **反思-验证迭代循环**：解决问题后"解决→反思→验证"循环迭代，确保质量可靠性
  3. **模板沉淀**：遇到代表性任务后，主动在技能模板目录补充该类任务模板文件，便于后期扫描复用

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| critical-rules.md Rule 31/32 | skills/task-planner/references/critical-rules.md:249-268 | ☑(Explore) | Research Findings-B2 |
| template-mapping.md | skills/task-planner/references/template-mapping.md:9-24,123-151 | ☑(Explore) | Research Findings-A2 |
| init-session.sh | skills/task-planner/scripts/init-session.sh:56-79 | ☑(Explore) | Research Findings-A3 |
| selftest-veto.sh | skills/task-planner/scripts/selftest-veto.sh(68行) | ☑(Explore) | Research Findings-D2 |
| config.json | skills/task-planner/config.json:289,429,394-419 | ☑(Explore) | Research Findings-E1 |

## Research Findings

### A. Explore 侦察报告（agent_3065ebea，2026-09-15，全量 file:line 见 knowledge-brief §2/§3）
- **A1 模板现状**：templates/ 21 文件；variant/ 已有 **12 变体**（research/diagnostic/writing/publish/code-edit/refactor/bugfix/migration/test-writing/deployment/performance-tuning/schema-migration）
- **A2 分流权威源**：template-mapping.md §一决策树:9-24、§六清单+互斥表:123-151；plan-writer.md 映射表:46-77
- **A3 语义漂移**：SKILL.md:524 称 init"自动"按 template_type 复制，实际 init-session.sh 需显式传第 2 位置参数（:56 TEMPLATE_TYPE="${2:-}"；VALID_TYPES 硬编码 :63；variant 路由 :65-79，非法回退 generic）
- **B1 规则范式**：Rule 31 :249-258（31.1触发…31.6机制）、Rule 32 :260-268（32.1登记…32.5机制）；范式=NN.M 动词短语+末条"机制"声明 config 三档键+selftest
- **B2 SKILL 联动点**：:9 索引行（"Rules 1-32"字样）、:193-194 C19/C20、:211-212 特判段、:294-295 摘要行；当前最大 Rule 32/C20 → 新增 Rule 33/34、C21/C22
- **C 空白确认**：现有"复盘"全部是错误/批量失败/成本驱动的事后触发（Rule 18.8/31.6/meta-corrector）；**"解决后主动反思-验证微循环"空白**；**"任务完成沉淀新 variant 模板"机制不存在**（grep reflect/复盘/沉淀.*模板 高置信度无正向命中）
- **D selftest**：14+ 个脚本、无聚合 runner、全量=逐个 bash；基线 **235 PASS/0 FAIL**；范式=selftest-veto.sh（ok/bad helper+VT-NN+末行 Total）；⚠️ VT-10(:13,51)/EL-11(:14,59) 锚定"Rules 1-32"字样——加规则必须同步修
- **E config**：JSON-Schema properties+additionalProperties:false(:429)；:394-419 有既有重复键脏点（不顺手修）；最新键范式=veto_enforce:289；check-complete.sh 门控插入位=LEARNING-GATE(:579-680) 之后
- **F 约定**：plans/ 入库；commit 风格 feat/chore 两笔一组；部署=smart-merge-back.sh --deploy 对账 3 实体位（~/.zcode、~/.claude、~/.config/opencode）；遗留 wt/task-v072 worktree+分支在位（已交付，禁触碰）
- **G 判定**：①模板矩阵基础已齐缺机器门控/一致性守护/env 入口 ②反思-验证微循环确认缺位→Rule 33 ③模板沉淀确认缺位→Rule 34

### B. plan-writer 产出（agent_9dc4ede4，2026-09-15）
- task_plan.md 223 行（6 Phase/5 VC/10 S-unit/FMEA 4 项含 2 项 RPN>100 兜底/主进程直做均带 25.3 白名单理由）
- knowledge-brief.md 74 行（§1-§5 齐，§2 11 条/§3 13 条真实锚点）——已 Read 核验（C5 通过）
- 关键裁定：init VALID_TYPES 与 check-template-type.sh **同源自 variant/ 目录动态派生**（消双权威源，四点同步降三点）；REFLECT-GATE 判定格式=progress.md `[reflect]` 标记行（P2 执行时写死进 33.3）
- 结构门验证：check-complete.sh 对计划跑通（唯一 exit 1=3-File Gate findings 待回填，属执行期动作）

## Technical Decisions
- Rule 33=解决→反思→验证迭代循环（33.1 触发/33.2 反思四问/33.3 独立验证/33.4 ≤3 轮边界/33.5 沉淀联动/33.6 机制 reflect_verify_enforce）
- Rule 34=模板生命周期（34.1 选取门控 check-template-type.sh/34.2 同步纪律/34.3 沉淀触发三条件/34.4 沉淀流程/34.5 防滥用/34.6 机制 template_gate_enforce）
- 模板用通用 general（v072/v073 先例；本任务自身不触发 34.3 沉淀条件）

## Issues Encountered
| Issue | Resolution |
|-------|-----------|
| （暂无） | |

## Resources
- 计划目录：plans/task-v074-template-matrix-reflect-loop/
- 哨兵/指针：已清（plan-created.cjs exit 0）；active_plan_side → 本计划
- 冲突信号：①=本计划目录（预期）；②③=遗留 v072 worktree/分支（禁触碰）

### C. P2 落地结论（2026-09-15，worktree 实测）
- **Rule 33 已落 critical-rules.md:270-280**（11 行）：33.1 触发三条件/33.2 反思四问/33.3 独立验证+`- [reflect] `逐字锚格式/33.4 ≤3 轮边界/33.5 notepad 沉淀联动/33.6 机制（reflect_verify_enforce 默认 warn）
- **REFLECT-GATE 已落 check-complete.sh:682-720**（39 行）：档位 env TASK_PLANNER_REFLECT_VERIFY_ENFORCE > config > warn；未声明 reflect_verify: required → SKIPPED；声明则校验 progress.md `- [reflect] ` 行 ≥2；enforce=exit 1/warn=告警；复刻 resolve_error_loop_tier 范式
- **config.json** reflect_verify_enforce 键 :299-304（string/enum 三档/default warn），jq 校验通过，properties 内、additionalProperties:false 未破坏
- **格式裁定**：`[reflect]` 判定锚=行首逐字前缀 `^- \[reflect] `（grep -c）；段落级定位（哪 Phase 的反思）不校验——留 Phase 4 selftest 权衡（executor risk#2 已登记）
- **派发教训**：check-dispatch.sh 守卫要求 prompt 含 findings.md/progress.md/acceptance:/checkpoint: 逐字 token——派发模板必须带三文件路径+8 字段标签

### D. P3 落地结论（2026-09-15，worktree 实测）
- **Rule 34 已落 critical-rules.md:281-290**：34.1 选取门控（白名单=variant/ 动态派生+general，禁第三硬编码副本）/34.2 三点同步纪律/34.3 沉淀触发三条件/34.4 沉淀流程（≤100 行+最小结构）/34.5 防滥用/34.6 机制（template_gate_enforce 默认 warn）
- **check-template-type.sh 37 行**：双写法提取（frontmatter `^template_type:` 与表格 `| template_type |`，取值截断全角括号注释）；exit 0/1/2；白名单 `general + ls variant/*-type.md` 动态派生
- **attest 集成**：--skip-template-check 逃生 + 档位 env TASK_PLANNER_TEMPLATE_GATE_ENFORCE > config > warn；enforce 拒绝锁定（无 .plan-attestation 生成）/warn 告警放行/off 跳过
- **设计裁定**：门控 fail-open 仅限脚本缺失场景（对齐 check-plan-dispatch 先例）；表格取值宽容截断是显式决策

### E. P4 落地结论（2026-09-15，worktree 实测）
- **init-session.sh**：TEMPLATE_TYPE="${2:-${TASK_TEMPLATE_TYPE:-}}"（位置参数优先、env 兜底）+ VALID_TYPES 动态派生（variant/ 目录 ls+general，与 check-template-type.sh 同源原则）——SKILL.md:524 "自动路由"漂移已消除实现侧根源
- **selftest 双件**：selftest-reflect-verify.sh（RV 9：条款 33.1-33.6+config 键+REFLECT-GATE 四锚）/ selftest-template-lifecycle.sh（TL 13：条款 34.1-34.6+config+三脚本门控要素+2 行为级）
- **锚点宽容化**：VT-10/EL-11 → `Rules 1-3[1-4]`（现 1-32 与 P5 后 1-34 均命中）；全库 grep 确认无其他隐含锚
- **基线增量**：断言总数 235（234P+1F）→ 257（234P+1F 基线 + 22 新断言）；T2b 1F 待 P5 上限上调后转 PASS

### F. P5 落地结论与计数更正（2026-09-15，主进程亲测）
- **SKILL.md 535 行（净 +6，纪律 ≤10 达标）**：索引 :277 与 References :325=Rules 1-34、C21/C22 :195-196、特判段 :215-216、摘要行 :299-300
- **T2b 已修复**：上限 540（label task-v074 扩充），knowledge-brief selftest 16/0
- **⚠️ 计数口径更正（Error Log#2）**：历史"全量 selftest 235/0"为子代理汇总算术错误；真实口径=逐脚本 Total 行求和。基线@7ef6214=17 脚本 265P/1F（T2b）；**当前=19 脚本 294P/0F**。子代理自报总数一律不采信，主进程亲跑求和入账

### G. 交付终态（2026-09-15）
- **COMPLETE**：merge 8c8c24a（master），簿记 ed1305e；3 实体位 IDENTICAL；Code Review Gate APPROVED；check-complete exit 0（含 REFLECT-GATE PASSED——本任务 dogfood 自家新门控闭环）
- 全量 selftest：19 脚本 **294 PASS/0 FAIL**（主进程逐 Total 行求和口径）
- 部署即时生效验证：~/.zcode 位 REFLECT-GATE 命中 5 处、rule-enhancement-type.md 在位
- 遗留（待用户授权，非本任务 scope）：INDEX v072/v073 误挂账 2 行、v072 worktree+分支清理、config.json :394-419 重复键脏点
- 会话侧修复记录：哨兵 sid 错位（init 注册 133bb≠会话 sess038d）→ 手工补 sess 前缀指针后 Write 解禁

### H. P7 遗留处置结果（2026-09-15，用户授权）
- **INDEX v072/v073 误挂账已修**：两行 pending→complete（补账标注）+ 两计划 Status 字面量 9 处 pending→complete（sed，commit a06fe1b）；根因=交付 chore 未翻自己行（复发第 2 次，v065 先例同型）
- **v072 遗留 worktree/分支已清理**：先验证 `git merge-base --is-ancestor 901b68b master`=真（内容已并入）+ worktree 无未提交变更 → `git worktree remove` + `git branch -D`（§11.3 第 5 条完成）
- **config.json 脏点已根除**：3 键（context_hygiene_enforce/plan_archive_age_days/plan_hygiene_enforce）二次定义删除，37 键唯一，jq 校验 PASS；3 实体位定向 cp 同步后 `diff -rq` 全部 diff=0
- **全量回归**：P7 改动后主进程重跑 19 脚本 **294 PASS/0 FAIL**（去重不影响断言——重复键本就 JSON 后者胜且值相同）
- **已推送**：origin/master 7ef6214→8fe649f（含 v074 全部 6 笔 feat + P7 fix + 簿记）

### I. P8 skill-fix 诊断报告（2026-09-15，全部第一手证据）

**P1-1 部署缺口**：companion/agents/plan-writer.md（v074 +2 行 rule-enhancement 契约）未同步两 agents 部署位（~/.zcode/agents、~/.claude/agents diff 实测 differ）；现行正向 SOP=lib/install-companion.sh（全量有 plan-resume 副作用，v056 实证）或定向 cp。
**P1-2 哨兵误拦根因定位**：拦截消息文本来自 zcode-pretooluse.sh:21（check-scope rc=1 的统一文案）；check-scope D10' 仲裁要求「本会话解析链命中的计划 mtime > 哨兵 created_epoch」。本会话 SessionStart 在轮次重入时重写哨兵（新 epoch），resume 判定说"哨兵不启用"但 check-scope 不认 side 指针+attestation，只认 mtime → 计划 mtime 早于新哨兵 epoch 即误拦。修法=check-scope 增加活跃计划仲裁：本会话 side 指针存在且目标计划 attestation SHA 匹配 → 放行（不弱化新会话防护：无 side 指针的新会话不走此分支）。
**P1-3 VC-GATE 形同虚设**：解析器只认 verification 风格 `- [x] V-P.N:` 行（check-complete.sh:489），而 v065 以来全部计划用 `- **V-N:** VC-x` 紧凑格式 → 恒计 0，warn 恒触发（本次 "映射 0 < 2"）。门控对现行计划格式零效力=真实缺陷。修法=计数器兼容 `**V-N:**` 行（含 VC-\d+ token 即计，映射目标校验复用 vc_defs 逻辑）。
**P1-4 LEARNING-GATE 行 46**：= progress.md 顶部模板桩占位行（`<待沉淀>`），解析器按设计报未回填；真实 P1 节的 Error Log（第二 `## Error Log` 节）反而不在扫描范围。修法=桩行如实回填（最小），解析器多节扫描 deferred。
**P1-5 文档脱节（Explore 全仓扫描）**：critical-rules.md:59,283,289 与 template-mapping.md:26 仍是"12 类/12 变体"（实际 13，含新沉淀 rule-enhancement；template-mapping :142 已登记与 :26 自相矛盾）；template-guide.md:32/36-47/59/65 缺 rule-enhancement 行且计数 12/20 过时；CHANGELOG [Unreleased] 缺 v074 条目（v071-073 均有，违仓惯例）；CLAUDE.md:32 与 README_zh.md:134,227 "Rules 1-10" 过时（实 1-34）；CLAUDE.md:70 新增模板指引漂移（init 白名单已动态派生免改脚本）；INSTALL_zh.md:277-303 安装清单大面漂移（缺 15+ 新脚本/13 变体/knowledge-brief）。
**P2 不修登记**：CR P2a attest fail-open（与 check-plan-dispatch 先例同构，约定内）；CR P2b 提取列序依赖（安全侧失败）；Batch Report 零单元必须填 8 字段（规则语义层，另行轮次）；sid 命名空间双源（env 133bb vs hook stdin sess038d）结构性统一（P1-2 修复已消其用户可见影响）；英文 README/INSTALL 悬空链接与 docs/ 指针（P3）。

### J. P8 补充证据（2026-09-15）
- check-scope.sh D10'' 仲裁已落 worktree（:125-150）：side 指针两形态+task_plan.md+`.plan-attestation` 内 `plan_sha256=` 与 sha256sum 比对，fail-closed；/tmp 沙箱 7 case（含篡改反例/新会话反例/sess 前缀/大写 hash）全 PASS（checkpoint 07-exec-p8.md）
- attestation 文件格式实读：attest-plan.sh:109 写 `plan_sha256=<hash>`（非 "SHA-256:" 前缀——修正了诊断阶段的假设）
- LEARNING-GATE 消音验证：progress.md 桩行回填后 `check-complete.sh | grep LEARNING-GATE` 无命中
- 34.2 三点同步清单遗漏 template-guide.md（本次脱节根因之一）——登记为 Rule 34.2 后续轮改进项（deferred）

### K. P8 修复结果与部署终态（2026-09-16）
- **全部落地**：check-scope D10'' attestation 仲裁（side 指针+SHA 匹配放行，fail-closed 7 case 验证）+ VC-GATE 紧凑格式兼容（T08/T09 补断言，真实计划零警告）+ 文档 13 处（变体 12→13/Rules 1-10→1-34/INSTALL 清单重生成）+ CHANGELOG v074 条目 + progress 桩行回填
- **commit**：10ba3d1（worktree）→ merge **0f85da8**（master）；3 实体位 IDENTICAL；companion 双位对账 IDENTICAL（claude 位 model→sonnet 适配）
- **全量回归**：19 脚本 **296 PASS/0 FAIL**（主进程逐 Total 求和；294+2 新断言；曾现 1 FAIL 系与滞留后台 agent 并发跑测试的 /tmp 夹具碰撞，agent 终止后复跑干净——教训：全量回归须确认无并发 selftest）
- **接管登记**：executor 首次返回截断（SendMessage 续推后仍静默，26 分钟无写入）→ 按 Rule 22.3④ 主进程接管 S2 收尾验收+S3 文档修复（10 文件 +169/-47）

### L. P9 收尾结果（2026-09-16，用户「继续」）
- **34.2 四点同步落地**：template-guide.md 纳为第 4 落点（critical-rules :286/:288、SKILL :216/:301 行内替换 535 行不变、rule-enhancement 模板 :37/:60、selftest TL-03 改四关键词+新增 TL-17）；残留 grep 零命中
- **Batch Report 零单元逃生**：check-complete.sh 批量门控支持段内「不适用（无批量生成单元）」声明跳过 8 字段（段级双关键词判定，段缺失仍 fail-closed；batch_report.md 头注+batch-quality-gate 18.6 行文档同步）
- **全量回归**：19 脚本 **297 PASS/0 FAIL**（+TL-17）；commit b8(见 log)→merge **599b675**；3 位 IDENTICAL；worktree 已清理
- 附：P8 滞留后台 agent 迟到完成报告与已交付状态一致（S1/S2/S3 自验全过，无冲突）

### M. P10 结果（2026-09-16，用户「继续」· 二）
- **sid 哨兵探测 fallback 落地**（根因收口）：env sid 无对应哨兵时取最新哨兵 sidkey（SessionStart 刚写=hook 真实 sid），init-session 指针注册与 plan-created 哨兵清除对齐 hook 命名空间；连带修正 init-session PLAN_ROOT 解析错位（`cd ..` 写到 <root>/.active_plan 而非 plans/ 下——P1-2 根因之一）；既有 env 命中路径零变化（T12b 红线验证）；多会话并发取舍已注释登记
- **fail-open 显式化**：attest 内两处 `[ -x ]` 静默分支（plan-dispatch/template-gate）各输出 SKIPPED 行，chmod -x 实测可达、行为零变化（CR P2a 收口）
- **文档清理**：README_zh 悬空链接清零+目录树补全（删仓顶不存在的 scripts/validate.sh 行）、CHANGELOG §4.5.2→§2.6 实存章节+[Unreleased] P10 条目
- **全量回归**：19 脚本 **301 PASS/0 FAIL**（297+4 新 T12 断言；executor 自报 293 再证算术误差教训）；commit 42b9ed0 前身 → merge **42b9eda**；3 位 IDENTICAL
