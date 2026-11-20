# ck-audit-r4 — R4 复审断点（审计体=critic）

- 时间：2026-11-20T22:21:49+08:00
- 状态：完成（裁决已定，待回传）

## 已完成
1. 基线：progress.md [plan-audit-R3]/[处置] 段 + verification.md VC-2:20 / VC-3:22-24 / VC-5:33 实读
2. 独立复跑（/tmp/r4audit 自建，worktree 只读、未改动；git status 干净）
3. 快扫：VC-1/VC-4 未破；13 条 Verify 命令 bash -n 全 OK

## 关键复跑结果
| 对象 | 结果 |
|---|---|
| 未修 worktree VC-1..VC-5 | rc=1/1/2/1/1 全红（VC-3 红在夹具 A：pta side 未写） |
| canon mock（锚定 -Eq + 指针未切换） | VC-3 rc=0、VC-2 rc=0、selftest 10/10 |
| loose mock（行首 `.*status.*in_progress`） | VC-3 rc=2（夹具 C ptc 抓住） |
| bold_only mock（仅 `^- **Status:** in_progress`） | VC-3 rc=1（夹具 B 抓住） |
| g1 mock（canon + 同 sid 通告直写） | VC-1 rc=0 |
| VC-4 mock（D/E 块补 .session-owner/attest） | VC-4 rc=0 |
| repo5（clone+PL-11..14） | VC-5 rc=0；掏空=1；仅 PL-11/12=1；越界新脚本=1（含已提交态） |
| vc2bad（有文案仍写 side） | VC-2 rc=1（side≠my-task 断言有效） |

## 残留问题（W=3 NIT=1，无 C/I）
- W-1 VC-3 init 侧无行为夹具：init 换拼写为 `grep -qiE 'Status.*in_progress'` → VC-3 rc=0（evade mock）
- W-2 VC-5 计数可被 no-op `ok "PL-11 …"` 满足（repo5 首轮即 rc=0）
- W-3 VC-3 静态反向只剥整行注释：行尾内联注释引旧串 → 正确实现被误红 rc=1（inline_note3）
- NIT-1 Phase1 门 V-1.2 仅 A/B 夹具，缺 C，弱于 VC-3

## 裁决
APPROVED（C=0 I=0 W=3 NIT=1）
