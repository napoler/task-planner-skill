# Verification Contract & Phase Gates

## Goal (1 sentence)

alignment-review 写入前校验闸门深化为「五维全文扫描→标记冲突+建议处置→确认后再同步整理→按最新有效版本整理（删除或归档+术语/编号/章节结构/引用统一）→简短变更记录三要素（变更范围/冲突处理结果/文档当前状态）」,同步升级 42.6.1/42.6.3 与 C32 行,新增 RL-12/13 守护；全量 selftest 0 FAIL 后合并回 master、三部署位 IDENTICAL、push GitHub、worktree 清理。

---

## Verification Contract

- [x] VC-1: 闸门段升级在位——五维扫描（版本冲突/重复段落/过期结论/编号不一致/失效引用）+「标记冲突位置并给出建议处置方法」（两阶段防误删）+「确认后再同步整理」（ask=用户确认/silent=Rule 44 自动超时裁决 44.3）+「删除或归档」（归档=移入历史区防误删）+四项统一（术语/编号/章节结构/引用）;v102 原话锚「未经一致性校验，不直接追加新内容」:29 保留
  Evidence: 主仓 alignment-review/SKILL.md :23-29 实测;全文扫描=3/编号不一致=1/删除或归档=4/确认=11/Rule 44=1;diff 仅闸门段+变更记录段+尾注
- [x] VC-2: 变更记录段升级——简短三要素表（变更范围/冲突处理结果/文档当前状态,各=1）;原五字段信息并入未丢（依据版本→裁决依据列/残留冲突→未决项列）;「确保文档清晰、一致、可追溯」在位
  Evidence: :58-62 表实测;CR 专项 2 PASS（并入无丢失）
- [x] VC-3: CRIT 42.6.1 行内升级（五维+标记确认+Rule 44 衔接,「全文扫描」≥1）+42.6.3 三要素化（变更范围/冲突处理结果/文档当前状态各 1）;42.6.2/.4 与 44.x/43.x 零改动;C32 行「五要素→三要素」级联（C33 行「自动裁决记录五要素」另一概念保留）
  Evidence: `grep -c '^42\.6\.'`=4（行数不变）;diff 删除行仅 42.6.1/42.6.3 两行;CRIT「五要素」全文仅存 44.3 一处
- [x] VC-4: RL-12/13 在位+头注释 11→13 级联+selftest-review-library `Total: 13 PASS=13 FAIL=0`;全量回归 **41 脚本 650 PASS / 0 FAIL**（=648+RL 2 咬合,主进程定数）
  Evidence: RL-12 锚实测 2/4/1,RL-13 锚 1/1;主进程全量求和
- [x] VC-5: 合并部署 push 清理——merge 77daa52（RC=0）;三位 IDENTICAL;部署位「全文扫描」锚=2×3、「三要素」CRIT=2×3 三平台亲验;push e1180a5..77daa52 ls-remote 终验一致;worktree/branch 0/0
  Evidence: smart-merge-back [DEPLOY] 三位 IDENTICAL;ls-remote=77daa52=master
- [x] VC-6: 边界零回归+CR APPROVED——diff 面 4 文件全在 scope（+35/-18）;config 零改动;CR（code-reviewer 隔离）**APPROVED**（0 P0/P1,2 P2 指针滞后合规留置+1 条先于基线的 registry 旧文登记）
  Evidence: 04-cr-p5.md APPROVED+7 专项全 PASS

---

## 委派统计复验（Rule 25.4）
- delegated=1（P2 executor S1→S3 串行;P5-CR code-reviewer 隔离）;main_direct=3-4（P1/P3/P4/P5 簿记）,violations=[], verdict=ok, rate≈0.2
- [x] 25.4a WHITELIST-EXEMPT（直做理由全白名单①②③⑤）

## 质量门控统计（Rule 26）
- [x] Q1-Q6: 触发 1 项（CR P2×2 指针滞后=计划「42.6.4 零改动」约束下的合规留置,登记后续）;未处置 0
- [x] Evidence 抽查 ≥3: ①部署位全文扫描/三要素锚三平台亲验 ②全量 650/0 主进程定数 ③ls-remote 终验 ④闸门段逐行 Read
- [x] 未处置违规: 无 → COMPLETE

## Goal Gate (终验)

```
## Goal Verification — 写入前校验闸门深化（五维扫描+标记确认后整理+三要素变更记录）全链交付
- [x] VC-1: 闸门段五维+两阶段+归档+统一 → PASS
- [x] VC-2: 变更记录三要素 → PASS
- [x] VC-3: 42.6.1/.3+C32 级联 → PASS
- [x] VC-4: RL-12/13+全量 650/0 → PASS
- [x] VC-5: 合并部署 push 清理闭环 → PASS
- [x] VC-6: 边界零回归+CR APPROVED → PASS
```

outcome: **COMPLETE**

**遗留披露（不阻塞）**:
1. CR P2×2: CRIT 42.6.4 与 C32 行机器面指针仍写「RL-11」未随 RL-12/13 扩展（按计划零改动约束留置,后续簿记任务收编）
2. CR 留痕: selftest-registry.tsv:41「review-library 10 目录」自 task-v101 起过期（先于本区间基线,登记后续）
3. 闸门「确认后整理」的 silent 通道依赖 Rule 44 自动超时裁决（行为面消费待实战）
