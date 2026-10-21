---
id: misc-skill-institutionalization-precedents
title: "技能制度化演进判例"
tags: [制度化, 规则演进, 判例, 零级联, 机器守护]
sources:
  - plans/archive/task-v097-tool-selection/knowledge-brief.md
  - plans/archive/task-v098-auto-resolution/knowledge-brief.md
  - plans/archive/task-v119/knowledge-brief.md
  - plans/archive/task-v127/knowledge-brief.md
  - plans/archive/task-v127/findings.md
  - plans/archive/task-v154-decision-arbiter/findings.md
  - plans/archive/task-v162-change-absorption-safety/findings.md
  - plans/archive/task-v169-user-session-log-write-once/findings.md
  - plans/archive/task-v195-spec-recall/findings.md
updated: 2026-10-22
---

# 技能制度化演进判例

> 回答两问：**什么时候某个做法值得升格为制度（Rule/机制/agent）**，**怎样落地才能零级联、不炸回归**。

## 结论（可直接复用）

1. **制度化触发判据（三类信号命中其一即可立项）**：①同类坑反复踩（出口遍地却无门槛定义）；②同一动作被执行体每次现场重新发明（结果不可复现）；③某类判断没有出口，只能临场硬扛或上抛用户。实证：全仓 66 处升级出口措辞、**0 处**升级门槛定义（task-v098 knowledge-brief.md:31）；额度查询从未落盘成脚本、每次现场"耗时累计推算"产出完全错误的额度（task-v138 knowledge-brief.md:24）；五类判断类问题缺强判断出口（task-v154 findings.md:24-25）。
2. **落地四件套范式（rule-enhancement）**：条款纯增量追加到 `references/critical-rules.md` 文末 → `SKILL.md` 四锚联动（frontmatter 全集行 + 摘要 bullet + Critical Rules 括注 + References 表行）→ 新建 `selftest-<domain>.sh` 静态守护并在 `selftest-registry.tsv` 登记 → 全量回归 FAIL=0 → `smart-merge-back.sh --deploy` 三宿主对账 IDENTICAL（DRIFT 即 exit 6 fail-closed）。锚：task-v122/findings.md:135；task-v129/findings.md:100；task-v138/knowledge-brief.md:52-53。
3. **判定面 / 机器面二分（零新 config 键的制度化通道）**：判定面=LLM 行为（靠条款约束，无需门控键）；机器面=静态 selftest 断言锚；`config.json` `properties` 键数保持不变、禁借机加键。锚：task-v097 knowledge-brief.md:17；task-v098 knowledge-brief.md:41。
4. **升级出口必须阈值化**：消解优先是默认动作、升级是例外。仅四类可上抛用户——G1 破坏性不可逆 / G2 范围越界 / G3 对外不可撤回发布 / G4 语义级目标分叉；命名/格式/注释/一致性顺带修/明显正确小修=直接做+登记；升级前须过消解清单并附"已尝试清单"。锚：task-v098 knowledge-brief.md:13-15,64（禁软措辞，方向不可倒置）。
5. **裁决独立化范式**：判断类裁决出口=独立强模型 agent，四态 APPROVE / REJECT-REWORK / ESCALATE-USER / INSUFFICIENT-EVIDENCE；**修复权留主代理，裁决只裁决不改码**；ESCALATE 锚定上述四门槛；单次独立、禁驻留循环（强模型经济性）。锚：task-v154 findings.md:39-40,48。
6. **新 agent / 新机制必须双写「触发门槛 + 禁用清单」**：只写门槛会被泛化滥用，缺禁用清单则门槛形同虚设。锚：task-v119 knowledge-brief.md:92-100（三触发门槛+三禁用清单+五段规划产出契约）、:65。
7. **需求分级双轴（存在性 P / 程度 E × 硬约束 H / 评分项 S）**：复合需求拆成逐条机读条目（类型|层级|权重|判定刻度）；**程度条目禁并入存在性条目**；未标层级默认 H；程度项**双向判**（过显眼=FAIL，过小到不可见=FAIL）；加权判定沿用仓内既有评分卡形态（全 H 过 + S 项加权 ≥ 阈值）。锚：task-v127 knowledge-brief.md:15-17；task-v127 findings.md:11-13,40。
8. **变更吸收三判**：D/A/B/C 四类通道（开新计划/照常执行/先重规划/停止写入更新被推翻部分）+ 追加 vs 替代的语义二分 + 变更标注表 + 定稿可行性判别门。既有"默认纯增量"只约束技能文件修改、未覆盖用户指令吸收场景，必须补通用吸收语义门。锚：task-v162 findings.md:27-28,50,79,88-93。
9. **逐字记录必须外置为 append-only 专档**：新建第 7 文件 `user-session-log.md`（只写不改 + 逐字抄录 + 恢复协议），计划内只留指针区块（因 attest 哈希锁禁追加 task_plan.md）；门控四档 enforce/warn/off/L0 skip，缺失即 ERROR 曝光不静默放行。锚：task-v169 findings.md:24-25,32,65-66。
10. **规范再召回机制**：把规范正文做成一张召回卡（≤120 行、≥20 条规则锚、A-F 分节），在"中断/压缩恢复"决策分支接为独立步骤并给该路径补挂。锚：task-v195 findings.md:48-51,67。
11. **零级联三招**：①**行内替换优先于净增行**（净增 0 行最省，行数钉零级联）；②计数锚用**宽容正则族**覆盖未来纪元（`1-4[5-9]` / `1-[7-8][0-9]` / `40-[4-8][0-9]` / `1-(69|71|7[4-9]|80)`），不写精确钉值；③行数钉用**链式演进注释**（440→442→444→447→449）随实测值同步并注 task 代号。锚：task-v123 knowledge-brief.md:30,60；task-v169 findings.md:77,92,106；task-v129 findings.md:47。
12. **假绿识别方法论**：新增规则后跑出的 FAIL，必须**先在未改动部署位/基线副本复跑同一脚本**再归因，区分"存量环境性失败"与"本次引入"，禁止按关键词直接归因。锚：task-v169 findings.md:57；task-v129 findings.md:170。

