# task-v081 材料包 — plan-writer 输入（自包含；本文件=唯一事实源，prompt 只放路径）

## 0. 用户指令原文（2026-09-17）
「优化当前技能 存在非常明显的拆分子代理不够细问题 比如现在出现过 一个 子代理包含这么多的步骤 完全是违背了小步快跑原则 以下是一个子代理的待办：Step1 收集上下文: gate报告+article.json+images.json+title_content.json+coverage-gaps+facts/research_data / Step2 备份 article.json 到 .backup 并 cmp / Step3 查 H2 禁用词表 / Step4 封面: PAAPI 取 K701 主图→仓内转存工具上传 storage 非tmp→写回 article_img+images.json / Step5 focus_keyword+meta_title+meta_description 定点修 / Step6 data_consistency 无出处数值改近似式或补 facts.json 锚 / Step7 正文嵌 3 图+覆盖缺口 Gap3/Gap1 增量写入(<=300词) / Step8 重算 _content_sha256+同步 title_content.json / Step9 跑 cli_verify-article-cover.ts 产出 .cover-verified / Step10 generator_field 依 gate details 修正 / Step11 非ASCII扫除+review_phrase+模板token 清理 / Step12 复跑 gate --strict --json 目标 c=0 h=0 / Step13 回报8字段+checkpoint 落盘」——单子代理 13 步，跨 ≥6 文件，明显超 Rule 21.1b 步级上限仍被放行。

## 1. 根因（主进程第一手取证，已完成）
四层防线均无「步骤数」维度：
1. `scripts/check-plan-dispatch.sh` S-unit 数值门控仅两维：时长≤step_max_minutes(15)/输入路径≤step_max_files(2)，且均 advisory（"SKIPPED…提示不阻断"，174/182 行）
2. `scripts/check-dispatch.sh` fine_grain_checks ② 打包检测只数 distinct `S<n>` ID（≥2 才告警）——单个 S-unit 塞 13 步只有 1 个 ID，不触发
3. ① prompt 长度 ≤prompt_max_chars(3000)——13 条极简步骤 <1000 字符，不触发
4. `references/critical-rules.md` Rule 21.1b 只有 文件/行数/分钟 三维，无步骤枚举上限；`templates/subagent_dispatch.md` 九字段亦无此约束

## 2. 设计方案（纯增量 — Rule 36.5 合规，无删除、无既有语义改写）
- **D1 config 新键**：`skills/task-planner/config.json` → `properties.subagent.properties.step_max_steps`（integer，default 4，description 写明口径=单次派发 prompt 内步骤枚举 distinct 计数上限；与 step_max_files/step_max_minutes 同层同型）
- **D2 check-dispatch.sh fine_grain_checks 增第④项「步骤枚举计数」**：
  - 标记正则（覆盖实测反例）：`Step ?[0-9]+`（大小写不敏感）、`步骤 ?[0-9]+`、`第[0-9一二三四五六七八九十]+步`、`①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮`、行首 `^[0-9]{1,2}[.、)] `；计数=按序号值去重后的 distinct 数（Step3 与 3. 与 第三步 同序号算 1）
  - distinct 计数 > step_max_steps → hits 追加「步骤枚举超限(N>4)」，走既有 mode 分档（warn 落盘 / enforce exit 2）
  - **任务书防绕门**：② 的「任务书+subagent-state/」双条件豁免命中时，从 prompt 提取存在的 subagent-state 引用路径（≤3 个、文件存在可读），对任务书文件内容同样计数，超限同样 hits
  - jq 缺键 → 回退默认 4 + SKIPPED 显式化一行（与 ①②③ 同范式）
