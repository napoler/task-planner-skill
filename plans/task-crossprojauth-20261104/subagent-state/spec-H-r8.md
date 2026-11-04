# spec-H R8 双修正面执行 spec（general-purpose 组，串行 S1-S7）

## 背景（自包含）

task-crossprojauth R8（用户 2026-11-04 原话「修正未完成的事情，以及上面需要涉及的 SOP 相关的修改也需要」）双修正面：
- **R8-a**：agent 执行体 SOP 侧补「47.6 抽检门」条款（§六 保护区已由用户原话显式授权；授权射程=条款追加，frontmatter/model/tools 与既有 SOP 章节零改动）。agent 文件**无源仓**，部署面=三位：`~/.zcode/agents/`（git 仓，pathspec 提交）/`~/.claude/agents/`（git 仓，pathspec 提交）/`~/.cursor/agents/`（非 git，仅落盘）。**三位 frontmatter 逐位适配（zcode=引号+`model: custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1`；claude=无引号+`model: sonnet`；cursor=无引号）——正文 SOP 三位一致。插入一律逐位 in-place Edit，禁止整文件 cp 覆盖（会毁 frontmatter 适配）。**
- **R8-b**：纪元顶锚 11x 窗口预放宽（源仓 `skills/task-planner/scripts/`，纯机械锚面，零语义变更；判据=fresh 94/94 + 当前 live 值 1-102/「其余 85 条」/`,96` 全 PASS）。

## 仓根与路径

源仓=/mnt/data/dev/task-planner-skill（`git status` 应干净除 plans/ 类 untracked；改动只允许 `skills/task-planner/scripts/*.sh`）。

## S1 R8-a 条款插入（6 文件：2 agent × 3 位）

插入位置=各文件「## 负结果报告」段**之前**（该段两 agent 都有，image 位 L68、video 位 L69 附近；逐位 Read 确认实际位置，不依赖行号）。

**video 位条款（`~/{zcode,claude,cursor}/agents/video-generation-executor.md` 三处插同块，逐字）**：

```
## QC 强制抽检门（Rule 47.6，task-crossprojauth R7 2026-11-04）
- 视频交付前必须关键镜头抽帧抽检（每镜 ≥3 帧：首/中/尾），用 image-understand 判读：
  - 缺陷清单（H 级=禁交付）：运动方向矛盾（如正常行驶场景出现倒车/反转、时序倒放、车轮反转）/ 主体一致性串戏（角色换脸、服装串帧、前后镜头人物不一致）/ 物理合理性（穿模、悬浮、重力矛盾）。
  - 证据落盘：抽帧文件路径 + 判读结论必须写入检查点（subagent-state/）；无抽帧证据的判读=QC 未做。
- 命中任一 H 级缺陷→按 47.5 自主迭代环重做（3 轮换一维：重抽/换词/调参，逐轮落盘淘汰理由），禁带病交付；3 轮不达标按 47.5 尾端带三件套（现状余量+依据+推荐项）上抛，禁裸选项平铺。
- 抽检未完成=返回消息禁称 COMPLETE（Rule 51.2 完成声称门联动）；「生成成功即交付」= 本门违规。
```

**image 位条款（`~/{zcode,claude,cursor}/agents/image-generation-executor.md` 三处插同块，逐字）**：

```
## QC 强制抽检门（Rule 47.6，task-crossprojauth R7 2026-11-04）
- 图片交付前必须逐单元抽检：按 Rule 50.5 原子验收条目表判读 + 常识缺陷抽检：
  - 缺陷清单（H 级=禁交付）：解剖/透视（多肢体、手形畸变、透视崩坏）/ 文字乱码 / 主体错位。
  - 证据落盘：抽检判读结论 + 被抽检图路径必须写入检查点（subagent-state/）；无图证判读=QC 未做。
- 命中任一 H 级缺陷→按 47.5 自主迭代环重做（3 轮换一维：重抽/换词/调参，逐轮落盘淘汰理由），禁带病交付；3 轮不达标按 47.5 尾端带三件套（现状余量+依据+推荐项）上抛，禁裸选项平铺。
- 抽检未完成=返回消息禁称 COMPLETE（Rule 51.2 完成声称门联动）；「生成成功即交付」= 本门违规。
```

验证口径：每位 `grep -c '^## QC 强制抽检门' agents/<agent>.md`=1；插入前后 frontmatter 区（L1-L9）`git diff` 零改动（zcode/claude 位可 `git diff` 直接看；cursor 位人工比对 L1-L9 不变）；既有章节（Role Definition/核心能力/前置检查/Workflow/禁止行为/证据要求/验证协议/负结果报告）标题各仍=1。

## S2 R8-a 部署位提交

- zcode 仓：`cd ~/.zcode && git add agents/image-generation-executor.md agents/video-generation-executor.md && git commit -m "feat(task-crossprojauth R8): image/video-generation-executor 补 47.6 QC 强制抽检门条款（frontmatter 零动）"`
- claude 仓：同 pathspec 同 message。
- cursor 位：仅落盘，不提交。
- 提交前各自 `git diff --stat` 确认改动仅限新增条款块（每 agent 文件 +约 8-9 行）。

## S3 R8-b 顶锚预放宽（源仓，逐文件 Edit，禁 sed 全仓批量）

