#!/usr/bin/env python3
"""Documentation-first workflow enforcement — global, applies to every project.

Modes (first CLI arg), one per hook wiring in ~/.claude/settings.json:

  prompt   - UserPromptSubmit: inject a "check docs first" reminder every
             turn, plus (once per session, git repos only) enforce the
             docs/ naming convention itself — see below.
  pretool  - PreToolUse (Edit|Write): once per session, before the first edit
             to a non-doc source file, remind Claude to check this project's
             docs/ folder.
  posttool - PostToolUse (Edit|Write): silently record that source changed.
  test     - PostToolUse (Bash): silently record that a test command ran.
  stop     - Stop: if source changed (or tests ran) without any docs/ change
             in the working tree, block once and tell Claude to update docs
             before finishing. A second consecutive trigger for the same
             unresolved change is let through, so a deliberate "no doc
             update needed" judgment call doesn't loop.

This is intentionally project-agnostic: it does not assume any particular
folder layout (no hardcoded backend/frontend, no hardcoded doc subfolder
names). It only assumes the convention "documentation for this project
lives somewhere under a docs/ directory."

Docs-folder convention enforcement (in `prompt` mode, once per session, only
inside an actual git repo so this never scatters folders into unrelated
directories):
  - No docs/ and nothing that looks like one exists -> the hook itself
    creates an empty docs/ folder (always safe: a new empty directory can't
    break anything). If the repo also looks established (real commit
    history / file count, see is_established_codebase), it additionally
    instructs Claude to ask the user whether a background Agent should
    backfill per-feature docs for the existing code, isolated in its own
    git worktree so a wide-sweep background job can't collide with
    whatever Claude is editing live for the user's actual request.
    IMPORTANT boundary: this offer fires exactly once, only at the moment
    docs/ is created from nothing. It does NOT audit an already-existing
    docs/ for coverage gaps against features added later without a
    matching doc — that's session-to-session drift this hook has no memory
    of, and would need a deliberate audit mechanism, not a per-prompt check.
  - No docs/, but exactly one differently-named candidate exists
    (documentation/, doc/, wiki/, handbook/, guides/, manual/) -> the hook
    does NOT rename it. Renaming can break things it doesn't know about
    (READMEs, CI, site-generator config), so instead it instructs Claude to
    do the rename itself this turn (git mv, then grep the repo for
    references and fix them) — a visible, reviewable change instead of a
    silent background mutation.
  - Multiple candidates exist -> instructs Claude to ask the user which one
    is canonical rather than guessing.

docs/ has one specific job: quick per-feature/component reference so a
feature can be understood without reading all its source. It is NOT a
replacement for README.md / ARCHITECTURE.md / DESIGN.md / PUBLISH.md, which
cover onboarding, high-level architecture, and release process. Every
reminder this hook emits states that distinction explicitly (see
DOCS_PURPOSE_BLURB), and a freshly-created docs/ is seeded with a
docs/README.md saying the same, so the distinction survives even if this
hook is later disabled or the session context is gone. When those other
top-level doc files exist, `other_docs_note()` names them explicitly so
their presence is never mistaken for satisfying this convention.

Opt out for a specific repo by creating a `.nodocshook` file at its root.

State is tracked per session_id in a temp directory so a fresh session
starts clean and concurrent sessions don't interfere with each other.
"""
import json
import os
import re
import subprocess
import sys
import tempfile

MODE = sys.argv[1] if len(sys.argv) > 1 else ""
STATE_DIR = os.path.join(tempfile.gettempdir(), "claude-docs-hook")

# Directories that never count as "source" for the purposes of this hook,
# regardless of project type/language.
EXCLUDED_DIR_NAMES = {
    "docs", "mem", ".claude", ".git", "node_modules", "dist", "build",
    ".next", "__pycache__", "venv", ".venv", "vendor", "target",
    ".idea", ".vscode", "coverage", ".pytest_cache", "out",
}

TEST_COMMAND_MARKERS = (
    "pytest", "npm run test", "npm test", "npx jest", "playwright test",
    "go test", "cargo test", "mvn test", "dotnet test", "rspec",
)

