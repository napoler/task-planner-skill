# D 组规格：纪元 1-101 四位顶字面炸点级联（26 selftest 脚本锚点放宽）

> task-crossprojauth-20261104 R2/R3 收口回归前置。执行体=general-purpose（executor 通道 provider 拒，判例见 01-03 checkpoint）。
> 授权依据：用户 R4「完成任务 需要部署 并推送到github」+ 计划 scope_files 声明 selftest 级联面；写范围限 26 脚本锚点行（技能保护区内、计划声明范围内）。

## 背景（自包含）
- R2/R3 把 `skills/task-planner/SKILL.md` 顶字面 1-99→1-101、「其余 82 条」→「84 条」、task-discipline「共 50 条」→「51 条」。
- 基线证据：HEAD(fad95ed) worktree 回归 94/94 FAIL=0（见 regression-after-R3.txt 同目录 regbase 记录）；当前工作树 68 PASS/26 FAIL。
- 根因=纪元顶字面 4 位跨位（9[0-9] 天花板→1-100/1-101）炸 26 个 selftest 的宽容正则/字面锚；**非** Rule 100/101 内容错误（26 脚本的内容类断言全部 PASS，FAIL 行=锚点类，见 failing-assertions.txt 56 行）。
- 探针（基线 vs 当前 SKILL.md）：`1-[89][0-9]` 3→0；`Rules 1-9[0-9]` 2→0；`1-101` 0→3；`其余 8[0-4] 条` 2→2（本身宽容）。FAIL 脚本里显示 "'1-80'=0 应 ≥1" 的断言，实际 grep 的是 `1-[89][0-9]` 类模式（消息标签=历史遗留 stale，基线时 `grep -c '1-80'` 也是 0）。

## 统一修法（逐断言，语义不变）
1. 定位：`grep -n '<断言ID>' skills/task-planner/scripts/selftest-<name>.sh` 读断言行。
2. 「应存在」类顶纪元锚（宽容正则如 `1-(3[1-9]|[4-7][0-9]|8[0-9](...)|9[0-9](...))`、`1-[89][0-9]`、`Rules 1-9[0-9]`、`1-8[0-9]`、字面 label '1-80' 实指 `1-[89][0-9]`）：
   - 在替代式中追加 4 位纪元分支 `10[0-9]`（纪元按 10 年窗口放宽，1-101 命中；与历史放宽先例同风格——`[2026-10-11 task-v070 S10o 扩 81 纪元…]` 注释列）。
   - 负边界类（`(8[0-9]([^0-9]|$)|9[0-9]([^0-9]|$))`）同步给 `10[0-9]` 加 `([^0-9]|$)` 尾界。
   - **禁**直接硬编码新字面 `1-101`（零余量守卫反模式）；必须按十位窗口放宽。
3. 计数类（`其余 84 条`、`51 条`）：断言本身已宽容（`8[0-4]`）不动；硬字面（如某处 grep `82`）改十位窗口 `8[0-4]`。
4. 负断言（旧纪元残留=0 类：`1-39`=0、`1-40`=0、旧 `1-51`=0、`40-[5-8][0-9]`=0）：**一律不动**。
5. 消息文本（ok/bad 字符串里的字面如 '1-80'、'1-3x..99'）：同步为新纪元描述（`'1-101'`、`'1-3x..101'`），避免下纪元再误导。
6. 注释：该断言行上方/内联追加一条 cascade 注 `[2026-11-04 task-crossprojauth-20261104 R2/R3: 纪元 1-101 四位顶字面, 顶锚放宽 10[0-9] 窗口]`（对齐文件既有注释风格，不删旧注）。
7. SRV-12（selftest-summary-readability 的「9 级联脚本各自 PASS」元断言）：9 个级联脚本=absorption-discipline/context-pressure/lane-advancement/tool-selection/requirement-coverage/requirement-grading/research-first/root-resolution/self-resolution（读脚本 L168-184 for 循环清单为准）——修好这 9 个后 SRV-12 自动转 PASS，**不改** SRV-12 本身；但 SRV 脚本自己的锚（SRV-03 `1-(7[4-9]|[89][0-9]|8[0-9])` 等）按规则 2 修。
8. 特例裁决：若某 FAIL 根因不是纪元字面（而是内容行真被删，如 DCS-11 的「偏移检查子代理化」/「Rule 61」行缺失）：先 `git show HEAD:skills/task-planner/SKILL.md` 对照确认；内容行缺失=主进程补 SKILL.md 行（**你来执行**，一行补回，注明）；若判定应改 SKILL.md 正文以外的文件，**停止该断言**在 checkpoint 登记 cause=内容缺失+证据，跳过，主进程复核。
9. 每修完 1 脚本：`bash skills/task-planner/scripts/selftest-<name>.sh` 全绿（rc=0）才进下一个；FAIL 明细追加 checkpoint。

## 验收（全满足才完成）
- `bash skills/task-planner/scripts/run-selftests.sh` → `Total: 94 PASS=94 FAIL=0`（主进程复跑独立确认）。
- 26 脚本 diff 只含：锚正则扩展/消息文本/注释追加（`git diff --stat` + 逐行 review 口径，无断言删除、无阈值放宽、无正文改写）。
- checkpoint `04-executor-epoch101.md`：每脚本一行（脚本/断言ID/旧模式→新模式/rc）+ 总账（26/26 修复 + run-selftests 原始输出 Total 行）。

## 材料
- 本目录 `failing-assertions.txt`（56 FAIL 断言行，## 分节）
- 本目录 `regression-after-R3.txt`（run-selftests 全量输出）
- 本目录 `skillmd-diff-head-vs-working.txt`（SKILL.md 基线 vs 当前 diff）
- 基线探针文件 `/tmp/skillmd-baseline.txt`（HEAD 版 SKILL.md，只读参考）

## 强约束
- 写范围=26 个 `skills/task-planner/scripts/selftest-*.sh`（仅 FAIL 断言行及注释）+ 特例裁决 8 的 SKILL.md 单行补回（如有）。
- **禁**改：SKILL.md 正文其他行/critical-rules*.md 规则体/deliverables/smart-merge-back.sh/其余 68 PASS 脚本/run-selftests.sh 本身。
- 禁新增脚本/新 config 键。
- 本会话主仓=主工作树（非 worktree）直改——R2/R3 先例，计划声明 L0-T/受管任务授权内；无 git 操作（主进程提交）。
