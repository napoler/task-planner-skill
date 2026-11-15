# Critic 独立复检 R2 — task-tpl-sediment-20261115（对 R1 CHANGES_REQUESTED 的修复复核）

- 复检时间：2026-11-15
- 复检对象：worktree `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115` commit `ff2d992`（修复批次，9 文件 +12/-12；基线 `8bc8e86`）
- 复检方式：逐项 grep/Read 回读 9 个修复点 + diff 全文审阅 + 全量 selftest 实跑 + 同类反模式全域扫描
- 结论：**CHANGES_REQUESTED** —— C-1..C-9 全部修复到位、ff2d992 自身零新回归；但同类反模式在交付面仍有 2 类残留（C-10 断链路径 1 处、C-11 计数窗 6 处），均落在本批已触碰文件内，修复成本极低

---

## A. C-1..C-9 逐项复核

| 项 | verdict | 证据 |
|----|---------|------|
| C-1 | **PASS** | `grep -c 'findings F' skills/plan-template-advisor/SKILL.md` = **0**（exit 1=无匹配）；机制锚三处齐：`init-session.sh 项目级模板发现机制` / `check-template-type.sh 白名单校验` / `render_template fail-closed 契约`；全文无 `F<n>`/`CA-<n>` 任务本地编号残留（:18/:53 的 `findings.md`/`notepad-learnings` 为核心 7 计划文件名，非本地 findings 编号，合法） |
| C-2 | **PASS（但见 C-10）** | `grep -rn 'plan-template-advisor/references' skills/task-planner/` = **0**；`plan-template-advisor/SKILL.md` 指向数：SKILL.md=1、README=1、ARCH=3（:69 注释 + :78 + :105）；`ls skills/plan-template-advisor/` 仅 SKILL.md（references/ 确不存在，改指 SKILL.md 正确）；路径实测 README `../`、ARCH `../../` 均可解析 |
| C-3 | **PASS** | `critical-rules.md:178` 现为「其余规则归 **7** 个既有卫星（plan-research-router/plan-template-kit/plan-collab-router/plan-cost-guard/plan-resume/progress-tracker/task-drift-guard）」，枚举实数=7 且 **advisor 已剔除**；`grep '8 个既有卫星'`=0；路由索引行 `:201` 保留（advisor 命中=1） |
| C-4 | **PASS** | `grep -c '非独立入库通道'` = 1；该文件 `git diff --numstat 8bc8e86..ff2d992` = `1 1`（仅 34.8 单行改，34.7/34.9 为上下文行零改动）；`^34\.[0-9] \*\*` 锚=9（34.1-34.9 无缺失）；衔接语义成立：「34.7 全自动合约触发生成的候选同样须过本条官方门 G1-G4 方可写入 templates/variant/（34.5 双闸门=G3 的查重/泛化性输入，非独立入库通道）」 |
| C-5 | **PASS** | `template-candidate/rule-clause-cascade-type.md`：39 行（≤100）、机读头 `<!-- template_type: rule-clause-cascade-type -->` 在位、五结构块齐（Goal / VC 表≥2〔实 3 行 VC-1..3〕/ Phase 骨架 / 执行范围限制 / 必要知识储备）；幽灵路径已改 `skills/task-planner/README.md`、`skills/task-planner/docs/ARCHITECTURE.md`（:14/:19/:38）；`F11/F12` 本地引用 **=0**，改为机制名锚（:24「落位指针机制名锚定，禁任务本地编号引用」、:39「init/render 签名误用（init-session.sh 调用签名契约）」） |
| C-6 | **PASS** | `install-stub.sh:40` = 「本行只登记 install-stub 显式 rsync 的 **8 个**」；`SATELLITE_SKILLS`(:41) 实解析 = 8 元素（脚本计数验证：8）——注释与数组一致（同类残留见 C-11） |
| C-7 | **PASS** | `grep -rn '第 12 卫星' skills/` = 3（verification-gate/SKILL.md:3、:10、references/critical-rules-verification.md:3）；`grep -rn '第 11 卫星' skills/` = **0** |
| C-8 | **PASS** | 三张路由表 advisor 行均居新域组（media-planner 之后）：SKILL.md:211→**212**、README.md:71→**72**、ARCH §2.1:77→**78**、ARCH §3:104→**105**，四表位次一致 |
| C-9 | **PASS** | ARCH §2.1:78 两列已实质化且不重复：定位=「管「项目模板适配与沉淀生产」——激活后分析当前项目→预测问题→缺口映射→产出候选模板→审查→登记入库的轻量 SOP 执行体」；域边界=「不管官方模板选型/生命周期（归 plan-template-kit）、机械发现/模板校验脚本（归 task-planner 脚本层）；规则承载=Rule 34.8/34.9 随 SKILL 内联」；规则数列 `0（内联）`（无脚本解析 ARCH，见负结果报告） |

