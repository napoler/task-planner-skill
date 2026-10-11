# Knowledge Brief — task-v079-skill-modify-conservatism（任务知识简略要点）
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：落地 Rule 36 技能修改保守化与功能删除防护（36.1-36.7 七子条 + config 键 skill_modify_enforce + check-skill-modify.sh pretooluse 守卫 + SKILL-MODIFY GATE + selftest 守护 + SKILL 联动），全量 selftest 0 FAIL 后合并 master 部署 3 实体位。
- 背景/动机：用户 2026-09-17 诉求——技能报错时 agent 盲目改技能（偷渡修改）；事故样本=文章优化技能「流量分级优化」功能被静默移除致高流量旧文被彻底重构、流量尽失。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 删除性行为清单 | 36.3 要求：修改前逐条列出将删除/改写的功能项，落 findings.md+progress.md，GATE 终验确认记录 |
| 锚级联 | SKILL/README 等 5+处 `Rules 1-35` 字样 + selftest 严格/宽容断言，新增 Rule 36 后须一次性改齐 1-36 |
| 三档 enforce 键 | config 键模式：enforce=阻断 / warn=提醒（默认）/ off=关闭；解析 env > config.json > warn |
| worktree | git 隔离开发区，本仓=运行中基础设施（§11.1 信号⑤），实现期必须隔离 |
| 白名单①③ | 主进程例外直做理由：①git 编排 ③机械求和/部署跑测（Rule 25.3） |