# Common alternate names people use for a docs/ folder. Matched case-insensitively
# against actual top-level directory names.
DOC_FOLDER_ALIASES = {"documentation", "doc", "wiki", "handbook", "guides", "manual"}

# Top-level files that serve a DIFFERENT purpose than docs/ (onboarding,
# architecture, release process) and must never be mistaken for satisfying
# the per-feature-reference convention this hook enforces.
OTHER_DOC_FILES = {
    "readme.md", "architecture.md", "design.md", "publish.md",
    "publishing.md", "contributing.md", "changelog.md",
}

DOCS_PURPOSE_BLURB = (
    "This project's docs/ folder holds quick per-feature/component reference "
    "docs — what a feature does, what files it touches, known issues — so it "
    "can be understood without reading all the source. It does NOT replace "
    "README.md / ARCHITECTURE.md / DESIGN.md / PUBLISH.md (if present); those "
    "cover onboarding, high-level architecture, and release process, not "
    "per-feature reference."
)

DOCS_SCOPE_BLURB = (
    "Scope is strictly the feature/component you're actively touching this "
    "session — never a retroactive sweep to document the rest of an existing "
    "codebase just because docs/ is new or empty."
)

# Project-root FILES other AI coding tools read as their own standing
# instructions, analogous to CLAUDE.md. Presence of any of these is evidence
# that this specific project is worked on by more than just Claude Code.
# CLAUDE.md is deliberately excluded — that's Claude Code's own file and may
# already have carefully-written, project-specific content of its own; this
# hook has no business rewriting it. Includes nested single-file conventions
# too (Copilot's is fixed at .github/copilot-instructions.md, not root-level).
OTHER_AGENT_FILES = (
    "AGENTS.md", "GEMINI.md", ".cursorrules", ".windsurfrules",
    os.path.join(".github", "copilot-instructions.md"),
)

# Some tools use a DIRECTORY of rule files instead of one flat file (Cursor's
# current convention, Windsurf's equivalent, and Cline's directory variant of
# .clinerules). Can't append to "a directory" — instead, if none of the files
# already inside it carry our marker, add one new file with the policy.
# (extension, dirname) — extension matches what that tool's own rule files
# use, so ours doesn't look out of place.
OTHER_AGENT_DIRS = (
    (os.path.join(".cursor", "rules"), ".mdc"),
    (os.path.join(".windsurf", "rules"), ".md"),
)

AGENT_POLICY_MARKER = "<!-- docs-first-hook:v1 -->"

AGENT_POLICY_BLOCK = (
    f"\n{AGENT_POLICY_MARKER}\n"
    "## Documentation-first workflow (added by a global Claude Code hook)\n\n"
    + DOCS_PURPOSE_BLURB + "\n\n"
    "Before implementing or changing a feature/component, check docs/ "
    "(docs/README.md if present) for its existing doc. After changing "
    "source, add or update that feature's doc under docs/ — or say why none "
    "applies. " + DOCS_SCOPE_BLURB + "\n"
    f"{AGENT_POLICY_MARKER}\n"
)


def find_other_agent_files(root):
    """Returns a list of (kind, relative_path) — kind is 'file' or 'dir'.
    .clinerules specifically can be either a single file or a directory of
    rule files depending on how the project set it up, so it's checked both
    ways rather than assumed.
    """
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
    """For every other-AI instructions file/directory already present in this
    project, add the docs-first policy if it isn't there yet. Never
    overwrites existing content: files get an append (marker-guarded, only
    once), directories get a brand-new file added alongside whatever's
    already there. Returns (found, patched) — found is every target
    detected (as display strings), patched is the subset that didn't already
    carry the policy and just got it added.
    """
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
            new_file = os.path.join(dir_full, f"docs-first-policy{ext}")
            try:
                with open(new_file, "w", encoding="utf-8") as f:
                    f.write(AGENT_POLICY_BLOCK.strip() + "\n")
                patched.append(os.path.join(rel, f"docs-first-policy{ext}").replace("\\", "/"))
            except Exception:
                continue
    return found, patched


def read_stdin_json():
    try:
        return json.load(sys.stdin)
    except Exception:
        return {}


