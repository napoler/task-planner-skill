# S5 全量回归+修复 检查点 (executor, task-v136/Phase5/S5, 2026-10-05)
- worktree: /home/terry/task-planner-skill-worktrees/task-v136/skills/task-planner/
- Step1 registry 补登记: selftest-registry.tsv 第 53 行追加 execution-honesty 行(4 字段); selftest-registry.sh 自检输出:
  T01-T05 全 PASS, "Total: 5 PASS=5 FAIL=0 (registry rows=52, actual selftest=52)", exit=0
- 回归口径: 逐脚本 bash 实跑 + timeout 90s; raw.tsv 每行= 脚本名 \t exit \t 耗时s \t Total行原文
- 非标准格式: selftest-final-gate-hash.sh 末行为 "==== ... 结果: PASS=x FAIL=y ====", 按 PASS=x 计入 passed
- 基线: 784 passed / 0 failed (Phase1 定数, 51 脚本); 本轮 52 脚本 (+execution-honesty 14 断言)

## Round 1 (首轮全量)
### 批次 1 (脚本 1-10)
| selftest-active-plan.sh | 0 | 3s | Total: 19 PASS=19 FAIL=0 |
| selftest-agent-coverage.sh | 0 | 1s | Total: 9 PASS=9 FAIL=0 SKIPPED=0 |
| selftest-ask-default-timeout.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-batch-pilot.sh | 0 | 0s | Total: 10 PASS=10 FAIL=0 |
| selftest-check-conflicts.sh | 0 | 1s | Total: 7 PASS=7 FAIL=0 |
| selftest-check-drift.sh | 0 | 2s | Total: 6 PASS=6 FAIL=0 |
| selftest-conclusion-discipline.sh | 0 | 1s | Total: 24 PASS=24 FAIL=0 |
| selftest-context-hygiene.sh | 0 | 1s | Total: 12 PASS=12 FAIL=0 |
| selftest-delegation.sh | 0 | 3s | Total: 38    PASS=38  FAIL=0 |
| selftest-dispatch-grain.sh | 0 | 1s | Total: 10 PASS=10 FAIL=0 |

**批次小计 (前 10 脚本)**: PASS 累计=146, FAIL 累计=0, 非零 exit 脚本数=0

### 批次 2 (脚本 11-20)
| selftest-dispatch.sh | 0 | 6s | Total: 31 PASS=31 FAIL=0 |
| selftest-error-loop.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 |
| selftest-execution-honesty.sh | 0 | 0s | Total: 14 PASS=14 FAIL=0 |
| selftest-execution-stability.sh | 0 | 2s | Total: 19  PASS=19  FAIL=0 |
| selftest-fallback.sh | 0 | 2s | Total: 31  PASS=31  FAIL=0 |
| selftest-final-gate-hash.sh | 0 | 17s | ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ==== |
| selftest-fine-grain-steps.sh | 0 | 2s | Total: 11 PASS=11 FAIL=0 |
| selftest-interaction.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-iterative-optimizer.sh | 0 | 0s | Total: 8 PASS=8 FAIL=0 |
| selftest-knowledge-brief.sh | 0 | 1s | Total: 16  PASS=16  FAIL=0 |

**批次小计 (前 20 脚本)**: PASS 累计=325, FAIL 累计=0, 非零 exit 脚本数=0

### 批次 3 (脚本 21-30)
| selftest-lane-advancement.sh | 0 | 0s | Total: 14 PASS=14 FAIL=0 |
| selftest-mechanism-profile.sh | 0 | 5s | Total: 19 PASS=19 FAIL=0 |
| selftest-media-agents.sh | 0 | 0s | Total: 10 PASS=10 FAIL=0 |
| selftest-media-dispatch.sh | 0 | 0s | Total: 9 PASS=9 FAIL=0 |
| selftest-methodology.sh | 0 | 1s | Total: 16 PASS=16 FAIL=0 |
| selftest-plan-dispatch.sh | 0 | 2s | Total: 12 PASS=12 FAIL=0 |
| selftest-plan-tier.sh | 0 | 11s | Total: 32 PASS=32 FAIL=0 |
| selftest-reflect-verify.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 |
| selftest-registry.sh | 0 | 1s | Total: 5 PASS=5 FAIL=0 (registry rows=52, actual selftest=52) |
| selftest-reliability-institution.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 |

