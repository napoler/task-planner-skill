#!/usr/bin/env python3
"""SKILL.md 三处封堵增量 → 5 个部署位的最小侵入同步预案（预备，非本轮执行）。

授权状态：用户 /goal 明确修正指令；但 AskUserQuestion 两轮未作答，宪法 §六 /
项目 AGENTS.md / 记忆 task-goal-autonomous-deploy-drift-20261118:21 一致要求
『明确授权后才动部署位』，故本脚本默认 dry-run，仅在用户显式放行后加 --execute。

安全设计：
  1. 严禁 cp 源码整文件覆盖——各位存在历史适配/欠账，整文件覆盖会抹掉他人增量。
     只按文本行精确替换三处增量（从 source 与 zcode 位逐行 diff 自动提取，零硬编码）。
  2. 每位先断言：三处 old 行各恰出现 1 次、锚=0；否则中止（防误伤/部分部署）。
  3. 写前备份到同名 .bak-<时间戳>；写后重读验证三锚=1、old=0；幂等（已部署则 SKIP）。
"""
import pathlib
import shutil
import sys
from datetime import datetime

ROOT = pathlib.Path(__file__).resolve().parents[2]
SRC = ROOT / "skills" / "task-planner" / "SKILL.md"
HOME = pathlib.Path.home()
POSITIONS = [
    HOME / ".zcode" / "skills" / "task-planner" / "SKILL.md",
    HOME / ".claude" / "skills" / "task-planner" / "SKILL.md",
    HOME / ".agents" / "skills" / "task-planner" / "SKILL.md",
    HOME / ".config" / "opencode" / "skills" / "task-planner" / "SKILL.md",
    HOME / ".cursor" / "skills" / "task-planner" / "SKILL.md",
]
ANCHORS = ["planctl add --section knowledge_use", "采集→消费闭环", "purpose 非空"]


def extract_pairs():
    """从 source 与 zcode 位(旧版基线)逐行 diff 得出 (old_line, new_line) 三元组。"""
    src = SRC.read_text(encoding="utf-8").splitlines()
    zcode = POSITIONS[0].read_text(encoding="utf-8").splitlines()
    if len(src) != len(zcode):
        raise SystemExit(f"ABORT: 源码与 zcode 位行数不等 {len(src)} vs {len(zcode)}，无法逐行 diff")
    pairs = [(zcode[i], src[i]) for i in range(len(src)) if src[i] != zcode[i]]
    if len(pairs) != 3:
        raise SystemExit(f"ABORT: 预期 3 处增量，实测 {len(pairs)}——zcode 位可能已被部署或源码漂移，禁止盲替换")
    joined = "\n".join(n for _, n in pairs)
    missing = [a for a in ANCHORS if a not in joined]
    if missing:
        raise SystemExit(f"ABORT: 提取的增量缺锚 {missing}")
    return pairs


def main():
    execute = "--execute" in sys.argv[1:]
    pairs = extract_pairs()
    stamp = datetime.now().strftime("%Y%m%dT%H%M%S")
    print(f"MODE={'EXECUTE' if execute else 'DRY-RUN (默认，不写盘)'}  增量对数={len(pairs)}")
    print(f"SOURCE={SRC}\n")
    for dst in POSITIONS:
        name = str(dst).replace(str(HOME), "~")
        if not dst.is_file():
            print(f"[MISS] {name}: 文件不存在，跳过")
            continue
        txt = dst.read_text(encoding="utf-8")
        hit = [a for a in ANCHORS if a in txt]
        if len(hit) == 3:
            print(f"[SKIP] {name}: 三锚齐全，已部署")
            continue
        if hit:
            print(f"[ERROR] {name}: 部分命中 {hit}，状态不确定，中止待人工介入")
            continue
        # 三锚全无 = 旧版，执行替换前断言
        for old, new in pairs:
            if txt.count(old) != 1:
                print(f"[ERROR] {name}: old 行出现 {txt.count(old)} 次(应为1)，中止: {old[:60]}")
                break
        else:
            new_txt = txt
            for old, new in pairs:
                new_txt = new_txt.replace(old, new, 1)
            if not all(a in new_txt for a in ANCHORS):
                print(f"[ERROR] {name}: 替换后锚校验失败，中止")
                continue
            if execute:
                bak = dst.with_name(dst.name + f".bak-{stamp}")
                shutil.copy2(dst, bak)
                dst.write_text(new_txt, encoding="utf-8")
                check_lines = dst.read_text(encoding="utf-8").splitlines()
                check = "\n".join(check_lines)
                # 修复假阴性：old 行是 new 行的前缀，子串 `o in check` 恒真，
                # 故不能用 `o not in check`。改为 new 行精确整行存在 + 三锚命中。
                ok = all(a in check for a in ANCHORS) and all(n in check_lines for _, n in pairs)
                print(f"[DONE] {name}: 备份={bak.name} 验证={'PASS' if ok else 'FAIL(需回滚)'}")
            else:
                print(f"[WOULD] {name}: 将备份+替换3行，验证通过后写入（未执行）")
    print("\n放行方式：确认后运行  python3 " + str(pathlib.Path(__file__)) + " --execute")


if __name__ == "__main__":
    main()
