# S10 仓级文档计数与路径批修正检查点

**执行体**: executor（sonnet-1）
**工作区**: /mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit
**执行时间**: 2026-10-08
**状态**: 完成

---

## 实态基线（一手证据）

| 项目 | 实态 | 证据命令 |
|------|------|----------|
| scripts total | 106 | `ls skills/task-planner/scripts/ \| wc -l` → 106 |
| scripts/*.sh | 96 | `ls skills/task-planner/scripts/*.sh \| wc -l` → 96 |
| selftest-*.sh | 62 | `ls skills/task-planner/scripts/selftest-*.sh \| wc -l` → 62 |
| templates 顶层 | 10 | `ls skills/task-planner/templates/*.md \| wc -l` → 10 |
| templates/variant/ | 29 | `ls skills/task-planner/templates/variant/ \| wc -l` → 29 |
| references/ | 10 | `ls skills/task-planner/references/*.md \| wc -l` → 10 |
| companion/agents/ | 7 | `ls skills/task-planner/companion/agents/ \| wc -l` → 7 |
| install.sh flag 面 | --canonical / --tools / --no-verify / --no-backup / --dry-run | grep install.sh |
| smoke.sh | 17 pass / 0 fail | `bash skills/task-planner/tests/smoke.sh` |

---

## 修改清单

### D16: INSTALL_zh.md 计数修正

| 行 | 修改前 | 修改后 | 证据 |
|----|--------|--------|------|
| 293 | `81 项: .sh 72 个（含 42 selftest）` | `106 项: .sh 96 个（含 62 selftest）` | ls 实测 |
| 302-304 | `8 个: critical-rules / ... / batch-quality-gate` | `10 个: ... / batch-quality-gate / agent-coverage / capability-registry` | ls 实测 |
| 305-309 | `6 个配套 agent: ... / video-generation-executor` | `7 个配套 agent: ... / video-generation-executor / drift-checker` | ls 实测 |
| 312 | `39 个模板、29 类 variant、81 项 scripts、8 个 references` | `39 个模板（顶层 10 个 md + variant 29 类）、106 项 scripts（含 62 selftest）、10 个 references、7 个 companion agent` | ls 实测 |

**注**: templates 顶层实测 10 个 md（S2 检查点报告 12 有误，以实测为准）

### D17: ARCHITECTURE.md 计数修正

| 行 | 修改前 | 修改后 | 证据 |
|----|--------|--------|------|
| 13 | `9 篇规则文档` | `10 篇规则文档` | ls 实测 |
| 17 | `90 个文件` | `106 个文件` | ls 实测 |
| 17 | `51 个 selftest-*.sh` | `62 个 selftest-*.sh` | ls 实测 |
| 46 | `实测 9 篇` | `实测 10 篇` | ls 实测 |
| 64 | `实测 90 文件` | `实测 106 文件` | ls 实测 |
| 81 | `selftest-*.sh ×51` | `selftest-*.sh ×62` | ls 实测 |

### D18: full-workflow.md 路径修正

| 行 | 修改前 | 修改后 | 证据 |
|----|--------|--------|------|
| 20 | `bash scripts/install.sh` | `bash skills/task-planner/install.sh` | find 实测 |
| 26 | `bash scripts/validate.sh` | `bash skills/task-planner/lib/verify.sh` | find 实测 |
| 41 | `session-catchup.py` | `session-catchup.ts` | ls 实测 |
| 42 | `bash scripts/init-session.sh` | `bash skills/task-planner/scripts/init-session.sh` | find 实测 |
| 103 | `bash scripts/check-scope.sh` | `bash skills/task-planner/scripts/check-scope.sh` | find 实测 |

### D28: 在役位口径对齐

| 文件 | 修改内容 | 证据 |
|------|----------|------|
| INSTALL_zh.md:3 | 添加在役位口径注释：五候选/三在役/cursor 陈旧/continue 未部署 | findings.md 拓扑事实 |
| ARCHITECTURE.md:99 | 添加在役位口径注释：五候选/三在役/cursor 陈旧/continue 未部署 | findings.md 拓扑事实 |

### D36: 验证

| 验证项 | 结果 | 证据 |
|--------|------|------|
| install.sh flag 面 vs CONTRIBUTING | 一致（--canonical / --tools / --no-verify / --no-backup / --dry-run） | grep install.sh |
| MIGRATION.md:45 smoke 16 pass | 实测 17 pass / 0 fail，已更新 | bash smoke.sh |

### M/L 计数项

| 文件 | 行 | 修改前 | 修改后 | 证据 |
|------|-----|--------|--------|------|
| INSTALL.md | 250 | `12 个 variant 模板文件` | `29 个 variant 模板文件` | ls 实测 |
| INSTALL.md | 253 | `# 应 = 12` | `# 应 = 29` | ls 实测 |

---

## 异常

1. **S2 检查点 templates 顶层计数有误**: S2 报告 12 个，实测 10 个。以实测为准，原文 10 正确无需修改。
2. **smoke.sh 实测 17 pass vs MIGRATION 声明 16 pass**: 已更新 MIGRATION.md:45 为 17 pass。

---

## 检查点写入时间

2026-10-08 S10 执行完成
