# Findings & Decisions — task-v123（Rule 48 交付总结可定位性与实用性）
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话（2026-10-03）：「当前的完成任务后的展示总结存在严重的缺陷 比如 让人审查接下来做什么时候 竟然不包含 审查内容路径或者网址 让人完全不知道到哪里审查 类似 的缺陷不一一列举 我希望的是完成总结可以更加实用」
- 拆解：① 交付总结（delivery summary）指认性信息必须可定位——审查/行动对象须带路径或网址；② 「类似缺陷不一一列举」= 要求系统性审计而非单点修补；③ 目标态=「更加实用」：每条指针/建议可被用户直接打开或执行

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 现行交付总结模板 | `skills/task-planner/templates/delivery-summary.md`（46 行） | ☑ 2026-10-03 | Research Findings 缺陷清单 D1-D9 |
| 真实总结实例 ×3 | `plans/task-v120/delivery-summary.md`、`plans/task-v112/delivery-summary-sample.md`、`plans/task-v118/delivery-summary.md` | ☑ 2026-10-03 | Research Findings 缺陷清单（实际证据） |
| SKILL.md 锚点 | `SKILL.md:9/:158/:247/:305`（行号 2026-10-03 08:53 实测） | ☑ 2026-10-03 | 级联锚清单 |
| 守卫范式 | `scripts/selftest-template-lifecycle.sh:22-24,90-96`（TL-19/20/21） | ☑ 2026-10-03 | TL 定义段 |
| Rule 块范式 | `references/critical-rules.md` L438-483（Rule 44/45/46 写法） | ☑ 2026-10-03 | D3 定稿区 |
| 部署脚本语义 | `scripts/smart-merge-back.sh:348-470`（--deploy 两级对账） | ☑ 2026-10-03 | Research Findings 部署拓扑 |
| 并行会话面 | `plans/task-v122/task_plan.md`（Rule 47 在途）+ `git worktree list` | ☑ 2026-10-03 | Research Findings 协调记录 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### A. 规划期一手侦察（主进程，2026-10-03 08:30-08:55）

**A1. 交付总结缺陷清单 v0（以现行模板 + 3 份真实实例为证据）**

| # | 缺陷 | 现行证据 | 修法（Rule 48 落点） |
|---|------|---------|---------------------|
| D1 | §3 指针用裸文件名，无路径 | 模板 L29「指针: verification.md Goal Gate 段」；v120 总结 L3「机器档案: 本目录 verification.md / progress.md」 | 48.2 指针形态硬规则 + 定位栏（绝对路径） |
| D2 | §5 行动项无对象定位 | 模板 L43 仅「一句话可执行」；v120 总结 L35「实战观察 1-2 周」（观察什么/在哪观察未给） | 48.3 行动项定位三要素 |
| D3 | §4 待裁决无对象定位 | v112 sample L33「部署同步：合并回后是否同步 ~/.zcode/skills/task-planner 部署位」未给目标文件路径/核查命令 | 48.3/48.4 |
| D4 | §4 回滚方式带未解析占位符、无仓库上下文 | 模板 L40「git revert <merge-hash>」原样输出风险 | 48.4 可执行回滚 |
| D5 | §2 位置列形态混用不可定位 | v120 总结 L13「位置: master 6961857」（不可点击/不可定位到文件） | 48.2 + §2 路径形态要求 |
| D6 | 无「快速复核入口」——用户无法最快自检关键结论 | 模板 §3 全为叙述性验证信息（无命令） | 48.4 快速复核入口 |
| D7 | 部署位信息非常规项（3 实体位拓扑下用户最关心之一） | 模板零提及；v120 §2 有（个别行为非约定） | 定位栏（部署位字段） |
| D8 | §1 无「行为面变化」——用户不知道对自身意味着什么 | 模板 §1 三行全为过程/结论 | §1 行为面变化（48 配套） |
| D9 | 机器档案路径仅相对（「本目录」），跨会话/多任务下无法定位 | v120 L3 同 D1 | 定位栏（机器档案绝对路径） |

**A2. 级联锚清单（改前扫锚，v117/v118 教训）**

