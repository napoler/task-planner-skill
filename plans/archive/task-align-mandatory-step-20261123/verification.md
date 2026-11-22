<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-align-mandatory-step-20261123

- task_id: `task-align-mandatory-step-20261123`
- 时间: created_at=2026-11-22T19:01:56Z / updated_at=2026-11-22T21:21:16Z

## Goal (1 sentence)
- 把对齐升格为所有任务修改完成后的强制必选步骤（步骤4硬门含精确锚『修改完成后强制对齐』）
- 对齐内涵覆盖关联面四族+部署位+引用面同步完整性，杜绝部分改部分丢弃
- 三处必选步骤载体（翻转前/终验/合规清单）齐备且部署位同步零丢弃
- 机器门 ALIGN-ANCHOR GATE（默认 enforce）+ 档位键 + BP-11 静态锚全部落地，5 部署位一致，enforce 缺锚 FAIL/齐锚 PASS

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pass | 步骤4翻转前硬门已把对齐升格为修改完成后强制必选步骤：SKILL.md 含精确锚『修改完成后强制对齐』（R1，需求锚（规范化）；逐字原话见 user-session-log.md #1） | grep -Fq '修改完成后强制对齐' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && echo PASS |  | R1, P1, P2, P4 |
| VC-2 | pass | 对齐内涵覆盖所有设计相关文件同步完整性：SKILL.md 含精确锚『关联面四族+部署位+引用面』，杜绝部分改部分丢弃（R2） | grep -Fq '关联面四族+部署位+引用面' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && echo PASS |  | R2, P1, P2, P4 |
| VC-3 | pass | 必选步骤载体三处齐备：终验智能子动作含『终验强制对齐』且合规清单新增 G11 对齐核查独立项（锚用无管道符串 G11 + 对齐核查，规避 MD 表格渲染转义；R3） | grep -Fq '终验强制对齐' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -Fq 'G11' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -Fq '对齐核查' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && echo PASS |  | R3, P2, P4 |
| VC-4 | pass | 部署同步无丢弃（用户 #2 裁决②授权覆盖）：主仓 + 4 部署位（.zcode/.claude/.config/opencode/.agents）共 5 处一致——SKILL.md 四锚全命中 + check-complete.sh 含 ALIGN-ANCHOR GATE + selftest-batch-pilot.sh 含 BP-11；机器门/断言脚本随 --deploy F5 整目录同步，.agents 由授权 cp/rsync 同步（R3） | B=/mnt/data/dev/task-planner-skill/skills/task-planner; for d in "/mnt/data/dev/task-planner-skill/skills/task-planner" "/home/terry/.zcode/skills/task-planner" "/home/terry/.claude/skills/task-planner" "/home/terry/.config/opencode/skills/task-planner" "/home/terry/.agents/skills/task-planner"; do grep -qF '修改完成后强制对齐' "$d/SKILL.md" \|\| exit 1; grep -qF '关联面四族+部署位+引用面' "$d/SKILL.md" \|\| exit 1; grep -qF '终验强制对齐' "$d/SKILL.md" \|\| exit 1; grep -qF 'G11' "$d/SKILL.md" \|\| exit 1; grep -qF 'ALIGN-ANCHOR GATE' "$d/scripts/check-complete.sh" \|\| exit 1; grep -qF 'BP-11' "$d/scripts/selftest-batch-pilot.sh" \|\| exit 1; done; echo PASS |  | R3, P3, P4, P5, D4-authorized |
| VC-5 | pass | 机器门实施（用户 #2 裁决①③）+ 真跑门三档（禁止 grep 临时文件冒充）：(a) check-complete.sh 含 ALIGN-ANCHOR GATE + 可独立 source 的门函数 align_anchor_gate()（ markers FN BEGIN/END 包住、自包含只依赖入参 tier 与 skill_md）+ 四锚 grep + 档位键；(b) config.json properties.align_anchor_enforce.default=enforce（jq 缺失/解析失败 fail-closed 落 enforce）；(c) selftest-batch-pilot.sh 含 BP-11 且实跑 0 FAIL；(d) 整目录 mktemp 复制（scripts+SKILL.md+config.json）→ sed 抽门函数 source → 齐锚 enforce 实跑 rc=0；删一锚 enforce 实跑 rc=1（! 断言）；同删锚 off rc=0、warn rc=0；trap EXIT 清理，绝不污染主仓/worktree/SKILL.md | BASE=/mnt/data/dev/task-planner-skill/skills/task-planner; CC="$BASE/scripts/check-complete.sh"; CFG="$BASE/config.json"; BP="$BASE/scripts/selftest-batch-pilot.sh"; SK="$BASE/SKILL.md"; grep -qF 'ALIGN-ANCHOR GATE' "$CC" && grep -qF 'align_anchor_gate()' "$CC" && grep -qF 'ALIGN-ANCHOR GATE FN BEGIN' "$CC" && grep -qF 'ALIGN-ANCHOR GATE FN END' "$CC" && grep -qF '修改完成后强制对齐' "$CC" && grep -qF '关联面四族+部署位+引用面' "$CC" && grep -qF '终验强制对齐' "$CC" && grep -qF '对齐核查' "$CC" && jq -e '.properties.align_anchor_enforce.default=="enforce"' "$CFG" >/dev/null && grep -qF 'BP-11' "$BP" && bash "$BP" >/dev/null 2>&1 && T="$(mktemp -d)" && trap 'rm -rf "$T"' EXIT && cp -r "$BASE/scripts" "$T/scripts" && cp "$SK" "$T/SKILL.md" && cp "$CFG" "$T/config.json" && sed -n '/ALIGN-ANCHOR GATE FN BEGIN/,/ALIGN-ANCHOR GATE FN END/p' "$T/scripts/check-complete.sh" > "$T/gate_fn.sh" && test -s "$T/gate_fn.sh" && source "$T/gate_fn.sh" && align_anchor_gate enforce "$T/SKILL.md" && sed -i '/修改完成后强制对齐/d' "$T/SKILL.md" && ! align_anchor_gate enforce "$T/SKILL.md" && align_anchor_gate off "$T/SKILL.md" && align_anchor_gate warn "$T/SKILL.md" && echo PASS |  | R4, P2, P4, P5, machine-gate, BP-11, real-gate-exec |

