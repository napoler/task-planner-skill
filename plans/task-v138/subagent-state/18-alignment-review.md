# sub:18 — Phase 4 S3 对齐审查（Rule 42.6.2 标准收尾）

- 任务：task-v138（Rule 55 可复用能力落盘纪律）对齐审查
- 审查基准：`plans/task-v138/task_plan.md`（R1-R4 原文 + 根源覆盖表八工序 + VC 表）
- 审查对象：主仓 `/mnt/data/dev/task-planner-skill` @ `5ed69e7`（工作区实文件 Read，非 worktree）
- 模式：只读审查，零仓库文件改动
- 日期：2026-10-06

## 结论

**APPROVED**（0 项 P0/P1 不对齐；2 项 LOW 陈旧性观察，均不阻断终验）

---

## 判定面 1 — R1-R4 逐条机制载体（每条 ≥1 个可指认载体）

| R | 需求要点（原文锚） | 机制载体（file:line） | 判定 |
|---|---|---|---|
| R1 | 「常用的功能、可复用的功能及时落盘到一个固定的脚本或者固定文档中」 | 条款 `critical-rules.md:619`（55.3 首次成功即落盘：可脚本化→`scripts/capabilities/` / 纯知识→`references/`，「落盘是任务 DoD 的一部分」）+ `:620`（55.4 固定位置）；实体 `skills/task-planner/scripts/capabilities/agnes-quota.sh`（211 行，`bash -n` 过，CP-10/CP-11 PASS）+ `skills/task-planner/references/capability-registry.md:10`（首条登记） | **COVERED** |
| R2 | 「确保后期不会重新再执行一遍弱智的功（能）」 | 条款 `critical-rules.md:617`（55.1 复用前置检查：「命中既有脚本或登记行 → **直接复用，禁止现场重新实现**」）+ `:621`（55.5 执行体接线，「条款无挂点=条款死文（53.2 反例）」）；挂点 `companion/agents/video-generation-executor.md:43`、`companion/agents/image-generation-executor.md:42`（各 1 行，复用前置检查段内） | **COVERED** |
| R3 | 「正常应该是直接通过API继续获取……产出的结果就是一个莫名其妙的完全不对的结果」 | 条款 `critical-rules.md:618`（55.2 权威来源优先禁令：耗时累计反推/抽样估算/记忆拼接一律禁止，附本任务 P1 探针判例「间接观测值冒充直查值」）；脚本行为 `scripts/capabilities/agnes-quota.sh:169-183`（判定段：非 200 → 显式失败 verdict + `exit 5`，仅两码均 200 才进二态判定与 exit 0）+ `:24-26`（反模式判例注释）；机器守护 `scripts/selftest-capability-persistence.sh` CP-19（404 → exit=5 失败语义）/ CP-20（200 → exit 0 verdict 含「未填充」），本次实跑 20/20 PASS | **COVERED** |
| R4 | 「机制落在 task-planner 技能体系=通用执行纪律（覆盖一切任务链），视频额度查询为其首个落盘实例；非仅视频个案补丁」 | 载体 = `references/critical-rules.md:613` `### 55 可复用能力落盘纪律`（技能体系通用条款层，非视频项目文件；55.1 判别特征表述为「查询类外部事实/已重复≥2次的固定多步流程/存在权威数据源的操作」，与视频无关的通用判据）；注册表首条 8 列完整 `references/capability-registry.md:8-10`（CP-08/CP-09 PASS，表头 8 列=首条 8 字段全非空）；通用性机器面 `scripts/selftest-capability-persistence.sh` CP-01..CP-20 全部锚定 Rule 55 通用条款/注册表/目录锚，非视频特化；三宿主部署位逐位 IDENTICAL（`~/.zcode`/`~/.claude`/`~/.config/opencode` 的 `skills/task-planner/references/capability-registry.md` 均 `diff -q` 无漂移） | **COVERED** |

R4 反向核查（确认「非个案补丁」）：视频额度只是**注册表首条**（`capability-registry.md:10`）与 55.5 挂点示例；55.3/55.4 的落盘义务、55.1 的判别标准、55.6 的守护均以「可复用操作」泛指表述，CP-16 零新 config 键锚、CP-05/CP-06 SKILL 纪元演进收口均与视频无关 → 机制面通用性成立。

---

## 判定面 2 — 根源覆盖表八工序逐行核销

