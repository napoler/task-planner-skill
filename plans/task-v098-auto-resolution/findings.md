# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户反馈原话（Rule 31.1 触发①，2026-09-30）：「我发现当前遇到问题不是想方设法的解决问题 而是更加倾向于将问题推给用户 我希望可以解决 我需的是自动处理问题的能力 而不是将无关紧要内容推给用户」
- 拆解：① 新增 Rule 41「问题自主消解与升级纪律」六子条（41.1 消解优先/41.2 升级四门槛/41.3 trivial 自主裁定/41.4 升级前置消解清单/41.5 打包呈报/41.6 零新键机制）；② selftest-self-resolution.sh 守护 + registry 登记；③ SKILL.md 四锚联动（C29/摘要行/两处括注）+ 行数级联；④ 仓根 .gitignore 增补 `.backup-*/`（41.3 首个消费示范，v097 CR P2-b 遗留）；⑤ 全量 selftest 0 FAIL → 合并 master → 3 位部署 IDENTICAL → worktree 清理
- 约束：interaction_mode: silent（/goal 自主会话延续）；code_review: required；isolation: worktree（基线 master@76168cb）；22.3/28/D6/Rule 39-40 原文逐字节零改动

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **升级点盘点（plan-writer grep -o 实测 2026-09-30，Rule 41 归因量化证据）**：SKILL.md — STOP×14、AskUser×6、等决策×2；critical-rules.md — STOP×23、AskUser×17、等决策×4、留用户×0。合计 66 处升级出口措辞、0 处「什么才配升级」门槛定义 → 直接原因（升级被当默认出口）成立
- **锚点核实（全部本会话实测）**：C28=SKILL.md:193；Rule 40 摘要行=:271；「Rules 1-39」字面=2 处（:241/:295，TS-05 断言=2 且 '1-40'=0，WF-10 四文档汇总 ≥6）；行数级联=selftest-skill-split.sh:41（≤433 task-v097 label 且 ≤558 上限）；critical-rules.md 联动锚 22.3=L151/22.7=L160/28.2=L249/28.4=L252-253/33.4=L305/35.6=L328
- **部署位核实**：三真实位=smart-merge-back.sh:377（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）；zcode/claude 两位当前与主仓 IDENTICAL（diff 实测）；.gitignore 为仓根文件不在部署槽
- **.gitignore 缺口实证**：`git check-ignore .backup-20260930-test` → NOT ignored（现行 `.backup/` 仅匹配该名字目录）；追加 1 行 `.backup-*/` 即闭环——v097 CR P2-b 遗留确认可自动修
- **基线**：master HEAD=76168cb；SKILL.md=433 行；critical-rules.md=402 行；config.json properties=40（零新键则维持）；全量 selftest 37 脚本 604/0（v097 终验，P1 复测定数）；冲突扫描信号①=plans/.active_plan(M)+本计划目录(??)，均与 scope 零重叠，②③④⑤无信号
- **SR 断言清单设计**（selftest-self-resolution.sh，对齐 selftest-tool-selection.sh TS-01..12 范式）：^41\.=6 / 41.2 含 G1-G4 / 41.4 含「已尝试清单」+「D6 硬停点语义保留不弱化」/ 41.3 含「直接做」+「留用户裁决」禁令措辞 / 41.6 零新键+properties=40 / SKILL 三锚 / Rules 1-39=2 且 1-40=0 / skill-split label task-v098 / registry 行存在
- **Rule 36.3 删除基线声明（P1 主进程登记,2026-09-30）**：本任务纯增量零功能性删除——预期 diff 面：critical-rules.md EOF 纯追加（既有 L1-402 零改动）/SKILL.md 四锚增改（deletions 仅允许 L241/L295 行内括注替换）/.gitignore +1 行/selftest-self-resolution.sh 全新/selftest-registry.tsv +1 行/selftest-skill-split.sh 断言值行内替换。删除性行为清单=**空清单**；执行期出现清单外 deletions 即越界（CR 专项核对点）。
- **P1 实测定数（2026-09-30 主进程）**：worktree 内全量 selftest 基线=37 脚本 **604 PASS / 0 FAIL**（与 v097 终验一致）；worktree porcelain=0；基线 commit=master@76168cb。

- **workflow dwfrun-9a720fe2 完成报告（主进程复核采信,2026-09-30）**：Wave1 条款（402→413,纯增 11）∥ SKILL 联动（433→435 净增 2,级联取 wc 实测）;Wave2 selftest 12/0+registry 39 行;Wave3 全量回归 world.run 执行;Wave4 独立评审 APPROVED（.sh 面）。主进程亲验: `^41\.`=6/C29=1/Rules 1-39=2/1-40=0/SR 12 全绿/registry rows=actual=38/全量 38 脚本 **616 PASS/0 FAIL**（修正 workflow 正则漏解析 6 脚本「====」格式 Total 行的 446 误值,FAIL=0 双口径一致）;attest sha 与 task_plan 当前内容一致（f8ae→7d5f 系 B 类重锁定,无外改）。证据: 检查点 02/03/04 + 主进程命令输出。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| D2（已裁沿用）: 纯增量 Rule 41 六子条，不改 22.3/28/D6/39/40 原文 | 41=后置纪律层经 C29 checklist 生效；Rule 36.5 纯增量；D6 硬停点语义零弱化 |
| 零新 config 键（41.6） | v087/v088/v097 同范式；properties=40 维持使 TS-12/WF-12 断言零改动 |
| .gitignore 入本任务 scope 作 41.3 消费示范 | 用户归因活例即此；1 行 trivial；仓根文件不进三部署位（生效路径=merge） |
| 主进程直做仅 P1/P4/P5（白名单①②③⑥）；P2/P3 派 executor(sonnet-1)+code-runner-agent(mini) | 条款措辞直接定义 D6 边界语义精度，禁降 haiku；机械回归走 mini |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 活例（归因输入）：task-v097 CR P2-b（仓根 .gitignore 增补一行 `.backup-*/`）被以「基建配置留裁决」推给用户 | 实为可自动完成的安全小修（trivial 1 行、非破坏性、计划内可授权）→ 本任务以 Rule 41.3 首个消费示范直接自动修 |
| 31.2 四维归因（主进程已裁，直接采用） | 现象=遇问题倾向 STOP/询问/「留用户裁决」而非穷尽自动手段；直接原因=升级点遍地但无「什么才配升级」门槛（66 处措辞 0 门槛）；根因=缺「问题自主消解」纪律层→各机制各自设停点→停点成本低于消解成本；类别=规则缺位（Rule 36.2 归因指向本体 → 修改提案合法） |
| **新缺陷（workflow 执行期发现,2026-09-30）**: check-delegation(enforce) 对 CreateWorkflow 子代理系统性误拦 Write/Edit——.session-owner=工作流 sid（sessdwfdwfrun…）而 hook input 取到的 session_id 为子会话自有 id 或 default,zcode-pretooluse.sh:30→check-delegation.sh:255「sid≠owner→子代理放行」分支永不命中 | rule41-writer 按纪律上报（未自助绕过）→主进程裁定假阳性拦截,批准 Bash heredoc 逐字等价写入+acceptance 全验+检查点登记误拦事件（ResolveWorkflowQuestion dwfq-9a720fe2-1,授权延伸至同 run 全部子代理）;**hook sid 管道修复登记 deferred（不阻塞本任务）——疑似 v096「派发守卫解析面」同族新变种** |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
