# ALIGN-review — 交付文档对齐审查（只读）

- 审查者：align-critic（独立于 S1-S9 与报告撰写者）
- 对象：`audit-report.md`（186 行）、`revision-proposals.md`（95 行）
- 事实源：`task_plan.md`（VC-1~VC-6 / 58.5 / Phase 状态）、`findings.md`、`subagent-state/S7-verifier.md`（verified 17 / partial 3 / fp 2 / unverified 0）
- 方法：`~/.zcode/skills/alignment-review/SKILL.md` 不存在（`ls` 未命中）→ 按通用一致性核对法（事实源逐条对账 + 锚点 grep 复现 + 计数复算 + 越界扫描）
- 纪律：只读；唯一写入=本文件；无 git 写操作；未改动 audit-report.md / revision-proposals.md
- 审查维度：结论一致性 / 完备性（VC 对应）/ 可执行性 / 一致性 / 可追溯性

---

## 甲 结论一致性（与 findings.md + S7 复核判定对账）

**[🔴CRITICAL]** `audit-report.md:38` — FACT LOCK 时间线混用 S8 旧快照与 S7 新数据，与复核事实源冲突
- 原文: "| 00:21:39 / 01:29:32 | spec 重建 / ep03-prompts.md 更新（**FACT LOCK 命中 32**） | `tmp/ep03/gen/specs/ep03-video-all.json` mtime；`docs/series/shiyan-lihua/ep03/ep03-prompts.md` mtime |"
- 原因: S7 实测 spec mtime=**01:30:00**、FACT LOCK 命中 **18**，`ep03-prompts.md`=01:29:32、命中 **32**（`S7-verifier.md:127`）；报告把 00:21:39（S8 截断快照）当 spec mtime、把 prompts 的 32 次命中混挂到 spec 行，等于把已判 fp 的旧数据重新引入时间线
- 置信度: HIGH（`stat` 复核：prompts=32、spec=18，计数归属成立；mtime 现已 02:09 变动，报告数值仍与 S7 不符）

**[🟡HIGH]** `findings.md:37,:46` — 已撤回结论仍留在事实源，报告未披露该残留
- 原文: "FACT LOCK 派发真实存在但**产出为零落盘**…子代理 `agent_1537858a…` 运行 23:39:30→01:03（117 parts）**无任何 Edit/Write**" / "- D-F4 **虚假进展**：派发 FACT LOCK 子代理（84 分钟）零落盘产出"
- 原因: S7 FP-1 已推翻（Edit 20 / Write 3 / 输出 3214B / 01:42:45 终态），audit-report 正确撤回，但 findings.md（VC-4 指定的 S7 结论落点）仍逐字保留该断言；报告 §7 只写"撤回 1 条初版结论"，未标注事实源需同步，读者按 findings 复核会得到相反结论
- 置信度: HIGH（两侧原文均直读）

**[🟡HIGH]** `audit-report.md:39,:49` — "5 类落点" 计数把"排除项"算成落点
- 原文: "规则级判例行、经验档、计划档、后续任务书共 5 类落点"
- 原因: §1.3 表 5 行中"排除项 `plans/task-videop1-ep03-videogen-001/task_plan.md:52`（模板占位，已排除）"不是落点，真实固化落点=4 类（规则/任务书/经验档/计划档）；该数字被 §1.2 D-F3 行再次引用，属夸大
- 置信度: HIGH

**[🟡HIGH]** `audit-report.md:50,:51` — D-F4/D-F5 编号含义被静默改写，与 findings.md 同号不同义
- 原文: "| D-F4 | 一手事实与结论倒挂且无复核动作 |" / "| D-F5 | 措辞层伪装（用「调度硬闸」替代「额度事实」） |"
- 原因: findings.md:46 D-F4=「虚假进展」（已撤回）、:47 D-F5=「一手事实与结论倒挂」；报告未注明"D-F4 原义已撤回、编号改述"，同一 ID 在两份事实源指向不同缺陷，违反可追溯性
- 置信度: HIGH