def normalize_path(p):
    """Windows subprocess cwd needs a drive letter — translate git-bash/MSYS
    style paths ('/c/Users/...', '/tmp/...') into native Windows form.
    A bare '/tmp/...' with no drive letter has no Windows equivalent to
    infer, so it's left as-is (callers already handle git failures safely).
    """
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
    """Returns (root_path, is_git_repo)."""
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
    return os.path.exists(os.path.join(root, ".nodocshook"))


def top_level_dirs(root):
    try:
        return [d for d in os.listdir(root) if os.path.isdir(os.path.join(root, d))]
    except Exception:
        return []


def top_level_files(root):
    try:
        return [f for f in os.listdir(root) if os.path.isfile(os.path.join(root, f))]
    except Exception:
        return []


def other_docs_note(root):
    """Names any README/ARCHITECTURE/DESIGN/PUBLISH-style files at root, so
    their presence is never mistaken for satisfying the docs/ convention."""
    found = [f for f in top_level_files(root) if f.lower() in OTHER_DOC_FILES]
    if not found:
        return ""
    names = ", ".join(f"`{f}`" for f in found)
    return (
        f" This project also has {names} at its root — those cover a "
        f"different purpose and don't count toward this."
    )


DOCS_README_STUB = (
    "# docs/\n\n"
    + DOCS_PURPOSE_BLURB
    + "\n\nEvery new feature or component should get (or update) a doc here. "
    + DOCS_SCOPE_BLURB
    + " Pre-existing features stay undocumented until someone actually "
    "touches them — this folder starting empty is not a backlog to clear.\n"
)


def write_docs_readme_stub(root):
    readme_path = os.path.join(root, "docs", "README.md")
    if os.path.exists(readme_path):
        return
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(DOCS_README_STUB)


ESTABLISHED_COMMIT_THRESHOLD = 5
ESTABLISHED_FILE_THRESHOLD = 20


def is_established_codebase(root):
    """Heuristic: does this repo already have real, pre-existing work (as
    opposed to being freshly initialized)? Used to decide whether it's worth
    offering a docs backfill at all — a brand-new repo has nothing to
    backfill, so there's no point asking.
    """
    try:
        commits = subprocess.run(
            ["git", "rev-list", "--count", "HEAD"],
            cwd=root, capture_output=True, text=True, timeout=5,
        )
        commit_count = int(commits.stdout.strip()) if commits.returncode == 0 else 0
    except Exception:
        commit_count = 0
    try:
        files = subprocess.run(
            ["git", "ls-files"],
            cwd=root, capture_output=True, text=True, timeout=5,
        )
        file_count = len(files.stdout.splitlines()) if files.returncode == 0 else 0
    except Exception:
        file_count = 0
    return commit_count >= ESTABLISHED_COMMIT_THRESHOLD or file_count >= ESTABLISHED_FILE_THRESHOLD


