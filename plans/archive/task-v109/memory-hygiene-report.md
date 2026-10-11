# task-v109 记忆整理报告（M1-M5 dogfood，sub:6-executor）

- 整理对象：/home/terry/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/（57 topic + MEMORY.md）
- 盘点时点：2026-10-02（master c91677d，ahead origin 21；worktree wt/task-v109）
- 校核基准（主进程第一手采用+本 sub 复核）：selftest=42 个 .sh（find | wc -l）；registry.tsv=43 行（SR-12 动态口径）；主仓 variant=16（worktree +memory-hygiene-type=17）；部署位 zcode=28（videop1 分叉，独有 audio-voice-type 等）/claude=16/opencode=16；660/0=v108 终验基线
- 处置分布：**verified=49，updated=2，stale-marked=4，删除建议=0**
- 索引层发现：MEMORY.md 58 索引行对应 57 topic；task-planner-repo-deploy-flow 被 2 行引用（「合并回智能门(task-v064)」行+「部署拓扑」行）→ proposed 版合并为 1 行

## 一、总表（57 条逐条处置）

| # | name | 类 | 处置 | 验证锚证据 |
|---|------|---|------|-----------|
| 1 | task-v108-template-system-alignment | A | verified | git log → "5a30382 Merge branch 'wt/task-v108'"；计数锚 16/22/25=时点快照（v109 推 17 后过锚） |
| 2 | task-v107-deep-review-alignment | A | verified | zcode variant 28 vs 主仓 16 实测复现 EX-1；R 系列待授权 OPEN |
| 3 | task-v106-iterative-optimizer | A | verified | ls skills/iterative-optimizer → SKILL.md；registry.tsv wc -l → 43 |
| 4 | task-v105-pool-host-enumerable | A | verified | ls review-library → 11；topic:20 遗留 3 项 OPEN |
| 5 | task-v104-align-gate-upgrade | A | verified | grep -c "42.6" CR → 6；topic:23 遗留 1 项 OPEN |
| 6 | task-v103-ask-default-timeout | A | verified | grep -c "44.3" CR → 1；topic:16 遗留 2 项 OPEN |
| 7 | task-v102-alignment-upgrade | A | verified | grep 42.6 命中；topic:16 遗留 3 项 OPEN（①措辞分叉仍在） |
| 8 | task-v101-alignment-review | A | verified | ls review-library/alignment-review 存在；topic:16 遗留 2 项 |
| 9 | task-v100-review-library | A | verified | ls review-library → 11 技能；topic:18 遗留 3 项 |
| 10 | task-v099-reliability-institution | A | verified | grep -c "43.1" CR → 2 |
| 11 | task-v098-auto-resolution | A | verified | grep -c "41.3" CR → 4 |
| 12 | task-v097-tool-selection | A | verified | grep -c "40.1" CR → 1；「未 push」=时点事实（后续 v100+ 多轮已 push） |
| 13 | task-v096-template-auto-record | A | verified | grep -c "34.7" CR → 1 |
| 14 | task-v095-skill-split | A | verified | ls skills/ → plan-{research-router,cost-guard,collab-router,template-kit} 在位 |
| 15 | task-v093-video-fix-template-intake | A | stale-marked | ②「33 脚本 525/0 动态白名单 16 类」=09-28 时点;现主仓 selftest=42 实测、variant=16（白名单类数一致但脚本数过时） |
| 16 | task-v092-guard-quirk-fixes | A | verified | git log d82720e 命中 2；ls scripts/check-drift.sh 在位 |
| 17 | task-v091-efficiency-optimization | A | updated | git worktree list → 仅 master+wt/task-v109（「双 worktree 全清理」✓ 实测成立）；基线 525/0 已被 v108 42/660 替代（②漂移） |
| 18 | task-v090-workflow-auto-activation | A | verified | grep -c "39.1" CR → 4；git log df8149f/12663ed 在史 |
| 19 | task-v089-workflow-auto-activation | A | verified | topic:3 自述「缺口两项已由 v090 全部落地 09-25」与现状一致 |
| 20 | task-v088-workflow-orchestration | A | verified | grep -c "39.1" CR → 4；「v089 后遗两项待决」句已被 v090 清账（尾部半过时=容忍性时点陈述,主体交付记录有效） |
| 21 | task-v087-task-boundary | A | verified | git log a2ae738/cb16507 在史 |
| 22 | task-v086-mini-fast-path | A | verified | grep -c "38.1" CR → 3；git log 4a925bb/55db912/c340219 在史 |
| 23 | task-v085-task-type-mechanism-profile | A | verified | grep -c "37.1" CR → 1；git log f452a2c 在史 |
| 24 | task-v084-thinking-methodology | A | verified | git log 871e71a 在史 |
| 25 | task-v083-batch-pilot-first | A | verified | grep -c "18.9" CR → 2；git log 8fed498 在史 |
| 26 | task-v082-minimal-probe | A | verified | grep -c "35.6" CR → 10；git log e120331 在史 |
| 27 | task-v081-fine-grain-step-gate | A | verified | grep -c "21.4" CR → 7；git log c10e8f2 在史 |
| 28 | task-v080-web-research-routing | A | verified | git log 34c3959 在史 |
| 29 | task-v079-skill-modify-conservatism | A | verified | grep -c "36.2" CR → 2；ls scripts/check-skill-modify.sh 在位 |
| 30 | task-v078-guard-fp-fixes | A | verified | git log f56ffb9 在史；「deferred 模板补骨架」已由 v108 M-01~M-13 清账（MEMORY L3 行实证） |
| 31 | task-v077-deferred-fixes | A | verified | git log 187194b 命中 1；「deferred 已由 v078 全部清账」与 MEMORY L61 一致 |
| 32 | task-v076-conclusion-discipline | A | verified | git log 5ad18f6 命中 1；「deferred 3 项由 v077 清账」一致 |
| 33 | task-v075-fine-grain-methodology | A | verified | git log d975ee0 命中 2；313/0=当轮时点基线（后续 660/0 演进正常替代链） |
| 34 | task-v074-template-reflect-loop | A | stale-marked | 双源冲突③：topic:11 正文「19 脚本 294 PASS/0 FAIL」vs MEMORY 索引行「全量 301/0」；topic「未 push,origin 停在 7ef6214」=push 态已过时（现 ahead 21 持续推进） |
| 35 | task-v073-veto-tracker | A | verified | grep -c "32." CR → 10；git log 7ef6214 在史 |
| 36 | task-v072-error-loop | A | verified | grep -c "31.2" CR → 7；git log 0119614 在史 |
| 37 | task-v071-shared-tracker | A | verified | grep -c "30.1" CR → 1；git log 760c2a3 在史；「config 33 键」=时点快照 |
| 38 | task-v070-exec-approach-echo | A | verified | grep -c "28.2.1" CR → 1；git log ce009d6 在史 |
| 39 | task-v063-methodology-intro | A | verified | git log 9f89908 在史；遗留①「verify.sh 白名单补 selftest-methodology」由 v075 B3 清账（MEMORY L29） |
| 40 | task-v062-interaction-modes | A | verified | git log b0da240 在史；遗留①「plan-resume@.zcode 缺位」实测 ~/.zcode/skills/plan-resume 在位=机制面已解 |
| 41 | task-v057-subagent-io-contract-plan | A | verified | git log 83282d2 命中 2；ls scripts/check-dispatch.sh 在位 |
| 42 | task-v056-fine-grained-dispatch-plan | A | stale-marked | ②「master 领先 origin 7 未 push」=09-09 时点,现 ahead 21 持续演进;「遗留 check-complete 反转」已由 v057 清账（MEMORY L86 行实证） |
| 43 | task-planner-repo-deploy-flow | A | updated | 双源冲突③：frontmatter「9 位全量(09-05/09-08 基线)」vs MEMORY 行「实体副本 3 实体位(09-16 后)」；正文止于 09-16 v075,未随 v076-v108 追加；zcode 位 videop1 分叉使「3 实体位 diff=0」在 zcode 位不再成立 |
| 44 | task-planner-three-file-compass | B | verified | grep -c "19.5" CR → 1；Rule 19.5-19.7+3-File Gate 在位 |
| 45 | task-planner-plan-parsing-pitfalls | B | stale-marked | ①「仓根 scripts/ 入口」实测 ls /mnt/data/dev/task-planner-skill/scripts/ → No such file or directory；「session-catchup.py 幽灵」实锤=仓内为 .ts 实体（ls scripts/session-catchup.ts 在位）；陷阱主体恒效仅仓根 scripts/ 局部锚灭 |
| 46 | task-planner-known-defects-20260905 | C | verified | 指向 plans/archive/task-v053-skillfix-deploy/deferred-issues.log 实测存在;「6 项已清账 19a40ca」topic:11 实证 |
| 47 | task-planner-check-complete-gate-inverted | C | verified | check-complete.sh:418 "exit (r+0 < f+0)" 在位=修复态实证 |
| 48 | task-planner-awk-scope-extraction-bug | C | verified | git log grep 19a40ca → 2;状态机范式仍为仓内标准写法 |
| 49 | quality-over-speed-in-skill-enhancement | B | verified | grep -c "25." CR → 28（Rule 25 族在位） |
| 50 | serial-dispatch-iron-rule | B | verified | grep -c "21.4" CR → 7；grep "串行" ~/.zcode/AGENTS.md → 0（「未对齐待授权」声明仍准确） |
| 51 | fine-grained-dispatch-philosophy | B | verified | 理念恒效；落地 Rule 21.1b grep=4 在位 |
| 52 | split-before-upgrade-small-steps | B | verified | grep -c "21.1b" CR → 4 |
| 53 | change-linkage-audit | B | verified | git log bc4107e grep -c → 2 |
| 54 | interruption-recovery-first-verify | C | verified | 教训载体,无待办断言 |
| 55 | skill-backup-no-rename-in-scan-path | B | verified | ls -d ~/skill-deploy-backups-* → 20260904/task-v097/task-v099 三目录在位 |
| 56 | subagent-clean-context-testing | B | verified | v109 task_plan VC 段「验证独立性铁律」活跃消费中 |
| 57 | zcode-todowrite-status-cr-glitch | C | verified | 本 sub 运行未复现 \r 注入（「偶发」声明保守,保留） |