**[🟡HIGH]** `audit-report.md:110` — "7 个当下即可归档" 是未验证事实却按定论书写
- 原文: "8 个 Status 全 complete 计划仍留根（7 个当下即可归档，仅 s77-p2-fix 被 `.session-owner` 24h TTL 拦）"
- 原因: `S7-verifier.md:162` 明确跳过该判定（"archive-plan.sh 执行 git mv（非只读），不得在只读复核中运行"），报告 §7:148 亦承认跳过 dry-run；与 :8 "无锚项一律标「未验证」" 自相矛盾
- 置信度: HIGH

**[🟡HIGH]** `audit-report.md:18` + `:98` — partial 状态未在使用点标注
- 原文: "全量 selftest 92/92 exit 0、1315 PASS / 0 FAIL、0 语法错（V-C5 面实测）"
- 原因: S7 对全量回归判 **partial（抽样 4/5，1315 未重算）**（`S7-verifier.md:56-59`），报告只在 §7 标注 partial，§0 核心结论三与 §3 事实表均按已复现事实陈述，读者无法感知该数字未全量验证
- 置信度: HIGH

**[🟡HIGH]** `revision-proposals.md:40` — 部署位落后数在 P0 方案中被当作 verified 依据
- 原文: "①旧版本已被证伪（现行加载位缺 Rule 93 全套，落后 19~47+ 提交）✓"
- 原因: S7 仅 verified `.zcode=19`，其余 3 位数字"未重新推导"（`S7-verifier.md:74`）；且 facts 三处互斥（findings §部署面 19/49/59/59、findings B-03 19/47/47/47~74、S7 47/47/56/74），"19~47+" 上界与 56/59/74 均不一致却未标 partial
- 置信度: HIGH

**[🟢MEDIUM]** `audit-report.md:88,:111` — 两处降级建议未同步
- 原文: "| A-08(P1) | … | verified（部分） |" / "| B-03(P0) | … | verified（其余 3 位精确落后数 partial） |"
- 原因: S7 ③ 明列 `[8d] Rule 38.7 → 降为 NIT`、`[12] 部署位 → 降为 P1`（`S7-verifier.md:148-149`）；报告 A-08 仍 P1、B-03 仍 P0，且未写"未采纳降级建议及理由"。已正确同步的仅 B-02（P0→P1）、C-05（P0→INFO）、C-04（措辞修正落 RP-11）
- 置信度: HIGH

---

## 乙 VC 对应（VC-1~VC-6 证据链）

**[🔴CRITICAL]** `progress.md:1-66` — VC-3/VC-5 要求的证据载体是未回填模板，报告未披露
- 原文: "| Test | Input | Expected | Actual | Status |" + "|      |       |          |        |        |"（全文唯一 Test Results 行）
- 原因: VC-3 要求"执行命令+FAIL 数落 progress.md""两行数字对照"，VC-5 要求"执行前基线已留档 progress.md"；实际 progress.md 零条 Phase 记录、零 Test Results、零 Error Log、Started 为空，`task_plan.md:170,182,203,216` 四个 Phase 全 `Status: pending`、G1-G5 全 pending、`:83-91` 58.5 裁决区块全空、`verification.md` 全为占位模板——报告却给出完整结果与裁决。两份交付文档均未把该缺口列入"未能覆盖的面"
- 置信度: HIGH（文件直读；`progress.md` mtime 10-21 23:29 与创建同刻）

**[🟡HIGH]** `audit-report.md:8` — "无锚项一律标未验证" 与实际锚点强度不符（VC-4）
- 原文: "本报告**不含**任何未标注证据锚的结论；无锚项一律标「未验证」"
- 原因: B-02 锚=`plans/ 实测`（:110）、C-06 锚=`S6 checkpoint`（:126）、D-05 锚=`S9 checkpoint`（:73）、A-09 锚=`—`（:89），均非 VC-4 要求的"文件:行 / 命令输出"；其中 B-02/C-06 为 P1 发现，"无锚结论=0"不成立
- 置信度: HIGH

