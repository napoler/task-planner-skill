# Merge Union Resolution Spec — task-v156 × master(v160/v162) 并集解规格

> 背景：worktree wt/v156-decision-alignment（我的 8 commit,base a538a3a）merge master（d45e8e2,含 Rule 72=v160/Rule 74=v162）后 7 文件冲突。
> 执行体任务：按本规格逐文件解冲突（删全部冲突标记）→跑全量回归→提交 merge。
> 总原则：并集=两侧内容全部保留,我的 v156 内容让位编号口径（C51→C53、计数「1-71+73」→「1-74」族）,禁删任何一侧条款/断言/注释（演进注释行全留）。

## F1 skills/task-planner/references/critical-rules.md（EOF 冲突 :947-1000）

- HEAD 侧=我的 Rule 73 块（### 73 …73.1-73.7）;master 侧=Rule 74 块（### 74）+Rule 72 块（## Rule 72 + 72.1-72.6）。
- 解析结果（数字序,删标记）：
  1. 先放 master 的 `## Rule 72（决策分级与用户打断纪律 — task-v160）`+72.1-72.6 整块;
  2. 再放我的 `### 73 执行期决策对齐与不变量纪律…` 整块,**但块头与 73.7 有两处口径更新**：
     - 块头「衔接 Rule 29/30/31/32/51/58/65/67/68/69/70 与在途 Rule 72（task-v160）」→「衔接 Rule 29/30/31/32/51/58/65/67/68/69/70/72（Rule 72 决策分级与用户打断纪律 — task-v160，管分级归属;本条管变更前对齐，互补）」;
     - 73.7 「合规清单 C51（SKILL.md 消费侧，C50 由 task-v158 占用本任务顺延）」→「合规清单 C53（SKILL.md 消费侧;C51=task-v158→实为 C50 之后由 task-v162 占用 Rule 74、C52=task-v160 占用 Rule 72,本任务顺延 C53）」——若嫌冗中保留语义:「合规清单 C53（SKILL.md 消费侧;C51/C52 已由 task-v162/task-v160 占用,本任务顺延 C53）」;
  3. 最后放 master 的 `### 74 变更吸收三判纪律…` 整块。
- 顺序=71(共同上文)→72→73→74;除上述两处口径更新外,两侧文本逐字不动。

## F2 skills/task-planner/SKILL.md（5 处冲突）

### :9 计数行
- 取 master 行,删「73 为编号预占空号,由 scripts/rule-reserve.sh …」子句（我落地后 73 不再是空号）;
- 结果行首=`- references/critical-rules.md: Critical Rules 全集 1-74（67-72/73/74 均经并行任务合流落地）(1-12 核心执行约束 + …`（master 行其余部分原样保留;精确改法:grep 定位 master 行含「预占空号」处,把「67-72/74 均经并行任务合流落地；73 为编号预占空号，由 scripts/rule-reserve.sh(后续至…)」整段替换为「67-72/73/74 均经并行任务合流落地」,行内其余文本不动）。

### :240 C 清单
- 保留 master 的 C51（Rule 74,v162）+C52（Rule 72,v160）两行;
- 我的行改号:`| C51 | 执行期决策对齐自查（Rule 73）：…` → `| C53 | 执行期决策对齐自查（Rule 73）：…`（行内容其余不动,含「机器面=selftest-decision-drift.sh…mini 档豁免」）;
- 三行顺序:C50→C51(74)→C52(72)→C53(73)。

### :312 详见行
- 取 master 行（`Critical Rules 1-74（含 Rule 40-74 全集，…`）;
- 在枚举尾部「Rule 71 无源不写·空段占位·写必带锚纪律」之后插入「、73 执行期决策对齐与不变量纪律」（若 master 行枚举里已有 72/74 条目则保持原序,仅补 73）;
- 行首「1-71+73」不保留（master 的 1-74 为上位口径）。

### :377 Rules bullet
- 两行都留:我的 `- **Rule 73（执行期决策对齐与不变量纪律 — task-v156）**：…` + master 的 `- **Rule 74（变更吸收三判纪律 — task-v162）**：…`（73 在前 74 后）;
- 另确认 master 侧 Rule 72 bullet（v160 加的那条）在文件中存在（自动合并区,勿动）。

### :408 References 表行
- 取 master 行（`Critical Rules 1-74（含 Rule 13-18/…`）;
- 在行末「…Rule 65 周期性回顾与前后对照）」前（或该枚举適當位置）追加「 / Rule 73 执行期决策对齐与不变量纪律」（用「 / 」分隔,与既有枚举分隔符一致;此行曾有的 `+Rule 73` 无分隔拼接是 Nit 已修形态,勿复原）。

