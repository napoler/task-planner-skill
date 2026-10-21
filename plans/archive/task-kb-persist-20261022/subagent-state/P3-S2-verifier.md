# P3-S2 独立验证者检查点 | task-kb-persist-20261022

- 角色：独立验证者（全新上下文，只读 + 写本检查点）
- 验证对象：worktree `/home/terry/task-planner-skill-worktrees/kb-persist-20261022/`
- 时间：2026-10-22
- 声明：本次验证**未修改任何仓库文件**。VC-3 运行 `kb-sync-from-plan.sh` 会重写 `knowledge/entries/_draft-task-v122.md`，但该文件为脚本自述的派生物（"draft 是派生物：同名已存在直接覆盖（可随时重建）"），重跑前后 md5 一致（`b85b137dd6ea8da2675b58eeca899f6e`），`git status --short` 与 `git diff --stat` 均为空 → 无实际改动。

---

## VC-2 检索实弹 —— PASS

命令原文：
```
cd /home/terry/task-planner-skill-worktrees/kb-persist-20261022 && bash scripts/kb-search.sh 锚点 | head -25
```

输出摘录：
```
== knowledge/INDEX.md
10:| guard-anchor-selftest-cascade | "锚点级联与 selftest 锁步规律" | [锚点级联, 宽容锚, selftest, 纪元扩容, 撞号恢复] | plans/archive/task-v158-source-anchor-discipline/delivery-summary.md<br>... | entries/guard-anchor-selftest-cascade.md |
== knowledge/README.md
36:  证据锚段须给 `file:line` 级锚点，写必带锚（Rule 71.2 写入前五问自检）。
== knowledge/entries/_draft-task-v122.md
  title: "（draft）task-v122 知识蒸馏待精炼"
  tags: [draft, 未精炼]
  sources: [plans/archive/task-v122/knowledge-brief.md, plans/archive/task-v122/findings.md]
== knowledge/entries/discipline-execution-honesty.md
  title: 执行纪律与能力沉淀
  tags: [执行诚实, 错误闭环, 能力沉淀, 验证优先, 知识管理]
  sources:
    - plans/archive/task-v072-error-loop/task_plan.md
    - plans/archive/task-v157-error-fix-prompt-forge/knowledge-brief.md
    ...
```

补充实测（去掉 `head` 取真实退出码）：
```
bash scripts/kb-search.sh 锚点 > /tmp/vc2_out.txt 2>/tmp/vc2_err.txt; echo "EXIT=$?"
→ EXIT=0   STDERR=[]   lines=113
命中文件 11 个：
  knowledge/INDEX.md, knowledge/README.md, knowledge/entry-template.md,
  knowledge/entries/{_draft-task-v122, discipline-execution-honesty, discipline-research-evidence,
    dispatch-lifecycle-return-contract, dispatch-split-decision, guard-anchor-selftest-cascade,
    misc-task-typing-and-execution-gates, worktree-parallel-pointer-race}.md
```

判定依据逐条核对：
- 是否命中条目：命中 11 个文件（9 个 entries + INDEX/README/entry-template）。PASS
- 命中输出是否含 title/tags/sources 摘要：每个命中文件均输出 `  title: ` / `  tags: ` / `  sources: ` 三行摘要，sources 为多行列表逐行展开。PASS
- sources 是否为 plans/archive 仓相对路径：是。全部形如 `plans/archive/<task-id>/<file>.md`，无 `/home/terry/...` 绝对路径。PASS
- 退出码：0（`head` 造成的 141 为 SIGPIPE，属管道行为，非脚本错误；去 `head` 后确认 exit 0）
- 后端：`rg` 存在于 `/usr/bin/rg`，走 rg 分支

---

## VC-3 入库实弹 —— PASS

命令原文：
```
cd /home/terry/task-planner-skill-worktrees/kb-persist-20261022 && bash scripts/kb-sync-from-plan.sh plans/archive/task-v122
```

输出摘录：
```
注: 同名 draft 已存在，覆盖: /home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/entries/_draft-task-v122.md
OK: 已生成 /home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/entries/_draft-task-v122.md (47 行)
### EXIT=0
```

draft frontmatter：
```
---
id: draft-task-v122
title: "（draft）task-v122 知识蒸馏待精炼"
tags: [draft, 未精炼]
sources: [plans/archive/task-v122/knowledge-brief.md, plans/archive/task-v122/findings.md]
updated: 2026-10-22
---
```

