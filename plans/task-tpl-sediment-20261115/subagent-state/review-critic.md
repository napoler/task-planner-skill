# Critic 独立复检 — task-tpl-sediment-20261115 Phase 2（Rule 103.3/103.4 第二轮）

- 复检时间：2026-11-15
- 复检对象：worktree `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115` commit `8bc8e86`（10 文件）
- 复检方式：计划三文件 + clause-drafts 对齐后，逐个全文 Read 9 个复检对象；每条发现以 grep/Read 复现原文
- 结论：**CHANGES_REQUESTED**（B/C/D 各含 FAIL 项；A/E/F 通过）

---

## A. CA-1..CA-11 逐项勾核

| CA | 判定 | 证据 |
|----|------|------|
| CA-1 | PASS | `critical-rules-template.md:22,23` 两子条在位；34.1-34.7 各锚仍=1（grep `^34.N \*\*` 逐个=1）；commit stat 该文件 `2 +`（纯增无删） |
| CA-2 | PASS | `skills/plan-template-advisor/SKILL.md` 单文件 60 行（目录内无 references/scripts） |
| CA-3 | PASS | `SKILL.md:214` 路由行；`12 卫星` ×3（:9/:205/:224）；`11 卫星`（计数形态）=0 |
| CA-4 | PASS（语义缺陷见 F3） | `critical-rules.md:201` 索引行在位；`:178` 建制枚举已改（但语义错误） |
| CA-5 | PASS | `plan-template-kit/SKILL.md` 新增沉淀指针句（+1 行） |
| CA-6 | PASS（注释漏改见 F6） | `install-stub.sh:41` 数组尾追加 `plan-template-advisor` |
| CA-7 | PASS | `README.md:4,16?,31,41,65,72,83` + `ARCHITECTURE.md:4,13,35,37,47,69,78,80,105,118` 计数/表行同改 |
| CA-8 | **OPEN（预期）** | `.zcode/plan-templates/` 当前仍仅 `knowledge-brief.md`（worktree 与主仓实测），候选在 `plans/…/template-candidate/`；按计划待 G2/G3 过门后落位——Phase 2 不作为缺陷，但终验前必须完成，禁宣称已落位 |
| CA-9 | **OPEN（预期）** | 计划「🔁 模板感知」处置登记为终验期动作 |
| CA-10 | PASS | `selftest-verification-gate.sh:80-86` 12 化 + `selftest-registry.tsv` VG-06 描述同步；实跑 `Total: PASS=13 FAIL=0 exit 0`；替代四条件成立（真值 12 → 旧断言必破，已复现） |
| CA-11 | PASS（与 F3 冲突） | README/ARCH 均已 `4 新域 / 7 收编`（README:31、ARCH:37、ARCH:118）；但 `critical-rules.md:178` 反向归类 |

## B. 条款质量

34.8 四要素（①执行期触点 ②候选暂存 ③两级门 G1-G4 ④未过门处置）齐；34.9 六要素（沉淀位/`*-type.md` 限制/命名/manifest/生产者/与 34.7 分工）齐；文风与 34.1-34.7 一致（粗体小标题 + ①②③）；无硬编码行号锚；判例锚=task-id 稳定标识。
**FAIL 项 F4**：与 34.7 存在未声明的入库路径冲突（详见 F4）。

## C. advisor SKILL

frontmatter name/description 合规（含触发词 + 排除面）；SOP 六步齐全（`grep -c '^### [①-⑥]'`=6）；边界铁律 5 条；路由段在位（`:58`）。
**FAIL 项 F1**：`grep 'findings F'` = 1（应为 0）。

## D. 级联完整性

五落点命中（advisor 名 grep：SKILL.md=1 / critical-rules.md=2 / kit SKILL.md=1 / install-stub.sh=1 / README=4 / ARCH=6）；2 计数窗（VG-06 + registry）齐；`11 卫星` 计数形态=0；TL-17 `30 个` 未动（`selftest-template-lifecycle.sh:111`）；既有 30 个 variant 未改（`ls variant/*-type.md`=30）。
**FAIL 项**：F3（分类语义矛盾）、F6（install-stub 注释计数）、F7（三处「第 11 卫星」序数失效）。

## E. 候选模板 G1

