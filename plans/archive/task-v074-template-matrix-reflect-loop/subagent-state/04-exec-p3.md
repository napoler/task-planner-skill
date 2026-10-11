## S1 完成 (2026-09-15)
- 改动文件: references/critical-rules.md 追加 Rule 34 块（原 279 行 → 290 行，追加 11 行：头+动机段+6 子条）
- 位置: `### 34 模板生命周期：选取门控 + 沉淀入库` 起，含 34.1-34.6 六子条
- 自验: 文件现 290 行；追加块 11 行 ≤22 行约束满足；Rule 33 (33.1-33.6) 未被改动
- 状态: completed

## S2 完成 (2026-09-15)
- 改动文件 1: config.json 追加 template_gate_enforce 键 (:305-311，位于 reflect_verify_enforce :299-304 之后；enum enforce/warn/off, default warn)
  - 自验: `jq . config.json > /dev/null` 通过；`grep -n template_gate_enforce config.json` → 305
- 改动文件 2 (新建): scripts/check-template-type.sh (37 行 ≤80 约束, set -u, chmod +x)
  - 白名单动态派生: general + ls templates/variant/*-type.md 去后缀（实测 12 变体）
  - 提取: frontmatter `^template_type:` 优先 → 表格行 `| template_type |` 第二列；取值取首个空白/全角括号前 token（兼容 "general（注释）" 写法）
- 自验结果（5 case）:
  - case1 真计划 task-v074/task_plan.md (表格行 general+注释) → `[template-gate] OK: template_type=general` rc=0 ✓
  - case2 /tmp/tp-missing-plan.md 缺 template_type → `INVALID: 缺失` rc=1 ✓
  - case3 /tmp/tp-bad-plan.md template_type=nonexistent → `INVALID: 不在白名单` rc=1 ✓
  - 补测 frontmatter 写法 template_type: bugfix → OK rc=0 ✓
  - 无参调用 → usage 提示 rc=2 ✓
  - `bash -n` 通过
- 状态: completed

## S3 完成 (2026-09-15)
- 改动文件: scripts/attest-plan.sh
  - 参数解析区 :11/:25 新增 --skip-template-check（skip_template=1，对齐 --skip-dispatch-check 写法）
  - attest 模式集成区 :68-105：check-plan-dispatch 块之后插入模板门控——
    档位解析 resolve_template_tier（env TASK_PLANNER_TEMPLATE_GATE_ENFORCE > jq 读 config.json .properties.template_gate_enforce.default > warn 回退，与 P2 REFLECT-GATE :687-694 同范式）
    off=整体跳过; 调 check-template-type.sh: exit 0 打 OK 继续 / exit 1 enforce=拒绝锁定 exit 1、warn=打 WARNING 继续锁定
  - 未触碰 check-plan-dispatch 既有逻辑、LOCK 主流程后续段（:107+ hash/attest）
- 自验结果（全部 /tmp 临时目录，未对真实计划跑 attest）:
  - `bash -n attest-plan.sh` 通过
  - enforce+非法 type: rc=1，无 .plan-attestation 生成 ✓
  - warn+非法 type: rc=0，打 [template-gate] WARNING，.plan-attestation 正常生成 ✓
  - 合法 type (research): rc=0，[template-gate] OK ✓
  - off 档: 门控段无输出，直接锁定 ✓
  - --skip-template-check (enforce 档+非法 type): 打 WARN 逃生行，锁定放行 ✓
- git status (worktree): M config.json / M critical-rules.md / M attest-plan.sh / ?? check-template-type.sh —— 恰 4 文件，无越界改动，未 commit（按 SOP 留给主进程验收后统一提交）
- 状态: completed

## 最终结论 (S1+S2+S3)
- 4 文件改动/新建全部落地 worktree: /mnt/data/dev/task-planner-skill-worktrees/v074/skills/task-planner/
  ① references/critical-rules.md:281-290 Rule 34 (34.1-34.6)
  ② config.json:305-311 template_gate_enforce 键 (jq 校验通过)
  ③ scripts/check-template-type.sh 新建 37 行 (白名单动态派生, 三档 case 实测通过)
  ④ scripts/attest-plan.sh:11,25,68-105 门控集成 (--skip-template-check 逃生, 五功能 case 实测通过)
- 禁止项确认: 未改 init-session.sh / 未动主仓 / 未 commit / 未动 config.json 既有脏点 (重复键区 394-419)
- Phase 4 遗留（不在本 S 范围）: scripts/selftest-template-lifecycle.sh、34.2 三点同步（template-mapping.md / plan-writer.md / SKILL.md）
