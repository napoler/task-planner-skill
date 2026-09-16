# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1（用户原话 2026-09-16）：单个子代理处理负载过重、小步快跑原则贯彻不足 → 往更细粒度强制方向优化（小任务更好执行与验证）
- R2：优化 methodology（方法论）的使用
- R3：完成后部署到平台（3 实体位：~/.zcode、~/.claude、~/.config/opencode）+ 提交 GitHub（push origin master）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| Explore 调研报告 agent_9b61fc75 | 本会话子代理(2026-09-16) | ✅ | Research Findings 全节 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### A：S-unit 粒度强制现状（Explore 2026-09-16，锚点均相对技能根）
- 21.1b 步级上限 ≤2 文件/≤100 行/≤15min 在 critical-rules.md:114，但 `step_max_files/lines/minutes`、`prompt_max_chars`、`max_per_phase` 在 scripts/ 下 **grep 零命中**——纯 prose，机器零校验
- `check-plan-dispatch.sh:109-124`（attest 时）只查 3 项：S-unit 表头存在、≥1 行 `S<n>`、执行体列非空；**不查任何规模数字**；legacy 计划无 Executor 行整体 fail-open(:37-40)
- `check-dispatch.sh:48`（Agent PreToolUse）只查 7 项文本存在性（三文件路径+status/acceptance/checkpoint 字段+subagent-state）；**不查 prompt 长度**（prompt_max_chars=3000 无 wc 检查）、**不检测单 prompt 打包多 S-unit**；解析兜底未命中降级 warn 放行(:167-179)
- 22.3② 拆细只在**首败后**被动触发（critical-rules.md:117/124），事前无门
- 模板侧：`templates/task_plan.md:182` 规模上限写在 HTML 注释；`templates/variant/rule-enhancement-type.md` Phase 2/3 无 7 列 S-unit 表示范（模板自身示范不严格）
- **结论（可机器化堵截缺口，按影响力）**：①attest 时逐行校验 S-unit 时长/输入文件数 ②check-dispatch 补 prompt 长度+多 S-unit 打包检测 ③Phase 级总量机械化 ④拆细前移到计划期（=①的 attest 拒绝）⑤模板补规模列/示范

### B：methodology 消费现状
- `references/methodology.md`（176 行）：R1 前置条件(:17-35)/R2 FMEA RPN(:37-51)/R3 幂等+checkpoint(:53-67)/R4 小批量+5Whys(:69-88)；Q1 证据(:94-102)/Q2 事实核查(:104-112)/Q3 去AI化(:114-132)/Q4 五维评分≥4.0(:134-153)/Q5 契约复用(:155-163)
- `fmea_enforce`/`content_quality_enforce`（config.json:81,89）+ `knowledge_brief_enforce`(:109) **无任何运行时脚本读取**——仅 selftest-methodology.sh:49-58 防篡改守护 + config 描述自认"enforce 档语义预留（后续轮）"；attest-plan.sh 实际只有 check-plan-dispatch + check-template-type 两道门
- `check-complete.sh` grep FMEA/methodology **零命中**——终验不查方法论任何项
- FMEA 段仅 templates/task_plan.md:229 有；selftest 只查标题存在性，不查 RPN 是否真填/高 RPN 有无兜底
- knowledge-brief 派发引用无机器校验（config.json:109 自认"流程层执行无 hook 校验"）
- v063 遗留（plans/task-v063-methodology-intro/verification.md:102-106）：①verify.sh §9 循环未含 selftest-methodology ②methodology 两处出处不可核 ③SKILL.md 锚点差 1 行 ④plan-resume@.zcode 缺位（后者 v062 已挂账不重复）