def ensure_docs_convention(root):
    """Idempotent check run once per session. Returns additionalContext text
    to surface to Claude, or None if docs/ already exists in the right place.
    May itself create an empty docs/ folder + seed README (safe, non-
    destructive) but never renames anything — renames are left to Claude to
    perform visibly.
    """
    lower_map = {d.lower(): d for d in top_level_dirs(root)}
    if "docs" in lower_map:
        return None

    note = other_docs_note(root)
    candidates = [lower_map[name] for name in DOC_FOLDER_ALIASES if name in lower_map]
    if len(candidates) == 1:
        alt = candidates[0]
        return (
            f"This project keeps a `{alt}/` folder and has no `docs/`. Before "
            f"assuming it's a drop-in replacement, peek at a few files inside "
            f"`{alt}/` to confirm it's actually per-feature developer "
            f"reference (not e.g. end-user wiki content, which serves a "
            f"different purpose). If it matches: rename it now "
            f"(`git mv {alt} docs`), grep the whole repo for references to "
            f"`{alt}/` and fix each one, then add a docs/README.md stating "
            f"the docs/ purpose ({DOCS_PURPOSE_BLURB}). If it doesn't match, "
            f"leave `{alt}/` alone, create a fresh `docs/` instead, and tell "
            f"the user what you found. Either way: {DOCS_SCOPE_BLURB}" + note
        )
    if len(candidates) > 1:
        names = ", ".join(f"`{c}/`" for c in candidates)
        return (
            f"This project has no `docs/` folder but multiple candidates that "
            f"might be it ({names}). Don't guess — ask the user which one "
            f"should become the canonical `docs/`, then rename it (git mv) and "
            f"fix references to the old name." + note
        )

    os.makedirs(os.path.join(root, "docs"), exist_ok=True)
    write_docs_readme_stub(root)
    base_msg = (
        "This project had no docs/ folder at all — created an empty one "
        "(with a docs/README.md stating its purpose) at the repo root."
    )
    if is_established_codebase(root):
        offer = (
            " This looks like an existing, already-built codebase (real commit "
            "history / file count), not a fresh project — ask the user (via "
            "AskUserQuestion) whether they'd like a background Agent to backfill "
            "per-feature docs for the existing code. If yes, dispatch it now "
            "(subagent_type: general-purpose or fork) with isolation: \"worktree\" "
            "— non-negotiable here, not optional: a wide sweep across many files "
            "running concurrently with your own edits needs its own branch, not "
            "just its own directory. Keep working on what they actually asked "
            "for yourself in the meantime — don't wait on it. If no or "
            "unanswered, just proceed without asking again this session. "
            f"{DOCS_SCOPE_BLURB}" + note
        )
        return base_msg + offer
    return (
        base_msg + " Do NOT treat this as a cue to backfill documentation for "
        "the rest of the codebase now — just proceed to what the user "
        f"actually asked for. {DOCS_SCOPE_BLURB}" + note
    )


def path_parts(path):
    return path.replace("\\", "/").split("/")


def is_doc_path(path):
    return "docs" in path_parts(path)


def is_untouched_stub(root, rel_path):
    """True if rel_path is the auto-generated docs/README.md and its content
    is still exactly what we wrote — i.e. nobody has actually documented
    anything yet. Without this, the stub's mere existence in `git status`
    would satisfy the docs-touched check for the rest of the session, even
    though no real feature doc was ever written.
    """
    if rel_path.replace("\\", "/") != "docs/README.md":
        return False
    try:
        with open(os.path.join(root, "docs", "README.md"), "r", encoding="utf-8") as f:
            return f.read() == DOCS_README_STUB
    except Exception:
        return False


def is_docs_dir_effectively_untouched(root):
    """`git status --porcelain` collapses a wholly-untracked directory into a
    single '?? docs/' line rather than listing files inside it — so if docs/
    is brand new this session, we never see 'docs/README.md' individually
    and is_untouched_stub() never gets a chance to run against it. Walk the
    actual filesystem instead: true only if every file under docs/ is the
    unmodified stub (i.e. nothing real has been written there yet).
    """
    docs_dir = os.path.join(root, "docs")
    for dirpath, _dirnames, filenames in os.walk(docs_dir):
        for fname in filenames:
            full = os.path.join(dirpath, fname)
            rel = os.path.relpath(full, root).replace("\\", "/")
            if not is_untouched_stub(root, rel):
                return False
    return True


def counts_as_docs_touched(root, rel_path):
    normalized = rel_path.replace("\\", "/").rstrip("/")
    if normalized == "docs":
        return not is_docs_dir_effectively_untouched(root)
    if not is_doc_path(rel_path):
        return False
    return not is_untouched_stub(root, rel_path)