**批次小计 (前 30 脚本)**: PASS 累计=470, FAIL 累计=0, 非零 exit 脚本数=0

### 批次 4 (脚本 31-40)
| selftest-requirement-coverage.sh | 0 | 13s | Total: 23 PASS=23 FAIL=0 |
| selftest-requirement-grading.sh | 0 | 0s | Total: 7 PASS=7 FAIL=0 |
| selftest-rescue-chain.sh | 0 | 1s | Total: 11 PASS=11 FAIL=0 |
| selftest-review-library.sh | 0 | 1s | Total: 15 PASS=15 FAIL=0 |
| selftest-root-resolution.sh | 0 | 0s | Total: 17 PASS=17 FAIL=0 |
| selftest-rule23-conflict-scan.sh | 0 | 1s | Total: 3 PASS=3 FAIL=0 |
| selftest-rule-reserve.sh | 0 | 1s | Total: 10 PASS=10 FAIL=0 |
| selftest-self-resolution.sh | 0 | 0s | Total: 13 PASS=13 FAIL=0 |
| selftest-shared-tracker.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-skill-collab.sh | 0 | 0s | Total: 25  PASS=25  FAIL=0 |

**批次小计 (前 40 脚本)**: PASS 累计=605, FAIL 累计=0, 非零 exit 脚本数=0

### 批次 5 (脚本 41-50)
| selftest-skill-modify.sh | 0 | 1s | Total: 9 PASS=9 FAIL=0 (SKIP=0) |
| selftest-skill-split.sh | 1 | 0s | Total: 41  PASS=40  FAIL=1 |
| selftest-smart-merge.sh | 0 | 9s | Total: 17 PASS=17 FAIL=0 |
| selftest-sync-index.sh | 0 | 0s | Total: 13 PASS=13 FAIL=0 |
| selftest-task-boundary.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-template-lifecycle.sh | 0 | 0s | Total: 24 PASS=24 FAIL=0 |
| selftest-template-sense.sh | 0 | 4s | Total: 8 PASS=8 FAIL=0 |
| selftest-tier-b.sh | 0 | 2s | Total: 18 PASS=18 FAIL=0 |
| selftest-tool-selection.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 |
| selftest-vc-gate.sh | 0 | 17s | Total: 11 PASS=11 FAIL=0 |

**批次小计 (前 50 脚本)**: PASS 累计=768, FAIL 累计=1, 非零 exit 脚本数=1

### 批次 6 (脚本 43-52)
| selftest-smart-merge.sh | 0 | 9s | Total: 17 PASS=17 FAIL=0 |
| selftest-sync-index.sh | 0 | 0s | Total: 13 PASS=13 FAIL=0 |
| selftest-task-boundary.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-template-lifecycle.sh | 0 | 0s | Total: 24 PASS=24 FAIL=0 |
| selftest-template-sense.sh | 0 | 4s | Total: 8 PASS=8 FAIL=0 |
| selftest-tier-b.sh | 0 | 2s | Total: 18 PASS=18 FAIL=0 |
| selftest-tool-selection.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 |
| selftest-vc-gate.sh | 0 | 17s | Total: 11 PASS=11 FAIL=0 |
| selftest-veto.sh | 0 | 0s | Total: 13 PASS=13 FAIL=0 |
| selftest-workflow-orchestration.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 |

**批次小计 (前 52 脚本)**: PASS 累计=797, FAIL 累计=1, 非零 exit 脚本数=1


### Round 1 汇总（Step 2+3 定数，按 Total 行原文逐脚本 token 重算，非自报）
- 脚本总数: 52（含 registry.tsv 补登记后的 execution-honesty；registry 自检 T01-T05 PASS）
- passed 合计: **797**，failed 合计: **1**
- 逐脚本 PASS/FAIL 分解（重算命令: awk 按 Total/结果行 token 解析，raw_1.tsv 存档 /tmp/selftest_v136_s5/raw_1.tsv）