### Technical Decisions（方案取舍论证）
| Decision | Rationale |
|----------|-----------|
| 本轮选 A-attest 数值门控 + A-dispatch 长度/打包检测 + B-FMEA 消费兑现 + B-v063 遗留清理，缓做 B-R1 前置门机制化/B-R3 checkpoint.jsonl/B-Phase 总量机械化 | 遵守小步快跑（本任务自身也要细粒度）：每项独立可测、单 Phase ≤3 文件；缓做项登记 deferred 供下轮 |
| A-attest 数值门控默认硬拒绝（沿用 check-plan-dispatch 现有失败=拒绝锁定义务，逃生=--skip-dispatch-check+SKIPPED 行显式化） | attest 属计划期，改计划成本低；v074 P10 已立 fail-open 显式化先例；无新 config 键（step_max_* 三键首次被消费） |
| A-dispatch 三项增量（prompt 长度/多 S-unit 打包/brief 引用提示）挂 dispatch_contract_enforce 分档，默认 warn 行为不变 | 派发期硬阻断有打断在途任务风险；先 warn 计数留观察数据，档位已存在可随时升 enforce |
| B-FMEA 消费=attest+check-complete 双点、按 fmea_enforce warn/enforce/off 分化 | 兑现 config.json:89"预留"语义；warn 默认不破坏存量计划；off 完全跳过 |
| P2 落地裁定（KQ1 定死）：路径 token=后缀锚定 `[^ ]+\.(sh\|md\|json\|ts\|js\|py\|cjs)`；计数用 `grep -oE\|wc -l`（grep -c 与 -o 同用按行计恒 1） | grep -o 下前缀形态 `(^|[[:space:]])` 会把前导空白/分号并进 token 致计数漂移；口径已写入 check-plan-dispatch.sh 头注释——P3 的 S-unit ID 打包检测若做 token 计数应复用同范式 |
| P3 实测：config.json `dispatch_contract_enforce.default`=enforce（非 plan 决策行原表述 warn）；三项增量部署后即硬阻断 | jq 直读实证；warn 档行为另测无回归；部署后派发实践须 ≤3000 字符+逐 S-unit（正是用户诉求的强制力）；多 S-unit 计数会把说明性文本中的 S1/S2 也计入（FMEA P3 行预设，warn 观察数据 P9 审） |
| P4 落地：fmea 档位链 env TASK_PLANNER_FMEA_ENFORCE > config fmea_enforce > warn；数据行识别=行首 `\|` 且第 6 数据列纯数字（7 列契约依赖，加列会误判——risk 已登记）；check-complete 终验点无逃生口（设计：终验不可跳过，临时降级用 env=warn） | 三档×双点矩阵实测全过；legacy 计划（无 Executor 行）fail-open 对齐 :37-40 先例 |
| P11 用户裁决（09-17）：数值门控硬拒锁→提示不阻断 | 根因=「小任务更好执行与验证」的目标由执行模型自己判断复杂度实现，attest 硬拒锁过严（用户 40min/4 路径场景即被拒）；执行体空/S-unit 表缺失仍拒（Rule 22.6 完整性义务保留）；提示行 SKIPPED 措辞=fail-open 显式化先例延续 |
| P5 落地：verify.sh §9 循环=唯一 selftest 遍历处（语义名义 delegation 三件套，实为全量落点）——追加 selftest-methodology.sh 后全量 26 pass/0 fail；methodology.md 两处不可核出处已泛化+文末登记（不瞎编） | 主进程 verify.sh 复跑实证；M-03 关键词断言不受影响（11/0） |
| P6/P7 落地：模板/条款同步全部行内扩写（SKILL 535 行不变，T2b ≤540 未触）；SKILL 标注 V5 字面（「机器校验已生效」）首版 3 处缺关键词，SendMessage 补丁修复=3 处齐 | 锚定级联 grep "Rules 1-" scripts/ 仅 3 个宽容锚（RV-10/EL-11/VT-10），行内标注零连锁 |
| P8 落地：CHANGELOG [Unreleased] 5 条（P2-P7 逐一对应 commit c506349/6c51c24/fdff22b/685b206/5d215b6+9f75354，selftest 总数留待 P9 实跑回填）；README 3 处增补（脚本树职责句×3+fmea_enforce 键「已兑现」+$schema 段运行时消费键清单） | 主进程 grep 计数 CHANGELOG=5/README=2；新增行无悬空链接；数字全取自主进程复跑记录非子代理自报 |

### P8 交付文档要点（2026-09-16）
- CHANGELOG 条目措辞红线：不写具体 selftest 总数（P9 才定数），只写「只增不减」——防文档数字与实跑漂移
- README $schema 段新增「运行时消费的键」清单句：fmea_enforce（已兑现）+ dispatch_contract_enforce 三项 + step_max_*/prompt_max_chars 四键首次消费——这是本轮「零新 config 键、兑现预留语义」的对外口径

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| （无） | — |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 关键文件：scripts/check-plan-dispatch.sh / scripts/check-dispatch.sh / scripts/attest-plan.sh / scripts/check-complete.sh / scripts/verify.sh（全量 selftest 入口）/ config.json:339-397（step_max_* 键定义区）
- 先例计划：plans/task-v056-fine-grained-dispatch-plan/（21.1b/22.3/22.4/22.6 首落地）、plans/task-v063-methodology-intro/（methodology 首引入）
- P1 基线定数（2026-09-16，主仓 master=3e9a451 亲跑）：19 脚本全 rc=0，逐 Total FAIL=0，PASS 合计 **301**（/tmp/v075-baseline.txt 留档）——P9 回归对比基准
- P1 锚点复验（worktree 内 grep 实证）：check-plan-dispatch.sh S-unit 循环 :109-124；check-dispatch.sh get_mode :91-105（jq 读 dispatch_contract_enforce）+scan_missing :42；check-complete.sh :451-452（plan-dispatch 终验接入点）；lib/verify.sh §9 循环 :227（`for _script in check-delegation.sh allow-direct.sh selftest-delegation.sh`）；attest-plan.sh resolve_template_tier :77-100（fmea 档位挂载范式）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-（无）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
