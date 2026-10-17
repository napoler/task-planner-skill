# Findings & Decisions

## Requirements
- R1-R7 逐字锚=task_plan.md「🎯 用户需求原文」+user-session-log.md #1（禁转译，Rule 51.1）
- 诉求本质：制度层诉求（Rule 31.8 层级）——交付物=技能规则文本条款，非修具体 bug 现场

## 📚 必要知识储备对齐记录
| 知识源 | 定位 | 已消费 | 结论落点 |
|--------|------|--------|---------|
| critical-rules-discipline.md（Rule 88-90 落位范式） | skills/task-discipline/references/critical-rules-discipline.md:479-576 | ☑ | §Rule 92 草稿（范式复制） |
| task-planner SKILL.md 级联面 | skills/task-planner/SKILL.md:9,17,166,179,221 | ☑ | §级联面清单 |
| 编号台账 | rule-reserve.sh next/check 实跑 | ☑ | §编号考证 |
| 用户宪法 §九 尺寸口径 | ~/.zcode/AGENTS.md §九 | ☑ | §Rule 92 草稿 92.2 |

## Research Findings

### S1 执行回执（2026-10-17 15:10，executor 子代理，verify_done 已复核）
- Rule 92 全文逐字落位 worktree `skills/task-discipline/references/critical-rules-discipline.md`：576→588 行（+12）；grep 标题=1、92.1-92.7=7、尾部 diff 草稿 rc=0（逐字节一致）。
- 子代理自曝并修复一次追加残留尾行（truncate -s -1），最终结构=90.6 行+空行+Rule 92 至末尾，接缝符合段间单空行惯例。
- 证据：主进程 Read 577-588 行亲验一致；检查点 subagent-state/2-s1-executor.md（status done，5/5 PASS）。
- 成本注记：本 S-unit 子代理消耗 ~1.08M tokens（12 行转写任务，委派纪律的实测成本样本）。

### S2 执行回执（15:28，executor，verify_done 已复核）
- 7 处编辑全部落位（task-discipline/SKILL.md×3、task-planner/SKILL.md×4）；子代理上报 VC-3 判据校准问题（:221 字面「核心域 1-92」无 Rules 前缀）且未猜测性补改——处置=主进程修正 VC-3 命令为 `(Rules )?1-92`（Decisions #2 纠正登记）。
- 主进程 8 项 grep 亲验全过（(Rules )?1-92=3、1-91=0、89,90,92）=2/1、90/92 纪律域=1、索引行=1、关键词=1）。检查点 2-s2-executor.md。

### S3 执行回执（15:25，executor，verify_done 已复核）
- 核心 critical-rules.md :182 清单 +92（1 处）；README.md Rules 1-91→1-92（3 处）；4 项 grep 全过+主进程亲验（1/3/0）。检查点 2-s3-executor.md。

### Drift check #1 回执（15:32，drift-checker）
- 判定 **ALIGNED**：diff 5 文件全在射程（CA-1..CA-5），既有规则正文零改动，R1-R7 语义全承载（92.1 尽量避免/92.3 按引用拆/92.4 其他文件/92.5 垂直化/建制段负担/92.6 例外）。风险登记：Current Phase 指针滞后（本批翻转已修）。检查点 2-drift-checker.md。
- Phase 2 V-N 证据：VC-1（1/7）✓；VC-2（优先拆分 3/引用 4/垂直 6/92.4=1）✓；VC-3（worktree 8 grep）✓；worktree 产物 commit 282fd42。

### CR Gate 回执（Code Reviewer 单轮，VERDICT: APPROVED，15:58 前后）
- 5 维度全过：正确性（R1-R7 全承载/无冲突）、级联完备性（9 编辑点一致、1-91 零残留）、风格（与 88-90 范式对齐、与 Rule 91 无冲突）、范围纪律（严格 5 文件、既有正文零改）、回归面（WF-10 实跑 PASS）。报告=subagent-state/5-code-reviewer.md。
- **登记项（不阻断，待用户裁决）**：
  - 🟡 WF-10 锚族滞后：`selftest-workflow-orchestration.sh:79` grep 族 `1-(68|69|71|75|91)` 未纳入 92；本 diff 使技能文件对 WF-10 贡献 7→1（cnt 10→4，仍过 ≥3 线）。按 CA-6 口径（仅断裂锚修）不属断裂——登记待后续任务/用户裁决补 92 进族（两处 grep+注释一行）。memory「纪元锚每纪元必炸」形态的下一处候选。
  - 🟡 discipline/SKILL.md 计数行滞后：加 92 后 :70/:81 的「41/42 条」真值为 42/43——既有漂移 D-A 延续，真值在此登记不改文件。
  - 💬 92.7 未写裁决日期字样（与 90.6 一致；判例锚内含 2026-10-17 日期），可选补强不改。

