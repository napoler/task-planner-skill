# S32-fix-c5locale checkpoint（task-v091/C-5-locale）

## step1 进场核对 ✅
- worktree HEAD = b5b9bc028775bc645d1367b637e534049a165322（= master b5b9bc0）
- git status --short 空（clean）
- branch = wt/task-v091-c5locale

## 计划
- step2: deploy_reconcile 内 6 处 comm pin LC_ALL=C（禁碰 :296 预检段）
- step3: selftest-smart-merge.sh 增 locale 回归用例（zh locale 下 L2 清单内差异仍 DRIFT + 双跑对拍）
- step4: bash -n + selftest 全 PASS + 缺陷对照复现 + worktree commit

## 执行记录

### C-5 收尾批（selftest SM-15a/15b）— 2026-09-27 ✅
- step1 进场核对: worktree HEAD=cc64c1b（含 smart-merge-back.sh 6 处 LC_ALL=C comm pin）, git status clean, branch=wt/task-v091-c5locale
- step2 实现（skills/task-planner/scripts/selftest-smart-merge.sh）:
  - SM-14 report 行后、全量清理段前插入 SM-15a/15b:
    - FN15=$(awk '/^    _re_lines\(\) \{/,/^    \}$/' "$TARGET" → $T15/fn.sh)（实测抽 40 行, 含 _re_lines+deploy_reconcile 两函数）
    - P15 基线: 抽取文件含 `deploy_reconcile() {` 且含 `LC_ALL=C comm`（剥 pin 时直接 FAIL = 回归钉子）
    - 夹具: $T15/repo git 仓(skills/task-planner 下 B.md+a.md 混合大小写, mb 基线 commit→改 B.md→branch commit); $T15/src 与 $T15/slot 两侧(B.md 内容差异 v1-branch vs v0, a.md 两侧相同 shared); h15.sh 包装(source $FN15 + DEPLOY_SRC/MAIN_REPO/MB/BRANCH/deploy_reconcile "$slot", 定位参数 $6)
    - SM-15a: env LC_ALL=zh_CN.UTF-8 跑 → 断言 rc=1 + 输出含 DRIFT-L2 + B.md
    - SM-15b: 同夹具 env LC_ALL=C 跑 → rc=1 且与 15a 输出逐字节一致
    - TOTAL_BASE 14→16; 统计段注释 14/15 → 16/17; 头注释用例清单 15 断言行 → 16 断言行
  - 实现偏差披露: ① FN15 放 $T15/fn.sh（非另开 mktemp, 走既有 record_dir trap 清理范式）; ② SM-15a/15b 共用同一套 git 仓+src/slot 夹具（两次 run 前后夹具不变, 满足"同夹具双跑"）; ③ P15 基线结果内嵌进 SM-15a 的 report 详情行（不单独占断言行, 与"Total=16"口径一致, 头注释 SM-15 块描述的基线语义保留）
- step3 验收:
  - bash -n → SYNTAX_OK
  - 全量实跑: Total: 17 PASS=17 FAIL=0 EXIT=0（SM-10 经套内相对推导注入, Total=16+1）; 本机 `locale -a` 实测含 zh_CN.utf8（另 C.utf8/en_US.utf8/zh_CN.gbk）, LANG=zh_CN.UTF-8 → 15a 真实走 zh locale 而非缺失降级; P15 基线=在, DRIFT-L2=在, B.md 入 DRIFT 明细=在, 15a/15b 逐字节一致=是
  - smart-merge-back.sh 本批零改动（cc64c1b 已含 6 处 pin, 未微调）→ 仅 commit selftest 一文件
  - commit = eb7d728（worktree 单独, 提交后 git status clean）
- 遗留/风险: 无。主仓 merge_back 未做（本批未指示合并回 master, 待主进程 §11.3 合回流程序列）。
