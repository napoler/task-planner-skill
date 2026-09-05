# Task Plan: .bak 备份政策核查与记忆固化
<!-- template_type: deployment -->

## Goal
落实用户指令（2026-09-05）："不要使用 .bak 改名备份——技能目录里的改名备份依旧会被检索机制检测到，没有任何用处；要删除就删除，或者彻底移除技能目录。" 本任务：① 全盘核查四平台技能目录 bak 类残留 ② 修正过时记忆（deploy-flow 的 .bak 遗留行与 8 链描述）③ 将备份政策固化为 feedback 记忆。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 四平台技能目录无 .bak/改名备份残留 | ls + grep bak/backup/old 全景核查 | Bash 输出（progress.md） |
| VC-2 | feedback 记忆 skill-backup-no-rename-in-scan-path 存在且入 MEMORY.md 索引 | Read 复核 | 记忆文件路径 |
| VC-3 | deploy-flow 记忆过时遗留行已修正（.bak 已不存在） | Read 复核 | 记忆文件路径 |

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| 技能目录 | （只读核查，本次无删除对象——.bak 已不存在） | 任何技能文件改动 |
| 记忆 | ~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/** | 其他项目记忆 |

## Phases

### Phase 1: 全盘核查 + 记忆固化 + 政策落地
- **Executor:** 主进程（例外理由：只读核查 + 记忆簿记，无代码编辑；任务主体在计划创建前已完成，本计划为合规簿记收尾）
- **Status:** complete
- 核查结果：四平台（~/.zcode/skills、~/.claude/skills、~/.agents/skills、~/.config/opencode/skills）顶层均无 bak/backup/old 类命名；plan-resume.bak-20260904 已于此前会话删除（记忆陈旧）；~/skill-deploy-backups-20260904/ 集中备份在扫描路径外、命名合规
- 证据：Bash 全景核查输出（progress.md）

## 🏁 终验记录

| # | 判定标准 | 结果 | 证据 |
|---|----------|------|------|
| VC-1 | 无 .bak 残留 | PASS | 四平台 ls+grep 输出（progress.md Phase 1） |
| VC-2 | feedback 记忆已固化 | PASS | memory/skill-backup-no-rename-in-scan-path.md + MEMORY.md 索引行 |
| VC-3 | deploy-flow 遗留行修正 | PASS | 记忆文件"备份政策"行更新（含四平台核查清零） |

**outcome: COMPLETE**（2026-09-05）——VC-1~3 全 PASS，主进程直做已登记例外。
