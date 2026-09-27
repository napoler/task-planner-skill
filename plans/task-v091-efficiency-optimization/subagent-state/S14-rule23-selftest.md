# S14 checkpoint — Rule 23 冲突扫描行为级 selftest + check-delegation C-1b 修复

- task: task-v091 / S14 / executor
- date: 2026-09-27
- status: complete
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091（未 commit，未动主仓与其他 worktree）

## 产出

1. `skills/task-planner/scripts/selftest-rule23-conflict-scan.sh`（新建，775，bash -n OK）
   - 三行为级夹具（/tmp 独立环境 + stdin JSON 含 cwd/session_id/tool_input.file_path，实跑 zcode-pretooluse.sh 断言 stdout）：
     R23-01 在途第二计划 scope 命中 → 期待 [conflict]；R23-02 第二计划 outcome: COMPLETE
     （字段/取值对齐 posttooluse:100-105 `grep -qiE 'outcome: *(COMPLETE|BLOCKED)'`）→ 期待无 [conflict]；
     R23-03 3 天前 mtime、无 active_plan 指针的在途计划 → 期待仍被扫到。
   - 运行结果（现行实现基线，exit=1）：`R23-01 FAIL` / `R23-02 PASS（空转）` / `R23-03 FAIL`
     / `Total: 3 PASS=1 FAIL=2`。
2. `skills/task-planner/scripts/check-delegation.sh`（get_enforce_mode，原 :131）
   - `.properties.delegation_enforce.default // "enforce"` → `.delegation_enforce // .properties.delegation_enforce.default // "enforce"`，
     附 `[2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先]` 注释（S11/S12 范式对齐）。
   - 验证（临时 config 夹具 + 复制脚本到 /tmp 骨架，未动 WT config.json）：
     A 顶层 warn+schema enforce → rc=0 + `[delegation-warn]`（旧单层路径会读 enforce→rc2）；
     B 原版 config → rc=2 无 stdout（enforce，行为不变）；C 仅 schema warn → rc=0 + warn（回落层完好）。

## 关键发现（移交 C-1a②）

- 现行 Rule 23 扫描对三夹具均不产出 `[conflict]`（R23-02 的 PASS 是空转）：
  pretooluse:105/:110 的 awk `if($i ~ /\\.[a-zA-Z]/)` 在 gawk 5.2.1 下 `\\.` 解析为
  「字面反斜杠+任意字符」，普通点分路径（src/main.py）不命中 → other_scope 恒空 →
  `grep -qF "$(basename file)"` 永不触发。基线夹具已把该行为钉死为 FAIL，C-1a② 修复
  提取正则与完结计划过滤后应 3/3 PASS。
- 完结判定 truth source = `outcome:` 字段（COMPLETE|BLOCKED，大小写不敏感），非 Status/State 行。

## 备忘

- 夹具 stdin 必含 session_id：缺省落 default 会被委派门控（pretool ①-⑥ 链）拦截，Rule 23 段执行不到。
- /tmp 探针残留已清理；无 git 写操作。
