---
id: md-edit-ops-structured-editing
title: "md-edit-ops 结构化 markdown 编辑执行器（edit-ops 指令单/预校验/原子应用/回滚）"
tags: [markdown-editing, edit-ops, atomic-edit, tooling, reliability]
sources: [skills/md-edit-ops/SKILL.md, skills/md-edit-ops/scripts/md-edit-ops.ts, skills/md-edit-ops/scripts/selftest-md-edit-ops.sh, skills/task-discipline/references/critical-rules-discipline.md, plans/archive/task-mdedit-reliability-20261116/findings.md, plans/archive/task-mdedit-reliability-20261116/research-external-tools.md]
updated: 2026-11-16
---

# md-edit-ops 结构化 markdown 编辑执行器

## What（本体事实）
- **技能本体**：`skills/md-edit-ops/`——edit-ops JSON 指令单执行器。CLI：`bun run`（或 `node --experimental-strip-types`）`skills/md-edit-ops/scripts/md-edit-ops.ts --order <file.json> [--dry-run] [--report <path>] [--backup-dir <dir>]`（零三方依赖，仅 node:fs/crypto/path；bun+node 双运行时）。
- **七步流水线**：load/schema 校验（exit 2）→ base_hashes staleness 门（exit 3，声明即 sha256 强校验，防多次编辑间漂移）→ 锚点预校验（exact/regex/heading 三型 + `expect_count` 强制唯一计数，命中≠计数即 FAIL，exit 4，全内存零写入且报告含全部 op 的 matched）→ 内存模拟应用 → 回读断言（标题**解释性守恒**+insert 类锚行保活+expect 正则，exit 5）→ 原子写盘（备份先行+temp+rename，多文件中途败自动回滚，exit 6）→ apply-report（per-op matched/line_range + per-file sha 前后值/backup 路径）。
- **四失败模式机制映射**：锚点失配/静默失配→预校验 0 命中即 FAIL；吞块→回读断言（结构守恒+锚保活）；状态混乱→apply-report+staleness 门；部分提交→原子写盘+备份回滚。
- **验证基线**：selftest `skills/md-edit-ops/scripts/selftest-md-edit-ops.sh` **52 断言 bun+node 双运行时 ALL GREEN**（已登记 selftest-registry.tsv）；实弹冒烟=README 全往返（dry-run 零写入→apply→逆序单还原 diff/sha 一致）。

## Why（业界对标缺口）
- Edit 锚点四失败模式高频（吞块判例三犯、python/sed 静默失配判例 3 处）；纪律 Rule 106 管**触发与留痕**，工具 md-edit-ops 管**执行与拦截**——双轨合流不重复不缺位（Rule 106.6，`skills/task-discipline/references/critical-rules-discipline.md:741`）。
- 业界对标（源码验证）：Aider SEARCH/REPLACE **成功块立即落盘、无事务回滚**；Codex apply_patch **无全量回滚**（失败仅带 delta）→「写前预校验+原子+回滚」是真实缺口；RFC6902 事务语义+git apply --check 两阶段为直接依据。
- 实证判例：同一指令单重放已应用文件→exit 4 拦截+零写入（staleness/幂等守卫）；部署副本运行位冒烟 exit 0。

## How（触发与部署）
- **触发面**：Rule 106.6 纪律条款 + md-edit-ops SKILL.md 触发词（批量编辑 markdown/结构化编辑/edit-ops/多次编辑/防吞块/markdown 批量修改）；markdown-editor 保持原则基座（本执行器为执行面，非替代）。
- **部署位**：zcode/claude/opencode/agents/cursor **5 位 19 文件 IDENTICAL**；smart-merge-back --deploy 覆盖 claude/opencode，zcode 运行位自保护 REJECTED 需手动 rm+cp（判例），新增技能与 discipline 位须文件级手动 cp（--deploy 只覆盖 task-planner 兄弟技能）。
- **使用契约**：构造指令单→`--dry-run` 看全貌 matched→正式跑→apply-report 路径记 progress `[recheck]` 行（Rule 106.1/106.6 协同）；失败单零写入可安全重试。

## Sources（全部盘上锚）
- `skills/md-edit-ops/`（SKILL.md+md-edit-ops.ts+selftest+examples）
- `skills/task-discipline/references/critical-rules-discipline.md:741`（Rule 106.6）
- `plans/archive/task-mdedit-reliability-20261116/findings.md`（设计定稿段+P3/P4/P5 结论段）
- `plans/archive/task-mdedit-reliability-20261116/research-external-tools.md`（Aider/Codex/RFC6902/git apply 逐条来源 URL）
