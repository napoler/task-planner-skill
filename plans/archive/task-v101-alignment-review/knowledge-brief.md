# Knowledge Brief — task-v101-alignment-review
## §1 速览
- 第 11 个池技能 alignment-review（对齐/同步一致性审查）+级联 3 处（selftest RL-01/DIRS、CRIT 42.2 枚举、general-review 枚举）+全量回归+部署 push。
## §2 已验证事实
| 事实 | 证据 |
|------|------|
| master=4194f34 | rev-parse 实测 |
| RL-01 断言 =10 在 selftest :5/:33-35（错误消息文本含「应 10」） | grep 实测 |
| DIRS 清单在 :27（10 名空格分隔） | 实测 |
| CRIT 42.2 枚举「10 类通用质量审核技能：general/…/release」在 :420 | 实测 |
| general-review 触发段枚举在 :8（alignment 零命中） | 实测 |
| 基线 40 脚本 638/0（P1 复测为准） | v100 交付 |
| RL-04..07 循环基于 $DIRS（DIRS 加名即自动覆盖新技能） | 脚本实测 |
## §3 文件锚点
| 路径 | 锚 |
|------|-----|
| review-library/general-review/SKILL.md | :8 枚举行 |
| references/critical-rules.md | :420 42.2 行 |
| scripts/selftest-review-library.sh | :5/:27/:33-35 |
| review-library/security-review/SKILL.md | 领域化写法参照 |
## §4 易错点
1. RL-01 三处同步（注释/断言/错误消息）漏一即 FAIL
2. CRIT 42.2 枚举是短名形态（general/code-quality/…/release）,新名对齐写 alignment
3. general-review :8 枚举是缩写形态（code/test/security/image/…）,写 alignment
4. 全池改后 `grep -c 'alignment' 各文件` ≥1 断言;「10 类」残留零容忍
5. 新技能成员注释「成员 11/11」;禁「1-4x」越界字面
## §5 材料包
| S-unit | 材料 |
|--------|------|
| P2-S1 | 范式 general-review+领域化参照 security-review+本计划核心问题段（清单来源） |
| P2-S2 | §2/§4+selftest :5-35+CRIT :420+gen :8 |
