# S32 组5 C-2/C-3/C-4/C-5 干净上下文验证 checkpoint

- 验证人: 全新子代理(不信任既有验证结论, 全部独立实测)
- 日期: 2026-09-27
- 被验对象: 任务书指 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v091`(HEAD=a05bd5e)。
  **环境事实(实测)**: 该 worktree 目录在验证开始时已被移除(主仓已 merge b5b9bc0, 见 `git -C /mnt/data/dev/task-planner-skill worktree list` 仅剩主仓)。
  **等价性证明**: 对 6 个关键脚本 `sha256(git show a05bd5e:<f>) == sha256(主仓工作树 <f>)` 逐一验证 IDENTICAL
  (smart-merge-back.sh / sync-todos.sh / check-complete.sh / selftest-smart-merge.sh / selftest-registry.sh / selftest-sync-index.sh, 均 5c003c82… 等哈希一致)。
  故后续全部实跑用主仓工作树副本(与 a05bd5e 字节级一致), 结论对 a05bd5e 成立。
- 硬约束遵守: 主仓零写(仅读+status); /tmp 夹具自建自清(已 rm -rf /tmp/fx-c2-v091 /tmp/fx-c3-v091 /tmp/fx-c5-v091); 无 git 写操作。

## C-2 check-complete 四元内容键 SKIP-BY-HASH — PASS

独立 /tmp/fx-c2-v091 计划夹具(1 计划: 1 Phase complete + Executor code-assistant + S-unit 表 + 5 VC + FMEA RPN 行 + Handoff 表 + 三件套), attest 锁定 sha256=a867a484…:

1. **A1 基线**: `check-complete.sh` rc=0, 全量跑(无 SKIP 行, `[plan-dispatch] ✓`/`[fmea-gate] OK`), 两门过后写状态文件
   `${TMPDIR}/task-planner-final-gate-e634984329a24073.state`:
   ```
   fg_key=22b63474…  key1_plan_sha256=a867a484…  key2_cpd_sha256=3044d258…  key3_fmea_seg_sha256=df727b47…
   key4_cfg_snap=env_plan_tier=_|env_fmea=_|cfg="warn",15,2,4,"warn"
   ```
2. **A2 不改重跑**: rc=0, stderr 原文:
   ```
   [plan] PLAN-DISPATCH GATE SKIP-BY-HASH (task-v091 C-2: 四元内容键一致, 引用 attest 锁定结果)
   [fmea-gate] SKIP-BY-HASH (task-v091 C-2: 四元内容键一致, 引用 attest 锁定结果, fmea_enforce=warn)
   ```
   且余门照跑实测: `[plan] VC-GATE PASSED` / `[plan] LEARNING-GATE PASSED` / `[compliance] OK` 同在输出, 终态 rc=0 不变。
3. **A3a 改 plan 内容(键①)**: `attest-plan.sh --verify` rc=1(TAMPERED); check-complete 输出无任何 SKIP 行(全量重跑, `[fmea-gate] OK` 实测行出现); 还原+重 attest 后 rerun → SKIP 复效。篡改轮不写状态(状态文件 key1 保持 a867a484)。
4. **A5 键④改值(env 覆盖)**: `TASK_PLANNER_PLAN_TIER_ENFORCE=enforce` → 无 SKIP(全量重跑, rc=0); 同 env 再跑 → SKIP-BY-HASH 复现; `TASK_PLANNER_FMEA_ENFORCE=off` 同理(首轮全量, 次轮 SKIP)。
5. **B1/B2 键②③④文件面(独立 skillcopy, worktree 本体未动)**: check-plan-dispatch.sh 追加一行(键②)+ config.json 顶层 `.fmea_enforce="off"`(键④)→ 首跑无 SKIP(全量, 两门实测行 `[fmea-gate] OK (fmea_enforce=off)` 不再出现而是无 fmea 输出=off 生效), 二跑 SKIP-BY-HASH; 状态 key4 快照实测变为 `cfg="warn",15,2,4,"off"`。
6. **守护 selftest-final-gate-hash.sh 独立实跑**: `结果: PASS=22 FAIL=0`(六夹具 22 断言)。

**结论**: 四元键任一变化(键①TAMPERED / 键②脚本 / 键③段 / 键④config 或 env)→ 不 SKIP 全量重跑; 全一致 → SKIP-BY-HASH 且余门照跑终态不变。PASS。

## C-3 sync-todos --index 单 awk 全量重算 — PASS

独立 /tmp/fx-c3-v091: 4 计划(1 complete / 1 in_progress / 1 pending / 1 无 Goal 节), 旧版 = `git archive d3a787c^`(rollup_task+extract_plan_meta 多进程形态), 新版 = `git archive a05bd5e`:

1. 首跑: 两侧 `--index` rc=0; stdout 仅 plans 目录路径行不同; **INDEX.md diff 为空(逐字节一致, 含 Last refreshed 行——两侧同秒生成)**。
2. 归档场景: 双侧 `mv plans/task-20260101-333333 plans/archive/` 后重跑 → INDEX 仍互相逐字节一致, 被归档任务行在两侧同步消失(旧行已消失, grep 计数=0)——29.6 全量重算特性保留。
3. touch 单 plan: 两侧同 mtime touch 后重跑 → INDEX 逐字节一致(仅「最后更新」列同值 2026-09-27)。
4. 独立实跑 `selftest-sync-index.sh`(主仓 a05bd5e 副本): `T01..T13 PASS, Total: 13 PASS=13 FAIL=0`。

**结论**: 输出与旧版逐字节一致(提案验收标准「INDEX diff 为空」实测满足)。PASS。

## C-4 selftest 分域 registry — PASS

1. 独立计数: `ls scripts/selftest-*.sh | wc -l` = **32**; `selftest-registry.tsv` 数据行 = **32**; `diff <(ls 排序) <(tsv 列1 排序)` 为空(集合精确对齐)。
2. 独立实跑 `selftest-registry.sh`: `T01..T05 PASS / Total: 5 PASS=5 FAIL=0 (registry rows=32, actual selftest=32)`。
3. `critical-rules.md:318` 36.6a 段原文在位: 「**交付终验必须全量 selftest 0 FAIL，全量总门不降**（36.6 原句原文保留）」——总门不降=PASS 判据满足。

**结论**: 一致性 32=32 + 五断言守护 + 总门条款在位。PASS。

## C-5 部署对账两级化 — FAIL(locale 依赖缺陷, 有可复现实测)

沙箱 /tmp/fx-c5-v091: 最小可跑 hermetic git 环境(bare origin + main clone master + worktree add wt/task-test, skill 根 9 文件含大小写混排 SKILL.md/config.d/selftest 等真实形态 + 分支改 2 skill 文件 + 1 非 skill 文件)。

1. **整脚本全一致场景(④) PASS**: `smart-merge-back.sh <wt> --deploy` rc=0: `[V6] MERGED: 8fef72a…` + `[DEPLOY] IDENTICAL` + `[DEPLOY] OK`(stdout 中出现 4 行 `comm: file N is not in sorted order` 警告——见风险①)。
2. **deploy_reconcile 抽取实跑**(从 a05bd5e 脚本 sed 抽 :519-557 原行, 未改动; 环境注入 DEPLOY_SRC/MAIN_REPO/MB/BRANCH):
   - **LC_ALL=C 下四场景全部符合提案**: ①清单内内容差异 → `[DEPLOY] DRIFT-L2: …(内容差异: scripts/a.sh)` DRIFT ✓; ②部署位多出文件 → `DRIFT-L1 多余: zz-extra.md` ✓; ③仓侧已删/部署位残留 → `DRIFT-L1 多余: templates/t.md`(L1 集合差确定性抓出)✓; ④全一致 → IDENTICAL ✓。另: 清单外文件带外热改 → IDENTICAL(残留面漏检, 与脚本注释声明一致); 抽中文件(CHANGELOG.md)热改 → DRIFT-L2(≥3 抽检实测生效)。
   - **默认环境 locale(zh_CN.UTF-8, 即 hook 生产运行环境)下场景① FAIL**: `deploy_reconcile` 对清单内内容差异判定 **IDENTICAL(假阴)**。根因实测: `comm` 在 ambient locale 下执行, 而其输入清单是 `LC_ALL=C sort` 排序 → zh 序下「not in sorted order」→ `inman`(manifest∩common)实测为空(C 序下应为 `scripts/a.sh scripts/b.sh`), L2 targets 退化为抽检 3 个清单外文件, 清单内文件内容差异不再被比对。L1 侧同缺陷方向为假阳/明细错乱(zh 下 comm -23 实测把「两侧共有行」也计入 missing——混合大小写清单时)。
3. **确定性反例(独立小实验, 已清理)**: 条目 `B.md, a.md`(C 序 B<a; zh 序 a<B)C 序排序后喂 `comm -23`: zh 下 rc=1 且两行皆输出(结果未定义), C 下仅 `B.md` 正确。
4. 独立实跑 `selftest-smart-merge.sh`: `Total: 15 PASS=15 FAIL=0`——但 15 用例夹具文件名全为小写 ASCII(a.md 型), C/zh 序一致, **该 selftest 结构上掩盖 locale 缺陷**。

**结论**: 两级对账逻辑本身(集合差+定向 diff+≥3 抽检+空清单保守回退)在 LC_ALL=C 下全部行为正确; 但在 ambient locale=zh_CN.UTF-8 的生产 shell 中 L2 假阴(清单内内容差异漏检→假 IDENTICAL)+L1 假阳。提案 §三 C-5 场景①「清单内内容差异→第二级报出」在该环境实测不满足 → 本项判 FAIL。

## 风险清单(按严重度)

| # | 风险 | 证据 | 影响 |
|---|------|------|------|
| 1 | C-5 deploy_reconcile 的 comm 未 pin LC_ALL=C, 输入却 LC_ALL=C sort → 非 C ambient locale 下 L2 假阴/L1 假阳 | zh 下 inman=[] 实测 + B.md/a.md 反例 rc=1 | HIGH: 生产 hook 默认 shell locale 即 zh_CN(本环境实测 LANG=zh_CN.UTF-8), 部署对账误报/漏报均可发生; selftest-smart-merge 15 用例全小写夹具不覆盖 |
| 2 | check-complete :566 状态文件写点依赖 ${TMPDIR} 存在 | A1 TMPDIR 指向不存在目录时 `line 566: …state: No such file or directory` + mktemp 报错, 仍 fail-open rc=0 | LOW: 设计即 fail-open, 仅脏 stderr |
| 3 | 残留面(脚本注释明示)非缺陷 | 清单外热改未抽中→IDENTICAL 实测 | 已知接受风险, 记录在案 |

## next(建议, 未执行——只读约束)

1. 修复: deploy_reconcile 内 6 处 comm 包 `LC_ALL=C`(或脚本头 `export LC_ALL=C` 限 reconcile 段)——一行级修复。
2. selftest-smart-merge.sh 增 1 用例: 混合大小写文件清单(SKILL.md vs changelog.md 型)+ 非 C locale(设 `LC_ALL=zh_CN.UTF-8` env 跑)断言 DRIFT-L2 仍报出 → 钉死 locale 回归。
3. C-2/C-3/C-4 无需动作; C-5 修复后建议对场景①补一轮 C/zh 双 locale 对拍。
