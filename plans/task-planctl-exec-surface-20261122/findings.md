<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-planctl-exec-surface-20261122

- task_id: `task-planctl-exec-surface-20261122`
- 时间: created_at=2026-11-21T20:32:16Z / updated_at=2026-11-21T21:43:17Z

## Requirements
- sess_1d7e33d6 会话中「planctl CLI+JSON 为默认」完全没被使用（plan-state.json 空壳+4 MD 手写）——根因修复：把 CLI 口径落到执行者实际读到的 4 个面
- 修复不破坏既有面：全量回归零新增 FAIL + 四位部署逐位 diff=0
- 行为面真正用起来：tmp 冒烟全链 CLI 流（init→add→render→attest）exit 0 且 MD 为派生视图

## Findings
| id | text | source | tags |
|---|---|---|---|
| F1 | 时间线排除借口：四位部署 mtime 02:38:14-19，sess_1d7e33d6 启动哨兵 03:24:12（plans/.plan_required_side/1d7e33d6*.plan_required）——会话全程跑在新口径磁盘上仍失败 | stat 部署位 + StoryLab/plans/.plan_required_side/ + git log 1732eab=02:32:17 |  |
| F2 | 执行层实证：task-corpus-enforce-001 plan-state.json 空壳（created==updated==2026-11-21T19:57:08Z 全业务数组空），task_plan.md 29KB/findings 16KB/verification 10KB/progress 4KB 全部手写，attest 04:06:47 锁手写 MD | StoryLab/plans/task-corpus-enforce-001/{plan-state.json,.plan-attestation,stat} |  |
| F3 | 根因四条：①posttooluse.sh:267/268/302/330 每次工具调用教 Edit MD，全 hook 链 grep planctl 零命中；②4 模板+29variant 头部契约行仍写「=模型填写面」；③init-session.sh:1090 仅一行输出无下一步指引，task-plan-init.cjs:145/plan-created.cjs:217 同；④attest/check-complete 全读 MD，JSON 空壳全程绿灯 | 源仓+部署位 grep/stat 实测（Explore 双路取证报告 2026-11-22） |  |
| F4 | 第 5 根因（本任务现场挖出）：render 产物结构性过不了 attest——check-plan-dispatch.sh:346-370 要求 task_plan.md 含「## 🎯 Goal 单元表」六列表头锚（goal-id/任务名/目标/完整验证方式/对应 S-unit/状态）+数据行，planctl.py 无该渲染逻辑（仅渲染 Phase Gates 表），75.1 调研区块同样缺失。即：纯 CLI 流即便被遵守也无法通过 attest 锁定，流程闭环断裂 | attest 实测 ✗（2026-11-22 04:35）+ grep planctl.py 零命中 Goal 单元渲染 + check-plan-dispatch.sh:346-370 |  |

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- 时间线排除借口：四位部署 mtime 02:38:14-19，sess_1d7e33d6 启动哨兵 03:24:12（plans/.plan_required_side/1d7e33d6*.plan_required）——会话全程跑在新口径磁盘上仍失败 — stat 部署位 + StoryLab/plans/.plan_required_side/ + git log 1732eab=02:32:17
- 执行层实证：task-corpus-enforce-001 plan-state.json 空壳（created==updated==2026-11-21T19:57:08Z 全业务数组空），task_plan.md 29KB/findings 16KB/verification 10KB/progress 4KB 全部手写，attest 04:06:47 锁手写 MD — StoryLab/plans/task-corpus-enforce-001/{plan-state.json,.plan-attestation,stat}
- 根因四条：①posttooluse.sh:267/268/302/330 每次工具调用教 Edit MD，全 hook 链 grep planctl 零命中；②4 模板+29variant 头部契约行仍写「=模型填写面」；③init-session.sh:1090 仅一行输出无下一步指引，task-plan-init.cjs:145/plan-created.cjs:217 同；④attest/check-complete 全读 MD，JSON 空壳全程绿灯 — 源仓+部署位 grep/stat 实测（Explore 双路取证报告 2026-11-22）
- 第 5 根因（本任务现场挖出）：render 产物结构性过不了 attest——check-plan-dispatch.sh:346-370 要求 task_plan.md 含「## 🎯 Goal 单元表」六列表头锚（goal-id/任务名/目标/完整验证方式/对应 S-unit/状态）+数据行，planctl.py 无该渲染逻辑（仅渲染 Phase Gates 表），75.1 调研区块同样缺失。即：纯 CLI 流即便被遵守也无法通过 attest 锁定，流程闭环断裂 — attest 实测 ✗（2026-11-22 04:35）+ grep planctl.py 零命中 Goal 单元渲染 + check-plan-dispatch.sh:346-370

