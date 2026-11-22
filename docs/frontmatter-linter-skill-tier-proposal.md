# frontmatter-linter skill 档适配提案（task-fix-all-20261123）

> 状态：**提案稿，未落地**。目标文件 `/home/terry/.zcode/agents/frontmatter-linter.md` 属 §六 保护区，本次未获用户明确授权，**禁止直接修改**。本提案供用户授权后落地。

## 1. 根因

`frontmatter-linter` 当前 R1 规则（`frontmatter-linter.md:18`）：

> `name` / `description` / `model` / `tools` 四字段必须存在且非空；缺任一 = ERROR

该契约是 **agent 档**契约，但扫描范围同时包含 `~/.zcode/skills/**/SKILL.md`（`frontmatter-linter.md:26`）。skill 的合法惯例是 `name` + `description` 必填，`allowed-tools`/`model`/`tools` 可选（大量顶层技能无 `model/tools`）。因此用 agent 契约扫 skill 会产生系统性 R1 ERROR 误报（本次审计观察到 21 个顶层技能被误报）。

## 2. 目标

让 linter 区分 **agent 档** 与 **skill 档**，各自应用对应必填字段规则；保留现有 R2-R5 语义，但按档位调整适用范围。

## 3. 建议增补条款（可直接落地到 frontmatter-linter.md）

### 3.1 新增“档位判定”规则（置于规则清单前）

```md
## 档位判定（先于 R1 执行）
- **agent 档**：路径匹配 `/home/terry/.zcode/agents/*.md`（排除 README/非 agent 文件）→ 应用 agent 规则集。
- **skill 档**：路径匹配 `/home/terry/.zcode/skills/**/SKILL.md` → 应用 skill 规则集。
- **unknown 档**：不匹配以上范围 → WARN `未知档位，跳过字段必填校验，仅报告 frontmatter 存在性`。
```

### 3.2 R1 拆分为 R1-agent / R1-skill

```md
1. **必填字段（agent 档）**: `name` / `description` / `model` / `tools` 四字段必须存在且非空；缺任一 = ERROR
1b. **必填字段（skill 档）**: `name` / `description` 必须存在且非空；缺任一 = ERROR。
    - `model`：可选；若存在则按 R3 格式校验。
    - `tools`：agent 档字段名；skill 档不要求。
    - `allowed-tools`：skill 档合法可选字段（工具白名单）；若存在应为非空列表，不作为 ERROR 缺失项。禁止因缺少 `model/tools` 报 R1 ERROR。
```

### 3.3 R2/R3/R4/R5 档位适配

```md
2. **name=文件名**: 两档通用。
   - agent 档：`name` 与文件基名（去 .md）一致。
   - skill 档：`name` 与所在技能目录名一致（`skills/<dir>/SKILL.md` → `<dir>`）；不一致 = ERROR。

3. **model 行格式**: 两档通用，但仅在字段存在时校验；skill 档缺失 `model` 不报错。

4. **tools/allowed-tools 一致性**:
   - agent 档：检查 frontmatter `tools` 与正文提及一致性（现行规则）。
   - skill 档：若声明 `allowed-tools`，检查正文/流程中实际使用的工具是否被白名单覆盖（正文提及但未列入 = WARN）；未声明 `allowed-tools` 不报缺失。

5. **description 一致性**: 两档通用（现行规则）。
```

### 3.4 扫描范围说明微调

```md
## 扫描范围
- `/home/terry/.zcode/agents/*.md`（排除 `*.mjs`、`*.sh`、`*.json`、`README*`）→ agent 档
- `/home/terry/.zcode/skills/**/SKILL.md` → skill 档
- 用 Glob 枚举，Read 每个目标文件的 frontmatter 区域（≤30 行）
```

### 3.5 输出模板补充

在缺陷行中增加档位标记，便于审计：

```md
- **[ERROR/WARN]** `文件路径:行号` — [agent|skill] 规则编号 + 缺陷描述
```

## 4. 落地点

| 路径 | 类型 | 本次动作 | 授权后动作 |
|------|------|----------|------------|
| `/home/terry/.zcode/agents/frontmatter-linter.md` | 全局保护区 agent 定义 | **未修改** | 用户明确授权后按 §3 落地 |
| `skills/*/companion/agents/` 中的 frontmatter-linter 副本 | 仓库内潜在副本 | 本次在 repo/worktree 内 `find -name '*frontmatter*linter*'` 未发现副本 | 若未来出现非保护区副本，可同步同一规则，但仍需用户确认范围 |

## 5. 验证建议（授权落地后）

1. 对 `~/.zcode/skills/**/SKILL.md` 抽样包含“仅 name+description”与“含 allowed-tools/model”两类样本，确认前者不再误报 R1。
2. 对 `~/.zcode/agents/*.md` 抽样确认 agent 档 R1 仍严格（缺 model/tools 继续 ERROR）。
3. 对 `allowed-tools` 存在但正文使用未列工具的 skill 样本，确认 R4 报 WARN 而非 ERROR。
4. 记录误报数变化（落地前 21 误报基线 → 落地后应清零或仅剩真实缺陷）。

## 6. 风险与边界

- 不放宽 agent 档契约；agent 仍必须 `name/description/model/tools`。
- skill 档 `model` 若存在仍按 R3 校验，避免“可选=不校验”造成格式漂移。
- 本提案只定义 lint 规则分档，不修改任何 skill/agent 文件内容。
