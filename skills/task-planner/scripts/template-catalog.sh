#!/usr/bin/env bash
# [2026-11-22 task-template-catalog-20261122] template-catalog.sh — 模板检索/管理 CLI（用户诉求：模板匹配流程化+可克隆派生）
# WHAT: 枚举「当前项目级 + 用户级(全局 + 安装位) + 内置」计划模板，输出模板名/简介/适配场景/功能；
#       支持 add/clone/derive 固化模板沉淀流程。仅文件扫描 + 可选 JSON 清单缓存，不引入 SQL/DB（D1 决策）。
# WHY:  旧 --list(init-session.sh:21-53) 仅人读文本、单项目 scope、无场景/功能字段，匹配靠读散文与固定流程；
#       统一 template_meta 注释块(D2)提供机器可读元数据，任务初期调 list --json 即可稳定匹配模板。
# 元数据契约: 模板头 `<!-- template_meta: {"name":…,"summary":…,"scenarios":[…],"features":[…]} -->`
#             缺失时回退到注释散文启发式抽取(适用场景/触发关键词/描述)，兼容存量与自定义模板。
# Usage:
#   template-catalog.sh list [--scope all|builtin|project|user|user-global|user-install] [--json] [--query <关键词>] [--recommend <任务描述>] [--include-installs]
#   template-catalog.sh add <name> [--from <type|path>] [--scope project|user-global] [--dry-run] [--force]
#   template-catalog.sh clone --from <type|path> --to <name> [--scope project|user-global] [--dry-run] [--force]
#   template-catalog.sh derive --from <type|path> --to <name> [--prune <段名,段名>] [--scope project|user-global] [--dry-run] [--force]
#   template-catalog.sh to-json [--dry-run|--write]  # 33 个骨架模板 → templates/json/*.template.json（默认 dry-run）
#   template-catalog.sh --help | -h
# [2026-11-25 task-json-template P5] JSON 原生模板治理:
#   What: list --json 同时列出 templates/json/*.template.json（source=json）与旧 MD（source=legacy）；add/clone/derive 可用 JSON 模板为源；保留 P2 的 to-json。
#   Why:  用户批准「JSON 原生模板 + 结构化勾选」；JSON 是权威源，MD 仅兼容视图，治理脚本不得再把 MD 正文当模板真源。
# 输出契约: list 默认人读表; --json 输出稳定 JSON {"templates":[{file,type,name,summary,scenarios,features,path,scope,default,valid,source,preferred},…]}
#           add/clone/derive stdout 单行结果行 `CATALOG <ACTION> <OK|DRY|FAIL> <path>`；错误走 stderr。
# exit: 0=成功 1=业务失败(源不存在/同名冲突等) 2=用法错误
# 作用域优先级(去重): project > user-global > user-install > builtin
set -euo pipefail

TCAT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TCAT_SCRIPT_DIR
exec python3 - "$@" <<'PY'
import os, sys, re, json, glob, shutil, argparse, datetime

SCRIPT_DIR = os.path.dirname(os.path.abspath(sys.argv[0]))
# 兼容内嵌执行: sys.argv[0] 是 '-'，改用环境变量或 cwd 不可靠 → 用 __file__ 占位由 bash 传入
# bash 调用 `python3 - "$@"` 时 sys.argv[0]='-'；真实脚本目录经 SCRIPT_DIR_ENV 传入
SCRIPT_DIR = os.environ.get("TCAT_SCRIPT_DIR", SCRIPT_DIR)
SKILL_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))
REPO_ROOT = os.path.abspath(os.path.join(SKILL_DIR, "..", ".."))
BUILTIN_DIR = os.path.join(SKILL_DIR, "templates")
BUILTIN_VARIANT = os.path.join(BUILTIN_DIR, "variant")
# [2026-11-25 P5] JSON 模板权威目录：与 P2 to-json / P1 init-session 同一真源，不再从 MD 正文反推元数据。
JSON_DIR = os.path.join(BUILTIN_DIR, "json")

META_RE = re.compile(r'<!--\s*template_meta:\s*(\{.*?\})\s*-->', re.S)
TYPE_RE = re.compile(r'<!--\s*template_type:\s*([A-Za-z0-9-]+)', re.M)
# [BUGFIX 2026-11-22 task-template-catalog] TYPE_FULL_RE 含尾部 `-->`：旧 TYPE_RE.sub 只替换到类型名，残留 ` -->` 产生 `<!-- template_type: X --> -->` 畸形头。
# 注意 re.sub replacement 若含反斜杠（meta JSON 的 `\"`）会被当转义序列破坏 JSON → 全部改用 lambda 作 replacement（返回字面串）。
TYPE_FULL_RE = re.compile(r'<!--\s*template_type:\s*[A-Za-z0-9-]+\s*-->', re.M)
TIER_RE = re.compile(r'(?:^<!--\s*plan_tier:\s*([A-Za-z0-9-]+)|^plan_tier:\s*([A-Za-z0-9-]+))', re.M)
LINEAGE_RE = re.compile(r'<!--\s*template-lineage:.*?-->', re.S)

def die(msg, code=1):
    print(f"[catalog] ERROR: {msg}", file=sys.stderr)
    sys.exit(code)

def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()

# ---- [2026-11-25 P5] JSON 模板读取：meta/sections 即权威，缺字段显式报错（不静默回退 MD） ----
def load_json_template(path):
    """读取 JSON 原生模板；结构不完整直接失败，避免用残缺元数据克隆出漂移模板。"""
    try:
        with open(path, encoding="utf-8") as f:
            doc = json.load(f)
    except (OSError, ValueError) as e:
        die(f"JSON 模板读取失败: {path} ({e})")
    meta, sections = doc.get("meta"), doc.get("sections")
    if not isinstance(meta, dict) or not isinstance(sections, list):
        die(f"JSON 模板缺 meta/sections: {path}")
    return doc

