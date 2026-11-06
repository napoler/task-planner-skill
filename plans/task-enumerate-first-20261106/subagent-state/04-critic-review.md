# Critic 复检回执 — Rule 105 变更集（commit 4344749）| 维度：条款正确性/守护完备性/级联漏改 | 总计 8（C0 / I1 / W2 / Q1 / N4）
- 复检体: critic（只读）；worktree=`/mnt/data/dev/task-planner-skill-worktrees/task-enumerate-first-20261106`
- 时间: 2026-11-06

## 一、执行体自审段比对（申报 vs 实际产出）

| 执行体 | 申报要点 | 实测复核 | 判定 |
|---|---|---|---|
| S1 | `### 105` 在 :707；`^105\.[1-5] `=5（:711/713/715/717/719）；14 行纯尾部增量；装备车/命名族在位；`Rule 35`@:709、`100.6`@:711 且 :681 零改动 | 全部一致：`grep -n "^### 105 "`=707；子条 5 行行号逐一命中；`git show --stat`=14 insertions 0 deletions；:681 仍为 `- **100.6 垃圾桶机制` | **5/5 PASS** |
| S2 | 脚本 101 行 + chmod +x；registry 追加 4 列 tab 行；EN 现态 7 PASS 0 FAIL；EN-03 阈值 ≥5→≥4 已登记 | 101 行、`-rwxrwxr-x`、`NF=4`、实跑 `Total: 7 PASS=7 FAIL=0` 全部一致。**两处描述性偏差**：① 自审称"照 file-disposal 范式…ok/bad 计数"，实际两脚本均为 `PASS/FAIL` 计数（file-disposal:25 `PASS=0; FAIL=0`）② 申报表仍写 `全量枚举≥5`，产物头注释亦写 ≥5，而代码为 ≥4 | **PASS + N-2/N-1（非关键面，阈值修正已双处登记 findings.md:71 + task_plan.md:559，不构成隐匿改判）** |
| S3 | `1-105`=3、`1-104`=0、`88 条`=2/`87 条`=0、行数 281、索引行在位、路由/指针含 105、diff 仅 2 文件 | 7 项逐条实测一致 | **7/7 PASS，但自审覆盖面不足**：未核对 task-discipline/SKILL.md 的规则条数计数句，致 I-1 漏检（申报"§3 自审全绿"就其所列 7 项为真，非虚假申报） |

## 二、维度 1 — 条款正确性

**🟢MEDIUM [W-1]** `skills/task-discipline/references/critical-rules-discipline.md:711,717` — 105.4 边界双阈值互斥，"放宽"不可执行
- 原文（105.1）: "判据=单层目录或名称清单 ≤200 项"
- 原文（105.4）: "（≤200 项经验值，可按目录实况放宽但须能一屏人工目检）"
- 原因: 放宽方向（>200）与目检上界（约 40-60 项/屏）互斥——>200 项必然无法一屏目检，故"放宽"分支永不成立；而 201-1000 项目录按 105.1 判"不适用"、按 105.4 又提示"可放宽"，同一场景两个结论，边界不可判
- 置信度: HIGH

**PASS [1-1] 五子条可执行性**：105.1 给出判定对象（存在性判断/匹配选择）、动作（ls / find -maxdepth 1 / 目录列表 Read）、禁止项（grep / find -name / Glob / 模糊搜）；105.2 给出触发（以"没搜到"支持"不存在"）、动作（回退全量枚举人工目检）、出口（复核仍无才可否定 + 受 Rule 35 约束）；105.3 给出信号短语与纠正方向（回退枚举，禁扩关键词族）。无"尽量/酌情/视情况"类不可判措辞。证据: :711-715。

**PASS [1-2] 与用户判例语义对齐**：用户原话（user-session-log.md:12）"本来 所有的素材名字也就是几十个 但是却因为 搜索名称错误导致错误决定 如果使用 ls 命令列出所有从中选择正确匹配 应该可去掉这种错误"；105 Why 段 :709 + 105.5 :719 逐字承载（素材命名全集几十个、关键词族选错、正确动作=ls 全量列出后在完整清单上选择），且 105.2/105.3 把"搜错→错误否定/错误方向"的因果链补成可执行义务。无转译降维。

**PASS [1-3] 与 Rule 35/63.2/75.15 无语义冲突、未重复造门**：实测原文——Rule 35（:107-115）管"能力否定三关与结论措辞"；`critical-rules-research.md:32`（63.2）管"知识缺口该不该检索+检索渠道链"；`critical-rules-research.md:82`（75.15）管"调研阶段网络获取评估强制槽位"。三者均不定义"本地可枚举集合的枚举方式 vs 关键词检索"，105 填补的是动作选择面，且 105.2 显式回指 Rule 35 不重述其判据 → 互补不重叠。

## 三、维度 2 — 守护完备性