| 锚 | 位置 | 本任务影响判定 |
|----|------|---------------|
| T-主 SKILL 行数 `≤444` | `selftest-skill-split.sh:41` | 4 处 SKILL 编辑一律**行内替换保零净增**；P2 后 `wc -l` 复核 |
| TL-19 五区块 `^## [1-5]\.` =5 | `selftest-template-lifecycle.sh:92` | 升级保持 5 区块；定位栏用 blockquote 不占序号 |
| TL-20 SKILL `delivery-summary` ≥2 | 同脚本 :94 | 行内替换不删既有两处提及 ✓ |
| TL-21 template-guide 口径句 | 同脚本 :96 | 不涉及（plan-template-kit 不动） |
| frontmatter「Critical Rules 全集 1-46」 | `SKILL.md:9` | 改 1-48（48∈1-4[5-9] 预扩窗口） |
| PT-08 `1-4[5-9]` 宽容锚 | `selftest-plan-tier.sh:77-78` | 1-48 匹配 ✓ 无需改 |
| RT-08 越界 1-4x 零命中 | `selftest-ask-default-timeout.sh:65-69` | 禁写「1-4x」字面；「1-48」在加白窗 ✓ |
| CD-12 n35+n45 ≥3 | `selftest-conclusion-discipline.sh:68-70` | ≥3 无上限，1-48 增量 ✓ |
| registry 43 脚本（44 行 tsv） | `selftest-registry.tsv` | 不新建脚本 → 零动 |
| templates/ 计数锚 35（knowledge-brief 头注，template-guide §2.4 口径） | `template-guide.md` | 升级不新增被计标题（只加注释/blockquote/表格行） |
| `### 44/45/46` 块与 `47` 在途 | `critical-rules.md` L438-483 + v122 | 块级追加；47 由 v122 落地（编号避让见 D5） |

**A3. 部署拓扑与合并机制**
- 3 实体位：`~/.zcode/skills/task-planner`、`~/.claude/skills/task-planner`、`~/.config/opencode/skills/task-planner`（现均 29 variants + SKILL 444 行，与 master b07c0cb 一致）
- `smart-merge-back.sh <wt> --deploy`：预检→已合并检测→`--no-ff` 合并→逐位两级对账（L1 文件集合差 / L2 内容定向 diff，基准=主仓 `skills/task-planner`）+ 原子替换（.bak.$$→tmp→slot）；任一 DRIFT exit 6
- 部署前方向审计硬门（v120 VC-5 范式）：部署位现文件 ≡ master 基线（无未收编前向更新）方可覆盖

**A4. 并行会话协调记录（task-v122，2026-10-03 活跃）**
- v122 = 「Rule 47 媒体制作任务派发纪律」（媒体拆分轴/具名执行体路由/批量试点先行/零新键），worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v122`（08:33 建立，计划 08:54 仍活跃更新）
- 重叠面：`SKILL.md`（:9/:247/:305 同区行）、`references/critical-rules.md`（各自尾部追加块）
- 处置：①编号避让——本任务取 **Rule 48**（47 归 v122）；②编辑最小化——块级追加/行尾追加；③合并冲突解决口径=「46/47/48 序并存」（乱序合并均收敛）；④v122 若终止 → 47 缺口登记由后续任务回填（FMEA 已登记）

### B. S1 普查回填（Explore，2026-10-03 10:52 返回，20/20 PASS；主进程三证据验收：返回证据 + 抽查 template:28/:39/:40/:43 与 v120:3 逐行复核一致 + 联动面 grep 复跑）

**B1. 缺陷清单核验（D1-D9 全部确认 — 逐条 file:line 证据）**
- D1 确认：模板 `:28`「指针: verification.md Goal Gate 段」裸文件名（主进程复核 ✓）
- D2 确认：模板 `:43` 行动项仅「一句话可执行，含触发条件」，缺定位三要素
- D3 确认：模板 `:39` 待裁决条目缺对象定位
- D4 确认：模板 `:40` 回滚含 `<merge-hash>` 未解析占位符（主进程复核 ✓）
- D5 确认：`plans/task-v120/delivery-summary.md:3`「机器档案: 本目录…」相对指代
- D6 确认：模板缺「快速复核入口」
- D7 确认：模板缺「部署位」字段（定位栏无）
- D8 确认：模板 `:13-17` §1 缺「行为面变化」
- D9 确认：v120 `:3` 相对路径（与 D5 同源：跨会话不可定位）

**B2. 级联锚核验（逐项判定「改前成立、改动须保持」）**
- `T-主`：SKILL.md=444 行；`TL-19`：五区块=5；`TL-20`：SKILL 提及 delivery-summary=2；`TL-21`：template-guide.md 含 delivery-summary.md —— 四锚基线成立
- `frontmatter` `:9`「Critical Rules 全集 1-46」；`PT-08` 检 `1-4[5-9]`（1-48 兼容）；`RT-08` 越界 1-4x 零命中（禁写 1-4x 字面）；`CD-12` n35+n45 ≥3；`registry`=44 行（43 脚本）；`templates/计数锚`=35 —— 判定：本任务改动面无冲突，仅须保持
- `### 44/45/46` 块在 `references/critical-rules.md` L438-483（Rule 48 追加点确认）

