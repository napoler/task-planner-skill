#!/usr/bin/env npx ts-node
/**
 * ================================================================================
 * META_NAME: sync-ide-folders
 * META_VERSION: 1.0.0
 * META_TITLE: Sync IDE Folders — 从规范源同步到各 IDE 目录
 * META_DESCRIPTION: 将共享文件同步到所有 IDE 特定文件夹
 * META_KEYWORDS:
 *   - sync
 *   - ide
 *   - planning-with-files
 * META_USAGE: |
 *   $ sync-ide-folders [--dry-run] [--verify]
 * META_EXAMPLES: |
 *   $ sync-ide-folders
 *   $ sync-ide-folders --dry-run
 *   $ sync-ide-folders --verify
 * META_INPUT: |
 *   输入: CLI flags (--dry-run, --verify)
 * META_OUTPUT: |
 *   输出: 同步统计到 stdout
 *   返回码: 0=成功, 1=发现漂移
 * META_DEPS: |
 *   Node.js >= 18
 *   ts-node
 *   无外部依赖
 * ================================================================================
 */

import * as fs from "fs";
import * as path from "path";
import * as crypto from "crypto";

const CANONICAL = path.resolve("skills/task-planner");

const TEMPLATES = ["templates/findings.md", "templates/progress.md", "templates/task_plan.md"];
const REFERENCES = ["examples.md", "reference.md"];
const SCRIPTS = ["scripts/check-complete.sh", "scripts/check-complete.ps1", "scripts/init-session.sh", "scripts/init-session.ps1", "scripts/session-catchup.py"];

type RefStyle = "flat" | "subdir" | "skip";

function buildManifest(base: string, opts: { refStyle?: RefStyle; templateDirs?: string[]; includeScripts?: boolean; extraTemplateDirs?: string[] }): Record<string, string> {
  const manifest: Record<string, string> = {};
  const b = base;
  const templateDirs = opts.templateDirs || ["templates/"];
  for (const tdir of templateDirs) {
    for (const t of TEMPLATES) {
      const filename = path.basename(t);
      manifest[t] = path.join(b, tdir, filename);
    }
  }
  if (opts.extraTemplateDirs) {
    for (const tdir of opts.extraTemplateDirs) {
      for (const t of TEMPLATES) {
        const filename = path.basename(t);
        manifest[`${t}__extra_${tdir}`] = path.join(b, tdir, filename);
      }
    }
  }
  if (opts.refStyle === "flat") {
    for (const r of REFERENCES) manifest[r] = path.join(b, r);
  } else if (opts.refStyle === "subdir") {
    for (const r of REFERENCES) manifest[r] = path.join(b, "references", r);
  }
  if (opts.includeScripts !== false) {
    for (const s of SCRIPTS) manifest[s] = path.join(b, s);
  }
  return manifest;
}

const IDE_MANIFESTS: Record<string, Record<string, string>> = {
  ".cursor": buildManifest(".cursor/skills/planning-with-files", { refStyle: "flat", includeScripts: false }),
  ".gemini": buildManifest(".gemini/skills/planning-with-files", { refStyle: "subdir", includeScripts: true }),
  ".codex": buildManifest(".codex/skills/planning-with-files", { refStyle: "subdir", includeScripts: true, extraTemplateDirs: ["assets/templates/"] }),
  ".openclaw": buildManifest(".openclaw/skills/planning-with-files", { refStyle: "subdir", includeScripts: true }),
  ".kilocode": buildManifest(".kilocode/skills/planning-with-files", { refStyle: "flat", includeScripts: false }),
  ".adal": buildManifest(".adal/skills/planning-with-files", { refStyle: "subdir", includeScripts: true }),
  ".pi": buildManifest(".pi/skills/planning-with-files", { refStyle: "flat", includeScripts: true }),
  ".continue": buildManifest(".continue/skills/planning-with-files", { refStyle: "flat", templateDirs: [], includeScripts: true }),
  ".codebuddy": buildManifest(".codebuddy/skills/planning-with-files", { refStyle: "subdir", includeScripts: true, extraTemplateDirs: ["assets/templates/"] }),
  ".factory": buildManifest(".factory/skills/planning-with-files", { refStyle: "skip", includeScripts: false }),
  ".agent": buildManifest(".agent/skills/planning-with-files", { refStyle: "skip", templateDirs: [], includeScripts: false }),
  ".opencode": buildManifest(".opencode/skills/planning-with-files", { refStyle: "flat", includeScripts: false }),
  ".kiro": {
    "scripts/check-complete.sh": ".kiro/scripts/check-complete.sh",
    "scripts/check-complete.ps1": ".kiro/scripts/check-complete.ps1",
    "scripts/init-session.sh": ".kiro/scripts/init-session.sh",
    "scripts/init-session.ps1": ".kiro/scripts/init-session.ps1",
  },
};

