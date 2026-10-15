# sub:8-code-assistant checkpoint (Rule 22.8)
status: done

## 产出（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v144/skills/task-planner）
1. scripts/selftest-subagent-granularity-skill-escort.sh（新建，23 断言 SG-01..SG-23，`bash scripts/selftest-subagent-granularity-skill-escort.sh` → Total: 23 PASS=23 FAIL=0，exit 0）
2. scripts/selftest-registry.tsv 追加 1 行（4 列 tab 对齐既有行，diff +1/-0）

## 断言覆盖（六文件锚）
- critical-rules.md: `^### 59 `=1；`^59\.[1-7] `=7；59.1 行含 enforce；59.2 行含「首动作 Read」；59.3 行含「可用强化技能」∧「仅提示用户可手动激活」；59.4 行含「先拆细再派」；59.5 行含「分段」；task-v144 来源锚
- templates/task_plan.md: 表头行锚定 `| ID ...粒度(三值)|伴飞技能|`=1（行首锚定——全文裸计数伴飞技能=2 含契约注释行，属预期）；enforce≥2
- templates/knowledge-brief.md: 「§6 可用强化技能清单」=1
- templates/subagent_dispatch.md: 「### 伴飞技能」=1；「九字段」≥1（既有 22.4 面防破坏）
- scripts/check-dispatch.sh: 「Rule 59.1 粒度三值硬门」≥1；「Rule 59.2 伴飞路径不存在」≥1
- scripts/analyze-splits.sh: 在位且 -x 可执行
- config.json 零新键负断言: granularity/skill_escort/escort_skill 字面=0

## 验证记录
- 首跑 SG-13 FAIL（全文裸计数=2 误报）→ 改表头行锚定修复 → 23/23 PASS exit 0
- 负断言自测：SKILL_ROOT 支持 SG_SKILL_ROOT env 覆盖；mktemp 临时副本删 task_plan.md 表头伴飞列 → SG-13 FAIL exit 1（断言非恒真）；本体未触碰
- 本单元新增 git 变更仅：?? selftest-subagent-granularity-skill-escort.sh + M selftest-registry.tsv（+1 行）

## 负结果/已知问题
- selftest-registry.sh T02 报「未登记: selftest-periodic-review.sh」= 存量 gap（HEAD commit 1a92ef3 已有该脚本但 registry 无行），与本单元无关；本单元新增行已正确登记（T03/T04/T05 PASS）
- 未 git add/commit；worktree 其他 S1-S7 产物零触碰

## 材料包追加
- findings.md `#### [sub:8-code-assistant]` 已追加（Research Findings 段末，sub:7 之后）
- progress.md Phase 3「Actions taken」已追加 `[sub:8]` 行
