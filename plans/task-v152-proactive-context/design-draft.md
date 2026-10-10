# Design Draft — Rule 67 设计定稿（task-v152 Phase 1 产物）

<!--
  WHAT: Rule 67 六子条条款草案全文 + session-handoff.md 五段模板草案 + hook 接线施工图 + 钉值级联清单。
  WHY: Phase 3 各 S-unit 的施工蓝本——执行体按本文件落笔，不自行重新设计。
  WHEN: Phase 1 产出；D1/D2/D3 已按 Rule 44.3 自动裁决（task_plan.md Decisions Made 三行）。
  锚点时效: 行号锚均标「实施日重验」（worktree 与部署位在途写入会漂移，过期锚禁盲用）。
-->

## §1 Rule 67 条款草案全文（拟追加 references/critical-rules.md 文末，Rule 65 段落之后）

```markdown
### 67 上下文压力主动评估与会话交接纪律（P0, 2026-10-09 task-v152，目标：执行期上下文过长/混乱从「被动等事件触发」升级为「主动三档评估→三态裁决→即压缩或交接」，根除长任务上下文膨胀与混乱累积；判定面=LLM 行为留痕+posttooluse 节奏提醒+selftest 静态守护、零新 config 键；衔接 Rule 19/22/24/29/61/62/64.3/65，既有条款原文零改动）

本条源于用户 2026-10-09 反馈原话（逐字抄录于 plans/task-v152-proactive-context/task_plan.md「🎯 用户需求原文」，51.1 口径）：R1「在遇到上下文过长，或者说出现就是出现混乱的时候，我希望可以进行主动地进行压缩，或者说是整理优化」；R2「如果实在是解决不了，也可以撰写交接文档，要求在新的会话中开启」；R3「核心就是主动评估、主动优化」。归因（实证，findings.md Research Findings A/B/C/G）：Rule 29.1 触发仅三档事件驱动（Phase complete/会话恢复/用户显式）且 check-context-hygiene.sh 4 项全为行数代理指标——「上下文过长/混乱/重复失败」无任何信号触发；Rule 29.5 自述 hook 未接读取、Rule 65 周期回顾亦未接 hook——主动性能靠纯 LLM 自律不可靠；全仓无会话级交接文档模板/机制（grep 会话交接/交接文档零命中）——「解决不了转新会话」无载体。本条补齐「主动评估→主动优化→交接兜底」链路。

67.1 **主动评估触发（三档，proactive triggers）**：① **节奏档**：`zcode-posttooluse.sh` 既有 drift-rhythm 节奏（64.3，每满 N=10 次工具调用）注入点同行追加评估提醒（67.5 承载，不新增计数器）；② **事件档**：同一子任务连续失败 ≥2 次（22.7 强制换档时点）、drift-checker 判 DRIFT、harness 上下文压缩（compaction）发生后的恢复点（19.3/62.1 四文件读序完成时）；③ **高危信号档**：periodic-review 判 CONTRADICTION（65.5 输出）、同一文件 ≥3 次往复修改、Todo 与计划状态失同步（S2 检出）。What=评估不依赖模型记忆，三档信号任一命中即当次评估；Why=Rule 29.1/65.1 事件驱动覆盖不到「长会话静默膨胀」，0% 执行率类缺陷（v148 判例）根因即触发靠自觉。

67.2 **三态裁决（assessment contract）**：按四信号自评——① 距上次回顾的工具调用轮数；② 计划三文件行数与陈旧度（复用 `check-context-hygiene.sh` exit 码语义：0=clean / 1=建议 / 2=严重）；③ 同一目标重复失败次数（progress Error Log 计数）；④ 结论矛盾计数（periodic-review.sh 输出）——裁决三态：**HEALTHY**=继续执行，零动作；**PRESSURE**=上下文膨胀但方向清晰（信号② 严重档或信号① 超窗）→ 触发 67.3；**CONFUSED**=方向丢失（信号③ ≥2 或信号④ 非零且连续 2 次评估未收敛）→ 触发 67.4。**裁决必须留痕**：progress.md 当次记一行 `[assess] <verdict> — <一句话依据>`，无痕迹=未评估（64.1 同族：无证据链=未执行）。What=判定有输入、有输出、有痕迹；Why=可复核防幻觉式 HEALTHY（64.4 反空转判定同款约束）。

67.3 **PRESSURE 主动压缩整理（compress-now，命中即执行）**：裁决 PRESSURE 后**不等 Phase complete**（29.1 事件驱动通道原文不变，本条为「主动」增量通道）当次执行——a) 跑 29.2 退场 SOP 三类动作（superseded 标记/≥5 条同主题折叠入 `## 压缩归档`/progress 已完成 Phase 段折叠）；b) 跑 29.3 压缩 SOP（findings >500 行强制压缩）；c) 增补蒸馏动作：本 Phase 高频结论按 62.3 蒸馏入 knowledge-brief §2/§4（已在 kb 的更新证据锚，不在 findings 重复展开）；d) 执行后 progress 记一行 `[compress] <动作> <三文件行数变化>`。原则沿用 29.2：被验证无关紧要的才退场，拿不准保留标「待复核」。What=主动、即时、可追溯的压缩；Why=R1「主动进行压缩/整理优化」的直接落地——既有 29.2 能力在，缺的只是「不等事件、命中就做」的触发语义。

