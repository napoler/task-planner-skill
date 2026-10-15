# 5-code-assistant checkpoint
status: done
date: 2026-10-15

## 改动清单（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v177，分支 wt/task-v177）

### skills/task-discipline/references/critical-rules-discipline.md
- Rule 85 段末（原 :508 文件末尾）追加「### 86 可测问题禁问与无推荐禁上抛」全文
- 头注含 What+Why（Rule 45 合规）+ 用户 2026-10-15 裁决一句
- 子条 86.1-86.7 每条独立成段（`### 86.N` H3 锚，grep -cE "^### 86\.[0-9]" = 7）
- 文本逐字采用 findings.md「Rule 86 草稿」（59-65 行），零笔误修正，零扩写
- 注：findings 草稿中无「机制行/机器面标注」独立段——86.7 本身就是机器面子条（selftest-rule86-autonomous-decision.sh + media 47.5 消费锚），已如实保留，未虚构额外机制行

### skills/task-discipline/SKILL.md
- :24 枚举末位 `,76` → `,76,85,86`
- :67 索引表 `| 76 |` 行后追加 `| 85 | 用户输入一致性纪律 | 同上 |` 与 `| 86 | 可测问题禁问与无推荐禁上抛 | 同上 |`
- 计数三处同刷 36→38：:15（「共 38 条」）、:71（「本索引 38 条」）、:82（「38 条规则全文」）

## 验收证据
- grep -cE "^### 86\.[0-9]" .../critical-rules-discipline.md = 7 ≥ 7 PASS
- bash skills/task-planner/scripts/run-selftests.sh --fresh → 尾行 `Total: 81 PASS=81 FAIL=0 (run=81 reused=0)` FAIL=0 PASS
- git status --short：仅上述 2 文件 M，无越界改动

## 负结果报告
- 检查依赖：findings.md Rule 86 草稿段（57-66 行）、critical-rules-discipline.md 400-509 行（Rule 70-85 现状）、SKILL.md 全文
- 未发现冲突：Rule 86 编号已预留（rule-reservations.jsonl task-v177），86.7 引用的 selftest-rule86-autonomous-decision.sh 与 media 47.5 为其他并行单元 S 范围，本单元未创建（铁律禁碰 2 文件外内容）
- 排除风险：未做 git 写操作；计数 grep 确认全仓 SKILL.md 仅 3 处「36 条」命中全部刷新，无遗漏