## §2 已验证关键事实
（证据源：01-explore-conventions.md 各节 + plan-writer 计划期一手 Read）

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| critical-rules.md 当前最大 Rule=35（`### 35` @L292，共 300 行） | references/critical-rules.md:292（01 §1 L6） | Rule 36 块追加在 L292 起 Rule 35 块之后（文件尾），净增 ~25 行 |
| 31.3「本体修改走后续任务」先例在 L255 | references/critical-rules.md:255（01 §1 L7/§7 L39） | 36.2/36.4 文案必须显式引用 31.3/D6 衔接，不改 31.3 原文 |
| config.json `additionalProperties:false`，14 个三档键全默认 warn，最新先例 @L299-310 | config.json（01 §2 L12-16；短描述风格已核 L302-310） | skill_modify_enforce 必须进 properties 区（非顶级裸挂），description 单行短风格 |
| check-complete.sh GATE 顺序末段=REFLECT-GATE（case 结束 ~L818）→ warn 计数（L821）→ L834 `exit $python_rc` | scripts/check-complete.sh:808-834（01 §4 L25；行号=plan-writer 实读） | SKILL-MODIFY GATE 插入锚=L818 REFLECT-GATE 段结束后、L821 warn 计数前；用独立 shell 段 + resolve skill_modify_tier |
| pretooluse Write/Edit 接线点=check-delegation.sh 调用后的分支（L29-55 区） | scripts/zcode-pretooluse.sh:29-55（01 §8 L45-48；行号=plan-writer 实读 L29-48） | check-skill-modify.sh 追加在 Write/Edit/ApplyPatch case 内、Rule 23 冲突检测（L77）之前；主/子代理一致生效（check-delegation 对子代理 sid≠owner exit 0 放行的空档） |
| check-delegation 白名单含 plans/ 祖先 + $SKILL_ROOT 自身——技能文件写操作不经其拦截 | 01 §8 L46（check-delegation 行为记录） | 新守卫须自行实现技能文件模式匹配（skills/<name>/** 目录），不能复用 delegation 白名单 |
| 合规清单最大 C 编号=C23 @SKILL.md L197；Rule 31/32/33/34 特判指针块 @L214-219 | skills/task-planner/SKILL.md:197, 214-219（01 §5 L31/L33；行号=plan-writer 实读） | C24 行插 L197 后；Rule 36 特判指针段插 L219（Rule 34 段）后 |
| `Rules 1-35` 级联锚全清单：SKILL frontmatter L9 / L278 / L327 + README.md:67 + batch-quality-gate.md:130；严格断言 CD-11/CD-12（L59-63）/CD-18（L75）/CD-19（L77）/RV-10（L13/L60）；宽容正则 `Rules 1-3[1-5]` 在 VT-10（L13/L51）/EL-11（L14/L59） | 各 file:line=plan-writer 实读（01 §5 L32） | P3/S8 必须一次修齐：严格 `1-35`→`1-36`、宽容 `1-3[1-5]`→`1-3[1-6]`；改前 `grep -rn "Rules 1-" scripts/` 全扫防漏 |
| variant 骨架 P1-P5 与 S-unit 7 列表列格式 | skills/task-planner/templates/variant/rule-enhancement-type.md（01 §6 L36） | 本计划 Phase/S-unit 结构照此对齐；模板文件本身有 v077 遗留 diff，不动 |
| selftest-veto.sh 范式：头注释逐用例 + ok/bad 双函数 + 宽容锚 + json 校验 + 尾 `exit $((FAIL > 0))` | 01 §3 L21（scripts/selftest-veto.sh） | S7 新建 selftest-skill-modify.sh 照此范式 |

## §3 关键文件锚点表
（路径=仓库根 /mnt/data/dev/task-planner-skill 相对；「将改」列=本任务写入动作）

| 路径 | 行号 | 将改动作 | 该区段做什么（≤10 行摘要） |
|------|------|---------|---------------------------|
| skills/task-planner/references/critical-rules.md | 292-299（尾） | 追加 Rule 36 块 ~25 行 | Rule 35 块（35.1-35.6 执行结论纪律）；新块接文件尾 |
| skills/task-planner/config.json | 299-310 | properties 追加 skill_modify_enforce | reflect_verify_enforce/template_gate_enforce 三档键先例区（短 description 风格）；subagent 对象 @L311 前插入 |
| skills/task-planner/scripts/check-skill-modify.sh | 新建 | 全新文件 | 入参=tool+file+sid+活跃计划；realpath 归一化匹配 skills/<name>/** 模式；未列于计划「执行范围限制」表 → warn JSON 提醒 / enforce exit 2；主/子代理一致 |
| skills/task-planner/scripts/zcode-pretooluse.sh | 29-55 | Write/Edit 分支追加 1 处调用 | PreToolUse 链：check-scope → Write/Edit/ApplyPatch case（L29）→ check-delegation（L40）→ 本接线点 → Rule 23 冲突（L77） |
| skills/task-planner/scripts/check-complete.sh | 818-821 | REFLECT-GATE 后插入 SKILL-MODIFY GATE shell 段 | L808 REFLECT-GATE FAILED/WARNING 分支尾；L821 warn 计数段前；范式=resolve_X_tier + 锚注释 task-v079 |
| skills/task-planner/scripts/selftest-skill-modify.sh | 新建 | 全新文件（≥6 断言） | 36.1-36.7 锚 + config 键 json 校验 + SKILL Rule 36 行/C24 + pretooluse 接线 grep + GATE grep |
| skills/task-planner/scripts/selftest-conclusion-discipline.sh | 59-63, 75-77 | CD-11/CD-12/CD-18/CD-19 断言 1-35→1-36 | CD-11 `grep -c '1-35'` ≥3 / CD-12 '1-34' 计数=0 / CD-18 README 锚 / CD-19 batch-gate 锚；头注释 L8-17 清单同步 |
| skills/task-planner/scripts/selftest-reflect-verify.sh | 13, 60 | RV-10 锚 'Rules 1-35'→'Rules 1-36' | RV-10 断言 SKILL 索引行含 'Rules 1-35'（字面量，非宽容正则） |
| skills/task-planner/scripts/selftest-veto.sh / selftest-error-loop.sh | L13/L51（VT）/ L14/L59（EL） | 宽容正则 `Rules 1-3[1-5]`→`Rules 1-3[1-6]` | VT-10/EL-11 宽容锚设计=跨 P 阶段不误报，本次扩 36 |
| skills/task-planner/SKILL.md | 9, 197, 219, 278, 327 | frontmatter L9 + L278/L327 锚 1-36；L197 后 C24 行；L219 后 Rule 36 特判段；Critical Rules 列表加 Rule 36 行 | 五处联动净增 ≤10 行（L9/278/327 为行内替换不增行；C24+Rule 36 行+特判段=增 3 行） |
| skills/task-planner/README.md | 67 | 锚 1-35→1-36 | 目录树注释行 `# Rules 1-35（…）` |
| skills/task-planner/references/batch-quality-gate.md | 130 | 锚 1-35→1-36 | `隶属 Rules 1-35` 表格行 |

## §4 易错点与禁止假设清单
1. config.json `additionalProperties:false`——新键必须挂 properties 内且保持合法 JSON（改完 `python3 -c json.load` 立即验）；禁裸挂顶级
2. 改 `Rules 1-35` 字样前必须 `grep -rn "Rules 1-" skills/task-planner/scripts/` 全扫一次修齐（严格+宽容锚共 7 处，清单见 §3）——漏一处=CD/RV 自测 FAIL
3. check-delegation 对子代理（sid≠.session-owner）exit 0 放行——check-skill-modify.sh 必须自行实现「主/子代理一致生效」，禁止假设 delegation 已覆盖技能文件
4. S-unit ID 全局纯数字 S1..S11 禁字母后缀（check-plan-dispatch.sh 数据行正则 `^\|\s*S[0-9]+\s*\|`；v077 已 dogfood 该契约）
5. 历史教训：Explore 无 Write 工具 → 其检查点（01）由主进程代落盘；本任务 code-runner/executor 返回后结论同样须主进程 Read 复核落盘（35.3 材料/35.4 证据）
6. 禁止改写 Rule 28/31/32/35 既有文字（36 只引用不扩列）；templates/variant/rule-enhancement-type.md 的 v077 遗留 diff 保持原样不提交不覆盖
7. 全量 selftest 总数=主进程逐脚本 Total 行 awk 机械求和（Rule 35 纪律），禁采信子代理自报汇总数字
8. P2 各 S-unit 前置 Read 目标文件再动手（本任务自身即 Rule 36 dogfood：授权修改=计划执行范围限制表逐行登记的修改）
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「P2/S5 守卫误报（RPN=120）」「P5/S11 部署位 REJECTED（RPN=120）」行

## §5 S-unit 材料包索引
（与 task_plan.md S-unit 表「输入」列互链；plan-dir = /mnt/data/dev/task-planner-skill/plans/task-v079-skill-modify-conservatism/）

| S-unit ID | 应读本 brief 哪节 | 额外材料路径（绝对/相对 plan-dir） |
|-----------|------------------|-------------|
| S1（worktree） | §1 + §4-6 | task_plan.md 隔离决策行 |
| S2（基线跑测） | §4-7（求和纪律） | 01-explore-conventions.md §3（selftest 清单） |
| S3（Rule 36 条款） | §1 + §2 + §4-6/8 | 02-rule36-design-brief.md L9-17（条款全文逐字采用） |
| S4（config 键） | §2 + §4-1 | 01-explore-conventions.md §2（L12-16 键模式） |
| S5（守卫+接线） | §2 + §3（check-skill-modify 行）+ §4-3 | 01-explore-conventions.md §8（hook 接线 L43-48） |
| S6（GATE） | §2（GATE 顺序行）+ §3（check-complete 行） | 01-explore-conventions.md §4（L24-27 范式） |
| S7（新 selftest） | §2（veto 范式行）+ §3 | 01-explore-conventions.md §3（L21 范式） |
| S8（锚级联） | §3（7 处锚逐行）+ §4-2 | 01-explore-conventions.md §5（L32 级联锚清单） |
| S9（SKILL 联动） | §3（SKILL 5 锚行） | 02-rule36-design-brief.md L19-23（联动 4 条） |
| S10（回归跑测） | §4-7（同 S2 求和方法） | 预期数=p1-baseline 基线+新 selftest 断言数，以实跑为准 |
| S11（合并部署） | §1 | task_plan.md 隔离决策行 + 宪法 §11.3 六条 |