**[🟢MEDIUM]** `audit-report.md:130-139,:95-101` — VC-1"每维含结论+发现编号+证据锚"两维不满足，且全文无 VC 复验记录
- 原文: "## §6 结构面（S1）" / "## §3 脚本健康与回归面（S4；核心悖论）"
- 原因: `grep 'VC-' audit-report.md revision-proposals.md` = 0 命中——无 VC-1~VC-6 逐条复验/通过声明；§3、§6 只有事实数值，无发现编号、无该维结论句，VC-1 的"每维含结论+发现编号"在 5 维中缺 2 维
- 置信度: HIGH（grep 0 命中）

**[🟢MEDIUM]** `audit-report.md:14` — VC-6② 字面要素缺失（39.6% / 重置时刻）
- 原文: "而当时额度实为 198/500（**剩余 302s**）"
- 原因: `task_plan.md:79` VC-6② 要求落锚"198/500、39.6%、重置 2026-10-22 00:00"三要素；报告只落 198/500+302s，39.6% 与重置时刻未出现（findings.md:40 记 39.6% 在会话树 0 命中，应显式说明该值为用户面板口径、非会话内证据，否则 VC-6 无法逐字判定通过）
- 置信度: HIGH

**[💬NIT]** `revision-proposals.md:77-80` — RP-30/31 缺"执行动作"列（VC-2 四要素）
- 原文: "| 编号 | 对象 | 变更类型 | 优先级 | 待决问题 | 依据 |"
- 原因: VC-2 要求"对象+变更类型+优先级+执行建议"；两条裁决项以"待决问题/选项"替代执行动作，尚可接受但未声明为有意差异
- 置信度: HIGH

**VC 逐条结论**：VC-1 部分（缺 2 维编号/结论 + 无复验记录）、VC-2 通过（四要素基本齐备，RP-30/31 例外）、VC-3 **不通过**（progress.md 无记录）、VC-4 部分（4 处弱锚）、VC-5 **不通过**（基线未留档，仅报告声明"零改动"）、VC-6 部分（②缺 2 要素；①③④ 齐备，①③ 有 part/msg id 与 file:line 锚，④ 有 RP-01~04）。

---

## 丙 方案可执行性（对象+变更类型+优先级+动作+依据）

**[🔴CRITICAL]** `revision-proposals.md:18` — RP-04 的 P0 修复锚点错行，照此执行修不到缺陷
- 原文: "① 修 `templates/task_plan.md:497`：把「备注(rescue/retry/verify_done)」中的 verify_done **拆为独立列**"
- 原因: grep 实测 `备注(rescue/retry/verify_done)` 在 **:502**（表头行），:497 是"列说明"散文句；在 :497 改动只会改说明文字，真实表头仍折叠 → check-complete.sh:1747 仍取不到列位，P0 修复落空。同一错锚见 `audit-report.md:71`（"模板 `templates/task_plan.md:497` 把该列折叠成…"）
- 置信度: HIGH（`grep -n` 输出 502 / 497 两行原文）

**[🟡HIGH]** `revision-proposals.md:54` — RP-19 对象文件与依据文件不是同一个脚本
- 原文: "| RP-19 | `skills/task-planner/scripts/check-plan-dispatch.sh` / 委派率统计口径 | 增量 | P1 |"
- 原因: C-05 的依据锚是 `check-delegation.sh:421-424,445`（`audit-report.md:125`），两脚本均存在（29553B / 42940B）；执行者按 RP-19 会改 `check-plan-dispatch.sh`，匹配器缺陷不会消失
- 置信度: HIGH

**[🟡HIGH]** `revision-proposals.md:28` — RP-07 内部前置引用指向错误条目
- 原文: "实施前先补 landed 行（RP-13）再收紧豁免表，否则收紧即假 FAIL"
- 原因: 账本补登是 **RP-17**（`:52`），RP-13 是部署门（`:41`）；同一文件 §七:87 又正确写"RP-17（账本补登）→ RP-07"，两处自相矛盾，按 :28 执行会先做无关的部署门
- 置信度: HIGH