## Technical Decisions
| Decision | Rationale |
|---|---|
| 修复面=执行者实际读到的 4 个面（init 输出/模板契约行/hook 教学文案/attest 空壳 WARN），不新增任何拦截门 | 用户既定裁决「真正有效的是在模板写入哪一步应该使用 cli 落盘」+两次否决 PreToolUse 硬拦截；取证证明 SKILL.md 散文载体执行者读不赢 hook 注入与模板契约行 |
| hook 仅改教学文案（6 处罗盘提醒+2 处 init 提示+1 处回放头行），节奏提醒/计数器/门机制全部不动 | 此前「hook 不动」为 jsonderive 任务范围控制；本次用户投诉直指方案未被使用，PostToolUse 旧教学是每次工具调用注入的最强反向指令，不对齐则修复大概率再度失效；无任何新增拦截 |
| P4 空壳检测=warn-only 单行输出，不阻断不新增脚本，嵌入既有 attest-plan.sh | 文本优先铁律下机器断言最小化；使「JSON 空壳+MD 手写」复发立即可见而非静默绿灯，且不触碰已否决的拦截方向 |
| render 扩展：新增「## 🎯 Goal 单元表」区块（goals 新增可选字段 name/verify/s_units/status 渲染六列锚）+「🔍 调研需求与检索计划」区块（research_status），schema 同步加可选字段不进 required | JSON 全派生架构下 gate 必需区块必须可由 JSON 派生，否则纯 CLI 流无法过 attest（F4 闭环断裂）；goal 新字段全部可选保存量 validate 兼容 |
| 旧教学清零传播面按 grep 实测扩展：SKILL.md L109/L128/L222 工作流行、references/todo-sync.md S2/S5、examples.md、companion/agents/plan-writer.md 调用方约束、zcode-userpromptsubmit.sh:285 邻近引用提示、check-doc-sync.sh 注释、INSTALL.md 预期输出、CLAUDE.md:48——同类载体一并切 planctl 口径 | 传播面先 grep（判例教训）；SKILL.md L109 每 Phase 工作流与 todo-sync S2/S5 是执行者高频读取面，漏改则旧教学残留在最强载体；plan-cost-guard/billing.md 属他技能范围不动，plans/ 存量档不清理（用户裁决） |
| VC-6 判据路径修正：冒烟产物实际在 /tmp/planctl-smoke-out/plans/task-smoke-001/（init 要求 plans/<task-id>/ 目录结构），原命令少了子目录层级 | 判据冻结后修正=重锁协议（Decisions 登记+render+重跑 attest）；冒烟已实跑全链 exit 0 |
| VC-5 判据口径修正：部署位含 8570 个运行期文件（.history/trash 等），整目录 diff -r 必然误报；改为 git 跟踪 254 文件逐位 cmp | 判据必须匹配真实生产字节（判例：判据 token 匹配真实生产字节）；重锁协议登记 |

## Issues Encountered
| Issue | Resolution |
|---|---|
| （本任务暂无问题记录） |  |

## Resources
- （本任务暂无资源引用）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
## 本任务 tag 倒排引用
- （本任务暂无tag 引用）