## 证据锚

- 触发判据量化：task-v098-auto-resolution/knowledge-brief.md:31；task-v138/knowledge-brief.md:24；task-v154-decision-arbiter/findings.md:24-25
- 四件套范式与零新键二分：task-v122/findings.md:135；task-v129/findings.md:100；task-v138/knowledge-brief.md:52-53；task-v097-tool-selection/knowledge-brief.md:17；task-v098-auto-resolution/knowledge-brief.md:41
- 升级四门槛 / 裁决四态 / 触发+禁用双写：task-v098-auto-resolution/knowledge-brief.md:13-15；task-v154-decision-arbiter/findings.md:39-40；task-v119/knowledge-brief.md:92-100
- 需求分级 / 吸收三判 / 逐字专档 / 规范再召回：task-v127/knowledge-brief.md:15-17；task-v127/findings.md:11-13；task-v162-change-absorption-safety/findings.md:27-28,50,93；task-v169-user-session-log-write-once/findings.md:24-25,65-66；task-v195-spec-recall/findings.md:48-51,67
- 零级联三招与假绿归因：task-v123/knowledge-brief.md:30,60；task-v169-user-session-log-write-once/findings.md:77,92,106；task-v129/findings.md:47,57,170

## 易错点

1. **只改 SKILL.md 两处计数就以为级联完** —— 4 索引文档命中总和有下限要求；解法：扩围修改集，或用"Rules 1-39（含 Rule 40…）"式宽容措辞保持计数（task-v097 knowledge-brief.md:29,70）。
2. **漏改行数钉（不止一处）** —— 行数上限断言散落 4-5 个 selftest，漏改任一处=全量回归 FAIL；须逐处实测 `wc -l` 后同步并注 task 代号（task-v097 knowledge-brief.md:28,71；task-v098 knowledge-brief.md:63）。
3. **新文本产生被负断言禁止的字面**（如被禁的纪元串）→ 回归 FAIL；改前先 grep 复扫既有锚（task-v098 knowledge-brief.md:62；task-v122 findings.md:152）。
4. **用改断言语义掩盖"锚过窄"** —— 只能按"锚过窄→宽容化 / 内容越界→回炉"二分处置（task-v127 knowledge-brief.md:61）。
5. **只写条款不给执行体挂点** —— 条款死文判例，无消费点等于没落地（task-v138 knowledge-brief.md:84）。
6. **规则编号抢占/撞号** —— 新号必须对照编号账本（reserved/landed）与在途任务 Goal（task-v154 knowledge-brief.md:47；task-v129 findings.md:44；task-v138 knowledge-brief.md:46）。
7. **计数级联只改"声明行"漏改同文件其他计数与历史注释** —— critic 实测 4 处漏改造成同文件自相矛盾，修复须回补 CA 登记（task-v195 findings.md:88-90）。
8. **声称"行为级已验证"** —— 会话内无法派发新 agent 时只能结构验证，未验证部分必须显式登记（task-v119 knowledge-brief.md:64）。
9. **派发 prompt 复述任务书编号列表** —— 会被派发守卫判定打包拦截（task-v127 findings.md:45）。

## 适用场景

- 要把反复出错/反复重做的做法升格为 Rule、机制、守卫脚本或专用 agent 时；
- 修已有规则但担心"改了计数/行数/锚"引发全量回归时；
- 需要逐条给出可复核证据锚（完成声称门）时；
- 出现"流程失控/缺失而非能力问题"的治理缺口诊断时（需求原文锚定 → 验证机制先行 → 完成声称对照强制链）。
