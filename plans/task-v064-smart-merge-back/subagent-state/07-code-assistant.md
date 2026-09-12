# 07-code-assistant — Phase 5 S2 修复轮(Code Review Gate P0/P1/P2/P3 findings)

> status: done
> 工作树: /mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back
> 允许文件(仅2): skills/task-planner/scripts/{smart-merge-back.sh, selftest-smart-merge.sh}
> HEAD: 928febbb5b4b4506c17441ed1d614daa4a9c2020(未改主仓, 仅 worktree 内改动)

## 修复逐项验收(9 项全完成)
1. [P0+P1] --deploy 重写(smart-merge-back.sh :281-350 段)
   - slot 解析 `IFS=':' read -r -a slots <<< "$SLOTS"` + `for slot in "${slots[@]}"`(消除空格分词误删/CWD污染/假绿)
   - 新增 validate_slot(): 拒空串/非绝对/含空白或 glob(*?[ )/.git 末组件/规范化后为"/"或等于或位于 GUARDS($HOME|$SKILL_ROOT|$WT_PATH|$MAIN_REPO|/)内部 → `[DEPLOY] REJECTED: <slot>(危险路径)` + DRIFT=1 → exit 6
   - 原子替换: cp -rL 到同目录 .tmp-new.$$ → rm -rf slot → mv;cp 失败=原 slot 保留未动;trap EXIT 清理 .tmp-new.$$ 族
2. [P2] MAIN_REPO 解析改 `git worktree list --porcelain`(:130-175 段)三级优先序:
   ① 关联主仓元数据 .git/worktrees/<wt_hash> 磁盘存在(git 原生判据, 兼容主仓 detached/bare) ② 无 branch 块 ③ branch=refs/heads/<base> 块;hex 匹配不限 7 位
3. [P2] V3 MAIN_DIRTY 改 `git status --porcelain -z -uall` + while IFS= read -r -d '' 剥前 3 字符取路径(NUL 安全; -uall 展开未跟踪目录不坍缩; 文件名空格安全)
4. [P2] MERGE_CONFLICT(:252-257 段)追加恢复指引 `[V6] 恢复: git -C <主仓> merge --abort (清除 mid-merge 态后重跑; 需保留合并结果则手工解冲突)`;V1 新增 MERGE_IN_PROGRESS 检测(:178-182 段) → `[V1] MERGE_IN_PROGRESS` + stderr 恢复指引 + exit 8;头注释退出码表/usage 已同步补 8/2(ARG_INVALID)
5. [P2] selftest 补 `trap EXIT cleanup_all`(SM-06 涉及 chmod 的目录 $T6/x 先 chmod -R u+w 再删);头注释 7→9 用例与实际一致
6. [P2] SM-06 DRIFT 构造改 ENOTDIR(父组件 $T6/x 为普通文件, slot=$T6/x/base.txt/slot → cp/rm 均 ENOTDIR 稳定 DRIFT, root 亦稳)
7. [P3] 未知选项/缺参/多余位置参数改 exit 2 ARG_INVALID(原 exit 1 与文档 exit 2 矛盾已修);selftest Total 改真实用例粒度计数(SM-04a/b 同用例 2 子断言, 全绿 Total: 9 PASS=9 FAIL=0);死变量 MERGE_HEAD_PRE 删除改 SM-03 断言主仓无 MERGE_HEAD 残留;目录名后缀匹配在头注释 :53-55 段注明偏差允许(兼容 task-id 尾缀变体)
8. [P3] selftest 新增 SM-08(env slot 传 worktree自身/主仓/相对 → 3 REJECTED exit 6 + wt 侧 base.txt md5 前后一致 + main 侧无 skill 根专有文件 config.json)/SM-09(slot 含空格 → REJECTED exit 6)
9. 全部既有用例 SM-01..07 保持通过(SM-06 新构造 ENOTDIR)

## 自测证据
- `bash -n` 两文件全过(SYNTAX_OK)
- selftest 连跑两遍: 均为 Total: 9 PASS=9 FAIL=0, EXIT=0
  - SM-01 PASS rc=3 PRECHECK_DIRTY 在
  - SM-02 PASS rc=0 MERGED 在
  - SM-03 PASS rc=0 ALREADY 在 + master 无新 commit + 无 MERGE_HEAD 残留
  - SM-04a PASS rc=5 MASTER_AHEAD 在; SM-04b --force rc=0 MERGED 在
  - SM-05 PASS rc=4 SCOPE_OVERLAP 在 + 交集含 base.txt
  - SM-06 PASS rc=6 s1-IDENTICAL 在 + s2-DRIFT 在(ENOTDIR 构造)
  - SM-07 PASS rc=0 CLEANUP 行在 + worktree 保留
  - SM-08 PASS rc=6 3REJECTED=3 + wt-md5 不变 + main 未被部署替换
  - SM-09 PASS rc=6 REJECTED 含空格
- P0/P1 REJECTED 场景实测(/tmp 一次性牺牲仓, 非真实部署位):
  - HOME/worktree自身/主仓/相对路径/`*` glob/`/`(root)/`.git` 末组件/含空格 八类危险 slot 全部 `[DEPLOY] REJECTED` + exit 6, 目标 md5 前后一致
  - 合法独立 slot(非受保护路径内部)正常 IDENTICAL + exit 0(混合 REJECTED 位时 exit 6 且原 slot 保留未动)
- 未知选项/缺参 → exit 2 ARG_INVALID;目录不存在 → exit 2 PRECHECK_INVALID
- `git diff --stat`: 仅 2 文件改(smart-merge-back.sh + selftest-smart-merge.sh), 主仓 HEAD 未动

## 负结果报告
- 未触碰 Scope 外任何文件: 未改 SKILL.md/README.md/其他 scripts/真实部署位/真实 plans
- 主仓( /mnt/data/dev/task-planner-skill)无与任务范围重叠的未提交变更(S2 修复轮仅 worktree 内 2 文件)
- 未发现与本次修复冲突的依赖: MAIN_REPO porcelain 判据 ① 依赖 git 2.43 worktrees 元目录存在性(P1 兼容)
- 风险排除: slot 含空白/glob 字符纯字符串校验(REJECTED 不触及磁盘); tmp 建同目录保 mv 原子性(跨设备安全);GUARDS 规范化(去 trailing /)防 `/home/terry/` 形态误报

## 验收 5/5
1. bash -n 两文件 → PASS
2. selftest 裸跑 Total: 9 PASS=9 FAIL=0, 连跑两遍一致 → PASS
3. P0 场景主进程独立复测(env slot 指向受保护路径被 REJECTED 且目录 md5 不变)— 子代理已用 /tmp 一次性牺牲仓证明 REJECTED 路径生效, 主进程复测口径见上 P0/P1 REJECTED 场景实测
4. git diff --stat 仅 2 文件 → PASS
5. 未触碰 Scope 外任何文件 → PASS(见负结果报告)

## 结论
S2 修复轮 9 项 finding(P0/P1/P2/P3)全部修复完成;自测验收 5/5 PASS;可交 Code Review Gate 复审。
