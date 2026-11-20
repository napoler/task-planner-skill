# Knowledge Brief — task-pointer-switch-defect-20261120（任务知识简略要点）
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：修复 task-planner 新任务 init / D 类意图切换时 side 指针被旧在途 claimant 误拦（需多次 --force）的设计缺陷，使同会话明确切换意图下一次成功。
- 背景/动机：用户实测每次切换都报「指针仍被旧计划声明，需 --force 覆盖」，浪费 2-3 次交互；根因已定位为守卫无 force 通道+流程未释放 `.session-owner`+skip 语义误导+判定误伤（见 findings.md）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| side 指针 | `plans/.active_plan_side/<sidkey>.active_plan`，按会话 sid 隔离的活跃计划指针（resolve 优先 side→全局→mtime→legacy） |
| sidkey/sid | 由 `CLAUDE_CODE_SESSION_ID` 规范化得到（去 `sess` 前缀等）；init 内有 sidmap/freshness fallback 映射逻辑 |
| `.session-owner` | 计划目录内声明会话认领的文件；hook 在 owner 空或==自己时写入，挂起后删除可由回切时 hook 自动重建 |
| 在途 claimant | 与当前 sid 匹配且 `task_plan.md` 状态为 in_progress 的他计划，占用 side 键写入的守卫对象 |
| 明确切换意图 | 在新计划目录执行 init（CWD 守卫成立）或完成 D 类确认切换流程——应优先于“沿袭互踩”防护，需通告后允许写入 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| init 同 sid 在途 claimant 时直接 skip 写 side 指针 | `skills/task-planner/scripts/init-session.sh:1229-1238,1251-1256`（`SKIP_SIDE_WRITE=1` + 仅 WARN） | G1 核心改点：改为通告+直接写（内置 force 语义），保留 fail-open 分支 |
| set-active-plan 同类守卫 skip 时 exit 0 且文案可误读为成功 | `skills/task-planner/scripts/set-active-plan.sh:263-291`（skip 分支 WARN 后 `exit 0`） | G4：必须输出明确“指针未切换”；exit code 变更需先评估调用点影响 |
| claimant in_progress 判定为全文裸匹配 | `init-session.sh:1236`、`set-active-plan.sh:261` 均 `grep -qi 'Status.*in_progress'` 扫全文件 | G3：锚定状态控制行（对齐 gc anchored 风格 `:203-209`），防模板/注释误命中 |
| gc completed-ttl 已使用锚定状态行判定 | `skills/task-planner/scripts/set-active-plan.sh:203-209`（has complete 且无 in_progress/pending 状态行） | 修复 claimant 判定时应与此风格一致，不回退 gc 逻辑 |
| D 类切换清单①未释放旧 `.session-owner` | `skills/task-planner/SKILL.md:220`（仅挂起登记+断点检查点） | G2：追加删除旧计划 `.session-owner`，回切时 hook 自动重建 |
| E 类/Rule 94 隔离处置未声明释放占用 | `skills/task-planner/SKILL.md:227` | G2：同步补充封存/隔离时释放旧 `.session-owner` 口径 |
| 模板 Status 行真实格式 | `skills/task-planner/templates/task_plan.md:315,333,346,376,397`（`- **Status:** in_progress/pending`） | G3 正则基准：锚定 `- **Status:**` 行 |
| 既有指针生命周期 selftest 结构与隔离方式 | `skills/task-planner/scripts/selftest-pointer-lifecycle.sh:1-99`（PL-01..PL-10，`/tmp` mktemp 夹具） | G5：仅扩展既有文件新增断言，禁降级/删减 PL；保持夹具隔离 |
| 源仓/部署位 5 个指针脚本历史 diff 为空（调研结论） | `plans/task-pointer-switch-defect-20261120/findings.md:66` | 执行期合并回后需按实际机制同步部署位并留证据，不能凭记忆声称 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| `skills/task-planner/scripts/init-session.sh`（worktree） | :1160-1207 | sidmap/freshness fallback：env sid 无哨兵时映射或 120s 内新鲜哨兵探测，避免抢他会话 |
| `skills/task-planner/scripts/init-session.sh`（worktree） | :1229-1256 | F3 side 写入所有权守卫：扫 `.session-owner` 找 claimant，in_progress→skip；complete/不存在→fail-open；后续写 side 指针 |
| `skills/task-planner/scripts/set-active-plan.sh`（worktree） | :203-209 | gc 全局指针 completed-ttl 判定：锚定 `**Status:** complete` 且无 active/pending 状态行 |
| `skills/task-planner/scripts/set-active-plan.sh`（worktree） | :263-291 | set 分支 claimant 守卫：in_progress 且无 `--force`→WARN+skip+exit 0；`--force` 覆盖写入 |
| `skills/task-planner/SKILL.md`（worktree） | :220 | D 类意图切换执行清单①-④（当前①缺释放 `.session-owner`） |
| `skills/task-planner/SKILL.md`（worktree） | :227 | E 类目标切换判定与 Rule 94 隔离处置（需同步释放占用口径） |
| `skills/task-planner/scripts/selftest-pointer-lifecycle.sh`（worktree） | :1-99 | PL-01..PL-10 静态+行为断言，含 PL-10 所有权守卫夹具（skip+WARN+--force） |
| `skills/task-planner/templates/task_plan.md`（worktree） | :315,333,346,376,397 | Phase `- **Status:**` 行格式基准（G3 锚定依据） |
| `plans/task-pointer-switch-defect-20261120/findings.md` | :48-75 | 本任务根因、修复方案 G1-G4、指针体系事实 |

