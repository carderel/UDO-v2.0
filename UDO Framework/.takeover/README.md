# .takeover/

## What It Is

This folder contains the Takeover Module — a systematic approach for AI to audit and understand existing projects.

## What It Does

When you point AI at an existing codebase or project, Takeover provides:
- Structured discovery process
- Specialized auditor agents
- Evidence collection
- Findings consolidation
- Knowledge capture for ongoing work

Instead of AI making assumptions about unfamiliar code, Takeover forces systematic investigation.

## Why It's Included

**Problem:** AI dropped into an existing project makes assumptions. It misses critical context. It breaks things because it doesn't understand dependencies. It gives confident but wrong answers about code it hasn't actually analyzed.

**Solution:** Formal takeover process. Spawn auditor agents. Collect evidence. Build understanding systematically before taking action.

## Structure

```
.takeover/
├── TAKEOVER_ORCHESTRATOR.md    # Main takeover protocol
├── discovery.json              # What to investigate
├── scope-config.json           # Boundaries of audit
├── agent-templates/            # Auditor agent definitions
│   ├── structure-auditor.md
│   ├── documentation-auditor.md
│   ├── code-quality-auditor.md
│   ├── security-auditor.md
│   └── test-auditor.md
├── audits/                     # Completed audit reports
├── evidence/                   # Supporting evidence
└── README.md                   # This file
```

## Takeover Process

### Phase 1: Discovery
- Map project structure
- Identify key files and directories
- Catalog technologies and dependencies
- Note documentation locations

### Phase 2: Audit
Spawn specialized auditors:

| Auditor | Focus |
|---------|-------|
| Structure | Architecture, organization, patterns |
| Documentation | README, comments, docs quality |
| Code Quality | Standards, complexity, maintainability |
| Security | Vulnerabilities, auth, data handling |
| Test | Coverage, test quality, CI/CD |

### Phase 3: Synthesis
- Consolidate findings
- Identify critical issues
- Create action recommendations
- Capture in canonical memory

### Phase 4: Handoff
- Update PROJECT_STATE.json with findings
- Create LESSONS_LEARNED entries
- Prepare for ongoing work

## When to Use Takeover

- Inheriting an existing codebase
- Joining a project mid-stream
- Auditing unfamiliar code
- Due diligence on acquisitions
- Security/quality assessments

## Auditor Agents

Each auditor is a specialized agent with:
- **Scope** — What to examine
- **Methods** — How to investigate
- **Outputs** — What to produce
- **Evidence** — What to collect

Example: `structure-auditor.md`
```markdown
# Structure Auditor

## Scope
- Directory organization
- Module/package structure
- Dependency graph
- Entry points

## Methods
1. Map directory tree
2. Identify patterns (MVC, microservices, etc.)
3. Trace imports/dependencies
4. Locate configuration files

## Outputs
- Structure diagram
- Pattern identification
- Dependency map
- Recommendations

## Evidence
- File listings
- Import traces
- Config file contents
```

## Audit Reports

Completed audits go in `audits/`:
```
audits/
├── structure-audit-2026-02-06.md
├── security-audit-2026-02-06.md
└── consolidated-findings.md
```

## Integration with UDO

After takeover:
- Findings become canonical facts in `.memory/canonical/`
- Issues become todos in PROJECT_STATE.json
- Lessons go to LESSONS_LEARNED.md
- Evidence preserved in `.takeover/evidence/`