`template-candidate/rule-clause-cascade-type.md`：机读头在位（:1）、五结构块齐（Goal/VC 表 3 条/Phase 3 段/执行范围限制/必要知识储备）、39 行 ≤100、类型名与 30 个 variant 无冲突（grep 空）。G1 四判据全过。
**PASS**（可用性缺陷另记 F5，属 G3 泛化性预警）。

## F. 越界审计

`git show --stat 8bc8e86` = 10 文件，与 CA-1..7/10/11 对应集完全一致（CA-8 待 Phase 3）；worktree `git status` 干净。**PASS**

---

## 发现清单（按严重度）

**[🟡IMPORTANT] C-1** `skills/plan-template-advisor/SKILL.md:60`
- 原文："机械发现与校验由 task-planner 脚本层负责（见 findings F2/F3/F9）。"
- 原因：任务本地 findings 编号外泄到已交付技能；计划 F12 声称「4 处 findings 指针已全换机制锚」，实际第 5 处（草案 :60 原样）未被清理——声称与产物不符
- 置信度: HIGH

**[🟡IMPORTANT] C-2** `skills/task-planner/README.md:72`；`skills/task-planner/docs/ARCHITECTURE.md:69,78,105`
- 原文："`../plan-template-advisor/references/`"（README:72 / ARCH:78,105）/ "`../../plan-template-advisor/references/`"（ARCH:69）
- 原因：advisor 按计划为单文件技能，`references/` 目录不存在（实测 MISSING），四处路由路径指向空目录；SKILL.md:214 与 critical-rules.md:201 用 `…/SKILL.md` 才是正确形态
- 置信度: HIGH

**[🟡IMPORTANT] C-3** `skills/task-planner/references/critical-rules.md:178`
- 原文："其余规则归 8 个既有卫星（plan-research-router/plan-template-kit/plan-template-advisor/…）"
- 原因：与 CA-11 修正（advisor=新域、收编=7）直接矛盾；且 ARCHITECTURE:78 记 advisor 规则数=0、critical-rules.md:201 称「规则随 SKILL 内联」，advisor 并不承载规则，把它列入「规则归 8 个既有卫星」语义不成立；同时改写了 Rule 82 建制段关于 task-v171 的历史陈述（当时 advisor 尚不存在）
- 置信度: HIGH

**[🟡IMPORTANT] C-4** `skills/plan-template-kit/references/critical-rules-template.md:21-23`
- 原文（34.7）："【全自动生成合约】终验 outcome=COMPLETE 且命中 34.3 任一条件 → 主进程**直接派执行体生成** …→ 生成侧强制执行 34.5 双闸门"；34.8③ 同文档："官方入库级 G1-G4"
- 原因：34.7 把入库门禁限定为 34.5 双闸门且「全自动不询问」，34.8 要求官方入库过 G1-G4 且 G3 为独立审查派发——两条入库路径并存而 34.8 未声明其与 34.7 的优先级/衔接（是先过 G1/G2 再生成？还是生成后补审？），执行期可合法地按 34.7 绕过 G3
- 置信度: MEDIUM-HIGH

**[🟡IMPORTANT] C-5** `plans/task-tpl-sediment-20261115/template-candidate/rule-clause-cascade-type.md:14,38,24,39`
- 原文："`grep -nE "…" skills/task-planner/SKILL.md README.md docs/ARCHITECTURE.md`"（:14）；"`README.md`、`docs/ARCHITECTURE.md`（卫星表与计数串）"（:38）；"避免悬空（判例 F12）"（:24）
- 原因：仓根无 `README.md`/`docs/`（实测不存在，实际位于 `skills/task-planner/` 下）——复犯本任务 CA-7 同类路径笔误，VC-2 命令会直接报错；同时模板内嵌 `F11/F12` 任务本地 findings 编号，正是自身警告的「悬空指针」反模式，G3 泛化性闸门会在意
- 置信度: HIGH

**[🟢WARNING] C-6** `skills/task-planner/lib/install-stub.sh:39-41`
- 原文："本行只登记 install-stub 显式 rsync 的 7 个" / `SATELLITE_SKILLS=(… plan-template-advisor)`（数组实为 8 个元素）
- 原因：CA-6 只追加元素未同步同行计数注释，与 CA-10 修正的 VG-06 属同类「计数窗漏改」
- 置信度: HIGH