---

## B. R2 新发现（R1 遗漏 / 同类反模式残留，均 pre-existing at 8bc8e86，非 ff2d992 引入）

**[🟡WARNING] C-10** `skills/task-planner/references/critical-rules.md:201`
- 原文：「规则全文见 `../plan-template-advisor/SKILL.md`（规则随 SKILL 内联）」
- 原因：该文件位于 `skills/task-planner/references/`，`../plan-template-advisor/SKILL.md` 解析为**不存在的** `skills/task-planner/plan-template-advisor/SKILL.md`（实测 ENOENT），应为 `../../plan-template-advisor/SKILL.md`；同索引其余 9 条路径全部为 `../../<sat>/`，仅此行深度少一级——疑为从 SKILL.md:212 行（基准目录为 `skills/task-planner/`，`../` 才正确）复制行时未换基准
- 性质：R1 **C-2 原文把此路径当作「正确形态」反例引用**，判定有误；属 C-2 同族「指针不可达」缺陷的漏网项
- 影响：权威规则索引第 10 条为断链，agent 按索引 Read 得 ENOENT 后退化到 grep 兜底
- 置信度: HIGH（`ls` 实测 + 9/10 同类行口径对比）

**[🟡WARNING] C-11** `SATELLITE_SKILLS` 计数窗 6 处仍写「7」（数组实为 8）
- 位置与原文：
  1. `skills/task-planner/README.md:113`：「`SATELLITE_SKILLS` 数组登记 **7 个卫星**（4 既有 + 3 新域）」
  2. `skills/task-planner/README.md:150`：「install-stub.sh # 每工具部署位安装（:41 SATELLITE_SKILLS 登记 **7 卫星**）」
  3. `skills/task-planner/lib/install-stub.sh:246`：「仓库顶层 skills/ 下 **7 个卫星**(4 既有+task-v171 S39 追加 3 新域」
  4. `skills/task-planner/lib/install-stub.sh:304`：「**7 卫星**技能（task-v171 S39 起 4→7）整目录安装到工具位同级 skills/ 目录」
  5. `skills/task-planner/docs/ARCHITECTURE.md:160`：「每工具部署位安装（:41 SATELLITE_SKILLS 登记 **7 卫星**显式 rsync）」
  6. `skills/task-planner/docs/ARCHITECTURE.md:182`：「`SATELLITE_SKILLS` 显式登记 **7 个**（4 既有 + task-v171 S39 追加 …）」
- 原因：`8bc8e86` 向数组尾追加 `plan-template-advisor` 后实为 8 元素（实测=8），C-6 仅修 :40 一处，其余 6 处「同源锚」未同改——正是本任务自身条款 34.7 确立的「计数级联：同源锚必同改（v093 教训）」与 CA-10/C-6 同类反模式
- 性质：注释/文档层，零运行期行为影响；但均在**本批已触碰文件**（README/ARCH/install-stub）内，且是任务自身质量标的（计数窗）的直接违反
- 置信度: HIGH（`grep -rn '7 卫星\|7 个卫星'` 定位 + 数组元素基数实测 8 + `git show 8bc8e86` 确认 6 处均为 pre-existing）

---

## C. 回归抽查（全部通过，ff2d992 零新回归）

| 检查 | 命令 | 结果 |
|------|------|------|
| VG 自测 | `bash skills/task-planner/scripts/selftest-verification-gate.sh` | **Total: PASS=13 FAIL=0，exit 0** |
| 文件集 | `git diff 8bc8e86..ff2d992 --stat` | **9 文件，+12/-12**，与预期集完全一致，无意外文件 |
| 工作树 | `git status --short` | **空（clean）** |
| 模板生命周期 | `selftest-template-lifecycle.sh` | 24 PASS=24 FAIL=0 |
| 技能拆分 | `selftest-skill-split.sh` | 40 PASS=40 FAIL=0 |
| 全量套件 | `run-selftests.sh --fresh` | **97 项：PASS=95 FAIL=2**（详见下） |

**全量套件 2 项 FAIL 归因（非本批引入）**：
- `selftest-active-plan` T11 FAIL（attest-plan.sh side 指针锁定夹具）
- `selftest-execution-stability` T11b FAIL（重锁洗白负例）
- 归因证据：① 两测试脚本在 `8bc8e86..ff2d992` 间**零改动**（diff 文件集不含它们）；② 两脚本对 9 个改动文件的引用命中数 **=0**（`grep -cE 'plan-template-advisor|SATELLITE_SKILLS|ARCHITECTURE|install-stub|critical-rules-template|verification-gate'`）；③ 二者均为自建 tmp 夹具 + attest-plan.sh 行为断言，与文档/计数改动无因果链 → 逻辑上在基线提交同样失败（环境/历史漂移，非本批）
- 建议：另案排查（不阻塞本任务），与 R1 观察项「Rules 1-97 vs 1-107 漂移」同类处理

---

## D. 负结果报告（已检查、预期有问题但未发现 / 已排除）

- `第 11 卫星` 在 `skills/` 全域 = **0**（C-7 修复彻底；ARCH:124 等历史注释形态亦未命中）
- `8 个既有卫星` = **0**（C-3 枚举已正确回退 7）
- 候选模板内 `F1[0-9]`/`判例 F` = **0**；仓根 `README.md`/`docs/` 裸路径 = **0**（仅 `skills/task-planner/...` 全路径）
- `plan-template-advisor/references` 在 `skills/` 全域 = **0**（C-2 彻底）；主仓 `plans/…/` 仅 `findings.md:38` 的 F15 审计回执文本提及（历史记录，非产物指针）
- 主仓 drafts 同步：`advisor-draft.md` `findings F`=0 且机制锚=1；`clause-drafts.md` `非独立入库通道`=1（源稿与 worktree 产物一致，后续 G2/G3 不会回带缺陷）
- ARCH §2.1 规则数列 `0（内联）` 是否破坏机读：`grep -rn 'ARCHITECTURE' skills/ --include=*.sh` = **0 命中**，无任何脚本解析该表 → 非缺陷
- `SATELLITE_SKILLS` 硬编码计数断言：除 `install-stub.sh` 自身外全域 **0 命中**（无测试断言卫星数=7/8）→ C-11 为纯注释漂移，不叠加测试失败
- 34.1-34.7/34.9 原文零改动（diff 1/1 单行）；`^34.N` 锚 9 个无缺失
- 已排除：C-8 的 `critical-rules.md:201` 位次（在 plan-template-kit 之后）非缺陷——该索引为规则编号邻接排序（advisor 消费 Rule 34.8/34.9，紧随其宿主 plan-template-kit），与三张表「新域组」分组是两套各自自洽的口径

---

## E. 验证摘要

总发现 11（R1 9 项复核全 PASS + R2 新发现 2 项 WARNING）/ 全部以 grep·ls·git show 复现原文 / 复核通过率 9/9 = 100% / 回归抽查 6 项，本批引入回归 0