| 脚本 | exit | 耗时 | Total 行原文 | 状态 |
|------|------|------|-------------|------|
| selftest-active-plan.sh | 0 | 3s | Total: 19 PASS=19 FAIL=0 | OK |
| selftest-agent-coverage.sh | 0 | 1s | Total: 9 PASS=9 FAIL=0 SKIPPED=0 | OK |
| selftest-ask-default-timeout.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 | OK |
| selftest-batch-pilot.sh | 0 | 0s | Total: 10 PASS=10 FAIL=0 | OK |
| selftest-check-conflicts.sh | 0 | 1s | Total: 7 PASS=7 FAIL=0 | OK |
| selftest-check-drift.sh | 0 | 2s | Total: 6 PASS=6 FAIL=0 | OK |
| selftest-conclusion-discipline.sh | 0 | 1s | Total: 24 PASS=24 FAIL=0 | OK |
| selftest-context-hygiene.sh | 0 | 1s | Total: 12 PASS=12 FAIL=0 | OK |
| selftest-delegation.sh | 0 | 3s | Total: 38    PASS=38  FAIL=0 | OK |
| selftest-dispatch-grain.sh | 0 | 1s | Total: 10 PASS=10 FAIL=0 | OK |
| selftest-dispatch.sh | 0 | 6s | Total: 31 PASS=31 FAIL=0 | OK |
| selftest-error-loop.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 | OK |
| selftest-execution-honesty.sh | 0 | 0s | Total: 14 PASS=14 FAIL=0 | OK |
| selftest-execution-stability.sh | 0 | 2s | Total: 19  PASS=19  FAIL=0 | OK |
| selftest-fallback.sh | 0 | 2s | Total: 31  PASS=31  FAIL=0 | OK |
| selftest-final-gate-hash.sh | 0 | 17s | ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ==== | OK |
| selftest-fine-grain-steps.sh | 0 | 2s | Total: 11 PASS=11 FAIL=0 | OK |
| selftest-interaction.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 | OK |
| selftest-iterative-optimizer.sh | 0 | 0s | Total: 8 PASS=8 FAIL=0 | OK |
| selftest-knowledge-brief.sh | 0 | 1s | Total: 16  PASS=16  FAIL=0 | OK |
| selftest-lane-advancement.sh | 0 | 0s | Total: 14 PASS=14 FAIL=0 | OK |
| selftest-mechanism-profile.sh | 0 | 5s | Total: 19 PASS=19 FAIL=0 | OK |
| selftest-media-agents.sh | 0 | 0s | Total: 10 PASS=10 FAIL=0 | OK |
| selftest-media-dispatch.sh | 0 | 0s | Total: 9 PASS=9 FAIL=0 | OK |
| selftest-methodology.sh | 0 | 1s | Total: 16 PASS=16 FAIL=0 | OK |
| selftest-plan-dispatch.sh | 0 | 2s | Total: 12 PASS=12 FAIL=0 | OK |
| selftest-plan-tier.sh | 0 | 11s | Total: 32 PASS=32 FAIL=0 | OK |
| selftest-reflect-verify.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 | OK |
| selftest-registry.sh | 0 | 1s | Total: 5 PASS=5 FAIL=0 (registry rows=52, actual selftest=52) | OK |
| selftest-reliability-institution.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 | OK |
| selftest-requirement-coverage.sh | 0 | 13s | Total: 23 PASS=23 FAIL=0 | OK |
| selftest-requirement-grading.sh | 0 | 0s | Total: 7 PASS=7 FAIL=0 | OK |
| selftest-rescue-chain.sh | 0 | 1s | Total: 11 PASS=11 FAIL=0 | OK |
| selftest-review-library.sh | 0 | 1s | Total: 15 PASS=15 FAIL=0 | OK |
| selftest-root-resolution.sh | 0 | 0s | Total: 17 PASS=17 FAIL=0 | OK |
| selftest-rule23-conflict-scan.sh | 0 | 1s | Total: 3 PASS=3 FAIL=0 | OK |
| selftest-rule-reserve.sh | 0 | 1s | Total: 10 PASS=10 FAIL=0 | OK |
| selftest-self-resolution.sh | 0 | 0s | Total: 13 PASS=13 FAIL=0 | OK |
| selftest-shared-tracker.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 | OK |
| selftest-skill-collab.sh | 0 | 0s | Total: 25  PASS=25  FAIL=0 | OK |
| selftest-skill-modify.sh | 0 | 1s | Total: 9 PASS=9 FAIL=0 (SKIP=0) | OK |
| selftest-skill-split.sh | 1 | 0s | Total: 41  PASS=40  FAIL=1 | FAIL |
| selftest-smart-merge.sh | 0 | 9s | Total: 17 PASS=17 FAIL=0 | OK |
| selftest-sync-index.sh | 0 | 0s | Total: 13 PASS=13 FAIL=0 | OK |
| selftest-task-boundary.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 | OK |
| selftest-template-lifecycle.sh | 0 | 0s | Total: 24 PASS=24 FAIL=0 | OK |
| selftest-template-sense.sh | 0 | 4s | Total: 8 PASS=8 FAIL=0 | OK |
| selftest-tier-b.sh | 0 | 2s | Total: 18 PASS=18 FAIL=0 | OK |
| selftest-tool-selection.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 | OK |
| selftest-vc-gate.sh | 0 | 17s | Total: 11 PASS=11 FAIL=0 | OK |
| selftest-veto.sh | 0 | 0s | Total: 13 PASS=13 FAIL=0 | OK |
| selftest-workflow-orchestration.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 | OK |

