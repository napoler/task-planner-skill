# P2-S4 任务书: image-review + ui-quality-review + release-review（task-v100,末批）

任务: 在 worktree 内按 S1 范式新建最后 3 个领域质量审核技能：`review-library/image-review/SKILL.md`、`review-library/ui-quality-review/SKILL.md`、`review-library/release-review/SKILL.md`。完成后池内恰 10 个。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/（只读;progress.md 禁写）

## 范式源（第一步必读）
/mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library/skills/task-planner/review-library/general-review/SKILL.md（S1 范式）+ 可参照 content-quality-review/SKILL.md（S3 交付）

## 三技能领域内容要求（每文件 50-70 行,清单 ≥10 条具体检查项）
### 1. image-review（图片质量审查——用户点名场景）
- name: image-review;description: 图片质量审查技能（兜底池）——截图/设计图/AI 生成图/配图…
- 清单领域点: 清晰度与分辨率（模糊/伪影/压缩噪声检测方法）/构图与主体突出/文字可读性（图内文字大小与对比度）/色彩与对比度（含色盲可访问性）/尺寸与宽高比合规（用途场景匹配）/格式与压缩率合理（PNG/JPG/WebP 选型）/与上下文内容匹配度（图文一致）/品牌一致性（色调/标志规范,如适用）/版权与水印面/alt 文本与元数据完备
- 证据要求注明: 图片审查证据=审查者实际查看图片（Read 图片文件/渲染预览）+逐项清单结论,禁未查看即下结论（Rule 43.1）
### 2. ui-quality-review（UI/前端质量审查）
- name: ui-quality-review;description: UI/前端质量审查技能（兜底池）——页面/组件/交互流程…
- 清单领域点: 布局完整性（错位/溢出/截断）/响应式表现（多断点）/交互反馈（hover/loading/错误态）/可访问性（键盘导航/对比度/语义标签）/文案一致性（按钮/提示语统一）/加载性能感知（骨架屏/懒加载）/空态与异常态设计/浏览器兼容面/视觉规范一致性（间距/字号/色板）/关键路径可用性实测
### 3. release-review（部署/发布质量审查）
- name: release-review;description: 部署/发布质量审查技能（兜底池）——上线前/迁移/回滚预案…
- 清单领域点: 发布清单完整（变更面枚举与 scope 对照）/回滚预案可执行（步骤+验证点）/配置与环境变量核对/数据库迁移安全性（可回滚/备份点）/依赖服务与版本矩阵/灰度与影响面控制/监控告警就位（关键指标）/发布窗口与通知/部署后冒烟验证清单/权限与凭据面复查

## 共同要求
- 来源注释行 N=8/9/10（按池内序,末批注明「兜底池建成」于 release-review 注释行）
- 触发条件段含 Rule 42.2 四级检测第④层+任务类型匹配;证据要求段引「Rule 43.1」;输出合约 APPROVED/CHANGES_REQUESTED+P0-P2 分级（release 类可注明回滚预案缺失=P0）
- 禁「1-4x」越界数字字面;禁动三文件外任何文件

## acceptance: 验收标准
1) 3 文件各存在且 50-70 行;四要素标题各 ≥1;清单 `- [ ]` ≥10
2) frontmatter name 三值互异且=目录名
3) `ls review-library/ | wc -l`=10（池建成）
4) 三文件「1-4x」越界字面零命中
5) 10 个 frontmatter name 全表输出（去重计数=10）
6) `git -C <wt> status --short` 仅 review-library/ 下新增 untracked

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/subagent-state/04-exec-p2s4.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S4
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要（含 10 name 全表）
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
