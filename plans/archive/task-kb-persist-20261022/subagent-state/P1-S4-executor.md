# P1-S4 — executor 检查点（knowledge/README.md + entry-template.md）

- 任务：task-kb-persist-20261022 / P1-S4（建 knowledge/README.md 与 knowledge/entry-template.md）
- 执行时间：2026-10-22
- worktree（唯一写入目标）：`/home/terry/task-planner-skill-worktrees/kb-persist-20261022/`
- 交付文件（仅此 2 个，其余文件零改动）：
  - `/home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/README.md`（63 行，限 ≤70）
  - `/home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/entry-template.md`（40 行，限 ≤50）
- 纪律：未创建/修改任何其他文件；未触碰他人并行开发的 `scripts/kb-*.sh`（只读阅读 + 只读调用 `--dry-run`/检索）；未写主仓（除本检查点）。

---

## §1 交付内容对照规格

| 规格项 | 落点 | 证据 |
|--------|------|------|
| ① 定位与三能力（持续沉淀/累计存留/快速查询）+ Why 引用户原话 | README §一（能力表 3 行 + Why 段） | `knowledge/README.md:6-16` |
| ② 目录结构（README/INDEX 勿手改/entry-template/entries/_draft- 不入索引） | README §二（目录树 + Why） | `knowledge/README.md:17-31` |
| ③ 写入约定（主题级合成禁碎片 / Rule 71 无源不写 sources 指向 plans/archive/<task-id>/ / 入库时机 sync→精炼→rebuild） | README §三（4 条 bullet + Why） | `knowledge/README.md:32-43` |
| ④ 查询方式（`kb-search.sh <关键词>`、`--tag` + 示例两条） | README §四 | `knowledge/README.md:44-55`（命令示例 47-48、示例说明 53-54） |
| ⑤ 与 plans/ 关系（蒸馏层 / 原文在归档 / 冲突以归档原文为准并修条目） | README §五 | `knowledge/README.md:56-63` |
| entry-template frontmatter 范例块（--- 围栏；id/title≤20 字/tags 列表/sources 每项一行归档路径/updated YYYY-MM-DD；每字段带说明注释） | 文件首部 frontmatter | `knowledge/entry-template.md:1-11`（sources 键行 7、列表项 8-9） |
| 四段结构（结论/证据锚/易错点/适用场景，各带填写说明注释） | `## 结论（可直接复用）` 等 4 个 H2 | `knowledge/entry-template.md:18-35`（结论 18 / 证据锚 23 / 易错点 28 / 适用场景 32） |
| 末尾「填写规则」3 条（一主题一条目 / sources 必填且真实存在 / 成稿后 slug 改名 + 重跑 rebuild） | `## 填写规则` | `knowledge/entry-template.md:36-40` |

## §2 自测命令与结果（原文输出）

```
$ cd /home/terry/task-planner-skill-worktrees/kb-persist-20261022 && wc -l knowledge/README.md knowledge/entry-template.md
 63 knowledge/README.md
 40 knowledge/entry-template.md
103 total
```

```
$ grep -n "kb-search.sh" knowledge/README.md
12:| 快速查询 | 遇到类似问题前，一条命令检索既有结论 | `scripts/kb-search.sh <关键词>`（可加 `--tag` 过滤） |
47:bash scripts/kb-search.sh worktree              # 关键词检索（输出：文件分组 + frontmatter 摘要 + 命中行）
48:bash scripts/kb-search.sh dispatch --tag 派发    # 关键词 + 标签过滤（仅命中带该 tag 的条目）
53:1. `bash scripts/kb-search.sh worktree` → 列出命中条目路径（`knowledge/entries/...`）及其 `title`/`tags`/`sources` 摘要与命中行号。
54:2. `bash scripts/kb-search.sh dispatch --tag 派发` → 只在 `tags` 含「派发」的条目中检索，缩小噪声。

$ grep -n "sources" knowledge/README.md
35:- **Rule 71 无源不写**：`sources` 必填，每项指向**真实存在**的归档路径（`plans/archive/<task-id>/…`）；
53:1. `bash scripts/kb-search.sh worktree` → ...`title`/`tags`/`sources` 摘要与命中行号。
```

