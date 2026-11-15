# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1（目标）: 跨项目解决 markdown 编辑高频出错，机制性拦截/检测/回滚（逐字锚：`plans/task-mdedit-reliability-20261116/user-session-log.md#1`）。
- R2-R5（候选方向，手段）: ①更高级工具 ②JSON 作为中间件有效管理 ③编辑脚本等方案优化 ④编辑有效工具或引入已有工具规避错误风险（均来自 R1 原文子串）。
- R6（目标）: 错误频率极高，必须纠正（R1 原文子串）。
- 四类已知失败模式（用户输入/计划约束）: ①锚点失配反复重试烧时间 ②new_string 误删相邻内容（吞块，历史判例三犯）③多次编辑后状态混乱 ④python/sed 批量替换静默失配（判例 3 处）。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 用户逐字需求锚 | `/mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/user-session-log.md` | 是 | Requirements / 本文开头约束 |
| Rule 106/106.1a 纪律现状 | `/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md:722-760` | 是（计划期摘要） | Rule 106/106.1a 纪律现状要点 |
| 全局 markdown-editor 技能 | `/home/terry/.zcode/skills/markdown-editor/SKILL.md` | 是 | markdown-editor 现状与可扩展性 |
| task-planner 技能与脚本资产 | `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`, `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/` | 是（计划期盘点） | Research Findings（本地资产盘点预留/初步） |
| 外部工具/方案调研 | P1/S2-S4 执行期 WebSearch/WebFetch/GitHub 等 | 否（待执行） | Research Findings（外部对标预留段） |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 本地资产盘点（初步，P1/S1 深化）
- **task-planner 仓库结构**：仓库含 `skills/`（含 task-planner/task-discipline 等）、`scripts/`（kb-* 等）、`knowledge/`、`plans/`、`templates/` 生态；task-planner 计划/校验脚本位于 `skills/task-planner/scripts/`（如 `init-session.sh`, `attest-plan.sh`, `check-complete.sh`, `check-plan-dispatch.sh` 等），适合作为 Bun/TS 脚本与 selftest 落点候选（证据：本次 `find`/`ls` 输出，/mnt/data/dev/task-planner-skill）。
- **已知纪律但非执行器**：Rule 106 体系提供过程期文档修改复检与 todo 对齐纪律，但未提供通用“edit-ops JSON 事务执行器”工具；本任务目标是将高频编辑失败转为工具级拦截/检测/回滚（与纪律互补）。

### markdown-editor 现状与可扩展性（已读摘要）
- **来源**：`/home/terry/.zcode/skills/markdown-editor/SKILL.md`（frontmatter: `name: markdown-editor`, `model: haiku`；触发“编辑 md/改 markdown/整理文档/重写 README…”等）。
- **能力**：提供 Markdown 编辑原则（尊重原文风格、结构完整性、最小有效修改、语法最佳实践）、常见操作示例（增节/改段/重排标题/转列表/改 front matter）、单文件与多文件编辑工作流与 I/O 契约/中断处理；强调“Read 当前内容后再编辑”“确认路径存在”等流程性约束。
- **是否已有结构化编辑机制**：**无**。未见 edit-ops JSON 指令单、写前全量预校验（锚点存在性/唯一性/命中计数/冲突检测）、原子应用（全过才写）、回读验证断言输出、备份回滚执行器或静默失配强制失败机制的实现定义。
- **可否扩展复用**：**可扩展复用为触发与原则基座**。可在其上/并行接入专用 `md-edit-ops` 技能与脚本执行器：由技能负责意图→edit-ops 结构化表达与调用约定，由脚本负责校验/原子应用/回读/回滚；需在 P2 裁决“新建独立技能 vs 扩展 markdown-editor”并避免触发混乱。

