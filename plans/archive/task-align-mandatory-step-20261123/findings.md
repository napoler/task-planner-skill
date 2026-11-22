<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-align-mandatory-step-20261123

- task_id: `task-align-mandatory-step-20261123`
- 时间: created_at=2026-11-22T19:01:56Z / updated_at=2026-11-22T21:21:16Z

## Requirements
- 把对齐设为修改完成后的强制必选步骤——所有任务在任何修改完成后必须执行对齐核查（用户原话#1逐字锚）
- 对齐内涵须覆盖所有设计相关文件的同步完整性：关联面四族+部署位+引用面，杜绝部分改部分丢弃
- 落地到技能必选步骤载体（Phase翻转前/终验交付/合规清单），并确保部署位同步无漂移
- 机器门实施（用户 #2 裁决①逐字授权）：check-complete.sh 加 ALIGN-ANCHOR GATE（默认 enforce，四锚全在位才放行）+ config.json 档位键 align_anchor_enforce + selftest-batch-pilot.sh BP-11 静态锚；机器门/断言脚本随 --deploy 全部署位同步（含授权 .agents）

## Findings
| id | text | source | tags |
|---|---|---|---|
| F-DRIFT | [RESOLVED by I-2] 主仓 HEAD 由 579c59b→ea2d6df（并行 task-retrieval-exclude 加 Rule112 两行），SKILL.md 459→461；worktree 原基于 579c59b。解决策略=INV-1/S4 规定 P2 落地前 worktree rebase/merge 到 ea2d6df，基线 461 行；净增预算收紧至 ≤9（S2≤4+S3≤5，461+9=470）；行号锚重定位 step4 :185 / 终验 :206 / G10 :251 插入 :252；S4 合并回前 wc -l ≤470 复验。FMEA-6 enforce 误伤兜底仍有效；禁默认上调 BP-08（Rule 74.7） | git log -3 / wc -l / md5 实测 2026-11-23；复审 I-2 裁决 | baseline-drift, BP-08, merge-back, RESOLVED |

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- 现有对齐机制清单：Rule103.6同步完整性(critical-rules-dispatch.md:249 ≥2受管文件四族关联面+核对清单全绿才可翻complete)；alignment-review/Rule42.6(review-library/alignment-review/SKILL.md:1-33,95-111 但critical-rules.md未检出42.6正文=缺口)；Rule106文档复检(discipline:735-760)；Rule84.14收尾回读(verification.md:58)；部署同步(smart-merge-back.sh:15-23,470,739-756 --deploy diff=0) — Explore子代理调研 agent_4ee40b84 2026-11-23
- 必选步骤落点：SKILL.md:184步骤4翻转前硬门(已有103.6文案可升格为强制对齐总入口)；SKILL.md:206-207终验智能子动作；SKILL.md:235合规清单G1-G10(无对齐独立G项，可新增G11) — Explore调研 SKILL.md 结构勘察
- 机器门缺口：check-complete.sh 检索sync|deploy|diff|mirror|部署|同步零命中=无同步/部署机器门；smart-merge-back --deploy 有post-verify diff -r；plan-doctor.sh:114有部署diff -rq；无给定源文件→自动列同步目标清单脚本(缺口) — Explore调研 脚本面勘察
- 全量 selftest 双环境对照暴露级联回归：新增 config 键 align_anchor_enforce（properties 53→54）触发约19个 selftest 固定计数断言（properties==53）FAIL；历史先例每次合法新增键均级联更新全部钉死键数断言（47→53/P-01 46→47）。须同步更新断言至54+注释来源，此即用户『所有设计相关文件同步修改不丢弃』诉求的 dogfood 实证 — code-runner-agent 全量 selftest 双环境对照回归报告（104 脚本：主仓 ΣFAIL=0 / worktree ΣFAIL=24，19 个归因 properties=54，1 个 delegation 批跑波动复跑 PASS）；勘察 selftest-agent-coverage.sh:191 等断言行
- [RESOLVED by I-2] 主仓 HEAD 由 579c59b→ea2d6df（并行 task-retrieval-exclude 加 Rule112 两行），SKILL.md 459→461；worktree 原基于 579c59b。解决策略=INV-1/S4 规定 P2 落地前 worktree rebase/merge 到 ea2d6df，基线 461 行；净增预算收紧至 ≤9（S2≤4+S3≤5，461+9=470）；行号锚重定位 step4 :185 / 终验 :206 / G10 :251 插入 :252；S4 合并回前 wc -l ≤470 复验。FMEA-6 enforce 误伤兜底仍有效；禁默认上调 BP-08（Rule 74.7） — git log -3 / wc -l / md5 实测 2026-11-23；复审 I-2 裁决

## Technical Decisions
| Decision | Rationale |
|---|---|
| [已被 D4 用户 #2 裁决覆盖，保留历史] 原默认走方案A不实施机器门；现①③改为实施机器门+静态锚，②.agents 授权覆盖 | 宪法§二文本优先铁律P0：规则偏好以文本条款落入指令载体即完成，新增脚本/hook/门属范围扩张须显式授权；.agents 属§六保护区，写须用户显式授权；机器门/子选项均属用户裁决项不默认实施 |
| 实现类任务强制worktree隔离：wt/task-align-mandatory-step-20261123@基线579c59b | 改运行中技能基础设施(skills/)，宪法§十一强制隔离；28未提交变更不在skills范围故不stash |
| D类新任务边界判定：与task-fix-all-20261123交付物无交集，旧计划挂起登记[intent-switch]并释放session-owner | skill D类判定卡：Goal/范围/交付物三要素均无交集 |
| D类切换挂起：新任务 task-retrieval-exclude-20261123（检索排除清单）Goal/范围/交付物零交集 | 本会话 sess3913b867 切走；owner已释放；旧计划保持pending待用户裁决是否续推；2026-11-23 |
| 用户 D1 三项裁决已定案（user-session-log.md #2 逐字）：①机器门实施（ALIGN-ANCHOR GATE 默认 enforce + 档位键 + BP-11 静态锚）②.agents 授权覆盖（纳入 5 位同步）③静态锚启用；覆盖原方案 A 默认值，文本优先铁律障碍由用户显式授权解除 | 用户 #2 三项全选最强方案=系统级完整交付；显式授权使范围扩张合法（宪法§二/§六）；一次 AskUserQuestion 定案后禁再上抛；机器门默认 enforce 满足『强制卡控』诉求 |
| 对齐条款去 Rule 112.1 编号，改无编号语义表述 | 实现期自查发现 Rule 112.1 已被 Rule 112 检索排除清单子条占用（critical-rules.md:253）；计划 4 精确锚均不含编号，去编号不影响验收；按文本优先铁律条款以文本落入即生效，无需新编号 |
| config.properties 53→54 级联更新 19 个 selftest 固定计数断言 | 本任务合法新增 align_anchor_enforce 致 properties=54，触发 19 脚本 ==53 断言 FAIL；历史先例每次合法新增键均级联更新全部钉死断言（47→53/P-01 46→47）；不修复即用户『部分改部分丢弃』诉求的实证回归，必须 dogfood 清零 |

## Issues Encountered
| Issue | Resolution |
|---|---|
| （本任务暂无问题记录） |  |

## Resources
- （本任务暂无资源引用）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
## 本任务 tag 倒排引用
- （本任务暂无tag 引用）
