# S6 材料包 — check-dispatch.sh prompt 侧返回格式段结构校验（子代理 Read 本文件后实现）

## 目标文件（worktree 内唯一可写）
/home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/check-dispatch.sh

## 挂点定位（只读参考）
既有逻辑: 脚本约 :120 行附近有 `for item in ... "status:" "acceptance:" "checkpoint:" "subagent-state/"` 的 prompt key 存在性检查循环;后续 :280-/:295 两条成功路径( enforce/warn 分支 )调用 fine_grain_checks 与 serial_slot_check 后 exit 0。

## 实现要求（纯增量,既有函数与逻辑零改动）
在被指定位置新增函数 return_section_check(),并挂入上述两条成功路径的 fine_grain_checks 调用之后( enforce=exit 2 阻断 / warn=stderr 告警 exit 0;无活跃计划 fail-open 语义不变)。函数输入=脚本内既有 prompt 文本变量名(以你 Read 到的实际变量名为准)。

- 判据 A（标题唯一）: prompt 内 `grep -c '^## 返回格式'` 须等于 1;大于 1 即拼接污染（用户实证形态「## 返回格式## 返回格式」标题重复）
- 判据 B（段含四 key）: 自「## 返回格式」标题行起,至下一个 `^## ` 标题行止的区间内,须同时含 `status:` `acceptance:` `checkpoint:` `confidence:` 四个 key;缺任一 = 段被替换成任务清单
- 判据 C（段内禁清单污染）: 同区间内出现 ≥3 行 `^[①②③④⑤⑥]` 或 `^[0-9]+[.、]` 形态序号列表行,且四 key 有缺 = 污染
- 输出: 违规 → stderr `[dispatch-guard] ✗ 返回格式段结构违规: <判据编号>: <详情>`;合规 → stderr `[dispatch-guard] ✓ 返回格式段结构`
- git diff --numstat 须 ≤ +35/-0

## 夹具（随 deliverable 验证,不写进 selftest-dispatch.sh）
- 污染夹具: heredoc 构造最小 prompt,含重复标题「## 返回格式## 返回格式」+三项任务要点清单(条目一 v3.1 23 段新配置摘要表/条目二 style_exempt 统一口径/条目三 合图锚占位清单)→ 跑 check-dispatch.sh 期望非 0 退出且 stderr 含段结构违规提示
- 干净夹具: 自 templates/subagent_dispatch.md §7 取原段落 + 三文件绝对路径 + subagent-state/ 路径构成最小 prompt → 期望 rc 0
- 两夹具命令与输出写回 evidence

## 回归硬约束
- `bash -n` 通过
- `bash skills/task-planner/scripts/selftest-dispatch.sh` 既有断言全 PASS(不得因本增强 FAIL)

## 完成后自跑
污染夹具、干净夹具、bash -n、selftest-dispatch.sh 四条命令,输出写 evidence。
