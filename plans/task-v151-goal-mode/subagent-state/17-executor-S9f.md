# 17-executor-S9f 检查点 — task-v151 第二轮 CR「建议增强 2 条」落地（S9b + S9d）

<!--
  WHAT: 按 15-code-reviewer-S9.md V1 表 b/d 行建议，主进程裁决落地两条增强（均落 66.2 行内追加，纯增量）。
  WHY: CR S9「必须修 0 条、建议增强 2 条全部采纳」；用户指令「完善一下条款」。
  官方基准: 09-goal-official-docs.md §1.1（单目标约束/子命令面）、§1.6（plan 模式冲突）、§1.5（goal 状态跨会话保留）。
  改动面: 仅 1 文件 1 行（critical-rules.md:852，+1/-1，66.2 仍=1 行单行长句）。
-->

## 改动前后 diff（worktree=wt/v151-goal-mode-2, 自 master ebb5fba）

### 改动前 66.2（852 行，尾句）
```
…禁止「技能已设置 /goal」「/goal 状态为…」类无第一手证据表述。
```

### 改动后 66.2（852 行，追加两段，分号连排，仍 1 行）
```
…禁止「技能已设置 /goal」「/goal 状态为…」类无第一手证据表述；多 goal 单元=任务级分解与证据源，**不作** /goal replace 轮替（官方：一个会话同一时间仅一个目标，且 goal 状态跨会话保留；消费方式裁决=只作证据源非轮替，轮替会丢审计链）；/goal 设定须已在执行模式（官方：计划模式与目标模式冲突，任务运行中无法设定——提示用户先切执行模式）。
```

- 增强 b（15:27/77）：66.2 末尾补术语区分句「多 goal 单元=证据源非 /goal 轮替」+官方单目标约束+跨会话保留+审计链裁决。
- 增强 d（15:39/78）：同落 66.2 末尾连排「/goal 设定须已在执行模式（官方 plan/goal 模式冲突）」提示（侵入最小处=66.2，非 SKILL C45，遵守「纯增量、禁改 SKILL/模板/1-65」边界）。

## 自验三行输出（原文）

```
$ grep -c '^66\.' skills/task-planner/references/critical-rules.md → 6（子条数不变）
$ grep -n '不作 /goal replace 轮替' 该文件 → rc=1（0 命中——该 grep 模式为无 Markdown 字面文本，
  而落地内容按 CR 原文含加粗标记「**不作**」；等价验证：
  $ grep -n '计划模式与目标模式冲突' → 852:（命中 1 处，66.2 行内）
  $ grep -c 'replace 轮替' → 1（唯一命中=66.2 行内，无残留）
$ bash skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh → 9 PASS/0 FAIL, exit=0
  （G-02 六子条锚=6 未回退）
```

## git diff --stat（worktree 内）

```
 skills/task-planner/references/critical-rules.md | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```
（符合任务书期望「仅 critical-rules.md 1 文件 +1/-1」；66.2 保持 1 行单行长句，追加两段分号连排）

## 约束核对

- [x] 仅改 1 文件 1 行，禁改既有 66.x 正文其他部分与 1-65（diff 确认单行变更）
- [x] 官方引句口径与 09 检查点 §1.1/§1.5/§1.6 一致（单目标约束/跨会话保留/plan-goal 冲突）
- [x] 不引入新 config 键、不动脚本与 selftest（G-08 零新键负断言 PASS）
- [x] 两增强同落 66.2 一行内（侵入最小处），未触碰 SKILL.md/templates

## 负结果报告

- 检查依赖文件: 09-goal-official-docs.md（官方引句基准）、15-code-reviewer-S9.md（CR 建议原文）、critical-rules.md 848-860（66 全链现状）
- 未发现冲突: 66.3「逐 goal 推进」/66.4 G 序调度与新增「证据源非轮替」句无矛盾（新增句正是对 b 行「术语同名易误读」的消歧，语义互补）；40.3 /goal 既有口径未动
- 排除风险: grep 自验模式 2 因 Markdown 加粗未按字面命中，已用等价 grep 确认落地位置唯一（852 行内）；selftest G-02 锚计数 6 不变，未破坏机器面