# ---- 元数据解析: JSON 原生 > template_meta 优先 → 启发式回退 ----
def parse_meta(path):
    # [2026-11-25 P5] JSON 后缀直接取 meta 字段；type 以 meta.template_type 为准（task_plan.template.json=general）
    if path.endswith(".template.json"):
        doc = load_json_template(path)
        meta = doc["meta"]
        lineage = meta.get("lineage") if isinstance(meta.get("lineage"), dict) else {}
        fallback_type = ("general" if os.path.basename(path) == "task_plan.template.json"
                         else re.sub(r'\.template\.json$', '', os.path.basename(path)))
        return {
            "type": str(meta.get("template_type") or fallback_type),
            "name": str(meta.get("name") or fallback_type),
            "summary": str(meta.get("summary") or ""),
            "scenarios": meta.get("scenarios") if isinstance(meta.get("scenarios"), list) else [],
            "features": meta.get("features") if isinstance(meta.get("features"), list) else [],
            "tier": str(meta.get("tier") or "standard"),
            "lineage": lineage,
            "meta_source": "json",
        }
    text = read(path)
    m = META_RE.search(text)
    obj = None
    if m:
        try:
            obj = json.loads(m.group(1))
        except Exception:
            obj = None
    tm = TYPE_RE.search(text)
    ttype = tm.group(1) if tm else ""
    if not ttype:
        bn = os.path.basename(path)
        ttype = "general" if bn == "task_plan.md" else re.sub(r'-type\.md$', '', bn)
    tier_m = TIER_RE.search(text)
    tier = (tier_m.group(1) or tier_m.group(2)) if tier_m else "standard"
    if obj and isinstance(obj, dict):
        return {
            "type": str(obj.get("type") or ttype),
            "name": str(obj.get("name") or ttype),
            "summary": str(obj.get("summary") or ""),
            "scenarios": obj.get("scenarios") if isinstance(obj.get("scenarios"), list) else [],
            "features": obj.get("features") if isinstance(obj.get("features"), list) else [],
            "tier": str(obj.get("tier") or tier),
            "meta_source": "template_meta",
        }
    # 回退: 散文启发式
    name = ""
    h1 = re.search(r'^#\s+(.+)$', text, re.M)
    if h1:
        name = re.sub(r'\[.*?\]', '', h1.group(1)).strip()
    summary, scenarios, features = "", [], []
    for line in text.splitlines()[:20]:
        c = re.search(r'<!--\s*(.*?)\s*-->', line)
        if not c:
            continue
        s = c.group(1).strip()
        if re.match(r'^(适用场景|适用于|触发词|触发关键词)', s):
            val = re.sub(r'^(适用场景|适用于|触发词|触发关键词)\s*[:：]\s*', '', s)
            scenarios += [x.strip() for x in re.split(r'[/、,，]', val) if x.strip()][:6]
        elif not summary and s and not s.startswith(('template_type', 'plan_tier', 'template-lineage', 'planctl', '人工门', '渲染契约')):
            summary = s[:80]
    for line in text.splitlines():
        h = re.match(r'^##\s+(.+)$', line)
        if h:
            features.append(re.sub(r'[🔍📎🎯🧮⚙️📦🛡]', '', h.group(1)).strip())
        if len(features) >= 6:
            break
    return {
        "type": ttype, "name": name or ttype, "summary": summary,
        "scenarios": scenarios[:6], "features": features[:6],
        "tier": tier, "meta_source": "heuristic",
    }

# ---- 作用域目录发现（复用 init-session.sh:64-79 向上遍历逻辑） ----
def find_project_templates(cwd):
    d = os.path.abspath(cwd)
    while d != "/":
        for sub in (".claude/plan-templates", ".zcode/plan-templates"):
            p = os.path.join(d, sub)
            if os.path.isdir(p):
                return p
        d = os.path.dirname(d)
    return None

def collect_scope(scope, include_installs):
    """返回 [(path, scope_label)]；scope_label ∈ project|user-global|user-install|builtin"""
    out = []
    cwd = os.getcwd()
    if scope in ("all", "project"):
        pd = find_project_templates(cwd)
        if pd:
            for f in glob.glob(os.path.join(pd, "*-type.md")):
                out.append((f, "project"))
    if scope in ("all", "user", "user-global"):
        home = os.path.expanduser("~")
        for sub in (".claude/plan-templates", ".zcode/plan-templates"):
            gd = os.path.join(home, sub)
            if os.path.isdir(gd):
                for f in glob.glob(os.path.join(gd, "*-type.md")):
                    out.append((f, "user-global"))
    if scope in ("all", "builtin", "user", "user-install"):
        for f in glob.glob(os.path.join(BUILTIN_VARIANT, "*-type.md")):
            out.append((f, "builtin"))
        base = os.path.join(BUILTIN_DIR, "task_plan.md")
        if os.path.isfile(base):
            out.append((base, "builtin"))
        # [2026-11-25 P5] JSON 模板并入 builtin 清单；与 MD 同 type 时 by source=json 优先（下方 dedup）。
        for f in glob.glob(os.path.join(JSON_DIR, "*.template.json")):
            out.append((f, "builtin"))
    if include_installs and scope in ("all", "user", "user-install"):
        for plat in ("zcode", "agents", "claude", "cursor"):
            vd = os.path.expanduser(f"~/.{plat}/skills/task-planner/templates/variant")
            for f in glob.glob(os.path.join(vd, "*-type.md")):
                out.append((f, "user-install"))
    return out

SCOPE_RANK = {"project": 0, "user-global": 1, "user-install": 2, "builtin": 3}

