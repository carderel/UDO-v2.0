# Bridge Protocol v1.0

## Overview

The Bridge is a bidirectional communication system between two or more AI agent instances that cannot directly communicate with each other. It uses shared files on the local filesystem as the communication channel.

**Core principle:** Any AI that can read and write files can participate in the bridge. The protocol is AI-agnostic — platform-specific details live in adapter definitions, not here.

### Roles

The bridge uses role-based naming, not platform names:

- **Local Agent** — The AI with direct filesystem access, code execution, and CLI capabilities. Operates within the project directory. (Example: Claude Code, Cursor, Gemini CLI)
- **Remote Agent** — The AI with capabilities outside the local environment: web browsing, desktop automation, cloud service access, document creation. (Example: Claude Desktop, Gemini Desktop, GPT Desktop)

Either agent can initiate requests. The human operator acts as the trigger, telling each agent when to check the bridge.

---

## File Structure

```
.bridge/
├── BRIDGE-PROTOCOL.md      # This file — the rules all agents follow
├── PRE-FLIGHT-AUDIT.md     # Complexity scoring for bridge requests
├── BROWSER-LADDER.md       # Escalation order for browser reads
├── bridge-queue.md          # Active requests and responses (the communication channel)
├── bridge-state.json        # Machine-readable status flags
├── session-log.md           # Running log of all bridge activity
├── templates/
│   ├── bridge-request.md    # Request format template
│   └── bridge-response.md   # Response format template
└── adapters/
    ├── README.md             # How adapters work
    ├── _template/
    │   └── adapter.md        # Blank adapter template
    └── {platform}/           # One folder per AI platform
        ├── adapter.md        # Platform capabilities and configuration
        └── INSTRUCTIONS.md   # Instructions to paste/load into that platform
```

---

## Communication Protocol

### Request Format

When either agent needs the other to do something, **append** a request block to `bridge-queue.md`:

```markdown
## REQUEST: [REQ-XXXX]
- **From:** {Local | Remote | agent-name}
- **To:** {Local | Remote | agent-name}
- **Priority:** {URGENT | NORMAL | LOW}
- **Status:** NEW
- **Timestamp:** YYYY-MM-DD HH:MM:SS
- **Category:** {see category list below}

### Context
{Full context — the receiving agent has ZERO memory of what you have been doing.
Include: what you're working on, what you've tried, relevant file paths, error messages.}

### Request
{Clear description of what needs to be done.}

### Acceptance Criteria
{How to know the task is done correctly.}
```

### Response Format

The receiving agent appends a response block **directly below** the request:

```markdown
### Response — [YYYY-MM-DD HH:MM:SS]
- **From:** {agent responding}
- **Status:** {COMPLETED | FAILED | NEEDS_CLARIFICATION}

{Results, findings, files created, actions taken.}

### Follow-up Needed
{Next steps for the requesting agent, or NONE.}
```

### Request IDs

Sequential: REQ-0001, REQ-0002, etc. Always increment from the last ID in the queue.

### Request Categories

| Category | When to Use |
|----------|-------------|
| `web-research` | Need information from the internet |
| `mac-automation` | Need to control a desktop application |
| `browser-task` | Need to interact with a web browser |
| `file-operation` | Need files read, written, or transformed |
| `code-task` | Need code written, tested, or debugged |
| `google-drive` | Need access to Google Drive files |
| `cloud-service` | Need access to Slack, email, calendar, or other cloud APIs |
| `document-creation` | Need a document, presentation, or spreadsheet created |
| `troubleshoot` | Something is broken, need help diagnosing |
| `other` | Doesn't fit above categories |

---

## Pre-Flight Complexity Audit

Every bridge request MUST pass a complexity audit before execution (**HS-UDO-010**). The receiving agent scores each operation in the request by tier (0-5 pts) and sums the weights. Scores 0-6 execute in a single prompt; 7-10 require phased decomposition and human approval; >10 trigger a HALT circuit breaker. The audit block is appended below the request in `bridge-queue.md` (respecting append-only HS-UDO-009). If no audit block exists, the request has not been audited and MUST NOT be executed.

**Full protocol:** See `PRE-FLIGHT-AUDIT.md`

---

## Browser Execution Ladder

All browser-based read operations follow a mandatory 5-level escalation order (**HS-UDO-011**): (1) Screenshot, (2) Page text extraction, (3) Targeted DOM query, (4) Full accessibility tree, (5) Static fallback request. Execution starts at Level 1 and escalates only on failure. Page type rules permit specific level skips (e.g., Looker dashboards skip Levels 2-4 due to canvas rendering). Every escalation is logged with reason. Reaching Level 5 means all automated options are exhausted — flag to user.

