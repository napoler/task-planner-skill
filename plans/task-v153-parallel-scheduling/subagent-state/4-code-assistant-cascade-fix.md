
#### [sub:级联修复] 2026-10-09 task-v153 钉值级联单元（scope 8 文件）

- SKILL.md:9 词序还原「Critical Rules 全集 1-68」：仅前 14 字位（「1-68 全集」→「全集 1-68」），行内括注零改动；RR-09 宽容正则 grep -cE 'Critical Rules 全集 1-(5[3-9]|6[0-9])' 命中恢复，selftest-root-resolution.sh 零改动（修后 17/17 rc=0）
- LA-12 / TS-05 / SR-07 / RC-11：grep -c 锚 'Critical Rules 1-66'→'1-68' + ok/bad 输出串 + 注释级联行（注明 task-v153 级联单元，Rule 45 注释）
- RF-06：cnt '1-66'→'1-68'；RF-07 双锚 'Critical Rules 1-66（含 Rule 40-65 全集'→'Critical Rules 1-68（含 Rule 40-65 全集'（括注 40-65 不变，与 SKILL:281 现行字面核对一致）
- SP-02：模式数钉值 11→12（P1-P12 设计契约冻结量，实测库文件 grep -c '^### P' =12）；SP-11：低档模型贡献行 11→12（实测 grep -c =12），注释同步
- 验收全量：7 旧 selftest 全 rc=0（14/12/12/17/13/23/13 全 FAIL=0）；3 新 selftest 9/9、9/9、5/5 全 rc=0；git diff --stat master 仅 skills/task-planner/ 内 15 文件，无越界新文件
- 禁改面核查：root-resolution 宽容正则未动；其他脚本无 1-66 残留（grep -n 复验）
