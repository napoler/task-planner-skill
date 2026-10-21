# 项目知识库（knowledge/）

> 定位：每次任务积累的知识有固定去处——持续沉淀、累计存留、可快速查询复用。
> 起因：2026-10-22 用户需求「每次积累的知识库文件不断累计沉淀，解决类似问题可以快速查询」。

## 一、定位与三能力

| 能力 | 含义 | 落地机制 |
|------|------|----------|
| 持续沉淀 | 每次任务的知识有固定入库去处，不随会话结束消失 | 任务终验后跑 `scripts/kb-sync-from-plan.sh` 产草稿 → 精炼成条目 |
| 累计存留 | 条目随 git 版本化，历史可追溯，归档任务不失联 | `knowledge/` 纳入仓库版本管理；原始证据长期留在 `plans/archive/<task-id>/` |
| 快速查询 | 遇到类似问题前，一条命令检索既有结论 | `scripts/kb-search.sh <关键词>`（可加 `--tag` 过滤，按标签子串匹配） |

Why（为什么建这个库）：单次会话的知识随上下文清空即失，复用只能翻旧计划目录，成本高且易漏；
本库把分散在归档计划里的事实蒸馏成主题级条目，检索一次即命中，避免"每次现场重新发明"。

## 二、目录结构

```
knowledge/
├── README.md            # 本文件：库定位与使用约定
├── INDEX.md             # 脚本派生索引（kb-rebuild-index.sh 生成，勿手改）
├── entry-template.md    # 条目模板：frontmatter + 四段结构
└── entries/
    ├── <主题-slug>.md        # 正式条目：主题级合成，一文件一主题
    └── _draft-<task-id>.md   # 待精炼草稿：kb-sync-from-plan.sh 产物，不入索引
```

Why（为何 `_draft-` 前缀不入索引）：草稿是待精炼的中间态，内容未合并去重、未补证据锚，
进索引会污染检索结果；`kb-rebuild-index.sh` 按文件名前缀跳过 `_draft-*`。

## 三、写入约定

- **条目 = 主题级合成**：一文件一主题，多来源聚合成一条；禁止按任务"复制式碎片"（同一主题拆成多条互相重复的条目）。
- **Rule 71 无源不写**：`sources` 必填，每项指向**真实存在**的归档路径（`plans/archive/<task-id>/…`）；
  证据锚段须给 `file:line` 级锚点，写必带锚（Rule 71.2 写入前五问自检）。
- **入库时机**：任务终验通过后 → `bash scripts/kb-sync-from-plan.sh <plan-dir>` 生成 draft
  → 精炼（合并去重 → 主题化 → 补证据锚 → 去 draft 前缀改名）→ `bash scripts/kb-rebuild-index.sh` 重建索引。
- **索引为派生物**：`INDEX.md` 只由脚本写；条目增删改名后重跑重建脚本，避免索引与实体失配。

Why（为何入库放在终验后）：任务未终验的结论可能是中途假设，过早入库等于把未验证内容沉淀成"事实"；
终验通过则意味着结论有可复核的证据锚（Rule 51 完成声称门）。

## 四、查询方式

```bash
bash scripts/kb-search.sh worktree              # 关键词检索（输出：文件分组 + frontmatter 摘要 + 命中行）
bash scripts/kb-search.sh dispatch --tag 派发    # 关键词 + 标签过滤（仅命中带该 tag 的条目）
```

示例两条：

1. `bash scripts/kb-search.sh worktree` → 列出命中条目路径（`knowledge/entries/...`）及其 `title`/`tags`/`sources` 摘要与命中行号。
2. `bash scripts/kb-search.sh dispatch --tag 派发` → 只在 `tags` 含「派发」的条目中检索，缩小噪声。

## 五、与 plans/ 的关系

- **知识条目是蒸馏层**：`plans/` 是原始证据层（task_plan / findings / knowledge-brief / verification），
  条目是原始证据的二次蒸馏（结论、锚点、易错点、适用场景）。
- **原始证据永远在归档计划目录**：条目不替代、不删改 `plans/archive/<task-id>/` 下的原文；
  任务归档后，条目仍可回溯到当时的原文版本。
- **冲突时以归档原文为准**：条目与归档原文冲突 → 以归档原文为准，并修正（或删除）条目中对应结论；
  条目是缓存层，不是权威层。