**B3. 联动面 grep（S1 建议 + 主进程复跑）**：`examples.md`、`docs/`、`companion/` 对「delivery-summary|交付总结」**零命中** → 无额外联动文件（skill split 后这些面板不含交付总结表述）。

**B4. D2/D3/D4/D5 定稿冻结（S1 审计后）**：S1 全部确认 D1-D9 无修订需求 → D 定稿区按 v0 冻结（S3-S6 依此实施）。

### C. S2 基线回填（executor 改派执行，2026-10-03 12:46 返回；主进程逐行求和复核 ΣPASS=676 + template-lifecycle 抽查 21/21 一致）

**基线（2026-10-03，worktree wt/task-v123 @ b07c0cb，43 脚本）**：43/43 rc=0，ΣPASS=**676** ΣFAIL=**0**（逐脚本 Total 行原文见检查点 `subagent-state/2-executor.md` 最终结论段；原始留档 `/tmp/task-v123-s2-results.txt` 385 行；scripts/ 零改动、porcelain 空）。
**回归对比基准锚（VC-4 失效判据）**：改动后须 43/43 rc=0 且 ΣFAIL=0；断言总数因 TL-22/23/24（+3）预期上移 → **ΣPASS 676→679**（43 脚本数不变；skill-split 因 SKILL 行数不变保持 41）。
**改派登记**：code-runner-agent（mini）provider 拒绝 ×1 → fallback probe 无健康通道（ok=0/failed=0）→ Rule 22.3① 改派 executor(sonnet-1)（v118 同型先例）。

### D. Phase 2 落地记录（S3-S5）

