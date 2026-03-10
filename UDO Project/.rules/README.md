# Project Rules

Project-specific rules and standards that extend the UDO framework.

## Purpose

While the UDO framework provides global standards, each project may define additional rules:
- Domain-specific standards
- Custom protocols
- Project-specific constraints
- Integration requirements

## Rule Categories

Suggested organization:
- `code-standards.md` - Code quality and style
- `data-validation.md` - Data handling requirements
- `content-guidelines.md` - Writing and documentation standards
- `security-rules.md` - Security and compliance
- `integration-rules.md` - Integration protocols

## Rule Format

Each rule file should include:
- Clear rule statement
- Rationale and context
- Examples and exceptions
- Enforcement method
- Last updated date

## Relationship to Framework

- **Framework rules** (HARD_STOPS.md) are mandatory
- **Project rules** (here) supplement framework rules
- Project rules cannot override framework rules
- When conflict exists, framework rules take precedence

## Enforcement

Rules are enforced via:
- Code review
- Automated linting (where applicable)
- Agent guidelines (in instructions)
- Session audits

## See Also

- UDO Framework/HARD_STOPS.md - Framework rules
- UDO Framework/ORCHESTRATOR.md - Framework standards