def valid_types():
    ts = {"general"}
    # [2026-11-25 P5] JSON 模板类型纳入白名单（无 MD 骨架的 JSON-only 模板也应合法）。
    for f in glob.glob(os.path.join(JSON_DIR, "*.template.json")):
        ts.add(parse_meta(f)["type"])
    for f in glob.glob(os.path.join(BUILTIN_VARIANT, "*-type.md")):
        ts.add(re.sub(r'-type\.md$', '', os.path.basename(f)))
    pd = find_project_templates(os.getcwd())
    if pd:
        for f in glob.glob(os.path.join(pd, "*-type.md")):
            ts.add(os.path.basename(f)[:-len("-type.md")])
    return ts

def default_type():
    pd = find_project_templates(os.getcwd())
    if pd and os.path.isfile(os.path.join(pd, "default")):
        try:
            v = read(os.path.join(pd, "default")).splitlines()[0].strip()
            if v:
                return v
        except Exception:
            pass
    return os.environ.get("TASK_TEMPLATE_DEFAULT", "") or "general"

def resolve_source(ref, scope):
    """type 名或路径 → 源文件绝对路径。
    [BUGFIX 2026-11-22 task-template-catalog] 源解析优先级改为 builtin(当前安装位,含 template_meta 权威源) > project > user-global > user-install。
    旧实现按 SCOPE_RANK(project<user-global<user-install<builtin) 升序，导致命中旧部署位无 meta 模板 → clone 元数据启发式回退(scenarios 空)。"""
    if os.path.isfile(ref):
        return os.path.abspath(ref)
    entries = collect_scope("all", True)
    # builtin 优先（当前 skill 安装位=权威源），其余按 SCOPE_RANK
    # [2026-11-25 P5] JSON 模板优先于同 type 的 MD 骨架：JSON 是权威源（general → task_plan.template.json）
    json_name = ("task_plan.template.json" if ref == "general" else f"{ref}.template.json")
    for label in ["builtin"] + [k for k in sorted(SCOPE_RANK, key=lambda x: SCOPE_RANK[x]) if k != "builtin"]:
        for path, slabel in entries:
            if slabel == label and os.path.basename(path) == json_name:
                return path
    for label in ["builtin"] + [k for k in sorted(SCOPE_RANK, key=lambda x: SCOPE_RANK[x]) if k != "builtin"]:
        for path, slabel in entries:
            if slabel == label and os.path.basename(path) == f"{ref}-type.md":
                return path
    die(f"找不到源模板: {ref}")

def target_dir(scope):
    if scope == "project":
        # 项目级落位：CWD 向上最近的项目根（无 plan-templates 则用 cwd 所在项目根）
        pd = find_project_templates(os.getcwd())
        if pd:
            return pd
        d = os.path.abspath(os.getcwd())
        while d != "/":
            if os.path.isdir(os.path.join(d, ".zcode")) or os.path.isdir(os.path.join(d, ".claude")):
                return os.path.join(d, ".zcode", "plan-templates")
            d = os.path.dirname(d)
        return os.path.join(os.getcwd(), ".zcode", "plan-templates")
    if scope == "user-global":
        return os.path.join(os.path.expanduser("~"), ".zcode", "plan-templates")
    die(f"不支持的目标 scope: {scope}（仅 project/user-global）")

# ---- list ----
def cmd_list(args):
    vcs = valid_types()
    dflt = default_type()
    entries = collect_scope(args.scope, args.include_installs)
    dedup = {}
    for path, label in entries:
        meta = parse_meta(path)
        key = meta["type"]
        rec = dict(meta)
        source = "json" if path.endswith(".template.json") else "legacy"
        rec.update({
            "file": os.path.basename(path),
            "path": path,
            "scope": label,
            "default": (key == dflt),
            "valid": (key in vcs),
            # [2026-11-25 P5] 来源标注：JSON 为源、MD 为兼容视图（旧计划/自造模板）
            "source": source,
        })
        if source == "json":
            if os.path.basename(path) == "task_plan.template.json":
                md_path = os.path.join(BUILTIN_DIR, "task_plan.md")
            else:
                md_path = os.path.join(BUILTIN_VARIANT,
                                       re.sub(r'\.template\.json$', '-type.md', os.path.basename(path)))
            rec["legacy_path"] = md_path if os.path.isfile(md_path) else ""
        else:
            rec["legacy_path"] = path
        # [2026-11-25 P5] JSON 与旧 MD 并列输出（各标 source），同来源同 type 再按 scope 去重。
        dkey = (key, source)
        if dkey not in dedup or SCOPE_RANK[label] < SCOPE_RANK[dedup[dkey]["scope"]]:
            dedup[dkey] = rec
    rows = sorted(dedup.values(), key=lambda r: (0 if r["source"] == "json" else 1, r["type"]))
    json_types = {r["type"] for r in rows if r["source"] == "json"}
    for r in rows:
        # preferred=JSON 权威源；MD 仅在无 JSON 同名模板时顶上（旧计划/自造模板兼容）
        r["preferred"] = (r["source"] == "json" or r["type"] not in json_types)
    # 关键词过滤/推荐排序
    if args.query or args.recommend:
        kw = (args.query or args.recommend or "").strip()
        toks = [t for t in re.split(r'[\s,，、/]+', kw) if t]
        def score(r):
            hay = " ".join([r["name"], r["summary"]] + r["scenarios"] + r["features"]).lower()
            return sum(1 for t in toks if t.lower() in hay)
        scored = [(score(r), i, r) for i, r in enumerate(rows)]
        if args.query:
            rows = [r for sc, _, r in scored if sc > 0]
        else:
            rows = [r for sc, i, r in sorted(scored, key=lambda x: (-x[0], x[1])) if sc > 0]
    if args.json:
        print(json.dumps({"templates": rows, "default": dflt, "count": len(rows)}, ensure_ascii=False, indent=2))
        return
    print(f"模板清单（scope={args.scope}，共 {len(rows)} 项；默认={dflt}）")
    print(f"{'TYPE':<24}{'SCOPE':<14}{'SOURCE':<9}{'NAME':<20}{'SUMMARY / SCENARIOS'}")
    for r in rows:
        sc = ",".join(r["scenarios"][:3])
        print(f"{r['type']:<24}{r['scope']:<14}{r['source']:<9}{r['name'][:18]:<20}{r['summary'][:40]} [{sc}]")

