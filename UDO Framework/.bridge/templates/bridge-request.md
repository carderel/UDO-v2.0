# Bridge Request Template

Use this format when writing a request in `bridge-queue.md`.

---

```markdown
## REQUEST: {REQ_ID}
- **From:** {FROM_AGENT}
- **To:** {TO_AGENT}
- **Priority:** {URGENT | NORMAL | LOW}
- **Status:** NEW
- **Timestamp:** {YYYY-MM-DD HH:MM:SS}
- **Category:** {CATEGORY}

### Context
{Full context — the receiving agent has ZERO memory of what you have been doing.
Include: what project/task you're working on, what you've tried, relevant file paths,
error messages (pasted verbatim, not summarized).}

### Request
{Clear, specific description of what needs to be done.}

### Acceptance Criteria
{How the requesting agent will know the response is complete and correct.}
```

---

## Field Reference

**Priority:**
- `URGENT` — Blocking current work, need response ASAP
- `NORMAL` — Needed but not immediately blocking
- `LOW` — Nice to have, can wait

**Status (set by protocol, not by requester):**
- `NEW` — Just created, waiting for receiving agent
- `IN_PROGRESS` — Receiving agent is working on it
- `COMPLETED` — Done, response attached
- `FAILED` — Could not complete, reason in response
- `NEEDS_CLARIFICATION` — Receiving agent needs more information

**Category:**
- `web-research` — Need information from the internet
- `mac-automation` — Need to control a desktop application
- `browser-task` — Need to interact with a web browser
- `file-operation` — Need files read, written, or transformed
- `code-task` — Need code written, tested, or debugged
- `google-drive` — Need access to Google Drive files
- `cloud-service` — Need access to Slack, email, calendar, etc.
- `document-creation` — Need a document, presentation, or spreadsheet
- `troubleshoot` — Something is broken, need help diagnosing
- `other` — Doesn't fit above categories

---

## Pre-Flight Audit Block

The pre-flight audit fields (Complexity-Score, Execution-Plan, Fallback-Assets) are **NOT** part of the request header above. They are populated by a `### Pre-Flight Audit` block that the receiving agent appends **below** the request after running the audit. This respects the append-only rule (HS-UDO-009).

If you are the **receiving agent**: after reading a NEW request, run the pre-flight complexity audit (see `PRE-FLIGHT-AUDIT.md`) and append the audit block before executing. If no audit block exists below the request, the audit has not been run — do not execute.

If you are the **requesting agent**: you do not need to add audit fields. The receiving agent handles this.