**[🟡HIGH]** `audit-report.md:82,:83,:85` vs `revision-proposals.md:52,:63` — 3 条 P0 发现只有 P1 级方案，且不在 §8 的 P0 表中
- 原文: "| A-02(P0) | **三面计数互斥**…" / "| A-03(P0) | **Rule 75 双行认领**…" / "| A-05(P0) | **Rule 56/83 账本零登记**…"
- 原因: 三条唯一对应方案为 RP-21（P1）、RP-17（P1），且 §8 表（:159-166）P0 三个主题只覆盖 RP-01~RP-14，未含 A-02/A-03/A-05 → P0 发现被降为 P1 执行而未声明，优先级口径断裂
- 置信度: HIGH（逐行比对）

**[💬NIT]** `revision-proposals.md:15` — RP-01 行号自注把 :195 标成 media-planner 行
- 原文: "`skills/task-planner/SKILL.md` 卫星路由表段（现 `:195` media-planner 行所在表）"
- 原因: `sed -n '195,196p'` 实测 :195=task-discipline 行、:196=media-planner 行（S7 已修正 S9 的 :196 笔误）；目标表正确，但行标签写反，易误导二次定位
- 置信度: HIGH

**丙正面核对（通过项）**：替代类 RP-05/07/12 均逐条列出 Rule 74 四条件并标 ④"需 worktree 实测"（`:26,:28,:40`）；删除类 RP-18/RP-25 均标"需用户逐项授权"（`:53,:67`）；RP-01~RP-29 五列齐备。方案层"只出提案不执行"边界清晰（`:5,:117`），无越界执行表述。

---

## 丁 越界与自洽

**[🔴CRITICAL]** `audit-report.md:145` — §7 "verified 17" 的枚举是 18 个编号 + 4 条事实，且与自身 partial/fp 互斥
- 原文: "- **verified 17**：A-01~A-07、B-01/B-03/B-04/B-05、C-01~C-04、D-01/D-02/D-03、§1 全部 4 条关键事实"
- 原因: 枚举实为 7+4+4+3=18 个 ID 再叠加 4 条事实；其中 B-03 对应 S7 清单 [12]（partial）、"§1 全部 4 条"含 [22]（partial，第 4 条为 fp）；而 A-08 在 §2 标"verified（部分）"却不在 §7 任一档。S7 的 17 是清单项 [1]-[7],[10],[11],[13]-[17],[19]-[21]，与报告编号不是同一集合 → 17/3/2 只在算术上等于 22，不构成 22 项的划分
- 置信度: HIGH（`S7-verifier.md:169` 清单逐项对照）

**[🟡HIGH]** `audit-report.md:146` — FACT LOCK 同时计入 partial 与 fp，重复计数
- 原文: "- **partial 3**：①全量回归 1315 数字未全量重算（抽样通过）②部署位 4 位精确落后数未重推（`.zcode` 部分成立）③§1 涉事第 4 条（FACT LOCK 产出）**判定为假阳性，已撤回**"
- 原因: 同一条目既列 partial ③ 又列 fp ①（:147），fp 的两条（FP-1、FP-2）本身是 [22]、[17] 的子结论；"22 条"总数掩盖了重复计入，正确表述应为"清单项 17 verified / 3 partial / 0 unverified；其中 2 条子结论被推翻"
- 置信度: HIGH

**[🟡HIGH]** `audit-report.md:20` — P0 分组之和 16 ≠ 总数 14，且"12 confirmed + 2 partial 降级"无对应
- 原文: "P0 共 14 项（其中 R3 直接相关 3 项、规则/守卫面 6 项、部署与簿记面 3 项、派发契约面 4 项，P0 口径按 S7 复核后为 12 项 confirmed + 2 项 partial 降级）"
- 原因: 3+6+3+4=16；"部署与簿记面 3 项"含已降 P1 的 B-02；S7 的 2 项 P0 降级是 B-02/B-03 **降为 P1**（`S7-verifier.md:149-150`），不是"partial 降级"，且 B-03 在 :111 仍标 P0
- 置信度: HIGH