# ---- [2026-11-25 P5] JSON 源 → 兼容 MD 骨架：只从结构化字段重建，禁止整份 MD roundtrip ----
def render_md_from_json(src, meta, new_type, action, prune):
    """从 JSON 模板的 meta/sections 生成 MD 兼容骨架（JSON 仍是权威源，MD 只作人读/旧工具视图）。"""
    doc = load_json_template(src)
    jmeta = doc["meta"]
    lineage = jmeta.get("lineage") if isinstance(jmeta.get("lineage"), dict) else {}
    pruned = [str(x) for x in (lineage.get("pruned") or []) if str(x).strip()]
    pruned_keys = {norm_section(x) for x in pruned}
    if action == "derive" and prune:
        for seg in [s.strip() for s in prune.split(",") if s.strip()]:
            k = norm_section(seg)
            if k and k not in pruned_keys:
                pruned.append(seg)
                pruned_keys.add(k)
    sv = lineage.get("spec_version", 1)
    reason = ("variant=JSON 模板派生裁剪，裁剪面=" + (",".join(pruned) or "none")
              if action == "derive" else "variant=JSON 模板克隆派生，父模板见 parent 字段")
    mobj = {"type": new_type, "name": new_type, "summary": meta["summary"],
            "scenarios": meta["scenarios"], "features": meta["features"]}
    lines = [
        f'<!-- template_type: {new_type} -->',
        f'<!-- template_meta: {json.dumps(mobj, ensure_ascii=False)} -->',
        f'<!-- template-lineage: level=derived parent={meta["type"]}-type.md base=../task_plan.md '
        f'spec_version={sv} pruned="{",".join(pruned) or "none"}" pruned_reason="{reason}" -->',
        f'<!-- plan_tier: {meta.get("tier") or "standard"} -->',
        f'<!-- 渲染契约(task-json-template-20261125)：JSON 模板为源；本 MD 仅兼容视图，权威数据=plan-state.json 的 template_doc/template_checks -->',
        f'# Task Plan: [{meta["name"]}任务名称]',
        '',
    ]
    for sec in doc["sections"]:
        anchor = str(sec.get("anchor") or "## 未命名段")
        if norm_section(anchor) in pruned_keys:
            continue
        lines.append(anchor)
        if sec.get("kind") == "ref":
            ref = sec.get("ref") or {}
            lines.append(f'<!-- planctl ref: {ref.get("path", "")} / {ref.get("renderer", "")}（权威源=JSON 模板） -->')
        for b in sec.get("blocks") or []:
            kind = b.get("kind")
            if kind in ("markdown", "raw"):
                lines.append(str(b.get("text") or ""))
            elif kind == "table":
                header = [str(c) for c in (b.get("header") or [])]
                if header:
                    lines.append("| " + " | ".join(header) + " |")
                    lines.append("|" + "|".join("---" for _ in header) + "|")
                for row in (b.get("rows") or []):
                    lines.append("| " + " | ".join(str(c) for c in row) + " |")
            elif kind == "checklist":
                for item in (b.get("items") or []):
                    box = "x" if item.get("checked") else " "
                    lines.append(f'- [{box}] {item.get("text", "")}')
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"

# ---- add/clone/derive ----
def cmd_write(args, action):
    src = resolve_source(args.from_, args.scope)
    src_text = read(src)
    meta = parse_meta(src)
    new_type = args.to
    if not re.match(r'^[A-Za-z0-9-]+$', new_type):
        die(f"目标名非法（仅字母数字连字符）: {new_type}")
    ddir = target_dir(args.scope)
    dst = os.path.join(ddir, f"{new_type}-type.md")
    exists = os.path.isfile(dst)
    if exists and not args.force:
        die(f"同名模板已存在（未 --force 拒锁）: {dst}")
    # [2026-11-25 P5] JSON 源：从结构化字段重建 MD 骨架，保留源 meta/lineage（spec_version/pruned）；不复制整份 MD。
    if src.endswith(".template.json"):
        text = render_md_from_json(src, meta, new_type, action, getattr(args, "prune", None))
        status = "DRY" if args.dry_run else "OK"
        if not args.dry_run:
            os.makedirs(ddir, exist_ok=True)
            if exists:
                shutil.copy2(dst, dst + ".bak." + datetime.datetime.now().strftime("%Y%m%d%H%M%S"))
            with open(dst, "w", encoding="utf-8") as f:
                f.write(text)
        print(f"CATALOG {action.upper()} {status} {dst}")
        return
    # 改写 template_type（TYPE_FULL_RE 含尾部 -->；lambda replacement 避免反斜杠转义）
    text = src_text
    if TYPE_FULL_RE.search(text):
        text = TYPE_FULL_RE.sub(lambda m: f'<!-- template_type: {new_type} -->', text, count=1)
    else:
        text = f'<!-- template_type: {new_type} -->\n' + text
    # 改写 template_meta（name/type=新，其余继承）
    mobj = {"type": new_type, "name": new_type, "summary": meta["summary"],
            "scenarios": meta["scenarios"], "features": meta["features"]}
    mline = f'<!-- template_meta: {json.dumps(mobj, ensure_ascii=False)} -->\n'
    if META_RE.search(text):
        text = META_RE.sub(lambda m: mline.rstrip('\n'), text, count=1)
    else:
        # 插入在 template_type 行之后
        lines = text.splitlines(True)
        for i, ln in enumerate(lines):
            if TYPE_RE.search(ln):
                lines.insert(i + 1, mline)
                break
        else:
            lines.insert(0, mline)
        text = "".join(lines)
    # lineage 注入（派生登记）
    parent_type = meta["type"]
    pruned = ""
    if action == "derive" and getattr(args, "prune", None):
        pruned = args.prune
    reason = "variant=克隆派生，父模板见 parent 字段" if action != "derive" else f"variant=领域裁剪派生，裁剪面={pruned or '待填'}"
    lineage = f'<!-- template-lineage: level=derived parent={parent_type}-type.md base=../task_plan.md spec_version=1 pruned="{pruned or "none"}" pruned_reason="{reason}" -->\n'
    if LINEAGE_RE.search(text):
        text = LINEAGE_RE.sub(lambda m: lineage.rstrip('\n'), text, count=1)
    else:
        lines = text.splitlines(True)
        for i, ln in enumerate(lines):
            if TYPE_RE.search(ln):
                lines.insert(i + 1, lineage)
                break
        else:
            lines.insert(0, lineage)
        text = "".join(lines)
    # derive 的 --prune：删除匹配的 `## <段名>` 段（到下一 `## ` 或文末）
    if action == "derive" and pruned:
        for seg in [s.strip() for s in pruned.split(",") if s.strip()]:
            text = re.sub(r'(?ms)^##\s*' + re.escape(seg) + r'[^\n]*\n(?:^(?!##\s).*\n?)*', '', text)
    status = "DRY" if args.dry_run else "OK"
    if not args.dry_run:
        os.makedirs(ddir, exist_ok=True)
        if exists:
            shutil.copy2(dst, dst + ".bak." + datetime.datetime.now().strftime("%Y%m%d%H%M%S"))
        with open(dst, "w", encoding="utf-8") as f:
            f.write(text)
    print(f"CATALOG {action.upper()} {status} {dst}")

