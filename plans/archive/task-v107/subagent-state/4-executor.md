# 4-executor checkpoint | Phase 2 S2 references+templates 审查
- start: 2026-10-02, 材料包=references/(除 critical-rules.md)+templates/
- [milestone] init: 目录结构已列 — references 7 个待审文件, templates 9 内置 + variant 16 个
- [milestone] 维度1 引用路径实存: 抽验 20 条 → 16 EXISTS / 4 MISSING(均为 variant VC 示例脚本, 见问题清单 D1-1)
- [milestone] 维度2 模板一致性: 16 variant frontmatter 形态 + 区块矩阵完成; mini-lite 豁免声明 40.2/42.5/42.6/44 四行全在位✓; 发现 4 文件缺 template_type 声明、8 标准 variant 缺委派统计/Handoff 区块(待复核)
- [milestone] 维度3 config 键对拍: 11 键全部与 defaults 一致(properties=40 与 40.6/41.6/42.5 断言相符)→ 0 问题
- [milestone] 维度4 过期内容: methodology 14 条✓/Rule18 十一条款✓/八字段✓; 发现 task_plan.md:249 旧 worktree 路径、knowledge-brief.md:9 计数 20≠22、methodology SKILL 行号锚偏移、batch-quality-gate 两处过期表述
- 最终结论(8 字段):
status: done
acceptance: 3/3 pass — [1:四维逐维有结论 2:问题清单含 ID/严重度/锚点/证据/修复建议 3:checkpoint 落盘]
files: none(+0/-0, 只读审查)
evidence: templates/task_plan.md:249 `../<repo>-wt-<task-id>`(旧约定,worktree-isolation §3 已废止); templates/knowledge-brief.md:9 "计数维持 20" vs `grep -rn "^## 📚 必要知识储备" templates/ | wc -l` → 22; references/worktree-isolation.md:46+71 两个 "## 4."; scripts/article_json_editor.py 等 4 脚本 find 全仓 0 命中
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v107/subagent-state/4-executor.md (status: done)
findings_written: findings.md #### [sub:4-executor] references+templates 审查
blockers: none
confidence: HIGH

## 问题清单（全文）

### P1（2）
- **P1-1** 锚点 templates/task_plan.md:249 — `worktree_path` 示例值仍写旧约定 `../<repo>-wt-<task-id>`；references/worktree-isolation.md:37 与宪法 §11.2（2026-08-29）已废止旧约定、立 `<repo-parent>/<repo>-worktrees/<task-id>` 新规范。证据：`sed -n '249p' templates/task_plan.md` → `| \`worktree_path\` | \`../<repo>-wt-<task-id>\` 或 n/a |`；worktree-isolation.md:37 原文「旧约定 `../<repo>-wt-<task-id>` …已废止」。修复：:249 改新路径模板，与 worktree-isolation §3 同文。
- **P1-2** 锚点 templates/knowledge-brief.md:9 — 头部注释「templates/ 全库该标题 grep 锚计数维持 20（template-guide.md:65 验收）」过期：实测 `grep -rn "^## 📚 必要知识储备" skills/task-planner/templates/ | wc -l` = 22（与 sub:3 P-2 同根：Rule 16 锚 21/22 漂移链）。卫星 skills/plan-template-kit/references/template-guide.md:77 已写「现为 22」，knowledge-brief 未同步。另「template-guide.md:65」行号锚 vs 卫星实际 :32/:77 段落已移位（待复核 :65 是否仍指 §2.2 表）。修复：20→22 并与 template-guide 同源改。

