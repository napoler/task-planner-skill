<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-template-json-compat-20261122

- task_id: `task-template-json-compat-20261122`
- 时间: created_at=2026-11-21T23:24:11Z / updated_at=2026-11-22T00:16:06Z

## Requirements
- 评估旧模板体系（4 基础模板 + 29 variant）与 JSON 体系兼容性，判定不兼容面
- 对不兼容面按用户选定档（领域段 JSON 承载 + 修门）做适应升级：schema 加可选字段承载 variant 领域段原文，render 附录吐出；修 VC-GATE 假绿 + V-N 真断
- 守住兼容红线：不动存量计划、不加 PreToolUse 硬门、软堵 render 全量覆盖不变、不改门的正当判据、不新增脚本/机器门

## Findings
| id | text | source | tags |
|---|---|---|---|
| F1 | 部分兼容：纯 CLI 流可跑通，51.1/66.5/75.1/FMEA 锚对齐；但 variant 领域段丢失、VC-GATE 假绿、V-N 真断三类实质断裂 | 首轮审计+2 聚焦探索；planctl.py:49/1584/1594-1603；attest-plan.sh:313-317；check-complete.sh:900-1055 |  |
| F2 | P0-c 假绿性质修正：控制流未因 vc_total==0 跳过下游门；有 JSON shim 时 vc-nonvacuous/rvc 真判，上一轮 dogfood 非全假；但 VC-GATE 入口计数假绿 | attest-plan.sh:313-328,329-393；check-vc-nonvacuous.sh:65-102 |  |
| F3 | 存量兼容红线：无 plan-state.json 旧计划有完整 fail-open；风险在有空壳 JSON 时 shim SKIP 假绿，已有 SOFT_ONLY WARN | attest-plan.sh:87-104；planctl.py:1710-1723 |  |
| F4 | variant 领域段形态：含门禁判据（video 未 QC 不得 complete 等），非纯文本；原样吐出只保文案不保机器语义，用户已选文本附录档并知悉 | video-type.md:19-107；writing-type.md:62-105 |  |
| F5 | W6 回归全绿：tmp 全链 5 项通过（VC-GATE 假绿→正确计数 1 条）；存量 fixture master/worktree 行为一致；selftest 双跑 90 脚本零新增 FAIL | /tmp/tjcompat-smoke 实弹 + /tmp/tjcompat-selftest-{wt,master}.log |  |

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- 部分兼容：纯 CLI 流可跑通，51.1/66.5/75.1/FMEA 锚对齐；但 variant 领域段丢失、VC-GATE 假绿、V-N 真断三类实质断裂 — 首轮审计+2 聚焦探索；planctl.py:49/1584/1594-1603；attest-plan.sh:313-317；check-complete.sh:900-1055
- P0-c 假绿性质修正：控制流未因 vc_total==0 跳过下游门；有 JSON shim 时 vc-nonvacuous/rvc 真判，上一轮 dogfood 非全假；但 VC-GATE 入口计数假绿 — attest-plan.sh:313-328,329-393；check-vc-nonvacuous.sh:65-102
- 存量兼容红线：无 plan-state.json 旧计划有完整 fail-open；风险在有空壳 JSON 时 shim SKIP 假绿，已有 SOFT_ONLY WARN — attest-plan.sh:87-104；planctl.py:1710-1723
- variant 领域段形态：含门禁判据（video 未 QC 不得 complete 等），非纯文本；原样吐出只保文案不保机器语义，用户已选文本附录档并知悉 — video-type.md:19-107；writing-type.md:62-105
- W6 回归全绿：tmp 全链 5 项通过（VC-GATE 假绿→正确计数 1 条）；存量 fixture master/worktree 行为一致；selftest 双跑 90 脚本零新增 FAIL — /tmp/tjcompat-smoke 实弹 + /tmp/tjcompat-selftest-{wt,master}.log

## Technical Decisions
| Decision | Rationale |
|---|---|
| 升级范围=领域段 JSON 承载 + 修门档（用户 AskUserQuestion 答复）；不采用骨架保留/系统级重建 | 破坏面 1-2 人日+守红线，符合文本优先铁律；领域段含门禁判据，纯文本附录只保文案不保机器语义（用户已知悉） |
| FMEA 真断甄别为数据缺口下的正当拒锁，非兼容缺陷；不改门，只在 init 指引补 fmea 登记提示 | 改门/开逃生口违反文本优先铁律与门判据不可降权原则 |
| 旧计划已终锁 feed8dbc+complete，hook 催回填不予执行；session-owner 用 mv 隔离释放 | 写入会破坏终锁（P0 反作弊）；新任务 dogfood 簿记全落新计划目录 |

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
