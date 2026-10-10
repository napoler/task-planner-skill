# S8 材料包：DG-08..12 断言规格 + registry 登记行 + DG-06 翻档

> 目标：在 worktree 内既有 `skills/task-planner/scripts/selftest-decision-grading.sh` 追加 DG-08..12（触点分组锚），registry.tsv 登记行，DG-06 翻常驻 FAIL 档。技能根 = `$(cd "$(dirname "$0")/.." && pwd)`。

## DG 断言（追加在既有断言之后、Total 汇总之前）
- DG-08 引用面组：`references/critical-rules.md` grep -c "Rule 72" ≥5（FAIL 档）
- DG-09 模板面组：`templates/variant/image-type.md` grep -c "Rule 72" ≥1 且 `templates/variant/multiview-ref-type.md` grep -c "Rule 72" ≥1（FAIL 档）
- DG-10 管线面组：`companion/agents/article-batch-publisher.md` grep -c "Rule 72" ≥2 且 `companion/agents/article-field-fixer.md` grep -c "Rule 72" ≥1（FAIL 档）
- DG-11 SKILL 接线组：`SKILL.md` grep -c "Rule 72" ≥5 且 C49 行含「A 级」「C 级」（FAIL 档）
- DG-12 预留骨架：`TODO(DG-13): 行为面决策分级 fixture 回归（执行期启用）` 注释行存在即 PASS（占位断言）

## registry.tsv 登记行（tab 分隔 4 列；先 `head -3 scripts/selftest-registry.tsv` 对齐既有行形态再追加）
- 列1 script: `selftest-decision-grading.sh`
- 列2 domain: `Rule 72 决策分级与用户打断纪律守护 DG-01..12（task-v160）`
- 列3 trigger_scenarios: `Rule 72 三级表条文锚(72.1-72.6)/SKILL 接线锚≥5+合规清单 C49/6 触点文件 Rule 72 引用/registry 自登记/config 零新键`
- 列4 dep_anchors: `references/critical-rules.md;SKILL.md;templates/variant/image-type.md;templates/variant/multiview-ref-type.md;companion/agents/article-batch-publisher.md;companion/agents/article-field-fixer.md;config.json`

## DG-06 翻档
- 现状：DG-06（registry 登记行）为 WARN 档默认放行（S7 实现时 registry 行尚未落位）。
- 修法：registry 行已真实落位 → 改为常驻 FAIL 档（删除 env 升级分支或保留 env 但默认 FAIL），注释更新为「登记行已落位（S8），2026-10-10 翻硬档」。

## 验收（对应任务书 §3）
- `bash skills/task-planner/scripts/selftest-decision-grading.sh` exit 0，输出含 DG-01..12 全编号与 Total 行（WARN=0）
- registry.tsv 新行 tab 列数=4（awk -F'\t' 抽行 print NF =4）
- `DG_REGISTRY_STRICT=1 bash 同脚本` 与普通跑输出一致
- 两文件 git diff 全部为新增行（既有断言零改动）
