#!/usr/bin/env python3
"""Session-memory-first workflow enforcement — global, applies to every project.

Mirrors docs_workflow.py's architecture exactly, but for the `/mem` per-task
session-log convention (see ~/.claude/rules/memory.md and this folder's own
README.md) instead of the `docs/` per-feature reference convention.

Modes (first CLI arg), one per hook wiring in ~/.claude/settings.json:

  prompt   - UserPromptSubmit: inject a "search mem/ first, log at the end"
             reminder every turn, plus (once per session, git repos only)
             enforce the mem/ folder convention itself — see below.
  pretool  - PreToolUse (Read|Grep): once per session, before the first read
             of anything, remind Claude to search this project's mem/ folder
             for related past context before re-deriving it from source.
  posttool - PostToolUse (Edit|Write): silently record that source changed.
  test     - PostToolUse (Bash): silently record that a test command ran.
  stop     - Stop: if source changed (or tests ran) without any real mem/
             change in the working tree, block once and tell Claude to write
             a session-log entry before finishing. A second consecutive
             trigger for the same unresolved change is let through, so a
             deliberate "no entry needed" judgment call doesn't loop.
  precommit - invoked directly by a real git pre-commit hook (see
             SetupMemGitHook.ps1), independent of Claude Code entirely.

Deliberate difference from docs_workflow.py: there is no "established
codebase, offer a background backfill" branch here. Backfilling docs can
read existing code and describe what it does today. Backfilling mem/ would
mean fabricating a history of past decisions and rationale nobody recorded
at the time — there is nothing honest to generate. So when mem/ doesn't
exist yet, this hook just creates the empty folder and moves on, regardless
of how established the codebase looks.

Opt out for a specific repo by creating a `.nomemhook` file at its root.

State is tracked per session_id in a temp directory so a fresh session
starts clean and concurrent sessions don't interfere with each other. Uses
its own STATE_DIR and its own agent-policy marker, so it never collides with
docs_workflow.py's session state or its AGENTS.md/GEMINI.md patch blocks.
"""
import json
import os
import re
import subprocess
import sys
import tempfile

MODE = sys.argv[1] if len(sys.argv) > 1 else ""
STATE_DIR = os.path.join(tempfile.gettempdir(), "claude-mem-hook")

# Directories that never count as "source" for the purposes of this hook.
EXCLUDED_DIR_NAMES = {
    "docs", "mem", ".claude", ".git", "node_modules", "dist", "build",
    ".next", "__pycache__", "venv", ".venv", "vendor", "target",
    ".idea", ".vscode", "coverage", ".pytest_cache", "out",
}

TEST_COMMAND_MARKERS = (
    "pytest", "npm run test", "npm test", "npx jest", "playwright test",
    "go test", "cargo test", "mvn test", "dotnet test", "rspec",
)

MEM_PURPOSE_BLURB = (
    "This project keeps per-task session logs under mem/ — one "
    "mem/YYYYMMDD-{task-slug}.md file per task, capturing: The Ask, Changes "
    "Made, Decisions & Rationale, Current Architecture. It exists so future "
    "sessions (yours or another AI tool's) can recover why something was "
    "built a certain way without re-deriving it from source or git blame."
)

MEM_SCOPE_BLURB = (
    "Before reconstructing context on a task, search mem/ first "
    "(e.g. `grep -ril \"<topic>\" ./mem`) instead of blindly reading source. "
    "Only fall back to source/DB/migration files when mem is silent on the "
    "detail, or to verify current state — mem is a snapshot at write time "
    "and can go stale."
)

# Project-root FILES other AI coding tools read as their own standing
# instructions. CLAUDE.md is deliberately excluded — that's Claude Code's own
# file. Same list as docs_workflow.py's OTHER_AGENT_FILES/DIRS, duplicated
# here (not imported) so this file has no dependency on docs_workflow.py and
# keeps working even if that one is ever removed or disabled independently.
OTHER_AGENT_FILES = (
    "AGENTS.md", "GEMINI.md", ".cursorrules", ".windsurfrules",
    os.path.join(".github", "copilot-instructions.md"),
)