# ---- [2026-11-25 task-json-template-20261125] to-json: 骨架模板 → 结构化 JSON ----
# WHAT: 把 33 个计划骨架模板按 H2 锚段拆成 ref（planctl 渲染器负责的段，只记 path/renderer）与
#       blocks（领域段的说明文字/勾选条目/表格）；meta 逐字段来自 template_meta/template-lineage/template_type 注释。
# WHY:  用户明确否决「把整份 MD 原文读进 JSON」；JSON 只保留机器可消费结构与领域段的结构化内容，
#       lineage.pruned 声明的段是有意裁剪，禁止再生成 blocks。
REF_SECTIONS = {
    # norm(标题) -> (plan-state.json 路径, 渲染器名)
    "用户需求原文": ("requirements", "requirements_lines"),
    "requirements": ("requirements", "requirements_table"),
    "goal": ("goals", "goal_statement"),
    "goals": ("goals", "goals_table"),
    "goal单元表": ("goals", "goal_unit_table"),
    "phases": ("phases", "phases_table"),
    "phase骨架": ("phases", "phases_table"),
    "verificationcontract": ("vcs", "vc_table"),
    "vc表": ("vcs", "vc_table"),
    "rvc映射": ("requirements", "r_vc_map"),
    "根源覆盖表": ("root_causes", "root_causes_table"),
    "codereview配置": ("config", "code_review_table"),
    "调研需求与检索计划": ("research_status", "research_status_table"),
    "执行范围限制": ("scope_limits", "scope_limits_table"),
}

SECTION_IDS = {
    "用户需求原文": "sec-requirements", "requirements": "sec-requirements-table",
    "goal": "sec-goal", "goals": "sec-goals", "goal单元表": "sec-goal-units",
    "phases": "sec-phases", "phase骨架": "sec-phases",
    "verificationcontract": "sec-vc", "vc表": "sec-vc",
    "rvc映射": "sec-r-vc-map", "根源覆盖表": "sec-root-causes",
    "codereview配置": "sec-code-review", "调研需求与检索计划": "sec-research-status",
    "执行范围限制": "sec-scope-limits",
    "指令理解迭代草稿": "sec-understanding", "不变量声明区": "sec-invariants",
    "规范基线": "sec-spec-baseline", "进度产出基线": "sec-progress-baseline",
    "双轮质检与同步完整性声明": "sec-dual-qc", "核心目标达成裁决": "sec-goal-verdict",
    "变更标注表": "sec-changes", "必要知识储备": "sec-knowledge",
    "核心问题定义": "sec-core-question", "证据面清单": "sec-evidence",
    "currentphase": "sec-current-phase", "nextstep": "sec-next-step",
    "工具选择与编排": "sec-tool-selection", "防倒退终检": "sec-anti-regress",
    "收尾回读梳理记录": "sec-readthrough", "收尾对齐与清理": "sec-cleanup",
    "隔离决策": "sec-isolation-decision", "fmea预演": "sec-fmea",
    "原生todo同步": "sec-todo-sync", "keyquestions": "sec-key-questions",
    "decisionsmade": "sec-decisions", "errorsencountered": "sec-errors",
    "notes": "sec-notes", "driftlog": "sec-drift-log",
    "委派统计": "sec-delegation-stats", "subagenthandoff登记表": "sec-handoff",
    "batchreport": "sec-batch-report", "chain区块交接配置": "sec-chain",
    "任务分型": "sec-task-typing", "隔离与静默纪律": "sec-isolation-silence",
    "子代理隔离铁律": "sec-subagent-isolation",
    "子代理隔离与静默纪律": "sec-subagent-isolation",
    "子代理派发约束": "sec-subagent-dispatch", "评级契约": "sec-rating-contract",
    "参考": "sec-references", "回滚策略": "sec-rollback",
    "项目级连续性资产包": "sec-continuity-assets", "连续性模式": "sec-continuity-mode",
    "记忆整理协议": "sec-memory-protocol",
    "换代集分支：对象先验等级门禁等级联动": "sec-branch-tier",
}