### Rule 106/106.1a 纪律现状要点（已读摘要）
- **来源**：`skills/task-discipline/references/critical-rules-discipline.md:722` 起（Rule 106 标题），`:726`（106.1a），`:737`（106.5 基线组含 B1 引用 106.1/106.2/106.3）。
- **106.1 写后回读门（P0）**：受管文档每次修改后声称完成前须复检①修改点与意图一致②跨字段不变量链未破坏，并在 progress 记 `[recheck]`；区分“写入成功重读豁免”与“跨字段一致性复检不豁免”。
- **106.1a 结构文件插段纪律（P0）**：对 `##/###` 组织的结构文件插入前先 `grep -nE '^#{2,3} '` 确认锚点结构角色与目标位置；插入型 Edit 的 `new_string` 必须包含 `old_string` 锚行原文子串；每次插段后强制同命令复检段清单（段数守恒、无重复标题），违者当轮修复。判例：吞锚/重复标题类多犯被结构回读拦截。
- **与本任务关系**：106/106.1a 是行为与过程纪律，可降低部分插段/结构破坏风险，但依赖执行体自觉与人工/规则触发；无法系统性覆盖锚点失配重试、批量替换静默失配、多步状态机混乱等工具层问题。因此需工具级执行器补足“预校验+原子应用+命中计数+回读断言+回滚”。
- **其他关联**：106.2 派生值先定基准、106.3 同文件二次修改全量回归、106.4 验证对象=交付物本体、106.5 两组 todo 驱动对齐（P1/P4 接线时需保持协同不冲突）。

### 已知失败模式四条（问题定义与对策方向，待 P1/P3 细化）
| # | 失败模式 | 表现/风险 | 机制性对策方向（P2 裁决后定稿） | 证据/来源 |
|---|----------|-----------|-------------------------------|-----------|
| 1 | 锚点失配反复重试烧时间 | old_string 不唯一或上下文漂移导致 Edit 失败/反复尝试 | edit-ops 显式定位（结构锚/范围/hash/前后文约束）+ 写前唯一性与存在性预校验，不通过整单拒绝 | user-session-log.md #1；Edit 工具锚点机制（用户输入） |
| 2 | new_string 误删相邻内容（吞块，历史判例三犯） | 插段/替换吞掉锚行或破坏邻接结构 | 原子应用前后结构回读断言（段清单/锚行守恒/diff 形态）+ 备份回滚；与 106.1a 互补 | user-session-log.md #1；106.1a 判例摘要（discipline:726） |
| 3 | 多次编辑后状态混乱 | 改了什么/还剩什么不可追踪 | edit-ops step 状态与 apply-report（已应用/失败/跳过+hash+原因）形成可审计回执 | user-session-log.md #1 |
| 4 | python/sed 批量替换静默失配（判例 3 处） | 0 命中或非预期命中仍被视为成功 | 强制 matched_count/changed 校验，0 命中或计数异常即 FAIL 并阻断后续写入 | user-session-log.md #1 |

### 外部对标与方案调研（2026-11-16 计划期已回填，全文=research-external-tools.md）
- **研究全文**：`plans/task-mdedit-reliability-20261116/research-external-tools.md`（55 行，逐条带来源 URL；证据分级=已验证/初步/未验证）。
- **候选方向1 高级工具/成熟实现（已验证）**：Aider SEARCH/REPLACE 多块格式（匹配级联=exact→去前导空白→去首空行→`...` 段唯一计数；失败块带建议但**成功块已落盘、无事务回滚**）；Codex apply_patch（`*** Begin/End Patch`+`@@` 上下文，seek_sequence=exact→rstrip→trim→Unicode 归一、EOF 优先；顺序应用、失败带 delta，**无全量回滚**）。→ 业界两大主流方案均无原子回滚，「写前预校验+原子性」是真实缺口。
- **候选方向2 JSON 中间件（已验证）**：RFC6902 JSON Patch 顺序执行、任一步失败则整体不得视为成功（事务语义现成可借鉴）；RFC7386 受限（null/数组）；对自由文本 markdown 需锚点/AST 映射层 → 支撑「JSON edit-ops 指令单」方向（R3）。
- **候选方向3 编辑脚本（已验证）**：`git apply` 默认原子+`--check/--reject/--3way` 可控（防静默失配现成机制）；unified diff 灵活补丁可降错误。
- **候选方向4 引入已有工具（已验证契约/初步服务）**：Claude Code Edit 契约=精确唯一 old_string+必须先 Read+replace_all，社区有 tab/space 失配实证；Morph/Relace fast-apply 页面可达但内部匹配/回滚契约未公开（未验证+外部服务依赖）→ 不作主干，至多未来加速层。
- **对比矩阵输入（P2）**：四失败模式确定性最强组合=「结构化指令单 + 写前唯一性预检 + 原子应用或可追踪 delta + 回读断言 + 版本化回滚」；模型式 fast-apply 需额外校验层。
- **Handoff 双锚**：findings 本段 ｜ kb 蒸馏待 P2 复核点（Rule 62.5 增量门控）；证据=research-external-tools.md 全文。

