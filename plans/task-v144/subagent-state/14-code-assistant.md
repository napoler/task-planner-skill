# sub:14 code-assistant — iteration-persistence FAIL 修复 + registry.tsv 补登

status: done

## 执行记录

### 目标 A: selftest-iteration-persistence.sh（三同步：断言+docblock+诊断串）
- IP-14 负断言对象 `^59\.[0-9] `→`^63\.[0-9] `（L158-170 断言块 + L21 docblock 条目 + L40 Why 段 + L170 ok/bad 诊断串）
  - 级联依据：critical-rules.md 取证 `grep -cE '^59\.[0-9] '`=8（v144 Rule 59 已落 59.1-59.8）、`'^6[0-9]\.[0-9] '`=14（60=v142、62=v145）、`'^63\.[0-9] '`=0 → 63=首个全未占用号（61 预留）
  - 级联注释：`[2026-10-08 task-v144 合并级联] 59 号已由 task-v144 Rule 59 合法创建（59.1-59.8），且 60=v142 / 62=v145 已落地、61 为预留号，首个全未占用号=63；负断言对象 59.x→63.x`
- IP-15 config properties 键数 40→42（L173-185 断言块 + L23 docblock 条目 + ok/bad 诊断串双分支 jq/python3）
  - 取证：`jq '.properties|keys|length'`=42（v145 合法加 2 键，FF 守护 42 为准）；Rule 57 自身仍零新键（IP-16 未动）
- 附带同 S-unit 级联：IP-12 宽容正则 `Rule 40-5[5-9]`→`Rule 40-[56][0-9]`——SKILL.md L273 全集声明已演进为「Rule 40-62」，旧正则命中=0（IP-12 FAIL 根因）

### 目标 B: selftest-registry.tsv
- 追加 1 行登记 selftest-periodic-review.sh（追加至 L59 后，新 L60；表头+59 脚本行=60 行）
- 行内容：`selftest-periodic-review.sh<TAB>Rule 57 周期性回顾与前后对照静态守护 PR-01..10（task-v142，补登记 2026-10-08 task-v144 合并级联：master 存量脚本从未登记，本行补登解 T02/SR-12）<TAB>57 条款五维度锚(存在/触发时机/前后对照/自动纠正/开关键 periodic_review_enforce)/periodic-review.sh 可执行/config 双键(periodic_review_enforce+periodic_review_interval_calls)/registry 自登记/SKILL C39 引用<TAB>periodic-review.sh;references/critical-rules.md;config.json;scripts/selftest-registry.tsv;SKILL.md`
- 提炼来源：selftest-periodic-review.sh L1-17 头注释（PR-01..10 断言面 + 实际引用文件路径）

## 验证（实跑原文行）
- `bash scripts/selftest-iteration-persistence.sh` → `Total: 18 PASS=18 FAIL=0`
- `bash scripts/selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=59, actual selftest=59)`
- `bash scripts/selftest-self-resolution.sh` → `Total: 13 PASS=13 FAIL=0`（SR-12 动态行数：59 脚本+1 表头=60，补登后对上）

## 负结果/边界
- 本 S-unit 仅改 2 文件；worktree 内其余 9 个 M 文件（SKILL.md / selftest-evidence-goal-gate / execution-stability / knowledge-brief / lane-advancement / requirement-coverage / self-resolution / tool-selection / workflow-orchestration）为前序 S1-S11 单元既有产物，零触碰
- 未 git add/commit
- IP-08 PASS 行含 "FAIL=2" 字样系 grep 到 PASS 说明文本，非断言失败（Total 行已证 FAIL=0）

## 材料索引
- findings.md 追加锚点：`#### [sub:14-code-assistant] IP-14/IP-15 级联修复 + registry.tsv 补登（iteration-persistence FAIL 清零）`
- progress.md Phase 3 Actions taken 追加：`- [sub:14] IP-14 负断言 59.x→63.x + ...`
