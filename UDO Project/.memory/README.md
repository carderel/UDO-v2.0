# Memory Management

This directory manages all session memory and knowledge state for the project.

## Memory Types

### Canonical Memory
**Location**: `.memory/canonical/`

Persistent, authoritative knowledge that persists across sessions. This is the single source of truth for project state and key learnings. Use for:
- Framework learnings and insights
- Key decisions and their rationale
- Permanent project metadata
- Established patterns and anti-patterns

### Working Memory
**Location**: `.memory/working/`

Session-scoped memory that spans multiple prompts within a single session. Cleared at session end. Use for:
- Intermediate work products
- Session-specific context
- Temporary hypotheses
- Session progress tracking

### Disposable Memory
**Location**: `.memory/disposable/`

Ultra-short-term memory for immediate operations. Cleared frequently. Use for:
- Prompt-to-prompt context
- Temporary calculations
- Immediate decision context
- Debugging information

## Protocol

- **Canonical**: Append-only, updates only via explicit protocol (HS-UDO-009)
- **Working**: Lives one session, cleared on handoff
- **Disposable**: Cleared frequently, ephemeral by design

## See Also

- ORCHESTRATOR.md - Full memory protocol
- HARD_STOPS.md - Memory constraints
