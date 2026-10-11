# Verification Contract & Phase Gates — task-v088 动态工作流编排 Rule 39

## Goal
task-planner 接入 /workflow（dynamic-workflows）路由与映射合约（Rule 39）落地：规则+守卫+索引级联+部署，全量 453/0。

## Verification Contract（终验逐条复验）

- [x] V-1: critical-rules.md 含 `### 39 动态工作流编排` 六子条锚点
  Evidence: `grep -n "^### 39\|^39\.[0-9]" skills/task-planner/references/critical-rules.md` → L343/L347-349/L359-361 全命中（P2 亲验，+20 行 341→361，diff 逐字节 IDENTICAL）
- [x] V-2: SKILL.md 净增 3 行、558 行（Rule 39 摘要行+C27+协同路由行+Rules 1-39 索引）
  Evidence: `wc -l skills/task-planner/SKILL.md` = 558；L9/L290/L343 均 1-39
- [x] V-3: Rules 1-38→1-39 索引级联全同步
  Evidence: `grep -rc "Rules 1-39"` SKILL(2)+CLAUDE(1)+README_zh(2)+skills/README(1)=6；4 文档 "Rules 1-38" 残留=0（P5 补 SKILL L9 frontmatter 行）
- [x] V-4: 4 既有 selftest 行数锚 555→558（batch-pilot/execution-stability/knowledge-brief/skill-collab 各 10/19/16/25 PASS）
- [x] V-5: 新建 selftest-workflow-orchestration.sh（WF-01..12）全 PASS；全量 27 selftest FAIL=0
  Evidence: worktree 全量 453/0（基线 441+12）；P5 级联补全（宽容锚 5 处+PT-08）后 master 全量 453/0 复跑
- [x] V-6: config.json 键数恒 40（零新键）
  Evidence: `jq -r '.properties|keys|length'` = 40
- [x] V-7: worktree 合并 + 清理 + 三位部署 IDENTICAL
  Evidence: smart-merge-back merge a3d8679；diff -r 亲验三实体位全 IDENTICAL；worktree remove + branch -d 完成
- [x] V-8: CHANGELOG.md v088 条目
  Evidence: `sed -n '8,14p' CHANGELOG.md` v088 条目在 v087 之上

## 委派统计（Rule 25.4）
- 子代理执行 Phase 3/5（P2/P3/P4）；主进程 P1（④③）/P5（①②③）
- 委派率 0.6 → WHITELIST-EXEMPT（直做理由全命中 25.3 白名单）

## 质量门控统计
- 22.7 换档 0 次；22.3 拆细 0 次（一次过）；错误学习：P5 全量兜底捕获 v085 级联漏网 2 层→B 类登记 Decisions Made（31.2 根因=索引级联 grep 清单未含字面 `1-38` 锚位）

## Outcome: COMPLETE