67.4 **CONFUSED 会话交接兜底（session handoff，解决不了→新会话）**：触发条件（任一）——① 22.3 五档兜底（改派/拆细/升档/接管/AskUser）穷尽后同一问题仍失败 ≥2 轮；② 连续 2 次评估裁决 CONFUSED。动作：按 `templates/session-handoff.md` 五段模板写 `<plan-dir>/session-handoff.md`（**目标锚 / 已完成与证据 / 当前断点 / 未决问题 / 新会话恢复指令**）→ Decisions Made 登记交接行 + progress 记 `[handoff] <文档路径>+<触发原因>` → 深水区执行动作停止（轻量簿记/只读验证可继续），向用户呈报文档路径与新会话启动指令。新会话恢复链（模板第 5 段固化）：`session-catchup.ts` 中断点检测 → 四文件读序（62.1：task_plan→progress→findings→knowledge-brief）→ `Skill("plan-resume")` 自主续推 Top 1（24.5）→ 从「当前断点」续做，**禁止重复已完成步骤**。What=结构化交接产物+可复制启动指令；Why=R2 落地载体；交接≠任务终止，是把易失上下文换新（RAM→Disk→新 RAM）。

67.5 **hook 节奏承载（rhythm nudge 接线）**：`scripts/zcode-posttooluse.sh` 在 64.3 drift-rhythm 注入点（grep 锚=注入文案 `[drift-rhythm]`，实施日重验行号）经同一 additionalContext 通道追加单行：`[context-pressure] 主动评估（Rule 67.2）：四信号自评 → HEALTHY 继续 / PRESSURE 即压缩(67.3) / CONFUSED 写会话交接文档(67.4)`——前置判定 env `TASK_PLANNER_CONTEXT_PRESSURE != off` 才注入；**既有 drift-rhythm 三键计数（count/last_inject/due）与注入文案零改动**（64.3 性能约束同款：O(1) 三键读写，禁止全仓扫描）。注入=软提醒不拦截（PostToolUse 平台事实，64.3 同款），拦截力由 67.2 留痕与 Phase complete 门控承载。只改技能侧脚本，**不动 `/home/terry/.zcode/cli/config.json`**（hooks.events 挂载表零改动）。