# 勾选条目 id 前缀：稳定短名（如 EV-SELF、KN-01），按段名映射，未知段回落 CK。
SECTION_ID_PREFIX = {
    "证据面清单": "EV", "核心问题定义": "CQ", "必要知识储备": "KN",
    "原生todo同步": "TD", "任务分型": "TP", "隔离与静默纪律": "ISO",
    "子代理隔离铁律": "ISO", "子代理隔离与静默纪律": "ISO",
    "执行范围限制": "EX", "防倒退终检": "AR", "双轮质检与同步完整性声明": "QC",
    "工具选择与编排": "TL", "推导": "CK",
}

CHECKBOX_LINE_RE = re.compile(r'^\s*(?:[-*+]\s+)?\[([ xX])\]\s*(.*)$')
BOX_LINE_RE = re.compile(r'^\s*(?:[-*+]\s+)?([☐☑☒])\s*(.*)$')
TABLE_SEP_RE = re.compile(r'^\s*\|(?:\s*:?-{3,}:?\s*\|)+\s*$')
LINEAGE_KV_RE = re.compile(r'(\w+)\s*=\s*("[^"]*"|\'[^\']*\'|[^\s]+)')
MAX_TEXT_LEN = 2000  # 用户硬约束：单个 raw/text 字段不得超过 2000 字符


def norm_section(title):
    """归一化 H2 标题用于 pruned 比对：去括号内容/Rule 编号/emoji/空格，保留中英文数字。"""
    s = re.sub(r'[（(][^)）]*[)）]', '', title)
    s = re.sub(r'Rule\s*\d+(?:\.\d+)*', '', s, flags=re.I)
    return re.sub(r'[^\w]', '', s).lower()


def parse_lineage(text):
    """从 template-lineage 注释逐字段解析；注释缺失时给出诚实缺省（derived/base 指向主模板）。"""
    m = LINEAGE_RE.search(text)
    if not m:
        return {"level": "derived", "parent": "../task_plan.md", "base": "../task_plan.md",
                "spec_version": 1, "pruned": [], "pruned_reason": ""}
    kv = {k: v.strip('"\'') for k, v in LINEAGE_KV_RE.findall(m.group(0))}
    pruned = [x.strip() for x in kv.get("pruned", "").split(",")
              if x.strip() and x.strip().lower() != "none"]
    try:
        spec_version = int(kv.get("spec_version", "1"))
    except ValueError:
        spec_version = 1
    return {
        "level": kv.get("level", "derived"),
        "parent": kv.get("parent", ""),
        "base": kv.get("base", ""),
        "spec_version": spec_version,
        "pruned": pruned,
        "pruned_reason": kv.get("pruned_reason", ""),
    }


def split_sections(text):
    """按 H2 切段；H3 及以下内容归属当前 H2，头部注释/preamble 不产出 section。"""
    sections = []
    cur = None
    for line in text.splitlines():
        if line.startswith("## "):
            cur = {"anchor": line.strip(), "lines": []}
            sections.append(cur)
        elif cur is not None:
            cur["lines"].append(line)
    return sections


def strip_comments(lines):
    """剥离 HTML 注释（含跨行）后再取说明文字；注释是元数据/理由，不是模板可见内容。"""
    out, in_comment = [], False
    for raw in lines:
        line = raw
        if in_comment:
            if "-->" in line:
                line = line.split("-->", 1)[1]
                in_comment = False
            else:
                continue
        while "<!--" in line:
            pre, rest = line.split("<!--", 1)
            if "-->" in rest:
                line = pre + rest.split("-->", 1)[1]
            else:
                line, in_comment = pre, True
                break
        if line.strip():
            out.append(line)
    return out