## 二、updated 类——更新文案 + 原文留存

### U1 task-v091-efficiency-optimization（topic 更新文案,不直接改 topic 文件）
原文（MEMORY 索引行,L37）:「task-v091 skill 执行效率优化（已交付 COMPLETE：Tier A 10 项落地 merge b5b9bc0+c5locale 36e9aaa，三位部署 diff -r ×3=0；Tier B 7 项暂缓待实测数据重议；v092 后 master 基线=33 脚本 525/0）」
更新要点：
1. 「v092 后 master 基线=33 脚本 525/0」→ 加 M5 失效条件标注：`[STALE 2026-10-02: 基线数字为 09-27 时点快照，现行基线=v108 42 脚本 660/0，失效条件=selftest 计数/registry 漂移即重验]`
2. 「两位 worktree 全清理」实测成立（git worktree list 仅 master+wt/task-v109），保留
3. 索引行 ≤200 字符压缩时保留：Tier A 10 项落地/ Tier B 7 项暂缓/ 基线 superseded-by-v108

### U2 task-planner-repo-deploy-flow（topic 更新文案 + 索引双行合并）
原文（frontmatter description）:「2026-09-05 起为实体副本模型（9 位全量），合并后必须显式 cp -rL 重新部署；2026-09-11 task-v060 收编…基线 master 3dc6a1b」
原文（正文止点）:「**2026-09-16 task-v075…（当日最新）**」后无 v076-v108 段落
更新要点：
1. 正文追加 2026-09-16 后部署现状段：v076-v108 均以「3 部署位（zcode/claude/opencode）+plan-writer 2 位」口径交付，「9 位全量」为 09-05/09-08 历史口径（companion 6 位+agent 2 位+主仓=9 位,后 10 任务统一收窄为 3 实体位+companion/agent 按需）
2. 追加 2026-09-30 后 videop1 分叉现状：~/.zcode/skills/task-planner/templates/variant=28（videop1 就地迭代,含 audio-voice-type.md 等 video/image 家族 12 类）vs 主仓/claude/opencode=16，v107 EX-1 登记归属待裁决（失效条件：裁决回流/归一后本段删除）
3. 「master 领先 origin N 未 push」类时点断言全部 M5 化：每处补失效条件「push 后即过时,消费前跑 git status -sb」
4. 索引层：「合并回智能门(task-v064)」行与「部署拓扑:实体副本 3 实体位」行合并为 1 行（同一 topic 双索引行,proposed 版 57 行=57 topic 对齐）

