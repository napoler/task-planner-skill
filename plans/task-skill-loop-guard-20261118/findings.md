# Findings — task-skill-loop-guard-20261118

## 根因链（取证已证实，详见 forensics/ 三份报告）
1. **规模爆炸**：`/goal「完成对离开罗布湖之后剧本的创作。我希望剧本和脚本一起完成」` + 「全部执行/逐集闭环 EP33–EP44」→ 11 集 × (剧本+分镜) × 多门 QC。
2. **54 子代理串行流水线**：每集 9–12 个（调研/编剧/审计/分镜/审镜/修正/归档）；88% 工具调用在 subagent（Read 598/Bash 864/Edit 129）。每代理 prompt 要求全量回读公共材料 → 重复检索。
3. **QC FAIL 无条件返工**：EP33 人数词面 13 处、EP34 BLOCKER、EP35 MAJOR 等 → 每次新起 executor+reviewer 双轮，同一 canonical 文件反复改。
4. **无版本快照**：EP33–EP39 单文档 + worktree `??` 未跟踪无 git 历史 → 改错难追溯。
5. **规范版本漂移**：worktree c179cee 旧规则 vs main d73ad36 新门禁 → EP34 按旧规创作按新规判错，纯流程性返工。

## 六缺口判定（审计子代理产出，主进程已复核锚点）
| 缺口 | 判定 | 优先级 |
|---|---|---|
| A 全局子代理预算 | 缺失（只有每 Phase 局部上限） | P0 |
| B goal 范围锚定 | 28.8 禁问 + 94.7「全部」豁免叠加，无上界 | P0 |
| C 同文档返工上限 | 缺失（103.8 无条件重开双轮） | P0 |
| D worktree 阶段提交 | 条款在位属执行违规；27.1 豁免措辞模糊 | P1/P2 |
| E 公共上下文传递 | 62.4 仅覆盖调研型，103.3a 反向放大 | P1 |
| F worktree 版本校验 | 记忆有 How-to-apply，条款无硬门 | P1 |

## 归属
- 本仓应修：A/B/C/E/F + D 次生措辞。
- StoryLab script-craft 工序/判据/单文档形态/工具失败：不在本仓，仅报告不动。

## B 类扩展发现（2026-11-18 全平台部署，用户新指令）
- **差异性质判定**：claude/cursor/opencode 三位 5 目标文件是同一落后快照（dst 字节数三位完全一致）；diff 内容全为已合并进源仓 master 的正式条款（11-04 后 worktree 免询问修订 + 本次 6 处），无任何平台特定适配（frontmatter/路径差异）。结论：直接以源仓当前版本覆盖，不丢平台语义。
- **部署后 selftest FAIL 归因**：zcode/claude/cursor/opencode 位 SA-11/12/18（SKILL.md 纪元窗/级联随动/使用点标注）与 DQ-08/09/10（Rule 103 域/user-session-log 锚缺失）FAIL，均来自部署位 SKILL.md 等未同步文件的历史欠账，非本次 5 文件引入。本次改动的契约门 SA-15/DQ-01 全 PASS；源仓两脚本 20/20、14/14 全绿。结论：FAIL 与本次无关，登记不扩大修复范围（§四 防漂移）。agents 位 SKILL.md 较新故 FAIL 少 1 个，同属历史欠账。