放宽判据（机械同族=D 组 10x 窗口先例续 11x）：
1. ERE 族 `1-(8[0-9]|9[0-9]|10[0-9])` → `1-(8[0-9]|9[0-9]|10[0-9]|11[0-9])`（含带 `([^0-9]|$)` 尾缀的 AD-09/SA-11 形态）
2. BRE 并联族 `1-[89][0-9]\|10[0-9]` → `1-[89][0-9]\|10[0-9]\|11[0-9]`（DCS-11）
3. `Rules 1-(3[5-9]|[4-9][0-9]|10[0-9])` → `Rules 1-(3[5-9]|[4-9][0-9]|10[0-9]|11[0-9])`（skill-split 面+其 AD-12 pin 行同步）
4. `1-(3[5-9]|9[0-9]|10[0-9])` → `1-(3[5-9]|9[0-9]|10[0-9]|11[0-9])`（conclusion-discipline n35 面）
5. `1-(7[0-9]|[89][0-9]|10[0-9])` → `1-(7[0-9]|[89][0-9]|10[0-9]|11[0-9])`（AD-04 面）
6. `其余 8[0-9] 条` → `其余 [89][0-9] 条`（AD-10/SA-12b 两处+其余命中处）
7. **AD-12 pin 面必须同步**：selftest-absorption-discipline.sh L91-100 的 `_pin_lit`/`_pin_tol` 目标字面（11 处 pin）与兄弟脚本 live 主锚改法**逐字一致**（pin 断言的是兄弟脚本字面，两侧同时改否则 AD-12 必 FAIL）。
8. 负断言族（`1-39`/`1-40`/`1-51`/`1-53`/`1-55`=0、`40-[5-8][0-9]`=0 等负向守卫）一律不动。
9. 注释行：改动行的紧邻注释（含「顶锚放宽 10[0-9] 窗口」字样者）追加「[2026-11-04 task-crossprojauth-20261104-R8: 11x 预放宽]」短注；历史注释行不改写。

全量面确认（S3 前必跑）：`cd /mnt/data/dev/task-planner-skill/skills/task-planner/scripts && grep -ln '10\[0-9\]' *.sh` 得完整文件清单（本 spec 已知面：anti-deferral、subagent-activation、capability-persistence、context-pressure、absorption-discipline、conclusion-discipline、drift-check-subagent、reflect-verify、lane-advancement、tool-selection、requirement-coverage、self-resolution、source-anchor-discipline、research-first、skill-split + 其余 grep 命中者）——清单外命中按判据 1-6 同族处理，**非窗口类命中（如纯数字注释、config 键 53 等）不动并在检查点登记**。

## S4 R8-b 源仓提交

`cd /mnt/data/dev/task-planner-skill && git add <改动脚本 pathspec 逐个> && git commit -m "chore(task-crossprojauth R8-b): 纪元顶锚 11x 窗口预放宽（AD-09/AD-10/SA-11/SA-12b+AD-12 pin 族 11 处+十位窗字面族全仓随动，零语义变更，判据=fresh 94/94+live 1-102/85 条全绿）"`

## S5 R8-b 部署

放宽的脚本 cp 至 `~/.zcode/skills/task-planner/scripts/`、`~/.claude/skills/task-planner/scripts/`、`~/.cursor/skills/task-planner/scripts/` → 三方 `cmp` diff=0 → zcode/claude 仓 `git add <脚本 pathspec>` 同 message 提交；cursor 仅落盘。注意**只 cp 本次放宽的脚本**，禁整目录 cp。

## S6 回归

源仓跑 `bash skills/task-planner/scripts/run-selftests.sh --fresh`，判据=`Total: 94 PASS=94 FAIL=0`（run=94 reused=0）；FAIL≠0 立即定位（预期零 FAIL；若 AD-12 pin 因兄弟脚本字面差异 FAIL=pin 与 live 主锚改法不一致，按判据 7 对齐后再跑）。

## S7 全量自检与检查点

检查点=/mnt/data/dev/task-planner-skill/plans/task-crossprojauth-20261104/subagent-state/08-executor-r8.md，逐 S 落证据：
- S1：6 文件 `grep -c '^## QC 强制抽检门'`=1 各；zcode/claude 位 `git diff --stat` 仅 +N 行
- S2/S5：三位 cmp 对账 drift=0；提交 hash 各一
- S3：`grep -rn '11\[0-9\]' *.sh | wc -l` ≥ 30（全量面）；`grep -rn '10\[0-9\]\( \|' ' *.sh`（残留未放宽面）=0 清单；负断言族 grep 仍=原值
- S6：run-selftests 原始输出尾部
- 最终结论（全过/FAIL 项）

## 硬约束

- §六 保护区授权射程=两个 executor agent 的条款追加；frontmatter/model/tools 零改动，其他 agent 文件零改动。
- R8-b 零新脚本文件、零新 config 键、零 hook 改动；只改既有 .sh 内 pattern 字面与注释。
- 逐字稿条款块照抄（本 spec 内代码块即逐字稿，含围栏内全部内容）。
- 返回消息 8 字段范式（同 G 组）：①S1-S7 清单+证据 ②grep 结果 ③改动文件+行数增量 ④S3 面清单（grep -ln 全量 vs 已知面）⑤S5 cmp 对账 ⑥遗留/风险 ⑦检查点路径 ⑧结论。