### 基线对比（784/0 → 797/1，首轮）
- 差值 +13 = execution-honesty 14 断言 - skill-split FAIL 1（skill-split 41 断言中 1 条 ≤478 钉失败）
- 预期 ≥784 达成（797≥784）；但 failed=1 未达成 0 FAIL，进入 Step 4 修复
- FAIL 定位: selftest-skill-split.sh:41 「T-主 行数 ≤478 ... 且 ≤558 上限」——SKILL.md 现 480 行（Phase3 S2 净增 +2，478→480），478 钉未上调=断言锚滞后（knowledge-brief §4-4 行数纪律先例：上限断言同步上调带 label）；属断言锚失效非条款问题，修复=该行钉 478→480 带 task-v136 label（≤558 总上限不动，480≤558 仍满足）
- 其他 4 脚本 ≤558 cap 断言（batch-pilot/knowledge-brief/skill-collab/execution-stability）480 行下全 PASS，无需改动

### Step 4 FAIL 修复记录
- FAIL 1/1: selftest-skill-split.sh:41（478 钉）→ 根因: Phase3 S2 净增 +2 行后 478 钉未上调（断言锚滞后，属断言类缺陷非条款问题；同任务 S2 已改齐 4 个锚级联脚本，本钉为 skill-split 独有）
- 修复: 钉 478→480 带 task-v136 label + 演进链补 478→480；≤558 总上限不动；未触碰 references/critical-rules.md、SKILL.md、templates/、companion/（0 改）
- 换道记录: 无需（同法一次成功）
### 批次 1 (脚本 1-10)
| selftest-active-plan.sh | 0 | 4s | Total: 19 PASS=19 FAIL=0 |
| selftest-agent-coverage.sh | 0 | 0s | Total: 9 PASS=9 FAIL=0 SKIPPED=0 |
| selftest-ask-default-timeout.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-batch-pilot.sh | 0 | 0s | Total: 10 PASS=10 FAIL=0 |
| selftest-check-conflicts.sh | 0 | 2s | Total: 7 PASS=7 FAIL=0 |
| selftest-check-drift.sh | 0 | 2s | Total: 6 PASS=6 FAIL=0 |
| selftest-conclusion-discipline.sh | 0 | 0s | Total: 24 PASS=24 FAIL=0 |
| selftest-context-hygiene.sh | 0 | 1s | Total: 12 PASS=12 FAIL=0 |
| selftest-delegation.sh | 0 | 3s | Total: 38    PASS=38  FAIL=0 |
| selftest-dispatch-grain.sh | 0 | 2s | Total: 10 PASS=10 FAIL=0 |

**批次小计 (前 10 脚本)**: PASS 累计=146, FAIL 累计=0, 非零 exit 脚本数=0

