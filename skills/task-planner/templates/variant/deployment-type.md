<!-- template_type: deployment -->
<!-- 适用场景: CI/CD 配置、Docker 镜像、k8s 部署、nginx 配置、cron 任务、环境变量、基础设施即代码 -->
<!-- 触发关键词: 部署/CI/CD/Docker/k8s/nginx/cron/基础设施/terraform/ansible -->
<!-- 推荐 subagent: executor (sonnet-1) + general-purpose (无专门 devops agent) -->

# Task Plan: [部署任务名称]

## Goal
[一句话:部署/配置什么(应用版本/服务/中间件/配置),达成什么状态(健康/可访问/可回滚)]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 部署前 staging 验证通过 | staging 端点 200 + 关键流程冒烟 | staging URL 输出 |
| VC-2 | 健康检查端点 200 | `curl /health` 或 `kubectl get pods` | `tmp/health-check.txt` |
| VC-3 | 回滚预案就绪(蓝绿/版本回退) | 回滚脚本 + 上一版本镜像 tag 保留 | `tmp/rollback-plan.md` |
| VC-4 | 配置变更可审计(diff 落盘) | `git diff` config 文件 + 提交记录 | `git log --stat` |
| VC-5 | 部署后无告警(日志/metric 正常) | 监控面板 + 错误率 ≤基线 | 监控截图 / alert 日志 |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-2 失败 = 部署未生效 = BLOCKED 升级用户
- VC-3 缺失 = 无回滚能力 = PARTIAL(高风险)

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 配置 | [如 Dockerfile / k8s/*.yaml / nginx.conf] | 其他无关配置 |
| 脚本 | [如 deploy.sh / rollback.sh] | 其他脚本 |
| CI/CD | [如 .github/workflows/*.yml / .gitlab-ci.yml] | 其他 |
| 文档 | [如 RUNBOOK.md / DEPLOY.md] | 其他 |

**强制约束**:
- 部署脚本必须先在 staging 验证,禁止直接上生产
- 回滚脚本必须与部署脚本成对存在
- 配置变更必须经 git commit 落盘,禁止直接 SSH 改线上

## Current Phase
Phase 1

## Phases

### Phase 1: 环境清单 + staging 准备
- [ ] 派 `Agent(subagent_type: executor)` 列环境清单(staging/prod/区域/网络/密钥)
- [ ] staging 环境预演脚本就绪
- [ ] 输出环境清单到 `tmp/env-inventory.md`
- **Status:** pending

### Phase 2: 配置变更(infra as code)
- [ ] 派 `code-assistant` 或 `executor` 改 Dockerfile / k8s yaml / nginx conf
- [ ] 配置文件全部 git 落盘(禁止 SSH 直改)
- [ ] 镜像/包版本号清晰可追溯(git tag 或 registry tag)
- **Status:** pending

### Phase 3: staging 验证
- [ ] 部署到 staging
- [ ] 派 `code-runner-agent` 跑冒烟测试 + 健康检查
- [ ] staging 通过 → 进入生产;否则修复配置直到通过
- **Status:** pending

### Phase 4: 生产部署(蓝绿/灰度)
- [ ] 备份当前生产版本(镜像 tag / 配置快照)
- [ ] 灰度发布(按比例切流 1% → 10% → 100%)
- [ ] 写 rollback.sh 脚本(回退到上一版本)
- **Status:** pending

### Phase 5: 部署后监控 + 收尾
- [ ] 监控告警阈值检查(错误率/延迟/资源)
- [ ] CI/CD 流水线更新(GitHub Actions / GitLab CI)
- [ ] RUNBOOK.md 更新(部署步骤/回滚步骤/常见问题)
- [ ] `Skill("task-drift-guard")` 终验
- **Status:** pending

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk` |
| `isolation` | `worktree`(默认 — 涉及运行中基础设施,§十一 P0) |
| `worktree_path` | `<repo-parent>/<repo>-worktrees/<task-id>` |
| `branch` | `wt/<task-id>` |
| `merge_back` | `pending` → `merged(<commit>)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | staging 准备 |
| Phase 2 | ☐ |  | 配置变更 |
| Phase 3 | ☐ |  | staging 验证 |
| Phase 4 | ☐ |  | 生产部署 |
| Phase 5 | ☐ |  | 监控收尾 |

## Key Questions

1. 部署策略(蓝绿 / 灰度 / 直接替换)?
2. 回滚 SLA(目标 <5min)?
3. 配置变更是否需 DBA/运维审批?
4. 是否需要变更窗口(非高峰)?

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 部署策略 | ... |
| 镜像 tag 策略 | ... |
| 回滚 SLA | ... |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- **铁律**:无 staging 验证 → 禁止生产部署(VC-1 门控)
- 无回滚预案 → 禁止生产部署(VC-3 门控)
- 部署相关配置主进程不直接 Edit — 派子代理
- 每 2-3 个 Phase 完成 → 跑 `Skill("task-drift-guard")`
- 部署属 §十一 P0 必 worktree 范围
