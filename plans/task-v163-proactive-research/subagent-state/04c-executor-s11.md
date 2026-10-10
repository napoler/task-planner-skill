# subagent-state: 04c-executor-s11

- **status**: done
- **S-unit**: 模板生成判定条目落盘（S11 — template-guide.md §2.6 + template-mapping.md Rule 75 注记）
- **时间**: 2026-10-10
- **需求锚（Rule 51.1a）**: R8「模板生成技能中补充一个条目，判断生成的模板是否需要添加调研」

## 任务范围
在 worktree 的 plan-template-kit 两文件落盘「新模板调研需求判定条目」：
1. `skills/plan-template-kit/references/template-guide.md` 在 §2.5 后插入 §2.6（13 行）
2. `skills/plan-template-kit/references/template-mapping.md` 在 §九 区块末尾追加 Rule 75 注记行（1 行）
纯增量，禁改既有内容；禁 git；禁网络。

## 执行步骤与证据

### step 1/4 Read 确认插入锚
- template-guide.md: §2.5 内容 :89-90，空行 :91，`---` :92，`## 三` :94 → 插入点 = :91 后 / :92 前（section 二内）
- template-mapping.md: blockquote :293-:299，空行 :300，`## §十` :301 → 插入点 = :299 后 / :300 前

### step 2/4 插入 §2.6
- 目标文件: `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/plan-template-kit/references/template-guide.md`
- 定向 Edit：在 §2.5「差异」行后、`---` 前插入 §2.6 三态判定表
- 新 heading 落位 :92

### step 3/4 插入 Rule 75 注记
- 目标文件: `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/plan-template-kit/references/template-mapping.md`
- 定向 Edit：在 §九 blockquote 末行（:299）后、`## §十` 前追加 `> **Rule 75 注记（task-v163）**...`
- 新注记落位 :300

### step 4/4 检查点 + findings 追加
- 本文件 + findings.md 追加 `#### [sub:04c-executor] 模板生成判定条目落盘`

## 验证证据（第一手命令输出）
- `grep -n "2.6 新模板调研需求判定条目\|Rule 75.6" template-guide.md` → `92:### 2.6 新模板调研需求判定条目（Rule 75.6 — task-v163）`
- `grep -n "research-type | 必需" template-guide.md` → `98:| research-type | 必需（NET-RESEARCH） | 调研类任务默认需网络调研 |`
- `grep -n "Rule 75 注记（task-v163）" template-mapping.md` → `300:> **Rule 75 注记（task-v163）**：...`
- 既有锚复核: `## §十 工具选择映射` :302（原 :301，+1 平移）；`## 三、引用方式` :107（原 :94，+13 平移）；§2.5 :87 不变
- 行数自洽: template-guide.md 316（§2.5→§三 由 7 行间距扩为 20 行，= +13）；template-mapping.md 317（§十 +1 平移，= +1）
- md5 基线（scope 禁 git，以定向 Edit + Read/grep 复核替代 diff）:
  - template-guide.md `6e03e33f06e94942151bda7220f1891a`
  - template-mapping.md `92eaf2cce26bbc67e785583ba58f29a5`

## 结论
template-guide.md §2.6 与 template-mapping.md Rule 75 注记均落盘；§2.5/§三/§九/§十 等既有锚仅行号平移、内容零改动；diff 仅追加（guide +13 行，mapping +1 行）。验收 3/3 pass。

## 验收
- 验收1 template-guide.md §2.6 grep 命中: PASS
- 验收2 template-mapping.md Rule 75 注记 grep 命中: PASS
- 验收3 既有内容零改动（diff 仅追加）: PASS
- 合计 3/3 pass