OTHER_AGENT_DIRS = (
    (os.path.join(".cursor", "rules"), ".mdc"),
    (os.path.join(".windsurf", "rules"), ".md"),
)

AGENT_POLICY_MARKER = "<!-- mem-first-hook:v1 -->"

AGENT_POLICY_BLOCK = (
    f"\n{AGENT_POLICY_MARKER}\n"
    "## Session-memory workflow (added by a global Claude Code hook)\n\n"
    + MEM_PURPOSE_BLURB + "\n\n" + MEM_SCOPE_BLURB + " After finishing a task "
    "that changed source, add a mem/YYYYMMDD-{task-slug}.md entry for it — "
    "The Ask, Changes Made, Decisions & Rationale, Current Architecture.\n"
    f"{AGENT_POLICY_MARKER}\n"
)


def find_other_agent_files(root):
    found = [("file", f) for f in OTHER_AGENT_FILES if os.path.isfile(os.path.join(root, f))]
    clinerules = os.path.join(root, ".clinerules")
    if os.path.isfile(clinerules):
        found.append(("file", ".clinerules"))
    elif os.path.isdir(clinerules):
        found.append(("dir", ".clinerules"))
    for dirname, _ext in OTHER_AGENT_DIRS:
        if os.path.isdir(os.path.join(root, dirname)):
            found.append(("dir", dirname))
    return found


def _dir_already_patched(dir_full):
    try:
        for fname in os.listdir(dir_full):
            fpath = os.path.join(dir_full, fname)
            if not os.path.isfile(fpath):
                continue
            try:
                with open(fpath, "r", encoding="utf-8") as f:
                    if AGENT_POLICY_MARKER in f.read():
                        return True
            except Exception:
                continue
    except Exception:
        pass
    return False


def _ext_for_dir(rel_dirname):
    for dirname, ext in OTHER_AGENT_DIRS:
        if dirname == rel_dirname:
            return ext
    return ".md"


def sync_other_agent_files(root):
    targets = find_other_agent_files(root)
    found = [rel.replace("\\", "/") for _kind, rel in targets]
    patched = []
    for kind, rel in targets:
        if kind == "file":
            full = os.path.join(root, rel)
            try:
                with open(full, "r", encoding="utf-8") as f:
                    content = f.read()
            except Exception:
                continue
            if AGENT_POLICY_MARKER in content:
                continue
            try:
                with open(full, "a", encoding="utf-8") as f:
                    f.write(AGENT_POLICY_BLOCK)
                patched.append(rel.replace("\\", "/"))
            except Exception:
                continue
        else:  # kind == "dir"
            dir_full = os.path.join(root, rel)
            if _dir_already_patched(dir_full):
                continue
            ext = _ext_for_dir(rel)
            new_file = os.path.join(dir_full, f"mem-first-policy{ext}")
            try:
                with open(new_file, "w", encoding="utf-8") as f:
                    f.write(AGENT_POLICY_BLOCK.strip() + "\n")
                patched.append(os.path.join(rel, f"mem-first-policy{ext}").replace("\\", "/"))
            except Exception:
                continue
    return found, patched


def read_stdin_json():
    try:
        return json.load(sys.stdin)
    except Exception:
        return {}


def normalize_path(p):
    if os.name != "nt" or not p:
        return p
    m = re.match(r"^/([a-zA-Z])/(.*)", p)
    if m:
        return f"{m.group(1)}:/{m.group(2)}"
    return p


def session_dir(session_id):
    d = os.path.join(STATE_DIR, session_id or "unknown")
    os.makedirs(d, exist_ok=True)
    return d


def marker(session_id, name):
    return os.path.join(session_dir(session_id), name)


def touch(path):
    open(path, "a").close()


def clear(session_id, names):
    for name in names:
        p = marker(session_id, name)
        if os.path.exists(p):
            os.remove(p)


def emit(obj):
    print(json.dumps(obj))


def repo_root(start_dir):
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=start_dir, capture_output=True, text=True, timeout=5,
        )
        if result.returncode == 0:
            return result.stdout.strip(), True
    except Exception:
        pass
    return start_dir, False


