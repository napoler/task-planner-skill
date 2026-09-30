# Knowledge Brief — task-v105-pool-host-enumerable
## §1 速览
- 11 池成员相对软链挂载三宿主顶层 skills/<member>(smart-merge-back --deploy 自动 install_pool_links)+install-companion 池分发(独立 skill 不覆盖)+RL-14/15;部署后 .zcode/.claude 各 11 链,opencode 10 链+security-review 保留。
## §2 已验证事实
| 事实 | 证据 |
|------|------|
| master=084a92a | rev-parse 2026-10-01 |
| 宿主枚举=顶层 only(plan-resume 在列,池 11 成员不在) | available-skills 列表 |
| symlink 经宿主可读(name 解析✓) | 探针 2026-10-01 |
| opencode 顶层冲突=security-review 独立副本(保留) | ls+diff 实测 |
| 挂载插入位=deploy_reconcile 成功分支(smart-merge-back :609) | Read |
| 分发插入位=install-companion :172 task-planner continue 分支 | Read |
| 基线 41 脚本 650/0;RL Total 13;config 键 40 | P1 复测 |
## §3 文件锚点
| 路径 | 锚 |
|------|-----|
| scripts/smart-merge-back.sh | :609 deploy_reconcile 调用/成功分支+:623 exit 0(函数定义插部署块内) |
| lib/install-companion.sh | :172 `[ "$skill_name" = "task-planner" ] && continue` |
| scripts/selftest-review-library.sh | :4 头注释计数/RL-13 后描述区/断言区尾 |
## §4 易错点
1. [ -e ] 对断链软链返回 false——判断「顶层已占用」须 [ -e ] || [ -L ] 双条件
2. 挂载校验失败只 rm 自己刚建的链(ln 之后才 rm),禁碰既有条目
3. LINK-* 纯输出不改 exit 码——SM selftest 断言 exit/DRIFT 语义
4. install-companion 分发前 cmp:目标存在且不同→skip+WARN;等同→sync_one 自幂等
5. push 判据=ls-remote(v099 教训);RL 头注释计数 13→15 级联
6. members 枚举用 `ls -d .../*/ | xargs -n1 basename`,kebab-case 无空格安全
## §5 材料包
| S-unit | 材料 |
|--------|------|
| P2-S1 | 任务书 install_pool_links 逐字规格+插入位 |
| P2-S2 | 任务书分发规格+:172 分支 |
| P2-S3 | RL-11/12 范式+RL-14/15 锚定义 |
