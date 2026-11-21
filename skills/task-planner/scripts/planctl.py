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

ARRAY_SECTIONS = ("requirements", "goals", "vcs", "phases", "findings", "audits", "delegations")
TOP_LEVEL_KEYS = (
    "schema_version", "task_id", "plan_tier", "execution_lane", "created_at", "updated_at",
    *ARRAY_SECTIONS, "tags",
)

# 新增条目时补齐的合法默认面（Why：避免 Agent 手写半条目导致 schema 校验失败；
# 身份字段 id/round 仍强制，缺失即报错，不静默造 id）。
ENTRY_DEFAULTS: dict[str, dict[str, Any]] = {
    "requirements": {"text": "", "type": "手段", "vc": [], "tags": []},
    "goals": {"text": "", "tags": []},
    "vcs": {"criterion": "", "command": "", "status": "pending", "evidence": "", "tags": []},
    "phases": {"status": "pending", "s_units": [], "v_checks": [], "tags": []},
    "findings": {"text": "", "source": "", "tags": []},
    "audits": {"verdict": "REJECTED", "by": "", "counts": {"C": 0, "I": 0, "W": 0}, "at": "", "tags": []},
    "delegations": {"agent": "", "scope": "", "status": "pending", "tags": []},
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
        known.update({"text": lambda v: isinstance(v, str)})
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
                      "v_checks": lambda v: isinstance(v, list) and all(isinstance(x, str) for x in v)})
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
    for key in TOP_LEVEL_KEYS:
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
    }
    for key, pred in simple.items():
        if key in doc and not pred(doc[key]):
            errs.append(f"$.{key}: 值非法（{doc[key]!r}）")

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
    else:
        raise PlanctlError(f"未知 section: {args.section}")
    emit(out)
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
    """修改条目的单字段；值按 coerce_value 做 JSON 类型提升。"""
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    hit = find_entry(doc, args.section, args.id)
    if hit is None:
        raise PlanctlError(f"{args.section} 中未找到 id={args.id!r}")
    hit[1][args.field] = coerce_value(args.value)
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


