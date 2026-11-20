---
id: modification-compliance-gate
title: "通用修改合规门（Rule 74.7）：无依据放宽=投毒的落地前拦截（sess_ba603cf5 判例）"
tags: [kb, anti-poison, modification-gate, compliance-quadruple, spec-baseline, anti-regression]
sources: [plans/task-modification-compliance-gate-20261119/findings.md, plans/task-modification-compliance-gate-20261119/verification.md, forensics/modification-compliance-gap-20261119.md, skills/task-discipline/references/critical-rules-discipline.md]
updated: 2026-11-19
---

# 通用修改合规门（Rule 74.7）

## 问题与根因
用户判例 sess_ba603cf5：4-12s 单镜限制（原本有理有据的模型能力硬约束）被静默放宽为 3s/15s，用户核心追问「为什么会被恶意修改？关键是**修改是否合规**——连合规性都没有就做恶意修改只会投毒」。
一手取证（`forensics/modification-compliance-gap-20261119.md`）结论：**无单点篡改**（git blame 佐证），真实机制=硬约束从未下沉为技能/QC 门 + 体系缺覆盖「所有已确立规范」的通用「修改前合规论证+授权」硬门。已归档的 `task-spec-baseline-freeze-20261119`（Rule 51.15）只冻结**已登记** Spec-Baseline，覆盖不到三类缺口：B1 未登记规范、B2 执行期就地放宽、B3 单边/软豁免未被识别。

## 机制（Rule 74.7，P0，纯文本零新脚本）
- **合规四元组**（任何已确立规范/规则/阈值/区间的修改落地前必登 `task_plan.md`「📋 变更标注表」）：`变更对象+当前值(verbatim) → 拟变更值 + 变更依据(证据/用户逐字授权) + 影响评估(放宽了哪些既有约束) + 处置(保留/等价替代/用户授权放宽)`。
- **无依据放宽=禁止落地**：区间型「删下界/抬上界/改单边/加软豁免（超拍登记·NOTE·叙事必要）」均属放宽，无用户逐字授权+证据 → `[MODIFICATION NON-COMPLIANT]`（PLAN TAMPERED 同族 P0，交付作废）。合法路径=STOP→用户授权→Decisions→更新→（命中基线按 51.15）重 attest。
- **与 51.15 分工**：先过 74.7（通用前置门），再判是否叠加 51.15（已登记基线冻结+四环消费）；禁以「未登记」为由绕过合规论证。
- **四处联动**：`critical-rules.md:109`（51.15 加 none-justified 登记前置 + 74.7 跨域指针）、`SKILL.md:122`（2.5d 执行期改规范必回填）、`critical-rules-dispatch.md:66`（22.4e 执行体禁自行放宽、回传主进程）、`discipline.md:757`（106.7 通用放宽判据）。

## 关键教训
- **部署位形态差异**：`~/.zcode/skills/task-planner/SKILL.md` 是薄壳（指向 canonical source），不含 2.5d 段，SKILL 条款只在 `~/.agents/skills` 完整位插入；两位置信源判断不可盲目 cp。
- **幂等部署脚本断言**：Python `str.count` 的字符串锚禁用 grep 正则行首符 `^`（曾致 2 FAIL），改纯文本锚后 ok=2/fail=0；负控制错锚 rc=1 证明验证非恒真。
- **Rule 27.3 porcelain 预检**：scope 表「允许的文件」列列真实源文件路径时，会把「他会话 stash pop 回来的 staged 改动」误判为本任务未提交变更；本任务改动已 commit 时，scope 列用描述性文字、真实路径移到表下注释留痕（不对抗检查）。
- **check-delegation 白名单前缀**：主进程直做 Phase 的 Executor 理由须以「白名单②：」开头，否则被判 self_declared_reason 触发 DELEGATION GATE violation。
- **EVIDENCE-ANCHOR**：`[goal:Gn]` 证据行内命令用 `bash check-complete.sh`（不带域外绝对路径），证据产物用计划目录内绝对路径，否则域外路径 token 判 FAIL。

## 范围边界
本任务=制度层修 skill（Rule 31.8），交付=规则文本条款。StoryLab 已产出的 3s/15s 违规分镜修复 + 项目层 4-12s 规范下沉属跨项目另一仓 `task-storyboard-duration-fix-001`，未授权不触碰；本机制对新会话生效，历史产物不自动回溯。
