# 4b — 计划 VC 逐条复验（Rule 84.3 终验前 V-N 实跑）

- 时间: 2026-10-23
- 工作目录: /mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023
- 分支: wt/task-nopause-execfirst-20261023
- 复验前 `git status --short`: 无输出（工作树干净）
- 复验后 `git status --short`: 无输出（本次复验未修改任何仓库文件，未执行 git 写）

---

## VC-1 — critical-rules-discipline.md 含 Rule 95 / 95.4 / 暂停前三问

**命令原文**
```
cd /mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023 && grep -c "Rule 95" skills/task-discipline/references/critical-rules-discipline.md && grep -c "95\.4" skills/task-discipline/references/critical-rules-discipline.md && grep -c "暂停前三问" skills/task-discipline/references/critical-rules-discipline.md
```

**退出码**: 0

**输出原文**
```
1
1
1
```

**证据行（追加定位，grep -n）**
- L619: `**建制（为什么有这条）**：用户 2026-10-23 /goal 指令... 本条（Rule 95）补位：给出一切暂停的必要性判定器与执行优先默认序，禁逐案补丁。`
- L626: `- **95.4 暂停前三问（泛化判定器）**：任何暂停/询问前必须自答——① 此暂停阻止什么具体损失？② 是否存在直接推进的替代路径？③ 暂停期间用户资源是否流失？...`

**判定**: **PASS**（三项计数均 ≥1，退出码 0）

---

## VC-2 — video-generation-executor.md 无"询问额度"类措辞，且含"执行即探测"

**命令原文**
```
cd /mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023 && bash -c '! grep -qE "是否有额度|询问.{0,12}额度|额度.{0,12}询问" skills/task-planner/companion/agents/video-generation-executor.md && grep -q "执行即探测" skills/task-planner/companion/agents/video-generation-executor.md'
```

**退出码**: 0

**输出原文**: （无输出，纯退出码判定）

**拆解证据**
- 否定项 `grep -nE "是否有额度|询问.{0,12}额度|额度.{0,12}询问"` → 无匹配，NEG_GREP_EXIT=1（`!` 取反后为真，符合预期）
- 肯定项 `grep -n "执行即探测"` → POS_GREP_EXIT=0，匹配两条：
  - L19: `- **成本纪律**: 视频调用昂贵——单镜试水先行（smoke-test 不裸调），试水 PASS 即自动扩批；额度状态执行即探测（Rule 95.1）：零报错时禁止向用户求证或预报备剩余配额与消耗量（非必要暂停=Rule 95.0 严重违规），HTTP 402/配额拒绝=持证据停止上报；中文 prompt 先译英文`
  - L43: `- **额度/配额查询复用（Rule 55.1/55.5）**：... 额度不可查询（无通道/计费层未填充）时执行即探测（Rule 95.1）——直接发起任务，成功=有额度，失败=持第一手证据处置，禁止在零报错时向用户求证或预报备消耗`

**判定**: **PASS**

---

## VC-3 — image-generation-executor.md 含"处置自主"且含"推给用户"

**命令原文**
```
cd /mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023 && grep -q "处置自主" skills/task-planner/companion/agents/image-generation-executor.md && grep -q "推给用户" skills/task-planner/companion/agents/image-generation-executor.md
```

**退出码**: 0

**输出原文**: （无输出，纯退出码判定）

**证据行（grep -n）**
- L48: `4. 三检逐项过；FAIL → 定位维度（提示词/模型随机/参考/规格）→ 修词重抽（≤预算）；质检处置自主化：处置在预算内自主循环（定位→修词→重抽→复检），结论+证据随批次报告呈报（Rule 70 四要素），禁止把可自主复检/重抽得出的处置决策以提问形式推给用户（Rule 95.3；验收裁决权仍归主进程/用户）`

**判定**: **PASS**

---

## VC-4 — 引用已有全量回归结果（不重跑套件）

**命令原文**
```
grep -n "FAIL=0" /mnt/data/dev/task-planner-skill/plans/task-nopause-execfirst-20261023/subagent-state/4a-selftest.md
```

**退出码**: 0

**输出原文（节选，共 30 行命中，行 15/24/33-62）**
```
15:Total: 92 PASS=92 FAIL=0 (run=92 reused=0)
24:**PASS** — FAIL=0，符合判定标准（末行 `Total: N PASS=x FAIL=y` 且 FAIL=0）。
62:Total: 92 PASS=92 FAIL=0 (run=92 reused=0)
```

**核对结论**
- 检查点文件存在：`/mnt/data/dev/task-planner-skill/plans/task-nopause-execfirst-20261023/subagent-state/4a-selftest.md`（2942 bytes，mtime 2026-10-24 02:10）
- 含 `Total: 92 PASS=92 FAIL=0 (run=92 reused=0)` 末行，且记录 `--fresh` 全量重跑、rc=0、两次执行结果一致（可复现）
- 按指令未重跑套件

**判定**: **PASS**

---

## VC-5 — 部署 diff

**判定**: **PENDING-MERGE**（属合并后项，本轮不执行）

---

## VC-6 — 账本 land

**判定**: **PENDING-MERGE**（属合并后项，本轮不执行）

---

## 汇总

| VC | 判定 |
|----|------|
| VC-1 | PASS |
| VC-2 | PASS |
| VC-3 | PASS |
| VC-4 | PASS |
| VC-5 | PENDING-MERGE |
| VC-6 | PENDING-MERGE |

- 未修改任何仓库文件；未执行任何 git 写操作（复验前后 `git status --short` 均为空）。
