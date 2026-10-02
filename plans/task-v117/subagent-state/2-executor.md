# 2-executor checkpoint — task-v117 Phase 2 S1（T-2 试点 18.9 硬门）

## M1 试点里程碑
- 插入位置判定理由：bugfix-type.md 既有尾部区块顺序 = Drift Log(:160) → Handoff 登记表(:165 原)，
  与主模板三区块顺序（Drift Log → 委派统计 → Handoff 登记表）对齐 ⇒ 委派统计插于
  Drift Log 与 Handoff 登记表之间（=新文件 :165-:175），零顺序错位。
- 逐字复制验证：首用 Edit 手工粘贴后发现 `<!-- ` 行尾空格丢失（主模板 :364 为 `<!-- ` 带尾空格），
  改以 `sed -n '363,373p' 主模板 > /tmp/src-block.txt` + `sed -i '165,175d; 164r /tmp/src-block.txt'`
  字节级拼接；`diff` 源块 vs 插入块 = BYTE-EXACT MATCH（含 HTML 注释 + 表格，11 行 + 1 空行 = 12 行插入）。
- grep 复现：`grep -n '委派统计' bugfix-type.md` → `165:## 📊 委派统计（Rule 25.4 — 终验前必填）` 命中。
- diff 摘要：`git diff --stat` = 1 file changed, 12 insertions(+)；行类型统计 = 10 个内容行 `+`、0 个删除行（纯插入）。
- Read 上下文（:155-:182）：无重复区块、无错位，Drift Log/委派统计/Handoff 三区块顺序与主模板一致。

## 最终结论
- 试点完成：bugfix-type.md 单文件改动，纯插入 12 行，零自造内容，未触碰主仓与 mini-lite。
- 验收三条 (a)grep 命中 (b)git diff 纯插入 (c)Read 上下文无重复/错位 —— 全部通过。
- 下一步：主进程 Read 本试点文件验收通过后放行 P2-S2 批量（27 家委派统计）。
- 未执行 git commit（按任务约束由主进程统一提交）。

## M2 批量里程碑（T-2 批量①，26 家）
- 目标面实测：`grep -L '委派统计' variant/*.md` 输出 27 行（含 mini-lite-type.md）；
  剔除 mini-lite（Rule 38.3 设计豁免）后本次批量目标 = 26 家（bugfix 试点已在上轮入块，不在名单内）。
- 插入分组（判定逻辑同试点）：
  - Handoff 组 14 家（既有 Drift Log→Handoff 登记表）：插入块 = 空行+源块（`/tmp/insert-h.txt`），
    于 Handoff 登记表标题行前 1 行（`sed -i "$((ln-1))r`）拼接。
  - 尾部组 12 家（无 Handoff，末区块=Drift Log）：插入块 = 空行+源块（`/tmp/insert-t.txt`），
    于文件末行（`N=$(wc -l)`）后 `sed -i "${N}r"` 拼接。
- 源块：`sed -n '363,373p' 主模板 > /tmp/src-block.txt`（11 行，md5=c4183446b6a93ad888a74b1a653a3a77），
  与试点 bugfix 插入块 diff = BYTE-EXACT MATCH。
- 逐文件复验（全部 26 家）：`grep -n '^## 📊 委派统计'` 定位 + `sed -n 'ln,ln+10p' | diff /tmp/src-block.txt`
  = 26/26 BYTE-EXACT（其中 14 家 Handoff 组 + 12 家尾部组各跑一轮全量字节 diff，非抽样）。
- 复核：`grep -L '委派统计' variant/*.md` 仅剩 `mini-lite-type.md` 一家（豁免）；逐文件 `grep -q` 全部命中。
- 纯插入性：`git diff --stat` = 27 files changed（含试点 bugfix）, 324 insertions(+), 0 deletions；
  `git diff --numstat` 逐文件 12/0，零删除行。

### Batch Report（Rule 18.6 八字段）
- total=26 | success=26 | failed=0 | failure_rate=0%
- sampled_pass：10% 抽样 3 家（publish-type.md@130 / refactor-type.md@160 / image-type.md@102）
  逐行字节 diff vs 源块 = 3/3 BYTE-EXACT，且三家 git diff 无删除行。
- sampled_fail（运行前 2 家）：performance-tuning-type.md + migration-type.md，
  `git diff --numstat` = 12/0 × 2，字节 diff = BYTE-EXACT，0 家失败（未触发整批熔断）。
- pre_check：Q1 同类型文件互不影响=否；Q2 存在可回滚 checkpoint（M1 试点记录+git）=有；
  Q3 插入点错位可 sed/git restore 回滚=能。
- rollback_point：worktree HEAD（未 commit，任意一步失败可 `git restore skills/task-planner/templates/variant/<f>` 精确回滚单文件）。
- 改动范围确认：`git status --short` 仅 27 个 M 文件，全部位于 `skills/task-planner/templates/variant/`（26 批量 + 1 试点），未触碰主仓与保护区。
- 未执行 git commit（按任务约束由主进程统一提交）。