67.6 **机制守护（mechanism guard）**：零新 config 键（64.6 同范式，键膨胀=配置面失控面）——开关与调参全走 env：`TASK_PLANNER_CONTEXT_PRESSURE`（on/off，默认 on）/ `TASK_PLANNER_CONTEXT_PRESSURE_N`（提醒间隔倍数，默认 1=随 64.3 每次同触发；≥2 隔次注入降频）。静态守卫 `scripts/selftest-context-pressure.sh` 断言面：六子条文本锚（`^67\.[1-6] `=6）/ 三态 verdict 词（HEALTHY|PRESSURE|CONFUSED ≥3）/「主动评估」「主动优化」关键词 /「不等 Phase complete」语义锚 / 交接模板五段在位与恢复链锚 / hook env 锚与 drift-rhythm 零改动负锚 / SKILL「Critical Rules 1-67」三处 / C45 在位 / registry 新行——并入 `selftest-registry.tsv`（4 列表头+N 行，SR-12 动态行数断言自动跟随）。SKILL.md 接线三处：Rule 67 摘要 bullet、「Critical Rules 1-65」→「1-67」计数三处级联、合规清单新增 C45。关系：Rule 29.1/29.2/29.3/29.5、Rule 65.1 触发时机与全部既有条款**原文零改动**——67 只追加「主动」通道与交接兜底，29 管「多→退场」SOP 本体，65 管结论一致性，61/64 管漂移，分工正交。
```

**C24/C36 自审（Phase 1 清单项）**：
- 36.2 归因：用户显式要求新能力（R1-R3 原文在案）→ 指向技能本体增强，提案合法
- 36.3 删除基线：**纯增量**——critical-rules 文末追加 / SKILL 三处计数改写=机械同步非语义删除 / 新模板 / hook 单行追加 / 新 selftest；**删除性行为清单 = ∅**
- 36.4 功能性删除/语义改写 = 无 → 无需 D6 逐项确认
- 36.6 回归 = Phase 4 全量 selftest 对基线
- 术语语义锚定（v150 P11 判例）：PRESSURE/CONFUSED/HEALTHY 三词在条款、模板、selftest、hook 注入文案**逐字回写**，禁同义改写

## §2 templates/session-handoff.md 模板草案全文（S3 蓝本）

```markdown
# Session Handoff — <task-id>（会话交接文档）
<!--
  WHAT: 当前会话无法继续时的结构化交接产物（Rule 67.4 CONFUSED 触发）。
  WHY: 会话上下文易失（RAM），本文件=持久断点快照（Disk）——新会话凭它免重做、免重复失败。
  WHEN: 写入 <plan-dir>/session-handoff.md；新会话第一动作=Read 本文件。
  旧会话职责: 写完+登记（Decisions Made + progress [handoff] 行）+呈报路径；深水执行停止。
-->

## 1. 目标锚（Goal）
- task_plan 绝对路径: <abs>/task_plan.md（sha256 或最后锁定时间）
- Goal 一句话: <照抄 task_plan Goal 段>
- 需求原文指针: task_plan.md「🎯 用户需求原文」R1..Rn（禁转述替代）

## 2. 已完成与证据
| Phase/S-unit | 状态 | 验收证据锚（file:line / 命令输出） |
|---|---|---|
| <逐行> | complete/partial | <三证据> |

## 3. 当前断点（新会话从这里继续）
- 断点一句话: <卡在哪>
- 最后一次失败现场: <错误关键行原文 + 尝试次数>
- 相关检查点: <subagent-state/ 绝对路径>
- 已排除路径: <22.3 试过什么+为何不行（防重复失败）>

## 4. 未决问题
- <问题 + 候选方案 + 推荐项>
- 禁令核对: notepad-learnings.md「🚫 被否决方案」段（Rule 32.2，提方案前必查）

## 5. 新会话恢复指令（逐条照做）
1. `cd <repo> && bun ~/.zcode/skills/task-planner/scripts/session-catchup.ts`（中断点检测）
2. 按四文件读序恢复（Rule 62.1，绝对路径）：
   Read <abs>/task_plan.md → <abs>/progress.md → <abs>/findings.md → <abs>/knowledge-brief.md
3. `Skill("plan-resume")` 自主续推 Top 1（Rule 24.5；config autonomous_resume=true）
4. 从 §3「当前断点」继续；**禁止重复 §2 已完成步骤**（防重做）
5. 恢复后首动作: 运行 `bash <skill>/scripts/check-context-hygiene.sh <plan-dir>` 确认上下文基线

