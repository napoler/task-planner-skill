#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""selftest-planctl.py — planctl.py 的端到端自检（P5，2026-11-21 task-json-state-20261121）。

WHAT：每个用例在 worktree 内的 tmp/planctl-selftest/ 下建独立临时 plan-dir，通过 subprocess
  真调 planctl.py（不 import 内部函数），覆盖 init→get 往返、CRUD、状态流转、tag 倒排、render、
  备份恢复、validate 拒绝非法 JSON、原子写无半文件、4 个 check 的正反例与 rc2 输入异常。
WHY：机器门会直接消费 planctl 的 stdout/rc；只测内部函数无法发现 CLI 参数与输出契约漂移。
输出：每例 `TEST <name>: PASS|FAIL`，末行 `TOTAL N PASS M FAIL K`；全 PASS exit 0，否则 1。
依赖：仅 Python 3 标准库。
"""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Callable

SCRIPTS_DIR = Path(__file__).resolve().parent
PLANCTL = SCRIPTS_DIR / "planctl.py"
# 所有临时写入落在 worktree 的 tmp/（已 gitignore），遵守「只写指定 worktree」约束。
SCRATCH_ROOT = SCRIPTS_DIR.parents[2] / "tmp" / "planctl-selftest"


def run_plan(plan: Path, *args: str, raw: bool = False) -> subprocess.CompletedProcess[str]:
    """调用 planctl.py；--plan-dir 统一附在末尾，返回含 rc/stdout/stderr 的完成对象。"""
    cmd = [sys.executable, str(PLANCTL), *args, "--plan-dir", str(plan)]
    return subprocess.run(cmd, capture_output=True, text=True, timeout=60, check=False)


def ok(cp: subprocess.CompletedProcess[str], label: str) -> subprocess.CompletedProcess[str]:
    """断言命令成功；失败时把 stderr 原文带进断言消息，避免黑盒猜错。"""
    assert cp.returncode == 0, f"{label}: rc={cp.returncode} stderr={cp.stderr.strip()!r} stdout={cp.stdout.strip()!r}"
    return cp


def bad(cp: subprocess.CompletedProcess[str], label: str) -> subprocess.CompletedProcess[str]:
    """断言命令失败（rc != 0）。"""
    assert cp.returncode != 0, f"{label}: 预期失败但 rc=0 stdout={cp.stdout.strip()!r}"
    return cp


def out_json(cp: subprocess.CompletedProcess[str]) -> Any:
    """解析 stdout 为 JSON；解析失败即暴露原文。"""
    try:
        return json.loads(cp.stdout)
    except json.JSONDecodeError as exc:
        raise AssertionError(f"stdout 非 JSON: {exc}; 原文={cp.stdout!r}") from exc


def new_plan(root: Path, task_id: str = "selftest") -> Path:
    """建一个已 init 的干净 plan-dir。"""
    plan = root / "plan"
    plan.mkdir(parents=True)
    ok(run_plan(plan, "init", "--task-id", task_id), "init")
    return plan


def add_vc(plan: Path, vid: str, command: str, evidence: str = "") -> None:
    """测试夹具：新增一条 VC。"""
    ok(run_plan(plan, "add", "--section", "vcs",
                "--json", json.dumps({"id": vid, "criterion": "c", "command": command,
                                      "evidence": evidence}, ensure_ascii=False)), f"add vc {vid}")


def add_audit(plan: Path, rnd: int, verdict: str, issues: str | None = None,
              c: int = 0, i: int = 0, w: int = 0) -> subprocess.CompletedProcess[str]:
    """[2026-11-21] 测试夹具：追加审计轮；issues=None 表示不传 --issues-json（旧行为）。"""
    args = ["audit-add", "--round", str(rnd), "--verdict", verdict, "--by", "critic",
            "--c", str(c), "--i", str(i), "--w", str(w)]
    if issues is not None:
        args.extend(("--issues-json", issues))
    return run_plan(plan, *args)


def assert_check_line(cp: subprocess.CompletedProcess[str], name: str, verdict: str) -> str:
    """校验 check 的 stdout 恰为单行约定格式，返回原文供进一步断言。"""
    line = cp.stdout.strip()
    assert len(line.splitlines()) == 1, f"check 输出必须单行: {cp.stdout!r}"
    assert line.startswith(f"PLANCTL CHECK {name}: {verdict} "), f"check 行格式错误: {line!r}"
    return line


# ───────────────────────────────── 用例 ─────────────────────────────────

def case_init_get(root: Path) -> None:
    plan = new_plan(root, "t-init")
    doc = out_json(ok(run_plan(plan, "get"), "get whole"))
    assert doc["task_id"] == "t-init", doc
    assert doc["schema_version"] == 1 and doc["plan_tier"] == "standard", doc
    assert doc["created_at"] and doc["updated_at"], doc
    assert ok(run_plan(plan, "validate"), "validate").stdout.strip() == "VALIDATE PASS"


def case_crud(root: Path) -> None:
    plan = new_plan(root)
    ok(run_plan(plan, "add", "--section", "requirements",
                "--json", '{"id":"R1","text":"原","type":"目标","vc":[]}'), "add R1")
    entry = out_json(ok(run_plan(plan, "get", "--section", "requirements", "--id", "R1"), "get R1"))
    assert entry["text"] == "原", entry
    ok(run_plan(plan, "set", "--section", "requirements", "--id", "R1",
                "--field", "text", "--value", "改"), "set text")
    entry = out_json(ok(run_plan(plan, "get", "--section", "requirements", "--id", "R1"), "get R1"))
    assert entry["text"] == "改", entry
    ok(run_plan(plan, "update", "--section", "requirements", "--id", "R1", "--json",
                '{"id":"R1","text":"终","type":"手段","vc":[],"tags":["x"]}'), "update R1")
    entry = out_json(ok(run_plan(plan, "get", "--section", "requirements", "--id", "R1"), "get R1"))
    assert entry["text"] == "终" and entry["tags"] == ["x"], entry
    ok(run_plan(plan, "delete", "--section", "requirements", "--id", "R1"), "delete R1")
    assert out_json(ok(run_plan(plan, "get", "--section", "requirements"), "get reqs")) == []


def case_status_transitions(root: Path) -> None:
    plan = new_plan(root)
    before = out_json(ok(run_plan(plan, "get"), "get"))["updated_at"]
    ok(run_plan(plan, "add", "--section", "phases",
                "--json", '{"id":"P1","v_checks":["VC-1"]}'), "add P1")
    add_vc(plan, "VC-1", "grep -q x file")
    ok(run_plan(plan, "phase-done", "--id", "P1"), "phase-done")
    ok(run_plan(plan, "vc-pass", "--id", "VC-1"), "vc-pass")
    assert out_json(ok(run_plan(plan, "get", "--section", "vcs", "--id", "VC-1"), "get VC"))["status"] == "pass"
    ok(run_plan(plan, "vc-fail", "--id", "VC-1"), "vc-fail")
    st = out_json(ok(run_plan(plan, "status"), "status"))
    assert st["phase_counts"].get("complete") == 1, st
    assert st["vc_counts"].get("fail") == 1, st
    assert st["updated_at"] >= before, st


def case_tag_add_search(root: Path) -> None:
    plan = new_plan(root)
    add_vc(plan, "VC-1", "grep -q x file")
    ok(run_plan(plan, "tag-add", "--section", "vcs", "--id", "VC-1", "--tag", "gate"), "tag-add")
    found = out_json(ok(run_plan(plan, "tag-search", "--tag", "gate"), "tag-search"))
    assert "selftest#vcs/VC-1" in found["refs"], found
    entry = out_json(ok(run_plan(plan, "get", "--section", "vcs", "--id", "VC-1"), "get VC"))
    assert "gate" in entry["tags"], entry


def case_render(root: Path) -> None:
    plan = new_plan(root)
    ok(run_plan(plan, "add", "--section", "requirements",
                "--json", '{"id":"R1","text":"demo","type":"目标","vc":["VC-1"]}'), "add R")
    add_vc(plan, "VC-1", "test -f x")
    ok(run_plan(plan, "add", "--section", "phases", "--json", '{"id":"P1"}'), "add P")
    ok(run_plan(plan, "add", "--section", "findings",
                "--json", '{"id":"F1","text":"note","source":"x.md:1"}'), "add F")
    ok(run_plan(plan, "render"), "render")
    for name in ("task_plan.md", "progress.md", "verification.md", "findings.md"):
        p = plan / name
        assert p.is_file(), f"缺视图 {p}"
        text = p.read_text(encoding="utf-8")
        assert "本文件由 planctl.py 从 plan-state.json 生成" in text, f"{name} 缺生成声明"
        assert "selftest" in text and "updated_at" in text, f"{name} 缺 task_id/时间戳"


def case_backup_restore(root: Path) -> None:
    plan = new_plan(root)
    ok(run_plan(plan, "add", "--section", "requirements",
                "--json", '{"id":"R1","text":"golden","type":"手段","vc":[]}'), "add R")
    ok(run_plan(plan, "backup"), "backup")
    hist = out_json(ok(run_plan(plan, "history"), "history"))
    assert hist["count"] >= 1 and hist["versions"][0]["index"] == 1, hist
    (plan / "plan-state.json").write_text("{ broken", encoding="utf-8")  # 模拟外部改坏
    ok(run_plan(plan, "restore"), "restore")
    doc = out_json(ok(run_plan(plan, "get"), "get after restore"))
    assert doc["task_id"] == "selftest", doc
    assert doc["requirements"][0]["text"] == "golden", doc
    assert ok(run_plan(plan, "validate"), "validate").returncode == 0


def case_validate_reject(root: Path) -> None:
    plan = new_plan(root)
    state = plan / "plan-state.json"
    state.write_text('{"schema_version": 2}', encoding="utf-8")
    cp = bad(run_plan(plan, "validate"), "validate bad version")
    assert "VALIDATE FAIL" in cp.stderr, cp.stderr
    # 再构造一份「顶层合法但条目非法」的结构，验证深层校验（不是只查 schema_version）
    doc = {"schema_version": 1, "task_id": "x", "plan_tier": "standard", "execution_lane": "L1",
           "created_at": "", "updated_at": "", "requirements": [{"id": 123}],
           "goals": [], "vcs": [], "phases": [], "findings": [], "audits": [],
           "delegations": [], "tags": []}
    state.write_text(json.dumps(doc), encoding="utf-8")
    cp = bad(run_plan(plan, "validate"), "validate bad entry")
    assert "schema_version" not in cp.stderr or "requirements" in cp.stderr, cp.stderr


def case_atomic_no_half_file(root: Path) -> None:
    plan = new_plan(root)
    for i in range(5):
        add_vc(plan, f"VC-{i}", "grep -q x file")
        leftovers = list(plan.glob(".plan-state-*.tmp")) + list((plan / ".history").glob("*.tmp"))
        assert not leftovers, f"第 {i} 次写后残留临时文件: {leftovers}"
        out_json(ok(run_plan(plan, "get"), "get"))  # 权威源必须始终可解析
    for bak in (plan / ".history").glob("plan-state-*.json"):
        json.loads(bak.read_text(encoding="utf-8"))  # 备份也必须完整


def case_check_vc_nonvacuous(root: Path) -> None:
    plan = new_plan(root)
    add_vc(plan, "VC-1", "true")
    cp = bad(run_plan(plan, "check", "vc-nonvacuous"), "vacuous true")
    assert "VC-1" in assert_check_line(cp, "vc-nonvacuous", "FAIL"), cp.stdout
    ok(run_plan(plan, "set", "--section", "vcs", "--id", "VC-1",
                "--field", "command", "--value", "echo x | grep -q x file"), "set real cmd")
    assert_check_line(ok(run_plan(plan, "check", "vc-nonvacuous"), "pipe has power"),
                      "vc-nonvacuous", "PASS")
    add_vc(plan, "VC-2", "cat /dev/null")
    cp = bad(run_plan(plan, "check", "vc-nonvacuous"), "vacuous cat")
    assert "VC-2" in assert_check_line(cp, "vc-nonvacuous", "FAIL"), cp.stdout
    ok(run_plan(plan, "set", "--section", "vcs", "--id", "VC-2",
                "--field", "command", "--value", "test -f file"), "set test cmd")
    assert_check_line(ok(run_plan(plan, "check", "vc-nonvacuous"), "all real"),
                      "vc-nonvacuous", "PASS")


def case_check_rvc(root: Path) -> None:
    plan = new_plan(root)
    ok(run_plan(plan, "add", "--section", "requirements",
                "--json", '{"id":"R1","text":"r","type":"目标","vc":["VC-1"]}'), "add R1")
    cp = bad(run_plan(plan, "check", "rvc"), "dangling VC")
    assert "VC-1" in assert_check_line(cp, "rvc", "FAIL"), cp.stdout
    add_vc(plan, "VC-1", "test -f f")
    assert_check_line(ok(run_plan(plan, "check", "rvc"), "covered"), "rvc", "PASS")
    ok(run_plan(plan, "add", "--section", "requirements",
                "--json", '{"id":"R2","text":"r2","type":"手段","vc":[]}'), "add R2 no VC")
    cp = bad(run_plan(plan, "check", "rvc"), "R2 uncovered")
    assert "R2" in assert_check_line(cp, "rvc", "FAIL"), cp.stdout
    ok(run_plan(plan, "set", "--section", "requirements", "--id", "R2",
                "--field", "vc", "--value", '["VC-1"]'), "set R2 vc")
    assert_check_line(ok(run_plan(plan, "check", "rvc"), "recovered"), "rvc", "PASS")


def case_check_audit(root: Path) -> None:
    plan = new_plan(root)
    cp = bad(run_plan(plan, "check", "audit"), "no audit")
    assert "audit" in assert_check_line(cp, "audit", "FAIL"), cp.stdout
    ok(run_plan(plan, "audit-add", "--round", "1", "--verdict", "REJECTED", "--by", "c"), "audit REJECTED")
    cp = bad(run_plan(plan, "check", "audit"), "rejected audit")
    assert "REJECTED" in assert_check_line(cp, "audit", "FAIL"), cp.stdout
    ok(run_plan(plan, "audit-add", "--round", "2", "--verdict", "APPROVED",
                "--by", "c", "--c", "1"), "audit APPROVED with C")
    cp = bad(run_plan(plan, "check", "audit"), "C>0 audit")
    assert "C=1" in assert_check_line(cp, "audit", "FAIL"), cp.stdout
    ok(run_plan(plan, "audit-add", "--round", "3", "--verdict", "APPROVED",
                "--by", "c", "--w", "3"), "audit clean")
    assert_check_line(ok(run_plan(plan, "check", "audit"), "clean audit"), "audit", "PASS")
    bad(run_plan(plan, "audit-add", "--round", "3", "--verdict", "APPROVED", "--by", "c"), "dup round")


def case_check_evidence(root: Path) -> None:
    plan = new_plan(root)
    add_vc(plan, "VC-1", "test -f f")
    assert_check_line(ok(run_plan(plan, "check", "evidence"), "empty evidence SKIP"),
                      "evidence", "PASS")
    good = root / "ev-good.md"
    good.write_text("Evidence VC-1\n2026-11-21T09:00:00Z\n", encoding="utf-8")
    ok(run_plan(plan, "set", "--section", "vcs", "--id", "VC-1",
                "--field", "evidence", "--value", str(good)), "set evidence good")
    assert_check_line(ok(run_plan(plan, "check", "evidence"), "evidence pass"), "evidence", "PASS")
    no_stamp = root / "ev-nostamp.md"
    no_stamp.write_text("Evidence VC-1 但没有时间戳", encoding="utf-8")
    ok(run_plan(plan, "set", "--section", "vcs", "--id", "VC-1",
                "--field", "evidence", "--value", str(no_stamp)), "set evidence bad")
    cp = bad(run_plan(plan, "check", "evidence"), "evidence no ISO")
    assert "ISO8601" in assert_check_line(cp, "evidence", "FAIL"), cp.stdout
    ok(run_plan(plan, "set", "--section", "vcs", "--id", "VC-1",
                "--field", "evidence", "--value", str(root / "missing.md")), "set evidence missing")
    cp = bad(run_plan(plan, "check", "evidence"), "evidence missing file")
    assert "不存在" in assert_check_line(cp, "evidence", "FAIL"), cp.stdout


def case_history_versioned(root: Path) -> None:
    plan = new_plan(root)
    ok(run_plan(plan, "add", "--section", "requirements",
                "--json", '{"id":"R1","text":"v1","type":"手段","vc":[]}'), "add R1")
    ok(run_plan(plan, "add", "--section", "requirements",
                "--json", '{"id":"R2","text":"v2","type":"手段","vc":[]}'), "add R2")
    hist = out_json(ok(run_plan(plan, "history"), "history"))
    assert hist["count"] >= 2, hist
    # 初始历史：index1=含 R1 的快照（add R2 前），index2=init 空快照。
    # 注意 restore 自身也会备份恢复前状态，故先测 --version 2 再测默认 restore，
    # 避免历史序号在两次恢复之间漂移导致断言不确定。
    ok(run_plan(plan, "restore", "--version", "2"), "restore v2")
    ids = [r["id"] for r in out_json(ok(run_plan(plan, "get", "--section", "requirements"), "get"))]
    assert ids == [], ids
    ok(run_plan(plan, "restore"), "restore default latest")
    ids = [r["id"] for r in out_json(ok(run_plan(plan, "get", "--section", "requirements"), "get"))]
    assert ids == ["R1", "R2"], ids


def case_check_input_anomaly(root: Path) -> None:
    plan = root / "no-such-plan"
    cp = run_plan(plan, "check", "rvc")
    assert cp.returncode == 2, f"rc 应为 2: {cp.returncode} {cp.stdout} {cp.stderr}"
    assert_check_line(cp, "rvc", "FAIL")


def case_audit_add_issues_json(root: Path) -> None:
    """[2026-11-21] audit-add --issues-json 正向落库 + 非法 key/枚举/缺字段拒绝 + 旧行为兼容。"""
    plan = new_plan(root)
    good = ('[{"key":"I-5","severity":"I","state":"open","title":"残留"},'
            '{"key":"W-1","severity":"W","state":"new"}]')
    ok(add_audit(plan, 1, "REJECTED", good), "issues ok")
    entry = out_json(ok(run_plan(plan, "get", "--section", "audits", "--id", "R1"), "get audit"))
    assert [x["key"] for x in entry["issues"]] == ["I-5", "W-1"], entry
    assert entry["issues"][0]["title"] == "残留" and "title" not in entry["issues"][1], entry
    # schema 拒绝：key 格式 / severity 枚举 / state 枚举 / 缺必填 / 非数组
    for label, payload in (
        ("bad key", '[{"key":"bad","severity":"I","state":"open"}]'),
        ("bad severity", '[{"key":"I-6","severity":"X","state":"open"}]'),
        ("bad state", '[{"key":"I-6","severity":"I","state":"bogus"}]'),
        ("missing state", '[{"key":"I-6","severity":"I"}]'),
        ("not array", '{"key":"I-6","severity":"I","state":"open"}'),
    ):
        cp = bad(add_audit(plan, 2, "REJECTED", payload), label)
        assert "--issues-json" in cp.stderr, cp.stderr
    audits = out_json(ok(run_plan(plan, "get", "--section", "audits"), "audits after rejects"))
    assert len(audits) == 1, audits  # 非法写入不得污染权威源
    # 旧行为：不传 --issues-json 的条目无 issues 字段，仍合法
    ok(add_audit(plan, 3, "REJECTED"), "legacy no issues")
    legacy = out_json(ok(run_plan(plan, "get", "--section", "audits", "--id", "R3"), "get legacy"))
    assert "issues" not in legacy, legacy
    assert ok(run_plan(plan, "validate"), "validate with issues").stdout.strip() == "VALIDATE PASS"


def case_check_audit_no_progress_streak(root: Path) -> None:
    """[2026-11-21] 连续 3 轮 REJECTED 同开放 C/I key → FAIL NO_PROGRESS_STREAK_3；2 轮不触发。"""
    plan = new_plan(root / "streak")
    i5 = '[{"key":"I-5","severity":"I","state":"open","title":"残留"}]'
    for rnd in (1, 2):
        ok(add_audit(plan, rnd, "REJECTED", i5), f"reject R{rnd}")
    line = assert_check_line(bad(run_plan(plan, "check", "audit"), "2 rounds"), "audit", "FAIL")
    assert "NO_PROGRESS_STREAK_3" not in line, line
    assert out_json(ok(run_plan(plan, "status"), "status"))["no_progress_streak"] is False
    ok(add_audit(plan, 3, "REJECTED", i5), "reject R3")
    line = assert_check_line(bad(run_plan(plan, "check", "audit"), "3 rounds"), "audit", "FAIL")
    assert "NO_PROGRESS_STREAK_3" in line, line
    assert "ESCALATE_USER_DECISION_REQUIRED" in line, line
    assert "R1={I-5}" in line and "R3={I-5}" in line, line
    assert out_json(ok(run_plan(plan, "status"), "status"))["no_progress_streak"] is True


def case_check_audit_no_progress_guard(root: Path) -> None:
    """[2026-11-21] 不误伤守卫：W/N 重复不触发；末轮 APPROVED 清零后无条件 PASS。"""
    plan = new_plan(root / "wn")
    wn = '[{"key":"W-1","severity":"W","state":"open"},{"key":"N-1","severity":"N","state":"new"}]'
    for rnd in (1, 2, 3):
        ok(add_audit(plan, rnd, "REJECTED", wn), f"W/N reject R{rnd}")
    line = assert_check_line(bad(run_plan(plan, "check", "audit"), "W/N only"), "audit", "FAIL")
    assert "NO_PROGRESS_STREAK_3" not in line, line
    assert out_json(ok(run_plan(plan, "status"), "status"))["no_progress_streak"] is False

    # 真实样本 StoryLab task-ep36：R1/R2 I-5 open（2 轮，不触发），R3 清零 APPROVED → PASS。
    sample = new_plan(root / "sample")
    i5 = '[{"key":"I-5","severity":"I","state":"open"}]'
    for rnd in (1, 2):
        ok(add_audit(sample, rnd, "REJECTED", i5), f"sample reject R{rnd}")
    line = assert_check_line(bad(run_plan(sample, "check", "audit"), "sample R2"), "audit", "FAIL")
    assert "NO_PROGRESS_STREAK_3" not in line, line
    ok(add_audit(sample, 3, "APPROVED", "[]"), "sample R3 converged")
    assert_check_line(ok(run_plan(sample, "check", "audit"), "sample APPROVED"), "audit", "PASS")
    assert out_json(ok(run_plan(sample, "status"), "status"))["no_progress_streak"] is False

    # 4 段含 3 个连续 REJECTED：R3 时命中止损，R4 APPROVED 后无条件 PASS。
    streak = new_plan(root / "streak-converged")
    for rnd in (1, 2, 3):
        ok(add_audit(streak, rnd, "REJECTED", i5), f"streak reject R{rnd}")
    line = assert_check_line(bad(run_plan(streak, "check", "audit"), "streak R3"), "audit", "FAIL")
    assert "NO_PROGRESS_STREAK_3" in line, line
    ok(add_audit(streak, 4, "APPROVED", "[]"), "streak R4 converged")
    assert_check_line(ok(run_plan(streak, "check", "audit"), "streak PASS"), "audit", "PASS")


CASES: tuple[tuple[str, Callable[[Path], None]], ...] = (
    ("init_get_roundtrip", case_init_get),
    ("crud_set_add_update_delete", case_crud),
    ("phase_done_vc_pass_fail", case_status_transitions),
    ("tag_add_tag_search", case_tag_add_search),
    ("render_four_views", case_render),
    ("backup_corrupt_restore", case_backup_restore),
    ("validate_reject_invalid_json", case_validate_reject),
    ("atomic_write_no_half_file", case_atomic_no_half_file),
    ("check_vc_nonvacuous_pos_neg", case_check_vc_nonvacuous),
    ("check_rvc_pos_neg", case_check_rvc),
    ("check_audit_pos_neg", case_check_audit),
    ("audit_add_issues_json_and_schema_reject", case_audit_add_issues_json),
    ("check_audit_no_progress_streak_3", case_check_audit_no_progress_streak),
    ("check_audit_no_progress_guard", case_check_audit_no_progress_guard),
    ("check_evidence_pos_neg", case_check_evidence),
    ("history_versioned_restore", case_history_versioned),
    ("check_input_anomaly_rc2", case_check_input_anomaly),
)


def main() -> int:
    """顺序跑全部用例，逐例打印 TEST 行，末尾汇总；全绿才 exit 0。"""
    SCRATCH_ROOT.mkdir(parents=True, exist_ok=True)
    passed = failed = 0
    for name, fn in CASES:
        try:
            with tempfile.TemporaryDirectory(prefix="case-", dir=str(SCRATCH_ROOT)) as td:
                fn(Path(td))
        except Exception as exc:  # 单例失败不阻断后续用例，汇总时如实计数
            failed += 1
            print(f"TEST {name}: FAIL {type(exc).__name__}: {exc}")
        else:
            passed += 1
            print(f"TEST {name}: PASS")
    total = len(CASES)
    print(f"TOTAL {total} PASS {passed} FAIL {failed}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
