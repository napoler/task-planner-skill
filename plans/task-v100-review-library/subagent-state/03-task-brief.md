# P2-S3 任务书: content-quality-review + documentation-review + data-quality-review（task-v100）

任务: 在 worktree 内按 S1 范式新建 3 个领域质量审核技能：`review-library/content-quality-review/SKILL.md`、`review-library/documentation-review/SKILL.md`、`review-library/data-quality-review/SKILL.md`。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/（只读）
- progress.md: 同目录（子代理禁写）

## 范式源（第一步必读）
/mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library/skills/task-planner/review-library/general-review/SKILL.md（S1 范式标杆,结构全部对标同构）+ 可参照 code-quality-review/SKILL.md（S2 已交付,领域化写法参照）

## 三技能领域内容要求（每文件 50-70 行,清单 ≥10 条具体检查项）
### 1. content-quality-review（内容/撰写质量审查——用户点名场景）
- name: content-quality-review;description: 内容与撰写质量审查技能（兜底池）——文章/文案/发布内容…
- 清单领域点: 事实准确性（每条事实主张有出处）/结构逻辑（论点-论据-结论链）/受众与语调匹配/标题与导语质量/冗余与啰嗦（删 30% 不损义）/AI 腔与套话检测/错别字与标点/格式排版一致性/原创性与抄袭面/SEO 与可发现性（如适用）/示例与数据支撑
### 2. documentation-review（文档质量审查）
- name: documentation-review;description: 文档质量审查技能（兜底池）——README/API 文档/操作手册…
- 清单领域点: 准确性（示例命令/路径/参数实跑可复现）/完整性（安装-配置-使用-故障排除闭环）/结构导航（目录/锚点）/版本一致性（与代码行为同步）/受众分级（入门 vs 参考）/代码示例可复制执行/术语一致性/链接有效性/更新日期与变更记录/可访问性（alt 文本/表格规范）
### 3. data-quality-review（数据质量审查）
- name: data-quality-review;description: 数据质量审查技能（兜底池）——数据集/管道产出/迁移结果…
- 清单领域点: 完整性（行数/空值率/必填字段）/准确性（抽样比对真源）/一致性（跨表/跨文件主键与枚举）/时效性（新鲜度/时间戳）/唯一性（重复行检测）/格式合规（类型/编码/Schema 漂移）/异常值与离群点/血缘与转换可追溯/抽样验证记录/隐私合规（PII 面检查）

## 共同要求
- 来源注释行 N=5/6/7（按池内序）;触发条件段含 Rule 42.2 四级检测第④层+任务类型匹配说明;证据要求段引「Rule 43.1」;输出合约 APPROVED/CHANGES_REQUESTED+P0-P2 分级（content 类可注明事实错误=P0）
- 禁「1-4x」越界数字字面;禁动三文件外任何文件

## acceptance: 验收标准
1) 3 文件各存在且 50-70 行;四要素标题各 ≥1;清单 `- [ ]` ≥10（领域具体化）
2) frontmatter name 三值互异且=目录名
3) `ls review-library/ | wc -l`=7（general+3+3）
4) 三文件「1-4x」越界字面零命中
5) `git -C <wt> status --short` 仅 review-library/ 下新增 untracked
6) 来源注释行 tail -1 实测 N=5/6/7

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/subagent-state/03-exec-p2s3.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S3
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
