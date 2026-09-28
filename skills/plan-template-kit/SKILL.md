---
name: plan-template-kit
description: 计划模板选型/定制/沉淀知识库。主路由：task-planner 在 Rule 16（选模板）与 Rule 34（沉淀）时显式 Skill("plan-template-kit") 调用；用户直呼「计划模板」「加任务类型」「模板定制/项目级覆盖」时也可触发。排除：执行期创建计划/初始化会话请用 task-planner。
---

# Plan Template Kit

卫星技能：纯知识层——沉淀 task-planner 模板体系的选型决策树、定制契约与路径规范；机械层（variant 库、init-session.sh、check-template-type.sh、attest 门控）全部留守 task-planner。

## 何时读哪份 reference

- **选型/定制/加类型** → `references/template-mapping.md`（唯一选型权威源）：§一 分流决策树 + 类型清单 / §六 模板路径速查表 / §七 定制红线与互斥关系 / §八 验证命令 / §九 机制适用性矩阵（Rule 37 权威源，知识储备契约见 template-guide §2.4）
- **模板优先级/项目级覆盖/路径规范** → `references/template-guide.md`：双层优先级（项目级 `.claude|zcode/plan-templates` 覆盖内置）、脚本契约标记（§四）、定制示例（§五）、路径引用规范（§七）

## 与机械层（task-planner）的关系

- 只读引用目录 `../task-planner/templates/variant/`（仓内相对路径随部署位走；SKILL 内引用遵循 template-guide §七：优先 `${TASK_PLANNER_ROOT}` 绝对路径）
- 本技能**不执行**任何机械动作：模板查找/复制/白名单=init-session.sh，类型门控=check-template-type.sh + attest，均为 task-planner 脚本职责
- 白名单动态派生自 variant/ 目录（16 类），本技能两份 reference 只描述、不改机械行为

## 沉淀指针（Rule 34）

- Rule 34.3 触发条件命中（同类任务第 2 次 / 新类型可泛化 / 用户点名）→ 按 34.4 流程新建 variant 模板后，执行 **34.2 四点同步**：① template-mapping.md 决策树与清单 ② plan-writer 映射表 ③ task-planner SKILL.md 模板节 ④ template-guide.md 变体表与计数
- 一致性由 task-planner `scripts/selftest-template-lifecycle.sh` 守护；沉淀动作登记计划 Decisions Made 表

## 使用入口（两种）

1. 主路由：task-planner Rule 16 选模板 / Rule 34 沉淀时显式 `Skill(skill="plan-template-kit")`
2. 直接触发：用户问「计划模板怎么选」「加一种任务类型」「项目级模板定制」时加载

## 边界铁律

- 执行期创建/初始化计划 = task-planner 职责，本技能不承接
- 只读路由与知识描述，不修改 task-planner 侧文件；发现两份 reference 与机械层漂移 → 报告，不在本技能内修