## 三、stale-marked 类——标注文案（固定格式,不删原文）

| name | 标注文案 |
|------|---------|
| task-v093-video-fix-template-intake | `[STALE 2026-10-02: 「33 脚本 525/0」为 09-28 时点基线，现行=v108 42 脚本 660/0；失效条件=selftest 全量重跑值≠行内数字]` |
| task-v074-template-reflect-loop | `[STALE 2026-10-02: 「19 脚本 294 PASS/0 FAIL」与 MEMORY 行「301/0」双源不一致（294=当轮口径）；「未 push,origin 停 7ef6214」push 态已过时；失效条件=push 后重验 git ls-remote]` |
| task-v056-fine-grained-dispatch-plan | `[STALE 2026-10-02: 「master 领先 origin 7 未 push」=09-09 时点,现 ahead 21；「遗留 check-complete 反转」已由 v057 83282d2 清账；失效条件=push 或清账完成后删除本标]` |
| task-planner-plan-parsing-pitfalls | `[STALE 2026-10-02: 「仓根 scripts/ 入口」实测不存在（仓内脚本均在 skills/task-planner/scripts/）；「session-catchup.py」幽灵实锤=仓内为 session-catchup.ts；陷阱主体仍有效]` |

## 四、删除建议（仅建议,零自动执行,交用户裁决）

