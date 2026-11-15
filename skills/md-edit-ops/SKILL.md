---
name: md-edit-ops
description: "批量编辑 markdown、结构化编辑、edit-ops、多次编辑、防吞块、markdown 批量修改。通过 JSON 指令单执行可校验、可回滚的 markdown 编辑，替代易失配的裸 sed/python 长文批量替换。"
---

# md-edit-ops — 结构化 Markdown 编辑执行器

用 JSON 指令单（edit-ops）对 markdown 执行**预校验→原子应用→回读断言→可回滚**的批量编辑，机制性拦截锚点失配、吞块、状态混乱与静默失配。

## 何时用
- 一次需对 markdown 做多处结构化修改，且需要可审计回执。
- 历史上易出现锚点失配、插段吞锚、批量替换 0 命中仍“成功”、多步后状态混乱的场景。
- 需要 `--dry-run` 先看全貌 matched 计数与断言结果，再决定是否落盘。

## 何时不用
- 单处极小改动且锚点唯一明确，可直接用常规 Edit（仍需遵守 Rule 106/106.1a 写后回读与结构守恒）。
- 非 markdown 或需要语义理解重写全文的场景。

## CLI
```bash
# Bun 优先；node 兼容（仅类型注解，无 enum/装饰器/三方依赖）
bun run skills/md-edit-ops/scripts/md-edit-ops.ts --order <file.json> [--dry-run] [--report <path>] [--backup-dir <dir>]
node --experimental-strip-types skills/md-edit-ops/scripts/md-edit-ops.ts --order <file.json> [--dry-run] [--report <path>] [--backup-dir <dir>]
```
- `--order`：指令单路径；其中 `file` 相对路径以指令单所在目录为基准解析。
- `--dry-run`：只跑 load/schema→staleness→预校验→模拟→断言，零写入，报告标 `dry_run:true`。
- `--report`：apply-report JSON 落盘路径（同时始终输出 stdout）。
- `--backup-dir`：备份目录（缺省 `<file>.edit-ops-bak` 同目录同名后缀）。

## 指令单 schema v1（示例）
```json
{
  "version": 1,
  "description": "批次说明",
  "base_hashes": { "path/to/doc.md": "sha256-hex（可选，声明即强校验）" },
  "ops": [
    {
      "id": "op1",
      "op": "sub | insert_after | insert_before | replace_range | delete_range | append | prepend",
      "file": "path/to/doc.md",
      "anchor": { "type": "exact | regex | heading", "value": "锚文本/模式/标题行", "expect_count": 1, "occurrence": 1 },
      "end_anchor": { "type": "exact", "value": "范围终点（replace_range/delete_range 必填）" },
      "old": "仅 sub：被替换原文（逐字计数校验）",
      "content": "新内容/插入内容",
      "expect": ["应用后必须命中的正则（可选）"]
    }
  ]
}
```
锚点：`exact`=逐字子串；`regex`=正则；`heading`=markdown 标题行（`^#{1,6} `且与 `value` 全行精确相等）。`expect_count` 缺省 1，**命中数≠expect_count 即 FAIL**（0 命中与多命中同等拦截）。`occurrence` 选择第几个命中（1-based，缺省 1）。

## 七步流水线（语义速查）
1. **load/schema**：解析与校验，失败 exit 2，零写入。
2. **staleness**：声明 `base_hashes` 则逐文件 sha256 比对，不符 exit 3（防陈旧指令单/状态漂移）。
3. **预校验+模拟（内存）**：逐 op 锚点计数与 sub.old 计数校验并顺序模拟；任一 FAIL → 整单拒绝 exit 4，报告含全部 op 的 `matched` 计数，零写入。
4. **回读断言（对模拟结果）**：标题行（`^#{1,6} `）净增守恒；insert 类 op 后 anchor 计数不变（锚行保活）；`expect` 正则逐条命中；任一败 exit 5，零写入。
5. **原子写盘**：先备份（`--backup-dir` 或 `<file>.edit-ops-bak`）→ temp 写 → rename；多文件顺序写中途失败 → 已写文件自备份回滚 exit 6。
6. **apply-report**：stdout + `--report` 落盘。`--dry-run` 只跑 1-4 步。

## apply-report 字段
- per-op：`{id, op, file, status, matched, line_range, error}`
- per-file：`{before_sha256, after_sha256, backup}`
- summary：`{total, ok, failed, exit_code}`；顶层 `dry_run`。

## Exit code
| code | 含义 | 写入 |
|------|------|------|
| 0 | 全成功 | 已写（或 dry-run 零写入） |
| 2 | load/schema/读文件失败 | 零写入 |
| 3 | base_hashes 陈旧/不符 | 零写入 |
| 4 | 预校验失败（锚点/计数/old） | 零写入，整单拒绝 |
| 5 | 回读断言失败（守恒/expect） | 零写入，整单拒绝 |
| 6 | 写盘失败且已回滚尝试 | 已写文件尝试从备份恢复 |

## 与 Rule 106/106.1a 协同
- 工具提供机器级预校验、原子与断言；纪律仍负责触发与留痕。
- 使用后将 `--report` 路径记入 progress 的 `[recheck]` 行（按 Rule 106.1），作为可审计证据。
- 结构文件插段仍应先确认锚点角色；本工具会拦截多命中/0 命中与锚行破坏类断言失败。
- 规则指针：task-discipline `Rule 106.6`（`skills/task-discipline/references/critical-rules-discipline.md`，批量/结构化 markdown 修改优先本执行器）。

## 禁止项
- **禁裸 sed/python 长文批量替换**处理 markdown 结构编辑（易静默失配/吞块）。必须走 edit-ops 指令单并检查 exit code 与 apply-report。

## 示例
见 `examples/order-demo.edit-ops.json` + `examples/demo.md`。