### edit-ops 设计定稿（P2/S1-S3，2026-11-16 主进程裁决）

**① 四候选方向评估矩阵**（能力/风险/跨项目复用/实现成本）：

| 方向 | 四失败模式覆盖 | 原子性/回滚 | 可观测性 | 跨项目复用 | 实现成本 | 裁决 |
|------|----------------|-------------|----------|------------|----------|------|
| ① 引入现成工具（Aider SEARCH/REPLACE、Codex apply_patch 格式适配） | 部分（失配有归一降级，但无唯一性硬校验/无结构断言） | **无**（部分提交，源码已验证） | 中（报错带建议） | 需移植实现，格式绑定 LLM 输出 | 高 | 不作主干：核心缺口（回滚/原子）恰是其短板 |
| ② JSON edit-ops 指令单 + 本地执行器 | **全覆盖**（设计目标=预校验/原子/回读断言/回滚） | **强**（全过才写+备份回滚） | **强**（per-op apply-report） | 强（纯本地零依赖） | 中 | **(Recommended)**：用户方向②③的合流，吸收①契约经验 |
| ③ 纯脚本优化（sed/python 命中计数强化） | 弱（仍无结构断言/事务） | 弱 | 弱 | 中 | 低 | 被 ② 吸收：执行器本身就是受控脚本，消灭裸 sed/python |
| ④ 外部 fast-apply 服务（Morph/Relace） | 未验证（内部匹配/回滚契约未公开） | 未验证 | 弱 | 弱（网络+费用+供应商锁定） | 低 | 拒绝入主干：未验证+外部依赖；未来可作可选加速层 |

**② edit-ops 指令单 schema v1（定稿）**：文件 `<name>.edit-ops.json`——
```json
{
  "version": 1,
  "description": "本批次编辑一句话说明",
  "base_hashes": {"<相对路径>": "sha256（可选；声明即强制校验，不符=陈旧指令单整单拒绝）"},
  "ops": [
    {
      "id": "op1",
      "op": "sub | insert_after | insert_before | replace_range | delete_range | append | prepend",
      "file": "目标文件相对路径",
      "anchor": {"type": "exact | regex | heading", "value": "锚文本/模式/标题路径", "expect_count": 1, "occurrence": 1},
      "end_anchor": {"type": "...", "value": "...", "expect_count": 1},
      "old": "仅 sub：被替换原文（逐字）",
      "content": "new/插入/替换后的内容",
      "expect": ["应用后该文件必须命中的正则（可选多条）"]
    }
  ]
}
```
锚点语义：`exact`=逐字子串；`regex`=正则；`heading`=markdown 标题行（`^#{1,6} `精确匹配）。`expect_count` 缺省 1：命中数≠expect_count → 该 op FAIL（0 命中与多命中同等对待，根治静默失配）。