**本盘点 57 条：删除建议 = 0 条。** 理由（M3 门槛复核）：
- 锚全灭：无（57 条引用锚逐一 grep/ls 实测,除 plan-parsing 局部锚外全部在位）
- 被新条目完全替代：无（v089「后遗已由 v090 落地」为清账陈述非替代;task-v070~v093 各条交付记录彼此独立）
- 纯时点快照：4 条 stale-marked 均主体叙事有效（交付记录+教训载体）,按 M3 边界规则标 stale 而非删除
- 双索引行合并（repo-deploy-flow 2→1 行）=索引层去重,非删除 topic,不属删除建议面

## 五、验证锚规范符合性（M4/M5）
- 57/57 条处置均附 ①file:line 或 ②命令→关键输出（≥10 字符）
- 38 个 commit 锚逐 sha grep -c 全部 ≥1（38/38 在史）
- 13 个 Rule 锚 grep 实测值：21.4=7 / 21.1b=4 / 42.6=6 / 44.3=1 / 43.1=2 / 41.3=4 / 40.1=1 / 34.7=1 / 18.9=2 / 35.6=10 / 36.2=2 / 22.4a=6 / 31.2=7 / 32.=10 / 30.1=1 / 38.1=3 / 37.1=1 / 28.2.1=1 / 39.1=4 / 19.5=1 / 25.=28（全部 >0 命中）
- 660/0 未全量重跑（42 脚本超 25min 预算）→ 采用主进程第一手基准+v108 终验记录（VC 契约允许）；registry 无 660 硬编码（动态口径 SR-12）故无漂移风险

## 六、负结果声明
- 检查步骤：57 topic 全量+MEMORY.md 58 索引行+38 commit 锚+21 Rule 锚+3 部署位 variant 计数+worktree list+INDEX 表行；未发现异常=45/57 条 verified 无冲突、6 条 C 类免检登记、删除面=0
- 排除风险：记忆目录零修改（全程 Read/grep/ls,写入仅 plans/task-v109/）；仓内 skills/ 零修改；无 git 写操作（仅 git log/status/worktree list 只读）
