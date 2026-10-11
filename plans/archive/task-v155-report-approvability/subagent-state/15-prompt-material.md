# S15 材料包：registry 登记 + WARN 翻硬档 + 计数钉核查

## ① registry.tsv 登记行（tab 分隔 4 列；先 `head -3 scripts/selftest-registry.tsv` 对齐既有行形态再追加）

列1 script: `selftest-report-reviewability.sh`
列2 domain: `Rule 70 用户呈报可审批性纪律守护 RRV-01..13（task-v155）`
列3 trigger_scenarios: `Rule 70 四要素条文锚(70.1-70.6)/SKILL 接线锚≥4+合规清单 C46/13 触点文件 Rule 70 引用/registry 自登记/config 零新键/report-lint 段锚`
列4 dep_anchors: `references/critical-rules.md;SKILL.md;reference.md;references/worktree-isolation.md;references/batch-quality-gate.md;templates/task_plan.md;templates/batch_report.md;templates/variant/image-type.md;templates/variant/multiview-ref-type.md;review-library/general-review/SKILL.md;review-library/alignment-review/SKILL.md;review-library/code-quality-review/SKILL.md;companion/agents/article-batch-publisher.md;companion/agents/article-field-fixer.md;companion/agents/plan-writer.md;scripts/check-complete.sh;config.json`

## ② selftest-report-reviewability.sh WARN→FAIL 翻档

- `grep -n "RRVV_REGISTRY_STRICT\|WARN" scripts/selftest-report-reviewability.sh` 定位 RRV-06/07 的 WARN 豁免逻辑（S12 实现时登记行与 lint 段尚未落位，故设 WARN 宽限；现两者均已真实落位）。
- 改为常驻 FAIL 档：registry 子项与 report-lint 子项缺失即 FAIL；可保留 env 分支但默认必须 FAIL。注释更新为「登记行与 lint 段已落位（S14/S15），2026-10-10 翻硬档」。
- 改后自跑 `bash skills/task-planner/scripts/selftest-report-reviewability.sh` 必须 exit 0 且 Total 行 WARN=0。

## ③ 计数钉核查（v150 判例：新增 selftest 必查全仓计数钉）

- `grep -rn "64" scripts/*.sh SKILL.md | grep -iE "selftest|脚本|count|total" | grep -vE "RRV|Rule 64|64\.[0-9]|task-v148"` 排查把 selftest 脚本总数钉死为 64 的静态断言（新增后应为 65：`ls scripts/selftest-*.sh | wc -l`）。
- 发现钉死的：改为 65 或动态计数（`$(ls "$SCRIPT_DIR"/selftest-*.sh | wc -l)` 形态，附 What+Why 注释说明为何动态化）。
- 未发现：在 findings 追加段如实登记「无静态计数钉，动态口径」。

## 验收（对应任务书 §3）
registry 新行 tab 列数=4；selftest 自跑 exit 0 且 WARN=0；RRVV_REGISTRY_STRICT=1 与普通跑一致；计数钉结论（修/未发现）登记 findings；改动文件 diff 删除行仅限 WARN 逻辑改造涉及行。
