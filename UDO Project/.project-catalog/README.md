# Project Catalog

Central record-keeping system for all project operations and decisions.

## Subdirectories

### Sessions
**Location**: `.project-catalog/sessions/`

Complete logs of all work sessions. Each session has:
- Timestamp and duration
- Agent(s) involved
- Work completed
- State snapshots
- Handoff notes

Session files: `{date}-{agent}-session.md`

### Decisions
**Location**: `.project-catalog/decisions/`

Record of all significant project decisions with:
- Decision statement
- Context and rationale
- Alternatives considered
- Decision date
- Responsible party
- Approval status

Decision files: `{date}-{title}.md`

### Backups
**Location**: `.project-catalog/backups/`

Project state snapshots for recovery:
- Full backups (via `bu` command)
- Checkpoints at critical milestones
- Timestamped for version control

### Checkpoints
**Location**: `.project-catalog/checkpoints/`

Operational checkpoints:
- Mid-session saves
- Pre-handoff snapshots
- Recovery points

## Usage

All entries use:
- ISO 8601 dates (YYYY-MM-DD)
- Clear, descriptive titles
- Complete context and metadata

## Protocols

See HARD_STOPS.md for catalog entry requirements and validation rules.

## See Also

- ORCHESTRATOR.md - Full project operations protocol
- PROJECT_STATE.json - Current status summary
