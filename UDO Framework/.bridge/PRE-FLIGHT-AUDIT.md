# Pre-Flight Complexity Audit

## Purpose

Scores bridge request operations to prevent overloaded single-prompt execution. Complex requests — especially those involving browser DOM reads, canvas-rendered pages, or auth-dependent workflows — can exceed rate limits, context windows, and timeout thresholds when bundled into a single prompt. This audit decomposes and restructures them before execution.

---

## When It Runs

**MANDATORY** before executing any bridge request. Enforced by **HS-UDO-010**.

- **Automatic trigger:** The receiving agent runs the audit after reading a NEW request from `bridge-queue.md`, before starting any work.
- **Manual trigger:** `Pre-flight [REQ-XXXX]` — runs the audit on a specific request without executing it.

If no `### Pre-Flight Audit` block exists below a request in `bridge-queue.md`, the audit has **not been run**. The request MUST NOT be executed.

---

## Tier Weights

| Tier | Weight | Operations |
|------|--------|------------|
| **Tier 1** | 0 pts | Text parsing, reasoning, output generation, summarization |
| **Tier 2** | 1 pt | Small file reads (<100KB), static HTML pages, screenshots, CSV/XLSX parsing |
| **Tier 3** | 3 pts | AppleScript on large files (>100KB), browser DOM reads, file write-back |
| **Tier 4** | 5 pts | Canvas/SPA pages (Looker, Data Studio), auth-dependent pages, multi-tab sequential reads |

### Tier Assignment Rules

- If an operation spans multiple tiers, use the **highest applicable tier**
- If uncertain, round **up** — overestimating complexity is safer than underestimating
- A single "read this webpage" may be Tier 2 (static) or Tier 4 (canvas SPA) — identify the page type first
- File size thresholds are approximate; when in doubt, treat as the higher tier

---

## Scoring Process

1. **Parse** the request's Context, Request, and Acceptance Criteria sections
2. **Identify** each distinct operation the request requires
3. **Assign** a tier to each operation using the table above
4. **Sum** the weights of all operations to get the **Complexity Score**

### Example

```
Request: "Read a Looker dashboard, extract 3 tables, summarize findings, write to a markdown file"

Operations:
  1. Navigate to Looker dashboard       → Tier 4 (canvas SPA)     = 5 pts
  2. Extract table 1                    → Tier 4 (canvas read)    = 5 pts
  3. Extract table 2                    → Tier 4 (canvas read)    = 5 pts
  4. Extract table 3                    → Tier 4 (canvas read)    = 5 pts
  5. Summarize findings                 → Tier 1 (reasoning)      = 0 pts
  6. Write markdown file                → Tier 3 (file write-back)= 3 pts

Complexity Score: 23 → HALT
```

---

## Decision Thresholds

| Score | Verdict | Action |
|-------|---------|--------|
| **0-6** | SINGLE-PROMPT OK | Execute the request in one prompt as written |
| **7-10** | PHASED | Decompose into phases, await human approval before executing |
| **>10** | HALT | Circuit breaker. Break into separate requests or escalate to human |

---

## Phased Restructuring Rules

When the verdict is **PHASED** (score 7-10):

1. **Decompose** the request into phases:
   - **Phase 1 — Gather:** All read/fetch operations
   - **Phase 2 — Analyze:** All reasoning, comparison, evaluation
   - **Phase 3 — Output:** All write-back, formatting, delivery

2. **Reorder cheapest-first** within each phase — execute Tier 1-2 operations before Tier 3-4

3. **Generate fallback assets list** for every Tier 3 and Tier 4 resource:
   - Identify a static alternative the user could provide instead
   - Specify the preferred format (e.g., "XLSX export instead of browser read")

4. **Each phase becomes a separate prompt** — the receiving agent completes one phase, logs results, then proceeds to the next

---

## Audit Block Format

The audit block is **appended below the request** in `bridge-queue.md`. This respects the append-only rule (HS-UDO-009). It is NOT part of the request header.

```markdown
### Pre-Flight Audit
- **Complexity-Score:** {total score}
- **Verdict:** {SINGLE-PROMPT OK | PHASED | HALT}
- **Phase-Count:** {1 | number of phases | N/A if HALT}
- **Audited-By:** {agent name}
- **Timestamp:** {YYYY-MM-DD HH:MM:SS}

**Operations Breakdown:**
| # | Operation | Tier | Weight |
|---|-----------|------|--------|
| 1 | {description} | {tier} | {pts} |
| 2 | {description} | {tier} | {pts} |

**Execution Plan:**
- Phase 1 — Gather: {operations list}
- Phase 2 — Analyze: {operations list}
- Phase 3 — Output: {operations list}

**Fallback Assets:**
| Resource | Tier | Static Alternative | Preferred Format |
|----------|------|--------------------|------------------|
| {resource} | {tier} | {alternative} | {format} |

**Status:** {Awaiting human approval | Approved | Executing | Complete}
```

### When Verdict is SINGLE-PROMPT OK

The Execution Plan and Fallback Assets sections can be simplified:

```markdown
**Execution Plan:** Single prompt — no phasing required.
**Fallback Assets:** None required.
**Status:** Approved (auto)
```

### When Verdict is HALT

```markdown
**Execution Plan:** HALTED — complexity exceeds safe threshold.
**Fallback Assets:** {list all Tier 3/4 resources with alternatives}
**Status:** Awaiting human decision
```

---

## Post-Audit Actions

1. **Append** the audit block to `bridge-queue.md` below the request
2. **Update** `bridge-state.json`:
   - Set `preflight.last_audit` to current timestamp
   - Set `preflight.last_score` to the complexity score
   - Set `preflight.last_verdict` to the verdict
   - Set `preflight.last_request_id` to the request ID
3. **Log** the audit to `.bridge/session-log.md`:
   ```
   ## [TIMESTAMP] [AGENT] — Pre-Flight Audit: REQ-XXXX
   **Action:** Ran pre-flight complexity audit
   **Result:** Score {N}, Verdict: {verdict}
   **Context:** {brief description of operations identified}
   ```
4. **If SINGLE-PROMPT OK:** Proceed to execute immediately
5. **If PHASED:** Wait for human approval before executing Phase 1
6. **If HALT:** Set `flags.needs_human: true` in `bridge-state.json`, do NOT execute

---

## Integration

- **Referenced by:** `BRIDGE-PROTOCOL.md` (Pre-Flight Complexity Audit section)
- **Enforced by:** `HS-UDO-010` in `HARD_STOPS.md`
- **Circuit breaker:** Score >10 triggers HALT in `ORCHESTRATOR.md` circuit breaker table
- **Command:** `Pre-flight [REQ-XXXX]` / shortcut `pf` in `COMMANDS.md`
