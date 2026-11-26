# Research Channels — 本地调研方法论

> 完整方法论文档。通篇零写死项目目录；目录只允许 `<root>/<dir>` 占位符出现。
> 与 SKILL.md 配套：SKILL.md 放速查与指针，本文件放可执行细节。

## §0 适用与分工

**适用**：计划期调研、执行前证据收集、用户直呼"调研/先查什么/查资料/本地调研"、任意需要"先搞清楚本地有什么"的任务。

**分工边界**：

| 组件 | 职责 | 边界 |
|------|------|------|
| `research-channels`（本技能） | 本地证据通道方法论 L1-L4 + L5 转交指针 | 不执行网络抓取；不写死目录 |
| `plan-research-router` | 网络/github 路由 SOP（WebSearch/gh/降级链） | 只做路由决策与路径选择 |
| `research-assistant` | 外部多源检索执行链（bing-intl/searxng 等） | 由 L5 或路由侧调用 |
| 宪法 §七 | 网络工具降级链铁律 | 本技能 L5 遵循其纪律，不重复定义 |

**核心原则**：机制通用，数据外置。目录结构、关注文件名模式、排除扩展由项目自己的索引（`.inventory.tsv`）与 `.inventory-ignore` 承载，本技能不硬编码。

## §1 L1 枚举层

目标：在结构未知时快速建立"这里有什么"的骨架，避免盲搜。

### 工具×场景×命令模板

| 场景 | 命令模板 | 何时用 | 备注 |
|------|----------|--------|------|
| 单层概览 | `ls -la <root>` | 刚进入目录，不确定顶层结构 | 先看入口文件/配置/文档 |
| 目录骨架 | `find <root> -maxdepth 2 -type d \| LC_ALL=C sort` | 需要 2 层结构图 | 广度优先摸骨架 |
| 全量文件清单 | `find <root> -type f -not -path '*/.git/*' -not -path '*/node_modules/*' \| LC_ALL=C sort` | 需要完整清单但无索引 | 大仓先限深度或转 L2 |
| 热点/体积 | `du -sh <root>/* 2>/dev/null \| sort -h` | 找大目录/产物/数据堆积 | 排查是否误入产物目录 |
| 按名找文件 | `find <root> -iname '*<kw>*' -not -path '*/.git/*'` | 知道文件名片段 | 命中后转 L4 阅读 |
| 按类型摸底 | `find <root> -type f -name '*.<ext>' \| wc -l && find <root> -type f -name '*.<ext>' \| head` | 判断某类文件规模 | 先计数再抽样，禁全量读 |

### 多层下钻策略（先广后深）

1. **广度**：先 `maxdepth 2` 拿骨架，标记相关性高的子树。
2. **聚焦**：对相关子树再 `maxdepth 4` 或定点 `ls`。
3. **收敛**：确认目标文件后立即转 L4 阅读锚定；不要在枚举层无限下钻。
4. **止损**：输出超过 ~200 行或命中 >100 文件时，停止扩展，转 L2 索引或委派子代理提炼。

## §2 L2 索引层

目标：生成/复用确定性文件清单，作为"全局有什么"的防遗漏基线。

### 脚本用法

```bash
# 生成索引（默认输出 <root>/.inventory.tsv）
bash <skill>/scripts/project-inventory.sh --root <root>

# 指定输出
bash <skill>/scripts/project-inventory.sh --root <root> --out <root>/.inventory.tsv

# 追加排除 glob（可重复）
bash <skill>/scripts/project-inventory.sh --root <root> --exclude-add '*.log' --exclude-add 'cache'

# 陈旧判定（复用未陈旧索引）
bash <skill>/scripts/project-inventory.sh --root <root> --check
```

### 研究第 0 步

任何调研动作前执行：

```bash
bash <skill>/scripts/project-inventory.sh --root <root> --check || \
  bash <skill>/scripts/project-inventory.sh --root <root>
```

### 陈旧判定语义

| exit code | 含义 | 动作 |
|-----------|------|------|
| 0 | fresh：索引存在且 mtime >= 树内最新文件 mtime | 直接复用索引 |
| 1 | stale：索引存在但树已更新 | 重新生成 |
| 2 | missing：索引不存在 | 生成索引 |

判定尊重排除集（被排除目录内的变化不触发 stale）。

### 索引格式与保证

- 格式：`path<TAB>bytes<TAB>mtime(YYYY-MM-DD HH:MM, UTC)<TAB>ext`，无表头，`LC_ALL=C sort` 全排序。
- 路径相对 `<root>`，可移植、可 diff。
- 确定性：同一树状态两次运行输出逐字节一致。
- **清单完整性保证**：索引覆盖所有未被排除的文件；"没进索引 = 没被发现"。发现索引外应被关注的区域时，要么调整排除、要么显式记录为盲区，禁止默默忽略。

## §3 L3 检索层

目标：在已知线索时快速定位证据文件与行。

### 决策表

| 你知道什么 | 用什么 | 命令模板 |
|------------|--------|----------|
| 文件名/片段 | `find -iname` | `find <root> -iname '*<kw>*' -not -path '*/.git/*'` |
| 关键词/符号 | `grep -rn` | `grep -rn --include='*.<ext>' '<kw>' <root>` |
| 多关键词任一 | `grep -rnE` | `grep -rnE 'kw1\|kw2\|kw3' <root>` |
| 结构未知 | L1 枚举 | 先骨架再检索，禁盲目全仓 grep |
| 需要全局有什么 | L2 索引 | 先 `project-inventory.sh` 再过滤 |
| 超大输出 | 子代理提炼 | 主上下文只收"命中锚+摘要" |

### 检索纪律