### 批次 2 (脚本 11-20)
| selftest-dispatch.sh | 0 | 6s | Total: 31 PASS=31 FAIL=0 |
| selftest-error-loop.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 |
| selftest-execution-honesty.sh | 0 | 0s | Total: 14 PASS=14 FAIL=0 |
| selftest-execution-stability.sh | 0 | 3s | Total: 19  PASS=19  FAIL=0 |
| selftest-fallback.sh | 0 | 2s | Total: 31  PASS=31  FAIL=0 |
| selftest-final-gate-hash.sh | 0 | 18s | ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ==== |
| selftest-fine-grain-steps.sh | 0 | 2s | Total: 11 PASS=11 FAIL=0 |
| selftest-interaction.sh | 0 | 1s | Total: 11 PASS=11 FAIL=0 |
| selftest-iterative-optimizer.sh | 0 | 0s | Total: 8 PASS=8 FAIL=0 |
| selftest-knowledge-brief.sh | 0 | 0s | Total: 16  PASS=16  FAIL=0 |

**批次小计 (前 20 脚本)**: PASS 累计=325, FAIL 累计=0, 非零 exit 脚本数=0

### 批次 3 (脚本 21-30)
| selftest-lane-advancement.sh | 0 | 1s | Total: 14 PASS=14 FAIL=0 |
| selftest-mechanism-profile.sh | 0 | 4s | Total: 19 PASS=19 FAIL=0 |
| selftest-media-agents.sh | 0 | 0s | Total: 10 PASS=10 FAIL=0 |
| selftest-media-dispatch.sh | 0 | 0s | Total: 9 PASS=9 FAIL=0 |
| selftest-methodology.sh | 0 | 1s | Total: 16 PASS=16 FAIL=0 |
| selftest-plan-dispatch.sh | 0 | 2s | Total: 12 PASS=12 FAIL=0 |
| selftest-plan-tier.sh | 0 | 12s | Total: 32 PASS=32 FAIL=0 |
| selftest-reflect-verify.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 |
| selftest-registry.sh | 0 | 0s | Total: 5 PASS=5 FAIL=0 (registry rows=52, actual selftest=52) |
| selftest-reliability-institution.sh | 0 | 1s | Total: 16 PASS=16 FAIL=0 |

**批次小计 (前 30 脚本)**: PASS 累计=470, FAIL 累计=0, 非零 exit 脚本数=0

### 批次 4 (脚本 31-40)
| selftest-requirement-coverage.sh | 0 | 13s | Total: 23 PASS=23 FAIL=0 |
| selftest-requirement-grading.sh | 0 | 0s | Total: 7 PASS=7 FAIL=0 |
| selftest-rescue-chain.sh | 0 | 1s | Total: 11 PASS=11 FAIL=0 |
| selftest-review-library.sh | 0 | 1s | Total: 15 PASS=15 FAIL=0 |
| selftest-root-resolution.sh | 0 | 0s | Total: 17 PASS=17 FAIL=0 |
| selftest-rule23-conflict-scan.sh | 0 | 1s | Total: 3 PASS=3 FAIL=0 |
| selftest-rule-reserve.sh | 0 | 1s | Total: 10 PASS=10 FAIL=0 |
| selftest-self-resolution.sh | 0 | 0s | Total: 13 PASS=13 FAIL=0 |
| selftest-shared-tracker.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-skill-collab.sh | 0 | 1s | Total: 25  PASS=25  FAIL=0 |

**批次小计 (前 40 脚本)**: PASS 累计=605, FAIL 累计=0, 非零 exit 脚本数=0

### 批次 5 (脚本 41-50)
| selftest-skill-modify.sh | 0 | 0s | Total: 9 PASS=9 FAIL=0 (SKIP=0) |
| selftest-skill-split.sh | 0 | 0s | Total: 41  PASS=41  FAIL=0 |
| selftest-smart-merge.sh | 0 | 10s | Total: 17 PASS=17 FAIL=0 |
| selftest-sync-index.sh | 0 | 1s | Total: 13 PASS=13 FAIL=0 |
| selftest-task-boundary.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-template-lifecycle.sh | 0 | 0s | Total: 24 PASS=24 FAIL=0 |
| selftest-template-sense.sh | 0 | 5s | Total: 8 PASS=8 FAIL=0 |
| selftest-tier-b.sh | 0 | 1s | Total: 18 PASS=18 FAIL=0 |
| selftest-tool-selection.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 |
| selftest-vc-gate.sh | 0 | 17s | Total: 11 PASS=11 FAIL=0 |

