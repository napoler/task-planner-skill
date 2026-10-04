# Delivery Summary — task-v125（执行体专业化优先与覆盖矩阵 / Rule 52）

> **定位栏（Rule 48.2）**: 机器档案=`/mnt/data/dev/task-planner-skill/plans/task-v125/` ｜ 仓库=`/mnt/data/dev/task-planner-skill` ｜ 交付基线=`merge c38a5fc2a653b9a54815f822a46dce30a450c4e2` ｜ 部署位=`/home/terry/.zcode/skills/task-planner`、`/home/terry/.claude/skills/task-planner`、`/home/terry/.config/opencode/skills/task-planner`（3 位 IDENTICAL）＋router 双位：`/home/terry/.zcode/skills/skill-agent-router/SKILL.md`、`/home/terry/.claude/skills/skill-agent-router/SKILL.md`

## 1. 任务说明
- **Goal 回顾**: 把「总是用通用 Agent」的三类缺口收口为机制——覆盖矩阵落仓 + Rule 52 执行体专业化优先（52.1-52.4）+ 三登记面修复 + selftest-agent-coverage 守护，全量 0 FAIL 后合并回 + 部署。
- **执行过程摘要**: P1 worktree+基线（Rule 52 经 rule-reserve 账本正式预留）→ P2 四单元并行落盘（G125：矩阵/Rule 52/SKILL/mapping）→ P3 锚演进批×2+新守护+回归 → P4 fresh 终验+对齐 → P5 CR Gate+合并+router 双位部署。关键裁决：编号三次竞态改号 48→50→52（v126/v127 先落地，v128 账本落地后按「先登记先占」预留）；两处锚级联按预登记分支演进（454→461、^52→^53）；S9 首派零输出无效按 22.8.5 判据重派；委派 violation 自修复。ask 模式无 silent 裁决。
- **行为面变化**: ① 规划/执行期派发 S-unit 现在有**单一事实源**：`/mnt/data/dev/task-planner-skill/skills/task-planner/references/agent-coverage.md`（87 agent×14 族×三登记面全矩阵 + 41 个「有体不用」实体的纳入/豁免去向）——选型先查矩阵，专用体在位必须用（Rule 52.1）；② `skill-agent-router` 路由表新增 6 个族行（质量审查/Git 运维/营销 SEO/数据研究/文档 UI/文章管线），派发时「找得到」那 41 个既有专业体；③ 以后任何「登记名指向不存在实体」会被 `selftest-agent-coverage.sh`（AC-04 实体存在性零容忍）直接 FAIL——「映射指空」不再复发。
- **交付结论**: **COMPLETE**（`/mnt/data/dev/task-planner-skill/plans/task-v125/verification.md` Goal Gate 段；check-complete exit 0）

## 需求覆盖核对（Rule 51.3 — 交付必载）
| 需求# | 用户原话（摘） | 判定 | 证据路径 |
|-------|--------------|------|---------|
| R1 | 「很多任务它总是喜爱使用通用的Agent，难道说是当前的自带Agent不够用吗？」 | **covered**（诊断=资产不缺 87 个/14 族；根因=三层脱节，机制已收口） | `/mnt/data/dev/task-planner-skill/plans/task-v125/subagent-state/2-coverage.md`（A/B/C 三类实证）+ `.../skills/task-planner/references/agent-coverage.md` |
| R2 | 「确保后期再次拆分子代理执行任务的时候，可以使用更对应的专业代理进行执行」 | **covered** | Rule 52.1 选型顺序（`.../skills/task-planner/references/critical-rules.md` 文末 52 块）+ 路由族行（`.../skills/task-planner/SKILL.md:364-369`）+ 守护 `.../skills/task-planner/scripts/selftest-agent-coverage.sh` |
| R3 | （追问隐含）「难道说是当前的自带Agent不够用的吗？」 | **covered**（零专用体 9 领域清单已成册=增补候选，交下轮裁决） | `agent-coverage.md` §四 零专用体领域段 |