```
$ awk '/^---$/{c++} c==1' knowledge/entry-template.md
---
id: media-dispatch-routing-rule-47   # 唯一标识：主题短横线 slug，全库唯一，跨批次不重名
title: 媒体类任务的子代理路由   # 主题短名，≤20 字，检索结果里一眼可分辨
tags: [子代理路由, 媒体]   # yaml 列表：2-4 个稳定标签，供 kb-search.sh --tag 过滤
# sources：yaml 列表，每项一行真实存在的归档路径（Rule 71 无源不写）。
# 键行刻意留空、勿加行内注释——kb-rebuild-index.sh 取该行余部作值，行内注释会污染索引列。
sources:
  - plans/archive/task-v122/knowledge-brief.md
  - plans/archive/task-v122/findings.md
updated: 2026-10-22   # YYYY-MM-DD：条目最后一次精炼日期（非草稿生成日）
---
（exit=0；frontmatter 块可被 awk 精确提取）
```

```
$ bash scripts/kb-search.sh worktree   # 只读冒烟：exit=0，命中 knowledge/README.md:47,53 与既有 draft 条目
$ bash scripts/kb-rebuild-index.sh --dry-run   # 只读（--dry-run 不落盘）：exit=0，空表 0 条
$ git status --short
?? knowledge/
?? scripts/
```

## §3 关键设计裁决（Decisions Made）

1. **sources 键行留空、说明注释置于键行上方**：读 `scripts/kb-rebuild-index.sh` 的 awk 解析器后确认——`sources:` 行会取该行**余部**作为值（`substr($0,9)` 后 trim），行内注释会被写进 INDEX.md 的 sources 列并污染索引。故模板中 `sources:` 键行裸写，说明用上方 `#` 注释行；其余字段（id/title/tags/updated）用行内 `#` 注释。
2. **entry-template.md 的 frontmatter 置于文件首行**：使 `awk '/^---$/{c++} c==1'` 无歧义提取即范例块；`kb-rebuild-index.sh` 只扫 `knowledge/entries/*.md`，模板不入索引。
3. **README 明确「任务终验后入库」**：终验前的结论属中途假设，过早入库会把未验证内容沉淀成事实（Rule 51 + Rule 71 写入前五问）。
4. **示例 sources 用仓内真实存在的归档路径** `plans/archive/task-v122/knowledge-brief.md`、`plans/archive/task-v122/findings.md`（该 task 目录实际存在），避免模板给出假路径示范。

## §4 未完成项与风险

- 未做：`knowledge/entries/` 下的正式条目（属 S1~S6 批次任务，不在本 S-unit 范围）；未跑正式索引重建（会写 `knowledge/INDEX.md`，超出「仅 2 文件」铁律，仅以 `--dry-run` 验证）。
- 风险：README 与 entry-template 中的脚本名/参数以当前 worktree 内 `scripts/kb-*.sh` 实现为准；他人并行开发若改脚本 CLI（如 `--tag` 语义、plan-dir 入参），README 第四章需同步订正。
- 风险：模板 `sources` 用仓相对路径（`plans/archive/...`），而既有 draft 条目由 `kb-sync-from-plan.sh` 写入的是绝对路径；两种形态并存，检索时均可命中，但后续条目宜统一为仓相对路径（可移植）。

---

## 最终结论

```
status: done
acceptance: 2/2 pass — [1:PASS 2:PASS]
files: /home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/README.md(+63/-0); /home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/entry-template.md(+40/-0)
evidence: wc -l knowledge/README.md knowledge/entry-template.md → 63 / 40（限 70 / 50）; grep -n "kb-search.sh" knowledge/README.md → 12,47,48,53,54; grep -n "sources" knowledge/README.md → 35,53; awk '/^---$/{c++} c==1' knowledge/entry-template.md → 提取 frontmatter 11 行（id/title/tags/sources/updated 全字段 + 注释），exit=0; bash scripts/kb-search.sh worktree → exit=0 命中 knowledge/README.md:47,53; bash scripts/kb-rebuild-index.sh --dry-run → exit=0（未落盘）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-kb-persist-20261022/subagent-state/P1-S4-executor.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
