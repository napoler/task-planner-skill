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
import contextlib
import copy
import datetime as dt
import fnmatch
import hashlib
import io
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
# [2026-11-25 task-json-template P1] 仓库根（scripts → task-planner → skills → repo），用于 template_ref 相对化。
REPO_ROOT = SCRIPT_DIR.parents[2]

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
    # [2026-11-25 task-json-template P1] What: template_checks 纳入通用数组段（set/get/update/delete/tag-add 自动可用）。
    # Why: 勾选需唯一权威入口，复用现有 CRUD 引擎而非另造编辑面；template_doc/template_ref 是顶层对象/字符串。
    "template_checks",
    # [2026-11-25 task-output-example-contract] What: Rule 113 输出示例契约段（完整示例+可复用模板的结构化承载位）。
    # Why: 原计划只有 criterion/command/evidence 的「可验证」契约，缺「可模仿」的产出形态；
    #      用户投诉「说输出 JSON 却不给 JSON 实例」即由此漏检。
    "output_examples",
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
    "phase_gates", "knowledge_compliance", "cross_checks", "output_examples",
    # 新增对象/标量段（progress / findings / task_plan / verification 的非数组语义）
    "resume_report", "understanding", "config", "dual_qc", "goal_verdict", "core_question",
    "isolation", "batch", "delegation_stats", "chain", "quality_gates", "outcome",
    "template_type", "template_ref", "template_doc", "template_checks", "template_body", "next_step",
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
    # [2026-11-25 task-json-template P1] What: 结构化勾选条目默认面；checked 为 bool（非字符串），
    # Why: normalize_entry 经通用 add/update 补默认后须直接通过 _validate_entry/schema 校验。
    "template_checks": {"section": "", "block": "", "text": "", "checked": False,
                        "note": "", "tags": []},
    # [2026-11-25 task-output-example-contract] Rule 113 条目默认面：身份 id 强制，其余按 schema required 补齐。
    # Why: 默认面让字段名齐全；vc_refs 仍须显式给 ≥1 个 VC（Rule 113.4），空引用由 _validate_entry 拒绝。
    "output_examples": {"deliverable": "", "format": "", "example": "", "template": "", "vc_refs": [], "tags": []},
}

# [2026-11-23 task-planner-lean 修1] 字段别名归一表：section -> {常见误写字段: 合法字段}。
# What: Agent 凭直觉写 research.question / decisions.source / errors.time 等近义字段，旧行为
#       _validate_entry 以"未知字段 X"硬拒且不给合法字段名，逼出 6-7 次盲试（sess_093593a1 实测）。
# Why: 修脚本容错面而非降校验强度——只在"合法字段未出现"时把误写字段搬过去，绝不覆盖显式正确值；
#       真类型错误（如 attempt="1"）仍由 _validate_entry 原样硬拒（selftest-planctl.py:405 依赖此行为）。
FIELD_ALIASES: dict[str, dict[str, str]] = {
    "research": {"question": "claim", "conclusion": "source", "desc": "claim"},
    "decisions": {"source": "rationale", "reason": "rationale", "desc": "decision"},
    "errors": {"time": "timestamp", "when": "timestamp", "msg": "error"},
    "actions": {"desc": "text", "when": "at"},
    "test_results": {"desc": "test", "result": "status"},
    "findings": {"desc": "text"},
    "issues": {"desc": "issue"},
    "resources": {"desc": "locator", "url": "locator"},
}
# 可自动补的时间字段（仅缺失时补；不补 id 以保留"缺 id 报错"契约；不动类型校验）。
AUTO_STAMP: dict[str, str] = {"errors": "timestamp", "audits": "at", "actions": "at"}

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
    # [2026-11-25 task-json-template P1] What: template_doc 顶层对象最小校验（深校验见 _validate_template_doc）。
    # Why: jsonschema 是可选依赖，手写校验必须独立拦住坏 meta/sections；其余字段允许扩展。
    "template_doc": ({"schema_version", "meta", "sections"},
                     {"schema_version": lambda v: isinstance(v, int) and not isinstance(v, bool) and v == 1,
                      "meta": lambda v: isinstance(v, dict),
                      "sections": lambda v: isinstance(v, list)}, True),
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


def audit_no_progress(audits: list[dict[str, Any]]) -> tuple[bool, str, str]:
    """判定审计是否无进展，并返回区分两种止损的触发 token。

    [2026-11-23 task-planner-lean 修3] What: 在原有「最近 3 连续 REJECTED 且开放 C/I key 集
          完全相同」之外新增第二触发「累计 REJECTED≥4 且末轮非 APPROVED」。
    Why: 原判定只认 key 集一字不差；sess_093593a1 真实审计 2C/12I→1C/6I→0C/3I→0C/1I→0C/0I
         每轮换 key，判定永不命中，5 轮烧 4-5 小时仍不上抛。同一计划反复打回≥4 轮本身即真无
         进展，应强制走 decision-arbiter/AskUser，禁止继续自动派发同类修复。
    返回 (是否命中, 各轮 key 集合详情, 触发 token)：token ∈ {NO_PROGRESS_STREAK_3,
    CUMULATIVE_REJECTED_4, ""}。末轮 APPROVED 一律跳过（收敛不误伤，真实样本 R4 APPROVED
    不再误判）；streak 判定跳过无 issues 字段的轮（无信号），累计判定则计入（反复打回即信号）。
    """
    if not audits:
        return False, "", ""
    last = max(audits, key=lambda a: a.get("round", 0))
    if last.get("verdict") == "APPROVED":
        return False, "末轮 APPROVED 已收敛，跳过无进展判定", ""
    rejected = sorted((a for a in audits if a.get("verdict") == "REJECTED"),
                      key=lambda a: a.get("round", 0))
    signaled = [(a.get("round"), open_ci_keys(a)) for a in rejected if "issues" in a]
    details = ", ".join(f"R{r}={{{', '.join(sorted(k)) or '∅'}}}" for r, k in signaled[-3:])
    if len(signaled) >= 3:
        tail = signaled[-3:]
        rounds = [r for r, _ in tail]
        consecutive = all(rounds[j + 1] - rounds[j] == 1 for j in (0, 1))
        sets = [k for _, k in tail]
        # 判定口径=「key 集完全相同」而非「末轮 ⊆ 前轮」：后者会把真实清零误判为无进展。
        if consecutive and sets[0] and sets[0] == sets[1] == sets[2]:
            return True, details, "NO_PROGRESS_STREAK_3"
    # 第二触发：累计 REJECTED≥4（末轮非 APPROVED 已在顶部短路，无需重复判）。
    if len(rejected) >= 4:
        return True, details, "CUMULATIVE_REJECTED_4"
    return False, details, ""


def audit_cap(audits: list[dict[str, Any]]) -> tuple[bool, str]:
    """[task-perf-default-mini 2026-11-24] 审计轮数硬刹车：累计 REJECTED≥2 且无 APPROVED 即命中。

    What: 只看轮数与 APPROVED 存在性，不看 issue key、不看审计体名——轮数是唯一客观信号。
    Why: 既有 NO_PROGRESS_STREAK_3/CUMULATIVE_REJECTED_4 都依赖 issues 字段比对 key 集或
         累计 4 轮，真实任务审计条目从不带 issues → 永不命中（判例 5 轮审计烧 1h）。
         原行为=审计循环体内无任何脚本被调用，止损只挂默认 warn 的 attest 上；本层为新增
         独立刹车，不改 109/96.7 既有判定语义。
    返回 (命中bool, 触发token)；token="AUDIT_CAP_2" 或 ""。任一 APPROVED（含末轮）视为真实
    收敛，不命中。
    """
    rejected = [a for a in audits if a.get("verdict") == "REJECTED"]
    any_approved = any(a.get("verdict") == "APPROVED" for a in audits)
    if len(rejected) >= 2 and not any_approved:
        return True, "AUDIT_CAP_2"
    return False, ""


# [2026-11-24 task-perf-default-mini] 审计刹车文案：planctl 写入回显与 PreToolUse 拦截共用同一口径。
AUDIT_CAP_MESSAGE = (
    "[audit-cap] ⛔ 本计划审计已累计 2 轮 REJECTED（AUDIT_CAP_2）："
    "禁止再派任何第 3 轮审计体（换 critic key/换审计体名不构成合法理由）。"
    "唯一出口：派一次 decision-arbiter 终裁，按裁决由主进程收口并在计划登记 "
    "[audit-converge] 行 + 遗留风险清单。"
)


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


