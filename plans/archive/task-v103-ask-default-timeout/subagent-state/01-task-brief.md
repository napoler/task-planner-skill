# P2-S1 任务书: CRIT 追加 Rule 44（用户选择点默认项与自动超时裁决,task-v103）

任务: worktree 内 critical-rules.md EOF 前追加 Rule 44 节（44.1-44.4 四子条）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v103-ask-default-timeout/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v103-ask-default-timeout/skills/task-planner/references/critical-rules.md（当前 437 行,43.4 在 :437——44 节追加在文件末尾既有 Rule 43 区之后;动手前 `grep -n '^43\.' ` 实测末行确认插入位,若末区有尾部空行/注释按其形态处理）

## 硬约束
- 42.x/43.x/其他行零改动（diff 纯增,deletions=0）
- 禁「1-4x」越界字面（如「Rules 1-44」）;「Rules 1-39」字面 2 处不动
- 44.2 引用 41.3 不重述;只动该文件

## 追加内容（逐字使用,格式同构 43 节:节头行+44.1-44.4 各独立行）
```
### 44 用户选择点默认项与自动超时裁决（P1 — task-v103，目标：把「呈现即阻塞」变为「带默认与超时的非阻塞呈现」——给用户的所有选择点必设默认选项+自动超时,超时未答复自动按推荐默认项执行并登记裁决记录;判定面=LLM 行为、零新 config 键;与 41.3/43.3 衔接,原文零改动）

44.1 **呈现契约（默认选项 + 自动超时必带）**：凡向用户提供 2 个及以上选项的询问（含工具选项呈现/方案选型/裁决点）,必须：① 指定一个「默认选项」（推荐方案,排第 1 位并标注默认/推荐）;② 给出自动超时时长（**默认 5 分钟**,询问点可按任务性质声明覆盖值,登记于计划「自动超时默认项」行或询问文本）;③ 各选项附理由与权衡（选项呈现规范既有要求不变）。无默认选项的选项呈现=契约缺失,补全后再呈现。
44.2 **低区分度优先直接裁决（不问,41.3 衔接）**：候选方案**产出结果一致、仅步骤数/耗时/路径略有差异**（低区分度）时,不交用户选择——按 41.3 trivial 直接裁决（选已验证最优者,Rule 43.3 候选预验证衔接）,把裁决结果与理由登记进 Decisions/progress（不打扰=不询问,不是不记录）;确需询问时仍须按 44.1 带默认选项与超时呈现。41.3 的「直接做」纪律原文引用,本条不重述。
44.3 **超时自动选择（自动裁决记录必留痕）**：用户超时（未答复）时,不阻塞等待、不擅自降级——**按默认选项（推荐方案）自动执行**,并登记「自动裁决记录」五要素（超时值/推荐项/触发时间/裁决理由/被覆盖的未决选项）,写入 progress.md 对应 Phase 或 Decisions 区;后续用户答复与自动执行不一致时,按新答复调整（自动裁决=可撤回承诺,非锁定）,调整须留痕。不打断 ≠ 不留痕。
44.4 **机制（零新 config 键 — 与 42.5/43.4/42.6.4 同范式）**：判定面=LLM 行为（询问点的默认项/超时声明、低区分度判定、超时自动裁决,非机器触发;config.json properties=40 维持）；机器面=`scripts/selftest-ask-default-timeout.sh` 静态断言（RT-01..RT-09,对齐 SR/R 范式：44 四子条锚+用户原话锚「默认选项」「自动超时」「5 分钟」+C33 行+模板「自动超时默认项」行+零新键）；消费侧=SKILL.md 合规清单 C33;41.3/43.3/Rule 28/25 原文零改动。
```

## acceptance: 验收标准
1) `grep -c '^44\.' CRIT`=4（44.1/44.2/44.3/44.4）
2) 用户原话锚：「默认选项」≥3（44.1 三处）、「自动超时」≥2、「5 分钟」≥1、「推荐方案」或「推荐默认项」≥1、「按 41.3」引用=1（44.2）
3) `git diff --numstat` 纯增（deletions=0）;43.4 行与 EOF 前既有内容零变化
4) `grep -nE '1-4[0-9]'` 新增文本零命中
5) `wc -l` 记录新行数（437→约 446）
6) `git -C <wt> status --short` 仅该文件 M

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v103-ask-default-timeout/subagent-state/01-exec-p2s1.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
