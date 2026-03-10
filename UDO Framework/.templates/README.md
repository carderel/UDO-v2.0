# .templates/

## What It Is

This folder contains reusable document templates for consistent structure across the project.

## What It Does

Templates provide standardized formats for:
- Agent definitions
- Session logs
- Handoff documents
- Error reports
- Evidence packets
- Teach-back documents
- And more

Instead of inventing structure each time, AI uses templates to ensure consistency and completeness.

## Why It's Included

**Problem:** Every time AI creates a document, it invents a new structure. Session logs look different. Handoffs miss critical info. Inconsistency makes documents harder to use and audit.

**Solution:** Define templates once. AI uses them every time. Documents are consistent, complete, and predictable.

## Structure

```
.templates/
├── agent.md                # Agent definition template
├── session.md              # Session log template
├── handoff.md              # Handoff document template
├── error.md                # Error report template
├── canonical-fact.md       # Verified fact template
├── archive-summary.md      # Archive summary template
├── reasoning-handoff.md    # RC mode handoff template
├── evidence-packet.md      # Evidence packet template
├── teach-back.md           # Teach-back template
└── README.md               # This file
```

## Template Contents

Each template includes:
- Required sections with placeholders
- Field descriptions
- Example content where helpful
- Checklist for completion

## How Templates Are Used

1. AI identifies need for document type
2. AI reads corresponding template
3. AI creates document following template structure
4. AI fills in all required fields
5. Document saved to appropriate location

## Example: Session Template

```markdown
# Session: {SESSION_ID}

**Date:** {DATE}
**Phase:** {PHASE}
**Status:** {ACTIVE/COMPLETE}

## Orientation
- [ ] Read PROJECT_STATE.json
- [ ] Read previous session log
- [ ] Confirmed current phase and todos

## Work Completed
{List of completed todos with outcomes}

## Decisions Made
{Key decisions and rationale}

## Blockers Encountered
{Any blockers and how they were resolved}

## Handoff Notes
{Context for next session}
```

## Adding Custom Templates

For project-specific document types:

1. Create `{template-name}.md` in `.templates/`
2. Define required sections
3. Add placeholders: `{FIELD_NAME}`
4. Include completion checklist
5. Reference in project documentation

## Templates vs Rules

| Templates | Rules |
|-----------|-------|
| Structure for documents | Constraints on behavior |
| "What sections to include" | "What to do/not do" |
| Format consistency | Quality standards |