def _validate_template_doc(value: Any, where: str, errs: list[str]) -> None:
    """深校验 template_doc 的 sections/blocks/checklist items（与 schema 定义等价的手写判定面）。

    [2026-11-25 task-json-template P1] What: 校验 section.id/anchor/kind、block.kind 与
      checklist item.id/checked 的类型；其余字段一律放行（契约「其余字段允许」）。
    Why: jsonschema 是可选依赖且 schema 对 block 采用宽松 additionalProperties，坏模板若不在
      init/set 时被拦住，会在 render 阶段才炸或渲染出错位勾选项；fail-loud 前置到写入口。
    """
    if not isinstance(value, dict):
        errs.append(f"{where}: 必须是 object")
        return
    sections = value.get("sections")
    if not isinstance(sections, list):
        errs.append(f"{where}.sections: 必须是 array")
        return
    for si, section in enumerate(sections):
        sp = f"{where}.sections[{si}]"
        if not isinstance(section, dict):
            errs.append(f"{sp}: 必须是 object")
            continue
        for key in ("id", "anchor"):
            if not STR_FIELD(section.get(key)) or not section[key]:
                errs.append(f"{sp}.{key}: 值非法（{section.get(key)!r}）")
        if section.get("kind") not in ("ref", "blocks"):
            errs.append(f"{sp}.kind: 值非法（{section.get('kind')!r}，须 ref|blocks）")
        blocks = section.get("blocks", [])
        if not isinstance(blocks, list):
            errs.append(f"{sp}.blocks: 必须是 array")
            continue
        for bi, block in enumerate(blocks):
            bp = f"{sp}.blocks[{bi}]"
            if not isinstance(block, dict):
                errs.append(f"{bp}: 必须是 object")
                continue
            kind = block.get("kind")
            if kind not in ("markdown", "checklist", "table", "raw"):
                errs.append(f"{bp}.kind: 值非法（{kind!r}，须 markdown|checklist|table|raw）")
                continue
            if kind != "checklist":
                continue
            items = block.get("items", [])
            if not isinstance(items, list):
                errs.append(f"{bp}.items: 必须是 array")
                continue
            for ii, item in enumerate(items):
                ip = f"{bp}.items[{ii}]"
                if not isinstance(item, dict):
                    errs.append(f"{ip}: 必须是 object")
                    continue
                if not STR_FIELD(item.get("id")) or not item["id"]:
                    errs.append(f"{ip}.id: 必须是非空字符串")
                # 与 schema 的 required [id, checked] 对齐：缺 checked 也拒，避免到 commit 才失败。
                if "checked" not in item or not isinstance(item["checked"], bool):
                    errs.append(f"{ip}.checked: 必须是 bool（{item.get('checked')!r}）")


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
        # [2026-11-26 task-spec-consumption-chain S3] What: 基线条目 id 前缀扩展到
        #   MK*/SPEC-*/NA-*/SRC-*；新增 12 个可选 STR_FIELD 字段（kind 槽位 / check 判定式 /
        #   applies 适用单元 / src 对应 SRC / result 结论 / observed 观测 / cls 类别 / origin 来源），
        #   required 仍为 {id,verbatim,anchor}。
        # Why: spec-scan 与 spec-brief 需在同一权威源中登记规范、待处置候选与不适用项；
        #   旧字段与 MK 前缀逐字节保留，SB* 与哨兵 none-justified 属存量兼容，不得因新前缀判定而拒写。
        known.update({k: STR_FIELD for k in ("verbatim", "anchor", "rule", "sha", "kind",
                                             "check", "applies", "src", "result", "observed",
                                             "cls", "origin")})
        required = {"id", "verbatim", "anchor"}
        _spec_id = str(entry.get("id") or "")
        if not _spec_id.startswith(("MK", "SPEC-", "NA-", "SRC-", "SB", "none-justified")):
            errs.append(f"{where}.id: 前缀必须是 MK*/SPEC-*/NA-*/SRC-*（存量 SB*/none-justified 兼容）")
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
        # [2026-11-25 task-json-template P1] What: s_units 可选 status 纳入写入面。
        # Why: render 第 10 列状态改由本字段派生，若不登记则 set --field status 被当作未知字段拒绝。
        known["status"] = STR_FIELD
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
    elif section == "template_checks":
        # [2026-11-25 task-json-template P1] What: 勾选条目 checked 严格 bool（字符串 "true" 拒收）。
        # Why: CLI --value true 经 coerce_value 已转 bool；若放字符串会让 render 把 "false" 判成真。
        known.update({"section": STR_FIELD, "block": STR_FIELD, "text": STR_FIELD,
                      "note": STR_FIELD, "tags": STR_LIST_FIELD,
                      "checked": lambda v: isinstance(v, bool)})
        required = {"id", "checked"}
    elif section == "output_examples":
        # [2026-11-25 task-output-example-contract] Rule 113 条目校验（与 schema definitions.output_example_item 等价）。
        # Why: 原行为本段不在手工字段表，通用 add 写出 example/template/vc_refs 被误判「未知字段」而拒绝。
        known.update({"deliverable": STR_FIELD, "format": STR_FIELD,
                      "example": STR_FIELD, "template": STR_FIELD,
                      # Rule 113.4：示例必须映射至少 1 个已存在 VC，空引用不算合规。
                      "vc_refs": lambda v: isinstance(v, list) and len(v) >= 1
                                 and all(isinstance(x, str) for x in v)})
        required = {"id", "deliverable", "format", "example", "template", "vc_refs"}

    for key in required:
        if key not in entry:
            errs.append(f"{where}: 缺字段 {key}")
    for key, value in entry.items():
        if key not in known:
            # [2026-11-23 task-planner-lean 修1] What: 未知字段报错附合法字段清单。
            # Why: 原行为只报"未知字段 X"，Agent 无从得知正确字段名，只能 6-7 次盲试。
            errs.append(f"{where}: 未知字段 {key}（合法字段: {', '.join(sorted(known))}）")
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
        # [2026-11-25 task-json-template P1] JSON 模板路径=自由文本；template_body 降级 deprecated 但保留兼容。
        "template_ref": STR_FIELD,
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

    # [2026-11-25 task-json-template P1] template_doc 深校验只在此处做一次，写入/回读共用同一判定面。
    if "template_doc" in doc:
        _validate_template_doc(doc["template_doc"], "$.template_doc", errs)

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
    """补齐条目默认字段并核对身份；身份缺失/与路径 id 不一致时显式报错。

    [2026-11-23 task-planner-lean 修1] What: 写库前做字段别名归一 + 自动补时间戳。
    Why: 原行为 Agent 用 research.question / decisions.source 等近义字段被"未知字段"硬拒且
         无提示，逼出 6-7 次 schema 盲试（sess_093593a1）。别名只在合法字段未出现时搬运，
         不覆盖显式正确值；id 仍强制（保留缺 id 报错契约），类型错误仍由 validate 原样拒。
    """
    if section not in ARRAY_SECTIONS:
        raise PlanctlError(f"未知 section: {section}（可用: {', '.join(ARRAY_SECTIONS)}）")
    if not isinstance(payload, dict):
        raise PlanctlError(f"{section}: --json 必须是 object")
    entry = copy.deepcopy(payload)
    # 别名归一必须在补默认之前：默认空串会让"合法字段未出现"判断失效。
    legal_keys = set(ENTRY_DEFAULTS[section]) | {"id"}
    for wrong, right in FIELD_ALIASES.get(section, {}).items():
        if wrong in entry and right not in entry and right in legal_keys:
            entry[right] = entry.pop(wrong)
    for key, value in ENTRY_DEFAULTS[section].items():
        entry.setdefault(key, copy.deepcopy(value))
    # 自动补时间戳：仅该字段确实缺省时补（不影响 attempt 等类型校验）。
    stamp_key = AUTO_STAMP.get(section)
    if stamp_key and not entry.get(stamp_key):
        entry[stamp_key] = now_iso()

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

# [2026-11-25 task-json-template P1] JSON 原生模板加载：只读、fail-loud、不改模板源文件。
# What: template_ref 用仓库内相对路径（跨仓/仓外保留传入原路径）；template_doc 只取 meta+sections；
#       template_checks 由所有 checklist blocks 扁平化，id 重复即拒绝。
# Why: 勾选只能有一处权威源（JSON），MD 勾选是渲染派生；init 若静默跳过重复 id 会让后续 set/get
#       定位歧义，故此处显式报错而不是"最后一条覆盖"。
def _template_ref_for(path: str) -> str:
    """把模板路径转成相对仓库根的路径；不在仓库内则原样返回传入路径。"""
    p = Path(path)
    absolute = p if p.is_absolute() else Path.cwd() / p
    try:
        return str(absolute.resolve().relative_to(REPO_ROOT))
    except ValueError:
        return path


