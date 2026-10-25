# Delivery Summary: task-v190 修 3 项 legacy（register-hooks L98 / SP-03 / TB-02）

## 1. 说明（做了什么）

修复 task-v189 交付总结中登记的 3 项"下一步建议"（用户全授权）：

| 项 | 问题 | 修复 | 根因 |
|----|------|------|------|
| ③ register-hooks-cj.ts L98 | `process.unlinkSync(tmp)` 调用不存在的 API | `unlinkSync(tmp)` + import 加 `unlinkSync` | `process.unlinkSync` 不存在（应用 `fs.unlinkSync`） |
| ②a SP-03 伴飞表路径 | `grep -o '/[^ |)]*SKILL\.md'` 提取 `~/.zcode/...` 时丢失 `~`，得到 `/.zcode/...` | `sed "s^\|$HOME\|"` 加 `$HOME` 前缀 | grep -o 匹配 `~` 后的 `/`，丢失 `~` |
| ②b TB-02 mini 保护区 | mini 直做通道保护区 case 不覆盖仓内 `skills/*/SKILL.md` | case 加 `*/skills/*` | case 只覆盖 `.zcode/skills/*` 等，漏仓内 `skills/` |

## 2. 产出

### 修改（3 文件）
- `skills/task-planner/scripts/register-hooks-cj.ts`（L21 import + L98 process.unlinkSync→unlinkSync）
- `skills/task-planner/scripts/selftest-split-pattern-library.sh`（L46 SP-03 sed 加 $HOME）
- `skills/task-planner/scripts/check-delegation.sh`（L311 case 加 */skills/*）

## 3. 审查详细（验证结果）

### selftest 套件（零回归）
| 基线 | 脚本数 | PASS | FAIL |
|------|--------|------|------|
| master（修复前） | 92 | 90 | 2 |
| worktree（修复后） | 92 | **92** | **0** |

**2 个 pre-existing FAIL 已修复**（`selftest-split-pattern-library` SP-03 + `selftest-tier-b` TB-02），现在 0 FAIL。

### 单项验证
- ②a SP-03：`伴飞表数据行 8 ≥6 且路径 7 条全部存在（0 缺失）` PASS
- ②b TB-02：`mini 保护区仍拦截` PASS
- ③ register-hooks-cj.ts：`node --experimental-strip-types` exit 0（--dry-run 无副作用）

### 合并回 master + push
- `git merge --no-ff wt/task-v190-skill-audit-legacy-fix`（3b50e82，7 files +902/-3）
- worktree 清理完成
- `git push origin master`（ecb5e54..3b50e82）

## 4. 风险必须列举

| 风险 | 状态 | 说明 |
|------|------|------|
| 无新增风险 | — | 3 项修复均为精确单点修复，零回归（92 PASS 0 FAIL） |

## 5. 下一步建议

无（3 项 legacy 全部修复 + push 完成）

---
**outcome: COMPLETE**（3 项修复全部验证通过，零回归，已合并回 master + push）