## 2. 产出清单（文件级）
| 文件 | 变更摘要 | 验证状态 |
|------|---------|----------|
| `/mnt/data/dev/task-planner-skill/skills/task-planner/references/agent-coverage.md` | 新建 128 行（类型族矩阵/三类缺口处置/C 类 41 行纳入豁免/零领域清单；52.3 维护责任头） | VC-1 PASS；S9 对账通过 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md` | 文末追加 Rule 52 块（52.1-52.4，+12） | VC-3 PASS（^52.=4） |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` | 六族路由行（:364-369）+3 行内修正（ComplexProblemSolver/research-assistant×2）+Rule 52 bullet（:290）+refs（:314）；454→461 | VC-2 PASS |
| `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/template-mapping.md` | 三处 B 类行内替换（:266 publisher/:268 双列/:278 兜底） | VC-2 PASS（净 0） |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-agent-coverage.sh` | 新建 197 行（AC-01..08；AC-04 实体存在性现查 46 名） | 8/8 PASS；CR APPROVED |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv` | +1 登记（50=50） | registry 5/5 PASS |
| 两锚演进：`selftest-skill-split.sh`（≤461）/ `selftest-requirement-coverage.sh`（RC-15 ^53） | 数值演进+注记，语义不变 | 41/41、15/15 PASS |
| 部署位 | 3 技能位 IDENTICAL；router 双位九节 +6 族行（145→151） | 部署对账 + grep 复核 |

## 3. 审查信息（尽量详细）
- **VC 复验**: 5/5 条 PASS（指针: `/mnt/data/dev/task-planner-skill/plans/task-v125/verification.md` Goal Gate 段）
- **回归**: 50 个 selftest / SUM-ASSERTIONS=**752** / FAIL=0（S7 + fresh S8 + 主仓终态三层复跑；checkpoint: `/mnt/data/dev/task-planner-skill/plans/task-v125/subagent-state/m8-executor.md`）
- **快速复核入口（Rule 48.4）**:
  1. `cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/selftest-agent-coverage.sh`（预期 `Total: 8 PASS=8 FAIL=0`——矩阵+三登记面+实体存在性一次复核）
  2. `grep -n '质量审查族\|Git 运维族' /home/terry/.zcode/skills/skill-agent-router/SKILL.md`（看 router 族行是否在位）
  3. `grep -c '^52\.' /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md`（预期 4——Rule 52 四子条）
- **对齐审查**: APPROVED（P0/P1/P2=0；指针 `/mnt/data/dev/task-planner-skill/plans/task-v125/verification.md:133-160`）
- **Code Review Gate**: APPROVED（code-quality-review 14 维 P0/P1=0；指针 `.../verification.md` CR 段）
- **委派统计**: `{"phases_total":5,"phases_delegated":3,"delegation_rate":0.600,...,"violations":[],"verdict":"ok"}` + WHITELIST-EXEMPT 放行行
- **质量门控**: Q1-Q6 触发 0 / 豁免 0 / 未处置 0；Evidence 抽查 3 条（m8 日志、S9 对账段、主仓终态复跑）
- **验证独立性**: 8 个全新独立子代理执行验证/审查（m5-m11 会话），主进程零自测替代验收

## 4. 风险点
- **已知遗留**（P2×2，不阻断）: ① `selftest-agent-coverage.sh` 建议 chmod +x（运行链一律 `bash <path>`，不影响执行）② AC-04 豁免名单为内置静态表（新增 skill 类登记名需随动注记；现表已含 25 项豁免）。
- **待裁决**: 「零专用体 9 领域」增补候选（媒体生成已由 v124 补 2；剩余：字幕/音频/音乐/翻译/DevOps/移动/游戏/应用安全）——清单在 `agent-coverage.md` §四，建议按实际任务频率逐批增补（本轮不扩范围）。
- **失效条件**: ① 「50 selftest/752/0 FAIL」失效判据=任一 selftest 增删（重跑全量即重验）② Rule 52 行为面失效判据=某任务 S-unit 落 general-purpose 而无登记理由（人工观察项，行为级冒烟）③ AC-04 失效判据=agents 目录缺失时 fail-open SKIPPED（设计如此）。
- **回滚方式**: `cd /mnt/data/dev/task-planner-skill && git revert -m 1 c38a5fc2a653b9a54815f822a46dce30a450c4e2`；router 部署位回滚=按备份或重写六族行删除；Rule 52 编号释放=`bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/rule-reserve.sh release 52 task-v125`。

## 5. 下一步建议（按推荐排序）
1. **[推荐]** 行为级冒烟（新会话）：给一个真实任务（如「批量生成 3 张产品图」）规划期选执行体，看点=是否按 Rule 52.1 命中 `image-generation-executor` 或矩阵族行（对照 `agent-coverage.md` §一）；动作=若见无理由落 general-purpose，把该计划 Executor 字段与派发记录回传，触发 Rule 52 消费面复查。
2. 零专用体 9 领域增补裁决（对象=`agent-coverage.md` §四；动作=按频率勾选下一批增补对象，后续可仿 task-v124 模式逐批落地）。
3. P2×2 清理（可与任意下次技能修改任务合并）。
