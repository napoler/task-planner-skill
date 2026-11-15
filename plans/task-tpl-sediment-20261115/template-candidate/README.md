# template-candidate 登记（task-tpl-sediment-20261115）

| 模板名 | 适用类型 | 来源任务 | 登记日期 | G1 结构 lint | G2 render 冒烟 | G3 独立审查 | G4 官方级联 | 状态 |
|--------|----------|----------|----------|--------------|----------------|-------------|-------------|------|
| `rule-clause-cascade-type.md` | 本仓规则/条款级联修订（规则增款、子条插段、索引/纪元/卫星计数与多文件级联同步） | task-tpl-sediment-20261115 (P2-S6 dogfood) | 2026-11-15 | PASS（见 G1 自检） | 待审（Phase 3） | 待审（Phase 3） | N/A（项目级候选，免 G4） | 待审 |

## G1 自检记录（本次产出）
- 文件存在：`plans/task-tpl-sediment-20261115/template-candidate/rule-clause-cascade-type.md`
- 行数：≤100（`wc -l` 复核）
- 机读头：首行 `<!-- template_type: rule-clause-cascade -->`（类型标识=文件名去 `-type.md` 后缀，init-session.sh 派生口径；首版误写 `rule-clause-cascade-type` 双后缀致 G2 首跑选型失败，已统一）
- 五结构块：Goal / VC 表 / Phase 骨架 / 执行范围限制 / 必要知识储备 均存在
- 命名查重：不与 worktree `templates/variant/` 既有 30 类同名（选定类型标识 `rule-clause-cascade`，文件名 `rule-clause-cascade-type.md`）
- VC-3 Verify command 修正：原引用不存在的 `scripts/run-selftests.sh` → 等价聚合口径（selftest-*.sh 循环）

## 备注
- 候选暂存于计划目录，未写入官方 `templates/variant/`；未过 G2/G3 不得入库。
