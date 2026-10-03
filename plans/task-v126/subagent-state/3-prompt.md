# S3 任务书：新建 selftest-lane-advancement.sh 静态守护（task-v126 Phase 3）

你是 task-v126 计划 S-unit S3 执行体。任务：新建 selftest 脚本守护 Rule 49 全部落点 + registry 登记。

## 路径与范式
- 新脚本落盘绝对路径：/home/terry/task-planner-skill-worktrees/task-v126/skills/task-planner/scripts/selftest-lane-advancement.sh
- 范式参照（先 Read 其头 60 行与结构）：同目录 selftest-media-dispatch.sh——SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 函数（前缀编号）、每断言 What/Why 双层注释（Rule 45 注释纪律）、末行 Total 输出 `Total: N PASS=N FAIL=N` 格式、任一 FAIL exit 1、jq 缺失时键数断言打 SKIPPED 不 FAIL（打印提示行，fail-open 非静默）
- 脚本头注释四要素（范式对齐）：用途/输入/输出/依赖 + 一行注明「范式对齐 selftest-media-dispatch.sh，task-v126 S3 产出」
- registry 登记：同目录 selftest-registry.tsv 追加一行（TSV 四列制表符分隔，参照尾行 selftest-media-dispatch.sh 行格式）：脚本名 + 守护描述（Rule 49 单元线并行推进守护）+ 守护面（Rule 49 条款 / SKILL.md bullet+C34+推进括注+References / 零新 config 键）+ 锚清单分号分隔
- 禁止触碰 worktree 外任何文件；禁止改其他 selftest 脚本与既有 registry 行
- 计划三文件（只读对齐）：/mnt/data/dev/task-planner-skill/plans/task-v126/task_plan.md、/mnt/data/dev/task-planner-skill/plans/task-v126/findings.md、/mnt/data/dev/task-planner-skill/plans/task-v126/progress.md
- 你的检查点：/mnt/data/dev/task-planner-skill/plans/task-v126/subagent-state/3-executor.md

## 断言清单（LA-01..LA-14，变量命名与断言写法对齐 media-dispatch；CRIT=critical-rules.md，SKILLMD=SKILL.md，CONFIG=config.json）
- LA-01: CRIT 子条锚 `grep -c '^49\.'` 应 ≥5（断言五子条主体行在位；Why: 锁条款本体未裁剪）
- LA-02: CRIT 标题锚 `grep -q '^### 49 '`（Why: 章节识别锚，防降级为普通段落）
- LA-03: CRIT 语义锚 `grep -q '推进三条件'`（Why: 49.2 核心判定语义）
- LA-04: CRIT 语义锚 `grep -q '跨 Phase 前移合法'`（Why: 49.3 推进合法性落点）
- LA-05: CRIT 登记锚 `grep -qF '[advance]'`（Why: progress 前移登记行格式的条款内声明）
- LA-06: CRIT 边界锚 `grep -q '汇合点强串行'`（Why: 49.4 不干扰边界第一条）
- LA-07: CRIT 门控锚 `grep -q 'Phase complete 翻转语义不变'`（Why: 门控不弱化承诺的文本落点）
- LA-08: SKILLMD bullet 锚 `grep -q 'Rule 49（单元线多路并行推进'`（Why: Critical Rules 摘要列表联动）
- LA-09: SKILLMD 合规行锚 `grep -q '^| C34 |'`（Why: 合规清单联动，C34 是 Rule 49 消费点）
- LA-10: SKILLMD 执行循环锚 `grep -q '验收后推进检查（Rule 49）'`（Why: 步骤 2.5 行尾括注在位）
- LA-11: SKILLMD References 锚 `grep -q 'Rule 49 单元线多路并行推进）'`（Why: 文档表括号追加在位）
- LA-12: SKILLMD 主锚守护 `grep -c 'Rules 1-39'` 应 =2（Why: v126 不动主锚的承诺，防误改破坏 SR-07）
- LA-13: SKILLMD 负断言 `grep -c '1-40'` 应 =0（Why: 与 SR-07 同口径负断言）
- LA-14: CONFIG 零新键 `jq '.properties | length'` 应 =40（jq 缺失打 SKIPPED 不 FAIL；Why: 49.5 零新键声明与 43.4/44.4/47.4 同口径）

## 验收自查（执行后必须跑并贴输出）
- bash 新脚本全 PASS（Total: 14 PASS=14 FAIL=0 且 exit 0）
- wc -l selftest-registry.tsv 应 =46（45+1）
- cd /home/terry/task-planner-skill-worktrees/task-v126 && git status --porcelain 应仅两个文件（新脚本 untracked + registry modified）
- 结果写检查点 3-executor.md

## 返回格式（8 字段严格模板）
status: done|partial|failed
summary: 一句话产出
files_changed: 绝对路径清单
acceptance: 验收自查命令与结果
evidence: 关键输出原文粘贴
issues: 无或问题清单
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v126/subagent-state/3-executor.md
next: 建议下一步
