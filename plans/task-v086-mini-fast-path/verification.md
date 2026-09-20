# Verification Contract & Phase Gates

## Goal (1 sentence)
落地 Rule 38 难度分级与轻量档（mini 判定+mini-lite 模板+5 锚点门控豁免+S6 项目多模板极简支持），全量回归 0 FAIL 后合并 master、部署 3 实体位并 push GitHub。

---

## Verification Contract (逐条复验)

- [x] VC-1: Rule 38 条款完整（38.1-38.5 五子条）
  Evidence: `skills/task-planner/references/critical-rules.md` L329-341（38.1 判定/38.2 矩阵/38.3 契约/38.4 豁免锚表 5 点/38.5 机制），selftest-plan-tier PT-01~06 条款锚全 PASS
- [x] VC-2: config 三档键 plan_tier_enforce 落地
  Evidence: `jq .properties.plan_tier_enforce skills/task-planner/config.json` = enum [enforce,warn,off] default warn；PT-07 PASS
- [x] VC-3: 模板分流生效（mini-lite 落盘 + 14 标准标记 + init 三场景）
  Evidence: worktree 干跑 PT-15~17（缺省 general / TASK_PLAN_TIER=mini 复制 mini-lite / mini+variant 定制优先提示）全 PASS；`grep -l "plan_tier: standard" templates/task_plan.md templates/variant/*.md` = 14
- [x] VC-4: 门控豁免生效（mini 降档/非 mini 零影响）
  Evidence: 三脚本三方对照（S3 checkpoint [S3-6]）：mini=FMEA MINI-TIER SKIP+VC-GATE PASSED(需≥2)+委派 floor 0.0；standard=master 对照输出逐字节一致（SHA f07c7a60 同）；MISMATCH 三档 warn/enforce/off 实测
- [x] VC-5: selftest 守护 + 全量回归 0 FAIL
  Evidence: selftest-plan-tier.sh 28 断言（PT-01~28，含 S7 新增 PT-28 mini enforce 双通链）；主进程复跑 worktree 430/0（25 脚本逐 Total 求和）、合并后 master 再复跑 430/0
- [x] VC-6: SKILL 联动 + 3 实体位部署 diff=0
  Evidence: SKILL.md 551 行（1-38 索引/C26/摘要行）；diff -r 三位 = ~/.zcode、~/.claude、~/.config/opencode 全 IDENTICAL（主进程亲验）

## S6 扩围验收（用户 09-21 指令：一个项目多模板、每次只加载 1 个）
- [x] init-session `--list` 列全部可用模板（内置 14 + 项目目录）不建文件 exit 0（PT-23）
- [x] 项目 default 指针文件 > env TASK_TEMPLATE_DEFAULT > 缺省 general；每次任务只复制 1 个模板（PT-24/25）
- [x] 自造模板无 template_type 标识行时 init 头部插入 frontmatter（PT-27）；check-template-type 第三形态提取使插入产物可通过 gate（S7-1，PT-28）
- [x] 全缺省路径与 master 行为逐字节一致（PT-26）

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → PARTIAL；证据不实 → BLOCKED

---

## 委派统计复验（Rule 25.4）

机器统计输出（`bash skills/task-planner/scripts/check-delegation.sh stats plans/task-v086-mini-fast-path`）：

```json
{"phases_total":4,"phases_delegated":2,"main_direct_count":2,"delegation_rate":0.500,"main_direct":[P1 白名单①②,P4 白名单①②],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase（P1/P4）均命中 Rule 25.3 白名单①git 编排+②计划系统文件维护
- [x] 委派率 0.5 < 0.7 但全部命中白名单 → **WHITELIST-EXEMPT**（先例 v082-v085 同构）；verdict=ok 无 violations

## 质量门控统计（Rule 26）
- Q1-Q6: 触发 0 项，豁免 0 项，未处置 0 项（CR 首轮 CHANGES_REQUESTED 项全部经 S7 修复后二轮 APPROVED，非降质放行）
- Evidence 抽查 3 条：VC-3（PT-15~17 干跑输出）、VC-4（[S3-6] 三方对照原文）、VC-6（diff -r 三位输出）——均可复现
- 豁免登记: 无

## Goal Gate (终验)
- VC-1~VC-6 + S6 扩围 4 项 全部 PASS → **outcome: COMPLETE**（deferred 登记 1 项=项目自造模板 34.1 白名单扩展，不影响本任务交付完整性）

## 已知边界登记（deferred-issues.log）
- D1: 项目自造模板（my-custom 类）不入 34.1 白名单，enforce 档拒锁（既有设计边界，warn 默认档可用）→ 独立任务
- D2: task_plan P4 描述「行首直书」措辞 vs 实际落地「gate 补第三形态」——活文档已同步更正
