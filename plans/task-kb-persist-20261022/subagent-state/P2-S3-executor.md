# P2-S3-executor — 域 C 知识蒸馏（2 条目）

status: done
updated: 2026-10-22
worktree: /home/terry/task-planner-skill-worktrees/kb-persist-20261022
domain: C（worktree 隔离 / 合并回合约 / 部署位同步 / 并行会话隔离 / 指针竞态 / git 安全）

## 产出（恰好 2 个新文件，未动 INDEX/scripts/其他文件）
1. `/home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/entries/worktree-lifecycle-mergeback.md`
   - id: worktree-lifecycle-mergeback；title「worktree 生命周期、合并回与部署位同步」；tags 5 个；sources 12 项；60 行
   - 12 条结论：worktree≠生效环境三步修法 / 新树文件不同步与基线口径 / Rule 27 逐 Phase 提交 / 提交早于 worktree remove / 合并回合约五条 / 瞬态文件冲突取分支版本 / smart-merge-back --deploy 三段原子化 + 新旧契约消息 / 契约改后同步 selftest / 部署位 rm+cp-rL+diff 对账 SOP / .gitignore 不随部署 / revert -m 1 / pathspec 限定提交 + 禁 TaskStop
2. `/home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/entries/worktree-parallel-pointer-race.md`
   - id: worktree-parallel-pointer-race；title「并行会话隔离与活跃计划指针竞态」；tags 5 个；sources 11 项；65 行
   - 14 条结论：指针四层解析链 / RC-1~RC-3 竞态根因与修法 / sidmap 三级语义与防抢条款 / 全局指针瞬态化（git rm --cached + .gitignore:15）/ 双树互不感知行为判据 / 新树 mtime 兜底落错计划 / 存在性假设维守卫 / 引用面 28 文件 170 hits 逐文件分级 + PL-07 机器契约锁步 / 状态判定锚定真实状态行 / side 所有权守卫 / pathspec 限定提交 / 并集解后必须重跑全集 / attest 哈希不符=他会话改动第一信号 / 退役「互顶-移交」叙事

## 自测结果（脚本：/tmp/kb-selftest.sh + /tmp/kb-yamlcheck.py）
- frontmatter YAML 真实解析（pyyaml safe_load）：两文件 id/title/tags/sources/updated 全 PASS，updated=2026-10-22
- sources 逐条存在性（基准仓 /mnt/data/dev/task-planner-skill）：entry1 12/12 存在、entry2 11/11 存在，missing=[]；抽 3 条已打印
- 四段正文齐全：两文件 `## 结论（可直接复用）` / `## 证据锚` / `## 易错点` / `## 适用场景` 全 PASS
- wc -l：entry1=60、entry2=65（均在 40-80 区间；首版 96/112 行已压缩重写至区间内）
- 汇总输出：`ALL PASS`（两轮，第二轮 yamlcheck 亦 ALL PASS）
- git status（worktree）：仅 `?? knowledge/entries/worktree-*.md` 两条为本次产出，其余 ?? 条目属其他域子代理

## 来源消费记录（实际读过才列入 sources）
- 域内 11 任务逐一打开：task-v164（knowledge-brief.md 87 行实质 + findings.md 253 行 + delivery-summary.md）、task-v059（findings）、task-git-timely-commit（findings）、fix-pointer-race-20261007（findings + subagent-state/5-code-assistant.md）、task-v159（findings + delivery-summary + subagent-state/4-code-assistant-SM.md + 4-code-runner-S8.md）、task-deploy-9b167fe / task-deploy-master-20260905（findings）、task-v053-skillfix-deploy（findings）、task-v182（findings）
- 空模板（内容为空，未作来源）：task-v159/v165/v182 的 knowledge-brief.md（★标记与实际不符，实为未填写模板）、task-deploy-all-symlink/findings.md（纯模板）
- 域外补充（已读全文相关行，按实际路径列入 sources）：task-videop1-ep03-rollback-guard/progress.md:106（裸 commit 搭车 → pathspec）、task-v195-spec-recall/progress.md:126（TaskStop 误杀 checkout + 半成品 worktree 被外部删除）、task-v170-archive-completed-plans/progress.md:34（attest 哈希不符判定归属）

## 边界声明
- 未修改 INDEX / scripts / 其他任何文件；未提交 git（主仓与 worktree 均无 git 写操作）
- 主仓仅写本检查点文件（按派发指令豁免）
- 每条结论均标注来源任务；每条证据锚均为 file:line 且原文可复核
