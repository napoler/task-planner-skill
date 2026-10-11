# Verification Contract & Phase Gates

## Goal (1 sentence)

按 template_type 建立机制画像映射层：非代码任务（writing/research/publish）不再被引向 Code Review Gate / code-assistant 等代码组机制，通用守卫全类型不变。

---

## Verification Contract（逐条复验，2026-09-20 终验）

- [x] VC-1: critical-rules.md 含 Rule 37（### 37 头 + 37.1-37.5 + FMEA R1 兜底段），template-mapping.md 含 §九 矩阵（14 数据行）
  Evidence: `grep -n "^### 37 " critical-rules.md` 命中 L317；`grep -n "^## 九、" template-mapping.md` 命中 L204；`git diff 3e07abc..HEAD` critical-rules +12 删除 0
- [x] VC-2: writing/research/publish 三行含「不适用：Code Review Gate、code-assistant/debugger/code-reviewer 路由」+ §一决策树尾指针注记
  Evidence: `grep -c "不适用"` template-mapping.md 命中 ≥3（L227-229 显式枚举+表体）；§一注记 L28 在位
- [x] VC-3: SKILL.md 三处增量（路由注记 L356/C25 L201/Rule 37 行 L310）+ 通用模板两处画像注记（已移入注释块防拆表）+ guide 指针行
  Evidence: `grep -c "Rule 37" SKILL.md`=3；`grep -n "机制画像" templates/task_plan.md` 命中注释块行与 L182；guide L50 指针
- [x] VC-4: selftest-mechanism-profile.sh 行为级双档断言通过（fake plan writing+code_review:required：默认档 exit 0+⚠ / TASK_PLANNER_MECHANISM_PROFILE_ENFORCE=enforce exit 1 / off 无输出）
  Evidence: `bash selftest-mechanism-profile.sh` → Total: 19 PASS=19 FAIL=0（MP-17/18/19 行为级）
- [x] VC-5: 无回归——24 个 selftest 全量 402 PASS / 0 FAIL（主进程逐 Total 行求和，CR 修复两轮后终态）；config.json json 合法且新键 default=warn
  Evidence: 主进程求和记录 `PASS=402 FAIL=0`（e88486c 后 c269624 复跑）；`python3 -m json.tool config.json` 通过；`jq .properties.mechanism_profile_enforce.default`=warn

**附加复验**：Code Review Gate APPROVED（Code Reviewer 子代理，findings 5 条全部处置：索引 1-36→1-37 级联 3+1 处 / CHANGELOG 条目 / 模板注记移注释块 / BP-08 注释括号 / 宽容锚 1-3[56]→1-3[5-7] 与 1-3[1-6]→1-3[1-7] 扩围）；CR 引出的 2 处 selftest 断言 FAIL（CD-11/CD-19/EL-11）已修并复跑 402/0。遗留 1 条低优先建议（注释形态 template_type 提取盲区，与既有 check-template-type.sh 同盲区，属沿袭约定不修）登记 notepad。

---

## Phase Gates（各 Phase 终态）

| Phase | Goal | Status | 提交 |
|-------|------|--------|------|
| 1 规则与主文件层 | Rule 37 + SKILL 三处增量 | complete | 1656b98 |
| 2 模板与映射层 | §九矩阵 + 模板微调 + guide 指针 | complete | db7e724 |
| 3 脚本与守卫层 | config 键 + check-complete 抽查 + selftest | complete | e8ecb80 |
| 4 验证与交付层 | 断言基线对齐 + CR Gate + 级联收尾 + 合并部署 | complete | e88486c/11857df/c269624 |

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| Rule 25/26/34/36 既有范式 | Rule 37 五子条结构与 36.x 对齐 | 符合 |
| template-mapping.md 既有章节样式 | §九 表格样式仿 §六互斥表 | 符合 |
| config content_quality_enforce 先例 | 新键 enum/默认/description 仿写 | 符合 |
| TL-17「13 个」计数锚 | S5 实测锚保持命中 | 符合 |

## 委派统计复验（Rule 25.4）
```
$ bash check-delegation.sh stats plans/task-v085-task-type-mechanism-profile
{"phases_total":4,"phases_delegated":3,"main_direct_count":1,"delegation_rate":0.75,"verdict":"ok"}
```
- [x] Phase 4 主进程直做 S11=合并部署/簿记（白名单①③⑥：git 编排+机械验证+终验簿记），S9/S10 已派发（code-runner 双次 Provider 拒绝后按 22.3④ 主进程接管机械验证命令，白名单③）
- [x] 委派率 0.75 ≥ floor 0.7，verdict=ok，无 violation

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成：触发 3 项（S5 指针句重复=Q2 类被主进程复核当场打回修复；S8 后全量 selftest 4 FAIL=Q5 回归，根因=行数基线 548→549 未同步，已修）；豁免 0 项；未处置 0 项
- [x] Evidence 抽查 3 条：①check-complete 三档 fake plan 实测（checkpoint 8-code-assistant.md 有全输出）②§九 14 行逐行主进程 Read ③config 新键 jq 取值——路径可 Read、结论可复现
- [x] 无未处置违规，outcome 不降级

## Goal Gate 终验

```
## Goal Verification — 机制画像映射层按 template_type 裁剪机制适用性
对照 VC 逐条复验：
- [x] VC-1: Rule 37 + §九 矩阵在位 → PASS
- [x] VC-2: 内容组三行「不适用」措辞在位 → PASS
- [x] VC-3: SKILL/模板/guide 增量在位 → PASS
- [x] VC-4: 行为级双档断言 PASS → PASS
- [x] VC-5: 402/0 + json 合法 → PASS

 outcome: COMPLETE
```

## [reflect] 反思+验证（Rule 33）
- [reflect] 反思：本任务 S-unit 派发 4 次被 check-dispatch 误拦、code-runner 2 次 Provider 拒绝、CR 引 5 处级联修正——根因分别=同名文件路径触发计划自声明误锚 / mini 档 provider 侧故障 / 「1-36」类索引在 SKILL+README+selftest 多锚位分散
- [reflect] 验证：402/0 全量 + CR APPROVED + 委派率 0.75 机器复验，三条独立证据源一致