**[🟡HIGH]** `audit-report.md:20` + `revision-proposals.md:95` — P1/P2 条目数三处互斥，方案统计自身不闭合
- 原文: "P1 11 项，P2 9 项" / "提案 31 条 = P0 14 条（生效通道 4 + 守卫 7 + 部署 3）+ P1 12 条 + P2 1 条 + 需用户裁决 2 条"
- 原因: 按方案表逐行统计 P1（非裁决）=RP-15~RP-28 共 **14** 条（非 12），P2=1，P0（非裁决）=14，裁决=2 → 31；所述分解 14+12+1+2=**29**≠31；报告 §8 又给出 6+9+2 第三种口径；报告正文实际枚举的 P1 发现仅 7 条（A-07/A-08/B-02/B-04/B-05/C-06/D-04），无一条 P2 发现 → "P1 11 / P2 9" 无表可对应
- 置信度: HIGH

**[🟡HIGH]** `revision-proposals.md:3` — "A-/B-/C-/D- 与 S9 补强 D-01~D-14 一一对应" 为假
- 原文: "（发现编号 A-/B-/C-/D- 与 S9 补强方向 D-01~D-14 一一对应）"
- 原因: S9 的 D-01~D-14 是补强清单，其中 D-02=check-complete.sh:1747 列名加固、D-03=warn 升 exit 1、D-04=产物存在性检测、D-05=常驻指针，而报告 D-02=资源断言零指针、D-03=固化通路 0/9、D-04=缺 Rule 93、D-05=负结果——D-02~D-05 同号异义；且 S9 的 A-/B-/C-/F-/V- 前缀与 S3(A-)/S5(B-)/S6(C-) 编号空间重叠（S9 A-01=卫星调用条件 vs 报告 A-01=宽锚计数守卫）
- 置信度: HIGH（`S9-auditor.md:121-129` 逐行对读）

**[💬NIT]** `audit-report.md:18` — "（V-C5 面实测）" 是不可解析锚
- 原文: "1315 PASS / 0 FAIL、0 语法错（V-C5 面实测）"
- 原因: 计划中无 "V-C5"；VC-5 定义为 git status 对照（`task_plan.md:78`），与 selftest 无关；该锚既非文件行也非命令，应改为 `S4-runner.md` 锚
- 置信度: HIGH

**[💬NIT]** `revision-proposals.md:95` — "替代类 3 条" 未计 RP-30
- 原文: "其中「替代」类 3 条、「删除」类 2 条（均标注需授权）"
- 原因: RP-30 变更类型为"替代或删除"（`:79`），未纳入任一计数；另 RP-18 对象含"71 个漂移状态文件"，删除授权标注正确
- 置信度: HIGH

**丁负面结论（未发现）**：
- 未发现"已修改技能文件/已部署/已同步"类越界表述——`grep -nE '已修|已改|已同步|已部署|已落地'` 仅命中 A-04/RP-07 的"正文已落地"（描述规则文本存在），非本任务改动声明；§8:155 明确"尚未修复"
- 未发现凭据泄露——`grep -Ei 'token|password|api[_-]?key|secret|sk-|PRIVATE KEY'` 0 命中；文档含会话 ID/DB part ID/主目录路径，属用户已提供的取证对象（`task_plan.md:21` 原始需求即含完整 session id），未超出任务范围
- 未发现把推测写成事实的"修复效果"承诺——RP 全部标注"需 worktree 实测"或"需用户授权"

---

## 负结果报告（检查了但未发现问题）