sources 仓相对路径断言：
```
grep "^sources: \[plans/archive" knowledge/entries/_draft-task-v122.md
→ sources: [plans/archive/task-v122/knowledge-brief.md, plans/archive/task-v122/findings.md]   (grep exit=0)
```

判定依据逐条核对：
- exit 0：是。PASS
- draft 文件生成：是，`knowledge/entries/_draft-task-v122.md`，47 行，含 frontmatter 五键 + §2/§3/§4 提取正文 + 末尾精炼指引注释。PASS
- sources 为仓相对路径：是（`plans/archive/task-v122/...`）。PASS
- 幂等性：连续两次运行，产物 md5 恒为 `b85b137dd6ea8da2675b58eeca899f6e`。PASS
- 附带观察（非 FAIL）：draft 正文标题行含绝对路径
  `# （draft）task-v122 知识蒸馏（来源: /home/terry/task-planner-skill-worktrees/.../knowledge-brief.md）`
  —— 仅影响可读性/可移植性提示，不违反本项判据（判据只看 frontmatter `sources:`）。建议后续精炼 draft 时把该行改为仓相对路径（非阻断项）。

---

## VC-7 三主题查询 —— PASS

命令原文（依次执行）：
```
bash scripts/kb-search.sh 派发 | head -6
bash scripts/kb-search.sh worktree | head -6
bash scripts/kb-search.sh 部署位 | head -6
```

### 主题一：派发
命中条目（含 INDEX/README 噪声）全量：
```
knowledge/INDEX.md, knowledge/README.md,
knowledge/entries/discipline-execution-honesty.md,
knowledge/entries/discipline-research-evidence.md,
knowledge/entries/dispatch-lifecycle-return-contract.md,   ← 语义主命中
knowledge/entries/dispatch-split-decision.md,              ← 语义主命中
knowledge/entries/guard-attest-completion-gates.md,
knowledge/entries/misc-skill-institutionalization-precedents.md,
knowledge/entries/misc-task-typing-and-execution-gates.md,
knowledge/entries/planflow-plan-lifecycle-gates.md,
knowledge/entries/worktree-parallel-pointer-race.md
```
语义判定：命中 `dispatch-lifecycle-return-contract`（返回契约）与 `dispatch-split-decision`（派发与拆分决策）——是主题同域条目，不是"仅碰关键词"（对比：`discipline-execution-honesty` 的命中行是「需要输出结论/交付物并附验收判据（含派发修正任务书）时」，属弱相关旁支）。
抽读 `dispatch-lifecycle-return-contract.md` `## 结论（可直接复用）` 第 10 条（line 32）：
```
10. **派发守卫机械判据（22.4c）+ prompt 纪律**（task-v057/v153）：PreToolUse hook 对 `Agent` 调用跑
    `check-dispatch.sh` —— 须含三文件绝对路径（22.4a）+ `status:`/`acceptance:`/`checkpoint:` 三 key（22.4b）
    + `subagent-state/` 路径（22.8.1）；档位 `dispatch_contract_enforce` = off/warn/enforce（enforce → exit 2 列缺项）；
    无活跃计划或解析异常 → **fail-open 放行**。prompt 内步骤枚举（①-⑮/StepN/行首编号）**≤4**，超出被拦（本会话被拦 5 次实证）。
```
信息量判定：含具体 hook 名、脚本名、必填 key 名、档位枚举、失败码、实测计数（5 次）→ **可直接回答"派发 prompt 怎么写才不被拦"**。PASS

