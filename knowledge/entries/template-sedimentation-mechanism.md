---
id: template-sedimentation-mechanism
title: "任务路径沉淀机制：Rule 34.8/34.9 两级审查门与项目级模板位（task-tpl-sediment-20261115）"
tags: [模板沉淀, rule-34, plan-template-advisor, 审查门, 项目级模板]
sources: [skills/plan-template-kit/references/critical-rules-template.md, skills/plan-template-advisor/SKILL.md, plans/archive/task-tpl-sediment-20261115/findings.md]
updated: 2026-11-15
---

# 任务路径沉淀机制（Rule 34.8/34.9）— 实施与判例要点

## 机制速览
- **34.8 执行期沉淀与审查门**：Phase 收尾/规范召回/收尾回读时点识别可复用路径→findings/notepad 记 `[template-candidate]` 行（不停等，Rule 95 兼容）→候选落计划目录 `template-candidate/`→过两级门才入库：官方级 G1-G4（结构 lint/render 冒烟/独立审查派发/官方级联四点+计数+selftest），项目级 G1-G3。未过门留暂存登记理由，禁静默丢弃。**与 34.7 分工**：34.7 全自动合约生成的候选同样须过 G1-G4（34.5 双闸门=G3 输入，非独立通道）。
- **34.9 项目级沉淀位**：`<项目>/.zcode/plan-templates/`（或 .claude 位）——init-session.sh 原生发现并并入 `*-type.md` 白名单（:65-97,667-679），零接线；只写 `*-type.md`，禁覆盖核心 7 计划文件模板；须维护 manifest（该目录 README.md：模板名/类型标识/来源任务/审查日期/门记录）。
- **生产者**：`plan-template-advisor` 卫星技能（第 12 颗，新域组；分析→预测→缺口映射→产出→审查→登记 六步 SOP；单次 ≤3 个防刷量）。

## 实施判例（task-tpl-sediment-20261115，commit 8bc8e86→7ea0a98）
- 首个 dogfood 产出：`rule-clause-cascade-type.md`（本仓规则/条款级联修订适配）已落 `.zcode/plan-templates/` 并经 init 实跑选中（project-level 路由）。
- **类型标识派生口径（关键坑）**：init 从文件名去 `-type.md` 后缀得类型名——机读头 `template_type` 须填该标识（`foo-type.md`→`foo`），双后缀标识→unknown→generic 回退（首跑实证，判例=smoke-g2.md）。教训已回写 advisor SOP。
- **计数级联三族语义**（改卫星数必查）：rsync 清单=SATELLITE_SKILLS 数组数（现 8）；收编卫星数=7（CA-11 后定案）；卫星总数=12（`N 卫星` 计数串+TL-17 类 selftest 硬断言同源锚必同改，VG-06 判例）。
- **双源并发合并**：同文件不同区域（他任务改 :107/:229，本任务改 :178/:201/:213）git 可自动并集；他任务 staged 归档移动阻塞 merge→**stash 窗口法**（push→merge→pop，判例 task-docmod-recheck 复用验证）。

## 易错点
1. 既有 34.1-34.7/30 个官方 variant 零改动纪律：只追加子条，禁替代旧文本（增量默认）。
2. advisor 产出禁覆盖核心计划文件模板；项目级模板必须 `*-type.md` 后缀才进白名单。
3. 冒烟跑 init 会写会话 side 指针→用隔离工作区（tmp/ 下自带 .zcode/plan-templates 的 SMOKE 目录，walk-up 先命中隔离模板）+事毕核验主指针。
4. 部署面两层：--deploy 仅覆盖 task-planner 目录（3 槽位）；卫星目录须手工 cp 四宿主（zcode/claude/opencode/cursor）+逐对 diff=0 对账（20 对口径）。
5. `scripts/run-selftests.sh` 不存在——回归用 `for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f"; done` 聚合口径；预存 FAIL（T11/T11b B1）另案，不阻新任务。

## 权威锚
- 条款全文：skills/plan-template-kit/references/critical-rules-template.md（34.8/34.9）
- 技能 SOP：skills/plan-template-advisor/SKILL.md
- manifest 范例：.zcode/plan-templates/README.md
- 复检判例：plans/archive/task-tpl-sediment-20261115/（review-critic-r1/r2/r3、smoke-g2/g2-r2、regression-s3）