**[🟢WARNING] C-7** `skills/verification-gate/SKILL.md:3,10`；`skills/verification-gate/references/critical-rules-verification.md:3`
- 原文："task-planner 第 11 卫星（Rule 82 分层…）"
- 原因：卫星总数 11→12 且 advisor 作为第 4 新域插入后，verification-gate 序数应为第 12；三处非注释正文仍称第 11（README:4/ARCH:4,124 属历史注释，可豁免）
- 置信度: MEDIUM

**[💬NIT] C-8** 四张路由表 advisor 行位次不一致：README:72、ARCH:78,105 置于 media-planner 之后；`SKILL.md:214`、`critical-rules.md:201` 置于 plan-template-kit 之后
- 原文："| plan-template-advisor | 项目模板适配与沉淀生产 | …"
- 原因：同族表格同一行的相对位置不同，检索/对照易错行
- 置信度: HIGH

**[💬NIT] C-9** `skills/task-planner/docs/ARCHITECTURE.md:78`
- 原文："| plan-template-advisor | 项目模板适配与沉淀生产 | 项目模板适配与沉淀生产（Rule 34.8/34.9 消费面） | 0 |"
- 原因：§2.1 其他行的「定位」「域边界」为不同内容，此行两列文字完全重复（复制粘贴），域边界未真正填写
- 置信度: HIGH

**观察（不计 FAIL）**：README:83 与 ARCHITECTURE:116 仍写「Rules 1-97」，而 SKILL.md:9/224 为「Rules 1-107」——既有漂移（本次仅改 11→12），非本 commit 引入，建议另案处理。

---

## 负结果报告（预期问题但未发现 / 已排除）

- `11 卫星` 计数形态在 `skills/` 与根 README 全域=0（仅 archive/knowledge 历史档命中，符合「历史注释除外」）
- TL-17 `30 个` 断言未动；variant 目录仍 30 个（本任务不加官方 variant，符合不变量②）
- 34.1-34.7 逐条锚=1，无删改（commit stat `2 +` 纯增）
- 除 VG-06 外无其他 selftest 硬断言卫星数：全 `scripts/*.sh` 扫描仅 `selftest-verification-gate.sh` 含 `12 卫星`；其余「10 卫星/核心 12 条」均为历史溯源注释，不构成断言
- `check-skill-modify.sh:30` 白名单未列 advisor —— 经读码排除为缺陷：`${name%%/*}` 未命中后落入 `rest=SKILL.md` 通用分支仍判为受控技能文件
- 类型名查重：`rule-clause-cascade-type` 与 30 个 variant 无同名/近名冲突
- 定向实跑（只读、零写入）：selftest-verification-gate PASS=13/0、dual-qc 14/0、skill-split 40/0、template-lifecycle 24/0、subagent-activation 20/0

## 修复建议（按优先级）

1. C-1：删 `（见 findings F2/F3/F9）` 或换为「见 `init-session.sh` 原生发现 / `render_template` fail-closed 契约」
2. C-2：四处路径改 `../plan-template-advisor/SKILL.md`（README 用 `../`，ARCH §2.1/§3 用 `../../`）
3. C-3：`:178` 回退为「7 个既有卫星」并保持 advisor 不列入；若需体现新增，另加一句「placeholder 新域卫星 plan-template-advisor 不承载规则，见路由索引」
4. C-4：34.8 末尾补一句衔接：34.7 全自动生成即 34.8 官方入库路径，生成前须过 G1/G2，G3 在 COMPLETE 前完成
5. C-5：候选模板把仓根路径改 `skills/task-planner/README.md`、`skills/task-planner/docs/ARCHITECTURE.md`；F11/F12 换机制名锚（如「init/render 签名误用」「落位指针悬空」）
6. C-6/C-7/C-8/C-9：计数注释 7→8；序数 11→12（三处）；统一 advisor 行位次（建议统一至 plan-template-kit 之后）；§2.1 域边界列填写实质内容

## 验证摘要

总发现 9（IMPORTANT 5 / WARNING 2 / NIT 2）+ 观察 1 / 全部以 grep·Read 复现原文 / 通过率 9/9 = 100%
