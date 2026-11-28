# EX-3 C 簇实施报告（规则标题归一 + verify.sh hooks 对账盲区）

## 1. 归一映射表（原形态→新形态×20）
| # | 行 | 原形态 | 新形态 |
|---|---:|---|---|
| 1 | 9 | `### 1 先规划，再执行` | `### Rule 1 先规划，再执行` |
| 2 | 12 | `### 2 PreToolUse 强制阻断` | `### Rule 2 PreToolUse 强制阻断` |
| 3 | 15 | `### 3 双操作后立即保存` | `### Rule 3 双操作后立即保存` |
| 4 | 18 | `### 5 Phase 完成后更新` | `### Rule 5 Phase 完成后更新` |
| 5 | 21 | `### 19 3-File 落盘强制...` | `### Rule 19 3-File 落盘强制...` |
| 6 | 33 | `### 20 计划注入与防篡改...` | `### Rule 20 计划注入与防篡改...` |
| 7 | 54 | `### 26 质量优先于速度门控...` | `### Rule 26 质量优先于速度门控...` |
| 8 | 84 | `### 51 需求覆盖与完成声称门控...` | `### Rule 51 需求覆盖与完成声称门控...` |
| 9 | 112 | `### 62 四文件罗盘数据流转...` | `### Rule 62 四文件罗盘数据流转...` |
| 10 | 130 | `### 66 goal 单元固化...` | `### Rule 66 goal 单元固化...` |
| 11 | 144 | `## Rule 80（用户会话逐字记录...）` | `### Rule 80（用户会话逐字记录...）` |
| 12 | 166 | `### 81 计划完成后归档纪律...` | `### Rule 81 计划完成后归档纪律...` |
| 13 | 180 | `### 82 技能专业化分层纪律...` | `### Rule 82 技能专业化分层纪律...` |
| 14 | 188 | `### 83 通道不可用快速失败...` | `### Rule 83 通道不可用快速失败...` |
| 15 | 198 | `### 109 独立审计门...` | `### Rule 109 独立审计门...` |
| 16 | 235 | `### 111 进度产出基线防倒退...` | `### Rule 111 进度产出基线防倒退...` |
| 17 | 250 | `### 112 检索排除清单纪律...` | `### Rule 112 检索排除清单纪律...` |
| 18 | 265 | `### 113 输出示例契约...` | `### Rule 113 输出示例契约...` |
| 19 | 308 | `### 116 惰性文件引入规范...` | `### Rule 116 惰性文件引入规范...` |
| 20 | 328 | `### 117 跨任务共用未解决问题登记...` | `### Rule 117 跨任务共用未解决问题登记...` |

附：非核心裸数字标题 115/118/119 归一为 `#### Rule N ...`（消除 `### <裸数字>` 残留，不计入核心 `^### Rule`=20）。

## 2. 锚同改清单
- `skills/task-planner/references/critical-rules.md:186` 计数钉：`^### ` → `^### Rule`，并附 2026-11-28 归一注释（:184 核心清单行未动）。
- `skills/task-planner/scripts/selftest-four-file-dataflow.sh`：FF-01 描述/断言 `^### 62 ` → `^### Rule 62 `；FF16 awk 边界 `^### 62 / ^### ` → `^### Rule 62 / ^### Rule `，附 2026-11-28 注释。
- 传播面 grep（scripts/lib）旧形态 `### 62 | ## Rule 80 | ### 83` 命中仅 selftest-four-file-dataflow.sh，上述已同改；selftest-rule-heading.sh 注释含 `## Rule 80` 为负例描述，非 critical-rules 标题锚。

## 3. verify.sh 改动（DEF-05）
- `lib/verify.sh:26` 注释：`全量副本模式下 frontmatter hooks: 块 N/A` → `全量副本模式下同样检查 hooks: 块存在性`。
- check 8 OpenCode/Cursor/Continue 分支：删除 full-copy N/A pass；统一检查 `^hooks:`。有 hooks → pass（full-copy 标注 `full-copy deploy`）；无 hooks → fail（full-copy 报 `missing hooks: block in full-copy deploy`，薄壳报原 regenerate 文案）。
- 加 What/Why 注释（2026-11-28 task-skill-fix-defs-20261128 DEF-05）。

## 4. 双 selftest 正负控制实测
| selftest | 正控制 | 负控制 | rc |
|---|---|---|---|
| `selftest-rule-heading.sh` | T01 真实 critical-rules.md：`^### Rule`==20、bare==0、h2==0 PASS | T02 mktemp 注入 `### 99` 裸标题被检出；T03 mktemp `## Rule` h2 被检出；T04 mktemp 删 Rule 117 计数不足被检出 | 0 (4 PASS/0 FAIL) |
| `selftest-verify-hooks.sh` | T00 verify.sh 含 DEF-05 锚且无旧 N/A 文案；T01 full-copy+hooks pass；T03 thin+hooks pass；T05 symlink/full+hooks pass | T02 full-copy 无 hooks fail；T04 thin-shell 无 hooks fail | 0 (6 PASS/0 FAIL) |

## 5. 回归
- `bash -n`：verify.sh / selftest-rule-heading.sh / selftest-verify-hooks.sh → SYNTAX_OK。
- `selftest-four-file-dataflow.sh`（受锚同改影响）：18 PASS / 0 FAIL。
- 标题形态终态：`grep -c '^### Rule '`=20，`grep -cE '^### [0-9]+'`=0，`grep -c '^## Rule '`=0。