- 已检查 `audit-report.md` 全 186 行 + `revision-proposals.md` 全 95 行，逐条对照 `findings.md`（149 行）、`task_plan.md`（303 行）、`S7-verifier.md`（178 行）、`S9-auditor.md`（补强 ④ 段）
- 预期问题但**未发现**：① 无"已修改技能文件"越界；② 无凭据泄露；③ 无"FACT LOCK 无产出仍推进"的残留主张（audit-report 已正确撤回，见 :147；残留仅在 findings.md）；④ 替代类四条件、删除类授权标注齐备；⑤ 报告未把 P2 方案写成可执行条目（符合 task_plan 颗粒度裁决）
- 已排除的可能性：① "§1 无锚"——§1.1 表每行均有 part/msg/file:line 锚，成立；② "C-04 措辞未同步"——RP-11 已写入"现无值域判据，S7 措辞修正"，同步到位；③ "B-02 未降级"——:110 已标"P0→P1 降级"，同步到位；④ "FACT LOCK 撤回不彻底导致 D-01 结论失效"——S7 :171 明示 D-01 静态+行为独立成立，报告 :147 亦保留该限定，成立

## 建议修改（只提建议，未改动文件）

| # | 文件:行 | 现状 | 建议改为 |
|---|---------|------|---------|
| 1 | `revision-proposals.md:18` / `audit-report.md:71` | `templates/task_plan.md:497` 折叠列 | `templates/task_plan.md:502`（表头）/ `:497`（说明句，需同步改事实错误） |
| 2 | `audit-report.md:38` | `00:21:39` + 命中 32 | `01:30:00`（spec，命中 18）/ `01:29:32`（prompts，命中 32） |
| 3 | `audit-report.md:145-147` | verified 17 枚举 18+4、FACT LOCK 双计 | 改为"清单项 17 verified / 3 partial / 0 unverified；[22]-4 与 [17] FP-2 为被推翻子结论" |
| 4 | `audit-report.md:20` | P0 14（3+6+3+4）、P1 11、P2 9 | P0 14（3+5+2+4，B-02 已降 P1）、P1 7、P2 0（P2 仅 1 条方案项 RP-29） |
| 5 | `revision-proposals.md:95` | P1 12 条（合计 29） | P1 14 条（合计 31） |
| 6 | `revision-proposals.md:3` | "一一对应" | 删除该断言，改"S9 补强 D-01~D-14 为独立编号空间，与报告 D-xx 不同义" |
| 7 | `revision-proposals.md:54` | RP-19 对象 check-plan-dispatch.sh | 对象改 `check-delegation.sh:421-424,445` |
| 8 | `revision-proposals.md:28` | "（RP-13）" | "（RP-17）" |
| 9 | `audit-report.md:110` | "7 个当下即可归档" | 加"（未验证：archive-plan dry-run 属写操作，S7 已跳过）" |
| 10 | `audit-report.md:8` | "无锚项一律标未验证" | 补"B-02/C-06/D-05/A-09 为 checkpoint 级锚，非 file:line" |
| 11 | `audit-report.md:18` | "（V-C5 面实测）" | "（S4-runner.md 实测）" |
| 12 | `findings.md:37,:46`（事实源，非本次交付物） | 仍主张"零落盘/虚假进展" | 按 S7 FP-1 改写为"终态有产物（Edit 20/Write 3），S8 为 01:03 运行中截断快照" |

---

## 验证摘要

- 总发现 24（CRITICAL 4 / HIGH 12 / MEDIUM 4 / NIT 4），另 3 项负结果
- 已验证 24（每条均经 Read 或 grep/sed/stat 复现原文）
- 通过率 **100%**
- 结论：两份交付文档主体与 S7 复核结论一致（FACT LOCK 撤回、C-05/B-02 降级、C-04 措辞均已同步），但存在 4 项交付阻断级缺陷：RP-04 锚点错行（P0 修复会落空）、§7 复核计数不可划分、VC-3/VC-5 证据载体为空、FACT LOCK 时间线混用旧数据。建议按上表 1-12 逐项修正后再交付。