### 主题二：worktree
命中条目全量：
```
knowledge/INDEX.md, knowledge/README.md,
knowledge/entries/_draft-task-v122.md,
knowledge/entries/dispatch-lifecycle-return-contract.md,
knowledge/entries/planflow-plan-lifecycle-gates.md,
knowledge/entries/worktree-lifecycle-mergeback.md,       ← 语义主命中
knowledge/entries/worktree-parallel-pointer-race.md        ← 语义主命中
```
语义判定：两条 worktree 域专属条目命中，非关键词碰瓷。
抽读 `worktree-lifecycle-mergeback.md` `## 结论` 第 5 条（line 15）与第 12 条（line 24）：
```
5. **合并回合约五条（宪法 §11.3）**：① Phase 全 complete + VC 逐条复验 → ② worktree status 干净
   → ③ 主仓无重叠未提交变更（否则 STOP 报告用户）→ ④ `git merge --no-ff wt/<id>` + Read 关键文件 + `git log` 复验
   → ⑤ **必须** `git worktree remove` + `git branch -d`（遗留 `wt/*` 分支 = 未完成信号）。首锚语义=确保基线存在
   （工作区干净则登记 HEAD 为基线锚），禁无条件空提交。〔task-git-timely-commit / task-v182〕
```
信息量判定：含 5 步有序判据、具体命令（`git merge --no-ff` / `git worktree remove` / `git branch -d`）、宪法条款锚 §11.3 → **可直接回答"worktree 任务怎么合并回去"**。PASS

### 主题三：部署位
命中条目全量：
```
knowledge/INDEX.md,
knowledge/entries/dispatch-split-decision.md,
knowledge/entries/guard-attest-completion-gates.md,
knowledge/entries/misc-skill-institutionalization-precedents.md,
knowledge/entries/worktree-lifecycle-mergeback.md,        ← 语义主命中（title 即含"部署位同步"）
knowledge/entries/worktree-parallel-pointer-race.md
```
语义判定：`worktree-lifecycle-mergeback` 的 title 直接为「worktree 生命周期、合并回与**部署位同步**」，tags 含 `部署位同步` → 强语义命中，非碰词。
抽读同条目 `## 结论` 第 7/9/10/11 条（lines 19, 21-23）：
```
7. **部署位必须原子化：staging → swap → post-verify**：D4 事故（04:45:38 `~/.claude` 已写入，04:49:07 `~/.zcode`
   slot 被删后中断 → 技能全局停摆，靠仓内源原子恢复）。新契约消息=`[DEPLOY] STAGE-FAIL: <slot>`（rc=1）/
   `[DEPLOY] SWAPPED: <slot>`（逐位）/ `[DEPLOY] OK: 全部部署位 IDENTICAL`（终行 rc=0）；`--legacy` 保留
   IDENTICAL/DRIFT + exit 6。〔task-v159〕
9. **部署位同步 SOP**：canonical 主仓为唯一 truth source → `git diff --name-status` 定位范围 → 兄弟位
   `diff -rq` IDENTICAL 则零改动 → 重部署位用 `rm -rf && cp -rL`（cp 覆盖不删目标多余文件 → master 已删的
   `WORKFLOW.md` 会留残影）→ 替换前 tar 备份 /tmp → 逐位 `diff -rq` 终验 IDENTICAL。〔task-deploy-9b167fe / task-deploy-master-20260905〕
10. **部署位 ≠ 仓内全量**：仓根 `.gitignore` 不在技能目录 → 部署 diff 不含它是**预期差**，禁为「补齐」造部署差异。〔task-v164〕
11. **回滚 merge commit 必须带主父**：`git revert -m 1 <merge-sha>`（直接 revert merge 会失败）；部署位回滚由
    `smart-merge-back.sh --deploy` 从主仓重推。〔task-v164〕
```
信息量判定：含部署位清单（`~/.zcode` / `~/.claude` / `~/.config/opencode`）、具体命令序列、契约消息字面量与退出码、易错判据（cp 残影 / .gitignore 预期差）、回滚命令 → **可直接回答"部署位怎么同步/怎么回滚"**。PASS

VC-7 总判定：3/3 主题均命中语义相关条目，且结论段信息量足以回答主题问题。PASS

---

## VC-4 负例探测 —— PASS

命令原文：
```
cd /home/terry/task-planner-skill-worktrees/kb-persist-20261022 && bash scripts/kb-search.sh quantum-xyz-不存在
```

输出：
```
无命中: quantum-xyz-不存在
### EXIT=0
```

判定：无命中 → 友好提示 `无命中: <关键词>`，exit 0，无 stderr、无报错。PASS

---

## VC-5 条目质量抽查（独立抽检）—— PASS

抽检对象：`knowledge/entries/worktree-lifecycle-mergeback.md`（worktree/部署位域，**非 dispatch 域**，独立选择）

frontmatter（Read 原文）：
```
---
id: worktree-lifecycle-mergeback
title: "worktree 生命周期、合并回与部署位同步"
tags: [worktree隔离, 合并回合约, 部署位同步, git安全, 智能合并]
sources: [plans/archive/task-git-timely-commit/findings.md, plans/archive/task-v059-active-plan-race/findings.md,
  plans/archive/task-v159-pointer-lifecycle/findings.md, plans/archive/task-v159-pointer-lifecycle/subagent-state/4-code-assistant-SM.md,
  plans/archive/task-v159-pointer-lifecycle/subagent-state/4-code-runner-S8.md,
  plans/archive/task-v164-pointer-worktree-local/findings.md, plans/archive/task-v164-pointer-worktree-local/delivery-summary.md,
  plans/archive/task-deploy-9b167fe/findings.md, plans/archive/task-deploy-master-20260905/findings.md,
  plans/archive/task-v182-git-snapshot-commits/findings.md, plans/archive/task-v195-spec-recall/progress.md,
  plans/archive/task-videop1-ep03-rollback-guard/progress.md]
updated: 2026-10-22
---
```

### 5a 来源可溯源（抽 1 条 source 路径 ls 存在）—— PASS
```
$ ls -l plans/archive/task-git-timely-commit/findings.md
EXISTS: plans/archive/task-git-timely-commit/findings.md (71 lines)
EXISTS: plans/archive/task-v164-pointer-worktree-local/delivery-summary.md (60 lines)
EXISTS: plans/archive/task-deploy-9b167fe/findings.md (50 lines)
EXISTS: plans/archive/task-v159-pointer-lifecycle/findings.md (24 lines)
```
补充全量审计（12 个 entries × 全部 sources 路径去重后逐条 `ls`）：
```
EXISTING=120   MISSING=0
```
行级锚点抽样复核（确认锚点指向真实内容而非行号漂移）：
- `task-v164-pointer-worktree-local/delivery-summary.md:3` → 定位栏（三部署位路径 + 合并基线 `a849947`）✅ 匹配条目中「三部署位 post-verify IDENTICAL」表述
- `task-v164-pointer-worktree-local/delivery-summary.md:53-54` → 失效条件 / 回滚方式（含 `git revert -m 1 a849947`）✅ 匹配条目第 11 条
- `task-deploy-9b167fe/findings.md:20-31` → 变更范围（`git diff --name-status ad7900d..9b167fe`，8 files）与 9 位拓扑 ✅ 匹配条目第 9 条
- `task-v057-subagent-io-contract/findings.md:22` → 派发模板 5 行占位骨架 / 12 次派发 0 次传三文件 ✅ 匹配条目第 1 条

### 5b 结论具体可复用（含数值/命令/判据而非空话）—— PASS
抽样 `## 结论（可直接复用）` 各条，均含以下可执行要素：
- 数值：`2 文件 / 100 行 / 15 分钟`、`≤6 用例/步`、`1.24M token`、`46 次调用`、`75/75 rc=0`、合规率 `24.1% (14/58)`、floor `0.7`、RPN 96
- 命令：`ln -sfn`、`git merge --no-ff wt/<id>`、`git worktree remove`、`git branch -d`、`git revert -m 1 <sha>`、`rm -rf && cp -rL`、`diff -rq`、`git diff --name-status`
- 判据/消息契约：`[DEPLOY] STAGE-FAIL` / `SWAPPED` / `OK: 全部部署位 IDENTICAL`（rc=1 / rc=0 / exit 6）、8 字段返回契约 key 清单、attest 拒锁档位 enforce
- 事件锚：`D4 事故 04:45:38 ~/.claude 已写入 → 04:49:07 ~/.zcode slot 被删后中断`

反例排除：未发现「应加强/需注意/要小心」类空话条目；12 个 entries 中抽检的 3 条（worktree-lifecycle-mergeback / dispatch-lifecycle-return-contract / dispatch-split-decision）结论段均为可执行条目格式（带〔来源锚〕或（来源：task-xxx））。

---

## 附加冒烟（超出指定验证项，仅作参考，不影响判定）

- `--tag` 过滤可用：`bash scripts/kb-search.sh 部署 --tag worktree隔离 --limit 3` → 仅命中 `worktree-lifecycle-mergeback.md`，过滤正确。
- 库规模：`knowledge/entries/*.md` = 13 个（含 1 个 draft，即 12 个正式条目 + 1 draft）；`knowledge/INDEX.md` 表格行 13 行。
- 空库/缺参路径未触发（未做破坏性测试，缺参数 exit 2 由代码静态可读确认，未实弹）。

---

## 总判定

| 验证项 | 判定 |
|--------|------|
| VC-2 检索实弹 | **PASS** |
| VC-3 入库实弹 | **PASS** |
| VC-7 三主题查询 | **PASS** (3/3) |
| VC-4 负例探测 | **PASS** |
| VC-5 条目质量抽查 | **PASS** |

**总判定：5/5 PASS —— 知识库可用。**

唯一非阻断观察：draft 正文标题行含 worktree 绝对路径（frontmatter `sources:` 已为仓相对路径，不违反判据）；后续精炼该 draft 时可顺手改为仓相对路径。

本次验证未修改任何仓库文件（`git status --short` 仅显示验证前既已存在的未跟踪目录 `.zcode/plan-templates/`；`git diff --stat` 为空）。