- **S3（executor，12:54 返回）**：`templates/delivery-summary.md` 按 D2 定稿逐字节覆盖写入（`cmp` VERBATIM_OK），46→67 行（+32/-11）；六锚全命中（可定位性硬规则/反模式/定位三要素/定位栏/快速复核入口/行为面变化）；五区块计数=5；`selftest-template-lifecycle.sh` 单跑 21/21 FAIL=0（TL-19/20/21 未破）。主进程验收：Read 成品逐行复核 ✓。
- **S4（code-assistant，12:57 返回）**：`SKILL.md` 4 处行内替换（R1/R1b/R2/R3/R4 逐字按 D4），+4/-4；四锚全命中（可定位性（Rule 48）/ 全集 1-48 / 46/47/48 / Rule 48 交付总结可定位性与实用性）；`wc -l`=444 保持；`selftest-skill-split.sh` 41/41 rc=0。主进程验收：git diff 逐行复核与 D4 一致 ✓。
- **S5（executor，13:01 返回）**：`references/critical-rules.md` 末尾追加 Rule 48 块（48.1-48.5 共 5 子条 + 标题行 + 用户原话引言），+10/-0 纯插入（483→493）；48.5 零新键锚在位（L492）；`### 4x` 计数 44/45/46/48 各 1（47 属 v122 在途）。主进程验收：Read 尾部逐行复核 ✓ + 五守卫单跑全绿（template-lifecycle 21/21、skill-split 41/41、RT-08 9/9、PT-08 32/32、CD-12 24/24）。
- **S6（code-assistant，15:00 返回，ENOSPC 事故后恢复点）**：`scripts/selftest-template-lifecycle.sh` 追加 TL-22/23/24（+10/-1），Total 21→24 全 PASS；头注释 +3 行（总数文案同步 21→24）；负向自检有牙齿——mktemp fixture 逐锚缺失实测（缺「定位三要素」→TL-22 FAIL 等三例），测后清理不落 repo。主进程验收：git diff 逐行复核与 D5 一致 ✓ + 重跑 24/24 ✓。**预期全量回归 ΣPASS=676+3=679**。
- **S7（executor，15:06 返回）**：全量 43 脚本回归——43/43 rc=0，**ΣPASS=679 ΣFAIL=0**（主进程 bc 独立求和 679 复核一致）；异常 1 例=`final-gate-hash` 结果行格式异类（「==== … 结果: PASS=22 FAIL=0 ====」非 Total 前缀，非 FAIL，重试复现 rc=0；基线同格式）；porcelain 仅 S6 产物。Phase 3 产物 commit **ca7c741**。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| D1 新增 Rule 48（不扩展 38.7/不避让成无编号条款） | 交付面可独立成条；45/46 范式；38.7 挂载会类别错位 |
| D2 模板升级=纯增量（头部注释区 + 定位栏 blockquote + 区块要求增强） | Rule 36.5 默认纯增量；五区块数量契约不动（TL-19 零级联） |
| D3 Rule 48 五子条（范围/指针形态/行动项三要素/复核回滚失效/机制） | 对齐 44-46 子条范式；48.5 零新键声明（43.4/44.4 同范式） |
| D4 SKILL 4 处行内替换（零净增） | 撞 T-主 444 定数风险归零；47/48 一并列入索引（v122 在途） |
| D5 编号避让 47→48 | 并行会话先占；预扩窗口零级联；乱序合并安全 |
| D6 零新 config 键 | 定性规则面；机器面=TL-22/23/24 静态守卫 + P4 独立审计 |
| D7 样例+独立审计入 VC-5 | 「实用」的唯一端到端证据（43.1）；直接回应用户原例 |
| D8 L1 通道 | 38.7 新 Rule 条款排除 L0 |

## D2 定稿区 — `templates/delivery-summary.md` 目标全文（P1 审计后冻结；S3 按此实施）
> 状态: v0 草案（规划期主进程）；S1 普查增补后冻结。变更性质：**纯增量**（既有指引零删除，五区块标题不变）。

