# /goal 程序化触达面实证（task-v151 G1 证据锚）

> 背景：R3/R5 澄清后需实证「/goal 是否可被技能层程序化代调/读取」。2026-10-09 06:0x 主进程 3 处查证（只读，未改任何文件）。

## 查证动作与结论（Rule 63.3 合法形态：已检索清单 + 证据锚）

| # | 查证动作 | 结果 | 结论 |
|---|---------|------|------|
| 1 | `find /opt/ZCode -maxdepth 4 -iname '*goal*'` | 空（无匹配文件/目录） | ZCode 安装面无 goal 独立模块 |
| 2 | `grep -i goal ~/.zcode/cli/config.json` + `ls ~/.zcode/cli/`（agents/artifacts/config.json/db/exec/image-cache/log/memories/plugins/rollout） | 无 goal 字段/目录 | CLI 配置与状态面无 goal 程序化载体 |
| 3 | `grep -ril goal ~/.zcode/cli --include='*.json' --include='*.md'`（排除 memories）+ 抽查 1 个命中 agent metadata（python walk 顶层键） | 命中均为 agent prompt/description 文本内「goal」一词；metadata 顶层键（agentId/childSessionId/profileId/prompt/status/…）无结构化 goal 字段 | 会话数据面无 goal 结构化存储可写 |

## 定论
- /goal = ZCode 用户侧 harness 内置命令（用户输入框直接输入即激活目标模式），**无技能层可代调/可读取的程序化接口**。
- 与 critical-rules.md 40.3 既有口径一致（「/goal 为用户侧 harness 命令，技能层不可代调，仅做映射指引」）；本实证将其证据化，Rule 66.2 承接此口径并升级为固纪律。
- 技能层职责收敛为：Goal 单元表=映射供料载体；执行期每 goal 翻 complete 单行呈示证据锚（66.2/44.5 展示限制）。
