## Milestones (2026-10-10 Code Reviewer)
- M1 逐 hunk 审查完成: 被审脚本 87 行(任务书写 82 行=不计尾部空行的文本行数, 无实质差异); SCRIPT_DIR 相对解析同范式 selftest-iterative-optimizer.sh; 无写死绝对路径; exit 语义同构 `exit $((FAIL > 0))`
- M2 试跑: `bash .../worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh` → FP-01..08 全 PASS, `Total: 8 PASS=8 FAIL=0`, exit=0
- M2b 断言真实性核对: SKILL.md 六区块逐锚计数(触发条件/输入契约/执行流程/门控铁律/反模式 各 1 + 输出合约 2 = 7 行)≥6 成立; QC-FP 表行 `^| QC-FP-` = 6; registry `tail -1` 含 error-fix-prompt-forge(末行真实); config.json grep -c = 0(exit=1 为 grep 无命中正常退出码)
- M3 范式差异核对: 与 selftest-iterative-optimizer.sh 结构逐段同构; 差异(新增 TPL/REG/CFG 三对象、FP-06 双文件互现循环、FP-05 grep 2>/dev/null)均有断言对象不同的合理理由; 位置平移与路径修正背景与 findings.md [sub:06] 一致
- bash -n 语法 OK; 文件保留 +x(平移 mv 未丢权限); UTF-8; 尾部有换行

## 问题清单(无 Blocker; P1×3 / P2×2 / Nit×1, 均已 grep/试跑复现)
1. [P1] `selftest-error-fix-prompt-forge.sh:68` FP-06 槽位词用默认 BRE 子串匹配: `for w in 问题陈述 根因 复现 禁改区 回滚 参考材料; do` — 「根因/复现」等是「根因结论/复现路径」等长词的前缀, 子串命中≠槽位词在位, 断言语义弱于注释宣称的「槽位词互现」; 建议改 grep -qF 或加边界。当前 6/6 真实互现, 不影响现 PASS。
2. [P1] `selftest-error-fix-prompt-forge.sh:60` FP-05 阈值 8 但模式含宽泛词「范围/验收/根因/复现」: `n=$(grep -c '根因\|复现\|范围\|禁改区\|验收\|回滚\|未验证假设区\|DoD' "$TPL" ...)` — 8 个宽泛 OR 模式对 8 阈值, 模板大改后宽泛词残留仍可 PASS, 九槽位守护退化为近似恒真; 建议: 精确词计数(未验证假设区/DoD/禁改区)+逐词独立断言, 或阈值=8 个不同词各 ≥1。
3. [P1] `selftest-error-fix-prompt-forge.sh:52-54` FP-04 用全文出现次数而非表行数: `a="$(grep -c 'QC-FP-' "$SKILL" || true)"` — 实测 8 = 表行 6 + 正文引用 2; 若自检表被删 2 行(剩 4 表行+正文 2 引用=6)断言仍 PASS, 自检表可被截断; 建议锚定 `^| QC-FP-` 行计数(实测=6)。
4. [P2] `selftest-error-fix-prompt-forge.sh:64,80` FP-05/07 FAIL 分支无数值诊断: `bad 05 "模板缺失或九槽位锚漂移（命中 $n 应 ≥8）"` 中 $n 在模板缺失时未定义来源不可靠; `bad 07 "registry 末行未登记 error-fix-prompt-forge"` 无 tail 输出快照, 排障信息弱于范式(IL-02..08 均带数值)。建议 FAIL 分支附实测值/末行内容摘要。
5. [P2] `selftest-error-fix-prompt-forge.sh:14,59,62` 「九槽位」注释与阈值 ≥8 不一致(共 3 处); 槽位清单列 8 词但模板实有 ⑨+参考材料 区块。建议注释改为「八槽位锚, 阈值 8」或阈值与词数对齐, 防后人误改阈值。
6. [Nit] `selftest-error-fix-prompt-forge.sh:34-38` FP-01 断言 name 锚但未断言「name=目录名」等价性(head -5 内 grep 计数=1 语义沿 IL-01); 消息文案「name=目录名」略超出实际断言强度。可接受(目录名由安装层保证), 仅措辞精度问题。

## 最终结论
status: done
acceptance: 4/4 pass — [1:PASS 2:PASS 3:PASS 4:PASS]
files: none
evidence: bash worktree/.../selftest-error-fix-prompt-forge.sh → `Total: 8 PASS=8 FAIL=0` exit=0; grep SKILL.md 六区块=7 行/QC-FP 表行=6; tail -1 registry.tsv 含 error-fix-prompt-forge; config.json grep -c=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/07-code-reviewer.md (status: done)
findings_written: none
blockers: none
confidence: HIGH

REVIEW: APPROVED | 问题清单=P1×3/P2×2/Nit×1(见上方里程碑段, 全部为断言强度加固建议, 当前 8/8 PASS 真实有效, 无 Blocker)
