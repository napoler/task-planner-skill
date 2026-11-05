# 09 CR Review — commit 4e2198c (Rule 80.8 决策前读取纪律)

- 审查对象：`/mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105` @ `4e2198c31e20b1f91b78e88ed6e0e996de8062f8`
- 变更规模：8 files, +108/-14（`git show 4e2198c --stat`）
- 计划：`plans/task-userlog-recall-20261105`，attest SHA `722481ec`

## 1. 增量纪律
**PASS**
- 80.1–80.7 写入面零改动：`critical-rules.md` diff 仅触及 `51.3` 追加（行100）与新增 `80.8`（行112）；80.1–80.7 原文未出现在 diff hunk。SL-18 对 `^80.[1-8] ` 计数=8 作完整性守护（`selftest-session-log.sh:200-208`）。
- 86.1/95.4/102.0 既有判据保留：`critical-rules-discipline.md:27` 在 86.1 句尾**追加**前置读档门，①②③ 可测性三问与核心行为未删改；`39→40` 95.4 将“三问→四问”，①②③ 原文逐字保留，新增 ④（专档原话裁决问），判定器“无损失/有路径/在流失 → 禁止暂停”仍作用于 ①②③；`52→53` 102.0“四问→五问”，①-④ 与 A/B/C/D/E 分类/执行闭环原文保留，新增 ⑤（专档对照）。
- 模板既有字段/逻辑未删：`delivery-summary.md:251-254` 在既有“需求覆盖核对”表上**加列**“专档条目#”，R1 行扩列，未删既有列；`subagent_dispatch.md:270` 在既有需求锚字段后**句尾追加**双锚说明，`{requirement_anchor}` 占位符保留；`user-session-log.md:290-300` 在“## 恢复协议”前追加“消费点”区块，既有恢复协议/条目格式说明未改。
- selftest 既有断言未改：SL-01..SL-12 逻辑未出现在修改 hunk（`selftest-session-log.sh:123-129` 仅将汇总位置后移并追加 SL-13..18，SL-12 仍调用 `t` helper）；新增 `td` helper 不影响既有断言。
- hook 纯文案追加：`zcode-userpromptsubmit.sh:227,229,231` 三处 `note=` 字符串句尾追加 80.8② 对照提示，`case`/`if`/变量赋值与触发逻辑零变更。

## 2. 语义正确性（80.8①-⑤ 互引一致性）
**PASS**
- 80.8 定义（`critical-rules.md:112`）：①上抛裁决前 ②新指令反思门 ③完成声称与交付前 ④子代理派发需求锚双锚 ⑤周期对照（Rule 19.7 3f）。
- 对应落点：86.1 前置读档门引用 `Rule 80.8①`（`discipline.md:27`）✓；95.4 第④问引用 `Rule 80.8①`（`discipline.md:40`，与上抛裁决语境一致）✓；102.0 第⑤问引用 `Rule 80.8②`（`discipline.md:53`）✓；51.3 双锚升级引用 `Rule 80.8③`（`critical-rules.md:100`）✓；subagent_dispatch 引用 `Rule 80.8④`（`subagent_dispatch.md:270`）✓；SKILL G9/Rule80 索引列出五决策点（`SKILL.md:70,85`）✓；user-session-log 消费点表 ①-⑤ 与 80.8 对齐（`user-session-log.md:293-299`）✓。
- 决策点编号（①-⑤）在规则正文、SKILL、模板、hook 提示间无错位。

## 3. 自相矛盾检查
**PASS（无冲突）**
- 95.4“三问→四问”：④ 为**前置消解**（专档已有裁决则按原话执行禁上抛），不否定 ①②③ 判定器；G1-G4/D6 真门豁免条款原文保留（`discipline.md:40`）。
- 102.0 分类逻辑未被干扰：⑤ 仅增加与专档冲突时的权威序对照（回指 80.4），A/B/C/D/E 五类判定与“先落盘后执行”闭环原文保留（`discipline.md:53-58`）。
- 80.4 恢复协议未重复定义：80.8 明确“会话恢复场景=80.4 既有读取义务不变（本条不新增恢复触发）”（`critical-rules.md:112`），模板消费点标注“会话恢复…(80.4 既有)”（`user-session-log.md:299`）。

## 4. 模板安全
**PASS**
- 无 `{{`/`}}` 渲染占位符引入：检视三模板新增内容（消费点表、`专档条目#` 列、`user-session-log.md#R1` 示例、双锚说明）均为静态 Markdown/中文文本，无新增占位符。
- `subagent_dispatch.md` 既有 `{requirement_anchor}` 占位符保留在行首字段中（`270`），本次仅句尾追加说明，不改变占位符形态。
- 消费点区块为普通 `##` 标题+表格，init/render 脚本常规按占位符替换/整体拷贝时无误命中风险。

## 5. hook 脚本安全
**PASS**
- `zcode-userpromptsubmit.sh` 改动纯文案（`227,229,231`），无新增分支/赋值/命令执行；取消检测 `case` 与 `_cancel_ref/_near_ref` 逻辑未变。
- 引号边界安全：追加内容位于双引号 `note="..."` 内，使用中文全角括号 `（）`、破折号 `——`、顿号/句号，无反引号/`$`/未转义双引号/反斜杠；commit 信息称 `bash -n` 已过，与人工复核一致。

## 6. selftest 质量（SL-13..18）
**PASS（1 条 MINOR 可改进）**
- SL-13a/b/14a-c/15a-b/16a-c 使用 `grep -qF` 匹配**高特异性**锚（含任务 ID `task-userlog-recall-20261105`、`Rule 80.8③/④`、完整标题/列名），误报/假 PASS 风险低（`selftest-session-log.sh:156-192`）。
- SL-18 用 `grep -cE '^80\.[1-8] '` 计数=8 强守护 80.1–80.8 完整性，并在失败时输出 diag，质量好（`200-208`）。
- **MINOR**（`selftest-session-log.sh:195-197`，SL-17）：断言仅 `grep -qF '80.8' "$UPSUBMIT"`，特异性弱于其他 SL（hook 内任何 `80.8` 残留/异位都可能 PASS）。当前 hook 变更前无 `80.8` 且三处已追加，实际可守护“接线存在”，但建议收紧为匹配句尾提示关键片段（如 `冲突以逐字原话为准（Rule 80.8②）`）以降低未来假 PASS。

## 7. 范围越界
**PASS**
- 8 文件均服务 80.8 落地：规则正文 2（planner+discipline）、SKILL 索引/G9、selftest、UPS hook 提示、3 模板（专档消费点/交付双锚/派发双锚）。无与本任务无关的顺手改动。

## 结论
- Verdict 建议：**APPROVED**（0 BLOCKER / 0 CONCERN / 1 MINOR）。
- MINOR 不阻塞合入：SL-17 锚可在后续维护中收紧特异性。