## F3 scripts/selftest-drift-check-subagent.sh（DCS-11）
- 我的演进注释行保留,master 的演进注释行保留（两条都留,v156 在前 v162 在后）;
- 正则并集:`Rule 40-(69|71|73)(\+[0-9]+)? 全集` 与 master 的 `Rule 40-(69|71|74) 全集` → 合并为 `Rule 40-(69|71|73|74)(\+[0-9]+)? 全集`;
- ok/bad 消息文案更新为新正则描述（「Rule 40-(69|71|73|74) 全集（±+NN 形态）」）。

## F4 scripts/selftest-parallel-scheduling.sh（P-05）
- 保留 master 的 crit_max 两形态提取（`grep -oE '^(## Rule|###) [0-9]+'`）+master 的三行演进注释;
- skill_max 用我的宽容版（`Critical Rules 1-[0-9]+(\+[0-9]+)?`）;
- 我的演进注释行保留在 master 注释之后;
- 最终两行:
  ```
  crit_max="$(grep -oE '^(## Rule|###) [0-9]+' "$CRIT" | grep -oE '[0-9]+' | sort -n | tail -1)"
  skill_max="$(grep -oE 'Critical Rules 1-[0-9]+(\+[0-9]+)?' "$SKILLMD" | grep -oE '[0-9]+' | sort -n | tail -1)"
  ```

## F5 scripts/selftest-research-first.sh（RF-07）
- 共用行（RF-06 ge 行）两侧相同,取一遍;
- 我的 v156 演进注释行保留;pair 行取 master 结构但第二锚用宽容版:master=`"$(cntE 'Critical ...(truncated)" "$SKILL")"` 描述「1-74 全集」,我的=`"$(cntE ..."`（1-71(+N) 形态）——**并集判据=第二锚 grep 能同时命中「1-74」与「1-71+73」两种书写**:
  - 先 Read 两侧完整 pair 行,以 master 行的 cntE 正则为基础,把其中的计数正则（形如 `1-[0-9]+` 或 `1-74`）替换为 `1-[0-9]+(\+[0-9]+)?`（若 master 用的是 grep -c 形态同理）;
  - 消息文案=「RF-07 SKILL 双锚(bullet 全角括号+头注 1-NN(+N) 全集宽容锚)」;
  - 若两侧该行除正则外完全一致,直接合一。

## F6 scripts/selftest-root-resolution.sh（RR-09）
- master 两条演进注释+我的一条演进注释全保留;
- 主断言正则用我的宽容版 `Critical Rules 全集 1-[0-9]+(\+[0-9]+)?`（覆盖 1-74 与 1-71+73 两形态;master 的 `1-(5[3-9]|6[0-9]|7[0-4])` 为其子集,不保留双正则——只留一条最宽容）;
- ok/bad 消息更新为「…（现状 1-74）=1 且旧「1-51/53/55」残留=0」;负断言 m 行（1-(51|53|55)）两侧一致,保留。

## F7 scripts/selftest-registry.tsv
- 三行全留:我的 decision-drift 行+master 的 absorption-discipline 行+subagent-return 行（顺序=我的在前或按 master 文件既有顺序,均可,只要三行都在）。

## F8 scripts/selftest-decision-drift.sh（我的文件,无冲突但需随并集更新断言）
- DD-17:`cnt 'C51'`→`cnt 'C53'`,消息「SKILL C53 合规行」（与 F2 让位一致）;
- DD-21 宽锚 `1-7[0-9]` 不动（1-74 命中）;
- DD-16 `Rule 73` ≥4 不动（bullet 在）;
- 若 DD 集中还有其他断言引用 `C51` 或 `1-71+73` 字面,一并改为 `C53`/宽锚。

## 收尾（必做,按序）
1. `grep -rn '^<<<<<<<\|^>>>>>>>\|^=======' <worktree>/skills/` =0（无残留标记）;
2. `cd <worktree> && for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f" >/dev/null 2>&1; echo "$(basename $f) rc=$?"; done | grep -v 'rc=0'` =空（全 rc=0）;把全量结果写入 /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/regression-r3-v156.log（格式同基线:每行 `name rc=N | Total 行`）;
3. 特别跑 `bash skills/task-planner/scripts/selftest-decision-drift.sh`（DD 全 PASS,Total 行原文）;
4. 在 worktree 内完成 merge 提交:`git add -A && git commit --no-edit`（merge 提交信息保留 git 生成的）;
5. `git status --porcelain` =空;`git log --oneline -3`。
