# S30 C-5 部署对账两级化 — 子代理检查点（最终结论）

- 时间: 2026-09-27
- 子代理: executor (S30)
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091
- 状态: complete（未 commit，按契约禁止 git 写操作）

## 1. 改动面（git status --short 实证）

仅 1 文件: `M skills/task-planner/scripts/smart-merge-back.sh`（56 insertions, 4 deletions）

```
 M skills/task-planner/scripts/smart-merge-back.sh
---
 skills/task-planner/scripts/smart-merge-back.sh | 60 +++++++++++++++++++++++--
 1 file changed, 56 insertions(+), 4 deletions(-)
```

## 2. 改造内容（smart-merge-back.sh）

- **头注释（:15-18、:91）**：`--deploy` 说明由「diff -rq 对账」改述为两级对账；exit 6 说明改述为「L1 文件集合差/L2 内容定向 diff 有差异」。接口/退出码语义不变。
- **:509-516 新增注释块**（含 C-5 指令要求原文行）：
  `# [2026-09-27 task-v091 C-5] 部署对账两级化：L1 确定性文件集合差（抓增/缺/改名）+ L2 内容定向 diff（git porcelain 清单）+≥3 抽检；残留面=清单外同名文件带外热改`
  附残留面明示：清单外同名文件带外热改靠 ≥3 概率抽检兜底（未抽中即漏检，记录在案）。
- **:519 新增 `_re_lines()`**：空安全行清单辅助（防 `printf '%s\n' ""` 给 comm 喂单空行误匹配）。
- **:520-557 新增 `deploy_reconcile()`**：
  - L1: `find -L <src|slot> -type f -printf '%P\n' | LC_ALL=C sort`（-L 与 cp -rL 实体化口径一致）逐行 `comm` 差 → 抓增/缺/改名；有差即打印 `[DEPLOY] DRIFT-L1` + 缺/多明细（各前 5 行）并 return 1
  - L2: git 程序化清单 `git -C $MAIN_REPO diff --name-only $MB $BRANCH -- skills/task-planner`（禁手填，来源恒为 git 输出，剥 skill 根前缀）+ 清单内∩存在（inman，删文件不入 targets 防假 DRIFT）+ 清单外同名文件取排序前 3 抽检（outman，确定性可复现）；逐目标 `cmp -s` 比对，有差打印 `[DEPLOY] DRIFT-L2` 并 return 1
  - 保守回退: 清单为空/不可用（非 git 仓/同 ref diff/失败）→ 全交集内容对比，与旧全树 diff -rq 语义等价，非静默降级
- **:603-610 调用点**（原 :555 `diff -rq` 处）：`if deploy_reconcile "$slotdir"` → 成功打印 `[DEPLOY] IDENTICAL: $slotdir (基准=主仓 skills/task-planner)`（判定行原文不变）；失败 DRIFT=1（明细行由函数先行打印）。
- **三 slot 原子替换段（cp→slotbak→mv→rm，:576-602）与 V1-V4 预检（:35-89 区段）零改动**。

## 3. 验收自测证据

### ① bash -n
```
SYNTAX_OK
```

### ② selftest-smart-merge.sh 全量原文（15/15 全绿）
```
SM-01 PASS rc=3(期望3) PRECHECK_DIRTY=在
SM-02 PASS rc=0(期望0) MERGED=在
SM-03 PASS rc=0(期望0) ALREADY=在 master无新commit=是 无MERGE_HEAD残留(...)
SM-04a PASS rc=5(期望5) MASTER_AHEAD=在
SM-04b PASS --force rc=0(期望0) MERGED=在
SM-05 PASS rc=4(期望4) SCOPE_OVERLAP=在 交集含base.txt=在
SM-06 PASS rc=6(期望6) s1-IDENTICAL=在 s2-DRIFT=在
SM-07 PASS rc=0 CLEANUP行=在 worktree保留=是
SM-08 PASS rc=6(期望6) REJECTED行数=3(期望≥3) wt-md5不变=是 main未被部署替换=是
SM-09 PASS rc=6(期望6) REJECTED含空格=在
SM-10 PASS rc=6(期望6) 真实wt注入=是 REJECTED祖先=在 ... 零改动=是
SM-11 PASS rc=8(期望8) MERGE_IN_PROGRESS=在
SM-12 PASS rc=6(期望6) HOME内部白名单外REJECTED=在 ... zcode存活+清单md5不变=是
SM-13 PASS rc=6(期望6) 部署根内主仓exact-REJECTED ... .git存活=是 主仓根清单md5不变=是
SM-14 PASS rc=0(期望0) IDENTICAL=在 slotB-SKILL_MARKER=canonical-v077(...)
Total: 15 PASS=15 FAIL=0
EXIT=0
```
断言消费核对：SM-06 grep `[DEPLOY] IDENTICAL: $T6/s1` 与 `[DEPLOY] DRIFT: $SLOT_S2`（cp 失败路径，本处未改）；SM-14 grep `[DEPLOY] IDENTICAL: $T14/slotB` 与终态内容 — IDENTICAL 判定行原文保留，两例全过。REJECTED/DRIFT(cp 失败)/部署源缺失行格式均未动。

