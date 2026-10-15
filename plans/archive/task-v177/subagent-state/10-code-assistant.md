# 检查点 10-code-assistant（task-v177 收尾：selftest 宽容锚演进 ×2）

status: done

## 已改（2 文件，均在 2 文件授权范围内）
### 1. `skills/task-planner/scripts/selftest-context-pressure.sh`（worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v177）
- CP-07 锚 `1-8[0134]` → `1-8[01346]`（c1/c2 两 grep + ok/bad 文案 + 头注释），:102-121
- 加注「（2026-10-15 task-v177：86 落地宽容锚演进，同 RG-06 范式）」

### 2. `skills/task-planner/scripts/selftest-root-resolution.sh`
- RR-09 锚 `Rules 1-8[0134] 全集索引：` → 字符类 +6，:127 附近
- **同批发现（协调者 2026-10-15 确认）**：v177 级联后 SKILL.md:217 References 表行措辞引入第 2 处「Rules 1-86 全集索引：」载体，裸 grep -c =2 与既有期望值 `-eq 1` 冲突。裁决采纳方案：主断言追加行首锚 `^`（`^Rules 1-8[01346] 全集索引：`）——正文声明行（SKILL:175）行起命中、References 表行以 `|` 起首天然不命中；期望值 =1 与断言逻辑不动，防级联漏改强度不减；先例 = v127 RC-15 `^50→^52` 行首锚定形态。备选（期望值 =1→=2）弃用：会把级联意外措辞重复固化成不变量（反向漂移），且丢失「唯一声明行」语义。
- 加注「（2026-10-15 task-v177：86 落地宽容锚演进，同 RG-06 范式）」+ 行锚定裁决注释

## 验证证据（worktree 内执行）
- `bash skills/task-planner/scripts/selftest-context-pressure.sh` → `Total: 9 PASS=9 FAIL=0`（CP-07 PASS：`'1-8[01346]'=5≥2 ∧ 全集串=3≥1`）✅
- `bash skills/task-planner/scripts/selftest-root-resolution.sh` → `Total: 17 PASS=17 FAIL=0`（RR-09 PASS：`'^Rules 1-8[01346] 全集索引：' 唯一声明行命中=1 且旧 1-51/53/55 残留=0`）✅

## 负结果/风险提示
- 已排除：两文件无残留活性 `1-8[0134]` 正则（仅注释）；RR-09 负断言 m=0 不受影响
- 未改但登记（超任务范围，潜伏脆弱点）：`selftest-root-resolution.sh:207` RR-16 仍用裸 `1-8[0134]`，当前 PASS 依赖 SKILL.md:217 注释里的「1-84 陈旧措辞」字面——若该注释日后被删，RR-16 会级联 FAIL
- 禁全量：未跑 run-selftests.sh（本单元验收仅两条目）
- git status 核查：本单元新增改动仅 2 个授权文件；无 git 写操作；未碰 SKILL.md 及其他 selftest
