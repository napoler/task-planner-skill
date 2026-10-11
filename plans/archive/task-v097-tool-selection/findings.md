# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话（2026-09-30 /goal 会话）: "优化当前 skill 确保可以结合 /workflow /goal 等这里工具来动态优化执行；可以考虑在模板引入依据不同任务选择不同的工具来执行任务；当然可以在模板工具创建skill中加入主动分析引入最合适有效的工具来解决问题"
- 拆解: ① skill 层与 /workflow、/goal 等 harness 工具的动态结合执行机制 ② 模板层引入按任务类型的工具选择区块 ③ 计划创建环节主动分析选最适工具（plan-writer 契约）
- 交互语境: /goal 自主会话 → interaction_mode: silent（静默决策清单随交付披露）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| Rule 39 全文+39.7 | skills/task-planner/references/critical-rules.md:339-390 | ☑（plan-writer 消费,本主进程复核计划时采信） | Research Findings 条 1 |
| SKILL.md 四锚 | skills/task-planner/SKILL.md:47,191,268,292 | ☑ | Research Findings 条 2 |
| 行数断言基线 | scripts/selftest-{knowledge-brief:38,skill-collab:82,skill-split:41,execution-stability:72,batch-pilot:55}.sh | ☑ | Research Findings 条 3 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- [plan-writer 侦察 2026-09-30] Rule 39 位于 CRIT L339-390（文件 391 行）,Rule 40 纯追加插入点=L391 后;39.1（L373）/39.7.2 原文须逐字保全。证据: knowledge-brief.md §2/§3。
- [plan-writer 侦察] SKILL.md=430 行,四锚: 协同路由 L47 / C27 L191 / Rule39 摘要 L268 / References L292;另有 L239 索引行。≤558 行数断言 5 处 + skill-split ≤430 目标线（当前恰在 430,净增预算极紧→行位替换优先）。
- [plan-writer 侦察·最大风险] WF-10 断言要求 4 索引文档（SKILL×2/CLAUDE.md/README_zh×2/skills README×1）「Rules 1-39」命中总和 ≥6——SKILL 两处改 1-40 则总和降 4 必 FAIL。默认对策 b=措辞「Rules 1-39（含 Rule 40 …）」保计数,P1-S2 实测后可切对策 a（scope 扩围 4 文档）。证据: selftest-workflow-orchestration.sh:52-66。
- [plan-writer 侦察] selftest 37 脚本+registry tsv 37 行;v096 记忆基线 36 脚本 592/0 仅参考,P1 实测定基线;companion 部署走 lib/install-companion.sh（companion/agents/*.md → ~/.zcode、~/.claude 的 agents/;opencode 位 plan-writer.md 存在性未核实=KQ4,P6-S3 实测）。
- [plan-writer 侦察] check-delegation 白名单理由关键词正则含「白名单①-⑥/git 编排/机械验证/计划系统文件」等——本计划主进程 Phase 理由已按此措辞;预期委派率≈0.64<0.7 依赖 25.4a WHITELIST-EXEMPT。
- [P1 实测 2026-09-30] 基线=worktree 内 36 脚本 **592 PASS / 0 FAIL**（35 脚本 Total 求和 570 + final-gate-hash 22）;对策 b 由 P1 grep 实测确证——4 处宽容正则锚（RV-10/EL-11/VT-10/CD-18）+ WF-10 计数 ≥6 共同锁死「Rules 1-39」字面子串,语义更新只能用「Rules 1-39（含 Rule 40 …）」括注形态。证据: progress.md Phase 1 Test Results。
- [P2-S1 产出 2026-09-30] Rule 40 六子条已落 worktree critical-rules.md（391→402 行,纯增 11 行,deletions=0,L1-391 零变化）。要点: 40.1 六类工具面含禁假设不存在工具约束;40.2 区块定位=Executor 上游分析不替代+禁伪行（### Phase N:/**Status:**/**Executor:** 三形态）;40.3 /goal 披露「不可代调、不可读取运行态」;40.4 建议登记制+39.1 红线原文不动;40.5 机器校验边界如实披露;40.6 零新 config 键+WF-12 properties=40 维持。证据: wt git diff + checkpoint 03-executor.md。
- [P2-S2 产出 2026-09-30] SKILL.md 430→433 行（净增 3: 协同路由 Rule 40 行/C28/Rule 40 摘要行）+L241/L295 行内括注（+0 行）;selftest-skill-split 上限 430→433。对策 b 实证成立: 字面「Rules 1-39」保留 ×2,「1-40」零命中,6 selftest 复跑全 0 FAIL（WF 16/split 41/kb 16/collab 25/stability 19/batch-pilot 10）。证据: 04-executor.md + 主进程复跑。技术备忘: 派发守卫要求 prompt 含三文件字面 token 且 ≤3000 字符 → 「任务书落盘+短 prompt 引用」为标准派发形态（Rule 35.3）。
- [P3 产出 2026-09-30] 模板层三落点齐: general 模板「🧰 工具选择与编排」区块（L133,+14 行,含定位声明+工具面表+40.4/40.3 判定行）+ mini-lite 豁免声明行（Rule 38.3 白名单延伸,45≤80）+ subagent_dispatch §2 工具面提示行（8 字段标签零破坏）。init-session 下游冒烟通过（/tmp,6/6）。commit 676319a。另注: subagent_dispatch.md 实际 8 字段标签=status/acceptance/files/evidence/checkpoint/findings_written/blockers/confidence（与计划草案的字段名不同但契约以模板实物为准,check-dispatch 29/0 佐证）。
- [P4 产出 2026-09-30] 卫星与 agent 契约齐: template-mapping §十 工具选择映射（6 类型族×4 列+使用规则 3 条,L232,245 行 ≤300）;template-guide 场景 5 区块定制指南（字段说明+红线 5 条）;plan-writer 义务行（掌握的技能列表内,选型依据指向 mapping §十）。M-16/CD-20 锚零破坏,methodology 16/0+conclusion-discipline 24/0。两次 executor partial 的根因=任务书验收①口径缺陷（grep≥2 vs 逐字文本 1 处）,非产物缺陷——executor 正确拒绝擅改逐字内容凑数（Rule 26 精神良好样本）,已裁定 ≥1 采信并登记 Error Log。
- [P5 产出 2026-09-30] selftest-tool-selection.sh 12 断言（TS-01..12: 六子条锚/40.3 披露/40.4+40.6 行内锚/SKILL 五锚/对策 b 字面锚×2/伪行面/模板三落点/卫星/契约/零 config 键）+registry 双落点（tsv 38 行,rows=actual=37）。全量回归 **37 脚本 604 PASS/0 FAIL**=基线 592+新增 12 精确咬合。commit ccfc70f。registry.sh 为动态 comm 口径（rows=actual）无硬编码行数,零改动即正解。
- [P6/P7 收口 2026-09-30] 合并 52b434f+三位 IDENTICAL+清理 0/0;CR **APPROVED**（锚保全/40.3 披露/40.4 调和/模板契约/纯增量全 PASS）。install-companion v2.2.2 内建平台 model 行适配（zcode=custom:…:slug / claude=纯档位名）→ claude 位 diff 差异为机制内预期,对账应看正文而非 frontmatter model 行。companion/.backup-* 残留按用户既有政策移出 ~/skill-deploy-backups-task-v097/（教训: 部署备份会污染主仓 smart-merge-back 对账面,移出扫描路径）。委派率 0.571 WHITELIST-EXEMPT（verdict=ok）。**outcome: COMPLETE**。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 纯增量 Rule 40 六子条方案（方案 A） | 用户显式要求主动结合 harness 工具;39.1 原文保留规避 36.4 删除确认门;与 v087/v088 同范式零新 config 键 |
| 「🧰 工具选择与编排」区块=Executor 上游分析记录 | Executor 字段是委派门控机器事实源（check-delegation 消费）,两层职责分离不互代 |
| WF-10 计数对策默认 b（措辞保计数） | 零 scope 扩围零断言改动;不可行再切 a（登记 Decisions Made） |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