| 工序 | 修复点（计划声明） | 落地证据（file:line） | 判定 |
|---|---|---|---|
| ① 需求识别 | Rule 55.1 三条可复用判别特征 | `critical-rules.md:617`（①查询类外部事实 ②已重复≥2次固定多步 ③存在权威数据源） | **核销** |
| ② 执行前复用检查 | Rule 55.1 必查注册表+脚本目录 + 55.4 固定位置 | `:617`（必查 `references/capability-registry.md` 与 `scripts/capabilities/`）+ `:620`（脚本固定置 `skills/task-planner/scripts/capabilities/`，注册表固定置 `references/capability-registry.md`） | **核销** |
| ③ 执行方法选取 | Rule 55.2 权威来源优先禁令 | `:618`（间接推算一律禁止；不可得才允许且须标「推算值+方法+未验证」）+ 脚本判定段 `agnes-quota.sh:169-183` | **核销** |
| ④ 首次成功后的落盘 | Rule 55.3 落盘计入 DoD | `:619`（「已成功执行可复用操作而未落盘 = 任务不完整」）+ 实例 `scripts/capabilities/agnes-quota.sh`（185 行首版 @62561a1，F1 修复后 211 行） | **核销** |
| ⑤ 索引与可发现 | Rule 55.4 注册表 8 列唯一索引 + 三宿主同步 | `:620`（8 列字段枚举）+ `references/capability-registry.md:8`（表头 8 列）`:10`（首条 8 字段）+ CP-08/CP-09 PASS + 三宿主 IDENTICAL | **核销** |
| ⑥ 下一次任务的实际复用 | Rule 55.5 执行体接线 + 55.6 selftest 静态守护 | `:621`（55.5 SOP 指向行，引用 53.2 条款死文反例）+ `video-generation-executor.md:43` + `image-generation-executor.md:42`（对称接线，Phase 1 判定额度为账户级）+ CP-14/CP-15 PASS | **核销** |
| ⑦ 机制防复发 | `selftest-capability-persistence.sh` + `selftest-registry.tsv` 登记（零新 config 键） | `scripts/selftest-capability-persistence.sh`（267 行，CP-01..CP-20，本次实跑 `Total: 20 PASS=20 FAIL=0`）+ `scripts/selftest-registry.tsv:54`（第 54 行=本任务登记行，末列 dep_anchors 写 `config properties=40`）+ CP-16（config.json `.properties` 键数实测 **40**，与既有脚本口径一致） | **核销** |
| ⑧ 部署与合并 | smart-merge-back --deploy + 逐位 IDENTICAL | `git log` HEAD=`5ed69e7 Merge branch 'wt/task-v138b'`；`git worktree list` 仅剩主仓一行（wt/task-v138 已清理）；三宿主 `references/capability-registry.md` 逐位 `diff -q` = IDENTICAL；`plans/.rule-reservations.jsonl` 末行 `{"rule":55,"status":"landed","task_id":"task-v138","ts":"2026-10-06"}` | **核销** |

**八工序 8/8 核销。**

---

## 判定面 3 — 变更纪律

### 3.1 纯增量合规（v138 范围内禁净删）

v138 自身三个 commit 的 numstat（`git show --numstat`）：

| commit | 文件 | +/- |
|---|---|---|
| d6cc6c8（Phase 2 条款+索引） | `references/critical-rules.md` | **+13/-0**（纯增量，Rule 55 块落在 :613-622，位于 53.5/`### 54` 之后文件尾） |
| d6cc6c8 | `SKILL.md` | +4/-3（3 处删行均为**纪元行内改写**：`:9` 全集 1-53→1-55、`:268` `Rules 40-53 全集`→`40-55 全集`、`:334` References 表行追加 `Rule 54/55`，均在执行范围表登记的唯一例外内，禁净删成立） |
| d6cc6c8 | 4 个既有 selftest | 纪元断言同步（`1-53`→`1-55`/`40-53`→`40-55`/`≤478`→`≤490`），已由 Decisions Made 2026-10-05 silent 授权登记（RR-09/RR-16/R-09/SR-08），属纪元跟随非语义削弱 |
| 62561a1（Phase 3 资产+接线+守护） | 6 文件 | **+375/-0 全纯增**（registry +10、agnes-quota +185、selftest +177、tsv +1、两 executor 各 +1） |
| 8b12495（Phase 4b F1 修复） | 2 文件（均为 v138 自建新文件） | agnes-quota +47/-21、selftest +91/-1（-1 为头注释断言计数 18→20 行内改写） |