def hook_disabled(root):
    return os.path.exists(os.path.join(root, ".nomemhook"))


def top_level_dirs(root):
    try:
        return [d for d in os.listdir(root) if os.path.isdir(os.path.join(root, d))]
    except Exception:
        return []


MEM_README_STUB = (
    "# mem/\n\n"
    + MEM_PURPOSE_BLURB
    + "\n\nFilename: `YYYYMMDD-{task-slug}.md`, one file per task per day. "
    "Full template: `~/.claude/mem/template.md`. " + MEM_SCOPE_BLURB + "\n"
)


def write_mem_readme_stub(root):
    readme_path = os.path.join(root, "mem", "README.md")
    if os.path.exists(readme_path):
        return
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(MEM_README_STUB)


def ensure_mem_convention(root):
    """Idempotent check run once per session. Returns additionalContext text,
    or None if mem/ already exists. Unlike docs_workflow.py's equivalent,
    there is no alias-matching (mem/ is a specific Claude-tooling convention,
    not a general one people name differently) and no backfill offer (see
    module docstring for why).
    """
    lower_map = {d.lower(): d for d in top_level_dirs(root)}
    if "mem" in lower_map:
        return None
    os.makedirs(os.path.join(root, "mem"), exist_ok=True)
    write_mem_readme_stub(root)
    return (
        "This project had no mem/ folder for per-task session logs — created "
        "an empty one (with a mem/README.md stating its purpose) at the repo "
        "root. Not a cue to reconstruct history for past work — just start "
        "logging from this task forward."
    )


def path_parts(path):
    return path.replace("\\", "/").split("/")


def is_mem_path(path):
    return "mem" in path_parts(path)


def is_untouched_stub(root, rel_path):
    if rel_path.replace("\\", "/") != "mem/README.md":
        return False
    try:
        with open(os.path.join(root, "mem", "README.md"), "r", encoding="utf-8") as f:
            return f.read() == MEM_README_STUB
    except Exception:
        return False


def is_mem_dir_effectively_untouched(root):
    mem_dir = os.path.join(root, "mem")
    for dirpath, _dirnames, filenames in os.walk(mem_dir):
        for fname in filenames:
            full = os.path.join(dirpath, fname)
            rel = os.path.relpath(full, root).replace("\\", "/")
            if not is_untouched_stub(root, rel):
                return False
    return True


def counts_as_mem_touched(root, rel_path):
    normalized = rel_path.replace("\\", "/").rstrip("/")
    if normalized == "mem":
        return not is_mem_dir_effectively_untouched(root)
    if not is_mem_path(rel_path):
        return False
    return not is_untouched_stub(root, rel_path)


def is_source_path(path):
    parts = path_parts(path)
    if is_mem_path(path):
        return False
    return not any(part in EXCLUDED_DIR_NAMES for part in parts)


data = read_stdin_json()
session_id = data.get("session_id", "unknown")
cwd = normalize_path(data.get("cwd") or os.getcwd())
ROOT, IS_GIT_REPO = repo_root(cwd)

if hook_disabled(ROOT):
    sys.exit(0)

if MODE == "prompt":
    context_parts = [
        "Session-memory workflow (global rule): " + MEM_PURPOSE_BLURB + " "
        + MEM_SCOPE_BLURB + " Before ending the turn, if you changed source "
        "this session, add a mem/ entry for it — or explicitly say why none "
        "applies. (Opt out per-project with a `.nomemhook` file at its root.)"
    ]
    if IS_GIT_REPO:
        checked = marker(session_id, "mem_convention_checked")
        if not os.path.exists(checked):
            touch(checked)
            convention_note = ensure_mem_convention(ROOT)
            if convention_note:
                context_parts.append(convention_note)
            found, patched = sync_other_agent_files(ROOT)
            if patched:
                context_parts.append(
                    f"This project also has {', '.join(f'`{f}`' for f in found)} — "
                    "other AI tools (Codex, Gemini CLI, Cursor, etc.) work in this "
                    f"project too, not just you. Added the session-memory policy "
                    f"directly to {', '.join(f'`{f}`' for f in patched)} (their own "
                    "instructions files) so those tools search mem/ first and log "
                    "their own work there too — appended, not overwritten."
                )
            elif found:
                context_parts.append(
                    f"This project also has {', '.join(f'`{f}`' for f in found)} "
                    "for other AI tools — they already carry the session-memory "
                    "policy, nothing to change."
                )
    emit({
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": "\n\n".join(context_parts),
        }
    })
    sys.exit(0)

