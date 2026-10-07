# checkpoint: sub:11-code-assistant (task-v144 S-unit 11)

status: done (全部修改落盘+验证完成；遗留 FAIL 均为文档面依赖，非本 unit 可修)

## 已完成修改（三同步：docblock+断言+诊断串）

### selftest-tool-selection.sh
- TS-05（原 L9/L53-56）: `grep -c 'Rules 1-39'=2 且 '1-40'=0` → `grep -c 'Critical Rules 1-62'≥1 且 '1-39'=0`
  （对齐既有负断言风格：旧字面全量负断言 `1-39`=0）
- TS-12（原 L17/L89-92）: 键数 40 → 42（v145 合法加 2 键，FF 守护 selftest-four-file-dataflow FF-15 断言 42 为准）
- 级联注释 `[2026-10-08 task-v144 合并级联]` 已加于 docblock + 行内注释

### selftest-self-resolution.sh
- SR-07（原 L11/L65-68）: 同 TS-05 型演进（Critical Rules 1-62≥1 且 1-39=0）
- SR-09（原 L14/L78-81）: 键数 40 → 42
- SR-12（原 L17）: docblock 行 40 → 写定 60（脚本 59+表头，按「补登后」事实）+级联注释；
  行内断言保持既有 v100 动态口径（ls selftest-*.sh +1 表头）不重复锁定，
  bad() 诊断串同步显示 expected=脚本数+表头（动态）

## 实跑结果（Total 原文行）
- tool-selection: `Total: 12 PASS=11 FAIL=1` — TS-05 FAIL
- self-resolution: `Total: 13 PASS=11 FAIL=2` — SR-07 / SR-12 FAIL

## 遗留 FAIL 归因（不在 scope，需后续单元）
1. TS-05/SR-07: SKILL.md:273 旧括注「Rules 1-39（含 Rule 40-55 全集…）」残留 1 处 `1-39` 字面
   → `grep -c '1-39'` =1。SKILL.md 属 scope 禁改（本 unit 只动两脚本），
   括注演进至「Critical Rules 1-62」须由 SKILL.md 修单单元执行。
2. SR-12: selftest-registry.tsv 缺 periodic-review 补登（59 行 vs 期望 60=59 脚本+表头）
   → registry.tsv 属后续单元 scope（brief §4 明示）。

## 负结果检查
- 检查了 selftest-four-file-dataflow.sh FF-15（42 键既有断言，同口径依据）、
  SKILL.md 字面分布（L9 索引行 1-62 / L273 旧括注 / L342 References 表行 1-62）、
  registry.tsv 逐脚本登记核对（唯一缺口=periodic-review）。
- 未触碰：registry.tsv、SKILL.md、其他脚本、git add/commit。

## 验证
- `bash selftest-tool-selection.sh` / `bash selftest-self-resolution.sh` 实跑，输出见上
- `git diff --stat` 仅两目标文件有本 unit 变更（另两 M 文件 execution-stability /
  knowledge-brief 为前序 unit 遗留，未动）
