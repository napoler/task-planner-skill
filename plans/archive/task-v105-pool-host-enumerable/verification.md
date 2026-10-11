# Verification Contract & Phase Gates

## Goal (1 sentence)

review-library 11 池成员以相对软链挂载到三宿主顶层 skills/<member>/(宿主可枚举):smart-merge-back --deploy 自动挂载(install_pool_links,冲突跳过+回滚,不改 exit)+install-companion 池分发(独立 skill 不覆盖)+RL-14/15 守护;全量 652/0 后合并、三位 IDENTICAL+挂载亲验、push、清理。

---

## Verification Contract

- [x] VC-1: install_pool_links 在位——相对软链 <skills>/<member>→task-planner/review-library/<member>;冲突跳过 LINK-WARN;挂载失败仅回滚自建链;deploy_reconcile 通过分支调用(:645);LINK-* 纯输出不改 exit(DRIFT/REJECTED/IDENTICAL 语义不变)
  Evidence: CR 专项 1/2 PASS(逐行 file:line 举证;deploy_reconcile/validate_slot/原子替换/exit 0 零删改;selftest-smart-merge 17/17 回归)
- [x] VC-2: install-companion 池分发——cmp 不同→skip+WARN+skipped 计数(独立 skill 不覆盖);等同→sync_one 幂等;仅 SKILL.md 单文件
  Evidence: CR 专项 3 PASS;agents 段/非 task-planner 分支零改动
- [x] VC-3: RL-14/15 在位+头注释 13→15;`Total: 15 PASS=15 FAIL=0`;RL-01..13 零改动;registry 无需新行(无新脚本)
  Evidence: RL 实跑 15/0;CR 专项 4 PASS(锚实测 install_pool_links=3/LINK-WARN=5/review-library=2/独立 skill=2)
- [x] VC-4: 全量回归 **41 脚本 652 PASS / 0 FAIL**（=基线 650+RL 2 咬合,主进程定数;selftest-smart-merge 零回归）
- [x] VC-5: 合并部署挂载 push 清理——merge fbe2109;三位 IDENTICAL;挂载亲验: .zcode 11 链(逐链 readlink+frontmatter name 校验 11/0)、.claude 11 链、opencode 10 链+security-review 独立副本保留(LINK-WARN 留痕);push 084a92a..fbe2109 ls-remote 终验一致;worktree/branch 0/0
- [x] VC-6: 边界零回归+CR **APPROVED**（0 P0/P1;2 Nit 不阻塞:xargs 空格鲁棒性前瞻/池分发单文件不对称前瞻）;diff 面 3 文件全在 scope(+70/-2)

---

## 委派统计复验（Rule 25.4）
- delegated=1(P2 executor S1→S3 串行;P5-CR code-reviewer);main_direct=3-4(P1/P3/P4/P5 簿记),verdict=ok,rate≈0.2
- [x] 25.4a WHITELIST-EXEMPT(直做理由全白名单①②③⑤)

## 质量门控统计（Rule 26）
- [x] Q1-Q6: 触发 1 项(部署脚本自替换竞态——merge 原地替换 bash 正执行的 smart-merge-back 自身,首跑按旧内容完成部署段,挂载段未执行;重放(ALREADY_MERGED 路径)补齐挂载。已登记 Error Log+notepad 防线「merge 与执行同脚本须两段式」);未处置 0
- [x] Evidence 抽查 ≥3: ①三宿主挂载逐链 readlink+name 校验 ②全量 652/0 主进程定数 ③ls-remote 终验 ④opencode security-review 保留核验
- [x] 未处置违规: 无 → COMPLETE

## Goal Gate (终验)

```
## Goal Verification — 池成员宿主可枚举全链交付
- [x] VC-1: 挂载函数+调用+exit 隔离 → PASS
- [x] VC-2: install-companion 池分发+不覆盖语义 → PASS
- [x] VC-3: RL-14/15+15/0 → PASS
- [x] VC-4: 全量 652/0 → PASS
- [x] VC-5: 合并部署挂载 push 清理+三宿主亲验 → PASS
- [x] VC-6: CR APPROVED → PASS
```

outcome: **COMPLETE**

**遗留披露（不阻塞）**:
1. 宿主 available-skills 为会话快照——软链已就位,新 skill 须新会话/重启刷新(install-companion 既有同语义注记)
2. CR Nit×2 前瞻(池成员命名扩空格时改 find -printf;池成员引入 scripts/ 时扩目录级分发)——登记后续
3. ~~opencode security-review 保持独立版~~ **[2026-10-01 用户裁决统一,已处置]**: 独立副本备份移出扫描路径 ~/skill-deploy-backups-task-v106-pool-unify/security-review-opencode-20260410(含独有 cloud-infrastructure-security.md),opencode 顶层改挂池版本相对软链;三宿主软链终态 **11/11/11**,下次 deploy 该链识别为 LINK-OK(不再 WARN);全库普查确认无其他实体副本残留
