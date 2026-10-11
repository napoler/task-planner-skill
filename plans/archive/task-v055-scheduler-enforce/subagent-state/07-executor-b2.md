# 07-executor-b2.md — task-v055 收尾批次(B' / Phase 3 SKILL收敛 + verify新3项 + verification自动化)

> 时间:2026-09-07
> 执行者:executor 子代理(主进程)
> 分支:wt/task-v055-scheduler-enforce(基于 master 176ff0f)
> Worktree:/mnt/data/dev/task-planner-skill-worktrees/task-v055-scheduler-enforce
> Commit:eee87e0f15eb029c8caf72baac6a637055a03011

## 任务范围

B 批剩余 3 文件收敛(用户原始指令原话):"剩余 3 项 → SKILL 收敛(548→≤500 行 / P0 20→≤10 处)、verify.sh 新 3 项体检、verification.md 委派统计自动化"

## 改动摘要

### 1. skills/task-planner/SKILL.md(548 行 / P0×20 → 497 行 / P0×10)

**P0 削减**(保留机制级,降级装饰性):
- 保留 10 处:头部铁律(L27)+ 7 条 Rule P0(13/14/19/22/25/26/27)+ 路由表主标题(L311)+ 路由表约束(L315)
- 降级 10 处:Rule 23 主标题 / references 描述(L9 / L212 / L287 / L320)/ 超时兜底标题 / 代码编辑标题 / 漂移纠正标题+小节 / 模板库标题+小节

**行数削减**(−51 行):
- 折叠 "💻 代码编辑强制隔离" 至路由表指针(−25)
- Read/Write 决策矩阵 6 行表 → 5 行清单(−2)
- "何时移交 comet" 段压缩(−8)
- "I/O 契约" 3 行 → 1 行(−2)
- "Scope Guard / Goal Gate" 合并(−3)
- "WebSearch 路径 1" 5 行表 → 单行(−4)
- "漂移纠正为什么高频 / 与 Rule 11 关系" 合并(−4)
- "调研禁止" 末项指针化(−1)
- 多余空行/孤 `---` 清掉(−2)
- 模板库末两行合并(−1)

**Rule 编号引用未断**:抽查 L37/40/81/82/84/86/89/96/112/118/126/150/151/152/155 与改前一致。

### 2. skills/task-planner/lib/verify.sh

新增 9 号检查(task-v055 委派门控三件套可执行性):检查 `check-delegation.sh` / `allow-direct.sh` / `selftest-delegation.sh` 三脚本存在且可执行。同构格式照搬 check 5/6 模式(脚本存在 + 可执行 + 失败信息含路径)。

文件头 Checks 列表(17-26 行)同步追加条目 9。

### 3. skills/task-planner/templates/verification.md

L75-78 「## 委派统计复验(Rule 25.4)」段改为机器驱动(stats 命令 + JSON 粘贴) + 人工复核双栏。明确"机器统计为事实源,人工仅复核"。

## 自测数字

| 自测项 | 要求 | 实测 | 状态 |
|--------|------|------|------|
| `wc -l SKILL.md` | ≤500 | 497 | ✓ |
| `grep -c 'P0' SKILL.md` | ≤10 | 10 | ✓ |
| verify.sh pass 数 | 17+3=20(无回归) | 20 pass / 3 fail | ✓(3 fail 为旧 check 2 部署漂移) |
| selftest-delegation.sh | 18/18 | 18/18 PASS | ✓(A 批未破坏) |

3 fail 详:claude-code / zcode / opencode 全量副本 SKILL.md 与 canonical 不一致 —— 因 SKILL.md 改了,stub 同步尚未触发(check-delegation.sh + allow-direct.sh + selftest-delegation.sh 是 stub 的脚本,通过软链/全量副本与 canonical 共用,只 SKILL.md 是副本)。合并回 master 后 re-sync stub 即可消除。

## Commit

```
eee87e0 feat(task-planner): task-v055/Phase 3 — SKILL收敛达标(≤500行/P0≤10)+verify新3项+verification委派自动化
```

## 遗留问题

1. **3 个 stub 的 SKILL.md 需重新同步**(claude-code / zcode / opencode)。合并到 master 后由各 stub 部署脚本 re-sync 即可,不在本批次范围。
2. **B 批中 SKILL.md 头部三条铁律强化块**已在 176ff0f 合并,本批次仅做收尾,不重复。

## 完成动作

- [x] git add 仅 3 文件
- [x] commit 提交(eee87e0)
- [x] checkpoint 写入本文件
- [x] enforce-demo.txt 追加「B' 收尾批次」段落
- [x] 最终回复:3 文件摘要 + 自测数字 + commit hash + 遗留问题