```markdown
<!-- delivery-summary.md — 任务交付总结五要素模板（SKILL 终验交付段配套，用户面） -->
<!-- 使用方式: 终验结论（COMPLETE/PARTIAL/BLOCKED）判定后、会话退出前，按本模板向用户输出交付总结；
     需要跨会话存证/独立子代理验收（VC 类条款要求落盘）时，同步落 plans/<task-id>/delivery-summary.md -->
<!-- 定位: 用户面总结 = 引用机器面档案而非重写——数据源指针: verification.md（VC/委派/门控/Goal Gate）、
     progress.md（每 Phase Files created-modified/Error Log）、subagent-state/（独立验证 checkpoint）、
     report.md / memory-hygiene-report.md（如有）；本模板不复述证据原文，只写指针+一句话结论 -->
<!-- 详略标准: 以「用户可独立决策」为准——用户读完不查三文件即可回答: 产出物在哪/哪些可信/风险是什么/我下一步做什么 -->
<!-- 可定位性硬规则（Rule 48，2026-10-03 task-v123；用户裁决原话「让人审查接下来做什么时候竟然不包含
     审查内容路径或者网址，让人完全不知道到哪里审查」）:
     ① 文件/对象指针 = 绝对路径，或仓内路径 + 全文给出仓库根绝对路径（定位栏）；禁止裸文件名（「见 verification.md」）
     ② 线上内容 = 完整 URL；操作 = 可直接执行的完整命令（含工作目录/前置 cd）
     ③ 禁止未解析占位符（<merge-hash> 之类原样输出）、模糊指代（「相关文件」「上文」「另行确认」）
     ④ 行动项定位三要素（§5 逐条必填）: 对象（要打开/审查的东西: 路径 或 URL）+ 看点（锚点/段落，看什么）
        + 动作（用户做什么 + 期望反馈形态）；审查类条目必须含审查对象路径或网址
     ⑤ 指针相对本总结语义自足——读者未读过三文件也能直接定位（机器档案路径见「定位栏」） -->
<!-- 反模式 → 修法对照（Rule 48.2 自查）:
     「见 verification.md」→ 「见 <绝对路径>/verification.md VC 复验段」
     「请审查」/「建议观察 1-2 周」→ 对象（路径/URL）+ 看点 + 动作三要素补齐（去哪看/看什么/回什么）
     「git revert <merge-hash>」→ 「cd <仓库绝对路径> && git revert <具体hash>」
     「部署位已同步」→ 逐位绝对路径列表    「bash xxx.sh」→ 前置 cd 绝对路径或写全绝对路径命令 -->
<!-- 头部形态: HTML 注释指引区（同 batch_report.md/knowledge-brief.md 根模板惯例），无 <!-- template_type: -->
     （非计划模板，不进 check-template-type 白名单，不入 25 模板口径） -->

# Delivery Summary — {task-id}（任务交付总结）

> **定位栏（Rule 48.2）**: 机器档案=`<plans/<task-id>/ 绝对路径>` ｜ 仓库=`<仓库根绝对路径>` ｜ 交付基线=`<merge commit hash，或「未合并（分支 <branch>）」>` ｜ 部署位=`<逐位绝对路径列表；无部署写「无」>`

## 1. 任务说明
- **Goal 回顾**: [一行，引 task_plan.md Goal 原文]
- **执行过程摘要**: [Phase 序列 + 各 Phase 执行体（子代理/主进程）+ 关键裁决点（含 silent 自动裁决清单，
  Decisions Made 表 `silent:` 前缀行逐项列出），3-6 行；数据源 = progress.md Phase 段 + task_plan.md Decisions Made]
- **行为面变化**: [必填行——本任务完成后用户可感知的变化（下次会看到什么不一样/能做什么新事）；无则写「无」，禁止省略]
- **交付结论**: COMPLETE / PARTIAL / BLOCKED [引 verification.md Goal Gate outcome]

## 2. 产出清单（文件级）
| 文件（绝对路径，或仓内路径并已在定位栏给出仓库根） | 变更摘要（新增/修改/删除 + 一句话） | 验证状态 |
| ... | ... | VC-N PASS / N selftest rc=0 / grep 锚实测 / Read 复验 |

[数据源 = progress.md 每 Phase「Files created/modified」+ verification.md VC Evidence 逐条指针；
 合并类任务附 merge commit hash（如 5a30382）；有部署时逐位列部署绝对路径 + 对账结论（diff=0）]

## 3. 审查信息（尽量详细）
- **VC 复验**: N/N 条 PASS（指针: <机器档案绝对路径>/verification.md Goal Gate 段）
- **回归**: <N> 个 selftest / SUM-ASSERTIONS=<数值>（独立子代理 sub:<k>，checkpoint: <机器档案绝对路径>/subagent-state/<k>-<agent>.md）
- **快速复核入口（Rule 48.4）**: [1-3 条用户可直接执行的最轻复核命令（含前置 cd 绝对路径），复验最关键结论的入口；
  例: `cd <仓库绝对路径> && bash skills/task-planner/scripts/selftest-template-lifecycle.sh`]
- **对齐审查**: verdict（APPROVED / CHANGES_REQUESTED + 处置项清单）（指针: checkpoint sub:<k>）
- **委派统计**: check-delegation.sh stats JSON 原文（phases_total/delegated/rate/verdict）+ 白名单豁免判定行
- **质量门控**: Q1-Q6 触发/豁免/未处置计数 + Evidence 抽查 ≥3 条记录（指针: verification.md 质量门控统计段）
- **验证独立性**: 本任务验证动作由 <N> 个全新独立子代理执行，主进程零自测替代验收（2026-09-26 裁决）

## 4. 风险点（必须列举；无则逐项写「无」，禁止整块省略）
- **已知遗留**: [PARTIAL 的已知缺陷 / 未授权零修复的候选清单指针（绝对路径）/ 无]
- **待裁决**: [需用户拍板的事项逐项列出（部署同步/D6 授权等），每项含对象定位（绝对路径/URL）+ 上下文一句话]
- **失效条件**: [本任务结论何时会过时——逐条给失效判据 + 验证方式（可执行命令或明确动作），消费方触发即重验；
  例「基线 43 脚本 676/0 — 失效条件: 任一新增/删除 selftest 脚本或计数漂移；重验: cd <仓库绝对路径> && bash <script>」]
- **回滚方式**: [可直接执行的完整命令 + 仓库/分支/具体 commit（`cd <仓库绝对路径> && git revert <具体hash>`）/
  备份文件绝对路径 / 无]

## 5. 下一步建议（用户可执行行动项，按推荐排序；默认项排第 1 位并标注「推荐」）
> 每条必须含定位三要素（Rule 48.3）：**对象**（要打开/审查的东西：绝对路径 或 URL）｜**看点**（具体位置/锚点）｜
> **动作**（做什么 + 期望反馈形态）；审查类条目必须给审查对象路径或网址；操作类必须给可执行命令。

1. **[推荐]** <行动项 1 — 对象: `<绝对路径/URL>` ｜ 看点: <锚点/段落> ｜ 动作: <做什么/期望反馈>>
2. <行动项 2>
3. ...
[多待决项按 Rule 41.5 打包呈报 + Rule 44.1 默认项排序；无待决项时写「本任务无待用户行动项」]
```
**验收锚（S3）**: `grep -q '可定位性硬规则'` + `grep -q '反模式'` + `grep -q '定位三要素'` + `grep -cE '^## [1-5]\.'` = 5 + TL-19 单跑 PASS。