def split_row(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def parse_blocks(lines, title):
    """把领域段正文结构化为 markdown/table/checklist/raw 块；每项文本受 MAX_TEXT_LEN 约束。"""
    blocks, prose, items = [], [], []
    used_ids = set()
    prefix = SECTION_ID_PREFIX.get(norm_section(title), "CK")
    counter = [0]

    def item_id(text):
        counter[0] += 1
        words = re.findall(r'[A-Za-z][A-Za-z0-9]*', text)
        suffix = "-".join(w.upper() for w in words[:2]) if words else (
            re.sub(r'[^\w\u4e00-\u9fff]', '', text)[:6] or str(counter[0]))
        base = f"{prefix}-{suffix}"
        while base in used_ids:
            counter[0] += 1
            base = f"{prefix}-{suffix}-{counter[0]}"
        used_ids.add(base)
        return base

    def add_item(text, checked):
        items.append({"id": item_id(text), "text": text.strip(), "checked": checked, "note": ""})

    def flush_prose():
        if not prose:
            return
        text = "\n".join(prose).strip()
        del prose[:]
        while text:
            if len(text) <= MAX_TEXT_LEN:
                chunk, text = text, ""
            else:
                cut = text.rfind("\n", 0, MAX_TEXT_LEN + 1)
                if cut < 1:
                    cut = MAX_TEXT_LEN
                chunk, text = text[:cut], text[cut:].lstrip("\n")
            n = sum(1 for b in blocks if b["kind"] == "markdown") + 1
            blocks.append({"id": "note" if n == 1 else f"note-{n}",
                           "kind": "markdown", "text": chunk[:MAX_TEXT_LEN]})

    i = 0
    while i < len(lines):
        line = lines[i]
        if len(line) > MAX_TEXT_LEN:
            flush_prose()
            n = sum(1 for b in blocks if b["kind"] == "raw") + 1
            blocks.append({"id": f"raw-{n}" if n > 1 else "raw", "kind": "raw",
                           "format": "markdown", "text": line[:MAX_TEXT_LEN]})
            i += 1
            continue
        m = CHECKBOX_LINE_RE.match(line)
        if m:
            flush_prose()
            add_item(m.group(2), m.group(1).lower() == "x")
            i += 1
            continue
        m = BOX_LINE_RE.match(line)
        if m:
            flush_prose()
            add_item(m.group(2), m.group(1) in ("☑", "☒"))
            i += 1
            continue
        if line.lstrip().startswith("|") and i + 1 < len(lines) and TABLE_SEP_RE.match(lines[i + 1]):
            flush_prose()
            header = split_row(line)
            j, rows = i + 2, []
            while j < len(lines) and lines[j].lstrip().startswith("|"):
                rows.append(split_row(lines[j]))
                j += 1
            n = sum(1 for b in blocks if b["kind"] == "table") + 1
            blocks.append({"id": f"table-{n}" if n > 1 else "table", "kind": "table",
                           "header": header, "rows": rows})
            # 表格内 ☐/☑ 单元格同时登记为 checklist，保证勾选状态可机读
            for row in rows:
                for ci, cell in enumerate(row):
                    if "☐" in cell or "☑" in cell or "☒" in cell:
                        col = header[ci] if ci < len(header) else f"col{ci + 1}"
                        label = re.sub(r'[☐☑☒]', '', cell).strip()
                        row_label = row[0].strip() if row else ""
                        text = f"{row_label} · {col}" if row_label and row_label != label else (label or col)
                        add_item(text, "☑" in cell or "☒" in cell)
            i = j
            continue
        prose.append(line)
        i += 1
    flush_prose()
    if items:
        blocks.append({"id": "checks", "kind": "checklist", "items": items})
    return blocks


def json_sources():
    """33 个源固定顺序：主模板 1 + variant 31 + 项目级 rule-clause-cascade 1。"""
    out = [(os.path.join(BUILTIN_DIR, "task_plan.md"), "task_plan")]
    for f in sorted(glob.glob(os.path.join(BUILTIN_VARIANT, "*-type.md"))):
        out.append((f, re.sub(r'-type\.md$', '', os.path.basename(f))))
    project = os.path.join(REPO_ROOT, ".zcode", "plan-templates", "rule-clause-cascade-type.md")
    if os.path.isfile(project):
        out.append((project, "rule-clause-cascade"))
    return out


def convert_template(src, ttype):
    """结构化转换单个模板；不复制核心锚段正文（由 planctl 渲染器负责）。"""
    text = read(src)
    meta = parse_meta(src)
    if not meta["summary"]:
        # rule-clause-cascade 等无 template_meta 注释模板：从 `**适用**:` 行补摘要/场景
        fit = re.search(r'\*\*适用\*\*\s*[:：]\s*(.+)', text)
        if fit:
            meta["summary"] = fit.group(1).strip()
            meta["scenarios"] = [x.strip() for x in re.split(r'[/、,，]', meta["summary"])
                                 if x.strip()][:6]
    lineage = parse_lineage(text)
    pruned = {norm_section(x) for x in lineage["pruned"]}
    sections = []
    # 先剥离 HTML 注释再切段：task_plan.md 尾部示例注释含字面 `## Goal`/`## Phases`，
    # 不剥离会产出幽灵 section（2026-11-25 抽样比对发现）。
    for pos, sec in enumerate(split_sections("\n".join(strip_comments(text.splitlines()))), 1):
        norm = norm_section(sec["anchor"])
        if norm and norm in pruned:
            continue
        sid = SECTION_IDS.get(norm) or f"sec-s{pos:02d}"
        ref = REF_SECTIONS.get(norm)
        if ref:
            sections.append({"id": sid, "anchor": sec["anchor"], "level": 2, "kind": "ref",
                             "ref": {"path": ref[0], "renderer": ref[1]}, "required": True})
        else:
            sections.append({"id": sid, "anchor": sec["anchor"], "level": 2, "kind": "blocks",
                             "required": True, "blocks": parse_blocks(sec["lines"], sec["anchor"])})
    return {
        "schema_version": 1,
        "meta": {
            # template_type 以 template_meta/template_type 注释为准（task_plan 文件名为 task_plan.md 但 type=general）
            "template_type": meta["type"],
            "name": meta["name"],
            "summary": meta["summary"],
            "scenarios": meta["scenarios"],
            "features": meta["features"],
            "lineage": lineage,
        },
        "sections": sections,
    }


def json_counts(doc):
    """dry-run 字段计数：段/ref/blocks/勾选/表格/raw/最长 text。"""
    blocks = [b for s in doc["sections"] if s["kind"] == "blocks" for b in s["blocks"]]
    items = [i for b in blocks if b["kind"] == "checklist" for i in b["items"]]
    texts = [b.get("text", "") for b in blocks if "text" in b]
    return {
        "sections": len(doc["sections"]),
        "refs": sum(1 for s in doc["sections"] if s["kind"] == "ref"),
        "blocks": len(blocks),
        "checklist": len(items),
        "tables": sum(1 for b in blocks if b["kind"] == "table"),
        "raw": sum(1 for b in blocks if b["kind"] == "raw"),
        "max_text": max([len(t) for t in texts] or [0]),
    }


def cmd_to_json(args):
    """--dry-run（默认）只列清单与计数；--write 才创建 templates/json/ 并落盘。"""
    if args.dry_run and args.write:
        die("--dry-run 与 --write 互斥", 2)
    write = args.write
    out_dir = os.path.join(BUILTIN_DIR, "json")
    sources = json_sources()
    if len(sources) != 33:
        die(f"源模板数量应为 33，实际 {len(sources)}（拒绝部分转换）")
    totals = {"sections": 0, "refs": 0, "blocks": 0, "checklist": 0, "tables": 0, "raw": 0, "max_text": 0}
    for src, ttype in sources:
        if not os.path.isfile(src):
            die(f"源模板不存在: {src}")
        doc = convert_template(src, ttype)
        if not doc["sections"]:
            die(f"转换结果无 section（拒绝写出空模板）: {src}")
        c = json_counts(doc)
        for k in totals:
            totals[k] = max(totals[k], c[k]) if k == "max_text" else totals[k] + c[k]
        rel_dst = os.path.join("skills", "task-planner", "templates", "json", f"{ttype}.template.json")
        stats = " ".join(f"{k}={v}" for k, v in c.items())
        print(f"TO-JSON {'OK' if write else 'DRY'} {os.path.relpath(src, REPO_ROOT)} -> {rel_dst} {stats}")
        if write:
            os.makedirs(out_dir, exist_ok=True)
            with open(os.path.join(out_dir, f"{ttype}.template.json"), "w", encoding="utf-8") as f:
                # 紧凑序列化：避免缩进空白使 JSON 接近/超过 MD 原文体积（用户判据：显著小于源模板）
                f.write(json.dumps(doc, ensure_ascii=False, separators=(",", ":")) + "\n")
    agg = " ".join(f"{k}={v}" for k, v in totals.items())
    print(f"TO-JSON {'WRITE' if write else 'DRY'} total={len(sources)} write={int(write)} {agg}")


def build_parser():
    # [2026-11-22] 补 help 示例减少试错：根 epilog 提供可照抄工作流 + 输出/退出码约定（复用头注释既有事实）
    p = argparse.ArgumentParser(
        prog="template-catalog.sh",
        description="模板检索/管理 CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""可照抄示例（工作流）：
  1) 列出模板：             template-catalog.sh list
  2) 关键词筛选/推荐排序：   template-catalog.sh list --query "代码审查,重构"
                            template-catalog.sh list --recommend "写一个带单测的重构计划"
  3) 派生自己的模板（先 dry-run 预览，去掉 --dry-run 才真正写入）：
                            template-catalog.sh add my-skeleton --from code-edit --dry-run
                            template-catalog.sh clone --from code-edit --to my-review --dry-run
                            template-catalog.sh derive --from code-edit --to my-review --prune "发布,回滚" --dry-run
  写入默认落 project 范围；也可显式 --scope user-global。

