动作摘要
1. 删除误插区块：从目标文件中删除从 `## Rule 104 子代理使用点显式标注纪律` 起、到 `### 104.6 例外 token 与统计口径` 段落全部内容结束的整个误插区块（原位于 Rule 96 与 Rule 103 之间，导致编号乱序）。删除后文件恢复为 96 段直接衔接 103 段。
2. 文件尾插入修正版：在 `### 103 双轮质检与同步完整性审查` 段最后一行之后，先添加一个空行，再逐字插入 `rule104-final.md` 全文（正确形态：`### 104 子代理使用点显式标注纪律` 主标题 + 注释头 + 正文行子条 `104.1-104.6`）。

修改文件清单
- /mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105/skills/task-dispatch/references/critical-rules-dispatch.md (+54/-~52 行)（删除误插的 52 行左右，追加 rule104-final.md 54 行）

验收证据（grep 输出原文）
$ grep -c "^### 104 子代理使用点显式标注纪律" /mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105/skills/task-dispatch/references/critical-rules-dispatch.md
1

$ grep -c "^## Rule 104" /mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105/skills/task-dispatch/references/critical-rules-dispatch.md
0

$ grep -nE "^### (96|103|104) " /mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105/skills/task-dispatch/references/critical-rules-dispatch.md
188:### 96 子代理激活默认档与并行推进强化（P0, 2026-10-24 task-subagent-boost-20261023，目标：①治「激活率低」——按可判定任务类别立激活默认档矩阵，主进程亲自执行收窄为例外白名单并登记理由；②治「并行推进率低」——计划期并行组硬标注 + 执行期同消息并发派发 + 两项指标留痕；判定面=LLM 行为+既有 attest/check-dispatch 既有档位（零新机器门、零新 config 键）；衔接 Rule 13/14/21.3/21.4/22.6/25/46/52/59.2/59.4/68，既有条款原文零改动、判定语义零改写）
275:### 103 双轮质检与同步完整性审查（P0 — task-dualqc-20261104，目标：子代理产出零带病交付+多文件修改零遗漏；判定面=派发型 S-unit 产出轮；衔接 84.4/84.7/96.2/22.3/74.3，原文零改动）
276:### 104 子代理使用点显式标注纪律（P0, 2026-11-05 task-subagent-markup-20261105，目标：把委派默认值从「模型临场自判」改为「显式标注告知」——104.2 使用点标注总表 15 动作类型+SKILL 就地速查+计划期 96 类别列+失败隔离硬阈值；判定面=LLM 行为+selftest 静态守护、零新 config 键；衔接 Rule 96/25.3/47.2/95，既有条款原文零改动）

$ grep -c "^104\.[1-6] \*\*" /mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105/skills/task-dispatch/references/critical-rules-dispatch.md
6

文件尾部 3 行（Read 确认 104 段完整收尾）:
104.6 **例外 token 与统计口径**

1. 偏离标注 token：`[markup-exempt] <一句话理由>`——104.2 表命中而主进程直做时登记；①-⑥ 白名单（Rule 25.3）理由继续有效且优先。
2. 机器消费边界（诚实披露）：check-delegation stats 现消费 ①-⑥ 编号（行内 447 口径），`[markup-exempt]` 为补充软通道**不改变硬门口径**；96.5 指标（激活子代理数/最大并行宽度）回填义务不变。
3. 守护锚：selftest-subagent-activation.sh SA-16+ 断言本条三载体在位（dispatch 全文/SKILL 速查表/模板列）——条款漂移=FAIL。

未完成项
无

检查点路径
/mnt/data/dev/task-planner-skill/plans/task-subagent-markup-20261105/subagent-state/S1-fix.md

风险
无。仅调整 Rule 104 插入位置与标题形态，未修改 96/103 段及文件其他内容。

下一步建议
无
