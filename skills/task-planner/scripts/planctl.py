#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""planctl.py — task-planner 结构化状态（plan-state.json）的唯一写入者与只读视图生成器。

WHAT（2026-11-21 task-json-state-20261121 P1/P2/P5）：
  子命令分四族：① 原子 CRUD（init/get/set/add/update/delete/status/validate）；
  ② 状态流转（phase-done/vc-pass/vc-fail/audit-add）；③ 倒排标签（tag-add/tag-search）；
  ④ 可恢复与机器门（backup/restore/history/render/check）。
WHY（用户裁决）：旧 SOP 用 grep/awk 正则从半结构化 Markdown 抽 VC/审计/任务状态，格式一变就
  假绿、误伤、漏匹配，critic 反复打回。改为「JSON 权威源 + 固定脚本 CRUD + MD 派生视图」，
  Agent 不再直接编辑状态文件；机器门消费稳定 JSON 而非正则匹配文本。

写入安全契约（强制）：任何写操作 = 校验新文档 → 旧版 copy 到 <plan-dir>/.history/（保留最近
  20 版）→ 同目录临时文件 + fsync + os.replace 原子替换 → 回读再校验 → 失败用备份回滚。
输出契约：get/status/tag-search/其余管理命令输出 JSON 到 stdout；check 输出单行
  `PLANCTL CHECK <name>: PASS|FAIL <reason>`（rc 0=PASS / 1=FAIL / 2=输入异常）；
  所有错误信息到 stderr。依赖：Python 3 标准库；jsonschema 若可用则叠加校验，缺失不影响功能。
