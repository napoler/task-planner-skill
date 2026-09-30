# Knowledge Brief — task-v103-ask-default-timeout
## §1 速览
- 新增 Rule 44（用户选择点默认项+自动超时 5 分钟默认+超时按推荐执行+裁决记录）+SKILL C33+模板「自动超时默认项」行+RT selftest 9 断言+registry;合并部署 push。
## §2 已验证事实
| 事实 | 证据 |
|------|------|
| master=7106233（v102 簿记 HEAD） | rev-parse 2026-10-01 |
| SKILL=440 行,T-主 行钉 -le 440（v102 级联值） | 实测 |
| CRIT=437 行,43.4 在 :437（44 节追加位=EOF） | 实测 |
| C32 行 :197;Rule 43 摘要行 :278 区（C33/Rule 44 摘要插入位其后） | 实测 |
| registry=41 行;SR-12 动态口径=脚本数+表头（RT 脚本+registry 行同批即自动咬合 42） | v102 根治先例 |
| config properties=40 键（R-12 锚,RT 零新键同口径守护） | R-12 现文 |
| 基线 40 脚本 639/0（P1 复测为准） | v102 交付 |
## §3 文件锚点
| 路径 | 锚 |
|------|-----|
| references/critical-rules.md | EOF（43.4 行后,44 节插入） |
| SKILL.md | :197 C32 行后（C33）;:278 Rule 43 摘要行后（Rule 44 摘要行） |
| templates/task_plan.md | 配置表（对齐审查行后+1 行） |
| templates/variant/mini-lite-type.md | 42.6 豁免行后+1 |
| scripts/selftest-registry.tsv | EOF +1 行 |
## §4 易错点
1. 用户原话锚必须字面入条款与 RT: 「默认选项」「自动超时」「推荐的方案」「5 分钟」
2. 44.2 引用 41.3 不重述（trivial 直接做纪律已在 41.3）
3. T-主 级联值以 S2 后 wc 实测定数禁手估（v102 六连实证教训）
4. RT 断言锚先 Read S1/S2 产出实测再写;registry 与 RT 脚本同批（SR-12 咬合）
5. R-09 越界断言 1-40 不命中 44（数字面 40 非 44,验证 RT 越界负断言写法用 1-4[0-9] 或 1-40 实测）
6. push 判据=ls-remote（v099 教训）
## §5 材料包
| S-unit | 材料 |
|--------|------|
| P2-S1 | 任务书 44.1-44.4 定义+用户原话锚 |
| P2-S2 | C32 行形态+配置表形态+mini-lite 豁免形态+T-主 wc 实测 |
| P2-S3 | RT 范式（对照 R 脚本）+S1/S2 产出实测锚+registry 行形态 |
