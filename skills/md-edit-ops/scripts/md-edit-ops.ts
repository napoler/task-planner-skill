#!/usr/bin/env node
import * as fs from "node:fs";
import * as path from "node:path";
import { createHash } from "node:crypto";

// Exit codes: 0 ok, 2 load/schema, 3 stale base_hashes, 4 precheck fail (zero write),
// 5 read-back assertion fail (zero write), 6 atomic write/rollback fail

type AnchorType = "exact" | "regex" | "heading";
interface Anchor {
  type: AnchorType;
  value: string;
  expect_count?: number;
  occurrence?: number;
}
interface Op {
  id: string;
  op: "sub" | "insert_after" | "insert_before" | "replace_range" | "delete_range" | "append" | "prepend";
  file: string;
  anchor: Anchor;
  end_anchor?: Anchor;
  old?: string;
  content?: string;
  expect?: string[];
}
interface Order {
  version: number;
  description?: string;
  base_hashes?: Record<string, string>;
  ops: Op[];
}

interface OpReport {
  id: string;
  op: string;
  file: string;
  status: "ok" | "fail" | "skipped";
  matched: number | null;
  line_range: [number, number] | null;
  error: string | null;
}
interface FileReport {
  before_sha256: string;
  after_sha256: string;
  backup: string | null;
}
interface Report {
  dry_run: boolean;
  ops: OpReport[];
  files: Record<string, FileReport>;
  summary: {
    total: number;
    ok: number;
    failed: number;
    exit_code: number;
  };
  error?: string;
}

function sha256(s: string): string {
  return createHash("sha256").update(s).digest("hex");
}