**③ 执行器七步流水线（语义定稿）**：
1. **load**：JSON 解析+schema 校验（失败 exit 2，零写入）
2. **staleness 门**：声明 base_hashes 时逐文件 sha256 比对，不符 exit 3（防多次编辑间状态漂移/陈旧指令单）
3. **预校验（纯内存，零写入）**：逐 op 锚点计数校验；任一 FAIL → 整单拒绝 exit 4，报告输出全部 op 的 matched 计数（一次性看全貌，不再逐个试错）
4. **模拟应用**：内存中对当前内容顺序应用全部 op 得新内容（sub 先校验 old 命中 expect_count）
5. **回读断言（对模拟结果，对应 Rule 106.1a 结构守恒）**：(a) 标题段清单（`^#{1,6} `）变化量=各 op content 中标题行净增数（解释性守恒）；(b) insert 类 op 后 anchor 原文仍存在且计数不变（锚行保活防吞锚）；(c) expect 正则逐条命中；(d) 多文件一致性。任一败 → 整单拒绝 exit 5
6. **原子写盘**：先备份（`--backup-dir` 缺省 `<file>.edit-ops-bak`）→ temp 文件写 → rename；多文件顺序写，中途失败 → 已写文件从备份回滚（exit 6）
7. **apply-report**：JSON 报告（per-op {id,status,matched,line_range,error} / per-file {before_sha,after_sha,backup} / summary）输出 stdout + `--report` 落盘；exit 0=全成功。`--dry-run` 只跑 1-5 步零写入。

**④ 技能形态裁决**：新建 `skills/md-edit-ops/`（SKILL.md + scripts/md-edit-ops.ts + selftest）；markdown-editor 保持原则基座不动（P4 仅加指针行最小增量）；运行时=Bun 首选 + `node --experimental-strip-types` 兼容（仅类型注解，禁 enum/装饰器/外部依赖，仅 node:fs/node:crypto/node:path）。
**⑤ 与 Rule 106 协同**：工具级「预校验+原子+回读断言+报告」承载 106.1/106.1a 的机器面；技能指引使用者将 apply-report 路径记入 progress `[recheck]` 行——纪律条款管触发与留痕，工具管执行与拦截，不重复不缺位。
**⑥ 设计裁决登记**：本段结论同步 task_plan.md Decisions 表；实现细节裁量权授予 P3 执行体（schema 字段命名微调、报告字段增删），语义七步与 exit code 契约为硬约束不得收窄。

### P3 实现结论（2026-11-16，general-coder 产出+主进程盘上复核）
- **产物**：worktree `skills/md-edit-ops/`（md-edit-ops.ts 638 行 + SKILL.md 84 行 + examples 35 行）；Bun v1.4.0 优先、node v22 --experimental-strip-types 兼容实测通过；仅类型注解/仅 node:fs,crypto,path，零三方依赖。
- **验收复核（主进程亲跑）**：A2 零态正例 exit 0+变更命中；B 0 命中 exit 4+零写入（sha256 前后一致）；F 多文件回滚 exit 6+f1 hash 还原；同单重放已应用文件=exit 4+before==after（陈旧守卫/幂等自证）。coder 自测 C/D/E=exit 4/5/3（检查点实录，主进程抽验覆盖同路径）。
- **实现裁量决策（执行体登记）**：①file 相对路径以指令单所在目录为基准（examples 跨目录可复用），支持绝对路径；②预校验失败仍报告全部 op 的 matched（一次性看全貌）；③标题净增守恒按逐 op removed/added 模拟推导，兼容七种 op；④写盘按文件去重顺序，中途败从备份回滚全部已写文件。
- **风险登记**：regex 锚/expect 用 JS RegExp（极端正则回溯风险，当前场景可接受）；回滚为尽力恢复（备份窗口被外部破坏时可能不完整，已由写前备份+顺序回滚缓解）；heading 锚全行精确匹配（尾随空格需调用方精确给值）。
- **证据**：`plans/task-mdedit-reliability-20261116/.p3-coder-checkpoint.md` + progress.md Phase 3 Test Results 表（主进程复跑实录）。