**批次小计 (前 50 脚本)**: PASS 累计=769, FAIL 累计=0, 非零 exit 脚本数=0

### 批次 6 (脚本 43-52)
| selftest-smart-merge.sh | 0 | 10s | Total: 17 PASS=17 FAIL=0 |
| selftest-sync-index.sh | 0 | 1s | Total: 13 PASS=13 FAIL=0 |
| selftest-task-boundary.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-template-lifecycle.sh | 0 | 0s | Total: 24 PASS=24 FAIL=0 |
| selftest-template-sense.sh | 0 | 5s | Total: 8 PASS=8 FAIL=0 |
| selftest-tier-b.sh | 0 | 1s | Total: 18 PASS=18 FAIL=0 |
| selftest-tool-selection.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 |
| selftest-vc-gate.sh | 0 | 17s | Total: 11 PASS=11 FAIL=0 |
| selftest-veto.sh | 0 | 1s | Total: 13 PASS=13 FAIL=0 |
| selftest-workflow-orchestration.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 |

**批次小计 (前 52 脚本)**: PASS 累计=798, FAIL 累计=0, 非零 exit 脚本数=0


## Round 2 (最终全量复跑, Step 5)

| selftest-active-plan.sh | 0 | 4s | Total: 19 PASS=19 FAIL=0 |
| selftest-agent-coverage.sh | 0 | 0s | Total: 9 PASS=9 FAIL=0 SKIPPED=0 |
| selftest-ask-default-timeout.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-batch-pilot.sh | 0 | 0s | Total: 10 PASS=10 FAIL=0 |
| selftest-check-conflicts.sh | 0 | 2s | Total: 7 PASS=7 FAIL=0 |
| selftest-check-drift.sh | 0 | 2s | Total: 6 PASS=6 FAIL=0 |
| selftest-conclusion-discipline.sh | 0 | 0s | Total: 24 PASS=24 FAIL=0 |
| selftest-context-hygiene.sh | 0 | 1s | Total: 12 PASS=12 FAIL=0 |
| selftest-delegation.sh | 0 | 3s | Total: 38    PASS=38  FAIL=0 |
| selftest-dispatch-grain.sh | 0 | 2s | Total: 10 PASS=10 FAIL=0 |
| selftest-dispatch.sh | 0 | 6s | Total: 31 PASS=31 FAIL=0 |
| selftest-error-loop.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 |
| selftest-execution-honesty.sh | 0 | 0s | Total: 14 PASS=14 FAIL=0 |
| selftest-execution-stability.sh | 0 | 3s | Total: 19  PASS=19  FAIL=0 |
| selftest-fallback.sh | 0 | 2s | Total: 31  PASS=31  FAIL=0 |
| selftest-final-gate-hash.sh | 0 | 18s | ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ==== |
| selftest-fine-grain-steps.sh | 0 | 2s | Total: 11 PASS=11 FAIL=0 |
| selftest-interaction.sh | 0 | 1s | Total: 11 PASS=11 FAIL=0 |
| selftest-iterative-optimizer.sh | 0 | 0s | Total: 8 PASS=8 FAIL=0 |
| selftest-knowledge-brief.sh | 0 | 0s | Total: 16  PASS=16  FAIL=0 |
| selftest-lane-advancement.sh | 0 | 1s | Total: 14 PASS=14 FAIL=0 |
| selftest-mechanism-profile.sh | 0 | 4s | Total: 19 PASS=19 FAIL=0 |
| selftest-media-agents.sh | 0 | 0s | Total: 10 PASS=10 FAIL=0 |
| selftest-media-dispatch.sh | 0 | 0s | Total: 9 PASS=9 FAIL=0 |
| selftest-methodology.sh | 0 | 1s | Total: 16 PASS=16 FAIL=0 |
| selftest-plan-dispatch.sh | 0 | 2s | Total: 12 PASS=12 FAIL=0 |
| selftest-plan-tier.sh | 0 | 12s | Total: 32 PASS=32 FAIL=0 |
| selftest-reflect-verify.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 |
| selftest-registry.sh | 0 | 0s | Total: 5 PASS=5 FAIL=0 (registry rows=52, actual selftest=52) |
| selftest-reliability-institution.sh | 0 | 1s | Total: 16 PASS=16 FAIL=0 |
| selftest-requirement-coverage.sh | 0 | 13s | Total: 23 PASS=23 FAIL=0 |
| selftest-requirement-grading.sh | 0 | 0s | Total: 7 PASS=7 FAIL=0 |
| selftest-rescue-chain.sh | 0 | 1s | Total: 11 PASS=11 FAIL=0 |
| selftest-review-library.sh | 0 | 1s | Total: 15 PASS=15 FAIL=0 |
| selftest-root-resolution.sh | 0 | 0s | Total: 17 PASS=17 FAIL=0 |
| selftest-rule23-conflict-scan.sh | 0 | 1s | Total: 3 PASS=3 FAIL=0 |
| selftest-rule-reserve.sh | 0 | 1s | Total: 10 PASS=10 FAIL=0 |
| selftest-self-resolution.sh | 0 | 0s | Total: 13 PASS=13 FAIL=0 |
| selftest-shared-tracker.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-skill-collab.sh | 0 | 1s | Total: 25  PASS=25  FAIL=0 |
| selftest-skill-modify.sh | 0 | 0s | Total: 9 PASS=9 FAIL=0 (SKIP=0) |
| selftest-skill-split.sh | 0 | 0s | Total: 41  PASS=41  FAIL=0 |
| selftest-smart-merge.sh | 0 | 10s | Total: 17 PASS=17 FAIL=0 |
| selftest-sync-index.sh | 0 | 1s | Total: 13 PASS=13 FAIL=0 |
| selftest-task-boundary.sh | 0 | 0s | Total: 11 PASS=11 FAIL=0 |
| selftest-template-lifecycle.sh | 0 | 0s | Total: 24 PASS=24 FAIL=0 |
| selftest-template-sense.sh | 0 | 5s | Total: 8 PASS=8 FAIL=0 |
| selftest-tier-b.sh | 0 | 1s | Total: 18 PASS=18 FAIL=0 |
| selftest-tool-selection.sh | 0 | 0s | Total: 12 PASS=12 FAIL=0 |
| selftest-vc-gate.sh | 0 | 17s | Total: 11 PASS=11 FAIL=0 |
| selftest-veto.sh | 0 | 1s | Total: 13 PASS=13 FAIL=0 |
| selftest-workflow-orchestration.sh | 0 | 0s | Total: 16 PASS=16 FAIL=0 |

### Round 2 汇总（Step 3 定数，逐脚本 Total 行原文重算，非自报）
- 脚本总数: 52 | 非零 exit 数: 0
- **passed 合计: 798 | failed 合计: 0**（达标: failed=0 且 798≥784）
- 与 Round 1 逐脚本 diff: 仅 selftest-skill-split.sh 行 'PASS=40 FAIL=1' → 'PASS=41 FAIL=0'（修复后断言重跑通过）；其余 51 脚本 Total 行逐字不变

### 基线对比最终定数（784/0 → 798/0）
- 差值 +14 = execution-honesty 新增 14 断言（EH-01..14，14/14 PASS）；skill-split 修复仅改断言钉不增断言数（41 不变）
- 非标准行核算: final-gate-hash 'PASS=22 FAIL=0' 已计入（两轮均按 token 解析，两轮该脚本 22 一致，与 Phase1 基线 §五修正记录 762→784 同源口径）
- 51 旧脚本 Total 行两轮逐字一致 = 修复未漂移任何既有断言

### CONFLICT 检查
- 未发现与并行会话（v134/v135）同名脚本冲突；52 脚本=基线 51+execution-honesty 1，无他任务新增脚本混入