## §4 易错点与禁止假设清单
1. **禁止把守卫改成无条件全放行**：必须保留 claimant complete/不存在的 fail-open 与 `--force` 覆盖语义（B-01），同时让“新计划 init=明确切换意图”一次成功。
2. **禁止新增脚本/守护基建**：修复仅改既有脚本分支、SKILL 条款、既有 selftest 文件（SPEC-NO-INFRA-01，文本优先铁律）。
3. **G4 exit code 不可拍脑袋改非 0**：必须先 grep/评估 `set-active-plan.sh` 调用点（hooks/其他脚本）；默认计划策略=保持 exit 0 仅强化“指针未切换”文案并登记。
4. **in_progress 锚定要兼顾真实格式与误命中**：基准是 `- **Status:** in_progress` 状态控制行；避免匹配散文/注释中的 `in_progress`，也避免漏判真实状态行。
5. **init 场景重现夹具必须隔离**：使用 `/tmp` mktemp + 显式 `CLAUDE_CODE_SESSION_ID` + 独立 plans 根，禁止触碰真实 `plans/` 与真实 side 键。
6. **部署同步不能口头完成**：源仓修复后需按实际部署机制同步 `~/.zcode/skills/task-planner/` 并留 diff/命令证据（B-04）。
7. FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 1 G1 直写破坏并行会话防互踩」「Phase 1 in_progress 锚定过严/过松导致漏判或误判」行

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1, §2, §3, §4 | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/skills/task-planner/scripts/init-session.sh`、`/mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/findings.md` |
| S2 | §1, §2, §3, §4 | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/skills/task-planner/scripts/set-active-plan.sh`、`/mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/findings.md` |
| S3 | §1, §2, §3, §4 | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/skills/task-planner/SKILL.md`、`/mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/findings.md` |
| S4 | §2, §3, §4 | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/skills/task-planner/scripts/selftest-pointer-lifecycle.sh`、`/mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/verification.md` |
| S5 | §2, §4 | `/mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/verification.md`、`/mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/task_plan.md`（基线与防倒退终检） |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | `/home/terry/.zcode/skills/task-planner/SKILL.md` | 本任务即修复 task-planner 指针切换缺陷与流程条款 | 子代理 prompt 挂载 / 主进程按需读取 |
| verification-before-completion | `/home/terry/.zcode/skills/verification-before-completion/SKILL.md` | VC-1 场景重现与终验前证据门控 | 子代理 prompt 挂载 |
| systematic-debugging | `/home/terry/.agents/skills/systematic-debugging/SKILL.md` | 若修复后场景仍失败，需先定位真实原因再改 | 子代理 prompt 挂载 / 主进程 Skill 调用 |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-pointer-switch-defect-20261120>` → 生成 knowledge/entries/_draft-task-pointer-switch-defect-20261120.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）
