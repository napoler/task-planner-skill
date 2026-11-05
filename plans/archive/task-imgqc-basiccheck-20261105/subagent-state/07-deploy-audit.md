# 12 位部署对账表（VC-4，2026-11-06）
部署源=master 0508586（merge 1ddedcb）；SRC_A=9e9eb2f8 SRC_V=16b56511 SRC_M=f582589d

| # | 位 | 路径 | md5 | 对账 |
|---|----|------|-----|------|
| 1 | zcode agents image | ~/.zcode/agents/image-generation-executor.md | 9e9eb2f8 | diff=0 ✓ |
| 2 | zcode agents video | ~/.zcode/agents/video-generation-executor.md | 16b56511 | diff=0 ✓ |
| 3 | claude agents image | ~/.claude/agents/image-generation-executor.md | 9e9eb2f8 | diff=0 ✓ |
| 4 | claude agents video | ~/.claude/agents/video-generation-executor.md | 16b56511 | diff=0 ✓ |
| 5 | cursor agents image | ~/.cursor/agents/image-generation-executor.md | 9e9eb2f8 | diff=0 ✓ |
| 6 | cursor agents video | ~/.cursor/agents/video-generation-executor.md | 16b56511 | diff=0 ✓ |
| 7 | zcode companion image | ~/.zcode/skills/task-planner/companion/agents/image-generation-executor.md | 9e9eb2f8 | diff=0 ✓（rm+cp 判例通道）|
| 8 | zcode companion video | ~/.zcode/skills/task-planner/companion/agents/video-generation-executor.md | 16b56511 | diff=0 ✓ |
| 9 | claude companion image | ~/.claude/skills/task-planner/companion/agents/image-generation-executor.md | 9e9eb2f8 | diff=0 ✓（smart-merge-back --deploy 自动位）|
| 10 | claude companion video | ~/.claude/skills/task-planner/companion/agents/video-generation-executor.md | 16b56511 | diff=0 ✓（同上）|
| 11 | cursor companion image | ~/.cursor/skills/task-planner/companion/agents/image-generation-executor.md | 9e9eb2f8 | diff=0 ✓ |
| 12 | cursor companion video | ~/.cursor/skills/task-planner/companion/agents/video-generation-executor.md | 16b56511 | diff=0 ✓ |
| 13-15 | media-planner rules ×3 | ~/.{zcode,claude,cursor}/skills/media-planner/references/critical-rules-media.md | f582589d ×3 | diff=0 ✓ |

frontmatter 零差异预检先行（agents 6 位 diff=0 证实直接 cp 合法）；运行位 zcode companion REJECTED 自保护→rm+cp 判例通道。
