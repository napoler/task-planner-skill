# s6 ca4-editspec（task-v172 CA-4 只读子代理 checkpoint 主进程代建豁免）— 供 code-assistant 精确执行

worktree 根目录：`/home/terry/task-planner-skill-worktrees/task-v172-ca4`
背景：R5/RC5——只读子代理（如 Explore，tools 无 Write）无法自行落盘 22.8.1 指定的 checkpoint 文件，契约 §8「检查点落盘」对其不可满足→主进程被迫代写、返回侧易被误判。本轮把「主进程代建」显式化为 22.8.6 条款 + 机器守护。逐条 Edit，old_string 精确匹配（先 Read 目标文件确认）。

---

## E1 文件：skills/task-dispatch/references/critical-rules-dispatch.md

在 22.8.5 行（内容以「22.8.5 **返回缺失兜底**」开头）之后、22.9 行之前插入一条新子条款。

old_string（22.8.5 整行 + 其后空行 + 22.9 行首，用于定位插入点）:
```
22.8.5 **返回缺失兜底**:主进程 30s Read 产出复核(22.5)时,若返回消息缺失但检查点 status: done,以检查点「最终结论」段为准完成回填
```
（若该行实际后紧跟 22.9，则把 old_string 扩到含 22.9 行首，在其间插入。）

new_string（22.8.5 原文保留 + 追加 22.8.6）:
```
22.8.5 **返回缺失兜底**:主进程 30s Read 产出复核(22.5)时,若返回消息缺失但检查点 status: done,以检查点「最终结论」段为准完成回填
22.8.6 **只读型 Executor checkpoint 主进程代建豁免**（[task-v172 CA-4]）:被派发子代理的 tools 不含 Write（如 Explore 等只读型）时,22.8.1 的检查点文件允许**由主进程当场代建**——子代理返回 `checkpoint:` 字段填 `绝对路径（待主进程代建）` 且把「最终结论」段全文附进返回消息;主进程在同一动作循环内按该路径 Write 出检查点文件（内容=返回消息「最终结论」段 8 字段块）并在 progress.md 记一行 `[主进程] 代写 <path>`,代建完成即视为 T5 满足、该 S-unit 三证据齐备;未代建=按 22.8.4「无进度」处理（断点重试以返回消息内容为准）。本豁免只免除子代理侧写盘动作,不减 checkpoint 内容义务（能写的 T1-T4 仍按 22.8.2 执行;全只读型=里程碑并入返回消息「最终结论」段）。
```
（措辞可微调,但必须含「22.8.6」「主进程代建」「tools 不含 Write」「待主进程代建」四个字面,供 selftest grep。）

## E2 文件：skills/task-planner/scripts/selftest-subagent-return.sh

Read 全文,在其断言区末尾（末条 ok/bad 之后、Total 汇总之前）新增 1 条 CA-4 守护断言：
- 断言 critical-rules-dispatch.md（该脚本已有 $CR 变量指向它）含 4 个字面：`22.8.6`、`主进程代建`、`待主进程代建`、`tools 不含 Write`：
```
if grep -q '22.8.6' "$CR" && grep -q '主进程代建' "$CR" && grep -q 'tools 不含 Write' "$CR"; then
  ok <NN> "CA-4: critical-rules-dispatch.md 含 22.8.6 只读型 checkpoint 主进程代建豁免（四锚全在位）"
else
  bad <NN> "CA-4: critical-rules-dispatch.md 缺 22.8.6 代建豁免（grep 命中不足）"
fi
```
- 同步把该脚本头部注释的断言计数（如「N 断言」）+1（若头部有计数声明）；若该脚本 Total 断言数被 selftest-registry.tsv 或他脚本钉住,一并核对（grep 'selftest-subagent-return' 的 registry 行与相关断言数）。

## E3 文件：skills/task-dispatch/scripts/check-subagent-return.sh（可选,低风险）

Read 全文,在其自检 fixture 区（现有 f1/f2/f3 之后）新增 1 个 fixture：`checkpoint:` 字段值带中文注释「（待主进程代建）」的返回块应仍判 PASS（证明 22.8.6 的返回字段值注记不触发判据二 VIOLATION）：
```
f="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md（待主进程代建）' 'findings_written: none' 'blockers: none' 'confidence: HIGH')"
```
（若该脚本自检结构不同,follow 其既有 fixture 范式,只保证「带注记的 checkpoint 值 → PASS」这条被机器验证。）

---

## 完成后自检（命令原文+结果写入检查点）
1. `cd /home/terry/task-planner-skill-worktrees/task-v172-ca4 && bash skills/task-planner/scripts/selftest-subagent-return.sh 2>&1 | tail -4`（期望 FAIL=0）
2. `bash skills/task-dispatch/scripts/check-subagent-return.sh 2>&1 | tail -4`（若其自带自检;期望 PASS/FAIL=0）
3. `bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -3`（期望 Total: 77 PASS=77 FAIL=0）
4. `bash skills/task-dispatch/scripts/run-selftests.sh 2>&1 | tail -3`（若存在 task-dispatch 的 run-selftests;否则 ls 该目录找 selftest 入口逐一跑,期望 FAIL=0）
5. `grep -n '22.8.6' skills/task-dispatch/references/critical-rules-dispatch.md`（确认 E1 落盘）
任一 FAIL：逐个定位,把新失败+根因写入检查点「错误与受阻」段,禁止改断言以外的东西
