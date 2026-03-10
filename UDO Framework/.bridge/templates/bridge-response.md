# Bridge Response Template

Use this format when responding to a request in `bridge-queue.md`. Append directly below the request you are responding to.

---

```markdown
### Response — {YYYY-MM-DD HH:MM:SS}
- **From:** {RESPONDING_AGENT}
- **Status:** {COMPLETED | FAILED | NEEDS_CLARIFICATION}
- **Escalation-Log:** {browser ladder levels attempted and outcomes, or N/A}

{Results, findings, files created, actions taken.
Be specific. Include file paths, data found, commands run.
If FAILED: explain what went wrong and what was tried.
If NEEDS_CLARIFICATION: list exactly what information is missing.}

### Follow-up Needed
{Next steps the requesting agent should take, or NONE.}
```

---

## After Responding

1. Update the request's **Status** field to match your response status
2. Update `bridge-state.json`:
   - Decrement `pending_requests` if COMPLETED or FAILED
   - Update `last_updated`, `last_updated_by`, and your `*_last_seen` timestamp
   - Set `status` to `idle` if no more pending requests
3. Log the action in `session-log.md`
4. If browser operations were involved, document the escalation log (see `BROWSER-LADDER.md`). Include the `Escalation-Log` table showing levels attempted, outcomes, and reasons for each escalation or skip.
