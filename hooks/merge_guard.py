#!/usr/bin/env python
"""PreToolUse gate for `gh pr merge`.

Allows a merge only when GitHub itself reports the PR as OPEN and CLEAN.
Anything else -- conflicts, missing required review, failing checks, a stale
branch, an unverifiable state -- is denied with the specific reason.

Why this exists as a hook rather than a line in the agent prompt: the
git-commit agent is told to merge only when the PR is clean and mergeable,
but an instruction with nothing checking it is not a control. A permission
rule can't do the job either -- it matches the command string, not the PR's
state. This runs the actual query and refuses.

Fails CLOSED. If the state cannot be determined, the merge is denied.
"""

import json
import re
import shutil
import subprocess
import sys

# mergeStateStatus values that are not CLEAN, with a plain-language reason.
BLOCKED_REASONS = {
    "DIRTY": "the PR has a merge conflict",
    "BLOCKED": "a required review or required status check is missing",
    "BEHIND": "the branch is behind its target and must be updated first",
    "UNSTABLE": "at least one check is failing",
    "UNKNOWN": "GitHub has not finished computing mergeability yet",
    "DRAFT": "the PR is still a draft",
}


def deny(reason):
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        },
        sys.stdout,
    )
    sys.exit(0)


def passthrough():
    """Not our business -- stay silent and let the normal flow continue."""
    sys.exit(0)


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        passthrough()

    command = (payload.get("tool_input") or {}).get("command") or ""

    # Only interested in an actual merge. `gh pr merge --help`, `gh pr view`,
    # and anything else fall straight through.
    if not re.search(r"\bgh\s+pr\s+merge\b", command):
        passthrough()
    if re.search(r"\bgh\s+pr\s+merge\b.*(--help|-h)\b", command):
        passthrough()

    # An admin override exists precisely to bypass the protections this gate
    # is checking. Never allowed from a hook-gated agent.
    if re.search(r"\s--admin\b", command):
        deny(
            "Refused: `gh pr merge --admin` bypasses branch protection and "
            "required checks. This gate exists to enforce them. Merge without "
            "--admin once the PR is CLEAN, or have a human do the override."
        )

    if shutil.which("gh") is None:
        deny("Refused: `gh` is not on PATH, so PR state cannot be verified. This gate fails closed.")

    # `gh pr merge 123` targets that PR; a bare `gh pr merge` targets the PR
    # for the current branch. Mirror both.
    match = re.search(r"\bgh\s+pr\s+merge\s+(\d+)", command)
    view = ["gh", "pr", "view"]
    if match:
        view.append(match.group(1))
    view += ["--json", "number,state,mergeStateStatus,mergeable,title"]

    try:
        result = subprocess.run(view, capture_output=True, text=True, timeout=30)
    except (subprocess.SubprocessError, OSError) as exc:
        deny(f"Refused: could not query PR state ({exc.__class__.__name__}). This gate fails closed.")

    if result.returncode != 0:
        detail = (result.stderr or "").strip().splitlines()
        detail = detail[-1] if detail else f"exit {result.returncode}"
        deny(f"Refused: could not read PR state via `gh pr view` ({detail}). This gate fails closed.")

    try:
        pr = json.loads(result.stdout)
    except (json.JSONDecodeError, ValueError):
        deny("Refused: `gh pr view` returned unparseable JSON. This gate fails closed.")

    number = pr.get("number", "?")
    state = pr.get("state")
    status = pr.get("mergeStateStatus")

    if state != "OPEN":
        deny(f"Refused: PR #{number} is {state}, not OPEN.")

    if status != "CLEAN":
        why = BLOCKED_REASONS.get(status, f"mergeStateStatus is {status}")
        deny(
            f"Refused: PR #{number} is not in a clean, mergeable state — {why} "
            f"(mergeStateStatus: {status}). Report this to the orchestrator "
            f"instead of merging."
        )

    # CLEAN and OPEN. Say so in the transcript, then let the normal permission
    # flow decide -- this gate only ever subtracts, it never grants.
    print(f"merge_guard: PR #{number} is OPEN and CLEAN - merge condition satisfied.")
    sys.exit(0)


if __name__ == "__main__":
    main()