"""

from __future__ import annotations

import argparse
import copy
import datetime as dt
import json
import os
import re
import sys
import tempfile
from pathlib import Path
from typing import Any, Callable

# jsonschema 为可选增强：不强行依赖；手写 validator 始终是权威判定面（环境缺包时行为一致）。
try:  # pragma: no cover - 取决于运行环境
    import jsonschema as _jsonschema  # type: ignore
except ImportError:  # pragma: no cover
    _jsonschema = None

SCRIPT_DIR = Path(__file__).resolve().parent
SKILL_DIR = SCRIPT_DIR.parent
SCHEMA_PATH = SKILL_DIR / "schemas" / "plan-state.schema.json"
TEMPLATE_PATH = SKILL_DIR / "templates" / "plan-state.json"

STATE_NAME = "plan-state.json"
HISTORY_DIR = ".history"
TAGS_INDEX_NAME = ".tags-index.json"  # 位于 <plan-dir>/../ ，跨计划共享倒排索引
HISTORY_LIMIT = 20
GENERATED_HEADER = "<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->"
VIEW_NAMES = ("task_plan.md", "progress.md", "verification.md", "findings.md")

ARRAY_SECTIONS = (
    "requirements", "goals", "vcs", "phases", "findings", "audits", "delegations",
    # [2026-11-22 task-jsonderive-deploy-20261122] What: 追加 29 个语义段数组 section。
    # Why: 原行为只覆盖 7 段，MD 语义段（Actions/Error Log/S-unit/Phase Gates 等）只能直接 Edit MD；
    #       纳入后 add/get/update/delete/tag-add 的 --section choices 由元组自动生效，不新增子命令。
    "actions", "files", "test_results", "errors", "reboot5q", "knowledge_use",
    "research", "decisions", "issues", "resources", "visual",
    "root_causes", "invariants", "spec_baseline", "progress_baseline", "scope_limits",
    "changes", "knowledge", "research_status", "evidence_faces", "tool_use", "s_units",
    "anti_regress", "fmea", "todo_sync", "key_questions",
    "phase_gates", "knowledge_compliance", "cross_checks",
)

# [2026-11-22 task-jsonderive-deploy-20261122] What: 把原 TOP_LEVEL_KEYS 的双重语义拆开。
# Why: 原行为中 TOP_LEVEL_KEYS 既当 required 又当 allowed；新字段全部可选，若直接并入会让
#       存量 plan-state.json（StoryLab 空壳）validate FAIL，故 required 保持原 14 键不变。
REQUIRED_TOP_LEVEL_KEYS = (
    "schema_version", "task_id", "plan_tier", "execution_lane", "created_at", "updated_at",
    "requirements", "goals", "vcs", "phases", "findings", "audits", "delegations", "tags",
)
OPTIONAL_TOP_LEVEL_KEYS = (
    # 新增数组段（与 ARRAY_SECTIONS 尾部一致，供顶层 allowed/写入校验使用）
    "actions", "files", "test_results", "errors", "reboot5q", "knowledge_use",
    "research", "decisions", "issues", "resources", "visual",
    "root_causes", "invariants", "spec_baseline", "progress_baseline", "scope_limits",
    "changes", "knowledge", "research_status", "evidence_faces", "tool_use", "s_units",
    "anti_regress", "fmea", "todo_sync", "key_questions",
    "phase_gates", "knowledge_compliance", "cross_checks",
    # 新增对象/标量段（progress / findings / task_plan / verification 的非数组语义）
    "resume_report", "understanding", "config", "dual_qc", "goal_verdict", "core_question",
    "isolation", "batch", "delegation_stats", "chain", "quality_gates", "outcome",
    "template_type", "template_body", "next_step",
)
TOP_LEVEL_KEYS = REQUIRED_TOP_LEVEL_KEYS + OPTIONAL_TOP_LEVEL_KEYS

# 新增条目时补齐的合法默认面（Why：避免 Agent 手写半条目导致 schema 校验失败；
# 身份字段 id/round 仍强制，缺失即报错，不静默造 id）。
ENTRY_DEFAULTS: dict[str, dict[str, Any]] = {
    "requirements": {"text": "", "type": "手段", "vc": [], "tags": []},
    "goals": {"text": "", "tags": [],
              # [2026-11-22 task-jsonderive-deploy-20261122] What: goal 证据默认空串; Why: 有值时 render 输出 [goal:G<n>] 证据行（evidence-anchor 门消费面）。
              "evidence": ""},
    "vcs": {"criterion": "", "command": "", "status": "pending", "evidence": "", "tags": []},
    "phases": {"status": "pending", "s_units": [], "v_checks": [], "tags": [],
               # [2026-11-22 task-jsonderive-deploy-20261122] What: Phase 显示名/起始时间默认空; Why: Started 供 3file-gate mtime 锚点，name 供 `### Phase <id>: <name>` 标题。
               "name": "", "started": ""},
    "findings": {"text": "", "source": "", "tags": []},
    "audits": {"verdict": "REJECTED", "by": "", "counts": {"C": 0, "I": 0, "W": 0}, "at": "", "tags": []},
    "delegations": {"agent": "", "scope": "", "status": "pending", "tags": []},
    # [2026-11-22 task-jsonderive-deploy-20261122] 新 section 默认面：覆盖 schema required 字段
    # （除 id），Why: 通用 `add --section X --json '{"id":"..."}'` 也能一次落库成功，
    # 原行为缺字段即被 validate 拒绝；自由文本留空串，数组留空表，计数留 0。
    "actions": {"phase": "", "text": "", "at": ""},
    "files": {"phase": "", "path": "", "change": ""},
    "test_results": {"phase": "", "test": "", "input": "", "expected": "", "actual": "", "status": "pending"},
    "errors": {"timestamp": "", "error": "", "attempt": 0, "resolution": "",
               "root_cause": "", "prevention": "", "trigger": ""},
    "reboot5q": {"question": "", "answer": ""},
    "knowledge_use": {"phase": "", "source": "", "purpose": ""},
    "research": {"claim": "", "source": ""},
    "decisions": {"decision": "", "rationale": ""},
    "issues": {"issue": "", "resolution": ""},
    "resources": {"locator": ""},
    "visual": {"finding": "", "source": ""},
    "root_causes": {"process": "", "defect": "", "fix": "", "vc": ""},
    "invariants": {"state": "", "item": "", "anchor": ""},
    "spec_baseline": {"verbatim": "", "anchor": "", "rule": "", "sha": ""},
    "progress_baseline": {"item": "", "snapshot": "", "metric": "", "ban": "", "status": ""},
    "scope_limits": {"category": "", "allow": [], "deny": []},
    "changes": {"object": "", "type": "", "absorb": "", "quote": "", "basis": "", "action": ""},
    "knowledge": {"category": "", "name": "", "loc": "", "level": "", "confirmed": "",
                  # [2026-11-22 task-jsonderive-deploy-20261122] What: 知识消费态/落点默认空; Why: findings.md 知识对齐表 4 列需从 JSON 派生（consumed/landing）。
                  "consumed": "", "landing": ""},
    "research_status": {"unit": "", "state": "", "keywords": "", "channels": "", "output": "", "net": ""},
    "evidence_faces": {"face": "", "target": "", "method": "", "anchor": "", "status": ""},
    "tool_use": {"phase": "", "tools": "", "why": ""},
    # [2026-11-24 task-sp-driven-invocation H5] What: s_units 默认键增 escort_skills（字符串数组）。
    # Why: 伴飞技能 .md 路径原本无专用编码载体，parallel 占「伴飞技能」列致 Rule 59.2 路径无法入库；
    #      类型与 s_units 其他数组字段一致（审计 N-I-3/NIT，非单一字符串）。
    "s_units": {"phase": "", "name": "", "executor": "", "files": "", "actions": "",
                "verify": "", "duration": "", "granularity": "", "parallel": "",
                "escort_skills": []},
    "anti_regress": {"item": "", "method": "", "anchor": "", "result": ""},
    "fmea": {"phase": "", "mode": "", "severity": 0, "occurrence": 0,
             "detection": 0, "rpn": 0, "fallback": ""},
    "todo_sync": {"trigger": "", "action": ""},
    "key_questions": {"question": "", "answer": ""},
    "phase_gates": {"goal": "", "depends": [], "done_when": "", "checks": [], "status": ""},
    "knowledge_compliance": {"item": "", "status": ""},
    "cross_checks": {"item": "", "method": "", "result": ""},
}

# [2026-11-22 task-jsonderive-deploy-20261122] 顶层对象字段规格：field → (required 集, 字段谓词, 是否允许额外键)。
# What: 为 set --field 写入的对象段提供与 schema 等价的手写校验；Why: jsonschema 缺失时行为仍需一致，
#       且 config 是自由扩展对象（原行为无该字段），显式放行额外键避免误拒未来配置项。
STR_FIELD = lambda v: isinstance(v, str)
INT_FIELD = lambda v: isinstance(v, int) and not isinstance(v, bool)
STR_LIST_FIELD = lambda v: isinstance(v, list) and all(isinstance(x, str) for x in v)
OBJECT_FIELD_SPECS: dict[str, tuple[set[str], dict[str, Callable[[Any], bool]], bool]] = {
    "resume_report": ({"path"}, {"path": STR_FIELD, "last": STR_FIELD}, False),
    "understanding": (set(), {k: STR_FIELD for k in ("original", "model", "options", "direction")}, False),
    "config": (set(), {"code_review": STR_FIELD, "session_id": STR_FIELD,
                       "worktree_path": STR_FIELD, "scope_files": STR_LIST_FIELD}, True),
    "dual_qc": (set(), {k: STR_FIELD for k in ("scope", "exempt", "multi_file")}, False),
    "goal_verdict": ({"goal", "verdict"},
                     {k: STR_FIELD for k in ("goal", "verdict", "evidence", "unresolved", "excluded", "next")}, False),
    "core_question": ({"text"}, {k: STR_FIELD for k in ("text", "checks", "verdict")}, False),
    "isolation": (set(), {k: STR_FIELD for k in ("conflict", "path", "branch", "merge_back")}, False),
    "batch": (set(), {"total": INT_FIELD, "success": INT_FIELD, "failed": INT_FIELD, "rate": STR_FIELD,
                      "sampled_pass": INT_FIELD, "sampled_fail": INT_FIELD,
                      "pre_check": STR_FIELD, "rollback": STR_FIELD}, True),
    "delegation_stats": (set(), {k: INT_FIELD for k in ("total", "subagent", "parallel_width", "verified")}, True),
    "chain": (set(), {k: STR_FIELD for k in ("mode", "blocks", "handoffs")}, False),
    "quality_gates": (set(), {"delegation_reverify": STR_FIELD, "quality_control": STR_FIELD}, False),
    "outcome": ({"result"}, {"result": STR_FIELD, "blocked_reason": STR_FIELD}, False),
}


class PlanctlError(Exception):
    """planctl 业务异常：统一由 main() 转 stderr + rc 1，禁止静默吞错。"""


# ── 审计问题 issue 与无进展判定（2026-11-21 task-audit-rework-cap-20261121）──────
# What: issue.key 是跨轮无进展判定的唯一机器信号；开放 C/I = severity∈{C,I} 且 state∈{open,new}。
# Why: 旧机器门只校验末段 APPROVED 形态，R1→R9 可反复以「I-5 残留」重现而一路 PASS；
#       文本口径「连续≥3轮无进展→呈报用户」无机器判定。本组函数把该口径落为可测的 check 判定。
ISSUE_KEY_RE = re.compile(r"^(C|I|W|N|Q)-[A-Za-z0-9_\u4e00-\u9fff-]{1,48}$")
ISSUE_SEVERITIES = frozenset(("C", "I", "W", "N", "Q"))
ISSUE_STATES = frozenset(("open", "fixed", "accepted", "new", "deferred"))
OPEN_CI_SEVERITIES = frozenset(("C", "I"))
OPEN_CI_STATES = frozenset(("open", "new"))


def _valid_issue(value: Any) -> bool:
    """校验单个 issue 条目；字段集与 schema definitions.audit_issue 一一对应。"""
    if not isinstance(value, dict):
        return False
    if not set(value).issubset({"key", "severity", "state", "title"}):
        return False
    if not {"key", "severity", "state"}.issubset(value):
        return False
    key = value.get("key")
    return (isinstance(key, str) and bool(ISSUE_KEY_RE.match(key))
            and value.get("severity") in ISSUE_SEVERITIES
            and value.get("state") in ISSUE_STATES
            and ("title" not in value or isinstance(value["title"], str)))


def parse_issues_json(raw: str | None) -> list[dict[str, Any]] | None:
    """解析 audit-add --issues-json；未提供时返回 None（旧行为不变），非法输入显式报错。"""
    if raw is None or not raw.strip():
        return None
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise PlanctlError(f"--issues-json 非法 JSON: {exc}") from exc
    if not isinstance(parsed, list):
        raise PlanctlError("--issues-json 必须是 JSON 数组")
    bad = [x for x in parsed if not _valid_issue(x)]
    if bad:
        raise PlanctlError("--issues-json 条目非法（key 须 C|I|W|N|Q-<1..48 字符>，"
                           f"severity/state 须属枚举，必填 key/severity/state）: {bad[:3]!r}")
    return parsed


def open_ci_keys(audit: dict[str, Any]) -> set[str]:
    """返回该审计轮尚未关闭的 C/I issue key 集合；无 issues 字段=无信号（空集）。"""
    issues = audit.get("issues")
    if not isinstance(issues, list):
        return set()
    return {str(x["key"]) for x in issues
            if isinstance(x, dict) and x.get("severity") in OPEN_CI_SEVERITIES
            and x.get("state") in OPEN_CI_STATES and isinstance(x.get("key"), str)}


def audit_no_progress(audits: list[dict[str, Any]]) -> tuple[bool, str]:
    """判定最近 3 个连续 REJECTED 轮是否开放 C/I key 集完全相同（零清零、零新增）。

    返回 (是否命中, 各轮 key 集合详情)。末轮 APPROVED 视为已收敛，直接不命中——
    防真实样本 R2→R3「I-5 清零后 APPROVED」被误伤。无 issues 字段的轮跳过（无信号）。
    """
    if not audits:
        return False, ""
    last = max(audits, key=lambda a: a.get("round", 0))
    if last.get("verdict") == "APPROVED":
        return False, "末轮 APPROVED 已收敛，跳过无进展判定"
    rejected = sorted((a for a in audits if a.get("verdict") == "REJECTED"),
                      key=lambda a: a.get("round", 0))
    signaled = [(a.get("round"), open_ci_keys(a)) for a in rejected if "issues" in a]
    details = ", ".join(f"R{r}={{{', '.join(sorted(k)) or '∅'}}}" for r, k in signaled[-3:])
    if len(signaled) < 3:
        return False, details
    tail = signaled[-3:]
    rounds = [r for r, _ in tail]
    consecutive = all(rounds[j + 1] - rounds[j] == 1 for j in (0, 1))
    sets = [k for _, k in tail]
    # 判定口径=「key 集完全相同」而非「末轮 ⊆ 前轮」：后者会把真实清零误判为无进展。
    if consecutive and sets[0] and sets[0] == sets[1] == sets[2]:
        return True, details
    return False, details


# ─────────────────────────────────────────────────────────────────────────────
# 时间与 JSON I/O
# ─────────────────────────────────────────────────────────────────────────────

def now_iso() -> str:
    """返回 UTC 的 ISO8601 时间戳（秒精度，Z 后缀），作为 updated_at/at 的权威时钟。"""
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def state_path(plan_dir: Path) -> Path:
    """返回该 plan-dir 下权威源文件的绝对路径。"""
    return plan_dir.resolve() / STATE_NAME


def check_plan_dir(plan_dir: str | Path) -> Path:
    """校验 plan-dir 必须是已存在目录，否则报错（避免默默创建到错误位置）。"""
    p = Path(plan_dir).resolve()
    if not p.is_dir():
        raise PlanctlError(f"plan-dir 缺失或非目录: {p}")
    return p


def read_state(plan_dir: Path) -> dict[str, Any]:
    """读取并 JSON 解析权威源；文件缺失/非法 JSON/顶层非 object 均显式报错。"""
    p = state_path(plan_dir)
    if not p.exists():
        raise PlanctlError(f"plan-state.json 不存在: {p}（先运行 planctl init）")
    try:
        doc = json.loads(p.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise PlanctlError(f"plan-state.json 非法 JSON: {p}:{exc.lineno}:{exc.colno} {exc.msg}") from exc
    if not isinstance(doc, dict):
        raise PlanctlError(f"plan-state.json 顶层必须是 object: {p}")
    return doc


def json_bytes(obj: Any) -> bytes:
    """稳定序列化：保留中文、缩进 2、末尾换行，供人直接 diff 也可读。"""
    return (json.dumps(obj, ensure_ascii=False, indent=2) + "\n").encode("utf-8")


def atomic_write(path: Path, data: bytes | str) -> Path:
    """同目录临时文件 → 写满并 fsync → os.replace 原子替换；异常清理临时文件后重抛。

    WHY：禁止直接 open(path,'w')——进程中断会留下半文件，下游 validate 读到的既非旧版也非新版。
    """
    if isinstance(data, str):
        data = data.encode("utf-8")
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(prefix=f".{path.name}-", suffix=".tmp", dir=str(path.parent))
    tmp = Path(tmp_name)
    try:
        with os.fdopen(fd, "wb") as fh:
            fh.write(data)
            fh.flush()
            os.fsync(fh.fileno())
        os.replace(str(tmp), str(path))
    except BaseException:
        try:
            tmp.unlink()
        except OSError:
            pass
        raise
    return path


# ─────────────────────────────────────────────────────────────────────────────
# 备份 / 恢复 / 历史
# ─────────────────────────────────────────────────────────────────────────────

def list_backups(plan_dir: Path) -> list[Path]:
    """按文件名（时间戳+序号，字典序即时间序）返回全部历史备份， newest first。"""
    hist = plan_dir / HISTORY_DIR
    if not hist.is_dir():
        return []
    pattern = re.compile(r"^plan-state-\d{8}T\d{6}-\d+\.json$")
    files = [p for p in hist.glob("plan-state-*.json") if pattern.match(p.name)]
    return sorted(files, reverse=True)


def prune_history(plan_dir: Path) -> None:
    """仅保留最近 HISTORY_LIMIT 版；超出的按时间序删最旧（不改用户其它文件）。"""
    for old in list_backups(plan_dir)[HISTORY_LIMIT:]:
        old.unlink()


def backup_state(plan_dir: Path) -> Path | None:
    """把当前权威源复制为 .history/plan-state-<YYYYmmddTHHMMSS>-<seq>.json；无源则 None。"""
    src = state_path(plan_dir)
    if not src.exists():
        return None
    hist = plan_dir / HISTORY_DIR
    hist.mkdir(parents=True, exist_ok=True)
    stamp = dt.datetime.now().strftime("%Y%m%dT%H%M%S")
    seq = 1
    while True:
        dest = hist / f"plan-state-{stamp}-{seq:02d}.json"
        if not dest.exists():
            break
        seq += 1
    atomic_write(dest, src.read_bytes())  # 备份本身也走原子写，防止备份半文件
    prune_history(plan_dir)
    return dest


def commit_state(plan_dir: Path, doc: dict[str, Any], *, backup: bool = True,
                 touch: bool = True) -> Path:
    """写前校验 → 备份 → 原子写 → 回读校验；任何失败都用备份回滚旧版。

    WHY：这是所有写命令的唯一出口。校验失败必须在触碰磁盘前发生；回读校验兜住序列化/编码层
    的意外（如不可序列化对象），失败时旧版必须原样保留，绝不留半文件。
    """
    new_doc = copy.deepcopy(doc)
    if touch:
        new_doc["updated_at"] = now_iso()
    errors = validate_state(new_doc)
    if errors:
        raise PlanctlError("写前 schema 校验失败，拒绝写入: " + " | ".join(errors[:6]))

    src = state_path(plan_dir)
    bak = backup_state(plan_dir) if backup and src.exists() else None
    try:
        atomic_write(src, json_bytes(new_doc))
        after = read_state(plan_dir)
        after_errors = validate_state(after)
        if after_errors:
            raise PlanctlError("写后 schema 校验失败: " + " | ".join(after_errors[:6]))
    except BaseException:
        if bak is not None and bak.exists():
            atomic_write(src, bak.read_bytes())  # 回滚同样原子，避免恢复过程再产生半文件
        raise
    return src


# ─────────────────────────────────────────────────────────────────────────────
# Schema 等价校验（手写权威 + 可选 jsonschema 叠加）
# ─────────────────────────────────────────────────────────────────────────────

_ISO_RE = re.compile(r"^\d{4}-\d{2}-\d{2}([T ]\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})?)?$")


def _is_iso8601(value: Any, *, allow_empty: bool = True) -> bool:
    """空串是模板未设置态（init 会填）；其余按 ISO8601 date/datetime 形态校验。"""
    if not isinstance(value, str):
        return False
    if value == "":
        return allow_empty
    return bool(_ISO_RE.match(value))


def _validate_entry(section: str, entry: Any, where: str, errs: list[str]) -> None:
    """对单个数组条目做与 plan-state.schema.json 等价的类型/枚举/必填校验。"""
    if not isinstance(entry, dict):
        errs.append(f"{where}: 必须是 object")
        return
    known: dict[str, Callable[[Any], bool]] = {
        "id": lambda v: isinstance(v, str) and v != "",
        "tags": lambda v: isinstance(v, list) and all(isinstance(t, str) for t in v),
    }
    required = {"id"}
    if section == "requirements":
        known.update({"text": lambda v: isinstance(v, str),
                      "type": lambda v: v in ("目标", "手段"),
                      "vc": lambda v: isinstance(v, list) and all(isinstance(x, str) for x in v)})
        required = {"id", "text", "type", "vc"}
    elif section == "goals":
        # [2026-11-22 task-jsonderive-deploy-20261122] What: 允许可选 evidence 字段; Why: 与 schema goal.properties 对齐，render 据此产出 [goal:G<n>] 证据行。
        # [2026-11-22 task-planctl-exec-surface-20261122] What: 追加可选 name/verify/s_units/status;
        # Why: render「🎯 Goal 单元表」（Rule 66.5 六列锚，attest 拒锁门）需要逐 goal 任务名/完整验证方式/对应 S-unit/状态。
        known.update({"text": lambda v: isinstance(v, str), "evidence": STR_FIELD,
                      "name": STR_FIELD, "verify": STR_FIELD, "status": STR_FIELD,
                      "s_units": lambda v: isinstance(v, list) and all(isinstance(x, str) for x in v)})
        required = {"id", "text"}
    elif section == "vcs":
        known.update({"criterion": lambda v: isinstance(v, str),
                      "command": lambda v: isinstance(v, str),
                      "status": lambda v: v in ("pending", "pass", "fail"),
                      "evidence": lambda v: isinstance(v, str)})
        required = {"id", "criterion", "command", "status", "evidence"}
    elif section == "phases":
        known.update({"status": lambda v: v in ("pending", "in_progress", "complete"),
                      "s_units": lambda v: isinstance(v, list) and all(isinstance(x, str) for x in v),
                      "v_checks": lambda v: isinstance(v, list) and all(isinstance(x, str) for x in v),
                      # [2026-11-22 task-jsonderive-deploy-20261122] What: 可选 name/started; Why: 与 schema 对齐且 phase-start 写入 Started 锚点不被判未知字段。
                      "name": STR_FIELD, "started": STR_FIELD})
        required = {"id", "status", "s_units", "v_checks"}
    elif section == "findings":
        known.update({"text": lambda v: isinstance(v, str), "source": lambda v: isinstance(v, str)})
        required = {"id", "text", "source"}
    elif section == "audits":
        known = {
            "round": lambda v: isinstance(v, int) and not isinstance(v, bool) and v >= 1,
            "verdict": lambda v: v in ("APPROVED", "REJECTED"),
            "by": lambda v: isinstance(v, str),
            "at": lambda v: _is_iso8601(v),
            "tags": known["tags"],
            # [2026-11-21] issues 为可选字段（向后兼容旧条目）；一旦出现即逐项按 schema 校验。
            "issues": lambda v: isinstance(v, list) and all(_valid_issue(x) for x in v),
            "counts": lambda v: (
                isinstance(v, dict) and set(v) == {"C", "I", "W"}
                and all(isinstance(v[k], int) and not isinstance(v[k], bool) and v[k] >= 0
                        for k in ("C", "I", "W"))
            ),
        }
        required = {"round", "verdict", "by", "counts", "at"}
    elif section == "delegations":
        known.update({"agent": lambda v: isinstance(v, str), "scope": lambda v: isinstance(v, str),
                      "status": lambda v: v in ("pending", "running", "done", "fail")})
        required = {"id", "agent", "scope", "status"}
    # [2026-11-22 task-jsonderive-deploy-20261122] 新 section 校验分支（What）：required 与
    #   schema definitions 一一对应，字段集与 properties 对齐；原行为这些段根本不在 ARRAY_SECTIONS，
    #   校验器直接报「未知字段」。Why: 通用 add --section 必须写出合法条目，错误在写前暴露。
    #   free_text（含 markdown 原文）只校验类型，不限制内容。
    elif section == "actions":
        known.update({k: STR_FIELD for k in ("phase", "text", "at")})
        required = {"id", "phase", "text"}
    elif section == "files":
        known.update({k: STR_FIELD for k in ("phase", "path", "change")})
        required = {"id", "path", "change"}
    elif section == "test_results":
        known.update({k: STR_FIELD for k in ("phase", "test", "input", "expected", "actual", "status")})
        required = {"id", "test", "status"}
    elif section == "errors":
        known.update({"timestamp": STR_FIELD, "error": STR_FIELD, "attempt": INT_FIELD,
                      "resolution": STR_FIELD, "root_cause": STR_FIELD,
                      "prevention": STR_FIELD, "trigger": STR_FIELD})
        required = {"id", "timestamp", "error"}
    elif section == "reboot5q":
        known.update({"question": STR_FIELD, "answer": STR_FIELD})
        required = {"id", "question", "answer"}
    elif section == "knowledge_use":
        known.update({k: STR_FIELD for k in ("phase", "source", "purpose")})
        required = {"id", "source", "purpose"}
    elif section == "research":
        known.update({"claim": STR_FIELD, "source": STR_FIELD})
        required = {"id", "claim", "source"}
    elif section == "decisions":
        known.update({"decision": STR_FIELD, "rationale": STR_FIELD})
        required = {"id", "decision"}
    elif section == "issues":
        known.update({"issue": STR_FIELD, "resolution": STR_FIELD})
        required = {"id", "issue"}
    elif section == "resources":
        known.update({"locator": STR_FIELD})
        required = {"id", "locator"}
    elif section == "visual":
        known.update({"finding": STR_FIELD, "source": STR_FIELD})
        required = {"id", "finding", "source"}
    elif section == "root_causes":
        known.update({k: STR_FIELD for k in ("process", "defect", "fix", "vc")})
        required = {"id", "process", "defect", "fix"}
    elif section == "invariants":
        known.update({k: STR_FIELD for k in ("state", "item", "anchor")})
        required = {"id", "state", "item", "anchor"}
    elif section == "spec_baseline":
        known.update({k: STR_FIELD for k in ("verbatim", "anchor", "rule", "sha")})
        required = {"id", "verbatim", "anchor"}
    elif section == "progress_baseline":
        known.update({k: STR_FIELD for k in ("item", "snapshot", "metric", "ban", "status")})
        required = {"id", "item", "snapshot"}
    elif section == "scope_limits":
        known.update({"category": STR_FIELD, "allow": STR_LIST_FIELD, "deny": STR_LIST_FIELD})
        required = {"id", "category"}
    elif section == "changes":
        known.update({k: STR_FIELD for k in ("object", "type", "absorb", "quote", "basis", "action")})
        required = {"id", "object", "type"}
    elif section == "knowledge":
        # [2026-11-22 task-jsonderive-deploy-20261122] What: 追加 consumed/landing 字段谓词; Why: findings 知识对齐表 4 列需经通用 add/set 写入，缺则被判未知字段。
        known.update({k: STR_FIELD for k in ("category", "name", "loc", "level", "confirmed",
                                             "consumed", "landing")})
        required = {"id", "category", "name"}
    elif section == "research_status":
        known.update({k: STR_FIELD for k in ("unit", "state", "keywords", "channels", "output", "net")})
        required = {"id", "unit", "state"}
    elif section == "evidence_faces":
        known.update({k: STR_FIELD for k in ("face", "target", "method", "anchor", "status")})
        required = {"id", "face", "target"}
    elif section == "tool_use":
        known.update({k: STR_FIELD for k in ("phase", "tools", "why")})
        required = {"id", "phase", "tools"}
    elif section == "s_units":
        # [2026-11-24 task-sp-driven-invocation H5] What: known 键增 escort_skills → STR_LIST_FIELD。
        # Why: 缺省时通用 add/set 写入 escort_skills 会被下方「未知字段」分支拒绝（审计 N-I-3），
        #      导致默认键虽存在却无法经权威写入接口落库。
        known.update({k: STR_FIELD for k in ("phase", "name", "executor", "files", "actions",
                                              "verify", "duration", "granularity", "parallel")})
        known["escort_skills"] = STR_LIST_FIELD
        required = {"id", "phase", "name"}
    elif section == "anti_regress":
        known.update({k: STR_FIELD for k in ("item", "method", "anchor", "result")})
        required = {"id", "item", "method"}
    elif section == "fmea":
        known.update({"phase": STR_FIELD, "mode": STR_FIELD,
                      "severity": INT_FIELD, "occurrence": INT_FIELD,
                      "detection": INT_FIELD, "rpn": INT_FIELD, "fallback": STR_FIELD})
        required = {"id", "phase", "mode"}
    elif section == "todo_sync":
        known.update({"trigger": STR_FIELD, "action": STR_FIELD})
        required = {"id", "trigger", "action"}
    elif section == "key_questions":
        known.update({"question": STR_FIELD, "answer": STR_FIELD})
        required = {"id", "question", "answer"}
    elif section == "phase_gates":
        known.update({"goal": STR_FIELD, "depends": STR_LIST_FIELD, "done_when": STR_FIELD,
                      "checks": STR_LIST_FIELD, "status": STR_FIELD})
        required = {"id", "goal", "done_when"}
    elif section == "knowledge_compliance":
        known.update({"item": STR_FIELD, "status": STR_FIELD})
        required = {"id", "item", "status"}
    elif section == "cross_checks":
        known.update({"item": STR_FIELD, "method": STR_FIELD, "result": STR_FIELD})
        required = {"id", "item", "method"}

    for key in required:
        if key not in entry:
            errs.append(f"{where}: 缺字段 {key}")
    for key, value in entry.items():
        if key not in known:
            errs.append(f"{where}: 未知字段 {key}")
        elif not known[key](value):
            errs.append(f"{where}.{key}: 值非法（{value!r}）")


def validate_state(doc: Any) -> list[str]:
    """返回全部校验错误（空列表=通过）；手写规则与 schema 一一对应，jsonschema 仅作叠加。"""
    errs: list[str] = []
    if not isinstance(doc, dict):
        return ["$: 顶层必须是 object"]
    # [2026-11-22 task-jsonderive-deploy-20261122] What: 缺字段检查仍只用原 14 个 required 键。
    # Why: 原行为 TOP_LEVEL_KEYS 兼作 required，新增可选字段若并入会导致存量 JSON 校验失败。
    for key in REQUIRED_TOP_LEVEL_KEYS:
        if key not in doc:
            errs.append(f"$: 缺字段 {key}")
    for key in doc:
        if key not in TOP_LEVEL_KEYS:
            errs.append(f"$: 未知字段 {key}")

    simple: dict[str, Callable[[Any], bool]] = {
        "schema_version": lambda v: isinstance(v, int) and not isinstance(v, bool) and v == 1,
        "task_id": lambda v: isinstance(v, str) and v != "",
        "plan_tier": lambda v: v in ("standard", "mini"),
        "execution_lane": lambda v: v in ("L0", "L0-T", "L0-E", "L1", "L2"),
        "created_at": lambda v: _is_iso8601(v),
        "updated_at": lambda v: _is_iso8601(v),
        "tags": lambda v: isinstance(v, list) and all(isinstance(t, str) for t in v),
        # [2026-11-22 task-jsonderive-deploy-20261122] 新标量：原行为无此字段，按自由文本校验。
        "template_type": STR_FIELD,
        # [2026-11-22 task-template-json-compat-20261122] 领域模板正文=自由文本，存量 JSON 无此字段不校验。
        "template_body": STR_FIELD,
        "next_step": STR_FIELD,
    }
    for key, pred in simple.items():
        if key in doc and not pred(doc[key]):
            errs.append(f"$.{key}: 值非法（{doc[key]!r}）")

    # [2026-11-22 task-jsonderive-deploy-20261122] 顶层对象字段（resume_report/config/outcome 等）：
    # What: 校验 required 子字段存在、类型合法、未知键（config/batch/delegation_stats 例外）。
    # Why: set --field 可直接写整对象，必须在 commit 前用与 schema 一致的规则拦截坏数据。
    for field, (obj_required, obj_props, allow_extra) in OBJECT_FIELD_SPECS.items():
        if field not in doc:
            continue
        value = doc[field]
        if not isinstance(value, dict):
            errs.append(f"$.{field}: 必须是 object")
            continue
        for key in obj_required:
            if key not in value:
                errs.append(f"$.{field}: 缺字段 {key}")
        # 遍历规格表（谓词在键上），不是遍历 value.items()——后者会把字段值误当函数调用。
        for key, pred in obj_props.items():
            if key in value and not pred(value[key]):
                errs.append(f"$.{field}.{key}: 值非法（{value[key]!r}）")
        if not allow_extra:
            for key in value:
                if key not in obj_props:
                    errs.append(f"$.{field}: 未知字段 {key}")

    for section in ARRAY_SECTIONS:
        if section in doc:
            arr = doc[section]
            if not isinstance(arr, list):
                errs.append(f"$.{section}: 必须是 array")
                continue
            for i, entry in enumerate(arr):
                _validate_entry(section, entry, f"$.{section}[{i}]", errs)

    if _jsonschema is not None:
        try:
            schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
            for err in _jsonschema.Draft7Validator(schema).iter_errors(doc):
                errs.append("jsonschema: " + err.message)
        except Exception as exc:  # schema 文件本身损坏必须暴露，不算通过
            errs.append(f"jsonschema: 无法加载模式文件（{exc}）")
    return errs


def require_valid(doc: dict[str, Any]) -> None:
    """校验失败即抛错（供 check 等只读命令复用同一判定面）。"""
    errs = validate_state(doc)
    if errs:
        raise PlanctlError("schema 校验失败: " + " | ".join(errs[:8]))


# ─────────────────────────────────────────────────────────────────────────────
# 条目定位 / 默认填充
# ─────────────────────────────────────────────────────────────────────────────

def _entry_matches(entry: dict[str, Any], section: str, ident: str) -> bool:
    """audits 无 id 字段：接受 round 数字串与 'R<round>' 两种引用形态。"""
    if section == "audits":
        rnd = entry.get("round")
        return ident in {str(rnd), f"R{rnd}"}
    return str(entry.get("id", "")) == str(ident)


def find_entry(doc: dict[str, Any], section: str, ident: str) -> tuple[int, dict[str, Any]] | None:
    """按 section/ident 定位条目，返回 (index, entry)；未命中返回 None。"""
    arr = doc.get(section)
    if not isinstance(arr, list):
        raise PlanctlError(f"未知或非法 section: {section}")
    for i, entry in enumerate(arr):
        if isinstance(entry, dict) and _entry_matches(entry, section, ident):
            return i, entry
    return None


def normalize_entry(section: str, payload: Any, ident: str | None = None) -> dict[str, Any]:
    """补齐条目默认字段并核对身份；身份缺失/与路径 id 不一致时显式报错。"""
    if section not in ARRAY_SECTIONS:
        raise PlanctlError(f"未知 section: {section}（可用: {', '.join(ARRAY_SECTIONS)}）")
    if not isinstance(payload, dict):
        raise PlanctlError(f"{section}: --json 必须是 object")
    entry = copy.deepcopy(payload)
    for key, value in ENTRY_DEFAULTS[section].items():
        entry.setdefault(key, copy.deepcopy(value))

    if section == "audits":
        if "round" not in entry:
            raise PlanctlError("audits: --json 缺 round")
    else:
        if not entry.get("id") and ident:
            entry["id"] = ident
        if not entry.get("id"):
            raise PlanctlError(f"{section}: 缺 id（--json 需含 id 或传 --id）")
        if ident and str(entry["id"]) != str(ident):
            raise PlanctlError(f"{section}: --json 的 id={entry['id']!r} 与 --id={ident!r} 不一致")
    return entry


def coerce_value(raw: str) -> Any:
    """CLI --value 默认字符串；能解析成 list/dict/int/bool/null 时按 JSON 类型落库。"""
    try:
        parsed = json.loads(raw)
    except (json.JSONDecodeError, TypeError):
        return raw
    if isinstance(parsed, str):
        return parsed if raw.strip().startswith('"') else raw  # 裸词保留原样（如 pass/APPROVED）
    return parsed


def emit(obj: Any) -> None:
    """统一 stdout JSON 输出（ensure_ascii=False 保留中文，机器可 json.load）。"""
    print(json.dumps(obj, ensure_ascii=False, indent=2))


# ─────────────────────────────────────────────────────────────────────────────
# 倒排标签索引
# ─────────────────────────────────────────────────────────────────────────────

def tag_index_path(plan_dir: Path) -> Path:
    """索引位于 plan-dir 的上一级：<plan-dir>/../.tags-index.json。"""
    return plan_dir.resolve().parent / TAGS_INDEX_NAME


def read_tag_index(plan_dir: Path) -> dict[str, list[str]]:
    """读倒排索引；文件不存在=空索引，存在但结构损坏=报错（ fail loud，不重建以免掩盖问题）。"""
    p = tag_index_path(plan_dir)
    if not p.exists():
        return {}
    try:
        idx = json.loads(p.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise PlanctlError(f"tags 索引非法 JSON: {p}: {exc}") from exc
    if not isinstance(idx, dict) or any(not isinstance(v, list) for v in idx.values()):
        raise PlanctlError(f"tags 索引结构非法（应为 {{tag: [ref,...]}}）: {p}")
    return idx


# ─────────────────────────────────────────────────────────────────────────────
# 子命令实现
# ─────────────────────────────────────────────────────────────────────────────

def cmd_init(args: argparse.Namespace) -> int:
    """从模板生成权威源；task_id/tier/lane 覆盖模板占位，时间戳填当前 UTC。"""
    plan = check_plan_dir(args.plan_dir)
    dest = state_path(plan)
    if dest.exists() and not getattr(args, "force", False):
        raise PlanctlError(f"plan-state.json 已存在，拒绝覆盖（先 backup 或加 --force）: {dest}")
    if not TEMPLATE_PATH.exists():
        raise PlanctlError(f"模板缺失: {TEMPLATE_PATH}")
    doc = json.loads(TEMPLATE_PATH.read_text(encoding="utf-8"))
    doc["task_id"] = args.task_id
    if args.tier:
        doc["plan_tier"] = args.tier
    if args.lane:
        doc["execution_lane"] = args.lane
    doc["created_at"] = now_iso()
    doc["updated_at"] = doc["created_at"]
    # [2026-11-22 task-template-json-compat-20261122] 领域段 JSON 承载：init 时把所选模板正文
    #   原文写入 template_body（写操作仍走 planctl 单一入口）；路径不存在/读失败 fail-loud，
    #   未传该参数则字段缺省（存量与 mini 档兼容）。
    tb_from = getattr(args, "template_body_from", None)
    if tb_from:
        _tb = Path(tb_from)
        if not _tb.is_file():
            raise PlanctlError(f"--template-body-from 指向的文件不存在: {tb_from}")
        doc["template_body"] = _tb.read_text(encoding="utf-8")
    commit_state(plan, doc, backup=False, touch=False)
    emit({"state": str(dest), "task_id": doc["task_id"], "plan_tier": doc["plan_tier"],
          "execution_lane": doc["execution_lane"]})
    return 0


def cmd_get(args: argparse.Namespace) -> int:
    """输出整份状态 / 某段 / 某条目 JSON，供脚本直接消费。"""
    doc = read_state(check_plan_dir(args.plan_dir))
    if not args.section:
        out: Any = doc
    elif args.section in ("tags", *ARRAY_SECTIONS):
        out = doc[args.section]
        if args.id:
            if args.section == "tags":
                out = next((t for t in out if t == args.id), None)
            else:
                hit = find_entry(doc, args.section, args.id)
                out = hit[1] if hit else None
            if out is None:
                raise PlanctlError(f"{args.section} 中未找到 id={args.id!r}")
    elif args.section in TOP_LEVEL_KEYS:
        # [2026-11-22 task-jsonderive-deploy-20261122] What: 支持 get --section <顶层对象/标量字段>。
        # Why: 原行为只认 tags 与原 7 个数组；新语义段可缺省，必须区分「未设置」与空值。
        if args.id:
            raise PlanctlError(f"顶层字段 {args.section} 不支持 --id")
        if args.section not in doc:
            raise PlanctlError(f"{args.section} 未设置（该顶层字段可选）")
        out = doc[args.section]
    else:
        raise PlanctlError(f"未知 section: {args.section}")
    emit(out)
    return 0


# ── 压缩恢复：核心状态获取能力收口到 planctl（唯一权威源读取者）────────────────
# [2026-11-25 task-planctl-recover] What: 新增 recover 子命令，压缩后由 hook 直接调用，
#   从 plan-state.json（权威源）读「代表当前任务最核心」的字段，产出注入恢复包。
# Why: 原方案把「恢复时能拿到什么」写死在 lib/plan-recovery.sh 的 jq 拼接里，hook/selftest
#   各自引用旁路，升级数据面要改多处；且原 recover 只读 goals、漏了 requirements[].text
#   （用户原话=任务目标权威源）。收口到 planctl 后：升级只改这一处，数据源唯一、无 jq 依赖。
RECOVER_DEFAULT_FIELDS = (
    "core_files", "skill_contract", "requirements", "goal", "phase", "next_step", "decisions", "mustkeep", "git_baseline",
)


def _recover_flat(value: Any, fallback: str = "-") -> str:
    """把 plan-state 字段扁平化为单行文本；空值/缺失写 fallback，不编造。"""
    if value is None:
        return fallback
    if isinstance(value, str):
        return value if value else fallback
    if isinstance(value, list):
        parts: list[str] = []
        for item in value:
            if isinstance(item, dict):
                parts.append(str(item.get("text") or item.get("goal") or item.get("name")
                                  or item.get("decision") or item.get("id") or ""))
            else:
                parts.append(str(item))
        joined = " / ".join(p for p in parts if p)
        return joined if joined else fallback
    if isinstance(value, dict):
        for key in ("text", "goal", "decision", "name", "id"):
            if value.get(key):
                return str(value[key])
        return fallback
    return str(value)


def cmd_recover(args: argparse.Namespace) -> int:
    """压缩恢复包：从权威源读核心字段 -> 文本注入 + 全文落盘 .compact-recovery.md。

    --fields 逗号分隔指定核心字段（默认 RECOVER_DEFAULT_FIELDS）：requirements/goal/phase/
    next_step/decisions/mustkeep/git_baseline/core_files。字段缺失一律写 `-`，不编造。
    --max-lines 限幅注入（默认 80，落盘全文不受限）。输出文本与旧 shell 版兼容。
    """
    plan_dir = check_plan_dir(args.plan_dir)
    task_id = plan_dir.name
    fields_raw = getattr(args, "fields", None) or ",".join(RECOVER_DEFAULT_FIELDS)
    fields = [f.strip() for f in fields_raw.split(",") if f.strip()]
    max_lines_raw = getattr(args, "max_lines", 80)
    max_lines = max_lines_raw if isinstance(max_lines_raw, int) and max_lines_raw >= 2 else 80

    doc = read_state(plan_dir)
    lines: list[str] = []

    # 保留旧版首行标记，确保 hook/selftest 的 [compact-recovery] 断言继续成立
    lines.append(f"[compact-recovery] 上下文恢复包（检测到在途计划 {task_id}；数据来自 planctl 读权威源 plan-state.json，非会话记忆。摘要可能丢细节，以下列字段为准）")

    # core_files：任务目标/原话/上下文核心文件的强制读取指令（用户 2026-11-25 授权收窄范围）
    if "core_files" in fields:
        lines.append("⚠️ 强制读取指令（压缩后必做，先于任何其它工具调用）: 摘要不可信。必须立即用 Read 依次读下列【核心文件（任务目标/上下文类）】全文，读完前不得推进任务、不得删改任何既有设定/事实：")
        lines.append("【核心·强制读取】（任务目标/原话/规范基线/结论，按序）:")
        lines.append(f"1. {plan_dir}/user-session-log.md（全文；用户原话=任务目标权威源，逐字条目 #N）")
        lines.append(f"2. {plan_dir}/task_plan.md（需求原文 / 🔒 规范基线(MK) / 变更标注表 / 验收契约 / Goal / Phase）")
        lines.append(f"3. {plan_dir}/findings.md（结论与证据锚）")
        lines.append(f"【按需·非强制】（非任务目标类，遇到问题再读）: 4. {plan_dir}/knowledge-brief.md（易错点） 5. {plan_dir}/.git-baseline-report.md（未处置偏移，若存在）")

    # skill_contract：压缩后 SKILL.md 正文可能被整体冲掉 → agent 遗忘技能语义、行为偏移。
    #   只重读技能入口 SKILL.md 一个文件；其余规则/配置由 SKILL.md 的指针按需加载，不在此预列
    #   （用户 2026-11-25 裁决：不要画蛇添足一次性铺开整个技能包）。
    if "skill_contract" in fields:
        lines.append("【技能体系·强制重读】（压缩后本技能 SKILL.md 正文可能被整体遗忘→行为偏移技能要求；须先重读再执行，其余规则/配置按 SKILL.md 指针按需加载）:")
        lines.append(f"1. {SKILL_DIR}/SKILL.md（技能入口：frontmatter + 工作流 + 全部硬条款，全文；遗忘此文件=技能体系崩溃）")

    # requirements[].text：用户逐字原话 = 任务目标权威源（旧版遗漏的关键字段）
    if "requirements" in fields:
        reqs = doc.get("requirements") or []
        lines.append("Requirements（用户原话/任务目标，逐字）:")
        if isinstance(reqs, list) and reqs:
            for r in reqs[:100]:
                if isinstance(r, dict):
                    rid = r.get("id") or "-"
                    lines.append(f"[{rid}] {_recover_flat(r.get('text'))}")
                else:
                    lines.append(_recover_flat(r))
        else:
            lines.append("-")

    if "goal" in fields:
        goal = doc.get("goal", doc.get("goals"))
        lines.append(f"Goal: {_recover_flat(goal)}")

    if "phase" in fields:
        phases = doc.get("phases") or []
        cur = "-"
        if isinstance(phases, list):
            for p in phases:
                if isinstance(p, dict) and p.get("status") == "in_progress":
                    cur = str(p.get("name") or p.get("phase") or p.get("id") or p.get("title") or "-")
                    break
        lines.append(f"Current Phase: {cur}")

    if "next_step" in fields:
        lines.append(f"Next Step: {_recover_flat(doc.get('next_step', doc.get('next')))}")

    if "decisions" in fields:
        decs = doc.get("decisions", doc.get("decisions_made")) or []
        lines.append("Decisions（全部，一行一条）:")
        if isinstance(decs, list) and decs:
            for d in decs[:100]:
                lines.append(_recover_flat(d))
        elif isinstance(decs, dict) or isinstance(decs, str):
            lines.append(_recover_flat(decs))
        else:
            lines.append("-")

    # mustkeep：spec_baseline 中 id 以 MK 开头的必保项（与 shell 版 mustkeep 同语义）
    if "mustkeep" in fields:
        sb = doc.get("spec_baseline") or []
        lines.append("必保清单:")
        mk_count = 0
        if isinstance(sb, list):
            for item in sb:
                if not isinstance(item, dict):
                    continue
                mid = str(item.get("id") or "")
                if not mid.startswith("MK"):
                    continue
                verbatim = _recover_flat(item.get("verbatim"))
                rule = str(item.get("rule") or "")
                target = rule.split("target=", 1)[1].split("|", 1)[0] if "target=" in rule else "?"
                anchor = _recover_flat(item.get("anchor"))
                lines.append(f"{mid} | {verbatim} | target={target} | 真源={anchor}")
                mk_count += 1
        if mk_count == 0:
            lines.append("必保清单=缺失（存量计划，非阻断提示）")

    # git_baseline：读 .git-baseline.json sidecar（缺失/不可读写指引，不编造）
    if "git_baseline" in fields:
        sidecar = plan_dir / ".git-baseline.json"
        script_dir = SCRIPT_DIR
        if not sidecar.is_file():
            lines.append(f"Git基线: 缺失 → 先执行 B9（任务开始前备份，未做不得写受管文件）: bash {script_dir}/git-baseline.sh snapshot {plan_dir}")
        else:
            try:
                g = json.loads(sidecar.read_text(encoding="utf-8"))
                sha = str(g.get("baseline_sha") or "-")[:8]
                cps = g.get("checkpoints")
                cps_n = len(cps) if isinstance(cps, list) else 0
                last = g.get("last_diff") if isinstance(g.get("last_diff"), dict) else {}
                def _n(v: Any) -> str:
                    return str(v) if isinstance(v, (int, str)) and v != "" else "0"
                lines.append(
                    f"Git基线: {sha} 检查点={cps_n} 未处置={_n(last.get('unresolved'))} "
                    f"必保丢失={_n(last.get('mustkeep_lost'))}（最近分析 {last.get('at') or '-'}；"
                    f"续做前先跑 B11: bash {script_dir}/git-baseline.sh diff {plan_dir}）"
                )
            except (OSError, ValueError, TypeError):
                lines.append(f"Git基线: 证据文件不可读 → 重跑 bash {script_dir}/git-baseline.sh status {plan_dir}")

    full = "\n".join(lines)

    # 全文落盘供截断后追读；写入失败 fail-open，不影响注入
    try:
        (plan_dir / ".compact-recovery.md").write_text(full + "\n", encoding="utf-8")
    except OSError:
        pass

    total = len(lines)
    if total > max_lines:
        print("\n".join(lines[: max_lines - 1]))
        print(f"…已截断（上限 {max_lines} 行）；全文见 {plan_dir}/.compact-recovery.md")
    else:
        print(full)
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    """输出 Phase/VC/审计状态摘要 JSON（机器可读，非人读表格）。"""
    doc = read_state(check_plan_dir(args.plan_dir))
    phases = doc["phases"]
    vcs = doc["vcs"]

    def tally(items: list[dict[str, Any]], field: str) -> dict[str, int]:
        counts: dict[str, int] = {}
        for item in items:
            key = str(item.get(field, "unknown"))
            counts[key] = counts.get(key, 0) + 1
        return counts

    audits = doc["audits"]
    last_audit = max(audits, key=lambda a: a.get("round", 0)) if audits else None
    # [2026-11-21] no_progress_streak 供外部观测无进展止损命中态（与 check audit 同一判定面）。
    no_progress, _ = audit_no_progress(audits)
    emit({
        "task_id": doc["task_id"],
        "plan_tier": doc["plan_tier"],
        "execution_lane": doc["execution_lane"],
        "created_at": doc["created_at"],
        "updated_at": doc["updated_at"],
        "phase_counts": tally(phases, "status"),
        "vc_counts": tally(vcs, "status"),
        "phases": [{"id": p.get("id"), "status": p.get("status")} for p in phases],
        "vcs": [{"id": v.get("id"), "status": v.get("status")} for v in vcs],
        "last_audit": last_audit,
        "no_progress_streak": no_progress,
        "tag_count": len(doc["tags"]),
    })
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    """schema 校验；rc 0 通过 / 1 失败（错误逐条打印到 stderr）。"""
    doc = read_state(check_plan_dir(args.plan_dir))
    errs = validate_state(doc)
    if errs:
        for err in errs:
            print(f"VALIDATE FAIL {err}", file=sys.stderr)
        return 1
    print("VALIDATE PASS")
    return 0


def cmd_set(args: argparse.Namespace) -> int:
    """修改条目字段（--section/--id）或顶层字段（仅 --field/--value）；值经 coerce_value 提升类型。

    [2026-11-22 task-jsonderive-deploy-20261122] What: 新增无 --section 的顶层写入分支。
    Why: 原行为 --section/--id 均 required，只能改数组条目；新语义段中 template_type/next_step/
         outcome/config 等是顶层对象或标量，必须可写才能替代直接 Edit MD。
         coerce_value 对 '{"a":1}' 返回 dict、对 '裸词' 返回 str，已兼容对象/字符串，无需改造。
    """
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    value = coerce_value(args.value)
    if not args.section:
        if args.id is not None:
            raise PlanctlError("写顶层字段时不得传 --id（要改条目请补 --section）")
        if args.field not in TOP_LEVEL_KEYS:
            raise PlanctlError(f"未知顶层字段: {args.field}")
        doc[args.field] = value
        commit_state(plan, doc)
        emit({"field": args.field, "value": value, "scope": "top_level"})
        return 0
    if args.id is None:
        raise PlanctlError("写条目字段必须同时传 --id")
    hit = find_entry(doc, args.section, args.id)
    if hit is None:
        raise PlanctlError(f"{args.section} 中未找到 id={args.id!r}")
    hit[1][args.field] = value
    commit_state(plan, doc)
    emit({"section": args.section, "id": args.id, "field": args.field,
          "value": hit[1][args.field]})
    return 0


def cmd_add(args: argparse.Namespace) -> int:
    """新增条目；id/round 重复即拒绝（避免同名条目让下游定位产生歧义）。"""
    plan = check_plan_dir(args.plan_dir)
    try:
        payload = json.loads(args.json)
    except json.JSONDecodeError as exc:
        raise PlanctlError(f"--json 非法 JSON: {exc}") from exc
    doc = read_state(plan)
    entry = normalize_entry(args.section, payload)
    # [2026-11-22 task-jsonderive-deploy-20261122] What: 可选 section 首次写入时懒初始化为 []。
    # Why: 原行为 7 个数组由 init 模板保证存在；新段缺省于存量 JSON，直接 find/append 会误报
    #       「未知或非法 section」，使通用 add 对存量计划不可用。
    doc.setdefault(args.section, [])
    hit = find_entry(doc, args.section,
                     str(entry.get("round")) if args.section == "audits" else str(entry["id"]))
    if hit is not None:
        raise PlanctlError(f"{args.section} 条目已存在: {args.id or entry.get('id')}")
    doc[args.section].append(entry)
    commit_state(plan, doc)
    emit({"section": args.section, "added": entry})
    return 0


def cmd_update(args: argparse.Namespace) -> int:
    """整条目替换（保留位置），不是字段合并；身份必须与 --id 一致。"""
    plan = check_plan_dir(args.plan_dir)
    try:
        payload = json.loads(args.json)
    except json.JSONDecodeError as exc:
        raise PlanctlError(f"--json 非法 JSON: {exc}") from exc
    doc = read_state(plan)
    hit = find_entry(doc, args.section, args.id)
    if hit is None:
        raise PlanctlError(f"{args.section} 中未找到 id={args.id!r}")
    entry = normalize_entry(args.section, payload, ident=args.id)
    doc[args.section][hit[0]] = entry
    commit_state(plan, doc)
    emit({"section": args.section, "id": args.id, "updated": entry})
    return 0


def cmd_delete(args: argparse.Namespace) -> int:
    """删除条目；未命中即报错，不做静默 no-op。"""
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    hit = find_entry(doc, args.section, args.id)
    if hit is None:
        raise PlanctlError(f"{args.section} 中未找到 id={args.id!r}")
    doc[args.section].pop(hit[0])
    commit_state(plan, doc)
    emit({"section": args.section, "id": args.id, "deleted": True})
    return 0


def cmd_phase_done(args: argparse.Namespace) -> int:
    """Phase 状态流转 → complete，自动刷新 updated_at。"""
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    hit = find_entry(doc, "phases", args.id)
    if hit is None:
        raise PlanctlError(f"phases 中未找到 id={args.id!r}")
    hit[1]["status"] = "complete"
    commit_state(plan, doc)
    emit({"id": args.id, "status": "complete", "updated_at": doc["updated_at"]})
    return 0


def cmd_phase_start(args: argparse.Namespace) -> int:
    """[2026-11-22 task-jsonderive-deploy-20261122] Phase → in_progress 并写 started=now。

    WHAT: 找到 phase 后设 status=in_progress、started=now_iso()，刷新 updated_at，原子提交。
    WHY: check-3file-gate.sh 从 progress.md 的 `- **Started:**` 行取 mtime 锚点；原状态无 started
         字段，render 只能输出空 Started，门控退化为 stale 阈值模式。phase-start 让 Started 有
         真实 ISO 时间源（与 vc-pass/phase-done 同构的状态流转，不引入新依赖）。
    """
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    hit = find_entry(doc, "phases", args.id)
    if hit is None:
        raise PlanctlError(f"phases 中未找到 id={args.id!r}")
    started = now_iso()
    hit[1]["status"] = "in_progress"
    hit[1]["started"] = started
    commit_state(plan, doc)
    emit({"id": args.id, "status": "in_progress", "started": started,
          "updated_at": doc["updated_at"]})
    return 0


def _vc_transition(args: argparse.Namespace, status: str) -> int:
    """vc-pass / vc-fail 共用实现：设置 status 并刷新 updated_at。"""
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    hit = find_entry(doc, "vcs", args.id)
    if hit is None:
        raise PlanctlError(f"vcs 中未找到 id={args.id!r}")
    hit[1]["status"] = status
    commit_state(plan, doc)
    emit({"id": args.id, "status": status, "updated_at": doc["updated_at"]})
    return 0


def cmd_vc_pass(args: argparse.Namespace) -> int:
    """VC 判定通过 → status=pass。"""
    return _vc_transition(args, "pass")


def cmd_vc_fail(args: argparse.Namespace) -> int:
    """VC 判定失败 → status=fail。"""
    return _vc_transition(args, "fail")


def cmd_audit_add(args: argparse.Namespace) -> int:
    """追加一轮独立审计；round 重复拒绝，at 自动填 ISO8601。

    [2026-11-21] 可选 --issues-json 落 issues[]；未提供时保持旧行为（条目无 issues 字段）。
    Why: issues 是跨轮无进展判定的唯一信号源，必须在写入时就按 schema 校验，不能留到 check 才暴露。
    """
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    if find_entry(doc, "audits", str(args.round)) is not None:
        raise PlanctlError(f"audits 轮次已存在: round={args.round}")
    issues = parse_issues_json(getattr(args, "issues_json", None))
    payload: dict[str, Any] = {
        "round": args.round, "verdict": args.verdict, "by": args.by,
        "counts": {"C": args.c, "I": args.i, "W": args.w}, "at": now_iso(), "tags": [],
    }
    if issues is not None:
        payload["issues"] = issues
    entry = normalize_entry("audits", payload)
    doc["audits"].append(entry)
    commit_state(plan, doc)
    emit({"added": entry})
    return 0


def cmd_tag_add(args: argparse.Namespace) -> int:
    """给条目打 tag 并同步 <plan-dir>/../.tags-index.json 倒排索引（O(1) 检索面）。"""
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    if args.section not in ARRAY_SECTIONS:
        raise PlanctlError(f"tag-add 不支持 section={args.section!r}")
    hit = find_entry(doc, args.section, args.id)
    if hit is None:
        raise PlanctlError(f"{args.section} 中未找到 id={args.id!r}")
    tags = hit[1].setdefault("tags", [])
    if not isinstance(tags, list):
        raise PlanctlError(f"{args.section}/{args.id} 的 tags 不是 array")
    if args.tag not in tags:
        tags.append(args.tag)
        tags.sort()
    ident = str(hit[1].get("round")) if args.section == "audits" else str(hit[1]["id"])
    commit_state(plan, doc)

    ref = f"{doc['task_id']}#{args.section}/{ident}"
    idx = read_tag_index(plan)
    refs = idx.setdefault(args.tag, [])
    if ref not in refs:
        refs.append(ref)
        refs.sort()
    atomic_write(tag_index_path(plan), json_bytes(idx))
    emit({"tag": args.tag, "ref": ref, "index": str(tag_index_path(plan))})
    return 0


def cmd_tag_search(args: argparse.Namespace) -> int:
    """按 tag 从倒排索引 O(1) 取条目引用列表（不扫描所有 plan-state.json）。"""
    plan = check_plan_dir(args.plan_dir)
    idx = read_tag_index(plan)
    emit({"tag": args.tag, "refs": idx.get(args.tag, [])})
    return 0


def _md_table(headers: list[str], rows: list[list[Any]]) -> str:
    """生成 Markdown 表格；单元格内的竖线转义，避免破坏列边界。"""
    def cell(v: Any) -> str:
        s = ", ".join(str(x) for x in v) if isinstance(v, list) else ("" if v is None else str(v))
        return s.replace("|", "\\|").replace("\n", " ")
    out = ["| " + " | ".join(headers) + " |",
           "|" + "|".join(["---"] * len(headers)) + "|"]
    out.extend("| " + " | ".join(cell(c) for c in row) + " |" for row in rows)
    return "\n".join(out)


# ── [2026-11-22 task-jsonderive-deploy-20261122] MD 视图派生辅助 ────────────────
# What: 为 4 个 MD 视图提供统一的「可选段安全读取 + 显式空占位 + Phase 号归一」原语。
# Why: 原 cmd_render 只输出 7 段简表，模板全部语义段（Error Log/5Q/Research/Gate 等）无法从
#       JSON 派生；新语义段对存量空壳是可选的，缺字段/类型异常必须退化为「无数据」而非崩溃。


def _arr(doc: dict[str, Any], key: str) -> list[dict[str, Any]]:
    """取可选数组段；缺字段或非数组时返回空表（fail-loud 由 validate 负责，render 只读）。"""
    value = doc.get(key)
    return value if isinstance(value, list) else []


def _obj(doc: dict[str, Any], key: str) -> dict[str, Any]:
    """取可选对象段；缺字段或非对象时返回空字典。"""
    value = doc.get(key)
    return value if isinstance(value, dict) else {}


def _phase_no(ident: Any) -> str:
    """把 phase id（P1/1/p2）归一为模板 `### Phase N:` 的纯数字 N。

    check-3file-gate.sh 以 `^#+ Phase [0-9]+:` 定位 Phase 段，若输出 `### Phase P1:` 则
    永远匹配不到 —— 这是 Started mtime 锚点失效的直接成因，故此处统一剥掉 P 前缀。
    """
    m = re.match(r"^[Pp]?(\d+)$", str(ident))
    return m.group(1) if m else str(ident)


def _phase_match(value: Any, ident: Any) -> bool:
    """按 phase 关联 actions/files/test_results 等条目；兼容 P1 / 1 / 1 三种写法。"""
    no = _phase_no(ident)
    return str(value) in {str(ident), no, f"P{no}"}


def _cell(v: Any) -> str:
    """把数组/None 转成可读单元格文本（_md_table 亦做此处理，便于段内自由文本拼接）。"""
    if isinstance(v, list):
        return ", ".join(str(x) for x in v)
    return "" if v is None else str(v)


def _table(headers: list[str], rows: list[list[Any]], empty: str) -> str:
    """空数据补一行显式占位（Rule 71 / check-complete 3-File stub 判定的共同要求）。"""
    return _md_table(headers, rows if rows else [[empty] + [""] * (len(headers) - 1)])


def _bullets(items: list[str], empty: str, indent: str = "") -> list[str]:
    """bullet 列表；无条目时输出显式占位行，不用空段。"""
    return [f"{indent}- {x}" for x in items] if items else [f"{indent}- {empty}"]


def _kv_table(obj: dict[str, Any], keys: tuple[str, ...], labels: tuple[str, ...] | None = None,
              empty: str = "（本任务暂无记录）") -> str:
    """把对象字段渲染为「字段|值」2 列表；无任何非空字段时输出占位行。"""
    labels = labels or keys
    rows = [[label, _cell(obj.get(k, ""))] for k, label in zip(keys, labels) if obj.get(k, "") not in (None, "", [], {})]
    return _table(["字段", "值"], rows, empty)


# S-unit 表 10 列固定列序（与 templates/task_plan.md:362 逐字一致）：
# check-plan-dispatch.sh 用 awk -F'|' 的 $4/$5/$7/$8 定位执行体/输入/时长/粒度，列序不可改。
SUNIT_HEADERS = ["ID", "目标(≤1 句)", "执行体(subagent_type(model))",
                 "输入(路径 + ≤10 行摘要)", "验收(可观察)", "预估时长",
                 "粒度(三值)", "伴飞技能", "前置依赖", "状态"]

# 空段占位统一前缀（Rule 71：显式占位合法，禁推测填充）
_EMPTY = "（本任务暂无%s）"


def _render_task_plan(doc: dict[str, Any], tid: str, stamp: str, meta: str,
                      top_tags: str, idx: dict[str, list[str]]) -> str:
    """重建 task_plan.md：恒输出 Requirements/Goals/Phases/R→VC/VC，其余段按数据在位追加。

    What: 原视图仅 4 张简表；本函数把 JSON 中 20+ 个语义段映射为模板同构段落。
    Why: 「MD 全派生」要求模板语义段可从 JSON 重建；空段不输出以保持视图精简（与验收条款一致）。
    """
    lines: list[str] = [
        GENERATED_HEADER, f"# Task Plan: {tid}", "", stamp.rstrip(), meta.rstrip(),
        f"- 顶层 tags: {top_tags}", "",
        # [2026-11-22 task-planctl-exec-surface-20261122] What: 补「🎯 用户需求原文」+R 行区块。
        # Why: attest Rule 51.1 硬门四锚（fail-closed 无 --skip 逃生口）按标题行 + R 需求行
        #   正则 ^[[:space:]]*[-*][[:space:]]+\*\*R[0-9] 校验；原 render 缺失 → 纯 CLI 流
        #   过不了 51.1（F4 闭环断裂同类）。数据源=requirements 逐条派生。
        "## 🎯 用户需求原文",
        *[f"- **{r.get('id', '')}（{r.get('type', '')}）** {r.get('text', '')}"
          for r in _arr(doc, "requirements")],
        "",
        "## Requirements（用户需求）",
        _md_table(["id", "type", "text", "vc", "tags"],
                  [[r.get("id"), r.get("type"), r.get("text"), r.get("vc", []), r.get("tags", [])]
                   for r in _arr(doc, "requirements")]),
        "", "## Goals（目标单元）",
        _md_table(["id", "text", "evidence", "tags"],
                  [[g.get("id"), g.get("text"), g.get("evidence", ""), g.get("tags", [])]
                   for g in _arr(doc, "goals")]),
        # [2026-11-22 task-planctl-exec-surface-20261122] What: 补「🎯 Goal 单元表」六列锚区块。
        # Why: check-plan-dispatch.sh Rule 66.5（attest 拒锁门）按本区块表头六列关键词+G<n> 连续数据行
        #   校验；原 render 缺失 → 纯 CLI 流（add→render→attest）结构性过不了 attest（F4 闭环断裂）。
        #   字段：goal 新增可选 name/verify/s_units/status；存量 goal 无 verify 时回退指向 VC 全集
        #   （诚实描述、非占位符，避免 66.5「完整验证方式列为空/占位」误伤存量数据）。
        "", "## 🎯 Goal 单元表",
        _md_table(["goal-id", "任务名", "目标", "完整验证方式", "对应 S-unit", "状态"],
                  [[g.get("id"), g.get("name", ""), g.get("text"),
                    g.get("verify", "") or "见下方 ✅ Verification Contract 区块（VC 全集）",
                    ", ".join(g.get("s_units", [])) or "-", g.get("status", "pending")]
                   for g in _arr(doc, "goals")]),
        "", "## Phases（阶段状态）",
        _md_table(["id", "status", "s_units", "v_checks", "name", "started", "tags"],
                  [[p.get("id"), p.get("status"), p.get("s_units", []), p.get("v_checks", []),
                    p.get("name", ""), p.get("started", ""), p.get("tags", [])]
                   for p in _arr(doc, "phases")]),
        "", "## R→VC 映射",
        # [2026-11-22 task-planctl-exec-surface-20261122] What: 标题去空格（原「R → VC 映射」不命中
        # attest 51.1 第 3 锚 ^#{2,3}.*R→VC 映射）；并在其后补「🧮 根源覆盖表」（第 4 锚 ^##[^#].*根源覆盖表，
        # 数据源=root_causes 五列；未登记时输出补登指引行，禁静默空表）。
        _md_table(["requirement", "vcs"],
                  [[r.get("id"), r.get("vc", [])] for r in _arr(doc, "requirements")]),
        "## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）",
        _md_table(["工序", "缺陷面", "修复点", "VC"],
                  [[rc.get("process"), rc.get("defect"), rc.get("fix"), rc.get("vc", "-")]
                   for rc in _arr(doc, "root_causes")] or
                  [["（root_causes 未登记）",
                    "结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由",
                    "-", "-"]]),
        "", "## ✅ Verification Contract（VC 状态与判据）",
        _md_table(["#", "判定标准", "验证方式", "证据路径/命令"],
                  [[v.get("id"), v.get("criterion"), v.get("command"), v.get("evidence")]
                   for v in _arr(doc, "vcs")]),
    ]
    # [2026-11-22 task-planctl-exec-surface-20261122] What: 补「🔍 调研需求与检索计划」区块（Rule 75.1）。
    # Why: check-plan-dispatch 75.1 advisory 按区块字面存在检测；数据源=research_status 对象。
    #   mini 档豁免不输出；无数据时输出显式 LOCAL-ONLY 声明行（诚实非空段，非占位符）。
    if doc.get("plan_tier") != "mini":
        rs = _obj(doc, "research_status")
        if rs and (rs.get("unit") or rs.get("state")):
            rs_rows = [[rs.get("unit", "全局"), rs.get("state", "LOCAL-ONLY"),
                        rs.get("keywords", "") or "（无 NET-* 检索项）",
                        rs.get("channels", "") or "-", rs.get("output", "") or "-"]]
        else:
            rs_rows = [["全局", "LOCAL-ONLY",
                        "（无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登）", "-", "-"]]
        lines += ["", "## 🔍 调研需求与检索计划",
                  _md_table(["unit", "三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT)",
                             "检索关键词", "渠道", "预期产出形态"], rs_rows)]
    phases = _arr(doc, "phases")
    # [2026-11-22 task-jsonderive-deploy-20261122] What: 逐 Phase 输出 ### 标题 + Status/Started 行。
    # Why: check-3file-gate.sh 从 task_plan.md 取 in_progress Phase、从 progress.md取 Started 锚点；
    #       简表无法提供 `### Phase N:` 标题，门控会静默退化为「无活动 Phase」。
    # [C-1 修复] What: 每 Phase 块内追加 `- **Executor:**` 行 + 该 Phase 的 S-unit 表（10 列锁序）。
    # Why: check-plan-dispatch.sh:59 以全文级 `^- \*\*Executor:\*\*` 判现代计划，:47/:51 以 `## ` 收段
    #       ——S-unit 表必须在 ### Phase 块内（下一个 ## 之前）才落解析面；独立顶层段被跳过（CR-1）。
    s_units_all = _arr(doc, "s_units")
    if phases:
        lines += ["", "## Phase 锚点明细（3file-gate/plan-dispatch 解析面）"]
        for p in phases:
            pid = _cell(p.get("id", ""))
            ph_sus = [s for s in s_units_all if s.get("phase") == pid]
            executors = "、".join(dict.fromkeys(
                str(s.get("executor", "")).strip() for s in ph_sus if str(s.get("executor", "")).strip()
            )) or "-"
            su_rows = []
            for s in ph_sus:
                name = _cell(s.get("name", ""))
                actions = _cell(s.get("actions", ""))
                goal = f"[{_cell(pid)}] {name}" + (f"（{actions}）" if actions else "")
                # [2026-11-24 task-sp-driven-invocation H5] What: 第8列「伴飞技能」改渲染 escort_skills 的 .md
                #   路径（空→「无」）；parallel 组标识从第8列移出，落第9列「前置依赖」行内注解。
                # Why: 原第8列填 parallel 使 Rule 59.2「路径+首动作 Read」无承载列；前置依赖列原恒渲 "-"
                #   恰好可复用，零列变更、不动 SUNIT_HEADERS/31 个 variant。注解用 [parallel-group:<值>]
                #   中性 token：check-plan-dispatch.sh 的 rule68_expand_deps 对非 ID token 原样输出，
                #   H4 只查 ID→组映射，不会把注解误判为非法 S-unit ID（审计 H3 风险规避）。
                _escort = _cell(s.get("escort_skills", "")).strip() or "无"
                _parallel = _cell(s.get("parallel", "")).strip()
                _deps = f"- [parallel-group:{_parallel}]" if _parallel else "-"
                su_rows.append([_cell(s.get("id", "")), goal, _cell(s.get("executor", "")),
                                _cell(s.get("files", "")), _cell(s.get("verify", "")),
                                _cell(s.get("duration", "")), _cell(s.get("granularity", "")),
                                _escort, _deps, "pending"])
            _pno = _phase_no(p.get("id"))
            lines += ["", f"### Phase {_pno}: {_cell(p.get('name', ''))}".rstrip(),
                      f"- **Status:** {_cell(p.get('status', 'pending'))}",
                      f"- **Started:** {_cell(p.get('started', ''))}",
                      f"- **Executor:** {executors}"]
            # [2026-11-22 task-template-json-compat-20261122] R-1：V-N 映射行（check-complete
            #   VC-GATE 按 `^- \[[ xX]\] V-<P号>.<N>\s*[:：]` 计数且校验 VC-x ∈ VC 定义集）；
            #   数据源=phases[].v_checks（JSON 已有）。无 v_checks 时不输出（门按缺映射判缺口，
            #   与旧行为一致，不开逃生口）。P 号必须与 Phase 标题一致，否则门 Skipped。
            for _vni, _vcid in enumerate(p.get("v_checks", []) or [], 1):
                lines.append(f"- [x] V-{_pno}.{_vni}: {_cell(_vcid)}（Phase {_pno} 验证契约映射）")
            if su_rows:
                lines += [_md_table(SUNIT_HEADERS, su_rows)]

    understanding = _obj(doc, "understanding")
    if understanding:
        lines += ["", "## 🧭 指令理解迭代草稿",
                  _kv_table(understanding, ("original", "model", "options", "direction"),
                            ("① 原始指令复述", "② 模型理解", "③ 思路与候选", "④ 大体执行方向"))]

    root_causes = _arr(doc, "root_causes")
    if root_causes:
        lines += ["", "## 🧮 根源覆盖表",
                  _table(["工序", "缺陷面", "修复点", "VC"],
                         [[x.get("process"), x.get("defect"), x.get("fix"), x.get("vc")]
                          for x in root_causes], _EMPTY % "根源记录")]

    invariants = _arr(doc, "invariants")
    if invariants:
        lines += ["", "## 🔒 不变量声明区",
                  _table(["三态", "条目", "来源锚"],
                         [[x.get("state"), x.get("item"), x.get("anchor")] for x in invariants],
                         _EMPTY % "不变量")]

    spec_baseline = _arr(doc, "spec_baseline")
    if spec_baseline:
        lines += ["", "## 🔒 规范基线（Spec-Baseline）",
                  _table(["spec_id", "约束原文(verbatim)", "来源锚(path:line)", "双向判定式", "来源 sha256"],
                         [[x.get("id"), x.get("verbatim"), x.get("anchor"), x.get("rule"), x.get("sha")]
                          for x in spec_baseline], _EMPTY % "规范基线")]

    progress_baseline = _arr(doc, "progress_baseline")
    if progress_baseline:
        lines += ["", "## 📦 进度产出基线",
                  _table(["基线项", "动工前快照", "关键产出/指标", "禁倒退清单", "状态"],
                         [[x.get("item"), x.get("snapshot"), x.get("metric"), x.get("ban"), x.get("status")]
                          for x in progress_baseline], _EMPTY % "进度基线")]

    scope_limits = _arr(doc, "scope_limits")
    if scope_limits:
        lines += ["", "## ⚠️ 执行范围限制",
                  _table(["类别", "允许的文件", "禁止"],
                         [[x.get("category"), x.get("allow", []), x.get("deny", [])]
                          for x in scope_limits], _EMPTY % "范围限制")]

    changes = _arr(doc, "changes")
    if changes:
        lines += ["", "## 📋 变更标注表",
                  _table(["编号", "对象（文件+锚点）", "类型", "吸收判定", "用户原话（逐字）", "依据（证据）", "执行动作"],
                         [[x.get("id"), x.get("object"), x.get("type"), x.get("absorb"),
                           x.get("quote"), x.get("basis"), x.get("action")] for x in changes],
                         _EMPTY % "变更标注")]

    knowledge = _arr(doc, "knowledge")
    if knowledge:
        lines += ["", "## 📚 必要知识储备（任务知识库对齐）",
                  _table(["类别", "名称/主题", "定位（路径/URL/版本/commit SHA）", "必读级别", "已确认"],
                         [[x.get("category"), x.get("name"), x.get("loc"), x.get("level"),
                           x.get("confirmed")] for x in knowledge], _EMPTY % "知识储备")]

    core_question = _obj(doc, "core_question")
    if core_question:
        lines += ["", "## ⚠️ 核心问题定义",
                  _kv_table(core_question, ("text", "checks", "verdict"),
                            ("核心问题", "核心问题判断", "裁决"))]

    evidence_faces = _arr(doc, "evidence_faces")
    if evidence_faces:
        lines += ["", "## 🔍 证据面清单",
                  _table(["证据面", "取证对象（可指名）", "取证方式", "落盘锚", "状态"],
                         [[x.get("face"), x.get("target"), x.get("method"), x.get("anchor"),
                           x.get("status")] for x in evidence_faces], _EMPTY % "证据面")]

    active_phase = next((p for p in phases if p.get("status") == "in_progress"), None)
    if active_phase:
        lines += ["", "## Current Phase", f"Phase {_phase_no(active_phase.get('id'))}"]
    if doc.get("next_step"):
        lines += ["", "## Next Step", _cell(doc["next_step"])]

    tool_use = _arr(doc, "tool_use")
    if tool_use:
        lines += ["", "## 🧰 工具选择与编排",
                  _table(["Phase", "命中工具面（40.1 六类）", "选择理由"],
                         [[x.get("phase"), x.get("tools"), x.get("why")] for x in tool_use],
                         _EMPTY % "工具选择")]


    anti_regress = _arr(doc, "anti_regress")
    if anti_regress:
        lines += ["", "## 🛡 防倒退终检",
                  _table(["检查项", "判定方法（机器/可复核）", "证据锚", "结果"],
                         [[x.get("item"), x.get("method"), x.get("anchor"), x.get("result")]
                          for x in anti_regress], _EMPTY % "防倒退终检")]

    isolation = _obj(doc, "isolation")
    if isolation:
        lines += ["", "## 🔀 隔离决策",
                  _kv_table(isolation, ("conflict", "path", "branch", "merge_back"),
                            ("conflict_scan", "isolation/worktree_path", "branch", "merge_back"))]

    fmea = _arr(doc, "fmea")
    if fmea:
        lines += ["", "## 📊 FMEA 预演",
                  _table(["Phase", "失败模式", "S(1-10)", "O(1-10)", "D(1-10)", "RPN=S×O×D", "预设兜底动作"],
                         [[x.get("phase"), x.get("mode"), x.get("severity"), x.get("occurrence"),
                           x.get("detection"), x.get("rpn"), x.get("fallback")] for x in fmea],
                         _EMPTY % "FMEA")]

    todo_sync = _arr(doc, "todo_sync")
    if todo_sync:
        lines += ["", "## 🔁 原生 Todo 同步",
                  _table(["Phase/触发", "Todo 已建/动作", "最近同步时间", "备注"],
                         [[x.get("trigger"), x.get("action"), "", ""] for x in todo_sync],
                         _EMPTY % "Todo 同步")]

    key_questions = _arr(doc, "key_questions")
    if key_questions:
        lines += ["", "## Key Questions"]
        lines += _bullets([f"{x.get('question', '')} — {x.get('answer', '')}" for x in key_questions],
                          _EMPTY % "关键问题")

    decisions = _arr(doc, "decisions")
    if decisions:
        lines += ["", "## Decisions Made",
                  _table(["Decision", "Rationale"],
                         [[x.get("decision"), x.get("rationale")] for x in decisions],
                         _EMPTY % "决策记录")]

    errors = _arr(doc, "errors")
    if errors:
        lines += ["", "## Errors Encountered",
                  _table(["Error", "Attempt", "Resolution", "Prevention（Rule 31 指针）"],
                         [[x.get("error"), x.get("attempt"), x.get("resolution"), x.get("prevention")]
                          for x in errors], _EMPTY % "错误记录")]

    batch = _obj(doc, "batch")
    if batch:
        lines += ["", "## 📦 Batch Report",
                  _kv_table(batch, ("total", "success", "failed", "rate", "sampled_pass",
                                    "sampled_fail", "pre_check", "rollback"),
                            ("total", "success", "failed", "failure_rate", "sampled_pass",
                             "sampled_fail", "pre_check", "rollback_point"))]

    delegation_stats = _obj(doc, "delegation_stats")
    if delegation_stats:
        lines += ["", "## 📊 委派统计",
                  _kv_table(delegation_stats, ("total", "subagent", "parallel_width", "verified"),
                            ("总单元数", "子代理执行数", "最大并行宽度", "复验通过数"))]

    chain = _obj(doc, "chain")
    if chain:
        lines += ["", "## 🔗 Chain 区块交接配置",
                  _kv_table(chain, ("mode", "blocks", "handoffs"), ("chain_mode", "blocks", "handoffs"))]

    # [2026-11-22 task-template-json-compat-20261122] 领域段 JSON 承载：init 把所选 variant
    #   模板正文原文写入 template_body，render 以附录吐出，弥补全量覆盖抹掉领域段（video 任务分型/
    #   子代理隔离铁律等）。标题降级 `^(#+ )`→`> \1`：附录内标题不以 `^## ` 开头，避免与权威
    #   51.1/66.5 锚竞争导致误判；内容原样保留，仅加引用前缀。mini 档豁免（极简 stub 无领域段）。
    if doc.get("template_body") and doc.get("plan_tier") != "mini":
        _tb_lines = []
        for _ln in str(doc["template_body"]).splitlines():
            _tb_lines.append(re.sub(r"^(#+ )", r"> \1", _ln) if re.match(r"^#+ ", _ln) else _ln)
        lines += ["", "## 📎 领域模板原文附录（仅供参考；权威判据以 JSON 结构化段+机器门为准）",
                  *(_tb_lines or ["（template_body 为空）"])]

    return "\n".join(lines) + "\n"


def _render_progress(doc: dict[str, Any], tid: str, stamp: str) -> str:
    """重建 progress.md：保留 Phase 状态/审计/Delegations 表，补逐 Phase 明细与全部日志段。

    What: Phase 段含 Status/Started/Actions/Files/Test Results；另含 Goals 证据行、Error Log、
          知识储备使用记录、5Q、resume 检查点表。
    Why: check-3file-gate.sh 解析 `### Phase N:` + `**Started:**`（mtime 锚），check-evidence-anchor
         解析 `[goal:G<n>]` 整行，check-context-hygiene 统计 Phase 段行数——锚格式必须逐字保留。
    """
    phases = _arr(doc, "phases")
    lines: list[str] = [
        GENERATED_HEADER, f"# Progress: {tid}", "", stamp.rstrip(), "",
        "## Phase 状态",
        _md_table(["id", "status", "tags"],
                  [[p.get("id"), p.get("status"), p.get("tags", [])] for p in phases]),
        "", "## Goals（证据锚）",
    ]
    goal_lines = [f"[goal:{g.get('id')}] {_cell(g.get('evidence', ''))}"
                  for g in _arr(doc, "goals") if g.get("evidence")]
    # [2026-11-22 task-jsonderive-deploy-20261122] What: 仅 evidence 非空的 goal 输出证据行。
    # Why: check-evidence-anchor.sh:300 按 `[goal:G<digits>]` 取整行；无 evidence 的 goal 不应产生空锚。
    lines += _bullets(goal_lines, _EMPTY % "goal 证据记录")
    lines += [
        "", "## 审计轮次",
        _md_table(["round", "verdict", "by", "C", "I", "W", "at", "tags"],
                  [[a.get("round"), a.get("verdict"), a.get("by"),
                    a.get("counts", {}).get("C"), a.get("counts", {}).get("I"),
                    a.get("counts", {}).get("W"), a.get("at"), a.get("tags", [])]
                   for a in _arr(doc, "audits")]),
        "", "## Delegations（派发登记）",
        _md_table(["id", "agent", "scope", "status", "tags"],
                  [[d.get("id"), d.get("agent"), d.get("scope"), d.get("status"), d.get("tags", [])]
                   for d in _arr(doc, "delegations")]),
        "", "## Phase 执行明细",
    ]
    for p in phases:
        pid = p.get("id")
        lines += [f"### Phase {_phase_no(pid)}: {_cell(p.get('name', ''))}".rstrip(),
                  f"- **Status:** {_cell(p.get('status', 'pending'))}",
                  f"- **Started:** {_cell(p.get('started', ''))}",
                  "- Actions taken:"]
        actions = [_cell(a.get("text", "")) for a in _arr(doc, "actions")
                   if _phase_match(a.get("phase", ""), pid)]
        lines += _bullets(actions, _EMPTY % "动作记录", indent="  ")
        lines += ["- Files created/modified:"]
        files = [f"{_cell(f.get('path', ''))} — {_cell(f.get('change', ''))}".strip(" —")
                 for f in _arr(doc, "files") if _phase_match(f.get("phase", ""), pid)]
        lines += _bullets(files, _EMPTY % "文件记录", indent="  ")
        lines += ["- Test Results:"]
        tests = [t for t in _arr(doc, "test_results") if _phase_match(t.get("phase", ""), pid)]
        lines += [_table(["Test", "Input", "Expected", "Actual", "Status"],
                         [[t.get("test"), t.get("input"), t.get("expected"), t.get("actual"),
                           t.get("status")] for t in tests], _EMPTY % "测试结果"), ""]

    resume = _obj(doc, "resume_report")
    resume_rows = [[resume.get("path"), resume.get("last")]] if resume else []
    lines += [
        "## 📚 必要知识储备使用记录",
        _table(["Phase", "引用知识源", "用途(决策/实现/验证)"],
               [[k.get("phase"), k.get("source"), k.get("purpose")]
                for k in _arr(doc, "knowledge_use")], _EMPTY % "知识使用记录"),
        "", "## Error Log",
        # [2026-11-22 task-jsonderive-deploy-20261122] 7 列锁序与 templates/progress.md 对齐：
        # check-complete.sh 按表头名 "Root Cause" 动态定位列号，表尾「触发命令/工具」增量增列不改列序。
        _table(["Timestamp", "Error", "Attempt", "Resolution", "Root Cause", "Prevention", "触发命令/工具"],
               [[e.get("timestamp"), e.get("error"), e.get("attempt"), e.get("resolution"),
                 e.get("root_cause"), e.get("prevention"), e.get("trigger")]
                for e in _arr(doc, "errors")], _EMPTY % "错误记录"),
        "", "## 5-Question Reboot Check",
        _table(["Question", "Answer"],
               [[q.get("question"), q.get("answer")] for q in _arr(doc, "reboot5q")],
               _EMPTY % "5Q 记录"),
        "", "---", "## plan-resume 报告检查点",
        _table(["plan-resume 报告路径", "上次更新"], resume_rows, _EMPTY % "plan-resume 检查点"),
    ]
    return "\n".join(lines) + "\n"


def _render_findings(doc: dict[str, Any], tid: str, stamp: str,
                     idx: dict[str, list[str]]) -> str:
    """重建 findings.md：保留 Findings 表 + tag 倒排，补 Requirements/知识对齐/Research 等段。

    What: Research Findings 由 research[] 与 findings[] 合并展示（各自带 source）。
    Why: 模板锚 `## Research Findings` / `## Technical Decisions` / `## Issues Encountered` 是子代理
          回填与终验引用面；空段用显式占位，避免 stub 判定且禁止推测填充（Rule 71）。
    """
    local_refs = sorted({ref for refs in idx.values() for ref in refs if ref.startswith(tid + "#")})
    lines: list[str] = [
        GENERATED_HEADER, f"# Findings: {tid}", "", stamp.rstrip(), "",
        "## Requirements",
    ]
    lines += _bullets([_cell(r.get("text", "")) for r in _arr(doc, "requirements")],
                      _EMPTY % "需求记录")
    lines += [
        "", "## Findings",
        _md_table(["id", "text", "source", "tags"],
                  [[f.get("id"), f.get("text"), f.get("source"), f.get("tags", [])]
                   for f in _arr(doc, "findings")]),
        "", "## 📚 必要知识储备对齐记录（Knowledge Base Alignment）",
        _table(["知识源", "定位(路径/URL)", "是否已消费", "结论落点(本文件段落)"],
               [[k.get("name"), k.get("loc"), k.get("consumed"), k.get("landing")]
                for k in _arr(doc, "knowledge")], _EMPTY % "知识对齐记录"),
        "", "## Research Findings",
    ]
    research_lines = [f"{_cell(x.get('claim', ''))} — {_cell(x.get('source', ''))}".rstrip(" —")
                      for x in _arr(doc, "research")]
    research_lines += [f"{_cell(x.get('text', ''))} — {_cell(x.get('source', ''))}".rstrip(" —")
                       for x in _arr(doc, "findings")]
    lines += _bullets(research_lines, _EMPTY % "调研发现")
    lines += [
        "", "## Technical Decisions",
        _table(["Decision", "Rationale"],
               [[d.get("decision"), d.get("rationale")] for d in _arr(doc, "decisions")],
               _EMPTY % "技术决策"),
        "", "## Issues Encountered",
        _table(["Issue", "Resolution"],
               [[i.get("issue"), i.get("resolution")] for i in _arr(doc, "issues")],
               _EMPTY % "问题记录"),
        "", "## Resources",
    ]
    lines += _bullets([_cell(r.get("locator", "")) for r in _arr(doc, "resources")],
                      _EMPTY % "资源引用")
    lines += ["", "## Visual/Browser Findings"]
    lines += _bullets([f"{_cell(v.get('finding', ''))} — {_cell(v.get('source', ''))}".rstrip(" —")
                       for v in _arr(doc, "visual")],
                      _EMPTY % "多模态发现——未产生截图/PDF/网页证据")
    lines += ["", "---", "## 本任务 tag 倒排引用",
              "\n".join(f"- {ref}" for ref in local_refs) or f"- {_EMPTY % 'tag 引用'}", ""]
    return "\n".join(lines)


def _render_verification(doc: dict[str, Any], tid: str, stamp: str) -> str:
    """重建 verification.md：保留 VC 表，补 Goal/Phase Gates/知识符合/质量门控/Goal Gate/交叉验证/5Q。

    What: 对象段（goal_verdict/quality_gates/outcome）为空时不输出对应明细，仅给显式占位。
    Why: 「终验全派生」要求这些判定面可机读；模板锚 `## Goal Gate` / `## Phase Gates` /
          `## 5-Question Reboot Check` 必须逐字保留，供终验脚本与人工恢复消费。
    """
    lines: list[str] = [
        GENERATED_HEADER, f"# Verification: {tid}", "", stamp.rstrip(), "",
        "## Goal (1 sentence)",
    ]
    lines += _bullets([_cell(g.get("text", "")) for g in _arr(doc, "goals")], _EMPTY % "Goal 语句")
    verdict = _obj(doc, "goal_verdict")
    if verdict:
        lines += ["", _kv_table(verdict, ("goal", "verdict", "evidence", "unresolved", "excluded", "next"))]
    lines += [
        "", "---", "## Verification Contract（VC 状态与判据）",
        _md_table(["id", "status", "criterion", "command", "evidence", "tags"],
                  [[v.get("id"), v.get("status"), v.get("criterion"), v.get("command"),
                    v.get("evidence"), v.get("tags", [])] for v in _arr(doc, "vcs")]),
        "", "## Phase Gates",
        _table(["Goal", "Depends on", "Done when", "Checks", "Status"],
               [[pg.get("goal"), pg.get("depends", []), pg.get("done_when"),
                 pg.get("checks", []), pg.get("status")] for pg in _arr(doc, "phase_gates")],
               _EMPTY % "Phase Gates 记录"),
        "", "## 📚 必要知识储备符合性核验（终验项）",
        _table(["必读知识源", "核验方式(交付物对照点)", "结论(符合/偏离+说明)"],
               [[kc.get("item"), "-", kc.get("status")] for kc in _arr(doc, "knowledge_compliance")],
               _EMPTY % "知识符合性记录"),
    ]
    quality = _obj(doc, "quality_gates")
    lines += ["", "## 委派统计复验（Rule 25.4）"]
    lines += _bullets([f"**机器统计复验:** {_cell(quality['delegation_reverify'])}"]
                      if quality.get("delegation_reverify") else [], _EMPTY % "委派复验记录")
    lines += ["", "## 质量门控统计（Rule 26）"]
    lines += _bullets([f"**质量门控:** {_cell(quality['quality_control'])}"]
                      if quality.get("quality_control") else [], _EMPTY % "质量门控记录")
    outcome = _obj(doc, "outcome")
    lines += ["", "## Goal Gate (终验，所有 phase complete 后执行)"]
    if outcome:
        lines += [f"outcome: {_cell(outcome.get('result', ''))}"]
        if outcome.get("blocked_reason"):
            lines += [f"blocked_reason: {_cell(outcome['blocked_reason'])}"]
    else:
        lines += [f"- {_EMPTY % 'Goal Gate 记录'}"]
    lines += [
        "", "---", "## 交叉验证记录（Rule 108）",
        _table(["验证对象", "机械面路径（命令+结果）", "语义面路径（复检体+结论）", "判定（一致/分歧→108.4 处置）"],
               [[cc.get("item"), cc.get("method"), cc.get("result"), "-"]
                for cc in _arr(doc, "cross_checks")], _EMPTY % "交叉验证记录"),
        "", "## 5-Question Reboot Check",
        _table(["#", "Question", "Answer (fill on resume)"],
               [[i, q.get("question"), q.get("answer")]
                for i, q in enumerate(_arr(doc, "reboot5q"), 1)], _EMPTY % "5Q 记录"),
    ]
    return "\n".join(lines) + "\n"


def cmd_render(args: argparse.Namespace) -> int:
    """从权威源生成 4 个 MD 视图（保留既有文件名以兼容 hook），全部原子写。

    [2026-11-22 task-jsonderive-deploy-20261122] What: 4 视图全量重建模板语义段（原仅 4 张简表）。
    Why: 视图只读派生，Agent/人不得直接编辑；每次 render 全量覆盖，杜绝 JSON 与 MD 漂移，
         同时让 evidence-anchor / 3file-gate / context-hygiene / plan-dispatch 等机器门可消费稳定锚。
    """
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    try:
        idx = read_tag_index(plan)
    except PlanctlError:
        idx = {}  # 索引损坏不影响视图生成（状态文件仍是权威源），但不吞掉写入错误
    tid = doc["task_id"]
    stamp = f"- task_id: `{tid}`\n- 时间: created_at={doc['created_at']} / updated_at={doc['updated_at']}\n"
    # [2026-11-22 task-jsonderive-deploy-20261122 C-2 修复] What: meta 行改行首裸格式（无反引号）。
    # Why: check-3file-gate/check-complete/check-plan-dispatch/check-tier-consistency 等门以
    #       `plan_tier: mini`/`execution_lane: L0` 裸子串或行首锚 grep；反引号包裹使匹配全部落空
    #       → L0/mini 门控静默失效（CR-1 C-2）。原行为=反引号列表行，删除。
    _tt = doc.get("template_type")
    meta_lines = [f"plan_tier: {doc['plan_tier']}",
                  f"execution_lane: {doc['execution_lane']}",
                  "schema_version: " + str(doc["schema_version"])]
    if _tt:
        meta_lines.insert(0, f"template_type: {_tt}")
    meta = "\n".join(meta_lines) + "\n"
    top_tags = ", ".join(doc["tags"]) or "（无）"

    views: dict[str, str] = {
        "task_plan.md": _render_task_plan(doc, tid, stamp, meta, top_tags, idx),
        "progress.md": _render_progress(doc, tid, stamp),
        "verification.md": _render_verification(doc, tid, stamp),
        "findings.md": _render_findings(doc, tid, stamp, idx),
    }

    written = []
    for name in VIEW_NAMES:
        atomic_write(plan / name, views[name])
        written.append(str(plan / name))
    emit({"rendered": written, "updated_at": doc["updated_at"]})
    return 0


def cmd_backup(args: argparse.Namespace) -> int:
    """手动备份当前权威源（不改变状态内容）。"""
    plan = check_plan_dir(args.plan_dir)
    read_state(plan)  # 确认源可读
    bak = backup_state(plan)
    if bak is None:
        raise PlanctlError("无 plan-state.json 可备份")
    emit({"backup": str(bak), "history_count": len(list_backups(plan))})
    return 0


def cmd_restore(args: argparse.Namespace) -> int:
    """从 .history 恢复；--version N 为 history 的 1-based 序号（默认 1=最近一次）。"""
    plan = check_plan_dir(args.plan_dir)
    backups = list_backups(plan)
    if not backups:
        raise PlanctlError(".history/ 无可用备份")
    version = args.version if args.version is not None else 1
    if version < 1 or version > len(backups):
        raise PlanctlError(f"--version {version} 越界（可用 1..{len(backups)}）")
    chosen = backups[version - 1]
    payload = chosen.read_bytes()
    try:
        restored = json.loads(payload.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise PlanctlError(f"备份文件非法 JSON，拒绝恢复: {chosen}: {exc}") from exc
    errors = validate_state(restored)
    if errors:
        raise PlanctlError("备份内容校验失败，拒绝恢复: " + " | ".join(errors[:6]))
    # 恢复自身也可回滚：先把当前（可能已损坏的）状态做一次备份，再原子替换。
    backup_state(plan)
    atomic_write(state_path(plan), payload)
    emit({"restored_from": str(chosen), "task_id": restored.get("task_id")})
    return 0


def cmd_history(args: argparse.Namespace) -> int:
    """列出可用备份版本（newest first，index 供 restore --version 使用）。"""
    plan = check_plan_dir(args.plan_dir)
    versions = []
    for i, p in enumerate(list_backups(plan), start=1):
        st = p.stat()
        versions.append({"index": i, "file": p.name, "path": str(p),
                         "size": st.st_size,
                         "mtime": dt.datetime.fromtimestamp(st.st_mtime, dt.timezone.utc)
                         .isoformat(timespec="seconds")})
    emit({"count": len(versions), "versions": versions})
    return 0


# ─────────────────────────────────────────────────────────────────────────────
# 机器门 check
# ─────────────────────────────────────────────────────────────────────────────

VACUOUS_HEADS = {"true", ":", "echo", "printf", "cat", "ok", "0"}
ISO_IN_FILE_RE = re.compile(r"\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}")


def is_vacuous_command(command: str) -> bool:
    """静态判 VC 命令是否真空，移植 check-vc-nonvacuous.sh 的字面集口径（读 JSON 而非正则扫 MD）。

    WHY：管道尾段决定退出码（`echo x | grep -q y f` 有判定力），语句边界 ;/& 逐句独立；
    剥变量赋值与 env 前缀后取 head 的 basename。任一语句尾段有真实命令 → 整链非真空。
    不可判定形态（wrapper/命令替换）一律放行 fail-open，避免误伤合法命令。
    """
    cmd = command.replace("`", "").strip()
    if not cmd:
        return True
    for statement in re.split(r"[;&]", cmd):
        statement = statement.strip()
        if not statement:
            continue
        segments = statement.split("|")
        last = segments[-1].strip()
        if not last:
            continue
        words = last.split()
        i = 0
        while i < len(words) and "=" in words[i] and not words[i].startswith("="):
            i += 1
        if i == len(words):
            continue  # 纯赋值段
        head = words[i].rsplit("/", 1)[-1]
        if head == "env":
            i += 1
            while i < len(words) and "=" in words[i] and not words[i].startswith("="):
                i += 1
            if i == len(words):
                continue
            head = words[i].rsplit("/", 1)[-1]
        if head == "cat":
            # cat 仅当无参数或全部参数为 /dev/null 时真空
            if all(w == "/dev/null" for w in words[i + 1:]):
                continue
            return False
        if head not in VACUOUS_HEADS:
            return False  # grep/test/diff 等真实判定命令
    return True


def check_vc_nonvacuous(doc: dict[str, Any], plan_dir: Path) -> tuple[bool, str]:
    """vc-nonvacuous：所有 vcs[].command 均须有静态判定力。"""
    vcs = doc["vcs"]
    if not vcs:
        return True, "无 vcs 条目（SKIP 无判定面）"
    bad = [v.get("id", "?") for v in vcs if is_vacuous_command(str(v.get("command", "")))]
    if bad:
        return False, f"{len(bad)}/{len(vcs)} 条 VC 命令真空: {', '.join(map(str, bad))}"
    return True, f"{len(vcs)} 条 VC 命令均有判定力"


def check_rvc(doc: dict[str, Any], plan_dir: Path) -> tuple[bool, str]:
    """rvc：每条 R 至少 1 个 VC，每个 VC 被某 R.vc 或某 phase.v_checks 引用。"""
    vcs = doc["vcs"]
    reqs = doc["requirements"]
    if not reqs and not vcs:
        return True, "无 requirements/vcs 条目（SKIP 无判定面）"
    vids = {str(v.get("id")) for v in vcs}
    problems: list[str] = []
    referenced: set[str] = set()
    for r in reqs:
        refs = [str(x) for x in r.get("vc", [])]
        if not refs:
            problems.append(f"{r.get('id')} 无 VC 映射")
        for ref in refs:
            if ref not in vids:
                problems.append(f"{r.get('id')} 引用不存在的 VC: {ref}")
            else:
                referenced.add(ref)
    for p in doc["phases"]:
        for ref in p.get("v_checks", []):
            if str(ref) in vids:
                referenced.add(str(ref))
    for vid in sorted(vids - referenced):
        problems.append(f"VC:{vid} 无 R/phase 引用")
    if problems:
        return False, f"覆盖缺口 {len(problems)} 项: " + "; ".join(problems[:8])
    return True, f"R={len(reqs)} VC={len(vcs)} 双向覆盖完整"


def check_audit(doc: dict[str, Any], plan_dir: Path) -> tuple[bool, str]:
    """audit：先做无进展止损（最近 3 个连续 REJECTED 轮 key 集不变→FAIL 并上报），再判末段形态。

    [2026-11-21 task-audit-rework-cap-20261121] 原行为=仅校验末轮 APPROVED 且 0C/0I；
    新增 no_progress 判定置于其后、原末段判定之前，且末轮 APPROVED 一律跳过（收敛不误伤）。
    """
    audits = doc["audits"]
    if not audits:
        return False, "无 audit 记录（末轮审计缺失）"
    no_progress, details = audit_no_progress(audits)
    if no_progress:
        return (False, "NO_PROGRESS_STREAK_3 ESCALATE_USER_DECISION_REQUIRED "
                       f"<details: {details}>（连续 3 轮 REJECTED 开放 C/I key 集完全相同，"
                       "禁止继续自动派发同类修复，改走 decision-arbiter/AskUser 上报）")
    last = max(audits, key=lambda a: a.get("round", 0))
    rnd = last.get("round")
    if last.get("verdict") != "APPROVED":
        return False, f"末轮 R{rnd} verdict={last.get('verdict')}（须 APPROVED）"
    counts = last.get("counts", {})
    c, i = counts.get("C"), counts.get("I")
    if c != 0 or i != 0:
        return False, f"末轮 R{rnd} counts C={c} I={i}（须 0C/0I）"
    return True, f"末轮 R{rnd} APPROVED 0C/0I"


def check_evidence(doc: dict[str, Any], plan_dir: Path) -> tuple[bool, str]:
    """evidence：evidence 路径存在且文件头含 VC 编号 + ISO8601；空 evidence 记 SKIP 不计 FAIL。"""
    problems: list[str] = []
    checked = skipped = 0
    for v in doc["vcs"]:
        evidence = str(v.get("evidence", "")).strip()
        if not evidence:
            skipped += 1
            continue
        checked += 1
        vc_id = str(v.get("id", ""))
        path = Path(evidence)
        if not path.is_absolute():
            path = plan_dir / path
        if not path.is_file():
            problems.append(f"{vc_id} evidence 文件不存在: {path}")
            continue
        try:
            head = path.read_text(encoding="utf-8", errors="replace")[:4096]
        except OSError as exc:
            problems.append(f"{vc_id} evidence 不可读: {exc}")
            continue
        if vc_id and vc_id not in head:
            problems.append(f"{vc_id} evidence 文件头缺 VC 编号")
        if not ISO_IN_FILE_RE.search(head):
            problems.append(f"{vc_id} evidence 文件头缺 ISO8601 时间戳")
    if problems:
        return False, f"证据缺口 {len(problems)} 项: " + "; ".join(problems[:8])
    return True, f"{checked} 条证据合格 / {skipped} 条空证据 SKIP"


CHECKS: dict[str, Callable[[dict[str, Any], Path], tuple[bool, str]]] = {
    "vc-nonvacuous": check_vc_nonvacuous,
    "rvc": check_rvc,
    "audit": check_audit,
    "evidence": check_evidence,
}


def cmd_check(args: argparse.Namespace) -> int:
    """机器门统一入口：stdout 单行 PLANCTL CHECK <name>: PASS|FAIL <reason>。"""
    name = args.name
    try:
        plan = check_plan_dir(args.plan_dir)
        doc = read_state(plan)
        require_valid(doc)
    except PlanctlError as exc:
        print(f"PLANCTL CHECK {name}: FAIL 输入异常: {exc}")
        print(f"planctl: {exc}", file=sys.stderr)
        return 2
    ok, reason = CHECKS[name](doc, plan)
    print(f"PLANCTL CHECK {name}: {'PASS' if ok else 'FAIL'} {reason}")
    return 0 if ok else 1


# ─────────────────────────────────────────────────────────────────────────────
# CLI
# ─────────────────────────────────────────────────────────────────────────────

def build_parser() -> argparse.ArgumentParser:
    """构造 argparse；所有子命令均要求 --plan-dir，check 额外要求 name 位置参数。"""
    parser = argparse.ArgumentParser(
        prog="planctl.py",
        description="task-planner 结构化状态工具：JSON 权威源 CRUD / MD 视图 / 倒排标签 / 机器门",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        # [2026-11-22 S3] 补 help 可照抄示例以减少试错：epilog 扩为多行原文块，
        # 内容复用模块 docstring 已有的输出/写入安全/退出码事实，不引入任何运行时行为。
        epilog="""示例（可照抄；先把 <计划目录> 换成含 plan-state.json 的真实目录，按顺序执行）：
  python3 planctl.py init      --plan-dir <计划目录> --task-id TASK-001 --tier standard --lane L0
  python3 planctl.py add       --plan-dir <计划目录> --section requirements --json '{\"id\":\"R1\",\"text\":\"需求原文\",\"type\":\"手段\"}'
  python3 planctl.py set       --plan-dir <计划目录> --section requirements --id R1 --field text --value '需求原文'
  python3 planctl.py set       --plan-dir <计划目录> --field next_step --value '下一步动作'
  python3 planctl.py check     --plan-dir <计划目录> vc-nonvacuous
  python3 planctl.py render    --plan-dir <计划目录>
  python3 planctl.py audit-add --plan-dir <计划目录> --round 1 --verdict APPROVED --by reviewer --c 3 --i 0 --w 0