### Verifier 独立复验回执（S5，ALL PASS 6/6）
- 主仓 master 终态逐条实跑：VC-1（1/7）✓；VC-2（3/4/6/1）✓；VC-3（3、0+0、2/1/1）✓；VC-4（S4 检查点 91/91+两 selftest 抽查 rc=0）✓；VC-5（check 92=landed by task-v185-file-split-discipline）✓；VC-6（skills/ 零未提交+worktree=0+merge 73ce9ec 在 log）✓。
- 检查点=subagent-state/5-s5-verifier.md；验证独立性满足（Rule 33.3，全新子代理实跑）。

### Alignment-review 回执（CHANGES_REQUESTED → 修正 → RE-VERDICT APPROVED）
- 首轮 4/5 PASS+P1×1：92.6 引「Rule 87.4③ 同面语义」错位（③=匹配项目既有风格，与「禁顺手拆」不同面；正确同面=87.4② 不重构没有坏掉的模块，:534 实存核验）。
- 修正=fix commit 39bf476（单行）；复验=RE-VERDICT APPROVED（引用面匹配+无新引入问题，残留冲突=0）。检查点=5-alignment-review.md。
- 教训：新规则文本的「衔接条款引用号」必须逐一对照被引条款原文，不能凭印象写编号——本次凭印象写 ③ 被独立审查抓出。

### 收口段 drift check 回执（#2，ALIGNED）
- skills/ diff 16951ff..39bf476 恰 5 文件=scope 全量；39bf476 可追溯 align 发现（射程内自纠）；R1-R7 承载无退损。检查点=5-drift-checker-final.md。
### 编号考证（2026-10-17 实跑）
- `rule-reserve.sh next` = **92**；`check 92`=free、`check 93`=free。
- Rule 91 已被占用：`skills/plan-collab-router/references/critical-rules-collab.md:50`（workflow per-subagent 模型分档纪律）。
- 全集索引现状：`Rules 1-91 全集索引` 字面 ×3（task-planner SKILL.md :9/:179/:221）+ README.md :36/:81/:123；task-discipline 清单（…,89,90）×3（task-discipline/SKILL.md:24、task-planner/SKILL.md:17 与 :166、核心 critical-rules.md:182——其中 SKILL.md 两处为同一清单字面）。

### 级联面清单（编辑点全集，CA-2..CA-5 对应）
1. `skills/task-discipline/references/critical-rules-discipline.md` 末尾追加 Rule 92 全文（唯一实质新增）
2. `skills/task-discipline/SKILL.md`：:24 规则清单 +92；:26 调用条件 +关键词「产出文件尺寸/拆分」；:28 规则索引表 +行 `| 92 | 产出文件尺寸纪律与优先拆分 | 同上 |`
3. `skills/task-planner/SKILL.md`：:9 frontmatter 1-91→1-92；:17 卫星 references 清单 +92；:166 卫星路由表 discipline 行 +92；:179 全集口径 1-91→1-92（「其余 73 条」措辞不动，见漂移登记）；:221 References 表 1-91→1-92
4. `skills/task-planner/references/critical-rules.md`：:182 task-discipline 路由行清单 +92
5. `skills/task-planner/README.md`：:36/:81/:123 三处 1-91→1-92
6. selftest 面：`selftest-error-loop.sh` EL-11 宽容锚已扩 `8[0-9]|9[0-9]`（:75 实证）；`selftest-context-pressure.sh` CP-07 用 `1-[89][0-9]`（:110 实证）——均覆盖 92，预期零断裂；以 S4 实跑为准

### 既有口径漂移登记（只登记不修，Rule 88.2③，待用户裁决）
- D-A：task-discipline/SKILL.md 规则索引表缺 Rule 85-90 行（85-90 已落盘于规则文件但索引表未同步）；同文件计数三口径并存：:15「共 41 条」/:69「现共 41 条」/:80「42 条规则全文」vs 清单实数 43 条
- D-B：README.md:81「其余 71 条」vs task-planner/SKILL.md:179「其余 73 条」（同口径两值）
- D-C：task-planner/SKILL.md 各卫星路由清单编号合计 89，但 1-91 实存编号 88（77/78/79 为预留未落地号，Rule 80 注释在案）——清单或全集口径有一处多计
- D-D：plans/task-v184-proactive-error-review/task_plan.md 触发 [PLAN TAMPERED]（锁定哈希不符）：工作区与 HEAD 零 diff、改动均已随 v184 簿记提交入库（HEAD 16951ff 等），mtime 2026-10-17 14:05——判定=「锁定后正常簿记编辑未重锁」样态，非本会话所为，未重锁（Rule 51.7 无登记重锁视为篡改信号）；本会话 side 指针已切走，留待 v184 属主会话处置

### 并行会话指针竞态实况（v180 判例复用）
- init 时全局指针设为 v185，数分钟内 `resolve-plan-dir.sh` 解析回 task-v184（他会在写）→ 本会话已设 side 指针 `set-active-plan.sh set task-v185-file-split-discipline --sid fae73c58a87848799b51ae47a36810ea`，解析实证指向本计划。

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| 编号 92/落点 task-discipline/P1/L0-T | 见 task_plan.md Decisions Made 表（论证过程同源，不重复） |

