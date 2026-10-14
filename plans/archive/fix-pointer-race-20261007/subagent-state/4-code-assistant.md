# 检查点 4-code-assistant — Phase4-S1 selftest 更新 + 全量回归

状态: done（2026-10-07）

## 修改摘要（唯一改动文件）
`/mnt/data/dev/task-planner-skill-worktrees/fix-pointer-race/skills/task-planner/scripts/selftest-active-plan.sh`

1. **文件头注释**（:3-8 区）：追加 T12e/T12f/T12g/T12h/T12i/T13/T14 用例说明 3 行。
2. **T12a 更新**（原 :164-175 区）：
   - 断言目标文件名 `sess038ddeadbeef.active_plan` → `038ddeadbeef.active_plan`（RC-1 canon 剥 sess 前缀）
   - 追加负例 `[ ! -e .../sess038ddeadbeef.active_plan ]`
   - 块首补注「[2026-10-07 fix-pointer-race] canon 统一：原断言 sess* 文件名固化双命名空间缺陷，已随 RC-1 修复更新」
3. **T12d 块之后、Total 行之前追加 7 个新用例**（沿用 PASS/FAIL 计数与 $TMP/err、mk_root、call 既有模式）：
   - T12e 新鲜窗负例：陈旧哨兵(10min)+无 sidmap → 拒抢，指针按 env sid 133bbenvdead1 落盘，038d… 指针不产生
   - T12f sidmap 优先：133bbenvdead1.sidmap→038ddeadbeef（哨兵本身陈旧 10min）→ 映射命中，指针落 038d… 内容 tt
   - T12g env 带前缀直配：env sess62e7… canon 剥前缀直配无前缀哨兵 62e7…；断言 sess* 指针不产生
   - T12h cjs sidmap 优先（PCRE=yes 包裹）：deadbeef55.sidmap→ffff0011aaaa2233 陈旧哨兵 → 哨兵被清 + 输出含「经 sidmap 映射」
   - T12i cjs 新鲜窗负例（同包裹）：无映射+陈旧哨兵 → 哨兵保留 + 输出含「疑似他会话」
   - T13 resolve 双命名空间读：历史 sessq13sid.active_plan 指针，sid=q13sid 调用仍可解析 bb
   - T14 gc 清扫 sidmap：oldmap.sidmap(25h) 删、newmap.sidmap 留、计数=1

未改任何生产脚本（resolve-plan-dir.sh / init-session.sh / plan-created.cjs / set-active-plan.sh 均只读参考）。

## 验收 a) 单测原始输出（worktree）
```
T01 PASS 01 … T12a PASS 12a … T12e PASS 12e / T12f PASS 12f / T12g PASS 12g / T12h PASS 12h / T12i PASS 12i / T13 PASS 13 / T14 PASS 14
Total: 26 PASS=26 FAIL=0
EXIT=0
```
（26 项全 PASS，FAIL=0，exit 0，无 FAIL 项）

## 验收 b) 全量回归（worktree 66 个 selftest-*.sh）
- PASS：51 项（含 selftest-active-plan.sh）
- FAIL：15 项：agent-coverage / ask-default-timeout / capability-persistence / iteration-persistence / lane-advancement / media-agents / media-dispatch / periodic-review / registry / reliability-institution / requirement-coverage / requirement-grading / self-resolution / tool-selection / workflow-orchestration

master 对照（/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/ 同名脚本）：15 项逐一复跑 → **15/15 全部同样 FAIL**。
判定：全部为既有问题（worktree 失败且 master 同样失败），非本次指针抢占修复引入。无「worktree 失败+master 通过」项，无需回报待裁决。

## 结论
done —— T12a 更新 + T12e-T14 新断言全部通过；全量回归 FAIL 项均确认为既有问题，只登记不修（遵守禁止改其他脚本约束）。