## D3 定稿区 — `references/critical-rules.md` Rule 48 全文（S5 按此实施；块级追加于 Rule 46 之后）

```markdown
### 48 交付总结可定位性与实用性（P0,2026-10-03 task-v123，目标：交付总结每一条指针与行动项用户可直接打开或执行，消除「让人审查不知道去哪看」；判定面=撰写自查+模板/SKILL 静态锚，零新 config 键；衔接 38.7 交付总结消费与 templates/delivery-summary.md，既有 Rules 原文零改动）

本条源于用户 2026-10-03 指令原话：「当前的完成任务后的展示总结存在严重的缺陷 比如 让人审查接下来做什么时候 竟然不包含 审查内容路径或者网址 让人完全不知道到哪里审查 类似 的缺陷不一一列举 我希望的是完成总结可以更加实用」。

48.1 **适用范围**：全部终验交付总结（含 38.7 L0 精简模式——精简只降详略、不豁免可定位性）；chat 直出与 plans/<task-id>/delivery-summary.md 存证两形态同规。
48.2 **指针形态硬规则（可定位性）**：指向文件/对象/结论的一切指针必须为以下之一——绝对路径；仓内路径且全文已给出仓库根绝对路径（定位栏）；完整 URL；可直接执行的完整命令（含工作目录/前置 cd）。**禁止**：裸文件名（「见 verification.md」）、模糊指代（「相关文件」「上文」「另行确认」）、未解析占位符（`<merge-hash>` 原样输出）、缺路径不可执行命令（`bash xxx.sh`）。
48.3 **行动项定位三要素**：下一步建议 / 待裁决 / 审查类条目逐条含 ① 对象=要打开或审查的东西（绝对路径 或 URL）② 看点=具体位置/锚点/段落 ③ 动作=用户做什么+期望反馈形态。**审查类条目必须含审查对象路径或网址**（本条用户原例落点）；操作类必须含可执行命令；禁止「持续关注/观察一段时间/后续跟进」类无对象空泛动词。
48.4 **复核、回滚与失效可执行**：§3 快速复核入口 ≥1 条可直接执行的最轻复核命令（含前置 cd）；回滚方式=具体命令+仓库路径/分支/具体 commit（禁占位符）；失效条件逐条附验证方式（命令或明确动作）。
48.5 **机制（零新 config 键）**：硬规则与反模式对照全文写入 templates/delivery-summary.md（头部指引+区块要求）；SKILL.md 终验交付段引用（可定位性括注）；selftest-template-lifecycle.sh TL-22/23/24 静态守护（模板三锚 / SKILL 括注锚 / 本条子条锚+零新键声明）；消费侧=终验交付撰写自查 + 全新独立子代理样例审计（验证独立性按 43.1，task-v123 首实证）。
```
**验收锚（S5）**: `grep -cE '^48\.[1-5]'` ≥5；`grep -q '48\.5.*零新 config 键'`；既有 1-46 原文零改动（diff 只增）。

