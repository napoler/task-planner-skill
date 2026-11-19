#!/usr/bin/env python3
"""幂等部署通用修改合规门条款到运行时部署位（就地插入，保留他会话差异）。
每处：若新锚已存在→skip；否则精确替换 old→new，assert 替换后新锚=1 且 old 减 1。
"""
import sys

# (path, anchor_after, old, new)
def build(zcode, agents):
    jobs = []
    for base, tag in [(zcode, "zcode"), (agents, "agents")]:
        disc = f"{base}/task-discipline/references/critical-rules-discipline.md"
        cr   = f"{base}/task-planner/references/critical-rules.md"
        disp = f"{base}/task-dispatch/references/critical-rules-dispatch.md"
        # 74.7 通用修改合规门（74.6 后，含 ### 76 后缀唯一定位）
        jobs.append((disc, "74.7 **通用修改合规门",
            "④ SKILL.md Rules 全集演进至 1-76+合规清单 C51/C54+用户新指令处理段三判门指引。违规按 Rule 26 降质处置。\n\n### 76 总结阶段格式可读性与审查清单实体化纪律 — task-v166",
            "④ SKILL.md Rules 全集演进至 1-76+合规清单 C51/C54+用户新指令处理段三判门指引。违规按 Rule 26 降质处置。\n\n74.7 **通用修改合规门（Modification Compliance Gate，P0，2026-11-19 task-modification-compliance-gate-20261119；判例 sess_ba603cf5 4-12s 硬约束被无依据放宽为 3s/15s）**：对**任何已确立规范/规则/验收约束/阈值/区间**的修改或放宽（含未登记 Spec-Baseline 的项目/SOP/技能侧硬约束、执行期产物内口径的就地调整），落地前必须先在 `task_plan.md`「📋 变更标注表」逐条登记**合规四元组**：`变更对象+当前值(原文 verbatim) → 拟变更值 + 变更依据(证据/用户逐字授权) + 影响评估(破坏或放宽了哪些既有约束) + 处置(保留/等价替代/用户授权放宽)`。**无依据放宽=禁止落地（P0）**：区间型约束的「删下界/抬上界/改单边/增加软豁免条款（超拍登记·NOTE 保留·叙事必要类）」均属放宽，无用户逐字授权+证据即判 `[MODIFICATION NON-COMPLIANT]`（PLAN TAMPERED 同族 P0，交付作废），唯一合法路径=STOP→用户显式授权→Decisions Made 登记→更新标注→（若命中基线则按 51.15 更新并）重跑 attest 重锁。**与 51.15 分工**：51.15 管已登记基线的冻结与四环消费，本条管「未登记规范/执行期就地放宽/单边口径」三类覆盖缺口，是所有修改的通用前置合规门（先过本条再判是否叠加 51.15）。执行期发生改规范时须即时回填标注表，禁「先改后补」；未登记合规四元组=未获修改许可。机制=L0-T 文本锚 + 复用 74.3 标注表/20.1 attest/51.15 四环，零新脚本零新 config 键。Why：用户判例 root——「连合规性都没有就做恶意修改，只会投毒」；无通用前置门时，规范被静默放宽无法在落地前拦截。\n\n### 76 总结阶段格式可读性与审查清单实体化纪律 — task-v166"))
        # 106.7 通用放宽判据
        jobs.append((disc, "通用放宽判据（Rule 74.7",
            "**禁默认「前序合规则本轮必合规」**——前序状态不构成免检理由。判例锚：sess_ba603cf5 EP17-32 全合规但 EP33 起在无回归门情况下静默退化出 59 个越界镜。",
            "**禁默认「前序合规则本轮必合规」**——前序状态不构成免检理由。判例锚：sess_ba603cf5 EP17-32 全合规但 EP33 起在无回归门情况下静默退化出 59 个越界镜。**通用放宽判据（Rule 74.7 纪律域，本门延伸）**：区间约束缺上下界（如仅 `≤上限` 无 `≥下限`）或引入「超拍登记/NOTE 保留/叙事必要」类软豁免，等同无依据放宽，按本门 STOP——不限于已登记基线，适用于所有已确立规范/阈值/区间。"))
        # 51.15 跨域指针 + none-justified
        jobs.append((cr, "Rule 74.7 通用修改合规门",
            "**执行链四环绑定**：派发必带（22.4e）、复检逐条核验（103.3b）、返工/续写全量回归（106.7）、终验基线门（verification-gate 84.15），缺一即视为规范未受管。机制=L0-T 文本锚 + 复用现有 attest/check 门，零新脚本零新 config 键。",
            "**执行链四环绑定**：派发必带（22.4e）、复检逐条核验（103.3b）、返工/续写全量回归（106.7）、终验基线门（verification-gate 84.15），缺一即视为规范未受管。**登记前置强化**：计划期须对用户/项目/SOP/技能中「已确立硬约束」做来源扫描，候选约束逐条登记进基线区块；确认无基线候选须显式写 `none-justified`，禁静默遗漏（登记遗漏=未受管）。**通用修改合规门跨域指针**：本条管已登记基线的冻结与四环消费；对「未登记规范/执行期就地放宽/单边口径」的全部修改，须先过纪律域 Rule 74.7 通用修改合规门（合规四元组 + 无依据放宽 P0 禁止），先过 74.7 再判是否叠加本条——两门互补，禁以「未登记」为由绕过合规论证。机制=L0-T 文本锚 + 复用现有 attest/check 门，零新脚本零新 config 键。"))
        # dispatch 22.4e 回传
        jobs.append((disp, "Rule 74.7 派发面联动",
            "Why：判例 sess_ba603cf5 中子代理只收到局部创作 prompt、未携带 4-12s 硬约束，导致 3s/15s 分镜静默产出——「规范在计划里但没进派发」= 规范不受管。",
            "Why：判例 sess_ba603cf5 中子代理只收到局部创作 prompt、未携带 4-12s 硬约束，导致 3s/15s 分镜静默产出——「规范在计划里但没进派发」= 规范不受管。**执行体禁自行改规范口径（Rule 74.7 派发面联动）**：子代理在执行中发现需修改/放宽任一已确立规范/阈值/区间（含基线项或产物内口径）时，**禁止自行落地**，须回传主进程按 74.7 合规四元组 +（命中基线则）51.15 路径处置（STOP→用户授权→Decisions→更新→重 attest）；子代理就地放宽= `[MODIFICATION NON-COMPLIANT]`（P0，交付作废）。"))
    # agents 位 SKILL.md 2.5d（zcode 位薄壳跳过）
    jobs.append((f"{agents}/task-planner/SKILL.md", "通用修改合规门（Rule 74.7",
        "     - **判据**：先问是补充还是替代——补充是常态，替代是例外，删除是特许；未做三判即写入 = P0 违规",
        "     - **判据**：先问是补充还是替代——补充是常态，替代是例外，删除是特许；未做三判即写入 = P0 违规\n     - **通用修改合规门（Rule 74.7，P0）**：执行期任一对已确立规范/阈值/区间的改动（含产物内口径就地放宽），落地前必须先补 `task_plan.md`「📋 变更标注表」合规四元组（变更对象+当前值原文→拟变更值+依据+影响评估+处置），无用户逐字授权+证据的放宽禁落地；若命中 `🔒 规范基线` 同步走 51.15 STOP→授权→Decisions→更新→重 attest。禁「先改后补」；详见 task-discipline/references/critical-rules-discipline.md Rule 74.7"))
    return jobs

def main():
    zcode, agents = sys.argv[1], sys.argv[2]
    ok = 0; skip = 0; fail = 0
    for path, anchor, old, new in build(zcode, agents):
        with open(path, encoding="utf-8") as f:
            txt = f.read()
        if anchor in txt:
            print(f"SKIP (anchor present): {path} :: {anchor[:30]}"); skip += 1; continue
        n = txt.count(old)
        if n != 1:
            print(f"FAIL (old count={n}, expect 1): {path} :: {old[:40]}"); fail += 1; continue
        out = txt.replace(old, new, 1)
        if out.count(anchor) != 1:
            print(f"FAIL (new anchor assert): {path}"); fail += 1; continue
        with open(path, "w", encoding="utf-8") as f:
            f.write(out)
        print(f"OK  {path} :: {anchor[:30]}"); ok += 1
    print(f"RESULT ok={ok} skip={skip} fail={fail}")
    return 1 if fail else 0

if __name__ == "__main__":
    raise SystemExit(main())