function fileHash(filePath: string): string | null {
  try { return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex"); } catch { return null; }
}

function syncFile(src: string, dst: string, dryRun: boolean): { action: string; detail: string } {
  if (!fs.existsSync(src)) return { action: "missing_src", detail: `Canonical file not found: ${src}` };
  const srcHash = fileHash(src);
  const dstHash = fs.existsSync(dst) ? fileHash(dst) : null;
  if (srcHash === dstHash) return { action: "skipped", detail: "Already up to date" };
  const action = dstHash === null ? "created" : "updated";
  if (!dryRun) {
    fs.mkdirSync(path.dirname(dst), { recursive: true });
    fs.copyFileSync(src, dst);
  }
  return { action, detail: `${action}: ${dst}` };
}

function parseArgs(argv: string[]): { dryRun: boolean; verify: boolean } {
  let dryRun = false;
  let verify = false;
  for (const arg of argv) {
    if (arg === "--dry-run") dryRun = true;
    if (arg === "--verify") verify = true;
  }
  return { dryRun, verify };
}

function main(): void {
  const { dryRun, verify } = parseArgs(process.argv.slice(2));

  if (!fs.existsSync(CANONICAL)) {
    console.error(`Error: Canonical source not found at ${CANONICAL}/`);
    console.error("Run this script from the repo root.");
    process.exit(1);
  }

  console.log(`${dryRun ? "[DRY RUN] " : ""}${verify ? "[VERIFY] " : ""}Syncing from ${CANONICAL}/\n`);

  const stats = { updated: 0, created: 0, skipped: 0, missing_src: 0, drift: 0 };

  for (const [ideName, manifest] of Object.entries(IDE_MANIFESTS).sort()) {
    const ideRoot = ideName;
    if (!fs.existsSync(ideRoot)) continue;

    console.log(`  ${ideName}/`);
    let ideChanges = 0;

    for (const [canonicalKey, targetPath] of Object.entries(manifest).sort()) {
      const canonicalRel = canonicalKey.split("__extra_")[0];
      const src = path.join(CANONICAL, canonicalRel);
      const dst = path.resolve(targetPath);

      if (verify) {
        const srcHash = fileHash(src);
        const dstHash = fileHash(dst);
        if (srcHash && dstHash && srcHash !== dstHash) {
          console.log(`    DRIFT: ${dst}`);
          stats.drift++;
          ideChanges++;
        } else if (srcHash && !dstHash) {
          console.log(`    MISSING: ${dst}`);
          stats.drift++;
          ideChanges++;
        }
      } else {
        const { action, detail } = syncFile(src, dst, dryRun);
        stats[action as keyof typeof stats]++;
        if (action === "updated" || action === "created") {
          console.log(`    ${action.toUpperCase()}: ${targetPath}`);
          ideChanges++;
        }
      }
    }

    if (ideChanges === 0) console.log("    (up to date)");
  }

  console.log(`\n${"=".repeat(50)}`);
  if (verify) {
    if (stats.drift > 0) {
      console.log(`DRIFT DETECTED: ${stats.drift} file(s) out of sync.`);
      console.log("Run 'ts-node sync-ide-folders.ts' to fix.");
      process.exit(1);
    } else {
      console.log("All IDE folders are in sync.");
      process.exit(0);
    }
  } else {
    console.log(`  Updated:  ${stats.updated}`);
    console.log(`  Created:  ${stats.created}`);
    console.log(`  Skipped:  ${stats.skipped} (already up to date)`);
    if (stats.missing_src > 0) console.log(`  Missing:  ${stats.missing_src} (canonical source not found)`);
    if (dryRun) {
      console.log("\n  This was a dry run. No files were modified.");
      console.log("  Run without --dry-run to apply changes.");
    }
  }
}

main();