if MODE == "pretool":
    if not IS_GIT_REPO or not os.path.isdir(os.path.join(ROOT, "mem")):
        sys.exit(0)
    nudged = marker(session_id, "pretool_nudged")
    if os.path.exists(nudged):
        sys.exit(0)
    touch(nudged)
    emit({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": (
                "First read/search this session — this project has a mem/ "
                "folder of past task session logs. If you're reconstructing "
                "context on why something was built a certain way, search "
                "mem/ first (`grep -ril \"<topic>\" ./mem`) before reading "
                "source — it's a lead to confirm against live code, not "
                "ground truth on its own, but cheaper to check first."
            ),
        }
    })
    sys.exit(0)

if MODE == "posttool":
    file_path = ((data.get("tool_input", {}) or {}).get("file_path", "") or
                 (data.get("tool_response", {}) or {}).get("filePath", "") or "")
    if is_source_path(file_path):
        touch(marker(session_id, "source_changed"))
    sys.exit(0)

if MODE == "test":
    cmd = (data.get("tool_input", {}) or {}).get("command", "") or ""
    if any(marker_str in cmd for marker_str in TEST_COMMAND_MARKERS):
        touch(marker(session_id, "tests_ran"))
    sys.exit(0)

if MODE == "stop":
    changed = os.path.exists(marker(session_id, "source_changed"))
    tested = os.path.exists(marker(session_id, "tests_ran"))
    if not (changed or tested):
        sys.exit(0)

    # Check for mem/ files directly in filesystem since mem/ is gitignored
    # (local-only). Look for any .md files in mem/ that exist.
    mem_touched = False
    mem_dir = os.path.join(ROOT, "mem")
    if os.path.isdir(mem_dir):
        for fname in os.listdir(mem_dir):
            if fname.endswith(".md") and fname != "README.md":
                mem_touched = True
                break

    if mem_touched:
        clear(session_id, ["source_changed", "tests_ran", "blocked_once"])
        sys.exit(0)
    blocked_once = marker(session_id, "blocked_once")
    if os.path.exists(blocked_once):
        clear(session_id, ["source_changed", "tests_ran", "blocked_once"])
        sys.exit(0)
    touch(blocked_once)
    emit({
        "systemMessage": "Mem-first check: source changed without a mem/ session-log entry this session.",
        "decision": "block",
        "reason": (
            "You changed source (or ran tests) this session, but the working "
            "tree shows no real mem/ change. If this project keeps session "
            "logs under mem/, add mem/YYYYMMDD-{task-slug}.md now — The Ask, "
            "Changes Made, Decisions & Rationale, Current Architecture — "
            "scoped to what you actually did this session, before finishing. "
            "Or, if no entry genuinely applies (e.g. a trivial one-line fix), "
            "say so explicitly in your response, then stop again."
        ),
    })
    sys.exit(0)

if MODE == "precommit":
    # Invoked directly by a real git pre-commit hook (SetupMemGitHook.ps1),
    # not by Claude Code — tool-agnostic backstop, fires for commits from
    # any tool or a human, same reasoning as docs_workflow.py's precommit.
    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=ROOT, capture_output=True, text=True, timeout=10,
        )
        staged = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    except Exception:
        sys.exit(0)
    if any(is_source_path(p) for p in staged) and not any(is_mem_path(p) for p in staged):
        sys.stderr.write(
            "\n[mem-first] This commit changes source but no mem/ file. "
            f"{MEM_PURPOSE_BLURB}\nConsider adding a mem/YYYYMMDD-{{task-slug}}.md "
            "entry before pushing — not blocking this commit. Bypass this "
            "message entirely for this repo with a `.nomemhook` file at its "
            "root.\n\n"
        )
    sys.exit(0)

sys.exit(0)