function parseArgs(argv: string[]): { order?: string; dryRun: boolean; report?: string; backupDir?: string } {
  const out: { order?: string; dryRun: boolean; report?: string; backupDir?: string } = { dryRun: false };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--order") out.order = argv[++i];
    else if (a === "--dry-run") out.dryRun = true;
    else if (a === "--report") out.report = argv[++i];
    else if (a === "--backup-dir") out.backupDir = argv[++i];
    else if (a === "-h" || a === "--help") {
      process.stdout.write("Usage: md-edit-ops --order <file.json> [--dry-run] [--report <path>] [--backup-dir <dir>]\n");
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${a}`);
    }
  }
  if (!out.order) throw new Error("Missing required --order <file.json>");
  return out;
}

function isObj(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

function failSchema(msg: string): never {
  const e = new Error(msg);
  (e as any)._schema = true;
  throw e;
}

function validateOrder(raw: unknown): Order {
  if (!isObj(raw)) failSchema("Order must be a JSON object");
  if (raw.version !== 1) failSchema("version must be 1");
  if (!Array.isArray(raw.ops)) failSchema("ops must be an array");
  const base_hashes = raw.base_hashes;
  if (base_hashes !== undefined) {
    if (!isObj(base_hashes)) failSchema("base_hashes must be an object");
    for (const [k, v] of Object.entries(base_hashes)) {
      if (typeof v !== "string" || !/^[a-f0-9]{64}$/i.test(v)) failSchema(`base_hashes[${k}] must be sha256 hex`);
    }
  }
  const validOps = new Set(["sub", "insert_after", "insert_before", "replace_range", "delete_range", "append", "prepend"]);
  const ops: Op[] = raw.ops.map((o, idx) => {
    if (!isObj(o)) failSchema(`ops[${idx}] must be object`);
    if (typeof o.id !== "string" || !o.id) failSchema(`ops[${idx}].id required`);
    if (typeof o.op !== "string" || !validOps.has(o.op)) failSchema(`ops[${idx}].op invalid`);
    if (typeof o.file !== "string" || !o.file) failSchema(`ops[${idx}].file required`);
    if (!isObj(o.anchor)) failSchema(`ops[${idx}].anchor required`);
    const a = o.anchor as Record<string, unknown>;
    if (a.type !== "exact" && a.type !== "regex" && a.type !== "heading") failSchema(`ops[${idx}].anchor.type invalid`);
    if (typeof a.value !== "string") failSchema(`ops[${idx}].anchor.value required`);
    if (a.expect_count !== undefined && (!Number.isInteger(a.expect_count) || (a.expect_count as number) < 0)) failSchema(`ops[${idx}].anchor.expect_count invalid`);
    if (a.occurrence !== undefined && (!Number.isInteger(a.occurrence) || (a.occurrence as number) < 1)) failSchema(`ops[${idx}].anchor.occurrence invalid`);
    const op: Op = {
      id: o.id as string,
      op: o.op as Op["op"],
      file: o.file as string,
      anchor: {
        type: a.type as AnchorType,
        value: a.value as string,
        expect_count: a.expect_count as number | undefined,
        occurrence: a.occurrence as number | undefined,
      },
    };
    if (o.end_anchor !== undefined) {
      if (!isObj(o.end_anchor)) failSchema(`ops[${idx}].end_anchor invalid`);
      const ea = o.end_anchor as Record<string, unknown>;
      if (ea.type !== "exact" && ea.type !== "regex" && ea.type !== "heading") failSchema(`ops[${idx}].end_anchor.type invalid`);
      if (typeof ea.value !== "string") failSchema(`ops[${idx}].end_anchor.value required`);
      if (ea.expect_count !== undefined && (!Number.isInteger(ea.expect_count) || (ea.expect_count as number) < 0)) failSchema(`ops[${idx}].end_anchor.expect_count invalid`);
      if (ea.occurrence !== undefined && (!Number.isInteger(ea.occurrence) || (ea.occurrence as number) < 1)) failSchema(`ops[${idx}].end_anchor.occurrence invalid`);
      op.end_anchor = { type: ea.type as AnchorType, value: ea.value as string, expect_count: ea.expect_count as number | undefined, occurrence: ea.occurrence as number | undefined };
    }
    if (o.old !== undefined) {
      if (typeof o.old !== "string") failSchema(`ops[${idx}].old must be string`);
      op.old = o.old as string;
    }
    if (o.content !== undefined) {
      if (typeof o.content !== "string") failSchema(`ops[${idx}].content must be string`);
      op.content = o.content as string;
    }
    if (o.expect !== undefined) {
      if (!Array.isArray(o.expect) || o.expect.some((e) => typeof e !== "string")) failSchema(`ops[${idx}].expect must be string[]`);
      op.expect = o.expect as string[];
    }
    if (op.op === "sub" && typeof op.old !== "string") failSchema(`ops[${idx}] sub requires old`);
    if ((op.op === "insert_after" || op.op === "insert_before" || op.op === "append" || op.op === "prepend" || op.op === "replace_range") && typeof op.content !== "string") failSchema(`ops[${idx}] ${op.op} requires content`);
    if ((op.op === "replace_range" || op.op === "delete_range") && !op.end_anchor) failSchema(`ops[${idx}] ${op.op} requires end_anchor`);
    return op;
  });
  return {
    version: 1,
    description: typeof raw.description === "string" ? raw.description : undefined,
    base_hashes: base_hashes as Record<string, string> | undefined,
    ops,
  };
}

interface MatchResult {
  count: number;
  indices: Array<{ start: number; end: number }>; // [start,end) in content
  error?: string;
}

function escapeRegExp(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function findMatches(content: string, anchor: Anchor): MatchResult {
  const { type, value } = anchor;
  if (type === "exact") {
    if (value === "") return { count: 0, indices: [], error: "empty exact anchor" };
    const indices: Array<{ start: number; end: number }> = [];
    let pos = 0;
    while (true) {
      const i = content.indexOf(value, pos);
      if (i === -1) break;
      indices.push({ start: i, end: i + value.length });
      pos = i + value.length; // non-overlapping
    }
    return { count: indices.length, indices };
  }
  if (type === "regex") {
    let re: RegExp;
    try {
      re = new RegExp(value, "gm");
    } catch (e: any) {
      return { count: 0, indices: [], error: `invalid regex: ${e.message}` };
    }
    const indices: Array<{ start: number; end: number }> = [];
    let m: RegExpExecArray | null;
    while ((m = re.exec(content)) !== null) {
      const start = m.index;
      const end = m.index + m[0].length;
      if (m[0].length === 0) {
        indices.push({ start, end });
        re.lastIndex = m.index + 1;
        if (re.lastIndex > content.length) break;
      } else {
        indices.push({ start, end });
      }
    }
    return { count: indices.length, indices };
  }
  if (type === "heading") {
    // ^#{1,6} exact match of the full heading line
    const indices: Array<{ start: number; end: number }> = [];
    let lineStart = 0;
    while (lineStart <= content.length) {
      let lineEnd = content.indexOf("\n", lineStart);
      if (lineEnd === -1) lineEnd = content.length;
      const line = content.slice(lineStart, lineEnd); // without \n
      const lineCmp = line.endsWith("\r") ? line.slice(0, -1) : line;
      if (/^#{1,6} /.test(lineCmp) && lineCmp === value) {
        indices.push({ start: lineStart, end: lineEnd }); // match the line content (exclude \n)
      }
      if (lineEnd === content.length) break;
      lineStart = lineEnd + 1;
    }
    return { count: indices.length, indices };
  }
  return { count: 0, indices: [], error: "unknown anchor type" };
}

function lineNumberAt(content: string, index: number): number {
  let line = 1;
  for (let i = 0; i < index && i < content.length; i++) {
    if (content[i] === "\n") line++;
  }
  return line;
}

function countHeadingLines(text: string): number {
  const lines = text.split(/\r?\n/);
  let c = 0;
  for (const ln of lines) {
    if (/^#{1,6} /.test(ln)) c++;
  }
  return c;
}

function getExpectCount(anchor: Anchor): number {
  return anchor.expect_count === undefined ? 1 : anchor.expect_count;
}
function getOccurrence(anchor: Anchor): number {
  return anchor.occurrence === undefined ? 1 : anchor.occurrence;
}

function computeRemovedText(op: Op, content: string, anchorIdx: { start: number; end: number }, endIdx?: { start: number; end: number }): string {
  if (op.op === "sub") {
    return op.old ?? "";
  }
  if (op.op === "delete_range" || op.op === "replace_range") {
    if (!endIdx) return "";
    return content.slice(anchorIdx.start, endIdx.end);
  }
  return "";
}

function applyOne(
  op: Op,
  content: string
): { ok: true; newContent: string; lineRange: [number, number] | null; anchorIdx: { start: number; end: number }; endIdx?: { start: number; end: number } } | { ok: false; error: string } {
  const m = findMatches(content, op.anchor);
  if (m.error) return { ok: false, error: m.error };
  const expect = getExpectCount(op.anchor);
  if (m.count !== expect) return { ok: false, error: `anchor count ${m.count} != expect_count ${expect}` };
  const occ = getOccurrence(op.anchor);
  if (occ < 1 || occ > m.count) return { ok: false, error: `occurrence ${occ} out of range (matched ${m.count})` };
  const anchorIdx = m.indices[occ - 1];

  let endIdx: { start: number; end: number } | undefined;
  if (op.op === "replace_range" || op.op === "delete_range") {
    if (!op.end_anchor) return { ok: false, error: "missing end_anchor" };
    const em = findMatches(content, op.end_anchor);
    if (em.error) return { ok: false, error: `end_anchor: ${em.error}` };
    const eexp = getExpectCount(op.end_anchor);
    if (em.count !== eexp) return { ok: false, error: `end_anchor count ${em.count} != expect_count ${eexp}` };
    const eocc = getOccurrence(op.end_anchor);
    if (eocc < 1 || eocc > em.count) return { ok: false, error: `end_anchor occurrence ${eocc} out of range` };
    endIdx = em.indices[eocc - 1];
    if (endIdx.end < anchorIdx.start) return { ok: false, error: "end_anchor appears before anchor" };
  }

  let newContent = content;
  let lineRange: [number, number] | null = null;

  if (op.op === "sub") {
    const old = op.old as string;
    // sub old count validation
    const oldCount = findMatches(content, { type: "exact", value: old, expect_count: expect }).count;
    if (oldCount !== expect) return { ok: false, error: `sub old count ${oldCount} != expect_count ${expect}` };
    // replace the occurrence-th match of old
    const oldMatches = findMatches(content, { type: "exact", value: old }).indices;
    if (occ < 1 || occ > oldMatches.length) return { ok: false, error: `sub old occurrence ${occ} out of range` };
    const target = oldMatches[occ - 1];
    newContent = content.slice(0, target.start) + (op.content ?? "") + content.slice(target.end);
    lineRange = [lineNumberAt(content, target.start), lineNumberAt(content, Math.max(target.start, target.end - 1))];
  } else if (op.op === "insert_after") {
    const ins = op.content ?? "";
    newContent = content.slice(0, anchorIdx.end) + ins + content.slice(anchorIdx.end);
    lineRange = [lineNumberAt(content, anchorIdx.start), lineNumberAt(content, Math.max(anchorIdx.start, anchorIdx.end - 1))];
  } else if (op.op === "insert_before") {
    const ins = op.content ?? "";
    newContent = content.slice(0, anchorIdx.start) + ins + content.slice(anchorIdx.start);
    lineRange = [lineNumberAt(content, anchorIdx.start), lineNumberAt(content, Math.max(anchorIdx.start, anchorIdx.end - 1))];
  } else if (op.op === "append") {
    newContent = content + (op.content ?? "");
    lineRange = [lineNumberAt(content, content.length), lineNumberAt(content, content.length)];
  } else if (op.op === "prepend") {
    newContent = (op.content ?? "") + content;
    lineRange = [1, 1];
  } else if (op.op === "replace_range") {
    const ei = endIdx!;
    newContent = content.slice(0, anchorIdx.start) + (op.content ?? "") + content.slice(ei.end);
    lineRange = [lineNumberAt(content, anchorIdx.start), lineNumberAt(content, Math.max(anchorIdx.start, ei.end - 1))];
  } else if (op.op === "delete_range") {
    const ei = endIdx!;
    newContent = content.slice(0, anchorIdx.start) + content.slice(ei.end);
    lineRange = [lineNumberAt(content, anchorIdx.start), lineNumberAt(content, Math.max(anchorIdx.start, ei.end - 1))];
  }

  return { ok: true, newContent, lineRange, anchorIdx, endIdx };
}

function ensureDirFor(filePath: string) {
  const dir = path.dirname(filePath);
  fs.mkdirSync(dir, { recursive: true });
}

function main() {
  let args: ReturnType<typeof parseArgs>;
  try {
    args = parseArgs(process.argv);
  } catch (e: any) {
    const report: Report = { dry_run: false, ops: [], files: {}, summary: { total: 0, ok: 0, failed: 1, exit_code: 2 }, error: e.message };
    process.stdout.write(JSON.stringify(report, null, 2) + "\n");
    process.exit(2);
  }

  const orderPath = path.resolve(args.order!);
  const baseDir = path.dirname(orderPath);

  function emit(report: Report, exitCode: number, reportPath?: string) {
    report.summary.exit_code = exitCode;
    report.summary.failed = report.ops.filter((o) => o.status === "fail").length;
    report.summary.ok = report.ops.filter((o) => o.status === "ok").length;
    report.summary.total = report.ops.length;
    const out = JSON.stringify(report, null, 2);
    process.stdout.write(out + "\n");
    if (reportPath) {
      try {
        ensureDirFor(reportPath);
        fs.writeFileSync(reportPath, out + "\n", "utf8");
      } catch (_) { /* best effort */ }
    }
    process.exit(exitCode);
  }

  let order: Order;
  try {
    const rawText = fs.readFileSync(orderPath, "utf8");
    const raw = JSON.parse(rawText);
    order = validateOrder(raw);
  } catch (e: any) {
    const msg = e && e.message ? e.message : String(e);
    const report: Report = { dry_run: !!args.dryRun, ops: [], files: {}, summary: { total: 0, ok: 0, failed: 1, exit_code: 2 }, error: `load/schema error: ${msg}` };
    emit(report, 2, args.report);
  }

  // Resolve file paths relative to order file dir
  const resolveFile = (f: string) => path.isAbsolute(f) ? f : path.resolve(baseDir, f);
  const fileKeys = Array.from(new Set(order.ops.map((o) => o.file)));

  // Load original contents
  const originals: Record<string, string> = {};
  const originalHashes: Record<string, string> = {};
  try {
    for (const fk of fileKeys) {
      const abs = resolveFile(fk);
      const content = fs.readFileSync(abs, "utf8");
      originals[fk] = content;
      originalHashes[fk] = sha256(content);
    }
  } catch (e: any) {
    const report: Report = { dry_run: !!args.dryRun, ops: [], files: {}, summary: { total: 0, ok: 0, failed: 1, exit_code: 2 }, error: `file read error: ${e.message}` };
    emit(report, 2, args.report);
  }

  // Step 3: staleness - base_hashes
  if (order.base_hashes) {
    for (const [fk, expected] of Object.entries(order.base_hashes)) {
      const actual = originalHashes[fk];
      if (actual === undefined) {
        // try loading it for hash check
        try {
          const abs = resolveFile(fk);
          const c = fs.readFileSync(abs, "utf8");
          if (sha256(c).toLowerCase() !== expected.toLowerCase()) {
            const report: Report = { dry_run: !!args.dryRun, ops: [], files: {}, summary: { total: 0, ok: 0, failed: 1, exit_code: 3 }, error: `base_hashes mismatch for ${fk}` };
            emit(report, 3, args.report);
          }
        } catch (e: any) {
          const report: Report = { dry_run: !!args.dryRun, ops: [], files: {}, summary: { total: 0, ok: 0, failed: 1, exit_code: 3 }, error: `base_hashes file missing/unreadable: ${fk}` };
          emit(report, 3, args.report);
        }
      } else if (actual.toLowerCase() !== expected.toLowerCase()) {
        const report: Report = { dry_run: !!args.dryRun, ops: [], files: {}, summary: { total: 0, ok: 0, failed: 1, exit_code: 3 }, error: `base_hashes mismatch for ${fk}` };
        emit(report, 3, args.report);
      }
    }
  }

  // Steps 3-4: sequential precheck + simulation collecting all matched counts
  const current: Record<string, string> = { ...originals };
  const opReports: OpReport[] = order.ops.map((o) => ({ id: o.id, op: o.op, file: o.file, status: "skipped", matched: null, line_range: null, error: null }));
  let precheckFailed = false;

  // For assertion 5b we need anchor counts before each insert op
  const preInsertAnchorCounts: Record<number, number> = {};

  for (let i = 0; i < order.ops.length; i++) {
    const op = order.ops[i];
    const content = current[op.file];
    if (content === undefined) {
      opReports[i].status = "fail";
      opReports[i].error = `target file not loaded: ${op.file}`;
      opReports[i].matched = 0;
      precheckFailed = true;
      continue;
    }
    // anchor count
    const m = findMatches(content, op.anchor);
    opReports[i].matched = m.count;
    if (m.error) {
      opReports[i].status = "fail";
      opReports[i].error = m.error;
      precheckFailed = true;
      continue;
    }
    const expect = getExpectCount(op.anchor);
    if (m.count !== expect) {
      opReports[i].status = "fail";
      opReports[i].error = `anchor count ${m.count} != expect_count ${expect}`;
      precheckFailed = true;
      continue;
    }

    // record pre-insert anchor count for 5b
    if (op.op === "insert_after" || op.op === "insert_before") {
      preInsertAnchorCounts[i] = m.count;
    }

    // simulate apply (includes sub old count check)
    const res = applyOne(op, content);
    if (!res.ok) {
      opReports[i].status = "fail";
      opReports[i].error = (res as any).error;
      precheckFailed = true;
      continue;
    }
    opReports[i].status = "ok";
    opReports[i].line_range = res.lineRange;
    current[op.file] = res.newContent;
  }

  if (precheckFailed) {
    const report: Report = { dry_run: !!args.dryRun, ops: opReports, files: {}, summary: { total: order.ops.length, ok: 0, failed: 0, exit_code: 4 } };
    // populate file reports with before hashes at least
    for (const fk of fileKeys) {
      report.files[fk] = { before_sha256: originalHashes[fk], after_sha256: originalHashes[fk], backup: null };
    }
    emit(report, 4, args.report);
  }

  // Step 5: read-back assertions on simulated results
  const assertionErrors: string[] = [];

  // 5a heading conservation per file
  for (const fk of fileKeys) {
    const before = originals[fk];
    const after = current[fk];
    const actualDelta = countHeadingLines(after) - countHeadingLines(before);
    // expected delta from ops targeting this file in order
    let expectedDelta = 0;
    let sim: string = before;
    for (const op of order.ops) {
      if (op.file !== fk) continue;
      const beforeOp = sim;
      const r = applyOne(op, sim);
      if (!r.ok) break; // shouldn't happen
      const afterOp = r.newContent;
      // compute contribution
      let contrib = 0;
      if (op.op === "sub") {
        contrib = countHeadingLines(op.content ?? "") - countHeadingLines(op.old ?? "");
      } else if (op.op === "insert_after" || op.op === "insert_before" || op.op === "append" || op.op === "prepend") {
        contrib = countHeadingLines(op.content ?? "");
      } else if (op.op === "delete_range" || op.op === "replace_range") {
        const m = findMatches(beforeOp, op.anchor);
        const em = op.end_anchor ? findMatches(beforeOp, op.end_anchor) : null;
        if (m.indices.length > 0 && em && em.indices.length > 0) {
          const occ = getOccurrence(op.anchor);
          const eocc = getOccurrence(op.end_anchor);
          const aIdx = m.indices[occ - 1];
          const eIdx = em.indices[eocc - 1];
          const removed = beforeOp.slice(aIdx.start, eIdx.end);
          contrib = countHeadingLines(op.op === "replace_range" ? (op.content ?? "") : "") - countHeadingLines(removed);
        }
      }
      expectedDelta += contrib;
      sim = afterOp;
    }
    if (actualDelta !== expectedDelta) {
      assertionErrors.push(`heading conservation failed for ${fk}: actual delta ${actualDelta} != expected ${expectedDelta}`);
    }
  }

  // 5b insert anchor preservation: anchor text still exists and count unchanged after that op?
  // "insert 类 op 后 anchor 原文仍存在且计数不变"
  // We'll re-simulate and check after each insert op relative to pre-op state
  {
    const simState: Record<string, string> = { ...originals };
    for (let i = 0; i < order.ops.length; i++) {
      const op = order.ops[i];
      const beforeOp = simState[op.file];
      const preCount = preInsertAnchorCounts[i];
      const r = applyOne(op, beforeOp);
      if (!r.ok) break;
      simState[op.file] = r.newContent;
      if (op.op === "insert_after" || op.op === "insert_before") {
        const afterCount = findMatches(simState[op.file], op.anchor).count;
        if (afterCount !== preCount) {
          assertionErrors.push(`anchor preservation failed for op ${op.id}: count ${preCount} -> ${afterCount}`);
        }
      }
    }
  }

  // 5c expect regexes per op (after full simulation on that file)
  for (const op of order.ops) {
    if (!op.expect || op.expect.length === 0) continue;
    const after = current[op.file];
    for (const pat of op.expect) {
      let re: RegExp;
      try { re = new RegExp(pat, "m"); } catch (e: any) {
        assertionErrors.push(`op ${op.id} expect invalid regex: ${e.message}`);
        continue;
      }
      if (!re.test(after)) {
        assertionErrors.push(`op ${op.id} expect regex not matched: ${pat}`);
      }
    }
  }

  if (assertionErrors.length > 0) {
    const report: Report = { dry_run: !!args.dryRun, ops: opReports, files: {}, summary: { total: order.ops.length, ok: 0, failed: 0, exit_code: 5 }, error: assertionErrors.join("; ") };
    for (const fk of fileKeys) {
      report.files[fk] = { before_sha256: originalHashes[fk], after_sha256: sha256(current[fk]), backup: null };
    }
    // mark ops as ok in precheck/sim sense but overall assertion failed - keep statuses as ok? better indicate failure context
    emit(report, 5, args.report);
  }

  // Dry-run success
  if (args.dryRun) {
    const report: Report = { dry_run: true, ops: opReports, files: {}, summary: { total: order.ops.length, ok: order.ops.length, failed: 0, exit_code: 0 } };
    for (const fk of fileKeys) {
      report.files[fk] = { before_sha256: originalHashes[fk], after_sha256: sha256(current[fk]), backup: null };
    }
    emit(report, 0, args.report);
  }

  // Step 6: atomic write with backups
  const backupPaths: Record<string, string> = {};
  const writtenFiles: string[] = [];
  const fileReports: Record<string, FileReport> = {};
  for (const fk of fileKeys) {
    fileReports[fk] = { before_sha256: originalHashes[fk], after_sha256: sha256(current[fk]), backup: null };
  }

  const rollback = () => {
    for (const fk of writtenFiles) {
      try {
        const abs = resolveFile(fk);
        const bkp = backupPaths[fk];
        if (bkp && fs.existsSync(bkp)) {
          fs.copyFileSync(bkp, abs);
        }
      } catch (_) { /* best effort */ }
    }
  };

  try {
    // create backups
    for (const fk of fileKeys) {
      const abs = resolveFile(fk);
      let bkp: string;
      if (args.backupDir) {
        const bd = path.resolve(args.backupDir);
        fs.mkdirSync(bd, { recursive: true });
        const base = path.basename(fk);
        bkp = path.join(bd, base + ".edit-ops-bak");
      } else {
        bkp = abs + ".edit-ops-bak";
      }
      fs.copyFileSync(abs, bkp);
      backupPaths[fk] = bkp;
      fileReports[fk].backup = bkp;
    }

    // write files sequentially: temp -> rename
    for (const fk of fileKeys) {
      const abs = resolveFile(fk);
      const dir = path.dirname(abs);
      const tmp = path.join(dir, `.md-edit-ops-${process.pid}-${Date.now()}-${Math.random().toString(16).slice(2)}.tmp`);
      fs.writeFileSync(tmp, current[fk], "utf8");
      try {
        fs.renameSync(tmp, abs);
      } catch (e) {
        try { fs.unlinkSync(tmp); } catch (_) {}
        throw e;
      }
      writtenFiles.push(fk);
    }
  } catch (e: any) {
    rollback();
    const report: Report = { dry_run: false, ops: opReports, files: fileReports, summary: { total: order.ops.length, ok: order.ops.length, failed: 0, exit_code: 6 }, error: `write/rollback error: ${e.message}` };
    emit(report, 6, args.report);
  }

  const report: Report = { dry_run: false, ops: opReports, files: fileReports, summary: { total: order.ops.length, ok: order.ops.length, failed: 0, exit_code: 0 } };
  emit(report, 0, args.report);
}

main();