---
交接登记（写回）: task_plan.md Decisions Made 加一行 `session-handoff: <路径>+<触发原因>, <时间>`；
progress.md 加 `[handoff]` 行；新会话恢复后在该行尾追加 `→ resumed by <新会话>`。
```

## §3 hook 接线施工图（S4 蓝本；2026-10-09 20:5x 实施细化——首派发现 F9 单轮单 JSON 约束后修订）

- **文件**：`scripts/zcode-posttooluse.sh`（仓 worktree 施工 + Phase 6 随部署同步；**禁止改** `/home/terry/.zcode/cli/config.json`）
- **插入位**：`drift_rhythm_check()` 内 due=1 的 else 分支（当前实测 :343 `emit "[drift-rhythm] ..."` 处，实施日重验）
- **F9 硬约束（zcode-posttooluse.sh:323 注释 + selftest-drift-enforcement DCE-19）**：单轮 stdout 恰好 1 行 JSON → **禁止新增第二次 emit**；`emit()` 走 `jq -Rs .`，消息内嵌 `\n` 合法（单 JSON 行内两行文本）
- **正确形态（单 emit 携带双行）**——在 else 分支 emit 前插入 `_cp` 计算块，emit 行改为后缀拼接（drift 文案字节前缀保留）：
  ```bash
  _cp=""
  if [ "${TASK_PLANNER_CONTEXT_PRESSURE:-on}" != "off" ]; then
    _cpn="${TASK_PLANNER_CONTEXT_PRESSURE_N:-1}"; case "$_cpn" in ''|*[!0-9]*) _cpn=1 ;; esac
    [ "$rhythm_n" -ge 1 ] 2>/dev/null || rhythm_n=10   # 除零防护（env 可注入 0）
    if [ "$_cpn" -eq 1 ] || [ $(( rhythm_count / rhythm_n % _cpn )) -eq 0 ]; then
      _cp="$(printf '\n%s' '[context-pressure] 主动评估（Rule 67.2）：四信号自评 → HEALTHY 继续 / PRESSURE 即压缩(67.3) / CONFUSED 写会话交接文档(67.4)')"
    fi
  fi
  emit "[drift-rhythm] 距上次偏移检查已 ≥${rhythm_n} 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套${_cp}"
  ```
- **零改动红线（修订版）**：`count/last_inject/due` 三键读写与 F10 前置守卫零改动；drift 文案作为前缀子串保留；**emit 行允许追加 `${_cp}` 后缀**（实测：全仓 selftest 对 drift-rhythm emit 行/文案零断言，原「零 hunks」为设计自设保守项，2026-10-09 20:5x 修订）；`git diff` 仅限 else 分支内新增块+emit 后缀
- **语义**：context-pressure 随 drift 注入同发（每 rhythm_n=10 次调用）；`TASK_PLANNER_CONTEXT_PRESSURE=off` 跳过；`_cpn≥2` 每 N 个 drift 周期携带一次（降频）；F10 守卫（计划完结/超 24h）天然继承——非活跃期不注入
- **冒烟**（Phase 4 S6）：fixture 状态文件写满计数→直调脚本→断言**单行 JSON** 且其解码文本含 `[drift-rhythm]` 与 `[context-pressure]` 两段；`bash -n` 先行
- 文件头注释补一行 What+Why（task-v152 Rule 67.5，含 F9 单 emit 理由）

## §4 钉值级联清单（S2 蓝本，实施日重验行号）

| # | 落点 | 改动 | 验证锚 |
|---|------|------|--------|
| 1 | SKILL.md 「Critical Rules 1-65」三处（实测 :9,:280,:360） | →「1-67」 | `grep -c 'Critical Rules 1-67' SKILL.md` =3 |
| 2 | SKILL.md Rule 摘要 bullet 列表尾部 | 追加 Rule 67 摘要行（衔接 65 行） | `grep -n 'Rule 67' SKILL.md` ≥1 |
| 3 | SKILL.md 合规检查清单 | 新增 C45 行（主动评估自查：三档触发已响应/[assess] 留痕/CONFUSED 已交接或登记豁免） | `grep -n 'C45' SKILL.md` ≥1 |
| 4 | critical-rules.md References 表 SKILL 侧描述（若含 Rule 枚举） | 1-65 → 1-67 | grep |
| 5 | 全仓旧 label 消费面 | `grep -rn '1-65' skills/task-planner/` 逐个判定改/留（锚演进必跨脚本 grep 旧 label——SR-11 判例；selftest 内钉值同步） | 全 selftest 回归 |
| 6 | SKILL 行数钉值 | grep selftest 内 `SKILL.md` 行数断言（v149 钉 510 系）→ 按新增行数上调 | 回归=基线 |
| 7 | selftest-registry.tsv | 加 1 行（selftest-context-pressure.sh，4 列） | `selftest-registry.sh` T02-T05 + SR-12 |
| 8 | docs/ARCHITECTURE.md ×62 | **不动**（历史债非本任务引入，登记 deferred） | - |

**S-unit 消费方式**：S1 读 §1；S2 读 §4；S3 读 §2；S4 读 §3；S5 读 §1（67.6 断言面）+ §4#7。
