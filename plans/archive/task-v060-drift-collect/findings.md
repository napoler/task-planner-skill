# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户指令（2026-09-11）：「分析一下该技能中有哪些改进没有收录进当前代码，进行补充」→ ① 产出未收录改进分析清单 ② 将缺失改进收编进 canonical 仓库
- 约束：部署位只读（收编完成前禁写）；工作树隔离；收编后重部署对账 9 位

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| task-planner-repo-deploy-flow.md | ~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/ | ☑ | Research Findings #0 |
| v059 同构先例 | plans/task-v059-active-plan-race/ | ☑（INDEX/git log 级） | Research Findings #0 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### #0 漂移全景（主进程侦察,2026-09-11 06:0x）
- 9 部署位 diff 扫描：仅 `~/.zcode/skills/task-planner` 有 10 文件 differ，其余 8 位（task-planner claude/opencode 2 位 + companion 6 位）diff=0；plan-writer agent zcode 位 IDENTICAL，claude 位仅 model 行适配差异（预期）。
- 仓库 master 自 bb34bf2（v059 簿记,09-10）零提交；部署侧漂移 mtime 两批：09-10 22:43（6 文件）/ 09-11 01:35（4 文件），均晚于 v059 重部署批次（09-10 19:45,27 文件）→ 均为 v059 交付后的部署侧热修。
- 部署位 .git 无历史（"no commits yet"），方向判定只能靠 diff + 特征探针。

### #1 S1 子代理审计（general-purpose,检查点 subagent-state/01-gp-audit.md,评分 96/A）
- 落盘产出可用部分：10 文件逐文件 diff 全文审计、改进语义摘要、文档联动面清单、新增文件检查（**零 "Only in"**,无新增 selftest 文件）。
- 关键改进语义（经主进程复核采信）：
  - **09-11 01:35 批**：check-dispatch.sh 三级解析（env/自声明→enforce,未锚定→warn 降级,根治 B5 全局指针误拦）+ 文件身份判定（stat inode/realpath,bind mount 免疫,废除无效拼写别名）；zcode-sessionstart.sh 透传 TASK_PLANNER_SID + BASH_SOURCE 派生路径（废除硬编码绝对路径）+ gc stdout 抑制（保 hook 单行 JSON 契约）；README/SKILL.md 同步描述哨兵私有化 + task-path-identity。
  - **09-10 22:43 批**：check-scope.sh / plan-created.cjs / task-plan-init.cjs = **哨兵私有化（task-planrequired-race）的核心实现**（side 哨兵 + 双清除 + TASK_PLANNER_SID 降级链 + 原子写 + legacy 降级,文件头均带 `[2026-09-10 task-planrequired-race]` 注记）；resolve-plan-dir.sh / set-active-plan.sh 补 norm_sid 剥 sess 前缀（D11 四处 canon 对齐）+ gc 扩扫过期 side 哨兵；zcode-pretooluse.sh 透传 sid + B5 根因注记。
- ⚠️ **子代理"3 文件反向异常"判定被主进程探针推翻**：它判定 check-scope/plan-created/task-plan-init 部署侧是 08-29 旧版、仓库侧是进化版。第一手证据相反——`grep -c '_side'`：部署侧 6/2/5 处 vs 仓库侧 **0 处**；命中行原文显示部署侧含完整 `.plan_required_side/<sidkey>` 会话私有哨兵实现与 `[2026-09-10 task-planrequired-race]` 注记,仓库侧是 pre-race 旧版（全局 `.plan-required`、CWD 无脑写）。子代理把 diff 行归属读反。其检查点中「反向异常」三行的方向判定作废,改进语义描述（行内容本身）仍真实可用。
- 联动面（修正方向后仍有效）：① 仓库 `tests/selftest-dispatch.sh` T05/T12 断言基于旧 check-dispatch 语义（stdout `[dispatch-warn]`+计数文件、尾斜杠 normalize）,收编新版后预期失效须同批改写；② `references/critical-rules.md` Rule 22.9 需补 sess 前缀剥除 + gc 扩扫 side 哨兵条款,Rule 22.4 系需核对 warn 降级/身份判定措辞；③ docs/ARCHITECTURE.md 仅文件名列表,不阻塞。
- 佐证收编紧迫性：本会话 SessionStart hook 写的就是 side 哨兵（部署侧新版生产运行中）,而仓库零这些代码——若按旧基线重部署,哨兵私有化机制会被旧版打回,跨会话竞态（B1/B2/B4）复发。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 10 文件统一「部署侧→仓库」收编 | 主进程特征探针（grep side 语义 6/2/5 vs 0 + 命中行原文）为第一手证据;子代理反向判定与其自身引用的行内容矛盾,不采信 |
| 收编批次内自洽校验交 Phase 3 | 哨兵四件套（check-scope/plan-created/task-plan-init/zcode-sessionstart）必须同批收编（子代理 risk#4 采信）,拆开会造成写/清/查语义分裂 |
| selftest T05/T12 先跑后改 | Phase 2 已实证:worktree 拷入新版 check-dispatch.sh 后 selftest-dispatch 12/12 一次通过（warn 降级走 stderr 与旧断言兼容）,无需改写——审计阶段"必失效"推断不成立,先跑后改避免了盲改 |
| 联动范围收敛为 critical-rules.md 一文件 | 执行体核对部署侧 SKILL/README 新描述 vs 仓库 references 后仅 3 处矛盾/缺失（22.9 sess 前缀、22.9 gc 扩扫、22.4c warn 降级+身份判定）,各最小修订;docs/ARCHITECTURE.md 仅文件名列表不阻塞 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 子代理方向判定与第一手探针矛盾 | 主进程裁决性探针（grep 命中行原文两侧对照）一锤定音:部署侧前向领先;已在本文件 #1 记录判定依据 |
| task_plan.md 首次 Write 30s 超时（hook 首交互慢） | 核实未写入后原样重试成功 |
| attest 被 check-plan-dispatch 拦截（S2a 命名不匹配 `S<纯数字>` 正则） | S-unit ID 改纯数字编号后重锁成功 |

## Resources
- 检查点: plans/task-v060-drift-collect/subagent-state/01-gp-audit.md（含逐文件 diff 证据抽查）
- 部署位源: /home/terry/.zcode/skills/task-planner（只读）
- canonical: /mnt/data/dev/task-planner-skill/skills/task-planner

## Visual/Browser Findings
-（本任务无多模态输入）
