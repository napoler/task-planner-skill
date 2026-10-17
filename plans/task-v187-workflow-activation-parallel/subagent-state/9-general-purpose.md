# [sub:S10-general-purpose] S10 重派检查点（22.3 换道，pg-w2）
worktree=/home/terry/task-planner-skill-worktrees/task-v187-workflow-activation-parallel/skills/plan-template-kit/references/

- 步骤1 完成: findings §S4 CA-10 蓝本已读（findings:91 + :76 40.4 EVOLVED 条款）——镜像语义=「命中 39.8 激活条件→登记 CreateWorkflow 路由并执行期按 39.8 三件套主动创建；未命中→Rule 21.4 声明制调度」
- 步骤2 完成: grep 定位 40.4 语义镜像行=3 处（「建议 CreateWorkflow」精确 grep 命中 3/3，均在 40.4 语境，无非 40.4 残留）:
  * template-guide.md:254（- workflow 编排判定行 Rule 40.4）→ 已改
  * template-mapping.md:312（代码组行 编排判定倾向列 尾部）→ 已改
  * template-mapping.md:321（映射使用规则 ② 段）→ 已改
- 步骤3 验证:
  * grep -c "39\.8" 合计=3（guide=1, mapping=2）≥2 ✓
  * 「建议 CreateWorkflow」guide=0 / mapping=0（40.4 语境全清，无未改项）✓
  * git diff -U0=6 行（3 ins/3 del）=替换行数；两文件其余行零变化 ✓（git diff --stat: guide 2+-, mapping 4+--=3 ins/3 del）
- 步骤4 完成: findings 已追加 `#### [sub:S10-general] S10 重派执行记录`（段末，禁改既有=仅插入不删改）

状态: done（S10 全部 4 步完成，2026-10-18，task-v187 pg-w2）
