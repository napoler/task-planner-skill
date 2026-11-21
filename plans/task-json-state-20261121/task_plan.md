# Task Plan: task-planner 结构化状态升级（JSON 权威源 + Python 脚本固化 SOP）

## 目标
把 task-planner 从"Agent 用正则从半结构化 Markdown 抽状态 + 反复文本编辑"升级为"脚本对 JSON 做原子 CRUD + 自动生成 MD 视图 + tags 倒排检索"。用户裁决：正则不是最高效策略，改用固定脚本固化 SOP。

## 阶段（P1-P7）
- [x] P1 定义 plan-state.schema.json + 模板
- [x] P2 实现 planctl.py（CRUD/原子写/备份/tags/render/check）
- [x] P3 改造机器门 + init-session/attest 接线
- [x] P4 SKILL.md SOP 硬条款 + 旧脚本转 shim
- [x] P5 selftest-planctl.py + selftest-planctl-shim.sh + registry 登记
- [x] P6 全量回归 + 端到端迁移试点 + 备份恢复验证
- [x] P7 合并回 master（merge 8590bf0）+ 清理 worktree + 三处部署位 diff=0

## Status
COMPLETE。P1-P7 全完成。SHIM 15/15 + PLANCTL 14/14 主进程复跑通过；全量 selftest 104 PASS FAIL=8（不增）；端到端 init→CRUD→tag→render→check→backup→corrupt→restore→validate 全绿；三处部署位 13 文件 md5 全对齐（DEPLOY_FAIL=0），部署位 selftest 复跑全 PASS。

## 验收
- planctl.py 全子命令可用，原子写+备份+schema 校验+tags 检索
- 全量 selftest FAIL 数不增
- 端到端：task-ep36-restructure-001 试点 init→CRUD→render→check 全绿，改坏 JSON 可 restore
- 三处部署位 md5 diff=0

## 验证
见每阶段 Verify command；终验跑 selftest-planctl.py + 现有全量 selftest + 部署 diff。

## worktree
/mnt/data/dev/task-planner-skill/tmp/worktrees/task-json-state-20261121 （分支 wt/task-json-state-20261121，基准 master）