### P2（6）
- **P2-1** 锚点 references/worktree-isolation.md:46+71 — 两个「## 4.」章节号（生命周期 / 合并回合约），应 4/5/6 或 4.x 编序。修复：合并回合约改「## 5.」，原「## 5. 反模式」改「## 6.」（同文件 :85）。
- **P2-2** 锚点 references/methodology.md:4/:232 — 指针行「SKILL.md:82（Poka-Yoke）/SKILL.md:159 后（内容质量门控）」及「SKILL.md:81」「:156 后」行号锚过期：实测 Poka-Yoke=SKILL.md:76、内容质量门控=SKILL.md:153（偏移 3-6 行，SKILL.md 后续插行未回移锚）。修复：改「SKILL.md Poka-Yoke 行/内容质量门控行」免行号，或按实测重标。
- **P2-3** 锚点 references/batch-quality-gate.md:135 — 关联文档表「Rule 18 十一条款（核心载体，隶属 Rules 1-36）」中 "Rules 1-36" 与 critical-rules 现行 Rule 1-44 规模脱节（同 sub:3 P-4 家族「Rules 1-N」括注问题）。待复核：「隶属」若指核心段口径则措辞改为「核心条款段」更稳。修复：去「1-36」或改「Rules 1-44」。
- **P2-4** 锚点 references/batch-quality-gate.md:111 — 关系表「publish-type.md 模板 | 唯一提到批量的 variant」过期：实测 `grep -l 批量 templates/variant/*.md` → video-type.md:63、video-fix-type.md:91/96 亦含「批量」（video 家族 task-v093/095 收编后未回写）。修复：改「publish/video/video-fix」。
- **P2-5** 锚点 references/dispatch-examples.md:5 — 「由 `scripts/selftest-dispatch.sh` DX-01..DX-03 静态断言守护」vs 脚本实测含 DX-01..DX-05b（:292-311，另有 04/05b 后加未回写）。修复：改「DX-01..DX-05b」。
- **P2-6** 锚点 templates/variant/{diagnostic,publish,research,writing}-type.md 头 4 行 — 4 文件缺 `<!-- template_type: X -->` 注释行（另 12 个 variant 均有；16 文件均含 `plan_tier:`）。check-template-type.sh 白名单按文件名动态派生、不影响 gate，但 16 文件 frontmatter 形态不统一，init-session 复制后依赖注释行插 frontmatter 的路径对这 4 文件需走兜底。修复：补 4 行注释声明。

### 待复核（2，不计入 P 级结论）
- **T-1** 锚点 templates/variant/writing-type.md:11-12 / research-type.md:14 / publish-type.md:15,34,90 — VC 表引用 `python3 scripts/article_json_editor.py`、`scripts/verify_content_originality.py`、`scripts/keyword_coverage.py`、`scripts/rollback.sh` 四脚本，全仓 find 0 命中（`find . -name article_json_editor.py` 等无输出）。疑点：模板为文章管线任务填样，脚本或属目标项目侧（deployment-type:91「写 rollback.sh 脚本」支持 task-generated 解释）→ 口径为「示例值未注目标项目相对」，建议加「示例」注脚而非删除。
- **T-2** 锚点 8 个 13 节标准 variant（bugfix/code-edit/deployment/migration/performance-tuning/refactor/schema-migration/test-writing）— 均无「📊 委派统计」/「🔗 Subagent Handoff 登记表」/「🚨 Drift Log」区块（主模板 task_plan.md 有；mini-lite 白名单显式含 Handoff 表）。Rule 25.4/22.5 措辞「必填」，但 init-session.sh grep 无自动追加证据 → 需主进程确认计划生成时是否由 plan-writer 补全区块；若模板即终态 = 一致性缺口升级 P1。

### 负结果记录
- 维度3 config 键对拍 11 键全 PASS：plan_update_interval_minutes=15 / todo_sync_interval_calls=10 / stale_remind_cooldown_calls=10 / fmea_enforce=warn / content_quality_enforce=warn / shared_tracker_enforce=warn / delegation_rate_floor=0.7 / interaction_mode=ask / vc_gate_enforce=warn / escalation_threshold=3 / subagent.prompt_max_chars=3000，与 todo-sync.md:36/:61、methodology.md:5、verification.md:90、subagent_dispatch.md:59 全部断言一致；config.json properties=40 与 40.6/41.6/42.5「properties=40 维持」断言一致。
- 维度4 数字面：methodology 14 条（R1-R4/T1-T5/Q1-Q5）✓、Rule 18 十一条款（18.1-18.11）✓、batch_report 八字段（total/success/failed/failure_rate/sampled_pass/sampled_fail/pre_check/rollback_point）✓、16 variant 计数✓。
- mini-lite 豁免面：40.2/42.5/42.6/44 四条豁免声明行（mini-lite-type.md:7-9）与 Rule 38.3 白名单五锚点无冲突。
- 维度1 全量 20 条抽验：16 EXISTS；references 间互引（batch_report↔batch-quality-gate↔publish-type 三角）全在位；../plan-cost-guard/references/cost-control.md 实存。
