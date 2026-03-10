# Browser Execution Ladder

## Purpose

Mandatory escalation order for browser-based read operations. Forces cheapest-first execution to minimize rate-limit hits, context consumption, and timeout risk. Every browser read starts at the cheapest level and only escalates when the current level fails or is insufficient.

**Reference name:** `BROWSER-LADDER` — use this name to reference this protocol in any bridge prompt.

---

## When It Applies

- **Any** browser-based read operation, regardless of request category
- **MANDATORY** for `browser-task` and `web-research` request categories
- Enforced by **HS-UDO-011**

If a bridge request involves reading data from a web page, the Browser Execution Ladder governs the approach. No exceptions.

---

## Escalation Levels

### Level 1 — Screenshot

Capture a screenshot of the rendered page. Attempt to extract the needed data visually.

- **Cost:** Low (single capture)
- **When it works:** Static content, simple tables, visible text, charts with labels
- **When it fails:** Dense data, small text, content below the fold, dynamic/interactive elements

### Level 2 — Page Text Extraction

Extract raw text content from the page. No DOM traversal — just the text layer.

- **Cost:** Low-medium
- **When it works:** Text-heavy pages, articles, simple lists
- **When it fails:** Data in tables that lose structure, canvas-rendered content, JavaScript-generated text

### Level 3 — Targeted DOM Query

Query a specific element or region of the page DOM. **Never** query the full DOM tree.

- **Cost:** Medium
- **When it works:** Known element IDs/classes, specific tables, form fields, structured data regions
- **When it fails:** Dynamically loaded content, shadow DOM, iframes, deeply nested structures

### Level 4 — Full Accessibility Tree

Read the full accessibility tree of the page. Scope to a region if possible.

- **Cost:** High (large context consumption)
- **When it works:** Complex SPAs where targeted queries miss content, dynamic UI elements
- **When it fails:** Canvas-rendered content (no accessibility tree), extremely large pages

### Level 5 — Static Fallback Request

All automated options are exhausted. Flag to the user with the preferred static format.

- **Cost:** Zero (human provides data)
- **Action:** Request the user to export the data manually (CSV, XLSX, PDF, copy-paste) and place it in the project directory
- **This is the terminal level** — no further automated escalation

---

## Escalation Rules

1. **Sequential execution** — start at Level 1, proceed upward only on failure or insufficiency
2. **No skipping** — unless Page Type Rules (below) explicitly permit it
3. **Log every escalation** — record the level attempted, the outcome (PASS/FAIL/SKIP), and the reason
4. **Sufficient = stop** — if a level yields the required data, stop. Do not continue escalating
5. **Partial success** — if a level yields partial data, note what was obtained and escalate for the remainder only

---

## Page Type Rules

Different page types have known characteristics that allow skipping levels that are guaranteed to fail. These are the **only** permitted skip exceptions.

| Page Type | Ladder Behavior |
|-----------|----------------|
| **Looker / Data Studio** | Level 1 attempt → skip to Level 5. Canvas rendering blocks Levels 2-4. Request CSV/XLSX export from user. |
| **Google Sheets (browser)** | Level 1 → Level 3 (scoped to visible range). If Level 3 fails → XLSX fallback (Level 5). Skip Level 4. |
| **Simple static HTML** | Level 1 or Level 2 sufficient. Rarely needs Level 3+. |
| **Auth-required pages** | Level 1 attempt (may capture login wall) → Level 5 (request data from user). Levels 2-4 will fail without auth. |
| **JavaScript SPAs** | Level 1, skip Level 2 (text extraction unreliable), Level 3 (scoped DOM), Level 4 if needed. |

### How to Identify Page Type

- **URL patterns:** `lookerstudio.google.com`, `datastudio.google.com` → Looker/Data Studio
- **URL patterns:** `docs.google.com/spreadsheets` → Google Sheets
- **Login redirects or auth prompts in screenshot** → Auth-required
- **Page loads blank then populates** → JavaScript SPA
- **Static content visible immediately** → Simple static HTML
- **When uncertain:** Treat as unknown — follow full sequential ladder

---

## Escalation-Log Format

Every browser read operation must produce an escalation log. Append to the bridge response.

```markdown
**Escalation-Log:**
| Level | Action | Result | Reason |
|-------|--------|--------|--------|
| 1 — Screenshot | Captured page | PASS | Data extracted from visible table |
```

```markdown
**Escalation-Log:**
| Level | Action | Result | Reason |
|-------|--------|--------|--------|
| 1 — Screenshot | Captured page | FAIL | Data too dense, text unreadable at screenshot resolution |
| 2 — Text extraction | Extracted raw text | FAIL | Table structure lost, columns misaligned |
| 3 — DOM query | Queried table#sales-data | PASS | All 3 columns extracted successfully |
```

```markdown
**Escalation-Log:**
| Level | Action | Result | Reason |
|-------|--------|--------|--------|
| 1 — Screenshot | Captured dashboard | FAIL | Canvas-rendered charts, no extractable text |
| 2-4 | — | SKIP | Page type: Looker (canvas rendering blocks Levels 2-4) |
| 5 — Static fallback | Requested CSV export from user | PENDING | Awaiting user-provided file |
```

---

## Integration

- **Referenced by:** `BRIDGE-PROTOCOL.md` (Browser Execution Ladder section)
- **Enforced by:** `HS-UDO-011` in `HARD_STOPS.md`
- **Circuit breaker:** Reaching Level 5 triggers "flag to user" in `ORCHESTRATOR.md` circuit breaker table
- **Adapter-specific rules:** See `adapters/claude-desktop/adapter.md` for Claude Desktop page type behavior
- **Escalation log included in:** Bridge response template (`templates/bridge-response.md`)