- **D3 check-plan-dispatch.sh 增第三数值维度**（advisory，与前两维同范式）：S-unit 数据行「目标」单元格步骤枚举 distinct 计数 > step_max_steps → 打印 `SKIPPED Phase X S<n> 步骤枚举 N > step_max_steps(4) — 建议拆分(提示不阻断)`。注意：该脚本 awk 列位 $5=输入、$7=时长，目标列位实现时实读 161-190 行 awk 块核实
- **D4 critical-rules.md 纯增量**：114 行 21.1b 句尾追加步骤枚举维度（≤step_max_steps 默认 4，超限=拆分信号，机器侧 check-dispatch ④ enforce 硬阻断 + check-plan-dispatch advisory）；22.4 九字段清单处与 132 行 22.6 表说明句尾各加同源半句（实现时 grep 定位 22.4 九字段行）
- **D5 SKILL.md 同步（净增 ≤2 行）**：「⏱️ 超时与失败兜底」节首段「(22.4 上下文预算=prompt 长度/打包检测已机器化：check-dispatch.sh 校验 prompt 字符数 vs prompt_max_chars 与多 S-unit 打包…」括号内追加「与步骤枚举计数 vs step_max_steps」；Critical Rules Rule 21 摘要行「(21.1b 数值门控机器校验已生效：check-plan-dispatch.sh）」处追加步骤枚举字样；优先并入现有行
- **D6 templates/subagent_dispatch.md**：九字段模板内补一行约束（步骤枚举 ≤ step_max_steps，超限回炉拆 S-unit）
- **D7 selftest 新建** `scripts/selftest-fine-grain-steps.sh`（命名/断言风格对齐既有 selftest-*）：
  a. 13 步 fixture prompt + enforce 档 → exit 2 且输出含「步骤枚举超限」
  b. 4 步 fixture → exit 0
  c. warn 档 13 步 → exit 0 且告警落盘
  d. 任务书豁免场景：prompt 含「任务书」+「subagent-state/」且任务书文件含 13 步 → exit 2（防绕门）
  e. config 临时剔除 step_max_steps → SKIPPED 行 + 默认 4 生效
  f. check-plan-dispatch：S-unit 行含 5+ 枚举 → SKIPPED 提示行出现；1-2 步对照行 → 无提示
- **D8 行数断言扩围（条件性）**：SKILL.md 若净增行，两处断言同步上调：`scripts/selftest-skill-collab.sh:80-81` 与 `scripts/selftest-execution-stability.sh:70-72`（≤548 → ≤新值，B 类扩围登记；先例=task-v079 538→548）。SKILL.md 当前行数以 wc -l 实测为准
- **D9 CHANGELOG**：仓库根 `/mnt/data/dev/task-planner-skill/CHANGELOG.md` 新增 task-v081 条目（格式对齐既有条目）

## 3. 实施文件锚点（绝对路径）
- /mnt/data/dev/task-planner-skill/skills/task-planner/config.json（新键插 step_max_* 族旁）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-dispatch.sh（fine_grain_checks 函数 243-292 行附近，④ 插在 ③ 之后 `[ -z "$hits" ]` 之前；头注释 39-43 补 ④ 口径）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-dispatch.sh（awk 数据行块 161-190 附近；头注释 24-35 补第三维）
- /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md（114/124/132 行锚点）
- /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（兜底节首段 + Rule 21 摘要行）
- /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-fine-grain-steps.sh（新建）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-collab.sh、selftest-execution-stability.sh（条件性扩围）
- /mnt/data/dev/task-planner-skill/CHANGELOG.md
- 全量 selftest 口径：全部 scripts/selftest-*.sh 逐一 bash 执行累计 pass/total（既有基线 349/0）

## 4. Phase 草案（每派发 S-unit ≤2 文件 ≤15min；执行体除注明外全部子代理，严格串行）
- P1 计划确认+attest 锁定（主进程，白名单②）
- P2 worktree 隔离区创建（主进程，白名单①；路径=/mnt/data/dev/task-planner-skill-worktrees/task-v081-fine-grain-step-gate，分支 wt/task-v081-fine-grain-step-gate，基于 master）
- P3 机器门控④：S3a config 新键；S3b check-dispatch.sh ④+头注释；S3c fixture 自测三档（executor）
- P4 计划侧第三维：check-plan-dispatch.sh advisory + 头注释（executor）
- P5 条款模板：S5a critical-rules.md；S5b SKILL.md+templates/subagent_dispatch.md（executor；36.3 删除基线=改动前 cp 留存 + git diff 零删除证据进 progress.md）
- P6 selftest+CHANGELOG：S6a selftest-fine-grain-steps.sh 新建+fixture；S6b 行数断言条件扩围+CHANGELOG 条目（executor）
- P7 回归+CR：worktree 内全量 selftest（code-runner）→ critic 审查（code_review: required）→ fix ≤3 轮
- P8 合并部署终验簿记（主进程编排+白名单）：smart-merge-back.sh --deploy → 主仓全量 selftest → 三部署位（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）diff -r 亲验 → push → check-complete → 簿记+memory

## 5. VC 草案（终验逐条证据）
- V1 jq 查 step_max_steps.default=4
- V2 enforce 档 13 步 fixture → check-dispatch.sh exit 2 含「步骤枚举超限」
- V3 4 步 fixture → exit 0
- V4 任务书豁免+任务书内 13 步 → exit 2
- V5 check-plan-dispatch 5+ 枚举行 → SKIPPED 提示行；对照行无提示
- V6 critical-rules.md/SKILL.md/subagent_dispatch.md 增量在位；git diff 证实纯增量零删除（36.3 基线对照）
- V7 worktree 全量 selftest 0 FAIL；合并后 master 全量 0 FAIL
- V8 三部署位 diff -r IDENTICAL
- V9 CHANGELOG 条目在位；行数断言与 SKILL.md 实测行数自洽
- V10 origin/master=local push 完成

## 6. 交互模式与预登记决策
- **interaction_mode: silent**（依据：自主执行环境用户不实时在线+用户指令显式在案+v079 先例「D1 未获答复转 silent」）；交付报告附静默决策清单
- Decisions Made 预登记：① silent 选择理由如上 ② plans/task-v080-web-research-routing/=本会话早前运行的另一任务计划（未锁定、无 worktree、属主=本 sid），本任务全程不碰不清理，会话指针已切至 v081 ③ step_max_steps 默认 4：4 步内=单一主动作+紧耦合校验的自然单元，枚举 ≥5 步即拆分信号，13 步反例被硬拦 ④ 行数断言 B 类扩围预案（条件性）⑤ Rule 36 纯增量声明：本方案无功能性删除无语义改写，C24 走「纯新增或机械联动→PASS」
- 易错点（写入 knowledge-brief §4）：awk 列位以实读为准勿信转述；Bash 内 grep 是 ugrep 别名转义有差异（脚本内不受影响，主进程交互命令用 command grep）；行数断言两处同步勿漏；step_max_* 家族 jq 路径是 properties.subagent.properties.<key>.default（双层 properties）；每 Phase 产物即 commit（Rule 27），禁攒批

## 7. 检查点合约（Rule 22.8）
plan-writer 每完成一个文件（task_plan.md / knowledge-brief.md）立即落盘；最终返回 8 字段摘要 + 检查点写入 subagent-state/01-plan-writer.md（含两文件路径+行数）
