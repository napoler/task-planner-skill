<!-- subagent_dispatch.md — Agent() 派发 prompt 模板(Rule 22.4)
使用方式:在主进程脚本中读本模板,填七字段,作为 Agent() 的 prompt 参数传入
禁止:省略任何必填字段;字段值使用占位符 {placeholder} 形式,调用方替换 -->

# Subagent Dispatch Prompt

## 1. 目标
{goal_one_sentence}

## 2. 输入
- 绝对路径:
  - {path_1}
  - {path_2}
- findings.md 相关摘要(≤10 行):
  ```
  {findings_excerpt}
  ```
- 上下文依赖:{context_dependencies}

## 3. 验收标准(2-5 条可观察证据)
- [ ] {acceptance_1}
- [ ] {acceptance_2}
- [ ] {acceptance_3}
- [ ] {acceptance_4}(可选)

## 4. Scope 禁改清单
- 禁止修改:{forbidden_path_1}, {forbidden_path_2}
- 禁止操作:{forbidden_op_1}, {forbidden_op_2}

## 5. 工作路径
- worktree 绝对路径(若在 worktree 中):{worktree_abs_path}
- 否则 cwd:{cwd}
- 注意:不要切换 CWD,使用绝对路径操作文件

## 6. 时长预算
- 任务类型:{type} → 超时阈值:{timeout_minutes} 分钟
- 超过阈值:立即返回 partial,报告未完成部分

## 7. 返回格式(强制)
```
[done|partial|failed|timeout]
结论摘要(≤3 行):{conclusion}
证据(file:line):{evidence}
置信度:HIGH|MED|LOW
未完成/受阻点(若有):{blockers}
```

**返回前必做**:
1. Read 实际产出文件确认变更落盘
2. 列出所有修改的文件路径(用于主进程登记)
3. 若 failed:写明失败原因 + 已尝试的方案(供主进程决策改派/降档)
