# Findings — task-v181（Rule 89 前后逻辑一致性与已确立事实禁反言）

## 调研事实面（本地一手取证）
- 判例源：/goal 目标指令逐字（user-session-log.md #1）——图片链接下载成功后又声称「不确定链接是否可用」= 已确立事实无新证据反言。
- 规则载体定位：`skills/task-discipline/references/critical-rules-discipline.md`（执行纪律域，Rule 85/86 同域同文件，L0-T 先例 4bbc1f6/2bdf2fe）。
- 规则编号：`rule-reserve.sh next`=89（88 已被并行 task-v180-scope-contract 占用，87 被 task-v179 占用）；`reserve 89 task-v181` 成功。
- 索引现状：master `skills/task-planner/SKILL.md` 全集索引 `Rules 1-86`（第 9/175/217 行）+「其余 72 条」（第 9/175 行）；「其余 N 条」实测**非** selftest 断言（纯 doc 值，可安全级联）。
- selftest 纪元锚：主锚为宽松正则 `1-[7-8][0-9]`（1-89 仍命中），**无需**跨十年纪元收口（89 未跨 1-[7-8] 界）。
- 域归属：89=执行纪律域（task-discipline 卫星），不进核心 critical-rules.md（Rule 82 分层）。

## 设计取舍
- 新增 top-level Rule 89（非并入 54/65 子条）：思路混乱=独立执行纪律缺陷，对齐 85/86「新行为纪律=新编号」先例，可发现性=「彻底」诉求。
- L0-T 纯文本（89.6 机制子条）：零新增守护脚本/config 键；守护机器化 opt-in（§四.6 + 86.7 范式）。
- 索引级联仅动 master SKILL.md：最小竞争面（v179/v180 并行占用 master）；critical-rules.md 卫星清单 + task-discipline/SKILL.md 清单=簿记级 doc-lag，无 selftest 影响，留待一致化 pass。