def _flatten_template_checks(sections: list[Any]) -> list[dict[str, Any]]:
    """从 template_doc.sections 的所有 checklist blocks 扁平化为 template_checks 条目。"""
    checks: list[dict[str, Any]] = []
    seen: set[str] = set()
    for section in sections:
        if not isinstance(section, dict):
            raise PlanctlError("模板 sections 条目必须是 object")
        sec_id = str(section.get("id", ""))
        blocks = section.get("blocks", [])
        if not isinstance(blocks, list):
            raise PlanctlError(f"模板 section {sec_id!r} 的 blocks 必须是 array")
        for block in blocks:
            if not isinstance(block, dict):
                raise PlanctlError(f"模板 section {sec_id!r} 的 block 必须是 object")
            if block.get("kind") != "checklist":
                continue
            block_id = str(block.get("id", ""))
            items = block.get("items", [])
            if not isinstance(items, list):
                raise PlanctlError(f"模板 checklist {sec_id}/{block_id} 的 items 必须是 array")
            for item in items:
                if not isinstance(item, dict) or not STR_FIELD(item.get("id")) or not item["id"]:
                    raise PlanctlError(f"模板 checklist {sec_id}/{block_id} 的 item 缺合法 id: {item!r}")
                cid = str(item["id"])
                if cid in seen:
                    raise PlanctlError(f"--template-json checklist id 重复: {cid}（section={sec_id}, block={block_id}）")
                seen.add(cid)
                checked = item.get("checked", False)
                if not isinstance(checked, bool):
                    raise PlanctlError(f"模板 checklist item {cid} 的 checked 必须是 bool（{checked!r}）")
                tags = item.get("tags", [])
                if not isinstance(tags, list) or not all(isinstance(t, str) for t in tags):
                    raise PlanctlError(f"模板 checklist item {cid} 的 tags 必须是字符串数组")
                checks.append({"id": cid, "section": sec_id, "block": block_id,
                               "text": str(item.get("text", "")), "checked": checked,
                               "note": str(item.get("note", "")), "tags": copy.deepcopy(tags)})
    return checks