**🟡HIGH [I-2]** `skills/task-planner/scripts/selftest-enumerate-first.sh:57-76` — EN-03/EN-05 为全文件词袋断言，空壳文案可 7/7 通过
- 原文: `if [ "$_en03_enum" -ge 4 ] && [ "$_en03_zero" -ge 1 ] && [ "$_en03_fb" -ge 1 ] && [ "$_en03_ls" -ge 2 ]` / `grep -q 'Rule 35' '$DISCIPLINE_CR' && grep -q '100.6'`
- 原因（两条实测证据）:
  ① **删整段仍 PASS**：把 105 段整体删除后运行（/tmp 副本），EN-05 仍 PASS（`Rule 35` 段外 3 行命中、`100.6` 段外 1 行命中=:681），EN-03 的 `零命中/回退/ls` 三条腿仍满足（段外计数 1/2/10）—— 这三条断言对 105 段零判别力。
  ② **空壳可过**：以 6 行 stub 替换 105 段（`### 105 x` + `105.1 全量枚举`／`105.2 全量枚举`／`105.3 全量枚举`／`105.4 全量枚举`／`105.5 装备车 命名族`，零实质条款）→ 实跑 `Total: 7 PASS=7 FAIL=0 exit=0`。断言未与子条绑定（EN-02 正则 `^105\.[1-5] ` 允许空正文），词袋计数被同文件他章内容与 stub 灌水同时满足。
- 影响: 脚本头注释自称守"防回归为 grep/find -name 替代 ls 全量枚举"，实际无法区分真条款与关键词填充 → 条款被静默掏空时守护不报警
- 置信度: HIGH

**PASS [2-1] 路径可移植**：`SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` + `ROOT="$SCRIPT_DIR/.."` + `$ROOT/../task-discipline/...`；把整个 `skills/` 树复制到 `/tmp/enftest/` 后原样运行 7 条断言均正常求值（非因路径失败），部署位 `/home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md` 实际存在，推导可达。与既有 10 个 selftest 同范式（`grep -l '\.\./task-discipline'`）。

**PASS [2-2] exit 语义与计数汇总**：`TOTAL=$((PASS+FAIL))` → `[ "$FAIL" -eq 0 ] && exit 0 || exit 1`；实测 FAIL=0 时 exit=0、FAIL≥1 时 exit=1（/tmp 删段测试 exit=1）。

**PASS [2-3] registry 行格式**：新行为 4 个 tab 分隔字段（`awk -F'\t' NF=4`），与表头 `script/domain/trigger_scenarios/dep_anchors` 一致；`selftest-registry.sh` 实跑 `Total: 5 PASS=5 FAIL=0 (registry rows=97, actual selftest=97)`，双向一致未破坏。

**💬NIT [N-1]** `skills/task-planner/scripts/selftest-enumerate-first.sh:6` vs `:61` — 头注释阈值与代码阈值不一致
- 原文: "`全量枚举`≥5、`零命中`≥1、`回退`≥1、`ls`≥2"（:6） vs 代码 `-ge 4`（:61）
- 原因: 阈值校准（≥5→≥4）后未回头注释，维护者按头注释会误判断言规格（校准本身已登记 findings.md:71，非隐匿）
- 置信度: HIGH

**💬NIT [N-4]** `scripts/selftest-enumerate-first.sh:70` — 断言取自设计稿的"且"，设计稿写"或"
- 原文: `grep -q '装备车' ... && grep -q '命名族'`
- 原因: findings.md:72 设计为"`装备车` 或 `命名族` 在位"，实现为"且"，比设计更严（不构成守护缺口，仅设计-实现口径漂移）
- 置信度: MEDIUM

## 四、维度 3 — 级联漏改

**🟡HIGH [I-1]** `skills/task-discipline/SKILL.md:15,86,97` — 规则条数计数句未随索引行级联（52→53），本 commit 引入的漂移
- 原文: ":15 …git 使用加强纪律、新请求计划同步与反思门纪律等共 52 条（全文见规则索引）" / ":86 …已后补落盘——本索引现共 52 条全文可消费。" / ":97 `references/critical-rules-discipline.md` — 52 条规则全文"
- 原因: 本 commit 在 :84 追加了 Rule 105 索引行，规则文档 `^### [0-9]+ ` 标题数=53、索引表行数=53，而三处计数仍写 52（父提交 4344749^ 时表行=52 且计数=52，即计数句原本与行数严格同步）→ 一致性回退，且 `grep -rn '52 条' scripts/` 无任何 selftest 守护该计数，漂移静默。另 :15 的规则罗列以"…等共 52 条"收尾但未含 105（"等"字兜底，非硬错）。
- 置信度: HIGH

**PASS [3-1] `1-104` 全仓残留**：`grep -rn '1-104' skills/ scripts/`（排除 plans/.git）仅命中守护脚本自身 6 行（EN-07 负断言与其注释，自指必要字面）；`skills/task-planner/SKILL.md` 内 =0。