输出约定：list 默认人读表；--json 输出稳定 JSON {"templates":[...],"default":...,"count":...}；
          templates 每项 source=json(JSON 权威)/legacy(旧 MD 兼容)，preferred=true 为选型首选；
          add/clone/derive stdout 单行 `CATALOG <ACTION> <OK|DRY|FAIL> <path>`；错误走 stderr。
退出码：0=成功  1=业务失败(源不存在/同名冲突等)  2=用法错误。
作用域优先级(去重)：project > user-global > user-install > builtin。""",
    )
    sub = p.add_subparsers(dest="cmd", required=True)
    # [2026-11-22] 补 help 示例减少试错：list 子命令给出可照抄示例
    lp = sub.add_parser(
        "list",
        help="列出模板清单",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""示例（可照抄）：
  template-catalog.sh list --scope builtin
  template-catalog.sh list --query "代码审查"
  template-catalog.sh list --recommend "重构计划" --json
  template-catalog.sh list --scope all --include-installs""",
    )
    lp.add_argument("--scope", default="all", choices=["all", "builtin", "project", "user", "user-global", "user-install"])
    lp.add_argument("--json", action="store_true")
    lp.add_argument("--query", help="按关键词过滤（名称/简介/场景/功能）")
    lp.add_argument("--recommend", help="按任务描述关键词排序推荐")
    lp.add_argument("--include-installs", action="store_true", help="含 ~/.zcode|agents|claude|cursor 安装位模板")
    # [2026-11-25 task-json-template-20261125] to-json：默认 dry-run，--write 才落盘（防误写模板目录）
    jp = sub.add_parser(
        "to-json",
        help="33 个骨架模板 → templates/json/*.template.json（结构化，非原文复制）",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""示例（可照抄）：
  template-catalog.sh to-json --dry-run   # 只列 33 条源→目标与字段计数
  template-catalog.sh to-json --write     # 真正生成 templates/json/""",
    )
    jp.add_argument("--dry-run", action="store_true", help="只输出清单与计数（默认）")
    jp.add_argument("--write", action="store_true", help="写入 templates/json/")
    for act in ("add", "clone", "derive"):
        # [2026-11-22] 补 help 示例减少试错：各子命令给出可照抄示例（写操作用 --dry-run 预览，不改业务逻辑）
        ap = sub.add_parser(
            act,
            help=f"{act} 模板",
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog={
                "add": """示例（可照抄）：
  template-catalog.sh add my-skeleton --from code-edit --dry-run
  template-catalog.sh add my-skeleton --from code-edit --scope project --dry-run""",
                "clone": """示例（可照抄）：
  template-catalog.sh clone --from code-edit --to my-review --dry-run
  template-catalog.sh clone --from code-edit --to my-review --scope user-global --dry-run""",
                "derive": """示例（可照抄）：
  template-catalog.sh derive --from code-edit --to my-review --prune "发布,回滚" --dry-run
  template-catalog.sh derive --from code-edit --to my-review --prune "发布" --scope project --dry-run""",
            }[act],
        )
        if act == "add":
            ap.add_argument("name", help="新模板类型名")
            ap.add_argument("--from", dest="from_", help="源模板 type 或路径（省略=空骨架）")
        else:
            ap.add_argument("--from", dest="from_", required=True, help="源模板 type 或路径")
            ap.add_argument("--to", required=True, help="目标模板类型名")
        ap.add_argument("--scope", default="project", choices=["project", "user-global"])
        ap.add_argument("--dry-run", action="store_true")
        ap.add_argument("--force", action="store_true")
        if act == "derive":
            ap.add_argument("--prune", help="逗号分隔的 ## 段名，派生时裁剪")
    return p

def main():
    args = build_parser().parse_args()
    if args.cmd == "list":
        cmd_list(args)
    elif args.cmd == "to-json":
        cmd_to_json(args)
    elif args.cmd == "add":
        if getattr(args, "from_", None):
            args.to = args.name
            cmd_write(args, "clone")
        else:
            # 空骨架：从 general 派生
            args.from_ = "general"
            args.to = args.name
            args.prune = None
            cmd_write(args, "add")
    elif args.cmd in ("clone", "derive"):
        cmd_write(args, args.cmd)

if __name__ == "__main__":
    main()
PY