**关键归属澄清**：`git diff b03fd36..5ed69e7 -- references/critical-rules.md` 显示的 2 处删行（`-41.1 消解优先原则`、``-53.3 决策管辖二分`）**归属 v139 commit `536e07d`**（该 commit numstat = critical-rules 2 insert/2 delete，且 `git show 536e07d` 内含这两行），不在 v138 范围 → **v138 范围内零净删，合规**。

`config.json` 在 `b03fd36..5ed69e7` 全程未被触及（`git diff --name-only` 命中 0 行），`.properties` 键数实测 **40**，零新 config 键承诺成立。

### 3.2 归属边界核对（v139/v136 改动不计本任务范围）

`b03fd36..5ed69e7` 内 `-- skills/task-planner` 变更 15 文件，其中属 v136 的 5 文件（`selftest-execution-honesty.sh` +160、`selftest-reliability-institution.sh` +8/-3 混合、`templates/delivery-summary.md` +1、tsv +1、SKILL C38/Rule 54 bullet）与属 v139 的 1 文件（`selftest-self-resolution.sh` +10/-5、`selftest-root-resolution.sh` +37/-28、`selftest-skill-split.sh` +4/-3 部分行）已排除；v138 资产 = critical-rules Rule 55 块、SKILL 三处 Rule 55 联动、capability-registry.md、agnes-quota.sh、selftest-capability-persistence.sh、tsv 登记行、两 executor 接线行。**归属划分无侵占。**

---

## 判定面 4 — 交叉引用真实性

Rule 55 块（`:613-622`）引用的全部 Rule 编号在 `critical-rules.md` 中实存核验：

| 引用 | 目标实存 | 行号 |
|---|---|---|
| Rule 23.10 | ✓ | `:526` 段（grep `^23.10` = 1） |
| Rule 43.1 / 43.6 | ✓ / ✓ | grep 各 = 1 |
| Rule 51.8 | ✓ | grep = 1 |
| Rule 34.3 | ✓ | grep = 1 |
| Rule 45 | ✓ | `### 45 注释完整性规范` @ `:470`（子条 45.1-45.7 @ `:474-480`） |
| Rule 53.2 | ✓ | `:590` 根治判据（防复发测试） |
| Rule 54.1 | ✓ | `:599` 就绪语义 |
| Rule 36.5 | ✓ | grep = 1 |
| Rule 22.3.0 | ✓ | `:164` 资料先行档 |
| Rule 41.2 | ✓ | grep = 1 |
| Rule 42.6（本 S-unit 依据） | ✓ | `:445` + 子条 42.6.1-42.6.4 @ `:446-449` |

**11/11 交叉引用真实，无悬空编号。**

---

## LOW 观察（不阻断，供后续维护窗口消费）

**LOW-1｜55.2 内嵌状态注记已陈旧**：`critical-rules.md:618` 写「Rule 54.1（资源状态第一手验证，task-v136 **预留未落地**）」。事实：v136 已于同日 `b2d38e5` 落地 Rule 54 并合并（`1992566`），Rule 54.1 @ `:599` 现为已落地条款。语义指向正确，仅括号内状态注记滞后。修法（单行、行内改写禁净删）：将该括注改为「Rule 54.1（资源状态第一手验证，task-v136 已落地）」。责任方：下个动 critical-rules.md 的任务（v138 已合并，建议不为此重开分支）。

**LOW-2｜VC-5 字面总数 52 与实测 53 的口径差**：VC-5 写「总数 51+1=52」，实测 `ls skills/task-planner/scripts/selftest-*.sh | wc -l` = **53**（差额 1 = v136 并行新增的 `selftest-execution-honesty.sh`）。Phase 4b S2 行已自行把基线修正为「基线 53 脚本 @fed4393 实测」，且 `selftest-capability-persistence.sh` 本次实跑 20/20 PASS、`findings [sub:16]` 记录全量 53/53 FAIL=0 → **属计划文档字面滞后，非资产缺陷**，无需修资产。

**未闭环的非本 S-unit 事项**：`[sub:15]` 的 F2-F5 四条 LOW 建议（判定正则 `0.5` 假阳性 / 纪元消息字面滞后 / 文件模式 644 vs 755 / exit3 消息未附网络计数）在 Phase 4b 有意未处理（`findings [sub:16] §⑦` 显式登记「留后续维护窗口」）——不属 R1-R4 对齐面，不影响本审查 APPROVED 结论。

---

## 变更记录三要素（Rule 42.6.3）
1. **写入前校验**：对齐 review 全程只读，零仓库文件改动；`git status` 于主仓未被本 S-unit 触碰（仅 plans/ 下 findings/progress/checkpoint 三个计划文件按契约追加）。
2. **对齐整理**：R1-R4 4/4 COVERED（各 ≥1 可指认载体）；根源覆盖表八工序 8/8 核销；变更纪律（纯增量 / 零新 config 键 / 归属边界）三项全过；交叉引用 11/11 真实。
3. **结论**：**APPROVED**，无 P0/P1 遗留；2 项 LOW 陈旧性观察已登记，不阻断终验。
