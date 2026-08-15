#!/usr/bin/env python
"""Track subagent start/stop so a heartbeat can spot agents that died silently.

Why this exists: a finished subagent already pushes a task-notification, so
polling for *completion* is pure waste. What does NOT notify is an agent that
dies mid-flight — an API stall, a session/quota limit, a crash. That happened
twice in one session: two agents were killed by a session limit and nothing
fired; it was only caught by inspecting the working tree by hand.

So the hooks below record start/stop, and `check` reports only the gap: agents
that started and never stopped. Nothing else is reported, because nothing else
needs a poll.

Modes:
  start  - SubagentStart hook. Appends a start record. Reads hook JSON on stdin.
  stop   - SubagentStop hook.  Appends a stop record.
  check  - Called by the heartbeat loop. Prints stalled agents, or nothing.

Never raises and never blocks: a broken watcher must not break a session.
"""

import json
import os
import sys
import time

LOG = os.path.join(os.path.expanduser("~"), ".claude", "agent-activity.jsonl")

# An agent quiet for longer than this is worth surfacing. Deliberately well
# above a normal run so ordinary work never trips it -- this reports stalls,
# not slowness.
#
# Was 900s, tuned when the redesign agents took 3-6 min. That produced two
# false alarms on a single 22-minute agent (URL tab routing) that was healthy
# throughout -- build + Playwright verification across two viewports and two
# themes simply takes that long. A check that cries wolf on the exact long-
# running jobs it exists to protect is worse than no check, because the
# tempting response to a false alarm is to re-dispatch, which collides with a
# live agent mid-write and loses the work for real.
STALL_SECONDS = 1800

# Stop replaying ancient history: entries older than this are ignored entirely.
MAX_AGE_SECONDS = 12 * 3600


def _stdin_payload():
    """Hook input arrives as JSON on stdin. Absent or malformed is fine."""
    try:
        if sys.stdin.isatty():
            return {}
        raw = sys.stdin.read()
        return json.loads(raw) if raw.strip() else {}
    except Exception:
        return {}


def _identity(payload):
    """Best-effort agent identity. Field names vary by event, so try several
    and fall back to the session id rather than dropping the record."""
    for key in ("agent_id", "agentId", "subagent_id", "task_id", "tool_use_id"):
        val = payload.get(key)
        if val:
            return str(val)
    return str(payload.get("session_id") or payload.get("sessionId") or "unknown")


def _label(payload):
    for key in ("subagent_type", "agent_type", "description", "name"):
        val = payload.get(key)
        if val:
            return str(val)[:60]
    return "agent"


def _append(event):
    payload = _stdin_payload()
    record = {
        "ts": int(time.time()),
        "event": event,
        "id": _identity(payload),
        "label": _label(payload),
        "cwd": payload.get("cwd") or os.getcwd(),
    }
    try:
        os.makedirs(os.path.dirname(LOG), exist_ok=True)
        with open(LOG, "a", encoding="utf-8") as fh:
            fh.write(json.dumps(record) + "\n")
    except Exception:
        pass  # logging must never break the hook chain


def _load():
    if not os.path.exists(LOG):
        return []
    cutoff = time.time() - MAX_AGE_SECONDS
    out = []
    try:
        with open(LOG, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    rec = json.loads(line)
                except Exception:
                    continue  # tolerate a torn line from concurrent writes
                if rec.get("ts", 0) >= cutoff:
                    out.append(rec)
    except Exception:
        return []
    return out


def check():
    """Three outcomes:
      IDLE     - nothing in flight; the heartbeat should disarm itself
      (silent) - agents running and healthy
      STALLED  - agents that started and never reported completion
    """
    records = _load()
    open_agents = {}
    for rec in records:
        key = rec.get("id")
        if rec.get("event") == "start":
            open_agents[key] = rec
        else:
            open_agents.pop(key, None)

    # No agents in flight => this heartbeat has nothing to watch. Watching an
    # idle session is pure overhead, so say so and let the caller stand down.
    if not open_agents:
        print("IDLE: no agents in flight")
        return

    now = time.time()
    stalled = [
        (int(now - r["ts"]) // 60, r)
        for r in open_agents.values()
        if now - r["ts"] > STALL_SECONDS
    ]
    if not stalled:
        return

    print("STALLED AGENTS (started, never reported completion):")
    for minutes, rec in sorted(stalled, reverse=True):
        print("  - %s (%s) silent %dm - cwd %s" % (rec["label"], rec["id"][:12], minutes, rec["cwd"]))
    print("A finished agent notifies on its own, so these most likely died "
          "(API stall / quota limit). Check the working tree for partial writes "
          "before re-dispatching -- their files may already be on disk.")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    if mode == "start":
        _append("start")
    elif mode == "stop":
        _append("stop")
    elif mode == "check":
        check()


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # never fail a hook