### Rule 92 草稿（交付物本体，S1 逐字转写源；也落盘为 rule92-draft.md 供派发）

```markdown
### 92 产出文件尺寸纪律与优先拆分（P1 — task-v185，目标：任务产出/写入文件时尽量避免单个文件过大——产出前默认评估体量、优先拆分为多个内聚文件（代码按模块/引用天然可拆，文档/数据/配置同理），建议沿内聚边界垂直化拆分，降低大单文件的读写/上下文/冲突/维护负担；判定面=LLM 行为+本条款文本锚、零新 config 键、零新增守护脚本；衔接 Rule 19.6（task_plan.md 瘦身线同源口径）/29（工作文件维护）/45（拆分时注释随逻辑迁移）/87/88（存量拆分须在射程内或获授权），既有规则条目原文零改动）

**建制（为什么有这条）**：用户 2026-10-17 指令（逐字锚 plans/task-v185-file-split-discipline/user-session-log.md #1）：「尽量避免单个文件过大……优先将文件拆分为多个……代码……按照引用之类都可以拆分……其他文件也是类似的情况，建议垂直化的拆分……减少单个文件过大导致的负担」。大单文件的负担=读写定位慢、上下文注入与读取成本高、多会话编辑冲突面大、diff 审查困难、工具行数/字符上限易触顶；且「先写大再拆」在实践中极少发生。既有规则只覆盖 task_plan.md 单文件瘦身（19.6）与任务/子代理拆分（task-dispatch Rule 21/59），「任务产出物本身的文件尺寸」无纪律承载，本条补位。

**优先拆分协议（P1）**：
- **92.1 产出前体量评估（总则）**：任何任务的产出/写入动作（新建文件，或预期使既有文件大幅增长的写入）前，默认评估目标文件预期体量；预计触达 92.2 参考线 → 优先拆分为多个文件，禁止默认产出超大单文件。「尽量避免」= 默认拆分+例外显式登记（92.6），不是禁止大文件。
- **92.2 尺寸参考线**：代码单文件 >300 行、文档/Markdown >500 行、任意单文件 >5K 字符（推荐线）→ 触发拆分评估；已接近参考线（约 80%）且内容仍会增长时，优先新开文件而非续写。口径与用户宪法 §九及 Rule 19.6（task_plan.md >500 行瘦身）同源；19.6 只管 task_plan.md 本身，本条管全部任务产出物。
- **92.3 代码垂直拆分**：代码是天然可拆物——按模块/职责/引用关系切分，一个内聚单元一文件（一个类/一组同域函数/一个入口），公共逻辑提取共享模块供引用复用；新建代码自第一行起按多文件结构组织，禁止「先堆单文件、拆分留给以后」。
- **92.4 非代码文件垂直拆分**：文档按主题/章节切独立文件+索引入口串联（可发现性优先）；数据/配置按结构域分片；长清单/日志类产出按批次或日期分卷。同理适用「能拆则拆」。
- **92.5 垂直切分边界（拆分质量）**：拆分沿**内聚边界**垂直切——同一职责/主题从入口到细节一条线落在一个文件，禁止按行数/篇幅机械横切。拆后必须：① 更新全部引用路径；② 保留或新建索引/入口文件保持可发现性；③ 注释随逻辑同步迁移不丢失（Rule 45）。禁止为拆而拆的碎片化（拆出 ≤10 行孤儿文件=过度拆分）。
- **92.6 例外与登记**：用户显式要求单文件交付物、机器锁定格式（lockfile/生成物）、平台约束单文件（如单 HTML 交付页）→ 按用户/平台要求执行，Decisions Made 登记一行即可，不构成违规。存量已有大文件的拆分属重构动作——须在本任务射程内（Rule 88）或获用户显式授权，禁止顺手拆（Rule 87.4③ 同面语义）。
- **92.7 机制（文本优先 L0-T——对齐 86.7/89.6/90.6 范式）**：判定面=LLM 行为+本条款文本锚（92.1 总则+92.2 参考线+92.3/92.4 拆分路径+92.5 垂直边界+92.6 例外登记），**零新增守护脚本/零新 config 键**；selftest/registry 机器化属 opt-in（Rule 38.7 L0-T 档），仅当用户显式要求才建。判例锚=2026-10-17 用户指令（plans/task-v185-file-split-discipline/user-session-log.md #1）。
```

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 全局活跃指针被并行会话改回 task-v184 | 设 side 指针 --sid fae73c58…（§并行会话指针竞态实况） |
| 相对路径命令失败一次（CWD 停在计划目录） | 改绝对路径重跑（无实害） |

## Resources
- 落点文件：/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md（576 行）
- 级联面：/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md、…/references/critical-rules.md、…/README.md、skills/task-discipline/SKILL.md
- 台账：/mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl

## Visual/Browser Findings
（本任务暂无多模态发现——未产生截图/PDF/网页证据）