- CJK/含空格关键词加引号：`grep -rn '关键词' <dir>`。
- 用 `--include`/`--exclude-dir` 限定范围，避免扫产物目录。
- 命中后记录 `file:line`，立即转 L4 阅读锚定；不要把 grep 原始大输出贴进主上下文。
- 同一关键词检索无结果时：换同义词/换层（L1 看是否存在该类文件）再试一次；仍无结果记证据后换层，禁止原地重复。

## §4 L4 阅读锚定层

目标：把证据变成可审计、可回链的锚定记录，禁止转译漂移。

### 锚定规则

- **逐字摘录**：关键句/字段/配置原样摘录，禁止转译改写后当原文。
- **锚格式**：`<相对路径>:<line>`（单行）或 `<相对路径>:<start>-<end>`（范围）；命令证据用 `命令 + 输出摘要行`。
- **最小充分**：摘录覆盖结论所需最小范围，附前后 1 行上下文判断语义时标注"含上下文"。
- **无锚不结论**：没有源锚的判断标为"未验证假设"，不得写入 decisions/findings 作为事实。

### 声明源扫描回执格式

L4 产出作为「声明源扫描回执」，可落 plan-state `spec_baseline`（`dimension` 为开放标签，机制不枚举；由 task-planner 侧消费门校验）。

| 源锚 | 逐字引文 | 维度标签 | 处置建议 |
|------|----------|----------|----------|
| `<dir>/<file>.md:42` | "……逐字原文……" | `setting` | 纳入约束：…… |
| `<dir>/<config>.yaml:7` | "key: value" | `config-key` | 作为实现依据 |

示例（维度标签用开放标签如 `setting/config-key/library-doc`，**标签自由，机制不枚举**）：

| 源锚 | 逐字引文 | 维度标签 | 处置建议 |
|------|----------|----------|----------|
| `docs/<spec>.md:15` | "接口超时默认 30s，可配置范围 5-120s" | `config-key` | 实现读取配置项并校验范围 |

### 回执最小字段

- `源锚`：可定位回原文。
- `逐字引文`：原文片段，保留关键标点/数字/大小写。
- `维度标签`：开放标签，由任务/项目自行约定；本机制只要求存在，不枚举合法值。
- `处置建议`：纳入约束/作为依据/冲突待裁决/忽略（须注明理由）。

## §5 L5 外部层

目标：本地证据不足时转外部调研，保持同等锚定纪律。

- 网络/github 调研转 `Skill(skill="plan-research-router")`，按其路由选择 WebSearch / gh / research-assistant 链。
- 需要多源交叉验证时走 `research-assistant` 技能链（bing-intl-search / searxng / 浏览器降级），遵循宪法 §七 降级链。
- 外部结论同样必须源锚：URL + 访问日期/版本号/commit SHA（能取到则取）；禁止"网上说"式无锚结论。
- 本地证据与外部证据冲突时，记录冲突双方锚与冲突点，交用户/上游裁决，不擅自裁断。

## §6 排除约定

### 默认排除集

以下 basename glob 默认排除（与 `project-inventory.sh` 一致）：

```
.git  node_modules  __pycache__  *.pyc  tmp  dist  build
.venv  venv  target  .zcode  .plan-required  .plan_required  archive
```

### 项目可覆写机制

- 项目根 `<root>/.inventory-ignore`：每行一个 glob，空行与 `#` 注释忽略；与默认集合并。
- 命令行 `--exclude-add <glob>`：临时追加，可重复传入。
- 需要纳入默认排除目录时：不要改脚本默认集；改用更窄的 `--root` 或单独 L1 命令定点查看，并在回执中记录"手工纳入区域"。

### 排除变更纪律

- 扩大排除 = 可能制造盲区：必须在调研结论中声明新增排除项与理由。
- 缩小排除 = 可能引入噪声/大输出：先计数再决定是否全量入索引。

## §6.1 工具决策表

| 你需要什么 | 首选 | 备选 | 禁止 |
|------------|------|------|------|
| 知道文件名/片段 | `find -iname` | `ls`/Glob | 全仓盲读 |
| 知道关键词/符号 | `grep -rn`/`rg -n` | L3 多关键词 OR | 无范围全仓 grep 后整屏贴入 |
| 结构未知 | L1 枚举（先广后深） | L2 索引 | 猜目录名反复 cd |
| 全局有什么 | L2 索引 `project-inventory.sh` | `find -type f` | 凭记忆假设文件存在 |
| 证据落盘 | L4 逐字摘录 + file:line | 命令+输出摘要 | 转译改写当原文 |
| 本地不足 | L5 转 plan-research-router | research-assistant | 无锚外部结论 |

## §6.2 大仓策略

1. **先索引**：`project-inventory.sh --root <root>` 生成基线；后续用 `grep`/`awk` 在索引上过滤，不反复扫盘。
2. **先热点**：`du -sh`/文件类型计数识别大目录，确认是否应排除。
3. **相关性子树下钻**：从骨架中选 1-3 个高相关子树深入，其他记录为"未下钻"。
4. **子代理提炼**：命中 >50 行或需跨多文件归纳时，委派子代理读文件并返回"锚+摘要"，主上下文不吃原料。
5. **禁止全量读入主上下文**：大仓原文、长日志、全量 grep 输出一律不进主上下文；只收锚与结论。

## §7 失败与证据纪律（执行清单）

- 任何层失败/无结果：记录 `层级 | 命令 | 失败/空结果原因 | 下一层` 一行，**当轮**切换。
- 同层同方法最多重试 1 次（参数修正）；第 2 次失败必须换层或换方法。
- 五层穷尽才可声明受限；声明模板：`受限：已尝试 L1-L5；证据=...；盲区=...；建议=...`。
- 所有结论回链源锚；无锚内容降级为假设，显式标注。
