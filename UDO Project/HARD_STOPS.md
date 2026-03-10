# Project Hard Stops

This document extends the UDO Framework hard stops with project-specific constraints.

## Framework Hard Stops

The project inherits all framework hard stops from `UDO Framework/HARD_STOPS.md`:

- HS-UDO-001 through HS-UDO-009 (mandatory)
- See framework documentation for full details

## Project-Specific Hard Stops

Add project-specific boundaries here:

### Template

```
PROJECT_HS_{NUMBER}: [Title]

Description: [What is restricted]
Rationale: [Why this matters]
Enforcement: [How this is checked]
Exception process: [If any exceptions are allowed, how]
```

### Example Structure

```
PROJECT_HS_001: [Your first rule]
- Description: ...
- Rationale: ...
- Enforcement: ...
```

## Relationship to Framework

- All framework hard stops (HS-UDO-001 through HS-UDO-009) are **mandatory**
- Project hard stops **extend** framework rules, not replace them
- When conflict exists, framework rules take precedence
- Project rules add domain-specific constraints

## Enforcement

Hard stops are enforced via:
- Pre-session review (agent reads before starting work)
- Mid-session checks (agent verifies during work)
- Post-session audit (session log references)
- Handoff protocol (constraints communicated to successor)

## Updates

When adding new hard stops:
1. Document clearly with rationale
2. Communicate to all agents
3. Update session logs
4. Note decision in .project-catalog/decisions/

## See Also

- `UDO Framework/HARD_STOPS.md` - Framework hard stops
- `UDO Framework/ORCHESTRATOR.md` - Full protocol
