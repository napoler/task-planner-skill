# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements（/goal 原文解释——解释不替代原文，原文锚定见 task_plan.md 🎯 区块）
- R1/R4「从根源解决，不只解决基础性问题」= 每个缺陷必须修到机制/载体/守卫层（同类问题被系统性阻止），显性层修补不算解决
- R2「严重偏差」= 指令在执行链被转译改写（判例：一个月→72h，dwfrun-6311f12f 在查）与执行跑偏
- R3/R7「恶意推低风险选择给用户」= 代理可判（可逆/有判据/信息在手）的决策必须自判并留痕，禁包装成询问
- R5「内容质量只改标题」判例 = 结果级需求必须分解全生产管线逐工序挖缺陷，禁只修最显性层
- R6「质量>速度」= 返工期望成本 > 彻底解决增量成本时禁选快而浅路径

## Research Findings
- **2026-10-05 侦察（主进程第一手）**：zcode 部署位 3 文件领先真源（SKILL 475 vs 461 / critical-rules 574 vs 567 / selftest-skill-split.sh:41 阈值 461→475），增量=task-v130「并行创作组」内容（Rule 21.4.1+23.9-23.13+SKILL §并行创作组），diff 已逐行核对、内容完整标注 task-v130 → 回填安全（VC-1 基准）
- **Rule 51.1 计划侧零载体复测**：`grep -rn "需求原文" skills/task-planner/templates/` = 0 命中（模板面全缺）；init-session.sh / attest-plan.sh / check-plan-dispatch.sh 挂点 0 命中 → 照模板生成的计划必然缺强制区块（审计 HIGH-3 复证实证）
- **规则账本**：46-52 landed、next=53（attest 已自动登记 task-v131）；无在途 worktree；主仓未提交=plans/ 簿记 14 文件与 scope 零重叠
- **指令篡改调查 workflow**：dwfrun-6311f12f 孤儿态（两子代理停 ask#1/ask#3 等待，属主会话死亡；本会话不可代答 pending questions）；结构根因已由对齐审计锁定=51.1 零载体；取证细节待后续 AmendWorkflow 接管（不阻塞本任务）

## 审计处置表（VC-6 — 对齐审计 13 发现逐条；来源 memory align-audit-2026-10-05.md）
| # | 级别 | 发现 | 处置 | 证据 |
|---|------|------|------|------|
| H-1 | high | zcode 位 3 文件领先真源（v130 并行创作组）未回填，重装即抹产出 | Phase 1 回填 + Phase 8 部署前置校验 | （待填） |
| H-2 | high | cursor 位严重过期（differ 35/缺 114/多 7 旧遗留） | Phase 8 全量重同步+备份后清理 | （待填） |
| H-3 | high | Rule 51.1 计划侧零载体（主模板+29 variant+三脚本无挂点） | ✅已修：init 注入（全 variant 兜底+mini 豁免+fail-open+幂等）+ attest 51.1 三锚门（fail-closed）+主模板/rule-enhancement 变体区块 | 证据：/tmp/v131-init-test/ 五路径 + /tmp/v131-attest-test/ 四例 + commit 9924b0a（subagent-state/04-06-executor.md） |
| M-1 | medium | 部署文档薄壳口径 vs 实盘全量副本两套口径 | ✅已修：INSTALL+install-stub 口径改全量副本（17/18-executor）；ARCHITECTURE:95-98 入 Phase 6 S1 | INSTALL.md:33-37 / lib/install-stub.sh 头注 |
| M-2 | medium | SKILL:251 索引行缺 Rule 50 | ✅已解：Phase 1 回填后 Rule 50 行在 :303 在位（审计基于回填前旧基线；08-executor 负结果如实登记零重复插入） | SKILL.md:303 grep 命中 |
| M-3 | medium | SKILL:9「全集 1-51」陈旧 | ✅已修：1-53（08-executor，旧锚 1-51 全仓 0 命中） | SKILL.md:9 |
| M-4 | medium | Rule 52.4 消费侧未落载体（SKILL:86 无 52 括注+Handoff 附注零命中） | ✅部分修：:86 已加 52.1 括注（08）；Handoff 附注=Phase 4 selftest 锚登记 | SKILL.md:86；Phase 4 S1 待落 |
| M-5 | medium | Rule 45.7 引用死路径（git log -S 证从未入库） | ✅已修：改指 plans/task-v111/progress.md 实存+头注释注明原因/时间/原行为（07-executor） | critical-rules.md:475-476 |
| L-1 | low | check-dispatch.sh:71 SKILL_ROOT 实指 scripts/ 目录注释自认 | ✅已修：注释如实化（遗留误称注明，代码零改动）+顺带落需求锚 advisory（P1-4） | check-dispatch.sh:72-77,410-419 四场景实测 |
| L-2 | low | Rule 16「全部模板标配」措辞 vs 35/39 实况 | ✅已修：白名单模板标配（38.3 豁免 4 类不计入）+35/39 分母（07；39=主 10+variant 29 实测） | critical-rules.md:75-76 |
| L-3 | low | agent-coverage.md 128 行锚无机器断言 | ✅已修：AC-09 精确锚=128+演进规则注记（Rule 52.3 同步义务） | selftest-agent-coverage.sh:204-217 Total 9/9 |
| L-4 | low | ARCHITECTURE.md 结构数字过期 | ✅已修：实测 9/90/10+29/6+目录树+全量副本口径（数字纠偏：审计 89→实测 90） | docs/ARCHITECTURE.md:12-21,46-84,98-108 |
| L-5 | low | opencode 物理路径 3 处文档只写 ~/.opencode | ✅已修：detect-tools.sh+README.md（readlink 实证 symlink）；sync-ide-folders.ts 登记豁免（symlink 兼容路径实测有效） | lib/detect-tools.sh:20 / README.md:44-55 |

## Issues Encountered
- （无阻断）派发守卫两次拦截（跨单元 ID 字样/brief 未引用/三文件路径花括号缩写）→ 按提示修正后通过，守卫口径已实测有效
- critic CHANGES_REQUESTED（P0×1+P1×5）：53.3「或」字自设 41.2 外第五升级出口=结构性推诿漏洞 → 当轮吸收全部修订（11/12-executor）；P2-3=Phase 4 既定工作、P2-4=init 注入设计内兜底，不改

## Technical Decisions
- 载体设计=init 注入（生成面单点全覆盖 29 variant）+ attest 校验（锁定面硬门）双机制；非 30 模板逐个补块（写入最小化+根源单点；主模板+rule-enhancement 变体补可见区块 2 文件）
- Rule 53 五子条设计见 task_plan.md Phase 3 段；零新 config 键（v126+ 先例）

## Resources
- 回填源：~/.zcode/skills/task-planner/{SKILL.md,references/critical-rules.md,scripts/selftest-skill-split.sh}
- 审计源：memory/align-audit-2026-10-05.md（13 发现全文已读入）
- worktree：/home/terry/task-planner-skill-worktrees/task-v131（branch wt/task-v131）