## D4 定稿区 — `SKILL.md` 4 处行内替换（S4 按此实施；**净增 0 行**）

| # | 行 | 原文（节选，精确匹配以 Read 为准） | 新文 |
|---|----|-----------------------------------|------|
| R1 | :9 frontmatter | `Critical Rules 全集 1-46（` | `Critical Rules 全集 1-48（` |
| R1b | :9 同行 | `45 注释完整性规范、46 子代理单任务专注度，含` | `45 注释完整性规范、46 子代理单任务专注度、47 媒体制作任务派发纪律、48 交付总结可定位性与实用性，含` |
| R2 | :158 | `…；需存证时落 plans/<task-id>/delivery-summary.md）` | `…；需存证时落 plans/<task-id>/delivery-summary.md；**可定位性（Rule 48）**：全体指针必须为绝对路径/URL/可执行命令（禁裸文件名、模糊指代、未解析占位符）；下一步建议与待裁决项逐条带「对象路径/URL+看点+动作」，审查类条目必须含审查对象路径或网址）` |
| R3 | :247 | `（Rules 1-39（含 Rule 40/41/42/43/44/45/46））：` | `（Rules 1-39（含 Rule 40/41/42/43/44/45/46/47/48））：` |
| R4 | :305 | `/ Rule 45 注释完整性规范 / Rule 46 子代理单任务专注度） \|` | `/ Rule 45 注释完整性规范 / Rule 46 子代理单任务专注度 / Rule 47 媒体制作任务派发纪律（并行任务 task-v122） / Rule 48 交付总结可定位性与实用性） \|` |

**验收锚（S4）**: 四行 grep 命中（`可定位性（Rule 48）` / `1-48` / `46/47/48` / `Rule 48 交付总结可定位性与实用性`）；`wc -l SKILL.md` = 444；`bash scripts/selftest-skill-split.sh` rc=0。
**注**: R1b/R4 提及 Rule 47 = v122 在途规则（合并后连续；若 v122 终止按 plan FMEA 兜底登记）。

## D5 定稿区 — `scripts/selftest-template-lifecycle.sh` TL-22/23/24（S6 按此实施）