输出约定：管理命令=JSON stdout；check=单行 PLANCTL CHECK <name>: PASS|FAIL <reason>；错误=stderr。
写入安全：写操作先校验新文档→旧版备份到 <计划目录>/.history/（保留最近 20 版）→临时文件+fsync+os.replace 原子替换→回读校验，失败回滚。
退出码：0=成功、非0=失败；业务/IO/JSON 错误 stderr + rc 1；check 自报 0=PASS / 1=FAIL / 2=输入异常；validate 0=通过 / 1=失败。
各子命令专属可照抄示例见 python3 planctl.py <子命令> --help 的『示例』段。""",
    )
    sub = parser.add_subparsers(dest="command", required=True, title="subcommands")

    def add_cmd(name: str, help_text: str, handler: Callable[..., int]) -> argparse.ArgumentParser:
        # [2026-11-22 S3] 补 help 示例减少试错：透传 RawDescriptionHelpFormatter 保留
        # epilog 中的多行原文块；只改 parser 构造参数，参数定义与 handler 绑定保持原样。
        p = sub.add_parser(
            name, help=help_text,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog=("示例（通用调用格式；把 <计划目录> 换成含 plan-state.json 的真实目录，"
                    "必填参数见上方 options，专属可照抄示例见该命令 --help 的『示例』段）：\n"
                    f"  python3 planctl.py {name} --plan-dir <计划目录> [必填参数]"),
        )
        p.add_argument("--plan-dir", required=True, help="计划目录（含 plan-state.json）")
        p.set_defaults(handler=handler)
        return p

    p = add_cmd("init", "从模板生成 plan-state.json（原子写）", cmd_init)
    # [2026-11-22 S3] 补 help 示例减少试错（仅文案，不改参数定义）。
    p.epilog = (
        "示例（可照抄，先把 <计划目录> 换成真实目录）：\n"
        "  python3 planctl.py init --plan-dir <计划目录> --task-id TASK-001 --tier standard --lane L0\n"
        "  python3 planctl.py init --plan-dir <计划目录> --task-id TASK-001 --force"
    )
    p.add_argument("--task-id", required=True)
    p.add_argument("--tier", choices=("standard", "mini"))
    p.add_argument("--lane", choices=("L0", "L0-T", "L0-E", "L1", "L2"))
    p.add_argument("--force", action="store_true", help="允许覆盖已有状态（谨慎）")
    p.add_argument("--template-body-from", metavar="FILE",
                   help="可选：读取该文件全文写入 template_body（init 所选 variant 模板正文，供 render 领域附录消费）")

    p = add_cmd("get", "输出整份/某段/某条目 JSON", cmd_get)
    # [2026-11-22 task-jsonderive-deploy-20261122] choices 扩到顶层全集，使新对象/标量字段可读。
    p.add_argument("--section", choices=("tags", *TOP_LEVEL_KEYS))
    p.add_argument("--id")

    # [2026-11-25 task-planctl-recover] 压缩恢复专用命令：核心数据获取能力收口到 planctl；
    #   升级「恢复时能拿到什么」只改 cmd_recover 一处，hook 与 selftest 不再各自引用旁路实现。
    p = add_cmd("recover", "压缩恢复：从权威源读核心字段产出注入包（参数指定字段集）", cmd_recover)
    p.epilog = (
        "示例（可照抄）：\n"
        "  python3 planctl.py recover --plan-dir <计划目录>\n"
        "  python3 planctl.py recover --plan-dir <计划目录> --fields requirements,goal,mustkeep\n"
        "  python3 planctl.py recover --plan-dir <计划目录> --fields core_files,requirements --max-lines 80"
    )
    p.add_argument("--fields", help="逗号分隔核心字段（默认 core_files,skill_contract,requirements,goal,phase,next_step,decisions,mustkeep,git_baseline）")
    p.add_argument("--max-lines", type=int, default=80, help="注入行数上限（默认 80；落盘全文不受限）")

    add_cmd("status", "输出 Phase/VC/审计状态摘要 JSON", cmd_status)
    add_cmd("validate", "schema 校验（rc 0 通过 / 1 失败）", cmd_validate)

    p = add_cmd("set", "修改条目字段或顶层字段", cmd_set)
    # [2026-11-22 S3] 补 help 示例减少试错（仅文案，不改参数定义）。
    p.epilog = (
        "示例（可照抄，先把 <计划目录> 换成真实目录）：\n"
        "  python3 planctl.py set --plan-dir <计划目录> --section requirements --id R1 --field text --value '需求原文'\n"
        "  python3 planctl.py set --plan-dir <计划目录> --field next_step --value '下一步动作'"
    )
    # [2026-11-22 task-jsonderive-deploy-20261122] 原行为 --section/--id required；现改为可选，
    # 省略即写顶层字段，条目写入仍须成对提供（cmd_set 内显式校验，不放宽成静默 no-op）。
    p.add_argument("--section", choices=ARRAY_SECTIONS, help="条目段；省略则写顶层 --field")
    p.add_argument("--id", help="条目 id；写顶层字段时不得传")
    p.add_argument("--field", required=True)
    p.add_argument("--value", required=True)

    p = add_cmd("add", "新增条目", cmd_add)
    # [2026-11-22 S3] 补 help 示例减少试错（仅文案，不改参数定义）。
    p.epilog = (
        "示例（可照抄，先把 <计划目录> 换成真实目录）：\n"
        "  python3 planctl.py add --plan-dir <计划目录> --section requirements --json '{\"id\":\"R1\",\"text\":\"需求原文\",\"type\":\"手段\"}'\n"
        "  python3 planctl.py add --plan-dir <计划目录> --section vcs --json '{\"id\":\"VC1\",\"criterion\":\"判据\",\"command\":\"验证命令\"}'"
    )
    p.add_argument("--section", required=True, choices=ARRAY_SECTIONS)
    p.add_argument("--json", required=True, help="条目 JSON 对象字符串")

    p = add_cmd("update", "整条目替换", cmd_update)
    p.add_argument("--section", required=True, choices=ARRAY_SECTIONS)
    p.add_argument("--id", required=True)
    p.add_argument("--json", required=True)

    p = add_cmd("delete", "删除条目", cmd_delete)
    p.add_argument("--section", required=True, choices=ARRAY_SECTIONS)
    p.add_argument("--id", required=True)

    p = add_cmd("phase-done", "Phase → complete", cmd_phase_done)
    p.add_argument("--id", required=True)

    # [2026-11-22 task-jsonderive-deploy-20261122] What: 新增 phase-start 子命令; Why: 为 3file-gate 的 Started 锚点提供可写入口（status=in_progress + started=now）。
    p = add_cmd("phase-start", "Phase → in_progress 并记 started=now", cmd_phase_start)
    p.add_argument("--id", required=True)

    for name, help_text, handler in (("vc-pass", "VC → pass", cmd_vc_pass),
                                     ("vc-fail", "VC → fail", cmd_vc_fail)):
        p = add_cmd(name, help_text, handler)
        p.add_argument("--id", required=True)

    p = add_cmd("audit-add", "追加审计轮次", cmd_audit_add)
    # [2026-11-22 S3] 补 help 示例减少试错（仅文案，不改参数定义）。
    p.epilog = (
        "示例（可照抄，先把 <计划目录> 换成真实目录）：\n"
        "  python3 planctl.py audit-add --plan-dir <计划目录> --round 1 --verdict APPROVED --by reviewer --c 3 --i 0 --w 0\n"
        "  python3 planctl.py audit-add --plan-dir <计划目录> --round 2 --verdict REJECTED --by reviewer --issues-json '[{\"key\":\"C-1\",\"severity\":\"C\",\"state\":\"open\"}]'"
    )
    p.add_argument("--round", type=int, required=True)
    p.add_argument("--verdict", choices=("APPROVED", "REJECTED"), required=True)
    p.add_argument("--by", required=True)
    p.add_argument("--c", type=int, default=0)
    p.add_argument("--i", type=int, default=0)
    p.add_argument("--w", type=int, default=0)
    p.add_argument("--issues-json", dest="issues_json",
                   help="可选：issue JSON 数组（每项含 key/severity/state，title 可选）；无进展判定信号源")

    p = add_cmd("tag-add", "打标签并更新倒排索引", cmd_tag_add)
    p.add_argument("--section", required=True, choices=ARRAY_SECTIONS)
    p.add_argument("--id", required=True)
    p.add_argument("--tag", required=True)

    p = add_cmd("tag-search", "按 tag 从倒排索引 O(1) 检索", cmd_tag_search)
    p.add_argument("--tag", required=True)

    # [2026-11-22 S3] 补 help 示例减少试错（仅文案，不改参数定义）。
    p = add_cmd("render", "生成 4 个 MD 派生视图", cmd_render)
    p.epilog = (
        "示例（可照抄，先把 <计划目录> 换成真实目录）：\n"
        "  python3 planctl.py render --plan-dir <计划目录>\n"
        "产出 4 个 MD 派生视图：task_plan.md / progress.md / verification.md / findings.md。"
    )
    add_cmd("backup", "手动备份权威源", cmd_backup)

    p = add_cmd("restore", "从 .history 恢复（默认最近一次）", cmd_restore)
    p.add_argument("--version", type=int, help="history 中的 1-based 序号")

    add_cmd("history", "列出可用备份版本", cmd_history)

    p = add_cmd("check", "机器门判定（stdout 单行 PLANCTL CHECK）", cmd_check)
    # [2026-11-22 S3] 补 help 示例减少试错（仅文案，不改参数定义）。
    p.epilog = (
        "示例（可照抄，先把 <计划目录> 换成真实目录）：\n"
        "  python3 planctl.py check --plan-dir <计划目录> vc-nonvacuous\n"
        "  python3 planctl.py check --plan-dir <计划目录> audit\n"
        "输出：stdout 单行 PLANCTL CHECK <name>: PASS|FAIL <reason>；rc 0=PASS / 1=FAIL / 2=输入异常。"
    )
    p.add_argument("name", choices=tuple(CHECKS), help="检查项")
    return parser


def main(argv: list[str] | None = None) -> int:
    """统一异常出口：业务/IO/JSON 错误一律 stderr + rc 1，check 自报 rc 2。"""
    args = build_parser().parse_args(argv)
    try:
        return int(args.handler(args))
    except PlanctlError as exc:
        print(f"planctl: {exc}", file=sys.stderr)
        return 1
    except (OSError, ValueError, TypeError) as exc:
        print(f"planctl: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