def is_source_path(path):
    parts = path_parts(path)
    if is_doc_path(path):
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
        "Documentation-first workflow (global rule): " + DOCS_PURPOSE_BLURB + " "
        "If this turn implements, changes, or tests a feature/component, "
        "first check docs/ (docs/README.md if present) for its existing doc. "
        "Read only the relevant section(s) and only the specific source files "
        "the doc points to — do not glob or read whole directories/files "
        "wholesale when the doc already names the exact files. Fall back to "
        "broader grep/exploration only when the doc is silent on the detail, "
        "contradicts what you observe in code, or looks stale (cross-check "
        "mem/ if unsure) — then verify against live code, not the doc. "
        "Before ending the turn, if you changed source, add/update that "
        "feature's doc under docs/ — or explicitly say why none applies. "
        + DOCS_SCOPE_BLURB + " "
        "(Opt out per-project with a `.nodocshook` file at its root.)"
    ]
    if IS_GIT_REPO:
        checked = marker(session_id, "docs_convention_checked")
        if not os.path.exists(checked):
            touch(checked)
            convention_note = ensure_docs_convention(ROOT)
            if convention_note:
                context_parts.append(convention_note)
            found, patched = sync_other_agent_files(ROOT)
            if patched:
                context_parts.append(
                    f"This project also has {', '.join(f'`{f}`' for f in found)} — "
                    "other AI tools (Codex, Gemini CLI, Cursor, etc.) work in this "
                    f"project too, not just you. Added the documentation-first "
                    f"policy directly to {', '.join(f'`{f}`' for f in patched)} "
                    "(their own instructions files) so those tools see the same "
                    "rule the next time they run here — appended, not "
                    "overwritten, so whatever was already in those files stands."
                )
            elif found:
                context_parts.append(
                    f"This project also has {', '.join(f'`{f}`' for f in found)} "
                    "for other AI tools — they already carry the "
                    "documentation-first policy, nothing to change."
                )
    emit({
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": "\n\n".join(context_parts),
        }
    })
    sys.exit(0)

if MODE == "pretool":
    file_path = (data.get("tool_input", {}) or {}).get("file_path", "") or ""
    if not is_source_path(file_path):
        sys.exit(0)
    nudged = marker(session_id, "pretool_nudged")
    if os.path.exists(nudged):
        sys.exit(0)
    touch(nudged)
    emit({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": (
                f"About to edit {file_path} — first source edit this session. "
                "If this project has a docs/ folder, check it (docs/README.md if "
                "present) for the doc covering this area before proceeding."
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
    try:
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            cwd=ROOT, capture_output=True, text=True, timeout=10,
        )
        out = result.stdout
    except Exception:
        sys.exit(0)
    paths = [line[3:].strip() for line in out.splitlines() if line.strip()]
    docs_touched = any(counts_as_docs_touched(ROOT, p) for p in paths)
    if docs_touched:
        clear(session_id, ["source_changed", "tests_ran", "blocked_once"])
        sys.exit(0)
    blocked_once = marker(session_id, "blocked_once")
    if os.path.exists(blocked_once):
        clear(session_id, ["source_changed", "tests_ran", "blocked_once"])
        sys.exit(0)
    touch(blocked_once)
    emit({
        "systemMessage": "Docs-first check: source changed without a docs/ update this session.",
        "decision": "block",
        "reason": (
            "You changed source (or ran tests) this session, but the working tree "
            "shows no docs/ change. If this project keeps documentation under docs/, "
            "check it for the feature doc this change belongs to and update just "
            "that doc (files touched, behavior, known issues, status) before "
            "finishing — scoped to what you actually changed, not a pass over "
            "unrelated pre-existing docs. Or, if no doc update genuinely applies "
            "(e.g. a trivial fix, or this project doesn't document at that "
            "granularity), say so explicitly in your response, then stop again."
        ),
    })
    sys.exit(0)

if MODE == "precommit":
    # Invoked directly by a real git pre-commit hook, not by Claude Code — no
    # tool/agent involved, no session_id, no stdin JSON. This is the
    # tool-agnostic backstop: it fires the same way regardless of whether the
    # commit came from Claude Code, Codex, Gemini CLI, or a human typing
    # `git commit`, since all of those eventually go through git. Warn-only,
    # never blocks a commit — the mechanical, blocking enforcement is Claude
    # Code's job (see "stop" above); this just catches what slips through
    # when a different tool (or a human) was driving.
    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=ROOT, capture_output=True, text=True, timeout=10,
        )
        staged = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    except Exception:
        sys.exit(0)
    if any(is_source_path(p) for p in staged) and not any(is_doc_path(p) for p in staged):
        sys.stderr.write(
            "\n[docs-first] This commit changes source but no docs/ file. "
            f"{DOCS_PURPOSE_BLURB}\nIf this change touches a feature/component, "
            "consider updating its doc under docs/ before pushing — not "
            "blocking this commit. Bypass this message entirely for this repo "
            "with a `.nodocshook` file at its root.\n\n"
        )
    sys.exit(0)

sys.exit(0)