```bash
# TL-22 [task-v123] delivery-summary.md 可定位性硬规则三锚（Rule 48.5）
if [ -f "$TDEL" ] && grep -q '可定位性硬规则' "$TDEL" && grep -q '反模式' "$TDEL" && grep -q '定位三要素' "$TDEL"; then ok 22 "delivery-summary.md 三锚（硬规则/反模式/定位三要素）在位"; else bad 22 "delivery-summary.md 缺可定位性锚（硬规则/反模式/定位三要素）"; fi
# TL-23 [task-v123] SKILL.md 终验段可定位性括注锚
if grep -q '可定位性（Rule 48）' "$SKILL"; then ok 23 "SKILL.md 含可定位性（Rule 48）括注"; else bad 23 "SKILL.md 缺可定位性（Rule 48）括注"; fi
# TL-24 [task-v123] critical-rules.md Rule 48 子条 ≥5 + 零新键声明
if [ "$(grep -cE '^48\.[1-5]' "$CRIT")" -ge 5 ] && grep -q '48\.5.*零新 config 键' "$CRIT"; then ok 24 "Rule 48 子条≥5 且 48.5 零新键声明在位"; else bad 24 "Rule 48 子条不足或零新键声明缺失"; fi
```
**实施要求（S6）**: ① 变量沿用脚本既有命名（`$SKILL`/`$TDEL` 已在 TL-19 定义；`$CRIT` 若无则按 SKILL_ROOT 范式补）；② 头注释块（:20-24 区）追加 TL-22/23/24 三行说明；③ **负向自检有牙齿**——构造缺锚 fixture（如临时文件不含「定位三要素」）跑同一断言必 FAIL（现场实测并把输入/结果记入 progress.md Test Results）；④ 断言编号续 TL-21；⑤ 不新建脚本（registry 零动）。

### E. Phase 4 独立验证记录（S8-S11）

- **S8（executor + code-quality-review，15:12 返回）**：CR Gate 轻 diff 单轮 verdict=**APPROVED**（P0=0 P1=0；P2×1=TL-22 消息聚合不指明缺哪锚——与 TL-19 风格一致，判风格延续不阻断）。14 维度逐项过；负向可达性独立复证 4/4（/tmp fixture 测后清理）；既有 21 断言零破坏（diff 2 hunks +10/-1，唯一 -1 为头注释文案 21→24）；Total 24/24。
- **S9（executor，15:18 返回）**：样例 `delivery-summary-sample.md`（47 行）——5 区块+定位栏（绝对路径机器档案/仓库/基线/部署位）；§5 三要素 5/5；审查类条目含对象路径 2/2；零裸文件名/零未解析占位符（自检修正 2 处后归零）；如实标注「进行中（PARTIAL 口径）」不虚构 merge hash。主进程 Read 逐行复核 ✓。
- **S10（executor 改派——Verifier 档 provider 认证失败，Rule 22.3①，15:22 返回）**：独立审计 4/4——样例逐条全 PASS；VC-1/2/3 锚独立复验全 PASS（TL 24/24、T-主 41/41、RT 9/9、PT 32/32、CD 24/24）；反例区分度实证（mktemp 坏条目三检查全 FAIL，测后清理 residual=0）。主进程核对结论 ✓。
- **S11（executor + alignment-review，15:16 返回）**：四要素对齐审查 verdict=**APPROVED**（P0=0/P1=0；P2×2 不阻断=① wt 提及 Rule 47 而 47 块在 master〔v122 已并入 a183a99，L484，47.1-47.4〕，合并后收敛；② master T-主 ≤447 演进 vs wt ≤444，合并时按 46/47/48 序解决并全线复验）。四要素证据：diff 4 文件逐 hunk 对应 D2/D3/D4/D5；口径 444+5+2+35 不破；引用四锚实存；五守卫复证全 rc=0 + TL-22 负向牙齿确认。**→ 侦测到 master 前进（B 类修订已登记：Phase 5 先 merge master）。**

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 并行会话 task-v122 已占 Rule 47（媒体派发） | 编号避让：本任务取 Rule 48（D5）；编辑最小化+乱序合并口径登记（FMEA） |

## Resources
- 模板: `skills/task-planner/templates/delivery-summary.md`
- 守卫: `skills/task-planner/scripts/selftest-template-lifecycle.sh`（TL-19/20/21 + 本任务 TL-22/23/24）
- SKILL 锚: `SKILL.md:9/:158/:247/:305`（2026-10-03 08:53 实测）
- 实例: `plans/task-v120/delivery-summary.md`、`plans/task-v112/delivery-summary-sample.md`
- 部署机制: `skills/task-planner/scripts/smart-merge-back.sh --deploy`（两级对账；基准=主仓 skills/task-planner）
- worktree: `/mnt/data/dev/task-planner-skill-worktrees/task-v123`（分支 `wt/task-v123`）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