### ③ /tmp 沙箱四场景（A/B 各 ≥8 文件: sub/f1-f5 + g1-g3，函数级抽取 deploy_reconcile 对拍）

**a. 清单内文件内容差异 → L2 报出**（fake-main git 仓 MB..BRANCH diff 含 sub/f3.txt；B 侧 f3.txt 旧内容）
```
=== a. 清单内文件内容差异 (L2 定向 diff) ===
[DEPLOY] DRIFT-L2: /tmp/s30-sandbox.ISWy/B (内容差异: sub/f3.txt)
RECONCILE_RC=1
```
a2. 清单外多文件热改（g1/g2/g3 改内容，清单仅 sub/f3.txt）→ ≥3 抽检报出：
```
[DEPLOY] DRIFT-L2: /tmp/s30-sandbox.ISWy/B (内容差异: g1.txt)
RECONCILE_RC=1
```

**b. B 多一个文件 → L1 集合差报出**
```
=== b. B 多一个文件 (L1 集合差) ===
[DEPLOY] DRIFT-L1: /tmp/s30-sandbox.ISWy/B (文件集合差: 缺/多如下)
  多余: extra9.txt
RECONCILE_RC=1
```

**c. A 已删 sub/f1.txt，B 残留 → L1 报出**
```
=== c. A 已删 sub/f1.txt, B 残留 (L1 集合差) ===
[DEPLOY] DRIFT-L1: /tmp/s30-sandbox.ISWy/B (文件集合差: 缺/多如下)
  多余: sub/f1.txt
RECONCILE_RC=1
```

**d. 全一致 → 与现状 IDENTICAL 判定一致**（干净沙箱 sb2: A/B 逐字节同 + git 清单不可用走保守回退全交集）
```
=== d. 全一致 + git 清单不可用 (MAIN_REPO 非 git 仓 → 保守回退全交集, cmp 全过) ===
RECONCILE_RC=0
=== 对照: 旧全树 diff -rq 同状态判定 ===
旧判: IDENTICAL
```
同状态清单可用时定向目标=清单内+抽检全过亦 RC=0。

残留面实证（与提案声明一致）: B 侧清单外 sub/f1.txt 带外热改且未被前 3 抽检覆盖时，新判 RC=0 而旧 diff -rq 判 DRIFT —— 即「清单外同名文件带外热改靠概率抽检兜底」的明示残留面，非缺陷。

### ④ git diff 面核对
`git status --short` 仅 `M skills/task-planner/scripts/smart-merge-back.sh`，无其他文件变更（主仓零触碰，无 git 写操作）。

## 4. 关键裁量

1. **git 清单来源**：用 `git diff --name-only $MB $BRANCH -- skills/task-planner`（程序化、禁手填，MB/BRANCH 为脚本既有变量）替代提案字面 "git porcelain"——porcelain 是工作区未提交态清单，不适用于「本次合并变更文件」语义；本方案即提案「程序化清单」实质。
2. **清单内目标取交集 inman**：清单含已删除文件时不入 targets（L1 已报缺失，避免二次假 DRIFT）。
3. **抽检确定性**：清单外按 LC_ALL=C 排序前 3（可复现，不依赖 $RANDOM；提案未指定随机源，取确定性优于随机）。
4. **find -L + %P**：与 cp -rL 实体化口径一致（symlink 实体内容对账），相对路径 %P 两侧同口径。
5. **判定行原文保留**：`[DEPLOY] IDENTICAL: $slotdir (基准=主仓 skills/task-planner)` 字节不变；DRIFT 失败时明细行（DRIFT-L1/L2）先行打印，判定语义由函数 return 码驱动 —— selftest 所消费的输出行（IDENTICAL / DRIFT:$slot 的 cp 失败与 REJECTED 路径）全部保留。
6. **空清单保守回退**：manifest 为空（无 skill 变更/git 不可用/同 ref diff）→ 全交集 cmp，语义等价旧全树 diff，非静默降级。

## 5. 风险

- 残留面（提案明示）: 清单外同名文件带外热改仅靠前 3 抽检兜底，>3 文件带外改且未抽中 → 漏检（概率兜底，记录在案）。
- L2 清单依赖 MB/BRANCH 变量在 --deploy 段可用（V4 ALREADY_MERGED 路径下 MB 已在 V3 计算，ALREADY 分支也走 MB，可用）。
- `head -n 5` 截断：缺/多 >5 文件时明细仅前 5（判定不受影响，DRIFT 语义完整）。

## 6. 未做（负结果报告）

- 未 commit（契约禁止）；未改 selftest-smart-merge.sh（15 断言零改动全过即证明输出结构兼容）；未触碰三 slot 原子替换段与 V1-V4 预检；主仓与部署位零写入；/tmp 沙箱已清理。