def cmd_render(args: argparse.Namespace) -> int:
    """从权威源生成 4 个 MD 视图（保留既有文件名以兼容 hook），全部原子写。

    WHY：视图只读派生，Agent/人不得直接编辑；每次 render 全量覆盖，杜绝 JSON 与 MD 漂移。
    """
    plan = check_plan_dir(args.plan_dir)
    doc = read_state(plan)
    try:
        idx = read_tag_index(plan)
    except PlanctlError:
        idx = {}  # 索引损坏不影响视图生成（状态文件仍是权威源），但不吞掉写入错误
    tid = doc["task_id"]
    stamp = f"- task_id: `{tid}`\n- 时间: created_at={doc['created_at']} / updated_at={doc['updated_at']}\n"
    meta = (f"- plan_tier: `{doc['plan_tier']}` / execution_lane: `{doc['execution_lane']}` "
            f"/ schema_version: {doc['schema_version']}\n")
    top_tags = ", ".join(doc["tags"]) or "（无）"
    views: dict[str, str] = {}

    views["task_plan.md"] = "\n".join([
        GENERATED_HEADER, f"# Task Plan: {tid}", "", stamp.rstrip(), meta.rstrip(),
        f"- 顶层 tags: {top_tags}", "", "## Requirements（用户需求）",
        _md_table(["id", "type", "text", "vc", "tags"],
                  [[r.get("id"), r.get("type"), r.get("text"), r.get("vc", []), r.get("tags", [])]
                   for r in doc["requirements"]]),
        "", "## Goals（目标单元）",
        _md_table(["id", "text", "tags"],
                  [[g.get("id"), g.get("text"), g.get("tags", [])] for g in doc["goals"]]),
        "", "## Phases（阶段状态）",
        _md_table(["id", "status", "s_units", "v_checks", "tags"],
                  [[p.get("id"), p.get("status"), p.get("s_units", []), p.get("v_checks", []),
                    p.get("tags", [])] for p in doc["phases"]]),
        "", "## R → VC 映射",
        _md_table(["requirement", "vcs"],
                  [[r.get("id"), r.get("vc", [])] for r in doc["requirements"]]), "",
    ])

    views["progress.md"] = "\n".join([
        GENERATED_HEADER, f"# Progress: {tid}", "", stamp.rstrip(), "",
        "## Phase 状态",
        _md_table(["id", "status", "tags"],
                  [[p.get("id"), p.get("status"), p.get("tags", [])] for p in doc["phases"]]),
        "", "## 审计轮次",
        _md_table(["round", "verdict", "by", "C", "I", "W", "at", "tags"],
                  [[a.get("round"), a.get("verdict"), a.get("by"),
                    a.get("counts", {}).get("C"), a.get("counts", {}).get("I"),
                    a.get("counts", {}).get("W"), a.get("at"), a.get("tags", [])]
                   for a in doc["audits"]]),
        "", "## Delegations（派发登记）",
        _md_table(["id", "agent", "scope", "status", "tags"],
                  [[d.get("id"), d.get("agent"), d.get("scope"), d.get("status"),
                    d.get("tags", [])] for d in doc["delegations"]]), "",
    ])

    views["verification.md"] = "\n".join([
        GENERATED_HEADER, f"# Verification: {tid}", "", stamp.rstrip(), "",
        "## Verification Contract（VC 状态与判据）",
        _md_table(["id", "status", "criterion", "command", "evidence", "tags"],
                  [[v.get("id"), v.get("status"), v.get("criterion"), v.get("command"),
                    v.get("evidence"), v.get("tags", [])] for v in doc["vcs"]]), "",
    ])

    local_refs = sorted({ref for refs in idx.values() for ref in refs if ref.startswith(tid + "#")})
    views["findings.md"] = "\n".join([
        GENERATED_HEADER, f"# Findings: {tid}", "", stamp.rstrip(), "",
        "## Findings",
        _md_table(["id", "text", "source", "tags"],
                  [[f.get("id"), f.get("text"), f.get("source"), f.get("tags", [])]
                   for f in doc["findings"]]),
        "", "## 本任务 tag 倒排引用",
        "\n".join(f"- {ref}" for ref in local_refs) or "- （无）", "",
    ])

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
        epilog="输出约定：管理命令=JSON stdout；check=单行 PLANCTL CHECK ...；错误=stderr",
    )
    sub = parser.add_subparsers(dest="command", required=True, title="subcommands")

    def add_cmd(name: str, help_text: str, handler: Callable[..., int]) -> argparse.ArgumentParser:
        p = sub.add_parser(name, help=help_text)
        p.add_argument("--plan-dir", required=True, help="计划目录（含 plan-state.json）")
        p.set_defaults(handler=handler)
        return p

    p = add_cmd("init", "从模板生成 plan-state.json（原子写）", cmd_init)
    p.add_argument("--task-id", required=True)
    p.add_argument("--tier", choices=("standard", "mini"))
    p.add_argument("--lane", choices=("L0", "L0-T", "L0-E", "L1", "L2"))
    p.add_argument("--force", action="store_true", help="允许覆盖已有状态（谨慎）")

    p = add_cmd("get", "输出整份/某段/某条目 JSON", cmd_get)
    p.add_argument("--section", choices=("tags", *ARRAY_SECTIONS))
    p.add_argument("--id")

    add_cmd("status", "输出 Phase/VC/审计状态摘要 JSON", cmd_status)
    add_cmd("validate", "schema 校验（rc 0 通过 / 1 失败）", cmd_validate)

    p = add_cmd("set", "修改条目单字段", cmd_set)
    p.add_argument("--section", required=True, choices=ARRAY_SECTIONS)
    p.add_argument("--id", required=True)
    p.add_argument("--field", required=True)
    p.add_argument("--value", required=True)

    p = add_cmd("add", "新增条目", cmd_add)
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

    for name, help_text, handler in (("vc-pass", "VC → pass", cmd_vc_pass),
                                     ("vc-fail", "VC → fail", cmd_vc_fail)):
        p = add_cmd(name, help_text, handler)
        p.add_argument("--id", required=True)

    p = add_cmd("audit-add", "追加审计轮次", cmd_audit_add)
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

    add_cmd("render", "生成 4 个 MD 派生视图", cmd_render)
    add_cmd("backup", "手动备份权威源", cmd_backup)

    p = add_cmd("restore", "从 .history 恢复（默认最近一次）", cmd_restore)
    p.add_argument("--version", type=int, help="history 中的 1-based 序号")

    add_cmd("history", "列出可用备份版本", cmd_history)

    p = add_cmd("check", "机器门判定（stdout 单行 PLANCTL CHECK）", cmd_check)
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