def _load_template_json(path: str) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    """读取 JSON 模板，返回 (template_doc 载荷, template_checks)；任何结构错误都抛 PlanctlError。"""
    p = Path(path)
    if not p.is_file():
        raise PlanctlError(f"--template-json 指向的文件不存在: {path}")
    try:
        tpl = json.loads(p.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise PlanctlError(f"--template-json 读取/解析失败: {path}: {exc}") from exc
    if not isinstance(tpl, dict):
        raise PlanctlError("--template-json 顶层必须是 object")
    version = tpl.get("schema_version", 1)
    if not isinstance(version, int) or isinstance(version, bool) or version != 1:
        raise PlanctlError(f"--template-json schema_version 必须为 1（实际 {version!r}）")
    meta = tpl.get("meta")
    sections = tpl.get("sections")
    if not isinstance(meta, dict) or not isinstance(sections, list):
        raise PlanctlError("--template-json 必须含 object meta 与 array sections")
    template_doc = {"schema_version": version, "meta": copy.deepcopy(meta),
                    "sections": copy.deepcopy(sections)}
    errs: list[str] = []
    _validate_template_doc(template_doc, "$.template_doc", errs)
    if errs:
        raise PlanctlError("--template-json 结构非法: " + " | ".join(errs[:8]))
    return template_doc, _flatten_template_checks(sections)


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
    # [2026-11-25 task-json-template P1] JSON 原生模板：init 落 template_ref/template_doc/template_checks，
    #   render 从 JSON 派生领域段与勾选；不再写 template_body，避免勾选双源。
    # [2026-11-22 task-template-json-compat-20261122] 旧 --template-body-from 保留给存量流程（deprecated）。
    tj_from = getattr(args, "template_json", None)
    tb_from = getattr(args, "template_body_from", None)
    if tj_from and tb_from:
        raise PlanctlError("不得同时传 --template-json 与已废弃的 --template-body-from（避免勾选双源）")
    if tj_from:
        template_doc, checks = _load_template_json(tj_from)
        doc["template_ref"] = _template_ref_for(tj_from)
        doc["template_doc"] = template_doc
        doc["template_checks"] = checks
    elif tb_from:
        _tb = Path(tb_from)
        if not _tb.is_file():
            raise PlanctlError(f"--template-body-from 指向的文件不存在: {tb_from}")
        # DEPRECATED（2026-11-25 P1）：仅供无 JSON 模板的旧流程，新计划请传 --template-json。
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
        # [2026-11-25 task-json-template P4] What: 可选数组段（template_checks）缺省时输出 []，
        #   而非 KeyError traceback（cmd_get 数组分支先于 TOP_LEVEL_KEYS 分支命中）。
        # Why: P4 门控统一用 `get --section template_checks` 判定「有无结构化勾选」；存量计划
        #   无该段是合法状态（OPTIONAL_TOP_LEVEL_KEYS），必须给稳定空标记才能走 MD 回退，
        #   不得靠异常/2>/dev/null 掩盖。必填数组段（vcs 等）在合法 state 中恒存在，零行为变化。
        out = doc.get(args.section, [])
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
# [2026-11-25 task-compact-recover-inline] What: 恢复包由「列路径叫模型自己 Read」改为「直接内联内容」：
#   ① skill_contract 内联技能正文（canonical SKILL.md 全文）；② 删除 core_files 字段；
#   ③ phase 增补进度全貌、新增 recent_actions（做过什么）；④ 限幅只作用于任务状态块。
# Why: 用户裁决——压缩后要的是「让模型直接知道」；只给路径依赖模型自觉去读，既浪费模型资源也不可靠。
#   依据项目自身设计：plan-state.json 是唯一权威源、4 个 MD 是 render 派生视图（禁手工 Edit），
#   故进度只从权威源读、不再列派生视图路径（同一内容给两遍=画蛇添足）；SKILL.md 是技能入口
#   （工作流+硬条款，非派生视图），压缩后被整体冲掉=技能体系崩塌，故全文内联且不受限幅；
#   references/config 由 SKILL.md 内指针按需加载，不预列（用户裁决：不要一次性铺开整个技能包）。
RECOVER_DEFAULT_FIELDS = (
    "skill_contract", "requirements", "goal", "phase", "recent_actions",
    "next_step", "decisions", "mustkeep", "git_baseline",
)
RECOVER_SKILL_BEGIN = "【技能正文·开始】"
RECOVER_SKILL_END = "【技能正文·结束】"   # 未见此标记=技能正文被平台截断，消费端须 Read 补全
RECOVER_ACTION_TAIL = 8     # 「做过什么」取最近 N 条动作（更早的属已翻篇阶段，按需查 progress 视图）
RECOVER_ACTION_CHARS = 200  # 单条动作注入限幅；超出截断并标 …（只限幅不改写，不编造）


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


def _recover_skill_text() -> tuple[Path, str]:
    """读取技能正文 SKILL.md 全文，返回 (实际读取的路径, 全文)；读不到返回 (路径, "")。

    Why 要做 canonical 解析：部署位（~/.zcode/skills/task-planner 等）的 SKILL.md 是宿主薄壳
    （只有 hook frontmatter + 指向 canonical 的资源路径表，见 lib/install-stub.sh 的
    generate_stub_skill_md），技能正文在 canonical 源仓；薄壳正文含
    「Canonical source: `${TASK_PLANNER_ROOT:-<绝对路径>}`」行，据此取到正文。
    环境变量 TASK_PLANNER_ROOT 与薄壳同语义，优先级最高；都取不到则用脚本自身上级目录的
    SKILL.md（源仓内运行时它本身就是完整版）。
    """
    skill_md = SKILL_DIR / "SKILL.md"
    try:
        own = skill_md.read_text(encoding="utf-8")
    except OSError:
        own = ""
    candidates: list[Path] = []
    env_root = os.environ.get("TASK_PLANNER_ROOT")
    if env_root:
        candidates.append(Path(env_root) / "SKILL.md")
    m = re.search(r"Canonical source:\s*`\$\{TASK_PLANNER_ROOT:-([^}]+)\}`", own)
    if m:
        candidates.append(Path(m.group(1)) / "SKILL.md")
    for cand in candidates:
        try:
            text = cand.read_text(encoding="utf-8")
        except OSError:
            continue
        if text:
            return cand, text
    return skill_md, own


def _recover_phase_lines(phases: Any) -> list[str]:
    """Phase 进度全貌（一行）+ 当前 Phase 名。✓=complete ▶=in_progress ○=pending（schema 枚举三态）。"""
    marks = {"complete": "✓", "in_progress": "▶", "pending": "○"}
    overview: list[str] = []
    cur = "-"
    found_cur = False
    if isinstance(phases, list):
        for p in phases:
            if not isinstance(p, dict):
                continue
            pid = str(p.get("id") or "-")
            status = str(p.get("status") or "-")
            overview.append(f"{pid}{marks.get(status, '?')}")
            if status == "in_progress" and not found_cur:
                cur = str(p.get("name") or p.get("phase") or p.get("id") or p.get("title") or "-")
                found_cur = True
    return [f"Phase 进度: {' '.join(overview) if overview else '-'}（✓完成 ▶进行中 ○待办）",
            f"Current Phase: {cur}"]


def _recover_action_lines(actions: Any) -> list[str]:
    """最近动作（做过什么）：按 at 时间升序取尾部 RECOVER_ACTION_TAIL 条；无 at 的排最前。"""
    if not isinstance(actions, list) or not actions:
        return ["最近动作: -"]

    def _at(item: dict[str, Any]) -> str:
        return str(item.get("at") or "")

    items = [a for a in actions if isinstance(a, dict)]
    items.sort(key=_at)
    out = [f"最近动作（做过什么，最近 {RECOVER_ACTION_TAIL} 条）:"]
    for a in items[-RECOVER_ACTION_TAIL:]:
        text = _recover_flat(a.get("text"), "")
        if len(text) > RECOVER_ACTION_CHARS:
            text = text[:RECOVER_ACTION_CHARS] + "…"
        out.append(f"[{a.get('id') or '-'} {_at(a) or '-'}] {text or '-'}")
    return out


def _recover_git_baseline_lines(plan_dir: Path) -> list[str]:
    """Git 基线行：读 .git-baseline.json sidecar（缺失/不可读写指引，不编造）。"""
    sidecar = plan_dir / ".git-baseline.json"
    script_dir = SCRIPT_DIR
    if not sidecar.is_file():
        return [f"Git基线: 缺失 → 先执行 B9（任务开始前备份，未做不得写受管文件）: bash {script_dir}/git-baseline.sh snapshot {plan_dir}"]
    try:
        g = json.loads(sidecar.read_text(encoding="utf-8"))
        sha = str(g.get("baseline_sha") or "-")[:8]
        cps = g.get("checkpoints")
        cps_n = len(cps) if isinstance(cps, list) else 0
        last = g.get("last_diff") if isinstance(g.get("last_diff"), dict) else {}

        def _n(v: Any) -> str:
            return str(v) if isinstance(v, (int, str)) and v != "" else "0"

        return [
            f"Git基线: {sha} 检查点={cps_n} 未处置={_n(last.get('unresolved'))} "
            f"必保丢失={_n(last.get('mustkeep_lost'))}（最近分析 {last.get('at') or '-'}；"
            f"续做前先跑 B11: bash {script_dir}/git-baseline.sh diff {plan_dir}）"
        ]
    except (OSError, ValueError, TypeError):
        return [f"Git基线: 证据文件不可读 → 重跑 bash {script_dir}/git-baseline.sh status {plan_dir}"]


def cmd_recover(args: argparse.Namespace) -> int:
    """压缩恢复包：任务核心状态（权威源）+ 技能正文全文 → 直接注入，并全文落盘 .compact-recovery.md。

    --fields 逗号分隔指定要注入的字段（默认 RECOVER_DEFAULT_FIELDS）；字段缺失一律写 `-`，不编造。
    --max-lines 只限「任务状态」块（默认 150）；技能正文不参与限幅（规则残缺比多占上下文更糟）。
    输出顺序：恢复纪律 → 任务状态（固定核心行在前、长列表在后可截断）→ 技能正文。
    落盘文件只存任务状态全文（供截断后追读）；技能正文磁盘上本就是 SKILL.md，不重复落盘。
    """
    plan_dir = check_plan_dir(args.plan_dir)
    task_id = plan_dir.name
    fields_raw = getattr(args, "fields", None) or ",".join(RECOVER_DEFAULT_FIELDS)
    fields = [f.strip() for f in fields_raw.split(",") if f.strip()]
    max_lines_raw = getattr(args, "max_lines", 150)
    max_lines = max_lines_raw if isinstance(max_lines_raw, int) and max_lines_raw >= 2 else 150

    doc = read_state(plan_dir)

    # ① 恢复纪律（固定头，不参与限幅）。保留旧版首行 [compact-recovery] 标记（hook/selftest 断言锚）。
    head = [
        f"[compact-recovery] 上下文恢复包（检测到在途计划 {task_id}；数据来自 planctl 读权威源 plan-state.json，非会话记忆。摘要可能丢细节，以下列字段为准）",
        "⚠️ 恢复纪律（先于任何其它工具调用）: ①压缩摘要不可信，任务目标/进度以下方「任务状态」为准，读完前不得推进任务、不得删改任何既有设定/事实；"
        "②下方已内联技能正文全文，无需再 Read SKILL.md，按其工作流与硬条款继续执行，references/配置按其中指针按需加载；"
        f"③若未见「{RECOVER_SKILL_END}」标记=技能正文被平台截断，须 Read 补全后再执行。",
    ]

    # ② 任务状态·固定核心行（短，任何限幅下都保全）
    core: list[str] = []
    if "goal" in fields:
        core.append(f"Goal: {_recover_flat(doc.get('goal', doc.get('goals')))}")
    if "phase" in fields:
        core.extend(_recover_phase_lines(doc.get("phases")))
    if "next_step" in fields:
        core.append(f"Next Step: {_recover_flat(doc.get('next_step', doc.get('next')))}")
    if "git_baseline" in fields:
        core.extend(_recover_git_baseline_lines(plan_dir))

    # ③ 任务状态·长列表（超限幅时从尾部截断；按「丢了最致命」排序：用户原话 > 必保 > 裁决 > 动作）
    longs: list[str] = []
    if "requirements" in fields:
        reqs = doc.get("requirements") or []
        longs.append("Requirements（用户原话/任务目标，逐字）:")
        if isinstance(reqs, list) and reqs:
            for r in reqs[:100]:
                if isinstance(r, dict):
                    longs.append(f"[{r.get('id') or '-'}] {_recover_flat(r.get('text'))}")
                else:
                    longs.append(_recover_flat(r))
        else:
            longs.append("-")
    if "mustkeep" in fields:
        sb = doc.get("spec_baseline") or []
        longs.append("必保清单:")
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
                longs.append(f"{mid} | {verbatim} | target={target} | 真源={anchor}")
                mk_count += 1
        if mk_count == 0:
            longs.append("必保清单=缺失（存量计划，非阻断提示）")
    if "decisions" in fields:
        decs = doc.get("decisions", doc.get("decisions_made")) or []
        longs.append("Decisions（全部，一行一条）:")
        if isinstance(decs, list) and decs:
            for d in decs[:100]:
                longs.append(_recover_flat(d))
        elif isinstance(decs, dict) or isinstance(decs, str):
            longs.append(_recover_flat(decs))
        else:
            longs.append("-")
    if "recent_actions" in fields:
        longs.extend(_recover_action_lines(doc.get("actions")))

    # ④ 限幅：只作用于任务状态块（core 必保全，longs 让位），-1 给截断提示行留位
    state = core + longs
    if len(head) + len(state) > max_lines:
        keep = max(max_lines - len(head) - len(core) - 1, 0)
        state = core + longs[:keep]
        state.append(f"…任务状态已截断（上限 {max_lines} 行）；完整内容见 {plan_dir}/.compact-recovery.md")

    lines = head + state

    # ⑤ 技能正文全文内联（不参与限幅）
    if "skill_contract" in fields:
        skill_path, skill_text = _recover_skill_text()
        body = skill_text.rstrip("\n")
        if body:
            lines.append(f"{RECOVER_SKILL_BEGIN} {skill_path}（技能入口全文 {len(body.splitlines())} 行，已内联，无需再 Read）")
            lines.extend(body.splitlines())
            lines.append(RECOVER_SKILL_END)
        else:
            lines.append(f"{RECOVER_SKILL_BEGIN} 技能正文不可读（{skill_path}）→ 须手动 Read 该文件 {RECOVER_SKILL_END}")

    # 全文落盘供截断后追读（只落任务状态；技能正文磁盘上本就是 SKILL.md，不重复落盘）；
    # 写入失败 fail-open，不影响注入
    try:
        (plan_dir / ".compact-recovery.md").write_text("\n".join(head + core + longs) + "\n", encoding="utf-8")
    except OSError:
        pass

    print("\n".join(lines))
    return 0


def cmd_recover_skill(args: argparse.Namespace) -> int:
    """无在途计划也要无条件续命的技能契约注入包：只出恢复纪律 + 技能正文全文。

    2026-11-24 压缩恢复实测缺陷根治：原 recover 必须带 --plan-dir 且 hook 只在 inflight
    命中时才调用，导致无 side 指针（首次会话/测试会话）或空壳计划（指针存在但无
    task_plan.md）时技能正文完全不注入——压缩把 SKILL.md 语义冲掉后技能体系即崩。
    用户核心诉求=「每次压缩后必须重新注入当前技能」。本命令与 cmd_recover 共享
    _recover_skill_text()（单一读取口径），但不读权威源、不需要计划目录、不落盘，
    只负责技能正文这一无条件部分；任务核心状态仍由 cmd_recover 在有在途计划时附加。
    fail-closed 边界：技能正文不可读时注入明确指引（不静默出空包伪装成功）。
    """
    head = [
        "[compact-recovery] 上下文恢复包（未检测到在途计划：仅无条件注入技能契约；数据来自技能入口 SKILL.md，非会话记忆）",
        "⚠️ 恢复纪律（先于任何其它工具调用）: ①压缩摘要不可信，任务目标/进度以下方技能契约与会话内既有事实为准，"
        "读完前不得删改任何既有设定/事实；②下方已内联技能正文全文，无需再 Read SKILL.md，"
        "按其工作流与硬条款继续执行，references/配置按其中指针按需加载；"
        f"③若未见「{RECOVER_SKILL_END}」标记=技能正文被平台截断，须 Read 补全后再执行。",
    ]
    skill_path, skill_text = _recover_skill_text()
    body = skill_text.rstrip("\n")
    if body:
        head.append(f"{RECOVER_SKILL_BEGIN} {skill_path}（技能入口全文 {len(body.splitlines())} 行，已内联，无需再 Read）")
        head.extend(body.splitlines())
        head.append(RECOVER_SKILL_END)
    else:
        head.append(f"{RECOVER_SKILL_BEGIN} 技能正文不可读（{skill_path}）→ 须手动 Read 该文件 {RECOVER_SKILL_END}")
    print("\n".join(head))
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
    # [2026-11-23 task-planner-lean 修3] 返回值扩为三元组（新增触发 token），观测态只需bool。
    no_progress, _, _ = audit_no_progress(audits)
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
    result: dict[str, Any] = {"section": args.section, "added": entry}
    # [2026-11-24 task-perf-default-mini 包3] What: audits 写入落盘后重读权威源跑 audit_cap，
    #   命中则把强制指令块随本次 add 的 stdout JSON 回显（不阻断写入）。
    # Why: 第 2 轮 REJECTED 本身必须能落盘（否则审计证据丢失）；刹车对象是之后的第 3 轮派发。
    #   文案放进 emit 的 JSON 字段而非另打裸文本，保住「planctl stdout 可 json.load」既有契约，
    #   PreToolUse Agent 分支用同一 token/口径做硬拦截。
    if args.section == "audits":
        cap_hit, cap_token = audit_cap(read_state(plan).get("audits", []))
        if cap_hit:
            result["audit_cap"] = AUDIT_CAP_MESSAGE
            result["audit_cap_token"] = cap_token
    emit(result)
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
    """生成 Markdown 表格；单元格内半角竖线转全角「｜」，避免破坏列边界。"""
    # [2026-11-26 task-spec-consumption-chain gate-fix3] What: 单元格里的半角 | 替换为全角 ｜（原为反斜杠转义 \|）。
    # Why: \| 仍保留半角 |，下游按 | split 时列数错位（含管道符的判定式会把 9 列撑成更多列）；全角字符不再是分隔符。
    # 所有表（_table/_kv_table/直接 _md_table 调用）统一经此单元格函数；无管道符的既有计划 replace 无命中，render 输出逐字节不变。
    def cell(v: Any) -> str:
        s = ", ".join(str(x) for x in v) if isinstance(v, list) else ("" if v is None else str(v))
        return s.replace("|", "｜").replace("\n", " ")
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


# [2026-11-25 task-json-template P1] JSON 原生模板派生渲染：核心段仍由既有代码生成，
# 模板 kind=blocks 的锚段在核心段之后按序追加。勾选只读 template_checks（MD 勾选不回读），
# 彻底消除「MD 手改勾选」与 JSON 双源漂移。
def _template_check_index(doc: dict[str, Any]) -> tuple[dict[tuple[str, str, str], dict[str, Any]],
                                                        dict[str, dict[str, Any]]]:
    """构造 (section, block, id) → 勾选条目 索引，以及 id → 条目 的单键兜底索引。"""
    by_key: dict[tuple[str, str, str], dict[str, Any]] = {}
    by_id: dict[str, dict[str, Any]] = {}
    for check in _arr(doc, "template_checks"):
        if not isinstance(check, dict):
            continue
        cid = str(check.get("id", ""))
        if not cid:
            continue
        by_key[(str(check.get("section", "")), str(check.get("block", "")), cid)] = check
        by_id.setdefault(cid, check)
    return by_key, by_id


def _render_template_block(section: dict[str, Any], block: dict[str, Any],
                           by_key: dict[tuple[str, str, str], dict[str, Any]],
                           by_id: dict[str, dict[str, Any]]) -> list[str]:
    """把单个模板块渲染为 MD 行；checklist 的 checked 从 JSON 索引取（不读 MD 勾选）。"""
    kind = block.get("kind")
    if kind in ("markdown", "raw"):
        return str(block.get("text", "")).splitlines()
    if kind == "table":
        # [2026-11-25 task-json-template] header=columns 兼容：to-json 转换器从 MD 表头
        # 产出 header 字段，渲染器原仅认 columns，导致领域表被渲染成空段。
        columns = block.get("columns") or block.get("header")
        rows = block.get("rows")
        if not isinstance(columns, list) or not isinstance(rows, list):
            return [str(block.get("text", ""))]
        names = [str(c) for c in columns]
        normalized = [[_cell(r.get(c, "")) for c in names] if isinstance(r, dict)
                      else [_cell(c) for c in r] for r in rows]
        return [_md_table(names, normalized)]
    if kind == "checklist":
        sec_id, block_id = str(section.get("id", "")), str(block.get("id", ""))
        out: list[str] = []
        items = block.get("items")
        if not isinstance(items, list):
            return out
        for item in items:
            if not isinstance(item, dict):
                continue
            cid = str(item.get("id", ""))
            check = by_key.get((sec_id, block_id, cid)) or by_id.get(cid)
            # 缺登记时退回模板项自身的初始 checked（init 时与 JSON 一致）；绝不解析 MD 勾选。
            source = check if check is not None else item
            mark = "x" if source.get("checked") is True else " "
            text = _cell(source.get("text", item.get("text", "")))
            note = _cell(source.get("note", item.get("note", "")))
            out.append(f"- [{mark}] {text}" + (f"（{note}）" if note else ""))
        return out
    return []


def _append_template_sections(doc: dict[str, Any], lines: list[str]) -> None:
    """在核心段之后按 template_doc.sections 顺序追加 kind=blocks 的锚段；mini 档豁免。"""
    tpl = _obj(doc, "template_doc")
    if not tpl or doc.get("plan_tier") == "mini":
        return
    sections = tpl.get("sections")
    if not isinstance(sections, list):
        return
    by_key, by_id = _template_check_index(doc)
    for section in sections:
        if not isinstance(section, dict) or section.get("kind") != "blocks":
            continue
        anchor = str(section.get("anchor", "")).strip().lstrip("#").strip()
        lines += ["", f"## {anchor or section.get('id', '')}"]
        blocks = section.get("blocks")
        if not isinstance(blocks, list):
            continue
        for block in blocks:
            if isinstance(block, dict):
                lines.extend(_render_template_block(section, block, by_key, by_id))


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
    # [2026-11-25 task-output-example-contract] What: 渲染 Rule 113「🧩 输出示例与格式契约」区块。
    # Why: task_plan.md 由本函数全量重建，模板 MD 中的示例区块会被抹掉；必须在此从 JSON 派生，
    #      否则用户「看不到可直接查看的示例」= 改造无效。mini/L0-lite 不豁免（Rule 113.2）。
    out_examples = _arr(doc, "output_examples")
    lines += ["", "## 🧩 输出示例与格式契约（Rule 113）"]
    if out_examples:
        lines += [_md_table(["id", "交付物", "格式", "对应 VC", "完整示例", "可复用模板"],
                           [[_cell(ex.get("id", "")), _cell(ex.get("deliverable", "")),
                             _cell(ex.get("format", "")),
                             ", ".join(str(x) for x in ex.get("vc_refs", [])) or "-",
                             "见下方「完整示例」代码块", "见下方「可复用模板」代码块"]
                            for ex in out_examples])]
        for ex in out_examples:
            lines += ["", f"### 示例 {_cell(ex.get('id', ''))} · {_cell(ex.get('deliverable', ''))}",
                      f"- **格式**：{_cell(ex.get('format', ''))}",
                      f"- **对应 VC**：{', '.join(str(x) for x in ex.get('vc_refs', [])) or '-'}",
                      "", "**完整示例（可直接查看）**：", "",
                      str(ex.get("example", "")).rstrip() or "（未填写 example —— Rule 113.2 违规）",
                      "", "**可复用模板（占位符版）**：", "",
                      str(ex.get("template", "")).rstrip() or "（未填写 template —— Rule 113.2 违规）"]
    else:
        lines += ["（尚未登记 output_examples —— Rule 113.1：凡声明输出格式的交付物必须给出完整示例+可复用模板，"
                  "经 `planctl add --section output_examples` 登记；无格式交付物须显式写 none-justified 并附理由）"]
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
                # [2026-11-25 task-json-template P1] What: S-unit 第 10 列状态由 s_units[].status 派生，
                # Why: 原恒写 pending 使 JSON 中 pass/in_progress 状态在视图里永远不可见；缺省仍 pending。
                _su_status = _cell(s.get("status") or "pending")
                su_rows.append([_cell(s.get("id", "")), goal, _cell(s.get("executor", "")),
                                _cell(s.get("files", "")), _cell(s.get("verify", "")),
                                _cell(s.get("duration", "")), _cell(s.get("granularity", "")),
                                _escort, _deps, _su_status])
            _pno = _phase_no(p.get("id"))
            lines += ["", f"### Phase {_pno}: {_cell(p.get('name', ''))}".rstrip(),
                      f"- **Status:** {_cell(p.get('status', 'pending'))}",
                      f"- **Started:** {_cell(p.get('started', ''))}",
                      f"- **Executor:** {executors}"]
            # [2026-11-22 task-template-json-compat-20261122] R-1：V-N 映射行（check-complete
            #   VC-GATE 按 `^- \[[ xX]\] V-<P号>.<N>\s*[:：]` 计数且校验 VC-x ∈ VC 定义集）；
            #   数据源=phases[].v_checks（JSON 已有）。无 v_checks 时不输出（门按缺映射判缺口，
            #   与旧行为一致，不开逃生口）。P 号必须与 Phase 标题一致，否则门 Skipped。
            # [2026-11-25 task-json-template P1] What: V-N 映射 checkbox 由对应 vcs[].status 派生
            #   （pass→[x]；pending/fail→[ ]）；找不到对应 VC 时保持旧 [x] 兼容存量计划。
            # Why: 原恒写 [x] 使未验证 VC 在 task_plan.md 显示为已通过，check-complete 的 VC-GATE
            #   只数映射行不验真实状态，形成假绿；勾选唯一权威源是 JSON 的 vcs[].status。
            _vc_by_id = {str(v.get("id")): v for v in _arr(doc, "vcs") if isinstance(v, dict)}
            for _vni, _vcid in enumerate(p.get("v_checks", []) or [], 1):
                _vc_entry = _vc_by_id.get(str(_vcid))
                _vc_mark = "x" if _vc_entry is None or _vc_entry.get("status") == "pass" else " "
                lines.append(f"- [{_vc_mark}] V-{_pno}.{_vni}: {_cell(_vcid)}（Phase {_pno} 验证契约映射）")
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
        # [2026-11-26 task-spec-consumption-chain S3] What: 既有 5 列顺序原样保留，右侧追加
        #   槽/校验命令/适用S-unit/结果 4 列（取 S3 新增 STR_FIELD，空值渲染空单元格）。
        # Why: check-spec-baseline.sh 与人工复核需在同一表内看到判定式、验证命令与最终结论，
        #   前 5 列是历史门控消费面，改序会破坏存量计划；追加列对旧行保持空值兼容。
        lines += ["", "## 🔒 规范基线（Spec-Baseline）",
                  _table(["spec_id", "约束原文(verbatim)", "来源锚(path:line)", "双向判定式", "来源 sha256",
                          "槽", "校验命令", "适用S-unit", "结果"],
                         [[x.get("id"), x.get("verbatim"), x.get("anchor"), x.get("rule"), x.get("sha"),
                           x.get("kind"), x.get("check"), x.get("applies"), x.get("result")]
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

    # 收尾对齐与清理板块：在 outcome 判定与合并回前核对口径并清理 Skill 说明 Markdown 中的新增痕迹旁注，证据落 progress。
    # 边界：代码文件注释属保护对象（不进 Agent 上下文、便于后期理解），禁止列入清理。
    _lane = str(doc.get("execution_lane", "L1"))
    if doc.get("plan_tier") != "mini" and _lane not in ("L0", "L0-T", "L0-E"):
        lines += ["", "## 🧹 收尾对齐与清理（交付前必填）",
                  _table(["类别", "检查项", "判据", "证据"],
                         [["对齐", "口径计数 / 冲突条款 / 行数快照", "冲突锚 grep 无本任务新增命中", "progress `[align-final]` 行"],
                          ["清理", "Skill 说明 Markdown 中的历史旁注 / 过期注 / 残留物；代码文件注释不在清理范围、受保护", "本任务新增痕迹注为 0（代码注释不计入）", "progress `[cleanup-final]` 行"]],
                         _EMPTY % "收尾对齐与清理"),
                  "", "范围：只清会被 Agent 读进上下文的 Skill 说明文件；代码文件（.py/.sh/.ts 等）里的注释属保护对象，禁止清理。执行时机：outcome 判定之前、合并回动作之前；mini / L0-lite 档豁免本板块。"]

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

    # [2026-11-25 task-json-template P1] 核心段之后按序追加 JSON 模板 blocks 段（勾选派生自
    #   template_checks）；有 template_doc 即新计划，不再吐旧 template_body 附录，避免双源。
    _append_template_sections(doc, lines)

    # [2026-11-22 task-template-json-compat-20261122] 兼容兜底：仅无 template_doc 的旧计划
    #   才把 template_body 原文以附录吐出（标题降级 `^(#+ )`→`> \1` 避免与权威 51.1/66.5 锚竞争）。
    # [2026-11-25 P1] 加 `not template_doc` 门：新计划禁用该附录，mini 档仍豁免复杂段。
    if not _obj(doc, "template_doc") and doc.get("template_body") and doc.get("plan_tier") != "mini":
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
        # [2026-11-25 task-output-example-contract] What: verification 视图附 Rule 113 示例对照指引 + 已登记示例索引。
        # Why: VC 只判「可验证」，用户投诉的是「看不到产出长什么样」；验收时须能直接对照示例，禁仅凭退出码放行。
        "", "> **输出示例对照（Rule 113）**：凡 VC 判定标准涉及输出格式/结构，须在 `task_plan.md`「🧩 输出示例与格式契约」区块有对应 `output_examples` 条目（完整示例+同结构模板+`vc_refs` 指向本 VC）；产出形态与示例不一致 = VC 未通过。",
        "", "**本计划已登记输出示例**：" + (", ".join(
            f"{ex.get('id')}（{ex.get('deliverable')} / {ex.get('format')} → {', '.join(str(x) for x in ex.get('vc_refs', []))}）"
            for ex in _arr(doc, "output_examples")
        ) if _arr(doc, "output_examples") else "（无 —— 若无格式交付物请写 none-justified 理由）"),
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
    # [2026-11-26 task-spec-consumption-chain S3] What: verification.md 尾部追加
    #   「基线-产物逐条核验表（Rule 84.15）」：仅存在 SPEC-* 行时生成；观测取 observed、
    #   结论取 result，空值显式写「待终验」，证据锚取基线 anchor。
    # Why: 规范不消费的根因是「判定式只写在计划里、派发与终验均无逐条回执」；
    #   该表把每条 SPEC 的判定式、校验命令、观测与结论落在终验视图，供 Rule 84.15 逐条核验。
    _spec_rows = [x for x in _arr(doc, "spec_baseline")
                  if isinstance(x, dict) and str(x.get("id") or "").startswith("SPEC-")]
    if _spec_rows:
        lines += ["", "## 基线-产物逐条核验表（Rule 84.15）",
                  _table(["spec_id", "双向判定式", "校验命令", "观测", "证据锚(path:line 或回执)", "结论"],
                         [[x.get("id"), x.get("rule"), x.get("check"),
                           _cell(x.get("observed")).strip() or "待终验",
                           x.get("anchor"),
                           _cell(x.get("result")).strip() or "待终验"]
                          for x in _spec_rows], _EMPTY % "基线核验记录")]
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
    """audit：先做无进展止损（两种触发→FAIL 并上报），再判末段形态。

    [2026-11-21 task-audit-rework-cap-20261121] 原行为=仅校验末轮 APPROVED 且 0C/0I；
    新增 no_progress 判定置于其后、原末段判定之前，且末轮 APPROVED 一律跳过（收敛不误伤）。
    [2026-11-23 task-planner-lean 修3] 第二触发=累计 REJECTED≥4（key 逐轮换但反复打回），
    与 NO_PROGRESS_STREAK_3 并列上报，各自独立 token 便于机器门与日志区分。
    """
    audits = doc["audits"]
    if not audits:
        return False, "无 audit 记录（末轮审计缺失）"
    no_progress, details, trigger = audit_no_progress(audits)
    if no_progress:
        if trigger == "CUMULATIVE_REJECTED_4":
            return (False, "CUMULATIVE_REJECTED_4 ESCALATE_USER_DECISION_REQUIRED "
                           f"<details: {details}>（累计 4+ 轮 REJECTED 且末轮未 APPROVED，"
                           "同一计划反复打回=真无进展，禁止继续自动派发同类修复，"
                           "改走 decision-arbiter/AskUser 上报）")
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


def cmd_spec_brief(args: argparse.Namespace) -> int:
    """输出可原样塞进派发 prompt 的「规范携带块」（Rule 22.4e）。

    [2026-11-26 task-spec-consumption-chain S3] What: 按 --sunit 过滤 spec_baseline 中的
      SPEC-* 行，打印固定头/逐行判定式+锚+sha 前 8 位/固定回执尾；无适用行打印显式 none。
    Why: 规范携带块必须逐字注入执行体且禁改写，若靠 Agent 手抄会丢判定式；
      由 CLI 从唯一权威源生成并固定文案，才能堵住「计划里有规范、执行体没看到」的断点。
      空 applies 视为不限定单元（存量行无该字段，丢规范比多带一条更危险）。
    """
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    require_valid(doc)
    sunit = str(args.sunit or "all").strip() or "all"
    rows: list[str] = []
    for item in _arr(doc, "spec_baseline"):
        sid = str(item.get("id") or "")
        if not sid.startswith("SPEC-"):
            continue
        if sunit.lower() != "all":
            tokens = {t.strip() for t in str(item.get("applies") or "").split(",") if t.strip()}
            if tokens and not (tokens & {"all", "*", sunit}):
                continue
        rule = _cell(item.get("rule")).replace("\n", " ")
        anchor = _cell(item.get("anchor"))
        sha8 = _cell(item.get("sha"))[:8]
        rows.append(f"{sid} {rule} ｜源 {anchor} sha:{sha8}")
    print("【规范携带块｜Rule 22.4e｜CLI 生成，禁改写/转译】")
    if rows:
        for row in rows:
            print(row)
    else:
        print("spec_baseline:none(经 spec-scan 确认)")
    print("回执必须含逐条核验表：`SPEC-<nn> | 观测:… | PASS`；缺表=本单元不成立。")
    return 0


# ── spec-scan：规范候选扫描（2026-11-26 task-spec-consumption-chain S4）────────
# What: 从项目指令正文、约定规范目录、计划模板、项目技能、需求文本、产物资产六个来源
#       收集「实际存在的规范文件」，输出稳定排序候选；--write 时把候选登记为 spec_baseline
#       的 SRC-* 行、sidecar 与 findings 收据（先删后写，保证幂等）。
# Why: 规范散落在仓库多个位置，Agent 手抄会漏；把发现逻辑收口到 CLI + 权威源，
#       spec-brief/机器门才能消费同一份稳定事实（Rule 22.4e）。

_SPEC_TOKEN_RE = re.compile(r"(?<![A-Za-z0-9_./-])(?:\./)?(?:[A-Za-z0-9_.@-]+/)*[A-Za-z0-9_.@-]+\.[A-Za-z0-9]{1,8}")
_SPEC_CONVENTION_DIRS = ("docs/standards", ".zcode/specs", "openspec/specs", "standards")
_SPEC_TEMPLATE_DIRS = (".zcode/plan-templates", ".claude/plan-templates")
_SPEC_SKILL_GLOBS = (".zcode/skills/*/SKILL.md", ".claude/skills/*/SKILL.md")
_SPEC_ASSET_PATTERNS = ("bible*", "canon*", "continuity*", "*-map.*", "*registry*")
_SPEC_CAPS = {"agents-path": 20, "skill": 30, "requirement": 20, "asset": 20}
_SPEC_RECEIPT_ID = "F-SPEC-SCAN"


def _spec_infer_project_root(plan_dir: Path) -> Path:
    """向上走查含 AGENTS.md / CLAUDE.md / .git 的祖先作为项目根；兜底 plan-dir 父目录。"""
    for p in (plan_dir, *plan_dir.parents):
        if any((p / marker).exists() for marker in ("AGENTS.md", "CLAUDE.md", ".git")):
            return p
    return plan_dir.parent


def _spec_rel(path: Path, project_root: Path) -> str:
    """路径相对项目根的统一 POSIX 表示；根外路径保留原样，避免丢可追溯性。"""
    try:
        rel = os.path.relpath(str(path), str(project_root))
    except ValueError:  # 跨盘符（Windows）等不可相对化场景
        return str(path)
    if rel == ".." or rel.startswith(".." + os.sep):
        return str(path)
    return Path(rel).as_posix()


def _spec_sha12(path: Path) -> str:
    """文件 sha256 前 12 位；分块读避免大文件一次性入内存，读失败返回空串（显式可见）。"""
    digest = hashlib.sha256()
    try:
        with path.open("rb") as fh:
            for chunk in iter(lambda: fh.read(65536), b""):
                digest.update(chunk)
    except OSError:
        return ""
    return digest.hexdigest()[:12]


def _dedup(seq: list[str]) -> list[str]:
    """按首次出现去重（保序），用于路径 token 上限裁剪前的稳定归一。"""
    seen: set[str] = set()
    out: list[str] = []
    for item in seq:
        if item not in seen:
            seen.add(item)
            out.append(item)
    return out


def _spec_tokens(text: str, project_root: Path, plan_dir: Path) -> list[str]:
    """从正文抽「带扩展名的路径 token」并只保留实际存在者；URL 与不存在路径一律不算。"""
    out: list[str] = []
    for match in _SPEC_TOKEN_RE.finditer(text or ""):
        token = match.group(0).rstrip(".,;:")
        if not token or "://" in token:
            continue
        raw = Path(token)
        probe = raw if raw.is_absolute() else project_root / token
        if not probe.exists():
            alt = plan_dir / token
            if not alt.exists():
                continue
            probe = alt
        out.append(_spec_rel(probe.resolve(), project_root))
    return _dedup(out)


def _spec_add(found: dict[str, dict[str, Any]], rel: str, cls: str, origin: str,
              project_root: Path, source: Path) -> None:
    """按路径去重写入候选；同路径 must 覆盖 ref，同级先到先得（配合源顺序保证确定性）。"""
    if not rel:
        return
    rank = 0 if cls == "must" else 1
    prev = found.get(rel)
    if prev is not None and rank >= (0 if prev["cls"] == "must" else 1):
        return
    found[rel] = {"path": rel, "cls": cls, "origin": origin, "sha": _spec_sha12(source)}


def _spec_scan_candidates(project_root: Path, plan: Path, doc: dict[str, Any],
                          scope_raw: str) -> list[dict[str, Any]]:
    """六源收集；源①先于②③...，最终统一按 (must 前 ref 后, 路径字典序) 排序编号。"""
    found: dict[str, dict[str, Any]] = {}
    # ① 项目指令文件（must）+ 正文中存在的路径 token（ref）
    for name in ("AGENTS.md", "CLAUDE.md"):
        p = project_root / name
        if not p.is_file():
            continue
        _spec_add(found, name, "must", "agents", project_root, p)
        for rel in _spec_tokens(p.read_text(encoding="utf-8", errors="replace"),
                                project_root, plan)[:_SPEC_CAPS["agents-path"]]:
            probe = project_root / rel
            _spec_add(found, rel, "ref", "agents-path", project_root,
                      probe if probe.is_file() else plan / rel)
    # ② 约定规范目录：目录存在才扫其顶层 *.md（must）
    for d in _SPEC_CONVENTION_DIRS:
        base = project_root / d
        if base.is_dir():
            for p in sorted(base.glob("*.md")):
                _spec_add(found, _spec_rel(p, project_root), "must", "convention", project_root, p)
    # ③ 项目级计划模板目录（ref）
    for d in _SPEC_TEMPLATE_DIRS:
        base = project_root / d
        if base.is_dir():
            for p in sorted(list(base.glob("*.md")) + list(base.glob("*.template.json"))):
                _spec_add(found, _spec_rel(p, project_root), "ref", "template", project_root, p)
    # ④ 项目级技能（ref，上限 30）
    skills: list[Path] = []
    for pattern in _SPEC_SKILL_GLOBS:
        skills.extend(project_root.glob(pattern))
    for p in sorted(set(skills), key=lambda x: _spec_rel(x, project_root))[:_SPEC_CAPS["skill"]]:
        _spec_add(found, _spec_rel(p, project_root), "ref", "skill", project_root, p)
    # ⑤ 需求行文本中存在的路径 token（must，上限 20）
    req_tokens: list[str] = []
    for item in _arr(doc, "requirements"):
        req_tokens.extend(_spec_tokens(str(item.get("text") or ""), project_root, plan))
    for rel in _dedup(req_tokens)[:_SPEC_CAPS["requirement"]]:
        probe = project_root / rel
        _spec_add(found, rel, "must", "requirement", project_root,
                  probe if probe.is_file() else plan / rel)
    # ⑥ --scope（及 scope_limits）路径向上祖先 ≤3 层的设定资产（must，上限 20）
    scopes = [s.strip() for s in str(scope_raw or "").split(",") if s.strip()]
    for item in _arr(doc, "scope_limits"):
        for key in ("allow", "deny"):
            vals = item.get(key)
            if isinstance(vals, list):
                scopes.extend(str(v).strip() for v in vals if str(v).strip())
    assets: list[Path] = []
    for raw in scopes:
        rp = Path(raw)
        if rp.is_absolute():
            base = rp
        elif (project_root / raw).exists() or not (plan / raw).exists():
            base = project_root / raw
        else:
            base = plan / raw
        if base.is_file():
            base = base.parent
        for d in (base, base.parent, base.parent.parent):
            if not d.is_dir():
                continue
            for child in d.iterdir():
                if child.is_file() and any(fnmatch.fnmatch(child.name, pat)
                                           for pat in _SPEC_ASSET_PATTERNS):
                    assets.append(child)
                elif child.is_dir() and child.name == "cards":
                    assets.extend(p for p in child.iterdir() if p.is_file())
    for p in sorted(set(assets), key=lambda x: _spec_rel(x, project_root))[:_SPEC_CAPS["asset"]]:
        _spec_add(found, _spec_rel(p, project_root), "must", "asset", project_root, p)
    ordered = sorted(found.values(), key=lambda c: (0 if c["cls"] == "must" else 1, c["path"]))
    for i, cand in enumerate(ordered, 1):
        cand["id"] = f"SRC-{i}"
    return ordered


def cmd_spec_scan(args: argparse.Namespace) -> int:
    """扫描规范候选；缺省 dry-run 只打印，--write 才落盘三件（baseline/sidecar/findings）。"""
    plan = Path(args.plan_dir).resolve()
    if not state_path(plan).is_file():
        print(f"planctl: spec-scan: plan-state.json 不存在: {state_path(plan)}", file=sys.stderr)
        return 2  # 与 check 的输入异常口径一致；无权威源禁止扫描落盘
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    project_root = (Path(args.project_root).resolve() if args.project_root
                    else _spec_infer_project_root(plan))
    if not project_root.is_dir():
        raise PlanctlError(f"--project-root 缺失或非目录: {project_root}")
    candidates = _spec_scan_candidates(project_root, plan, doc, str(args.scope or ""))
    at = now_iso()
    must = sum(1 for c in candidates if c["cls"] == "must")
    ref = len(candidates) - must
    receipt = f"[spec-scan] n={len(candidates)} must={must} ref={ref} at={at}"
    write = bool(getattr(args, "write", False)) and not bool(getattr(args, "dry_run", False))
    if not write:
        for c in candidates:
            print(f"id={c['id']} cls={c['cls']} origin={c['origin']} path={c['path']}")
        print(receipt + " (dry-run 未落盘)")
        return 0
    # ① spec_baseline：先删全部旧 SRC-* 再写新行 → 重复执行结果恒定
    baseline = [x for x in _arr(doc, "spec_baseline")
                if not str(x.get("id") or "").startswith("SRC-")]
    for c in candidates:
        baseline.append(normalize_entry("spec_baseline", {
            "id": c["id"], "verbatim": c["path"], "anchor": c["origin"],
            "rule": "pending", "cls": c["cls"], "origin": c["origin"], "sha": c["sha"],
        }))
    doc["spec_baseline"] = baseline
    commit_state(plan, doc)
    # ② sidecar：扫描快照（机器门 B19 消费面）
    atomic_write(plan / ".spec-scan.json", json_bytes({
        "at": at, "project_root": str(project_root), "must": must, "ref": ref,
        "candidates": [{"id": c["id"], "path": c["path"], "cls": c["cls"],
                        "origin": c["origin"], "sha": c["sha"]} for c in candidates],
    }))
    # ③ findings 收据：复用既有 add 通道；先移除旧收据保证幂等
    fresh = read_state(plan)
    fresh["findings"] = [f for f in _arr(fresh, "findings")
                         if f.get("id") != _SPEC_RECEIPT_ID and f.get("source") != "spec-scan"]
    commit_state(plan, fresh)
    with contextlib.redirect_stdout(io.StringIO()):
        cmd_add(argparse.Namespace(plan_dir=str(plan), section="findings",
                                   json=json.dumps({"id": _SPEC_RECEIPT_ID, "text": receipt,
                                                    "source": "spec-scan"}, ensure_ascii=False)))
    for c in candidates:
        print(f"id={c['id']} cls={c['cls']} origin={c['origin']} path={c['path']}")
    print(receipt + " (--write 已落盘)")
    return 0


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
  # Rule 113 输出示例契约：凡声明 JSON/Markdown 表格等格式，必须写完整示例+同结构模板+VC 引用；完整可照抄实例见 templates/task_plan.md「🧩 输出示例与格式契约」区块
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
    # [2026-11-25 task-json-template P1] 新入口：结构化 JSON 模板（唯一勾选源）；旧参数保留但 deprecated。
    p.add_argument("--template-json", metavar="FILE",
                   help="可选：读取 JSON 原生模板，写 template_ref/template_doc/template_checks（推荐；勾选唯一权威源）")
    p.add_argument("--template-body-from", metavar="FILE",
                   help="DEPRECATED：读取该文件全文写入 template_body（仅供旧计划兼容，勿与 --template-json 同传）")

    p = add_cmd("get", "输出整份/某段/某条目 JSON", cmd_get)
    # [2026-11-22 task-jsonderive-deploy-20261122] choices 扩到顶层全集，使新对象/标量字段可读。
    p.add_argument("--section", choices=("tags", *TOP_LEVEL_KEYS))
    p.add_argument("--id")

    # [2026-11-25 task-planctl-recover] 压缩恢复专用命令：核心数据获取能力收口到 planctl；
    #   升级「恢复时能拿到什么」只改 cmd_recover 一处，hook 与 selftest 不再各自引用旁路实现。
    p = add_cmd("recover", "压缩恢复：权威源核心状态 + 技能正文全文直接内联，产出注入包（参数指定字段集）", cmd_recover)
    p.epilog = (
        "示例（可照抄）：\n"
        "  python3 planctl.py recover --plan-dir <计划目录>\n"
        "  python3 planctl.py recover --plan-dir <计划目录> --fields requirements,goal,mustkeep\n"
        "  python3 planctl.py recover --plan-dir <计划目录> --fields requirements,goal --max-lines 40"
    )
    p.add_argument("--fields", help="逗号分隔核心字段（默认 skill_contract,requirements,goal,phase,recent_actions,next_step,decisions,mustkeep,git_baseline）")
    p.add_argument("--max-lines", type=int, default=150, help="任务状态块注入行数上限（默认 150；技能正文不受限，落盘全文不受限）")

    # [2026-11-24 task-compact-skill-always] 无在途计划也须无条件注入技能契约：独立子命令，
    #   绕过 add_cmd 的 --plan-dir required=True（本命令不读权威源，不需要计划目录）。
    #   直接 sub.add_parser + set_defaults，与 add_cmd 的 handler 绑定方式一致。
    p_skill = sub.add_parser(
        "recover-skill",
        help="无条件注入技能正文 SKILL.md 全文（无在途计划时压缩恢复用，不读权威源）",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p_skill.set_defaults(handler=cmd_recover_skill)

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

    # [2026-11-26 task-spec-consumption-chain S3] Rule 22.4e 规范携带块 CLI 生成入口。
    # Why: 派发 prompt 中的规范块必须来自 plan-state.json 单一权威源（禁 Agent 手抄/改写），
    #      --sunit 缺省 all 保持兼容：无筛选时输出全部 SPEC 行。
    p = add_cmd("spec-brief", "生成规范携带块（Rule 22.4e，stdout 纯文本）", cmd_spec_brief)
    p.epilog = (
        "示例（可照抄）：\n"
        "  python3 planctl.py spec-brief --plan-dir <计划目录>\n"
        "  python3 planctl.py spec-brief --plan-dir <计划目录> --sunit S3\n"
    )
    p.add_argument("--sunit", default="all", help="S-unit id（如 S3）；缺省 all=全部 SPEC 行")

    # [2026-11-26 task-spec-consumption-chain S4] 规范候选扫描入口。
    # Why: 缺省 --write=false（dry-run 只打印不落盘）；所有新参数带默认值，旧调用行为不变。
    p = add_cmd("spec-scan", "扫描规范候选（六源；缺省 dry-run，--write 才落盘）", cmd_spec_scan)
    p.epilog = (
        "示例（可照抄）：\n"
        "  python3 planctl.py spec-scan --plan-dir <计划目录>\n"
        "  python3 planctl.py spec-scan --plan-dir <计划目录> --project-root <项目根> \\\n"
        "      --scope outputs/a/bible.md,outputs/a/story-map.md --write\n"
    )
    p.add_argument("--project-root", default="",
                   help="项目根（缺省=从 plan-dir 向上找到含 AGENTS.md/CLAUDE.md/.git 的目录，兜底 plan-dir 父目录）")
    p.add_argument("--scope", default="", help="逗号分隔产物路径（来源⑥资产祖先扫描）")
    p.add_argument("--write", action="store_true", default=False,
                   help="落盘 spec_baseline SRC-* / .spec-scan.json / findings 收据；缺省 dry-run")
    p.add_argument("--dry-run", action="store_true", default=False,
                   help="显式 dry-run（与 plan-brief 契约兼容；与 --write 同传时以 dry-run 为准）")
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