## Phase Gates
| Goal | Depends on | Done when | Checks | Status |
|---|---|---|---|---|
| R1,R2,R3,R4 |  | 三处锚点行位+四精确锚字符串+部署位清单确认落 findings | VC-1, VC-2 | pending |
| R1,R2,R3 | PG-1 | SKILL.md 三处锚点 + 机器门 ALIGN-ANCHOR GATE + 档位键 + BP-11 全部落地且 grep/实测命中 | VC-1, VC-2, VC-3, VC-5 | pending |
| R3,R4 | PG-2 | worktree rebase 到 ea2d6df 后合并回主仓 + 4 槽位共 5 位部署；VC-4 五位一致（四锚+GATE+BP-11）；scripts 增量按 CH-4（非零 diff） | VC-4, VC-5 | pending |
| R1,R2,R3,R4 | PG-3 | 5 VC 全量复验 PASS + selftest FAIL=0 | VC-1, VC-2, VC-3, VC-4, VC-5 | pending |
| R3,R4 | PG-4 | 防倒退三项净效果≥0 + 归档 + worktree 清理 | VC-4, VC-5 | pending |

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|---|---|---|
| （本任务暂无知识符合性记录） |  |  |

## 委派统计复验（Rule 25.4）
- （本任务暂无委派复验记录）

## 质量门控统计（Rule 26）
- （本任务暂无质量门控记录）

## Goal Gate (终验，所有 phase complete 后执行)
- （本任务暂无Goal Gate 记录）

---
## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|---|---|---|---|
| VC 执行入口唯一性（W-4） | S5 主进程按 verification.md VC 表 command 列手工逐条执行 + 证据回填 verification.md/progress.md；BP-08 行数哨兵随 VC-5 执行 | run-verification.sh 仅解析 '**Verify command**:' 字段，对 planctl 渲染表解析 0 条（本机实测），禁用其汇总为准；run-verification.sh 汇总仅作参考 | - |

## 5-Question Reboot Check
| # | Question | Answer (fill on resume) |
|---|---|---|
| （本任务暂无5Q 记录） |  |  |
