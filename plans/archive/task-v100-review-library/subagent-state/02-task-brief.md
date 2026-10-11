# P2-S2 任务书: code-quality-review + test-quality-review + security-review（task-v100）

任务: 在 worktree 内按 S1 范式新建 3 个领域质量审核技能：`review-library/code-quality-review/SKILL.md`、`review-library/test-quality-review/SKILL.md`、`review-library/security-review/SKILL.md`。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/task_plan.md（只读: Goal 区+VC-1/VC-2）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/progress.md（子代理禁写）

## 范式源（第一步必读）
/mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library/skills/task-planner/review-library/general-review/SKILL.md（S1 范式标杆——frontmatter 形态/触发条件段/审查清单格式/证据要求引 Rule 43.1/输出合约/来源注释行,全部对标同构,仅领域内容替换）

## 三技能领域内容要求（每文件 50-70 行,清单 ≥10 条具体可执行检查项,禁空洞套话）
### 1. code-quality-review（代码质量审查）
- name: code-quality-review;description: 代码质量审查技能（兜底池）——…
- 清单领域点: 正确性与边界条件/错误处理（禁裸 except/静默吞错）/命名与可读性/重复代码与死代码/注释与 docstring/输入校验/并发与资源泄漏/依赖与版本/与既有代码风格一致性/测试覆盖配套
### 2. test-quality-review（测试质量审查）
- name: test-quality-review;description: 测试质量审查技能（兜底池）——…
- 清单领域点: 断言有效性（非恒真/覆盖关键路径）/边界与异常用例/测试隔离性（无相互依赖）/确定性（无 flaky：随机/时序/外部依赖）/夹具与数据管理/覆盖缺口识别/测试命名与可读性/ mock 使用合理性/失败信息可诊断性/回归防护
### 3. security-review（安全审查）
- name: security-review;description: 安全审查技能（兜底池）——…
- 清单领域点: 注入面（SQL/命令/路径拼接）/密钥与凭据硬编码/输入验证与转义/权限与最小授权/敏感数据日志泄漏/依赖漏洞面/不安全反序列化/文件操作路径穿越/网络通信加密/审计留痕
- security 的 P0 定义可注明：注入/密钥泄漏类问题一律 P0

## 共同要求
- 每文件来源注释行: `<!-- task-v100-review-library 兜底池成员 N/10;Rule 42.2 第④层消费;范式对标 general-review -->`（N=2/3/4 按池内序）
- 触发条件段说明本领域何时命中（Rule 42.2 四级检测第④层+任务类型匹配）
- 证据要求段引「Rule 43.1」;输出合约 APPROVED/CHANGES_REQUESTED+P0-P2 分级
- 禁「1-4x」越界数字字面;禁动三文件外任何文件

## acceptance: 验收标准
1) 3 文件各存在且 50-70 行
2) 每文件四要素标题（## 触发条件/## 审查清单/## 证据要求/## 输出合约）各 ≥1
3) 每文件 `- [ ]` 清单条目 ≥10（领域具体化,抽 3 条无套话）
4) frontmatter name 三值互异且与目录名一致
5) `ls review-library/ | wc -l`=4（general+3）
6) `git -C <wt> status --short` 仅 review-library/ 下 3 个新 untracked
7) 三文件无「1-4x」越界字面（grep -nE '1-4[0-9]' 零命中）

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/subagent-state/02-exec-p2s2.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