**Full protocol:** See `BROWSER-LADDER.md`

---

## Session Log Protocol

Both agents append to `session-log.md`. Rules:

1. **Log everything meaningful** — commands run, errors hit, decisions made, files changed
2. **Include full error messages** — do not summarize, paste the actual error
3. **Note reasoning** — why you chose approach A over B
4. **Flag blockers immediately** — if something needs the other agent, say so
5. **Keep entries atomic** — one action per entry
6. **Timestamp everything**

### Log Entry Format

```markdown
## [YYYY-MM-DD HH:MM:SS] [LOCAL|REMOTE] — Brief Title

**Action:** What was done
**Result:** What happened
**Context:** Why it matters, relevant state changes

---
```

---

## State File (bridge-state.json)

```json
{
  "bridge_version": "1.0",
  "last_updated": "ISO timestamp",
  "last_updated_by": "local | remote | agent-name",
  "status": "idle | local_waiting | remote_waiting | both_active",
  "pending_requests": 0,
  "active_request_id": null,
  "session_started": "ISO timestamp",
  "local_last_seen": "ISO timestamp",
  "remote_last_seen": "ISO timestamp",
  "adapters_active": [],
  "flags": {
    "urgent": false,
    "needs_human": false,
    "error_state": false
  }
}
```

**Update rules:**
- Update `last_updated` and `last_updated_by` on every state change
- Update `local_last_seen` / `remote_last_seen` whenever that agent interacts with the bridge
- Set `pending_requests` to the count of requests with status NEW or IN_PROGRESS
- Set `adapters_active` to the list of adapter names currently in use

---

## Auto-Detection Rules

### Local Agent should automatically write a bridge request when:

1. It encounters an error it cannot resolve after **2 attempts**
2. A task requires capabilities **outside its CAPABILITIES.json**
3. A task requires web research or browsing
4. A task requires interacting with a desktop application
5. A task requires access to cloud services (Google Drive, email, Slack, etc.)
6. A task requires browser automation
7. The human says anything like "ask the other AI" or "get help from [platform name]"

### Remote Agent should automatically write a bridge response when:

1. It completes any request from `bridge-queue.md`
2. It finds information that changes the current approach
3. It encounters a limitation that the Local Agent could handle instead

---

## Error Escalation Protocol

| Level | Action | Max Attempts |
|-------|--------|--------------|
| **1 — Self-resolve** | Try to fix independently | 2 attempts |
| **2 — Bridge request** | Write detailed request to the other agent | 1 request (may clarify) |
| **3 — Human intervention** | Both agents stuck. Set `needs_human: true` in bridge-state.json | Escalate immediately |

---

## Important Rules

1. **Never overwrite** — always APPEND to `bridge-queue.md` and `session-log.md`
2. **Be verbose in context** — the receiving agent has NO memory of what you have been doing
3. **Include file paths** — always use absolute paths
4. **Paste actual errors** — do not paraphrase error messages
5. **Update state** — always update `bridge-state.json` when you start or finish something
6. **Increment request IDs** — sequential from last ID in queue
7. **Timestamp everything**
8. **Check your adapter** — read your platform's adapter in `adapters/` to know your capabilities and limitations

---

## Trigger Phrases (for the Human)

### Tell the Remote Agent:
- **"Check the bridge"** — Read `bridge-queue.md` and handle any NEW requests
- **"Bridge status"** — Read `bridge-state.json` and report
- **"Sync up"** — Read the full session log and get up to speed

### Tell the Local Agent:
- **"Bridge request [description]"** — Write a structured request to `bridge-queue.md`
- **"Check bridge"** — Read `bridge-queue.md` for completed responses
- **"Bridge log"** — Write current context to `session-log.md`

---

## Integration with UDO

When operating inside a UDO project:

- Bridge activity is part of the UDO session. Log it in the session log at `.project-catalog/sessions/`.
- Bridge decisions go to `.project-catalog/decisions/` if they affect the project.
- Completed bridge queue entries can be archived to `.project-catalog/communications/`.
- The Local Agent's `CAPABILITIES.json` should reflect bridge availability.
- Bridge state is tracked in `PROJECT_STATE.json` under the `bridge` key.
- The hard stop **HS-UDO-009** applies: bridge-queue.md and session-log.md are **append-only**.