### P5 selftest 与实弹冒烟结论（2026-11-16，code-runner 产出+主进程亲跑复核）
- **selftest**：`skills/md-edit-ops/scripts/selftest-md-edit-ops.sh` 12 场景/52 断言，bun 26+node(strip-types) 26 双运行时 **PASS 52/52 FAIL=0**（主进程亲跑复核 RC=0，非仅自报）；已按仓内惯例登记 `skills/task-planner/scripts/selftest-registry.tsv`（worktree 内）。
- **实弹冒烟（真实 md 全往返）**：worktree README_zh.md → 指令单（真实段 insert_after+真实句 sub）→ dry-run exit 0 零写入（sha 一致）→ 正式 apply exit 0 两变更落地 → 逆序单还原 → diff 无差异+sha 复原一致。**机制闭环实证：编辑→校验→应用→可逆**。
- **语义澄清（登记为对齐非缺陷）**：⑦「标题守恒」实现为解释性守恒（变更可被 ops 内容解释即合法，显式删标题 exit 0），与 P2 设计「变化量=op 标题净增数」一致；「非预期净变」（如 insert 吞锚行）仍 exit 5 拦截（断言⑧实证）。禁破坏性删除由 Rule 74/99 纪律面承载。
- **残留风险**：回滚注入依赖 chmod（特殊 FS 可能需替代法，低）；⑦语义如需更严口径属后续任务裁量。
- **证据**：`.p5-checkpoint.md`（selftest 尾部+冒烟全程实录）+ progress.md Phase 5 Test Results。

### P4 接线结论（2026-11-16，code-assistant 产出+主进程抽查复核）
- **纪律面落位**：task-discipline `critical-rules-discipline.md:741` 新增 **Rule 106.6 结构化编辑工具指针（md-edit-ops）**——批量/结构化 markdown 修改优先 edit-ops 指令单、apply-report 记 `[recheck]`、裸 sed/python 0 命中即 FAIL、单处小改守 106.1/106.1a。至此**纪律（106 触发与留痕）+ 工具（md-edit-ops 执行与拦截）双轨合流，无重复无缺位**。
- **接线点**：md-edit-ops SKILL.md:79 ↔ 106.6 互引；task-planner spec-mode.md:37 使用点指针（选点=registry/scripts 零引用低风险区）；技能索引 SKIP（仓内无 catalog 文件——P6 部署位同步时按部署位实际形态处理）。
- **结构安全证据**：`^#{2,3}` 段清单 66→66 守恒、Rule 107 起始唯一；4 项 discipline 关联 selftest 实跑全 PASS、未改断言。
- **口径说明**：106.6 为正文子条非标题行——heading 层守恒（66→66）与子条层 +1 两口径均成立，已在 checkpoint 双证据披露。
- **证据**：`subagent-state/p4-checkpoint.md` + progress.md Phase 4 Test Results。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 计划期采用“本地证据先行 + 外部真实调研补证” | R1 为跨项目工具级目标，需对标现有工具与模式避免重复造轮子；本地先确认 Rule 106/markdown-editor 基线 |
| P2 初步推荐混合方案（JSON edit-ops + Bun+TS 执行器 + 技能接线） | 单一候选难覆盖四痛点全链路；混合可兼顾表达力(R3)、自动化校验/回滚(R4/R6)与复用接线(R2/R5)，待 P1 证据定稿 |
| 实现期优先 Bun+TS 与仓库脚本生态对齐 | 符合环境与脚本优先级约束，便于 selftest 与多环境部署 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| （计划期暂无） | - |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- `/mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/user-session-log.md`（R1 逐字锚）
- `/mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md`（计划与 VC）
- `/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md:722-760`（Rule 106/106.1a）
- `/home/terry/.zcode/skills/markdown-editor/SKILL.md`（全局编辑技能现状）
- `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`（task-planner 架构/流程）
- `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/`（脚本落点与 selftest 约定参考）
- `/mnt/data/dev/task-planner-skill/knowledge/entries/worktree-lifecycle-mergeback.md`（部署/合并先例参考，P6 深读）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