**PASS [3-2] `87 条` 残留**：`grep -rc '87 条'` 全仓 skills/scripts=0；`88 条` 在 SKILL.md =2（:9 与 :222），核心 14 + 卫星 88 的算术随 +1 同步。

**PASS [3-3] SKILL.md 三处 105 标注一致性**：frontmatter references `:9` "Rules 1-105 全集索引…其余 88 条"；指针段 `:222` "Rules 1-105…其余 88 条…Rule 105 可枚举集合全量枚举优先纪律域（task-discipline 卫星）"；references 表 `:265` "核心域 1-105 全集索引"；路由表 `:209` 尾部 `,101,105）`；派发指针 `:255` "可枚举集合全量枚举优先（Rule 105）"——五处口径一致，`1-105` 计数=3（EN-06 阈值 ≥3 恰好卡边）。

**PASS [3-4] task-discipline/SKILL.md 索引行格式**：`:84` 为 3 列 `| 105 | 域描述 | \`references/critical-rules-discipline.md\` \`### 105\` 段 |`，与相邻 :83（101）/ :82（100）结构一致；仅中列描述明显长于邻行（含"·素材/资产等…零命中回退复核"），不破坏表格解析 → 格式 PASS、风格 NIT。

**⚠️QUESTION [Q-1]** `task_plan.md:106`（VC-4）— 旧锚"字面归零"与守护脚本自指冲突无豁免登记
- 原文: "`grep -rn \"1-104\" --include=\"*.md\" --include=\"*.sh\"` 旧锚=0（或逐项登记已修正）"
- 原因: 守护脚本必须书写 `1-104` 字面才能做负断言，VC-4 字面口径永不为 0；括号内允许"逐项登记"，但 6 处命中是否已按此登记无法从产物判定 → 需在 verification 中显式备注自指例外
- 置信度: MEDIUM

**💬NIT [N-3]** `skills/task-planner/SKILL.md:209` — 路由枚举缺 Rule 102（先存缺陷，非本 commit 引入）
- 原文: "…97,98,99,100,101,105）"
- 原因: Rule 102 已迁入 task-discipline（discipline SKILL.md:83 有索引行、:222 指针段含 102），但路由枚举未列；本 commit 仅在尾部追加 105，未新增该缺陷
- 置信度: HIGH

## 五、负结果报告（检查过但未发现问题）

- 检查：`skills/task-discipline/references/critical-rules-discipline.md` 全文件（105 段前后，Why 段与 5 子条、交叉引）；`skills/task-planner/SKILL.md`（frontmatter/指针段/路由表/References 表）；`skills/task-discipline/SKILL.md`（域说明/索引表/落盘状态段/文末清单）；`selftest-enumerate-first.sh` 全文；`selftest-registry.tsv` 表头+末 4 行；`references/critical-rules.md`（核心域是否有 1-104 计数残留）；`plan-research-router/references/critical-rules-research.md` 63.2/75.15 原文。
- 预期可能有但**未发现**：① `1-104` 在 skills/ 与 scripts/ 的非自指残留（0 处）；② `87 条` 残留（0 处）；③ 与 Rule 63.2/75.15 的重复造门（三者域不同，明确）;④ registry 行列数与表头不符、脚本未入 registry 或脚本缺失（registry 97=97 双向一致）；⑤ 脚本 exit 码语义错误（实测双态正确）；⑥ 硬编码绝对路径/部署位不可达（相对推导，部署位存在）；⑦ SKILL.md 五处 105 标注互相矛盾（一致）。
- 已排除：`## 卫星路由表` 缺 105 的怀疑（:209 已含）；`105.x` 编号与既有 9x/10x 重号（105 未被占用）；`EN-06` 的 `,105` 匹配误伤（当前 SKILL.md 仅 :209 命中）。

## 六、验证摘要

- 总发现 8 / 已验证 8 / 通过率 100%
- 复现手段：`grep -n`/`grep -c` 逐条锚定原文；`bash selftest-enumerate-first.sh` 实跑（真实树 7/7、删 105 段 3/7、空壳 stub 7/7）；`bash selftest-registry.sh` 实跑 5/5；`git show 4344749^:skills/task-discipline/SKILL.md` 对比父提交计数（52/52）；副本实验均在 `/tmp` 下进行，未触碰 worktree 与主仓任何文件。

## 七、结论

必须修复仅 1 项（I-1 计数句 52→53，三处；或统一改为不带数字的"全集见规则索引"）。建议同批处理 I-2（把 EN-03/EN-05 词袋断言收窄为 105 段内 scoped grep 或子条绑定断言）与 W-1（105.4 边界阈值二选一，明确"一屏"与"200 项"只留一个口径）。N-1/N-2/N-3/N-4/Q-1 属随手改/待确认，不阻断。

VERDICT: CHANGES_REQUESTED（I-1 三处 "52 条"→53 条未级联；建议同批 I-2 selftest 空壳可过 + W-1 105.4 双阈值互斥）