## 最终结论
- 批量完成：26/26 家委派统计区块补齐，纯插入 26×12=312 行，零自造内容、零删除、零顺序错位。
- 验收判据全过：① grep -L 仅剩 mini-lite（豁免）② 逐文件字节 diff = BYTE-EXACT ③ git diff 纯插入。
- 布局一致性终验（与主模板/试点 bugfix 逐处对齐，全部通过）：
  - Handoff 组 14 家：Drift Log 表格尾 → 既有空行 → 委派统计 11 行块 → 恰好 1 空行 → Handoff 标题
    （gap 检查 14/14 一致，interval = 表尾+1 为唯一空行，与主模板 :361-:375 结构同构）。
  - 尾部组 12 家：Drift Log 表格尾（=原末行）→ 新空行 → 委派统计 11 行块，文件以「委派率」表行 + \n 收尾
    （12/12 一致，无多余尾随空行；块前 1 行 = 空行 12/12）。
  - 即本批量插入布局与试点 bugfix、主模板 :363-:374 完全一致，无格式偏离，无需追加修正。

## M3 批量里程碑（T-2 批量② Handoff 登记表，12 家）
- 目标面实测：`grep -L 'Handoff' variant/*.md` = 12 行，与 knowledge-brief §2「T-2 缺项面：Handoff 12 家缺（v115 回流 video/image 族）」/
  S-unit 表 S3 行「12 家 v115 族」完全一致；mini-lite-type.md 未入缺名单（其 :44 既有简化版 Handoff 表 + Rule 38.3 设计豁免，未触碰）。
  名单（12 家）：audio-voice / multiview-ref / image / prompt-struct / final-assembly / physics-compliance /
  character-design / motion-camera / qc-defect / script-dev / video-prompt / storyboard。差异=无（12=12）。
- 源块：`sed -n '375,390p' 主模板`（16 行，md5=0b4d2d74f590726570de12afdbfe9e30）；
  插入块 = 空行 1 + 源块 16 = 17 行（`/tmp/insert-h2.txt`），逐字复制主模板实测文本，零自造。
- 插入点：全部 12 家委派统计区块（M2 尾部组产物）均位于文件尾部 ⇒ Handoff 插于文件末行后
  （`N=$(wc -l)`; `sed -i "${N}r /tmp/insert-h2.txt"`），复用于 M2 已验证的 sed 字节级拼接法；
  插后布局：委派率表行 → 新空行 → Handoff 16 行块（文件以 `| 3 | ... |` 行 + 双换行收尾，无多余尾随空行）。
- 逐文件复验（12/12）：`grep -q 'Subagent Handoff 登记表'` 全部命中；
  全量 `tail -17 <f> | diff /tmp/insert-h2.txt` = 12/12 BYTE-EXACT（本轮为全量字节 diff，非抽样）。
- 批量后复核：`grep -L 'Subagent Handoff 登记表' variant/*.md` = 空输出（28 家全齐；mini-lite 为简化版表，
  既已含 Handoff 词不属本批目标面，其 :44 简化表未动）。
- 纯插入性：本批 12 家 `git diff --numstat` 全部 29/0（17 行插入含 1 新空行 + 16 源行，0 删除行）；
  累计 `git diff --stat` = 27 files changed, 528 insertions(+), 0 deletions（含 M2 26×12=312 + 本批 12×17=204 + 试点 12）。

### Batch Report（Rule 18.6 八字段，S3 双采样）
- total=12 | success=12 | failed=0 | failure_rate=0%
- sampled_pass（运行后 10% 抽样 2 家）：image-type.md / video-prompt-type.md，
  `tail -17 | diff /tmp/insert-h2.txt` = BYTE-EXACT（且全量 12/12 亦逐文件字节 diff 通过，抽样为其子集）。
- sampled_fail（运行前 2 家）：audio-voice-type.md + multiview-ref-type.md，
  插入后 `git diff --numstat` = 29/0 × 2、字节 diff = BYTE-EXACT，0 家失败（未触发熔断）。
- pre_check：Q1 同类型文件互不影响（纯追加文件尾部，无共享行编辑）=否；Q2 存在可回滚 checkpoint（M1/M2 记录+git）=有；
  Q3 插入点错位可 `git restore` 单文件回滚=能。
- rollback_point：worktree HEAD（未 commit；单文件回滚 `git restore skills/task-planner/templates/variant/<f>`）。
- 改动范围确认：本批 12 家全部位于 `skills/task-planner/templates/variant/`，未触碰主仓、未动 mini-lite 简化表、
  未执行 git commit（按 S4 约束由后续步骤统一提交）。

## 最终结论（M3 追加）
- T-2 批量② 完成：12/12 家 Handoff 登记表补齐，纯插入 12×17=204 行，零自造、零删除。
- Phase 2 S3 验收判据：① grep -q 双区块（委派统计+Handoff）12/12 命中 ② 全量字节 diff BYTE-EXACT
  ③ Batch Report 八字段落盘本 checkpoint —— 全部通过。
- 下一步：主进程 Read 复核后进入 S4（worktree commit）与 Phase 3 回归。
